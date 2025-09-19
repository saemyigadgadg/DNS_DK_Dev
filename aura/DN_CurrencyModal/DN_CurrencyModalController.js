/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-07-03
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-02   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var currencyList = component.get("v.currencyList");

        currencyList = [
            {'code' : 'KRW', 'name' : 'Korea'},
            {'code' : 'USD', 'name' : 'US'},
            {'code' : 'JPY', 'name' : 'Japan'},
            {'code' : 'CNY', 'name' : 'China'},
        ];

        component.set("v.currencyList", currencyList);
    },


    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    
    //모달에서 Currency 선택 시, 값 전달
    sendCurrencyInfo : function(component, event, helper) {

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var currencyList = component.get('v.currencyList');
        var currency = currencyList[index];

        var message = currency;

        var cmpEvent = component.getEvent("cmpEvent5");
        cmpEvent.setParams({
            "modalName" : 'DN_CurrencyModal',
            "actionName" : 'Close',
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    }
})