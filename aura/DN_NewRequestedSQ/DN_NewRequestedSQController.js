({
    modalInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set("v.initialValue", true);
        
        console.log("🚀 ~ recordId:", component.get('v.recordId'));

        // Apex Call
        helper.apexCall(component, event, helper, 'newReqInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log("🚀 newReqInit r:", r);

            component.set('v.isReviewCheck', r.checkIsReview);
            component.set('v.language', r.language);
            component.set('v.categoryValues', r.categoryValues);
            if(r.rt == 'DNSA') {
                component.set('v.dnsa', true);
            }
        }))
        .catch(function(error) {
            console.log('# newReqInit error : ' + error.message);
        });
        component.set('v.isLoading', false);
    },

    handleChangeCategory : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set("v.initialValue", true);
        
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
            component.set('v.isPick', true);
            component.set('v.isLoading', false);
            if(component.find('SQRegistrationField').get('v.value') == null) {
                component.find('SQRegistrationField').set('v.value', component.get('v.recordId'));
            }
        } catch (error) {
            console.log('error', error.message);
            component.set('v.isLoading', false);
        }
        component.set('v.isLoading', false);
    },

    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        component.set('v.isLoading', true);
        var nameValue = component.find('nameField').get('v.value');
        console.log('nameValue.length', nameValue.length);
        
        if(nameValue.length > 40 && nameValue != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
            helper.toast('Error', $A.get("$Label.c.DNS_REQ_T_NAMEVALIDATION"));
            component.set('v.isLoading', false);
        } else {
            var fields = event.getParam('fields');
            fields['IsInitialRequest__c'] = component.get('v.initialValue'); // Aura 속성 값 적용
            component.find('recordEditForm').submit(fields);
            // component.find("recordEditForm").submit();
        }
    },

    handleSuccess : function(component, event, helper) {
        component.set('v.isLoading', false);
        helper.toast('Success', $A.get("$Label.c.DNS_REQ_T_CREATEREQ"));
        helper.closeModal(component, event);
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_NewRequestedSQ',
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

    handleClose : function(component, event, helper) {
        helper.closeModal(component, event);
    }
})