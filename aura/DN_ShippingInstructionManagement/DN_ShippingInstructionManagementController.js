/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-13-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-13-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
     //init
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
                    helper.getDataQuery(component,params.type);
                    break;
                case 'Save': // 저장
                    helper.updateQTy(component);// 출고지시 수량 저장
                    break;
                case 'ExcelDownload': // 출고지시서
                    let select = component.get('v.seletedList');
                    if(select.length ==0) {
                        helper.toast('error', ' 출고지시서를 다운로드할 항목을 선택하세요');
                        return;
                    }
                    if(select.length >1) {
                        helper.toast('error', ' 하나의 출고지시번호를 선택해주세요');
                        return;
                    }
                    helper.handleShippingOrder(component);
                    break;
                case 'PageChnage':
                    //console.log(JSON.stringify(msg), ' msg');
                    component.set('v.nextPage',params.message.nextpage);
                    component.set('v.currentPage',params.message.currentPage);
                    helper.getDataQuery(component,params.type);
                    break; 
                case 'GoodIssue':  //출고완료 - 주문출고로 이동
                    let seleted = component.get('v.seletedList');
                    
                    if(seleted.length == 0) {
                        helper.toast('error', ' 출고완료할 항목을 선택하세요.');
                        return;
                    }
                    let firstValue = seleted[0].DeliveryOrder__c;
                    let isDifferent = seleted.some(item => item.DeliveryOrder__c !== firstValue);
                    if(isDifferent) {
                        helper.toast('error', ' 동일한 출고지시번호만 선택하여 주문출고가 가능합니다.');
                        return;
                    }
                    // if(seleted.length >1) {
                    //     helper.toast('error', ' 하나의 출고지시번호를 선택해주세요');
                    //     return;
                    // }
                    let state = {
                        'c__dealerorderItems' : seleted[0].DealerOrderItem__c
                    }
                    let pageRef = helper.gfnGetCommunityCustomPageRef('OrderShipment__c',state);
                    var navService = component.find("navService");
                    navService.navigate(pageRef);
                    break; 
                default:
                    break;
            }  
        }
    },

    handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        let allData = component.get('v.recordList');
        let seleted = component.get('v.seletedList');
       
        if(check) {
            seleted.push(allData[index]);
        } else {
            seleted = seleted.filter(item => item !== allData[index]);
        }
        console.log(JSON.stringify(seleted),' < ==selectedGR');
        component.set('v.seletedList', seleted);
    },

    // 전체 row 선택
    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox");
        var isChecked = component.find("headerCheckbox").get("v.checked");
        var plist = [];
        let allData = component.get('v.recordList');

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
            plist = allData;
        } else {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
            plist = [];
        }
        component.set('v.seletedList', plist);
    },

    handleQTYChange: function (component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let recordList = component.get('v.recordList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        recordList[index].Quantity__c = value;
        component.set('v.recordList', recordList);
    },
})