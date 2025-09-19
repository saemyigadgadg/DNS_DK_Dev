({
    handleClickSubmit : function(component, event, helper) {
        component.set('v.isLoading', true);
        
        // Apex Call
        helper.apexCall(component, event, helper, 'setRejectBackGroundColor', {
            reviewId : component.get('v.reviewId'),
            color : true,
            reason : component.get('v.reason')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;

            if(r == 'fail') {
                helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            } else {
                helper.toast('Success', $A.get("$Label.c.DNS_REVIEW_SUCCESSREJECT"));
                helper.closeModal(component, event);
                helper.init(component, event);
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