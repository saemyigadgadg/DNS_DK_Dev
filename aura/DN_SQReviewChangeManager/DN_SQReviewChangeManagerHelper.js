({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

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

    closeModal : function(component) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_SQReviewChangeManager',
            "actionName"    : 'CloseChangeManager',
            "message"       : 'CloseChangeManager'
        });
        modalEvent.fire();
    },

    init : function(component, event) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_SQReviewChangeManager',
            "actionName"    : 'InitChangeManager',
            "message"       : 'InitChangeManager'
        });
        modalEvent.fire();
    },

    searchManager : function(component, event, helper) {
        var self = this;
        try {
            component.set('v.isLoading', true);
            // Apex Call
            self.apexCall(component, event, self, 'searchManager', {
                keyword : component.get('v.keyword')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
                
                component.set('v.searchDataList', r);
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# searchManager error : ' + error.message);
            });
        } catch (error) {
            console.log('searchManager Error : ' + error);
        }
    },
})