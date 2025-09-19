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

    doOpenDescription: function(component, event, helper) {
        const index = event.getSource().get('v.name');
        let dataRows = component.get('v.dataRows');
        dataRows[index].isExpanded = !dataRows[index].isExpanded;
        
        component.set('v.dataRows', dataRows);
    },

    handleClickNew : function(component, event, helper) {
        if(!component.get('v.isQuoteLineItem')) {
            helper.toast('Error', 'It doesn\'t work if the Quote Line Item is empty.');
        } else {
            component.set('v.isNewClick', true);
        }
    },

    handleClickPreAuth : function(component, event, helper) {
        component.set('v.isPreAuthClick', true);
    },

    handleClickPreAuthClose : function(component, event, helper) {
        component.set('v.isPreAuthClick', false);
    },

    handleClickPreAuthApply : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'cloneSQ', {
            recordId : component.get('v.recordId'),
            type : 'false'
            
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'success') {
                helper.toast('Success', $A.get("$Label.c.DNS_SQ_T_SQCREATION"));
                $A.get('e.force:refreshView').fire();
            } else if(r == 'empty') {
                helper.toast('Error', $A.get("$Label.c.DNS_SQ_T_EMPYREQ"));
            } else {
                helper.toast('Error', $A.get("$Label.c.DNS_SQ_T_FAILFAIL"));
            }
            component.set('v.isLoading', false);
            component.set('v.isPreAuthClick', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# changeCategory error : ' + error.message);
            component.set('v.isLoading', false);
            component.set('v.isPreAuthClick', false);
        });
    },

    handleClickConfirm : function(component, event, helper) {
        component.set('v.isConfirmClick', true);
    },

    handleClicSend : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'sendDNSSalesTeamRequestedSQ', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'Success') {
                helper.toast('Success', 'Alert sent successfully.');
                $A.get('e.force:refreshView').fire();
            } else {
                helper.toast('Error', 'An error occurred, please contact your administrator.');
            }
        }))
        .catch(function(error) {
            console.log('# changeCategory error : ' + error.message);
        });
        component.set('v.isLoading', false);
    },

    handleClickConfirmClose : function(component, event, helper) {
        component.set('v.isConfirmClick', false);
    },

    handleClickConfirmApply : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'cloneSQ', {
            recordId : component.get('v.recordId'),
            type : 'true'
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'success') {
                helper.toast('Success', $A.get("$Label.c.DNS_SQ_T_SQCREATION"));
                $A.get('e.force:refreshView').fire();
            } else if(r == 'empty') {
                helper.toast('Error', $A.get("$Label.c.DNS_SQ_T_EMPYREQ"));
            } else {
                helper.toast('Error', $A.get("$Label.c.DNS_SQ_T_FAILFAIL"));
            }
            component.set('v.isLoading', false);
            component.set('v.isConfirmClick', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# changeCategory error : ' + error.message);
            component.set('v.isLoading', false);
            component.set('v.isConfirmClick', false);
        });
    },

    handleMenuSelect : function(component, event, helper) {
        const selectedValue = event.getParam('value');
        const [action, recordId] = selectedValue.split('-');
        console.log('action', action);
        
        
        
        if (action === 'Edit') {
            helper.handleEdit(component, event, recordId);
        } else if (action === 'Delete') {
            helper.handleDelete(component, event, helper, recordId);
        } else if (action === 'Refine') {
            helper.handleRefine(component, event, helper, recordId);
        } else if (action === 'Complete') {
            helper.handleComplete(component, event, helper, recordId);
        }
    },

    handleClickViewAll : function(component, event, helper) {
        var navService = component.find('navService');
        var pageReference = {
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: component.get('v.recordId'),
                objectApiName: 'SQRegistration__c',
                relationshipApiName: 'SQ_Regist_LineItem__r',
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
    },

    handleClickSave : function(component, event, helper) {
        component.set('v.isRichLoading', true);
        component.set('v.backgroundColor', 'background: #f9f9f9;')
        // Apex Call
        helper.apexCall(component, event, helper, 'saveRichTextValue', {
            richTextContent : component.get('v.richTextContent'),
            recordId : component.get('v.recordId'),
            type : 'requested'
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

    handleClickEdit : function(component, event, helper) {
        component.set('v.isEditable', true);
        component.set('v.backgroundColor', 'background: #EAF5FE;')
    },

    handleModalEvent : function(component, event, helper) {
        console.log('handleModalEvent');
        var actionName = event.getParam('actionName');
        var message = event.getParam('message');
        console.log('message', message);
        
        if(message == 'CloseNewRequestedSQ') {
            component.set('v.isNewClick', false);
        }

        if(message == 'CloseNewRequestedSQ') {
            component.set('v.isPreAuthClick', false);
        }

        if(message == 'refreshNewRequestedSQ') {
            // helper.init(component, event, helper);
            $A.get('e.force:refreshView').fire();
        }
        
        if(message == 'updateRequestedSQ') {
            // helper.init(component, event, helper);
            $A.get('e.force:refreshView').fire();
        }

        if(message == 'CloseRefine') {
            component.set('v.isRefine', false);
        }

        if(message == 'CloseEditRequestedSQ') {
            component.set('v.isEditClick2', false);
        }
    }
    
})