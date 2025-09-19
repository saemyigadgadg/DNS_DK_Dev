({
    searchInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'initSearchButton', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('initSearchButton r', r);

            if(!r.checkQuoteLineItems) {
                helper.toast('Error', 'It doesn\'t work if the Quote Line Item is empty.');
                component.find('overlayLib').notifyClose();
                component.set('v.isLoading', false);
                return
            }

            if(!r.checkInit) {
                // helper.toast('Error', $A.get("$Label.c.DNS_SQR_T_ERRORAUTHDROP"));
                helper.toast('Error', $A.get("$Label.c.DNS_SQR_T_ERRORSQSEARCH"));
                component.find('overlayLib').notifyClose();
                component.set('v.isLoading', false);
                return
            }
            
            component.set('v.productModel', r.getModel);
            component.set('v.productCode', r.getCode);
            component.set('v.userDistrict', r.getUserDistrict);
            component.set('v.userLicense', r.getUserLicense);
            component.set('v.checkGlobal', r.checkGlobal);
            if(r.checkGlobal == 'Global SQ') {
                component.set('v.isGlobal', true);
            }

            if(r.checkGlobal != 'DNSA') {
                // Apex Call
                helper.apexCall(component, event, helper, 'initSearchModal', {
                    modelName : r.getModel,
                    recordId : component.get('v.recordId'),
                    productCode :r.getCode
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
                    
                    component.set('v.searchDataList', formattedData);
                    component.set('v.dataRow', dataRow);
                    component.set('v.isLoading', false);
                }))
                .catch(function(error) {
                    console.log('# initSearchModal error : ' + error.message);
                });
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getModelSearch error : ' + error.message);
        });

        window.setTimeout(
            $A.getCallback(function() {
                var inputCmp = component.find("inputKeyword");
                if (inputCmp) {
                    inputCmp.focus();
                }
            }), 400
        );
    },

    handleClickSearch : function(component, event, helper) {
        try {
            // Apex Call
            if(component.get('v.checkGlobal ') != 'DNSA') {
                helper.searchSQ(component, event, helper);
            } else {
                helper.DNSAsearchSQ(component, event, helper);
            }
        } catch (error) {
            console.log('handleClickSearch Error : ' + error);
        }
    },

    handleRowSelection : function(component, event, helper) {
        try {
            const selectedRows = component.get('v.selectedRows');
            const rowIndex = event.getSource().get('v.value');
            const rowData = component.get('v.dataRow')[rowIndex];
            console.log("🚀 ~ rowData:", rowData)
        
            if (!rowData) {
                console.error('Row data is undefined for index:', rowIndex);
                return;
            }
        
            if (event.getSource().get('v.checked')) {
                selectedRows.push(rowData);
                
                const allCheckboxes = component.find("checkbox");
                allCheckboxes.forEach(checkbox => {
                    if (checkbox.get("v.value") !== rowIndex) {
                        checkbox.set("v.disabled", true);
                    }
                });
                
            } else {
                const indexToRemove = selectedRows.findIndex(row => row.id === rowData.id);
                if (indexToRemove > -1) {
                    selectedRows.splice(indexToRemove, 1);
                }
                const allCheckboxes = component.find("checkbox");
                allCheckboxes.forEach(checkbox => {
                    checkbox.set("v.disabled", false);
                });
            }
            component.set('v.selectedRows', selectedRows);
            console.log('test', component.get('v.selectedRows'));
        } catch (error) {
            console.log('# handleRowSelection error : ', error);
        }
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            if(component.get('v.checkGlobal ') != 'DNSA') {
                helper.searchSQ(component, event, helper);
            } else {
                helper.DNSAsearchSQ(component, event, helper);
            }
        }
    },

    handleTitleSelection : function(component, event, helper) {
        try {
            const selectedRows = component.get('v.selectedTitle');
            const rowIndex = event.getSource().get('v.value');
            const rowData = component.get('v.requestedTitle')[rowIndex];
        
            if (!rowData) {
                console.error('Row data is undefined for index:', rowIndex);
                return;
            }
        
            if (event.getSource().get('v.checked')) {
                selectedRows.push(rowData);
    
                const allCheckboxes = component.find("checkboxTitle");
                allCheckboxes.forEach(checkbox => {
                    if (checkbox.get("v.value") !== rowIndex) {
                        checkbox.set("v.disabled", true);
                    }
                });
    
            } else {
                const indexToRemove = selectedRows.findIndex(row => row.Name === rowData.Name);
                if (indexToRemove > -1) {
                    selectedRows.splice(indexToRemove, 1);
                }
                const allCheckboxes = component.find("checkboxTitle");
                allCheckboxes.forEach(checkbox => {
                    checkbox.set("v.disabled", false);
                });
            }
            
            component.set('v.selectedTitle', selectedRows);
            
        } catch (error) {
            console.log('handleTitleSelection error ::: ', error);
            
        }
    },

    handleClickNext : function(component, event, helper) {
        if( component.get('v.selectedRows').length > 0 ){
            // Apex Call
            helper.apexCall(component, event, helper, 'getRelatedListInit', {
                recordId : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
                component.set('v.requestedTitle', r.getInitDatas);
                component.set('v.modal', true);
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# updateRequestedSQ error : ' + error.message);
            });
        } else {
            helper.toast('Error', '선택해 주세요.');
        }
    },

    handleClickClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
        $A.get('e.force:refreshView').fire();
    },

    handleModalClose : function(component, event, helper) {
        // component.find('overlayLib').notifyClose();
        component.set('v.modal', false);
    },

    handleClickModalApply : function(component, event, helper) {
        var modalEvent = component.getEvent('modalEvent');
        console.log('modalEvent', modalEvent);
        console.log('component.get(v.selectedRows) :::', component.get('v.selectedRows'));
        

        // Apex Call
        helper.apexCall(component, event, helper, 'updateRequestedSQ', {
            selectedTitle : component.get('v.selectedTitle'),
            selectedRows : component.get('v.selectedRows'),
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            
            if(r.flag == 'success') {
                helper.toast('Success', 'The update was successful.');
                component.set('v.modal', false);
                modalEvent.setParams({
                    "modalName"     : 'DN_SQSearchModalButton',
                    "actionName"    : 'Update',
                    "message"       : 'updateRequestedSQ'
                });
                modalEvent.fire();
                component.find('overlayLib').notifyClose();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.toast('Error', 'The update failed.');
            }
        }))
        .catch(function(error) {
            console.log('# updateRequestedSQ error : ' + error.message);
        });
    }
})