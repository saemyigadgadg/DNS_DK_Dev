({
    init : function(component, event, helper) {
        var action = component.get('c.getSpindleInfo');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('getSpindleInfo', result);
            if(result.isSuccess){
                component.set('v.spindleInfo', result.returnValue);
                component.set('v.isSpinner', false);
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