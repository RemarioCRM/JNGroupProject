({
    doInit: function(component, event, helper) {
        const siteLead = {
            FirstName: "",
            LastName: "",
            Lead_Title__c: "",
            MiddleName: "",
            Suffix__c: "",
            Gender__c: "",
            Marital_Status__c: "",
            Date_of_Birth__c: new Date(),
            Place_of_Birth__c: "",
            Mother_s_Maiden_Name__c: "",
            Number_of_Dependent_Adults__c: 0,
            Number_of_Dependent_Children__c: 0,
            Country_of_Citizenship__c: "Jamaica",
            Country_of_Residence__c: "Jamaica",
            Highest_Level_of_Education_Attained__c: "",
            Jamaican_Tax_Registration_Number__c: null,
            Service_of_Interest__c:""
        };

        Object.assign(siteLead, component.get("v.SiteLead"));
        component.set("v.SiteLead", siteLead);
        helper.getPickListValues(component);
    },
    getTitle: function(component, event, helper) {
        const selected = event.getSource().get("v.value");
        let siteLead = component.get("v.SiteLead");
        siteLead["Lead_Title__c"] = selected;
        component.set("v.SiteLead", siteLead);
    },
    getCountryofCitizenship: function(component, event, helper) {
        const selected = event.getSource().get("v.value");
        let siteLead = component.get("v.SiteLead");
        siteLead["Country_of_Citizenship__c"] = selected;
        component.set("v.SiteLead", siteLead);
    },
    getCountryofResidence: function(component, event, helper) {
        const selected = event.getSource().get("v.value");
        let siteLead = component.get("v.SiteLead");
        siteLead["Country_of_Residence__c"] = selected;
        component.set("v.SiteLead", siteLead);
    },
    getSuffix: function(component, event, helper) {
        const selected = event.getSource().get("v.value");
        let siteLead = component.get("v.SiteLead");
        siteLead["Suffix__c"] = selected;
        component.set("v.SiteLead", siteLead);
    },
    getEducationLevel: function(component, event, helper) {
        const selected = event.getSource().get("v.value");
        let siteLead = component.get("v.SiteLead");
        siteLead["Highest_Level_of_Education_Attained__c"] = selected;
        component.set("v.SiteLead", siteLead);
    },
    getGender: function(component, event, helper) {
        const selected = event.getSource().get("v.value");
        let siteLead = component.get("v.SiteLead");
        siteLead["Gender__c"] = selected;
        component.set("v.SiteLead", siteLead);
    },
    getMaritalStatus: function(component, event, helper) {
        const selected = event.getSource().get("v.value");
        let siteLead = component.get("v.SiteLead");
        siteLead["Marital_Status__c"] = selected;
        component.set("v.SiteLead", siteLead);
    },
    TRNformatter: function(component, event, helper) {
        var TrnValue = event.getSource().get("v.value");
        component.set("v.trn_number", TrnValue.replace(",", ""));
    },
    validateTabFields: function(component, event, helper) {
        return component.find("validation").reduce(function(validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
    },
    createDetails: function(component, event, helper) {
        helper.createLead(component);
    },
    checkDateValidity: function(component, event, helper) {
            let cmp = event.getSource();
            let currentDateValue = cmp.get("v.value");
            let currentDateTime = new Date(currentDateValue).getTime();
            let now = new Date();
            now.setFullYear(now.getFullYear()-18);
            let maxDateTime = now.getTime();
            if(currentDateTime > maxDateTime){
                cmp.setCustomValidity("You must 18+ years or older");
            } else {
                cmp.setCustomValidity("");
            }
            
            cmp.reportValidity();
    }
});