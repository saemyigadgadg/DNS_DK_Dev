/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-06-16
 * @last modified by  : chungwoo.lee@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-12   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        // 접수일 (To) 기본 값 설정
        // var today = new Date();
        // var todayString = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
        // component.set("v.ReceptionDateTo", todayString);

        // // 접수일 (From) 기본 값 설정
        // var firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        // var firstDayString = firstDayOfMonth.getFullYear() + '-' + ('0' + (firstDayOfMonth.getMonth() + 1)).slice(-2) + '-' + ('0' + firstDayOfMonth.getDate()).slice(-2);

        // component.set("v.ReceptionDateFrom", firstDayString);
        
        // 접수일 기본 값
        var today = new Date();
        var year = today.getFullYear();
        var month = today.getMonth(); // 0-based

        // 종료일: 올해 이번달 30일
        var endDate = new Date(year, month, 30);
        var endDateString = endDate.getFullYear() + '-' + ('0' + (endDate.getMonth() + 1)).slice(-2) + '-' + ('0' + endDate.getDate()).slice(-2);
        component.set("v.ReceptionDateTo", endDateString);

        // 시작일: 작년 이번달 30일
        var startDate = new Date(year - 1, month, 30);
        var startDateString = startDate.getFullYear() + '-' + ('0' + (startDate.getMonth() + 1)).slice(-2) + '-' + ('0' + startDate.getDate()).slice(-2);
        component.set("v.ReceptionDateFrom", startDateString);

    },

    // 접수일자 Validation
    handleDayCountCheck : function (component, event, helper) {
        var selectStartDate = component.get('v.ReceptionDateFrom');
        var selectEndDate   = component.get('v.ReceptionDateTo');
        var result = helper.daycounter(selectStartDate, selectEndDate);

        if (selectEndDate < selectStartDate) {
            helper.toast('WARNING', '시작일이 종료일 보다 클 수 없습니다.');
            selectEndDate = selectStartDate;
            component.set('v.ReceptionDateTo', selectEndDate);
            return ;
        }

        if (result > 365) {
            helper.toast('WARNING', '기간은 365일을 초과할 수 없습니다.');
            selectEndDate = selectStartDate;
            component.set('v.ReceptionDateTo', selectEndDate);
            return ;
        }
    },

    //주문번호 모달 열기
    openOrderListModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        let eduTicket = true;
        $A.createComponent("c:DN_OrderListModalforServiceHistoryResult",
                {'eduTicket' : eduTicket},
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
            var container = component.find("OrderListModal");
            container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);

    },

    // 기종모달
    openModelModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        // var rowIndex = event.getSource().get('v.accesskey');
        var type = '기종';
        // component.set('v.selectedModelIndex', Number(rowIndex));
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 장비번호 모달 
    openSerialNumberModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        let machineName = component.get("v.machineName");
        // var rowIndex = event.getSource().get('v.accesskey');
        var type = '장비번호';
        // component.set('v.selectedModelIndex', Number(rowIndex));
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type,
                'MachineName' : machineName
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    //고객 모달 열기
    openCustomerListModal : function(component, event, helper){
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_CustomerListModalforSalesServiceHistory",
                {},
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
            var container = component.find("CustomerListModal");
            container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);
    },

    // 모달 이벤트
    handleCompEvent : function(component, event, helper) {
        var modalName = event.getParam("modalName");
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");
        console.log("modalName", modalName);
        console.log("message", JSON.stringify(message));
        if (modalName == 'DN_CustomerListModalforSalesServiceHistory') {
            console.log("name", message.Name);
            component.set('v.customerInfo', message);
        } else if (modalName == 'DN_OrderListModalforServiceHistoryResult') {
            console.log('messagetest ::: ', JSON.stringify(message.WorkOrderNumber, null, 4));
            component.set("v.workOrderInfo", message);
            
        } else if (modalName == 'MachineModal') {
            component.set("v.machineName", message.label);
            component.set('v.assetName', "");
            component.set('v.assetData', "");
        } else if (modalName == 'SerialModal') {
            component.set("v.assetName", message.label);
            
            let assetId = message.value;

            if (!assetId) {
                helper.toast('WARNING', 'Please select unit information.');
                return;
            }        
        } 
    },

    // 서비스 이력 검색
    doSearch : function (component, event, helper) {
        let psoNumber = component.get("v.workOrderInfo").psoNumber;
        let receiptDateFrom = component.get("v.ReceptionDateFrom") || null;
        let receiptDateTo = component.get("v.ReceptionDateTo") || null;

        let customerName = component.get("v.customerInfo.Name");
        let customerCode = component.get("v.customerInfo.CustomerCode__c");

        if (customerName && !customerCode) {
            helper.toast('WARNING', 'This customer does not have a customer code.');
            return;
        }
        
        console.log(receiptDateFrom);
        console.log(receiptDateTo);

        let searchData = {
            receiptDateFrom : receiptDateFrom, 
            receiptDateTo   : receiptDateTo,
            psoNumber       : psoNumber  || null,
            customerCode    : customerCode,
            machineName     : component.get("v.machineName") || null,
            assetName       : component.get("v.assetName") || null,
        };

        console.log(JSON.stringify(searchData, null, 2));
    
        component.set("v.isLoading", true);
    
        helper.apexCall(component, event, helper, 'getServiceHistoryList', { searchData : searchData })
        .then($A.getCallback(function(result) {
            console.log('result ::: ' + JSON.stringify(result, null, 2));
            let responseData = result.r.serviceHistoryList;
    
            console.log('response ::: ', JSON.stringify(responseData, null, 2));
            console.log('queryString ::: ', JSON.stringify(result.r.queryString, null, 2));
    
            if (result.r.flag == 'success' && responseData != null) {
                helper.toast('SUCCESS', 'Search completed successfully.');
                component.set("v.isSearched", true);
                component.set("v.serviceHistoryList", responseData);
                
                let excelData = [];
                
                responseData.forEach(element => {
                    excelData.push({
                        '고객사': element.Account && element.Account.Name ? element.Account.Name : '', 
                        '기종': element.Asset && element.Asset.MachineName__c ? element.Asset.MachineName__c : '',
                        '장비번호': element.Asset && element.Asset.Name ? element.Asset.Name : '',
                        '수주번호': element.Asset && element.Asset.Order__r && element.Asset.Order__r.ERPPSONo__c ? element.Asset.Order__r.ERPPSONo__c : '',
                        '장비도착일': element.Asset && element.Asset.InstallDate ? element.Asset.InstallDate : '',
                        '접수일자': element.Case && element.Case.ApplicationDateTime__c ? element.Case.ApplicationDateTime__c.substring(0,10) : '',
                        '서비스종결일': element.ConfirmedDate__c ? element.ConfirmedDate__c : '',
                        '오더유형': element.PMActivityType__c ? element.PMActivityType__c : '',
                        '오더유형 2': element.OrderType__c ? element.OrderType__c : '',
                        '서비스오더 번호': element.ServiceOrderNumber__c ? element.ServiceOrderNumber__c : '',
                        'Work Center': element.ServiceTerritory && element.ServiceTerritory.Name ? element.ServiceTerritory.Name : '',
                        '작업자': element.Worker__r && element.Worker__r.Name ? element.Worker__r.Name : '',
                        '고장부위내역': element.FailurePhenomenonDetail__c ? element.FailurePhenomenonDetail__c : '',
                        '고장원인내역': element.CauseOfFailureDetail__c ? element.CauseOfFailureDetail__c : '',
                        '고장조치분류': '',
                        '접수내역': element.Case && element.Case.ReceptionDetails__c ? element.Case.ReceptionDetails__c : '',
                        '조치내역': element.Case && element.PendingOrCustomerMatters__c ? element.PendingOrCustomerMatters__c : '',
                    })
                });                
                
                component.set('v.excelData',excelData);

            } else if (result.r.flag == 'arrivalDateNull') {
                helper.toast('WARNING', 'No filing date has been selected.');
            } else if (result.r.flag == 'NoneUserInfo') {
                helper.toast('WARNING', result.r.message);
            } else {
                helper.toast('WARNING', 'No records found.');
                component.set("v.isSearched", false);
                component.set("v.serviceHistoryList", []);
                component.set('v.excelData', []);
            }
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# getServiceHistoryList error : ' + error.message);
        })
        .finally(function() {
            component.set("v.isLoading", false);
        });
    },
    
    // 오더번호 지우기
    clearOrderNo: function (component, event, helper) {
        let workOrderInfo = component.get("v.workOrderInfo");
        if (!workOrderInfo) {
            helper.toast("WARNING", "저장된 수주주번호 값이 없습니다."); // 오더번호 값이 없을 때 알림
            return;
        }
        component.set("v.workOrderInfo", "");
    },

    // 기종 지우기
    clearMachine: function (component, event, helper) {
        let machineName = component.get("v.machineName");
        if (!machineName) {
            helper.toast("WARNING", "저장된 기종 값이 없습니다."); // 기종 값이 없을 때 알림
            return;
        }
        component.set("v.machineName", "");
    },

    //장비번호 지우기
    clearAsset : function (component, event, helper) {
        let assetName = component.get("v.assetName");
        if (!assetName) {
            helper.toast("WARNING", "저장된 장비번호 값이 없습니다."); // 장비번호 값이 없을 때 알림
            return;
        }
        component.set("v.assetName", "");
    },

    //고객사명 지우기
    clearCustomerName : function (component, event, helper) {
        // let customerCode = component.get("v.customerInfo.CustomerCode__c"); 

        // let customerCode = component.get("v.customerInfo");
        // if (!customerCode) {
        //     helper.toast("WARNING", "저장된 고객사명 값이 없습니다."); // 고객코드 값이 없을 때 알림
        //     return;
        // }

        let customerInfo = component.get("v.customerInfo");
        customerInfo = {};
        component.set("v.customerInfo", customerInfo);
    },

    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        table1.scrollTo({ top: scrollY, left: 0, behavior: 'auto' });
    },

})