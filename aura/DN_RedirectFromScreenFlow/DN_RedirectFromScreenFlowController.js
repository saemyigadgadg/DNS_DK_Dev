({
    invoke : function(component, event, helper) {
        let redirectType = component.get('v.redirectType');
        
        let pageReference = null;

        switch (redirectType) {
            case 'DealerQuote_ListView':
                pageReference = {
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'custom_quotation_management__c',
                    }
                };
                break;
            case 'CreateDealerOrderFromQuote':
                pageReference = {
                    type: 'comm__namedPage',
                    attributes: {
                        name:'CustomerOrderCreate__c'
                    },
                    state: {
                        c__quote: component.get('v.sourceRecordId')
                    }
                };
                break;
            case 'DealerOrder_ListView':
                pageReference = {
                    type: 'comm__namedPage',
                    attributes: {
                        name:'CustomerOrderManagement__c'
                    }
                };
                break;
            case 'EditOrder':
                pageReference = {
                    type: 'comm__namedPage',
                    attributes: {
                        name:'CustomerOrderCreate__c'
                    },
                    state: {
                        c__editorder: component.get('v.sourceRecordId')
                    }
                };
                break;
            default:
                break;
        }

        helper.navigationTo(component, pageReference, true);
    }   
})