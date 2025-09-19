({
    handleClickSubmit : function(component, event, helper) {
        component.set('v.isLoading', true);
        console.log(component.get('v.reason'));
        
        // Apex Call
        helper.apexCall(component, event, helper, 'sendRefineRequirements', {
            recordId : component.get('v.recordId'),
            rowId : component.get('v.rowId'),
            reason : component.get('v.reason')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;

            if(r == 'fail') {
                helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            } else {
                helper.toast('Success', $A.get("$Label.c.DNS_REQ_T_CREATEREFINE"));
                helper.closeModal(component, event);
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# sendRefineRequirements error : ' + error.message);
        });
    },

    handleClickClose : function(component, event, helper) {
        helper.closeModal(component, event);
    }
})