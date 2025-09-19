/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-04
 * @last modified by  : yuhyun.park@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-04   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        console.log('closeModal', ' < ===111');
        var modal = component.find("orderListModal");
        var modalBackGround = component.find("modalBackGround");

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
            console.log(action + ' < ==helper');
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
})