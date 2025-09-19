/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-29-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-15-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    apexCall : function( component, event, helper, methodName, params ) {
        let self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    closeModal: function (component) {
        var modalContainer = component.find("serviceManModal");
    
        if (modalContainer) {
            modalContainer.set("v.body", []); 
        }
    },

    initResultWorkList: function (workOrderResultList) {
        let workList = [];
    
        if (workOrderResultList && workOrderResultList.length > 0) {
            for (let i = 0; i < workOrderResultList.length; i++) {
                if (workOrderResultList[i].resultType === 'WH') {
                    let result = workOrderResultList[i];
                    
                    let workItem = {};
    
                    workItem.checkbox = false;
                    workItem.worker = result.worker;
                    workItem.workDate = result.workDate;
                    workItem.workEndDate = result.workEndDate || '';
                    workItem.startTime = result.workStartTime.substring(0,5);
                    workItem.endTime = result.workEndTime.substring(0,5);
                    
                    workItem.workId = result.workOrderResultId;
                    workItem.serviceAppointmentId = result.serviceAppointmentId;
                    workItem.saKey = result.saKey;
                    workList.push(workItem);
                }
            }
        }
        return workList;
    },
    
    initResultDefectList: function(workOrderResultList) {
        let defectList = [];
        
        if (workOrderResultList && workOrderResultList.length > 0) {
            for (let i = 0; i < workOrderResultList.length; i++) {
                if(workOrderResultList[i].resultType === 'ITD') {
                    let result = workOrderResultList[i];
                    let defectItem = {};
        
                    defectItem.type         = result.defectType ? result.defectType : '';
                    defectItem.content      = result.defectDetail ? result.defectDetail : '';
                    defectItem.actionTaken  = result.defectAction ? result.defectAction : '';
                    defectItem.remarks      = result.note ? result.note : '';
                    defectItem.workId       = result.workOrderResultId ? result.workOrderResultId : '';
        
                    defectList.push(defectItem);
                }   
            }
        }
        return defectList;
    },
    
    // 총 설치시간 처리
    updateTotalInstallTime: function(component) {
        // let serviceData = component.get("v.serviceData").serviceReportInfo;
        let workOrderResultData = component.get("v.workOrderResultData");
        console.log('test before set ::: ' , JSON.stringify(workOrderResultData, null, 2));
        workOrderResultData.totalInstallTime = 0;
        component.set("v.workOrderResultData", workOrderResultData);

        // 총 설치시간
        let totalInstallTime = parseFloat(workOrderResultData.mainInstallTime) || 0;
        
        // 총 입력시간
        let totalInputTime = parseFloat(workOrderResultData.mainInstallTime) || 0;

        // 가설치시간 반영
        if (workOrderResultData.isTemporaryInstall) {
            totalInstallTime += parseFloat(workOrderResultData.tempInstallTime) || 0;
            totalInputTime += parseFloat(workOrderResultData.tempInstallTime) || 0;
        }

        // 사양 설치시간 반영
        if (workOrderResultData.specInstallTime) {
            totalInstallTime += parseFloat(workOrderResultData.specInstallTime) || 0;
            totalInputTime += parseFloat(workOrderResultData.specInstallTime) || 0;
        }

        // 설치시간의 경우 공휴일 계산 전 *1.5 적용
        let savetotalInstallTime = totalInstallTime * 1.5;
        console.log('totalInstallTime ::: ',totalInstallTime);
        console.log('savetotalInstallTime ::: ',savetotalInstallTime);
    
        // 공휴일 추가 계산
        if (workOrderResultData.isHoliday) {
            savetotalInstallTime *= 1.5;
        }

        // 업데이트된 총 설치시간 및 입력시간 설정
        workOrderResultData.totalInstallTime = parseFloat(savetotalInstallTime);
        workOrderResultData.totalInputTime = parseFloat(totalInputTime);
        component.set("v.workOrderResultData", workOrderResultData);
    },

    // 사양설치 시간 처리
    updateSpecInstallTime: function(component) {
        // let serviceData = component.get("v.serviceData").serviceReportInfo;
        let workOrderResultData = component.get("v.workOrderResultData");
        let specTime = 0;
    
        // 사양 설치 시간 계산
        const specValues = {
            isFenseApcCover: workOrderResultData.fenseApcCover,     
            isSemiSplashGuard: workOrderResultData.semiSplashGuard,   
            isOverTools: workOrderResultData.overTools,         
            isPMG: workOrderResultData.pmgTime,               
            isAAC: workOrderResultData.accTime,                
        };
    
        Object.keys(specValues).forEach(key => {
            if (workOrderResultData[key]) {
                specTime += specValues[key];
            }
        });
    
        // 기타 시간 포함
        if (workOrderResultData.isEtc) {
            specTime += parseFloat(workOrderResultData.etcTime) || 0;
        }
    
        // 업데이트된 사양 설치시간 설정
        workOrderResultData.specInstallTime = parseFloat(specTime);
        component.set("v.workOrderResultData", workOrderResultData);
    
        console.log("Updated Spec Install Time ::: ", JSON.stringify(specTime));
    },

    // 작업 내역 정렬
    sortWorkList : function (component, workList) {
        workList.sort(function (a, b) {
            var nameA = a.worker.Name.toUpperCase();
            var nameB = b.worker.Name.toUpperCase();

            if (nameA < nameB) return -1;
            if (nameA > nameB) return 1;

            if (a.workDate > b.workDate) return 1;
            if (a.workDate < b.workDate) return -1;

            if (a.startTime > b.startTime) return 1;
            if (a.startTime < b.startTime) return -1;
  
            // const priority = { "MV": 1, "DN": 2, "WK": 3 };
            // const typeA = priority[a.workType] || 99; 
            // const typeB = priority[b.workType] || 99;
         
            // return typeA - typeB; 
            return 0;
         
        })
        
        component.set('v.workList', workList);         
    },

    
    //핸드폰 번호, 지역번호 validation
    isSaveValidPhoneNumber: function(phone) {
        const cleaned = phone.replace(/[^0-9\-]/g, '');

        const mobilePattern = /^01[016789]-\d{4}-\d{4}$/;        // 휴대폰
        const seoulPatternShort = /^02-\d{3}-\d{4}$/;            // 서울 2-3-4
        const seoulPatternLong = /^02-\d{4}-\d{4}$/;             // 서울 2-4-4
        const localPatternShort = /^0\d{2}-\d{3}-\d{4}$/;        // 지방 3-3-4
        const localPatternLong = /^0\d{2}-\d{4}-\d{4}$/;         // 지방 3-4-4

        return (
            mobilePattern.test(cleaned) ||
            seoulPatternShort.test(cleaned) ||
            seoulPatternLong.test(cleaned) ||
            localPatternShort.test(cleaned) ||
            localPatternLong.test(cleaned)
        );
    }

                // 작업 목록 정렬 (이미 helper.sortWorkList가 있으나, 필요 시 아래와 같이 정렬도 가능)
            // saveWorkList.sort((a, b) => {
            //     // 작업자 ID 기준 정렬
            //     if (a.worker.Id < b.worker.Id) return -1;
            //     if (a.worker.Id > b.worker.Id) return 1;
                
            //     // 작업 시작일 기준 정렬 ("yyyy-MM-dd" 포맷)
            //     if (a.workDate < b.workDate) return -1;
            //     if (a.workDate > b.workDate) return 1;
                
            //     // 작업 시작시간 기준 정렬 (밀리초 부분 제거)
            //     let aStart = a.startTime ? a.startTime.substring(0, 8) : "00:00:00";
            //     let bStart = b.startTime ? b.startTime.substring(0, 8) : "00:00:00";
            //     return aStart.localeCompare(bStart);
            // });
    
})