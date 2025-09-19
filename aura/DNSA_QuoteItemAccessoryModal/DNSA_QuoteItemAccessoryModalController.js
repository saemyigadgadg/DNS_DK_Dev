({
    doInit : function(component, event, helper) {
        console.log('옴?');
        helper.reverseSpinner(component);
        helper.setColumns(component);

        const selectedItems   = component.get('v.selectedItems');
        const baseProduct     = selectedItems[0].ProductName;

        let quoteLineItemIds = [];
        selectedItems.forEach(item => quoteLineItemIds.push(item.Id));
        try {
            var action = component.get("c.fetchModalInfo");
        action.setParams({ baseProduct : baseProduct, quoteLineItemIds : quoteLineItemIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ' + state);
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('returnVal ', returnVal);

                if(returnVal.ERROR == 'ERROR'){
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_DiffAccessory"));
                    helper.close(component);
                }

                if(returnVal.isPass) {
                    component.set('v.categoryOption',       returnVal.categoryOption);
                    component.set('v.selTableData',         returnVal.selTableData);
                    component.set('v.defaultData',          returnVal.selTableData);
                    component.set('v.categoryOptionData',   returnVal.categoryOptionData);

                    component.set('v.shipTo',   returnVal.accId);
                    component.set('v.shipDate',   returnVal.shipDate);
                    component.set('v.isFactory', returnVal.isFactory);
                    helper.reverseSpinner(component);
                } else {
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.msg);
                    helper.close(component);
                }
            } else {
                helper.handleError('selectedItems', response.getError());
            }
        });
        $A.enqueueAction(action);
        } catch (error) {
            console.log('error!! : ' + error);
        }
        
    },

    handleCategoryChange : function(component, event, helper) {
        helper.reverseSpinner(component);
        var selectedOptionValue = event.getParam("value");
        console.log('selectedOptionValue : ', selectedOptionValue);
        component.set('v.category', selectedOptionValue);

        helper.changeTableData(component, selectedOptionValue);
    },

    handleRowAction: function(component, event, helper) {
        try {
            const actionName = event.getParam('action').name;
            const row = event.getParam('row');
            
            console.log('Action Name:', actionName);
            console.log('Row Data:', JSON.stringify(row, null, 2));
            
            let selTableData = component.get('v.selTableData') || [];
            let delTableData = component.get('v.delTableData') || [];
            let tableData = component.get('v.tableData') || [];
            
            if (actionName === 'add') {
                const addItem = tableData.find(item => item.key === row.key);
                if (addItem) {
                    addItem.accId = component.get('v.shipTo');
                    addItem.shipDate  = component.get('v.shipDate');
                    console.log('addItem', addItem);
                    tableData = tableData.filter(item => item.key !== row.key);
                    component.set("v.tableData", tableData);
    
                    addItem.del = '';
                    selTableData.push(addItem);
                    component.set("v.selTableData", selTableData);
    
                    delTableData = delTableData.filter(item => item.key !== row.key);
                    component.set("v.delTableData", delTableData);
                }
            }
        } catch (error) {
            console.error('Error in handleRowAction:', error);
        }
    },

    handleRemoveClick: function(component, event, helper) {
        try {
            const rowKey = event.getSource().get("v.name");
            const category = component.get("v.category");
            
            let selTableData = component.get('v.selTableData') || [];
            let delTableData = component.get('v.delTableData') || [];
            let tableData = component.get('v.tableData') || [];
            
            const removeItem = selTableData.find(item => item.key === rowKey);
            if (removeItem) {
                if (removeItem.category === category) {
                    removeItem.del = 'D';
                    delTableData.push(removeItem);
                    component.set("v.delTableData", delTableData);
        
                    selTableData = selTableData.filter(item => item.key !== rowKey);
                    component.set("v.selTableData", selTableData);
        
                    tableData.push(removeItem);
                    component.set("v.tableData", tableData);
                } else {
                    // console.warn('Item does not belong to the current category.');
                    // helper.toast('Error', 'Error', 'Item does not belong to the current category.');
                    removeItem.del = 'D';
                    delTableData.push(removeItem);
                    component.set("v.delTableData", delTableData);
        
                    selTableData = selTableData.filter(item => item.key !== rowKey);
                    component.set("v.selTableData", selTableData);
                }
            }
        } catch (error) {
            console.error('Error in handleRemoveClick:', error);
        }
    },
    

    handleClose : function(component, event, helper) {
        helper.close(component);
    },

    handleSave : function(component, event, helper) {
        try {
            helper.reverseSpinner(component);
    
            const selectedItems = component.get('v.selectedItems');
            const selTableData  = component.get('v.selTableData');
            const delTableData  = component.get('v.delTableData');
            let valid = false;
            console.log('selTableData', selTableData);
    
            for (let item of selTableData) {
                console.log('item', item);
            
                if (item.accId == null || item.accId == undefined || item.accId == '') {
                    helper.toast('Error', 'Error', 'Make sure to enter Ship To.');
                    helper.reverseSpinner(component);
                    valid = true;
                    return;
                } else if (item.shipDate == null || item.shipDate == undefined || item.shipDate == '') {
                    helper.toast('Error', 'Error', 'Make sure to enter Machine Request Ship Date.');
                    helper.reverseSpinner(component);
                    valid = true;
                    return;
                }
            }
    
            if(valid) {
                return;
            }
            
            console.log('selTableData.concat(delTableData)', selTableData.concat(delTableData));
            console.log('selTableData.concat(delTableData)', JSON.stringify(selTableData.concat(delTableData), null, 2));
            
            let qLineItemIds = [];
            selectedItems.forEach(item => {
                qLineItemIds.push(item.Id);
            });
    
            var action = component.get("c.saveAccessories");
            action.setParams({ qLineItemIds : qLineItemIds, selTableData : selTableData.concat(delTableData) });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_MSG_AccessoryCreated"));
                    helper.close(component);
                } else {
                    helper.handleError('selectedItems', response.getError());
                    helper.reverseSpinner(component);
                }
            });
            $A.enqueueAction(action);
            
        } catch (error) {
            helper.reverseSpinner(component);
        }
    },

    handleShipDateChange: function(component, event, helper) {
        const field = event.getSource();
        const shipDate = field.get("v.value");
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (new Date(shipDate) < today) {
            helper.toast("Error", "Error", "Machine Request Machine Request Ship Date cannot be in the past.");
            field.set("v.value", "");
        }
    }
})