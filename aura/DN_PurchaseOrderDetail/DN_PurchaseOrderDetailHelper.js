/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 01-22-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-05-30   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("purchaseOrderDetailModal");
        var modalBackGround = component.find("purchaseOrderDetailModalBackGround");

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

    apexCall : function(component, methodName, params) {
        console.log('helper 동작 확인')
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's': response.getState()});
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

    getNextPart: function(component, rList , target) {
        console.log('helper rList :: ' + rList)
        console.log('helper target :: ' + target)
        let nextValue = '';

        if(rList.length > 0) {
            for (let i = 0; i < rList.length; i++) {
                if (rList[i].MATNR == target) {
                    if (i + 1 < rList.length) {
                        nextValue = rList[i + 1].MATNR;
                        console.log('nextValue : ' +nextValue);
                    }
                    break;
                }
            }
    
            if (nextValue) {
                console.log("Next Value: " + nextValue);
            } else {
                console.log("No next value found for " + target);
            }
    
            return nextValue;    
        }
        else {
            return '';
        }
    },
})