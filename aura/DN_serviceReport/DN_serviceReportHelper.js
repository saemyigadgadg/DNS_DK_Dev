/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-29-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-12-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },
    
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log('Apex MethodName ::: ', methodName,' by ERROR ::: ', errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
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
                    workItem.workDate = result.workDate || '';
                    workItem.workEndDate = result.workEndDate || ''; 
    
                    if (result.workStartTime) {
                        workItem.startTime = result.workStartTime.substring(0, 8); 
                    } else {
                        workItem.startTime = '';
                    }
    
                    if (result.workEndTime) {
                        workItem.endTime = result.workEndTime.substring(0, 8);
                    } else {
                        workItem.endTime = '';
                    }
                    
                    if (result.workTime && result.workTime != "NaN") {
                        workItem.workHours = result.workTime;
                    } else if (result.workTime && result.workTime.includes(':')) {
                        let [hours, minutes] = result.workTime.split(':').map(Number);
                        let decimalHours = hours + minutes / 60;
                        workItem.workHours = (Math.round(decimalHours * 10) / 10).toFixed(1);
                    } else if (workItem.startTime && workItem.endTime) {
                        let start = new Date(`1970-01-01T${workItem.startTime}Z`);
                        let end = new Date(`1970-01-01T${workItem.endTime}Z`);
                        let diffMs = end - start;
                    
                        if (diffMs > 0) {
                            let diffHours = diffMs / (1000 * 60 * 60);
                            workItem.workHours = (Math.round(diffHours * 10) / 10).toFixed(1);
                        } else {
                            workItem.workHours = '';
                        }
                    } else {
                        workItem.workHours = '';
                    }

                    workItem.workType = result.workType || '';
                    workItem.workContent = result.description || '';
                    switch (result.workType) {
                        case 'MV':
                            workItem.workTypeLabel = '이동';
                            break;
                        case 'DN':
                            workItem.workTypeLabel = '진단';
                            break;
                        case 'WK':
                            workItem.workTypeLabel = '작업';
                            break;
                    }
                    
                    if (result.travelHour) {
                        workItem.travelHour     = result.travelHour;
                    }

                    if (result.airTripType) {
                        workItem.airTripType    = result.airTripType;
                    }
    
                    workItem.workId = result.workOrderResultId;
                    workItem.serviceAppointmentId = result.serviceAppointmentId;
                    workItem.saKey = result.saKey;
                    workList.push(workItem);
                }
            }
        }
        console.log('refresh workList ::: ', JSON.stringify(workList, null, 2));
        return workList;
    },
    
    initResultStandardWorkList: function(workOrderResultList) {
        let standardWorkList = [];
    
        if (workOrderResultList && workOrderResultList.length > 0) {
            for (let i = 0; i < workOrderResultList.length; i++) {
                if (workOrderResultList[i].resultType === 'SWT') {
                    let result = workOrderResultList[i];
                    let standardWorkItem = {};
                    standardWorkItem.checkbox     = false;
                    standardWorkItem.breakdownPart = result.breakDownPart ? result.breakDownPart : '';
                    standardWorkItem.standardWorkItem = result.standardWorkItem ? result.standardWorkItem : '';
                    standardWorkItem.standardWorkTime = result.standardWorkTime != null ? result.standardWorkTime : 0;
                    standardWorkItem.standardWorkPeople = result.standardWorkPeople != null ? result.standardWorkPeople : 0;
    
                    standardWorkItem.isChangedStandardWork = result.isChangeStandardWork != null ? result.isChangeStandardWork : false;
                    standardWorkItem.actualWorkTime = result.ActualactualWorkTimeWorkTime__c != null ? result.actualWorkTime : 0;
                    standardWorkItem.actualWorkPeople = result.actualWorkPeople != null ? result.actualWorkPeople : 0;
                    standardWorkItem.changeRequestReason = result.changeRequestReason ? result.changeRequestReason : '';
                    
                    standardWorkItem.standardHourId = result.standardHourId != null ? result.standardHourId : '';
                    standardWorkItem.workId = result.workOrderResultId ? result.workOrderResultId : '';
                    standardWorkItem.isLeftDisabled = true;
                    standardWorkList.push(standardWorkItem);
                }
            }
        }
        return standardWorkList;
    },

    // 확정 시 라벨로 변환
    updateLabelsForConfirmation: function (component) {
        let workList = component.get("v.workList");
        let workDetailOption = component.get("v.workDetailOption");
        let productRequests = component.get('v.productRequests');
        
        workList.forEach(work=> {
            if (work.workType && workDetailOption) {
                const matchedOption = workDetailOption.find(option => option.value == work.workType);
                work.workTypeLabel = matchedOption ? matchedOption.label : work.workType;
            }

        });
        
        productRequests.forEach(product => {
            if (product.ReturnStatus__c && product.returnTargetOptions) {
                const matchedOption = product.returnCategoryOptions.find(option => option.value == product.ReturnStatus__c);
                product.ReturnStatusLabel = matchedOption ? matchedOption.label : product.ReturnStatus__c;
            }
    
            if (product.ReturnType__c && product.returnCategoryOptions) {
                const matchedOption = product.returnCategoryOptions.find(option => option.value == product.ReturnType__c);
                product.ReturnTypeLabel = matchedOption ? matchedOption.label : product.ReturnType__c;
            }
    
            if (product.Reason1__c && product.firstReasonOptions) {
                const matchedOption = product.firstReasonOptions.find(option => option.value == product.Reason1__c);
                product.Reason1Label = matchedOption ? matchedOption.label : product.Reason1__c;
            }
    
            if (product.Reason2__c && product.secondReasonOptions) {
                const matchedOption = product.secondReasonOptions.find(option => option.value == product.Reason2__c);
                product.Reason2Label = matchedOption ? matchedOption.label : product.Reason2__c;
            }
        });
    
        component.set('v.productRequests', productRequests);
    },

    // 작업합계 자동 계산 로직
    updateTotals: function (component) {
        let workOrderResultData = component.get("v.workOrderResultData")|| {};
        component.set("v.workOrderResultData", workOrderResultData) ;
        
        // 작업합계
        let workList = component.get("v.workList");

        let totalWorkTime = 0;
        if (workList) {
            workList.forEach(work => {
                if (work.workType == 'WK') {
                    if (work.workHours) {
                        // let [hours, minutes] = work.workHours.split(":").map(Number);
                        // totalWorkTime += hours + minutes / 60;
                        totalWorkTime += parseFloat(work.workHours);
                    }
                }
            });
        }
        
        // 표준공수 합계
        // 표준 공수 계산식 총 표준공수 = (시간 x 인원) 의 총합
        let standardWorkList = component.get("v.standardWorkList");
        let totalStandardWorkTime = 0;
        if (standardWorkList) {
            standardWorkList.forEach(work => {
                if (work.standardWorkTime && !isNaN(parseFloat(work.standardWorkTime))) {
                    let testWork = work.standardWorkTime * work.standardWorkPeople;
                    totalStandardWorkTime += testWork;   
                }
            });  
        }
        
        let overWork = totalWorkTime - totalStandardWorkTime;

        if (overWork < 0) {
            overWork = 0;
        }
        workOrderResultData.totalWorkTime = parseFloat(totalWorkTime.toFixed(1));
        workOrderResultData.totalStandardWorkTime = parseFloat(totalStandardWorkTime.toFixed(1));
        workOrderResultData.overWork = parseFloat(overWork.toFixed(1));
        
        component.set("v.workOrderResultData", workOrderResultData);
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
  
            const priority = { "MV": 1, "DN": 2, "WK": 3 };
            const typeA = priority[a.workType] || 99; 
            const typeB = priority[b.workType] || 99;
         
            return typeA - typeB; 
         
        })
        component.set('v.workList', workList);         
    },

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
    
})