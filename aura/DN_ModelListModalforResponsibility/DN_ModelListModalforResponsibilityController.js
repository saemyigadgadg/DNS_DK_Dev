/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-18
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-18   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var modelList = component.get("v.modelList");
        
        modelList = [
            {'code' : 'MB0001', 'desc' : 'DBC 1105'},
            {'code' : 'MB0002', 'desc' : 'DBC 110 II'},
            {'code' : 'MB0003', 'desc' : 'DBC 130 II'},
            {'code' : 'MB0004', 'desc' : 'DBC 130L II'},
            {'code' : 'MB0005', 'desc' : 'DBC 160'}
        ]

        component.set("v.modelList", modelList);
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 기종 선택 시, 값 전달
    sendModelInfo : function(component, event, helper) {

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var modelList = component.get('v.modelList');
        var modelInfo = modelList[index];

        var message = modelInfo;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_ModelListModalforResponsibility',
            "actionName" : 'Close',
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);

    },
})