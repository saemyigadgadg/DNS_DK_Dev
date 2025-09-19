({
    doInit : function(component, event, helper) {
        helper.reverseSpinner(component);

        var action = component.get("c.fetchInit");
        action.setParams({ recordId : component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('doInit result - ', JSON.stringify(returnVal, null, 1));

                if(!returnVal.isPass) {
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.errorMsg);
                    helper.closeModal();
                    return;
                }

                component.find('AccountId').set('v.value', returnVal.AccountId);
                
                helper.reverseSpinner(component);
            } else {
                helper.handleError('doInit', response.getError());
                helper.closeModal();
            }
        });
        $A.enqueueAction(action);
    }

    , handleClose: function(component, event, helper) {
        helper.closeModal();
    }

    , handleSubmit: function(component, event, helper) {
        event.preventDefault();
        helper.reverseSpinner(component);

        const fields = event.getParam('fields');

        var action = component.get("c.saveOptionOnlyOrder");
        action.setParams({ 
            recordId : component.get('v.recordId')
            , newOrder : fields
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();

                helper.toast('success', $A.get("$Label.c.DNS_M_Success"), "Option Only Order has been successfully created.");
                helper.closeModal();
                var navService = component.find("navService");
                var pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        "recordId": returnVal,
                        "objectApiName": 'Order',
                        "actionName": "view"
                    }
                };
                navService.navigate(pageReference);
            } else {
                helper.handleError('handleSubmit', response.getError());
                helper.reverseSpinner(component);
            }
        });
        $A.enqueueAction(action);
    }

    , handleError: function(component, event, helper) {
        helper.handleError('handleError', event.getParam("message"));
        console.log("Error error : " + JSON.stringify(event.getParam("error"), null, 1));
    }
})