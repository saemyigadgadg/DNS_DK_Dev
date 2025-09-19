({
	closeModal : function(component) {
        var modal = component.find("resourceAbsenceCreate");
        var modalBackGround = component.find("resourceAbsenceCreateBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
    },
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
                        reject(errors);
                        
                    }
                });
                $A.enqueueAction(action);
            }
        }));
        // .catch(function(error) {
        //     // reject로 전달된 error를 받아서 처리
        //     let errorMessage = 'An error occurred';
        //     if (error && error[0] && error[0].message) {
        //         errorMessage = error[0].message;  // error message를 추출
        //     }
    
        //     // 토스트 메시지 표시
        //     //helper.toast('Error', errorMessage);
        // });
    },
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

})