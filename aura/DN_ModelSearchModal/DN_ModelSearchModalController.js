/**
 * @author            : Jun-Yeong Choi
 * @description       : 
 * @last modified on  : 03-04-2025
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   2024-06-18   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        var type = component.get('v.type');
        var Machine = component.get('v.MachineName');

        console.log('type : ' + type)
        console.log('Machine : ' + Machine)

        if(Machine != null && Machine != undefined && Machine != '') {
            console.log('machineNo = ' + Machine);
            component.set('v.machineNo', Machine);

            component.set('v.isLoading', true);

            var action = component.get('c.unitInfo');
            action.setParams({
                mn : Machine
            });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if(status === "SUCCESS") {
                    console.log('장비번호 성공');
                    let unitInfo = response.getReturnValue();
                    console.log('unitInfo :: ' + JSON.stringify(unitInfo,null,4));
                    var lists = unitInfo.map(function(at) {
                        return {label: at.Name, value: at.Id, machineName : at.MachineName__c}
                    })
                    console.log('lists :: ' + JSON.stringify(lists,null,4));
                    component.set('v.serialList', lists);
                } else {
                    console.log('실패...');
                }
                component.set('v.isLoading', false);
            })
    
            $A.enqueueAction(action);
        }
    },

    // 기종 찾기
    searchMachine: function(component, event, helper) {
        var keyWord = component.get('v.modelValue').trim();
        console.log('keyWord : ' + keyWord);
        console.log('keyWord.trim() : ' + keyWord.trim());
    
        // if(keyWord.length < 3) {
        //     helper.toast('WARNING','3자리 이상 입력하여 검색해주세요.');
        //     return;
        // }else if(keyWord.trim() == '') {
        //     helper.toast('WARNING','빈값으로 검색하실 수 없습니다.');
        //     return;
        // };
        if (!keyWord) {
            helper.toast('WARNING',$A.get("$Label.c.service_msg_validation_007"));
            return;

        } else if(keyWord.length < 3) {
            helper.toast('WARNING',$A.get("$Label.c.service_msg_validation_014"));
            return;
        }
        
        var action = component.get('c.machineInfo');
        component.set("v.isLoading", true);
        action.setParams({ machineName: keyWord });
        action.setCallback(this, function(response) {
            var status = response.getState();
            console.log("status", status);
            component.set("v.isLoading", false);
            if (status === "SUCCESS") {
                console.log('성공');
                let assetInfo = response.getReturnValue();
                component.set("v.isLoading", false);
                if (!assetInfo || assetInfo.length === 0) {
                    // 검색 결과가 없을 때 Toast 메시지 표시
                    helper.toast('WARNING', 'No matching data found');
                    component.set('v.modelList', []); // 검색 결과 비우기
                    component.set("v.isLoading", false);
                } else {
                    var lists = assetInfo.map(function(at) {
                        return { label: at.Name, value: at.ModelCode__c }
                    });
                    console.log('searchList : ' + JSON.stringify(lists, null, 4));
                    component.set('v.modelList', lists);
                    component.set("v.isLoading", false);
                }
            } else {
                console.log('실패...');
                helper.toast('ERROR', 'An error occurred while fetching data. Please try again.');
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    // 장비번호 찾기
    searchEquipment: function(component, event, helper) {
        var machineNo = component.get('v.machineNo');
        var equipmentNo = component.get('v.equipmentNo');
    
        console.log('before machineNo :: ' + machineNo);
        component.set("v.isLoading", true);
        
        // validation
        if (
            (machineNo && machineNo.trim().length >= 3) || 
            (equipmentNo && equipmentNo.trim().length >= 3)
        ) {
            if (
                machineNo && equipmentNo && 
                (machineNo.trim().length < 3 || equipmentNo.trim().length < 3)
            ) {
                helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_014"));
                component.set("v.isLoading", false);
                return;
            }
        } else {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_014"));
            component.set("v.isLoading", false);
            return;
        }
        
        console.log('after machineNo :: ' + machineNo);
    
        var action = component.get('c.equipmentInfo');
        action.setParams({
            mn: machineNo,
            en: equipmentNo
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            component.set("v.isLoading", false);
            if (status === 'SUCCESS') {
                console.log('장비번호 모달 성공');
                var result = response.getReturnValue();
                component.set("v.isLoading", false);
                if (!result || result.length === 0) {
                    // 검색 결과가 없을 때 Toast 메시지 표시
                    helper.toast('WARNING', 'No matching data found');
                    component.set('v.serialList', []); // 검색 결과 비우기
                    component.set("v.isLoading", false);
                } else {
                    var lists = result.map(function(at) {
                        return { label: at.Name, value: at.Id, machineName: at.MachineName__c };
                    });
                    console.log('lists :: ' + JSON.stringify(lists, null, 4));
                    component.set('v.serialList', lists);
                    component.set("v.isLoading", false);
                }
            } else {
                console.log('실패...');
                helper.toast('ERROR', 'An error occurred while fetching data. Please try again.');
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    rowClick: function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
        console.log('index:', index);

        var modelList = component.get('v.modelList');
        var model = modelList[index];
        console.log('model::', JSON.stringify(model, null, 4));

        let message = Object.assign({}, model, {"parentCmp":component.get('v.parentCmp')});

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : "MachineModal",
            "actionName" : "Close",
            "message" : message
        });
        cmpEvent.fire();
        helper.closeModelModal(component);
    },

    selectRow : function(component, event, helper) {
        var index = event.currentTarget.dataset.record;
        console.log('IDX : ' + index);

        var serialList = component.get('v.serialList');
        var serial = serialList[index];
        console.log('serial:: ' + JSON.stringify(serial, null, 4));

        let message = Object.assign({}, serial, {"parentCmp":component.get('v.parentCmp')});

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : "SerialModal",
            "actionName" : "Close",
            "message" : message
        });
        cmpEvent.fire();
        helper.closedModal(component);
    },

    // 기종 모달 취소
    modelModalCancel: function (component, event, helper) {
        helper.closeModelModal(component);
    },

    // 장비번호 모달 취소
    serialModalCancel: function (component, event, helper) {
        helper.closedModal(component);
    },

    handleKeyPress: function (component, event, helper) {
        let keyCode = event.which || event.keyCode;
        try {
            if (keyCode === 13) {  
                let activeElement = document.activeElement;
                
                if (component.find("inputModelValue") && 
                    component.find("inputModelValue").getElement() === activeElement) {
                    $A.enqueueAction(component.get('c.searchMachine'));
                } else if (component.find("inputMachineNoValue") && 
                    component.find("inputMachineNoValue").getElement() === activeElement) {
                    $A.enqueueAction(component.get('c.searchEquipment'));
                }
            }
        } catch (error) {
            console.error("Error in handleKeyPress:", error);
        }
    }

})