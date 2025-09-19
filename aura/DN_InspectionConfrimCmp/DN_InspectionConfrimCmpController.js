({
    doInit : function(component, event, helper) {

        var action = component.get("c.validateConfirm");
        action.setParams({ inspectionId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('validateConfirm result ::: ', returnVal);

                if(returnVal.isSuccess) {
                    component.set('v.isLoading', false);
                } else {
                    helper.handleError('validateConfirm', returnVal.errMessage);
                    helper.closeModal();
                }
            } else {
                helper.handleError('validateConfirm', response.getError());
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

        var action = component.get("c.confirmInspection");
        action.setParams({ inspectionId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('confirmInspection result ::: ', returnVal);

                if(returnVal.isSuccess) {
                    helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_S_InspectionConfirmed"));
                    helper.closeModal();
                } else {
                    helper.handleError('confirmInspection', returnVal.errMessage);
                    component.set('v.isLoading', false);
                }
            } else {
                helper.handleError('confirmInspection', response.getError());
                component.set('v.isLoading', false);
            }
        } ); 
        $A.enqueueAction(action);
    }
})