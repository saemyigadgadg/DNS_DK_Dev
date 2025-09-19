({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal.Status != "SUCCESS"){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type" : "error",
                        "title": $A.get("$Label.c.DNS_M_Error") + '!',
                        "message": returnVal.Status //이미 주문이 생성 된 견적은 복제가 불가합니다. // Quotes for which an order has already been created cannot be copied.

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set('v.isStatus', true);
                    const btnType = 
                [
                    {'label' : $A.get("$Label.c.DNS_M_Cancel"), 'value' : 'cancel'},
                    {'label' : $A.get("$Label.c.DNS_M_Confirm"), 'value' : 'confirm'}
                ];
                component.set('v.btnType', btnType);
                component.set('v.title', $A.get("$Label.c.DNS_T_FinalQuoteTitle"));
                component.set('v.subtitle', $A.get("$Label.c.DNS_T_FinalQuoteSubtitle"));
                component.set('v.label', $A.get("$Label.c.DNS_T_FinalQuoteLabel"));
                // console.log('returnVal.TotalAmount : ' + returnVal.TotalAmount);
                component.set('v.FPAmount', returnVal.TotalAmount);
                }
            });
        $A.enqueueAction(action);
        component.set("v.dataLoad", true);
    },
    selectBtn : function(component, event, helper){
        var getValue = event.getParam('value');
        var inputElement = component.find("FPAmount");
        // console.log(getValue);
        // console.log(component.get("v.recordId"));
        // console.log(inputElement.get("v.value"));

        if(getValue === "confirm" && getValue != undefined){
            // console.log('1');
            component.set("v.dataLoad", false);

            var action = component.get("c.updateFinalQuote");
            action.setParams({
                recordId : component.get("v.recordId"),
                FPAmount : inputElement.get("v.value")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                // console.log(state);
                if(state === "SUCCESS"){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success"),
                            "message": $A.get("$Label.c.DNS_M_Success")
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
                        component.set("v.dataLoad", true);

                }else{
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        // 에러 메시지 표시
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.DNS_M_GeneralError"), // Error Occurred.
                            "message": $A.get("$Label.c.DNS_ACC_T_ADMIN"), // An error occurred, please contact your administrator.
                            "type": "error"
                        });
                        toastEvent.fire();
                        component.set("v.dataLoad", true);
                    }
                }
            });
        $A.enqueueAction(action);
        }else{
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
        
    }
})