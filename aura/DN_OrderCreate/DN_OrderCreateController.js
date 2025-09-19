/**
 * @author            : youjin shim
 * @Description       :
 * @last modified on  : 2025-09-15
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-10-25   youjin.shim@sbtglobal.com     Initial Version
 * Memo               : 
**/
({
    doInit: function (component, event, helper) {
        
        // 요청 배송 날짜 생성 +1? +3? 일-목 +1, 금 +3, 토 +2
        var day   = new Date();
        var today = helper.dayCount(day);
        component.set('v.today', today);

        // Parts List 생성 개수
        helper.addList(component, event, helper, 10);
        component.set('v.isLoading', true);

         // 유저 정보를 가져 옴.
        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {            
            let response = result.r;
            console.log('response >> '+JSON.stringify(response,null,4))
            component.set('v.dealerInfo', response);
            if(response.userProfile == 'DNSA CS Parts_Partner'){
                component.set('v.isDNSA',true);
            }

            let city    = response.ShippingAddress.city || '';
            let street  = response.ShippingAddress.street || '';
            let zipCode = response.ShippingAddress.zipCode != null ? `(${response.ShippingAddress.zipCode}) ` : '';

            let inputShipTo = zipCode+' '+city+' '+ street +', '+response.accountName;
            component.set('v.inputShipTo', inputShipTo);

            let shippingLocation = {
                supplier             : 'DN Solutions',           // 공급업체
                customerId           : response.accountId,       // 수취자 Id
                customerCode         : response.dealerCode,      // 수취자 코드
                shippingDestination  : response.accountName,     // 배송처
                shippingAddress      : inputShipTo,              // 배송처 주소
                zipCode              : response.zipCode,         // 우편번호
                city                 : city,
                street               : street,                   // 거리
                partManager          : response.dealerName,      // 부품 담당자
                partManagerMP        : response.userMobilePhone, // 배송처 전화번호
            }
            component.set('v.shippingLocation', shippingLocation);

            return helper.apexCall(component, 'GetShippingInfo', { di : response });
        }))
        .then($A.getCallback(function(result) {
            var response = result.r;
            component.set('v.shipInfo', response);
            return helper.apexCall(component, 'GetOrderTypeList', {})
        }))
        .then($A.getCallback(function(result) {
            let response = result.r;
            response.pop();

            component.set('v.orderTypeList', response);
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            console.log('error>> '+JSON.stringify(errors,null,4))
        }));

        // 고객 주문관리 >> 딜러 주문에서 넘어온 부품 번호
        let partsList = helper.catchUrl(component, event) == undefined ? [] : helper.catchUrl(component, event);    

        if(partsList.length != 0) {
            helper.apexCall(component, 'SearchPartNo', {pn : partsList})
            .then($A.getCallback(function(result) {
                let response = result.r;
                component.set('v.confirmParts', response);
                return helper.searchProduct(component, event, helper);
            }))
            .then($A.getCallback(function(result) {
                let doSimul = component.get('c.doSimulation');
                $A.enqueueAction(doSimul);
            }))
            .catch($A.getCallback(function(errors) {
                component.set('v.isLoading', false);
                console.log('error>> '+JSON.stringify(errors,null,4))
            }))
        }

        // GPES 에서 part Info 받는 부분
        window.addEventListener(
            'message',
            $A.getCallback(function(event) {
                console.log('GPES 작동 여부 >>> ' +JSON.stringify(event,null,4));
                console.log('event.origin >>> ' +event.origin);
                
                // if(event.origin === 'https://dn-solutions--dev.sandbox.my.site.com') { // 개발
                if(event.origin === 'https://dportal.dn-solutions.com') { // 운영
                    try {
                        const data = event.data;
                        const parsedData = JSON.parse(data);
                        component.set('v.receivedData', parsedData);
                        var receivedData = component.get('v.receivedData');
                        var selectPartsNo = [];
                        console.log('receivedData >>> ' +JSON.stringify(receivedData,null,4))
                        for(var i = 0; i < receivedData.length; i++) {
                            selectPartsNo.push(receivedData[i].partNo);
                        }
                        component.set('v.selectPartsNo', selectPartsNo);
                        component.set('v.isGPESModal', false);
                        var partNo = component.get('v.selectPartsNo');
                        helper.apexCall(component, 'SearchPartNo', {pn : partNo})
                        .then($A.getCallback(function(result) {
                            let response = result.r;
                            if(response.length == '0') {
                                return Promise.reject({type:'EmptyGPES', message:'{!$Label.c.ORC_MSG_3}'}); //CRM에 등록된 부품이 없습니다.
                            }else {
                                component.set('v.confirmParts', response);
                                return helper.searchProduct(component, event, helper);    
                            }
                        }))
                        .then($A.getCallback(function(result) {
                            console.log('result > ' + JSON.stringify(result,null,4));
                            var partsList = component.get('v.partsList');
                            var receivedData = component.get('v.receivedData');

                            console.log('partsList > ' + JSON.stringify(partsList,null,4));
                            console.log('receivedData > ' + JSON.stringify(receivedData,null,4));

                            partsList.forEach(function(part) {
                                var partNo = String(part.orderPartNo || '').trim().toLowerCase();
                                var gpesRow = receivedData.find(function(data) {
                                    return String(data.partNo || '').trim().toLowerCase() === partNo;
                                })
                                console.log('partNo > '+ partNo)
                                console.log('gpesRow > '+ JSON.stringify(gpesRow,null,4))
                                if(gpesRow) {
                                    part.quantity   = String(gpesRow.qty) || '';
                                }
                            });
                            component.set('v.partsList', partsList);
                        }))
                        .catch($A.getCallback(function(errors) {
                            component.set('v.isLoading', false);
                            if(errors.type == 'EmptyGPES') {
                                helper.toast('INFO', errors.message);
                            }else {
                                console.log('error>> '+JSON.stringify(errors,null,4))
                            }
                            
                        }))
                    } catch (error) {
                        component.set('v.isLoading', false);
                        console.log('error>> '+JSON.stringify(error,null,4))
                        helper.toast('ERROR', 'Failed to parse the message.');
                    }
                } else {
                    console.warn('Unauthorized message origin: ', event.origin);
                }
            })
        );

        component.set('v.isLoading', false);
        component.set('v.isBTN', false);
    },


    // 배송정보 선택 (인터페이스에서 받아와야 하는 값)
    selectRow : function(component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var shipInfo = component.get('v.shipInfo');
        var ship = shipInfo[index];

        let requestedDeliveryDate;

        let today = new Date();
        let dayNo = today.getDay();

        if(dayNo == 6) { // 토 + 2일
            requestedDeliveryDate = helper.dayCount(today, 2);
        }else if(dayNo == 5) { // 금 + 3일
            requestedDeliveryDate = helper.dayCount(today, 3);
        }else{ // 일 - 목 + 1일
            requestedDeliveryDate = helper.dayCount(today, 1);
        }
        

        var shippingInfo = {
            shippingTerm          : ship.shippingTerm,           // 선적 조건
            shippingCode          : ship.shippingCode,           // 선적 조건 코드(10택배, 20트럭, 90퀵, 99방문)
            paymentTerm           : ship.paymentTerm,            // 지급 조건
            paymentTerm2          : ship.paymentTerm2,           // 지급 조건(약어)
            transportationTermOne : ship.transportationTermOne,  // 운송 조건1
            transportationTermTwo : ship.transportationTermTwo,  // 운송 조건2
            requestedDeliveryDate : requestedDeliveryDate        // 요청배송일자
        }

        component.set('v.shippingInfo', shippingInfo);
        component.set('v.infoChangeModal', false);
    },

    // 주문 유형 입력
    orderTypeChange : function(component, event, helper) {
        helper.updateFieldValue(component, event, helper);
    },

    // 단순 입력 (고객주문번호, 일괄배송여부, 기종, 장비번호)
    commonTypeChange : function(component, event, helper) {
        helper.updateFieldValue1(component, event, helper);
    },

    // 주문 부품 입력
    orderPartsChange : function(component, event, helper) {
        helper.updateFieldValue2(component, event, helper);
    },



    // parts 값 입력 (수량) R90031A, 100702-01001C // 기종 : HFP 1540 // 장비번호 : MY0279-000028
    // inputRow: function (component, event, helper) {
    //     let partsList = component.get('v.partsList');

    //     let inputCmp = event.getSource();
    //     let name  = inputCmp.get('v.name');
    //     let value = inputCmp.get("v.value");
    //     let keyNo = inputCmp.get('v.accesskey');

    //     let rowQty = partsList[keyNo].quantity;
    //     console.log('rowQty >> ' +rowQty);

    //     console.log('name > '+name)
    //     console.log('value > '+value)
    //     console.log('keyNo > '+keyNo)

    //     if (name === 'orderPartNo' && value.length > 35) {
    //         inputCmp.set('v.value', value.substring(0, 35));
    //         helper.toast('INFO', '최대 입력값은 35자리 입니다.');
    //         return;
    //     }

    //     if(name === 'orderPartNo') {
   
    //         if (value) {
    //             value = value.toUpperCase();
    //             let isPartsList = partsList.some((e, i)=> i != keyNo && e.orderPartNo == value);
    //             if(isPartsList) {
    //                 helper.toast('WARNING','이미 선택한 부품 입니다.');
    //                 partsList[keyNo].orderPartNo = '';
    //                 component.set('v.partsList', partsList);
    //                 return;
    //             }
    //         }
    //     }
        
        
    //     if (name == 'quantity' && value <= 0) {
    //         helper.toast('INFO','수량이 0 이하가 될 수 없습니다.');
    //         inputCmp.set("v.value", '');
    //     } 

    //     if(name == 'quantity' && value.length > 6) {
    //         inputCmp.set("v.value", '');
    //         helper.toast('INFO','수량은 최대 999999 까지 가능합니다.');
    //     }
        
    //     // 'orderPartNo'가 같은 항목들을 찾아서 업데이트
    //     let opn = partsList[keyNo].orderPartNo;
    //     partsList.forEach(item => {
    //         if (item.orderPartNo != '' && item.orderPartNo === opn) {
    //             item[name] = value;
    //         }
    //     });

    //     if (name == 'machine' && value) {
    //         value = value.toUpperCase();
    //         inputCmp.set("v.value", value);
    //     }

    //     if (name == 'equipment' && value) {
    //         value = value.toUpperCase();
    //         inputCmp.set("v.value", value);
    //     }
        
    //     component.set('v.partsList', partsList);
    // },

    // parts 값 입력 (긴급도)
    urgencyCheck : function(component, event, helper) {
        var partsList = component.get('v.partsList');
        var orderType = component.get('v.orderType');
        var rowIndex = parseInt(event.getSource().get('v.accesskey',10));

        var fieldName = 'urgency';
        var checkbox = event.getSource();
        var fieldValue = !checkbox.get('v.checked');

        if(orderType == 'YDEO') {
            fieldValue = !fieldValue;
            checkbox.set('v.checked', fieldValue);
        }else {
            fieldValue = false;
            checkbox.set('v.checked', fieldValue);
            helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_4}")); 	//주문 유형이 EMERGENCY ORDER 인 경우에만 긴급 선택이 가능합니다.
        }

        component.set('v.' + fieldName, fieldValue);

        var part = partsList[rowIndex];
        part[fieldName] = fieldValue;

        partsList[rowIndex] = part;
        component.set('v.partsList', partsList);
    },
    // 저장 전 시뮬레이션 로직
    doSimulation : function(component, event, helper) {
        console.log('simul start!!');
        component.set('v.isLoading', true);
        
        // 에러 보고서 및 가격 정보 초기화
        component.set('v.isPrice', false);
        component.set('v.isError', false);

        let orderType   = component.get('v.orderType');
        let dealerInfo  = component.get('v.dealerInfo');
        let partsList   = component.get('v.partsList');
        let isPartsList;
        let partList      = [];
        let errorList     = [];
        let orderPartList = [];
        let partRecord;
        let errorRecord;
        let isSupplyPartNo;

        let productSet  = new Set();
        let productList = new Set();

        isSupplyPartNo = partsList.some(e => e.orderPartNo == '' && e.supplyPartNo != ''); 
        isPartsList = partsList.some(e => e.orderPartNo != '');
        if(isSupplyPartNo) {
            helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_5}")); // 부품을 선택해 주세요.
            component.set('v.isLoading', false);
            return;
        }

        if(!isPartsList) {
            helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_5}")); 
            component.set('v.isLoading', false);
            return;
        }

        partsList = partsList.filter(e => e.orderPartNo != '' && e.orderPartNo != null);
        
        isPartsList = partsList.some(e => e.quantity == '' || e.quantity == 0 || e.quantity == null);

        if(isPartsList) {
            helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_6}")); //수량을 입력해 주세요.
            component.set('v.isLoading', false);
            return;
        }

        partsList.forEach(e=> {
            if(e.quantity.includes(',')) {
                e.quantity = e.quantity.replace(/,/g, '');
            }
        })
        
        partsList = partsList.filter(e => parseInt(e.hang, 10) % 10 === 0);

        helper.apexCall(component, 'CheckReplacement', {dli : dealerInfo, plt : partsList})
        // helper.apexCall(component, 'GetSimulationInfo', {dli : dealerInfo, plt : partsList, odt : orderType})
        .then($A.getCallback(function(result) {
            // 004 인터페이스 대체품 찾아서 row 추가.
            let response = result.r;
            let t_ITEM = response.T_ITEM;
            let materialMap = new Map();
            
            t_ITEM.forEach(e => {
                let currentItem = parseInt(e.ITEM, 10);
                if (!materialMap.has(e.MATERIAL) || currentItem < parseInt(materialMap.get(e.MATERIAL).ITEM, 10)) {
                    materialMap.set(e.MATERIAL, e);
                }
            });

            let filteredList = Array.from(materialMap.values());
            t_ITEM = filteredList;
            console.log('@@add component : ' + component.get('v.oDKey'));
            return helper.apexCall(component, 'GetSimulationInfoMass', {dli : dealerInfo, plt : t_ITEM, odt : orderType, odkey: component.get('v.oDKey')})
        }))
        .then($A.getCallback(function(result){
            let response = result.r;
            let returnMSG = response.O_RETURN;
            console.log( 'response : ' + JSON.stringify(response));
            if(returnMSG.TYPE == 'E') {
                helper.toast('ERROR',`ERP: ${returnMSG.MESSAGE}`);
                return Promise.reject('Simulation Info Error: ' + returnMSG.MESSAGE);
            }else {
                if (response.E_STAT == 'P') {
                    component.set('v.oDKey',response.ODKEY);
                    component.set('v.simulstatus', response.E_STAT);
                    component.set("v.showCustomToast", true);
                    setTimeout(()=>{
                        component.get("c.doSimulation").run();
                        let controller = component.getDef().getController();
                        if(controller && controller.doSimulation){
                            controller.doSimulation(component, null, helper);
                        }
                    }, 15000);
                    return;
                } else {
                    component.set("v.showCustomToast", false);
                    component.set('v.simulstatus', response.E_STAT);
                }

                let mainInfo = response.LS_MAIN_HEAD_RESULT;
                let currency = mainInfo.WAERK;
                component.set('v.credit', helper.formatPrice(mainInfo.CREDIT));
                component.set('v.creditCurr', mainInfo.CREDIT_WAERK);
                component.set('v.tAmount', helper.formatPrice(mainInfo.NETWR));
                component.set('v.currency', currency);
                component.set('v.totalAmount', mainInfo.NETWR);
                component.set('v.totalCredit', mainInfo.CREDIT);
                

                // 가격 정보
                if(response.LT_PRICING_01) {
                    var priceData01 = response.LT_PRICING_01;
                    var priceData02 = response.LT_PRICING_02;
                    var priceData = priceData01.concat(priceData02);
                    component.set('v.priceData', priceData);
                    component.set('v.isPirce', true);
                }
                console.log('response >>> '+JSON.stringify(response,null,4));

                // 에러 보고서
                if(response.LT_NON_EXIST.length > 0) {
                    component.set('v.isError', true);
                    for(let error of response.LT_NON_EXIST) {
                        errorRecord = {
                            'partName'     : error.ERROR_MATNR, // 부품번호
                            'noMaterial'   : 'X',               // 자재없음
                            'noCode'       : error.NOTCD,       // 코드 없음
                            'message'      : error.MESSAGE,     // 내용
                        }
                        errorList.push(errorRecord);
                    }
                }
                if(response.LT_WRONG_ITEM.length > 0) {
                    component.set('v.isError', true);
                    for(let error of response.LT_WRONG_ITEM) {
                        errorRecord = {
                            'partName'     : error.ERROR_MATNR, // 부품번호
                            'wrongItem'    : 'X',               // Wrong Item
                            'noCode'       : error.NOTCD,       // 코드 없음
                            'message'      : error.MESSAGE,     // 내용
                        }
                        errorList.push(errorRecord);
                    }
                }
                if(response.LT_WRONG_DIVISION.length > 0) {
                    component.set('v.isError', true);
                    for(let error of response.LT_WRONG_DIVISION) {
                        errorRecord = {
                            'partName'     : error.ERROR_MATNR, // 부품번호
                            'products'     : 'X',               // 제품군
                            'noCode'       : error.NOTCD,       // 코드 없음
                            'message'      : error.MESSAGE,     // 내용
                        }
                        errorList.push(errorRecord);
                    }
                }
                if(response.LT_NON_PRICE.length > 0) {
                    component.set('v.isError', true);
                    for(let error of response.LT_NON_PRICE) {
                        errorRecord = {
                            'partName'     : error.ERROR_MATNR, // 부품번호
                            'price'        : 'X',               // 가격
                            'noCode'       : error.NOTCD,       // 코드 없음
                            'message'      : error.MESSAGE,     // 내용
                        }
                        errorList.push(errorRecord);
                    }
                }

                // if(response.LT_NON_EXIST.length > 0) {
                //     component.set('v.isError', true);
                //     for(let error of response.LT_NON_EXIST) {
                //         errorRecord = {
                //             'partName'     : error.NOTCD,       // 부품번호
                //             'noCode'       : 'X',               // no code
                //             'noCode'       : error.NOTCD,       // 코드 없음
                //             'message'      : error.MESSAGE,     // 내용
                //         }
                //         errorList.push(errorRecord);
                //     }
                // }

                if(response.LT_NON_PURCHASE.length > 0) {
                    component.set('v.isError', true);
                    for(let error of response.LT_NON_PURCHASE) {
                        if(error.ERROR_MATNR != null && error.ERROR_MATNR != '') {
                            if(error.HILV == '000000') {
                                errorRecord = {
                                    'partName'     : error.ERROR_MATNR, // 부품번호
                                    'nonPurchased' : 'X',               // 비구매
                                    'noCode'       : error.NOTCD,       // 코드 없음
                                    'message'      : error.MESSAGE,     // 내용
                                }
                                errorList.push(errorRecord);
                            }    
                        }else {
                            errorRecord = {
                                'partName'     : error.NOTCD,       // 부품번호
                                'noCode'       : 'X',               // no code
                                'noCode'       : error.NOTCD,       // 코드 없음
                                'message'      : error.MESSAGE,     // 내용
                            }
                            errorList.push(errorRecord);
                        }
                        
                    }
                }
                console.log('errorList >>> ' +JSON.stringify(errorList,null,4));
                if(errorList.length > 0) {
                    helper.toast('ERROR',`${errorList.length} 개의 에러가 있습니다. 보고서를 확인해주세요.`);
                    component.set('v.errorCount', errorList.length);
                }
                component.set('v.errorList', errorList);
                if(response.LT_ITEM) {
                    var itemList = response.LT_ITEM;
                    var urgency = orderType == 'YDEO';
                    var num = 10;

                    for(let part of itemList) {
                        console.log('part.AVAIL_QTY1 : ' + part.AVAIL_QTY1);
                        console.log('part.AVAIL_QTY2 : ' + part.AVAIL_QTY2);
                        partRecord = {
                            'hangNumber'     : num,
                            // 'hang'           : num.padStart(6, '0'), // 항목
                            'hang'           : part.ITEM,            // 항목
                            'orderPartNo'    : part.MATERIAL_ENT,    // 주문품번
                            'supplyPartNo'   : part.MATERIAL,        // 공급풉번
                            'partName'       : part.MATERIAL_TEXT,   // 품명
                            'urgency'        : urgency,              // 긴급도
                            'quantity'       : helper.formatPrice(part.INPUT_QTY),      // 주문 수량
                            'salesUnit'      : part.MIN_QTY == 0 ? '1' : part.MIN_QTY,  // 판매 단위
                            'unit'           : part.UOM,             // 단위
                            'unitPrice'      : helper.formatPrice(part.NET_ITEM_PRICE), // 단가
                            'partsAmount'    : helper.formatPrice(part.NET_VALUE),      // 금액
                            'piCurrency'     : currency,              // 통화
                            'availableStock1': helper.formatPrice(part.AVAIL_QTY1),     // 창원 가용 재고
                            'availableStock2': helper.formatPrice(part.AVAIL_QTY2),     // 천안 가용 재고
                            // 'availableStock' : helper.formatPrice(part.AVAIL_QTY1),     // 가용 재고
                            'twp'            : part.TO_PART == 'X' ? 'V' : '',          // TWP
                            'bulletin'       : part.BULLETIN == 'X' ? 'V' : '',         // bullentin
                            'note'           : part.MEMO == 'X' ? 'V' : '',             // note
                            'machine'        : part.ZZAPPMACHINE,     // 기종
                            'equipment'      : part.ZZEQMASTER,       // 장비번호
            
                            'orderPartId'    : '',                    // 주문품번 Id
                            'supplyPartId'   : '',                    // 공급품번 Id
                            'isSimul'        : true                // simulation 확인
                        }
                        num += 10;
                        partList.push(partRecord);
                    }
                }

                partList.forEach(e => {
                    partList.forEach(f => {
                        if (e.machine && e.machine.trim() !== '' && e.orderPartNo === f.orderPartNo) {
                            f.machine = e.machine;
                            f.equipment = e.equipment;
                        }
                    });
                });            

                for (let pdt of partList) {
                    productSet.add(pdt.orderPartNo);
                    productSet.add(pdt.supplyPartNo);
                }

                productList = Array.from(productSet);
                return helper.apexCall(component, 'SearchPartNo', {pn : productList});
            }
        }))
        .then($A.getCallback(function(result){
            let response = result.r;
            partList.forEach(e => {
                if(parseInt(e.hang, 10) % 10 != 0) {
                    e.isDisabled = true;
                }
                response.forEach(j => {
                    if(e.orderPartNo == j.ProductCode) {
                        e.orderPartId = j.Id || '';
                    }
                    if(e.supplyPartNo == j.ProductCode) {
                        e.supplyPartId = j.Id || '';
                    }
                })
            })

            component.set('v.partsList', partList);
            component.set('v.partListLength', partList.length);
            var partsList2 = component.get('v.partsList');

            var message = '';
            let bulletinGroupNo = new Map();
            let twpGroupNo = new Map();
            partsList2.forEach(e => {
                if(e.twp != '') {
                    const groupKey = Math.floor(Number(e.hang) % 10 == 0);

                    if (!twpGroupNo.has(groupKey)) {
                        twpGroupNo.set(groupKey, []);
                    }
                    twpGroupNo.get(groupKey).push(e.hang);
                }
                if(e.note != '') {
                    message += `\n${e.hang} 번 :: Part Note" 기준정보 내용을 확인하십시오.`;
                }
                if (e.bulletin !== '') {
                    const groupKey = Math.floor(Number(e.hang) / 10) * 10;
            
                    if (!bulletinGroupNo.has(groupKey)) {
                        bulletinGroupNo.set(groupKey, []);
                    }
                    bulletinGroupNo.get(groupKey).push(e.hang);
                }
            });
            
            bulletinGroupNo.forEach((hangNumbers) => {
                message += `\n${hangNumbers.join(', ')} 번 :: Part Bulletin" 기준정보 내용을 확인하십시오.`;
            })

            twpGroupNo.forEach((hangNumbers) => {
                message += `\n${hangNumbers.join(', ')} 번 :: 부품 데이터와 함께 존재합니다. TWP 를 확인하십시오.`;
            })

            if(message != '') {
                if(twpGroupNo.size != 0) {
                    helper.toast('SUCCESS', '\u00A0'.repeat(40) + '▣ 알림 메세지 ▣\n'+message);
                } else if(bulletinGroupNo.size != 0) {
                    helper.toast('SUCCESS', '\u00A0'.repeat(35) + '▣ 알림 메세지 ▣\n'+message);
                } else {
                    helper.toast('SUCCESS', '\u00A0'.repeat(28) + '▣ 알림 메세지 ▣\n'+message);
                }
                
            }
            component.set('v.isSave', true);
            component.set('v.isLoading', false);
            console.log('simulation 확인!!!    '+JSON.stringify(component.get('v.partsList'),null,4))
            // console.log(component.get('v.initPartsList'));
        }))
        .catch($A.getCallback(function(errors) {
            if (component.get('v.simulstatus') == 'S') {
                component.set('v.isLoading', false);
            }
            console.log('errors >> ' +JSON.stringify(errors,null,4))
        }))
    },

    // save data
    doSave : function (component, event, helper) {
        component.set('v.isLoading', true);

        var isSave = component.get('v.isSave');

        var dealerInfo            = component.get('v.dealerInfo');              // 유저 정보

        var orderType             = component.get('v.orderType');               // 주문유형
        var customerOrderNo       = component.get('v.customerOrderNo');         // 고객주문번호
        var consolidatedShipping  = component.get('v.consolidatedShipping');    // 일괄배송여부

        var shippingInfo          = component.get('v.shippingInfo');            // 배송 정보
        var shippingLocation      = component.get('v.shippingLocation');        // 배송처 정보

        var partsList             = component.get('v.partsList');               // parts 모음

        console.log('저장 최초 partsList >>' + JSON.stringify(partsList,null,4))

        var totalAmount = Number(component.get('v.totalAmount'));
        var totalCredit = Number(component.get('v.totalCredit'));

        const custom = shippingLocation.customerCode === '11999999';  // 고객 코드 5~, C5~, 수기 입력시 true 그 외에는 false

        if (customerOrderNo == null || customerOrderNo == '') {
            component.set('v.isLoading', false);
            return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_7}")); //고객주문번호를 입력해 주세요.
        }

        if (shippingLocation == null || shippingLocation == '') {
            component.set('v.isLoading', false);
            return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_8}")); //배송처를 입력해 주세요.
        }

        if (shippingInfo == null || shippingInfo == '') {
            component.set('v.isLoading', false);
            return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_9}")); //배송 정보를 입력해 주세요.
        }

        // 부품 번호 확인
        let noPartNo = partsList.filter(part => part.orderPartId == null);
        console.log('부품 확인 >> ' +JSON.stringify(noPartNo,null,4))
        if (noPartNo.length > 0) {
            component.set('v.isLoading', false);
            return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_10}"));//부품정보를 입력 해주세요\n(수기입력시 Enter 를 눌러주세요)');
        }
        
        partsList = partsList.filter(part => part.orderPartId);
        var qty = partsList.filter(e => e.quantity == '0');
        console.log('qty > '+JSON.stringify(qty,null,4));
        console.log('qty > '+qty.length);
        if(qty.length != 0) {
            component.set('v.isLoading', false);
            return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_6}")); //수량을 입력 해주세요.
        } 

        if(component.get('v.simulstatus') == 'P') {
            component.set('v.isLoading', false);
            return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_11}")); //시뮬레이션 실행 중입니다. Simulation 버튼을 다시 한번 클릭해주세요.
        } else { 
            var noSimulation = partsList.filter(part => part.isSimul == false);
            console.log('noSimulation >> ' + JSON.stringify(noSimulation,null,4));
            if (noSimulation.length > 0) {
                component.set('v.isLoading', false);
                return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_12}"));//주문을 생성할 수 없습니다. 시뮬레이션 실행해주시기 바랍니다.
            }

            console.log('isSave >> ' + isSave);
            if(!isSave) {
                component.set('v.isLoading', false);
                return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_13}"));//변경된 데이터가 있습니다. 다시 시뮬레이션을 실행해 주세요.
            }
        }

        partsList.forEach(e => {
            if(e.quantity.includes(',')) {
                e.quantity = e.quantity.replace(/,/g, '');
            }
        });

        // crm 에는 단가가 0 이 아닌 것만 저장
        var crmPartsList = partsList.filter(part => part.unitPrice != '0');
        // sap 에는 원본 품번만 저장
        var sapPartsList = partsList.filter(part => Number(part.hang)%10 === 0);
        
        // 주문유형이 긴급일 경우 기종과 장비번호 필요
        if (orderType === 'YDEO') {
            var partsList2 = partsList.filter(part => part.copy != 'check');
            for (var i = 0; i < partsList2.length; i++) {
                if(partsList2[i].machine == null || partsList2[i].machine == '') {
                    component.set('v.isLoading', false);
                    return helper.toast('WARNING', $A.get("{{!$Label.c.ORC_MSG_14}")); //긴급주문인 경우 각 주문품번별 기종 및 장비번호 정보가 필요합니다. \n 내용 입력해 주시기 바랍니다.
                }
                else if(partsList2[i].equipment == null || partsList2[i].equipment == '') {
                    component.set('v.isLoading', false);
                    return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_14}"));
                }
            }
        }

        // 총액 발리데이션
        if(totalAmount > totalCredit) {
            component.set('v.isLoading', false);
            return helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_15}")); //여신초과로 주문를 진행할 수 없습니다. 주문을 위하여 입금하여 주시기 바랍니다
        }

        var createPartsOrderInfo = {
            orderType             : orderType,            // 주문 유형
            customerOrderNo       : customerOrderNo,      // 고객 주문 번호
            consolidatedShipping  : consolidatedShipping, // 일괄 배송
            shippingLocation      : shippingLocation,     // 배송 장소
            shippingInfo          : shippingInfo,         // 배송 방법
            dealerInfo            : dealerInfo,           // 사용자 정보
            // today                 : today,                // 생성일
            sapPartsList          : sapPartsList,         // SAP 저장용 POI 레코드
            crmPartsList          : crmPartsList          // CRM 저장용 POI 레코드
        }

        component.set("v.isBTN", true);
        console.log('createPartsOrderInfo >> ' +JSON.stringify(createPartsOrderInfo,null,4));

        // if(true) {component.set('v.isLoading', false); return;}
            
        helper.apexCall(component, 'SavePartOrder', {oci : createPartsOrderInfo, custom : custom})
        .then($A.getCallback(function(result) {
            let response = result.r;
            var msg = ''
            if(response == '인터페이스 생성 실패') {
                component.set('v.isLoading', false);
                component.set("v.isBTN", false);
                //msg += `\n입력 값을 확인하고 다시 시도해주세요.`;
                return helper.toast('FAIL', $A.get("{!$Label.c.ORC_E_MSG_1}")); //오더 생성에 실패하였습니다.입력 값을 확인하고 다시 시도해주세요.
                
            } else {
                helper.toast('SUCCESS', `주문번호 ${response} 번으로 오더가 생성되었습니다.`);

                localStorage.setItem('partOrderNo', response);
                helper.backOrderInquiry(component, event, helper);    
            }
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            if(errors && errors[0] && errors[0].message) {
                console.log('Error : ' + errors[0].message);
            }else {
                console.log('무슨 에러인가?? XㅅX');
            }
        }))
    },

    /* ---------------------------------------------------------------------------------------- */
    /* --------------------------------- 내부 기능 및 내부 모달 --------------------------------- */
    /* ---------------------------------------------------------------------------------------- */

    backPage: function (component, event, helper) {
        window.history.back();
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

    // 특수 아이콘
    openGPESInUrl: function(component, event, helper) {
        console.log('입력');
        //https://dportal.dn-solutions.com/apex/IF_GPES_T
 
        // let apexPageURL = $A.get("$Label.c.DN_VfPage") +'/apex/IF_GPES_T';
        // let apexPageURL = $A.get("$Label.c.DN_GPES_Url") +'/apex/IF_GPES_T';
        let apexPageURL = 'https://dportal.dn-solutions.com/apex/IF_GPES_T'
        let partNo = event.currentTarget.getAttribute("data-partno");
        let type = event.currentTarget.getAttribute("data-type");
        let url;

        // https://dportal.dn-solutions.com/apex/IF_GPES_T?type=partinfo&part_no=101507-00205B
        if(type == 'bulletin') {
            url = `${apexPageURL}?type=partinfo&part_no=${partNo}`;
            // url = `https://gpes.dn-solutions.com/partBasicInfoVw.do?type=partinfo&part_no=${partNo}`;
        }else if(type == 'twp') {
            url = `${apexPageURL}?type=twp&part_no=${partNo}`;
        } else if(type == 'note') {
            url = `${apexPageURL}?type=partinfo&part_no=${partNo}`;
        }
        // https://gpes.dn-solutions.com/partBasicInfoVw.do?type=T&part_no=
        window.open(url, "_blank");
    },

    // 주문품번 td에서 부품번호 Modal 띄우기
    openSearchProductNumber: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedPartsIndex', Number(rowIndex));
        component.set('v.costInfoModal', false);
        $A.createComponent('c:DN_SearchProductNumber',
            {
                'type': '부품번호'
            },
            function (content, status, errorMessage) {
                if (status === 'SUCCESS') {
                    var container = component.find('SearchProductNumber');
                    container.set('v.body', content);
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.')
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            }
        );
    },

    // 가격정보 모달
    openCostInfoModal:function (component, event, helper) {
        component.set('v.costInfoModal', true);
        component.set('v.excelUploadModal', false);
        component.set('v.errorReportModal', false);

        var priceData = component.get('v.priceData');

        
        // 개별 필드 값 설정
        const itemTotal       = helper.formatPrice(priceData[0].NEWR);  // Item Total (A)
        const freight         = helper.formatPrice(priceData[1].NEWR);  // Freight (B)
        const insurance       = helper.formatPrice(priceData[2].NEWR);  // Insurance (C)
        const handlingCharge  = helper.formatPrice(priceData[3].NEWR);  // Handling Charge (D)
        const outputTax       = helper.formatPrice(priceData[4].NEWR);  // Output Tax (E)
        const totalAmt        = helper.formatPrice(priceData[5].NEWR);  // Total Amount (A+B+C+D+E)
        const itemTotalDoosan = helper.formatPrice(priceData[6].NEWR);  // Item Total (Doosan) (A-F)
        const commissionValue = helper.formatPrice(priceData[7].NEWR);  // Commission Value (F)
        const priceCurrency   = priceData[0].WAERK;

        // costInfo 객체 초기화
        component.set('v.costInfo', {
            itemTotal       : itemTotal,
            freight         : freight,
            insurance       : insurance,
            handlingCharge  : handlingCharge,
            outputTax       : outputTax,
            totalAmt        : totalAmt,
            itemTotalDoosan : itemTotalDoosan,
            commissionValue : commissionValue,
            priceCurrency   : priceCurrency
        });
    },

    // 배송정보 모달
    openInfoChangeModal: function (component, event, helper) {
        component.set('v.infoChangeModal', true);
        component.set('v.costInfoModal', false);
        component.set('v.excelUploadModal', false);
        component.set('v.errorReportModal', false);
    },

    // 에러보고서 모달
    openErrorReport: function (component, event, helper) {
        component.set('v.errorReportModal', true);
        component.set('v.infoChangeModal', false);
        component.set('v.costInfoModal', false);
        component.set('v.excelUploadModal', false);
    },

    // GPES 모달 cancel
    closeModal : function(component, event, helper) {
        component.set('v.isGPESModal', false);
    },

    // 가격정보 모달 cancle
    closeCostInfoModal:function (component, event, helper) {
        component.set('v.costInfoModal', false);
    },

     // 에러 보고서 cancel
    closeErrorReport : function(component, event, helper) {
        component.set('v.errorReportModal', false);
    },

    // 배송정보 모달 cancle 
    closeInfoChangeModal: function (component, event, helper) {
        component.set('v.infoChangeModal', false);
    },

    // 배송처 모달 열기
    openCustomerShipTo: function (component, event, helper) { 
        var dealerInfo = component.get('v.dealerInfo');
        component.set('v.isLoading', true);
        //열려 있는 모달창 닫기
        component.set('v.excelUploadModal', false);
        component.set('v.costInfoModal', false);

        $A.createComponent('c:DN_AgencyCustomerShipToModal',
            {dealerInfo : dealerInfo},
            function (content, status, errorMessage) {
                if (status === 'SUCCESS') {
                    var container = component.find('AgencyCustomerShipToModal');
                    container.set('v.body', content);
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.')
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            });
        component.set('v.isLoading', false);
    },

    // 추가 버튼
    bulkAddPartsProduct: function (component, event, helper) {
        helper.addList(component, event, helper, 5);
        component.set('v.isSave', false);
        component.set('v.oDKey',null);
    },

    // 전체 row 선택
    // selectAll: function (component, event, helper) {
    //     var checkboxes = component.find('checkbox');
    //     var isChecked = component.find('headerCheckbox').get('v.checked');
    //     var plist = [];
    //     // var partsList = component.get('v.partsList');

    //     // 모든 체크박스의 상태를 변경합니다.
    //     if (isChecked == true) {
    //         if (Array.isArray(checkboxes)) {
    //             checkboxes.forEach(function (checkbox, index) {
    //                 checkbox.set('v.checked', isChecked);
    //                 plist.push(index);
    //             });
    //         } else {
    //             checkboxes.set('v.checked', isChecked);
    //             plist.push(0);
    //         }
    //     } else {
    //         if (Array.isArray(checkboxes)) {
    //             checkboxes.forEach(function (checkbox) {
    //                 checkbox.set('v.checked', isChecked);
    //             });
    //         } else {
    //             checkboxes.set('v.checked', isChecked);
    //         }
    //         plist = [];
    //     }
    //     component.set('v.selectedProducts', plist);
    //     // var selectedProducts = component.get('v.selectedProducts');
    // },

    // ' + ' 버튼
    // addPartsProduct: function (component, event, helper) {
    //     helper.addList(component, event, helper, 1);
    // },

    // ' - ' 버튼
    // deletePartsProduct: function (component, event, helper) {
    //     var partsList = component.get('v.partsList');
    //     var rowIndex = event.getSource().get('v.accesskey');
    //     let dashList = component.find('dashId');
    //     var selectedValue = event.getSource().get('v.value');
    //     if (!Array.isArray(dashList)) {
    //         dashList = [dashList];
    //     }
    //     if(selectedValue != '') {
    //         var dashLength = dashList.filter(e => e.get('v.value') == selectedValue);            
    //         var length = dashLength.length;
    //         partsList.splice(rowIndex, length);
    //         component.set('v.partsList', partsList);
    //     } else {
    //         partsList.splice(rowIndex, 1);
    //         component.set('v.partsList', partsList);
    //     }

        
    //     if(partsList.length == 0) {
    //         component.set('v.priceData', '');
    //         component.set('v.credit', '');
    //         component.set('v.creditCurr', '');
    //         component.set('v.tAmount', '');
    //         component.set('v.currency', '');
    //         component.set('v.isPirce', false);
    //     }
    // },

    // checkBox 선택 삭제
    // deleteSelectedItems: function (component, event, helper) {
    //     let partsList = component.get('v.partsList');
    //     let checkboxes = component.find('checkbox');

    //     console.log('partsList >> ' + JSON.stringify(partsList,null,4))
    //     console.log('checkboxes >> ' + JSON.stringify(checkboxes,null,4))

    //     var partsList1 = partsList.length;
    //     checkboxes = Array.isArray(checkboxes) ? checkboxes : [checkboxes];
    //     // let updatedPartsList = partsList.filter((_, index) => !checkboxes[index].get('v.checked'));
    //     partsList = partsList.filter((_, index) => !checkboxes[index].get('v.checked'));
    //     var partsList2 = partsList.length;
    //     component.set('v.partsList', partsList);

    //     console.log('1>> ' +partsList1)
    //     console.log('2>> ' +partsList2)
    //     if(partsList1 < partsList2) {
    //         component.set('v.isSave', false);
    //     }

    //     let headerCheckbox = component.find('headerCheckbox');
    //     if (headerCheckbox) {
    //         headerCheckbox.set('v.checked', false);
    //     }

    //     if(partsList.length == 0) {
    //         component.set('v.priceData', '');
    //         component.set('v.credit', '');
    //         component.set('v.creditCurr', '');
    //         component.set('v.tAmount', '');
    //         component.set('v.currency', '');
    //         component.set('v.totalAmount', '');
    //         component.set('v.totalCredit', '');

    //         component.set('v.isPirce', false);
    //     }
    // },

    // 체크박스 선택/해제
    // handleCheckboxChange: function (component, event, helper) {
    //     var checkboxes = component.find('checkbox');
    //     var selectedValue = event.getSource().get('v.value');
    //     var isChecked = event.getSource().get("v.checked");

    //     console.log('selectedValue >>' + selectedValue)
    //     console.log('isChecked >>' + isChecked)

    //     if (!Array.isArray(checkboxes)) {
    //         checkboxes = [checkboxes];
    //     }

    //     if(selectedValue != '') {
    //         checkboxes.forEach(function(checkbox) {
    //             if (checkbox.get("v.value") === selectedValue) {
    //                 checkbox.set("v.checked", isChecked);
    //             }
    //         });
    //     }

    //     var checkboxes2 = component.find('checkbox');
    //     console.log('checkboxes2 >>> ' + JSON.stringify(checkboxes2,null,4));
    // },

    // doCheckAll : function(component, event, helper) {
    //     component.set('v.checkList', []);
    //     let checkList = component.get('v.checkList');

    //     var checkboxes = component.find('checkbox');
    //     var isChecked = component.find('headerCheckbox').get('v.checked');

    //     console.log('isChecked >> ' +isChecked);
    //     console.log('checkboxes >>' +JSON.stringify(checkboxes,null,4))

    //     checkboxes.forEach((e, index) => {
    //         e.set('v.checked', isChecked);
    //         checkList.push(index);
    //     })

        
    //     console.log('checkboxes >>' +JSON.stringify(checkboxes,null,4))

    //     component.set('v.checkList', checkList);
    // },

    doCheckAll : function(component, event, helper) {
        let isChecked = component.find('headerCheckbox').get('v.checked');
        let partsList = component.get('v.partsList');  // 총 길이 기준
        let checkList = [];
    
        let checkboxes = component.find('checkbox');
    
        console.log('isChecked >> ' + isChecked);
        console.log('checkboxes >> ' + JSON.stringify(checkboxes, null, 4));
    
        // checkboxes가 하나면 배열이 아니라 단일 객체일 수 있으므로 처리 필요
        if (!Array.isArray(checkboxes)) {
            checkboxes = [checkboxes];
        }
    
        checkboxes.forEach((e, index) => {
            e.set('v.checked', isChecked);
            if (isChecked) {
                checkList.push(index);
            }
        });
    
        // 중복 제거 + 정렬 (안 해도 되지만 안정성 확보용)
        checkList = Array.from(new Set(checkList)).sort((a, b) => b - a);
    
        console.log('checkList >> ' + JSON.stringify(checkList, null, 4));
        component.set('v.checkList', checkList);
    },
    

    doCheck: function (component, event, helper) {
        let partsList = component.get('v.partsList');
        let accesskey = event.getSource().get('v.accesskey');
        let checkList = component.get('v.checkList');
        let checkboxes = component.find('checkbox');
        let isChecked = event.getSource().get("v.checked");
    
        console.log('isChecked >> ' + JSON.stringify(isChecked, null, 4));
    
        let partNoValue = partsList[accesskey].orderPartNo;
    
        // 동일한 부품번호를 가진 모든 인덱스 찾기
        let matchedIndexes = partsList
            .map((part, index) => part.orderPartNo === partNoValue ? index : -1)
            .filter(index => index !== -1);
    
        console.log('matchedIndexes >> ' + JSON.stringify(matchedIndexes, null, 4));
    
        // 체크 상태에 따라 추가 또는 제거
        if (isChecked) {
            checkList.push(...matchedIndexes);
        } else {
            checkList = checkList.filter(idx => !matchedIndexes.includes(idx));
        }
    
        // 중복 제거 + 정렬
        checkList = Array.from(new Set(checkList)).sort((a, b) => b - a);
    
        // 동일한 orderPartNo를 가진 checkbox 체크 상태 변경
        checkboxes.forEach(function (checkbox) {
            if (checkbox.get("v.value") === partNoValue) {
                checkbox.set("v.checked", isChecked);
            }
        });
    
        console.log('checkList >> ' + JSON.stringify(checkList, null, 4));
        component.set('v.checkList', checkList);

        console.log('pl >>' + partsList.length)
        console.log('cl >>' + checkList.length)

        // 전체 체크 확인용
        if(partsList.length != checkList.length) {
            component.find('headerCheckbox').set('v.checked', false);
        } else {
            component.find('headerCheckbox').set('v.checked', true);
        }
    },

    deleteRow: function(component, event, helper) {
        let checkList = component.get('v.checkList');
        let partsList = component.get('v.partsList');

        let updatedPartsList = partsList.filter((_, index) => !checkList.includes(index));

        console.log('BF updatedPartsList >> '+JSON.stringify(updatedPartsList,null,4));

        for(let i = 0; i < updatedPartsList.length; i++) {
            updatedPartsList[i].itemNo = String((i+1)*10).padStart(4, '0');
        }

        console.log('AF updatedPartsList >> '+JSON.stringify(updatedPartsList,null,4));

        component.set('v.partsList', updatedPartsList);
        component.set('v.checkList', []);
        component.find('headerCheckbox').set('v.checked', false);
    },

    //기종, 장비번호 지우기
    // clearField: function (component, event, helper) {
    //     let index = event.getSource().get('v.accesskey'); 
    //     let fieldName = event.getSource().get('v.name'); 
    //     let partsList = component.get('v.partsList');
    
    //     if (!partsList || !partsList[index][fieldName]) { 
    //         helper.toast('WARNING', `저장된 ${fieldName} 값이 없습니다.`);
    //         return;
    //     }
    
    //     partsList[index][fieldName] = ''; 
    //     component.set('v.partsList', partsList);
    // },

    //부품 번호 지우기
    clearOrderPart: function (component, event, helper) {
        let index = event.getSource().get('v.accesskey'); 
        let fieldName = event.getSource().get('v.name'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index].orderPartNo.trim()) { 
            helper.toast('WARNING', $A.get("{!$Label.c.BPI_E_MSG_6}")); //저장된 부품번호 값이 없습니다
            return;
        }
        let partNoValue = partsList[index].orderPartNo;
        let hangValue = partsList[index].hang;

        console.log('partNoValue >>' + partNoValue);
        partsList[index] = {
            hang: hangValue,
            isSimul : false,
            orderPartId : null
        };
        
        let findReplacePart = partsList.filter(part => part.orderPartNo == partNoValue);
        let indexReplacePart = partsList.findIndex(part => part.orderPartNo == partNoValue);

        if(indexReplacePart > -1) {
            let hangValue2 = partsList[indexReplacePart].hang;
            partsList[indexReplacePart] = {
                hang: hangValue2
            };    
        }
        console.log('partsList > '+JSON.stringify(partsList,null,4))
        component.set('v.isSave', true);
        component.set('v.partsList', partsList);
    },

    handleKeyPress: function (component, event, helper) {
        let targetElement = event.target;
        let divElement = targetElement.closest("div");
        let idx = divElement ? divElement.getAttribute("accesskey") : null;
        let partsList = component.get('v.partsList');
    
        if (!idx || !partsList[idx]) return;
    
        if (component.get('v.isLoading')) {
            console.log('검색 중이라 요청 무시됨');
            return;
        }
    
        let partRecord = partsList[idx].orderPartNo.toUpperCase().trim();
        let partList = [partRecord];
    
        if (event.keyCode === 13) {
            if (partRecord === '') {
                helper.toast('INFO', $A.get("{!$Label.c.ORC_MSG_16}")); //값을 넣어주세요.
                return;
            }
    
            let isPartsList = partsList.some((e, i) => i != idx && e.orderPartNo == partRecord);
            if (isPartsList) {
                helper.toast('WARNING', $A.get("{!$Label.c.DNS_CAM_T_EXISTCOMMONPARTS}"));//이미 선택한 부품 입니다.
                partsList[idx].orderPartNo = '';
                component.set('v.partsList', partsList);
                return;
            }
    
            component.set('v.isLoading', true);
    
            helper.apexCall(component, 'SearchPartNo', { pn: partList })
            .then($A.getCallback(function (result) {
                component.set('v.isLoading', false);
    
                let response = result.r;
                if (response.length == 0) {
                    helper.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_17}"));//해당 부품은 등록되지 않은 부품 입니다. 다시 확인해주세요.
                    partsList[idx].orderPartNo = '';
                    component.set('v.partsList', partsList);
                } else {
                    helper.toast('SUCCESS', $A.get("{!$Label.c.ORC_S_MSG_1}")); //부품 검색이 완료되었습니다.
                    let part = partsList[idx];
                    part.orderPartId = response[0].Id;
                    part.orderPartNo = response[0].ProductCode;
                    part.partName    = response[0].FM_MaterialDetails__c;
                    component.set('v.partsList', partsList);
                }
            }))
            .catch($A.getCallback(function (error) {
                component.set('v.isLoading', false);
                console.log('error >> ' + JSON.stringify(error, null, 4));
            }));
        }
    },
    
    

    doEnter : function(component, event, helper) {

        let enter = event.keyCode;
        if(enter == 13) {
            let doSimul = component.get('c.doSimulation');
            $A.enqueueAction(doSimul);
        }
    },

    /* ------------------------------------------------------------------------------------------------------ */
    /* --------------------------------------------- 엑셀 업로드 --------------------------------------------- */
    /* ------------------------------------------------------------------------------------------------------ */        

    // 엑셀 업로드 모달 오픈
    openUploadExcel : function(component, event, helper) {
        component.set('v.excelUploadModal', true);
        component.set('v.costInfoModal', false);
    },
    
    // 엑셀 업로드 모달 클로즈
    closeUploadExcel : function (component, event, helper) {
        component.set('v.excelUploadModal', false);
    },

    // 엑셀 업로드 작업(업로드 -> CRM 부품 검색 -> SAP simulation 까지)
    uploadExcel: function (component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.isExcel', true);
        component.set('v.qtyArray', null);
        component.set('v.excelUploadModal', false);

        var file = event.getSource().get('v.files')[0];

        if (file) {
            component.set('v.fileName', file.name);
        } else {
            helper.toast('ERROR', $A.get("{!$Label.c.ORC_E_MSG_2}")); //엑셀 파일에 데이터가 없습니다.
            component.set('v.isLoading', false);
            return;
        }
        helper.readExcelFile(component, file, event)
        .then($A.getCallback(function(result){
            var excelData        = [];
            var orderPartNoList  = [];            
            const result2 = result.filter(row => row.length > 0);

            if(result2.length == 1) {
                return Promise.reject({type:'EmptyExcel', message:'{!$Label.c.ORC_E_MSG_2}'}); //엑셀에 데이터가 없습니다.
            }
            else if(result2.length > 201) {
                return Promise.reject({type:'LimitExcel', message:'{!$Label.c.ORC_MSG_18}'});//부품은 최대 200건 까지만 업로드 가능합니다.
            }

            // 실제 작동 코드 테스트시 주석처리
            for(let e of result2) {
                var orderPartNoRaw = String(e[0] || '').trim();
                var data = {
                    orderPartNo : orderPartNoRaw.toUpperCase(),
                    quantity    : e[1] || '',
                    machine     : e[2] || '',
                    equipment   : e[3] || ''
                }
                excelData.push(data);
                
                if (data.orderPartNo) {
                    orderPartNoList.push(data.orderPartNo);
                }
            }
            component.set('v.excelData', excelData);
            console.log('orderPartNoList >>> ' +JSON.stringify(orderPartNoList,null,4));
            return helper.apexCall(component, 'SearchPartNo', {pn : orderPartNoList})
        }))
        .then($A.getCallback(function(result){
            let response = result.r;
            console.log('JS SearchPartNo >>> ' +JSON.stringify(response,null,4))
            component.set('v.confirmParts', response);
            return helper.excelList(component, event, helper);
        }))
        .then($A.getCallback(function(result){
            return helper.searchProduct(component, event, helper);
        }))
        .then($A.getCallback(function(result) {
            console.log('추가 레코드 생성')
            var partsList = component.get('v.partsList');
            var excelData = component.get('v.excelData');

            // partsList 업데이트
            partsList.forEach(function(part) {
                // part.orderPartNo 가 문자열이 아닐 수 있으므로 방어코드 추가
                var partNo = (typeof part.orderPartNo === 'string' ? part.orderPartNo : String(part.orderPartNo || '')).trim().toLowerCase();
                if (!partNo) return;

                var matchingData = excelData.find(function(data) {
                    let excelPartNo = '';
                    if (typeof data.orderPartNo === 'string') {
                        excelPartNo = data.orderPartNo.trim().toLowerCase();
                    } else if (data.orderPartNo != null) {
                        excelPartNo = String(data.orderPartNo).trim().toLowerCase();
                    }
                    return excelPartNo === partNo;
                });

                console.log('excel matchingData >>>> ' + JSON.stringify(matchingData, null, 4));
                
                if (matchingData) {
                    part.quantity   = typeof matchingData.quantity === 'string' || typeof matchingData.quantity === 'number'
                                    ? String(matchingData.quantity) : '';
                    part.machine    = typeof matchingData.machine === 'string' ? matchingData.machine : '';
                    part.equipment  = typeof matchingData.equipment === 'string' ? matchingData.equipment : '';
                    part.isExcel    = true;
                }
            });
            component.set('v.partsList', partsList);
            component.set('v.isExcel', false);
            console.log('partsList >>  '+JSON.stringify(partsList,null,4));
            // component.set('v.isLoading', false);
            let doSimul = component.get('c.doSimulation');
            $A.enqueueAction(doSimul);

        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            component.set('v.isExcel', false);
            console.log('errors.message >> ' +JSON.stringify(errors.message,null,4));
            if(errors.type == 'EmptyExcel') {
                helper.toast('INFO', errors.message);
            }else if(errors.type == 'LimitExcel') {
                helper.toast('INFO', errors.message);
            }else {
                helper.toast('ERROR', $A.get("{!$Label.c.ORC_E_MSG_3}")); //관리자에게 문의 바랍니다.(부품주문 - 엑셀업로드)
            }
        }))
    },

    downloadExcel: function (component, event, helper) {
        try {
            let partsList = component.get('v.partsList');
            // let partsList = component.get('v.excelDown');
            // console.log('excel down >> '+JSON.stringify(partsList,null,4))
            if (partsList[0].orderPartNo == '') {
                helper.toast('ERROR', $A.get("{!$Label.c.MPI_E_MSG_2}")); //엑셀로 변경할 데이터가 없습니다.
                return;
            } else {
                var header = [
                    ['항목', '주문품번', '공급품번', '품명', '긴급도', '주문수량', '판매단위', '단위', '단가', '금액', '통화', '창원재고', '천안재고', 'TWP', 'Bulletin', 'Note', '기종', '장비번호']
                ];
                // var header = [
                //     ['항목', '주문품번', '공급품번', '품명', '긴급도', '주문수량', '판매단위', '단위', '단가', '금액', '통화', '가용재고', 'TWP', 'Bulletin', 'Note', '기종', '장비번호']
                // ];
    
                var sheetName = '오더 생성 Parts List';
                var wb = XLSX.utils.book_new();
                var excelData = [];
                excelData = excelData.concat(header);
                
                partsList.forEach(item => {
                    if(item.partName != '') {
                        excelData.push([
                            item.hang           || '',  // 항목
                            item.orderPartNo    || '',  // 주문품번
                            item.supplyPartNo   || '',  // 공급품번
                            item.partName       || '',  // 품명
                            item.urgency ? '긴급':'일반',  // 긴급도
                            item.quantity       || '',  // 주문수량
                            item.salesUnit      || '',  // 판매단위
                            item.unit           || '',  // 단위
                            item.unitPrice      || '',  // 단가
                            item.partsAmount    || '',  // 금액
                            item.currency       || '',  // 통화
                            item.availableStock1|| '',  // 창원 가용재고
                            item.availableStock2|| '',  // 천안 가용재고
                            // item.availableStock || '',  // 가용재고
                            item.twp            || '',  // TWP
                            item.bulletin       || '',  // bulletin
                            item.note           || '',  // note
                            item.machine        || '',  // 기종
                            item.equipment      || ''   // 장비번호
                        ]);
                    }
                });

                let orderPartLength = Math.max(...partsList.map(item => item.orderPartNo.length ));
                let supplyPartLength = Math.max(...partsList.map(item => item.supplyPartNo.length ));
                let partNameLength = Math.max(...partsList.map(item => item.partName.length ));
                // console.log("가장 긴 partName 길이:", maxLength);

        
                var ws = XLSX.utils.aoa_to_sheet(excelData);
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 15 },  // 항목
                    { wch: orderPartLength + 7 },  // 주문품번
                    { wch: supplyPartLength + 7 },  // 공급품번
                    { wch: partNameLength + 12 },  // 품명
                    { wch: 15 },  // 긴급도
                    { wch: 15 },  // 주문수량
                    { wch: 15 },  // 판매단위
                    { wch: 15 },  // 단위
                    { wch: 15 },  // 단가
                    { wch: 15 },  // 금액
                    { wch: 15 },  // 통화
                    { wch: 15 },  // 창원가용재고
                    { wch: 15 },  // 천안가용재고
                    { wch: 15 },  // TWP
                    { wch: 15 },  // Bulletin
                    { wch: 15 },  // Note
                    { wch: 15 },  // 기종
                    { wch: 15 }   // 호기
                ];
    
                const range = XLSX.utils.decode_range(ws['!ref']);
                for (let R = range.s.r; R <= range.e.r; R++) {

                    // // 1열(A열, Column 0)의 셀 주소 가져오기
                    // const firstCellAddress = XLSX.utils.encode_cell({ r: R, c: 0 });

                    // // 1열 값이 비어 있으면 해당 행을 건너뜀
                    // if (!ws[firstCellAddress] || !ws[firstCellAddress].v) {
                    //     continue; // 해당 행을 넘김
                    // }

                    for (let C = range.s.c; C <= range.e.c; C++) {
                        const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
                        if (!ws[cellAddress]) {
                            ws[cellAddress] = { t: 's', v: '', s: {} };
                        }
            
                        if (ws[cellAddress] != undefined) {
                            ws[cellAddress].s = {
                                alignment: { horizontal: 'center', vertical: 'center' },
                                border: {
                                    top   : { style: 'thin', color: { rgb: '000000' } },
                                    bottom: { style: 'thin', color: { rgb: '000000' } },
                                    left  : { style: 'thin', color: { rgb: '000000' } },
                                    right : { style: 'thin', color: { rgb: '000000' } }
                                }
                            };
                        }

                        // 첫 번째 행(헤더)에 스타일 추가
                        if (R === 0) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 연한 하늘색 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }
                    }
                }

                XLSX.utils.book_append_sheet(wb, ws, sheetName);
    
                var wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'binary' });
    
                function s2ab(s) {
                    var buf = new ArrayBuffer(s.length);
                    var view = new Uint8Array(buf);
                    for (var i = 0; i < s.length; i++) view[i] = s.charCodeAt(i) & 0xFF;
                    return buf;
                }
    
                var blob = new Blob([s2ab(wbout)], { type: "application/octet-stream" });
                var link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = sheetName + '.xlsx';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        } catch (error) {
            console.log('에러 내역 ::: ' + error.message);
        }
    },    

    /* **************************************************************************************************************************** */
    /* ******************************************************** 받아오는 값 ******************************************************** */
    /* **************************************************************************************************************************** */



    // GPES 모달
    openGPES : function(component, event, helper) {

        // Apex URL 설정
        let apexPageURL = $A.get("$Label.c.DN_VfPage") +'/apex/IF_GPES_T?type=reqParts'; // 통합
        component.set('v.apexPageURL', apexPageURL);
        component.set('v.isGPESModal', true);

        component.set('v.infoChangeModal', false);
        component.set('v.costInfoModal', false);
        component.set('v.excelUploadModal', false);

        // // DD 250515
        // console.log('GPES 작동');
        // helper.addMessageListener(component, event);
        // helper.gpesEventListener(component, event, helper);

        // var test = function(event) {
        //     console.log('event        > ' +JSON.stringify(event,null,4));
        //     console.log('event.origin > ' +JSON.stringify(event.origin,null,4));
        //     console.log('event.data   > ' +JSON.stringify(event.data,null,4));
        // };

        // if (this.isGPESModal) {
        //     this.handleMessage = test.bind(this);
        //     console.log('handleMessage ::: ', this.handleMessage);
        //     window.addEventListener('message', this.handleMessage);
        // } else {
        //     window.removeEventListener('message', this.handleMessage);
        //     this.handleMessage = null;
        // }
    },

    // event
    handleCompEvent: function(component, event, helper) {
        var modalName = event.getParam('modalName');
        var message   = event.getParam('message');
        var idx       = component.get('v.selectedPartsIndex');
        var partsList = component.get('v.partsList');

        // 부품
        if(modalName === 'DN_SearchProductNumber') {
            if(idx !== undefined && idx >= 0 && idx < partsList.length) {
                // var isPartsList = partsList.some(e => e.orderPartId == message.Id);
                // if(isPartsList) {
                //     helper.toast('WARNING','이미 선택한 부품 입니다.');
                //     return;
                // }
                let isPartsList = partsList.some((e, i)=> i != idx && e.orderPartNo == message.ProductCode);
            
                if(isPartsList) {
                    helper.toast('WARNING',$A.get("{!$Label.c.DNS_CAM_T_EXISTCOMMONPARTS}")); //이미 선택한 부품 입니다.
                    partsList[idx].orderPartNo = '';
                    component.set('v.partsList', partsList);
                    return;
                }

                var part = partsList[idx];

                part.orderPartId = message.Id;             // Id
                part.partName    = message.Name;           // 품명
                part.orderPartNo = message.ProductCode;    // 품번
                part.model       = message.Model__c;       // 모델
                part.isSimul     = false;

                console.log('partsList >> ' + JSON.stringify(partsList,null,4));
                component.set('v.partsList',partsList);
            } else {
                console.log('idx 가 유효하지 않음1 => ' +idx);
            }
        }        

        // 기종 => asset 에서 가져오는 거긴 한데 아직 정확히 전달 받은 정보 없음.
        else if (modalName === 'MachineModal') {
            if(idx !== undefined && idx >= 0 && idx < partsList.length) {
                var part = partsList[idx];

                part.machine     = message.label;
                part.machineInfo = message;

                partsList.forEach(e => {
                    if(e.orderPartNo == part.orderPartNo && part.orderPartNo != '') {
                        e.machine     = message.label;
                    }
                })
                component.set('v.partsList', partsList);
                component.set('v.machineInfo', message);

            }  else {
                console.log('idx 가 유효하지 않음2 => ' +idx);
            }
        }

        // 장비번호
        else if (modalName === 'SerialModal') {
            if(idx !== undefined && idx >= 0 && idx < partsList.length) {
                var part = partsList[idx];

                part.machine       = message.machineName;
                part.equipment     = message.label;
                part.equipmentInfo = message;

                partsList.forEach(e => {
                    if(e.orderPartNo == part.orderPartNo && part.orderPartNo != '') {
                        e.machine       = message.machineName;
                        e.equipment     = message.label;
                    }
                })

                component.set('v.partsList', partsList);
                component.set('v.equipmentInfo', message);

            }  else {
                console.log('idx 가 유효하지 않음3 => ' +idx);
            }
        } 

        // 배송처 주소 (수기 입력)
        else if(modalName === 'DN_inputModalOpen') {

            // 화면 송출용
            var Street      = message.inputAddress;
            var zipCode     = message.inputZipCode == null ? '' : '(' + message.inputZipCode + ') ';
            var inputShipTo = zipCode + Street;
            component.set('v.inputShipTo', inputShipTo);

            console.log('message address >> '+JSON.stringify(message,null,4));
            var shippingLocation = {
                supplier            : 'DN Solution',
                customerCode        : '11999999',
                // buyer               : message.inputCustomerName,
                shippingDestination : message.inputCustomerName,
                // city                : message.inputCountry,
                // Street              : message.inputAddress,
                city                : message.addr,
                street              : message.detail,
                zipCode             : message.inputZipCode,
                partManager         : message.inputManager,
                partManagerMP       : message.inputPhone,
                
            }
            component.set('v.shippingLocation', shippingLocation);
        }

        // 배송처 주소 (검색 및 선택)
        else if(modalName === 'DN_AgencyCustomerShipToModal') {
            let addr = message.customerAddress;
            let detail = message.customerDetail;
            let zip = message.customerZipCode;
            // let city = message.customerAddress.split(' ')[0];
            console.log('address>>>>>'+JSON.stringify(message,null,4));


            // const [streetAddress, city, zip, country] = message.customerAddress.split(',').map(part => part.trim());

            var zipCode     = zip == null ? '' : '(' + zip + ') ';

            const inputShipTo = zipCode + addr + ' ' + detail +' ,'+message.customerName;
            component.set('v.inputShipTo', inputShipTo);

            var shippingLocation = {
                supplier             : 'DN Solutions',        // 공급업체
                customerId           : message.customerId,    // 수취자 Id
                // customerCode         : message.customerCode,  // 수취자 코드
                // customerCode         : message.customerCode.startsWith('C500') ? '11999999' : message.customerCode,
                customerCode         : message.customerCode.startsWith('C5') || message.customerCode.startsWith('5') ? '11999999' : message.customerCode,
                // buyer                : message.customerName,  // 구매자
                shippingDestination  : message.customerName,  // 배송처
                shippingAddress      : inputShipTo,           // 배송처 주소
                // city                 : city,                  // 도시
                // street               : address,               // 거리
                city                 : addr,
                street               : detail,
                zipCode              : zip,                   // 우편번호
                partManager          : message.manager,       // 부품 담당자
                partManagerMP        : message.customerPhone, // 배송처 전화번호
            }

            component.set('v.shippingLocation', shippingLocation);
        }
    },    
})