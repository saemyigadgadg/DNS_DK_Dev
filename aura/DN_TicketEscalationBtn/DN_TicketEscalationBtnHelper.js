/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-02-20
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-20   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
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
                        // let errors = response.getError();
                        let errors = response.getError()[0].pageErrors[0].message;
                        // console.log(methodName, errors);
                        helper.toast(component, 'Error', errors, 'error');
                        component.set('v.isLoading', false);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    closeModal: function () {
        var closeModal = $A.get("e.force:closeQuickAction");
        closeModal.fire();
    },
})