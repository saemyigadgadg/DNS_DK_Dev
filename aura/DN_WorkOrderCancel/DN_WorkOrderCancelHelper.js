({
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    closeModal : function(component) {
        var actionModal = $A.get("e.force:closeQuickAction");
        actionModal.fire();
    },
    navigateToRecord : function(component, recordId) {
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
    },
})