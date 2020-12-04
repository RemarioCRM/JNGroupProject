public with sharing class Util {
  public static final String AccountRole = 'AccountRole';
  public static final String ContactRole = 'ContactRole';
  public static Integer ExecutionCount = 0;
  public static Map<String, Boolean> affiliations = new Map<String, Boolean>();
  public static Map<String, Boolean> Memory = new Map<String, Boolean>(); // ensures methods are executed only once
  public static Map<String, Id> getRecordTypeids(String sobjectType) {
    Map<String, Id> recordTypesMap = new Map<String, Id>();
    List<RecordType> recordTypes = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE SobjectType = :sobjectType
    ];
    for (RecordType record : recordTypes) {
      recordTypesMap.put(record.DeveloperName, record.Id);
    }
    return recordTypesMap;
  }

  public static String getRecordTypeDevName(
    Id recordTypeId,
    Map<String, Id> recordTypes
  ) {
    for (String key : recordTypes.keySet()) {
      if (recordTypeId == recordTypes.get(key)) {
        return key;
      }
    }
    return null;
  }
  public static String getMappedRecordTypeId(
    String devName,
    Map<String, Id> recordTypes
  ) {
    for (String value : recordTypes.keySet()) {
      if (value == devName) {
        return recordTypes.get(value);
      }
    }
    return null;
  }

  public static Map<String, FinServ__ReciprocalRole__c> getRoleRelationships(
    String roleRecordType
  ) {
    Map<String, FinServ__ReciprocalRole__c> roleMap = new Map<String, FinServ__ReciprocalRole__c>();
    List<FinServ__ReciprocalRole__c> roles = [
      SELECT id, Name, FinServ__InverseRole__c, FinServ__RelationshipType__c
      FROM FinServ__ReciprocalRole__c
      WHERE
        Name IN ('Emergency Contact', 'Political Affiliation', 'JN Affiliation')
        AND FinServ__InverseRole__c IN (
          'Emergency Contact Dependent',
          'Political Affiliation Dependent',
          'JN Affiliation Dependent'
        )
        AND RecordType.DeveloperName = :roleRecordType
    ];
    for (FinServ__ReciprocalRole__c record : roles) {
      roleMap.put(record.Name, record);
    }
    return roleMap;
  }
  public static FinServ__AccountAccountRelation__c createAcountToAccountRelationship(
    Id mainAccount,
    Id relatedAccount,
    Id role
  ) {
    FinServ__AccountAccountRelation__c accountRecord = new FinServ__AccountAccountRelation__c();
    //accountRecord.FinServ__Role__c = role;
    accountRecord.FinServ__Account__c = mainAccount;
    accountRecord.FinServ__RelatedAccount__c = relatedAccount;
    return accountRecord;
  }

  public static List<AggregateResult> QueryContactToContactRelationship(
    List<Id> roleIds,
    List<Id> contactIds
  ) {
    return [
      SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name
      FROM FinServ__ContactContactRelation__c
      WHERE
        FinServ__Contact__c IN :contactIds
        AND FinServ__Role__c IN :roleIds
        AND FinServ__RelatedContact__c != NULL
      GROUP BY FinServ__Contact__c, Id, FinServ__Role__r.Name
    ];
  }
  public static FinServ__ContactContactRelation__c createContactToContactRelationship(
    Id mainContact,
    Id relatedContact,
    Id role
  ) {
    FinServ__ContactContactRelation__c record = new FinServ__ContactContactRelation__c();
    record.FinServ__Role__c = role;
    record.FinServ__Contact__c = mainContact;
    record.FinServ__RelatedContact__c = relatedContact;
    return record;
  }
  public static Account createAccount(
    Map<String, String> fields,
    Sobject record,
    String recordTypeId
  ) {
    Account newAccount = new Account();
    newAccount.RecordTypeId = recordTypeId;
    //key is from account, value is to record
    for (String key : fields.keySet()) {
      newAccount.put(key, record.get(fields.get(key)));
    }
    //insert newAccount;
    return newAccount;
  }
  public static Supplementary_Card_Holders__c createSupplementaryCardHolder(
    Id opportunityId,
    Id accountId
  ) {
    Supplementary_Card_Holders__c newRecord = new Supplementary_Card_Holders__c();
    newRecord.Opportunity__c = opportunityId;
    newRecord.Account__c = accountId;
    return newRecord;
  }
  public static Boolean areFieldsEmpty(List<String> fields, Sobject record) {
    for (String field : fields) {
      if (record.get(field) == null || record.get(field) == '') {
        return true;
      }
    }
    return false;
  }
  public static Long getNameHash(List<String> values) {
    return String.join(Values, ':').hashCode();
  }

  /**
   * Gets all the holidays in the system and returns a map.
   * @return Map<Date,Holiday>
   */
  private static Map<Date, Holiday> getHolidays() {
    Map<Date, Holiday> mappedHolidays = new Map<Date, Holiday>();
    for (Holiday hDay : [
      SELECT h.StartTimeInMinutes, h.Name, h.ActivityDate
      FROM Holiday h
    ]) {
      mappedHolidays.put(hDay.ActivityDate, hDay);
    }
    return mappedHolidays;
  }

  /**
   * Checks whether or not a datetime is within business hours
   * @param {DateTime} date - Datetime to be checked.
   * @return Boolean
   */

  public static Boolean isWithinBusinessHours(Datetime currentDateTime) {
    BusinessHours bh = GetActiveBusinessHours('JN Default Business Hours');
    return BusinessHours.isWithin(bh.Id, currentDateTime);
  }

  /**
   * Checks whether or not a date is a public holiday.
   * @param {DateTime} date - Date to be checked.
   * @return Boolean
   */
  public static Boolean checkHoliday(Date dateRecord) {
    Boolean result = false;
    Map<Date, Holiday> mappedHolidays = getHolidays();
    if (mappedHolidays.size() > 0) {
      if (mappedHolidays.containsKey(dateRecord)) {
        result = true;
        return result;
      }
    }
    return result;
  }

  public static Date GetBackDatedDate(Date currentDate, Integer days) {
    Boolean isHoliday;
    while (days > 0) {
      DateTime dt = DateTime.newInstance(
        currentDate.year(),
        currentDate.month(),
        currentDate.day()
      );
      isHoliday = checkHoliday(currentDate);
      String day = dt.format('E');
      if (day != 'Sat' && day != 'Sun' && !isHoliday) {
        days -= 1;
      }
      if (days > 0) {
        currentDate = currentDate.addDays(-1);
      }
    }
    return currentDate;
  }

  public static Boolean DidFieldChange(Object v1, Object v2) {
    if (v1 == null && v2 == null) {
      return false;
    }
    if (v1 != v2) {
      return true;
    }
    return false;
  }
  public static Map<String, Integer> GetYearValues(
    Date startDate,
    Date currentDate
  ) {
    Map<String, Integer> values = new Map<String, Integer>();
    Integer days = 0;
    Integer months = 0;
    Integer years = 0;
    while (startDate < currentDate) {
      days += 1;
      startDate = startDate.addDays(1);
    }

    Integer calendarYears = Integer.valueOf(days / 365);
    Integer calendarMonths = Integer.valueOf(days / 30.417);
    values.put('days', days);
    values.put('years', calendarMonths >= 12 ? calendarYears : 0);
    values.put('months', calendarMonths);
    return values;
  }
  public static String GenerateHash(List<String> values) {
    Blob targetBlob = Blob.valueOf(String.join(values, '-'));
    Blob hash = Crypto.generateDigest('MD5', targetBlob);
    return EncodingUtil.base64Encode(hash);
  }
  public static Boolean IsExecuted(String method) {
    String hash = GenerateHash(new List<String>{ method });
    if (Memory.containsKey(hash)) {
      return true;
    }
    Memory.put(hash, true);
    return false;
  }
  public static Boolean Some(List<String> records, String match) {
    for (String record : records) {
      if (record == match)
        return true;
    }
    return false;
  }
  /**
   * @param {String} name - name of business hour
   * Queries active business business hours.
   * @return BusinessHour
   */
  public static BusinessHours GetActiveBusinessHours(String name) {
    return [
      SELECT
        Id,
        FridayStartTime,
        FridayEndTime,
        ThursdayStartTime,
        ThursdayEndTime,
        WednesdayStartTime,
        WednesdayEndTime,
        TuesdayStartTime,
        TuesdayEndTime,
        MondayStartTime,
        MondayEndTime
      FROM BusinessHours
      WHERE Name = :name
    ];
  }
  /**  returns the previous month last day
   * @param {Date} current - current date
   */
  public static Date GetPrevMonthLastDay(Date current) {
    return Date.newInstance(
      current.year(),
      current.month(),
      Date.daysInMonth(current.year(), current.month())
    );
  }

  /**
   * get the remaining hours for a lead to to disqualified if not contacted within x amount of hours
   * @param {Integer} hours - the max amount of hours
   * @param {DateTime} assignmentTime - time the lead was assigned
   * @param {currentTime} - current date/time
   * @param {BusinessHours} - businessHour business hours to use
   * @param {Boolean} false if current > max time
   */
  public static Boolean LeadWithinTimeLimit(
    Integer hours,
    Datetime assignmentTime,
    DateTime currentTime,
    BusinessHours businessHour
  ) {
    //1. get the business hours , ensure that that the assignmentTime is not > business hour day end time
    //2. get current business hours day
    String assignmentTimeDay = assignmentTime.format('E');
    DateTime diff, paddedDateTime;
    Integer endHoursDiff;
    hours = hours * 1000 * 60 * 60; //convert to milliseconds
    switch on assignmentTimeDay {
      when 'Mon' {
        endHoursDiff = GetHoursBetweenDates(
          assignmentTime,
          CreateDateTimeFromTime(businessHour.MondayEndTime, currentTime),
          hours
        );
        currentTime = BusinessHours.nextStartDate(businessHour.Id, currentTime);
        return CheckIfCurrentTimeIsValid(
          endHoursDiff,
          currentTime,
          businessHour
        );
      }
      when 'Tue' {
        endHoursDiff = GetHoursBetweenDates(
          assignmentTime,
          CreateDateTimeFromTime(businessHour.TuesdayEndTime, currentTime),
          hours
        );
        currentTime = BusinessHours.nextStartDate(businessHour.Id, currentTime);
        return CheckIfCurrentTimeIsValid(
          endHoursDiff,
          currentTime,
          businessHour
        );
      }
      when 'Wed' {
        endHoursDiff = GetHoursBetweenDates(
          assignmentTime,
          CreateDateTimeFromTime(businessHour.WednesdayEndTime, currentTime),
          hours
        );
        currentTime = BusinessHours.nextStartDate(businessHour.Id, currentTime);
        return CheckIfCurrentTimeIsValid(
          endHoursDiff,
          currentTime,
          businessHour
        );
      }
      when 'Thu' {
        endHoursDiff = GetHoursBetweenDates(
          assignmentTime,
          CreateDateTimeFromTime(businessHour.ThursdayEndTime, currentTime),
          hours
        );
        currentTime = BusinessHours.nextStartDate(businessHour.Id, currentTime);
        return CheckIfCurrentTimeIsValid(
          endHoursDiff,
          currentTime,
          businessHour
        );
      }
      when 'Fri' {
        endHoursDiff = GetHoursBetweenDates(
          assignmentTime,
          CreateDateTimeFromTime(businessHour.FridayEndTime, currentTime),
          hours
        );
        currentTime = BusinessHours.nextStartDate(businessHour.Id, currentTime);
        return CheckIfCurrentTimeIsValid(
          endHoursDiff,
          currentTime,
          businessHour
        );
      }
    }
    return true;
  }
  /**
   * gets the number of hours between two dates
   * @param {Datetime} assignmentTime
   * @param {Datetime} endTime
   * @return {Integer} hours
   */
  public static Integer GetHoursBetweenDates(
    Datetime assignmentTime,
    DateTime endTime,
    Integer hours
  ) {
    Long first = assignmentTime.getTime();
    Long second = endTime.getTime();
    //return (second - first / 1000.0) / 60.0 / 60.0; // milliseconds / seconds / minutes / hours
    return hours - (Integer) (second - first);
  }
  /**
   * based on the current business day, add hours to start time
   * @param {Decimal} hours - hours to add
   * @param {DateTime} currentTime - current date/time
   * @param {BusinessHours} - businessHour
   * @return {Boolean}
   */
  public static Boolean CheckIfCurrentTimeIsValid(
    Integer milli,
    DateTime currentTime,
    BusinessHours businessHour
  ) {
    String currentTimeDay = currentTime.format('E');
    DateTime paddedDateTime;
    switch on currentTimeDay {
      when 'Mon' {
        paddedDateTime = CreateDateTimeFromTime(
          businessHour.MondayStartTime.addMilliseconds(milli),
          currentTime
        );
        if (
          paddedDateTime <=
          CreateDateTimeFromTime(businessHour.MondayEndTime, currentTime)
        ) {
          if (currentTime > paddedDateTime) {
            return true;
          }
        }
      }
      when 'Tue' {
        paddedDateTime = CreateDateTimeFromTime(
          businessHour.TuesdayStartTime.addMilliseconds(milli),
          currentTime
        );
        if (
          paddedDateTime <=
          CreateDateTimeFromTime(businessHour.TuesdayEndTime, currentTime)
        ) {
          if (currentTime > paddedDateTime) {
            return true;
          }
        }
      }
      when 'Wed' {
        paddedDateTime = CreateDateTimeFromTime(
          businessHour.WednesdayStartTime.addMilliseconds(milli),
          currentTime
        );
        if (
          paddedDateTime <=
          CreateDateTimeFromTime(businessHour.WednesdayEndTime, currentTime)
        ) {
          if (currentTime > paddedDateTime) {
            return true;
          }
        }
      }
      when 'Thu' {
        paddedDateTime = CreateDateTimeFromTime(
          businessHour.ThursdayStartTime.addMilliseconds(milli),
          currentTime
        );
        if (
          paddedDateTime <=
          CreateDateTimeFromTime(businessHour.ThursdayEndTime, currentTime)
        ) {
          if (currentTime > paddedDateTime) {
            return true;
          }
        }
      }
      when 'Fri' {
        paddedDateTime = CreateDateTimeFromTime(
          businessHour.FridayStartTime.addMilliseconds(milli),
          currentTime
        );
        if (
          paddedDateTime <=
          CreateDateTimeFromTime(businessHour.FridayEndTime, currentTime)
        ) {
          if (currentTime > paddedDateTime) {
            return true;
          }
        }
      }
    }
    return false;
  }
  /**
   * create datetime from time
   * @param {Time} - currentTime
   * @param {DateTime} - currentDateTime
   */
  public static DateTime CreateDateTimeFromTime(
    Time currentTime,
    Datetime currentDateTime
  ) {
    return Datetime.newInstance(
      currentDateTime.year(),
      currentDateTime.month(),
      currentDateTime.day(),
      currentTime.hour(),
      currentTime.minute(),
      currentTime.second()
    );
  }

  /**
   * Get all opportunity products related to an opportunity
   * @param {Id} - oppId
   * @return OpportunityLineItem
   */
  public static OpportunityLineItem getOpportunityProducts(Id oppId) {
    return [
      SELECT Id, Product_Family__c, Name, UnitPrice
      FROM OpportunityLineItem
      WHERE OpportunityId = :oppId
    ];
  }
}