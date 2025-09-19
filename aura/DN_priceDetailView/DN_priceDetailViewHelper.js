({
    apexCall : function(component, methodName, params) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's':response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log('error :: ' + methodName + 'message :: ' + errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, msg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: msg
        });
        toastEvent.fire();
    }
})