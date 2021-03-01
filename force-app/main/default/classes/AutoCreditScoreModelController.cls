//Sample Applicant Ids are a15f0000002F8z5AAC 	a15f0000002F9sIAAS
public class AutoCreditScoreModelController {

    //----- SUMMARY OF MODEL PARAMETERS ----//
    //Date of Application
    public date dateOfApplication{get;set;}
    public String dateString{get;set;}
    
    //Application ID
    public String applicationIdString{get;set;}
    
    //Credit Product
    public String productCategry{get; set;}
    public String productCategryToDisplay{get; set;}
    
    //Loan Amount
    public Double loanAmt{get; set;}
    
    //Loan Limit
    public Decimal loanAmtLimit{get; set;}
    
    //Number of Applicant(s)
    public String totalNumberOfApplicants{get; set;}
    
    //----- SUMMARY OF PERSONAL CREDIT SCORING MODEL ----//
    //Name of Applicant
    public String nameOfApplicant{get; set;}
    
    //Is the Applicant a Politcally Exposed Person (PEP)?*
    public String isApplicantPolicExpoxed {get; set;}
    
    //Tax Registration Number:*
    public String jamaicanTaxNumber {get; set;}
    
    //Has the sanction screening(s) resulted in a negative trace?*
    public String hasSanctionNegativeTrace {get; set;}
    
    //Primary Income Type:*
    public String primaryEmploymentType {get; set;}
    
    //Assessed Monthly Income:*
    public Decimal grossMonthlyIncome {get; set;}
    
    //---INPUT RESPONSES----//
    //Age 
    public String ageString{get; set;}
	public Decimal ageScore{get; set;}
	public Decimal ageWeightage{get; set;}    
    
    //Education
    public String educationString{get; set;}
	public Decimal educationScore{get; set;}
	public Decimal educationWeightage{get; set;}
    
    //Residential Status
    public String statusOfAddressString{get; set;}
    public Decimal statusOfAddressScore{get; set;}
	public Decimal statusOfAddressWeightage{get; set;}
    
    //Years at Current Residence
    public String yearsAtResidentString{get; set;}
    public Decimal yearsAtResidentScore{get; set;}
	public Decimal yearsAtResidentWeightage{get; set;}
    
    //Credit History in the last 24 months
    public String creditHistoryLast24Months {get; set;}
    public Decimal creditHistoryLast24Score{get; set;}
	public Decimal creditHistoryLast24Weightage{get; set;}
    
    //Net Worth 
    public String assessmentOfApplicantNetWorth {get; set;}
    public Decimal assessmentOfApplicantNetWorthScore{get; set;}
	public Decimal assessmentOfApplicantNetWorthWeightage{get; set;}
    
    //Employment Status 
    public String emplStatus {get; set;}
    public Decimal emplStatusScore{get; set;}
	public Decimal emplStatusWeightage{get; set;}
    
    //Industry of Employment
    public String industryName {get; set;}
    public Decimal industryNameScore{get; set;}
	public Decimal industryNameWeightage{get; set;}
    
    //Length of Current Employment 
    public String lengthOfEmploymentString{get; set;}
    public Decimal lengthOfEmploymentScore{get; set;}
	public Decimal lengthOfEmploymentWeightage{get; set;}
    
    //Professional Category 
    public String professionalCategory {get; set;}
    public Decimal professionalCategoryScore{get; set;}
	public Decimal professionalCategoryWeightage{get; set;}
        
    //---COLLATERAL DETAILS  INPUT RESPONSES -----//
    //Collateral 
    public String collateralName {get; set;}
    public Decimal collateralScore{get; set;}
	public Decimal collateralWeightage{get; set;}
    
    //Loan To Value 
    public String loanToValue {get; set;}
    public Decimal loanToValueScore{get; set;}
    public Decimal loanToValueValue {get; set;}
	public Decimal loanToValueWeightage{get; set;}
    
    //Ability to Service 
    public String abilityToService {get; set;}
    public Decimal abilityToServiceValue {get; set;}
    public Decimal abilityToServiceScore{get; set;}
	public Decimal abilityToServiceWeightage{get; set;}
    
    //Repayment Method 
    public String repaymntMethod {get; set;}
    public Decimal repaymntMethodScore{get; set;}
	public Decimal repaymntMethodWeightage{get; set;}
    
    //Total Weighted Score 
    public Decimal totalWeightedScore {get; set;}
    
    //Credit Risk Rating like R1, R2 etc 
    public String creditRiskRatingValue {get; set;}
    
    public Id applicantId{get;set;}
    public Applicant__c applicantObject{get; set;}
    public Loan_Calculator__c loanCalculator {get; set;}
    public Account personAccount {get; set;}
       
    Public SubCriteriaOptionWrapper subCritOptionWrpr;
    Public CreditScoreModelWrapper creditScoreMdlWrpr;
    
    public Decimal fnalScore{get; set;} 
    
    public AutoCreditScoreModelController(){        
        //Form the date of application value to display in vf page
        dateOfApplication = date.today();
        dateString = dateOfApplication.format();
        
        //Get applicant id from URL
        applicantId = ApexPages.currentPage().getParameters().get('Id');
        if(applicantId!=Null){
        
            //Get applicant objects by using the applicant id from URL
            applicantObject = getApplicant(applicantId);
    		ApplicantWrapper applicantWrp = new ApplicantWrapper(applicantObject);
            
            //Get account objects
            personAccount = getAccount(applicantObject.Account__c);
            
            //Get product Category Value
            productCategry = getProductCategory(applicantObject.Opportunity__c);
            formatProductCatg(productCategry);
            
            //Get Loan Amount/Limit Value
            getLoanCalculationApplicantProduct(applicantObject.Opportunity__c, applicantId, applicantObject.Opportunity__r.Product_Details__c);
            
            //Get Jamaican Tax Number Value
            jamaicanTaxNumber = personAccount.Jamaican_Tax_Registration_Number__pc;
            
            //Get formatted Application ID Value
            applicationIdString = formApplicationId(productCategry, jamaicanTaxNumber, dateString);
            
            //Get Name of Applicant Value
            nameOfApplicant = personAccount.Name;
            
            //Get value - Is the Applicant a Politcally Exposed Person (PEP)?* 
            if(personAccount.Political_Exposure__pc == True){
                isApplicantPolicExpoxed = 'Yes';    
            }else{
                isApplicantPolicExpoxed = 'No';    
            }
            
            //Get value - Has the sanction screening(s) resulted in a negative trace?*
            hasSanctionNegativeTrace = applicantObject.Sanction_Screening_has_Negative_Trace__c;
                        
            //Get the value of Assessed Monthly Income:
            grossMonthlyIncome = applicantObject.Gross_Monthly_IncomeC__c;
            
            //Get the Number of Applicant(s):
            totalNumberOfApplicants = getNumberOfApplicants(applicantObject.Opportunity__c);

            //Get the value of Credit History in the last 24 months
            ProductDetailService prdDetailSrv = new ProductDetailService();
                        
            creditHistoryLast24Months= prdDetailSrv.getSubCriteriaOption(Constants.CREDIT_HISTORY, applicantObject.Credit_History_in_last_24_Months__c);    
            
            //Get the value of Net Worth 
            assessmentOfApplicantNetWorth = prdDetailSrv.getSubCriteriaOption(Constants.NET_WORTH, applicantObject.Assessment_of_Applicant_Net_Worth__c);

            subCritOptionWrpr = ProductDetailService.getSubcriteriaOptionsForApplicant(applicantObject.Opportunity__c, applicantWrp);
            subCritOptionWrpr.collateral = collateralName;
            subCritOptionWrpr.loanToValue = loanToValueValue;
            subCritOptionWrpr.ablitityToService = abilityToServiceValue;
            subCritOptionWrpr.repaymentMethod = repaymntMethod;
            
            CreditScoreModelWrapper creditWrapper = new CreditScoreModelWrapper(subCritOptionWrpr); 
            
            ageString = prdDetailSrv.getSubCriteriaOption(Constants.AGE, String.ValueOf(subCritOptionWrpr.age));            
            educationString = prdDetailSrv.getSubCriteriaOption(Constants.EDUCATION, subCritOptionWrpr.education);
            statusOfAddressString = prdDetailSrv.getSubCriteriaOption(Constants.STATUS_OF_ADDRESS, subCritOptionWrpr.residentialStatus);
            yearsAtResidentString = prdDetailSrv.getSubCriteriaOption(Constants.YEARS_AT_RESIDENCE, String.valueOf(subCritOptionWrpr.yearsAtCurrentResidence));
            primaryEmploymentType = subCritOptionWrpr.employmentType;    
            emplStatus = prdDetailSrv.getSubCriteriaOption(Constants.EMPLOYMENT_STATUS, subCritOptionWrpr.employmentStatus);
            industryName = prdDetailSrv.getSubCriteriaOption(Constants.INDUSTRY, subCritOptionWrpr.industryOfEmployment);
            lengthOfEmploymentString = prdDetailSrv.getSubCriteriaOption(Constants.LENGTH_OF_EMPLOYMENT, String.valueOf(subCritOptionWrpr.lengthOfCurrentEmployment));
            professionalCategory = prdDetailSrv.getSubCriteriaOption(Constants.PROFESSIONAL_CATEGORY, subCritOptionWrpr.professionalCategory);     
            
            //Assign the value of Score and Weightage to each row  
            assignScoreaAndWeightage(creditWrapper.fieldScoreMap);
            
            //Get the value in Total Weighted Score
            totalWeightedScore = creditWrapper.finalScore;
            
            //Get the value in Credit Risk Rating 
            creditRiskRatingValue = creditWrapper.riskRating.rating;
        }
    } 
    
    private void assignScoreaAndWeightage(Map<String, List<Decimal>> mapOfScoreWeightage){
        list<Decimal> lstOfScoreAndWeight;
                        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.AGE);
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    ageScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    ageWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        } 
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.EDUCATION);
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    educationScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    educationWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        } 
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.STATUS_OF_ADDRESS);
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    statusOfAddressScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    statusOfAddressWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.YEARS_AT_RESIDENCE);
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    yearsAtResidentScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    yearsAtResidentWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
       lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.CREDIT_HISTORY);
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    creditHistoryLast24Score = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    creditHistoryLast24Weightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.NET_WORTH); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    assessmentOfApplicantNetWorthScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    assessmentOfApplicantNetWorthWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.EMPLOYMENT_STATUS); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    emplStatusScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    emplStatusWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.INDUSTRY); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    industryNameScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    industryNameWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.LENGTH_OF_EMPLOYMENT); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    lengthOfEmploymentScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    lengthOfEmploymentWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.PROFESSIONAL_CATEGORY); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    professionalCategoryScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    professionalCategoryWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.COLLATERAL); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    collateralScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    collateralWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.LOAN_TO_VALUE); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    loanToValueScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    loanToValueWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }

        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.ABILITY_TO_SERVICE); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    abilityToServiceScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    abilityToServiceWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
        lstOfScoreAndWeight = mapOfScoreWeightage.get(Constants.REPAYMENT_METHOD); 
        if(lstOfScoreAndWeight!= Null){
            if(lstOfScoreAndWeight.size()>0){
                if(lstOfScoreAndWeight.get(0)!=Null){
                    repaymntMethodScore = lstOfScoreAndWeight.get(0);    
                }
                if(lstOfScoreAndWeight.get(1)!=Null){
                    repaymntMethodWeightage = lstOfScoreAndWeight.get(1);    
                }
            }    
        }
        
    }
    
    private Applicant__c getApplicant(Id applicantId){
        Applicant__c applicantObjectInstance;
        
        applicantObjectInstance = [SELECT 
                                        Credit_History_in_last_24_Months__c,
                                   		Sanction_Screening_has_Negative_Trace__c,
                                        Assessment_of_Applicant_Net_Worth__c,
                                        Statutory_Deductions_Numbers__c,
                                        Rent_Strata_Maintenance__c,
                                        Personal_Expenses_Monthly_Prior_Loan__c,
                                        Savings_Pension_Insurance_Number__c,
                                        Real_Estate_Monthly_Payment_Number__c,
                                        Motor_Vehicle_Monthly_Payment_Number__c,
                                        Other_Asset_Monthly_Payment_Number__c,
                                        Other_Loan_Monthly_Payment_Number__c,
                                        Gross_Monthly_Income__c,
                                        Account__r.PersonBirthdate,
                                        Rent_Board_Monthly_Prior_Loan__c,
                                        Rent_Board_Monthly_After_Loan__c,
                                        Gross_Monthly_IncomeC__c,
                                        Strata_Maintenance_Monthly_Prior_Loan__c,
                                        Strata_Maintenance_Monthly_After_Loan__c,
                                   		Opportunity__c,
                                   		Opportunity__r.Product_Details__c,
                                   		Account__c,
                                   		CurrencyIsoCode
                                   FROM Applicant__c 
                                   WHERE Id =:applicantId];
            				
        if(applicantObjectInstance!=Null){
            return applicantObjectInstance;
        }else{
            return Null;
        }
    }
    
    private String getNumberOfApplicants(Id oppId){
        string numberOfApp = '';
        Opportunity applicantOpp;
        applicantOpp = [SELECT Number_of_Applicants__c 
                       FROM Opportunity 
                       WHERE id=: oppId];
        
        if(applicantOpp!=Null){
            if(applicantOpp.Number_of_Applicants__c!=Null){
               numberOfApp = String.valueOf(applicantOpp.Number_of_Applicants__c);
            }
        }
        Return numberOfApp;
    }
        
    private Account getAccount(Id accountId) {
        Account accountObj = [SELECT Status_of_Address__c,
                              		Status_of_Address__pc,
                              		Years_at_Residence__pc,
                              		Highest_Level_of_Education_attained__pc,
                              		FinServ__Age__pc,
                              		PersonBirthdate,
                              		Name,
                              		Political_Exposure__pc,
                              		Jamaican_Tax_Registration_Number__pc
                              
                              FROM Account
                              WHERE Id = :accountId];
        if (accountObj != null) {
            return accountObj;
        }else{
            return Null;   
        }
    }
    
    private string getProductCategory(Id oppId){
        list<OpportunityLineItem> oppProductCtg = new List<OpportunityLineItem>();
        string productCtg='';
        
        oppProductCtg = [SELECT Product_Family__c 
                         FROM OpportunityLineItem 
                         WHERE OpportunityId =:oppId];
        
        if(oppProductCtg!=Null){
            if(oppProductCtg.size() > 0){
                productCtg = oppProductCtg.get(0).Product_Family__c; 
            }
        }
        
        return productCtg;
    }
    
    private string formApplicationId(string prodctCtg, string jmcnTaxNumber, string dateOfApplication){
        string formattedApplicationID ='';
        if(prodctCtg == Constants.AUTO_PRODUCT_FAMILY){
            formattedApplicationID = 'C1-'+jmcnTaxNumber+'-'+dateOfApplication; 
        }else if(prodctCtg == Constants.CREDITCARD_PRODUCT_FAMILY){
            formattedApplicationID = 'C4-'+jmcnTaxNumber+'-'+dateOfApplication;
        }else if(prodctCtg == Constants.UNSECURED_PRODUCT_FAMILY){
            formattedApplicationID = 'C3-'+jmcnTaxNumber+'-'+dateOfApplication;
        }else if(prodctCtg == Constants.LINEOFCREDIT_PRODUCT_FAMILY){
            formattedApplicationID = 'C5-'+jmcnTaxNumber+'-'+dateOfApplication;
        }
        return formattedApplicationID;
    }
    
    private void formatProductCatg(string prodctCtg){
        productCategryToDisplay='';
        if(prodctCtg == Constants.AUTO_PRODUCT_FAMILY){
            productCategryToDisplay = Constants.AUTO_PRODUCT_FAMILY_FOR_DISPLAY; 
        }else if(prodctCtg == Constants.CREDITCARD_PRODUCT_FAMILY){
            productCategryToDisplay = Constants.CREDITCARD_PRODUCT_FAMILY_FOR_DISPLAY;
        }else if(prodctCtg == Constants.UNSECURED_PRODUCT_FAMILY){
            productCategryToDisplay = Constants.UNSECURED_PRODUCT_FAMILY_FOR_DISPLAY;
        }else if(prodctCtg == Constants.LINEOFCREDIT_PRODUCT_FAMILY){
            productCategryToDisplay = Constants.LINEOFCREDIT_PRODUCT_FAMILY_FOR_DISPLAY;
        }
    }
        
    private void getLoanCalculationApplicantProduct(Id oppId, Id applicantId, id loanCalculatorId){
        list<Loan_Calculation_Applicant_Product__c> applicantLoanCalPrdct;
        list<Loan_Calculator__c> loanCalculator;
        list<Loan_Calculation_Product__c> loanCalPrdct; 
            
        applicantLoanCalPrdct = [SELECT Loan_Amount_Number__c 
                                 FROM Loan_Calculation_Applicant_Product__c 
                                 WHERE Applicant_Id__c=: applicantId];
        if(applicantLoanCalPrdct!=Null){
            if(applicantLoanCalPrdct.size() > 0){
                loanAmt = applicantLoanCalPrdct.get(0).Loan_Amount_Number__c;        
            }
        }
        
        loanCalPrdct = [SELECT Requested_Credit_Limit_Number__c, 
                        		Collateral_Type_List__c, 
                        		Loan_to_Value_Number__c, 
                        		Ability_to_Service_Before_Number__c, 
                        		Repayment_Method_List__c 
                        FROM Loan_Calculation_Product__c 
                        WHERE Loan_Calculation_Id__c =: loanCalculatorId]; 
        if(loanCalPrdct != Null){
            if(loanCalPrdct.size()>0){
                
                loanAmtLimit = 0;
                collateralName ='';
                loanToValue = '';
                abilityToService = '';
                repaymntMethod = '';
                
                if(loanCalPrdct.get(0).Requested_Credit_Limit_Number__c!=Null){
                    loanAmtLimit = loanCalPrdct.get(0).Requested_Credit_Limit_Number__c;             
                }
                if(loanCalPrdct.get(0).Collateral_Type_List__c!=Null){
                    collateralName = loanCalPrdct.get(0).Collateral_Type_List__c;             
                }
                if(loanCalPrdct.get(0).Loan_to_Value_Number__c!=Null){
                    loanToValueValue = loanCalPrdct.get(0).Loan_to_Value_Number__c;
                    loanToValue = String.ValueOf(loanCalPrdct.get(0).Loan_to_Value_Number__c);             
                }
                if(loanCalPrdct.get(0).Ability_to_Service_Before_Number__c!=Null){
                    abilityToServiceValue = loanCalPrdct.get(0).Ability_to_Service_Before_Number__c;
                    abilityToService = String.ValueOf(loanCalPrdct.get(0).Ability_to_Service_Before_Number__c);             
                }
                if(loanCalPrdct.get(0).Repayment_Method_List__c!=Null){
                    repaymntMethod = loanCalPrdct.get(0).Repayment_Method_List__c;             
                }
            }
        }
    }
}