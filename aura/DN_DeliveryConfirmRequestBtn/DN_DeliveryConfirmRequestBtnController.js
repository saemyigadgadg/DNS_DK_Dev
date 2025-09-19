({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.validateDeliveryConfrim");
        action.setParams({ doId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('validateDeliveryConfrim - result ::: ', JSON.stringify(returnVal, null, 2));
                
                if(returnVal.isSuccess) {
                    component.set('v.isLoading', false);
                } else {
                    helper.handleError('validateDeliveryConfrim', returnVal.errMessage);
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

        var action = component.get("c.setConfirmData");
        action.setParams({ doId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('setConfirmData result ::: ', JSON.stringify(returnVal, null, 1));

                var action_confirm = component.get("c.requestConfrim");
                action_confirm.setParams({ doId : component.get("v.recordId"), cvList : returnVal });
                action_confirm.setCallback(this, function(response_confirm) {
                    var state_confirm = response_confirm.getState();
                    if(state_confirm === "SUCCESS"){
                        var returnVal_confirm = response_confirm.getReturnValue();
                        // console.log('requestConfrim result ::: ', JSON.stringify(returnVal_confirm, null, 1));
                        if(returnVal_confirm.isSuccess) {
                            helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_SendToERPSuccess")); // Successfully transmitted to ERP.
                            helper.closeModal();
                        } else {
                            helper.handleError('requestConfrim', returnVal_confirm.errMessage);
                            component.set('v.isLoading', false);
                        }
                    } else {
                        helper.handleError('requestConfrim', response_confirm.getError());
                        component.set('v.isLoading', false);
                    }
                });
                $A.enqueueAction(action_confirm);
            } else {
                helper.handleError('setConfirmData', response.getError());
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    }
})