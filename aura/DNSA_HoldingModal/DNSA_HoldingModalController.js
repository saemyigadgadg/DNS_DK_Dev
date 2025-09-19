({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        // helper.apexCall(component, event, helper, 'checkPending', {
        //     recordId : component.get('v.recordId')
        // })
        // .then($A.getCallback(function(result) {
        //     let r = result.r;
        //     console.log('r', r);

        // }))
        // .catch(function(error) {
        //     console.log('# initPricing error : ' + error.message);
            component.set('v.isLoading', false);
        // });
    },



    handleClickConfirm : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'setHolding', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r == 'Success') {
                helper.toast('Success', $A.get("$Label.c.DNSA_QUOTE_T_HOLDINGSUCCESS"));
                component.set('v.isLoading', false);
                helper.closeModal();
            } else if(r == 'null') {
                helper.toast('Error', $A.get("$Label.c.DNSA_QUOTE_T_HOLDINGNULL"));
                component.set('v.isLoading', false);
            } else {
                helper.toast('Error', r);
                component.set('v.isLoading', false);
            }

        }))
        .catch(function(error) {
            console.log('# pendingConfirm error : ' + error.message);
            helper.toast('Error', 'An error occurred, please contact your administrator.');
            component.set('v.isLoading', false);
        });
    },

    handleCancel : function(component, event, helper) {
        helper.closeModal();
    }
})