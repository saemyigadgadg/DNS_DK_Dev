({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);
            console.log(action);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },
    copyTextHelper : function(component, event, text) {
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", text);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.body.removeChild(hiddenInput);        
    },
    getInterfaceLogList : function (component, event, helper, name) {
        console.log('getInterfaceLogList');
        try {
            helper.apexCall(component, event, helper, 'getInterfaceLogList', {interfaceName : name})
            .then($A.getCallback(function(result) {      
                console.log(result.r);
                component.set('v.data', result.r.data);
            }))
            .catch(function(error) {
                console.log('# getInit error : ' + error.message);
            });
            
        } catch (error) {
            console.log('Popup error ::: ', error);
        }
    }
})