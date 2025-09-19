/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-30-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-30-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var shipToModal = component.find("customerShipToModal");
        var inputModal = component.find("addressInputModal");
        var modalBackGround = component.find("modalBackGround");

        //modal close
        $A.util.removeClass(shipToModal, "slds-fade-in-open");
        //modal close
        $A.util.removeClass(inputModal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(shipToModal, "slds-hide");
        $A.util.addClass(inputModal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
    },

    gfnGetShipTo : function(component, customerCode, customerName) {
        let action = component.get('c.getDealerCustomerShipTo');
        action.setParams({
            customerCode : customerCode,
            customerName : customerName
        });

        action.setCallback(this, function(response) {
            let status = response.getState();
            if(status === "SUCCESS") {
                let result = response.getReturnValue();
                component.set('v.shipToList2', result);
                console.log('shipToList2 :: ' + component.get('v.shipToList2'));
            } else if(status === "ERROR") {
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message) {
                    console.log('errors 사유: '+errors[0].message);
                } else {
                    console.log('error 사유를 확인하지 못했습니다.')
                }
            }
            component.set("v.isLoading", false);
        })
        $A.enqueueAction(action);
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