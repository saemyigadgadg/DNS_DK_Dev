/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-17
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-17   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {

        var houseBankList = component.get("v.houseBankList");

        houseBankList = [
            {'bankCode':'A0001', 'nameofBank':'한국산업은행'},
            {'bankCode':'B0001', 'nameofBank':'INDUSTRIAL BANK OF KOREA'},
            {'bankCode':'C0001', 'nameofBank':'KOOKMIN BANK'}
        ]

        component.set("v.houseBankList", houseBankList);
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 계좌 선택 시, 값 전달
    sendHouseBankInfo : function(component, event, helper) {

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var houseBankList = component.get('v.houseBankList');
        var houseBank = houseBankList[index];

        var message = houseBank;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_HouseBankListModal',
            "actionName" : 'Close',
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    }





})