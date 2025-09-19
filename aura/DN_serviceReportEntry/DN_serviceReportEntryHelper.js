/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-20-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-15-2025   youjin.shim@sbtglobal.com   Initial Version
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
                        console.log(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    closeModal: function (component, modalName) {
        if(modalName === 'DN_serviceManModal') {
            var modalContainer = component.find("serviceManModal");
        } else if (modalName === 'DN_SearchProductNumber') {
            var modalContainer = component.find("searchProductModal");
        }
        
    
        if (modalContainer) {
            modalContainer.set("v.body", []); 
        }
    },

    openModal: function (component, event, helper, type, modalType) {
        component.set("v.isLoading", true);
        
        if (event && (type === '호기' || type === '부품번호')) {
            var rowIndex = event.getSource().get('v.accesskey');
            var indexAttr = 'v.selectedPartsIndex';
            component.set(indexAttr, Number(rowIndex));
            console.log('rowIndex', rowIndex);
        }

        var componentName =  "c:DN_SearchProductNumber";

        console.log("componentName ::: ", componentName);
        console.log("modalType ::: ", modalType);
        
        $A.createComponent(componentName,
            {
                'type': type,
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find(modalType + "Modal");
                    console.log("type", type);
                    container.set("v.body", content);
                    console.log("container", container);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        
        component.set("v.isLoading", false);
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
                // if (work.workType == 'WK') {
                    if (work.workHours) {
                        let [hours, minutes] = work.workHours.split(":").map(Number);
                        totalWorkTime += hours + minutes / 60;
                    // }
                }
            });
        }
        console.log("test total ::: ", totalWorkTime);
        component.set("v.workOrderResultData", workOrderResultData);
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
                    workItem.startTime = result.workStartTime.substring(0,5);
                    workItem.endTime = result.workEndTime.substring(0,5);
                    workItem.travelHour = result.travelHour;
                    workItem.airTripType = result.airTripType;
                    if (result.workTime) {
                        workItem.workHours = result.workTime.substring(0,5);
                    } else {
                        workItem.workHours = '';
                    }

                    if (result.description) {
                        workItem.workContent = result.description;
                    }
                    
                    workItem.workId = result.workOrderResultId;
                    workItem.serviceAppointmentId = result.ServiceAppointment__c;
                    workList.push(workItem);
                }
            }
        }
        return workList;
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
        }

        return usageList;
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
        // component.set('v.workList', workList); 
        return workList;        
    },
})