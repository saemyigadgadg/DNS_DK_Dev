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
    handleClickConfirm : function(component, event, helper) {
        component.set('v.isLoading', true);

        try {
            // Apex Call
            helper.apexCall(component, event, helper, 'sendControlAlert', {
                recordId : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);

                if(r == 'Success') {
                    helper.toast('Success', 'Alert sent successfully.');
                    component.set('v.isLoading', false);
                    helper.closeModal();
                } else {
                    helper.toast('Error', 'An error occurred, please contact your administrator.');
                    component.set('v.isLoading', false);
                    helper.closeModal();
                }
            }))
            .catch(function(error) {
                console.log('# sendControlAlert error : ' + error.message);
                helper.toast('Error', 'An error occurred, please contact your administrator.');
                component.set('v.isLoading', false);
            });
        } catch (error) {
            console.log('# handleClickConfirm error : ' + JSON.stringify(error.message));    
        }
    },

    handleCancel : function(component, event, helper) {
        helper.closeModal();
    }
})