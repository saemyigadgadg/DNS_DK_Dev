({
    closeModal : function(component) {
        var modal = component.find("customerListModal");
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

    gfnGetSearchParams : function(component) {
        return {
            'customerCode':component.get('v.customerCode')
            ,'customerName':component.get('v.customerName')
            ,'type':component.get('v.type')
        };
    },

    gfnGetAgencyList : function(component, event, helper) {
        helper.apexCall(component, event, helper, 'getAgencyList', {
            'targetObject':component.get('v.targetObject')
            ,'searchParams':helper.gfnGetSearchParams(component)
        })
        .then($A.getCallback(function(result) {

            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {
                component.set('v.customerList', r.agencyCustomerList);
                component.set('v.customerShipToList', r.agencyShipToList);
                
                let searchInput = component.find('firstCursor');
                if(Array.isArray(searchInput)) {
                    searchInput = searchInput[0];
                }
                if(searchInput) {
                    searchInput.focus();
                }
            }
            component.set('v.isSpinner', false);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            component.set('v.isSpinner', false);
        });
    }
})