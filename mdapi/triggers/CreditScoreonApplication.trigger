trigger CreditScoreonApplication on Applicant__c(
  after insert,
  after update,
  before delete
) {
  set<Id> oppIdSet = new Set<Id>();
  if (Trigger.isDelete) {
    for (Applicant__C app : [
      SELECT id, Opportunity__c
      FROM Applicant__C
      WHERE Id = :Trigger.old
    ]) {
      oppIdSet.add(app.Opportunity__c);
    }
  } else if (Trigger.isUpdate || Trigger.isInsert) {
    for (Applicant__C app : [
      SELECT id, Opportunity__c
      FROM Applicant__C
      WHERE Id = :Trigger.new
    ]) {
      oppIdSet.add(app.Opportunity__c);
    }
  }
  Integer count = 0;
  AggregateResult[] groupedResults = [
    SELECT COUNT(Id), Opportunity__c
    FROM Applicant__C
    WHERE Opportunity__c IN :oppIdSet
    GROUP BY Opportunity__c
  ];
  for (AggregateResult ar : groupedResults) {
    Id appid = (ID) ar.get('Opportunity__c');
    count = (INTEGER) ar.get('expr0');
  }
  if (count > 3) {
    Trigger.new[0].addError('You can add maximum of 2 applications.');
  }
  system.debug('Number of Applicant coumt===>' + count);

  //system.debug('oppIdSet======'+oppIdSet);
  //CreditScoreHelper cs = new CreditScoreHelper();
  //cs.CreditScoreFromOpp(oppIdSet);

}
