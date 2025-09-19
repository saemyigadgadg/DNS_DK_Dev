/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-15-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    closedModal : function(component) {
        var modal = component.find("orderStatusDetailModal");
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

    updateFieldValue: function(component, event) {
        console.log('helper selected')
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");
        let index = event.getSource().get('v.accesskey'); 

        component.set("v." + fieldName, fieldValue);

        if(fieldName == 'Urgency__c') {
            var poi = component.get('v.tList');
            poi[index].urgency = fieldValue == 'true' ? 'true' : 'false';
            console.log('poi :: ' +JSON.stringify(poi,null,4))
            component.set('v.tList', poi);
        }
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

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's':response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log('error :: ' + methodName + 'message :: ' + errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },
})