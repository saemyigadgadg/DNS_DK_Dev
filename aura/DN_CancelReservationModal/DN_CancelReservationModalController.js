({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'cancelInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('cancelInit result', r);
            
            if(r.flag == 'order') {
                helper.toast('Error', r.message);
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
            }

            if(r.getCancelProductInfo.length == 0) {
                component.set('v.isLoading', false);
                helper.toast('Error', 'The Quote Line Item does not exist.');
                component.find('overlayLib').notifyClose();
            } else {
                component.set('v.productInfo', r.getCancelProductInfo);
                component.set('v.isLoading', false);
            }
        }))
        .catch(function(error) {
            console.log('# cancelInit error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleClickApply : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'cancelReservation', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            if(r == 'success') {
                helper.toast('Success', 'Cancel Reservation Success');
                component.find('overlayLib').notifyClose();
                $A.get('e.force:refreshView').fire();
            } else if(r == 'fail') {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                component.find('overlayLib').notifyClose();
            } else {
                helper.toast('Error', r);
                component.find('overlayLib').notifyClose();
            }

            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# updateSQRegistrationStage error : ' + error.message);
        });
    },

    handleClickClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
    }
})