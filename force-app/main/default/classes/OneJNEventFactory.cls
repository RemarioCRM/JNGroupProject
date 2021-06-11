/**
 * @description       :
 * @author            : Remario Richards
 * @group             :
 * @last modified on  : 06-08-2021
 * @last modified by  : Ishwari Gaikwad(Thinqloud)
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   05-26-2021   Remario Richards   Initial Version
 **/
public with sharing class OneJNEventFactory {
  /**
   * @description process inbound events
   * @author Remario Richards | 05-26-2021
   * @param eventType
   * @param oneJNDeserializer
   **/
  public static void ProcessIncomingEvent(
    String eventType,
    OneJNDeserializer oneJNDeserializer,
    String sfRecordId
  ) {
    if (eventType == Constants.RETURN_LOAN_APPLICATION_ID) {
      processGetApplicationEvent(oneJNDeserializer, sfRecordId, eventType);
    }
    if (
      eventType == Constants.RETURN_CREDITCARD_PRE_ASSESSMENT ||
      eventType == Constants.RETURN_UNSECURED_LOAN_PRE_ASSESSMENT
    ) {
      processGetPreAssessmentEventResponse(
        oneJNDeserializer,
        sfRecordId,
        eventType
      );
    }
    if (
      eventType == Constants.RETURN_MANUAL_DESICION_APPROVED ||
      eventType == Constants.RETURN_MANUAL_DESICION_REJECT
    ) {
      processGetManualIdEvent(oneJNDeserializer, sfRecordId, eventType);
    }
    if (
      eventType == Constants.RETURN_CREDITCARD_FINAL_ASSESSMENT ||
      eventType == Constants.RETURN_UNSECURED_LOAN_FINAL_ASSESSMENT
    ) {
      processFinalAssessmentEvent(oneJNDeserializer, sfRecordId, eventType);
    }
  }
  /**
   * @description process outbound events
   * @author Remario Richards | 05-26-2021
   **/
  public static void ProcessOutgoingEvent(
    String eventType,
    List<Application__c> applicationList,
    List<Opportunity> opportunityList
  ) {
    if (eventType == Constants.GET_LOAN_APPLICATION_ID) {
      processGetApplicationIdEvent(applicationList, eventType);
    }
    if (
      eventType == Constants.GET_CREDITCARD_PRE_ASSESSMENT ||
      eventType == Constants.GET_UNSECURED_LOAN_PRE_ASSESSMENT
    ) {
      processGetPreAssessmentEvent(eventType, opportunityList);
    }
    if (
      eventType == Constants.GET_MANUAL_DESICION_APPROVED ||
      eventType == Constants.GET_MANUAL_DESICION_REJECT
    ) {
      processGetManualEvent(eventType, applicationList);
    }
    if (
      eventType == Constants.GET_CREDITCARD_FINAL_ASSESSMENT ||
      eventType == Constants.GET_UNSECURED_LOAN_FINAL_ASSESSMENT
    ) {
      processGetPreAssessmentEvent(eventType, opportunityList);
    }
  }

  /**
   * @description
   * @author Ishwari Gaikwad(Thinqloud) | 06-03-2021
   * @param application
   **/
  private static void processGetApplicationIdEvent(
    List<Application__c> applicationList,
    String eventType
  ) {
    // to get the request JSON
    String JSONString = OneJNEventService.build(
      applicationList,
      new List<Opportunity>{},
      eventType
    );
    // to get the initialised platform event record
    One_JN_Output__e requestPlatformEvent = Util.getOutputPlateformEventInstance(
      Constants.GET_LOAN_APPLICATION_ID,
      applicationList[0].Id,
      JSONString,
      ''
    );
    // publish the event
    Database.SaveResult result = EventBus.publish(requestPlatformEvent);
    if (result.isSuccess()) {
      System.debug('Platform event published successfully.');
    } else {
      for (Database.Error err : result.getErrors()) {
        System.debug('Error returned: ' + err.getStatusCode());
      }
    }
  }
  /**
   * @description
   * @author Rahul Rahangdale (Thinqloud) | 06-07-2021
   * @param application
   **/
  private static void processGetManualEvent(
    string eventType,
    List<Application__c> applicationList
  ) {
    // to get the request JSON
    String JSONString = OneJNEventService.build(
      applicationList,
      new List<Opportunity>{},
      eventType
    );
    // to get the initialised platform event record
    One_JN_Output__e requestPlatformEvent = Util.getOutputPlateformEventInstance(
      eventType,
      applicationList[0].Id,
      JSONString,
      ''
    );
    // publish the event
    Database.SaveResult result = EventBus.publish(requestPlatformEvent);
    if (result.isSuccess()) {
      System.debug('Platform event published successfully.');
    } else {
      for (Database.Error err : result.getErrors()) {
        System.debug('Error returned: ' + err.getStatusCode());
      }
    }
  }

  /**
   * @description process application events
   * @author Remario Richards | 05-26-2021
   **/
  private static void processGetApplicationEvent(
    OneJNDeserializer oneJNDeserializer,
    String sfRecordId,
    String eventType
  ) {
    oneJNDeserializer deserialiser = OneJNDeserializer.parse(
      oneJNDeserializer,
      eventType,
      sfRecordId
    );
    if (deserialiser.applicationRecord <> null) {
      update deserialiser.applicationRecord;
    }
  }
  /**
   * @description process pre assessment events
   * @author Remario Richards | 05-26-2021
   **/
  private static void processPreassessmentEvent(
    OneJNDeserializer oneJNDeserializer
  ) {
  }
  /**
   * @description process final assessment events
   * @author Remario Richards | 05-26-2021
   **/
  private static void processFinalAssessmentEvent(
    OneJNDeserializer oneJNDeserializer,
    String sfRecordId,
    String eventType
  ) {
    oneJNDeserializer deserialiser = OneJNDeserializer.parse(
      oneJNDeserializer,
      eventType,
      sfRecordId
    );
    List<sObject> sObjectsToUpdate = new List<sObject>();
    if (deserialiser.primaryApplicantRecord <> null) {
      sObjectsToUpdate.add(deserialiser.primaryApplicantRecord);
    }
    if (deserialiser.coApplicantRecord <> null) {
      sObjectsToUpdate.add(deserialiser.coApplicantRecord);
    }
    if (deserialiser.opportunityRecord <> null) {
      sObjectsToUpdate.add(deserialiser.opportunityRecord);
    }
    if (deserialiser.applicationRecord <> null) {
      sObjectsToUpdate.add(deserialiser.applicationRecord);
    }
    if (deserialiser.loanCalculationProductRecord <> null) {
      sObjectsToUpdate.add(deserialiser.loanCalculationProductRecord);
    }
    if (sObjectsToUpdate.size() > 0) {
      update sObjectsToUpdate;
    }
  }

  /**
   * @description
   * @author Trupti Zende (Thinqloud) | 06-04-2021
   * @param applicationList
   **/
  private static void processGetPreAssessmentEvent(
    String eventType,
    List<Opportunity> opportunityList
  ) {
    // to get the request JSON
    String JSONString = OneJNEventService.build(
      new List<Application__c>{},
      opportunityList,
      eventType
    );
    // to get the initialised platform event record
    One_JN_Output__e requestPlatformEvent = Util.getOutputPlateformEventInstance(
      eventType,
      opportunityList[0].id,
      JSONString,
      ''
    );
    // publish the event
    Database.SaveResult result = EventBus.publish(requestPlatformEvent);
    if (result.isSuccess()) {
      System.debug('Platform event published successfully.');
    } else {
      for (Database.Error err : result.getErrors()) {
        System.debug('Error returned: ' + err.getStatusCode());
      }
    }
  }

  private static void processGetPreAssessmentEventResponse(
    OneJNDeserializer oneJNDeserializer,
    String sfRecordId,
    String eventType
  ) {
    oneJNDeserializer deserialiser = OneJNDeserializer.parse(
      oneJNDeserializer,
      eventType,
      sfRecordId
    );
    List<sObject> sObjectsToUpdate = new List<sObject>();
    if (deserialiser.primaryApplicantRecord <> null) {
      sObjectsToUpdate.add(deserialiser.primaryApplicantRecord);
    }
    if (deserialiser.coApplicantRecord <> null) {
      sObjectsToUpdate.add(deserialiser.coApplicantRecord);
    }
    if (deserialiser.opportunityRecord <> null) {
      sObjectsToUpdate.add(deserialiser.opportunityRecord);
    }
    if (deserialiser.applicationRecord <> null) {
      sObjectsToUpdate.add(deserialiser.applicationRecord);
    }
    if (sObjectsToUpdate.size() > 0) {
      update sObjectsToUpdate;
    }
  }
  /**
   * @description
   * @author Rahul Rahangdale (Thinqloud) | 06-09-2021
   * @param application
   **/

  private static void processGetManualIdEvent(
    OneJNDeserializer oneJNDeserializer,
    String sfRecordId,
    String eventType
  ) {
    oneJNDeserializer deserialiser = OneJNDeserializer.parse(
      oneJNDeserializer,
      eventType,
      sfRecordId
    );
    List<sObject> sObjectsToUpdate = new List<sObject>();
    if (deserialiser.primaryApplicantRecord <> null) {
      sObjectsToUpdate.add(deserialiser.primaryApplicantRecord);
    }
    if (deserialiser.coApplicantRecord <> null) {
      sObjectsToUpdate.add(deserialiser.coApplicantRecord);
    }
    if (deserialiser.opportunityRecord <> null) {
      sObjectsToUpdate.add(deserialiser.opportunityRecord);
    }
    if (deserialiser.applicationRecord <> null) {
      sObjectsToUpdate.add(deserialiser.applicationRecord);
    }
    if (deserialiser.loanCalculationProductRecord <> null) {
      sObjectsToUpdate.add(deserialiser.loanCalculationProductRecord);
    }
    if (sObjectsToUpdate.size() > 0) {
      update sObjectsToUpdate;
    }
  }
}