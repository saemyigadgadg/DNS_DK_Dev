/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-12-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    // init 
    doInit : function(component, event, helper) {
        var baseUrl = window.location.origin;
        component.set("v.baseUrl", baseUrl);     
        
        // 스탠다드 파일 업로드 기능 클릭 시 파일의 타입을 구분하기 위해 윈도우 클릭 이벤트 발생
        const onClick = (event) => {
            if(event.target.name == 'fileUpload') {
                console.log(event.target.id, ' <> === 파일첨부 타입');
                console.log(event.target.name,  ' < ==== 파일첨부');
                // 파일타입이 report인 경우만 값 넣는 형태로 구성, 추후 변동가능성 있음
                if(event.target.id == 'report') {
                    component.set("v.fileType", event.target.id);
                } else {
                    component.set("v.fileType", '');
                }
            }
        }
        window.addEventListener('click', onClick);
        $A.enqueueAction(component.get('c.handleFileList'));
    },

    // value 값에 따라 맞는 modal open
    openModal: function (component, event, helper) {
        const value = event.getSource().get("v.value");
        let serviceData = component.get("v.serviceData").serviceReportInfo;
        let workOrderResultData = component.get("v.workOrderResultData") || {};

        const selectedBrokenArea = workOrderResultData.selectedBrokenArea || {};
        const selectedPhenomenon = workOrderResultData.selectedPhenomenon || {};
        
        const modalMap = {
            "brokenAreaSearch": {
                modal: "v.brokenAreaModal",
                apexMethod: "getFailureAreaMajor",
                paramKey: "objectType", 
                paramValue: serviceData.objectType,
                targetList: "v.majorOptions",
            },
            "phenomenonSearch": {
                modal: "v.phenomenonModal",
                apexMethod: "getFailurePhenomenon",
                paramKey: "middleValue",
                paramValue: selectedBrokenArea.phenomenonGroup.substring(0,6),
                targetList: "v.phenomenonList",
            },
            "causeSearch": {
                modal: "v.causeAreaModal",
                apexMethod: "getFailureCause",
                paramKey: "phenomenonValue",
                paramValue: selectedPhenomenon.causeAreaGroup,
                targetList: "v.causeAreaList",
            },
            "repairActionSearch": {
                modal: "v.repairActionModal",
                apexMethod: "getRepairAction",
                paramKey: "objectType",
                paramValue: serviceData.objectType,
                targetList: "v.repairActionList",
            },
            "statusSearch": {
                modal: "v.brokenStatusModal",
                apexMethod: null, 
                paramKey: null,
                paramValue: null,
                targetList: null,
            }
        };
    
        const config = modalMap[value];

        console.log('selectedBrokenArea ::: ', JSON.stringify(modalMap, null ,2));
    
        if (!config) {
            console.error("Invalid modal type:", value);
            helper.toast("ERROR", "잘못된 모달 요청입니다.");
            return;
        }

        if (value === "statusSearch") {
            component.set(config.modal, true); 
            return;
        }

        if (value === "phenomenonSearch" && (!workOrderResultData.selectedBrokenArea || Object.keys(workOrderResultData.selectedBrokenArea).length === 0)) {
            helper.toast('WARNING', '고장부위를 먼저 선택해주세요.');
            return;
        }
        if (value === "causeSearch" && (!workOrderResultData.selectedPhenomenon || Object.keys(workOrderResultData.selectedPhenomenon).length === 0)) {        
            helper.toast('WARNING', '고장현상을 먼저 선택해주세요.');
            return;
        }
    
        component.set('v.isLoading', true);
    
        helper.apexCall(component, event, helper, config.apexMethod, { [config.paramKey]: config.paramValue })
        .then($A.getCallback(function (result) {
            let r = result.r;
            console.log("From Apex ::: ", JSON.stringify(r, null, 2));
    
            if (r.errorString) {
                console.error(r.stackTrace);
            } else {
                component.set(config.targetList, r);
                if (config.modal) {
                    component.set(config.modal, true);
                }
            }
            component.set('v.isLoading', false);
        }))
        .catch((error) => {
            helper.toast("ERROR", "데이터 가져오기에 실패했습니다.");
            console.error("Fetch Error ::: ", JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },  
    
    // 수리내역 모달 별 값 선택
    handleRowClick: function (component, event, handler) {
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        var modalName = event.currentTarget.closest("tr").getAttribute("data-field");
        console.log('index ::: ', index);
        console.log('modalName ::: ', modalName);
        
        let workOrderResultData = component.get("v.workOrderResultData") || {};

        switch (modalName) {
            case 'brokenAreaModal':
                const selectedBrokenAreaGroup = component.get("v.selectedMajorValue");
                let majorOptions = component.get('v.majorOptions');
                
                let selectedMajor = majorOptions.find(option => option.value == selectedBrokenAreaGroup);
                let selectedMajorLabel = selectedMajor ? selectedMajor.label : selectedMajor.value;
                component.set('v.selectedMajorLabel', selectedMajorLabel);

                const selectedBrokenArea = component.get("v.middleAreaList")[index];
                workOrderResultData.selectedBrokenArea = workOrderResultData.selectedBrokenArea || {};
                workOrderResultData.selectedBrokenArea.brokenAreaGroup = selectedBrokenAreaGroup;
                workOrderResultData.selectedBrokenArea.brokenAreaCode = selectedBrokenArea.value;
                workOrderResultData.selectedBrokenArea.failureArea = selectedMajorLabel;
                workOrderResultData.selectedBrokenArea.failureAreaDetail = selectedBrokenArea.label;
                workOrderResultData.selectedBrokenArea.brokenAreaPart = selectedMajorLabel + ' - ' + selectedBrokenArea.label;
                workOrderResultData.selectedBrokenArea.phenomenonGroup = selectedBrokenAreaGroup + selectedBrokenArea.value + '00';
                workOrderResultData.selectedPhenomenon = {};
                workOrderResultData.selectedCauseArea = {}; 
                workOrderResultData.selectedRepairAction = {}; 
                component.set('v.repairActionGroupCode', '');
                break;
    
            case 'phenomenonModal':
                const selectedBrokenAreaGroupPhenomenon = workOrderResultData.selectedBrokenArea.phenomenonGroup.substring(0,6) || '';
                const selectedPhenomenon = component.get("v.phenomenonList")[index];
                workOrderResultData.selectedBrokenArea = workOrderResultData.selectedBrokenArea || {};
                workOrderResultData.selectedPhenomenon = workOrderResultData.selectedPhenomenon || {};
                workOrderResultData.selectedPhenomenon.phenomenonCode = selectedPhenomenon.value;
                workOrderResultData.selectedPhenomenon.phenomenonPart = selectedPhenomenon.label;
                workOrderResultData.selectedPhenomenon.causeAreaGroup = selectedBrokenAreaGroupPhenomenon + selectedPhenomenon.value;
                workOrderResultData.selectedCauseArea = {}; 
                workOrderResultData.selectedRepairAction = {}; 
                component.set('v.repairActionGroupCode', '');
                break;
                
            case 'causeAreaModal':
                // const selectedPhenomenonGroupCauseArea = workOrderResultData.selectedPhenomenon.causeAreaGroup;
                const selectedCauseArea = component.get("v.causeAreaList")[index];
                workOrderResultData.selectedPhenomenon = workOrderResultData.selectedPhenomenon || {};
                workOrderResultData.selectedCauseArea = workOrderResultData.selectedCauseArea || {};
                workOrderResultData.selectedCauseArea.causeAreaCode = selectedCauseArea.value;
                workOrderResultData.selectedCauseArea.causeAreaPart = selectedCauseArea.label;
                let repairActionGroupCode = '90000001';
                component.set("v.repairActionGroupCode", repairActionGroupCode);
                workOrderResultData.selectedRepairAction = {}; 
                break;
    
            case 'repairActionModal':
                const selectedRepairAction = component.get("v.repairActionList")[index];
                workOrderResultData.selectedRepairAction = workOrderResultData.selectedRepairAction || {};
                workOrderResultData.selectedRepairAction.repairActionCode = selectedRepairAction.value;
                workOrderResultData.selectedRepairAction.repairActionPart = selectedRepairAction.label;
                break;
    
            case 'brokenStatusModal':
                const selectedbrokenStatus = component.get("v.brokenStatusList")[index];
                workOrderResultData.selectedBrokenStatus = workOrderResultData.selectedBrokenStatus || {};
                workOrderResultData.selectedBrokenStatus.brokenStatusCode = selectedbrokenStatus.value;
                workOrderResultData.selectedBrokenStatus.brokenStatusPart = selectedbrokenStatus.label;
                break;
        }
    
        component.set("v.workOrderResultData", workOrderResultData);
        component.set(`v.${modalName}`, false);

        let fields = ["field1", "field2", "field4", "field6", "field12"];
        fields.forEach(fieldId => {
            let inputField = component.find(fieldId);
            if (inputField) {
                if (inputField.get("v.value")) {
                    $A.util.removeClass(inputField, "error-border");
                }
            }
        });
    },

    // 고장부위(대) 변경 
    handleMajorChange: function (component, event, helper) {
        const selectedValue = event.getParam("value");
        console.log('taget value ::: ', selectedValue);

        helper.apexCall(component, event, helper, 'getFailureAreaMiddle', { majorValue: selectedValue })
        .then($A.getCallback(function (result) {
            let r = result.r;
            console.log("Major From Apex ::: ", JSON.stringify(r, null, 2));
    
            if (r.errorString) {
                console.error(r.stackTrace);
            } else {
                component.set("v.middleAreaList", r);
                component.set("v.isBrokenAreaSearch", true);
            }
            component.set('v.isLoading', false);
        }))
        .catch((error) => {
            helper.toast("ERROR", "데이터 가져오기에 실패했습니다.");
            console.error("Fetch Error ::: ", JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },

    // 직영 신규 표준공수 고장부위 리스트 변경
    handleFaultAreaChange: function (component, event, helper) {
        let serviceData = component.get("v.serviceData").serviceReportInfo;


        helper.apexCall(component, event, helper, 'getFailureAreaMajor', { objectType: serviceData.objectType })
        .then($A.getCallback(function (result) {
            let r = result.r;
            console.log("FaultArea Major From Apex ::: ", JSON.stringify(r, null, 2));
    
            if (r.errorString) {
                console.error(r.stackTrace);
            } else {
                component.set("v.faultAreaOptions", r);
            }
            component.set('v.isLoading', false);
        }))
        .catch((error) => {
            helper.toast("ERROR", "데이터 가져오기에 실패했습니다.");
            console.error("Fetch Error ::: ", JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },

    // modal close
    closeModal : function (component) {
        const modals = [
            'v.brokenAreaModal', 
            'v.phenomenonModal', 
            'v.causeAreaModal', 
            'v.repairActionModal', 
            'v.brokenStatusModal'
        ];
    
        modals.forEach(modal => component.set(modal, false));
    },

    // 서비스맨 모달 열기
    openServiceManModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        var type = 'ServiceReport';
        var workOrderId = component.get("v.serviceData").workOrderId;
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        console.log('openServiceManModal Index ::: ', index);
        component.set("v.selectedWork", index);

        let loginUserInfo = component.get("v.loginUserInfo");
        let loginUserTerritoryId;
        if(loginUserInfo != null) {
            loginUserTerritoryId = loginUserInfo.Service_Territory__c;
        } else {
            loginUserTerritoryId = '';
        }

        $A.createComponent("c:DN_serviceManModal",
            {
                'type': type ,
                'workOrderId' : workOrderId,
                'curruntWorkcenterId': loginUserTerritoryId ,
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("serviceManModal");
                    console.log("container", container);
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 모달 선택 이벤트 
    handleCompEvent: function (component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message"); 
        console.log('handleCompEvent called');
        console.log('modalName:', modalName);
        console.log('actionName:', actionName);
        console.log('message:', message);


        var index = component.get("v.selectedWork");
        var workList = component.get('v.workList');

        if (modalName == 'DN_serviceManModal') {
            workList[index].worker = message;
            component.set('v.workList', workList);

            var workerFields = component.find("field13");
            if (workerFields) {
                if (!Array.isArray(workerFields)) workerFields = [workerFields];
                workerFields.forEach(function(inputField) {
                    // 값이 있을 경우 error-border 제거
                    var value = inputField.get("v.value");
                    if (value && value.trim() !== "") {
                        $A.util.removeClass(inputField, "error-border");
                    }
                });
            }
        }
        
        if (actionName === 'Close') {
            helper.closeModal(component);
        }
        console.log(JSON.stringify(workList,null,2));  
    },

    // 표준공수 선택 모달 열기
    openStandardWorkModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        var type = '표준공수';
        // let serviceData = component.get("v.serviceData").serviceReportInfo;
        let assetName = component.get("v.serviceData").serviceReportInfo.assetName;
        let objectType = component.get("v.serviceData").serviceReportInfo.objectType;

        console.log('assetName ::: ', assetName);
        console.log('objectType ::: ', objectType);
        
        $A.createComponent("c:DN_standardWorkLookupModal",
            {
                'type': type,
                'assetName': assetName,
                'objectType': objectType,
                // 'isBranch': component.get("v.isBranch")
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("standardWorkLookupModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    //workList 추가
    addWorkList : function(component, event, helper) {
        var workList = component.get("v.workList");
        let newWorkList = {
            checkbox: false,       
            worker: "",            
            workDate: "",
            startTime: "",         
            endTime: "",           
            workHours: "",         
            workType: "",        
            workContent: "",
            workId: "", 
            serviceAppointmentId: "",  
        };
        workList.push(newWorkList);
        component.set("v.workList", workList);
    },

    //workList checkbox 선택시 전체 선택 
    handleWorkCheckboxChange: function(component, event, helper) {
        let workList = component.get("v.workList");
        let allChecked = workList.every(item => item.checkbox);
        component.set("v.selectAllWorkList", allChecked);
        helper.updateTotals(component);
    },
    toggleAllWorkCheckboxes: function(component, event, helper) {
        let isChecked = component.get("v.selectAllWorkList");

        let workList = component.get("v.workList");
        if (workList) {
            workList.forEach(item => item.checkbox = isChecked);
            component.set("v.workList", workList);
            helper.updateTotals(component);
        }
    },
    
    //workList 삭제
    deleteWorkList: function (component, event, helper) {
        try {
            let workList = JSON.parse(JSON.stringify(component.get("v.workList"))) || [];
            let deletedWorkList = component.get("v.deletedWorkList") || [];
    
            console.log("Before workList ::: ", JSON.stringify(workList, null, 2));
    
            for (let i = workList.length - 1; i >= 0; i--) {
                if (workList[i].checkbox) {
                    deletedWorkList.push(workList[i].workId);
                    workList.splice(i, 1);
                }
            }
    
            console.log("After workList ::: ", JSON.stringify(workList, null, 2));
            console.log("Deleted items ::: ", JSON.stringify(deletedWorkList, null, 2));
    
            component.set("v.deletedWorkList", deletedWorkList);
            component.set("v.workList", []);
            component.set("v.workList", workList);
        } catch (error) {
            helper.toast("ERROR", "작업내역 리스트를 수정 중 오류가 발생했습니다.");
            console.error("Deleted workList Error ::: ", error);
        }
    },

    //standardWorkList 삭제
    deleteStandardWorkList: function (component, event, helper) {
        try {
            let standardWorkList = JSON.parse(JSON.stringify(component.get("v.standardWorkList"))) || [];
            let deletedWorkList = component.get("v.deletedWorkList") || [];
    
            console.log("Before standardWorkList ::: ", JSON.stringify(standardWorkList, null, 2));
    
            for (let i = standardWorkList.length - 1; i >= 0; i--) {
                if (standardWorkList[i].checkbox) {
                    deletedWorkList.push(standardWorkList[i].workId);
                    standardWorkList.splice(i, 1);
                }
            }
    
            console.log("After standardWorkList ::: ", JSON.stringify(standardWorkList, null, 2));
            console.log("Deleted items ::: ", JSON.stringify(deletedWorkList, null, 2));
    
            component.set("v.deletedWorkList", deletedWorkList);
            component.set("v.standardWorkList", []);
            component.set("v.standardWorkList", standardWorkList);
        } catch (error) {
            helper.toast("ERROR", "작업내역 리스트를 수정 중 오류가 발생했습니다.");
            console.error("Deleted workList Error ::: ", error);
        }
    },

    // standard checkbox 선택 시 선택된 값들 순회
    toggleAllStandardCheckboxes: function(component, event, helper) {
        let standardWorkList = component.get("v.standardWorkList");
        let allChecked = standardWorkList.every(item => item.checkbox);
        
        component.set("v.selectAllStandardWorkList", allChecked);
    },
    // Table Header 선택으로 전체 선택 및 해제 후 작업/표준공수 합계 반영
    toggleAllStandardWorkCheckboxes: function(component, event, helper) {
        let isChecked = component.get("v.selectAllStandardWorkList");

        let standardWorkList = component.get("v.standardWorkList");
        if (standardWorkList) {
            standardWorkList.forEach(item => item.checkbox = isChecked);
            component.set("v.standardWorkList", standardWorkList);
            helper.updateTotals(component);
        }
    },

    //직접입력 행 추가
    addStandardWork: function (component, event, helper) {
        component.set('v.isNoStandardWork', false);

        let changeData = component.get('v.workOrderResultData');
        changeData.reasonForOrverWork = '';
        component.set('v.workOrderResultData', changeData);
        
        let standardWorkList = component.get("v.standardWorkList");
        standardWorkList.push({
            checkbox: true,
            breakdownPart: '',
            standardWorkItem: '',
            standardWorkTime: 0,
            standardWorkPeople: 0,
            actualWorkTime: 0,
            actualWorkPeople: 0,
            isNew: true,
            isChangedStandardWork: true
        });
        component.set("v.standardWorkList", standardWorkList);
    },

    //표준공수 변경필요여부 체크시 disabled false로 변경
    handleCheckboxChange: function (component, event, helper) {
        let standardWorkList = component.get("v.standardWorkList");
        let index = event.getSource().get("v.label");
        let clickedItem = standardWorkList[index];
        
        const RequiredFields = clickedItem.actualWorkTime    || 
                                clickedItem.actualWorkPeople || 
                                clickedItem.changeRequestReason;

        if (RequiredFields) {
            helper.toast('WARNING', '실제 작업시간과 변경요청 사유를 입력 시 표준공수 변경필요여부를 변경할 수 없습니다.');
            clickedItem.isChangedStandardWork = true;
        } else {
            clickedItem.isLeftDisabled = !clickedItem.isChangedStandardWork;
        }
        component.set("v.standardWorkList", standardWorkList);
    },

    // 표준 공수 모달 선택한 행 Event
    handleSelectedItems: function (component, event, helper) {
        var selectedItems = event.getParam("selectedItems");
        let standardWorkList = component.get("v.standardWorkList");

        console.log('select Check ::: ', JSON.stringify(selectedItems, null, 2));

        if (selectedItems[0].readOnlyValue) {
            component.set("v.standardWorkList", []);
            component.set("v.isNoStandardWork", selectedItems[0].isNoStandardWork);
            component.set("v.readOnlyValue", selectedItems[0].readOnlyValue);

            let workOrderResultData = component.get("v.workOrderResultData");
            workOrderResultData.totalStandardWorkTime = 0;
            workOrderResultData.overWork = 0;
            workOrderResultData.reasonForOrverWork = selectedItems[0].readOnlyValue;
            component.set("v.workOrderResultData", workOrderResultData);

        } else {
            component.set('v.isNoStandardWork', false);

            let changeData = component.get('v.workOrderResultData');
            changeData.reasonForOrverWork = '';
            component.set('v.workOrderResultData', changeData);

            selectedItems.forEach(function(item) {
                let newRow = {
                    checkbox: false,
                    breakdownPart: item.breakdownPart || '',
                    standardWorkItem: item.standardWorkItem || '',
                    standardWorkTime: item.standardWorkTime || 0,
                    standardWorkPeople: item.standardWorkPeople || 0,
                    actualWorkTime: item.actualWorkTime || 0,
                    actualWorkPeople: item.actualWorkPeople || 0,
                    isChangedStandardWork: false,
                    isLeftDisabled : true,
                    isNew: false,
                    standardHourId:item.standardHourId
                };
        
                // 리스트에 새 행 추가
                standardWorkList.push(newRow);
            });
        
            // 업데이트된 리스트를 다시 설정
            component.set("v.standardWorkList", [...standardWorkList]); // 배열을 새로 설정
            helper.updateTotals(component);
        }
    },

    //전화번호 validation
    // validatePhoneNumber: function(component, event, helper) {
    //     let inputField = event.getSource();
    //     let value = inputField.get("v.value") || "";
    //     let cleanedValue = value.replace(/[^0-9]/g, '');
    //     let formattedValue = cleanedValue;

    //     // 입력 값이 11자리 이상인 경우, 첫 11자리만 사용
    //     if (cleanedValue.length > 11) {
    //         cleanedValue = cleanedValue.slice(0, 11);
    //     }
    //     // 4자리에서 7자리까지의 숫자는 첫 3자리와 그 이후에 하이픈을 추가
    //     if (cleanedValue.length > 3 && cleanedValue.length <= 7) {
    //         formattedValue = cleanedValue.slice(0, 3) + '-' + cleanedValue.slice(3);
    //     } else if (cleanedValue.length > 7) {
    //         formattedValue = cleanedValue.slice(0, 3) + '-' + cleanedValue.slice(3, 7) + '-' + cleanedValue.slice(7, 11);
    //     }
    //     // 포맷팅된 값이 원래 값과 다르면 값을 업데이트
    //     if (value !== formattedValue) {
    //         inputField.set("v.value", formattedValue);
    //     }
    //     // 입력된 값이 13자리라면 오류 스타일을 제거, 그렇지 않으면 오류 스타일 추가
    //     if (formattedValue.length === 13) { 
    //         $A.util.removeClass(inputField, "error-border"); 
    //     } else {
    //         $A.util.addClass(inputField, "error-border"); 
    //     }
    
    // },

    validatePhoneNumber: function(component, event, helper) {
        let inputField = event.getSource();
        let value = inputField.get("v.value") || "";
        let cleanedValue = value.replace(/[^0-9]/g, '');
    
        let formattedValue = '';
        let isValid = false;
    
        // 서울 지역번호 (02)
        if (cleanedValue.startsWith('02')) {
            if (cleanedValue.length === 9) { // 02-xxx-xxxx
                formattedValue = cleanedValue.replace(/(\d{2})(\d{3})(\d{4})/, '$1-$2-$3');
                isValid = true;
            } else if (cleanedValue.length === 10) { // 02-xxxx-xxxx
                formattedValue = cleanedValue.replace(/(\d{2})(\d{4})(\d{4})/, '$1-$2-$3');
                isValid = true;
            }
        }
        // 그 외 지역번호 (031, 051 등) 또는 휴대폰 (010)
        else if (/^0\d{2}/.test(cleanedValue)) {
            if (cleanedValue.length === 10) { // 031-xxx-xxxx
                formattedValue = cleanedValue.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
                isValid = true;
            } else if (cleanedValue.length === 11) { // 010-xxxx-xxxx or 031-xxxx-xxxx
                formattedValue = cleanedValue.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
                isValid = true;
            }
        }
    
        if (value !== formattedValue && formattedValue) {
            inputField.set("v.value", formattedValue);
        }
    
        if (isValid) {
            $A.util.removeClass(inputField, "error-border");
        } else {
            $A.util.addClass(inputField, "error-border");
        }
    },

    // 현장 책임자 동일 체크 시 요청자와 요청자 연락처로 설정
    handleIsCustomerCheckedChange: function (component, event, helper) {
        const isChecked = component.get("v.isCustomerChecked");
        const serviceData = component.get("v.serviceData");
        const isManagerChecked = component.get("v.isSiteManagerChecked");
        const representative = serviceData.serviceReportInfo.representative || "";
        const contactPhone = serviceData.serviceReportInfo.contactPhone || "";

        function formatPhoneNumber(phone) {
            if (!phone) return "";
            return phone.replace(/(\d{3})(\d{4})(\d{4})/, "$1-$2-$3");
        }
        
        if (isChecked) {
            //고객 동일에 체크 되어 있을 때 현장 책임자 동일 체크 해제
            if(isManagerChecked) {
                component.set("v.isSiteManagerChecked", false);
            }
            //요청자와 요청자 연착처로 값 집어넣기
            component.set("v.siteManager", representative);
            component.set("v.siteManagerPhone", formatPhoneNumber(contactPhone));

            window.setTimeout(() => {
                const inputField7 = component.find("field7");
                const inputField8 = component.find("field8");
                const value7 = component.get("v.siteManager");
                const value8 = component.get("v.siteManagerPhone");
                if (value7) {
                    //체크해서 현장책임자에 값 들어갈 경우 validation 해제
                    $A.util.removeClass(inputField7, "error-border");
                }
                if (value8) {
                    //체크해서 현장 책임자 핸드폰에 값 들어갈 경우 validation 해제
                    $A.util.removeClass(inputField8, "error-border");
                } else {
                    //체크해서 현장 책임자 핸드폰에 값 들어가지 않을 경우 validation 걸기
                    $A.util.addClass(inputField8, "error-border");
                }
            }, 0);
        } else {
            //고객 동일 체크 해제 시 모든 validation 다시 걸기
            component.set("v.isSiteManagerChecked", false)
            component.set("v.siteManager", "");
            component.set("v.siteManagerPhone", "");
            component.set("v.mainWorker", "");
            component.set("v.mainWorkerPhone", "");

            window.setTimeout(() => {
                const inputField7 = component.find("field7");
                const inputField8 = component.find("field8");
                const inputField9 = component.find("field9");
                const inputField10 = component.find("field10");
                $A.util.addClass(inputField7, "error-border");
                $A.util.addClass(inputField8, "error-border");
                $A.util.addClass(inputField9, "error-border");
                $A.util.addClass(inputField10, "error-border");
            }, 0);
        }
    },

    // 현장책임자 직접 입력시 validation 삭제
    handleField7Change: function (component, event, helper) {
        const value = event.getSource().get("v.value");
        const inputField = component.find("field7");
        
        if (value) {
            // 현장책임자의 값이 비어있지 않으면 validation 해제
            $A.util.removeClass(inputField, "error-border");
        } else {
            // 현장책임자의 값이 비어있으면 validation 추가
            $A.util.addClass(inputField, "error-border");
        }
    },

    // 주작업자 동일 체크 시 현장 책임자 입력된 값으로 설정
    handleIsSiteManagerCheckedChange: function (component, event, helper) {
        const isChecked = component.get("v.isSiteManagerChecked");
        const siteManager = component.get("v.siteManager");
        const siteManagerPhone = component.get("v.siteManagerPhone");
        
        if (isChecked) {
            //현장 책임자 동일 체크시 현장책임자와 현장책임자 핸드폰 값 넣기
            component.set("v.mainWorker", siteManager);
            component.set("v.mainWorkerPhone", siteManagerPhone);

            window.setTimeout(() => {
                const inputField9 = component.find("field9");
                const inputField10 = component.find("field10");
                const value9 = component.get("v.mainWorker");
                const value10 = component.get("v.mainWorkerPhone");
                if (value9) {
                    //체크해서 주 작업자에 값 들어갈 경우 validation 해제
                    $A.util.removeClass(inputField9, "error-border");
                }
                if (value10) {
                    //체크해서 주 작업자 핸드폰에 값 들어갈 경우 validation 해제
                    $A.util.removeClass(inputField10, "error-border");
                } else {
                    //체크해서 주 작업자 핸드폰에 값 들어가지 않을 경우 validation 추가
                    $A.util.addClass(inputField10, "error-border");
                }
            }, 0);
        } else {
            //현장 책임자 동일 체크 해제 시 모든 validation 다시 걸기
            component.set("v.mainWorker", "");
            component.set("v.mainWorkerPhone", "");

            window.setTimeout(() => {
                const inputField9 = component.find("field9");
                const inputField10 = component.find("field10");
                $A.util.addClass(inputField9, "error-border");
                $A.util.addClass(inputField10, "error-border");
            }, 0);
        }
    },

    //주 작업자에 직접 입력 시 validation 제거
    handleField9Change: function (component, event, helper) {
        const value = event.getSource().get("v.value");
        const inputField = component.find("field9");
        
        if (value) {
            //주 작업자 필드값이 입력 시 validation 제거
            $A.util.removeClass(inputField, "error-border");
        } else {
            //주 작업자 필드값이 없을 시 validation 추가
            $A.util.addClass(inputField, "error-border");
        }
    },

    // 작업 내역 Validation
    handleWorkChange: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var workList = component.get('v.workList');
        var work = workList[index];

        console.log('index work ::: ', JSON.stringify(work, null, 2));
        
        let workDate = work.workDate;
        let startTime = work.startTime;
        let endTime = work.endTime;
        let applicationDateTime = component.get("v.serviceData.serviceReportInfo.applicationDateTime");

        console.log('workDate ::: ', workDate);
        console.log('startTime ::: ', startTime);
        console.log('endTime ::: ', endTime);
        console.log('applicationDateTime ::: ', applicationDateTime);

        let today = new Date();
        today.setHours(0, 0, 0, 0); 
        let convertTodayDate    = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');

        // 작업일
        let convertWorkDateTime = new Date(workDate);
        convertWorkDateTime.setHours(0, 0, 0, 0); 
        let convertWorkDate     = convertWorkDateTime.getFullYear() + '-' + String(convertWorkDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertWorkDateTime.getDate()).padStart(2, '0');

        // 접수일 / 접수시간
        let convertAppDateTime  = new Date(applicationDateTime);
        let convertAppDate      = convertAppDateTime.getFullYear() + '-' + String(convertAppDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertAppDateTime.getDate()).padStart(2, '0');

        let hours               = String(convertAppDateTime.getHours()).padStart(2, '0');
        let minutes             = String(convertAppDateTime.getMinutes()).padStart(2, '0');
        let seconds             = String(convertAppDateTime.getSeconds()).padStart(2, '0');
        let convertAppTimeOnly  = `${hours}:${minutes}:${seconds}`; 

        let currentDateTime = new Date();
            
        let currentHours    = String(currentDateTime.getHours()).padStart(2, '0');
        let currentMinutes  = String(currentDateTime.getMinutes()).padStart(2, '0');
        let currentSeconds  = String(currentDateTime.getSeconds()).padStart(2, '0');
        let currentTime     = `${currentHours}:${currentMinutes}:${currentSeconds}`;

        if (workDate) {
            if (!applicationDateTime) {
                helper.toast('ERROR', '접수일시에 대한 정보가 존재하지 않습니다.');
                return;
            } else {
                if (convertWorkDateTime > today) {
                    helper.toast('WARNING', '오늘날짜보다 작업일이 작아야 합니다.');
                    work.workDate   = today; 
                    work.startTime  = "";
                    work.endTime    = "";
                    work.workHours  = "";
                    component.set("v.workList", workList);
                    return;
                } 

                if (convertWorkDate < convertAppDate) {
                    helper.toast('WARNING', '접수일시 이전의 작업일은 입력할 수 없습니다.');
                    work.workDate   = today; 
                    work.startTime  = "";
                    work.endTime    = "";
                    work.workHours  = "";
                    component.set("v.workList", workList);
                    return;
                }
            } 

            if (convertWorkDate == convertTodayDate) {
                if (startTime > currentTime || endTime > currentTime) {
                    helper.toast('WARNING', '현재시간 이후의 일시는 입력할 수 없습니다.');
                    work.startTime  = "";
                    work.endTime    = "";
                    work.workHours  = "";
                    component.set("v.workList", workList);
                    return;
                }
            }
        }

        if (startTime) {
            if (!workDate) {
                helper.toast('WARNING', '작업일이 입력되지 않았습니다. 먼저 작업일을 입력해주세요.');
                work.startTime  = "";
                work.endTime    = "";
                work.workHours  = "";
                component.set("v.workList", workList);
                return; 
            }
            
            if (convertWorkDate == convertAppDate) {
                if (startTime < convertAppTimeOnly) {
                    helper.toast('WARNING', '작업일과 접수일이 같습니다. 접수시간 이후 시간으로 시작시간을 입력해주세요.');
                    work.startTime  = "";
                    work.endTime    = "";
                    work.workHours  = "";
                    component.set("v.workList", workList);
                    return;
                }
            }
        }

        if (startTime && endTime) {
            try {
                let start = new Date(`1970-01-01T${startTime}Z`);
                let end = new Date(`1970-01-01T${endTime}Z`);
                
                // 2025.04.29 이청우 수정 : 작업구분이 이동일 경우에만 작업시간 값 0 허용
                if (work.workType == 'MV') {
                    if (end < start) {
                        helper.toast('WARNING', '종료시간이 시작시간보다 작을 수 없습니다.');
                        work.endTime = "";
                        work.workHours = "";
                        component.set("v.workList", workList);
                        return;
                    }
                } else {
                    if (end <= start) {
                        helper.toast('WARNING', '종료시간이 시작시간보다 작거나 같을 수 없습니다.');
                        work.endTime = "";
                        work.workHours = "";
                        component.set("v.workList", workList);
                        return;
                    }
                }                
        
                let fromValue = start.getUTCHours() + (start.getUTCMinutes() / 60);
                let toValue = end.getUTCHours() + (end.getUTCMinutes() / 60);
                let timeDiff = Math.round((toValue - fromValue) * 10) / 10;
        
                work.workHours = timeDiff.toFixed(1);
                // if (timeDiff > 12) {
                //     helper.toast('WARNING', '작업시간이 12시간을 초과했습니다.');
                //     work.endTime = "";
                //     work.workHours = "";
                //     component.set("v.workList", workList);
                //     return;
                // }
                // if (timeDiff >= 8) {
                //     helper.toast('WARNING', '작업시간이 8시간을 초과했습니다.');
                // }
        
            } catch (error) {
                console.error("Error during time validation:", error);
                helper.toast("ERROR", "시간 계산 중 오류가 발생했습니다.");
                return;
            }
        } else {
            work.workHours = "";
        }
        component.set("v.workList", workList);
        helper.updateTotals(component);
    },
    
    // 표준 공수 Validation
    handleStandardWorkChange: function (component, event, helper) {
        let index = event.currentTarget.getAttribute("data-index");
        let standardWorkList = component.get("v.standardWorkList");

        if (index !== null && standardWorkList[index]) {
            let standardWork = standardWorkList[index];
            
            let standardWorkTime = standardWork.standardWorkTime || 0;
                
            component.set("v.standardWorkList", standardWorkList);
    
            helper.updateTotals(component);
        } else {
            console.error('Failed to validate standard work: Index or Field missing.');
        }
    },

    // 작업 내역 저장
    doSave: function (component, event, helper) {
        try {
            let workList = component.get('v.workList');
            // let isBranch = component.get("v.isBranch");
            let workOrderId = component.get("v.serviceData").workOrderId;
            let workOrderResultData = component.get("v.workOrderResultData");
            let deletedWorkList = component.get("v.deletedWorkList");
            // let standardWorkList = component.get("v.standardWorkList"); 
            let productRequestList = component.get("v.productRequests");
            let saveWorkList = JSON.parse(JSON.stringify(workList));
            // let saveStandardWorkList = []; 
            var staticFieldIds = ["field1", "field2", "field3", "field4", "field5", "field6", "field7", "field8", "field9", "field10", "field11", "field12"];
            var siteManagerPhone = component.get("v.siteManagerPhone");
            var mainWorkerPhone = component.get("v.mainWorkerPhone");
            // var phonePattern = /^\d{3}-\d{4}-\d{4}$/;
            var hasError = false; 
            var fieldsWithError = []; 
            
            if (!Array.isArray(workList) || workList.length === 0) {
                helper.toast('WARNING', '작업 내역이 없습니다. 1개 이상의 작업을 추가해주세요.');
                return;
            }

            // 원복시 해당 Validation 삭제 후 아래 주석 해제
            for (let i = 0; i < workList.length; i++) {
                const work = workList[i];
                if (
                    !work.worker || !work.worker.Name ||
                    !work.workDate ||
                    !work.startTime ||
                    !work.endTime ||
                    !work.workHours ||
                    !work.workType ||
                    !work.workContent
                ) {
                    hasError = true;
                    fieldsWithError.push(i + 1);
                }
            }
    
            if (hasError) {
                let message = '작업 내역 중 입력되지 않은 항목이 있습니다.\n';
                message += '다음 행(들)을 확인하세요: ' + fieldsWithError.join(', ') + '번 행';
                helper.toast('WARNING', message);
                return;
            }

            /** 2025.05.13 개선사항 요청으로 샌드박스에만 먼저 적용
            if (!siteManagerPhone || !helper.isSaveValidPhoneNumber(siteManagerPhone)) {
                helper.toast("ERROR", "현장책임자 핸드폰을 올바른 전화번호 형식으로 입력해주세요. (예: 010-1234-5678 또는 02-123-4567)");
                return;
            }
            
            if (!mainWorkerPhone || !helper.isSaveValidPhoneNumber(mainWorkerPhone)) {
                helper.toast("ERROR", "주 작업자 핸드폰을 올바른 전화번호 형식으로 입력해주세요. (예: 010-1234-5678 또는 031-123-4567)");
                return;
            }

            //작업내역 - 작업자 validation
            var allWorkValid = component.find('work-field').reduce(function (validSoFar, inputcomponent) {
                inputcomponent.showHelpMessageIfInvalid();
                return validSoFar && inputcomponent.get('v.validity').valid;
            }, true);
    
            var workerFields = component.find("field13"); 
            if (workerFields) {
                if (!Array.isArray(workerFields)) workerFields = [workerFields]; 
                workerFields.forEach(function(inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true;
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                });
            }

            //작업내역 - 작업구분 validation
            var workComboFields = component.find("field14"); 
            if (workComboFields) {
                console.log("workCombo", workComboFields);
                if (!Array.isArray(workComboFields)) workComboFields = [workComboFields]; 
                workComboFields.forEach(function(inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true;
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                });
            }

            //부품사용내력 - 반납구분 validation
            var comboFields = component.find("field18"); 
            if (comboFields) {
                if (!Array.isArray(comboFields)) comboFields = [comboFields]; 
                comboFields.forEach(function(inputField, index) {
                    var value = inputField.get("v.value");
                    var product = productRequestList[index];
                
                    // field18(반품 유형)이 비어 있으면 에러 표시
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true;
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                
                    if (product.ReturnStatus__c === "Y" && product.ReturnType__c === "2") {
                        console.log("값 없음");
                        var reasonField = component.find("field19"); 
                        var reasonField2 = component.find("field20"); 

                        if (reasonField && reasonField2) {
                            if (!Array.isArray(reasonField)) reasonField = [reasonField]; 
                            if (!Array.isArray(reasonField2)) reasonField2 = [reasonField2];
                        
                            var reasonInput = reasonField[index];
                            var reasonInput2 = reasonField2[index];
                        
                            var isReason1Empty = !product.Reason1__c || product.Reason1__c.trim() === "";
                            var isReason2Empty = !product.Reason2__c || product.Reason2__c.trim() === "";
                        
                            // Reason1이 비어 있으면 에러
                            if (isReason1Empty) {
                                $A.util.addClass(reasonInput, "error-border");
                                hasError = true;
                            } else {
                                $A.util.removeClass(reasonInput, "error-border");
                            }
                        
                            // Reason2도 별도로 검사
                            if (isReason2Empty) {
                                $A.util.addClass(reasonInput2, "error-border");
                                hasError = true;
                            } else {
                                $A.util.removeClass(reasonInput2, "error-border");
                            }
                        }
                    }
                });
            }
            for (var i = 0; i < staticFieldIds.length; i++) {
                var fieldId = staticFieldIds[i];
                var inputField = component.find(fieldId);
                var value = inputField.get("v.value");
            
                if (!value || value.trim() === "") {
                    fieldsWithError.push(inputField); 
                    hasError = true; 
                } else {
                    $A.util.removeClass(inputField, "error-border");  
                }
            }

            if (hasError) {
                fieldsWithError.forEach(function(field) {
                    $A.util.addClass(field, "error-border");
                });
                helper.toast('WARNING', '필수값 작성을 완료해주세요.');
                return;  
            }

            if (!allWorkValid) {
                helper.toast('WARNING', '작업내역을 모두 작성해주세요.');
                console.log('allWorkValid ::: ', JSON.stringify(allWorkValid, null, 2));
                return;
            }
            */

            /** 2025.05.13 개선사항 요청으로 샌드박스에만 먼저 적용
            if (
                !workOrderResultData.selectedBrokenArea ||
                !workOrderResultData.selectedBrokenArea.brokenAreaCode ||
                !workOrderResultData.selectedBrokenArea.brokenAreaPart ||
            
                !workOrderResultData.selectedPhenomenon ||
                !workOrderResultData.selectedPhenomenon.causeAreaGroup ||
                !workOrderResultData.selectedPhenomenon.phenomenonDetail ||
                !workOrderResultData.selectedPhenomenon.phenomenonPart ||
            
                !workOrderResultData.selectedCauseArea ||
                !workOrderResultData.selectedCauseArea.causeAreaCode ||
                !workOrderResultData.selectedCauseArea.causeAreaDetail ||
                !workOrderResultData.selectedCauseArea.causeAreaPart ||
            
                !workOrderResultData.selectedRepairAction ||
                !workOrderResultData.selectedRepairAction.repairActionCode ||
                !workOrderResultData.selectedRepairAction.repairActionDetail ||
                !workOrderResultData.selectedRepairAction.repairActionPart ||
            
                !workOrderResultData.selectedBrokenStatus ||
                !workOrderResultData.selectedBrokenStatus.brokenStatusCode ||
                !workOrderResultData.selectedBrokenStatus.brokenStatusPart
            ) {
                helper.toast('WARNING', '수리이력 작성을 완료해주세요.');
                return;
            }
            */

            //표준공수리스트 validation
            // standardWorkList.forEach(workItem => {
            //     workItem.actualWorkTime = workItem.actualWorkTime ? parseFloat(workItem.actualWorkTime) : 0;
            //     workItem.actualWorkPeople = workItem.actualWorkPeople ? parseFloat(workItem.actualWorkPeople) : 0;
            // });
            // saveStandardWorkList = standardWorkList;  

            // for (const product of productRequestList) {
            //     if (product.ShippingCheck__c == 'N') {
            //         helper.toast('WARNING', '발송되지 않은 부품사용내역이 존재합니다.');
            //         return;
            //     }
            // }
            
            // if (!isBranch) {
            //     if (workOrderResultData.overWork > 0 && !workOrderResultData.reasonForOrverWork) {
            //         helper.toast('WARNING', '초과시간이 발생하여 사유를 작성해주시기 바랍니다.');
            //         return;
            //     }
            // }
            
            helper.sortWorkList(component, saveWorkList);
            
            let saCounter = 0;
            let currentSaKey = "";
            let lastMVWorker = '';
            let lastMVEndDate = null; 
            let lastMVEndTime = null; 
            let lastMVSaKey = "";
            let preWorker = ''; 
            let preWorkDate = null; 
            let preEndTime = null;

            for (let index = 0; index < saveWorkList.length; index++) {
                const item = saveWorkList[index];
                
                if (item.workType == "MV") {
                    if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && lastMVEndTime && lastMVEndTime > item.startTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.`);
                        console.log('조건 ::: ', 'item.workType == "MV"');
                        console.log('마지막 이동 종료 시간 ::: ', lastMVEndTime);
                        console.log('비교 대상 이동 시작 시간 ::: ', item.startTime);
                        return; 
                    }

                    if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && preEndTime && preEndTime > item.startTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.`);
                        console.log('조건 ::: ', 'preEndTime && preEndTime > item.startTime');
                        console.log('마지막 작업 종료 시간 ::: ', lastMVEndTime);
                        console.log('비교 대상 이동 시작 시간 ::: ', item.startTime);
                        return; 
                    }
                    saCounter++;
                    currentSaKey = `sa${String(saCounter).padStart(3, "0")}`;
                    lastMVWorker = item.worker.Id;
                    lastMVEndDate = item.workDate;
                    lastMVEndTime = item.endTime;
                    lastMVSaKey = currentSaKey;
                    item.saKey = currentSaKey;
                    console.log(`saKey set for MV at index ${index}:`, currentSaKey);
                } else {
                    const preEndDateTime = new Date(`1970-01-01T${preEndTime}Z`).getTime();
                    const currentStartDateTime = new Date(`1970-01-01T${item.startTime}Z`).getTime();
            
                    if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && item.startTime >= lastMVEndTime) {
                        item.saKey = lastMVSaKey;
                    } else if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && item.startTime < lastMVEndTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다..`);
                        console.log('조건 ::: ', 'lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && item.startTime < lastMVEndTime');
                        console.log('마지막 이동 종료 시간 ::: ', lastMVEndTime);
                        console.log('비교 대상 이동 시작 시간 ::: ', item.startTime);
                        return; 
                    } else {
                        helper.toast("WARNING", `작업 ${index + 1}행에 대한 이동이 없습니다.`);
                        return; 
                    }
            
                    if (preWorker == item.worker.Id && preWorkDate == item.workDate && preEndDateTime > currentStartDateTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.`);
                        console.log('조건 ::: ', 'preWorker == item.worker.Id && preWorkDate == item.workDate && preEndDateTime > currentStartDateTime');
                        return;
                    }
            
                    // 이전 작업 변수 업데이트
                    preWorker = item.worker.Id;
                    preWorkDate = item.workDate;
                    preEndTime = item.endTime;
                }
            }
            

            component.set("v.workList", []);
            component.set("v.workList", saveWorkList);

            let fieldMap = {
                workOrderId: workOrderId,
                siteManager : component.get("v.siteManager"),
                siteManagerPhone : component.get("v.siteManagerPhone"),
                mainWorker : component.get("v.mainWorker"),
                mainWorkerPhone : component.get("v.mainWorkerPhone"),
                workOrderResultData: workOrderResultData,
                workList: saveWorkList,
                // standardWorkList: saveStandardWorkList,
                deletedWorkList: deletedWorkList,
                productRequests: productRequestList,
                deletedFileList: component.get("v.deletedFileList"),
            };
            
            console.log('fieldMap to Apex ::: ', JSON.stringify(fieldMap, null, 2));

            component.set('v.isLoading', true);
            
            helper.apexCall(component, event, helper, 'upsertServiceReport', { fieldMap: fieldMap })
                .then($A.getCallback(function (result) {
                    let r = result.r;
                    
                    if (r.errorString) {
                        helper.toast('ERROR', '저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                        console.error(r.errorString);
                        component.set('v.isLoading', false);
                        return; 
                    }
            
                    helper.toast('SUCCESS', '작업 내역이 성공적으로 저장되었습니다.');

                    const searchService = r.searchService;

                    console.log('refresh SearchService ::: ', JSON.stringify(searchService, null, 2));

                    $A.enqueueAction(component.get('c.handleFileList'));
                    
                    const searchWorkOrderResult = searchService.repairHistoryInfo;
                    if (searchWorkOrderResult) {
                        component.set("v.workOrderResultData", searchWorkOrderResult);
                    }

                    if (searchService.workList) {
                        let workOrderResultList = searchService.workList;
                        let initWorkList = helper.initResultWorkList(workOrderResultList);
                        helper.sortWorkList(component, workList);
                        component.set("v.workList", initWorkList);
                    }
                    // if (searchService.standardWorkList) {
                    //     let workOrderResultList = searchService.standardWorkList;
                    //     let initStandardWorkList = helper.initResultStandardWorkList(workOrderResultList);
                    //     component.set("v.standardWorkList", initStandardWorkList);
                    // }

                    if (searchService) {
                        let siteManager = searchService.serviceReportInfo.siteManager || '';
                        component.set("v.siteManager", siteManager);
                        let siteManagerPhone = searchService.serviceReportInfo.siteManagerPhone || '';
                        component.set("v.siteManagerPhone", siteManagerPhone);
                        let mainWorker  = searchService.serviceReportInfo.mainWorker || '';
                        component.set("v.mainWorker", mainWorker);
                        let mainWorkerPhone = searchService.serviceReportInfo.mainWorkerPhone || '';
                        component.set("v.mainWorkerPhone", mainWorkerPhone);

                        let representative = (searchService.serviceReportInfo && searchService.serviceReportInfo.representative) || '';
                        let contactPhone = (searchService.serviceReportInfo && searchService.serviceReportInfo.contactPhone) || '';

                        let isCustomerChecked = component.get("v.isCustomerChecked");
                        if ((siteManager || siteManagerPhone) && (representative == siteManager) && (contactPhone == siteManagerPhone)) {
                            isCustomerChecked = true;
                            component.set("v.isCustomerChecked", isCustomerChecked);
                        } else {
                            component.set("v.isCustomerChecked", false);
                        }
                        
                        let isSiteManagerChecked = component.get("v.isSiteManagerChecked");
                        if ((siteManager || siteManagerPhone) && (mainWorker == siteManager) && (mainWorkerPhone == siteManagerPhone)) {
                            isSiteManagerChecked = true;
                            component.set("v.isSiteManagerChecked", isSiteManagerChecked);
                        } else {
                            component.set("v.isSiteManagerChecked", false);
                        }
                    }

                    component.set('v.deletedWorkList', []);
                    component.set('v.deletedFileList', []);

                    let isConfirmed = false;

                    helper.apexCall(component, event, helper, 'callOutServiceOrder', { 
                        recordId : component.get("v.serviceData").workOrderId, isConfirmed: isConfirmed, docMapList: r.docMapList, convertVersionIdList : r.convertFileIds,
                    }).then($A.getCallback(function (result) {
                        let r = result.r;
                        console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                        let resParam = r.resParam.res046;
                        
                        if (resParam) {
                            if (resParam.O_RETURN.TYPE == 'S') {
                                helper.toast('SUCCESS', "ERP : " + resParam.O_RETURN.MESSAGE);
                            
                                console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                                component.set('v.isLoading', false);
                            } else {
                                if(resParam.O_RETURN.MESSAGE) {
                                    helper.toast('WARNING', "ERP : " + resParam.O_RETURN.MESSAGE);
                                    console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                                } else {
                                    helper.toast('WARNING', "ERP : " + "None RFC.");
                                }
                            }
                        } else {
                            helper.toast('WARNING', "ERP : " + "None RFC.");
                        }
                        
                        component.set('v.isLoading', false);
                    }))
                    .catch(error => {
                        helper.toast('ERROR', 'ERP로 데이터 전송 중 오류가 발생했습니다.');
                        console.log('IF Error:', JSON.stringify(error, null, 2));
                        component.set('v.isLoading', false);
                    });
                }))
                .catch(error => {
                    helper.toast('ERROR', '데이터 저장 중 오류가 발생했습니다.');
                    // helper.toast('ERROR', JSON.stringify(error.message, null, 2));
                    console.log('Save Error ::: ', JSON.stringify(error, null, 2));
                    component.set('v.isLoading', false);
                });
        } catch (error) {
            console.log('Save Error:', JSON.stringify(error, null, 2));
            helper.toast('ERROR', '알 수 없는 오류가 발생했습니다. 관리자에게 문의해주세요.');
            component.set('v.isLoading', false);
        }
    },

    //확정 버튼 눌러 읽기 전용 화면 변환
    isConfirmedTrue : function (component, event, helper) {
        try {
            let workOrderId = component.get("v.serviceData").workOrderId;
            let orderType = component.get("v.serviceData").serviceReportInfo.workOrderTypeCode;
            // let isBranch = component.get("v.isBranch");
            let workOrderResultData = component.get("v.workOrderResultData");
            let workList = component.get("v.workList");
            let deletedWorkList = component.get("v.deletedWorkList");
            // let standardWorkList = component.get("v.standardWorkList"); 
            let productRequestList = component.get("v.productRequests");
            let isNoStandardWork = component.get("v.isNoStandardWork");

            let saveWorkList = JSON.parse(JSON.stringify(workList));
            let workTypeWorkList = [];
            // let saveStandardWorkList = []; 
            var staticFieldIds = ["field1", "field2", "field3", "field4", "field5", "field6", "field7", "field8", "field9", "field10", "field11", "field12"];
            var siteManagerPhone = component.get("v.siteManagerPhone");
            var mainWorkerPhone = component.get("v.mainWorkerPhone");
            // var phonePattern = /^\d{3}-\d{4}-\d{4}$/;
            var hasError = false; 


            if (!siteManagerPhone || !helper.isSaveValidPhoneNumber(siteManagerPhone)) {
                helper.toast("ERROR", "현장책임자 핸드폰을 올바른 전화번호 형식으로 입력해주세요. (예: 010-1234-5678 또는 02-123-4567)");
                return;
            }
            
            if (!mainWorkerPhone || !helper.isSaveValidPhoneNumber(mainWorkerPhone)) {
                helper.toast("ERROR", "주 작업자 핸드폰을 올바른 전화번호 형식으로 입력해주세요. (예: 010-1234-5678 또는 031-123-4567)");
                return;
            }

            if (!Array.isArray(workList) || workList.length === 0) {
                helper.toast('WARNING', '작업 내역이 없습니다. 1개 이상의 작업을 추가해주세요.');
                return;
            }
            var allWorkValid = component.find('work-field').reduce(function (validSoFar, inputcomponent) {
                inputcomponent.showHelpMessageIfInvalid();
                return validSoFar && inputcomponent.get('v.validity').valid;
            }, true);
    
            var workerFields = component.find("field13"); 
            if (workerFields) {
                if (!Array.isArray(workerFields)) workerFields = [workerFields]; 
                workerFields.forEach(function(inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true; 
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                });
            }
            // 작업내역 - 작업구분 validation
            var workComboFields = component.find("field14"); 
            if (workComboFields) {
                console.log(" workComboFields",  workComboFields);
                if (!Array.isArray(workComboFields)) workComboFields = [workComboFields]; 
                workComboFields.forEach(function(inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true;
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                });
            }
                        
            // 부품사용내력 - 반납구분 validation
            var comboFields = component.find("field18"); 
            if (comboFields) {
                if (!Array.isArray(comboFields)) comboFields = [comboFields]; 
                comboFields.forEach(function(inputField, index) {
                    var value = inputField.get("v.value");
                    var product = productRequestList[index];
                
                    // field18(반품 유형)이 비어 있으면 에러 표시
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true;
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                
                    if (product.ReturnStatus__c == "Y" && product.ReturnType__c == "2") {
                        console.log("값 없음");
                        var reasonField = component.find("field19"); 
                        var reasonField2 = component.find("field20");
                        // var reasonField = product.Reason1__c;
                        // var reasonField2 = product.Reason2__c;

                        console.log('return status ::: ',product.ReturnStatus__c);
                        console.log('return type ::: ',product.ReturnType__c);
                        console.log('return field19 ::: ',reasonField);
                        console.log('return field20 ::: ',reasonField2);

                        if (reasonField && reasonField2) {
                            if (!Array.isArray(reasonField)) reasonField = [reasonField]; 
                            if (!Array.isArray(reasonField2)) reasonField2 = [reasonField2];
                        
                            var reasonInput = reasonField[index];
                            var reasonInput2 = reasonField2[index];
                        
                            var isReason1Empty = !product.Reason1__c || product.Reason1__c.trim() === "";
                            var isReason2Empty = !product.Reason2__c || product.Reason2__c.trim() === "";
                        
                            // Reason1이 비어 있으면 에러
                            if (isReason1Empty) {
                                $A.util.addClass(reasonInput, "error-border");
                                hasError = true;
                            } else {
                                $A.util.removeClass(reasonInput, "error-border");
                            }
                        
                            // Reason2도 별도로 검사
                            if (isReason2Empty) {
                                $A.util.addClass(reasonInput2, "error-border");
                                hasError = true;
                            } else {
                                $A.util.removeClass(reasonInput2, "error-border");
                            }
                        }
                    }
                });
            }

            var fieldsWithError = []; 
            for (var i = 0; i < staticFieldIds.length; i++) {
                var fieldId = staticFieldIds[i];
                var inputField = component.find(fieldId);
                var value = inputField.get("v.value");
            
                if (!value || value.trim() === "") {
                    fieldsWithError.push(inputField); 
                    hasError = true; 
                } else {
                    $A.util.removeClass(inputField, "error-border");  
                }
            }

            if (hasError) {
                fieldsWithError.forEach(function(field) {
                    $A.util.addClass(field, "error-border");
                });
                helper.toast('WARNING', '필수값 작성을 완료해주세요.');
                return;  
            }

            if (!allWorkValid) {
                helper.toast('WARNING', '작업내역을 모두 작성해주세요.');
                console.log('allWorkValid ::: ', JSON.stringify(allWorkValid, null, 2));
                return;
            }

            for (let i = 0; i < saveWorkList.length; i++) {
                let workItem = saveWorkList[i];

                if (workItem.workType == 'WK') { 
                    workTypeWorkList.push(workItem) 
                }
            }

            // if (isBranch) {
            //     standardWorkList.forEach(workItem => {
            //         if (!workItem.standardWorkTime || !workItem.standardWorkItem) {
            //             helper.toast('WARNING', '표준공수 리스트의 모든 필드를 입력해주세요.');
            //             return;
            //         }
    
            //         workItem.actualWorkTime = workItem.actualWorkTime ? parseFloat(workItem.actualWorkTime) : 0;
            //         workItem.actualWorkPeople = workItem.actualWorkPeople ? parseFloat(workItem.actualWorkPeople) : 0;
            //     });
            //     saveStandardWorkList = standardWorkList;  

            //     if (workTypeWorkList.length > 0 && saveStandardWorkList.length === 0) {
            //         if (!isNoStandardWork) {
            //             helper.toast('WARNING', '표준 공수 없음 또는 표준 공수를 선택해주세요.');
            //             return;
            //         }
            //     }

            //     if (isBranch && workOrderResultData.overWork > 0 && !workOrderResultData.reasonForOrverWork) {
            //         helper.toast('WARNING', '초과시간이 발생하여 사유를 작성해주시기 바랍니다.');
            //         return;
            //     }
            // }
            
            if (!workOrderResultData.selectedBrokenArea && !workOrderResultData.selectedPhenomenon && !workOrderResultData.selectedCauseArea && !workOrderResultData.selectedRepairAction ) {
                helper.toast('WARNING', '수리이력 작성을 완료해주세요.');
                return;
            }
            
            for (let product of productRequestList) {
                if (!product.ShippingCheck__c || product.ShippingCheck__c === 'N') {
                    helper.toast('WARNING', '배송되지 않은 부품이 있습니다.');
                    return;
                }
            }

            let isBranch = component.get("v.isBranch");
            let reportFiles = component.get("v.reportFileList");
            
            if(orderType == "202"){
                if(isBranch && reportFiles.length === 0){
                    helper.toast('WARNING','서비스보고서 파일이 첨부되지 않았습니다.');
                    return;
                }
            }

            if ((orderType == "201" || orderType == "203" || orderType == "204" || orderType == "221") && reportFiles.length === 0) {
                helper.toast('WARNING','서비스 보고서가 첨부되지 않았습니다.');
                return;
            }
            
            helper.sortWorkList(component, saveWorkList);
            
            let saCounter = 0;
            let currentSaKey = "";
            let lastMVWorker = '';
            let lastMVEndDate = null; 
            let lastMVEndTime = null; 
            let lastMVSaKey = "";
            let preWorker = ''; 
            let preWorkDate = null; 
            let preEndTime = null;

            for (let index = 0; index < saveWorkList.length; index++) {
                const item = saveWorkList[index];
                
                if (item.workType == "MV") {
                    if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && lastMVEndTime && lastMVEndTime > item.startTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.`);
                        console.log('조건 ::: ', 'item.workType == "MV"');
                        console.log('마지막 이동 종료 시간 ::: ', lastMVEndTime);
                        console.log('비교 대상 이동 시작 시간 ::: ', item.startTime);
                        return; 
                    }

                    if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && preEndTime && preEndTime > item.startTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.`);
                        console.log('조건 ::: ', 'preEndTime && preEndTime > item.startTime');
                        console.log('마지막 작업 종료 시간 ::: ', lastMVEndTime);
                        console.log('비교 대상 이동 시작 시간 ::: ', item.startTime);
                        return; 
                    }
                    saCounter++;
                    currentSaKey = `sa${String(saCounter).padStart(3, "0")}`;
                    lastMVWorker = item.worker.Id;
                    lastMVEndDate = item.workDate;
                    lastMVEndTime = item.endTime;
                    lastMVSaKey = currentSaKey;
                    item.saKey = currentSaKey;
                    console.log(`saKey set for MV at index ${index}:`, currentSaKey);
                } else {
                    const preEndDateTime = new Date(`1970-01-01T${preEndTime}Z`).getTime();
                    const currentStartDateTime = new Date(`1970-01-01T${item.startTime}Z`).getTime();
            
                    if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && item.startTime >= lastMVEndTime) {
                        item.saKey = lastMVSaKey;
                    } else if (lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && item.startTime < lastMVEndTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다..`);
                        console.log('조건 ::: ', 'lastMVWorker == item.worker.Id && lastMVEndDate == item.workDate && item.startTime < lastMVEndTime');
                        console.log('마지막 이동 종료 시간 ::: ', lastMVEndTime);
                        console.log('비교 대상 이동 시작 시간 ::: ', item.startTime);
                        return; 
                    } else {
                        helper.toast("WARNING", `작업 ${index + 1}행에 대한 이동이 없습니다.`);
                        return; 
                    }
            
                    if (preWorker == item.worker.Id && preWorkDate == item.workDate && preEndDateTime > currentStartDateTime) {
                        helper.toast("WARNING", `작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.`);
                        console.log('조건 ::: ', 'preWorker == item.worker.Id && preWorkDate == item.workDate && preEndDateTime > currentStartDateTime');
                        return;
                    }
            
                    // 이전 작업 변수 업데이트
                    preWorker = item.worker.Id;
                    preWorkDate = item.workDate;
                    preEndTime = item.endTime;
                }
            }

            component.set("v.workList", []);
            component.set("v.workList", saveWorkList);

            let fieldMap = {
                workOrderId: workOrderId,
                siteManager : component.get("v.siteManager"),
                siteManagerPhone : component.get("v.siteManagerPhone"),
                mainWorker : component.get("v.mainWorker"),
                mainWorkerPhone : component.get("v.mainWorkerPhone"),
                workOrderResultData: workOrderResultData,
                workList: saveWorkList,
                // standardWorkList: saveStandardWorkList,
                deletedWorkList: deletedWorkList,
                productRequests: productRequestList,
                deletedFileList: component.get("v.deletedFileList"),
            };
            
            console.log('fieldMap to Apex ::: ', JSON.stringify(fieldMap, null, 2));

            helper.updateLabelsForConfirmation(component);
            
            component.set('v.isLoading', true);

            helper.apexCall(component, event, helper, 'upsertServiceReport', { fieldMap })
            .then($A.getCallback(function(upsertResult) {
                const r = upsertResult.r;
                if (r.errorString) {
                    helper.toast('ERROR', '저장 중 오류가 발생했습니다.');
                    return Promise.reject('SAVE_ERROR');
                }
                component.set('v.deletedWorkList', []);
                component.set('v.deletedFileList', []);
                // 046 → 050
                return helper.apexCall(component, event, helper, 'callOutServiceOrder', {
                recordId: component.get("v.serviceData").workOrderId,
                isConfirmed: true,
                docMapList: r.docMapList,
                convertVersionIdList: r.convertFileIds
                });
            }))
            .then($A.getCallback(function(callOutResult) {
                const r = callOutResult.r;
                const res050 = r.resParam.res050;
                
                if (res050.O_RETURN.TYPE !== 'S') {
                    helper.toast('WARNING', "ERP : " + res050.O_RETURN.MESSAGE);
                    return Promise.reject('050_FAILED');
                }
                
                helper.toast('SUCCESS', "ERP : " + res050.O_RETURN.MESSAGE);
                
                if (r.confirmedDate) {
                    var serviceData = component.get("v.serviceData"); 
                    serviceData.serviceReportInfo.confirmedDate = r.confirmedDate;                   
                    component.set("v.serviceData", serviceData);     

                    const cmpEvent = component.getEvent("cmpEvent");
                    cmpEvent.setParams({ actionName: 'isConfirmed', message: r.confirmedDate });
                    cmpEvent.fire();
                }

                ["header","input-card","read-card","textareaInput"].forEach(id => {
                    const el = component.find(id);
                    if (el) $A.util.addClass(el, "confirmed");
                });

                helper.updateLabelsForConfirmation(component);
                $A.enqueueAction(component.get('c.handleFileList'));
                component.set("v.isDisabled", true);
                component.set("v.isConfirmed", true);
                
                return helper.apexCall(component, event, helper,'callOutServiceOrder054', { recordId: component.get("v.serviceData").workOrderId });
            }))
            .then($A.getCallback(function(callOut054Result) {
                const res054 = callOut054Result.r.res054 || callOut054Result.r;
                if (res054.O_RETURN.TYPE === 'S') {
                    helper.toast('SUCCESS', "ERP : SUCCESS");
                } else {
                    if (res054.O_RETURN.MESSAGE !== 'Please Input All Parametes.') {
                        helper.toast('WARNING', "ERP : " + res054.O_RETURN.MESSAGE);
                    }
                }
            }))
            .catch($A.getCallback(function(error) {
                console.error(error);
                helper.toast('ERROR', 'ERP 연동 중 오류가 발생했습니다.');
            }))
            .finally($A.getCallback(function() {
                component.set('v.isLoading', false);
            }));
        } catch (error) {
            console.log('Confirmed Error:', JSON.stringify(error, null, 2));
            helper.toast('ERROR', '알 수 없는 오류가 발생했습니다. 관리자에게 문의해주세요.');
            component.set('v.isLoading', false);
        }
    },

    // 첨부파일 업로드 후처리
    handleUploadFinished : function (component, event, helper) {
        let fileType = component.get("v.fileType");
        let uploadedFiles = event.getParam("files");
        let fileInfoList = [];
        uploadedFiles.forEach(element => {
            fileInfoList.push( {
                'fileType' : fileType,
                'contentVersionId' : element.contentVersionId,
                'fileTitle' : element.name,
            })
        });
        console.log('fileInfoList to Apex ::: ', JSON.stringify(fileInfoList));
        
        helper.apexCall(component, event, helper, 'uploadfinished', {
            fileList: fileInfoList
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('');
            $A.enqueueAction(component.get('c.handleFileList'));
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });

    },

    // 현재 조치결과입력에 파일 정보 가져오기
    handleFileList : function (component, event, helper) {
        let etcFileList = [];
        let reportFileList = [];
        helper.apexCall(component, event, helper, 'getFileList', {
            recordId : component.get("v.recordId"),
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('업로드된 파일 목록 ::: ', JSON.stringify(r, null, 2));
            r.forEach(element => {
                if(element.fileType == 'report') {
                    reportFileList.push(element);
                } else {
                    etcFileList.push(element);
                }
            });
            console.log(JSON.stringify('Service Reports ::: ', reportFileList, null, 2));
            console.log(JSON.stringify('ETC Files ::: ', etcFileList, null, 2));
            component.set("v.etcFileList", etcFileList);
            component.set("v.reportFileList", reportFileList);
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });
    },

    // 서비스 리포트 파일 삭제 (바로 삭제되지 않고 삭제할 리스트에 적재 후 저장 시 Delete)
    removeReportFile: function (component, event, helper) {
        let removeId = event.currentTarget.getAttribute("data-id");
        console.log('removeId ::: ', removeId);
    
        let reportFileList = JSON.parse(JSON.stringify(component.get("v.reportFileList"))) || [];
        let deletedFileList = component.get("v.deletedFileList") || [];
    
        for (let i = reportFileList.length - 1; i >= 0; i--) {
            if (reportFileList[i].contentDocumentId == removeId) {
                // let deletedFile = {
                //     fileId: reportFileList[i].contentDocumentId,  
                //     fileType: reportFileList[i].fileType,         
                // };
                // deletedFileList.push(deletedFile);
                deletedFileList.push(reportFileList[i].contentDocumentId);
                reportFileList.splice(i, 1);
            }
        }
    
        component.set("v.deletedFileList", deletedFileList);
        component.set("v.reportFileList", []);
        component.set("v.reportFileList", reportFileList);
    },    

    removeETCFile : function (component, event, helper) {
        let removeId = event.currentTarget.getAttribute("data-id");
        console.log('removeId ::: ', removeId);

        let etcFileList = JSON.parse(JSON.stringify(component.get("v.etcFileList"))) || [];
        let deletedFileList = component.get("v.deletedFileList") || [];
    
            for (let i = etcFileList.length - 1; i >= 0; i--) {
                if (etcFileList[i].contentDocumentId == removeId) {
                    deletedFileList.push(etcFileList[i].contentDocumentId);
                    etcFileList.splice(i, 1);
                }
            }
    
            console.log("After etcFileList ::: ", JSON.stringify(etcFileList, null, 2));
            console.log("Deleted items ::: ", JSON.stringify(deletedFileList, null, 2));
    
            component.set("v.deletedFileList", deletedFileList);
            component.set("v.etcFileList", []);
            component.set("v.etcFileList", etcFileList);
    },

    // 부품 사용 내역 
    handleFieldChange: function (component, event, helper) {
        let index = event.getSource().get("v.name");
        let fieldValue = event.getSource().get("v.value");
        let productRequests = component.get('v.productRequests');
        let product = productRequests[index];
        product.returnTargetOptions = component.get("v.returnTargetOptions");
    
        let fieldName = event.getSource().get("v.label"); 

        console.log("index", index);
        
        if (fieldName === "returnStatus") {
            if (fieldValue === "Y") {
                product.ReturnType__c = "2";  
                product.firstReasonOptions = []; 
                product.Reason1__c = "";
                product.secondReasonOptions = []; 
                product.Reason2__c = "";
            } else {
                product.ReturnType__c = ""; 
                product.returnCategoryOptions = [];  
            }
            // 필드 업데이트
            product.ReturnStatus__c = fieldValue;
            productRequests[index] = product;
            component.set('v.productRequests', productRequests);
        }

        if (fieldName === "returnType") {
            let inputField = component.find("field18");
            if (inputField) {
                if (!Array.isArray(inputField)) inputField = [inputField];
                inputField.forEach(function(field) {
                    $A.util.removeClass(field, "error-border");
                });
            }
        }
    
        if (fieldName === "firstReason") {
            let inputField = component.find("field19");
            if (inputField) {
                if (!Array.isArray(inputField)) inputField = [inputField];
                inputField.forEach(function(field) {
                    $A.util.removeClass(field, "error-border");
                });
            }
        }

        if (fieldName === "secondReason") {
            let inputField = component.find("field20");
            if (inputField) {
                if (!Array.isArray(inputField)) inputField = [inputField];
                inputField.forEach(function(field) {
                    $A.util.removeClass(field, "error-border");
                });
            }
        }

        if (fieldName) {
            helper.apexCall(component, event, helper, 'getPicklistValueList', { fieldValue, fieldName })
                .then($A.getCallback(function (result) {
                    let r = result.r;
                    
                    console.log('From "getPicklistValueList" of Apex :::', JSON.stringify(r, null, 2));
    
                    if (r.errorString) {
                        helper.toast('ERROR', r.errorString);
                        console.error(r.stackTrace);
                    } else if (r.length ===0) {
                        console.log('No data.');
                        helper.toast('INFO', '마지막 선택 값 입니다.');
                    } else {
                        switch (fieldName) {
                            case 'returnStatus':
                                product.returnCategoryOptions = r;
                                product.ReturnType__c = "";
                                product.firstReasonOptions = [];
                                product.Reason1__c = "";
                                product.secondReasonOptions = [];
                                product.Reason2__c = "";
                                productRequests[index] = product;
                                break;

                            case 'returnType':
                                product.firstReasonOptions = r;
                                product.Reason1__c = "";
                                product.secondReasonOptions = [];
                                product.Reason2__c = "";
                                productRequests[index] = product;
                                break;
    
                            case 'firstReason':
                                product.secondReasonOptions = r;
                                product.Reason2__c = "";
                                productRequests[index] = product;
                                break;
        
                            default:
                                console.log('Unhandled fieldName :::', fieldName);
                        }

                        if (product.ReturnStatus__c === "Y" && !product.ReturnType__c) {
                            product.ReturnType__c = "2";  
                            productRequests[index] = product;
                            component.set('v.productRequests', productRequests);

                            // 25.04.02 추가 반납대상 "예" 선택 시 구분 "폐품"으로 자동 선택 후 Reason1 옵션 셋팅 추가
                            helper.apexCall(component, event, helper, 'getPicklistValueList', { fieldValue: "2", fieldName: "returnType" })
                            .then($A.getCallback(function (result) {
                                let r = result.r;
                                if (r.errorString) {
                                    helper.toast('ERROR', r.errorString);
                                    console.error(r.stackTrace);
                                } else if (r.length === 0) {
                                    console.log('No data for returnType.');
                                    helper.toast('INFO', '마지막 선택 값 입니다.');
                                } else {
                                    product.firstReasonOptions = r;
                                    product.Reason1__c = "";
                                    product.secondReasonOptions = [];
                                    product.Reason2__c = "";
                                }
                                productRequests[index] = product;
                                component.set('v.productRequests', productRequests);
                                console.log('Updated ProductRequests with firstReasonOptions ::: ', JSON.stringify(productRequests, null, 2));
                            }))
                            .catch(error => {
                                helper.toast('ERROR', 'An unexpected error occurred.');
                                console.log('Error :::', error);
                            });
                        }
                    }
                    component.set('v.productRequests', productRequests);
                    console.log('Updated ProductRequests ::: ', JSON.stringify(productRequests, null, 2));
                }))
                .catch(error => {
                    helper.toast('ERROR', 'An unexpected error occurred.');
                    console.error('Error :::', error);
                });
        } else {
            console.error('Field name not found');
        }
    },

    // 전표발행 모달 open
    openScrapReceipt: function (component, event, helper) {
        let serviceData = component.get('v.serviceData');
        let productList = component.get('v.productRequests');

        console.log('serviceData ::: ', JSON.stringify(serviceData.serviceReportInfo.confirmedDate, null, 2));
    
        if (productList.length === 0) {
            helper.toast("WARNING", "부품사용내역이 존재하지 않습니다.");
            return;
        }

        // let invalidShipping = productList.some((product) => { 
        //     return product.ShippingCheck__c !== 'Y';
        // });
        
        // if (invalidShipping) {
        //     helper.toast("WARNING", "불출되지 않은 부품이 존재합니다.");
        //     return;
        // }

        // if(serviceData.serviceReportInfo.confirmedDate) {
            let matnrList = [];
            let aufnrList = [];
            let baseAUFNR = serviceData.serviceOrderNumber;

            productList.forEach((product) => {
                // 2025.05.30 전표 발행 유효성 체크 : 발송여부와 반납대상이 둘 다 Y 값인 경우에만 전표발행 인터페이스 셋팅하고 호출 되도록 수정
                if (product.ShippingCheck__c == 'Y' && product.ReturnStatus__c == 'Y') {
                    if (product.Product__r && product.Product__r.Name) {
                        matnrList.push(product.Product__r.Name);
                        aufnrList.push(baseAUFNR);  
                    }
                }
            });
        
            if (matnrList.length === 0) {
                helper.toast("WARNING", "유효한 부품 데이터가 없습니다.");
                return;
            }
        
            let MATNR = matnrList.join(',');
            let AUFNR = aufnrList.join(','); 
 
            let currentUrl = component.get("v.baseUrl");
            if (currentUrl.includes('sandbox.my.site.com')) {
                currentUrl += "/partners/apex/DN_ReturnedScrapReceipt?MATNR=" + encodeURIComponent(MATNR) + "&AUFNR=" + encodeURIComponent(AUFNR);
            } else {
                currentUrl += "/apex/DN_ReturnedScrapReceipt?MATNR=" + encodeURIComponent(MATNR) + "&AUFNR=" + encodeURIComponent(AUFNR);
            }

            console.log('VF 호출 URL :::', currentUrl);
            component.set('v.apexUrl', currentUrl);
            component.set('v.isLoading', false); 
            component.set('v.pdfModalOpen', true);
        // } else {
        //     helper.toast("WARNING", "전표발행은 확정 후 가능합니다.");
        //     return;
        // }
    },
    
    // 전표 발행 모달 close
    modalCancel : function (component, event, helper) {
        component.set("v.pdfModalOpen", false);
    },
    
    //작업자 지우기
    clearWorker: function (component, event, helper) {
        let workList = component.get('v.workList');
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        let serviceMan = workList[index].worker;
        if (!serviceMan) {
            helper.toast("WARNING", "index"); 
            return;
        }
        workList[index].worker = "";
        component.set("v.workList", workList);
    },    

    handleInputChange: function (component, event, helper) {
        var inputField = event.getSource(); 
        var value = inputField.get("v.value");
        if (value && value.trim() !== "") {
            $A.util.removeClass(inputField, "error-border");
        }
    },
    

})