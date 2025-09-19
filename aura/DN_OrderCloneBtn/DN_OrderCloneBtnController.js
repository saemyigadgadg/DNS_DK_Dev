({
    doInit : function(component, event, helper) {
        helper.reverseSpinner(component);

        component.set('v.columns', [
            { label: $A.get("$Label.c.DNS_C_Product"), fieldName: 'quoteItemLink', type: 'url'
                , sortable: true, typeAttributes: { label: { fieldName: 'productName' }, target: '_blank' }}
            , {label: $A.get("$Label.c.DNS_C_RDD"), fieldName: 'rdd', type: 'date-local', sortable: true}
            , {label: $A.get("$Label.c.DNS_C_ERPQUOTENO"), fieldName: 'qERPNo', sortable: true}
        ]);

        var action = component.get("c.fetchInit");
        action.setParams({ recordId : component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('doInit result - ', JSON.stringify(returnVal, null, 1));
                if(!returnVal.isPass) {
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.errorMsg);
                    helper.closeModal();
                    return;
                }

                component.set('v.data', returnVal.prods);
                helper.reverseSpinner(component);
            } else {
                helper.handleError('doInit', response.getError());
                helper.closeModal();
            }
        });
        $A.enqueueAction(action);
    }

    , closeClick: function(component, event, helper) {
        helper.closeModal();
    }

    , handleSubmit: function(component, event, helper) {
        event.preventDefault();
        helper.reverseSpinner(component);

        const fields = event.getParam('fields');
        const selectedRows = component.get('v.selectedRows');
        console.log('handleSubmit - fields ::: ', fields.ReqDeliveryDate__c);
        console.log('handleSubmit - selectedRows ::: ', JSON.stringify(selectedRows, null, 1));
        
        if(selectedRows.length == 0) {
            helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_NoSelectItem"));
            helper.reverseSpinner(component);
            return;
        } else if(selectedRows.length > 1){
            helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_SelectOne")); // Please select only one item.
            helper.reverseSpinner(component);
            return;
        }

        var action = component.get("c.cloneCurrOrder");
        action.setParams({ 
            recordId : component.get('v.recordId')
            , reqDeliveryDate : fields.ReqDeliveryDate__c
            , prodList : selectedRows
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('cloneCurrOrder result - ', JSON.stringify(returnVal, null, 1));
                if(!returnVal.isPass) {
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.errorMsg);
                    helper.closeModal();
                    return;
                }

                helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_OrderCreation"));
                helper.closeModal();

                var navService = component.find("navService");
                var pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: returnVal.data.newOrderId,
                        objectApiName: "Order",
                        actionName: "view"
                    }
                };
                navService.navigate(pageReference);
            } else {
                helper.handleError('handleSubmit', response.getError());
                helper.reverseSpinner(component);
            }
        });
        $A.enqueueAction(action);
    }

    , handleError: function(component, event, helper) {
        helper.handleError('handleError', event.getParam("message"));
        console.log("Error error : " + JSON.stringify(event.getParam("error"), null, 1));
    }

    , handleSelectRow: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRows', selectedRows);
    }

    , handleSort: function (component, event, helper) {
        let sortedBy      = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
        
        component.set('v.sortedBy', sortedBy);
        component.set('v.sortDirection', sortDirection);

        let fieldName = sortedBy;
        if (fieldName === 'quoteItemLink') { fieldName = 'productName'; }
        
        var reverse = sortDirection !== 'asc';
        let data = component.get("v.data");
        data.sort(helper.sortData(fieldName, reverse));
        component.set("v.data", data);
    }
})