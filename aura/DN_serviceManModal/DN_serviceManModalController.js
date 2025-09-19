/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-22-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-08-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({  
    // 작업자 모달 Init
    doInit : function (component, event, helper){
        let workOrderId = component.get("v.workOrderId");
        let curruntWorkcenterId = component.get("v.curruntWorkcenterId");
        let searchType = component.get("v.type");
        let isBranch = component.get("v.isBranch");
        console.log('searchType', searchType);
        let action = component.get("c.getLoginUserInfo");

        if (workOrderId && searchType != 'DNSA') {
            action.setParams({ "recordId" : workOrderId , "type" : searchType });
            action.setCallback(this, function(response) {
                let r = response.getReturnValue();
                console.log('response ServiceReport ::: ', JSON.stringify(r, null, 2));
                
                if (r.flag == "success") {
                    component.set("v.workerList", r.workerInfoList);
                    component.set("v.curruntWorkcenter",r.workerInfoList[0].workCenterName);
                } else if (r.flag == "warning") {
                    helper.toast('WARNING', '작업자가 존재 하지 않습니다.');
                    component.set('v.curruntWorkcenter','');
                } else {
                    helper.toast('Error', 'An error occurred, please contact your administrator.');
                    console.log('Error ::: ',r.getMessage);
                }
            });
            $A.enqueueAction(action);

        } else if (workOrderId && searchType == 'DNSA') {
            action.setParams({ "recordId" : curruntWorkcenterId , "type" : 'DNSA' });
            action.setCallback(this, function(response) {
                let r = response.getReturnValue();
                console.log('response DNSA ::: ', JSON.stringify(r, null, 2));
                
                if (r.flag == "success") {
                    component.set("v.workerList", r.workerInfoList);
                    component.set("v.curruntWorkcenter",r.workerInfoList[0].workCenterName);
                } else if (r.flag == "warning") {
                    helper.toast('WARNING', 'There are currently no work centers to which we belong. (DNSA)');
                    component.set('v.curruntWorkcenter','');
                } else {
                    helper.toast('Error', 'An error occurred, please contact your administrator.');
                    console.log('Error ::: ',r.getMessage);
                }
            });
            $A.enqueueAction(action);

        } else { 
            action.setParams({ "recordId" : curruntWorkcenterId , "type" : '', "isBranch" : isBranch});
            action.setCallback(this, function(response) {
                let r = response.getReturnValue();
                console.log('response 지사 or 대리점 ::: ', JSON.stringify(r, null, 2));
                
                if (r.flag == "success") {
                    component.set("v.workerList", r.workerInfoList);
                    component.set("v.curruntWorkcenter", r.workerInfoList[0].workCenterName);
                    component.set("v.curruntWorkcenterId", r.workerInfoList[0].workCenterId);
                    if (r.workerInfoList.workCenterDivision == '지사') {
                        component.set("v.isBranch", true);
                    }
                    
                } else if (r.flag == "warning") {
                    helper.toast('WARNING', '존재하는 작업자가 없습니다.');
                    component.set('v.curruntWorkcenter','');
                } else {
                    helper.toast('Error', 'An error occurred, please contact your administrator.');
                    console.log('Error ::: ',r.getMessage);
                }
            });
            $A.enqueueAction(action);
        }
    },

    // 워크센터 모달 열기 
    openDealerModal : function(component, event, helper) {
        component.set('v.inputModalOpen', true);
        let workCenterId = component.get('v.curruntWorkcenterId');
        
        helper.apexCall(component, event, helper, 'getCurruntWorkCenter', { workCenterId : workCenterId })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('response ::: ', JSON.stringify(r, null, 2));
    
            if(r.flag == 'success') {
                component.set('v.workCenterList',  r.workCenterList);
                
            } else if(r.flag == 'warning') {
                helper.toast('WARNING', 'There are currently no work centers to which we belong.');
                component.set('v.workCenterList','');
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# WorkCenter Search error : ' + error.message);
            component.set('v.isLoading', false);
        });
        
    },

    // 작업자 선택 이벤트
    rowClick: function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var workerList = component.get('v.workerList');
        // 인터페이스 완료 후 텍스트 값이 아닌 작업자 고유 코드 값으로 변경 필요
        // var worker = workerList[index].Name;
        var worker = workerList[index];
        console.log('worker ::: ', JSON.stringify(worker, null, 2));
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : "DN_serviceManModal",
            "actionName" : "Close",
            "message" : worker
        });
        cmpEvent.fire();
        
        helper.closeModal(component);
    },

    // 워크센터 선택 이벤트
    sendWorkInfo: function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
  
        var workCenterList = component.get('v.workCenterList');
        // 인터페이스 완료 후 텍스트 값이 아닌 W/C 고유 코드 값으로 변경 필요
        var workCenterId = workCenterList[index].Id;

        helper.apexCall(component, event, helper, 'getNewWorkers', { workCenterId : workCenterId })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('new Workers ::: ', JSON.stringify(r, null, 2));
    
            if(r.flag == 'success') {
                component.set("v.workerList", r.newWorkerList);
                
            } else if(r.flag == 'warning') {
                helper.toast('WARNING', 'There are currently no work centers to which we belong.');
                component.set('v.workerList','');
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# WorkCenter Search error : ' + error.message);
            component.set('v.isLoading', false);
        });
        
        component.set('v.inputModalOpen', false);
    },

    //워크센터 모달 닫기
    closeDealerModal : function(component, event, helper) {
        component.set('v.inputModalOpen', false);
    },

    //서비스맨 모달 닫기
    modalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    
})