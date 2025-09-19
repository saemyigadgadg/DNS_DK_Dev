/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-27-2025
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-27-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        helper.initJob(component);
        //디폴트 쿼리 설정
        helper.setQuery(component);
    },

    selectAll: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let checkboxes = component.find("checkbox");
        let allList = component.get('v.recordList');
        let seletedList = component.get('v.seletedList');
        console.log(check,' ::: check');
        if(check) {
            checkboxes.forEach(function (checkbox, index) {
                checkbox.set("v.checked", check);
                seletedList.push(allList[index]);
            });
        } else {
            checkboxes.forEach(function (checkbox, index) {
                checkbox.set("v.checked", check);
            });
            seletedList = [];
        }
        component.set('v.seletedList', seletedList);
    },

     // 체크박스 선택
     handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        let allList = component.get('v.recordList');
        let seletedList = component.get('v.seletedList');
        console.log(index,' :: test');
        if(check) {
            seletedList.push(allList[index]);
        } else {
            seletedList = seletedList.filter(item => item !== allList[index]);
        }
        console.log(JSON.stringify(seletedList), ' :: seletedList');
        component.set('v.seletedList', seletedList);
    },

    // 구매처
    openOtherDealerStockModal: function (component, event, helper) {
        let recordList = component.get('v.recordList');
        let index = event.getSource().get('v.accesskey');
        component.set('v.openIndex',index);
        //poQTY
        let partList = [{
            "partName": recordList[index].material,
            "requestQuantity": recordList[index].poQTY
        }];
        $A.createComponent("c:DN_OtherDealerStockQtyModal",
            {
                'partList': partList
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    $A.getCallback(function () {
                        console.log("Modal rendered successfully");
                        var container = component.find("OtherDealerStockModal");
                        container.set("v.body", content);
                    })();
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // 구매처 수신
    handleCompEvent: function (component, event, helper) {
        let modalName = event.getParam("modalName");
        let message = event.getParam("message");
        let partsList = component.get("v.recordList");
        let openIndex = component.get('v.openIndex');
        console.log(partsList[openIndex].material,' :L:: partsList[openIndex].material');
        let data = message[partsList[openIndex].material];
        console.log(JSON.stringify(data), ' :::: data');
        partsList[openIndex].dealer      = data.dealer;
        partsList[openIndex].dealerName  = data.dealerName;
        partsList[openIndex].dealerCode  = data.dealerCode;    

        component.set("v.recordList", partsList);
        
        component.set('v.openIndex', null);
    },

    // DUE OUT Modal
    openDUEOUTDetailModal: function (component, event, helper) {
        let index = event.currentTarget.name;
        let recordList = component.get('v.recordList');
        
        $A.createComponent("c:DN_WAMDDetailModal",
            {
                'modalType': 'DUEOUT',
                'docNum' : recordList[index].material
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    $A.getCallback(function () {
                        console.log("Modal rendered successfully");
                        var container = component.find("WAMDDetailModal");
                        container.set("v.body", content);
                    })();
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // Due In Modal
    openDUEINDetailModal: function (component, event, helper) {
        let index = event.currentTarget.name;
        let recordList = component.get('v.recordList');
        $A.createComponent("c:DN_WAMDDetailModal",
            {
                'modalType': 'DUEIN',
                'docNum' : recordList[index].material
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    $A.getCallback(function () {
                        console.log("Modal rendered successfully");
                        var container = component.find("WAMDDetailModal");
                        container.set("v.body", content);
                    })();
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // WAMD Modal
    openWAMDDetailModal: function (component, event, helper) {
        let index = event.currentTarget.name;
        let recordList = component.get('v.recordList');
        $A.createComponent("c:DN_WAMDDetailModal",
            {
                'modalType': 'WAMD',
                'docNum' : recordList[index].material
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    $A.getCallback(function () {
                        console.log("Modal rendered successfully");
                        var container = component.find("WAMDDetailModal");
                        container.set("v.body", content);
                    })();
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // 가용재고 오픈
    openLABSTDetailModal: function (component, event, helper) {
        let index = event.currentTarget.name;
        let recordList = component.get('v.recordList');
        $A.createComponent("c:DN_WAMDDetailModal",
            {
                'modalType': 'LABST',
                'docNum' : recordList[index].material
                
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    $A.getCallback(function () {
                        console.log("Modal rendered successfully");
                        var container = component.find("WAMDDetailModal");
                        container.set("v.body", content);
                    })();
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
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
                    let where = component.get('v.whereCondition');
                    console.log(JSON.stringify(where), ' :::where');
                    if(where.ABCIndicator =='ALL' && where.MRPType =='ALL') {
                        if(where.productCode ==undefined) {
                            helper.toast('error','부품번호 입력 또는 ABC Indicator 또는 MRP Type을 선택하세요');
                            return;
                        }
                    }    
                    helper.getDataQuery(component, params.type, '검색이 완료되었습니다.')
                            .then($A.getCallback(function(result) {
                                if(component.get('v.recordList').length == 0) {
                                    component.set('v.excelData', []);
                                    return Promise.reject('No Data');
                                }

                                return helper.executeExcelGenerate(component);
                            }))
                            .catch(error => {
                                console.log(error,' :: sserror');
                            })
                    break;
                case 'ExcelDownload': 
                    component.set('v.isLoading', true);

                    component.set('v.isExcelButton', true);
                    if(component.get('v.isExcelButton')) {
                        if(component.get('v.recordList').length == 0) { 
                            helper.toast('error','검색되는 데이터가 없습니다.');
                            component.set('v.isExcelButton', false);
                            component.set('v.isLoading', false);
                            return;
                        }
                        helper.handleExcelDownload(component);    
                        component.set('v.isExcelButton', false);
                    }
                    

                    // if(component.get('v.isExcelData')) {
                    //     helper.handleExcel(component);
                    //     component.set('v.isExcelButton', false);
                    // }
                    break;
                case 'PageChnage':
                    //console.log(JSON.stringify(msg), ' msg');
                    component.set('v.nextPage',params.message.nextpage);
                    component.set('v.currentPage',params.message.currentPage);
                    helper.getDataQuery(component,params.type, '검색이 완료되었습니다.');
                    break; 
                case 'Save':
                    let seletedList = component.get('v.seletedList');
                    if(seletedList.length > 0) {
                        //링크 이동
                        let hostname = window.location.hostname;
                        let pathName = window.location.pathname;
                        let navService = component.find('navService');
                        pathName = pathName.substring(0, pathName.lastIndexOf('/') + 1);
                        
                        let matList = [];
                        let qtyList = [];
                        let dealerList = [];
                        let dealerCodeList = [];
                        let dealerNameList = [];
                        seletedList.forEach(element => {
                            matList.push(element.material);
                            qtyList.push(element.poQTY);
                            let dealer = element.dealer !=undefined? element.dealer : '';
                            let dealerCode = element.dealerCode !=undefined? element.dealerCode : '';
                            let dealerName = element.dealerName !=undefined? element.dealerName : '';
                            console.log(dealer, ' dealer');
                            console.log(dealerCode, ' dealerCode');
                            console.log(dealerName, ' dealerName');
                            dealerList.push(dealer);
                            dealerCodeList.push(dealerCode);
                            dealerNameList.push(dealerName);
                        });
                        
                        let urls = hostname + pathName +params.message.modalName +`?c_Material=${matList.join(',')}&c_QTY=${qtyList.join(',')}&c_daler=${dealerList.join(',')}&c_code=${dealerCodeList.join(',')}}&c_name=${dealerNameList.join(',')}`;
                        console.log(urls,' ::: urls');
                        let pageReference = {
                            type: "standard__webPage",
                            attributes: {
                                url: urls,
                            },
                        };
                        navService.navigate(pageReference)
                        break;
                    } else {
                        helper.toast('error',' 항목을 선택해주세요');
                        break;
                    }
                    
                default:
                    break;
            }  
        }
    },

    // 테이블 세로 스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

    handeQTYChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let recordList = component.get('v.recordList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(orderQty);
        }
        recordList[index].poQTY = value;
        component.set('v.recordList',recordList);
    },

})