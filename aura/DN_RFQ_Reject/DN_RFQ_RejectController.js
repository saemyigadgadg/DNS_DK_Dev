({
    doinit : function(component, event, helper){

        var recordId = component.get("v.recordId");
        var action = component.get("c.currentStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal != 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal, //반려 및 기각은 Sales Confirm, SE Receipt 단계에서만 가능합니다., Rejection and disapproval are only allowed at the Sales Confirm and SE Receipt stages.
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
            }else{
                const title = $A.get("$Label.c.DNS_M_RFQRejectTitle");
                const subtitle = $A.get("$Label.c.DNS_M_RFQRejectSubtitle");
                const confirm = $A.get("$Label.c.DNS_M_Confirm");
                const cancel = $A.get("$Label.c.DNS_M_Cancel");
                const reason = $A.get("$Label.c.DNS_M_RFQRejectReason");
                const reasonPlace = $A.get("$Label.c.DNS_M_RFQRejectReasonPlace");
                const options = [{'label': $A.get("$Label.c.DNS_M_RFQOptionreject"), 'value': 'Reject'},
                    {'label': $A.get("$Label.c.DNS_M_RFQOptiondiscard"), 'value': 'Discard'}];
                component.set('v.title', title);
                component.set('v.subtitle', subtitle);
                component.set('v.confirm', confirm);
                component.set('v.cancel', cancel);
                component.set('v.reason', reason);
                component.set('v.reasonPlace', reasonPlace);
                component.set('v.options', options);
                component.set('v.status', true);
            }
        });
        $A.enqueueAction(action);

        
    },
    saveRFQJect : function(component, event, helper){
        var rejectType = component.get('v.actionType');
        if(rejectType == undefined){
            // alert('반려 또는 기각을 선택해주세요.');
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_RFQError"),
                        "type": "error"
                    });
                    toastEvent.fire();
            return;
        }
        var rejectReason = component.get('v.rejectReason');
        if(!rejectReason || rejectReason.trim() === ''){
            // alert(rejectType + ' 사유를 입력해 주세요.');
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_RFQRejectReasonPlace"),
                        "type": "error"
                    });
                    toastEvent.fire();
            return;
        }
        component.set('v.isLoading', true);
        var recordId = component.get("v.recordId");
            var action = component.get("c.rfqRejct");
            action.setParams({
                recordId : recordId,
                rejectReason : rejectReason,
                rejectType : rejectType
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
                            "title": $A.get("$Label.c.DNS_M_Success"),
                            "message": $A.get("$Label.c.DNS_M_Success")
    
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
                }else{
                    var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            // 에러 메시지 표시
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                // "message": $A.get("$Label.c.DNS_M_Error"),
                                "message": errors[0].message,
                                "type": "error"
                            });
                            toastEvent.fire();
                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();
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