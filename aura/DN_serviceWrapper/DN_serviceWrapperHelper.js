/**
 * @description       : 
 * @author            : jiyoung.p@dncompany.com
 * @group             : 
 * @last modified on  : 2025-09-18
 * @last modified by  : jiyoung.p@dncompany.com
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

    numberOnlyCheck : function (number) {
        if (!number) return false;
        let result = /^[0-9]*$/;
        return result.test(number);
    },

    initResultWorkList: function (workOrderResultList, templateNumber, isBranch) {
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
                        workItem.startTime = result.workStartTime.substring(0, 5) + ':00';
                    } else {
                        workItem.startTime = '';
                    }
                    
                    if (result.workEndTime) {
                        workItem.endTime = result.workEndTime.substring(0, 5) + ':00';
                    } else {
                        workItem.endTime = '';
                    }                    
                    
                    if (workItem.startTime == workItem.endTime) {
                        workItem.workHours = '0';
                    }
                    else if (result.workTime && result.workTime != "NaN") {
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

                    // if (isBranch && (templateNumber == 'RT04' || templateNumber == 'RT05')) {
                    //     switch (result.workType) {
                    //         case 'MV':
                    //             workItem.workTypeLabel = '이동';
                    //             break;
                    //         case 'DN':
                    //             workItem.workTypeLabel = '표준외작업';
                    //             break;
                    //         case 'WK':
                    //             workItem.workTypeLabel = '표준작업';
                    //             break;
                    //     }
                    // } else {
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
                    // }
                    
                    if (result.travelHour) {
                        workItem.travelHour     = result.travelHour;
                    }

                    if (result.airTripType) {
                        workItem.airTripType    = result.airTripType;
                    }

                    workItem.isHoliday      = result.isHoliday;

                    workItem.workId = result.workOrderResultId;
                    workItem.serviceAppointmentId = result.serviceAppointmentId;
                    workItem.saKey = result.saKey;
                    workList.push(workItem);
                }
            }
        }
        console.log('search workList ::: ', JSON.stringify(workList, null, 2));
        return workList;
    },

    
    initResultDefectList: function(workOrderResultList) {
        let defectList = [];
    
        if (workOrderResultList && workOrderResultList.length > 0) {
            for (let i = 0; i < workOrderResultList.length; i++) {
                if(workOrderResultList[i].resultType === 'ITD') {
                    let result = workOrderResultList[i];
                    let defectItem = {};
                    
                    defectItem.checkbox     = false;
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

    initResultUsagePartsList: function(searchProductRequestList) {
        let usageList = [];
    
        if (searchProductRequestList && searchProductRequestList.length > 0) {
            for (let i = 0; i < searchProductRequestList.length; i++) {
                if (searchProductRequestList[i].resultType === 'PT') {
                    let result = searchProductRequestList[i];
                    let usageItem = {};

                    usageItem.productCode       = result.productCode;
                    usageItem.productName       = result.productName;
                    usageItem.isCause           = result.isCause;
                    usageItem.quantity          = result.quantity != null ? result.quantity : 0;
                    usageItem.returnNote        = result.returnNote != null ? result.returnNote : '';
    
                    usageItem.workId = result.workOrderResultId ? result.workOrderResultId : '';
                    usageList.push(usageItem);
                }
            }
            console.log('test ::: ' , JSON.stringify(usageList, null, 2));
        }

        return usageList;
    },

    productPicklistSet: function(component, searchProductRequestList) {
        return new Promise((resolve, reject) => {
            if (!searchProductRequestList || searchProductRequestList.length === 0) {
                console.log('No product requests found');
                resolve([]);
                return;
            }
    
            let productRequests = [];
            let promises = [];
    
            searchProductRequestList.forEach(record => {
                if (record.ReturnStatus__c) {
                    promises.push(this.getPicklistValues(component, 'returnStatus', record.ReturnStatus__c).then(result => {
                        record.returnCategoryOptions = result;
                        record.ReturnStatusLabel = record.ReturnStatus__c == 'Y' ? '예' : '아니오';
                        
                    }));
                }

                if (record.ReturnStatus__c == 'Y' && !record.ReturnType__c) {
                    record.ReturnType__c = '2';
                }
    
                if (record.ReturnType__c) {
                    promises.push(this.getPicklistValues(component, 'returnType', record.ReturnType__c).then(result => {
                        record.firstReasonOptions = result;
                        let matchedOption = record.returnCategoryOptions.find(option => option.value == record.ReturnType__c);
                        record.ReturnTypeLabel = matchedOption ? matchedOption.label : record.ReturnType__c;
                    }));
                } 
    
                if (record.Reason1__c) {
                    promises.push(this.getPicklistValues(component, 'firstReason', record.Reason1__c).then(result => {
                        record.secondReasonOptions = result;
                        let matchedOption1 = record.firstReasonOptions.find(option => option.value == record.Reason1__c);
                        record.Reason1Label = matchedOption1 ? matchedOption1.label : record.Reason1__c;

                        if (record.Reason2__c) {
                            let matchedOption2 = record.secondReasonOptions.find(option => option.value == record.Reason2__c);
                            record.Reason2Label = matchedOption2 ? matchedOption2.label : record.Reason2__c;
                        }
                    }));
                }
    
                productRequests.push(record);
            });
    
            Promise.all(promises)
                .then(() => {
                    component.set('v.productRequests', productRequests);
                    resolve(productRequests);
                })
                .catch(error => {
                    console.error('Error occurred:', error);
                    reject(error);
                });
        });
    },
    
    getPicklistValues: function(component, fieldName, fieldValue) {
        return new Promise((resolve, reject) => {
            let action = component.get("c.getPicklistValueList");
            action.setParams({ fieldValue, fieldName });
    
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    console.error('Error:', errors);
                    reject(errors);
                }
            });
    
            $A.enqueueAction(action);
        });
    },
    
    // Component Reset
    resetComponent: function(component) {
        component.set("v.workList", []);
        component.set("v.selectAllWorkList", false); //1
        component.set("v.defectList", []);
        component.set("v.selectAllDefectList", false); //1
        component.set("v.standardWorkList", []);
        component.set("v.usageList", []);
        component.set("v.productRequests", []);
        component.set("v.commonParts", []);
        component.set("v.selectAllStandardWorkList", false); //1
        component.set("v.siteManager", "");
        component.set("v.siteManagerPhone", "");
        component.set("v.mainWorker", "");
        component.set("v.mainWorkerPhone", "");
        component.set("v.isCustomerChecked", false);
        component.set("v.isSiteManagerChecked", false);
        component.set("v.multiPicklistValues", []);
        component.set("v.serviceData", {});
        component.set("v.workOrderResultData", {});
        component.set("v.templateNumber", "");
        component.set("v.isTypeCheck", false);
        component.set("v.isConfirmed", false);
        component.set("v.isDisabled", false);
        component.set("v.repairActionGroupCode", '');
        component.set("v.confirmedDate", "");
    },
})