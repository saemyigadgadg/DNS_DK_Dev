({
    myAction: function (component, event, helper) {
        let action = component.get("c.getServiceOrderNumber");
        action.setParams({ recordId: component.get("v.recordId") });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let serviceOrderNumber = response.getReturnValue();
                component.set("v.orderNumber", serviceOrderNumber);
            } else {
                console.error("Failed to ServiceOrderNumber__c");
            }
        });

        $A.enqueueAction(action);
    },

    handleClose: function (component, event, helper) {
        // 모달 닫기
        component.set("v.isOpen", false);
    },

})