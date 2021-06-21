/**
 * @Description        : Handler for trigger
 * @Author             : Remario Richards
 * @Last Modified By   : Travis Allen
 * @Created On          : 10/7/2019
 * @Last Modified On   : 06-18-2021
 */
trigger NewLeadTrigger on Lead(
  before insert,
  after insert,
  before update,
  after update
) {
  if (Util.canTriggerExecute()) {
    LeadTriggerHandler.init(Trigger.new, Trigger.oldMap, Trigger.newMap);
    if (Trigger.isUpdate) {
      if (Trigger.isAfter) {
        System.debug('LeadTriggerHandler Executed');
        LeadTriggerHandler.crmm_CreateEmploymentOnConversion();
        LeadTriggerHandler.crmm_lead_trigger_conversion();
        LeadTriggerHandler.leadConversionBasic();
        LeadTriggerHandler.convertInfoToEmployment();
        LeadTriggerHandler.convertLeadRelatedPersons();
        LeadTriggerHandler.EnforceLeadOpportunityRecordType();
      } else {
        LeadTriggerHandler.crmm_TimeSpentInStage();
        LeadTriggerHandler.crmm_TierTwoTrigger();
        if (!Util.IsExecuted('StartRoutingUsingTier2')) {
          SkillsBasedRouting.StartRoutingUsingTier2(Trigger.new, System.now());
        }
        LeadTriggerHandler.IndustryTypeValidations();
      }
    } else if (Trigger.isInsert) {
      if (Trigger.isAfter) {
        LeadTriggerHandler.leadActivityEvent();
      } else {
        LeadTriggerHandler.crmm_TierOne();
        LeadTriggerHandler.IndustryTypeValidations();
      }
    }
  }
}
