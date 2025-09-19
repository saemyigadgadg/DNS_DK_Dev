/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-08-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-22-2024   youjin.shim@sbtglobal.com   Initial Version
**/

({
    doInit : function(component, event, helper) {
        const brokenStatusList = [
            { 'value': "0001", 'label': "단순하자" },
            { 'value': "0002", 'label': "성능저하" },
            { 'value': "0003", 'label': "가동불능경" },
            { 'value': "0004", 'label': "가동불능중" },
        ];

        component.set("v.brokenStatusList", brokenStatusList);

        // 스탠다드 파일 업로드 기능 클릭 시 파일의 타입을 구분하기 위해 윈도우 클릭 이벤트 발생
        const onClick = (event) => {
            if(event.target.name == 'fileUpload') {
                console.log(event.target.id, ' <> === 파일첨부 타입');
                console.log(event.target.name,  ' < ==== 파일첨부');
                // 파일타입이 report인 경우만 값 넣는 형태로 구성, 추후 변동가능성 있음
                component.set("v.fileType", event.target.id);
            }
        }
        window.addEventListener('click', onClick);
        $A.enqueueAction(component.get('c.handleFileList'));
    },

      // 출하지시서 열기
      openEquipment: function (component, event, helper) {
        var machineName = component.get("v.serviceData.serviceReportInfo.machineName");
        var assetName = component.get("v.serviceData.serviceReportInfo.assetName");

        var url = '/partners/s/equipment-specification-info'
                    + '?machineName=' + encodeURIComponent(machineName)
                    + '&assetName=' + encodeURIComponent(assetName);
        window.open(url, '_blank');
    },

    // 첨부파일 업로드 후처리
    handleUploadFinished : function (component, event, helper) {
        let fileType = component.get("v.fileType");
        let uploadedFiles = event.getParam("files");
        let fileInfoList = [];
        uploadedFiles.forEach(element => {
            fileInfoList.push( {
                'fileType' : fileType,
                'contentVersionId' : element.contentVersionId
            })
        });
        console.log(JSON.stringify(fileInfoList),' < ===fileInfoList');
        // 파일 업로드 후 파일타입 구분하기 위해 해당 필드에 값 업데이트
        helper.apexCall(component, event, helper, 'uploadfinished', {
            fileList: fileInfoList
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            $A.enqueueAction(component.get('c.handleFileList'));
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });

    },

    // 현재 조치결과입력에 파일 정보 가져오기
    handleFileList : function (component, event, helper) {
        let allFileList = [];
        
        helper.apexCall(component, event, helper, 'getFileList', {
            recordId : component.get("v.recordId"),
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log(r, ' >< ==rrrrr');
            r.forEach(element => {
                allFileList.push(element);
            });
        
            component.set("v.fileList", allFileList);
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });
    },

    //파일 삭제
    removeFile: function (component, event, helper) {
        component.set("v.isLoading", true);
        let removeId = event.currentTarget.getAttribute("data-id");
        component.set("v.removeId", removeId);
        
        helper.apexCall(component, event, helper, 'fileRemove', {
            fileId: component.get("v.removeId")
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            $A.enqueueAction(component.get('c.handleFileList'));
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });
        component.set("v.isLoading", false);
    },

    //확정 버튼 눌러 읽기 전용 화면 변환
    isConfirmedTrue : function (component, event, helper) {
        
        try {
            let workOrderId = component.get("v.serviceData").workOrderId;
            let workOrderResultData = component.get("v.workOrderResultData");
            let workList = component.get("v.workList");

            let saveWorkList = [];
            let saveStandardWorkList = []; 
    
            if (!Array.isArray(workList) || workList.length === 0) {
                helper.toast('WARNING', '작업 내역이 없습니다. 1개 이상의 작업을 추가해주세요.');
                return;
            }

            workList.forEach(workItem => {
                    if (!workItem.worker || !workItem.workDate || !workItem.startTime || !workItem.endTime || !workItem.workHours || !workItem.workContent) {
                        helper.toast('WARNING', '작업내역의 모든 필드를 입력해주세요.');
                        return;
                    }

                    saveWorkList.push(workItem);
            });
    
            if (workOrderResultData.overWork > 0 && !workOrderResultData.reasonForOrverWork) {
                helper.toast('WARNING', '초과시간이 발생하여 사유를 작성해주시기 바랍니다.');
                return;
            }

            let fieldMap = {
                workOrderId: workOrderId,
            };
            
            component.set('v.isLoading', true);
            helper.apexCall(component, event, helper, 'confirmServiceReport', { fieldMap: fieldMap })
                .then($A.getCallback(function (result) {
                    if (!result || !result.r) {
                        throw new Error("Invalid response structure from Apex.");
                    }
                    let r = result.r;
                    console.log('From Apex ::: ', JSON.stringify(r, null, 2));
                    if (r.errorString) {
                        helper.toast('ERROR', '확정 내역 저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                        console.error(r.stackTrace);
                    } else {
                        let workOrderNumber = component.get("v.serviceData").workOrderNumber;
                        const isConfirmed = r.isConfirmed;
                        const isConfirmedTime = r.isConfirmedTime;

                        console.log('isConfirmed ::: ', isConfirmed);
                        console.log('isConfirmedTime ::: ', isConfirmedTime);
                        helper.toast('SUCCESS', '오더번호 :  ' + workOrderNumber + '  작업 내역 및 표준 공수가 확정되었습니다.');          
                        
                        let standardWorkList = component.get("v.standardWorkList");

                        ["header", "input-card", "read-card"].forEach(function(elementId) {
                            var element = component.find(elementId);
                            if (element) {
                                $A.util.addClass(element, "confirmed");
                            }
                        });

                        component.set("v.standardWorkList", standardWorkList);
                        console.log("new standardWorkList",  JSON.stringify(standardWorkList));
                        component.set("v.isDisabled", true);
                        component.set("v.isConfirmed", true);
                        component.set("v.isLoading", false);
                    }
                    component.set('v.isLoading', false);
                }))
                .catch(error => {
                    helper.toast('ERROR', '데이터 저장에 실패했습니다.');
                    console.error('Save Error:', JSON.stringify(error, null, 2));
                    component.set('v.isLoading', false);
                });
        } catch (error) {
            console.error('Save Error:', error);
            helper.toast('ERROR', '알 수 없는 오류가 발생했습니다. 관리자에게 문의해주세요.');
            component.set('v.isLoading', false);
        }
    },

    // 모달 모음
    openServiceManModal: function (component, event, helper) {
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

    openproductNumberModal: function (component, event, helper) {
        component.set("v.type", "부품번호"); 
        var index = event.currentTarget.closest("tr").getAttribute("data-index");
        component.set("v.selectedUsage", index);
        console.log('index ::: of usage ::: ',index);
        
        helper.openModal(component, event, helper, '부품번호', 'searchProduct');
    },

     // value 값에 따라 맞는 modal open
     // value 값에 따라 맞는 modal open
    openModal: function (component, event, helper) {
        const value = event.getSource().get("v.value");
        let serviceData = component.get("v.serviceData").serviceReportInfo;
        let workOrderResultData = component.get("v.workOrderResultData") || {};

        console.log("serviceData.serviceReportInfo ::: ", JSON.stringify(serviceData, null, 4));
        console.log("workOrderResultData ::: ", JSON.stringify(workOrderResultData, null, 4));

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
            // "statusSearch": {
            //     modal: "v.brokenStatusModal",
            //     apexMethod: "getFailureAreaMiddle",
            //     paramKey: "objectType",
            //     paramValue: serviceData.objectType,
            //     targetList: "v.brokenStatusList",
            // }
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
    
        component.set('v.isLoading', true);
    
        console.log('modalMap ::: ', JSON.stringify(config, null, 4));
    
        helper.apexCall(component, event, helper, config.apexMethod, { [config.paramKey]: config.paramValue })
        .then($A.getCallback(function (result) {
            let r = result.r;
            console.log("From Apex ::: ", JSON.stringify(r, null, 4));
    
            if (r.errorString) {
                console.error(r.stackTrace);
            } else {
                component.set(config.targetList, r);
                if (config.modal) {
                    component.set(config.modal, true);
                }

                const fieldsToClear = [
                    "field1", "field2", "field3", "field4"
                ];
                fieldsToClear.forEach(function(fieldId) {
                    const inputField = component.find(fieldId);
                    console.log('Found input field for:', fieldId, inputField);
                
                    if (inputField) {
                        // value가 undefined, 0, ""이 아닌 경우에만 error-border 제거
                        const value = inputField.get("v.value");
                        console.log('Value for', fieldId, value);
                        
                        if (value && value.trim() !== "" && value !== "0") {
                            console.log('Removing error-border from:', fieldId);
                            $A.util.removeClass(inputField, "error-border");
                        } else {
                            console.log('No value or empty value for', fieldId);
                        }
                    } else {
                        console.log('No input field found for:', fieldId);
                    }
                });
            }
            component.set('v.isLoading', false);
        }))
        .catch((error) => {
            helper.toast("ERROR", "데이터 가져오기에 실패했습니다.");
            console.error("Fetch Error ::: ", JSON.stringify(error, null, 4));
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
                // const selectedPhenomenonGroupCauseArea = workOrderResultData.selectedPhenomenon.causeAreaGroup || '';
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
        console.log('Updated workOrderResultData:', JSON.stringify(workOrderResultData));
    },

    // 고장부위(대) 변경 
    handleMajorChange: function (component, event, helper) {
        const selectedValue = event.getParam("value"); 
        console.log('taget ::: ', selectedValue);

        helper.apexCall(component, event, helper, 'getFailureAreaMiddle', { majorValue: selectedValue })
        .then($A.getCallback(function (result) {
            let r = result.r;
            console.log("From Apex ::: ", JSON.stringify(r, null, 4));
    
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
            console.error("Fetch Error ::: ", JSON.stringify(error, null, 4));
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
    addWorkList: function (component, event, helper) {
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

    //작업 내역 체크박스 전체 선택
    toggleAllWorkList: function(component, event, helper) {
        const selectAll = event.getSource().get("v.checked"); // 체크박스의 상태 가져오기
        let workList = component.get("v.workList");
    
        workList.forEach((history) => {
            history.workListChange = selectAll;
        });
    
        component.set("v.workList", workList);
    },

    //workList checkbox 선택시 전체 선택 (24-12-18)
    handleWorkCheckboxChange: function(component, event, helper) {
        let workList = component.get("v.workList");
        let allChecked = workList.every(item => item.checkbox);
        component.set("v.selectAllWorkList", allChecked);
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

    // 부품사용내역 표 추가
    addUsageList: function (component, event, helper) {
        var usageList = component.get("v.usageList");
        let newUsageList = {
            checkbox: false,       
            ProductInfo: "",            
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

    // 부품번호 지우기
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

    
    // // Modal 이벤트 핸들러
    handleCmpEvent: function(component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message");
        console.log('modalName ::: ',modalName);
        console.log('actionName ::: ',actionName);
        console.log('message ::: ',message);

        var index = component.get("v.selectedWork");
        var usageIndex = component.get("v.selectedUsage");
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
        } else if (modalName == 'DN_SearchProductNumber') {
            console.log('usageIndex ::: ', usageIndex); 
            usageList[usageIndex].productInfo = message;
            component.set('v.usageList', usageList);
            helper.closeProductNumberModal(component);
        }
    
        if (actionName === 'Close') {
            helper.closeModal(component);
        }
    },

    // 작업내역 Validation
    handleWorkChange: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var workList = component.get('v.workList');
        var work = workList[index];
        
        let startTime = work.startTime;
        let endTime = work.endTime;

        if (work.workDate) {
            let today = new Date();
            today.setHours(0, 0, 0, 0); 
            
            let convertDate = new Date(work.workDate);
            convertDate.setHours(0, 0, 0, 0); 

            if (convertDate >= today) {
                helper.toast('WARNING', '오늘날짜보다 작업일이 작아야 합니다.');
                work.workDate   = today; 
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
    
                var diffMs = end - start;
                var diffHours = Math.floor(diffMs / (1000 * 60 * 60));
                var diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
    
                // 경고 메시지
                // if (diffHours > 12) {
                //     helper.toast('WARNING', '작업시간이 12시간을 초과했습니다.');
                //     work.endTime = "";
                //     work.workHours = "";
                //     component.set("v.workList", workList);
                //     return;
                // }
                // if (diffHours >= 8) {
                //     helper.toast('WARNING', '작업시간이 8시간을 초과했습니다.');
                // }
    
                work.workHours = `${diffHours.toString().padStart(2, '0')}:${diffMinutes.toString().padStart(2, '0')}`;
    
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

    // // 작업일 변경 
    // handleDateChange : function (component, event, helper) {
    //     const selectedDate = event.getSource().get("v.value");
    //     const today = new Date().toISOString().split("T")[0];
    //     const index = event.getSource().get("v.name");
    //     const workList = component.get("v.workList");

    //     const applicationDateTime = component.get("v.serviceData.serviceReportInfo.applicationDateTime");
    //     const date = new Date(applicationDateTime);
    //     const dateOnly = date.toISOString().split("T")[0];

    //     if(selectedDate > today) {
    //         helper.toast('ERROR', '현재시간 이후의 일시는 입력할 수 업습니다.');
    //         event.getSource().set("v.value", "");
    //         workList[index].workDate = "";
    //     } else if (selectedDate < dateOnly) {
    //         helper.toast('ERROR', '접수일시 이전의 일시는 입력할 수 업습니다.');
    //         event.getSource().set("v.value", "");
    //         workList[index].workDate = "";
    //     }
    // },

    // handleTimeChange : function (component, event, helper) {
    //     const selectedDate = event.getSource().get("v.value"); 
    //     const index = event.currentTarget.closest("tr").getAttribute("data-index");
    //     const workList = component.get("v.workList");
    //     const workDate = workList[index].workDate;
    //     const applicationDateTime = component.get("v.serviceData.serviceReportInfo.applicationDateTime");
        
    //     const date = new Date(applicationDateTime); 
    //     const dateOnly = date.toISOString().split("T")[0]; 
    //     const hours = String(date.getHours()).padStart(2, '0');
    //     const minutes = String(date.getMinutes()).padStart(2, '0');
    //     const seconds = String(date.getSeconds()).padStart(2, '0');
    //     const timeOnly = `${hours}:${minutes}:${seconds}`;

    //     if (!workDate) {
    //         helper.toast('ERROR', '작업일이 입력되지 않았습니다. 먼저 작업일을 입력해주세요.');
    //         event.getSource().set("v.value", "");
    //         workList[index].startTime = "";
    //         return; 
    //     }

    //     if (workDate === dateOnly) {
    //         if (selectedDate < timeOnly) {
    //             helper.toast('ERROR', '접수일시 이전의 일시는 입력할 수 없습니다.');
    //             workList[index].startTime = "";
    //             event.getSource().set("v.value", "");
    //         }
    //     }
    // },

    // 유상 서비스 저장
    saveServiceReport : function (component, event, helper) {
        let workOrderId = component.get("v.serviceData").workOrderId;
        let workOrderResultData = component.get("v.workOrderResultData");
        let workList = component.get("v.workList");
        let usageList =  component.get("v.usageList");
        let deletedWorkList = component.get("v.deletedWorkList");
        let fileList = component.get("v.fileList");
        let saveWorkList = [];
        
        console.log("workList**", workList);

        if (!Array.isArray(workList) || workList.length === 0) {
            helper.toast('WARNING', '작업 내역이 없습니다. 1개 이상의 작업을 추가해주세요.');
            return;
        }

        let isValid = workList.every(workItem => {
            if (
                !workItem.worker || !workItem.worker.Name.trim() || 
                !String(workItem.workDate).trim() || 
                !String(workItem.startTime).trim() || 
                !String(workItem.endTime).trim() || 
                !String(workItem.workHours).trim() || 
                !String(workItem.workContent).trim()
            ) {
                helper.toast('WARNING', '작업내역의 모든 필드를 입력해주세요.');
                return false;
            }
            return true;
        });
        
        if (!isValid) {
            return;
        }
        saveWorkList.push(...workList);
        console.log('saveWorkList ::: ', JSON.stringify(saveWorkList));
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
            console.log('Data Check ::: ', JSON.stringify(workOrderResultData, null, 2));

            helper.toast('WARNING', '수리이력 작성을 완료해주세요.');

            return;
        }

        usageList.forEach(usage => {
            if (usage.quantity) {
                usage.quantity = parseFloat(usage.quantity); 
            }
        });

        // helper.sortWorkList(component, saveWorkList);

        // component.set('v.workList', saveWorkList);  

        // component.log('TEST ::: ', JSON.stringify(saveWorkList, null, 2));

        // let saCounter = 1;
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

        let fieldMap = {
            workOrderId: workOrderId,
            workOrderResultData: workOrderResultData,
            workList: saveWorkList,
            // worker:  workOrderResultData.worker,
            // workCenter: component.get("v.loginUserInfo").Service_Territory__c,
            usageList: usageList,
            deletedWorkList: deletedWorkList,
            defectDate: component.get('v.defectDate'),
            receiptDate: component.get('v.receiptDate'),
            actionCallDate: component.get('v.actionCallDate'),
            // fileList : fileList,
        };
        
        console.log('fieldMap to Apex ::: ', JSON.stringify(fieldMap, null, 2));

        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'upsertServiceReport', { fieldMap: fieldMap })
            .then($A.getCallback(function (result) {
                if (!result || !result.r) {
                    throw new Error("Invalid response structure from Apex.");
                }
                let r = result.r;

                console.log('response ::: ', JSON.stringify(r, null, 2));

                const searchWorkOrderResultList = r.searchWorkOrderResultList;
                if (r.errorString) {
                    helper.toast('ERROR', '저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                    console.error(r.stackTrace);
                } else {
                    helper.toast('SUCCESS', '작업 내역이 성공적으로 저장되었습니다.');
                    // ["header", "input-card", "read-card"].forEach(function(elementId) {
                    //     var element = component.find(elementId);
                    //     if (element) {
                    //         $A.util.addClass(element, "confirmed");
                    //     }
                    // });

                    if (searchWorkOrderResultList) {
                        let initWorkList = helper.initResultWorkList(searchWorkOrderResultList);
                        console.log('initWorkList ::: ', JSON.stringify(initWorkList, null, 2));
                        component.set("v.workList", initWorkList);
                    }

                    // component.set("v.isDisabled", true);
                    // component.set("v.isConfirmed", true);
                    
                    component.set('v.deletedWorkList', []);
                }
                
                component.set("v.isLoading", false);
            }))
            .catch(error => {
                helper.toast('ERROR', '데이터 저장에 실패했습니다.');
                console.error('Save Error:', JSON.stringify(error, null, 2));
                component.set('v.isLoading', false);
            });
        
    },
    
    // 작업 내역 저장
    // 확정 : 인터페이스 완료되면 작업내역 저장 후  읽기 전용 화면 변환
    isConfirmedTrue : function (component, event, helper) {
        try {
            let searchService = component.get("v.serviceData").searchService;
            let workOrderResultData = component.get("v.workOrderResultData");
            let workList = component.get("v.workList");
            let usageList =  component.get("v.usageList");
            let deletedWorkList = component.get("v.deletedWorkList");
            let fileList = component.get("v.fileList");
            let saveWorkList = [];
            var staticFieldIds = ["field1", "field2", "field3", "field4"];


            if (!Array.isArray(workList) || workList.length === 0) {
                helper.toast('WARNING', '작업 내역이 없습니다. 1개 이상의 작업을 추가해주세요.');
                return;
            }

            // 필드값 입력하지 않았을 때 input 테두리 붉은색
            var allValid = component.find('field').reduce(function (validSoFar, inputcomponent) {
                inputcomponent.showHelpMessageIfInvalid();
                return validSoFar && inputcomponent.get('v.validity').valid;
            }, true);
    
            staticFieldIds.forEach(function(fieldId) {
                var inputField = component.find(fieldId);
                var value = inputField.get("v.value");
    
                if (!value || value.trim() === "") { 
                    $A.util.addClass(inputField, "error-border"); 
                } else {
                    $A.util.removeClass(inputField, "error-border");
                }
            });

            var workerFields = component.find("field15"); 
            if (workerFields) {
                if (!Array.isArray(workerFields)) workerFields = [workerFields]; 
                workerFields.forEach(function(inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                    } else {
                        $A.util.removeClass(inputField, "error-border");
                    }
                });
            }

            
            if (!allValid && !staticFieldIds && !workerFields) {
                helper.toast('WARNING', '작업내역의 모든 필드를 입력해주세요.');
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
                !workOrderResultData.selectedRepairAction.repairActionPart ||
            
                !workOrderResultData.selectedBrokenStatus ||
                !workOrderResultData.selectedBrokenStatus.brokenStatusCode ||
                !workOrderResultData.selectedBrokenStatus.brokenStatusPart
            ) {
                helper.toast('WARNING', '수리이력 작성을 완료해주세요.');
                return;
            }

            usageList.forEach(usage => {
                if (usage.quantity) {
                    usage.quantity = parseFloat(usage.quantity); 
                }
            });

            helper.sortWorkList(component, saveWorkList);
            component.set('v.workList', saveWorkList);  

            let saCounter = 1;
            let currentSaKey = "sa000";
            let lastWorker = '';
            let lastDate = null;  

            saveWorkList.forEach((item, index) => {
                if (lastWorker == item.worker.Id && lastDate == item.workDate) {
                    item.saKey = currentSaKey;
                } else {
                    saCounter++;
                    item.saKey = `sa${String(saCounter).padStart(3, "0")}`;
                    currentSaKey = item.saKey;
                    lastWorker = item.worker.Id;
                    lastDate = item.workDate;
                }
            });

            let fieldMap = {
                searchService: searchService,
                workOrderResultData: workOrderResultData,
                workList: saveWorkList,
                worker: component.get("v.loginUserInfo").Id ,
                workCenter: component.get("v.loginUserInfo").Service_Territory__c,
                usageList: component.get("v.usageList") || null,
                deletedWorkList: deletedWorkList,
                defectDate: defectDate,
                receiptDate: receiptDate,
                actionCallDate: actionCallDate,
                fileList : fileList,
            };
            
            console.log('fieldMap to Apex ::: ', JSON.stringify(fieldMap, null, 2));

            component.set('v.isLoading', true);

            helper.apexCall(component, event, helper, 'savePaidService', { fieldMap: fieldMap })
                .then($A.getCallback(function (result) {
                    if (!result || !result.r) {
                        throw new Error("Invalid response structure from Apex.");
                    }
                    let r = result.r;

                    console.log('response ::: ', JSON.stringify(r, null, 2));

                    const searchWorkOrderResultList = r.searchWorkOrderResultList;
                    if (r.errorString) {
                        helper.toast('ERROR', '저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                        console.error(r.stackTrace);
                    } else {
                        helper.toast('SUCCESS', '작업 내역이 성공적으로 저장되었습니다.');
                        ["header", "input-card", "read-card"].forEach(function(elementId) {
                            var element = component.find(elementId);
                            if (element) {
                                $A.util.addClass(element, "confirmed");
                            }
                        });

                        if (searchWorkOrderResultList) {
                            let initWorkList = helper.initResultWorkList(searchWorkOrderResultList);
                            component.set("v.workList", initWorkList);
                        }

                        component.set("v.isDisabled", true);
                        component.set("v.isConfirmed", true);
                        
                        component.set('v.deletedWorkList', []);
                    }
                    component.set('v.isLoading', false);
                    component.set("v.isConfirmed", true);
                    component.set("v.isDisabled", true);
                    component.set("v.isLoading", false);
                }))
                .catch(error => {
                    helper.toast('ERROR', '데이터 저장에 실패했습니다.');
                    console.error('Save Error:', JSON.stringify(error, null, 2));
                    component.set('v.isLoading', false);
                });
        } catch (error) {
            console.error('Save Error ::: ', JSON.stringify(error));
            helper.toast('ERROR', '알 수 없는 오류가 발생했습니다. 관리자에게 문의해주세요.');
            component.set('v.isLoading', false);
        }
    },

})