({
    searchInit : function(component, event, helper) {
        try {
            console.log('seearchHistory', component.get('v.searchHistory'));

            console.log('productModel', component.get('v.productModel'));
            console.log('productModelasd', component.get('v.productCode'));

            // Apex Call
            helper.apexCall(component, event, helper, 'initSearchCheckGlobal', {
                recordId : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r1', r);

                component.set('v.isGlobal', r);

                if(component.get('v.productModel') != '') {
                    component.set('v.isLoading', true);
                    // Apex Call
                    helper.apexCall(component, event, helper, 'initSearchModal', {
                        modelName : component.get('v.productModel'),
                        recordId : component.get('v.recordId'),
                        productCode : component.get('v.productCode')
                    })
                    .then($A.getCallback(function(result) {
                        let r = result.r;
                        console.log('r', r);
        
                        var dataRow = r.getInitDatas;
        
                        dataRow.forEach(row => {
                            if (row.descriptionHtml) {
                                row.descriptionHtml = row.descriptionHtml.replace(/<\/p>/g, '\n');
                                row.descriptionHtml = row.descriptionHtml.replace(/<.*?>/g, '');
                            }
                        });
                        const formattedData = helper.processSearchData(dataRow);

                        let searchHistory = component.get('v.searchHistory') || [];
                        searchHistory.push({ keyword: '', model: component.get('v.productModel') });

                        component.set('v.searchHistory', searchHistory);
                        
                        component.set('v.searchDataList', formattedData);
                        component.set('v.dataRow', dataRow);
                        component.set('v.isLoading', false);
                    }))
                    .catch(function(error) {
                        console.log('# initSearchModal error : ' + error.message);
                    });
                }
            }))
            .catch(function(error) {
                console.log('# initSearchCheckGlobal error : ' + error.message);
            });
    
            window.setTimeout(
                $A.getCallback(function() {
                    var inputCmp = component.find("inputKeyword");
                    if (inputCmp) {
                        inputCmp.focus();
                    }
                }), 400
            );
            
        } catch (error) {
            console.log('searchInit Error : ' + error);
        }
    },

    handleClickSearch : function(component, event, helper) {
        try {
            // Apex Call
            helper.searchSQ(component, event, helper);
        } catch (error) {
            console.log('handleClickSearch Error : ' + error);
        }
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            helper.searchSQ(component, event, helper);
        }
    },

    handleRowSelection : function(component, event, helper) {
        const selectedRows = component.get("v.selectedRows");
        const rowIndex = event.getSource().get("v.value");
        const rowData = component.get("v.dataRow")[rowIndex];
    
        if (!rowData) {
            console.error('Row data is undefined for index:', rowIndex);
            return;
        }
    
        if (event.getSource().get("v.checked")) {
            selectedRows.push(rowData);
        } else {
            const indexToRemove = selectedRows.findIndex(row => row.sqTitle === rowData.sqTitle);
            if (indexToRemove > -1) {
                selectedRows.splice(indexToRemove, 1);
            }
        }
        
        component.set("v.selectedRows", selectedRows);
        console.log('component.set(v.selectedRows', component.get("v.selectedRows"));

        if (selectedRows.length > 0) {
            component.set("v.isApplyDisabled", false);
        } else {
            component.set("v.isApplyDisabled", true);
        }
        
    },

    handleClickApply: function(component, event, helper) {
        var messageObject = {
            selectedRows: component.get("v.selectedRows") || [], // 선택된 행 데이터
            searchHistory: component.get('v.searchHistory') || []
        };

        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"  : 'DN_SQSearchModal',
            "actionName" : 'Apply',
            "message"    : messageObject // 객체 형태로 전달
        });
        modalEvent.fire();
    },

    handleClose : function(component, event, helper) {
        console.log('component.get(v.searchHistory)', component.get('v.searchHistory'));
        
        var messageObject = {
            searchHistory: component.get('v.searchHistory') || []
        };

        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_SQSearchModal',
            "actionName"    : 'Close',
            "message"       : messageObject
        });
        modalEvent.fire();
    }
})