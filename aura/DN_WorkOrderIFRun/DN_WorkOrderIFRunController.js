({
    handleInterface : function(component, event, helper) {
        console.log('handleInterface');
        console.log('recordId', component.get('v.recordId'));
        component.set('v.isSpinner', true);
        var action = component.get('c.callWorkOrderIF');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('callWorkOrderIF',result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', '['+ result.orderNumber + '] is successfully updated!!', 'Success');
                component.set('v.isSpinner', false);
                $A.get('e.force:refreshView').fire();
            }else{
                helper.toast(component, 'ERROR', result.errMessage, 'Error');
                component.set('v.isSpinner', false);
            }
        });
        $A.enqueueAction(action);
    }
})