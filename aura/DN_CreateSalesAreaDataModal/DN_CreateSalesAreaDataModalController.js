({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'initSalesAreaData', {
            recordId    : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r) {
                helper.toast('Error', 'Sales Area Data already exists with a value of 1800.');
                helper.closeModal(component);
            }

            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# initSalesAreaData error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleClickSave : function(component, event, helper) {
        component.set('v.isLoading', true);
        try {
            // Apex Call
            helper.apexCall(component, event, helper, 'insertSalesAreaData', {
                recordId    : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
    
                if(r.flag == 'success') {
                    helper.toast('Success', r.message);
                    helper.closeModal(component);
                    $A.get('e.force:refreshView').fire();
                } else if(r.flag == 'fail') {
                    helper.toast('Error', r.message);
                } else if(r.flag == 'empty') {
                    helper.toast('Error', r.message);
                } else if(r.flag == 'error') {
                    helper.toast('Error', r.message);
                } else if(r.flag == 'office') {
                    helper.toast('Error', r.message);
                }

                component.set('v.isLoading', false);

            }))
            .catch(function(error) {
                console.log('# insertSalesAreaData error : ' + error.message);
                component.set('v.isLoading', false);
            });
        } catch (error) {
            helper.toast('Error', error.message);
            component.set('v.isLoading', false);
        }
    },

    handleClickClose : function(component, event, helper) {
        helper.closeModal(component);
    }
})