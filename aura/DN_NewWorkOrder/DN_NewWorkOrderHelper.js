({
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() );
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    navigateRecord : function (recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    onTabClosed : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    checkAccGroup : function(component){
        var shipToAccountGroup = component.get('v.shipToAccountGroup');
        let shipTo = component.find("shipTo").getElement();
        if(shipTo){
            if(shipToAccountGroup == '1030'){
                const errorMessage = document.getElementsByClassName('shipToErr');
                if(errorMessage.length == 0){
                    shipTo.classList.add("slds-has-error");
                    const noticeMsg = document.createElement("div");
                    noticeMsg.className = "slds-form-element__help shipToErr";
                    noticeMsg.innerText = "Ship To 정보가 1030 입니다.";
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
    },
    checkRecordType : function(component){
        var soldToRecordType = component.get('v.soldToRecordType');
        let soldTo = component.find("soldTo").getElement();
        if(soldTo){
            if(soldToRecordType == 'Dealer'){
                component.set("v.errMsg", "Sold To 정보가 대리점입니다.");
            }else{
                component.set("v.errMsg", "");
            }
        }
    },
    calstrVal : function(component){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var strVal = response.pageReference.state.ws;
            console.log('this response' ,response);
            console.log('this response.recordId' ,response.recordId);

            if(response.recordId){
                component.set('v.ticketId', response.recordId);
            }else if(strVal){
                if(strVal.includes('Case')){
                    strVal = strVal.replace("/lightning/r/Case/", '');
                    strVal = strVal.replace("/view", '');
                    console.log('strVal' ,strVal);
                    component.set('v.ticketId', strVal);
                }else{
                    console.log('case 아님');
                }
            }
        });
        
       
    },

    getInitInfo : function(component){
        this.apex(component, "getTicketInfo", {
            ticketId : component.get('v.ticketId')
        })
        .then(function(result){
            console.log('getTicketInfo',JSON.stringify(result));
            if(result.isSuccess){

                //Ticket이 DNSA면 생성화면 국내와 다름
                component.set('v.isDNSA', result.isDNSA);
                component.set('v.recordTypeId', result.recordTypeId);
                component.set('v.ticketType', result.ticketType);

                if(result.isDNSA){
                    console.log(result.isDNSA);
                    component.set('v.isSpinner', false);
                    component.set('v.assetId', result.assetId);
                    component.set('v.model', result.model);
                    component.set('v.dispatchTime', result.dispatchTime);
                    component.set('v.shipTo', result.shipTo);
                    component.set('v.soldTo', result.soldTo);
                    component.set('v.orderType', result.orderType);
                    component.set('v.warranty', result.warranty);

                }else{
                    component.set('v.assetId', result.assetId);
                    component.set('v.model', result.model);
                    component.set('v.warranty', result.warranty);
                    component.set('v.shipTo', result.shipTo);
                    component.set('v.soldTo', result.soldTo);
                    component.set('v.soldToRecordType', result.soldToRecordType);
    
                    const localDate = result.dispatchTime.toLocaleString();  // 로컬 시간대에 맞는 날짜와 시간 표시
                    console.log('localDate',localDate);
                    console.log('nolocalDate', result.dispatchTime);
                    component.set('v.dispatchTime', result.dispatchTime);
    
                    //sales order 정보
                    component.set('v.salesOrder', result.salesOrder);
                    component.set('v.soNumber', result.soNumber);
                    component.set('v.soSoldTo', result.soSoldTo);
                    component.set('v.soSoldToCode', result.soSoldToCode);
                    component.set('v.soSoldToRecordType', result.soSoldToRecordType);
                    component.set('v.soShipToId', result.soShipToId);
                    component.set('v.soShipTo', result.soShipTo);
                    component.set('v.soShipToCode', result.soShipToCode);
                    component.set('v.soShipToRecordType', result.soShipToRecordType);
                    
                    console.log(JSON.stringify(result.orderTypeList));
                    if (result.orderTypeList.length > 0) {
                        // TicketType → OrderType 매핑
                        var orderTypeMapping = {
                            'Failure receipt': ['201', '202', '203', '204', '215', '214', '217', '218'],
                            'Installation request': ['104', '809'],
                            'Post-delivery training': ['801', '802', '803'],
                            'Regular Inspections': ['103'],
                            'Service Campaign': ['106'],
                            'Sales support': ['810'],
                            'Customer Support': ['219', '220'],
                            'Pre-Call': ['203'],
                            'Missing Part, Wrong Part': ['201', '202']
                        };

                        // component.set("v.orderTypeOptions", result.orderTypeList);
                        var allOptions = result.orderTypeList;
                        // TicketType 값 가져오기
                        var ticketType = component.get("v.ticketType");
                        var filteredOptions = allOptions.filter(function(opt){
                            return orderTypeMapping[ticketType] && orderTypeMapping[ticketType].includes(opt.value);
                        });

                        component.set("v.defaultOTOptions", filteredOptions);
                        component.set("v.orderTypeOptions", filteredOptions);
                        component.set('v.orderType', result.orderType);
                    }

                    var orderType = component.get('v.orderType');
                    if(orderType == '104' || orderType == '809' || orderType == '801'){
                        // let soldTo = component.find("soldTo").getElement();
                        // console.log('soldTo',soldTo);
        
                        if(result.soldToRecordType == 'Dealer' || result.soldToRecordType == 'Ship to Party'){
                            //지우면 안 돼 하영냥~~~
                            if(result.soldToRecordType == 'Dealer'){
                                component.set("v.errMsg", "Sold To 정보가 대리점입니다.");
                            }else if(result.soldToRecordType == 'Ship to Party'){
                                component.set("v.errMsg", "Sold To 정보가 배송처입니다.");
                            }
                            component.set('v.isSpinner', false);
                        }else{
                            component.set('v.isSpinner', false);
                        }
                    }else{
                        component.set('v.isSpinner', false);
                    }
                    
                }

            }else{
                console.log('elseelse', result.errMessage);
                component.find('notifLib').showToast({
                    "title": 'ERROR',
                    "message": result.errMessage,
                    "variant": 'Error'
                });
                console.log('elseelse');
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        });
    },

    //DNSA Ticket 정보 가져오기
    getDNSAInfo : function(component){
        this.apex(component, "getTicketInfo", {
            ticketId : component.get('v.ticketId')
        })
        .then(function(result){
            console.log('getTicketInfo',result);
            if(result.isSuccess){

              

                
                
            }else{
                console.log('elseelse', result.errMessage);
                component.find('notifLib').showToast({
                    "title": 'ERROR',
                    "message": result.errMessage,
                    "variant": 'Error'
                });
                console.log('elseelse');
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        });
    }
    

})