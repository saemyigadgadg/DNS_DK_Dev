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
    

    // Phone 필드 값 정규식 : 숫자만 입력 되도록 수정
    // phoneNumberCheck : function (number) {
    //     if (!number) return false;
    //     let result = /^[0-9]*$/;
    //     return result.test(number);
    // },

    // // Phone 필드 값 정규식 : e.g. 010-1234-1234 or 011-123-1234
    // phoneNumberCheck : function (number) {
    //     if (!number) return false;
    //     let result = /^(01[016789])-?(\d{3,4})-?(\d{4})$/;
    //     return result.test(number);
    // },
})