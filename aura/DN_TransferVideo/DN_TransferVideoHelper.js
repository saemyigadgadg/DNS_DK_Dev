({
    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },
    
    closeModal : function(component) {
        var actionModal = $A.get("e.force:closeQuickAction");
        actionModal.fire();
    },
})