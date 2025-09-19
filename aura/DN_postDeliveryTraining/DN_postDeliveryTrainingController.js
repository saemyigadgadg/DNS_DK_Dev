/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-05-30
 * @last modified by  : chungwoo.lee@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-12-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
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
            isHoliday: false,
            workId: "",   
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

    //th에 있는 checkbox선택 시 모든 checkbox 선택
    toggleAllCheckboxes: function(component, event, helper) {
        let isChecked = component.get("v.selectAll");
        let workList = component.get("v.workList");
        workList.forEach(item => {
            item.checkbox = isChecked;
        });
        component.set("v.workList", workList);
    },
    toggleSelectAll: function(component, event, helper) {
        let allChecked = component.get("v.workList").every(item => item.checkbox);
        component.set("v.selectAll", allChecked);
    },

//전화번호 validation
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
    },
    
    // 작업 내역 저장
    doSave: function (component, event, helper) {
        try {
            let workOrderId = component.get("v.serviceData").workOrderId;
            let workList = component.get("v.workList");
            let deletedWorkList = component.get("v.deletedWorkList");
            let saveWorkList = JSON.parse(JSON.stringify(workList));

            var siteManagerPhone = component.get("v.siteManagerPhone");
            var mainWorkerPhone = component.get("v.mainWorkerPhone");
            var staticFieldIds = ["field7", "field8", "field9", "field10"];
            var hasError = false; 
            var fieldsWithError = [];


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
            
            var workerFields = component.find("field1"); 
            if (workerFields) {
                if (!Array.isArray(workerFields)) workerFields = [workerFields]; 
                workerFields.forEach(function(inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true;
                        fieldsWithError.push(inputField);
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

            if (!allValid) {
                helper.toast('WARNING', `필수값 작성을 완료해주세요.`);
                return
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

            let saveWorkOrderResult = component.get("v.workOrderResultData");
            saveWorkOrderResult.actionDetail = component.get("v.serviceData").actionDetail;
            
            let fieldMap = {
                workOrderId: workOrderId,
                siteManager : component.get("v.siteManager"),
                siteManagerPhone : component.get("v.siteManagerPhone"),
                mainWorker : component.get("v.mainWorker"),
                mainWorkerPhone : component.get("v.mainWorkerPhone"),
                workOrderResultData :saveWorkOrderResult,
                workList: saveWorkList,
                deletedWorkList: deletedWorkList,
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
                    
                    const searchWorkOrderResult = searchService.repairHistoryInfo;
                    if (searchWorkOrderResult) {
                        searchWorkOrderResult.isHoliday = searchService.installTestInfo.isHoliday;
                        component.set("v.workOrderResultData", searchWorkOrderResult);
                    }
                    
                    if (searchService.workList) {
                        let workOrderResultList = searchService.workList;
                        let initWorkList = helper.initResultWorkList(workOrderResultList);
                        helper.sortWorkList(component, workList);
                        component.set("v.workList", initWorkList);
                    }

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

                    let isConfirmed = false;

                    helper.apexCall(component, event, helper, 'callOutServiceOrder', { 
                        recordId : component.get("v.serviceData").workOrderId, isConfirmed: isConfirmed, docNoList: component.get("v.deletedFileList"), convertVersionIdList : r.convertFileIds,
                    })
                    .then($A.getCallback(function (result) {
                        let r = result.r;

                        console.log('callOut response all ::: ' ,JSON.stringify(r, null, 2));

                        let resParam = r.resParam;
                        
                        if (resParam.O_RETURN.TYPE == 'S') {
                            helper.toast('SUCCESS', "ERP : " + resParam.O_RETURN.MESSAGE);
                        
                            console.log('callOut response Success ::: ' ,JSON.stringify(r, null, 2));
                            component.set('v.isLoading', false);
                        } else {
                            helper.toast('WARNING', "ERP : " + resParam.O_RETURN.MESSAGE);
                        
                            console.log('callOut response Error ::: ' ,JSON.stringify(r, null, 2));
                            component.set('v.isLoading', false);
                        }
                    }))
                    .catch(error => {
                        helper.toast('ERROR', '데이터 저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                        console.error('Interface Error:', JSON.stringify(error, null, 2));
                        component.set('v.isLoading', false);
                    });
            }))
            .catch(error => {
                helper.toast('ERROR', '데이터 저장에 실패했습니다.');
                console.error('Save Error:', JSON.stringify(error, null, 2));
                component.set('v.isLoading', false);
            });
        } catch (error) {
            console.error('Save Error:', JSON.stringify(error, null, 2));
            helper.toast('ERROR', '알 수 없는 오류가 발생했습니다. 관리자에게 문의해주세요.');
            component.set('v.isLoading', false);
        }
    },

    // 확정 처리
    isConfirmedTrue : function (component, event, helper) {
        try {
            let workOrderId = component.get("v.serviceData").workOrderId;
            let workList = component.get("v.workList");
            let deletedWorkList = component.get("v.deletedWorkList");
            let saveWorkList = JSON.parse(JSON.stringify(workList));
            let orderType = component.get("v.serviceData").serviceReportInfo.workOrderTypeCode;

            var siteManagerPhone = component.get("v.siteManagerPhone");
            var mainWorkerPhone = component.get("v.mainWorkerPhone");
            var staticFieldIds = ["field7", "field8", "field9", "field10"];
            var hasError = false; 
            var fieldsWithError = [];

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
            
            var workerFields = component.find("field1"); 
            if (workerFields) {
                if (!Array.isArray(workerFields)) workerFields = [workerFields]; 
                workerFields.forEach(function(inputField) {
                    var value = inputField.get("v.value");
                    if (!value || value.trim() === "") {
                        $A.util.addClass(inputField, "error-border");
                        hasError = true;
                        fieldsWithError.push(inputField);
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

            if (!allValid) {
                helper.toast('WARNING', `필수값 작성을 완료해주세요.`);
                return
            }

            let baseUrl = window.location.origin;
            let fileList = component.get("v.fileList");
            
            // 직영인 경우에만(내부 CRM에서 서비스리포트 저장하는 경우) 오더타입 801 만 제외 추가
            if (fileList.length === 0 && (component.get("v.isReportBranch") && orderType == "801")) {
                helper.toast('WARNING', '파일이 첨부되지 않았습니다. 파일을 첨부해주세요.');
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
                workOrderResultData : component.get("v.workOrderResultData"),
                workList: saveWorkList,
                deletedWorkList: deletedWorkList,
                deletedFileList: component.get("v.deletedFileList"),
            };

            helper.updateLabelsForConfirmation(component);
            
            component.set('v.isLoading', true);
            
            helper.apexCall(component, event, helper, 'upsertServiceReport', { fieldMap: fieldMap })
                .then($A.getCallback(function (result) {
                    if (!result || !result.r) {
                        throw new Error("Invalid response structure from Apex.");
                    }
                    let r = result.r;
                    console.log('From Apex ::: ', JSON.stringify(r, null, 2));

                    if (r.errorString) {
                        helper.toast('ERROR', '저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                        console.error(r.errorString);
                        component.set('v.isLoading', false);
                        return; 
                    }
                    helper.toast('SUCCESS', '작업 내역이 성공적으로 저장되었습니다.');
                    const searchService = r.searchService;

                    console.log('refresh SearchService ::: ', JSON.stringify(searchService, null, 2));
                    
                    const searchWorkOrderResult = searchService.repairHistoryInfo;
                    if (searchWorkOrderResult) {
                        searchWorkOrderResult.isHoliday = searchService.installTestInfo.isHoliday;
                        component.set("v.workOrderResultData", searchWorkOrderResult);
                    }

                    if (searchService.workList) {
                        let workOrderResultList = searchService.workList;
                        let initWorkList = helper.initResultWorkList(workOrderResultList);
                        helper.sortWorkList(component, workList);
                        component.set("v.workList", initWorkList);
                    }

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

                    let isConfirmed = true;

                    helper.apexCall(component, event, helper, 'callOutServiceOrder', { 
                        recordId : component.get("v.serviceData").workOrderId, isConfirmed: isConfirmed, docNoList: component.get("v.deletedFileList"), convertVersionIdList : r.convertFileIds,
                    })
                    .then($A.getCallback(function (result) {
                        let r = result.r;
                        console.log('callOut response all ::: ' ,JSON.stringify(r, null, 2));

                        let resParam = r.resParam;
                        
                        if (resParam.O_RETURN.TYPE == 'S') {
                            helper.toast('SUCCESS', "ERP : " + resParam.O_RETURN.MESSAGE);
                        
                            console.log('callOut response Success ::: ' ,JSON.stringify(r, null, 2));

                            if (searchService.serviceReportInfo.confirmedDate) {
                                var cmpEvent = component.getEvent("cmpEvent");
                                cmpEvent.setParams({
                                    modalName: 'updateService', 
                                    actionName: 'updateServiceData',
                                    message: searchService  
                                });
                                cmpEvent.fire();
                            }

                            let orderNumber = component.get("v.serviceData").serviceOrderNumber;
                            helper.toast('SUCCESS', '오더번호 :  ' + orderNumber + '  작업 내역 및 표준 공수가 확정되었습니다.');     

                            // IF-SERVICE-050 (확정 IF) 후 업데이트된 확정 처리 일시 상위 컴포넌트(DN_serviceWrapper)로 값 전달
                            if (r.confirmedDate) {
                                var cmpEvent = component.getEvent("cmpEvent");
                                cmpEvent.setParams({
                                    actionName : 'isConfirmed',
                                    message: r.confirmedDate  
                                });
                                cmpEvent.fire();
                            }
                                
                            ["header", "input-card", "read-card"].forEach(function(elementId) {
                                var element = component.find(elementId);
                                if (element) {
                                    $A.util.addClass(element, "confirmed");
                                }
                            });
                            component.set("v.isDisabled", true);
                            component.set("v.isConfirmed", true);
                            component.set('v.isLoading', false);
                        } else {
                            helper.toast('WARNING', "ERP : " + resParam.O_RETURN.MESSAGE);
                        
                            console.log('callOut response Error ::: ' ,JSON.stringify(r, null, 2));
                            component.set('v.isLoading', false);
                        }
                    }))
                    .catch(error => {
                        helper.toast('ERROR', '데이터 저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                        console.error('Interface Error:', JSON.stringify(error, null, 2));
                        component.set('v.isLoading', false);
                    });
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
    
    // 첨부파일 업로드 후처리
    handleUploadFinished : function (component, event, helper) {
        //DealerPotalFileType__c
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
        let fileList = [];
        helper.apexCall(component, event, helper, 'getFileList', {
            recordId : component.get("v.recordId"),
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log(JSON.stringify(r, null, 2), ' >< ==rrrrr');

            r.forEach(element => {
                fileList.push(element);
            });
            component.set("v.fileList", fileList);
        }))
        .catch(function(error) {
            console.log(' error : ' + error.message);
        });
    },

    //파일 삭제
    removeFile : function (component, event, helper) {
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
            // workList[index].worker = message;
            // component.set('v.workList', workList);
            workList[index].worker = message;
            component.set('v.workList.worker', workList[index].worker);

            var workerFields = component.find("field1");
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
})