({
  calculateMonthlyP_ILoanAmount: function (component) {
    console.info("calling Result");
    const result = basicPMTCalculator(
      ["years", "months", "loanAmount", "market"],
      component.get("v.ParentContainer")
    );
    console.info("Result", result);
    component.set("v.monthly_PI_LoanAmount", result);
    console.info("Result 3");
    this.updateChildContainerWithValue(component, [{ "key": "monthly_PI_LoanAmount", value: parseFloat(result) }]);
    console.info("Result 4");
  },
  setDeductRepaymentFlag: function (component) {
    console.log("Repayment deducted");
    let creditRepayment = component.get("v.ParentContainer");
    if (creditRepayment.deductRepayment == "Yes") {
      component.set("v.deductRepaymentFlag", true);
    } else {
      component.set("v.deductRepaymentFlag", false);
    }
  },

  calculateSavings: function (component) {
    //TODO: refactor into calculations resource
    let PIMonthlyPayment = component.get("v.monthly_PI_LoanAmount");
    let parentContainer = component.get("v.ParentContainer");
    if (PIMonthlyPayment > 0) {
      let tenure = calculateMonths(parentContainer.years, parentContainer.months);
      if (parentContainer.percentage > 0 && parentContainer.percentage) {
        let monthlyCompulsorySavings =
          PIMonthlyPayment * parentContainer.percentage;
        let totalCompulsorySavings = monthlyCompulsorySavings * tenure;
        component.set("v.monthlyCompulsorySavings", monthlyCompulsorySavings);
        component.set(
          "v.totalCompulsorySavingsBalance",
          totalCompulsorySavings
        );
      } else if (parentContainer.amount > 0 && parentContainer.amount) {
        component.set("v.monthlyCompulsorySavings", parentContainer.amount);
        let totalCompulsorySavings = parentContainer.amount * tenure;
        component.set(
          "v.totalCompulsorySavingsBalance",
          totalCompulsorySavings
        );
      } else {
        component.set("v.monthlyCompulsorySavings", 0);
        component.set("v.totalCompulsorySavingsBalance", 0);
      }
    }
  },
  calculateProcessingFee: function (component) {
    const combinedFields = component.get("v.ParentContainer");
    const {
      processingFee,
      monthlyProcessingFee,
      processingFeeClosingCost
    } = basicProcessingFeesCalculator(
      ["years", "months", "loanAmount", "market"],
      combinedFields,
      ["years", "months", "loanAmount", "market", "includeInLoanAmountFlag"],
      component.get("v.jnDefaultConfigs.gct")
    );

    component.set("v.processingFeesGCT", processingFee);
    component.set(
      "v.monthlyPrincipalInterestProcessingFee",
      monthlyProcessingFee
    );
    component.set("v.processingFeeClosingCost", processingFeeClosingCost);

    this.updateChildContainerWithValue(component, [
      { "key": "processingFeeClosingCost", value: processingFeeClosingCost },
      { "key": "monthlyPrincipalInterestProcessingFee", value: monthlyProcessingFee },
      { "key": "processingFeesGCT", value: processingFee }]);
  },
  totalMonthlyPaymentCalculation: function (component) {
    const parentObj = component.get("v.ParentContainer");
    let total = calculateTotalLoanAmount(["totalMonthlyPIPayment"], parentObj);
    component.set("v.totalMonthlyLoanPayment", total);
    this.updateChildContainerWithValue(component, [{ "key": "totalMonthlyLoanPayment", value: total }]);
  },
  totalLoanAmountCalculation: function (component) {
    const parentObj = component.get("v.ParentContainer");
    parentObj.jnLifeCreditorPremium = 1000;
    let total = calculateTotalLoanAmount(["loanAmount", "jnLifeCreditorPremium", "processingFeesGCT"], parentObj);
    component.set("v.totalLoanAmount", total);
    this.updateChildContainerWithValue(component, [{ "key": "totalLoanAmount", value: total }]);
  },
  totalMonthlyPILoanPaymentCalculation: function (component) {
    const parentObj = component.get("v.ParentContainer");
    let total = calculateTotalMonthlyPIPayment(
      ["monthly_PI_LoanAmount", "monthlyJnLifeCreditor_PI_Premium",
        "monthlyPrincipalInterestProcessingFee"],
      parentObj);
    component.set("v.totalMonthly_PI_LoanPayment", total);
    this.updateChildContainerWithValue(component, [{ "key": "totalMonthly_PI_LoanPayment", value: total }]);
  },
  totalMonthlyLoanPaymentMonthlyCompulsorySavingsCalculation: function (component) {
    const parentObj = component.get("v.ParentContainer");
    let total = calculateTotalLoanAmount(["totalMonthlyLoanPayment", "monthlyCompulsorySavings"], parentObj);
    component.set("v.totalMonthlyLoanPaymentAndSavings", total);
    this.updateChildContainerWithValue(component, [{ "key": "totalMonthlyLoanPaymentAndSavings", value: total }]);
  },
  totalInterestPaymentCalculation: function (component) {
    const totalMonthlyPIPayment = component.get("v.totalMonthly_PI_LoanPayment");
    const totalLoanAmount = component.get("v.totalLoanAmount");
    const years = component.get("v.ParentContainer.years");
    const months = component.get("v.ParentContainer.months");
    let total = calculateTotalInterestPayment(totalMonthlyPIPayment, totalLoanAmount, years, months);
    component.set("v.totalInterestPaymentBalance", total);
    this.updateChildContainerWithValue(component, [{ "key": "totalInterestPaymentBalance", value: total }]);
  },
  updateChildContainerWithValue: function (component, values) {
    let childContainer = component.get("v.ChildContainer");
    console.info("Before", JSON.stringify(childContainer));
    values.forEach(element => {
      childContainer[element.key] = element.value;
    });
    console.info("Before", JSON.stringify(childContainer));
    component.set("v.ChildContainer", childContainer);
  }
});