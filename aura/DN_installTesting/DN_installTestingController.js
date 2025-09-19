/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-12-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-12-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({ 
    doInit: function(component, event, helper) {
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
    
    // 가설치시간 및 공휴일 체크박스 관리
    handleCheckboxChange: function(component, event, helper) {
        const fieldName = event.getSource().get("v.name");
        const isChecked = event.getSource().get("v.checked");
        let workOrderResultData = component.get("v.workOrderResultData");
    
        if (fieldName === "isTemporaryInstall" && isChecked) {
            workOrderResultData.isHoliday = false;
            helper.toast("info", "가설치가 적용되는 대형장비에 대해서는 휴일 적용이 불가합니다.");
        } else if (fieldName === "isHoliday" && isChecked) {
            workOrderResultData.isTemporaryInstall = false;
            helper.toast("info", "공휴일 여부를 선택했습니다. 가설치시간은 비활성화됩니다.");
        }
    
        workOrderResultData[fieldName] = isChecked;
        component.set("v.workOrderResultData", workOrderResultData);
        console.log('ttest', component.get('v.workOrderResultData'));
        helper.updateTotalInstallTime(component);
    },

    // 사양 설치 관련 체크박스 로직
    handleSpecCheckboxChange: function(component, event, helper) {
        const fieldName = event.getSource().get("v.name");
        const isChecked = event.getSource().get("v.checked");
        let workOrderResultData = component.get("v.workOrderResultData");
    
        workOrderResultData[fieldName] = isChecked;
        component.set("v.workOrderResultData", workOrderResultData);
    
        helper.updateSpecInstallTime(component);
        helper.updateTotalInstallTime(component);
    },
    
    // 기타 시간 변경 시 로직
    handleOtherInstallTimeChange: function(component, event, helper) {
        let workOrderResultData = component.get("v.workOrderResultData");
        const value = parseFloat(event.getSource().get("v.value")) || 0;
        workOrderResultData.etcTime = value;

        component.set("v.workOrderResultData", workOrderResultData);

        helper.updateSpecInstallTime(component); 
        helper.updateTotalInstallTime(component);
    },
    
    // 설치완료일 < 설치시운전 완료일 Validation
    handleInstallTestCompleteChange: function (component, event, helper) {
        const installationFinish = component.get("v.serviceData.serviceReportInfo.installationFinish"); 
        const installTestComplete = component.get("v.installTestComplete"); 
    
        if (installTestComplete && new Date(installTestComplete) < new Date(installationFinish)) {
            helper.toast("WARNING", "설치완료일보다 시운전 완료일이 작을 수 없습니다.");
            component.set("v.installTestComplete", ""); 
        }
    },    
    
    /////////////////workList///////////////
    //workList 추가
    addWorkList : function(component, event, helper) {
        var workList = component.get("v.workList");
        let newWorkList = {
            checkbox: false,       
            worker: "",            
            workDate: "",
            startTime: "",
            workEndDate: "",         
            endTime: "",           
            workHours: "",         
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

    //workList th 체크박스 선택 시 td 체크박스 선택
    toggleWorkAllCheckboxes: function(component, event, helper) {
        var selectAll = component.get("v.selectAllWork");
        var workList = component.get("v.workList");
        for (var i = 0; i < workList.length; i++) {
            workList[i].checkbox = selectAll;
        }
        component.set("v.workList", workList);
    },

    toggleWorkSelectAll: function(component, event, helper) {
        let allChecked = component.get("v.workList").every(item => item.checkbox);
        component.set("v.selectAll", allChecked);
    },


    /////////////////defectList///////////////
    //defectList 추가
    addDefectList: function (component, event, helper) {
        var defectList = component.get("v.defectList");
        let newDefectList = {
            type: "",        
            content: "",    
            actionTaken: "",
            remarks: "",
            workId: "" 
        };
        defectList.push(newDefectList);
        component.set("v.defectList", defectList);
    },

    deleteDefectList: function (component, event, helper) {
        try {
            let defectList = JSON.parse(JSON.stringify(component.get("v.defectList"))) || [];
            let deletedWorkList = component.get("v.deletedWorkList") || [];
    
            console.log("Before workList ::: ", JSON.stringify(defectList, null, 2));
    
            for (let i = defectList.length - 1; i >= 0; i--) {
                if (defectList[i].checkbox) {
                    deletedWorkList.push(defectList[i].workId);
                    defectList.splice(i, 1);
                }
            }
    
            console.log("After defectList ::: ", JSON.stringify(defectList, null, 2));
            console.log("Deleted items ::: ", JSON.stringify(deletedWorkList, null, 2));
    
            component.set("v.deletedWorkList", deletedWorkList);
            component.set("v.defectList", []);
            component.set("v.defectList", defectList);
        } catch (error) {
            helper.toast("ERROR", "작업내역 리스트를 수정 중 오류가 발생했습니다.");
            console.error("Deleted workList Error ::: ", error);
        }
    },

    //workList checkbox 선택시 전체 선택 
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
            // helper.updateTotals(component);
        }
    },

    // defectList checkbox 선택시 전체 선택 
    handleDefectCheckboxChange: function(component, event, helper) {
        let defectList = component.get("v.defectList");
        let allChecked = defectList.every(item => item.checkbox);
        component.set("v.selectAllDefectList", allChecked);
    },
    toggleAllDefectCheckboxes: function(component, event, helper) {
        let isChecked = component.get("v.selectAllDefectList");

        let defectList = component.get("v.defectList");
        if (defectList) {
            defectList.forEach(item => item.checkbox = isChecked);
            component.set("v.defectList", defectList);
            // helper.updateTotals(component);
        }
    },

    // 고객사 준비상태 선택된 값 List
    handlePreparationOptionsChange: function (component, event, helper) {
        let selectedValues = event.getParam("value");
        component.set("v.value", selectedValues); 
    
        let workOrderResultData = component.get("v.workOrderResultData") || {};
        
        workOrderResultData.preparationOptions = selectedValues ? selectedValues.join(';') : '';
        component.set("v.workOrderResultData", workOrderResultData);
    
        console.log("Updated Preparation Options ::: ", workOrderResultData.preparationOptions);
        console.log("Updated workOrderResultData ::: ", JSON.stringify(component.get("v.workOrderResultData")));
    },

    // 설치 시운전 완료일 Validation
    handleinstallationFinishChange: function (component, event, helper) {
        let applicationDateTime = component.get("v.serviceData.serviceReportInfo.applicationDateTime");
        let installTestFinish = component.get('v.workOrderResultData').installationFinish;

        let today = new Date();
        today.setHours(0, 0, 0, 0); 
        let toadayDateOnly = today.toISOString().split("T")[0];

        let installTestDate = new Date(installTestFinish);
        installTestDate.setHours(0, 0, 0, 0);
        let installDateOnly = installTestDate.toISOString().split("T")[0];

        let applicationDate = new Date(applicationDateTime);
        applicationDate.setHours(0, 0, 0, 0);
        let applicationDateOnly = applicationDate.toISOString().split("T")[0];
        
        // if (applicationDateOnly > installDateOnly) {
        //     helper.toast('WARNING', '설치 시운전 완료일은 접수일과 같거나 커야 합니다.');
        //     component.set('v.workOrderResultData.installationFinish', '');
        //     return;
        // }

        if (installDateOnly > toadayDateOnly) {
            helper.toast('WARNING', '설치시운전 완료일은 오늘보다 작거나 같아야 합니다.');
            component.set('v.workOrderResultData.installationFinish', toadayDateOnly);
            return;
        } 
        
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
    
    // 작업내역 Validation 수정 중 
    handleWorkChange: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var workList = component.get('v.workList');
        var work = workList[index];       

        let workStartDate = work.workDate;
        let workEndDate = work.workEndDate;
        let startTime = work.startTime;
        let endTime = work.endTime;
        let applicationDateTime = component.get("v.serviceData.serviceReportInfo.applicationDateTime");
        let installationFinish = component.get("v.workOrderResultData.installationFinish");
        console.log('설치 시운전 완료일 ::: ', installationFinish);

        // 오늘 날짜 및 현재 시간
        let today = new Date();
        today.setHours(0, 0, 0, 0); 
        let convertTodayDate    = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');

        let currentDateTime = new Date();
        let currentHours    = String(currentDateTime.getHours()).padStart(2, '0');
        let currentMinutes  = String(currentDateTime.getMinutes()).padStart(2, '0');
        let currentSeconds  = String(currentDateTime.getSeconds()).padStart(2, '0');
        let currentTime     = `${currentHours}:${currentMinutes}:${currentSeconds}`;

        // 작업 시작일
        let convertWorkStartDateTime = new Date(workStartDate);
        convertWorkStartDateTime.setHours(0, 0, 0, 0); 
        let convertWorkStartDate     = convertWorkStartDateTime.getFullYear() + '-' + String(convertWorkStartDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertWorkStartDateTime.getDate()).padStart(2, '0');

        // 작업 종료일
        let convertWorkEndDateTime = new Date(workEndDate);
        convertWorkEndDateTime.setHours(0, 0, 0, 0); 
        let convertWorkEndDate     = convertWorkEndDateTime.getFullYear() + '-' + String(convertWorkEndDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertWorkEndDateTime.getDate()).padStart(2, '0');

        // 접수일 / 접수시간
        let convertAppDateTime  = new Date(applicationDateTime);
        let convertAppDate      = convertAppDateTime.getFullYear() + '-' + String(convertAppDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertAppDateTime.getDate()).padStart(2, '0');

        let hours               = String(convertAppDateTime.getHours()).padStart(2, '0');
        let minutes             = String(convertAppDateTime.getMinutes()).padStart(2, '0');
        let seconds             = String(convertAppDateTime.getSeconds()).padStart(2, '0');
        let convertAppTimeOnly  = `${hours}:${minutes}:${seconds}`; 

        console.log('convertWorkStartDate ::: ',convertWorkStartDate);
        console.log('convertWorkEndDate ::: ',convertWorkEndDate);
        console.log('installationFinish ::: ', installationFinish);

        if (!applicationDateTime) {
            helper.toast('ERROR', '접수일시에 대한 정보가 존재하지 않습니다.');
            return;
        } 
        
        if (!installationFinish) {
            helper.toast('WARNING', '설치 시운전 완료일 먼저 입력해주세요.');
            return;
        } else {
            // if (installationFinish < convertAppDate || installationFinish < convertAppDate) {
            //     helper.toast('WARNING', '접수일시 이전의 설치 시운전 완료일은 입력할 수 없습니다.');
            //     let cancelInstallationFinish = "";
            //     component.set("v.workOrderResultData.installationFinish", cancelInstallationFinish);
            //     return;
            // }

            if (convertWorkStartDate < convertAppDate || convertWorkEndDate < convertAppDate) {
                helper.toast('WARNING', '접수일시 이전의 작업일은 입력할 수 없습니다.');
                work.workDate    = convertAppDate;
                work.workEndDate = convertAppDate;
                component.set("v.workList", workList);
                return;
            }

            if (convertWorkStartDate > today) {
                helper.toast('WARNING', '오늘 날짜보다 작업 시작일이 작거나 같아야 합니다.');
                work.workDate    = convertTodayDate;
                component.set("v.workList", workList);
                return;
            } 

            if (convertWorkEndDate > today) {
                helper.toast('WARNING', '오늘 날짜보다 작업 종료일이 작거나 같아야 합니다.');
                work.workEndDate = convertTodayDate;
                component.set("v.workList", workList);
                return;
            } 

            if (convertWorkStartDate && convertWorkStartDate > installationFinish) {
                console.log('작업 시작일 ::: ',convertWorkStartDate);
                console.log('설치시운전 완료일 ::: ',installationFinish);
                helper.toast('WARNING', '작업 시작일은 설치시운전 완료일 보다 작거나 같아야 합니다.');
                work.workDate    = installationFinish;
                component.set("v.workList", workList);
            }

            if (convertWorkEndDate && convertWorkEndDate > installationFinish) {
                helper.toast('WARNING', '작업 종료일은 설치시운전 완료일 보다 작거나 같아야 합니다.');
                work.workEndDate    = installationFinish;
                component.set("v.workList", workList);
            }

            if (convertWorkStartDate > convertWorkEndDate) {
                helper.toast('WARNING', '작업 시작일은 작업 종료일 보다 작거나 같아야 합니다.');
                work.workEndDate    = '';
                component.set("v.workList", workList);
                return;
            }
        }

        if (startTime) {
            if (!workStartDate) {
                helper.toast('WARNING', '작업일이 입력되지 않았습니다. 먼저 작업일을 입력해주세요.');
                work.startTime  = "";
                work.endTime    = "";
                work.workHours  = "";
                component.set("v.workList", workList);
                return; 
            }
            
            if (convertWorkStartDate == convertAppDate) {
                if (startTime < convertAppTimeOnly) {
                    helper.toast('WARNING', '작업 시작일과 접수일이 같습니다. 접수 시간 이후 시간으로 시작시간을 입력해주세요.');
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
        
                if (isNaN(start.getTime()) || isNaN(end.getTime())) {
                    helper.toast("ERROR", "시간 형식이 올바르지 않습니다.");
                    return;
                }
        
                if (convertWorkStartDate === convertWorkEndDate && end < start) {
                    helper.toast('WARNING', '작업 시작일과 종료일이 같은 경우 종료시간이 시작시간보다 작을 수 없습니다.');
                    work.endTime = "";
                    work.workHours = "";
                    component.set("v.workList", workList);
                    return;
                }
        
                let fromValue = start.getUTCHours() + (start.getUTCMinutes() / 60);
                let toValue = end.getUTCHours() + (end.getUTCMinutes() / 60);
                let timeDiff = Math.round((toValue - fromValue) * 10) / 10;
        
                work.workHours = timeDiff.toFixed(1);
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
            let workList = component.get("v.workList");
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

            let checkBoxList = component.get("v.checkboxStates");        
            const keys = ["isFenseAPCCover", "isSemiSplashGuard", "isOverTools", "isPMG", "isAAC", "isEtc"]; 

            let checkBoxObject = {};
            for (let i = 0; i < keys.length; i++) {
                checkBoxObject[keys[i]] = checkBoxList[i];
            }

            let workOrderResultData = component.get("v.workOrderResultData");
            let numericFields = [ "etcTime", "mainInstallTime", "specInstallTime", "tempInstallTime", "totalInputTime", "totalInstallTime" ];
    
            numericFields.forEach(field => {
                if (workOrderResultData[field] != null) {
                    workOrderResultData[field] = parseFloat(workOrderResultData[field]); 
                }
            });

            if(!workOrderResultData.installationFinish) {
                helper.toast('WARNING', '설치 시운전 완료일을 입력해 주세요.');
                return;
            }

            if(workOrderResultData.mainInstallTime < 1) {
                helper.toast('WARNING', `설치 표준시간이 없습니다.`);
                return;
            }

            helper.sortWorkList(component, saveWorkList);
            
            for (let i = 0; i < saveWorkList.length - 1; i++) {
                let current = saveWorkList[i];
                let next = saveWorkList[i + 1];
                
                if (current.worker.Id === next.worker.Id && current.workDate === next.workDate) {
                    let currentEnd = current.endTime ? current.endTime.substring(0, 8) : "00:00:00";
                    let nextStart  = next.startTime ? next.startTime.substring(0, 8) : "00:00:00";
                    
                    const toSeconds = (timeStr) => {
                        const [h, m, s] = timeStr.split(':').map(Number);
                        return h * 3600 + m * 60 + s;
                    };
                    let currentEndSec = toSeconds(currentEnd);
                    let nextStartSec  = toSeconds(nextStart);
                    
                    if (currentEndSec > nextStartSec) {
                        helper.toast("WARNING", "작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.");
                        console.log("겹치는 작업 current ::: ", JSON.stringify(current, null,2));
                        console.log("겹치는 작업 next ::: ",  JSON.stringify(next, null,2));
                        return;
                    }
                }
            }

            for (let i = 0; i < saveWorkList.length; i++) {
                let saKey = 'sa' + String(i + 1).padStart(3, '0');
                saveWorkList[i].saKey = saKey;
                console.log('Set saKey ::: ', saKey); 
            }
            

            // 검증 통과 후 작업 목록 업데이트
            component.set("v.workList", []);
            component.set("v.workList", saveWorkList);

            
            let isConfirmed = false;

            let fieldMap = {
                workOrderId: component.get("v.serviceData").workOrderId,
                siteManager : component.get("v.siteManager"),
                siteManagerPhone : component.get("v.siteManagerPhone"),
                mainWorker : component.get("v.mainWorker"),
                mainWorkerPhone : component.get("v.mainWorkerPhone"),
                serviceData : component.get("v.serviceData").serviceReportInfo,
                workOrderResultData : workOrderResultData,
                workList: saveWorkList,
                defectList: component.get("v.defectList"),
                deletedWorkList: component.get("v.deletedWorkList"),
                deletedFileList: component.get("v.deletedFileList"),
                isConfirmed : isConfirmed,
            };
    
            console.log('fieldMap to apex ::: ', JSON.stringify(fieldMap, null, 2));
    
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
                    let searchService = r.searchService;

                    console.log('refresh SearchService ::: ', JSON.stringify(searchService, null, 2));

                    console.log('file log ::: ', JSON.stringify(r.convertFileIds, null, 2));
                    
                    let searchWorkOrderResult = searchService.installTestInfo;

                    if (searchWorkOrderResult) {
                        component.set("v.workOrderResultData", searchWorkOrderResult);
                    }

                    if (searchService.workList) {
                        let workOrderResultList = searchService.workList;
                        let initWorkList = helper.initResultWorkList(workOrderResultList);
                        component.set("v.workList", initWorkList);
                    }
                    if (searchService.defectList) {
                        let workOrderResultList = searchService.defectList;
                        let initDefectList = helper.initResultDefectList(workOrderResultList);
                        component.set("v.defectList", initDefectList);
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
                    helper.toast('ERROR', '데이터 저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                    console.error('Save Error:', error);
                    component.set('v.isLoading', false);
                })
        } catch (error) {
            console.log('handleSave Error :::', JSON.stringify(error, null, 2));
            helper.toast('ERROR', '알 수 없는 오류가 발생했습니다. 관리자에게 문의해주세요.');
            component.set('v.isLoading', false);
        }
    },
    
    // 서비스맨 모달 열기
    openServiceManModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        var type = 'InstallTest';
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

        console.log('index :::', index);
        console.log('Before :::', JSON.stringify(component.get('v.serviceData'), null, 2));

        if (modalName == 'DN_serviceManModal') {
            // workList[index].worker.Id = message.Id;
            // workList[index].worker.IName = message.Name;
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

            console.log('after :::', JSON.stringify(component.get('v.serviceData'), null, 2));
        }
        
        if (actionName === 'Close') {
            helper.closeModal(component);
        }
        console.log('final :::', JSON.stringify(component.get('v.serviceData'), null, 2));
    },

    // IF 후 확정 처리
    isConfirmedTrue: function (component, event, helper) {
        try {
            let workList = component.get("v.workList");
            let fileList = component.get("v.fileList");
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
                return;
            }

            if(fileList.length === 0) {
                helper.toast('WARNING', `확정 전 파일을 첨부해주시기 바랍니다.`);
                return;
            }
    
            let checkBoxList = component.get("v.checkboxStates");        
            const keys = ["isFenseAPCCover", "isSemiSplashGuard", "isOverTools", "isPMG", "isAAC", "isEtc"]; 

            let checkBoxObject = {};
            for (let i = 0; i < keys.length; i++) {
                checkBoxObject[keys[i]] = checkBoxList[i];
            }

            let workOrderResultData = component.get("v.workOrderResultData");
            let numericFields = [ "etcTime", "mainInstallTime", "specInstallTime", "tempInstallTime", "totalInputTime", "totalInstallTime" ];

            if(workOrderResultData.mainInstallTime < 1) {
                helper.toast('WARNING', `설치 표준시간이 없습니다.`);
                return;
            }
            numericFields.forEach(field => {
                if (workOrderResultData[field] != null) {
                    workOrderResultData[field] = parseFloat(workOrderResultData[field]); 
                }
            });

            helper.sortWorkList(component, saveWorkList);
            
            for (let i = 0; i < saveWorkList.length - 1; i++) {
                let current = saveWorkList[i];
                let next = saveWorkList[i + 1];
                
                if (current.worker.Id === next.worker.Id && current.workDate === next.workDate) {
                    let currentEnd = current.endTime ? current.endTime.substring(0, 8) : "00:00:00";
                    let nextStart  = next.startTime ? next.startTime.substring(0, 8) : "00:00:00";
                    
                    const toSeconds = (timeStr) => {
                        const [h, m, s] = timeStr.split(':').map(Number);
                        return h * 3600 + m * 60 + s;
                    };
                    let currentEndSec = toSeconds(currentEnd);
                    let nextStartSec  = toSeconds(nextStart);
                    
                    if (currentEndSec > nextStartSec) {
                        helper.toast("WARNING", "작업시간 구간이 겹치는 데이터가 존재합니다. 작업 시간을 조정하시기 바랍니다.");
                        console.log("겹치는 작업 current ::: ", JSON.stringify(current, null,2));
                        console.log("겹치는 작업 next ::: ",  JSON.stringify(next, null,2));
                        return;
                    }
                }
            }

            for (let i = 0; i < saveWorkList.length; i++) {
                let saKey = 'sa' + String(i + 1).padStart(3, '0');
                saveWorkList[i].saKey = saKey;
                console.log('Set saKey ::: ', saKey); 
            }

            // 검증 통과 후 작업 목록 업데이트
            component.set("v.workList", []);
            component.set("v.workList", saveWorkList);

            let isConfirmed = true;

            let fieldMap = {
                workOrderId: component.get("v.serviceData").workOrderId,
                siteManager : component.get("v.siteManager"),
                siteManagerPhone : component.get("v.siteManagerPhone"),
                mainWorker : component.get("v.mainWorker"),
                mainWorkerPhone : component.get("v.mainWorkerPhone"),
                serviceData : component.get("v.serviceData").serviceReportInfo,
                workOrderResultData : workOrderResultData,
                workList: saveWorkList,
                defectList: component.get("v.defectList"),
                deletedWorkList: component.get("v.deletedWorkList"),
                deletedFileList: component.get("v.deletedFileList"),
                isConfirmed : isConfirmed
            };

            console.log('fieldMap to Apex IF ::: ', JSON.stringify(fieldMap, null, 2));
            
            component.set('v.isLoading', true);

            helper.apexCall(component, event, helper, 'upsertServiceReport', { fieldMap: fieldMap })
                .then($A.getCallback(function (result) {
                if (!result || !result.r) {
                        throw new Error("Invalid response structure from Apex.");
                }
                let r = result.r;

                const searchService = r.searchService;

                console.log('refresh SearchService ::: ', JSON.stringify(searchService, null, 2));

                if (r.errorString) {
                    helper.toast('ERROR', '저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                    console.error(r.errorString);
                    component.set('v.isLoading', false);
                    return; 
                }
                helper.toast('SUCCESS', '작업 내역이 성공적으로 저장되었습니다.');

                console.log('file log ::: ', JSON.stringify(r.convertFileIds, null, 2));

                const searchWorkOrderResult = searchService.installTestInfo;
                if (searchWorkOrderResult) {
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
                component.set('v.deletedFileList', []);
                
                helper.apexCall(component, event, helper, 'callOutServiceOrder', { 
                    recordId : component.get("v.serviceData").workOrderId, isConfirmed: isConfirmed, docNoList: component.get("v.deletedFileList"), convertVersionIdList : r.convertFileIds,
                })
                .then($A.getCallback(function (result) {
                    let r = result.r;
                    
                    console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                    
                    let resParam = r.resParam;
                    let searchService = r.searchService;

                    if (resParam.O_RETURN.TYPE == 'S') {
                        helper.toast('SUCCESS', "ERP : " + resParam.O_RETURN.MESSAGE);
                        
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
                        $A.enqueueAction(component.get('c.handleFileList'));
                        component.set('v.isLoading', false);
                    } else {
                        helper.toast('WARNING', "ERP : " + resParam.O_RETURN.MESSAGE);
                    
                        console.log('response by callOut ::: ' ,JSON.stringify(r, null, 2));
                        component.set('v.isLoading', false);
                    }
                }))
                .catch(error => {
                    helper.toast('ERROR', '데이터 저장 중 오류가 발생했습니다. 관리자에게 문의해주세요.');
                    console.error('IF Error:', JSON.stringify(error, null, 2));
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

    //작업자 지우기
    clearWorker: function (component, event, helper) {
        // let serviceMan = component.get("v.worker");
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

            console.log('res Convert File List ::: ', JSON.stringify(r, null, 2));

            // let currentList = component.get("v.htmFileList") || [];
            // let currentSet = new Set(currentList);
            // let newSet = new Set(r.convertFileIds || []);

            // for (let id of newSet) {
            //     currentSet.add(id); 
            // }

            // component.set("v.htmFileList", Array.from(currentSet));
            console.log("test file ::: ",JSON.stringify(component.get("v.htmFileList"), null, 2));
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
    
    handleDefectChange: function (component, event, helper) {
        var index = event.currentTarget.getAttribute('data-index');
        var defectList = component.get("v.defectList"); 
        var defect = defectList[index];
        
        console.log('Updated ::: ', defect);
    
        component.set("v.defectList", defectList); 
    },

    //Launching Excellence Web 모달 열기
    openExcellenceModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.isModalOpen", true); 
        component.set("v.isLoading", false);
    },

    handleButtonClick : function(component, event, helper) {
        const isDesktop = event.getParams('detail').isDesktop;
        if(isDesktop){
            component.set("v.isModalOpen", false); 
        }
    },

})