/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-23-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-15-2025   youjin.shim@sbtglobal.com   Initial Version
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

        let action = component.get("c.getServiceReportType");
        
        action.setParams({ });

        action.setCallback(this, function(response) {
            let r = response.getReturnValue();
            
            if (r.flag == "success") {
                console.log('responseData for DNSA ::: ', JSON.stringify( r, null, 2));
                component.set("v.reportTypeOptions", r.picklistValues);
            } else if (r.flag == "warning") {
                helper.toast("WARNING", r.message);
            } else {
                helper.toast("Error", r.message);
            }
            
        });
        $A.enqueueAction(action);

        var recordId = component.get("v.recordId");
        var currentUrl = component.get("v.baseUrl");

        console.log('init org URL ::: ', currentUrl);
        
        if (currentUrl.includes('sandbox.my.site.com')) {
            currentUrl += "/partners/apex/DN_ServiceReportAPrint?recordId=" + recordId;
        } else {
            currentUrl += "/apex/DN_ServiceReportAPrint?recordId=" + recordId;
        }

        console.log('convert org URL ::: ', currentUrl);
        component.set("v.vfPageUrl", currentUrl);
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
        };
    
        const config = modalMap[value];
    
        if (!config) {
            console.error("Invalid modal type:", value);
            helper.toast("ERROR", "Invalid modal request");
            return;
        }

        if (value === "statusSearch") {
            component.set(config.modal, true); 
            return;
        }

        if (value === "phenomenonSearch" && (!workOrderResultData.selectedBrokenArea || Object.keys(workOrderResultData.selectedBrokenArea).length === 0)) {
            helper.toast('WARNING', 'Please select the area of failure first');
            return;
        }
        if (value === "causeSearch" && (!workOrderResultData.selectedPhenomenon || Object.keys(workOrderResultData.selectedPhenomenon).length === 0)) {        
            helper.toast('WARNING', 'Please select the fault phenomenon first');
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
                let fields = ["field1", "field2", "field4", "field6"];
                fields.forEach(fieldId => {
                    let inputField = component.find(fieldId);
                    if (inputField) {
                        $A.util.removeClass(inputField, "error-border");
                    }
                });
            }
            component.set('v.isLoading', false);
        }))
        .catch((error) => {
            helper.toast("ERROR", "Failed to get data");
            console.error("Fetch Error ::: ", JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },

    // 수리내역 모달 별 값 선택
    handleRowClick: function (component, event, handler) {
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        var modalName = event.currentTarget.closest("tr").getAttribute("data-field");
    
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
                component.set('v.repairActionGroupCode', '90000000');
                break;
    
            case 'repairActionModal':
                const selectedRepairAction = component.get("v.repairActionList")[index];
                workOrderResultData.selectedRepairAction = workOrderResultData.selectedRepairAction || {};
                workOrderResultData.selectedRepairAction.repairActionCode = selectedRepairAction.value;
                workOrderResultData.selectedRepairAction.repairActionPart = selectedRepairAction.label;
                break;

        }
    
        component.set("v.workOrderResultData", workOrderResultData);
        component.set(`v.${modalName}`, false);

        let fields = ["field2", "field3", "field5", "field7"];
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
            helper.toast("ERROR", "Data retrieval failed.");
            console.error("Fetch Error ::: ", JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },

    closeModal : function (component) {
        const modals = [
            'v.brokenAreaModal', 
            'v.phenomenonModal', 
            'v.causeAreaModal', 
            'v.repairActionModal', 
        ];
    
        modals.forEach(modal => component.set(modal, false));
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
            travelHour: "0",         
            airTripType: "",        
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
            console.log("Deleted WorkList ::: ", JSON.stringify(deletedWorkList, null, 2));
    
            component.set("v.deletedWorkList", deletedWorkList);
            component.set("v.workList", []);
            component.set("v.workList", workList);
        } catch (error) {
            helper.toast("ERROR", "Error modifying task history list.");
            console.error("Deleted workList Error ::: ", error);
        }
    },

    // 부품사용내역 표 추가
    addUsageList: function (component, event, helper) {
        var usageList = component.get("v.usageList");
        let newUsageList = {
            checkbox: false,       
            // ProductInfo: "", 
            productCode : "",
            productName : "",           
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
        try {
            let usageList = JSON.parse(JSON.stringify(component.get("v.usageList"))) || [];
            let deletedWorkList = component.get("v.deletedWorkList") || [];
    
            console.log("Before usageList ::: ", JSON.stringify(usageList, null, 2));
    
            for (let i = usageList.length - 1; i >= 0; i--) {
                if (usageList[i].checkbox) {
                    deletedWorkList.push(usageList[i].workId);
                    usageList.splice(i, 1);
                }
            }
    
            console.log("After usageList ::: ", JSON.stringify(usageList, null, 2));
            console.log("Deleted UsageList ::: ", JSON.stringify(deletedWorkList, null, 2));
    
            component.set("v.deletedWorkList", deletedWorkList);
            component.set("v.usageList", []);
            component.set("v.usageList", usageList);
        } catch (error) {
            helper.toast("ERROR", "An error occurred while modifying the part usage history list.");
            console.error("Deleted usageList Error ::: ", error);
        }
    },

    //부품 사용 내역 체크박스 전체 선택
    handleUsageCheckboxChange: function(component, event, helper) {
        let usageList = component.get("v.usageList");
        let allChecked = usageList.every(item => item.checkbox);
        component.set("v.selectAllUsageList", allChecked);
        // helper.updateTotals(component);
    },

    toggleAllUsageCheckboxes: function(component, event, helper) {
        let isChecked = component.get("v.selectAllUsageList");

        let usageList = component.get("v.usageList");
        if (usageList) {
            usageList.forEach(item => item.checkbox = isChecked);
            component.set("v.usageList", usageList);
            // helper.updateTotals(component);
        }
    },

    //작업자 지우기
    clearWorker: function (component, event, helper) {
        let workList = component.get('v.workList');
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        let serviceMan = workList[index].worker;
        if (!serviceMan) {
            helper.toast("WARNING", "Saved worker does not exist"); 
            return;
        }
        workList[index].worker = "";
        component.set("v.workList", workList);
    },  

    // 서비스맨 모달 열기
    openServiceManModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        var type = 'DNSA';
        var workOrderId = component.get("v.serviceData").workOrderId;
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        console.log('openServiceManModal Index ::: ', index);
        component.set("v.selectedWork", index);

        let loginUserInfo = component.get("v.loginUserInfo");
        let loginUserTerritoryId;
        // if(loginUserInfo != null) {
        //     loginUserTerritoryId = loginUserInfo.Service_Territory__c;
        // } else {
        //     loginUserTerritoryId = '';
        // }
        // 하드 코딩된 데이터 위 주석처리된 로직으로 수정해야함
        loginUserTerritoryId = '0HhJO0000003JUW0A2';
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

    // 부품 조회 모달
    openproductNumberModal: function (component, event, helper) {
        component.set("v.type", "부품번호"); 
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        component.set("v.selectedUsage", index);
        console.log('index ::: of usage ::: ',index);
        
        helper.openModal(component, event, helper, '부품번호', 'searchProduct');
    },

    // Modal 이벤트 핸들러
    handleCompEvent: function(component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message");
        console.log('modalName ::: ',modalName);
        console.log('actionName ::: ',actionName);
        console.log('message ::: ',message);

        if (actionName === 'isConfirmed') {
            console.log('set ConfirmedDate ::: ', message);
            return;
        }

        var index = component.get("v.selectedWork");
        var usageIndex = component.get("v.selectedUsage");

        console.log('workerIndex ::: ', index);
        console.log('usageIndex ::: ', usageIndex);

        var workList = component.get('v.workList');
        var usageList = component.get('v.usageList');
        
        if (modalName == 'DN_serviceManModal') {
            workList[index].worker = message;
            component.set('v.workList', workList);
            helper.closeModal(component, modalName);
        
        } else if (modalName == 'DN_SearchProductNumber') {
            // usageList[usageIndex].productInfo = message;
            usageList[usageIndex].productCode = message.ProductCode;
            usageList[usageIndex].productName = message.Name;
            component.set('v.usageList', usageList);
            helper.closeModal(component, modalName);

        } else {
            console.log('none modalName check please.');
            helper.toast('ERROR','An error occurred. Please contact the administrator.');
        }
        
        if (actionName == 'Close') {
            helper.closeModal(component);
        }
    },

    // 작업 내역 Validation
    handleWorkChange: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var workList = component.get('v.workList');
        var work = workList[index];
        
        let workDate = work.workDate;
        let startTime = work.startTime;
        let endTime = work.endTime;
        let applicationDateTime = component.get("v.serviceData.serviceReportInfo.applicationDateTime");

        console.log('workDate ::: ', workDate);
        console.log('startTime ::: ', startTime);
        console.log('endTime ::: ', endTime);
        console.log('applicationDateTime ::: ', applicationDateTime);

        // 접수일 / 접수시간
        let convertAppDateTime  = new Date(applicationDateTime);
        let convertAppDate      = convertAppDateTime.getFullYear() + '-' + String(convertAppDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertAppDateTime.getDate()).padStart(2, '0');

        let hours               = String(convertAppDateTime.getHours()).padStart(2, '0');
        let minutes             = String(convertAppDateTime.getMinutes()).padStart(2, '0');
        let seconds             = String(convertAppDateTime.getSeconds()).padStart(2, '0');
        let convertAppTimeOnly  = `${hours}:${minutes}:${seconds}`; 
        
        // 오늘 날짜 및 현재 시간
        let today = new Date();

        let convertToday    = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
        let currentHours    = String(today.getHours()).padStart(2, '0');
        let currentMinutes  = String(today.getMinutes()).padStart(2, '0');
        let currentSeconds  = String(today.getSeconds()).padStart(2, '0');
        let convertTime     = `${currentHours}:${currentMinutes}:${currentSeconds}`;        

        console.log('작업 날짜 :::', workDate);
        console.log('접수 날짜 :::', convertAppDate);
        // console.log('오늘 날짜 :::', today);

        console.log('오늘 날짜 / 시간 :::', today);
        console.log('오늘 날짜 :::', convertToday);
        console.log('오늘 시간 :::', convertTime);

        if (workDate) {
            if (!applicationDateTime) {
                helper.toast('ERROR', 'No information exists for Application Date Time.');
                return;
            } else {
                if (workDate > convertToday) {
                    helper.toast('WARNING', 'The working day must be less than or equal to today\'s date.');
                    work.workDate   = today; 
                    work.startTime  = "";
                    work.endTime    = "";
                    work.workHours  = "";
                    component.set("v.workList", workList);
                    return;
                } 

                if (workDate < convertAppDate) {
                    helper.toast('WARNING', 'You cannot enter workdays prior to the date of receipt.');
                    work.workDate   = today; 
                    work.startTime  = "";
                    work.endTime    = "";
                    work.workHours  = "";
                    component.set("v.workList", workList);
                    return;
                }
            } 

            if (workDate == convertToday) {
                if (startTime > convertTime || endTime > convertTime) {
                    helper.toast('WARNING', 'You cannot enter a date and time after the current time.');
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
                helper.toast('WARNING', 'You cannot enter a date and time after the current time.');
                work.startTime  = "";
                work.endTime    = "";
                work.workHours  = "";
                component.set("v.workList", workList);
                return; 
            }
            
            if (workDate == convertAppDate) {
                if (startTime < convertAppTimeOnly) {
                    helper.toast('WARNING', 'The work day and the reception date are the same. Please enter the start time as the time after the registration time.');
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

                if (end <= start) {
                    helper.toast('WARNING', 'The end time cannot be less than or equal to the start time.');
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
                //     helper.toast('WARNING', 'Operation time exceeded 12 hours.');
                //     work.endTime = "";
                //     work.workHours = "";
                //     component.set("v.workList", workList);
                //     return;
                // }
                // if (timeDiff >= 8) {
                //     helper.toast('WARNING', 'Operation time exceeded 8 hours.');
                // }
        
            } catch (error) {
                console.error("Error during time validation:", error);
                helper.toast("ERROR", "An error occurred during time calculation.");
                return;
            }
        } else {
            work.workHours = "";
        }
        component.set("v.workList", workList);
        helper.updateTotals(component);
    },

    // 서비스 리포트 입력 내용 저장
    saveServiceReport : function (component, event, helper) {
        let searchService = component.get("v.serviceData").serviceReportInfo;
        let workOrderResultData = component.get("v.workOrderResultData");
        let workList = component.get("v.workList");
        let usageList =  component.get("v.usageList");
        let fileList = component.get("v.fileList");
        let deletedWorkList = component.get("v.deletedWorkList");
        let hasSignatureEngineer = component.get("v.hasSignatureEngineer");
        let hasSignatureCustomer = component.get("v.hasSignatureCustomer");
        var hasError = false; 
        var fieldsWithError = []; 

        let repairStartDate = searchService.repairStartDate;
        // let repairEndDate = searchService.repairEndDate;
        
        var staticFieldIds = ["field2", "field3", "field4", "field5", "field6", "field7", "field8", "field9", "field11", "field12", "field13", "field14"]
        let combobox = component.find("field1");
        let comboboxValue = combobox.get("v.value");

        if (comboboxValue.trim() === "") {
            combobox.set("v.class", "error-border");
            hasError = true;
        }
        
        var allValid = true;
        var invalidFields = [];

        // component.find('field').forEach(function(inputcomponent) {
        //     inputcomponent.showHelpMessageIfInvalid();
        //     if (!inputcomponent.get('v.validity').valid) {
        //         allValid = false;
        //     }
        //     return;
        // });

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

        // if (!repairStartDate || !repairEndDate) {
        //     if (!repairStartDate) { 
        //         helper.toast('WARNING', 'Please enter repair Start Date.'); 
        //     }
        //     if (!repairEndDate) { 
        //         helper.toast('WARNING', 'Please enter repair End Date.'); 
        //     }
        // }

        // if (!repairStartDate) {
        //     if (!repairStartDate) { 
        //         helper.toast('WARNING', 'Please enter repair Start Date.'); 
        //     }
        // }

        // 파일 업로드 Validation 부분
        if (fileList.length === 0) {
            let inputField = component.find("fileWrapper");
            helper.toast('WARNING', 'Please attach a file to save.');
            if (inputField) {
                $A.util.addClass(inputField, "error-border");
                hasError = true;
            }
        } else {
            // 파일이 하나 이상 있으면 error-border 제거
            let inputField = component.find("fileWrapper");
            if (inputField) {
                $A.util.removeClass(inputField, "error-border");
            }
        }

        if (!Array.isArray(workList) || workList.length === 0) {
            helper.toast('WARNING', 'It\'s none of my business. Please add at least one task.');
            return;
        }

        var allWorkValid = component.find('work-field').reduce(function (validSoFar, inputcomponent) {
            inputcomponent.showHelpMessageIfInvalid();
            return validSoFar && inputcomponent.get('v.validity').valid;
        }, true);

        // var workerFields = component.find("field5"); 
        // if (workerFields) {
        //     if (!Array.isArray(workerFields)) workerFields = [workerFields]; 
        //     workerFields.forEach(function(inputField) {
        //         var value = inputField.get("v.value");
        //         if (!value || value.trim() === "") {
        //             $A.util.addClass(inputField, "error-border");
        //         } else {
        //             $A.util.removeClass(inputField, "error-border");
        //         }
        //     });
        // }

        if (hasError) {
            fieldsWithError.forEach(function(field) {
                $A.util.addClass(field, "error-border");
            });
            helper.toast('WARNING', 'Please fill in the field.');
            return;  
        }

        if (!allWorkValid) {
            helper.toast('WARNING', 'Please fill in the field.');
            console.log('allWorkValid ::: ', JSON.stringify(allWorkValid, null, 2));
            return;
        }

        

        // if (!allValid || invalidFields.length > 0) {
        //     helper.toast('WARNING', 'Please fill in the field');
        //     console.log('allWorkValid ::: ', JSON.stringify(allValid, null, 2));
        //     console.log('invalidFields ::: ', JSON.stringify(invalidFields, null, 2));
        //     return;
        // }


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
            helper.toast('WARNING', 'Please complete the repair history.');
            return;
        }

        if (!hasSignatureEngineer ) {
            helper.toast('WARNING','Please enter the engineer\'s signature.');
            return;
        }
        if (!hasSignatureCustomer) {
            helper.toast('WARNING','Please enter the customer\'s signature.');
            return;
        }

        usageList.forEach(usage => {
            if (usage.quantity) {
                usage.quantity = parseFloat(usage.quantity); 
            }
        });

        // let fileList = component.get("v.fileList");
        // let fileWrapper = component.find("fileWrapper");
        // console.log();
        // if (fileList.length === 0) {
        //     // helper.toast('WARNING','Please attach a file.');
        //     $A.util.addClass(fileWrapper, "error-border"); 
        //     return;
        // } else {
        //     $A.util.removeClass(fileWrapper, "error-border");
        // }
            
        let fieldMap = {
            workOrderId: component.get("v.recordId"),
            serviceReportInfo: searchService,
            workOrderResultData: workOrderResultData,
            workList: workList,
            workCenter: component.get("v.loginUserInfo").Service_Territory__c,
            usageList: component.get("v.usageList"),
            deletedWorkList: deletedWorkList,
            deletedFileList: component.get("v.deletedFileList"),
        };
        
        console.log('fieldMap to Apex ::: ', JSON.stringify(fieldMap, null, 2))
        
        component.set('v.isLoading', true);  

        helper.apexCall(component, event, helper, 'saveDNSAServiceReport', { fieldMap: fieldMap })
            .then($A.getCallback(function (result) {
                if (!result || !result.r) {
                    throw new Error("Invalid response structure from Apex.");
                }
                let r = result.r;

                console.log('response ::: ', JSON.stringify(r, null, 2));

                const searchWorkOrderResultList = r.searchService.workList;
                const searchProductRequestList = r.searchService.productRequestList;
                if (r.errorString) {
                    helper.toast('ERROR', 'An error occurred while saving. Please contact the administrator.');
                    console.error(r.stackTrace);
                    component.set('v.isLoading', false);
                } else if (r.flag == 'WARNING') {
                    helper.toast(r.flag, r.message);
                    component.set('v.isLoading', false)
                } else {
                    helper.toast('SUCCESS', 'Your work history has been saved successfully. Please wait...');
                    if (searchWorkOrderResultList) {
                        let initWorkList = helper.initResultWorkList(searchWorkOrderResultList);
                        console.log('initWorkList ::: ', JSON.stringify(initWorkList, null, 2));
                        component.set("v.workList", initWorkList);

                        let initUsageList = helper.initResultUsagePartsList(searchProductRequestList);
                        console.log('initUsageList ::: ', JSON.stringify(initUsageList, null, 2));
                        component.set("v.usageList", initUsageList);
                    }
                    
                    component.set('v.deletedWorkList', []);
                    component.set('v.deletedFileList', []);
                    
                    let isConfirmed = false;
                    if (r.searchService.serviceReportInfo.repairEndDate) {
                        isConfirmed = true;
                    }

                    helper.apexCall(component, event, helper, 'callOutServiceOrder', { 
                        recordId : component.get("v.serviceData").workOrderId, isConfirmed: isConfirmed, docNoList: r.docNoList, convertVersionIdList : r.convertFileIds,
                    })
                    .then($A.getCallback(function (result) {
                        let r = result.r;
                        console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                        let resParam = r.resParam;
                        
                        if (resParam.O_RETURN.TYPE == 'S') {
                            helper.toast('SUCCESS', "ERP : " + resParam.O_RETURN.MESSAGE);
                            
                            console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                            
                            if (isConfirmed) {
                                component.set('v.isConfirmed', true);    
                                if (r.confirmedDate) {
                                    // var serviceData = component.get("v.serviceData"); 
                                    // serviceData.serviceReportInfo.confirmedDate = r.confirmedDate;                   
                                    // component.set("v.serviceData", serviceData);     

                                    const cmpEvent = component.getEvent("cmpEvent");
                                    cmpEvent.setParams({ actionName: 'isConfirmed', message: r.confirmedDate });
                                    cmpEvent.fire();
                                }
                            }

                            component.set('v.isLoading', false);
                        } else {
                            helper.toast('WARNING', "ERP : " + resParam.O_RETURN.MESSAGE);
                        
                            console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                            component.set('v.isLoading', false);
                        }
                    }))
                    .catch(error => {
                        helper.toast('ERROR', 'An error occurred. Please contact the administrator.');
                        console.error('IF Error:', JSON.stringify(error, null, 2));
                        component.set('v.isLoading', false);
                    });
                }
            }))
            .catch(error => {
                helper.toast('ERROR', 'Failed to save data.');
                console.error('APEX Save Error ::: ', JSON.stringify(error, null, 2));
                component.set('v.isLoading', false);
            });
    },

    handlePrint : function (component, event, helper) {
        component.set('v.printModalOpen', true);
    },

    closePrintModal : function (component, event, helper) {
        component.set('v.printModalOpen', false);
    },

    // 첨부파일 업로드 후처리
    handleUploadFinished: function(component, event, helper) {
        let fileType = component.get("v.fileType");
        let uploadedFiles = event.getParam("files");
        let fileInfoList = [];
    
        uploadedFiles.forEach(element => {
            fileInfoList.push({
                'fileType': fileType,
                'contentVersionId': element.contentVersionId
            });
        });
    
        console.log(JSON.stringify(fileInfoList), ' < === fileInfoList');
    
        // 파일 업로드 후 서버에 데이터 전송
        helper.apexCall(component, event, helper, 'uploadfinished', {
            fileList: fileInfoList
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log("Apex Response: ", JSON.stringify(r, null, 2));
            let fieldWrapper = component.find("fileWrapper");
            if (fieldWrapper) {
                $A.util.removeClass(fieldWrapper, "error-border");
            }
    
            // 파일 업로드 후 handleFileList 호출
            $A.enqueueAction(component.get('c.handleFileList'));
        }))
        .catch(function(error) {
            console.log('error : ' + error.message);
        });
    },
    

    // 현재 조치결과입력에 파일 정보 가져오기
    handleFileList : function (component, event, helper) {
        let fileList = [];
        helper.apexCall(component, event, helper, 'getFileList', {
            recordId : component.get("v.recordId"),
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            let hasEngineer = false;
            let hasCusotomer = false;
            console.log('handleFileList ::: ', JSON.stringify(r, null, 2));
            r.forEach(element => {
                if (element.fileType != 'Signature') fileList.push(element);
                if(element.fileTitle && element.fileTitle.includes('Signature-Engineer')) hasEngineer = true;
                else if(element.fileTitle && element.fileTitle.includes('Signature-engineer')) hasEngineer = true;
                if(element.fileTitle && element.fileTitle.includes('Signature-Customer')) hasCusotomer = true;
                else if(element.fileTitle && element.fileTitle.includes('Signature-customer')) hasCusotomer = true;
            });
            console.log('component set files ::: ', JSON.stringify(fileList, null, 2));
            component.set('v.hasSignatureEngineer', hasEngineer);
            component.set('v.hasSignatureCustomer', hasCusotomer);
            component.set("v.fileList", fileList);
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });
    },

    //파일 삭제
    removeFile: function(component, event, helper) {
        // let contentDocumentId = event.target.getAttribute('data-id'); 
    
        // helper.apexCall(component, event, helper, 'removeFile', {
        //     contentDocumentId: contentDocumentId
        // })
        // .then($A.getCallback(function(result) {
        //     let r = result.r;
        //     console.log("File deleted successfully ::: ", JSON.stringify(r, null, 2));
    
        //     if (r.success) {
        //         // 파일 삭제 후 화면에서 해당 파일 제거
        //         let fileList = component.get("v.fileList");
        //         let updatedFileList = fileList.filter(file => file.contentDocumentId !== contentDocumentId);
        //         component.set("v.fileList", updatedFileList); // 화면에서 파일 리스트 갱신
        //     } else {
        //         console.error("Error deleting file: ", r.errorMessage);
        //     }
        // }))
        // .catch(function(error) {
        //     console.error("File deletion failed: ", error.message);
        // });
        let removeId = event.currentTarget.getAttribute("data-id");
        console.log('removeId ::: ', removeId);

        let fileList = JSON.parse(JSON.stringify(component.get("v.fileList"))) || [];
        let deletedFileList = component.get("v.deletedFileList") || [];
    
        for (let i = fileList.length - 1; i >= 0; i--) {
            if (fileList[i].contentDocumentId == removeId) {
                deletedFileList.push(fileList[i].contentDocumentId);
                fileList.splice(i, 1);
            }
        }

        console.log("After etcFileList ::: ", JSON.stringify(fileList, null, 2));
        console.log("Deleted items ::: ", JSON.stringify(deletedFileList, null, 2));

        component.set("v.deletedFileList", deletedFileList);
        component.set("v.fileList", []);
        component.set("v.fileList", fileList);
    },
    
    

    changecOptions :  function (component, event, helper) {
        let combobox = component.find("field7");
        $A.util.removeClass(combobox, "error-border");
    },

    // Print 기능으로 생성된 PDF 파일 이메일 전송
    handleSendEmail : function(component, event, helper) {
        var emailAddresses = component.get("v.emailAddress").trim();
        var recordId = component.get("v.recordId"); 

        console.log("Record Id ::: ", recordId);
        console.log("Email Addresses ::: ", emailAddresses);

        if (!emailAddresses) {
            helper.toast('WARNING', 'Please enter your email address');
            return;
        }

        component.set('v.isLoading', true); 

        helper.apexCall(component, event, helper, 'sendPDFEmail', {
            emailAddresses: emailAddresses, 
            recordId: recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log("Response ::: ", r);

            if (r) {
                helper.toast('SUCCESS', r);
            
                console.log('response by send Email ::: ' ,JSON.stringify(r, null, 2));
                component.set('v.isLoading', false);
            } else {
                helper.toast('ERROR', "Nothing was returned.");
            
                component.set('v.isLoading', false);
            }
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });
    },

    
    closePrintModal : function(component, event, helper) {
        component.set("v.printModalOpen", false);
    },

    handleInputChange: function (component, event, helper) {
        var inputField = event.getSource(); 
        var value = inputField.get("v.value");
        if (value && value.trim() !== "") {
            $A.util.removeClass(inputField, "error-border");
        }
    },

    onSignatureComplete: function(component, event, helper){
        console.log('complete test');
        
        // $A.enqueueAction(component.get('c.handleFileList'));
        
        var type = event.getParam("signatureType");
        if(type === 'engineer'){
            component.set('v.hasSignatureEngineer', true);
        } else if(type === 'customer'){
            component.set('v.hasSignatureCustomer', true);
        }else if(type === 'engineer_delete'){
            component.set('v.hasSignatureEngineer', false);
        }else if(type === 'customer_delete'){
            component.set('v.hasSignatureCustomer', false);
        }
    }

})