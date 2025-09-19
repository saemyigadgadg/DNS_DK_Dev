({
    init: function (component) {
        component.set('v.isLoading', true);
        console.log('recordID', component.get('v.recordId'));
        var action = component.get('c.getExtractInfo');
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (response.getState() === 'SUCCESS') {
                console.log('result', result);
                component.set('v.happyCallList', result);
            } else {
                console.log('error');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

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