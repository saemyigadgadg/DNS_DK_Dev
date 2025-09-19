({
    modalInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'getSQFieldSet', {

        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            component.set('v.fieldList', r);
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getSQFieldSet error : ' + error.message);
        });
    },

    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        component.set('v.isLoading', true);
    
        component.find("recordEditForm").submit();
    },    

    handleSuccess : function(component, event, helper) {
        component.set('v.isLoading', false);
        helper.toast('Success', 'The SQ has been edited.');
        helper.closeModal(component, event);
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_EditSQModal',
            "actionName"    : 'Edit',
            "message"       : 'refreshNewRequestedSQ'
        });
        modalEvent.fire();
    },

    handleError : function(component, event, helper) {
        const errorMessage = event.getParam('message');
        helper.toast('Error', errorMessage);
        component.set('v.isLoading', false);
    },

    handleClickClose : function(component, event, helper) {
        helper.closeModal(component, event);
    }
})