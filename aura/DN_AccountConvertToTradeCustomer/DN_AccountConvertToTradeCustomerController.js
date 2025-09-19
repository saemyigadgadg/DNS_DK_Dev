/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 04-11-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-09   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'checkConvertRequired', {
            recordId: component.get('v.recordId')
        }).then($A.getCallback(function (result) {
            let r = result.r;

            if(r.flag == 'emptyCode') {
                var modalEvent = component.getEvent('modalEvent');
                modalEvent.setParams({
                    "modalName"     : 'DN_AccountConvertToTradeCustomer',
                    "actionName"    : 'Close',
                    "message"       : 'Close'
                });
                modalEvent.fire();
                component.find('overlayLib').notifyClose();
                helper.toast('error', $A.get("$Label.c.DNS_ACC_T_EMPTYCODE"));
                return;
            }

            if(r.flag == 'isblock') {
                var modalEvent = component.getEvent('modalEvent');
                modalEvent.setParams({
                    "modalName"     : 'DN_AccountConvertToTradeCustomer',
                    "actionName"    : 'Close',
                    "message"       : 'Close'
                });
                modalEvent.fire();
                component.find('overlayLib').notifyClose();
                helper.toast('error', $A.get("$Label.c.DNS_ACC_T_REQUESTALREADY"));
                return;
            }

            if(r.flag == 'erpError') {
                var modalEvent = component.getEvent('modalEvent');
                modalEvent.setParams({
                    "modalName"     : 'DN_AccountConvertToTradeCustomer',
                    "actionName"    : 'Close',
                    "message"       : 'Close'
                });
                modalEvent.fire();
                component.find('overlayLib').notifyClose();
                // helper.toast('error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                helper.toast('error', r.message);
                return;
            }

            if(r.flag == 'error') {
                var modalEvent = component.getEvent('modalEvent');
                modalEvent.setParams({
                    "modalName"     : 'DN_AccountConvertToTradeCustomer',
                    "actionName"    : 'Close',
                    "message"       : 'Close'
                });
                modalEvent.fire();
                component.find('overlayLib').notifyClose();
                helper.toast('error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                return;
            }
            
            if (r.flag == 'success') {
                let accFilteredKeys = '';
                if (r.result.isKorea) {
                    if (r.result.isBVC) {
                        var modalEvent = component.getEvent('modalEvent');
                        modalEvent.setParams({
                            "modalName"     : 'DN_AccountConvertToTradeCustomer',
                            "actionName"    : 'Close',
                            "message"       : 'Close'
                        });
                        modalEvent.fire();
                        component.find('overlayLib').notifyClose();
                        helper.toast('error', $A.get("$Label.c.DNS_ACC_T_BVCCHECK"));
                        return;
                    } else {
                        for (let key in r.result) {
                            if (r.result.hasOwnProperty(key) && r.result[key] === false) {
                                switch (key) {
                                    case 'checkResult':
                                        component.set("v.accCheckResult", true);
                                        break;
                                    case 'isTotalBusinessNumber':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_BUSINESS");
                                        break;
                                    case 'currencyField':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_Currency");
                                        break;
                                    case 'production':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_PRODUCT");
                                        break;
                                    case 'shippingAddress':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_ADDRESS");
                                        break;
                                    case 'typeOfIndustry':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_INDUSTRY");
                                        break;
                                    case 'typeOfBusiness':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_BUSINESSTYPE");
                                        break;
                                    case 'region':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_REGIONREQ");
                                        break;
                                }
                            }
                        }
                    }
                } else {
                        for (let key in r.result) {
                            if (r.result.hasOwnProperty(key) && r.result[key] === false) {
                                switch (key) {
                                    case 'checkResult':
                                        component.set("v.accCheckResult", true);
                                        break;
                                    case 'businessNumber':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_BUSINESS");
                                        break;
                                    case 'currencyField':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_Currency");
                                        break;
                                    case 'production':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_PRODUCT");
                                        break;
                                    case 'shippingAddress':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_ADDRESS");
                                        break;
                                    case 'country':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_COUNTRY");
                                        break;
                                    case 'region':
                                        accFilteredKeys += $A.get("$Label.c.DNS_ACC_T_REGIONREQ");
                                        break;
    
                                }
                            }
                        }
                    }
                    component.set("v.accFilteredFieldList", accFilteredKeys != '' ? accFilteredKeys.replace(/,\s*$/, '') : '');
                }
    
                // SalesAreaData
                if(r.sadResult != null) {
                    if (r.sadResult.length > 0) {
                        let sadFilteredKeys = '';
                        for(var i = 0; i < r.sadResult.length; i++) {
                            for (let key in r.sadResult[i]) {
                                if (r.sadResult[i].hasOwnProperty(key) && r.sadResult[i][key] === false) {
                                    switch (key) {
                                        case 'checkResult':
                                            component.set("v.sadCheckResult", true);
                                            break;
                                        case 'currencyField':
                                            sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_Currency");
                                            break;
                                        case 'shippingConditions':
                                            sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_CONDITIONS");
                                            break;
                                        case 'incoterms':
                                            sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_INCOTERMS");
                                            break;
                                        case 'termsOfPayment':
                                            sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_PAYMENT");
                                            break;
                                        // case 'shipToParty':
                                        //     sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_SHIPTOPART");
                                        //     break;
                                        // case 'soldToParty':
                                        //     sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_SOLDTOPARTY");
                                        //     break;
                                        // case 'billToParty':
                                        //     sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_BILLTOPARTY");
                                        //     break;
                                        // case 'payer':
                                        //     sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_PAYER");
                                        //     break;
                                        case 'district' :
                                            sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_DISTRICT");
                                            break;
                                        case 'office' :
                                            sadFilteredKeys += $A.get("$Label.c.DNS_ACC_T_OFFICE");
                                            break;
                                    }
                                }
                            }
                        }
                        component.set("v.sadFilteredFieldList", sadFilteredKeys != '' ? sadFilteredKeys.replace(/,\s*$/, '') : '');
                    } else {
                        var modalEvent = component.getEvent('modalEvent');
                        modalEvent.setParams({
                            "modalName"     : 'DN_AccountConvertToTradeCustomer',
                            "actionName"    : 'Close',
                            "message"       : 'Close'
                        });
                        modalEvent.fire();
                        component.find('overlayLib').notifyClose();
                        helper.toast('error', $A.get("$Label.c.DNS_ACC_T_SALESAREA"));
                        return;
                    }

                } else {
                    var modalEvent = component.getEvent('modalEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_AccountConvertToTradeCustomer',
                        "actionName"    : 'Close',
                        "message"       : 'Close'
                    });
                    modalEvent.fire();
                    component.find('overlayLib').notifyClose();
                    helper.toast('error', $A.get("$Label.c.DNS_ACC_T_SALESAREA"));
                    return;
                }

                if(!component.get('v.accCheckResult') && !component.get('v.sadCheckResult') && !component.get('v.isEmpty')) {
                    component.set('v.checkResult', true);
                }

                component.set('v.isLoading', false);
            }))
            .catch(function (error) {
                console.log('# doInit error : ' + JSON.stringify(error.message));
                component.set('v.isLoading', false);
                helper.toast('error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                var modalEvent = component.getEvent('modalEvent');
                modalEvent.setParams({
                    "modalName"     : 'DN_AccountConvertToTradeCustomer',
                    "actionName"    : 'Close',
                    "message"       : 'Close'
                });
                modalEvent.fire();
                component.find('overlayLib').notifyClose();
            });
    },

    handleCloseModal: function (component, event, helper) {
        let result = component.get('v.checkResult');

        if (result) {
            var modalEvent = component.getEvent('modalEvent');
            modalEvent.setParams({
                "modalName"     : 'DN_AccountConvertToTradeCustomer',
                "actionName"    : 'Close',
                "message"       : 'Close'
            });
            modalEvent.fire();
            component.find('overlayLib').notifyClose();
            $A.get('e.force:refreshView').fire();
            return;
        } else {
            var modalEvent = component.getEvent('modalEvent');
            modalEvent.setParams({
                "modalName"     : 'DN_AccountConvertToTradeCustomer',
                "actionName"    : 'Close',
                "message"       : 'Close'
            });
            modalEvent.fire();
            component.find('overlayLib').notifyClose();
            return;
        }
    }
})