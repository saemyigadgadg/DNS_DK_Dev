({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.dnsaValidateOrderConfrim");
        action.setParams({ orderId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('dnsaValidateOrderConfrim result ::: ', JSON.stringify(returnVal, null, 2));
                if(returnVal.isSuccess) {
                    component.set('v.isLoading', false);
                } else {
                    helper.handleError('dnsaValidateOrderConfrim', returnVal.errorMsg);
                    helper.closeModal();
                }
            } else {
                helper.handleError('dnsaValidateOrderConfrim', response.getError());
                helper.closeModal();
            }
        });
        $A.enqueueAction(action);
    }

    , handleCancel : function(component, event, helper) {
        helper.closeModal();
    }

    , handleConfirm : function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.requestConfirm");
        action.setParams({ orderId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('requestConfirm result ::: ', JSON.stringify(returnVal, null, 2));

                if(returnVal.isSuccess) {
                    helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_OrderStatusUpdated"));
                    helper.closeModal();
                } else {
                    helper.handleError('requestConfirm', returnVal.errorMsg);
                    component.set('v.isLoading', false);
                }
            } else {
                helper.handleError('requestConfirm', error.message);
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    }
})