({
    doinit : function(component, event, helper) {
        helper.init(component, event, helper);
    },

    handleClickSubmit : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            event.preventDefault();

            const fields = {};
            const recordFields = component.find("recordField");
            let nameFieldError = false;
            let reviewDateError = false;
            var rowDataList = component.get('v.rowDataList');
            
            var hasError = false;
            rowDataList.forEach((row, index) => {
                if (row.sqTitle && row.sqTitle.length > 40 && row.sqTitle != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
                    hasError = true;
                }
            });

            if (hasError) {
                component.set('v.isLoading', false);
                helper.toast('ERROR', $A.get("$Label.c.DNS_SQR_T_sqTitleNameVali"));
                return;
            }

            if (Array.isArray(recordFields)) {
                recordFields.forEach(field => {
                    const fieldName = field.get("v.fieldName");
                    let fieldValue = field.get("v.value");
    
                    if (fieldName === "Name") {
                        if (fieldValue.length > 40 && fieldValue != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
                            nameFieldError = true;
                        }
                    }

                    if(fieldName === 'Environment__c') {
                        if(fieldValue == $A.get("$Label.c.DNS_SQR_P_PLACE")) {
                            fieldValue = '';
                        }
                    }

                    if (fieldName === 'ReviewRequestDate__c') {
                        if (fieldValue) {
                            let reviewDate = new Date(fieldValue);
                            let today = new Date();  
                            
                            today.setHours(0, 0, 0, 0);
                            reviewDate.setHours(0, 0, 0, 0);
                
                            if (reviewDate < today) {
                                reviewDateError = true;
                            }
                        }
                    }
    
                    fields[fieldName] = fieldValue;
                });
            } else if (recordFields) {
                // fields[recordFields.get("v.fieldName")] = recordFields.get("v.value");
                const fieldName = recordFields.get("v.fieldName");
                let fieldValue = recordFields.get("v.value");
    
                // Name 필드 값 검증
                if (fieldName === "Name") {
                    if (fieldValue.length > 40 && fieldValue != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
                        nameFieldError = true;
                    }
                }

                if (fieldName === 'ReviewRequestDate__c') {
                    if (fieldValue) {
                        let reviewDate = new Date(fieldValue);
                        let today = new Date();  
                        
                        today.setHours(0, 0, 0, 0);
                        reviewDate.setHours(0, 0, 0, 0);
            
                        if (reviewDate < today) {
                            reviewDateError = true;
                        }
                    }
                }
    
                fields[fieldName] = fieldValue;
            }

            if (nameFieldError) {
                component.set('v.isLoading', false);
                helper.toast('ERROR', $A.get("$Label.c.DNS_REQ_T_NAMEVALIDATION"));
                return;
            }

            if (reviewDateError) {
                component.set('v.isLoading', false);
                helper.toast('ERROR', $A.get("$Label.c.DNS_SQR_T_DATEPAST"));
                return;
            }
    
            component.find("recordEditForm").submit(fields);
        } catch (error) {
            console.log('error', error.message);
        }
    },

    handleSubmitSuccess : function(component, event, helper) {
        try {
            var response = event.getParam("response");
            var recordId = response.id;
    
            var rowDataList = component.get('v.rowDataList').length > 0 ? component.get('v.rowDataList') : null;
            if (rowDataList != null) {
                var isValid = true;
                rowDataList.forEach(function(row) {
                    if (!row.sqTitle || row.sqTitle.trim() === '') {
                        isValid = false;
                    }
                });
    
                if (!isValid) {
                    helper.toast('ERROR', $A.get("$Label.c.DNS_SQR_T_ALLTITLEFILL"));
                    component.set('v.isLoading', false);
                    return;
                }
            }
    
            var lineItemList = JSON.stringify(component.get('v.lineItemList'));
            var requestedSQ = rowDataList != null ? JSON.stringify(rowDataList) : 'null';

            console.log('@@ requestedSQ : ' + requestedSQ);
            console.log('@@ searchDatas : ' + JSON.stringify(component.get('v.searchDataList')));

            // Apex Call
            helper.apexCall(component, event, helper, 'insertSQRegistration', {
                recordId    : component.get('v.recordId'),
                lineItemList : lineItemList,
                // fieldMap    : fieldMap,
                requestedSQ : requestedSQ,
                searchDatas : component.get('v.searchDataList'),
                sqrId : recordId
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
    
                if(r.flag == 'success') {
                    helper.toast('SUCCESS', $A.get("$Label.c.DNS_SQR_T_SUCCESSINSERT"));
                    helper.closeModal(component, event, helper);
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.toast('ERROR', r.flag);
                }
    
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# insertSQRegistration error : ' + error.message);
            });
            
        } catch (error) {
            console.log('success error', error.message);
        }
    },

    handleSubmitError : function(component, event, helper) {
        var errors = event.getParam('error');
        console.log('errors', errors);
        
        var message = $A.get("$Label.c.DNS_ACC_T_ADMIN");
        
        if (errors && errors.body) {
            if (errors.body.message) {
                message = errors.body.message;
            } else if (errors.body.output && errors.body.output.errors.length > 0) {
                message = errors.body.output.errors[0].message;
            }
        }

        helper.toast('ERROR', message);
        component.set('v.isLoading', false);
    },

    handleSearchClick : function(component, event, helper) {
        component.set('v.isSearch', true);
        component.set('v.stageValue', 'Sales Review');
    },

    handleClickAddButton: function(component, event, helper) {
        var rowDataList = component.get("v.rowDataList") || [];
        const newRows = event.getParam("newRowData");

        if (newRows && newRows.length > 0) {
            rowDataList.push(...newRows); // 선택된 행 추가
        } else {
            var newRow = {
                "sqCategory": "기타",
                "sqTitle": "",
                "descriptionHtml": ""
            };
    
            rowDataList.push(newRow);
        }

        component.set("v.rowDataList", rowDataList);
    },

    handleClickdeleteButton: function(component, event, helper) {
        var index = event.getSource().get("v.accesskey", 10);
        var rowDataList = component.get("v.rowDataList");

        rowDataList.splice(index, 1);
        component.set("v.rowDataList", rowDataList);
    },

    handleChangeCategory: function(component, event, helper) {
        try {
            
            var index = event.getSource().get('v.accesskey');
            var categoryValue = event.getSource().get('v.value');
            
            var picklist = component.get("v.picklistValue");
    
            var selectedItem = picklist.find(function(item) {
                return item.value === categoryValue;
            });
            console.log("🚀 ~ selectedItem ~ selectedItem:", selectedItem);
    
            var selectedLabel = selectedItem ? selectedItem.label : '';
            console.log("선택된 라벨:", selectedLabel);
    
            
            var rowDataList = component.get('v.rowDataList');
            
            if(categoryValue != '기타' && categoryValue != '입회검사') {
                // Apex Call
                helper.apexCall(component, event, helper, 'changeCategory', {
                    category : categoryValue,
                    selectedLabel : selectedLabel,
                    language : component.get('v.language')
                })
                .then($A.getCallback(function(result) {
                    let r = result.r;
        
                    if(r == 'fail') {
                        helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                    } else {
                        rowDataList[index].descriptionHtml = r;
                        if(component.get('v.language') != 'ko') {
                            rowDataList[index].sqTitle = selectedLabel;
                            // if(rowDataList[index].sqTitle == '공통_COOLANT TANK / CHIP CONVEYOR 타입 변경 검토') {
                            //     rowDataList[index].sqTitle = 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form';
                            // } else if(rowDataList[index].sqTitle == 'VMC_부가 축 SQ의뢰') {
                            //     rowDataList[index].sqTitle = 'VMC_Additional Axis SQ Request Form';
                            // } else if(rowDataList[index].sqTitle == 'VMC기종_치구라인 SQ의뢰') {
                            //     rowDataList[index].sqTitle = 'VMC_Jig & Fixture SQ Request form';
                            // } else if(rowDataList[index].sqTitle == 'TC기종_표준 Chuck 변경 검토의뢰') {
                            //     rowDataList[index].sqTitle = 'TC_Standard Chuck Change Request Form';
                            // }
                        } else {
                            rowDataList[index].sqTitle = categoryValue.replace(' 양식', '');
                        }
    
                        component.set('v.rowDataList', rowDataList);
                    }
                }))
                .catch(function(error) {
                    console.log('# changeCategory error : ' + error.message);
                });
            } else if(categoryValue == '입회검사') {
                rowDataList[index].sqTitle = categoryValue;
                if(component.get('v.language') != 'ko') {
                    if(rowDataList[index].sqTitle == '입회검사') {
                        rowDataList[index].sqTitle = 'Factory Acceptance test (FAT)';
                    }
                }
                rowDataList[index].descriptionHtml = '';
                component.set('v.rowDataList', rowDataList);
            } else {
                rowDataList[index].descriptionHtml  = '';
                rowDataList[index].sqTitle      = '';
                component.set('v.rowDataList', rowDataList);
            }
        } catch (error) {
            console.log('error', error.message);
            
        }
    },

    handleClose : function(component, event, helper) {
        helper.closeModal(component, event, helper);
    },

    handleModalEvent: function (component, event, helper) {
        console.log('handleModalEvent');
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");
        
        if(actionName == 'Close') {
            const searchHistory = message.searchHistory;
            component.set('v.isSearch', false);

            if(searchHistory && searchHistory.length > 0) {
                component.set('v.searchDataList', searchHistory);
                console.log('component.get(v.searchDataList)', component.get('v.searchDataList'));
                
            }
        }
    
        if (actionName === 'Apply') {
            const searchHistory = message.searchHistory;
            const selectedRows = message.selectedRows;
    
            if (selectedRows.length > 0) {
                var rowDataList = component.get("v.rowDataList") || [];
                rowDataList.push(...selectedRows);
                
                component.set("v.rowDataList", rowDataList);
                component.set('v.isSearch', false);
            }
            
            if(searchHistory.length > 0) {
                component.set('v.searchDataList', searchHistory);
            }
        }
    },
    
    handleRemovePlaceholder: function (component, event, helper) {
        var cleared = component.get("v.placeholderCleared");
        var placeholder = component.get("v.richTextValue");
        if (!cleared) {
            component.set("v.richTextValue", '');
            component.set("v.placeholderCleared", true);            
        }
    },

    handleResetPlaceholder: function (component, event, helper) {
        var cleared = component.get("v.placeholderCleared");
        var placeholder = component.get("v.richTextValue");        
        if(cleared) {
            if(placeholder == ''){
                component.set("v.richTextValue", $A.get("$Label.c.DNS_SQR_P_PLACE"));
                component.set("v.placeholderCleared", false);
            }
        }
    }
})