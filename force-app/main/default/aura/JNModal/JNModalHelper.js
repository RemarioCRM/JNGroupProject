({
  showModal: function (component, event, helper) {
    var modal = component.find("crmm_modal");
    $A.util.removeClass(modal, "hideDiv");
  },

  closeModal: function (component, event, helper) {
    var modal = component.find("crmm_modal");
    $A.util.addClass(modal, "hideDiv");
  }
});
