({
    doInit : function(component, event, helper) {
        component.set('v.isStatus',     true);
        component.set('v.confirm',      $A.get("$Label.c.DNS_B_QuoteConfirm"));
        component.set('v.cancel',       $A.get("$Label.c.DNS_M_Cancel"));
    },

    savequoteCopy: function(component, event, helper){
        component.set('v.isLoading', true);
        
        // Apex Call
        helper.apexCall(component, event, helper, 'cloneCommodityQuote', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('DNSA result', r);

            if(r.isSuccess) {
                helper.toast('Success', 'Commodity Quote has been cloned.');
                component.set('v.isLoading', false);
                helper.closeModal();

                var navService = component.find("navService");
                var pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        "recordId": r.returnValue,
                        "objectApiName": 'Quote',
                        "actionName": "view"
                    }
                };
                navService.navigate(pageReference);

            } else {
                helper.toast('Error', r.errMessage);
                component.set('v.isLoading', false);
            }

            
        }))
        .catch(function(error) {
            console.log('# savequoteCopy error : ' + error.message);
        });
    },

    handleClickClose: function(component, event, helper){
        helper.closeModal();
    },
})