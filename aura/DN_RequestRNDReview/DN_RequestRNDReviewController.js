({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'reviewReqInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(!r) {
                helper.toast('Error', $A.get("$Label.c.DNS_REVIEW_T_NOAUTH"));
                component.find('overlayLib').notifyClose();
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# reviewReqInit error : ' + error.message);
        });
    },

    handleClickRequest : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'createReviewSQ', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            

            helper.toast(r.flag, r.message);
            component.find('overlayLib').notifyClose();
            component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# createReviewSQ error : ' + error.message);
        });
    },

    handleClickClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
    }
})