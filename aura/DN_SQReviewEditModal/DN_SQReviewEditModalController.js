({
    editInit : function(component, event, helper) {
        helper.init(component, event);
    },

    handleClickAddButton: function(component, event, helper) {
        var rowDataList = component.get("v.rowDataList") || [];

        var newRow = {
            "Id1": null,
            "Id2": null,
            "title": "",
            "type": "SQ",
            "isNew": true
        };

        rowDataList.push(newRow);

        component.set("v.rowDataList", rowDataList);
    },

    handleClickdeleteButton : function(component, event) {
        let rowIndex = event.getSource().get("v.accesskey");
        let rowDataList = component.get("v.rowDataList");
        let rowData = rowDataList[rowIndex];
        let idsToDelete = component.get('v.deletedRows') || [];
        
        if (rowData.Id1) idsToDelete.push(rowData.Id1);
        if (rowData.Id2) idsToDelete.push(rowData.Id2);
        console.log('idsToDelete : ' + idsToDelete);
        
        component.set('v.deletedRows', idsToDelete);
        rowDataList.splice(rowIndex, 1);
        
        component.set("v.rowDataList", rowDataList);
    },

    handleClickApply : function(component, event, helper) {

        // 20250613 yeongju.yun sq일 때 40자 제한
        let rowDataList = component.get("v.rowDataList");
        console.log('rowDataList', rowDataList);

        let invalidList = rowDataList.filter(row => row.type === 'SQ' && row.title && row.title.length > 40);
        if (invalidList.length > 0) {
            helper.toast('error', $A.get("$Label.c.DNS_M_SQMaximum40")); // Maximum 40 characters allowed for SQ type.
            return;
        }
        
        let idsToDelete = component.get("v.deletedRows");

        if (idsToDelete && idsToDelete.length > 0) {
            helper.handleDelete(component, event, idsToDelete);
        }

        let recordsToSave = rowDataList
            .filter(row => row.isNew)
            .map(row => {
                if (row.type === "SQ") {
                    return [{ title: row.title, type: row.type }, { title: row.title, type: row.type }];
                } else if (row.type === "설계") {
                    return [{ title: row.title, type: row.type }];
                }
                return [];
            })
            .flat();
        
        if(recordsToSave != '') {
            helper.handleSave(component, event, recordsToSave, rowDataList);
        }
    },

    handleClickClose : function(component, event, helper) {
        helper.handleClose(component, event);
    },

    handleTypeChange : function(component, event, helper) {
        var index = event.getSource().get("v.accesskey");
        var itemList = component.get("v.rowDataList");
        var selectedType = event.getSource().get("v.value");

        itemList[index].type = selectedType;
        component.set("v.rowDataList", itemList);

        if (selectedType === 'SQ') {
            window.setTimeout(function() {
                var inputList = component.find("sqTitle");
                var inputCmp = Array.isArray(inputList) ? inputList[index] : inputList;
                
                if (inputCmp && inputCmp.get("v.value") && inputCmp.get("v.value").length > 40) { inputCmp.reportValidity(); }
            }, 0);
        }
    },
})