({
    dropInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'checkDropAuth', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            
            if(r == 'fail') { 
                helper.toast('Error', $A.get("$Label.c.DNS_SQR_T_DROPAUTH"));
                component.find('overlayLib').notifyClose();
            }
            if(r == 'Already') { 
                helper.toast('Error', $A.get("$Label.c.DNS_SQR_DROPMESSAGE"));
                component.find('overlayLib').notifyClose();
            }
            

            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# createReviewSQ error : ' + error.message);
        });
    },

    handleClickDrop : function(component, event, helper) {
        let reason = component.get('v.reason');

        if(reason != null) {
            component.set('v.isLoading', true);
            // Apex Call
            helper.apexCall(component, event, helper, 'dropSQ', {
                recordId : component.get('v.recordId'),
                reason : reason
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
                
                if(r == 'success') { 
                    helper.toast('Success', $A.get("$Label.c.DNS_SQR_T_SUCCESSDROP"));
                } else {
                    helper.toast('Error', $A.get("$Label.c.DNS_SQR_T_FAILDROP"));
                }
    
                component.find('overlayLib').notifyClose();
                component.set('v.isLoading', false);
                $A.get('e.force:refreshView').fire();
            }))
            .catch(function(error) {
                console.log('# createReviewSQ error : ' + error.message);
            });
        } else {
            helper.toast('Error', $A.get("$Label.c.DNS_SQR_T_CHECKDROPREASON"));
        }
    },

    handleClickClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
    }
})