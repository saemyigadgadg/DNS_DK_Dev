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
                        //console.log(JSON.stringify(errors),' errors helpler');
                        //console.log(methodName, errors);
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
    userAccess : function(component, event, helper) {
        let self = this;
        let recordId = component.get('v.recordId');
        console.log(recordId,' ::: recordId');
        this.apexCall(component, event, helper, 'getDealerCustomer', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log(r,' ::: rrr');
            component.set('v.isCheck', r);
            // 수정불가
            if(r) {
                self.toast('error', '대리점 고객은 수정이 불가능합니다.');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } 
        }))
        .catch(function(error) {
            console.log('# searchAddress error : ' + error.message);
        });
    },
})