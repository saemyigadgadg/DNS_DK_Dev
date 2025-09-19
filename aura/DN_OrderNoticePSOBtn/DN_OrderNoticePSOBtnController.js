({
    doInit : function(component, event, helper) {

        const recordId = component.get('v.recordId');
        var initAction = component.get("c.validateOrder");
        initAction.setParams({ recordId: recordId, isCPO: false });
        initAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var initResult =  response.getReturnValue();

                if(initResult.isPass) {
                    const myUrl = initResult.vfPageUrl + '?Id='+recordId;
                    
                    component.set('v.iframeSrc', myUrl);
                } else {
                    component.find("notifLib").showToast({
                        "title": $A.get("$Label.c.DNS_M_GeneralError")
                        , "message": initResult.errorMsg
                        , "variant": 'error'
                    });

                    $A.get('e.force:closeQuickAction').fire();
                    $A.get('e.force:refreshView').fire();
                }
                
                component.set('v.isLoading', false);
                
            } else {
                let error = response.getError();
                console.log("validateOrder - error", JSON.stringify(error));
                component.find("notifLib").showToast({
                    "title": $A.get("$Label.c.DNS_M_GeneralError")
                    , "message": error[0].message
                    , "variant": 'error'
                });
            }
        });
        $A.enqueueAction(initAction);
    }
})