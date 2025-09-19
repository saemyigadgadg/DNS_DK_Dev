/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-16-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    //init
    doInit: function (component, event, helper) {
        //console.log(JSON.stringify(component.get('v.currentUserInfo')), ' < === userINFO');
        
        //디폴트 쿼리 설정
        helper.setQuery(component);
       
    },

    //모든 체크박스 선택
    selectAll: function (component, event, helper) {
        let checkboxes = component.find("checkbox");
        let isChecked = event.getSource().get('v.checked');//.get("v.value"); //let check = event.getSource()
        let orderList = component.get('v.orderList');
        let plist = [];
        //console.log(isChecked,' :: isChecked');
        // 모든 체크박스의 상태를 변경합니다.
        if(Array.isArray(checkboxes)) {
            checkboxes.forEach(function (checkbox, index) {
                checkbox.set("v.checked", isChecked);
            });
        } else {
            checkboxes.set("v.checked", isChecked);
        }
        if(isChecked) {
            plist = orderList;
        } else {
            plist = [];
        }
        component.set('v.selectedProducts', plist);
        var selectedProducts = component.get('v.selectedProducts');
        //console.log('selectedProd:', JSON.stringify(selectedProducts));
    },
    // 입고처리 선택
    handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        let allList = component.get('v.orderList');
        let seletedList = component.get('v.selectedProducts');
        if(check) {
            seletedList.push(allList[index]);
        } else {
            seletedList = seletedList.filter(item => item !== allList[index]);
        }
        component.set('v.selectedProducts', seletedList);
        //console.log(JSON.stringify(seletedList),'seletedList');
    },

    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

    //저장위치 설정
    openSettingStorage: function (component, event) {
        component.set('v.isLoading', true);

        var index = event.target.name;
        var purchaseList = component.get('v.orderList');
        var type = 'Setting';
        //console.log('index', index);
        //console.log('purchaseList[index]', JSON.stringify(purchaseList[index]));
        let parts = {
            'buyerName' : purchaseList[index].buyerName,
            'partNumber' : purchaseList[index].partNumber,
            'stockLocation' : purchaseList[index].stockLocation,
            'partId' : purchaseList[index].partId
        };
        $A.createComponent("c:DN_SettingStorageModal",
            {
                "type": type,
                "parts": parts
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("settingStorageModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        component.set('v.isLoading', false);
    },
    
    //저장위치 Modal Event
    handleCompEvent : function(component, event, helper) {
        //console.log(' 모달이벤트 수신')
        let message = event.getParam('message');
        //console.log(JSON.stringify(message), ' < ==message');
        if(message=='Save') {
            
            let searchType = component.get('v.whereCondition');
            if(searchType.orderType == 'All') {
                helper.getDataListAll(component,'Seach');
            } else {
                if(searchType.orderType == 'DNS') {
                    helper.getDataList(component,'Seach','getDNSLIst');
                } else {
                    helper.getDataList(component,'Seach','getDealerPurOrder');
                }
            }
        }
    },

    // 송장번호 클릭
    handleClick : function(component, event, helper) {
       let text = event.currentTarget.name;
       //https://kdexp.com/service/delivery/etc/delivery.do?barcode= 
       let openUrl = `https://kdexp.com/service/delivery/etc/delivery.do?barcode=${text}`;
       window.open(`${openUrl}`, `운송정보`, `top=10, left=10, width=500, height=500, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`);
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            //console.log(" setSubscriptionLMC");
            //console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'filterChange':
                helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach':
                    //console.log(JSON.stringify(component.get('v.whereCondition')), ' test1111');
                    let searchType = component.get('v.whereCondition');
                    if(searchType.orderType == 'All') {
                        helper.getDataListAll(component,params.type);
                    } else {
                        if(searchType.orderType == 'DNS') {
                            helper.getDataList(component,params.type,'getDNSLIst');
                        } else {
                            helper.getDataList(component,params.type,'getDealerPurOrder');
                        }
                    }
                    break;
                case 'Save':
                    let selected = component.get('v.selectedProducts');
                    //console.log(JSON.stringify(selected), ' :::: ele');  
                    for(let i=0; i<selected.length; i++) {
                        let element = selected[i];
                        if(parseInt(element.gRPossibleQuantity) < parseInt(element.gRQuantity)) {
                            helper.toast('error', `구매주문번호 : ${element.orderNumber}의 입고수량을 확인해주세요`);
                            return;
                        }
                        if(parseInt(element.gRQuantity) <0) {
                            helper.toast('error', `구매주문번호 : ${element.orderNumber}의 입고수량을 확인해주세요`);
                            return;
                        }
                        if(!parseInt(element.gRQuantity)) {
                            helper.toast('error', `구매주문번호 : ${element.orderNumber}의 입고수량을 확인해주세요`);
                            return;
                        }
                    }
                    helper.insertGR(component);// 입고처리
                    break;
                case 'ExcelDownload':
                    helper.handleExcel(component); 
                    // let searchTypes = component.get('v.whereCondition');
                    // if(searchTypes.orderType == 'All') {
                    //     helper.getDataListAll(component,params.type)
                    //     .then($A.getCallback(function(result) {
                    //         helper.handleExcel(component); 
                    //     }))
                    //     .catch(error => {
                    //         console.log(error,' :: sserror');
                    //     });
                    // } else {
                    //     if(searchTypes.orderType == 'DNS') {
                    //         helper.getDataList(component,params.type,'getDNSLIst')
                    //         .then($A.getCallback(function(result) {
                    //             helper.handleExcel(component); 
                    //         }))
                    //         .catch(error => {
                    //             console.log(error,' :: sserror');
                    //         });
                    //     } else {
                    //         helper.getDataList(component,params.type,'getDealerPurOrder')
                    //         .then($A.getCallback(function(result) {
                    //             helper.handleExcel(component); 
                    //         }))
                    //         .catch(error => {
                    //             console.log(error,' :: sserror');
                    //         });
                    //     }
                    // }
                    break;
                case 'Output':
                    helper.handleOutput(component);
                    break;
                default:
                    break;
            }  
        }
    },
    handleQTYChange: function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let orderList = component.get('v.orderList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        orderList[index].gRQuantity = value;  
        component.set('v.orderList',orderList);    
    },
})