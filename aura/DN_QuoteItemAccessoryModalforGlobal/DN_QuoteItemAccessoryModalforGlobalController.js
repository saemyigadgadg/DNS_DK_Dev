/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-07
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-15   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doinit: function (component, event, helper) {
        component.set("v.isLoading", true);
		helper.setColumns(component);

        const selectedItems   = component.get('v.selectedItems');
        const baseProduct     = selectedItems[0].ProductName;
        let quoteLineItemIds  = [];
        selectedItems.forEach(item => quoteLineItemIds.push(item.Id));

        var action = component.get("c.fetchModalInfo");
        action.setParams({ baseProduct : baseProduct, quoteLineItemIds : quoteLineItemIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('returnVal ', returnVal);
                
                if(returnVal.ERROR == 'ERROR'){
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_DiffAccessory")); // The selected accessories are different.
                    helper.close(component);
                }

                if(returnVal.isPass) {
                    component.set('v.categoryOption', returnVal.categoryOption);
                    component.set('v.selTableData',   returnVal.selTableData);
                    component.set('v.checkDNSA',      returnVal.checkDNSA);
                    component.set('v.defaultData',    returnVal.selTableData); //최초 데이터 갖고있는곳

                    //DNSA가 아닐경우에만 category선택 없이 바로 전체 list보여줌
                    if(!returnVal.checkDNSA){ component.set('v.tableData', returnVal.categoryOptionData); }
                    if(returnVal.checkGlobal){ component.set('v.tableData', []); }

                    component.set("v.isLoading", false);
                } else {
                    helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.msg);
                    helper.close(component);
                }

            } else {
                helper.handleError('selectedItems', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handleKeyPress: function(component, event, helper){
        if(event.keyCode == 13){
            $A.enqueueAction(component.get('c.handleSearch'));
        }
    },

    handleSearch: function (component, event, helper) {
        var selTableData = component.get('v.selTableData');
        var searchTerm   = component.get("v.searchTerm");
        
        if (!searchTerm || searchTerm.trim() === "") { // 검색어 유효성 확인
            helper.toast("error", "Validation Error", "Please enter a search term.");
            return;
        }

        component.set("v.isLoading", true);

        var action = component.get("c.fetchSearchInfo");
        action.setParams({ searchTerm: searchTerm });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                if (returnVal.OptionDatas.length == 0) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_AccessoryNoList"), // There are no selectable accessories available.
                        "type": "error"
                    });
                    toastEvent.fire();
                    component.set("v.isLoading", false);

                    return;
                }

                
                const categoryOptionData = returnVal.OptionDatas;
                component.set('v.categoryOptionData', categoryOptionData);

                const tableData = categoryOptionData.filter(item => !selTableData.some(selItem => selItem.key === item.key));
                component.set('v.tableData', tableData);
                component.set("v.isLoading", false);

            } else {

                helper.handleError('selectedItems', response.getError());
            }
        });
        $A.enqueueAction(action);
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
        // console.log('actionName : ' + actionName);
        // console.log('rowkey : ' + row.key);
        if(actionName == 'add') {
            try {
                // console.log('1');
                const addItem = tableData.find(item => item.key === row.key);
                if(addItem) {
                // console.log('2');

                var action = component.get("c.accessoryAvaliable");
                // console.log('3');
                // console.log(row.key);

                action.setParams({row : row.key});
                // console.log('4');

                action.setCallback(this, function(response) {
                // console.log('response : ' + JSON.stringify(response));
                var returnVal = response.getReturnValue();
                // console.log('return val : ' + returnVal);
                    if(returnVal === 'SUCCESS'){
                        tableData = tableData.filter(item => item.key !== row.key);
                        component.set("v.tableData", tableData);
        
                        categoryOptionData = categoryOptionData.filter(item => item.key !== row.key);
                        component.set("v.categoryOptionData", categoryOptionData);
        
                        addItem.del = '';
                        selTableData.push(addItem);
                        component.set("v.selTableData", selTableData);
        
                        delTableData = delTableData.filter(item => item.key !== row.key);
                        component.set("v.delTableData", delTableData);
                    }else{
                        helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal);
                    }
                });
            $A.enqueueAction(action);

            }
            } catch (error) {
                // console.log('error 235 : ' + error);
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

                // categoryOptionData.push(removeItme);
                // component.set('v.categoryOptionData', categoryOptionData);

                helper.changeTableData(component, category);
            }
        }
        // console.log('selTableData : ' + JSON.stringify(component.get('v.selTableData')));
        // console.log('delTableData : ' + JSON.stringify(component.get('v.delTableData')));

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