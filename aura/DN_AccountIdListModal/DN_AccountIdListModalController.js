/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-07-03
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-17   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {

        var accountIdList = component.get("v.accountIdList");

        accountIdList = [
            {'houseBk' : 'B001', 'acctId':'00001', 'text':'경남-전자채권수금-2070061637106'},
            {'houseBk' : 'C001', 'acctId':'00002', 'text':'수협-보통예금-10107291069'},
            {'houseBk' : 'C002', 'acctId':'00003', 'text':'수협-USD 외화지급-180000215183'}
        ]

        component.set("v.accountIdList", accountIdList);
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 계좌 선택 시, 값 전달
    sendAccountIdInfo : function(component, event, helper) {

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var accountIdList = component.get('v.accountIdList');
        var accountId = accountIdList[index];

        var message = accountId;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_AccountIdListModal',
            "actionName" : 'Close',
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    }





})