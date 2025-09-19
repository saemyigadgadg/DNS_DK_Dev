({
    doInit : function(component, event, helper) {

        var action = component.get("c.serviceValidateOrderConfrim");
        action.setParams({ orderId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('serviceValidateOrderConfrim result ::: ', returnVal);

                if(returnVal.isSuccess) {
                    component.set('v.isLoading', false);
                } else {
                    helper.handleError('serviceValidateOrderConfrim', returnVal.errMessage);
                    helper.closeModal();
                }
            } else {
                helper.handleError('serviceValidateOrderConfrim', response.getError());
                helper.closeModal();
            }
        } );
        $A.enqueueAction(action);
    }

    , handleCancel : function(component, event, helper) {
        helper.closeModal();
    }

    , handleConfirm: function (component, event, helper) {
        component.set('v.isLoading', true);
    
        var action = component.get("c.serviceRequestConfrim");
        action.setParams({ orderId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                console.log('serviceRequestConfrim result ::: ', returnVal);
    
                if (returnVal.isSuccess) {
                    helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_OrderStatusUpdated"));
                    helper.closeModal();
                } else {
                    helper.handleError('serviceRequestConfrim', returnVal.errMessage);
                    component.set('v.isLoading', false);
                }
            } else {
                helper.handleError('serviceRequestConfrim', response.getError());
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    }
})