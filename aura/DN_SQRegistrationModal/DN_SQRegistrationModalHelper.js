({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    closeModal : function(component, event, helper) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_SQRegistrationModal',
            "actionName"    : 'Close',
            "message"       : 'CloseSQ'
        });
        modalEvent.fire();
    },

    init : function(component, event, helper) {
        var self = this;
        component.set('v.isLoading', true);
        var lineItemId = component.get('v.lineItemList')[0].Id;

        //25-08-12 [GSR]CRM SQ 개선 요청 건 으로 추가
        let rowDataList = component.get("v.rowDataList");
        if (!rowDataList || rowDataList.length === 0) {
            rowDataList = [{ sqCategory: '', sqTitle: '', descriptionHtml: '' }];
            component.set("v.rowDataList", rowDataList);
        }

        // Apex Call
        self.apexCall(component, event, helper, 'getInit', {
            recordId : component.get('v.recordId'),
            lineItemId : lineItemId,
            objectName : component.get('v.objectName')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('@@ result.r', result);

            component.set('v.fieldList',      r.initDatas);
            component.set('v.picklistValue',  r.getCategoryPicklist);
            component.set('v.productModel',   r.getProductModel.name != null ? r.getProductModel.name : '');
            component.set('v.productModelId', r.getProductModel.id != null ? r.getProductModel.id : '');
            component.set('v.productCode',    r.getProductModel.code != null ? r.getProductModel.code : '');

            component.set('v.accValue',      r.getDefaultField.Account);
            component.set('v.opptyValue',    r.getDefaultField.Opportunity);
            component.set('v.stageValue',    r.getDefaultField.Stage);
            component.set('v.currencyValue', r.getDefaultField.CurrencyIsoCode);
            component.set('v.modelValue',    r.getProductModel.name);
            component.set('v.productValue',  r.getProductModel.productId);
            component.set('v.language',      r.getDefaultField.language);
            component.set('v.recordTypeName', r.getDefaultField.RecordTypeName);
            component.set('v.recordTypeId', r.getRecordTypeId);

            if(r.getDefaultField.RecordTypeName == 'Korea') {
                component.set('v.groupId', r.getDefaultField.groupId);
            } 
            else if(r.getDefaultField.globalGroupId != null) {
                component.set('v.groupId', r.getDefaultField.globalGroupId);
            }
            console.log('@@ v.groupId : ' + r.getDefaultField.groupId);

            // Apex Call
            self.apexCall(component, event, helper, 'getFieldInfo', {
                recordId : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('getFieldInfo.r', r);

                component.set('v.ownerId', r.getCurrentUser.Id);
                component.set('v.dealerId', r.getCurrentUser.AccountId);
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# getFieldInfo error : ' + error.message);
            });
        }))
        .catch(function(error) {
            console.log('# getInit error : ' + error.message);
        });
    },

    parseCurrency: function(value) {
        if (value === undefined || value === null || value === '') {
            return null; // 값이 없으면 null 반환
        }
        return parseFloat(value.replace(/,/g, '')); // 쉼표 제거 후 숫자로 변환
    },    
})