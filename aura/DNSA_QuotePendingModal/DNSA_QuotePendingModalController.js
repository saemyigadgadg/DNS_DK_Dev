({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'checkPending', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r.seq != '1') {
                helper.toast('Error', 'Only the first booker can make a Pending Request.');
                component.set('v.isLoading', false);
                helper.closeModal();
                return;
            }
            if(!r.isProduct) {
                helper.toast('Error', 'Quote Line Item doesn\'t exist.');
                component.set('v.isLoading', false);
                helper.closeModal();
                return;
            }
            if(r.isOrder) {
                helper.toast('Error', 'An Order already exists.');
                component.set('v.isLoading', false);
                helper.closeModal();
                return;
            }
            
            /* Portal Request Pending */
            if(r.isPartner) {
                if(!r.isFile) {
                    helper.toast('Error', 'Please upload relevant file.');
                    component.set('v.isLoading', false);
                    helper.closeModal();
                    return;
                }
                if(r.isPending) {
                    helper.toast('Error', 'You\'ve already requested Pending.');
                    component.set('v.isLoading', false);
                    helper.closeModal();
                    return;
                }
                component.set('v.isPending', r.isPending);
            } else {
                /* CRM Pending Confirm */
                if(!r.isPending) {
                    helper.toast('Error', 'This stock reservation has not been requested pending.');
                    component.set('v.isLoading', false);
                    helper.closeModal();
                    return;
                }
                component.set('v.isPending', r.isPending);
            }
            component.set('v.stockNum', r.stockNum);

            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# initPricing error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleClickPending : function(component, event, helper) {
        component.set('v.isLoading', true);

        if(component.get('v.reason') == null || component.get('v.reason') == '') {
            helper.toast('Error', 'Please enter a reason.');
            component.set('v.isLoading', false);
            return;
        }

        // Apex Call
        helper.apexCall(component, event, helper, 'requestPending', {
            recordId : component.get('v.recordId'),
            reason : component.get('v.reason'),
            VBELN_ST : component.get('v.stockNum')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r == 'Success') {
                helper.toast('Success', 'Pending request succeeded.');
            } else if(r == 'error') {
                helper.toast('Error', 'Pending request failed.');
            } else {
                helper.toast('Error', r);
            }
            component.set('v.isLoading', false);
            helper.closeModal();
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# requestPending error : ' + error.message);
            helper.toast('Error', 'An error occurred, please contact your administrator.');
            component.set('v.isLoading', false);
        });
    },

    handleClickConfirm : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'pendingConfirm', {
            recordId : component.get('v.recordId'),
            VBELN_ST : component.get('v.stockNum'),
            reason : component.get('v.reason')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r == 'Success') {
                helper.toast('Success', 'Pending request succeeded.');
            } else if(r == 'error') {
                helper.toast('Error', 'Pending request failed.');
            } else {
                helper.toast('Error', r);
            }
            component.set('v.isLoading', false);
            helper.closeModal();
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# pendingConfirm error : ' + error.message);
            helper.toast('Error', 'An error occurred, please contact your administrator.');
            component.set('v.isLoading', false);
        });
    },

    handleClickReject : function(component, event, helper) {
        component.set('v.isLoading', true);

        // Apex Call
        helper.apexCall(component, event, helper, 'cancelReservation', {
            recordId : component.get('v.recordId'),
            reason : component.get('v.reason')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r == 'success') {
                helper.toast('Success', 'Pending reject succeeded.');
            } else if(r == 'fail') {
                helper.toast('Error', 'Pending reject failed.');
            } else {
                helper.toast('Error', r);
            }
            component.set('v.isLoading', false);
            helper.closeModal();
            $A.get('e.force:refreshView').fire();
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