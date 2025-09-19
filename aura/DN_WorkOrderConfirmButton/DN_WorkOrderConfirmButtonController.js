({
    handleConfirm : function(component, event, helper) {
        component.set("v.isSpinner", true);
        let action = component.get("c.changeStatus");
        action.setParams({ recordId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log("결과 :::", result);

                if (result === "SUCCESS") {
                    helper.showToast("SUCCESS", $A.get("$Label.c.DNS_M_ConfirmSuccess"), "success");
                    $A.get('e.force:refreshView').fire();

                    helper.closeModal(component);
                } else {
                    helper.showToast("ERROR", result, "error");
                }
            } else {
                helper.showToast("ERROR", $A.get("$Label.c.DNS_M_ConfirmFail"), "error");
            }

            component.set("v.isSpinner", false); 
        });

        $A.enqueueAction(action);
    },
    handleClose : function(component, event, helper) {
        helper.closeModal(component);
    },
})