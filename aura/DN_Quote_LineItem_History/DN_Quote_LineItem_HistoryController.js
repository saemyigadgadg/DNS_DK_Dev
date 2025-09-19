({
    doInit: function(component, event, helper) {
        var action = component.get("c.getQuoteLineItemsHistory");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            var returnVal = response.getReturnValue();
                component.set("v.quoteLineItemHistory", returnVal);
                component.set("v.total", "Quote Line Items History (" + returnVal.length + ")");
            }
        });
        $A.enqueueAction(action);

        component.set('v.columns', [
            // { label: '', fieldName: 'Id', type: 'text', hideDefaultActions: true},
            { label: 'Product', fieldName: 'ProductName', type: 'text' },
            { label: 'Date', fieldName: 'CreatedDate', type: 'date' },
            { label: 'Field', fieldName: 'Field', type: 'text' },
            { label: 'User', fieldName: 'CreatedByName', type: 'text' },
            { label: 'Original Value', fieldName: 'OldValue', type: 'text' },
            { label: 'New Value', fieldName: 'NewValue', type: 'text' }
        ]);
    }
})