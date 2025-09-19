/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-02
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-04-02   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    init : function(component, event, helper) {
        const today = new Date();
        const year = today.getFullYear(); 
        const month = String(today.getMonth() + 1).padStart(2, '0');;
        const day = String(today.getDate()).padStart(2, '0');
        const formatedDate = year+'-'+month+'-'+day;
        component.set('v.startDate', formatedDate);
        component.set('v.endDate', formatedDate);

        var action = component.get('c.getSettingInfo');
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result.isSuccess){
                component.set('v.workcenterOptions', result.workcenter);
                component.set('v.branchOptions', result.branch);
                component.set('v.statusOptions', result.status);
                component.set('v.isLoading', false);
            }else{
                component.set('v.isLoading', false);
            }  
        });
        $A.enqueueAction(action);
    },
    
    handleSearch : function(component, event, helper) {
        if(
            ($A.util.isEmpty(component.get('v.startDate')) && (!$A.util.isEmpty(component.get('v.endDate'))))
            || ($A.util.isEmpty(component.get('v.endDate')) && (!$A.util.isEmpty(component.get('v.startDate'))))
        ){
            helper.toast(component, 'ERROR', '접수일자를 정확히 입력해주세요.', 'Error');
            return;
        }

        if(
            ($A.util.isEmpty(component.get('v.completeStartDate')) && (!$A.util.isEmpty(component.get('v.completeEndDate'))))
            || ($A.util.isEmpty(component.get('v.completeEndDate')) && (!$A.util.isEmpty(component.get('v.completeStartDate'))))
        ){
            helper.toast(component, 'ERROR', '완료일자를 정확히 입력해주세요.', 'Error');
            return;
        }

        if(
            ($A.util.isEmpty(component.get('v.confirmStartDate')) && (!$A.util.isEmpty(component.get('v.confirmEndDate'))))
            || ($A.util.isEmpty(component.get('v.confirmEndDate')) && (!$A.util.isEmpty(component.get('v.confirmStartDate'))))
        ){
            helper.toast(component, 'ERROR', '확정일자를 정확히 입력해주세요.', 'Error');
            return;
        }

        if(
            $A.util.isEmpty(component.get('v.startDate')) 
            && $A.util.isEmpty(component.get('v.endDate'))
            && $A.util.isEmpty(component.get('v.completeStartDate')) 
            && $A.util.isEmpty(component.get('v.completeEndDate'))
        ){
            if(!$A.util.isEmpty(component.get('v.customerCode'))){
                var customerCode = component.get('v.customerCode').trim();
                if(customerCode.length < 7){
                    helper.toast(component, 'ERROR', '고객코드를 정확히 입력해주세요.', 'Error');
                    return;
                }
            }else if(!$A.util.isEmpty(component.get('v.modelValue'))){
                var equipmentNumber = component.get('v.modelValue').trim();
                if(equipmentNumber.length < 13){
                    helper.toast(component, 'ERROR', '장비번호를 정확히 입력해주세요.', 'Error');
                    return;
                }
            }else if(!$A.util.isEmpty(component.get('v.orderNumber'))){
                var orderNumber = component.get('v.orderNumber').trim();
                if(orderNumber.length < 9){
                    helper.toast(component, 'ERROR', '오더번호를 정확히 입력해주세요.', 'Error');
                    return;
                }
            }else if(!$A.util.isEmpty(component.get('v.branch'))){
                var branch = component.get('v.branch').trim();
                if(branch.length < 9){
                    helper.toast(component, 'ERROR', '관할지사를 정확히 입력해주세요.', 'Error');
                    return;
                }
            }else if(!$A.util.isEmpty(component.get('v.account'))){
                var account = component.get('v.account').trim();
                if(account.length < 9){
                    helper.toast(component, 'ERROR', '업체명을을 정확히 입력해주세요.', 'Error');
                    return;
                }
            }else if(!$A.util.isEmpty(component.get('v.workCenter'))){
                var workCenter = component.get('v.workCenter').trim();
                if(workCenter.length < 9){
                    helper.toast(component, 'ERROR', '서비스 W/C를 정확히 입력해주세요.', 'Error');
                    return;
                }
            }else if(!$A.util.isEmpty(component.get('v.status'))){
                var status = component.get('v.status').trim();
                if(status.length < 9){
                    helper.toast(component, 'ERROR', '진행상태를 정확히 입력해주세요.', 'Error');
                    return;
                }
            }else if(!$A.util.isEmpty(component.get('v.customerCode'))){
                var customerCode = component.get('v.customerCode').trim();
                if(customerCode.length < 9){
                    helper.toast(component, 'ERROR', '고객번호를 정확히 입력해주세요.', 'Error');
                    return;
                }
            } else{
                helper.toast(component, 'ERROR', '접수일시 또는 완료일시를 입력해주세요.', 'Error');
                return;
            }
        }

        if(!$A.util.isEmpty(component.get('v.startDate')) && (!$A.util.isEmpty(component.get('v.endDate')))){
            var startDate = new Date(component.get('v.startDate'));
            var endDate = new Date(component.get('v.endDate'));
            console.log('검색 달수 간격 startDate',endDate.getMonth() - startDate.getMonth());
            
            if(endDate < startDate){
                helper.toast(component, 'ERROR', '접수일자를 정확히 입력해주세요.', 'Error');
                return;
            }

            var sixMonthsLater = new Date(startDate);
            sixMonthsLater.setMonth(sixMonthsLater.getMonth() + 6);

            if (endDate > sixMonthsLater) {
                var is6monthLimit = true;
                
                if(!$A.util.isEmpty(component.get('v.modelValue'))){
                    var equipmentNumber = component.get('v.modelValue').trim();
                    if(equipmentNumber.length >= 13){
                        is6monthLimit = false;
                    }
                }

                if(!$A.util.isEmpty(component.get('v.account'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.modelTypeNameValue'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.orderNumber'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.customerCode'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.branch'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.workCenter'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.status'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.customerCode'))){
                    is6monthLimit = false;
                }

                if(is6monthLimit){
                    helper.toast(component, 'ERROR', '6개월의 정보만 조회할 수 있습니다.', 'Error');
                    return;
                }
            }             
        }
        
        if(!$A.util.isEmpty(component.get('v.completeStartDate')) && (!$A.util.isEmpty(component.get('v.completeEndDate')))){
            var completeStartDate = new Date(component.get('v.completeStartDate'));
            var completeEndDate = new Date(component.get('v.completeEndDate'));
            console.log('검색 달수 간격 completeStartDate',completeEndDate.getMonth() - completeStartDate.getMonth());
            
            if(completeEndDate < completeStartDate){
                helper.toast(component, 'ERROR', '완료일자를 정확히 입력해주세요.', 'Error');
                return;
            }

            var sixMonthsLater = new Date(completeStartDate);
            sixMonthsLater.setMonth(sixMonthsLater.getMonth() + 6);
            console.log('sixMonthsLater', sixMonthsLater);

            if (completeEndDate > sixMonthsLater) {
                var is6monthLimit = true;
                
                if(!$A.util.isEmpty(component.get('v.modelValue'))){
                    var equipmentNumber = component.get('v.modelValue').trim();
                    if(equipmentNumber.length >= 13){
                        is6monthLimit = false;
                    }
                }

                if(!$A.util.isEmpty(component.get('v.account'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.modelTypeNameValue'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.orderNumber'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.customerCode'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.branch'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.workCenter'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.status'))){
                    is6monthLimit = false;
                }

                if(!$A.util.isEmpty(component.get('v.customerCode'))){
                    is6monthLimit = false;
                }

                if(is6monthLimit){
                    helper.toast(component, 'ERROR', '6개월의 정보만 조회할 수 있습니다.', 'Error');
                    return;
                }
            } 
        }
        
        var data = {
            startDate : component.get('v.startDate'),
            endDate : component.get('v.endDate'),
            completeStartDate : component.get('v.completeStartDate'),
            completeEndDate : component.get('v.completeEndDate'),
            orderNumber : component.get('v.orderNumber'),
            workcenter : component.get('v.workCenter'),
            branch : component.get('v.branch'),
            status : component.get('v.status'),
            account : component.get('v.account'),
            modelValue : component.get('v.modelValue'),
            modelTypeNameValue : component.get('v.modelTypeNameValue'),
            checkStandard : component.get('v.isCheckStandard'),
            customerCode : component.get('v.customerCode'),
            confirmStartDate : component.get('v.confirmStartDate'),
            confirmEndDate : component.get('v.confirmEndDate'),
        };

        var jsonData = JSON.stringify(data);

        component.set('v.isLoading', true);
        //최대 검색 기간은 6개월
        var action = component.get('c.getServiceHistoryList');
        action.setParams({
            conditionData : jsonData
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result.isSuccess){
                component.set('v.historyList', result.returnList);
                component.set('v.isLoading', false);
            }else{
                helper.toast(component, 'ERROR', '데이터를 가져오는데 문제가 발생했습니다.', 'Error');
                component.set('v.isLoading', false);
            }            
        });
        $A.enqueueAction(action);
    },

    // 기종/호기 검색 Modal - 열기
    openModal : function(component, event, helper){
        component.set('v.searchModel', true);
    },

    // 기종 Modal - 열기
    openTypeModal : function(component, event, helper){
        var newArr = [];
        component.set('v.modelList', newArr);
        component.set('v.searchTypeModel', true);
        component.set('v.modelTypeSearchVal', '');
    },
    
    // 기종/호기 검색 Modal - 닫기
    closeModal: function (component, event, helper) {
        component.set('v.searchModel', false);
    },

    // 기종 Modal - 닫기
    closeTypeModal: function (component, event, helper) {
        component.set('v.searchTypeModel', false);
    },

    handleMTEnterKey : function(component, event, helper) {
        if (event.which === 13) {
            var modelTypeSearchVal = component.get('v.modelTypeSearchVal');

            if($A.util.isEmpty(modelTypeSearchVal) || modelTypeSearchVal.length < 3){
                helper.toast(component, 'ERROR', '3글자 이상 입력해주세요.', 'Error');
                return;
            }

            component.set('v.isModalLoading', true);

            var action = component.get('c.getTypeList');
            action.setParams({
                modelTypeSearchVal : modelTypeSearchVal
            });

            action.setCallback(this, function(response){
                var result = response.getReturnValue();

                if(result.isSuccess){
                    var modelList = result.returnList || [];
                    var selectedModels = component.get('v.selectedModelList') || [];

                    // 기존 선택한 것과 비교해서 isChecked 속성 추가
                    modelList.forEach(function(model){
                        model.isChecked = selectedModels.some(function(selected){
                            return selected.Id === model.Id;
                        });
                    });

                    component.set('v.modelList', modelList);                    
                    component.set('v.isModalLoading', false);
                }else{
                    helper.toast(component, 'ERROR', '데이터를 가져오는데 문제가 발생했습니다.', 'Error');
                    component.set('v.isModalLoading', false);
                }
            });

            $A.enqueueAction(action);
        }
    },

    handleMEnterKey : function(component, event, helper) {
        if (event.which === 13) {
            var modelSearchVal = component.get('v.modelSearchVal');

            if($A.util.isEmpty(modelSearchVal) || modelSearchVal.length < 3){
                helper.toast(component, 'ERROR', '3글자 이상 입력해주세요.', 'Error');
                return;
            }

            component.set('v.isModalLoading', true);
            var action = component.get('c.getEquipmentList');
            action.setParams({
                modelSearchVal : modelSearchVal
            });

            action.setCallback(this, function(response){
                var result = response.getReturnValue();

                if(result.isSuccess){
                    var equipList = result.returnList || [];
                    var selectedEquipList = component.get('v.selectedEquipList') || [];
                    // 기존 선택한 것과 비교해서 isChecked 추가
                    equipList.forEach(function(equip){
                        equip.isChecked = selectedEquipList.some(function(selected){
                            return selected === equip.Name;
                        });
                    });

                    component.set('v.equipList', equipList);
                    component.set('v.isModalLoading', false);
                } else {
                    helper.toast(component, 'ERROR', '데이터를 가져오는데 문제가 발생했습니다.', 'Error');
                    component.set('v.isModalLoading', false);
                }
            });

            $A.enqueueAction(action);
        }
    },

    // 장비 번호
    modelSearch : function (component, event, helper) {
        var modelSearchVal = component.get('v.modelSearchVal');

        if($A.util.isEmpty(modelSearchVal) || modelSearchVal.length < 3){
            helper.toast(component, 'ERROR', '3글자 이상 입력해주세요.', 'Error');
            return;
        }

        component.set('v.isModalLoading', true);
        var action = component.get('c.getEquipmentList');
        action.setParams({
            modelSearchVal : modelSearchVal
        });

        action.setCallback(this, function(response){
            var result = response.getReturnValue();

            if(result.isSuccess){
                var equipList = result.returnList || [];
                var selectedEquipList = component.get('v.selectedEquipList') || [];
                // 기존 선택한 것과 비교해서 isChecked 추가
                equipList.forEach(function(equip){
                    
                    equip.isChecked = selectedEquipList.some(function(selected){
                        return selected === equip.Name;
                    });
                });

                component.set('v.equipList', equipList);
                component.set('v.isModalLoading', false);
            } else {
                helper.toast(component, 'ERROR', '데이터를 가져오는데 문제가 발생했습니다.', 'Error');
                component.set('v.isModalLoading', false);
            }
        });

        $A.enqueueAction(action);
    },

    modelTypeSearch : function (component, event, helper) {
        var modelTypeSearchVal = component.get('v.modelTypeSearchVal');

        if($A.util.isEmpty(modelTypeSearchVal) || modelTypeSearchVal.length < 3){
            helper.toast(component, 'ERROR', '3글자 이상 입력해주세요.', 'Error');
            return;
        }

        component.set('v.isModalLoading', true);

        var action = component.get('c.getTypeList');
        action.setParams({
            modelTypeSearchVal : modelTypeSearchVal
        });

        action.setCallback(this, function(response){
            var result = response.getReturnValue();

            if(result.isSuccess){
                var modelList = result.returnList || [];
                var selectedModels = component.get('v.selectedModelList') || [];

                // 기존 선택한 것과 비교해서 isChecked 속성 추가
                modelList.forEach(function(model){
                    model.isChecked = selectedModels.some(function(selected){
                        return selected.Id === model.Id;
                    });
                });

                component.set('v.modelList', modelList);               
                component.set('v.isModalLoading', false);
            }else{
                helper.toast(component, 'ERROR', '데이터를 가져오는데 문제가 발생했습니다.', 'Error');
                component.set('v.isModalLoading', false);
            }
        });

        $A.enqueueAction(action);
    },


    // hadleModel : function (component, event, helper) {
    //     var isChecked = event.getParam('checked');
    //     if(isChecked){
    //         component.set('v.selectedModel', event.target.name);
    //         var chekcbox = document.querySelectorAll('.equipbox');
    //         [...chekcbox].forEach(ch => {
    //             if(ch !== event.target){
    //                 ch.checked = false;
    //             }
    //         });
    //     }else{
    //         component.set('v.selectedModel', '');
    //     }
    // },

    // 체크박스 선택 핸들러
    hadleEquipModel : function(component, event, helper) {
        var selectedEquipList = component.get('v.selectedEquipList');
        var checkbox = event.getSource();
        var equipName = checkbox.get("v.name");

        if (checkbox.get("v.checked")) {
            // 추가
            if (!selectedEquipList.includes(equipName)) {
                selectedEquipList.push(equipName);
            }
        } else {
            // 제거
            selectedEquipList = selectedEquipList.filter(function(item){
                return item !== equipName;
            });
        }

        component.set('v.selectedEquipList', selectedEquipList);
    },

    removeSelectedEquip : function(component, event, helper) {
        var equipNameToRemove = event.getSource().get("v.value");
        var selectedEquipList = component.get("v.selectedEquipList");

        selectedEquipList = selectedEquipList.filter(function(item){
            return item !== equipNameToRemove;
        });

        component.set("v.selectedEquipList", selectedEquipList);

        // 체크박스도 uncheck 처리
        var checkboxes = document.getElementsByClassName("equipbox");
        Array.from(checkboxes).forEach(function(checkbox){
            if (checkbox.name === equipNameToRemove) {
                checkbox.checked = false;
            }
        });
    },

    // 체크박스 변경시 실행
    hadleModel : function(component, event, helper) {
        let selectedModels = component.get("v.selectedModelList") || [];
        let modelList = component.get("v.modelList");

        let checkbox = event.getSource();
        let index = event.getSource().getElement().closest("tr").dataset.record;
        let selected = modelList[index];

        if (checkbox.get("v.checked")) {
            // 중복 체크 없이 추가
            if (!selectedModels.find(m => m.Id === selected.Id)) {
                selectedModels.push(selected);
            }
        } else {
            // 체크 해제시 제거
            selectedModels = selectedModels.filter(m => m.Id !== selected.Id);
        }

        component.set("v.selectedModelList", selectedModels);
    },
    // X 버튼 클릭 시
    removeSelectedModel : function(component, event, helper) {
        const idToRemove = event.currentTarget.getAttribute("data-id");
        let selectedModels = component.get("v.selectedModelList");

        selectedModels = selectedModels.filter(m => m.Id !== idToRemove);
        component.set("v.selectedModelList", selectedModels);

        // 체크박스 상태 업데이트
        let modelList = component.get("v.modelList");
        modelList.forEach(model => {
            if (model.Id === idToRemove) {
                model.isChecked = false;
            }
        });
        component.set("v.modelList", modelList);
    },

    selectModel : function (component, event, helper) {
        var selectedEquipList = component.get('v.selectedEquipList') || [];
        var selectedNames = selectedEquipList.join(", ");

        component.set('v.modelValue', selectedNames);
        component.set('v.equipList', []);
        component.set('v.modelSearchVal', '');
        component.set('v.searchModel', false);
    },

    // 기종 Modal
    selectTypeModel : function (component, event, helper) {
        let selectedModels = component.get("v.selectedModelList");
        let modelCodes = selectedModels.map(m => m.ModelCode__c).join(", ");
        let selectedNames = selectedModels.map(m => m.Name).join(", ");
        
        component.set('v.modelTypeValue', modelCodes);
        component.set('v.modelTypeNameValue', selectedNames);
        component.set('v.searchTypeModel', false);

    },

    handleScroll : function(component, event, helper) {          
        var table2 = event.target; 
        var scrollY = table2.scrollTop; 
        var table1 = component.find('leftTableDiv').getElement(); 
        table1.scrollTo({top:scrollY, left:0, behavior:'auto'}); 
    },
    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Loaded');
    },

    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function(component, event, helper) {
        try {
            // var searchDitance = component.get('v.searchDitance');
            const historyList = component.get('v.historyList');
            
            if (historyList.length > 0) {
                component.set('v.isLoading', true);                

                var date = new Date();
                var year = date.getFullYear();
                var month = date.getMonth() + 1;
                var day = date.getDate();
                var yobi = date.getDay();
                var hour = date.getHours();
                var minute = date.getMinutes();
                var second = String(date.getSeconds()).padStart(2, '0');
                var half = '오전';

                switch (yobi) {
                    case 0:
                        yobi = '일';
                        break;
                    case 1:
                        yobi = '월';
                        break;
                        case 2:
                        yobi = '화';
                        break;
                    case 3:
                        yobi = '수';
                        break;
                    case 4:
                        yobi = '목';
                        break;
                    case 5:
                        yobi = '금';
                        break;
                    case 6:
                        yobi = '토';
                        break;
                }

                if (hour > 12) {
                    hour = hour - 12;
                    half = '오후';
                }

                var printDate = '출력일 (' + year + '년 ' + month + '월 ' + day + '일 ' + yobi + '요일' + ' ' + half + ' ' + hour + ':' + minute + ':' + second + ')';

                const workbook = new ExcelJS.Workbook();
                const worksheet = workbook.addWorksheet('sheet1');

                const headerStyle = {
                    font: {
                        name: '돋움',
                        size: 9,
                        color: { argb: "2f435c" }
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "dbe2ea" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: {
                        top: { style: 'thin', color: { argb: '657584' } },
                        bottom: { style: 'thin', color: { argb: '657584' } },
                        left: { style: 'thin', color: { argb: '657584' } },
                        right: { style: 'thin', color: { argb: '657584' } }
                    }
                };

                const colStyles = {
                    font: {
                        name: '돋움',
                        size: 9,
                        color: { argb: "2f435c" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };
    
                const locationStyles = {
                    font: {
                        name: '돋움',
                        size: 9,
                        color: { argb: "2f435c" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "left"
                    },
                    border: headerStyle.border
                };
    
                const nameStyles = {
                    font: {
                        name: '돋움',
                        color: { argb: "0a0aff" },
                        size: 9
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };    
                
                const statusStyles = {
                    font: {
                        name: '돋움',
                        color: { argb: "2f435c" },
                        size: 9
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "ffff80" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };

                const mergeStyle = {
                    font: {
                        name: '맑은 고딕',
                        color: { argb: "000000" },
                        size: 15,
                        bold: false
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "F3F3F3" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    }
                };

                const finishMergeStyle = {
                    font: {
                        name: '맑은 고딕',
                        color: { argb: "646464" },
                        size: 10,
                        bold: false
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "dcdcdc" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "right"
                    }
                };
        
        
                // 1행 빈줄
                // worksheet.addRow([]);
    
                // // 제목 추가
                // worksheet.addRow(['하자접수이력관리']);
        
                // // 3행 빈줄
                // worksheet.addRow([]);

                // 헤더 추가
                const header = [
                    '오더번호',
                    'PM Activity',
                    '관할지사',
                    '서비스 W/C',
                    '서비스요원(명)',
                    '기종',
                    '장비번호',
                    '출하일자',
                    '업체명',
                    '주소',
                    '전화번호',
                    '접수유형(대)',
                    '접수유형(중)',
                    '접수내용',
                    '고장부위(대)',
                    '고장부위(소)',
                    '고장현상',
                    'Ticket 접수일자',
                    'Ticket 접수시간',
                    '출발예정일시',
                    'Service Order 생성일자',
                    'Service Order 생성시간',
                    '고객약속일자',
                    '고객약속시간',
                    '출발일자(Mobile)',
                    '출발시간(Mobile)',
                    '작업완료일자(Mobile)',
                    '작업완료시간(Mobile)',
                    '출발일자(Service Report)',
                    '출발시간(Service Report)',
                    '도착일자(Service Report)',
                    '도착시간(Service Report)',
                    '작업완료일자(Service Report)',
                    '작업완료시간(Service Report)',
                    '상담원',
                    '조치내역',
                    '2시간내 출동',
                    '24시간내 처리',
                    '작업 M/H',
                    '표준공수',
                    '표준인원',
                    '표준작업항목',
                    '청구여부',
                    '표준시간초과사유',
                    '진행상태',
                    '공동작업자',
                    '포털 확정일자',
                    '포털 확정시간'
                ];
                const headerRow = worksheet.addRow(header);
    
                headerRow.eachCell((cell) => {
                    cell.style = headerStyle;
                });
    
                // 데이터 추가
                historyList.forEach(data => {
                    const dataRow = worksheet.addRow([
                        data.orderNum,
                        data.pmType,
                        data.branch,
                        data.workcenter,
                        data.resourceName,
                        data.model,
                        data.serialNum,
                        data.shippingDate,
                        data.account,
                        data.address,
                        data.phone,
                        data.ticketTypeMajor,
                        data.ticketTypeMiddle,
                        data.receptionDetail,
                        data.failureAreaMajor,
                        data.failureAreaMiddle,
                        data.failurePhenomenon,
                        data.receptionDate,
                        data.receptionTime,
                        data.scheduledDispatchTime,
                        data.orderCreatedDate,
                        data.orderCreatedTime,
                        data.timeAgreedOnSiteDate, //고객약속일자
                        data.timeAgreedOnSiteTime, //고객약속시간
                        data.mobile_departureDate,
                        data.mobile_departureTime,
                        data.mobile_completeDate,
                        data.mobile_completeTime,
                        data.serviceReport_departureDate,
                        data.serviceReport_departureTime,
                        data.serviceReport_arrivalDate,
                        data.serviceReport_arrivalTime,
                        data.serviceReport_completeDate,
                        data.serviceReport_completeTime,
                        data.receptionist,
                        data.inspectionDetail,
                        data.in2Hour,
                        data.in24Hour,
                        data.totalMH,
                        data.standardMH,
                        data.standardCnt,
                        data.standardWork,
                        data.isBilled,
                        data.overReason,
                        data.status,
                        data.collaborator,
                        data.portal_completetDate,
                        data.portal_completetTime
                    ]);

                    // 총 43열
                    for (let i = 1; i < 46; i++) {
                        if (i == 10) {
                            dataRow.getCell(i).style = locationStyles;
                        } else if (i == 14) {
                            dataRow.getCell(i).style = locationStyles;
                        } else if (i == 33) {
                            dataRow.getCell(i).style = locationStyles;
                        } else if (i == 39) {
                            dataRow.getCell(i).style = locationStyles;
                        } else if (i == 41) {
                            dataRow.getCell(i).style = locationStyles;
                        } else {
                            dataRow.getCell(i).style = colStyles;
                        }
                    }
                    // 10, 14, 33, 39, 41
                });

                worksheet.addRow([]);
                worksheet.addRow([
                    printDate
                ]);
    
                // 셀 병합
                var finishRowIndex = historyList.length + 3;
                var startMerge = 'A' + finishRowIndex;
                var finishMerge = 'A' + finishRowIndex + ':AQ' + finishRowIndex;

                // worksheet.mergeCells('A2:H2');
                worksheet.mergeCells(finishMerge);
                // const mergedCell = worksheet.getCell('A2');
                const finishMergedCell = worksheet.getCell(startMerge);
                // mergedCell.style = mergeStyle;
                finishMergedCell.style = finishMergeStyle;
        
                // 행 높이 설정
                // worksheet.getRow(2).height = 40; // 제목 행
                // worksheet.getRow(4).height = 20;
                for (let i = 1; i < historyList.length + 2; i++) {
                    worksheet.getRow(i).height = 17; // 데이터 행
                }
                worksheet.getRow(historyList.length + 3).height = 20; // 마지막 날짜

        
                // 열 너비 설정 10, 14, 33, 39, 41
                for (let i = 1; i < 46; i++) {
                    if (i == 10 || i == 14 || i == 33 || i == 39 || i == 41) {
                        worksheet.getColumn(i).width = 50;
                    } else {
                        worksheet.getColumn(i).width = 20;
                    }
                }
                // worksheet.getColumn(2).width = 18;
                // worksheet.getColumn(3).width = 12;
                // worksheet.getColumn(4).width = 30;
                // worksheet.getColumn(5).width = 10;
                // worksheet.getColumn(6).width = 15;
                // worksheet.getColumn(7).width = 12;
                // worksheet.getColumn(8).width = 22;

                // 고정 행 설정
                worksheet.views = [
                    { state: 'frozen', xSplit: 1, ySplit: 1, topLeftCell: 'B2', activeCell: 'B2' }
                ];

                var localDate = new Date();
                // 로컬 시간에 맞는 년, 월, 일 추출
                var year = localDate.getFullYear();
                var month = String(localDate.getMonth() + 1).padStart(2, '0');
                var day = String(localDate.getDate()).padStart(2, '0'); 

                var dateString = year + month + day;
        
                // 파일 생성
                workbook.xlsx.writeBuffer().then((buffer) => {
                    // const blob = new Blob([buffer], { type: 'application/octet-stream' });
                    // FileSaver.saveAs(blob, 'example.xlsx');
                    const blob = new Blob([buffer], { type: 'application/octet-stream' });
                    const link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = dateString + ' 하자접수이력관리.xlsx';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    component.set('v.isLoading', false);
                });
            }
        } catch (error) {
            console.log('에러 내역 알려주세요 ::: ' + error);
            console.log('에러 내역 알려주세요 ::: ' + error.message);
            component.set('v.isLoading', false);
        }

    },
})