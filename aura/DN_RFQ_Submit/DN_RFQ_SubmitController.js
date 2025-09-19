({
    doinit : function(component, event, helper){
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.currentStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            // console.log('returnVal : ' + returnVal);
            if(returnVal != 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_RFQSubminError"),
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);

    },
    requestSubmit : function(component, event, helper){
        component.set('v.isLoading', true);
        var recordId = component.get("v.recordId");
            var action = component.get("c.reqSubmit");
            action.setParams({
                recordId : recordId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var msg = response.getReturnValue();

                // console.log("Response state: " + state);
                // console.log("Response msg: " + msg);
                if(msg === "SUCCESS"){
                    
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success"),
                            "message": $A.get("$Label.c.DNS_MSG_RFQSubmit")
    
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
                }else{
                    var errors = response.getError();
                        // if (errors && errors[0] && errors[0].message) {
                            // 에러 메시지 표시
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                "message": msg,
                                "type": "error"
                            });
                            toastEvent.fire();
                        // }
                }
            });
        $A.enqueueAction(action);
        
    },
    handleClickClose: function(component, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
    }
})