/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-03-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    apexCall : function(component, methodName, params) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's':response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log('error :: ' + methodName + 'message :: ' + errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    

    // 속성 업로드
    updateFieldValue: function (component, event, helper) {
        let self = this;
        var fieldName = event.getSource().get('v.name');
        var fieldValue = event.getSource().get('v.value');
        var refundList = component.get('v.refundList');
        var rowIndex = event.getSource().get('v.accesskey');
        
        if(fieldName == 'complaintReason1') {
            var complaintType2 = component.get('v.complaintType2');
            var cr2 = complaintType2.filter(option => option.value.startsWith(fieldValue));
            refundList[rowIndex].cr2Option = cr2;

            component.set('v.refundList',refundList);
        }

        var orderQtyList = component.get('v.orderQtyList');
        console.log('orderQtyList >>>> ' +JSON.stringify(orderQtyList,null,4))
        console.log('fieldName >>>> ' + fieldName);
        console.log('fieldValue >>>> ' + fieldValue);
        if(fieldName == 'orderQty') {
            if(orderQtyList[rowIndex] < fieldValue) {
                self.toast('WARNIMG', `입력하신 수량은 최대 반품 수량인 ${orderQtyList[rowIndex]} 을 초과합니다.`);
                refundList[rowIndex].orderQty = orderQtyList[rowIndex];
            }
            component.set('v.refundList',refundList);
        }

    },
    
    // 공통 row 전체 선택 메서드
    selectAllRows: function (component, event, helper, checkboxName, headerCheckboxName) {
        var checkboxes = component.find(checkboxName);
        var isChecked = component.find(headerCheckboxName).get("v.checked");

        var plist = [];

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    checkbox.set("v.checked", isChecked);
                    plist.push(index);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
                plist.push(0);
            }
        } else {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
            plist = [];
        }
        component.set('v.selectedRows', plist);
        var selectedRows = component.get('v.selectedRows');
        console.log('all checked :: ' + selectedRows);
    },

    // 공통 체크박스 선택/해제
    handleCheckboxChange: function (component, event, helper, checkboxName) {
        var checkbox = component.find(checkboxName);
        var selectedRows = [];
        if (Array.isArray(checkbox)) {
            for (var i = 0; i < checkbox.length; i++) {
                if (checkbox[i].get("v.checked")) {
                    selectedRows.push(i);
                }
            }
        } else {
            if (checkbox.get("v.checked")) {
                selectedRows.push(0); 
            }
        }
        component.set('v.selectedRows', selectedRows);
        var selectedRows = component.get('v.selectedRows');
        console.log('selectedRows :: ' + selectedRows);
    },

    abackOrderInquiry: function (component, recordId, helper) {
        window.history.back();
    },

    deepCopy: function(obj) {
        if (typeof obj !== "object" || obj === null) return obj;
        let copy = Array.isArray(obj) ? [] : {};
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                copy[key] = this.deepCopy(obj[key]);
            }
        }
        return copy;
    }
})