/**
 * @description       :
 * @author            : Ishwari Gaikwad(Thinqloud)
 * @group             :
 * @last modified on  : 06-21-2021
 * @last modified by  : Remario Richards
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   06-14-2021   Ishwari Gaikwad(Thinqloud)   Initial Version
 **/
public class OneJNSerializerDecision {
  /**
   * @description : preparing the serialiser as per the event type
   * @author Ishwari Gaikwad(Thinqloud) | 06-14-2021
   * @param serialiser
   * @param eventType
   * @return Map<String, Object>
   **/
  public class Application {
    /**
     * @description : serialize get application event
     * @author Trupti Zende (Thinqloud) | 06-21-2021
     * @param serialiser
     * @param eventType
     * @return Map<String, Object>
     **/
    public Map<String, Object> serialize(
      OneJNSerializer serialiser,
      String eventType
    ) {
      Map<String, Object> JSONToSerialize = new Map<String, Object>();
      JSONToSerialize.put('ProductType', serialiser.AppData.ProductType);
      JSONToSerialize.put('PhoenixId', serialiser.AppData.PhoenixId);

      return JSONToSerialize;
    }
  }
  public class ManualDecision {
    /**
     * @description serialize manual decision events
     * @author Trupti Zende (Thinqloud) | 06-21-2021
     * @param serialiser
     * @param eventType
     * @return Map<String, Object>
     **/
    public Map<String, Object> serialize(
      OneJNSerializer serialiser,
      String eventType
    ) {
      Map<String, Object> JSONToSerialize = new Map<String, Object>();
      JSONToSerialize.put('ApplicationId', serialiser.AppData.ApplicationId);
      JSONToSerialize.put(
        'ApprovedInterestRate',
        serialiser.AppData.InterestRateForApplication
      );
      JSONToSerialize.put('ApprovedTenure', serialiser.AppData.ApprovedTenure);
      JSONToSerialize.put(
        'ApprovedCreditAmount',
        serialiser.AppData.ApprovedCreditAmount
      );
      JSONToSerialize.put('PhoenixId', serialiser.AppData.PhoenixId);
      JSONToSerialize.put(
        'AdjudicationDecision',
        serialiser.AppData.AdjudicationDecision
      );

      return JSONToSerialize;
    }
  }

  public class PreAssesssment {
    /**
     * @description serialize credit card pre- assessment evnets
     * @author Trupti Zende (Thinqloud) | 06-21-2021
     * @param serialiser
     * @param eventType
     * @return Map<String, Object>
     **/
    public Map<String, Object> creditCardSerialize(
      OneJNSerializer serialiser,
      String eventType
    ) {
      Map<String, Object> JSONToSerialize = new Map<String, Object>();

      String appDataObj = JSON.serialize(serialiser.AppData);
      String serializerdata = JSON.serialize(serialiser);
      Map<String, Object> appDataJson = (Map<String, Object>) JSON.deserializeUntyped(
        appDataObj
      );
      Object currencyType = appDataJson.get('CurrencyType');
      appDataJson.put('Currency', currencyType);
      //appDataJson.put('InterestRate', serialiser.AppData.ApprovedInterestRate);
      List<String> appDataFieldsToRemove = new List<String>{
        'FeeFinancing',
        'LoanPurpose',
        'IsJointApplication',
        'IsPEP',
        'ApprovedTenure',
        'AdjudicationDecision',
        'CurrencyType',
        'PhoenixId',
        'ApprovedCreditAmount',
        'InterestRateForApplication'
      };

      appDataJson = removeFields(appDataJson, appDataFieldsToRemove);

      Map<String, Object> applicantJson = (Map<String, Object>) JSON.deserializeUntyped(
        serializerdata
      );
      List<Object> applicantData = (List<Object>) applicantJson.get(
        'Applicant'
      );
      List<String> applicantFieldsToRemove = new List<String>{
        'MonthlyExpensesNonCreditVerified',
        'MonthlyIncomeVerified',
        'MtherIncomeVerified',
        'TotalAssetsVerified',
        'TotalLiabilitiesConsolidatedVerified',
        'TotalLiabilitiesVerified',
        'TotalMonthlyPaymentsVerified',
        'TotalNetworthVerified',
        'TotalPaymentsConsolidatedVerified',
        'OtherIncomeVerified'
      };
      for (Object applicant : applicantData) {
        Map<String, Object> applicantMap = (Map<String, Object>) applicant;
        applicantMap = removeFields(applicantMap, applicantFieldsToRemove);
        applicant = (Object) applicantMap;
      }
      String appDataObj1 = JSON.serialize(appDataJson);
      String applicantObj1 = JSON.serialize(applicantData);

      String SerializeObj = JSON.serialize(serialiser);
      JSONToSerialize = (Map<String, Object>) JSON.deserializeUntyped(
        SerializeObj
      );

      JSONToSerialize.put(
        'AppData',
        (Object) JSON.deserializeUntyped(appDataObj1)
      );
      JSONToSerialize.put(
        'Applicant',
        (Object) JSON.deserializeUntyped(applicantObj1)
      );
      return JSONToSerialize;
    }
    /**
     * @description serialize unsecured loan pre-assessment event
     * @author Trupti Zende (Thinqloud) | 06-21-2021
     * @param serialiser
     * @param eventType
     * @return Map<STring, Object>
     **/
    public Map<STring, Object> unsecuredLoanSerialize(
      OneJNSerializer serialiser,
      String eventType
    ) {
      Map<String, Object> JSONToSerialize = new Map<String, Object>();
      String appDataObj = JSON.serialize(serialiser.AppData);
      String serializerdata = JSON.serialize(serialiser);
      Map<String, Object> appDataJson = (Map<String, Object>) JSON.deserializeUntyped(
        appDataObj
      );
      Object currencyType = appDataJson.get('CurrencyType');
      appDataJson.put('Currency', currencyType);
      //appDataJson.put('InterestRate', serialiser.AppData.ApprovedInterestRate);
      List<String> appDataFieldsToRemove = new List<String>{
        'IsPEP',
        'SubProductType',
        'ApprovedTenure',
        'AdjudicationDecision',
        'CurrencyType',
        'PhoenixId',
        'ApprovedCreditAmount',
        'InterestRateForApplication'
      };

      appDataJson = removeFields(appDataJson, appDataFieldsToRemove);
      Map<String, Object> applicantJson = (Map<String, Object>) JSON.deserializeUntyped(
        serializerdata
      );
      List<Object> applicantData = (List<Object>) applicantJson.get(
        'Applicant'
      );
      List<String> applicantFieldsToRemove = new List<String>{
        'MonthlyExpensesNonCreditVerified',
        'MonthlyIncomeVerified',
        'OtherIncomeVerified',
        'TotalAssetsVerified',
        'TotalLiabilitiesConsolidatedVerified',
        'TotalLiabilitiesVerified',
        'TotalMonthlyPaymentsVerified',
        'TotalNetworthVerified',
        'TotalPaymentsConsolidatedVerified'
      };
      for (Object applicant : applicantData) {
        Map<String, Object> applicantMap = (Map<String, Object>) applicant;
        applicantMap = removeFields(applicantMap, applicantFieldsToRemove);
        applicant = (Object) applicantMap;
      }
      String appDataObj1 = JSON.serialize(appDataJson);
      String applicantObj1 = JSON.serialize(applicantData);

      String SerializeObj = JSON.serialize(serialiser);
      JSONToSerialize = (Map<String, Object>) JSON.deserializeUntyped(
        SerializeObj
      );

      JSONToSerialize.put(
        'AppData',
        (Object) JSON.deserializeUntyped(appDataObj1)
      );
      JSONToSerialize.put(
        'Applicant',
        (Object) JSON.deserializeUntyped(applicantObj1)
      );
      return JSONToSerialize;
    }
  }
  public class FinalAssessment {
    /**
     * @description serialize credit card final assessment events
     * @author Trupti Zende (Thinqloud) | 06-21-2021
     * @param serialiser
     * @param eventType
     * @return Map<String, Object>
     **/
    public Map<String, Object> creditCardserialize(
      OneJNSerializer serialiser,
      String eventType
    ) {
      Map<String, Object> JSONToSerialize = new Map<String, Object>();
      String appDataObj = JSON.serialize(serialiser.AppData);
      Map<String, Object> appDataJson = (Map<String, Object>) JSON.deserializeUntyped(
        appDataObj
      );
      Object currencyType = appDataJson.get('CurrencyType');
      appDataJson.put('Currency', currencyType);
      List<String> appDataFieldsToRemove = new List<String>{
        'FeeFinancing',
        'LoanPurpose',
        'IsJointApplication',
        'IsPEP',
        'RequestedTenure',
        'ApprovedTenure',
        'AdjudicationDecision',
        'CurrencyType',
        'PhoenixId',
        'ApprovedCreditAmount',
        'InterestRateForApplication'
      };

      appDataJson = removeFields(appDataJson, appDataFieldsToRemove);

      String appDataObj1 = JSON.serialize(appDataJson);

      String SerializeObj = JSON.serialize(serialiser);
      JSONToSerialize = (Map<String, Object>) JSON.deserializeUntyped(
        SerializeObj
      );

      JSONToSerialize.put(
        'AppData',
        (Object) JSON.deserializeUntyped(appDataObj1)
      );
      return JSONToSerialize;
    }
    /**
     * @description serialize unsecured loan final assessment event
     * @author Trupti Zende (Thinqloud) | 06-21-2021
     * @param serialiser
     * @param eventType
     * @return Map<String, Object>
     **/
    public Map<String, Object> unsecuredLoanserialize(
      OneJNSerializer serialiser,
      String eventType
    ) {
      Map<String, Object> JSONToSerialize = new Map<String, Object>();

      String appDataObj = JSON.serialize(serialiser.AppData);
      Map<String, Object> appDataJson = (Map<String, Object>) JSON.deserializeUntyped(
        appDataObj
      );
      Object currencyType = appDataJson.get('CurrencyType');
      appDataJson.put('Currency', currencyType);

      List<String> appDataFieldsToRemove = new List<String>{
        'IsPEP',
        'MinMonthlyRepayment',
        'SubProductType',
        'ApprovedTenure',
        'AdjudicationDecision',
        'CurrencyType',
        'PhoenixId',
        'ApprovedCreditAmount',
        'InterestRateForApplication'
      };

      appDataJson = removeFields(appDataJson, appDataFieldsToRemove);

      String appDataObj1 = JSON.serialize(appDataJson);
      String SerializeObj = JSON.serialize(serialiser);
      JSONToSerialize = (Map<String, Object>) JSON.deserializeUntyped(
        SerializeObj
      );

      JSONToSerialize.put(
        'AppData',
        (Object) JSON.deserializeUntyped(appDataObj1)
      );
      return JSONToSerialize;
    }
  }
  /**
   * @description to set the request body for one JN events
   * @author Trupti Zende (Thinqloud) | 06-21-2021
   * @param serialiser
   * @param eventType
   * @return Map<String, Object>
   **/
  public static Map<String, Object> setSerializer(
    OneJNSerializer serialiser,
    String eventType
  ) {
    Map<String, Object> JSONToSerialize = new Map<String, Object>();

    if (eventType == Constants.GET_LOAN_APPLICATION_ID) {
      Application application = new Application();
      JSONToSerialize = application.serialize(serialiser, eventType);
    } else if (
      eventType == Constants.SUBMIT_CREDIT_CARD_MANUAL_DECISION ||
      eventType == Constants.SUBMIT_UNSECURED_LOAN_MANUAL_DECISION
    ) {
      ManualDecision manualDecision = new ManualDecision();
      JSONToSerialize = manualDecision.serialize(serialiser, eventType);
    } else if (eventType == Constants.GET_CREDITCARD_PRE_ASSESSMENT) {
      PreAssesssment preAssessment = new PreAssesssment();
      JSONToSerialize = preAssessment.creditCardSerialize(
        serialiser,
        eventType
      );
    } else if (eventType == Constants.GET_UNSECURED_LOAN_PRE_ASSESSMENT) {
      PreAssesssment preAssessment = new PreAssesssment();
      JSONToSerialize = preAssessment.unsecuredLoanSerialize(
        serialiser,
        eventType
      );
    } else if (eventType == Constants.GET_CREDITCARD_FINAL_ASSESSMENT) {
      FinalAssessment finalAssessment = new FinalAssessment();
      JSONToSerialize = finalAssessment.creditCardserialize(
        serialiser,
        eventType
      );
    } else if (eventType == Constants.GET_UNSECURED_LOAN_FINAL_ASSESSMENT) {
      FinalAssessment finalAssessment = new FinalAssessment();
      JSONToSerialize = finalAssessment.unsecuredLoanserialize(
        serialiser,
        eventType
      );
    }

    return JSONToSerialize;
  }
  /**
   * @description to remove the fields from json
   * @author Trupti Zende (Thinqloud) | 06-15-2021
   * @return Map<String, Object>
   **/
  public static Map<String, Object> removeFields(
    Map<String, Object> jsonData,
    List<String> fieldsList
  ) {
    if (fieldsList.size() > 0) {
      for (String field : fieldsList) {
        jsonData.remove(field);
      }
    }
    return jsonData;
  }
}