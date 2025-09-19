({
    doInit: function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'initPricing', {
            recordId: component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if (r.stageName !== 'Created') {
                helper.toast('Error', 'Only available in Created status.');
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                return;
            }
            if (r.checkRecordType) {
                helper.toast('Error', 'Discount button is only available for Commodity.');
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                return;
            }
            if (r.flag === 'order') {
                helper.toast('Error', r.message);
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                return;
            }

            if (r.dealerPrice.flag === 1) {
                helper.toast('Error', 'The Order Item does not exist.');
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
            } else {
                // Format all prices to two decimal places
                component.set('v.dealerPrice', Number(Number(r.dealerPrice.dealerPrice).toFixed(2)));
                component.set('v.extraDisc', Number(Number(r.dealerPrice.disc).toFixed(2)));
                component.set('v.warrValue', Number(Number(r.dealerPrice.warr).toFixed(2)));
                component.set('v.listPrice', Number(Number(r.dealerPrice.listPrice).toFixed(2)));
                component.set('v.adjustmentPrice', Number(Number(r.dealerPrice.adjustmentPrice).toFixed(2)));

                if (r.initDatas.O_RETURN.MESSAGE === '') {
                    component.set('v.O_Price', Number(Number(r.initDatas.O_PRICE).toFixed(2)));

                    let inputFields = component.find("recordField");
                    let fieldValues = {};

                    if (Array.isArray(inputFields)) {
                        inputFields.forEach(function(field) {
                            fieldValues[field.get("v.fieldName")] = field.get("v.value");
                        });
                    } else {
                        fieldValues[inputFields.get("v.fieldName")] = inputFields.get("v.value");
                    }

                    fieldValues["O_Price"] = component.get("v.O_Price");
                    helper.calculateTotalPrice(component, event, helper, fieldValues);
                } else {
                    helper.toast('Error', r.initDatas.O_RETURN.MESSAGE);
                    component.set('v.isLoading', false);
                }
            }
        }))
        .catch(function(error) {
            console.log('# initPricing error: ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleClickApply: function(component, event, helper) {
        component.set('v.isLoading', true);
        let inputFields = component.find("recordField");
        let fieldValues = {};
    
        if (Array.isArray(inputFields)) {
            inputFields.forEach(function(field) {
                fieldValues[field.get("v.fieldName")] = field.get("v.value");
            });
        } else {
            fieldValues[inputFields.get("v.fieldName")] = inputFields.get("v.value");
        }
        fieldValues["O_Price"] = component.get("v.O_Price");
        console.log("🚀 ~ fieldValues :: " + JSON.stringify(fieldValues));

        if(fieldValues['ServiceReimbursement__c'] == null) {
            helper.toast('Error', 'Select the Service Reimbursement (Yes/No) field.');
            component.set('v.isLoading', false);
            return;
        }

        if(fieldValues['MachinePartsWarranty__c'] == '') {
            helper.toast('Error', 'Select the Machine Warranty field.');
            component.set('v.isLoading', false);
            return;
        }
    
        // Apex Call
        helper.apexCall(component, event, helper, 'applyPricing', {
            recordId: component.get('v.recordId'),
            fieldData: fieldValues
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('Apex Response:', r);
    
            if(r == 'success') {
                helper.toast('Success', 'Pricing was successfully applied');
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.toast('Error', 'An error occurred, please contact your administrator.');
                component.set('v.isLoading', false);
            }
        }))
        .catch(function(error) {
            console.error('initPricing error:', error.message);
            component.set('v.isLoading', false);
        });
    },

    handleClickClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
    },

    handleFieldChange: function(component, event, helper) {
        let changedField = event.getSource();
        let fieldName = changedField.get("v.fieldName");
        // console.log("🚀 ~ fieldName:", fieldName)
        // let value = changedField.get("v.value");
        // console.log("🚀 ~ value:", value)

        let inputFields = component.find("recordField");
        let fieldValues = {};

        if (Array.isArray(inputFields)) {
            inputFields.forEach(function(field) {
                fieldValues[field.get("v.fieldName")] = field.get("v.value");
                console.log(`🚀 ~ inputFields.forEach ~ field.get("v.value"):`, field.get("v.value"))
                console.log(`🚀 ~ inputFields.forEach ~ field.get("v.fieldName"):`, field.get("v.fieldName"))
            });
        } else {
            fieldValues[inputFields.get("v.fieldName")] = inputFields.get("v.value");
            console.log(`🚀 ~ inputFields.get("v.value"):`, inputFields.get("v.value"))
            console.log(`🚀 ~ inputFields.get("v.fieldName"):`, inputFields.get("v.fieldName"))
        }

        fieldValues["O_Price"] = component.get("v.O_Price");

        let OtherDiscount = fieldValues['OtherDiscount__c'] != null ? 
            Number(fieldValues['OtherDiscount__c']) : 0;
        let PromotionalPackage = fieldValues['PromotionalPackage__c'] != null ? 
            Number(fieldValues['PromotionalPackage__c']) : 0;
        let ProfitMarginSubsidyPlan = fieldValues['ProfitMarginSubsidyPlan__c'] != null ? 
            Number(fieldValues['ProfitMarginSubsidyPlan__c']) : 0;
        
        let text = 'errorMsg_' + fieldName;
        let shortFieldName = text.replace(/[^a-zA-Z0-9]/g, "");
        let errorMsg = component.find(shortFieldName);
        
        // if (value > 0) {
        if (OtherDiscount > 0  || PromotionalPackage > 0 || ProfitMarginSubsidyPlan > 0) {
            $A.util.removeClass(errorMsg, "slds-hide"); // 에러 메시지 표시
            component.set('v.checkApply', true);
        } else {
            $A.util.addClass(errorMsg, "slds-hide"); // 에러 메시지 숨김
            component.set('v.checkApply', false);
    
            helper.calculateTotalPrice(component, event, helper, fieldValues);
        }

    },

    handlePickChange: function(component, event, helper) {
        let changedField = event.getSource();
        let fieldName = changedField.get("v.fieldName");
        console.log("🚀 ~ fieldName:", fieldName)
        let value = changedField.get("v.value");
        console.log("🚀 ~ value:", value)
        
        let inputFields = component.find("recordField");
        let fieldValues = {};
    
        if (Array.isArray(inputFields)) {
            inputFields.forEach(function(field) {
                fieldValues[field.get("v.fieldName")] = field.get("v.value");
            });
        } else {
            fieldValues[inputFields.get("v.fieldName")] = inputFields.get("v.value");
        }
    
        fieldValues["O_Price"] = component.get("v.O_Price");
        helper.calculateTotalPrice(component, event, helper, fieldValues);

    },

    handleWarrChange : function(component, event, helper) {
        component.set('v.isLoading', true);
        let changedField = event.getSource();
        let fieldName = changedField.get("v.fieldName");
        console.log("🚀 ~ fieldName:", fieldName)
        let value = changedField.get("v.value");
        console.log("🚀 ~ value:", value)
        
        // Apex Call
        helper.apexCall(component, event, helper, 'changeWarranty', {
            recordId: component.get('v.recordId'),
            value: value
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('changeWarranty Response:', r);

            if(r == 'error') {
                helper.toast('Error', 'An error occurred, please contact your administrator.');
                component.find('overlayLib').notifyClose();
                component.set('v.isLoading', false);
            } else {
                component.set('v.warrValue', Number(r));

                let inputFields = component.find("recordField");
                let fieldValues = {};
            
                if (Array.isArray(inputFields)) {
                    inputFields.forEach(function(field) {
                        fieldValues[field.get("v.fieldName")] = field.get("v.value");
                    });
                } else {
                    fieldValues[inputFields.get("v.fieldName")] = inputFields.get("v.value");
                }
            
                fieldValues["O_Price"] = component.get("v.O_Price");
                helper.calculateTotalPrice(component, event, helper, fieldValues);
            }
    
            
        }))
        .catch(function(error) {
            console.error('changeWarranty error:', error.message);
            component.set('v.isLoading', false);
        });

        
        // helper.calculateTotalPrice(component, event, helper, fieldValues);
    },
    
})