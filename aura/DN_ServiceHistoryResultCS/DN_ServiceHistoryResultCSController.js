/**
 * @author            : youjin shim
 * @description       : 
 * @last modified on  : 03-14-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-11   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        // 접수일 (To) 기본 값 설정
        var today = new Date();
        var todayString = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
        component.set("v.endDate", todayString);

        // 접수일 (From) 기본 값 설정
        var firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        var firstDayString = firstDayOfMonth.getFullYear() + '-' + ('0' + (firstDayOfMonth.getMonth() + 1)).slice(-2) + '-' + ('0' + firstDayOfMonth.getDate()).slice(-2);

        component.set("v.startDate", firstDayString);
    },


    // 기종모달
    openModelModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        // 해당 컴포넌트에서 row 정보 필요시 사용.
        // var rowIndex = event.getSource().get('v.accesskey');
        // component.set('v.selectedModelIndex', Number(rowIndex));

        var type = '기종';
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

    clearMachine: function (component, event, helper) {
        let machineName = component.get("v.machineName");
        if (!machineName) {
            helper.toast("WARNING", $A.get("$Label.c.service_msg_validation_005")); 
            // 저장된 기종값이 없습니다.
            return;
        }
        component.set("v.machineName", "");
        component.set("v.assetName", "");
    },

    clearAsset : function (component, event, helper) {
        let assetName = component.get("v.assetName");
        if (!assetName) {
            helper.toast("WARNING", $A.get("$Label.c.service_msg_validation_006")); 
            // 저장된 장비번호 값이 없습니다.
            return;
        }
        component.set("v.assetName", "");
    },

    // 장비번호 모달 
    openSerialNumberModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        let machineName = component.get("v.machineName");

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

    // 모달 이벤트 핸들러
    handleCompEvent :function (component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message");


        if (modalName == 'DN_customerSearchModal') {
            component.set('v.customerInfo', message);
        } else if(modalName == 'DN_dealerModal') {
            component.set('v.workCenterInfo', message);
        } else if (modalName == 'MachineModal') {
            component.set("v.machineName", message.label);
            component.set('v.assetName', "");
            component.set('v.assetData', "");
        } else if(modalName == 'SerialModal') {
            component.set("v.assetName", message.label);
            component.set("v.machineName", message.machineName);
            component.set("v.equipmentObj", message);
            
            let assetId = message.value;

            if (!assetId) {
                helper.toast('WARNING', 'Please select unit information.');
                return;
            }        
            
        }

        if (actionName === 'Close') {
            helper.closeModal(component);
        }
    },

    // 검색 전 작업계획일 Validation
    handleDayCountCheck : function (component, event, helper) {
        var selectStartDate = component.get('v.startDate');
        var selectEndDate   = component.get('v.endDate');
        var result = helper.daycounter(selectStartDate, selectEndDate);

        if (selectEndDate < selectStartDate) {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_001"));
            // 시작일이 종료일보다 클 순 없습니다. 
            selectEndDate = selectStartDate;
            component.set('v.endDate', selectEndDate);
            component.find('endDate').focus();
            return ;
        }

        if (result > 365) {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_002"));
            // 기간은 365일을 초과할 수 없습니다.
            selectEndDate = selectStartDate;
            component.set('v.endDate', selectEndDate);
            component.find('endDate').focus();
            return ;
        }
    },

    // 검색
    doSearch : function(component, event, helper) {
        console.log('---------search---------')
        var machineName = component.get('v.machineName');
        var assetName = component.get('v.assetName');
        var selectStartDate = component.get('v.startDate');
        var selectEndDate   = component.get('v.endDate');

        // 기종 미선택시 경고문
        if (!machineName) {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_007"));
            // 기종을 선택해주세요.
            component.find('machineName').focus();
            return ;
        }

        // 장비번호 미선택시 경고문
        if (!assetName) {
            helper.toast('WARNING', $A.get("$Label.c.service_msg_validation_008"));
            //장비번호를 선택해주세요.
            component.find('assetName').focus();
            return ;
        }

        let fieldMap = {
            startDate       : selectStartDate, 
            endDate         : selectEndDate,
            machineName     : machineName,
            assetName       : assetName,
        };

        console.log("fieldMap ::: ",JSON.stringify(fieldMap, null, 2));

        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'searchHistorybyAsset', { fieldMap: fieldMap })
        .then($A.getCallback(function (result) {
            const responseData = result.r.serviceHistoryList;

            console.log(JSON.stringify(result.r, null, 2));
            console.log('queryString ::: ',JSON.stringify(result.r.queryString, null, 2));

            if (result.r.flag == 'success') {
                component.set('v.historyList', responseData);

                const workOrder = responseData[0] || {};
                const asset = workOrder.Asset || {};
                const account = workOrder.Account || {};

                let headExcelData = [];
                let excelData = [];

                headExcelData.push({
                    [$A.get("$Label.c.service_lbl_model")] : asset.MachineName__c || '',
                    [$A.get("$Label.c.service_lbl_serial_no")] : asset.Name || '',
                    [$A.get("$Label.c.service_fld_shipping_date")] : asset.ShippingDate__c || '',
                    [$A.get("$Label.c.service_fld_account")] : account.Name || '',
                    [$A.get("$Label.c.service_fld_account_phone_no")] : account.Phone || '',
                    [$A.get("$Label.c.service_fld_representative")] : account.Representative__c || '',
                    [$A.get("$Label.c.service_fld_warranty")] : asset.FM_EquipmentWarrantyEquipmentParts__c || '',
					[$A.get("$Label.c.service_fld_warranty_start_date")] : asset.WarrantyStartDate__c || '',
                    [$A.get("$Label.c.service_fld_warranty_end_date")]  : asset.WarrantyEnd__c || ''
                });

                component.set('v.headExcelData',headExcelData);

                responseData.forEach((element, index) => {
                    excelData.push({
                        [$A.get("$Label.c.service_fld_turn")] : index+1,
                        [$A.get("$Label.c.service_fld_last_service_date")]: element.FM_LastServiceDate__c ? element.FM_LastServiceDate__c : '',
                        [$A.get("$Label.c.service_fld_service_type1")] : element.PMActivityType__c ? element.PMActivityType__c : '',
                        [$A.get("$Label.c.service_fld_service_type2")] : element.OrderType__c ? element.OrderType__c : '',
                        [$A.get("$Label.c.service_fld_order_no")] : element.ServiceOrderNumber__c ? element.ServiceOrderNumber__c : '',
                        [$A.get("$Label.c.service_fld_worker")] : element.Worker__c ? element.Worker__r.Name : '',
						[$A.get("$Label.c.service_fld_work_center")] : element.ServiceTerritory && element.ServiceTerritory.Name ? element.ServiceTerritory.Name : '',
                        [$A.get("$Label.c.service_fld_break_details")] : element.FailureArea__c ? element.FailureArea__c + ' - ' + element.FailureAreaGroup__c : '',
						[$A.get("$Label.c.service_fld_break_phenomenon_history")] : element.FailurePhenomenon__c ? element.FailurePhenomenon__c : '',
						[$A.get("$Label.c.service_fld_break_cause_details")] : element.CauseOfFailure__c ? element.CauseOfFailure__c : '',
						[$A.get("$Label.c.service_fld_action_detail")] : element.RepairAction__c ? element.RepairAction__c : '',
						[$A.get("$Label.c.service_fld_received_desc")] : element.Case && element.Case.ReceptionDetails__c ? element.Case.ReceptionDetails__c : ''
                    })
                });
                
                component.set('v.excelData', excelData);
                component.set('v.isLoading', false);
            } else if (result.r.flag == 'warning') {
                helper.toast('WARNING', result.r.message);
                component.set('v.historyList', []);
                component.set('v.excelData', []);
                component.set('v.isLoading', false);
            } else {
                helper.toast('ERROR', result.r.errorMessage);
                component.set('v.historyList', []);
                component.set('v.excelData', []);
                component.set('v.isLoading', false);
            }
        }))
        .catch(error => {
            // Custom Label : 데이터 조회에 실패했습니다.
            helper.toast('ERROR', $A.get("$Label.c.service_err_failed_to_retrieve_data"));
            console.error('doSearch Error :::', JSON.stringify(error, null, 2));
            component.set('v.isLoading', false);
        });
    },

    //sticky table scroll 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

})