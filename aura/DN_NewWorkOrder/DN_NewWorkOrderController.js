/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-05-02
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-24-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    init : function(component, event, helper) {

        const urlParams = new URLSearchParams(window.location.search);
        console.log('urlParams',urlParams);
        console.log('inContextOfRef',urlParams.get('inContextOfRef'));
        if(urlParams.get('inContextOfRef')){
            var base64String = urlParams.get('inContextOfRef');
            helper.apex(component, 'decodeTicketId',{
                base64String : base64String
            })
            .then(function(result){
                console.log('decodeTicketId',result);
                if(result.isSuccess){
                    component.set('v.ticketId', result.returnValue);
                    console.log('ticketId', component.get('v.ticketId'));
                    helper.getInitInfo(component);
                }
            });
        }else{
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var strVal = response.pageReference.state.ws;
                console.log('response' ,response);
                console.log('response.recordId' ,response.recordId);
                console.log('response.pageReference' ,response.pageReference);
                console.log('strVal' ,strVal);
                if(response.recordId){
                    component.set('v.ticketId', response.recordId);
                }else if(strVal){
                    if(strVal.includes('Case')){
                        strVal = strVal.replace("/lightning/r/Case/", '');
                        strVal = strVal.replace("/view", '');
                        console.log('strVal' ,strVal);
                        component.set('v.ticketId', strVal);
                    }
                }
                console.log('ticket ID:::' + component.get('v.ticketId'));
                helper.getInitInfo(component);
            })
            .catch(function(error) {
                console.log(error);
            });
        }        
    },
    handleLocation : function(component, event, helper){
        var ticketId = component.get('v.ticketId');
        var attributes = {'ticketId' : ticketId};
        console.log('DN_ResourceTrackingComponent');
        $A.createComponent("c:DN_ResourceTrackingComponent", attributes, function(content, status, errorMessage) {
            console.log('status', status);
            if (status === "SUCCESS") {
                var container = component.find("locationContainer");
                container.set("v.body", content);
            } else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.");
            } else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
    },
    handleSave : function(component, event, helper){
        var isDNSA = component.get('v.isDNSA');

        if($A.util.isEmpty(component.get('v.soldTo'))){
            helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_E_CheckShipto'), 'Error');
            return null;
        }

        if($A.util.isEmpty(component.get('v.shipTo')) || $A.util.isEmpty(component.get('v.dispatchTime')) || $A.util.isEmpty(component.get('v.orderType'))){
            helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
            return null;
        }

        if(component.get('v.orderType') == '214' || component.get('v.orderType') == '215'){
            if($A.util.isEmpty(component.get('v.spTask'))){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                return null;
            }
        }

        if(!isDNSA){
            if($A.util.isEmpty(component.get('v.serviceResourceId'))){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                return null;
            }
        }

        if(component.get('v.orderType') == '104' || component.get('v.orderType') == '801' || component.get('v.orderType') == '809'){
            console.log('soShipToId',component.get('v.soShipToId'));
            console.log('shipTo',component.get('v.shipTo'));
            if(component.get('v.soShipToId') != component.get('v.shipTo')){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_E_CheckShipToInfo'), 'Error');
                return null;
            }
        }

        // if((component.get('v.isDirect') == true) && (component.get('v.orderType')!= '202')){
        //     // helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
        //     helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_E_CheckDirectWarranty'), 'Error');
        //     return null;
        // }

        var jsonData = '';
        if(isDNSA){
            var dnsaData = {
                CaseId : component.get('v.ticketId'),
                AssetId : component.get('v.assetId'),
                TicketType__c : component.get('v.ticketType'),
                OrderType__c : component.get('v.orderType'),
                AccountId : component.get('v.shipTo'),
                isAlarmToStaff__c : component.get('v.isAlarmTalk'),
                SoldTo__c : component.get('v.soldTo'),
                ScheduledDispatchTime__c : component.get('v.dispatchTime'),
                PONo__c : component.get('v.poNumber'),
                EquipmentWarranty__c : component.get('v.warranty')
            }
            jsonData = JSON.stringify(dnsaData);
        }else{
            var data = {
                CaseId : component.get('v.ticketId'),
                AssetId : component.get('v.assetId'),
                TicketType__c : component.get('v.ticketType'),
                OrderType__c : component.get('v.orderType'),
                AccountId : component.get('v.shipTo'),
                ServiceTerritoryId : component.get('v.workCenterId'),
                SPTask__c : component.get('v.spTask'),
                Worker__c : component.get('v.serviceResourceId'),
                isAlarmToStaff__c : component.get('v.isAlarmTalk'),
                SoldTo__c : component.get('v.soldTo'),
                ScheduledDispatchTime__c : component.get('v.dispatchTime'),
                EquipmentWarranty__c : component.get('v.warranty'),
                IsDirectPaidService__c : component.get('v.isDirect')
            };
            jsonData = JSON.stringify(data);
        }

        console.log('jsonData',jsonData);     
        component.set('v.isSpinner', true);
        console.log('isDNSA', isDNSA);

        //Double Click 방지
        component.set('v.saveBtn', true);

        helper.apex(component, "saveWorkOrder", {
            isDNSAParam : component.get('v.isDNSA'),
            workOrderData : jsonData
        })
        .then(function(result){
            console.log('saveWorkOrder',result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', 'SUCCESS', 'Success');
                helper.onTabClosed(component);
                helper.navigateRecord(result.returnValue);
            }else{
                helper.toast(component, 'ERROR',result.errMessage, 'Error');
                console.log(result.errMessage);
                component.set('v.isSpinner', false);
                component.set('v.saveBtn', false);
            }
        });
    },
    onTabClosed : function(component, event, helper) {
        helper.onTabClosed(component);
    },

    handleValueChange : function(component, event, helper) {
        console.log('handleValueChange');
        const searchFilterCombobox = component.find("searchFilterCombobox");
        if (searchFilterCombobox) {
            console.log('detail ', event.getParams('detail'));
            const lookupValue = event.getParams('detail').lookupValue;
            const selectedValue = event.getParams('detail').selectedValue;

            component.set('v.workCenterId', lookupValue);
            component.set('v.serviceResourceId', selectedValue);
            component.set('v.isSelect', component.get('v.isSelect'));

            console.log('AURA lookupValue:', lookupValue);
            console.log('AURA selectedValue:', selectedValue);
        }
    },

    handleCompEvent : function(component, event, helper) {
        component.set('v.isSpinner', true);
        var modalName = event.getParam("modalName");
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");

        console.log('message', JSON.stringify(message));
        console.log('workcenterId', message.workcenterId);
        console.log('technicianId', message.technicianId);
        console.log('isSelect', component.get('v.isSelect'));
        
        component.set('v.isSelect', true);

        //같은 값이면 바꾸기 위해 null 처리해주기
        component.set('v.serviceTerritoryId', null);
        component.set('v.workCenterId', null);
        component.set('v.workerId', null);
        
        component.set('v.serviceTerritoryId', message.workcenterId);
        component.set('v.workCenterId', message.workcenterId);
        component.set('v.workerId', message.technicianId);
        component.set('v.serviceResourceId', message.technicianId);

        console.log('serviceTerritoryId', component.get('v.serviceTerritoryId'));
        console.log('workerId', component.get('v.workerId'));
        console.log('isSelect', component.get('v.isSelect'));
        console.log('배정완료');
        var searchFilterCombobox = component.find("searchFilterCombobox");
        searchFilterCombobox.handleAuraValueChange();
        component.set('v.isSpinner', false);
    },
    changeSoldTo : function(component, event, helper){
        var changedSoldTo = event.getParam('value');
        console.log('changedSoldTo', changedSoldTo);
        if(!$A.util.isEmpty(changedSoldTo)){
            var orderType = component.get('v.orderType');
            console.log('@@ orderType : '+ orderType);
            if(orderType == '801' || orderType == '809' || orderType == '104'){
                component.set('v.isSpinner', true);

                helper.apex(component, 'getSoldToRecordType',{
                    soldTo : changedSoldTo[0],
                })
                .then(function(result){
                    console.log('getSoldToRecordType', result);
                    if(result.isSuccess){
                        component.set('v.soldToRecordType', result.soldToRecordType);
                        if(result.soldToRecordType == 'Dealer' || result.soldToRecordType == 'Ship to Party'){
                            //지우면 안 돼 하영냥~~
                            if(result.soldToRecordType == 'Dealer'){
                                component.set("v.errMsg", "Sold To 정보가 대리점입니다.");
                            }else if(result.soldToRecordType == 'Ship to Party'){
                                component.set("v.errMsg", "Sold To 정보가 배송처입니다.");
                            }
                            component.set('v.isSpinner', false);
                        }else{
                            component.set("v.errMsg", "");
                            component.set('v.isSpinner', false);
                        }
                    }else{
                        component.set('v.isSpinner', false);
                    }
                });
            }
        }else{
            component.set('v.soldTo', '');
            component.set('v.soldToRecordType','');
            component.set("v.errMsg", "");
        }
    },
    changeShipTo : function(component, event, helper){
        var shipToCmp = event.getParam('value')[0];
        if(shipToCmp){
            helper.apex(component, "getShipToAccGroup", {
                shipTo : shipToCmp
            })
            .then(function(result){
                console.log('getTicketInfo',result);
                if(result.isSuccess){
                    component.set('v.shipTo', result.shipTo);
                    component.set('v.shipToAccountGroup', result.shipToAccountGroup);

                    let shipTo = component.find("shipTo").getElement();
                    if(shipTo){
                        console.log('result.shipToAccountGroup',result.shipToAccountGroup);
                        if(result.shipToAccountGroup == '1030'){
                            const errorMessage = document.getElementsByClassName('shipToErr');
                            if(errorMessage.length == 0){
                                shipTo.classList.add("slds-has-error");
                                const noticeMsg = document.createElement("div");
                                noticeMsg.className = "slds-form-element__help shipToErr";
                                noticeMsg.innerText = "Ship To 정보가 배송처 입니다.";
                                shipTo.appendChild(noticeMsg);
                            }
                        }else{
                            const errorMessage = document.getElementsByClassName('shipToErr');
                            console.log('errorMessage',errorMessage);
                            if(errorMessage.length != 0){
                                shipTo.classList.remove("slds-has-error");
                                errorMessage[0].remove();
                            }
                        }
                    }
                }else{
                    component.set('v.isSpinner', false);
                }
            });
        }else{
            let shipTo = component.find("shipTo").getElement();
            console.log('shipTo',shipTo);
            shipTo.classList.remove("slds-has-error");
            const errorMessage = document.getElementsByClassName('shipToErr');
            if(errorMessage.length != 0){
                errorMessage[0].remove();
            }

            component.set('v.shipTo', '');
            component.set('v.shipToAccountGroup','');
        }
    },
    handleOrderType : function(component, event, helper){
        console.log('handleOrderType');
        console.log("선택된 OrderType: " + component.get("v.orderType"));
        var orderType = component.get("v.orderType");
        console.log('orderType', orderType);

        var warrantyList = component.get('v.warranty').split('/');
        console.log('warrantyList : ' + warrantyList[0]);

        if (warrantyList[0].trim() == 'N') {
            if ( orderType == '201') {
                // component.set('v.orderType', '');

                component.set('v.orderType', '202');
                helper.toast(component, 'ERROR', '공임 보증 기간이 만료되어 무상을 선택 할 수 없습니다.', 'Error');
                return false;
            }
        }

        if (warrantyList[1].trim() == 'N') {
            if (orderType == '214') {
                // component.set('v.orderType', '');
                
                component.set('v.orderType', '202');
                helper.toast(component, 'ERROR', '부품 보증 기간이 만료되어 무상을 선택 할 수 없습니다.', 'Error');
                return false;
            }
        }

        if(!$A.util.isEmpty(orderType)){

            component.set('v.isSpinner', true);
            var ticketId = component.get('v.ticketId');
            helper.apex(component, 'getSoldToInfo',{
                ticketId : ticketId,
                orderType : orderType
            })
            .then(function(result){
                console.log('getSoldToInfo',result);
                if(result.isSuccess){
                    component.set('v.soldTo', result.soldTo);
                    component.set('v.salesOrder', result.salesOrder);
                    component.set('v.soNumber', result.soNumber);
                    component.set('v.soldToRecordType', result.soldToRecordType);
                    component.set('v.soSoldToRecordType', result.soSoldToRecordType);
                    component.set('v.soSoldToCode', result.soSoldToCode);
                    component.set('v.soSoldTo', result.soSoldTo);
                    component.set('v.soShipToRecordType', result.soShipToRecordType);
                    component.set('v.soShipToCode', result.soShipToCode);
                    component.set('v.soShipTo', result.soShipTo);
                    component.set('v.soShipToId', result.soShipToId);
                    
                    if(orderType == '801' || orderType == '809' || orderType == '104'){
                        let soldTo = component.find("soldTo").getElement();
                        console.log('soldTo',soldTo);
        
                        if(result.soldToRecordType == 'Dealer' || result.soldToRecordType == 'Ship to Party'){
                            if(result.soldToRecordType == 'Dealer'){
                                component.set("v.errMsg", "Sold To 정보가 대리점입니다.");
                            }else if(result.soldToRecordType == 'Ship to Party'){
                                component.set("v.errMsg", "Sold To 정보가 배송처입니다.");
                            }
                            component.set('v.isSpinner', false);
                        }else{
                            component.set("v.errMsg", "");
                            component.set('v.isSpinner', false);
                        }
                    }else{

                        component.set('v.isSPTask', false);
                        component.set('v.isSP', false);

                        component.set('v.serviceTerritoryId', '');
                        component.set('v.workerId', '');

                        component.set('v.isSpinner', false);
                    }
                }
            });
        }
    },
    handleIsDirect : function(component, event, helper){
        var isDirect = event.getParam('value');
        var defaultOTOtions = component.get('v.defaultOTOptions');
        if(isDirect){
            var filteredOptions = defaultOTOtions.filter(function(opt) {
                    return ['202', '215'].includes(opt.value);
                });
            component.set('v.orderTypeOptions', filteredOptions);
            component.set('v.orderType', '202');
        }else{
            component.set('v.orderTypeOptions', defaultOTOtions);

        }
    }
})