/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-08-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    saveAttribute : function(component, event) {
        var attributeName = event.getSource().get('v.name');
        var attrbuteValue = event.getSource().get('v.value');

        component.set('v.'+attributeName, attrbuteValue);
    },

    toast : function(type, msg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: msg
        });
        toastEvent.fire();
    },

    apexCall : function(component, methodName, params) {
        console.log('helper 동작 확인')
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        console.log('환불 조회 apex 작동 확인!!')
                        resolve({'c':component, 'r':response.getReturnValue(), 's': response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    // 공통 row 전체 선택 메서드
    selectAllRows: function (component, event, helper, checkboxName, headerCheckboxName) {
        console.log('전체 선택 실행: ' + checkboxName + ' | ' + headerCheckboxName);
    
        var isChecked = component.find(headerCheckboxName).get("v.checked"); 
        var checkboxes = component.find(checkboxName); 
        var selectedRows = []; 

        if (Array.isArray(checkboxes)) {
            checkboxes.forEach(function (checkbox) {
                checkbox.set("v.checked", isChecked);
                if (isChecked) {
                    selectedRows.push(checkbox.get("v.value"));
                }
            });
        } else if (checkboxes) {
            checkboxes.set("v.checked", isChecked); 
            if (isChecked) {
                selectedRows.push(checkboxes.get("v.value")); 
            }
        }
    
        component.set("v.selectedRows", selectedRows); 
        console.log('selectedRows:: ', JSON.stringify(selectedRows)); 

    },

    // 공통 체크박스 선택/해제
    handleCheckboxChange: function (component, event, helper, checkboxName) {
        var checkboxes = component.find('checkboxId'); 
        var selectedValue = event.getSource().get("v.value");
        var isChecked = event.getSource().get("v.checked");

        if (!Array.isArray(checkboxes)) {
            checkboxes = [checkboxes];
        }
        console.log('checkboxes 형태' + JSON.stringify(checkboxes,null,4))
        console.log('checkbox.get("v.value") 형태' + JSON.stringify(checkboxes[0].get("v.value"),null,4))
        console.log('selectedValue 형태' + JSON.stringify(selectedValue,null,4))

        checkboxes.forEach(function(checkbox) {
            if (checkbox.get("v.value") === selectedValue) {
                checkbox.set("v.checked", isChecked);
            }
        });

        var selectedRows = checkboxes
            .filter(function(checkbox) {
                return checkbox.get("v.checked");
            })
            .map(function(checkbox) {
                return checkbox.get("v.value");
            });

        component.set("v.selectedRows", selectedRows);
        console.log('selectedRows :: ' , JSON.stringify(selectedRows));
    },

    dayCount : function(selDay) {
        console.log('헬퍼 데이 카운트')
        let year  = selDay.getFullYear(); 
        let month = ('0' + (selDay.getMonth() + 1)).slice(-2);
        let day   = ('0' + selDay.getDate()).slice(-2);

        return year + '-' + month + '-' + day;
    },

    // 기간 계산
    dayCounter : function (sDate, eDate) {
        console.log('기간 계산')
        var diff = new Date(eDate) - new Date(sDate);
        var daySecond = 24*60*60*1000;
        var result = parseInt(diff/daySecond);
        return result
    },
    
})