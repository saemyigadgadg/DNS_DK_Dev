({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'sqConfirmInite', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;

            if(!r) {
                helper.toast('ERROR', 'Only available to DNSA Sales Team.');
                component.find('overlayLib').notifyClose();
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# updateSQRegistrationStage error : ' + error.message);
        });
    },

    handleClickApply : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'updateSQRegistrationStage', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;

            if(r == 'fail') {
                helper.toast('ERROR', 'An error occurred, please contact your administrator.');
                component.find('overlayLib').notifyClose();
            } else {
                helper.toast('Success', 'SQ Confirm is complete.');
                component.find('overlayLib').notifyClose();
                $A.get('e.force:refreshView').fire();
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