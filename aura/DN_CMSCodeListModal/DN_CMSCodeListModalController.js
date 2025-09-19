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

        var cmsCodeList = component.get("v.cmsCodeList");

        cmsCodeList = [
            {'cmsCode':'cmsCode1', 'department':'department1', 'account':'account1'},
            {'cmsCode':'cmsCode2', 'department':'department2', 'account':'account2'},
            {'cmsCode':'cmsCode3', 'department':'department3', 'account':'account3'},
            {'cmsCode':'cmsCode4', 'department':'department4', 'account':'account4'},
        ];

        component.set("v.cmsCodeList", cmsCodeList);
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 고객 선택 시, 값 전달
    sendCMSCodeInfo : function(component, event, helper) {

        var cmsCodeType = component.get("v.cmsCodeType");

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var cmsCodeList = component.get('v.cmsCodeList');
        var cmsCode = cmsCodeList[index];

        var message = cmsCode;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_CMSCodeListModal',
            "actionName" : cmsCodeType,
            "message" : message,
        });

        cmpEvent.fire();
        helper.closeModal(component);
    }


})