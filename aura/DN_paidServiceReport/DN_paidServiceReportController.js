/**
 * @description       : 
 * @author            : youjin.shim@sobetec.com
 * @group             : 
 * @last modified on  : 05-08-2025
 * @last modified by  : Chungwoo Lee
**/
({
    doInit : function (component, event, helper) {
        // var firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        // var firstDayString = firstDayOfMonth.getFullYear() + '-' + ('0' + (firstDayOfMonth.getMonth() + 1)).slice(-2) + '-' + ('0' + firstDayOfMonth.getDate()).slice(-2);
        
        // component.set("v.defectDate", firstDayString);
        // component.set("v.receiptDate", firstDayString);
        // component.set("v.actionCallDate", firstDayString);

        var baseUrl = window.location.origin;
        component.set("v.baseUrl", baseUrl);

        const brokenStatusList = [
            { 'value': "0001", 'label': "단순하자" },
            { 'value': "0002", 'label': "성능저하" },
            { 'value': "0003", 'label': "가동불능경" },
            { 'value': "0004", 'label': "가동불능중" },
        ];
        component.set("v.brokenStatusList", brokenStatusList);  
        
        let action = component.get("c.getLoginUserInfo");
        
        action.setParams({ });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let r = response.getReturnValue();
            
            console.log('Login Information ::: ', JSON.stringify(r,null, 2));

            if (state === "SUCCESS") {
                if (r.flag == "success") {
                    component.set("v.loginUserInfo", r.loginUserInfo);
                    console.log('user info ::: ',JSON.stringify(r.loginUserInfo, null, 2));
                    
                    if (r.loginUserInfo.Service_Territory__r.classify__c == '지사') {
                        component.set('v.isBranch', true);
                    }
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

        if (!component.get("v.workOrderResultData")) {
            component.set("v.workOrderResultData", {});
        }       
        $A.enqueueAction(component.get('c.addWorkList'));
    },

    // 출하지시서 조회
    openEquipment: function (component, event, helper) {
        var machineName = component.get("v.machineName");
        var assetName = component.get("v.assetName");

        var currentUrl = component.get("v.baseUrl");

        if (!machineName || !assetName) {
            helper.toast('WARNING', '출하지시서 조회를 위해 기종 또는 장비번호를 검색해주세요.');
            return;
        } else {
            if (currentUrl.includes("--dev.sandbox")) {
                currentUrl += '/partners/s/equipment-specification-info' + '?machineName=' + encodeURIComponent(machineName) + '&assetName=' + encodeURIComponent(assetName);
            } else {
                currentUrl += '/s/equipment-specification-info' + '?machineName=' + encodeURIComponent(machineName) + '&assetName=' + encodeURIComponent(assetName);
            }
            
            window.open(currentUrl, '_blank');
        }
    },
    
    doSearch : function (component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.isLoading", false);
    },

    // 모달 모음
    openModelModal: function (component, event, helper) {
        // 기종 모달 열기
        component.set("v.isLoading", true);
        var type = '기종';
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    openSerialNumberModal: function (component, event, helper) {
        // 장비번호 모달 열기
        component.set("v.isLoading", true);
        let machineName = component.get("v.machineName");
        var type = '장비번호';
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type,
                'MachineName' : machineName
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    openServiceManModal : function(component, event, helper) {
        // 서비스맨 모달 열기 
        component.set("v.isLoading", true);
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        component.set("v.selectedWork", Number(index));

        let loginUserInfo = component.get("v.loginUserInfo");
        let loginUserTerritoryId;
        if(loginUserInfo != null) {
            loginUserTerritoryId = loginUserInfo.Service_Territory__c;
        } else {
            loginUserTerritoryId = '';
        }

        $A.createComponent("c:DN_serviceManModal",
            {
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

    // 부품 조회 모달
    openproductNumberModal: function (component, event, helper) {
        component.set("v.type", "부품번호"); 
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        component.set("v.selectedUsage", index);
        console.log('index ::: of usage ::: ',index);
        
        helper.openModal(component, event, helper, '부품번호', 'searchProduct');
    },

    // 저장된 값 지우기
    clearMachine: function (component, event, helper) {
        helper.clearField(component, "v.machineName", "저장된 기종 값이 없습니다.", helper);
    },
    clearAsset: function (component, event, helper) {
        helper.clearField(component, "v.assetName", "저장된 장비번호 값이 없습니다.", helper);
    },
    //작업자 지우기
    clearWorker: function (component, event, helper) {
        var idx = event.getSource().get('v.accesskey'); 
        let workList = component.get('v.workList');
        console.log("idx", idx);
        console.log("workList", JSON.stringify(workList));
    
        if (!workList || !workList[idx].worker.Name) {
            helper.toast('WARNING', `저장된 작업자 값이 없습니다.`);
            return;
        }
    
        workList[idx].worker.Name = '';
        component.set('v.workList', workList);
    },
    // 선택된 부품 지우기
    clearProductNumber: function (component, event, helper) {
        var idx = event.getSource().get('v.accesskey'); 
        let usageList = component.get('v.usageList');
    
        if (!usageList || !usageList[idx].productInfo.ProductCode) {
            helper.toast('WARNING', `저장된 품번 값이 없습니다.`);
            return;
        }
    
        usageList[idx].productInfo = {
            ProductCode: '',
        };
        component.set('v.usageList', usageList);
    },

    // value 값에 따라 맞는 modal open
    openModal: function (component, event, helper) {
        const value = event.getSource().get("v.value");
        console.log(value);
        let serviceData = component.get("v.serviceData").searchService || {};
        console.log(JSON.stringify(serviceData, null, 4));
        let workOrderResultData = component.get("v.workOrderResultData") || {};

        
        if (Object.keys(serviceData).length === 0) {
            helper.toast('WARNING', '기종과 장비번호를 검색해주세요.');
            return;
        }        

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
                paramValue: selectedBrokenArea.phenomenonGroup,
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
    
        console.log('modalMap ::: ', JSON.stringify(config, null, 2));
    
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
                workOrderResultData.selectedBrokenArea.phenomenonGroup = selectedBrokenAreaGroup + selectedBrokenArea.value;
                workOrderResultData.selectedPhenomenon = {};
                workOrderResultData.selectedCauseArea = {};
                workOrderResultData.selectedRepairAction = {}; 
                component.set('v.repairActionGroupCode', '');
                break;
    
            case 'phenomenonModal':
                const selectedBrokenAreaGroupPhenomenon = workOrderResultData.selectedBrokenArea.phenomenonGroup || '';
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
                const selectedCauseArea = component.get("v.causeAreaList")[index];
                workOrderResultData.selectedPhenomenon = workOrderResultData.selectedPhenomenon || {};
                workOrderResultData.selectedCauseArea = workOrderResultData.selectedCauseArea || {};
                workOrderResultData.selectedCauseArea.causeAreaCode = selectedCauseArea.value;
                workOrderResultData.selectedCauseArea.causeAreaPart = selectedCauseArea.label;
                workOrderResultData.selectedRepairAction = {}; 
                component.set('v.repairActionGroupCode', '90000001');
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

        let fields = ["field1", "field2","field3", "field4"];
        fields.forEach(fieldId => {
            let inputField = component.find(fieldId);
            if (inputField) {
                if (inputField.get("v.value")) {
                    $A.util.removeClass(inputField, "error-border");
                }
            }
        });
        console.log('Updated workOrderResultData:', JSON.stringify(workOrderResultData));
    },

    // 고장부위(대) 변경 
    handleMajorChange: function (component, event, helper) {
        const selectedValue = event.getParam("value"); 
        console.log('taget ::: ', selectedValue);

        helper.apexCall(component, event, helper, 'getFailureAreaMiddle', { majorValue: selectedValue })
        .then($A.getCallback(function (result) {
            let r = result.r;
            console.log("From Apex ::: ", JSON.stringify(r, null, 2));
    
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

    // 작업 내역 표 추가
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
        
    //workList checkbox 선택시 전체 선택 
    handleWorkCheckboxChange: function(component) {
        let workList = component.get("v.workList");
        let allChecked = workList.every(item => item.checkbox);
        component.set("v.selectAllWorkList", allChecked);
    },
    toggleAllWorkCheckboxes: function(component) {
        let isChecked = component.get("v.selectAllWorkList");

        let workList = component.get("v.workList");
        if (workList) {
            workList.forEach(item => item.checkbox = isChecked);
            component.set("v.workList", workList);
            helper.updateTotals(component);
        }
    },

    // 부품사용내역 표 추가
    addUsageList: function (component, event, helper) {
        var usageList = component.get("v.usageList");
        let newUsageList = {
            checkbox: false,       
            productCode: "",
            productName: "",            
            isCause: false,
            quantity: 0,  
            returnNote: "",       
            productId: "", 
        };
        usageList.push(newUsageList);
        component.set("v.usageList", usageList);
    },

    // 부품사용내역 표 삭제
    deleteUsageList: function (component, event, helper) {
        var usageList = component.get("v.usageList");
        let updatedUsageList = usageList.filter((usage) => !usage.usageListChange);

        component.set("v.selectAllUsageList", false);
        component.set("v.usageList", updatedUsageList);
    },

    //부품 사용 내역 체크박스 전체 선택
    toggleAllUsageList: function(component, event, helper) {
        const selectAll = event.getSource().get("v.checked"); // 체크박스의 상태 가져오기
        let usageList = component.get("v.usageList");
    
        usageList.forEach((usage) => {
            usage.usageListChange = selectAll;
        });
    
        component.set("v.usageList", usageList);
    },

    // Modal 이벤트 핸들러
    handleCmpEvent: function(component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message");
        console.log('modalName ::: ',modalName);
        console.log('actionName ::: ',actionName);
        console.log('message ::: ',message);

        var index = component.get("v.selectedWork");
        var usageIndex = component.get("v.selectedUsage");

        console.log('workerIndex ::: ', index);
        console.log('usageIndex ::: ', usageIndex);

        var workList = component.get('v.workList');
        var usageList = component.get('v.usageList');
        
        if (modalName == 'DN_serviceManModal') {
            workList[index].worker = message;
            component.set('v.workList', workList);

            var workerFields = component.find("field15");
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
            
            helper.closeServiceManModal(component);
        
        } else if (modalName == 'MachineModal') {
            component.set("v.machineName", message.label);
            component.set('v.assetName', "");
            component.set('v.assetData', "");
        } else if (modalName == 'DN_SearchProductNumber') {
            console.log('product Info ::: ', JSON.stringify(message, null, 2)); 

            usageList[usageIndex].productCode = message.ProductCode;
            usageList[usageIndex].productName = message.FM_MaterialDetails__c;
            component.set('v.usageList', usageList);

        } else {
            component.set("v.assetName", message.label);
            component.set("v.machineName", message.machineName);
            
            let assetId = message.value;

            if (!assetId) {
                helper.toast('WARNING', 'Please select unit information.');
                return;
            }        
        }
        
        if (actionName === 'Close') {
            helper.closeModal(component);
        }
    },

    // 기종 / 장비번호로 입력할 Asset 데이터 조회
    handleSearchData : function (component, event, helper) {
        let machineName = component.get("v.machineName");
        let assetName = component.get("v.assetName");

        if (!machineName || !assetName) {
            helper.toast('WARNING', '기종과 장비번호를 먼저 입력해주세요.');
            return;
        }

        component.set("v.isLoading", true);

        helper.apexCall(component, event, helper, 'searchServiceData', { machineName : machineName, assetName : assetName })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            console.log('response ::: ', JSON.stringify(r, null, 2));
    
            if(r.flag == 'success' && r.searchService != null) {
                helper.toast('SUCCESS', '조회되었습니다.');
                component.set("v.serviceData", r);
            } else {
                helper.toast('WARNING', '해당 장비에 대한 정보가 없습니다.');
                component.set("v.serviceData", '');
            }

            component.set("v.isLoading", false);
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# getCSServiceList error : ' + error.message);
            component.set("v.isLoading", false);
        });
    },

    // 작업내역 Validation
    handleWorkChange: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var workList = component.get('v.workList');
        var work = workList[index];
    
        let workDate = work.workDate;
        let startTime = work.startTime;
        let endTime = work.endTime;
        let applicationDateTime = component.get("v.serviceData.serviceReportInfo.applicationDateTime");

        let today = new Date();
        today.setHours(0, 0, 0, 0); 
        let convertTodayDate    = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');

        // 작업일
        let convertWorkDateTime = new Date(workDate);
        convertWorkDateTime.setHours(0, 0, 0, 0); 
        let convertWorkDate     = convertWorkDateTime.getFullYear() + '-' + String(convertWorkDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertWorkDateTime.getDate()).padStart(2, '0');

        let currentDateTime = new Date();
            
        let currentHours    = String(currentDateTime.getHours()).padStart(2, '0');
        let currentMinutes  = String(currentDateTime.getMinutes()).padStart(2, '0');
        let currentSeconds  = String(currentDateTime.getSeconds()).padStart(2, '0');
        let currentTime     = `${currentHours}:${currentMinutes}:${currentSeconds}`;

        if (workDate) {
            if (convertWorkDateTime > today) {
                helper.toast('WARNING', '오늘날짜보다 작업일이 작아야 합니다.');
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
    
        if (startTime) {
            if (!workDate) {
                helper.toast('WARNING', '작업일이 입력되지 않았습니다. 먼저 작업일을 입력해주세요.');
                work.startTime  = "";
                work.endTime    = "";
                work.workHours  = "";
                component.set("v.workList", workList);
                return; 
            }
        }

        if (startTime && endTime) {
            try {
                let start = new Date(`1970-01-01T${startTime}Z`);
                let end = new Date(`1970-01-01T${endTime}Z`);
                
                if (isNaN(start.getTime()) || isNaN(end.getTime())) {
                    helper.toast("ERROR", "시간 형식이 올바르지 않습니다.");
                    return;
                }
                
                if (end < start) {
                    helper.toast('WARNING', '종료시간이 시작시간보다 작을 수 없습니다.');
                    work.endTime = "";
                    work.workHours = "";
                    component.set("v.workList", workList);
                    return;
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
    },

    handleUsageChange : function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var usageList = component.get('v.usageList');
        var usage = usageList[index];

        console.log('usage test ::: ', usage)
    },

    // 첨부파일 업로드 후처리
    handleUploadFinished: function (component, event) {
        const uploadedFiles = event.getParam("files");
        const fileList = component.get("v.fileList");
        console.log('Record ID ::: ',component.get('v.recordId'));
        console.log('files ::: ',event.getParam("files"));
        console.log('fileList ::: ',component.get("v.fileList"));

        uploadedFiles.forEach((file) => {
            fileList.push({
                title: file.name,
                contentDocumentId: file.documentId
            });
        });

        component.set("v.fileList", fileList);
        console.log('fileList :::', JSON.stringify(component.get("v.fileList"), null, 2));
    },

    // 파일 제거
    removeFile: function (component, event) {
        const fileId = event.currentTarget.dataset.id;
        let fileList = component.get("v.fileList");

        // 선택된 파일 제거
        fileList = fileList.filter((file) => file.contentDocumentId !== fileId);
        component.set("v.fileList", fileList);
    },

    // 확정 : 인터페이스 완료되면 작업내역 저장 후  읽기 전용 화면 변환
    isConfirmedTrue : function (component, event, helper) {
        try {
            let searchService = component.get("v.serviceData").searchService;
            let workOrderResultData = component.get("v.workOrderResultData");
            let workList = component.get("v.workList");
            let usageList =  component.get("v.usageList");
            let fileList = component.get("v.fileList");
            let saveWorkList = JSON.parse(JSON.stringify(workList));
            var staticFieldIds = ["field1", "field2", "field3", "field4"];

            // defectDate = component.get("v.defectDate"),
            //     receiptDate = component.get("v.receiptDate"),
            //     actionCallDate = component.get("v.actionCallDate"),

            var hasError = false; 
            var fieldsWithError = []; 

            // 필드값 입력하지 않았을 때 input 테두리 붉은색
            var allValid = component.find('field').reduce(function (validSoFar, inputcomponent) {
                inputcomponent.showHelpMessageIfInvalid();
                return validSoFar && inputcomponent.get('v.validity').valid;
            }, true);
    
            staticFieldIds.forEach(function(fieldId) {
                var inputField = component.find(fieldId);
                if (inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") { 
                        $A.util.addClass(inputField, "error-border"); 
                        hasError = true;
                        fieldsWithError.push(inputField); 
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                }
            });

            var workerFields = component.find("field15"); 
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

            if (hasError) {
                fieldsWithError.forEach(function(field) {
                    $A.util.addClass(field, "error-border");
                });
                helper.toast('WARNING', '필수값 작성을 완료해주세요.');
                return;  
            }
            
            if (!allValid && !staticFieldIds && !workerFields) {
                helper.toast('WARNING', '필드를 입력해주세요.');
            }

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
                !workOrderResultData.selectedRepairAction.repairActionPart

            ) {
                helper.toast('WARNING', '수리이력 작성을 완료해주세요.');
                return;
            }
    
            let isValid = saveWorkList.every(workItem => {
                if (
                    !workItem.worker || !workItem.worker.Name || !workItem.worker.Name.trim() || 
                    !workItem.workDate || !String(workItem.workDate).trim() || 
                    !workItem.startTime || !String(workItem.startTime).trim() || 
                    !workItem.endTime || !String(workItem.endTime).trim() || 
                    !workItem.workHours || !String(workItem.workHours).trim() || 
                    !workItem.workContent || !String(workItem.workContent).trim()
                ) {
                    helper.toast('WARNING', '작업내역의 모든 필드를 입력해주세요.');
                    return false;
                }
                return true;
            });
            
            if (!isValid) {
                return;
            }

            let defectDate = component.get("v.defectDate");
            let receiptDate = component.get("v.receiptDate");
            let actionCallDate = component.get("v.actionCallDate");

            if ((actionCallDate < defectDate) || (actionCallDate < receiptDate)) {
                helper.toast("WARNING", "조치요구일은 하자발생일과 접수일보다 빠를 수 없습니다.");
                return;
            }

            if (workList && workList.length > 0) {
                for (let i = 0; i < workList.length; i++) {
                    let workDate = workList[i].workDate;

                    if (workDate && (new Date(workDate) < new Date(defectDate) || new Date(workDate) < new Date(receiptDate) )) {
                        helper.toast("WARNING", "작업일은 하자발생일과 접수일보다 빠를 수 없습니다.");
                        return;
                    }
                }
            }

            usageList.forEach(usage => {
                if (usage.quantity) {
                    usage.quantity = parseFloat(usage.quantity); 
                }
            });

            // helper.sortWorkList(component, saveWorkList);

            // let saCounter = 0;
            // let currentSaKey = "sa000";
            // let lastWorker = '';
            // let lastDate = null;  

            // saveWorkList.forEach((item, index) => {
            //     if (lastWorker == item.worker.Id && lastDate == item.workDate) {
            //         item.saKey = currentSaKey;
            //     } else {
            //         saCounter++;
            //         item.saKey = `sa${String(saCounter).padStart(3, "0")}`;
            //         currentSaKey = item.saKey;
            //         lastWorker = item.worker.Id;
            //         lastDate = item.workDate;
            //     }
            // });

            let firstWorkerId = saveWorkList[0].worker.Id;

            saveWorkList.sort((a, b) => {
                const keyA = `${a.worker.Id}_${a.workDate}`;
                const keyB = `${b.worker.Id}_${b.workDate}`;
                return keyA.localeCompare(keyB);
            });           

            let saKeyMap = {};
            let saCounter = 0;

            saveWorkList.forEach((item) => {
                const key = `${item.worker.Id}_${item.workDate}`;

                if (saKeyMap[key]) {
                    item.saKey = saKeyMap[key];
                } else {
                    saCounter++;
                    const newSaKey = `sa${String(saCounter).padStart(3, "0")}`;
                    saKeyMap[key] = newSaKey;
                    item.saKey = newSaKey;
                }
            });

            component.set("v.workList", []);
            component.set("v.workList", saveWorkList);

            let fieldMap = {
                searchService: searchService,
                workOrderResultData: workOrderResultData,
                reportedBy : component.get('v.loginUserInfo').Id,
                worker : firstWorkerId,
                workCenter : component.get('v.loginUserInfo').Service_Territory__r.Id,
                workList: saveWorkList,
                usageList: component.get("v.usageList"),
                deletedWorkList: component.get("v.deletedWorkList"),
                defectDate: defectDate,
                receiptDate: receiptDate,
                actionCallDate: actionCallDate,
                fileList : fileList,
                deletedFileList: component.get("v.deletedFileList"),
            };
            
            console.log('fieldMap to Apex ::: ', JSON.stringify(fieldMap, null, 2));
            
            component.set('v.isLoading', true);  

            helper.apexCall(component, event, helper, 'savePaidService', { fieldMap: fieldMap })
                .then($A.getCallback(function (result) {
                    if (!result || !result.r) {
                        throw new Error("Invalid response structure from Apex.");
                    }
                    let r = result.r;

                    console.log('response paid Report ::: ', JSON.stringify(r.searchService, null, 2));
                    let convertFileIds = r.convertFileIds;
                    console.log('response workOrder Id ::: ', r.workOrderId);

                    let workOrderId =  r.workOrderId;

                    if (r.errorString) {
                        helper.toast('ERROR', '저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                        console.error(r.stackTrace);
                    } else {
                        helper.toast('SUCCESS', '작업 내역이 성공적으로 저장되었습니다.');
                        

                        if (r.searchService) {
                            let initWorkList = helper.initResultWorkList(r.searchService.workList);
                            let initPartList = helper.initResultUsagePartsList(r.searchService.productRequestList);
                            component.set("v.workList", []);
                            
                            component.set("v.workList", initWorkList);
                            component.set("v.usageList", initPartList);
                        }
                        

                        component.set('v.deletedWorkList', []);
                        component.set('v.deletedFileList', []);

                        let isConfirmed = true;

                        helper.apexCall(component, event, helper, 'callOutServiceOrder', { recordId : workOrderId , isConfirmed: isConfirmed, convertVersionIdList : convertFileIds})
                        .then($A.getCallback(function (result) {
                            let r = result.r;
                            console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));

                            let resParam = r.resParam;
                            
                            if (resParam.O_RETURN.TYPE == 'S') {
                                helper.toast('SUCCESS', "ERP : " + resParam.O_RETURN.MESSAGE);

                                ["header", "input-card", "read-card"].forEach(function(elementId) {
                                    var element = component.find(elementId);
                                    if (element) {
                                        $A.util.addClass(element, "confirmed");
                                    }
                                });
                            
                            } else {
                                helper.toast('WARNING', "ERP : " + resParam.O_RETURN.MESSAGE);
                            
                            }
                            component.set('v.isLoading', false);
                            component.set("v.isConfirmed", true);
                            component.set("v.isDisabled", true);
                        }))
                        .catch(error => {
                            helper.toast('ERROR', 'ERP로 데이터 전송 중 오류가 발생했습니다.');
                            console.log('IF Error:', JSON.stringify(error, null, 2));
                            component.set('v.isLoading', false);
                        });
                    }
                }))
                .catch(error => {
                    helper.toast('ERROR', '데이터 저장 중 오류가 발생했습니다.');
                    // helper.toast('ERROR', JSON.stringify(error.message, null, 2));
                    console.log('Save Error:', JSON.stringify(error, null, 2));
                    component.set('v.isLoading', false);
                });
        } catch (error) {
            console.error('Save Error ::: ', JSON.stringify(error));
            helper.toast('ERROR', '알 수 없는 오류가 발생했습니다. 관리자에게 문의해주세요.');
            component.set('v.isLoading', false);
        }
    },

    // 고장내역 하자발생일, 접수일, 조치요구일 validation
    handleDefectDateChange : function (component, event, helper) {
        const selectedDate = event.getSource().get("v.value");
        const today = new Date().toISOString().split("T")[0];

        if(selectedDate > today) {
            helper.toast('WARNING', '현재시간 이후의 일시는 입력할 수 없습니다.');
            event.getSource().set("v.value", "");
        }
    },

    handleValueChange: function(component, event, helper) {
        var inputField = event.getSource(); 
        var value = inputField.get("v.value"); 

        console.log("inputField", inputField);
        console.log("value", value);

        if (value && value.trim() !== "") { 
            $A.util.removeClass(inputField, "error-border"); 
        }
    }

})