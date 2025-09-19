({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.roleCheck");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            // console.log('result : ' + response);
            if(result != 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.DNS_M_Error"),
                    "message": result,
                    "type": "error"
                });
                toastEvent.fire();
                component.set('v.openModal', false);
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();

            }else{
                component.set('v.openModal', true);
            }
        });
        $A.enqueueAction(action);
    },
    handleClickClose: function(component, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
    },
    
    requestReview : function(component, event, helper) {
        var requestReason = component.get('v.requestReason');
        component.set('v.isLoading', true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.reviewRequest");

        action.setParams({
            recordId : recordId,
            requestReason : requestReason
        });
        action.setCallback(this, function(response){
        var state = response.getState();
            var result = response;
            if(state  === 'SUCCESS'){
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
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.DNS_M_Error"),
                    "message": $A.get("$Label.c.DNS_M_Error") + " : " + errors[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);

    }   
    
})