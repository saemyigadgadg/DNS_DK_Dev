({
    doinit : function(component, event, helper){
        var lineItemList = component.get('v.lineItemList');
        var action = component.get("c.tradeCustomerCheck");
        action.setParams({
            lineItemList : lineItemList
        });

        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal != "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type" : "Error",
                    "title": $A.get("$Label.c.DNS_M_Error"),
                    "message": returnVal

                });
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();

                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }else{
                const title = $A.get("$Label.c.DNS_M_QuotePriceTitle");
                const subtitle = $A.get("$Label.c.DNS_M_QuotePriceSubtitme");
                const confirm = $A.get("$Label.c.DNS_M_Confirm");
                const cancel = $A.get("$Label.c.DNS_M_Cancel");
                component.set('v.title', title);
                component.set('v.subtitle', subtitle);
                component.set('v.confirm', confirm);
                component.set('v.cancel', cancel);
                component.set('v.openModal', true);
            }

        });
        $A.enqueueAction(action);
        
    },
    quotePrice : function(component, event, helper) {
        var lineItemList = component.get('v.lineItemList');
        component.set('v.isLoading', true);

        // console.log(lineItemList);

        var action = component.get("c.getQuotePrice");
        action.setParams({
            lineItemList : lineItemList
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal === "SUCCESS") {
                // console.log('SUCCESS');
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type" : "Success",
                        "title": $A.get("$Label.c.DNS_M_Success"),
                        "message": $A.get("$Label.c.DNS_M_UpdateSuccess")

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();

                    var modalEvent = component.getEvent('modalEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_QuotePriceModal',
                        "actionName"    : 'Close',
                        "message"       : 'erpQuotePrice'
                    });
                    modalEvent.fire();
                component.set('v.openModal', false);

                    
            }else{
                var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                component.set('v.openModal', false);

                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
        
    },

    handleClickClose: function(component, event, helper){
        var modalEvent = component.getEvent('modalEvent');
        // console.log('modalEvent', modalEvent);
        modalEvent.setParams({
            "modalName": 'DN_QuotePriceModal',
            "actionName": 'Close',
            "message": 'ClosePrice'
        });
        modalEvent.fire();
    }
})