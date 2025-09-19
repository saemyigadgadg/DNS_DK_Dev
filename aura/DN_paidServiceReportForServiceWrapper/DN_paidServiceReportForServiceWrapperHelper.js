/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-22-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-22-2024   youjin.shim@sbtglobal.com   Initial Version
**/

({
    
    openModal: function (component, event, helper, type, modalType) {
        component.set("v.isLoading", true);

        var componentName = modalType === 'serviceMan' ? "c:DN_serviceManModal" :
                    modalType === 'searchProduct' ? "c:DN_SearchProductNumber" : 
                    "c:DN_ModelSearchModal";
        console.log("componentName ::: ", componentName);
        console.log("modalType ::: ", modalType);
        

        $A.createComponent(componentName,
            {
                'type': type
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

    closeModal : function (component) {
        const modals = [
            'v.brokenAreaModal', 
            'v.phenomenonModal', 
            'v.causeModal', 
            'v.detailActionModal', 
            'v.statusModal'
        ];
    
        modals.forEach(modal => component.set(modal, false));
    },

    // 작업자 모달 닫기
    closeServiceManModal: function (component) {
        var modalContainer = component.find("serviceManModal");
    
        if (modalContainer) {
            modalContainer.set("v.body", []); 
        }
    },

    closeProductNumberModal: function (component) {
        var modalContainer = component.find("searchProductModal");
    
        if (modalContainer) {
            modalContainer.set("v.body", []); 
        }
    },


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
                    workItem.startTime = result.workStartTime.substring(0,5);
                    workItem.endTime = result.workEndTime.substring(0,5);

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

    sortWorkList : function (component) {
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
         
            // return typeA - typeB;
            return 0;
         
        })
        console.log('sort workList ::: ', JSON.stringify(workList, null, 2));
        // component.set('v.workList', workList);         
    },

})