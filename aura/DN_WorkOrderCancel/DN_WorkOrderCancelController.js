({
    init : function(component, event, helper) {
        var action = component.get('c.getListView');
        action.setCallback(this, function(response){
            component.set('v.listViewId', response.getReturnValue());
            console.log('listview ID ', component.get('v.listViewId'));
        });
        $A.enqueueAction(action);
    },
    handleCancel : function(component, event, helper) {
        component.set('v.isSpinner', true);
        var action = component.get('c.cancelWorkOrder');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('cancelWorkOrder',result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', $A.get("$Label.c.DNS_M_DeleteSuccess"), 'Success');
                if(!$A.util.isEmpty(result.returnValue)){
                    helper.navigateToRecord(component, result.returnValue);
                }else{
                    var navEvent = $A.get("e.force:navigateToList");
                    navEvent.setParams({
                        "listViewId": component.get('v.listViewId'),
                        "listViewName": null,
                        "scope": "WorkOrder"
                    });
                    navEvent.fire();
                }

                // $A.get('e.force:refreshView').fire();
                // helper.closeModal(component);
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