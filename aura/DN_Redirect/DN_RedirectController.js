({
    doRedirect : function(component, event, helper) {
        console.log('doRedirect!!');
        let redirectType;
        let navigationType;
        let recordId;
        let params = event.getParam('arguments');
        if (params) {
            redirectType = params.redirectType;
            navigationType = params.navigationType;
            recordId = params.recordId;
            // add your code here
        }
        
        let pageReference = null;

        switch (redirectType) {
            //수정화면에서 다시 페이지이동시키게끔 변경.
            case 'AddMoreOrder':
                pageReference = {
                    type: 'comm__namedPage',
                    attributes: {
                        name:'CustomerOrderCreate__c'
                    },
                    state: {
                        'c__clone':recordId
                    }
                };
                break;
            case 'OrderDetail': 
                pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": recordId,
                        "objectApiName": "DealerOrder__c",
                        "actionName": "view"
                    }
                }
                break;
            default:
                break;
        }

        switch (navigationType) {
            case 'moveToURL':
                helper.navigationToURL(component, pageReference, true);
                break;
            case 'directMove':
                helper.navigationTo(component, pageReference, true);
                break;
            default:
                break;
        }
        
    }
})