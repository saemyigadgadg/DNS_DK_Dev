/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-07-03
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-24   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        var portList = component.get("v.portList");

        portList = [
            { 'code': 'CAL', 'desc': 'CALGARY' },
            { 'code': 'HAL', 'desc': 'HALI FAX' },
            { 'code': 'LTB', 'desc': 'Lethbridge' }
        ];

        component.set("v.portList", portList);
    },

    closeModal: function (component, event, helper) {
        // var cmpEvent = component.getEvent("cmpEvent");
        // cmpEvent.fire();
        helper.closeModal(component);
    },

    openPrevious: function (component, event, helper) {
        component.set("v.isLoading", true);

        var paramFrom = component.get("v.paramFrom");
        var portType = component.get("v.portType");
        var calloutCmp = component.get("v.calloutCmp");

        console.log("paramFrom in Previous:: ", paramFrom);
        console.log("calloutCmp in Previous:: ", calloutCmp);



        $A.createComponent("c:DN_CountryCodeModal",
            {
                "portType": portType,
                "calloutCmp": calloutCmp
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("countryCodeModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });

        helper.closeModal(component);



        component.set("v.isLoading", false);
    },

    //Country Code, Portal Code 둘다 전달
    sendCountryPortCode: function (component, event, helper) {
        var countryCode = component.get("v.countryCode");
        var paramFrom = component.get("v.paramFrom");
        var portType = component.get("v.portType");
        var calloutCmp = component.get("v.calloutCmp");

        console.log('calloutCmp :: ', calloutCmp);

        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var portList = component.get('v.portList');
        var portCode = portList[index];

        var message = {
            "countryCode": countryCode,
            "portCode": portCode,
            "calloutCmp": calloutCmp
        };

        var cmpEvent;

        //CountryCode가 이미 입력된 경우
        if (paramFrom == "goPortCode") {
            if (calloutCmp == "Booking Request Create Modal") {
                cmpEvent = component.getEvent("cmpEvent3");
                console.log("cmpEvent3");

            } else if (calloutCmp == "DisplaySRCreateBL") {
                cmpEvent = component.getEvent("cmpEvent4");
                console.log("cmpEvent4");
            } else if (calloutCmp == "DisplaySRCreateBLCreateModal") {
                cmpEvent = component.getEvent("cmpEvent5");
                console.log("cmpEvent5");

            } else {
                cmpEvent = component.getEvent("cmpEvent2");
                console.log("cmpEvent2");
            }

            //CountryCode & PortCode가 모두 입력되지 않은 경우
        } else {
            cmpEvent = component.getEvent("cmpEvent");
            console.log("cmpEvent 1");
        }

        cmpEvent.setParams({
            "modalName": 'DN_PortCodeModal',
            "actionName": portType,
            "message": message,
        });

        console.log("Message :: ", JSON.stringify(message));

        cmpEvent.fire();
        helper.closeModal(component);
    },

    //Country Code만 전달(Finish)
    sendCountryCode: function (component, event, helper) {

        var countryCode = component.get("v.countryCode");
        var portType = component.get("v.portType");
        var calloutCmp = component.get("v.calloutCmp");

        var message = {
            "countryCode": countryCode,
            "calloutCmp": calloutCmp

        };

        console.log("message ::" , JSON.stringify(message));

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName": 'DN_PortCodeModal',
            "actionName": portType,
            "message": message,
        });

        cmpEvent.fire();
        helper.closeModal(component);

    },



})