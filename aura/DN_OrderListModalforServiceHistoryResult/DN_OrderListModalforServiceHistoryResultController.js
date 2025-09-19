/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 04-28-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-11   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var assetList = component.get('v.assetList');
        var eduTicket = component.get('v.eduTicket');
        console.log('assetList :: ' + JSON.stringify(assetList,null,4));
        console.log('eduTicket :: ' + JSON.stringify(eduTicket,null,4));
    },


    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },

    doSearch : function(component, event, helper) {
        // let assetList = component.get('v.assetList');
        var eduTicket = component.get('v.eduTicket');
        var dealerInfo = component.get('v.dealerInfo');
        let workOrderNumber = component.get('v.workOrderNumber').trim();

        console.log('workOrderNumber :: ' + workOrderNumber);
        
        component.set("v.isLoading", true);
        if(eduTicket) {
            console.log('eduTicket >> ' + eduTicket);
            console.log('dealerInfo.accountId >> ' + dealerInfo.accountId);
            helper.apexCall(component, event, helper, 'searchOrderList', {
                erpNo : workOrderNumber,
                delaerAccId : dealerInfo.accountId
            }).then($A.getCallback(function(result) {
                let r = result.r;
                console.log('오더 번호 >> ' +JSON.stringify(r,null,4));

                if(r.flag == 'success') {
                    if(r.size > 0) {
                        helper.toast('SUCCESS', 'SUCCESS.');
                        component.set("v.workOrderList", r.resultList);
                        component.set("v.isLoading", false);
                    } else {
                        helper.toast('WARNING', 'No records found.');
                        component.set("v.workOrderList", []);
                        component.set("v.isLoading", false);
                    }
                } else {
                    helper.toast('WARNING', 'No records found.');
                    component.set("v.workOrderList", []);
                    component.set("v.isLoading", false);
                }
            }))
            .catch($A.getCallback(function(error) {
                helper.toast('ERROR', '관리자에게 문의 부탁 드립니다.');
                console.log('error >> ' +JSON.stringify(error,null,4));
                component.set("v.isLoading", false);
            }))
        }else {
            helper.apexCall(component, event, helper, 'searchWorkOrderList', {
                workOrderNumber :   workOrderNumber,
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
    
                console.log('response ::: ', JSON.stringify(r, null, 4));
        
                if(r.flag == 'success') {
                    if(r.size > 0) {
                        helper.toast('SUCCESS', 'SUCCESS.');
                        component.set("v.workOrderList", r.resultList);
                        component.set("v.isLoading", false);
                    } else {
                        helper.toast('WARNING', 'No filing date has been selected.');
                        component.set("v.workOrderList", []);
                        component.set("v.isLoading", false);
                    }
                } else {
                    helper.toast('WARNING', 'No records found.');
                    component.set("v.workOrderList", []);
                    component.set("v.isLoading", false);
                }
                /*
                if(r.flag == 'success' && r.workOrderList != null) {
                    helper.toast('SUCCESS', 'SUCCESS.');
                    
                    component.set("v.workOrderList", r.workOrderList);
    
                } else if (r.flag == 'no data') {
                    helper.toast('WARNING', 'No filing date has been selected.');
                } else {
                    helper.toast('WARNING', 'No records found.');
                    
                    component.set("v.workOrderList", []);
                }*/
            }))
            .catch(function(error) {
                helper.toast('ERROR', 'An error occurred, please contact your administrator.');
                console.log('# workOrderNumber Modal error : ' + error.message);
                component.set("v.isLoading", false);
            });
        }

    },
    
    sendOrderInfo : function(component, event, helper) {
        var customerCode = component.get("v.customerCode");
        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var workOrderList = component.get('v.workOrderList');
        var workOrder = workOrderList[index];
        var message = workOrder;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_OrderListModalforServiceHistoryResult',
            "actionName" : customerCode,
            "message" : message,
        });
        console.log('messagetest ::: ', JSON.stringify(message.WorkOrderNumber, null, 4));
        
        cmpEvent.fire();
        helper.closeModal(component);
    },

    handleKeyPress: function (component, event, helper) {
        if(event.keyCode === 13) {
            $A.enqueueAction(component.get('c.doSearch'));
        }   
    },
})