/**
 * @description       :
 * @author            : Remario Richards
 * @group             :
 * @last modified on  : 04-21-2021
 * @last modified by  : Remario Richards
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   04-20-2021   Remario Richards   Initial Version
 **/
trigger ApplicationTrigger on Application__c(after insert) {
  ApplicationTriggerHandler.init(Trigger.new, Trigger.oldMap, Trigger.newMap);
  if (Trigger.isInsert) {
    if (Trigger.isAfter) {
      ApplicationTriggerHandler.checkOpportunityHasOneApplication();
    }
  }
}
