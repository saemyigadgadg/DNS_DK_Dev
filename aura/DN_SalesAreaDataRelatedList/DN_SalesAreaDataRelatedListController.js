({
    doInit : function(component, event, helper) {
        component.set("v.isLoaded", true);

        helper.apexCall(component, event, helper, 'getSalesAreaData', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r != null) {
                // Create Link Column
                var newList = r.map(function(el) {
                    var id = el.Id;
                    var name = el.Name;
                    var url = 'https://dn-solutions--dev.sandbox.my.site.com/partners/s/salesareadata/' + id + '/' + name;
                    console.log('🚩 url', url);
    
                    return Object.assign({}, el, { Link: url });
                });
    
                component.set('v.relatedList', newList);
                console.log('🚩 New List', newList); 
            }
        }))
        .catch(function(error) {
            console.log('# getSalesAreaData error : ' + error.message);
        });

        component.set('v.isLoaded', false);
    },

    handleClickNew : function(component, event, helper) {
        // var pageReference = {
        //     type: 'standard__objectPage',
        //     attributes: {
        //         objectApiName: 'SalesAreaData__c',
        //         actionName: 'new'
        //     }
        // };
    
        // var navService = component.find("navService");
        // navService.navigate(pageReference);

        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "SalesAreaData__c",
            "defaultFieldValues": {
                "Account__c": component.get('v.recordId')
            }
        });
        createRecordEvent.fire();
    },

    handleRowAction : function(component, event, helper) {
        var selectedRow = event.getParam('row');
        var recordId = selectedRow.Id;
        
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'SalesAreaData__c',
                actionName: 'edit'
            }
        };
    
        var navService = component.find("navService");
        navService.navigate(pageReference);
    },

    handleClickViewAll : function(component, event, helper) {
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: component.get("v.recordId"),
                objectApiName: 'Account',
                relationshipApiName: 'SalesAreaData__r',
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
    }
})