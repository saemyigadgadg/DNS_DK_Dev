/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-26
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-26   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {

        var salesOrgList = component.get("v.salesOrgList");

        salesOrgList = [
            { 'code': '1140', 'name': 'DI MT Sales org.' },
            { 'code': '1146', 'name': 'DI MT Parts' },
            { 'code': '1800', 'name': 'DN Solutions' }
        ]

        component.set("v.salesOrgList", salesOrgList);

    },

    closeModal: function (component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 Sales Org 선택 시, 값 전달
    sendSalesOrgInfo: function (component, event, helper) {

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var salesOrgList = component.get('v.salesOrgList');
        var salesOrg = salesOrgList[index];

        var message = salesOrg;

        var cmpEvent = component.getEvent("cmpEvent2");
        cmpEvent.setParams({
            "modalName": 'DN_SalesOrganizationModal',
            "actionName": 'Close',
            "message": message,
        });

        console.log('message ::', JSON.stringify(message) );

        cmpEvent.fire();
        helper.closeModal(component);
    }
})