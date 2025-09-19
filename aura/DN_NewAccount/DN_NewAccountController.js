({
    doInit : function(component, event, helper) {
        helper.apexCall(component, event, helper, 'getUserRecordType', {
            
        })
        .then($A.getCallback(function(result) {
            let r = result.r;

            console.log('r.appName', r.appName);
            var recordTypeOptions = [];
            for(var key in r.recordType) {
                if (r.recordType.hasOwnProperty(key) && key != 'Master' && key != 'Dealer' && key != '대리점') {
                    recordTypeOptions.push({
                        label: key,
                        value: r.recordType[key]
                    });
                }
            }
            component.set("v.recordTypeOptions", recordTypeOptions);
            component.set("v.userProfile", r.profile);
            component.set("v.listId", r.listId);
            component.set("v.appName", r.appName);
        }))
        .catch(function(error) {
            console.log('# getInit error : ' + error.message);
        });
    },

    handleChangeRadio : function(component, event, helper) {
        var changeValue = event.getParam("value");
        var options     = component.get("v.recordTypeOptions");
        var changeLabel = options.find(option => option.value === changeValue).label;

        component.set('v.radioValue', changeValue);
        component.set('v.radioLabel', changeLabel);

    },

    handleNext : function(component, event, helper) {
        component.set('v.isLoading',    true);
        if(component.get('v.radioValue') == null) {
            helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_SELECTRECORD"));
            component.set('v.isLoading',    false);
        } else {
            if(component.get('v.radioValue') == 'DNSACustomer') {
                // Apex Call
                helper.apexCall(component, event, helper, 'getNextInit', {
                    objectName      : component.get('v.objectName'),
                    recordTypeName  : component.get('v.radioValue')
                })
                .then($A.getCallback(function(result) {
                    let r = result.r;
                    console.log('layout ', r);
                    
                    component.set('v.recordTypeId',         r.getRecordTypeId);
                    component.set('v.userCountry',         r.getUserCountry);
                    component.set('v.userCurrency',         r.getUserCurrencyCode);
        
                    component.set('v.isDupl',       true);
                    component.set('v.isNext',       true);
                    component.set('v.isLoading',    false);
                }))
                .catch(function(error) {
                    console.log('# handleNext error : ' + error.message);
                });
            } else {
                component.set('v.isNext', true);
                window.setTimeout(
                    $A.getCallback(function() {
                        var inputCmp = component.find("inputKeyword");
                        if (inputCmp) {
                            inputCmp.focus();
                        }
                    }), 400
                );
                component.set('v.isLoading',    false);
            }
        }
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            if(component.get('v.keyword') == '') {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_KEYWORD"));
                return;
            } else if(component.get('v.keyword').length < 2) {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_NAMELENGTH"));
                return;
            } else {
                helper.searchAccount(component, event, helper);
                component.set('v.searchCheck', false);
            }
        }
    },

    handleClickSearch : function(component, event, helper) {
        try {
            if(component.get('v.keyword') == '') {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_KEYWORD"));
                return;
            } else if(component.get('v.keyword').length < 2) {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_NAMELENGTH"));
                return;
            } else {
                // Apex Call
                helper.searchAccount(component, event, helper);
                component.set('v.searchCheck', false);
            }
        } catch (error) {
            console.log('handleClickSearch Error : ' + error);
        }
    },

    handleSaveRecord: function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
    
            let rt = component.get('v.radioValue');
            let prospectLayout = '';
            let type = '';
            if(rt == 'ProspectCustomer') {
                prospectLayout = component.find("prospectLayout");
                type = 'prospect';
            } else if(rt == 'DNSACustomer') {
                prospectLayout = component.find("dnsaLayout");
                type = 'dnsa';
            } else if(rt == 'TradeCustomer') {
                prospectLayout = component.find("tradeLayout");
                type = 'trade';
            } else if(rt == 'ShipToParty') {
                prospectLayout = component.find("shipToLayout");
                type = 'shipto';
            }

            let recordFields = prospectLayout.find("recordField");
            var fieldMap = {};
            
            for (let i = 0; i < recordFields.length; i++) {
                let input = recordFields[i];
                let fieldName = input.get("v.fieldName");
                let fieldValue = input.get("v.value");
                
                if (input.get("v.required") && (fieldValue == null || fieldValue === '')) {
                    helper.apexCall(component, event, helper, 'getLabel', {
                        fieldName: fieldName
                    })
                    .then($A.getCallback(function(result) {
                        let r = result.r;
                        helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_REQUIRED") + r);
                        input.focus();
                        component.set('v.isLoading', false);
                    }));
                    return;
                } else {
                    fieldMap[fieldName] = fieldValue;
                }
            }
    
            var shippingAddress = prospectLayout.find('shippingAddress');
            if (shippingAddress) {
                console.log('type :',type);
                
                if(type == 'dnsa') {
                    if(shippingAddress.get("v.street") == null || shippingAddress.get("v.street") === '') {
                        helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_REQUIRED") + 'Shipping Street');
                        shippingAddress.focus();
                        component.set('v.isLoading', false);
                        return;
                    } else if(shippingAddress.get("v.city") == null || shippingAddress.get("v.city") === '') {
                        helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_REQUIRED") + 'Shipping City');
                        shippingAddress.focus();
                        component.set('v.isLoading', false);
                        return;
                    } else if(shippingAddress.get("v.province") == null || shippingAddress.get("v.province") === '') {
                        helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_REQUIRED") + 'Shipping State');
                        shippingAddress.focus();
                        component.set('v.isLoading', false);
                        return;
                    } else if(shippingAddress.get("v.country") == null || shippingAddress.get("v.country") === '') {
                        helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_REQUIRED") + 'Shipping Country');
                        shippingAddress.focus();
                        component.set('v.isLoading', false);
                        return;
                    } else if(shippingAddress.get("v.postalCode") == null || shippingAddress.get("v.postalCode") === '') {
                        helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_REQUIRED") + 'Shipping PostalCode');
                        shippingAddress.focus();
                        component.set('v.isLoading', false);
                        return;
                    }
                }
                fieldMap['ShippingStreet']      = shippingAddress.get("v.street");
                fieldMap['ShippingCity']        = shippingAddress.get("v.city");
                fieldMap['ShippingState']       = shippingAddress.get("v.province");
                fieldMap['ShippingCountry']     = shippingAddress.get("v.country");
                fieldMap['ShippingPostalCode']  = shippingAddress.get("v.postalCode");
            }
    
            // Apex Call
            helper.apexCall(component, event, helper, 'saveAccountRecord', {
                objectName: component.get('v.objectName'),
                fieldMap: fieldMap,
                recordTypeId: component.get('v.recordTypeId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                component.set('v.isLoading', false);

                let appName = component.get('v.appName');
                if(r.code == 'error') {
                    helper.toast('Error', r.message);
                    console.log('errorMsg', r.message);
                } else {
                    if (appName == 'DNS CS') {
                        helper.navigateList(component);
                    }
                    window.location.href = r.message;
                }

                // if (r != null) {
                //     if (r.includes('https://')) {
                //         let appName = component.get('v.appName');
                //         if (appName == 'DNS CS') {
                //             helper.closeTabAndNavigateToRecord(r, component);
                //         } else {
                //             window.location.href = r;   
                //         }
                //     } else {
                //         helper.toast('Error', r);
                //         console.log('errorMsg', r);
                //     }
                // }
            }));
        } catch (error) {
            console.log('handleSave Error: ' + error);
            component.set('v.isLoading', false);
        }
    },
    
    handleDuplNext : function(component, event, helper) {
        component.set('v.isLoading', true);
        
        try {
            var profileName = component.get('v.userProfile');
            
            var selectRow = component.get('v.selectedRows');
            console.log('selectRow', selectRow);
            
            if(selectRow.length == 0) {
                // Apex Call
                helper.apexCall(component, event, helper, 'getNextInit', {
                    objectName      : component.get('v.objectName'),
                    recordTypeName  : component.get('v.radioValue')
                })
                .then($A.getCallback(function(result) {
                    let r = result.r;
                    console.log('layout ', r);
        
                    component.set('v.recordTypeId',         r.getRecordTypeId);
                    component.set('v.userCountry',         r.getUserCountry);
                    component.set('v.userCurrency',         r.getUserCurrencyCode);
        
                    component.set('v.isDupl',       true);
                    component.set('v.isLoading',    false);
                }))
                .catch(function(error) {
                    console.log('# handleNext error : ' + error.message);
                });
            } else {
                
                if(profileName != '영업 직영영업' && profileName != 'System Administrator') {
                    helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_CANNOTREQ"));
                    component.set('v.selectedRows', []);
                    component.set('v.isLoading', false);
                } else {
                    // Apex Call
                    helper.apexCall(component, event, helper, 'checkShareAcc', {
                        recordId : selectRow[0].accId
                    })
                    .then($A.getCallback(function(result) {
                        let r = result.r;
                        console.log('r', r);
            
                        if(r == 'auth') {
                            helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_AUTH"));
                            component.set('v.selectedRows', []);
                        } else if(r == 'already') {
                            helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_ALREADY"));
                            component.set('v.selectedRows', []);
                        } else {
                            component.set('v.isRequest', true);
                        }
                        component.set('v.isLoading', false);
                    }))
                    .catch(function(error) {
                        console.log('# handleNext error : ' + error.message);
                    });
                }
            }
        } catch (error) {
            console.log('# handleDuplNext error : ', error.message);
        }
    },

    handleBack : function(component, event, helper) {
        window.history.back();
    },

    handleCancel: function(component, event, helper) {
        helper.navigateList(component);
        // let appName = component.get('v.appName');
        // if (appName == 'DNS CS') {
        //     helper.navigateList(component);
        // } else {
        //     window.history.back();
        // }
    },

    handleRowSelection: function (component, event, helper) {
        try {
            const selectedRows = component.get('v.selectedRows');
            const rowIndex = event.getSource().get('v.value');
            const rowData = component.get('v.searchDataList')[rowIndex];
    
            if (!rowData) {
                console.error('Row data is undefined for index:', rowIndex);
                return;
            }
    
            const allCheckboxes = component.find("checkbox");
    
            if (!allCheckboxes) {
                console.error('No checkboxes found.');
                return;
            }
    
            const checkboxesArray = Array.isArray(allCheckboxes) ? allCheckboxes : [allCheckboxes];
    
            if (event.getSource().get('v.checked')) {
                selectedRows.push(rowData);
    
                checkboxesArray.forEach(checkbox => {
                    if (checkbox.get("v.value") !== rowIndex) {
                        checkbox.set("v.disabled", true);
                    }
                });
    
            } else {
                const indexToRemove = selectedRows.findIndex(row => row.id === rowData.id);
                if (indexToRemove > -1) {
                    selectedRows.splice(indexToRemove, 1);
                }
    
                checkboxesArray.forEach(checkbox => {
                    checkbox.set("v.disabled", false);
                });
            }
    
            component.set('v.selectedRows', selectedRows);
    
        } catch (error) {
            console.log('# handleRowSelection error : ', error.message);
        }
    },
    

    handleSaveRequest : function(component, event, helper) {
        component.set('v.isLoading',    true);
        var value = component.find('requestField').get('v.value');

        // Apex Call
        helper.apexCall(component, event, helper, 'insertRequestCustomer', {
            reason : value,
            selectedId : component.get('v.selectedRows')[0].accId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;

            let appName = component.get('v.appName');
            if(r == 'Empty') {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_SIMPLECUSTOMER"));
            } else if (r == 'Error') {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            } else {
                if (appName == 'DNS CS') {
                    helper.navigateList(component);
                }
                window.location.href = r;
            }


            component.set('v.isLoading',    false);
        }))
        .catch(function(error) {
            console.log('# handleNext error : ' + error.message);
        });
    },

    handleSearchPrevious : function(component, event, helper) {
        component.set('v.isNext', false);
    },

    handleRequestPrevious : function(component, event, helper) {
        component.set('v.keyword', '');
        component.set('v.selectedRows', []);
        component.set('v.searchDataList', []);
        component.set('v.searchCheck', true);
        component.set('v.isRequest', false);
    },

    handlePrevious : function(component, event, helper) {
        if(component.get('v.radioValue') == 'DNSACustomer') {
            component.set('v.radioValue', '');
            component.set('v.isNext', false);
            component.set('v.isRequest', false);
            component.set('v.isDupl', false);
        } else {
            component.set('v.keyword', '');
            component.set('v.selectedRows', []);
            component.set('v.searchDataList', []);
            component.set('v.searchCheck', true);
            component.set('v.isDupl', false);
        }

    }
})