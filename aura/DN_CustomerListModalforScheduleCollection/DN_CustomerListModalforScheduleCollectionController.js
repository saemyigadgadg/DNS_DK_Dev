/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 01-22-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-03   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var customerList = component.get("v.customerList");
        console.log('customerList >>> ' +customerList);
        console.log('customerList Length >>> ' +customerList.length);
    },


    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    
    //모달에서 고객 선택 시, 값 전달
    sendCustomerInfo : function(component, event, helper) {

        var customerType = component.get("v.customerType");


        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var customerList = component.get('v.customerList');
        var customer = customerList[index];

        var message = customer;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_CustomerListModalforScheduleCollection',
            "actionName" : customerType,
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    },
    handleValueChange : function(component, event, helper) {
        var source = event.getSource();
        var auraId = source.getLocalId();
        
        if(auraId == 'customerName') {
            component.set("v.customerName", event.target.value);
        } else {
            component.set("v.customerCode", event.target.value);
        }
    },
    // 엔터키 적용
    handleEnterClick : function(component, event, helper) {
        //console.log(event.keyCode,' < ==event.target.keyCode');
        if(event.keyCode  == 13) {
            $A.enqueueAction(component.get('c.searchCustomer'));
        }
    },

    // 고객사 검색
    // 고객사 검색
    searchCustomer : function(component, event, helper) {
        console.log('searchCustomer',' < ==searchCustomer');
        component.set("v.isLoading", true);
        
        helper.apexCall(component, event, helper, 'getCustomList', {
            customCode : component.get("v.customerCode"),
            customName : component.get("v.customerName")
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            let customerList = [];
            console.log(r,' < ==r');
            customerList = r;

            if (!customerList || customerList.length === 0) {
                helper.toast('ERROR', '조회된 고객사가 없습니다.');
            } else {
                console.log(customerList, '<== customerList');
                component.set("v.customerList", customerList);
            }
        }))
        .catch(function(error) {
            console.log('# addError error : ' + error.message);
        });    
        component.set("v.isLoading", false);
    }

})