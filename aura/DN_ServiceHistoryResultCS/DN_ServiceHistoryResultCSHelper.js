({
    apexCall : function( component, event, helper, methodName, params ) {
        let self = this;
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
                        reject(errors);
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

    closeModal : function (component) {
        const modals = [
            'v.brokenAreaModal', 
            'v.phenomenonModal', 
            'v.causeModal', 
            'v.detailActionModal', 
            'v.statusModal'
        ];
    
        modals.forEach(modal => component.set(modal, false));
    },

    daycounter : function (sDate, eDate) {
        var diff = new Date(eDate) - new Date(sDate);
        var daySecond = 24*60*60*1000;
        var result = parseInt(diff/daySecond);
        console.log('result :: ' + result + '일');
        return result
    }
})