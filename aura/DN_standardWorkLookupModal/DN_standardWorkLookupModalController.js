/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-12-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-15-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit: function(component, event, helper) {
        const objectType = component.get("v.objectType");
        const modelCode = component.get("v.assetName").split('-')[0];
        const isBranch = component.get("v.isBranch");

        console.log('objectType in Init :::', objectType);
        console.log('modelCode in Init :::', modelCode);
        console.log('isBranch in Init :::', isBranch);

        let action = component.get("c.initStandardHRList");

        action.setParams({ objectType: objectType, modelCode: modelCode });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let r = response.getReturnValue();

            console.log('responseData ::: ', JSON.stringify( r, null, 2));
            
            if (state === "SUCCESS") {
                if (r.flag == "success") {
                    component.set('v.modelManagerId', r.modelManager.Id);
                    component.set("v.failureAreaList", r.failureAreaList);
                    component.set("v.standardWorkList", r.standardHRList);
                } else if (r.flag == "warning") {
                    helper.toast("WARNING", r.message);
                } else {
                    helper.toast("Error", r.message);
                }
            } else {
                helper.toast("Error", r.message);
            } 
        });
        $A.enqueueAction(action);
    }, 

    //서비스맨 모달 닫기
    modalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    //th에 있는 checkbox선택 시 모든 checkbox 선택
    toggleAllCheckboxes: function(component, event, helper) {
        let selectAll = component.get("v.selectAll"); // 전체 선택 체크박스 상태 가져오기
        let checkboxes = component.find("tableCheckbox"); // 개별 체크박스 배열 가져오기
    
        if (Array.isArray(checkboxes)) {
            checkboxes.forEach(checkbox => checkbox.set("v.checked", selectAll));
        } else if (checkboxes) {
            checkboxes.set("v.checked", selectAll);
        }
    },
    
    // 개별 체크박스 상태에 따라 전체 선택 상태 업데이트
    toggleSelectAll: function(component, event, helper) {
        var rowIndex    = event.getSource().get("v.accesskey");
        var standardWorkList = component.get("v.standardWorkList");
        var selectedItems = component.get("v.selectedItems") || [];

        var item               = standardWorkList[rowIndex],
            itemId             = item.Id,
            breakdownPart      = item.FailureArea__c,
            standardWorkItem   = item.StandardHourItem__c,
            standardWorkTime   = item.StandardWorkTime__c,
            standardWorkPeople = item.StandardWorkForce__c;

            var isChecked = event.getSource().get("v.checked");

            if (isChecked) {
                selectedItems.push({
                    standardHourId: itemId,
                    breakdownPart     : breakdownPart,
                    standardWorkItem  : standardWorkItem,
                    standardWorkTime  : standardWorkTime,
                    standardWorkPeople: standardWorkPeople
                });
            } else {
                selectedItems = selectedItems.filter(function(item) {
                    return item.id !== itemId;
                });
            }
            
            component.set("v.selectedItems", selectedItems);
    },

    handleSave: function(component, event, helper) {
        var selectedItems = component.get("v.selectedItems");
        var compEvent = component.getEvent("SelectedItemEvent");

        compEvent.setParams({
            "selectedItems": selectedItems
        });

        compEvent.fire();
        console.log("Event fired with selectedItems:", JSON.stringify(selectedItems));
        helper.closeModal(component);
        
    },

    // 검색 버튼으로 조회
    doSearch : function (component, event, helper) {
        let failureAreaList = component.get("v.failureAreaList");
        let selectedFailureArea = component.get("v.failureArea");
        let modelManagerId = component.get("v.modelManagerId");
        let standardHourName = component.get("v.standardHourName");
        let labelData = '';
        
        failureAreaList.forEach(element => {
            if(element.value == selectedFailureArea) {
                console.log(element.label);
                labelData = element.label;
            } 
        });

        if (!labelData) {
            helper.toast('WARNING', '고장부위 값이 존재하지 않습니다.');
            return;
        }

        helper.apexCall(component, event, helper, 'searchStandardHRList', { failureArea: labelData , modelManagerId: modelManagerId, standardHourName: standardHourName })
        .then($A.getCallback(function (result) {
            let r = result.r;
            
            console.log('response from apex ::: ', JSON.stringify(r.standardHRList, null, 2));
            
            if (r.errorString) {
                helper.toast('ERROR', '조회 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                console.log(r.stackTrace);
            } else {
                if (r.standardHRList) {
                    helper.toast('SUCCESS', '표준 공수가 조회되었습니다.');
                    component.set("v.standardWorkList", r.standardHRList);

                } else {
                    helper.toast('WARNING', '해당 장비의 고장 부위 별 표준 공수가 존재하지 않습니다.');
                    component.set('v.standardWorkList', []);
                }
            }
        }))
        .catch((error) => {
            helper.toast("ERROR", "데이터 가져오기에 실패했습니다.");
            console.log("Fetch Error ::: ", JSON.stringify(error, null, 2));
        });
    },


    // 고장부위 콤보박스로 조회
    handleFailureAreaChange: function (component, event, helper) {
        let failureArea = component.get("v.failureArea");
        let modelManagerId = component.get("v.modelManagerId");
        let failureAreaList = component.get("v.failureAreaList");
        let labelData = '';

        failureAreaList.forEach(element => {
            if(element.value == failureArea) {
                console.log(element.label);
                labelData = element.label;
            } 
        });

        if (!labelData || !modelManagerId) {
            helper.toast('WARNING', '고장부위 또는 모델 코드의 값이 존재하지 않습니다.');
            return;
        }
        
        console.log('failureArea ::: ', labelData, 'modelManagerId ::: ' , modelManagerId);

        helper.apexCall(component, event, helper, 'getStandardHRbyfailureArea', { failureArea: labelData, modelManagerId: modelManagerId })
        .then($A.getCallback(function (result) {
            let r = result.r;

            console.log('response from apex ::: ', JSON.stringify(r.standardHRList, null, 2));
            
            if (r.errorString) {
                helper.toast('ERROR', '조회 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                console.log(r.stackTrace);
            } else {
                if (r.standardHRList) {
                    helper.toast('SUCCESS', '표준 공수가 조회되었습니다.');
                    component.set("v.standardWorkList", r.standardHRList);

                } else {
                    helper.toast(r.flag, '해당 장비의 고장 부위 별 표준 공수가 존재하지 않습니다.');
                    component.set('v.standardWorkList', []);
                }
            }
        }))
        .catch(error => {
            helper.toast('ERROR', '데이터 조회에 실패했습니다.');
            console.log('handleFailureAreaChange Error ::: ', JSON.stringify(error, null, 2));
        });
    },

    // 표준 공수 없음 
    standardWorkNone : function (component, event, helper) { 
        let isBranch = component.get("v.isBranch");
        var selectedItems = component.get("v.selectedItems");
        var compEvent = component.getEvent("SelectedItemEvent");

        if (isBranch) {
            selectedItems.push({
                readOnlyValue : '표준공수 없음을 선택하였습니다.',
                isNoStandardWork : true,
            });
        } else {
            selectedItems.push({
                readOnlyValue : '표준공수 없음을 선택하였습니다.',
                isNoStandardWork : true,
            });
        }
        
        component.set("v.selectedItems", selectedItems);

        compEvent.setParams({
            "selectedItems": selectedItems
        });

        compEvent.fire();
        console.log("Event fired with selectedItems:", JSON.stringify(selectedItems));
        helper.closeModal(component);
    },
})