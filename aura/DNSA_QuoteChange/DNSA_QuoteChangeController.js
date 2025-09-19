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
                        "message": returnVal 

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set('v.isStatus', true);
                }
            });
        $A.enqueueAction(action);
    },
    savequoteCopy : function(component, event, helper){
        try {
            var copyReason = component.get('v.copyReason');
        if(!copyReason || copyReason.trim() === ''){
            alert($A.get("$Label.c.DNS_T_QuoteCopyReasonPlace"));
            return;
        }
        component.set('v.isLoading', true);
        var recordId = component.get("v.recordId");
        console.log('copyReason : ' + copyReason);
        console.log('recordId : ' + recordId);
            var action = component.get("c.quoteCopy");
            action.setParams({
                recordId : recordId,
                copyReason : copyReason
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log("Response state: " + state);
                if(state === "SUCCESS"){
                    
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success") + '!',
                            "message": $A.get("$Label.c.DNS_M_Success")
    
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
                        var returnVal = response.getReturnValue();
                        console.log("returnVal : " + returnVal);

                            component.set("v.newRecordId", returnVal);

                            var navService = component.find("navService");
                            var pageReference = {
                            type: "standard__recordPage",
                            attributes: {
                                "recordId": returnVal,
                                "objectApiName": 'Quote',
                                "actionName": "view"
                            }
                        };
                    navService.navigate(pageReference);
                }else{
                    var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            // 에러 메시지 표시
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                "message": $A.get("$Label.c.DNS_M_Error") + " : " + errors[0].message,
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                }
            });
        $A.enqueueAction(action);
        } catch (error) {
            console.log('error : ' + error);
        }
    },
    handleClickClose: function(component, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
    }
})