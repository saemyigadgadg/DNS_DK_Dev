/**
 * @description       : 대상장비등록 모달창
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2024-07-22
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-22-2024   junyeong.choi@sbtglobal   Initial Version
**/
({
    doInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.checkCommonParts');
        action.setParams(
            {
                recordId: recordId
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result::', JSON.stringify(result));
                if (result.registerCheck == true) {
                    helper.showMyToast('ERROR', $A.get("$Label.c.DNS_CAM_T_COMMONPARTS"));
                    $A.get("e.force:closeQuickAction").fire();
                    return;
                }
                if (result.DNSArecordType) {
                    component.set("v.maintPlant", '414S');
                    component.set("v.planningPlant", '440');
                    component.set("v.DNSARecordType", true);
                } else {
                    component.set("v.maintPlant", "184S");
                    component.set("v.planningPlant", "180");
                }
            }
        });
        $A.enqueueAction(action);
    },

    // 대상 장비 검색
    searchEquipments: function (component, event, helper) {
        helper.searchData(component);
    },

    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    // Checkbox 선택/해제
    handleCheckboxChange: function (component, event, helper) {
        console.log('check');
        var checkbox = component.find('checkbox');
        var targetList = component.get('v.targetList');

        // checkbox 가 단일 오브젝트일때 예외처리
        if (!Array.isArray(checkbox)) {
            checkbox = [checkbox];
            console.log('checkbox', JSON.stringify(checkbox.length));
        }
        var selectedEquipment = [];
        for (var i = 0; i < checkbox.length; i++) {
            if (checkbox[i].get("v.checked")) {
                selectedEquipment.push(targetList[i]);
            }
        }
        console.log('selectedEquipment::', JSON.stringify(selectedEquipment));
        component.set('v.selectedEquipment', selectedEquipment);
    },

    // handleCheckboxChange: function (component, event, helper) {
    //     console.log('check');
    //     var checkbox = component.find('checkbox');
    //     var targetList = component.get('v.targetList');
    //     var rowIndex = event.getSource().get('v.accesskey');
    
    //     // checkbox가 단일 오브젝트일 때 예외처리
    //     if (!Array.isArray(checkbox)) {
    //         checkbox = [checkbox];
    //         console.log('checkbox', JSON.stringify(checkbox.length));
    //     }
    
    //     var selectedEquipment = component.get('v.selectedEquipment') || [];
    //     for (var i = 0; i < checkbox.length; i++) {
    //         var equipment = targetList[i];
    //         if (checkbox[i].get("v.checked")) {
    //             if (!selectedEquipment.some(item => item.Id === equipment.Id)) {
    //                 selectedEquipment.push(equipment); // 새로 추가
    //             }
    //         } else {
    //             selectedEquipment = selectedEquipment.filter(item => item.Id !== equipment.Id); // 선택 해제
    //         }
    //     }
    //     console.log('selectedEquipment::', JSON.stringify(selectedEquipment));
    //     component.set('v.selectedEquipment', selectedEquipment);
    // },
    
    handleInputFieldChange: function (component, event, helper) {
        var value = event.getSource().get("v.value");
        console.log('value:', value);
        var rowIndex = event.getSource().get('v.accesskey');
        console.log('rowIndex:', rowIndex);
        var targetList = component.get('v.targetList');

        // 빈 배열([])이거나 값이 비었으면 null로 설정
        if ($A.util.isEmpty(value) || (Array.isArray(value) && value.length == 0)) {
            value = null;
        }

        targetList[rowIndex].Manager__c = value;
        var selectedEquipment = component.get('v.selectedEquipment');

        if (selectedEquipment < 1) {
            console.log('Equipment');
        } else {
            // 중복 여부를 체크하여 중복되지 않는 경우에만 추가
            var exists = selectedEquipment.some(function (equipment) {
                return equipment.Id == targetList[rowIndex].Id;
            });

            if (!exists) {
                selectedEquipment.push(targetList[rowIndex]);
            }

            console.log('selectedEquipment', JSON.stringify(selectedEquipment));
            component.set('v.selectedEquipment', selectedEquipment);
        }
    },

    // AssetId Lookup
    openAssetId: function (component, event, helper) {
        var recordId = event.currentTarget.getAttribute("data-recordid");
        console.log('recordId:', recordId);
        var url = '/lightning/r/Asset/' + recordId + '/view';
        window.open(url, '_blank');
    },

    // // AccountId Lookup
    // openAccountId: function (component, event, helper) {
    //     var recordId = event.currentTarget.getAttribute("data-recordid");
    //     console.log('recordId:', recordId);
    //     var url = '/lightning/r/Account/' + recordId + '/view';
    //     window.open(url, '_blank');
    // },

    // 대상장비 등록
    registerEquipment: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId', recordId);
        var selectedEquipment = component.get('v.selectedEquipment');
        var selectedData = [];
        if (selectedEquipment.length < 1) {
            helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_SELECTTARGETEQUIPMENT"));
        } else {
            component.set('v.isLoading', true);
            for (var i = 0; i < selectedEquipment.length; i++) {
                selectedData.push(
                    {
                        AssetId: selectedEquipment[i].AssetId,
                        Manager__c: selectedEquipment[i].Manager__c,
                        Email:selectedEquipment[i].Email
                    }
                )
            }
            console.log('selectedData', JSON.stringify(selectedData));
            var action = component.get('c.registerTargetEquipment');
            action.setParams(
                {
                    recordId: recordId,
                    selectedData: selectedData
                }
            );
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state:', state);
                if (state == 'SUCCESS') {
                    var result = response.getReturnValue();
                    if(result.isSuccess == true) {
                        helper.showMyToast('SUCCESS', selectedEquipment.length + $A.get("$Label.c.DNS_CAM_T_CREATETARGETEQUIPMENT"))
                        $A.get('e.force:refreshView').fire();
                        // $A.get("e.force:closeQuickAction").fire();
                    } else {
                        $A.createComponent("c:DN_ExistingTargetEquipmentModal",
                        {
                            selectedEquipment : selectedEquipment,
                            recordId : recordId
                        },
                        function (content, status, errorMessage) {
                            if (status == "SUCCESS") {
                                var container = component.find("ExistingTargetEquipmentModal");
                                container.set("v.body", content);
                            } else if (status == "INCOMPLETE") {
                                console.log("응답이 없습니다. 관리자에게 문의하세요.")
                            } else if (status == "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                        });
                    }
                } else {
                    // 오류 핸들링
                    var errors = response.getError();
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        console.log("Apex 에러: " + errors[0].message);
                    } else {
                        console.log("에러 발생");
                    }
                }
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }
    },

    // Account 검색 모달 열기
    accountSearchModal: function (component, event, helper) {
        component.set('v.searchAccount', true);
        // component.set('v.publicIsLoading', true);
        // var action = component.get('c.initAccountList');
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     console.log('state:', state);
        //     if (state == 'SUCCESS') {
        //         var result = response.getReturnValue();
        //         console.log('result', result);
        //         // var accountList = component.get('v.accountList');
        //         // accountList = result;
        //         component.set('v.accountList', result);
        //     } else {
        //         helper.showMyToast('Error', '목록을 불러오는데 문제가 발생하였습니다.');
        //     }
        //     component.set('v.publicIsLoading', false);
        // });
        // $A.enqueueAction(action);
    },

    // 기종 검색 모달 열기
    modelSearchModal: function (component, event, helper) {
        component.set('v.searchModel', true);
        // component.set('v.publicIsLoading', true);
        // var accountName = component.get('v.accountName');
        // console.log('accountName', accountName);

        // var action = component.get('c.initModelList');
        // action.setParams(
        //     {
        //         accountName: accountName
        //     }
        // );
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     console.log('state:', state);
        //     if (state == 'SUCCESS') {
        //         var result = response.getReturnValue();
        //         console.log('result', result);
        //         component.set('v.modelList', result);
        //     } else {
        //         helper.showMyToast('Error', '목록을 불러오는데 문제가 발생하였습니다.');
        //     }
        //     component.set('v.publicIsLoading', false);
        // });
        // $A.enqueueAction(action);
    },

    // 장비 검색 모달 열기
    assetSearchModal: function (component, event, helper) {
        component.set('v.searchAsset', true);
        component.set('v.publicIsLoading', true);
        var modelName = component.get('v.modelName');
        console.log('modelName', modelName);
        var action = component.get('c.initAssetList');
        action.setParams(
            {
                modelName: modelName
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set('v.assetList', result);
            } else {
                helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_CANTLOADINGLIST"));
            }
            component.set('v.publicIsLoading', false);
        });
        $A.enqueueAction(action);
    },

    // Account 검색 모달 닫기
    accountListCancel: function (component, event, helper) {
        component.set('v.searchAccount', false);
    },

    // Model 검색 모달 닫기
    modelListCancel: function (component, event, helper) {
        component.set('v.searchModel', false);
    },

    // Asset 검색 모달 닫기
    assetListCancel: function (component, event, helper) {
        component.set('v.searchAsset', false);
    },

    // Account 검색 모달 검색 실행
    accountSearch: function (component, event, helper) {
        component.set('v.publicIsLoading', true);
        var accountSearchVal = component.get('v.accountSearchVal');
        console.log('accountSearchVal', accountSearchVal);

        if(accountSearchVal == null || accountSearchVal.length <= 1) {
            helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_TWOLIMITENTER"));
            component.set('v.publicIsLoading', false);
            return;
        }
        
        var action = component.get('c.initAccountList');
        action.setParams(
            {
                accountSearchVal: accountSearchVal
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set('v.accountList', result);
            } else {
                helper.showMyToast('Error', 'Failed Search Data');
            }
            component.set('v.publicIsLoading', false);
        });
        $A.enqueueAction(action);
    },

    // model 검색 모달 검색 실행
    modelSearch: function (component, event, helper) {
        component.set('v.publicIsLoading', true);
        var modelSearchVal = component.get('v.modelSearchVal');
        console.log('기종 검색 실행');

        if(modelSearchVal == null || modelSearchVal.length <= 2) {
            helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_THREELIMITENTER"));
            component.set('v.publicIsLoading', false);
            return;
        }

        var action = component.get('c.initModelList');
        action.setParams(
            {
                modelSearchVal: modelSearchVal
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set('v.modelList', result);
            } else {
                helper.showMyToast('Error', 'Failed Search Data');
            }
            component.set('v.publicIsLoading', false);
        });
        $A.enqueueAction(action);
    },

    // 제조번호 검색 모달 검색 실행
    assetSearch: function (component, event, helper) {
        component.set('v.publicIsLoading', true);
        var assetSearchVal = component.get('v.assetSearchVal');
        console.log('제조번호 검색 실행');

        if(assetSearchVal == null || assetSearchVal.length <= 3) {
            helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_FOURLIMITENTER"));
            component.set('v.publicIsLoading', false);
            return;
        }

        var action = component.get('c.searchAssetList');
        action.setParams(
            {
                assetSearchVal: assetSearchVal,
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set('v.assetList', result);
            } else {
                helper.showMyToast('Error', 'Failed Search Data');
            }
            component.set('v.publicIsLoading', false);
        });
        $A.enqueueAction(action);
    },

    // Account Row 선택
    inputAccount: function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var accountList = component.get('v.accountList');
        component.set('v.accountName', accountList[index].AccountId);
        component.set('v.searchAccount', false);
    },

    // Account Row 선택
    inputModel: function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var modelList = component.get('v.modelList');
        component.set('v.modelName', modelList[index].Model);
        component.set('v.searchModel', false);
    },

    // Asset Row 선택
    inputAsset: function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var assetList = component.get('v.assetList');
        component.set('v.assetName', assetList[index].Name);
        component.set('v.searchAsset', false);
    },


})