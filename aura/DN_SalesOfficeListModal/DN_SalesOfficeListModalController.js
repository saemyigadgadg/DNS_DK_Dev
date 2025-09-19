/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-05
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-05   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var salesOfficeList = component.get("v.salesOfficeList");
        
        salesOfficeList = [
            {'salesOffice' : '114A', 'text' : '영업지원(DNS)'},
            {'salesOffice' : '114B', 'text' : '인천지사'},
            {'salesOffice' : '114C', 'text' : '수원지사'}
        ]

        component.set("v.salesOfficeList", salesOfficeList);
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 판매부서 선택 시, 값 전달
    sendSalesOfficeInfo : function(component, event, helper) {

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var salesOfficeList = component.get('v.salesOfficeList');
        var salesOffice = salesOfficeList[index];

        var message = salesOffice;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_SalesOfficeListModal',
            "actionName" : 'Close',
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    }


})