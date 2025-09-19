({
    modalInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'getReviewEditLayout', {
            
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            component.set('v.fieldList', r);
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getReviewEditLayout error : ' + error.message);
        });
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        component.set('v.isLoading', true);

        var fields = event.getParam("fields");
        var sqTitle = fields.SQTitle__c;
        var hasError = false;

        if (sqTitle && sqTitle.length > 40 && sqTitle !== 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
            hasError = true;
        }

        if (hasError) {
            component.set('v.isLoading', false);
            helper.toast('Error', 'SQ Title은 40자를 초과할 수 없습니다.');
            return;
        }

        component.find("recordEditForm").submit(fields);
    },


    handleSuccess : function(component, event, helper) {
        component.set('v.isLoading', false);
        helper.toast('Success', 'The SQ Review has been edited.');
        helper.closeModal(component, event);
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_EditSQReviewModal',
            "actionName"    : 'edit',
            "message"       : 'RefreshSQReview'
        });
        modalEvent.fire();
    },

    handleError : function(component, event, helper) {
        const errorMessage = event.getParam('message');
        helper.toast('Error', errorMessage);
        component.set('v.isLoading', false);
    },

    handleClickClose : function(component, event, helper) {
        helper.closeModal(component, event);
    }
})