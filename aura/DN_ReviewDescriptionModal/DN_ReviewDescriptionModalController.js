({
    descriptionInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        
        // Apex Call
        helper.apexCall(component, event, self, 'getDescriptionData', {
            recordId : component.get('v.reviewId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            component.set('v.description', r);
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getDescriptionData error : ' + error.message);
        });
    },

    handleClickSave : function(component, event, helper) {
        component.set('v.isLoading', true);
        
        // Apex Call
        helper.apexCall(component, event, self, 'setSQReviewDescription', {
            recordId : component.get('v.reviewId'),
            recordId2 : component.get('v.reviewId2'),
            description : component.get('v.description')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'Success') {
                helper.cancelModal(component);
                helper.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_SUCCESSDESUPDATE"));
            } else {
                helper.toast('Error', $A.get("$Label.c.DNS_REVIEW_T_FAILDESUPDATE"));
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getDescriptionData error : ' + error.message);
        });
    },
    
    handleClickCancel : function(component, event, helper) {
        helper.cancelModal(component);
    },
})