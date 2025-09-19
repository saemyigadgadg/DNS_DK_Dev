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
        var bizAreaList = component.get("v.bizAreaList");
        
        bizAreaList = [
            {'bizArea' : 'B100', 'description' : 'Corporate Center'},
            {'bizArea' : 'B110', 'description' : 'Construction Equipment'},
            {'bizArea' : 'B120', 'description' : 'Forklifts'},
            {'bizArea' : 'B130', 'description' : 'Engines & Materials'},
            {'bizArea' : 'B140', 'description' : 'Machine Tools'}
        ]

        component.set("v.bizAreaList", bizAreaList);
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 사업영역 선택 시, 값 전달
    sendBizAreaInfo : function(component, event, helper) {

        var bizAreaType = component.get("v.bizAreaType");

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var bizAreaList = component.get('v.bizAreaList');
        var bizArea = bizAreaList[index];

        var message = bizArea;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_BizAreaListModal',
            "actionName" : bizAreaType,
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    }


})