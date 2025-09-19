({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    calculateTotalPrice: function(component, event, helper, fieldValues) {
        console.log('FLAG');
        
        let totalPrice = 0.00;
        let dealerPrice = Number(component.get('v.dealerPrice')) || 0;

        let DiscountfromSalesAvailabilityList = fieldValues['DiscountfromSalesAvailabilityList__c'] != null ? 
            Number(fieldValues['DiscountfromSalesAvailabilityList__c']) : 0;
        let OtherDiscount = fieldValues['OtherDiscount__c'] != null ? 
            Number(fieldValues['OtherDiscount__c']) : 0;
        let PromotionalPackage = fieldValues['PromotionalPackage__c'] != null ? 
            Number(fieldValues['PromotionalPackage__c']) : 0;
        let ProfitMarginSubsidyPlan = fieldValues['ProfitMarginSubsidyPlan__c'] != null ? 
            Number(fieldValues['ProfitMarginSubsidyPlan__c']) : 0;
        let ExtWarranty = fieldValues['ExtWarranty__c'] != null ? 
            Number(fieldValues['ExtWarranty__c']) : 0;
        let reimPrice = fieldValues['O_Price'] != null ? 
            Number(fieldValues['O_Price']) : 0;
        let reim = fieldValues['ServiceReimbursement__c'] != null ? 
            fieldValues['ServiceReimbursement__c'] : null;

        if (reim === 'Y') {
            totalPrice = dealerPrice - (dealerPrice * (DiscountfromSalesAvailabilityList / 100)) + OtherDiscount + PromotionalPackage + ProfitMarginSubsidyPlan + ExtWarranty + reimPrice;
        } else {
            totalPrice = dealerPrice - (dealerPrice * (DiscountfromSalesAvailabilityList / 100)) + OtherDiscount + PromotionalPackage + ProfitMarginSubsidyPlan + ExtWarranty;
        }

        totalPrice = Number(totalPrice.toFixed(2));

        component.set('v.totalPrice', totalPrice);
        component.set('v.isLoading', false);
    },
})