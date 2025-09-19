({
    modalInit : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            component.set("v.fieldStatus", { Sales_SQ__c: false, rndSQ__c: false });
            // Apex Call
            helper.apexCall(component, event, helper, 'editRequestedInit', {
                recordId : component.get('v.rowId'),
                objectName : component.get('v.objectName')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
    
                component.set('v.fieldList', r.getRequestedSQEditFieldSet);
                component.set('v.isSalesSQ', r.checkSalesSQ);
                component.set('v.isRndSQ', r.checkRndSQ);
                component.set('v.language', r.language);
                component.set('v.isReviewCheck', r.checkIsReview);
                component.set('v.categoryValues', r.categoryValues);

                let fieldStatus = component.get("v.fieldStatus");
                fieldStatus.Sales_SQ__c = r.checkSalesSQ || false;
                fieldStatus.rndSQ__c = r.checkRndSQ || false;
                component.set("v.fieldStatus", fieldStatus);

                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# getRequestedSQEditFieldSet error : ' + error.message);
            });
        } catch (error) {
            console.log('# modalInit error : ' + error.message);
            
        }
    },

    handleChangeCategory : function(component, event, helper) {
        component.set('v.isLoading', true);
        var categoryValue = component.find('categoryField').get('v.value');
        var picklist = component.get("v.categoryValues");
    
        try {
            var selectedItem = picklist.find(function(item) {
                return item.value === categoryValue;
            });
            var selectedLabel = selectedItem ? selectedItem.label : '';
            
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
                        component.find('descriptionField').set('v.value', r);
                        if(component.get('v.language') != 'ko') {
                            component.find('nameField').set('v.value', selectedLabel);
                        } else {
                            component.find('nameField').set('v.value', categoryValue.replace(' 양식', ''));
                        }
                    }
                }))
                .catch(function(error) {
                    console.log('# changeCategory error : ' + error.message);
                });
            } else {
                component.find('descriptionField').set('v.value', '');
                if(component.get('v.language') != 'ko') {
                    component.find('nameField').set('v.value', selectedLabel);
                } else {
                    component.find('nameField').set('v.value', categoryValue.replace(' 양식', ''));
                }
            }
        } catch (error) {
            console.log('error', error.message);
            component.set('v.isLoading', false);
        }
        component.set('v.isLoading', false);
    },


    handleChangeSalesSQ: function (component, event, helper) {
        var fieldValue = event.getSource().get("v.value");
        var fieldStatus = component.get("v.fieldStatus");

        if (typeof fieldStatus === "string") {
            try {
                fieldStatus = JSON.parse(fieldStatus);
            } catch (error) {
                console.error("Failed to parse fieldStatus:", error);
                return;
            }
        }

        fieldStatus.rndSQ__c = !!fieldValue;
        component.set("v.fieldStatus", fieldStatus);
    },

    handleChangeRndSQ: function (component, event, helper) {
        var fieldValue = event.getSource().get("v.value");
        var fieldStatus = component.get("v.fieldStatus");

        if (typeof fieldStatus === "string") {
            try {
                fieldStatus = JSON.parse(fieldStatus);
            } catch (error) {
                console.error("Failed to parse fieldStatus:", error);
                return;
            }
        }

        fieldStatus.Sales_SQ__c = !!fieldValue;
        component.set("v.fieldStatus", fieldStatus);
    },

    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        component.set('v.isLoading', true);
    
        var fields = component.find('recordField');
        var isValid = true;
    
        if (Array.isArray(fields)) {
            fields.forEach(function(field) {
                if (field.get('v.fieldName') === 'Name') { // 필드명이 'Name'인 경우
                    var nameValue = field.get('v.value');
                    if (nameValue && nameValue.length > 40 && nameValue != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
                        helper.toast('Error', $A.get("$Label.c.DNS_REQ_T_NAMEVALIDATION"));
                        isValid = false;
                    }
                }
            });
        } else {
            if (fields.get('v.fieldName') === 'Name') {
                var nameValue = fields.get('v.value');
                if (nameValue && nameValue.length > 40 && nameValue != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
                    helper.toast('Error', $A.get("$Label.c.DNS_REQ_T_NAMEVALIDATION"));
                    isValid = false;
                }
            }
        }
    
        if (!isValid) {
            component.set('v.isLoading', false);
            return;
        }
    
        component.find("recordEditForm").submit();
    },    

    handleSuccess : function(component, event, helper) {
        component.set('v.isLoading', false);
        helper.toast('Success', $A.get("$Label.c.DNS_REQ_T_EDITREQ"));
        helper.closeModal(component, event);
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_EditRequestedSQ',
            "actionName"    : 'Close',
            "message"       : 'refreshNewRequestedSQ'
        });
        modalEvent.fire();
    },

    handleError : function(component, event, helper) {
        const errorMessage = event.getParam('message');
        helper.toast('Error', errorMessage);
        component.set('v.isLoading', false);
    },

    handleClickClose : function(component, event, helper) {
        helper.closeModal(component, event);
    }
})