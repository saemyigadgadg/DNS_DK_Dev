({
    apexCall : function( component, event, helper, methodName, params ) {

        var actions = [
            { label: 'Edit', name: 'edit' }
        ]
        
        component.set('v.tableColumns', [
            { label: 'Name' ,fieldName: 'Link', type: 'url', typeAttributes: { 
                label: { fieldName: 'Name' },
                tooltip: { fieldName: 'Name' },
                target: '_blank'
            } },            
            { label: $A.get("$Label.c.DNS_SAD_C_SALESORGANIZATION"), fieldName: 'SalesOrganization', type: 'Picklist'},
            { label: $A.get("$Label.c.DNS_SAD_C_SALESDISTRICT"), fieldName: 'SalesDistrict', type: 'Picklist'},
            //{ label: $A.get("$Label.c.DNS_SAD_C_SALESOFFICE"), fieldName: 'SalesOffice', type:'Picklist'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ])       

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
    }
    
})