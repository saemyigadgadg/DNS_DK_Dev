({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal === "ERROR"){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type" : "error",
                        "title": $A.get("$Label.c.DNS_M_Error") + '!',
                        "message": $A.get("$Label.c.DNS_M_CantQuoteCopyOrder") //이미 주문이 생성 된 견적은 복제가 불가합니다. // Quotes for which an order has already been created cannot be copied.

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set('v.isStatus', true);
                    const btnType = 
                    [
                        {'label' : '취소', 'value' : 'cancel'},
                        {'label' : '복제', 'value' : 'copy'}
                    ];
                    component.set('v.btnType', btnType);
                    component.set('v.title', $A.get("$Label.c.DNS_M_QuoteCopyTItle"))
                    component.set('v.title', $A.get("$Label.c.DNS_M_QuoteCopySubTItle"))
                    component.set('v.confirm', $A.get("$Label.c.DNS_B_QuoteConfirm"));
                    component.set('v.cancel', $A.get("$Label.c.DNS_M_Cancel"));
                    component.set('v.reason', $A.get("$Label.c.DNS_T_QuoteCopyReason"));
                    component.set('v.reasonPlace', $A.get("$Label.c.DNS_T_QuoteCopyReasonPlace"));
                }
            });
        $A.enqueueAction(action);
    },
    savequoteCopy : function(component, event, helper){
        var copyReason = component.get('v.copyReason');

        //이유 입력하지 않아도 가능하게_250314
        if(!copyReason || copyReason.trim() === ''){
            // alert($A.get("$Label.c.DNS_T_QuoteCopyReasonPlace"));
            // return;
            copyReason = '';
        }
        component.set('v.isLoading', true);
        var recordId = component.get("v.recordId");
        // console.log('copyReason : ' + copyReason);
        // console.log('recordId : ' + recordId);
            var action = component.get("c.quoteCopy");
            action.setParams({
                recordId : recordId,
                copyReason : copyReason
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                // console.log("Response state: " + state);
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
                        // console.log("returnVal : " + returnVal);

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
        
    },
    handleClickClose: function(component, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
    }
})