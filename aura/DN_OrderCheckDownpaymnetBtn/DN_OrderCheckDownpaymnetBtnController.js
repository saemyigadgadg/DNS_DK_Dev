({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.callIFDownPayment");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                if(returnVal.isSuccess) {
                    if(returnVal.errorMsg) {
                        helper.toast('warning', '', returnVal.errorMsg);

                    } else {
                        helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_RetrievedDownPayment"));
                        // The status data has been retrieved. Please check it in the Payment Schedule tab.
                    }
                    helper.closeModal();
                } else {
                    helper.handleError('validateOrderConfrim', returnVal.errorMsg);
                    helper.closeModal();
                }
            } else {
                helper.handleError('validateOrderConfrim', response.getError());
                helper.closeModal();
            }
        });
        $A.enqueueAction(action);
    }
})