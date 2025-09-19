({
    navigationTo: function (component, pageReference, isReplace) {
        console.log(JSON.stringify(pageReference));
        let navService = component.find("navService");
        navService.navigate(pageReference, isReplace);
    },
    
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

})