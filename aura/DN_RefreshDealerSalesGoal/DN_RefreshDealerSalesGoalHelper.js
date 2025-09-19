/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-12-06
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-06   yuhyun.park@sbtglobal.com   Initial Version
**/
({

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },


    apexCall: function (component, event, helper, methodName, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            let action = component.get('c.' + methodName);

            if (typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({ 'c': component, 'h': helper, 'r': response.getReturnValue(), 'state': response.getState() });
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


})