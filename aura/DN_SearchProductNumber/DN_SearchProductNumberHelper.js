/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 12-10-2024
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-05-29   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("searchProductModal");
        var modalBackGround = component.find("searchProductModalBackGround");

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

    updateFieldValue: function(component, event) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");

        console.log('fieldName :: ' + fieldName);
        console.log('fieldValue :: ' + fieldValue);

        component.set("v." + fieldName, fieldValue);
    }, 

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    apexCall : function(component, methodName, params) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);
            }

            action.setCallback(self, function(response) {
                if(response.getState() === 'SUCCESS') {
                    resolve({'c':component, 'r':response.getReturnValue(), 's':response.getState()});
                }else {
                    let errors = response.getError();
                    console.error(methodName + ' 해당 로직 고장 : ' + errors);
                    reject(errors);
                }
            });
            $A.enqueueAction(action);
        }))
    },
})