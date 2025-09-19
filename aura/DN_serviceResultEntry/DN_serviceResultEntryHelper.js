/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-29-2025
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-29-2025   youjin.shim@sbtglobal.com   Initial Version
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

    getUpdateScore : function (component, event, helper) {
        let that = this;
        that.apexCall(component, event, helper, 'getUpdateScore', {
            recordId : component.get("v.recordId"),
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('update Score ::: ', r);
            let serviceData = component.get("v.serviceData");
            serviceData.inspectionScore = r;
            component.set('v.serviceData', serviceData);
        }))
        .catch(function(error) {
            console.log('# getUpdateScore error : ' + error.message);
        });
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
                            workItem.workTypeLabel = '표준외작업';
                            break;
                        case 'WK':
                            workItem.workTypeLabel = '표준작업';
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

    // 리포트 확정 시 작업내역의 작업유형 라벨로 전환
    updateLabelsForConfirmation: function (component) {
        let workList = component.get("v.workList");
        let workDetailOption = component.get("v.workDetailOption");

        workList.forEach(work=> {
            if (work.workType && workDetailOption) {
                const matchedOption = workDetailOption.find(option => option.value == work.workType);
                work.workTypeLabel = matchedOption ? matchedOption.label : work.workType;
            }

        });
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
})