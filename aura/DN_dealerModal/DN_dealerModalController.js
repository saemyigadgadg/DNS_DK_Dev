/* @author            : youjin shim
  @description       : 
  @last modified on  : 02-14-2025
  @last modified by  : Chungwoo Lee
  Modifications Log
  Ver   Date         Author                      Modification
  1.0   2024-10-24   youjin.shimk@sbtglobal.com   Initial Version */

  ({
    doInit: function (component, event, helper) {
      let workCenterId = component.get("v.workCenterId");

      console.log('TEST :::',workCenterId);
      
      let action = component.get("c.getCurruntWorkCenter");
        
        action.setParams({ "workCenterId" : workCenterId });

        action.setCallback(this, function(response) {
          let r = response.getReturnValue();
          console.log(r);
          
          if (r.flag == "success") {
            component.set("v.dealerList", r.workCenterList);
          } else if (r.flag == "warning") {
            helper.toast('WARNING', r.message);
            component.set("v.dealerList", []);
          } else {
            helper.toast('Error', 'An error occurred, please contact your administrator.');
            console.log('Error ::: ',r.getMessage);
          }
        });
        $A.enqueueAction(action);        
    },

    // 행 클릭
    rowClick: function (component, event, helper) {
      var index = event.currentTarget.dataset.record;
      console.log('index:', index);

      var dealerList = component.get('v.dealerList');
      // 인터페이스 완료 후 텍스트 값이 아닌 워크센터 고유 코드 값으로 변경 필요
      var dealer = dealerList[index];

      var cmpEvent = component.getEvent("cmpEvent");
      cmpEvent.setParams({
          "modalName" : "DealerModal",
          "actionName" : "Close",
          "message" : dealer
      });
      cmpEvent.fire();
      helper.closeModal(component);
  },

    // modal 닫기
    dealerModalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },
})