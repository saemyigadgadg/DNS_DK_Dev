/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-26-2024
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-15-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("standardWorkLookupModal");
        var modalBackGround = component.find("modalBackGround");
    
        if (!modal || !modalBackGround) {
            console.error("Modal or Modal Background not found!");
            return;
        }
    
        console.log("Closing modal:", modal);
    
        // Modal 닫기
        $A.util.removeClass(modal, "slds-fade-in-open");
        $A.util.addClass(modal, "slds-hide");
    
        // Modal Background 닫기
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
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
    },


    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    filterStandardWorkList: function (standardWorkList, failureArea) {
        if (!failureArea) {
            return standardWorkList;
        }
    
        return standardWorkList.filter(function (item) {
            return item.FailureArea__c === failureArea;
        });
    }
})