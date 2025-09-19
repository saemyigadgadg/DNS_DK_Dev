({
    cancelModal : function(component) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DNSA_DescriptionModal',
            "actionName"    : 'CancelDescriptionModal',
            "message"       : 'CancelDescriptionModal'
        });
        modalEvent.fire();
    },
})