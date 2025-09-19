/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-28-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-06-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        // Sandbox & Production url 구분
        var baseUrl = window.location.origin;
        console.log('baseUrl check ::: personnelDispatch ', baseUrl);
        component.set("v.baseUrl", baseUrl);

        // 작업 계획일 기본 값
        var today = new Date();
        var year = today.getFullYear();
        var month = today.getMonth(); // 0-based

        // 종료일: 올해 이번달 30일
        var endDate = new Date(year, month, 30);
        var endDateString = endDate.getFullYear() + '-' + ('0' + (endDate.getMonth() + 1)).slice(-2) + '-' + ('0' + endDate.getDate()).slice(-2);
        component.set("v.workEndDate", endDateString);

        // 시작일: 작년 이번달 30일
        var startDate = new Date(year - 1, month, 30);
        var startDateString = startDate.getFullYear() + '-' + ('0' + (startDate.getMonth() + 1)).slice(-2) + '-' + ('0' + startDate.getDate()).slice(-2);
        component.set("v.workStartDate", startDateString);

            
        var options = [
            {'label': $A.get("$Label.c.service_lbl_pending"), 'value': 'notConfirm'},
            {'label': $A.get("$Label.c.service_lbl_confirmed"), 'value': 'Confirm'},
            {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''}
        ];
        component.set("v.options", options);
        
        let action = component.get("c.getLoginUserInfo");
        
        action.setParams({ });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let r = response.getReturnValue();
            
            if (state === "SUCCESS") {
                console.log('plant', r.workCenterInfo.PlanningPlant__c);
                component.set("v.plant", r.workCenterInfo.PlanningPlant__c);
                if (r.workCenterInfo.PlanningPlant__c != '414S') {
                    component.set("v.isDNSA", false);

                    var orderTypes = [
                        {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''},
                        {'label': $A.get("$Label.c.service_lbl_inspection_order"), 'value': 'CS01'},
                        {'label': $A.get("$Label.c.service_lbl_field_service_order"), 'value': 'CS02'},
                        {'label': $A.get("$Label.c.service_lbl_other_service_order"), 'value': 'CS08'},
                    ];
                    component.set("v.orderTypes", orderTypes);
                } else {
                    var orderTypes = [
                        {'label': $A.get("$Label.c.service_lbl_all"), 'value': ''},
                        {'label': 'History Order', 'value': 'HS01'},
                    ];
                    component.set("v.orderTypes", orderTypes);
                }
            }
        });
        $A.enqueueAction(action);

    },

    // 검색 전 작업계획일 Validation
    handleDayCountCheck : function (component, event, helper) {
        var selectStartDate = component.get('v.workStartDate');
        var selectEndDate   = component.get('v.workEndDate');
        var result = helper.daycounter(selectStartDate, selectEndDate);

        if (selectEndDate < selectStartDate) {
            // 시작일이 종료일 보다 클 수 없습니다.
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_001"));
            var parts = selectStartDate.split("-");
            var year = parseInt(parts[0], 10);
            var month = parseInt(parts[1], 10) - 1; // JavaScript는 0부터 시작하는 월 (0=1월)
            var day = parseInt(parts[2], 10);

            var dateObj = new Date(year, month, day);

            dateObj.setFullYear(dateObj.getFullYear() + 1);

            var result = dateObj.getFullYear() + "-" + String(dateObj.getMonth() + 1).padStart(2, "0") + "-" + String(dateObj.getDate()).padStart(2, "0");
            selectEndDate = result;
            component.set('v.workEndDate', selectEndDate);
            component.find('endDate').focus();
            return ;
        }

        if (result > 365) {
            // 기간은 365일을 초과할 수 없습니다.
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_002"));
            var parts = selectStartDate.split("-");
            var year = parseInt(parts[0], 10);
            var month = parseInt(parts[1], 10) - 1;
            var day = parseInt(parts[2], 10);

            var dateObj = new Date(year, month, day);

            dateObj.setFullYear(dateObj.getFullYear() + 1);

            var result = dateObj.getFullYear() + "-" + String(dateObj.getMonth() + 1).padStart(2, "0") + "-" + String(dateObj.getDate()).padStart(2, "0");
            selectEndDate = result;
            component.set('v.workEndDate', selectEndDate);
            component.find('endDate').focus();
            return ;
        }
    },
    
    // 서비스 진행 업무 현황 조회 
    doSearch : function(component, event, helper) {
        let searchData = {
            workStatus      : component.get("v.workStatus"),
            workStartDate   : component.get("v.workStartDate"),
            workEndDate     : component.get("v.workEndDate"),
            workOrderNumber : component.get("v.workOrderNumber").trim(),
            orderType       : component.get("v.orderType"),
            hasWarranty     : component.get('V.hasWarranty'),
        };

        if (!searchData.workStartDate || !searchData.workEndDate) {
            // 검색할 출동요청일 시작일과 종료일을 선택해주세요.
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_003"));
            if (!searchData.workStartDate) {
                component.find('startDate').focus();
            } else {
                component.find('endDate').focus();
            }
            return;
        }

        console.log('searchData 수정 ::: ' , JSON.stringify(searchData, null, 2));
        
        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'searchProgressWork', { searchData: searchData })
        .then($A.getCallback(function(result) {

            const responseData = result.r.serviceList;

            if (result.r.flag === 'notServiceResource') {
                helper.toast('WARNING', '로그인된 계정은 서비스요원 계정이 아닙니다.');
                component.set('v.isSearched', false);
                component.set('v.isLoading', false);
                return;
            }

            if (responseData && Array.isArray(responseData)) {
                console.log('queryString size ::: ', responseData.length);
            } else {
                helper.toast('WARNING', 'No records found.');
                component.set("v.serviceList", []);
                component.set('v.excelData', []);
                component.set('v.isLoading', false);
                return;
            }

            console.log('response ::: ', JSON.stringify(responseData, null, 2));
            console.log('queryString ::: ', JSON.stringify(result.r.queryString, null, 2));

            component.set("v.isSearched", true);

            let _isDNSA = component.get("v.isDNSA");
            if(result.r.flag == 'success' && responseData != null) {
                if (result.r.CRM_USER) {
                    // 검색 결과가 조회되었습니다. 내부 사용자는 조회만 가능합니다.
                    helper.toast('SUCCESS', $A.get("$Label.c.service_msg_success2"));
                } else {
                    // 검색 결과가 조회되었습니다.
                    helper.toast('SUCCESS', $A.get("$Label.c.service_msg_success"));
                }
                component.set("v.serviceList", responseData);

                let excelData = [];

                responseData.forEach(element => {
                    
                    let _requestDate = '';
                    if (element.HasWarrantyDirectManagement__c) {
                        _requestDate = $A.util.isEmpty(element.ReceiptDate__c) ? '' : $A.localizationService.formatDate(element.ReceiptDate__c, 'yyyy-MM-dd');
                    } else {
                        _requestDate = $A.util.isEmpty(element.ScheduledDispatchTime__c) ? '' : $A.localizationService.formatDate(element.ScheduledDispatchTime__c, 'yyyy-MM-dd');
                    }
                    if (_isDNSA) {
                        excelData.push({
                            [$A.get("$Label.c.service_fld_dispatch_request_date")]: _requestDate, 
                            [$A.get("$Label.c.service_fld_order_type")]: element.PMActivityType__c || '', 
                            [$A.get("$Label.c.service_fld_order_type2")]: element.OrderType__c || '', 
                            [$A.get("$Label.c.service_fld_order_no")]: element.ServiceOrderNumber__c || '',
                            [$A.get("$Label.c.service_fld_work_center")]: element.ServiceTerritory && element.ServiceTerritory.Name ? element.ServiceTerritory.Name : '',
                            [$A.get("$Label.c.service_fld_worker")]: element.Worker__r && element.Worker__r.Name ? element.Worker__r.Name : '',
                            [$A.get("$Label.c.service_fld_account")]: element.Account && element.Account.Name ? element.Account.Name : '',
                            [$A.get("$Label.c.service_fld_model")]: element.Asset && element.Asset.MachineName__c ? element.Asset.MachineName__c : '', 
                            [$A.get("$Label.c.service_fld_serial_no")]: element.Asset && element.Asset.Name ? element.Asset.Name : '',
                            [$A.get("$Label.c.service_fld_order_details")]: element.Case && element.Case.ReceptionDetails__c ? element.Case.ReceptionDetails__c : '',
                            [$A.get("$Label.c.service_fld_installation_completion_date")]: element.Asset && element.Asset.WarrantyStartDateWages__c ? element.Asset.WarrantyStartDateWages__c : '',
                            [$A.get("$Label.c.service_fld_received_date")]: element.Case && element.Case.ApplicationDateTime__c ? element.Case.ApplicationDateTime__c.substring(0,10) : '', 
                            [$A.get("$Label.c.service_fld_status")]: element.Status == 'Confirm' || element.Status == 'Completed' ?  $A.get("$Label.c.service_lbl_confirmed") : $A.get("$Label.c.service_lbl_pending"), 
                        })
                    } else {
                        excelData.push({
                            [$A.get("$Label.c.service_fld_dispatch_request_date")]: _requestDate, 
                            [$A.get("$Label.c.service_fld_order_type")]: element.PMActivityType__c || '', 
                            [$A.get("$Label.c.service_fld_order_type2")]: element.OrderType__c || '', 
                            [$A.get("$Label.c.service_fld_order_no")]: element.ServiceOrderNumber__c || '',
                            [$A.get("$Label.c.service_fld_work_center")]: element.ServiceTerritory && element.ServiceTerritory.Name ? element.ServiceTerritory.Name : '',
                            [$A.get("$Label.c.service_fld_worker")]: element.Worker__r && element.Worker__r.Name ? element.Worker__r.Name : '',
                            [$A.get("$Label.c.service_fld_account")]: element.Account && element.Account.Name ? element.Account.Name : '',
                            [$A.get("$Label.c.service_fld_model")]: element.Asset && element.Asset.MachineName__c ? element.Asset.MachineName__c : '', 
                            [$A.get("$Label.c.service_fld_serial_no")]: element.Asset && element.Asset.Name ? element.Asset.Name : '',
                            [$A.get("$Label.c.service_fld_order_details")]: element.Case && element.Case.ReceptionDetails__c ? element.Case.ReceptionDetails__c : '',
                            [$A.get("$Label.c.service_fld_installation_completion_date")]: element.Asset && element.Asset.WarrantyStartDateWages__c ? element.Asset.WarrantyStartDateWages__c : '',
                            [$A.get("$Label.c.service_fld_received_date")]: element.Case && element.Case.ApplicationDateTime__c ? element.Case.ApplicationDateTime__c.substring(0,10) : '', 
                            [$A.get("$Label.c.service_fld_status")]: element.Status == 'Confirm' ?  $A.get("$Label.c.service_lbl_confirmed") : $A.get("$Label.c.service_lbl_pending"), 
                            [$A.get("$Label.c.service_fld_hq_assignment")]: element.HasWarrantyDirectManagement__c ? 'N' : 'Y', 
                        })
                    }
                    // excelData.push({
                    //     [$A.get("$Label.c.service_fld_dispatch_request_date")]: element.HasWarrantyDirectManagement__c ? element.ReceiptDate__c.substring(0,10) || '' : element.ScheduledDispatchTime__c.substring(0,10) || '', 
                    //     [$A.get("$Label.c.service_fld_order_type")]: element.PMActivityType__c || '', 
                    //     [$A.get("$Label.c.service_fld_order_type2")]: element.OrderType__c || '', 
                    //     [$A.get("$Label.c.service_fld_order_no")]: element.ServiceOrderNumber__c || '',
                    //     [$A.get("$Label.c.service_fld_work_center")]: element.ServiceTerritory && element.ServiceTerritory.Name ? element.ServiceTerritory.Name : '',
                    //     [$A.get("$Label.c.service_fld_worker")]: element.Worker__r && element.Worker__r.Name ? element.Worker__r.Name : '',
                    //     [$A.get("$Label.c.service_fld_account")]: element.Account && element.Account.Name ? element.Account.Name : '',
                    //     [$A.get("$Label.c.service_fld_model")]: element.Asset && element.Asset.MachineName__c ? element.Asset.MachineName__c : '', 
                    //     [$A.get("$Label.c.service_fld_serial_no")]: element.Asset && element.Asset.Name ? element.Asset.Name : '',
                    //     [$A.get("$Label.c.service_fld_order_details")]: element.Case && element.Case.ReceptionDetails__c ? element.Case.ReceptionDetails__c : '',
                    //     [$A.get("$Label.c.service_fld_installation_completion_date")]: element.Asset && element.Asset.InstallDate ? element.Asset.InstallDate : '',
                    //     [$A.get("$Label.c.service_fld_received_date")]: element.Case && element.Case.ApplicationDateTime__c ? element.Case.ApplicationDateTime__c.substring(0,10) : '', 
                    //     [$A.get("$Label.c.service_fld_status")]: element.Status == 'Confirm' ?  $A.get("$Label.c.service_lbl_confirmed") : $A.get("$Label.c.service_lbl_pending"), 
                    //     [$A.get("$Label.c.service_fld_hq_assignment")]: element.HasWarrantyDirectManagement__c ? 'N' : 'Y', 
                    // })
                });                
                
                component.set('v.excelData', excelData);
                component.set('v.isLoading', false);
            } else if (result.r.flag == 'notServiceResource') {
                // 현재 로그인된 유저는service resource 가 아닙니다.
                helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_004"));
                component.set('v.isLoading', false);
            } else {
                helper.toast('WARNING', 'No records found.');
                console.log(result.r.message);
                component.set("v.serviceList", []);
                component.set('v.excelData', []);
                component.set('v.isLoading', false);
            }
        }))
        .catch(error => {
            // 데이터 조회에 실패했습니다. 관리자에게 문의해주세요.
            helper.toast('ERROR', $A.get("$Label.c.service_err_failed_to_retrieve_data"));
            console.error('Search Error :::', JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },

    openOrderWrapper : function (component, event, helper) {
        const element = event.currentTarget;
        const orderNumber = event.currentTarget.dataset.orderNumber;
        component.set("v.orderNumber", orderNumber);

        element.classList.add("visited");

        var currentUrl = component.get("v.baseUrl");

        if (currentUrl.includes("--dev.sandbox")) {
            currentUrl += `/partners/s/service-wrap?orderNumber=${orderNumber}`;
            console.log('baseUrl check by Sandbox ::: ' , JSON.stringify(currentUrl, null, 2));            
        } else {
            currentUrl += `/s/service-wrap?orderNumber=${orderNumber}`;
            console.log('baseUrl check by Production ::: ' , JSON.stringify(currentUrl, null, 2));
        }

        window.open(currentUrl, "_blank");
    },

    handleKeyPress: function (component, event, helper) {
        if(event.keyCode === 13) {
            $A.enqueueAction(component.get('c.doSearch'));
        }
    }
})