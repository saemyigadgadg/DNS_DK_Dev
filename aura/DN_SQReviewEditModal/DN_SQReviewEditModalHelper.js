({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    init : function(component, event) {
        component.set('v.isLoading', true);
        
        // Apex Call
        this.apexCall(component, event, this, 'getSQReviewEditInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            component.set('v.picklistValue', r.getTypePicklist);
            component.set('v.rowDataList', r.getReviewDatas);
            
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getSQReviewEditInit error : ' + error.message);
        });
    },

    handleSave : function(component, event, recordsToSave, rowDataList) {
        var self = this;
        component.set('v.isLoading', true);
        console.log('recordsToSave :' + JSON.stringify(recordsToSave, null, 2));
        

        // Apex Call
        this.apexCall(component, event, this, 'insertSQReview', {
            records : recordsToSave,
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'Success') {
                self.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_COMPLETE"));
                self.handleClose(component, event);
                self.handleRefresh(component, event);
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_REVIEW_T_FAIL"));
            }
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# insertSQReview error : ' + error.message);
        });
    },

    handleDelete : function(component, event, idsToDelete) {
        var self = this;
        component.set('v.isLoading', true);

        // Apex Call
        this.apexCall(component, event, this, 'deleteSQReview', {
            recordIds : idsToDelete
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'Success') {
                self.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_SUCCESSMODIFI"));
                self.handleClose(component, event);
                component.set('v.deletedRows', []);
                self.handleRefresh(component, event);
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_REVIEW_T_FAILMODIFI"));
            }
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# deleteSQReview error : ' + error.message);
        });
    },
    
    handleClose : function(component, event) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_SQReviewEditModal',
            "actionName"    : 'CloseReviewEdit',
            "message"       : 'CloseReviewEdit'
        });
        modalEvent.fire();
    },

    handleRefresh : function(component, event) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_SQReviewEditModal',
            "actionName"    : 'RefreshSQReview',
            "message"       : 'RefreshSQReview'
        });
        modalEvent.fire();
    }
})