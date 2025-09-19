/**
 * @author            : Jun-Yeong Choi
 * @Description       : 
 * @last modified on  : 04-22-2025
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component._isInit = true;
        var dealerInfo = component.get('v.dealerInfo');
        $A.enqueueAction(component.get('c.searhBuyerInfo'));
    },

    customerShipToCancel : function(component, event, helper) {
        helper.closeModal(component);
    },

    handleChange : function(component, event, helper) {
        var input = component.find("mygroup");
        var inputValue = input.get("v.value");

        if(inputValue == "Input") {
            component.set('v.inputModalOpen', true);
        } else {
        }
    },

    addressInputCancel : function(component, event, helper) {
        component.set('v.inputModalOpen', false);
    },

    //행정안전부 도로명 주소 url 이동
    addressInfo : function() {
        window.open("https://www.juso.go.kr/openIndexPage.do");
    },

    clickRow : function(component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var shipToList = component.get('v.shipToList2');
        var cmpEvent = component.getEvent("cmpEvent");

        let message = Object.assign({}, shipToList[index] , {"parentCmp":component.get('v.parentCmp')});
        cmpEvent.setParams({
            "modalName" : "DN_AgencyCustomerShipToModal",
            "actionName" : "Close",
            "message" : message
        });
        cmpEvent.fire();
        helper.closeModal(component);
    },

    inputAddressClick : function(component, event, helper){
       
        
        var inputZipCode = component.find("inputZipCode").get("v.value");
        var inputCountry = component.find("inputCountry").get("v.value");
        var inputAddress = component.find("inputAddress").get("v.value");
        var detailAddress = component.find("detailAddress").get("v.value");
        var inputManager = component.find("inputManager").get("v.value");
        var inputPhone = component.find("inputPhone").get("v.value");
        var inputCustomerName = component.find("inputCustomerName").get("v.value");
        //var detailAddress = component.get('v.detailedAddress');

        if(inputCustomerName == '') { helper.toast('INFO', '고객사명을 입력해주세요.'); return }
        else if(inputZipCode == '') { helper.toast('INFO', '우편번호를 입력해주세요.'); return }
        else if(inputCountry == '') { helper.toast('INFO', '지역을 입력해주세요.');     return }
        else if(inputAddress == '') { helper.toast('INFO', '주소를 입력해주세요.');     return }
        else if(inputManager == '') { helper.toast('INFO', '담당자를 입력해주세요.');   return }
        else if(inputPhone   == '') { helper.toast('INFO', '전화번호를 입력해주세요.'); return }
        // else if(detailAddress == '') { helper.toast('INFO', '상세주소를 입력해주세요.'); return }
        // console.log('detailAddress >> '+detailAddress);
        

        var message = {
            "inputZipCode" : inputZipCode,
            "postalCode" : inputZipCode,
            "inputCustomerName": inputCustomerName,
            "inputCountry" : inputCountry,
            "city":inputCountry,
            "inputAddress" : inputAddress + ' , '+detailAddress,
            "inputManager" : inputManager,
            "inputPhone"   : inputPhone,
            "inputCustomerName" : inputCustomerName,
            "detailAddress" : detailAddress,
            "parentCmp":component.get('v.parentCmp'),
            // DD 250422
            "addr" : inputAddress,
            "detail" : detailAddress
        };
        console.log(JSON.stringify(message),' :::: message');
        
        let isCheck = false;
       
        // 주소 길이 초과
        if(inputAddress.length > 36) {
            isCheck = true;
        }
        //상세주소 길이 초과
        if(detailAddress.length > 36) {
            component.find("detailAddress").setCustomValidity("상세주소는 최대 36자까지만 작성가능합니다.");
            component.find("detailAddress").reportValidity();
            isCheck = true;
        }
       

        if(isCheck) {
            helper.toast('error', '주소길이가 초과되었습니다. 주소를 확인해주세요');
            return;
        }
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : "DN_inputModalOpen",
            "actionName" : "Close",
            "message" : message,
        });
        cmpEvent.fire();
        helper.closeModal(component);

    },
    // 주소검색 모달
    handleSearchAddress : function(component, event, helper) {
        component.set('v.isAddress', true);
    },

    handleModalEvent: function(component, event, helper) { 
        try {
            let message = event.getParam('message');
            let addressResult = message.selectedResult;
            console.log(JSON.stringify(addressResult),' ::: addressResult');
            component.find('inputZipCode').set("v.value",addressResult.zipNo);
            component.find('inputCountry').set("v.value",addressResult.siNm);
            //let addddressSet = message.detailedAddress.length > 0 ? addressResult.roadAddr + ', ' + message.detailedAddress : addressResult.roadAddr;
            component.find('inputAddress').set("v.value", addressResult.roadAddrPart1);
            component.find('detailAddress').set("v.value", message.detailedAddress);
            
            //상세 주소 저장
            component.set('v.detailedAddress', addressResult.roadAddrPart2+' '+ message.detailedAddress);

            // DD 250422
            component.set('v.addr', addressResult.roadAddrPart1);
            component.set('v.detail', addressResult.roadAddrPart2 + ' '+ message.detailedAddress);
        } catch (error) {
            console.log('handleModalEvent error: ' + JSON.stringify(error));
        }
    },

    // 고객(buyer) 정보 검색
    searhBuyerInfo : function(component, event, helper) {
        component.set("v.isLoading", true);
        console.log('바이어 정보 검색');
        var buyerCode = component.find("buyerCode").get("v.value");
        var buyerName = component.find("buyerName").get("v.value");
        var dealerInfo = component.get('v.dealerInfo');

        if(!component._isInit && (buyerCode == null || buyerCode == '') && (buyerName == null ||  buyerName == '')) {
            helper.toast('ERROR', '정확한 값을 입력해주세요.');
            component.set("v.isLoading", false);
            return;
        }
        component._isInit = false;

        let dealerURIKeys = component.get('v.dealerURIKeys');
        let currentURL = location.href;
        let isDealerSite = dealerURIKeys.some((dealerURIKey)=> currentURL.lastIndexOf(dealerURIKey)!==-1);
        if(isDealerSite) {
            helper.gfnGetShipTo(component, buyerCode, buyerName);
            return ;
        }
        var action = component.get('c.searchBuyerInfo');
        action.setParams({
            bc : buyerCode,
            bn : buyerName,
            dli : dealerInfo
        });

        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result >> ' +JSON.stringify(result,null,4))
                // var shipToList2 = component.get('shipToList2');

                var shipToList2 = result.map((list) => {
                    return {
                        'customerId'      : list.Customer__c || null,
                        'customerCode'    : list.FM_CustomerCode__c || null,
                        'customerName'    : list.FM_Customer__c || null,
                        'customerAddress' : list.RoadAddr__c || null,
                        'customerDetail'  : list.DetailInfo__c || null,
                        'customerZipCode' : list.Address__c ? list.Address__c.postalCode : null,
                        'manager'         : list.Customer__r ? list.Customer__r.FM_PartsManagerName__c : null,
                        'customerPhone'   : list.Customer__r ? list.Customer__r.FM_PartsManagerPhone__c : null
                    }
                });
                console.log('DD shipToList2 >> '+JSON.stringify(shipToList2,null,4))
                component.set('v.shipToList2', shipToList2);
            } else if(status === "ERROR") {
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message) {
                    console.log('errors 사유: '+errors[0].message);
                } else {
                    console.log('error 사유를 확인하지 못했습니다.')
                }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    // 수정
    handleKeyPress: function (component, event, helper) {
        console.log("enter");
        console.log("Pressed KeyCode:", event.keyCode);
        console.log("Pressed Key:", event.key);
        if (event.keyCode === 13) {
            $A.enqueueAction(component.get('c.searhBuyerInfo'));
        }
    }

})