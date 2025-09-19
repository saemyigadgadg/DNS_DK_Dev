/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-07-10
 * @last modified by  : suheon.ha@sobetec.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-19   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        //디폴트 쿼리 설정
        helper.setQuery(component);
    },
    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(" setSubscriptionLMC");
            console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach':
                    helper.getData(component);
                    break;
                case 'Save': // 저장
                    helper.saveData(component);
                    break;
                default:
                    break;
            }  
        }
    },
    
    // TSL 모달 인터페이스
    opentargetServiceLevel: function (component, event, helper) {
        component.set("v.isLoading", true);
        let allData = component.get('v.tslList');
        let index = event.getSource().get("v.name");
        component.set('v.selectedRow', allData[index]);
        $A.createComponent("c:DN_TargetServiceLevelModal",
            {},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("targetServiceLevelModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // Weight 입력
    handleValue: function (component, event, helper) {
        //event.getSource();//.get("v.value");
        let weightList = component.get('v.weightList');
        let value = event.getSource().get("v.value");
        let index = event.getSource().get("v.name");
        let rowData = weightList[index];
        let regex = /^(99(\.[0-9]?)?|[0-9]{1,2}(\.[0-9]?)?)?$/;
        if (!regex.test(value)) {
            // 0.0 ~ 99.9 범위에서 올바른 값만 추출
            let matchedValue = value.match(/^(99(\.[0-9]?)?|[0-9]{1,2}(\.[0-9]?)?)?/);

            if (matchedValue) {
                if(matchedValue[0]) {
                    value = matchedValue[0]; // 첫 번째 매칭된 값 사용
                }else {
                    value = 0; //숫자가 없으면 0 값으로 설정    
                }
            } else {
                value = 0; // 숫자가 없으면 0 값으로 설정
            }

            event.getSource().set("v.value", value); // 수정된 값 반영
        }
    },

    //  인터페이스 통해 받은 데이터 적용
    handleCmpEvent : function(component, event, helper) {
		let message = event.getParam('message'); 
		let parts = {};
        let allData = component.get('v.tslList');
        let selecteRow = component.get('v.selectedRow');
        selecteRow.TargetServiceLevel__c = message.TSL;
        selecteRow.SVCFactor__c = message.SFT;
        allData.forEach(element => {
            if(selecteRow.Id === element.Id) {
                element = selecteRow;
            }
        });
        component.set('v.tslList',allData);
    },
})