/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-04
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-04   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.apexCall(component, event, helper, 'getOrder', {
            accountId : component.get('v.accountId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            let orderList =[];
            console.log(r,' < ==r');
            orderList = r;
            console.log(orderList,' <M ==customerList');
            component.set("v.orderList", orderList);
        }))
        .catch(function(error) {
            console.log('# addError error : ' + error.message);
        });
        component.set("v.isLoading", false);
    },


    closeModal : function(component, event, helper) {
        console.log('closeModal 1111');
        helper.closeModal(component);
    },

    
    //모달에서 오더번호 선택 시, 값 전달
    sendOrderInfo : function(component, event, helper) {

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var orderList = component.get('v.orderList');
        var order = orderList[index];

        var message = order;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_SalesOrderListModalforScheduleCollection',
            "actionName" : 'Close',
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    }
})