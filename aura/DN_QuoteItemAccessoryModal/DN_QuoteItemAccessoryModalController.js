({
    doinit : function(component, event, helper) {
        // console.log('doInit : ', JSON.stringify(component.get('v.selectedItems'), null, 2));
        helper.reverseSpinner(component);

        const selectedItems   = component.get('v.selectedItems');
        const baseProduct     = selectedItems[0].ProductName;

        let quoteLineItemIds = [];
        selectedItems.forEach(item => quoteLineItemIds.push(item.Id));

        var action = component.get("c.fetchModalInfo");
        action.setParams({ baseProduct : baseProduct, quoteLineItemIds : quoteLineItemIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            // console.log('returnVal!! : ' + returnVal);
            if(returnVal == null){
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.DNS_M_Error"),
                            "message": $A.get("$Label.c.DNS_M_AccessoryNoList"),
                            "type": "error"
                        });
                        toastEvent.fire();
                    helper.close(component);
                        
                    return;
            }

            if(state === "SUCCESS"){
                // console.log('returnVal ', returnVal);
                

                if(returnVal.ERROR == 'ERROR'){
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_DiffAccessory"));
                    helper.close(component);
                }

                if(returnVal.isPass) {
                    component.set('v.categoryOption',     returnVal.categoryOption);
                    component.set('v.categoryOptionData', returnVal.categoryOptionData);
                    component.set('v.selTableData',       returnVal.selTableData);
                    component.set('v.checkDNSA',          returnVal.checkDNSA);
                    component.set('v.checkDomestic',      returnVal.checkDomestic);
                    component.set('v.defaultData',        returnVal.selTableData); //최초 데이터 갖고있는곳

                    // console.log(JSON.stringify(returnVal.checkDNSA));
                    // console.log(JSON.stringify(returnVal.categoryOptionData));
                    //DNSA가 아닐경우에만 category선택 없이 바로 전체 list보여줌
                    if(!returnVal.checkDNSA){
                        component.set('v.tableData', returnVal.categoryOptionData);
                    }

                    helper.setColumns(component);
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

        const categoryOptionData = component.get('v.categoryOptionData');
        const categoryOption = component.get('v.categoryOption');
        // console.log(JSON.stringify(categoryOptionData));
        // console.log(JSON.stringify(categoryOption));
        const tableData          = categoryOptionData;
        
        component.set('v.tableData', tableData);
    }

    , handleCategoryChange : function(component, event, helper) {
        const quoteId = component.get('v.quoteId');
        // console.log('quoteId', quoteId);
        var selectedOptionValue = event.getParam("value");
        // console.log('handleCategoryChange : ', selectedOptionValue);

        helper.changeTableData(component, selectedOptionValue);
    }

    , handleRowAction : function(component, event, helper) {
        helper.reverseSpinner(component);

        const actionName = event.getParam('action').name; // add, remove
        const row        = event.getParam('row');
        const category   = component.get('v.category');

        // console.log('handleRowAction - row : ', JSON.stringify(row, null, 2));

        let selTableData       = component.get('v.selTableData');
        let delTableData       = component.get('v.delTableData');
        let tableData          = component.get('v.tableData');
        let categoryOptionData = component.get('v.categoryOptionData');
        let defaultData        = component.get('v.defaultData');
        if(actionName == 'add') {
            const addItem = tableData.find(item => item.key === row.key);
            if(addItem) {
                
                tableData = tableData.filter(item => item.key !== row.key);
                component.set("v.tableData", tableData);

                categoryOptionData = categoryOptionData.filter(item => item.key !== row.key);
                component.set("v.categoryOptionData", categoryOptionData);

                addItem.del = '';
                selTableData.push(addItem);
                component.set("v.selTableData", selTableData);

                delTableData = delTableData.filter(item => item.key !== row.key);
                component.set("v.delTableData", delTableData);

            }
        } else {
            const removeItme = selTableData.find(item => item.key === row.key);
            
            if(removeItme) {
                //기존에 생성 되어있던 값 Check
                // const deleteItme = selTableData.find(item => item.Id != null || item.Id != undefined);
                // const deleteItme = selTableData.find(item => item.key === row.key);
                const deleteItme = defaultData.find(item => item.key === row.key);
                if(deleteItme){
                    deleteItme.del = 'D';
                    delTableData.push(deleteItme);

                    component.set("v.delTableData", delTableData);
                }
                selTableData = selTableData.filter(item => item.key !== row.key);
                component.set("v.selTableData", selTableData);

                categoryOptionData.push(removeItme);
                component.set('v.categoryOptionData', categoryOptionData);

                helper.changeTableData(component, category);
            }
        }
        console.log('selTableData : ' + JSON.stringify(component.get('v.selTableData')));
        console.log('delTableData : ' + JSON.stringify(component.get('v.delTableData')));

        helper.reverseSpinner(component);
    }

    , handleClose : function(component, event, helper) {
        helper.close(component);
    }

    ,handleCellChange: function(component, event, helper){
        // 변경된 데이터 가져오기
        const draftValues = event.getParam("draftValues");
        // console.log("Draft Values:", draftValues);
        const selTableData  = component.get('v.selTableData');
        // console.log('selTableData : ' + JSON.stringify(selTableData));
        selTableData.forEach(item => {
            if (item.key === draftValues[0].key) {
                if(item.quantity != draftValues[0].quantity){
                    item.del = 'U';
                }
                item.quantity = draftValues[0].quantity;
            }
        });
        component.set('v.selTableData', selTableData);
        // console.log('selTableData : ' + JSON.stringify(component.get('v.selTableData')));


    }

    , handleSave : function(component, event, helper) {
        helper.reverseSpinner(component);

        component.set("v.isLoading", true);

        const selectedItems = component.get('v.selectedItems');
        const selTableData  = component.get('v.selTableData');
        const delTableData  = component.get('v.delTableData');
        // console.log('selectedItems : ' + JSON.stringify(selectedItems));
        // console.log('selTableData : ' + JSON.stringify(selTableData));
        
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
    }
})