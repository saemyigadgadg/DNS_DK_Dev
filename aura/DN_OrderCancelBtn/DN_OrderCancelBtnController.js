({
    doInit : function(component, event, helper) {

        var action = component.get("c.validateOrderCancel");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('validateOrderCancel result ::: ', returnVal);

                if(returnVal.isSuccess) {
                    component.set('v.isLoading', false);
                } else {
                    helper.handleError('validateOrderCancel', returnVal.errorMsg);
                    helper.closeModal();
                }
            } else {
                helper.handleError('validateOrderCancel', response.getError());
                helper.closeModal();
            }
        } );
        $A.enqueueAction(action);
    }

    , handleCancel : function(component, event, helper) {
        helper.closeModal();
    }

    , handleConfirm : function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.cancelOrder");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_OrderStatusUpdated"));
                helper.closeModal();
            } else {
                helper.handleError('cancelOrder', response.getError());
                component.set('v.isLoading', false);
            }
        } );
        $A.enqueueAction(action);
    }
})