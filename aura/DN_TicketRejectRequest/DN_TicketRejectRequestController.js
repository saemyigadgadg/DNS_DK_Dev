({
    doInit : function(component, event, helper) {

    },

    handleClickSend : function(component, event, helper) {
        component.set('v.isLoading', true);
        
        if(component.get('v.reason') == 'undefined' || component.get('v.reason') == '' || component.get('v.reason') == null) {
            helper.toast('Error', $A.get("$Label.c.DNS_B_REASON_IS_REQUIRED"));
            component.set('v.isLoading', false);
            return;
        }
        // Apex Call
        helper.apexCall(component, event, helper, 'sendTicketRejectRequest', {
            recordId : component.get('v.recordId'),
            reason : component.get('v.reason')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log("🚀 ~ .then ~ r:", r);

            if(r == 'Success') {
                helper.toast('Success', $A.get("$Label.c.DNS_TICKET_REJECTREQUESTSUCCESS"));
                component.set('v.reason', '');
                helper.closeModal();
                component.set('v.isLoading', false);
                $A.get('e.force:refreshView').fire();
            } else {
                helper.toast('Error', $A.get("$Label.c.DNS_TICKET_REJECTREQUESTERROR"));
                component.set('v.isLoading', false);
            }
        }))
        .catch(function(error) {
            console.log('# changeCategory error : ' + error.message);
            helper.toast('Success', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            component.set('v.isLoading', false);
        });
    },

    handleCancel : function(component, event, helper) {
        helper.closeModal();
    }
})