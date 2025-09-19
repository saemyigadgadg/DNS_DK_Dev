({
    doinit : function(component, event, helper) {
        helper.reverseSpinner(component);

        var action = component.get("c.fetchAccessory");
        action.setParams({ recordId : component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('fetchAccessory - returnVal ::: ' + JSON.stringify(returnVal, null, 2));
                
                if(returnVal.isPass){
                    const initData = returnVal.data;
                    component.set('v.targetShipToIds', initData.targetShipToIds);
                    component.set('v.dnsaRecordType',  initData.dnsaRecordType);
                    
                    helper.setColumns(component);

                    component.set('v.categoryOption',  initData.category);
                    component.set('v.selTableData',    initData.selTableData);

                    helper.reverseSpinner(component);
                } else {
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.errorMsg);
                    helper.closeModal();
                }

            } else {
                helper.handleError('fetchAccessory', response.getError());
                helper.closeModal();
            }
        });
        $A.enqueueAction(action);
        
    }

    , handleCategoryChange : function(component, event, helper) {
        helper.reverseSpinner(component);

        var selectedValue = event.getParam("value");
        console.log('handleCategoryChange : ', selectedValue);

        var action = component.get("c.getAccessoryData");
        action.setParams({ recordId : component.get('v.recordId'), category : selectedValue });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('getAccessoryData - returnVal ::: ' + JSON.stringify(returnVal, null, 2));

                if(returnVal.isPass){
                    const data = returnVal.data;

                    let keyArray = [];
                    const selTableData = component.get('v.selTableData');
                    selTableData.forEach(element => { keyArray.push(element.key); });
                    // console.log('handleCategoryChange - keyArray ::: ', JSON.stringify(keyArray, null, 1));
                    // console.log('handleCategoryChange - data.accRows ::: ', JSON.stringify(data.accRows, null, 1));

                    let tableData = [];
                    let tableDataRemove = [];
                    data.accRows.forEach(row => {
                        if(keyArray.includes(row.key)) {
                            tableDataRemove.push(row);
                        } else {
                            tableData.push(row);
                        }
                    });
                    console.log('handleCategoryChange - tableDataRemove ::: ', JSON.stringify(tableDataRemove, null, 1));
                    console.log('handleCategoryChange - tableData ::: ', JSON.stringify(tableData, null, 1));

                    // let accRows = data.accRows.filter(row => !keyArray.includes(row.key));
                    // console.log('handleCategoryChange - accRows ::: ', JSON.stringify(accRows, null, 1));
                    component.set('v.tableData', tableData);
                    component.set('v.tableDataRemove', tableDataRemove);
                } else {
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.errorMsg);
                    helper.closeModal();
                }
            } else {
                helper.handleError('fetchAccessory', response.getError());
            }
            helper.reverseSpinner(component);
        });
        $A.enqueueAction(action);
    }

    , handleClose : function(component, event, helper) {
        helper.closeModal();
    }

    , handleAddAction : function(component, event, helper) {
        helper.reverseSpinner(component);

        const actionName = event.getParam('action').name;
        const row = event.getParam('row');

        console.log('handleAddAction ::: ', actionName, '/', JSON.stringify(row, null, 2));

        let tableData       = component.get('v.tableData');
        let selTableData    = component.get('v.selTableData');
        let tableDataRemove = component.get('v.tableDataRemove');

        tableData = tableData.filter(item => item.key !== row.key); // remove from table data
        selTableData.push(row); // add to selected table data
        tableDataRemove.push(row);

        component.set('v.tableData', tableData.slice());
        component.set('v.selTableData', selTableData.slice());
        
        helper.reverseSpinner(component);

        /*
        {
            "accCode": "BB218C547A",
            "accName": "CHUCK,POWER;3,JAW:A1-15/M175X3",
            "category": "CHUCK LEFT",
            "key": "CHUCK LEFT/BB218C547A",
            "price": 13300,
            "quantity": 1,
            "salesUnit": "EA",
            "shipTo": "Lobo Tech",
            "shipToURL": "https://dn-solutions--dev.sandbox.my.salesforce.com/001F700001mWalEIAS"
        }
        */
    }

    , handleRowAction : function(component, event, helper) {

        helper.reverseSpinner(component);
        const action = event.getParam('action');
        console.log('DNSA_OrderAddAccessoryBtn - handleRowAction', JSON.stringify(action, null, 1));
        
        let tableData       = component.get('v.tableData');
        let selTableData    = component.get('v.selTableData');
        let tableDataRemove = component.get('v.tableDataRemove');

        selTableData = selTableData.filter(item => item.key !== action.key); // remove from selected table data
        component.set('v.selTableData', selTableData.slice());

        const removedRow = tableDataRemove.find(row => row.key == action.key);

        if(component.get('v.category') && removedRow && component.get('v.category') == removedRow.category) {
            tableData.push(removedRow); // reverting to table data if the category is same
        }
        component.set('v.tableData', tableData.slice());
        helper.reverseSpinner(component);
        /*
        {
            "detail": {
                "action": {
                    "key": "CHUCK JAWS/SB12N1",
                    "name": "remove"
                }
            }
        }
        */

    }

    , handleCellChange: function(component, event, helper){
        console.log('DNSA_OrderAddAccessoryBtn - handleCellChange');
        const draftValues = event.getParam('draftValues')[0];
        let changedRow = component.get('v.selTableData').find(sel => draftValues.key == sel.key);
        
        console.log(`DNSA_OrderAddAccessoryBtnController - handleCellChange - draftValues : ${JSON.stringify(draftValues, null, 1)}`);
        
        if ('quantity' in draftValues) {
            console.log(10);
            changedRow.quantity = draftValues.quantity ? draftValues.quantity : 0;
        } else if ('shipToId' in draftValues) {
            console.log(20);
            changedRow.shipToId = draftValues.shipToId;
        }
        // if(draftValues.quantity) {
        //     changedRow.quantity = draftValues.quantity;
        // } else if(draftValues.shipToId) {
        //     changedRow.shipToId = draftValues.shipToId;
        // }
        console.log(`DNSA_OrderAddAccessoryBtnController - handleCellChange - changedRow : ${JSON.stringify(changedRow, null, 1)}`);
        /*
        {
            "quantity": "2",
            "key": "PULL STUDS/31643-30PCS"
        }
        */
    }

    , handleSave : function(component, event, helper) {
        helper.reverseSpinner(component);

        const selTableData = component.get('v.selTableData');
        console.log('selTableData ::: ' , JSON.stringify(selTableData, null, 1));
        if(selTableData.length == 0) {
            helper.handleError('handleSave', 'Please select at least one accessory.');
            helper.reverseSpinner(component);
            return;
        }

        const noShipTo = selTableData.filter(ele => !ele.shipToId || ele.shipToId == '');
        if(noShipTo.length > 0) {
            helper.handleError('handleSave', 'Please enter all Ship To.');
            helper.reverseSpinner(component);
            return;
        }

        const noQty = selTableData.filter(ele => !ele.quantity || ele.quantity == '' || ele.quantity == 0);
        if(noQty.length > 0) {
            helper.handleError('handleSave', 'Please enter all quantity.');
            helper.reverseSpinner(component);
            return;
        }

        var action = component.get("c.saveAccessories");
        action.setParams({ recordId : component.get('v.recordId'), dataList : selTableData });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_MSG_AccessoryCreated"));
                helper.closeModal();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.handleError('selectedItems', response.getError());
                helper.reverseSpinner(component);
            }
        });
        $A.enqueueAction(action);

    }

})