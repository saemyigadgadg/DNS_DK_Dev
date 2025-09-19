({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal != "SUCCESS"){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type" : "error",
                        "title": $A.get("$Label.c.DNS_M_Error") + '!',
                        "message": returnVal //이미 주문이 생성 된 견적은 복제가 불가합니다. // Quotes for which an order has already been created cannot be copied.

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set('v.isStatus', true);
                }
            });
        $A.enqueueAction(action);
    },
    handleClose : function(component, event, helper) {

        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        
    }
})