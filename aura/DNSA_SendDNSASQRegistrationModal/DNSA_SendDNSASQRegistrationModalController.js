({
    handleClickConfirm : function(component, event, helper) {
        component.set('v.isLoading', true);

        try {
            // Apex Call
            helper.apexCall(component, event, helper, 'sendSQRegistrationDNSASalesTeamAlert', {
                recordId : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);

                if(r == 'Success') {
                    helper.toast('Success', 'Alert sent successfully.');
                    component.set('v.isLoading', false);
                    helper.closeModal();
                } else {
                    helper.toast('Error', 'An error occurred, please contact your administrator.');
                    component.set('v.isLoading', false);
                    helper.closeModal();
                }
            }))
            .catch(function(error) {
                console.log('# sendControlAlert error : ' + error.message);
                helper.toast('Error', 'An error occurred, please contact your administrator.');
                component.set('v.isLoading', false);
            });
        } catch (error) {
            console.log('# handleClickConfirm error : ' + JSON.stringify(error.message));    
        }
    },

    handleCancel : function(component, event, helper) {
        helper.closeModal();
    }
})