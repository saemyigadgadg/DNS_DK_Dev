({
    cancelModal : function(component) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DNSA_OpenNoteModal',
            "actionName"    : 'CancelNoteModal',
            "message"       : 'CancelNoteModal'
        });
        modalEvent.fire();
    },
})