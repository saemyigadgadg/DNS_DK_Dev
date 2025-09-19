({
    doInit : function(component, event, helper) {
        const empApi = component.find('empApi');
        const channel = '/event/refreshEvent__e';
        const replayId = -1;

        empApi.subscribe(channel, replayId, $A.getCallback(function (message) {
            if(message.data.payload.objectName__c == 'SQRegistration') {
                helper.init(component, event, helper);
            }
        })).then(function (subscription) {
            console.log('Subscribed to Platform Event:', subscription.channel);
            component.set('v.subscription', subscription);
        });
        helper.init(component, event, helper);
    },

    handleClickSelect : function(component, event, helper) {
        try {
            const selectedValue = event.getParam('value');
            const [action, recordId] = selectedValue.split('-');
            console.log('action', action);
            
            
            if(action === 'Edit') {
                helper.handleEdit(component, event, recordId);
            } else if(action === 'Skip') {
                helper.handleSkip(component, event, recordId);
            } else if(action === 'Reject') {
                helper.handleReject(component, event, recordId);
            } else if(action === 'Clear') {
                helper.handleClear(component, event, recordId);
            } else if(action === 'ReSubmit') {
                helper.handleRequest(component, event, recordId);
            } else if(action === 'Complete') {
                helper.handleComplete(component, event, recordId);
            }
        } catch (error) {
            console.log('# handleClickSelect error : ' + error.message);
        }
    },

    handleClickTextSave : function(component, event, helper) {
        component.set('v.isRichLoading', true);
        component.set('v.backgroundColor', 'background: #f3f3f3;')
        // Apex Call
        helper.apexCall(component, event, helper, 'saveRichTextValue', {
            richTextContent : component.get('v.richTextContent'),
            recordId : component.get('v.recordId'),
            type : 'review'
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            component.set('v.isEditable', false);
            component.set('v.isRichLoading', false);
        }))
        .catch(function(error) {
            console.log('# changeCategory error : ' + error.message);
        });
    },

    handleClickTextEdit : function(component, event, helper) {
        component.set('v.isEditable', true);
        component.set('v.backgroundColor', 'background: #EAF5FE;')
    },

    handleClickReviewEdit : function(component, event, helper) {
        component.set('v.isEditReview', true);
    },

    handleClickReviewSearch : function(component, event, helper) {
        try {
            component.set('v.isSearchReview', true);
        } catch (error) {
            console.log('error', error.message);
        }
    },

    handleClickReviewDescription: function (component, event, helper) {
        var divElement = event.currentTarget;
        console.log('divElement', divElement);
        const reviewId = divElement.getAttribute("data-review-id");
        console.log('reviewId', reviewId);
    
        if (reviewId) {
            const [recordId1, recordId2] = reviewId.split('-');
    
            component.set('v.reviewId', recordId1);
            component.set('v.reviewId2', recordId2);
            component.set('v.isReviewDescription', true);
        } else {
            console.error('🍅 reviewId not found!');
        }
    },
    

    handleModalEvent: function (component, event, helper) {
        console.log('handleModalEvent');
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");
        
        if(message == 'CloseReviewSearch') {
            component.set('v.isSearchReview', false);
        } else if(message == 'CloseReviewEdit') {
            component.set('v.isEditReview', false);
        } else if(message == 'CloseChangeManager') {
            component.set('v.isChangeManager', false);
        } else if(message == 'CancelReviewDescription') {
            component.set('v.isReviewDescription', false);
        } else if(message == 'InitChangeManager') {
            // helper.init(component, event);
            $A.get('e.force:refreshView').fire();
        } else if(message == 'RefreshSQReview') {
            // helper.init(component, event);
            $A.get('e.force:refreshView').fire();
        } else if(message == 'CloseReject') {
            component.set('v.isReject', false);
        } else if(message == 'InitReject') {
            // helper.init(component, event);
            $A.get('e.force:refreshView').fire();
        } else if(message == 'InitReject') {
            // helper.init(component, event);
            $A.get('e.force:refreshView').fire();
        } else if(message == 'CloseEditSQReview') {
            component.set('v.isClickEdit', false);
        }
    },

    handleClickChangeManager :function (component, event, helper) {
        var divElement = event.getSource().getElement().parentElement;
        var review = divElement.getAttribute("data-review-id");
        const [reviewId, type] = review.split('-');
        component.set('v.reviewId', reviewId);
        component.set('v.reviewType', type);
        
        component.set('v.isChangeManager', true);
    }
})