/**
* @Description        : Handler for trigger
* @Author             : Remario Richards
* @Last Modified By   : Remario Richards
* @Created On          : 10/7/2019
* @Last Modified On   : 10/7/2019
*/
trigger NewLeadTrigger on Lead (before insert, after insert, before update, after update) {
        LeadTriggerHandler.init(Trigger.new, Trigger.oldMap, Trigger.newMap);
        
        if(Trigger.isUpdate) {
            if(Trigger.isAfter) {
                System.debug('LeadTriggerHandler Executed');
                LeadTriggerHandler.crmm_CreateEmploymentOnConversion();
                LeadTriggerHandler.crmm_lead_trigger_conversion();
                LeadTriggerHandler.leadConversionBasic();
                LeadTriggerHandler.convertInfoToEmployment();
                LeadTriggerHandler.convertLeadRelatedPersons();
                LeadTriggerHandler.EnforceLeadOpportunityRecordType();
            }
            else {
                
                LeadTriggerHandler.crmm_TimeSpentInStage();
                LeadTriggerHandler.crmm_TierTwoTrigger();
                SkillsBasedRouting.routeUsingSkillsTier2(Trigger.new);
                LeadTriggerHandler.IndustryTypeValidations();
                
            }
        } else if(Trigger.isInsert){
            if(Trigger.isAfter) {
                LeadTriggerHandler.leadActivityEvent();
                //SkillsBasedRouting.routeUsingSkillsTier1((new Map<Id,Lead>(Trigger.new)).keySet());           
            }
            else {
                LeadTriggerHandler.crmm_TierOne();
                LeadTriggerHandler.IndustryTypeValidations();
            }
        } 
}