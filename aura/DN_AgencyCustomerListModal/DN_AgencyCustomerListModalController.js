/**
 * @author            : Jun-Yeong Choi
 * @Description       : 
 * @last modified on  : 2024-06-10
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component.set('v.isSpinner', true);
        var type = component.get('v.type');
        // console.log('~~~~~~~~~~~');
        // console.log(type);
       

        helper.gfnGetAgencyList(component, event, helper);
      
    },

    customerListCancel : function(component, event, helper) {
        helper.closeModal(component);
    },

    sendCustomerInfo : function(component, event, helper) {
        let index = event.currentTarget.dataset.record;
        console.log('index::', index);
        let customerList = component.get('v.customerList');
        console.log('customerList::', customerList);
        let customerShipTo = component.get('v.customerShipToList').find(shipTo=> shipTo.customerCode === customerList[index].customerCode);
        let message = Object.assign({}, customerList[index] , {"customerShipTo":customerShipTo}, {"parentCmp":component.get('v.parentCmp')});
        
        let cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : "DN_AgencyCustomerListModal",
            "actionName" : "Close",
            message
        });
        cmpEvent.fire();
        helper.closeModal(component);
    },
    
    generalCustomer : function(component, event, helper) {
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : "DN_AgencyCustomerListModal",
            "actionName" : "Close",
            "message" : { 
                "customerName":"일반고객"
                ,'id' :'9999999999' //일반고객일경우 코드
                ,"parentCmp":component.get('v.parentCmp')
            },
            
        });
        cmpEvent.fire();
        helper.closeModal(component);
    },

    searchCustomer : function(component, event, helper) {
        component.set('v.isSpinner', true);
        helper.gfnGetAgencyList(component, event, helper);
    },

    // 엔터키 적용
    handleEnterClick : function(component, event, helper) {
        if(event.keyCode  == 13) {
            $A.enqueueAction(component.get('c.searchCustomer'));
        }
    }

})