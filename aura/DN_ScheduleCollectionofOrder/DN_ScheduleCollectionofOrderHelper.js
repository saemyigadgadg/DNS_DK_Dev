({
    apexCall : function(component, methodName, params) {
        console.log('methodName' + ' || ' + methodName);
        console.log('params' + ' || ' + JSON.stringify(params,null,4));

        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);
                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's': response.getState()});
                    } else {
                        let errors = response.getError();
                        console.error('apexCall 에러 :: '+methodName +' '+ JSON.stringify(errors,null,4));
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    
    toast : function(type, msg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: msg
        });
        toastEvent.fire();
    },
})