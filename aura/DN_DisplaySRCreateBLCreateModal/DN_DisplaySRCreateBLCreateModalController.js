/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-07-03
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-28   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set("v.isLoading", true);

        var blInfo = component.get("v.blInfo");
        var costInfoList = component.get("v.costInfoList");
        var detailInfoList = component.get("v.detailInfoList");

        blInfo = {
            "docNo": "2000348777",
            "invoiceNo": "M202410AC0049",
            "masterBLNo": "PCLUPUS03014955",
            "loadingPortCountry": "KR",
            "loadingPort": "PUS",
            "houseBLNo": "PCLUPUS03014955",
            "dischargingPortCountry": "KR",
            "dischargingPort": "PUS",
            "vesselName": "PANCON VICTORY",
            "voyageNo": "2411W",
            "onBoardDate": "2024-03-23",
            "eta": "2024-03-25"
        }

        costInfoList = [
            {
                "code": "code1", "costs": "costs", "curr": "curr1", "amount": "1200", "tax": "0.1",
                "totalAmount": "1200", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode1"
            },
            {
                "code": "code2", "costs": "costs", "curr": "curr2", "amount": "1300", "tax": "0.2",
                "totalAmount": "1300", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode2"
            },
            {
                "code": "code3", "costs": "costs", "curr": "curr3", "amount": "1400", "tax": "0.3",
                "totalAmount": "1400", "exchangeRate": "1380.5", "occurredDate": "2024-03-23", "taxCode": "taxCode3"
            },
            {
                "code": "code1", "costs": "costs", "curr": "curr1", "amount": "1200", "tax": "0.1",
                "totalAmount": "1200", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode1"
            },
            {
                "code": "code2", "costs": "costs", "curr": "curr2", "amount": "1300", "tax": "0.2",
                "totalAmount": "1300", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode2"
            },
            {
                "code": "code3", "costs": "costs", "curr": "curr3", "amount": "1400", "tax": "0.3",
                "totalAmount": "1400", "exchangeRate": "1380.5", "occurredDate": "2024-03-23", "taxCode": "taxCode3"
            },
            {
                "code": "code1", "costs": "costs", "curr": "curr1", "amount": "1200", "tax": "0.1",
                "totalAmount": "1200", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode1"
            },
            {
                "code": "code2", "costs": "costs", "curr": "curr2", "amount": "1300", "tax": "0.2",
                "totalAmount": "1300", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode2"
            },
            {
                "code": "code3", "costs": "costs", "curr": "curr3", "amount": "1400", "tax": "0.3",
                "totalAmount": "1400", "exchangeRate": "1380.5", "occurredDate": "2024-03-23", "taxCode": "taxCode3"
            },
            {
                "code": "code1", "costs": "costs", "curr": "curr1", "amount": "1200", "tax": "0.1",
                "totalAmount": "1200", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode1"
            },
            {
                "code": "code2", "costs": "costs", "curr": "curr2", "amount": "1300", "tax": "0.2",
                "totalAmount": "1300", "exchangeRate": "1362.3", "occurredDate": "2024-03-23", "taxCode": "taxCode2"
            },
            {
                "code": "code3", "costs": "costs", "curr": "curr3", "amount": "1400", "tax": "0.3",
                "totalAmount": "1400", "exchangeRate": "1380.5", "occurredDate": "2024-03-23", "taxCode": "taxCode3"
            },
        ]

        detailInfoList = [
            { "model": "model1", "serialNo": "serialNo1", "containerType": "containerType1", "clp": "clp1", "clpNo": "clpNo1", "etc": "etc1" },
            { "model": "model2", "serialNo": "serialNo2", "containerType": "containerType2", "clp": "clp2", "clpNo": "clpNo2", "etc": "etc2" },
            { "model": "model3", "serialNo": "serialNo3", "containerType": "containerType3", "clp": "clp3", "clpNo": "clpNo3", "etc": "etc3" }
        ]

        component.set("v.blInfo", blInfo);
        component.set("v.costInfoList", costInfoList);
        component.set("v.detailInfoList", detailInfoList);

        component.set("v.isLoading", false);
    },

    // Save 기능 추가 필요
    saveModal: function (component, event, helper) {
        helper.closeModal(component);
    },

    closeModal: function (component, event, helper) {
        helper.closeModal(component);
    },

    // Currency 모달 열기
    openCurrencyModal: function (component, event, helper) {

        component.set("v.isLoading", true);

        $A.createComponent("c:DN_CurrencyModal",
            {},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("currencyModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);

    },

    // Loading Port - Country 모달
    openLoadingCountryModal: function (component, event, helper) {
        component.set("v.isLoading", true);

        // Loading Port와 Discharging Port를 구분
        var portType = "Loading Port";
        // 호출한 컴포넌트를 구분
        var calloutCmp = 'DisplaySRCreateBLCreateModal';

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
        component.set("v.isLoading", false);

    },

    // Loading Port - Port 모달
    //{!v.loadingPort.countryCode.code}에 값이 없으면 countryCodeModal, 값이 있으면 portCodeModal
    openLoadingPortModal: function (component, event, helper) {
        component.set("v.isLoading", true);

        // Loading Port와 Discharging Port를 구분
        var portType = "Loading Port";
        // 호출한 컴포넌트를 구분
        var calloutCmp = 'DisplaySRCreateBLCreateModal';
        var loadingPort = component.get("v.loadingPort");
        var countryCode = loadingPort.countryCode;

        // countryCodeModal
        if (!countryCode) {
            console.log('countryCode is missing or empty.');

            $A.createComponent("c:DN_CountryCodeModal",
                {
                    "countryCode": countryCode,
                    "portType": portType,
                    "calloutCmp" : calloutCmp

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

            // portCodeModal
            // paramFrom : CountryCode를 거치지 않고 바로 PortCode를 선택하는 경우를 구분하기 위한 용도
        } else {
            console.log('countryCode is present: ' + countryCode);

            $A.createComponent("c:DN_PortCodeModal",
                {
                    "countryCode": countryCode,
                    "paramFrom": "goPortCode",
                    "portType": portType,
                    "calloutCmp" : calloutCmp

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
        }
        component.set("v.isLoading", false);
    },



    // Discharging Port - Country 모달
    openDischargingCountryModal: function (component, event, helper) {
        component.set("v.isLoading", true);

        // Loading Port와 Discharging Port를 구분
        var portType = "Discharging Port";
        // 호출한 컴포넌트를 구분
        var calloutCmp = 'DisplaySRCreateBLCreateModal';

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
        component.set("v.isLoading", false);

    },

    // Discharging Port - Port 모달
    //{!v.dischargingPort.countryCode.code}에 값이 없으면 countryCodeModal, 값이 있으면 portCodeModal
    openDischargingPortModal: function (component, event, helper) {
        component.set("v.isLoading", true);

        // Loading Port와 Discharging Port를 구분
        var portType = "Discharging Port";
        // 호출한 컴포넌트를 구분
        var calloutCmp = 'DisplaySRCreateBLCreateModal';
        var dischargingPort = component.get("v.dischargingPort");
        var countryCode = dischargingPort.countryCode;

        // countryCodeModal
        if (!countryCode) {
            console.log('countryCode is missing or empty.');

            $A.createComponent("c:DN_CountryCodeModal",
                {
                    "countryCode": countryCode,
                    "portType": portType,
                    "calloutCmp" : calloutCmp

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

            // portCodeModal
            // paramFrom : CountryCode를 거치지 않고 바로 PortCode를 선택하는 경우를 구분하기 위한 용도
        } else {
            console.log('countryCode is present: ' + countryCode);

            $A.createComponent("c:DN_PortCodeModal",
                {
                    "countryCode": countryCode,
                    "paramFrom": "goPortCode",
                    "portType": portType,
                    "calloutCmp" : calloutCmp

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
        }
        component.set("v.isLoading", false);
    },


    // 모달
    handleCompEvent: function (component, event, helper) {

        console.log("DisplaySRCreateBLCreateModal - Handle Comp로 잘 들어왔음");


        var modalName = event.getParam("modalName");
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");

        if (modalName == 'DN_CurrencyModal') {
            component.set("v.currencyInfo", message);
        } else if (modalName == 'DN_PortCodeModal') {
            if (actionName == 'Loading Port') {
                component.set("v.loadingPort", message);
            }else if (actionName == 'Discharging Port'){
                component.set("v.dischargingPort", message);
            }
        }
    },

    // 전체 선택/해제
    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox");
        var isChecked = component.find("headerCheckbox").get("v.checked");
        var plist = [];

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked == true) {
            checkboxes.forEach(function (checkbox) {
                checkbox.set("v.checked", isChecked);
            });
            var detailInfoList = component.get('v.detailInfoList');
            detailInfoList.forEach(function (pl) {
                plist.push(pl);
            });
        } else if (isChecked == false) {
            checkboxes.forEach(function (checkbox) {
                checkbox.set("v.checked", isChecked = false);
            })
            plist = [];
        }
        component.set('v.selectedDetailInfo', plist);
    },

    // 개별 체크변경
    handleCheckboxChange: function (component, event, helper) {
        var checkbox = component.find('checkbox');
        var selectedDetailInfo = [];
        for (var i = 0; i < checkbox.length; i++) {
            if (checkbox[i].get("v.checked")) {
                selectedDetailInfo.push(i);
            }
        }
        component.set('v.selectedDetailInfo', selectedDetailInfo);
    },


})