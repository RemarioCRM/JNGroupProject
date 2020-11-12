({
  /**
 * @param {*} component
 * @param {*} event
 * @param {*} helper
 */
  doInit: function (component, event, helper) {
    // let data = {
    //   jngiMonthlyPremium: 0
    // };
    // component.set("v.ChildContainer", data);
  },
  scriptsLoaded: function (component, event, helper) {
    component.set("v.scriptsLoaded", true);
  },
  /**
   * @param {*} component
   * @param {*} event
   * @param {*} helper
   */
  onChildContainerChange: function (component, event, helper) {
    const data = Object.assign(
      component.get("v.ParentContainer"),
      component.get("v.ChildContainer")
    );
    data['containerName'] = component.get("v.containerName");
    component.set("v.ParentContainer", data);
  },
  /**
 * @param {*} component
 * @param {*} event
 * @param {*} helper
 */
  onParenContainerChange: function (component, event, helper) {
    const containerName = component.get("v.ParentContainer.containerName");
    console.log("scriptsLoaded", component.get("v.scriptsLoaded"));
    if (component.get("v.scriptsLoaded") && containerName !== component.get("v.containerName")) {
      console.info("Parent", JSON.parse(JSON.stringify(component.get("v.ParentContainer"))))
      // on auto loan changes
      helper.calculateMonthlyP_ILoanAmount(component);
      console.log("calculateMonthlyP_ILoanAmount")
      // on credit repayment changes
      helper.setDeductRepaymentFlag(component);
      console.log("calculateMonthlyP_ILoanAmount")
      // on processing fee changes
      helper.calculateProcessingFee(component);
      //on loan savings change
      helper.calculateSavings(component);
      //calculate totals
      helper.totalMonthlyPaymentCalculation(component);
      helper.totalLoanAmountCalculation(component);
      helper.totalMonthlyPILoanPaymentCalculation(component);
      helper.totalInterestPaymentCalculation(component);
      helper.totalMonthlyLoanPaymentMonthlyCompulsorySavingsCalculation(component);
    }
  }
});