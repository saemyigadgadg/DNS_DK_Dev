({
    handleChange : function(component, event, helper) {
        component.set('v.isSpinner', true);
        var action = component.get('c.changeBillingStatus');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('changeBillingStatus',result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', $A.get("$Label.c.DNS_M_BillingChanged"), 'Success');
                helper.closeModal(component);
            }else{
                helper.toast(component, 'ERROR', $A.get("$Label.c.DNS_M_BillingError"), 'Error');
                component.set('v.isSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleClose : function(component, event, helper) {
        helper.closeModal(component);
    },
})