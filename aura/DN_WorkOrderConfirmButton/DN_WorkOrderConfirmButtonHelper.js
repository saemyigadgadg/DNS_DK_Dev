({
    showToast: function(title, message, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
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