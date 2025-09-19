({
    handleCancel : function(component, event, helper) {
        component.set('v.isSpinner', true);
        var action = component.get('c.cancelConfirmation');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('cancelWorkOrder',result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', $A.get("$Label.c.DNS_M_CancelSuccess"), 'Success');
                $A.get('e.force:refreshView').fire();
                helper.closeModal(component);
            }else{
                helper.toast(component, 'ERROR', result.errMessage, 'Error');
                component.set('v.isSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleClose : function(component, event, helper) {
        helper.closeModal(component);
    },
})