({
    doInit : function(component, event, helper) {
        helper.setPlantData(component);
    },

    handleCloseModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    handleClickRow : function(component, event, helper) {
        var plant = event.currentTarget.getAttribute("data-plant");
        console.log('Plant:', plant);
        component.set('v.plant', plant);

        var modalEvent = component.getEvent('cmpEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_CustomsClearancePlantModal',
            "actionName"    : 'handleClickRow',
            "message"       : plant
        });
        modalEvent.fire();

        helper.closeModal(component);
    }
})