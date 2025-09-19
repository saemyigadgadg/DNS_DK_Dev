/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-13-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-13-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({  
    doInit : function (component, event, helper) {
        var baseUrl = window.location.origin;
        component.set("v.baseUrl", baseUrl);
        
        // 접수일자 오늘로 To Date 초기 설정
        let today = new Date();
        let todayString = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
        component.set("v.receiptDateTo", todayString);

        // 접수일자 오늘 달의 1일로 설정 From Date 초기 설정
        let firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        let firstDayString = firstDayOfMonth.getFullYear() + '-' + ('0' + (firstDayOfMonth.getMonth() + 1)).slice(-2) + '-' + ('0' + firstDayOfMonth.getDate()).slice(-2);

        component.set("v.receiptDateFrom", firstDayString);

        let action = component.get("c.getLoginUserInfo");
        
        action.setParams({ });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let r = response.getReturnValue();

            if (state === "SUCCESS") {
                if (r.flag == "success") {
                    component.set("v.isBranch",r.isBranch);
                    component.set("v.originWCId",r.workCenterInfo.Id);
                    component.set("v.workCenter",r.workCenterInfo);
                    component.set("v.worker",r.workerInfo);
                    component.set("v.plant" , r.workCenterInfo.PlanningPlant__c);

                    if (r.workCenterInfo.PlanningPlant__c == '184S') {
                        var orderTypes = [
                            {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''},
                            {'label': $A.get("$Label.c.service_lbl_inspection_order"), 'value': 'CS01'},
                            {'label': $A.get("$Label.c.service_lbl_field_service_order"), 'value': 'CS02'},
                            {'label': $A.get("$Label.c.service_lbl_other_service_order"), 'value': 'CS08'},
                        ];
                        component.set("v.orderTypeOptions", orderTypes);
                        component.set("v.orderTypeValue", 'CS01');
                    } else {
                        var orderTypes = [
                            {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''},
                            {'label': 'History Order', 'value': 'HS01'},
                        ];
                        component.set("v.orderTypeOptions", orderTypes);
                        component.set("v.orderTypeValue", 'HS01');
                    }

                    console.log('workCenterInfo   ', r.workCenterInfo);
                    console.log('originWCId   ', r.workCenterInfo.Id);
                } else if (r.flag == "warning") {
                    helper.toast("WARNING", r.message);
                } else {
                    helper.toast("Error", r.message);
                }
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Apex Exception ::: ", errors[0].message);
                    helper.toast("Error", "An error occurred. Please contact the administrator.");
                } else {
                    console.error("Apex Exception :::", "unknown error");
                    helper.toast("Error", "An error occurred. Please contact the administrator.");
                }
            }
        });
        $A.enqueueAction(action);    

        helper.fetchNCTypeList(component, event, helper);
    },

    handleDayCountCheck : function (component, event, helper) {
        var selectStartDate = component.get('v.receiptDateFrom');
        var selectEndDate   = component.get('v.receiptDateTo');

        if (selectEndDate < selectStartDate) {
            // helper.toast('WARNING', '{!$Label.c.service_msg_validation_001}');
            helper.toast('WARNING', '시작일이 종료일 보다 클 순 없습니다.');
            // 시작일이 종료이보다클 순 없습니다.
            selectEndDate = selectStartDate;
            component.set('v.receiptDateTo', selectEndDate);
            component.find('endDate').focus();
            return ;
        }
        
        // var result = helper.daycounter(selectStartDate, selectEndDate);

        // if (result > 365) {
        //     helper.toast('WARNING', '{!$Label.c.service_msg_validation_002}');
        //     // 기간은 365일을 초과할 수 없습니다.
        //     selectEndDate = selectStartDate;
        //     component.set('v.receiptDateTo', selectEndDate);
        //     component.find('endDate').focus();
        //     return ;
        // }
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
    openCustomerSearchModal : function(component, event, helper){
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_CustomerListModalforSalesServiceHistory",
                {},
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
            var container = component.find("customerSearchModal");
            container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);
    },

    // WorkCenter 모달
    openDealerModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        let workCenterId = component.get("v.originWCId");
        $A.createComponent("c:DN_dealerModal",
            {
                'workCenterId': workCenterId
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("dealerModal");
                    console.log("container", container);
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 작업자 모달 
    openServiceManModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        let selectedWCId = component.get("v.workCenter").Id; 
        let isBranch = component.get("v.isBranch");
        console.log('selectedWCId', selectedWCId);
        if(selectedWCId == null) {
            selectedWCId = '';
        } 

        $A.createComponent("c:DN_serviceManModal", 
            {
                'curruntWorkcenterId': selectedWCId ,
                'isBranch' : isBranch , 

            }, 
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("serviceManModal");
                    console.log("container", container);
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 모달 이벤트 핸들러
    handleCompEvent :function (component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message"); 

        if (modalName == 'DN_CustomerListModalforSalesServiceHistory') {
            console.log("name", message.Name);
            component.set('v.customerInfo', message);
        } else if(modalName == 'DealerModal') {
            console.log('DealerModal ::: ', JSON.stringify(message, null, 2));
            component.set('v.workCenter', message);
            console.log('SELECTED ::: ' , JSON.stringify(component.get("v.workCenter"), null , 2));
            
        } else if (modalName == 'DN_serviceManModal') {
            console.log('before worker ::: ', component.get("v.worker"));
            component.set('v.worker', message);
            console.log('updated worker ::: ', component.get("v.worker"));

        } else if (modalName == 'MachineModal') {
            component.set("v.machineName", message.label);
            component.set('v.assetName', "");
            component.set('v.assetData', "");
        
        } else if(modalName == 'SerialModal') {
            component.set("v.assetName", message.label);
            component.set("v.machineName", message.machineName);
            
        }        
    },

    //오더번호 클릭시 서비스 페이지로 이동
    openOrderWrapper : function (component, event, helper) {
        const element = event.currentTarget;
        const orderNumber = event.currentTarget.dataset.orderNumber;
        component.set("v.orderNumber", orderNumber);

        //css 변경 위해 class 추가
        element.classList.add("visited");

        let currentUrl = component.get("v.baseUrl");
        if (currentUrl.includes("--dev.sandbox")) {
            currentUrl += `/partners/s/service-wrap?orderNumber=${orderNumber}`;
        } else {
            currentUrl += `/s/service-wrap?orderNumber=${orderNumber}`;
        }

        window.open(currentUrl, "_blank");
    },

    // 서비스 이력 조회
    doSearch : function (component, event, helper) {
        let receiptDateFrom = component.get("v.receiptDateFrom") || null;
        let receiptDateTo = component.get("v.receiptDateTo") || null;

        let searchData = {
            receiptDateFrom : receiptDateFrom,
            receiptDateTo   : receiptDateTo,
            orderNumber     : component.get("v.orderNumber") || null,
            customerName    : component.get("v.customerInfo").Name || null,
            machineName     : component.get("v.machineName") || null,
            assetName       : component.get("v.assetName") || null,
            orderType       : component.get("v.orderTypeValue") || null,
            workCenter      : component.get("v.workCenter").Name || null,
            ncType          : component.get("v.ncTypeValue") || null,
            worker          : component.get("v.worker").Id || null,
        };

        if (!searchData.receiptDateFrom || !searchData.receiptDateTo) {
            helper.toast('WARNING', '{!$Label.c.service_msg_validation_009}');
            // 검색할 접수일자의 시작일과 종료일을 선택해주세요.
            if (!searchData.receiptDateFrom) {
                component.find('startDate').focus();
            } else {
                component.find('endDate').focus();
            }
            return;
        }

        const keysToCheck = ['orderNumber', 'customerName', 'machineName', 'assetName', 'workCenter', 'ncType', 'worker'];
        let isNonEmptySearch = keysToCheck.some(key => {
            let val = searchData[key];
            return val !== null && val !== undefined && String(val).trim() !== '';
        });

        if (!isNonEmptySearch) {
            var result = helper.daycounter(searchData.receiptDateFrom, searchData.receiptDateTo);
            if (result > 365) {
                // helper.toast('WARNING', '{!$Label.c.service_msg_validation_002}');
                helper.toast('WARNING', '날짜를 제외한 추가 검색 조건이 없으면 기간은 365일을 초과 할 수 없습니다.');
                // 기간은 365일을 초과할 수 없습니다.
                component.set('v.receiptDateTo', searchData.receiptDateTo);
                component.find('endDate').focus();
                return ;
            }
        }

        console.log('searchData ::: ' , JSON.stringify(searchData, null, 2));
        
        component.set("v.isLoading", true);
        
        helper.apexCall(component, event, helper, 'getCSServiceHistoryList', { searchData : searchData })
        .then($A.getCallback(function(result) {
            const responseData = result.r.serviceHistoryList;

            console.log('response ::: ', JSON.stringify(result.r, null, 2));
    
            if(result.r.flag == 'success' && responseData != null) {
                helper.toast('SUCCESS', $A.get("$Label.c.service_msg_validation_010"));
                // 검색이 성공적으로 완료되었습니다.
                component.set("v.isSearched", true);
                component.set("v.serviceHistoryList", responseData);

                console.log('queryString ::: ', JSON.stringify(result.r.queryString, null, 2));

                let excelData = [];
                
                responseData.forEach(element => {
                
                    excelData.push({
                        [$A.get("$Label.c.service_fld_account")]: element.Account && element.Account.Name ? element.Account.Name : '',
                        [$A.get("$Label.c.service_fld_order_type")]: element.PMActivityType__c || '', 
                        [$A.get("$Label.c.service_fld_order_type2")]: element.OrderType__c || '', 
                        [$A.get("$Label.c.service_fld_generation_date")]: element.Case && element.Case.CreatedDate ? element.Case.CreatedDate.substring(0,10) : '',
                        [$A.get("$Label.c.service_fld_confirmed_processing_date")]: element.ConfirmedDate__c ? element.ConfirmedDate__c.substring(0,10) : '',
                        [$A.get("$Label.c.service_fld_warranty_divition")]: element.Asset && element.Asset.FM_EquipmentWarrantyEquipmentParts__c ? element.Asset.FM_EquipmentWarrantyEquipmentParts__c : '',
                        [$A.get("$Label.c.service_fld_work_center")]: element.ServiceTerritory && element.ServiceTerritory.Name ? element.ServiceTerritory.Name : '',
                        [$A.get("$Label.c.service_fld_counselor")]: element.Case && element.Case.Owner && element.Case.Owner.Name ? element.Case.Owner.Name : '', 
                        [$A.get("$Label.c.service_fld_order_no")]: element.ServiceOrderNumber__c || '',
                        [$A.get("$Label.c.service_fld_model")]: element.Asset && element.Asset.MachineName__c ? element.Asset.MachineName__c : '',
                        [$A.get("$Label.c.service_fld_serial_no")]: element.Asset && element.Asset.Name ? element.Asset.Name : '',
                        [$A.get("$Label.c.service_fld_received_desc")]: element.Case && element.Case.ReceptionDetails__c ? element.Case.ReceptionDetails__c : '', 
                        [$A.get("$Label.c.service_fld_action_history")]: element.PendingOrCustomerMatters__c || '', 
                        [$A.get("$Label.c.service_fld_worker")]: element.Worker__r && element.Worker__r.Name ? element.Worker__r.Name : '', 
                        [$A.get("$Label.c.service_fld_nc_type")]: element.Asset && element.Asset.NCType__c ? element.Asset.NCType__c : '', 
                    })
                });                
                
                component.set('v.excelData',excelData);
                component.set("v.isLoading", false);
            } else {
                helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_011"));
                console.log();
                component.set("v.isSearched", false);
                component.set("v.serviceHistoryList", []);
                component.set("v.isLoading", false);
            }
        }))
        // .catch(function(error) {
        //     helper.toast('ERROR', 'An error occurred, please contact your administrator.');
        //     console.log('# getCSServiceHistoryList error message ::: ' + error.message);
        //     component.set("v.isLoading", false);
        // });  
        // .catch($A.getCallback(function(error) {
        //     console.error('# getCSServiceHistoryList error message ::: ', JSON.stringify(error, null, 2));
        
        //     helper.toast('ERROR', 'An error occurred, please contact your administrator.');
        
        //     component.set("v.isLoading", false);
        // }));
        .catch(error => {
            helper.toast('ERROR',  $A.get("$Label.c.service_err_failed_to_retrieve_data"));
            // 데이터 조회에 실패했습니다. 관리자에게 문의해주세요.
            console.error('csServiceHistory Search Error :::', JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },

    //sticky table scroll 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

    // 기종 지우기
    clearMachine: function (component, event, helper) {
        helper.clearField(component, "machineName", $A.get("$Label.c.service_lbl_model"));
    },

    // 장비번호 지우기
    clearAsset: function (component, event, helper) {
        helper.clearField(component, "assetName", $A.get("$Label.c.service_lbl_serial_no"));
    },

    // 작업자 지우기
    clearServiceMan: function (component, event, helper) {
        helper.clearField(component, "worker", $A.get("$Label.c.service_lbl_worker"));
    },

    // 고객사명 지우기
    clearCustomerName: function (component, event, helper) {
        const customer = component.get("v.customerInfo.Name");
        console.log("customer", customer);
    
        if (!customer) { 
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_012"));
            // 저장된 고객사 값이 없습니다.
            return;
        }

        component.set("v.customerInfo", "");
    },

    // 워크센터 지우기
    clearWorkCenter: function (component, event, helper) {
        helper.clearField(component, "workCenter", "워크센터");
    }
})