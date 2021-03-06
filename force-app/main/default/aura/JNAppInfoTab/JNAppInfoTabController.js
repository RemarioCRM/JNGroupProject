({
  doInit: function(component, event, helper) {
    const sitelead = {
      Loan_Amount__c: 0,
      Proposed_Card_Limit__c: 0,
      Preferred_Date_of_Contact__c: "",
      Preferred_Time_of_Contact__c: "",
      Preferred_Location__c: "",
      Loan_Purpose__c: "",
      Gross_Monthly_Income__c: 0,
      Gross_Monthly_Expenses__c: 0
    };
    var setMindate = new Date();
    component.set("v.mindate", setMindate.toISOString().split('T')[0]);
    console.log(component.get("v.mindate"));
    component.set("v.SiteLead", sitelead);
    helper.getPickListValues(component);
  },
  getPreferredLocation: function(component, event, helper) {
    const selected = event.getSource().get("v.value");
    let siteLead = component.get("v.SiteLead");
    siteLead["Preferred_Location__c"] = selected;
    component.set("v.SiteLead", siteLead);
  },
  getLoanPurpose: function(component, event, helper) {
    const selected = event.getSource().get("v.value");
    let siteLead = component.get("v.SiteLead");
    siteLead["Loan_Purpose__c"] = selected;
    component.set("v.SiteLead", siteLead);
  },
  validateTabFields: function(component, event, helper) {
    return component.find("validation").reduce(function(validSoFar, inputCmp) {
      // Displays error messages for invalid fields
      inputCmp.showHelpMessageIfInvalid();
      return validSoFar && inputCmp.get("v.validity").valid;
    }, true);
  }
});