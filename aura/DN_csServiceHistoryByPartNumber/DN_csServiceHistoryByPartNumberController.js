/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-13-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-07-2024   youjin.shim@sbtglobal.com   Initial Version
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
        
        var orderTypes = [
            {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''},
            {'label': $A.get("$Label.c.service_lbl_inspection_order"), 'value': 'CS01'},
            {'label': $A.get("$Label.c.service_lbl_field_service_order"), 'value': 'CS02'},
            {'label': $A.get("$Label.c.service_lbl_other_service_order"), 'value': 'CS08'},
        ];
        component.set("v.orderTypeOptions", orderTypes);

        let action = component.get("c.getLoginUserInfo");
        
        action.setParams({ });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let r = response.getReturnValue();

            console.log('login User Info ::: ', JSON.stringify(r, null, 2));

            if (state === "SUCCESS") {
                if (r.flag == "success") {
                    component.set("v.loginUserInfo", r);
                    component.set("v.isBranch",r.isBranch);
                    component.set("v.workCenter",r.workCenterInfo);
                    component.set("v.worker",r.workerInfo);

                    if (r.workCenterInfo.PlanningPlant__c == '184S') {
                        var orderTypes = [
                            {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''},
                            {'label': $A.get("$Label.c.service_lbl_inspection_order"), 'value': 'CS01'},
                            {'label': $A.get("$Label.c.service_lbl_field_service_order"), 'value': 'CS02'},
                            {'label': $A.get("$Label.c.service_lbl_other_service_order"), 'value': 'CS08'},
                        ];
                        component.set("v.orderTypeOptions", orderTypes);
                    } else {
                        var orderTypes = [
                            {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''},
                            {'label': 'History Order', 'value': 'HS01'},
                        ];
                        component.set("v.orderTypeOptions", orderTypes);
                    }
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
        
        // 해당 컴포넌트에서 row 정보 필요시 사용.
        // var rowIndex = event.getSource().get('v.accesskey');
        // component.set('v.selectedModelIndex', Number(rowIndex));

        var type = '장비번호';
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

    // 워크센터 모달
    openDealerModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        let workCenterId = component.get("v.workCenter").Id;
        
        if (!workCenterId) {
            workCenterId = component.get("v.loginUserInfo").workCenterInfo.Id;
        }

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
        let workCenterId = component.get("v.workCenter").Id; 
        let isBranch = component.get("v.isBranch");

        if(workCenterId == null) {
            workCenterId = '';
        } 

        $A.createComponent("c:DN_serviceManModal", 
            {
                'curruntWorkcenterId': workCenterId ,
                'isBranch' : isBranch
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

    // 모달 이벤트 핸들러
    handleCompEvent :function (component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message");
        if (modalName == 'DN_CustomerListModalforSalesServiceHistory') {
            component.set('v.customerInfo', message);
        } else if(modalName == 'DN_dealerModal') {
            component.set('v.workCenterInfo', message);
        } else if (modalName == 'MachineModal') {
            component.set("v.machineName", message.label);
            component.set('v.assetName', "");
            component.set('v.assetData', "");
        } else if (modalName == 'DN_serviceManModal') {
            console.log('before worker ::: ', component.get("v.worker"));
            component.set('v.worker', message);
            console.log('updated worker ::: ', component.get("v.worker"));

        } else if(modalName == 'SerialModal') {
            component.set("v.assetName", message.label);
            component.set("v.machineName", message.machineName);
            
            let assetId = message.value;

            if (!assetId) {
                helper.toast('WARNING', 'Please select unit information.');
                return;
            }        
            // helper.apexCall(component, event, helper, 'searchByAssetName', { assetId })
            // .then($A.getCallback(function(result) {
            //     let r = result.r;
            //     console.log('response ::: ', JSON.stringify(r, null, 2));
        
            //     if(r.flag == 'success' && r.assetData != null) {
            //         // helper.toast('SUCCESS', 'Request creation was successful');
            //         component.set('v.assetData', r.assetData);
            //     } else {
            //         helper.toast('WARNING', 'An error occurred, please contact your administrator.');
            //     }
            // }))
            // .catch(function(error) {
            //     helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            //     console.log('# requestcustomerId error : ' + error.message);
            //     component.set('v.isLoading', false);
            // });
        }
        
        if (actionName === 'Close') {
            helper.closeModal(component);
        }
    },

    // 검색 전 접수일자 Validation
    handleDayCountCheck : function (component, event, helper) {
        var selectStartDate = component.get('v.receiptDateFrom');
        var selectEndDate   = component.get('v.receiptDateTo');
        var result = helper.daycounter(selectStartDate, selectEndDate);

        if (selectEndDate < selectStartDate) {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_001"));
            // 시작일이 종료이보다클 순 없습니다.
            selectEndDate = selectStartDate;
            component.set('v.receiptDateTo', selectEndDate);
            component.find('endDate').focus();
            return ;
        }

        if (result > 365) {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_002"));
            // 기간은 365일을 초과할 수 없습니다.
            selectEndDate = selectStartDate;
            component.set('v.receiptDateTo', selectEndDate);
            component.find('endDate').focus();
            return ;
        }
    },

    // 서비스 이력 조회
    doSearch : function (component, event, helper) {
        let receiptDateFrom = component.get("v.receiptDateFrom") || null;
        let receiptDateTo = component.get("v.receiptDateTo") || null;

        let productNumber = component.get("v.productNumber") || null;
        let customerInfo = component.get("v.customerInfo") || null;

        let searchData = {
            receiptDateFrom: receiptDateFrom,
            receiptDateTo: receiptDateTo,
            orderNumber: component.get("v.orderNumber") || null,
            customerCode: customerInfo ? customerInfo.CustomerCode__c : null,
            machineName: component.get("v.machineName") || null,
            assetName: component.get("v.assetName") || null,
            orderType: component.get("v.orderTypeValue") || null,
            workCenter: component.get("v.workCenter") ? component.get("v.workCenter").Name : null,
            ncType: component.get("v.ncTypeValue") || null,
            worker: component.get("v.worker") ? component.get("v.worker").Id : null,
            productNumber: productNumber || null,
        };

        if (!searchData.receiptDateFrom || !searchData.receiptDateTo) {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_009"));
            // 검색할 접수일자의 시작일과 종료일을 선택해주세요.
            if (!searchData.receiptDateFrom) {
                component.find('startDate').focus();
            } else {
                component.find('endDate').focus();
            }
            return;
        }

        console.log('searchData ::: ' , JSON.stringify(searchData, null, 2));

        component.set("v.isLoading", true);
        
        helper.apexCall(component, event, helper, 'getCSServiceHistoryByPartNumber', { searchData : searchData })
        .then($A.getCallback(function(result) {
            const responseData = result.r.serviceHistoryList;
            console.log('response ::: ', JSON.stringify(result.r, null, 2));
    
            if(result.r.flag == 'success' && responseData.length !=0) {
                component.set("v.isSearched", true);
                component.set("v.serviceHistoryList", responseData);
                console.log('List Size ::: ', responseData.length);

                let excelData = [];
                
                responseData.forEach(element => {                
                    excelData.push({
                        '고객사': element.accountName ? element.accountName : '',
                        '오더 유형': element.pmActivityType ? element.pmActivityType : '', 
                        '오더 유형 2': element.orderType ? element.orderType : '', 
                        '생성일자': element.createdDate ? element.createdDate : '',
                        '확정처리일시': element.confirmedDate ? element.confirmedDate : '',
                        '보증 구분': element.warrantyType ? element.warrantyType : '',
                        'Work Center': element.workCenter ? element.workCenter : '',
                        '상담원': element.caseOwner ? element.caseOwner : '', 
                        '오더번호': element.orderNumber ? element.orderNumber : '',
                        '부품번호': element.productCode ? element.productCode : '',
                        '부품명': element.productName ? element.productName : '',
                        '기종': element.assetModel ? element.assetModel : '',
                        '장비번호': element.assetName ? element.assetName : '',
                        '접수내용': element.receptionDetail ? element.receptionDetail : '', 
                        '조치내역': element.actionDetail ? element.actionDetail : '', 
                        '작업자': element.worker ? element.worker : '', 
                        'NC Type': element.ncType ? element.ncType : '', 
                    })
                });                
                
                component.set('v.excelData', excelData);
                component.set("v.isLoading", false);
            } else {
                helper.toast('WARNING', 'No records found.');
                component.set("v.isSearched", false);
                component.set("v.serviceHistoryList", []);
                component.set('v.excelData', []);
                component.set("v.isLoading", false);
            }
        }))
        // .catch(function(error) {
        //     helper.toast('ERROR', 'An error occurred, please contact your administrator.');
        //     console.log('# getCSServiceHistoryList error : ' + error.message);
        //     component.set("v.isLoading", false);
        // });
        .catch(error => {
            helper.toast('ERROR', $A.get("$Label.c.service_err_failed_to_retrieve_data"));
            // 데이터 조회에 실패했습니다. 관리자에게 문의해주세요.
            console.error('Search Error :::', JSON.stringify(error, null, 2));
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
        helper.clearField(component, "machineName", "기종");
    },

    // 장비번호 지우기
    clearAsset: function (component, event, helper) {
        helper.clearField(component, "assetName", "장비번호");
    },

    // 작업자 지우기
    clearServiceMan: function (component, event, helper) {
        helper.clearField(component, "worker", "작업자");
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

        component.set("v.customerInfo.Name", "");
    },

    // 워크센터 지우기
    clearWorkCenter: function (component, event, helper) {
        helper.clearField(component, "workCenter", "워크센터");
    }
})