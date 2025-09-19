({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.validateDeliveryConfrim");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('validateDeliveryConfrim - result ::: ', JSON.stringify(returnVal, null, 2));
                
                if(returnVal.isSuccess) {
                    component.set('v.isLoading', false);
                } else {
                    helper.handleError('validateDeliveryConfrim', returnVal.errorMsg);
                    helper.closeModal();
                }
            } else {
                helper.handleError('validateDeliveryConfrim', response.getError());
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
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('requestConfirm result ::: ', returnVal);

                if(returnVal.isSuccess) {
                    helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_SendToERPSuccess")); // Successfully transmitted to ERP.
                    helper.closeModal();
                } else {
                    helper.handleError('requestConfirm', returnVal.errorMsg);
                    component.set('v.isLoading', false);
                }
            } else {
                helper.handleError('requestConfirm', response.getError());
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    }
})