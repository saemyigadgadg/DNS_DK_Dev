({
    doInit : function(component, event, helper) {
        helper.reverseLoading(component);
        var action = component.get("c.validateApproval");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('validateConfirm result ::: ', returnVal);

                if(returnVal.isSuccess) {
                    helper.reverseLoading(component);
                } else {
                    helper.handleError('validateApproval', returnVal.errMessage);
                    helper.closeModal();
                }
            } else {
                helper.handleError('validateApproval', response.getError());
                helper.closeModal();
            }
        } );
        $A.enqueueAction(action);
    }

    , handleCancel : function(component, event, helper) {
        helper.closeModal();
    }

    , handleSave : function(component, event, helper) {
        component.set('v.isLoading', true);

        const comments = component.get('v.comments');
        console.log('handleSave - comments ::: ', comments);
        
        var action = component.get("c.requestApproval");
        action.setParams({ recordId : component.get("v.recordId"), comments : comments });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('requestApproval result ::: ', returnVal);

                if(returnVal.isSuccess) {
                    helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_Success"));
                    helper.closeModal();
                } else {
                    helper.handleError('requestApproval', returnVal.errMessage);
                    component.set('v.isLoading', false);
                }
            } else {
                helper.handleError('requestApproval', response.getError());
                component.set('v.isLoading', false);
            }
        } ); 
        $A.enqueueAction(action);
    }
})