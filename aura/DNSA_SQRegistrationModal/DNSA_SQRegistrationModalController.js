({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        // Apex Call
        helper.apexCall(component, event, helper, 'getInit', {
            recordId    : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            if(r.isSuccess == 'SUCCESS'){
                component.set('v.recordTypeId', r.getRecordTypeId);
                component.set('v.quoteId', r.initDatas.Id);
                component.set('v.opptyId', r.initDatas.OpportunityId);
                component.set('v.accId', r.initDatas.AccountId);
                component.set('v.currencyId', r.initDatas.CurrencyIsoCode);
                component.set('v.usaId', r.messageGroup);
                component.set('v.dnsaId', r.dnsaMessageGroup);
                component.set('v.isLoading', false);
            }else{
                helper.toast('ERROR', r.isSuccess);
                component.set('v.isLoading', false);
                helper.closeModal(component);
                $A.get('e.force:refreshView').fire();
            }
            
        }))
        .catch(function(error) {
            console.log('# getInit error : ' + error.message);
        });
    },

    handleClickSubmit : function(component, event, helper) {
        event.preventDefault();
        component.set('v.isLoading', true);
        const fields = event.getParam('fields');
        console.log(fields);
        const upRecord = {};
        upRecord.RecordTypeId   = fields.RecordTypeId;
        upRecord.Quote__c       = fields.Quote__c;
        upRecord.Opportunity__c = fields.Opportunity__c;
        upRecord.Account__c     = fields.Account__c;
        upRecord.CurrencyIsoCode= fields.CurrencyIsoCode;
        upRecord.Name           = fields.Name;
        upRecord.Environment__c = fields.Environment__c;
        upRecord.Message_Group__c = fields.Message_Group__c;
        upRecord.RequestFromDealer__c = fields.RequestFromDealer__c;
        try {
        var action = component.get("c.createSQ");
        

        action.setParams({
            recordId : component.get('v.recordId'),
            upRecord : upRecord
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal == 'SUCCESS'){
                component.set('v.isLoading', false);
                helper.toast('SUCCESS', $A.get("$Label.c.DNS_SQR_T_SUCCESSINSERT"));
                helper.closeModal(component);
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        } catch (error) {
            console.log(error);
        }
        

        // component.find("recordEditForm").submit();
    },

    handleSubmitSuccess : function(component, event, helper) {
        component.set('v.isLoading', false);
        helper.toast('SUCCESS', $A.get("$Label.c.DNS_SQR_T_SUCCESSINSERT"));
        helper.closeModal(component);
        $A.get('e.force:refreshView').fire();
    },

    handleSubmitError : function(component, event, helper) {
        var errors = event.getParam('error');
        console.log('errors', errors);
        
        var message = $A.get("$Label.c.DNS_ACC_T_ADMIN");
        
        if (errors && errors.body) {
            if (errors.body.message) {
                message = errors.body.message;
            } else if (errors.body.output && errors.body.output.errors.length > 0) {
                message = errors.body.output.errors[0].message;
            }
        }

        helper.toast('ERROR', message);
        component.set('v.isLoading', false);
    },

    handleClickClose : function(component, event, helper) {
        helper.closeModal(component);
    }
})