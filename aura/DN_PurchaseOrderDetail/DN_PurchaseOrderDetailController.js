/**
 * @author            : Yeong-Deok Seo
 * @Description       : (포탈) 부품 주문 > 오더 조회 > Order Detail Information
 * @last modified on  : 2025-09-15
 * @last modified by  : KyongyunJung@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-05-30   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    init : function(component, event, helper) {
        var orderNumber = component.get('v.partOrderNo');
        var type = component.get('v.Type');
        
        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let response = result.r;
            component.set('v.dealerInfo', response);
        }))
        .then($A.getCallback(function(result) {
            if (orderNumber.startsWith('3') || orderNumber.startsWith('2') || orderNumber.startsWith('7')) {
                component.set('v.detailPage', '3Type');
                let search = component.get('c.doSearch');
                $A.enqueueAction(search);
            
            } // 타대리점 구매 오더(4)
            else if (orderNumber.startsWith('4')) {
                component.set('v.detailPage', '4Type');
                // component.set('v.isLoading', false);
    
            } // 반품 부품 오더(5) 아직 페이지 없음
            else if (orderNumber.startsWith('5')) {
                component.set('v.detailPage', '3Type');
                let search2 = component.get('c.doSearch2');
                $A.enqueueAction(search2);
                // component.set('v.isLoading', false);
            }
            var detailPage = component.get('v.detailPage');
            component.set('v.isLoading', false);
            console.log('orderNumber', orderNumber);
            console.log('detailPage', detailPage);            
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            helper.toast('ERROR', $A.get("{!$Label.c.PES_E_MSG_2}"));  //관리자에게 문의 부탁 드립니다.
            console.log('errors>> ' +JSON.stringify(errors,null,4));
        }))        
    },

    // ODI 모달 닫기
    puchaseOrderDetailModalCancel : function(component, event, helper) {
        helper.closeModal(component);
    },


    // 기능 변경으로 직접적으로는 검색 버튼 없음. init 에서 호출되어 사용중.
    doSearch : function(component, event, helper) {
        console.log('작덩!!!!!');
        var partOrderNo = component.get('v.partOrderNo');
        helper.apexCall(component, 'GetDetailInfo', {pon : partOrderNo})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('response >>>> '+JSON.stringify(response,null,4));
            var orderType = response.OrderType__c;
            var zipcode = response.ZipCode__c != null && response.ZipCode__c !== undefined ? `(${response.ZipCode__c}) ` : '';
            var city = response.City__c != null && response.City__c !== undefined ? response.City__c : '';
            var street = response.Street__c != null && response.Street__c !== undefined ? response.Street__c : '';

            var shippingLocation = {
                shippingAddress : zipcode + city + ' ' + street + ', ' +response.ShippingDestination__c,
                partManager : response.PartManager__c || '',
                partManagerMP : response.PartManagerMobilePhone__c || '',
            }
            var shippingInfo = {
                shippingTerm : response.ShippingTerm__c,
                shippingRoute : response.ShippingRoute__c || '', // dns에서는 안쓰고 dnsa 에서 사용하는 걸로 들음
                paymentTerm : response.PaymentTerm__c,
                transportationTermOne : response.TransportationTermOne__c,
                transportationTermTwo : response.TransportationTermTwo__c
            }
            var partsList = [];
            
            for (let part of response.PurchaseOrderItems__r) {
                var record = {
                    partOrderNo     : partOrderNo,
                    hang            : part.ItemNo__c,
                    orderPartNo     : part.OrderPartNo__c,
                    supplyPartNo    : part.SupplyPartNo__c,
                    partName        : part.PartName__c,
                    quantity        : part.Quantity__c,
                    unit            : part.Unit__c,
                    unitPrice       : part.UnitPrice__c,
                    currency        : part.CurrencyIsoCode,
                    orderItemAmount : part.PartAmount__c,
                    machine         : part.MachineName__c || '',
                    equipment       : part.EquipmentNo__c || '',
                    DepartureSite   : part.DepartureSite__c || ''
                };
                partsList.push(record);
            }
            component.set('v.orderType', orderType);
            component.set('v.customerOrderNo', response.CustomerOrderNo__c);
            component.set('v.deliveryDate', response.RequestedDeliveryDate__c);
            component.set('v.consolidatedShipping', response.ConsolidatedShipping__c);
            component.set('v.shippingLocation', shippingLocation);
            component.set('v.shippingInfo', shippingInfo);
            component.set('v.totalPrice', response.totalPrice);
            component.set('v.orderAmount', (response.ItemsAmount__c*1.1).toLocaleString());
            component.set('v.pcoCurrecny', response.CurrencyIsoCode);
            component.set('v.partsList', partsList);
            
            component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            helper.toast('ERROR',$A.get("{!$Label.c.PES_E_MSG_2}")); //관리자에게 문의 부탁 드립니다.
            console.log('error>> ' +JSON.stringify(errors,null,4));
        }))

    },

    doSearch2 : function(component, event, helper) {
        var dealerInfo = component.get('v.dealerInfo');
        var partOrderNo = component.get('v.partOrderNo')
        helper.apexCall(component, 'GetDetailReturn', {dli: dealerInfo, pon: partOrderNo})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('response :: '+JSON.stringify(response,null,4))

            var shippingInfo = {
                shippingTerm : response.shippingTerm,
                shippingRoute: response.routeTerm,
                transportationTermOne : response.transportationTermOne,
                transportationTermTwo : response.transportationTermTwo
            }

            var shippingLocation = {
                shippingAddress : response.deliveryAddress,
                partManagerMP : response.managerPhone
            }

            component.set('v.customerOrderNo', response.customerOrderNo);
            component.set('v.deliveryDate', response.requestDeliveryDate);
            component.set('v.shippingLocation', shippingLocation);
            component.set('v.shippingInfo', shippingInfo);
            component.set('v.partsList', response.partsList);

        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            helper.toast('ERROR', $A.get("{!$Label.c.PES_E_MSG_2}"));
            console.log('error>> ' +JSON.stringify(errors,null,4));
        }))
    },

    // 부품 기본 정보 Modal 띄우기
    openPartBasicInfo : function(component, event, helper) {
        console.log('*** 부품 기본 정보 모달 ***');
        component.set('v.isPartBasicInfoModal', true);
        component.set('v.isLoading', true);

        let partNumber = event.currentTarget.dataset.record;
        
        component.set('v.partNumber',partNumber);
        let dealerInfo = component.get('v.dealerInfo');
        
        helper.apexCall(component, 'GetBasicPartInfo', {dli: dealerInfo, pon: partNumber})
        .then($A.getCallback(function(result) {
            let response = result.r;
            
            let pbInfo = response.partBasicInfo;
            pbInfo.consumerPrice = pbInfo.consumerPrice.toLocaleString() + ' ' + pbInfo.pbiCurrency;
            pbInfo.unitPrice = pbInfo.unitPrice.toLocaleString() + ' ' + pbInfo.pbiCurrency;

            component.set('v.partInfo', pbInfo);
            component.set('v.replaceList', response.replacementInfo);

            return helper.apexCall(component, 'GetReplacePart', {pon : partNumber, dli : dealerInfo});
        }))
        .then($A.getCallback(function(result) {
            let response = result.r;

            let replacementPart = helper.getNextPart(component, response, partNumber);
            console.log('reName :: ' + replacementPart);
            component.set('v.replaceName', replacementPart);
            component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            helper.toast('ERROR', $A.get("{!$Label.c.PES_E_MSG_2}")); //관리자에게 문의 부탁 드립니다.
            console.log('errors>> ' +JSON.stringify(errors,null,4));            
        }))

    },
    
    // 부품 기본정보 Modal 닫기
    closePartBasicInfoModal : function(component, event, helper) {
        component.set('v.dropdownList', null);
        component.set('v.isPartBasicInfoModal', false);
    },

    // 부품 기본정보 Modal에서 부품번호 검색했을 때 Dropdown만들기
    handleKeyUp: function (component, event, helper) {
        component.set('v.issearching', true);
        var queryTerm = component.find('enter-search').get('v.value').toUpperCase();
        var searchPartsList = component.get('v.searchPartsList');
        var dropdownList = [];
        searchPartsList.forEach(parts => {
            console.log(parts);
            var number = parts.MATNR;
            if (number.includes(queryTerm) && queryTerm != '') {
                var obj = {
                    "oneText" : number.split(queryTerm)[0],
                    "twoText" : queryTerm,
                    "threeText" : number.split(queryTerm)[1],
                    "MATNR" : parts.MATNR,
                    "MAKTX" : parts.MAKTX
                };
                dropdownList.push(obj);
            } else if (queryTerm == null || queryTerm == '') {
                dropdownList = [];   
            }
        });
        component.set('v.dropdownList', dropdownList);
        component.set('v.issearching', false);
    },

    // 부품번호 Dropdown에서 부품 선택했을 때
    hadleClick: function (component, event, helper) {
        var term = event.getSource().get('v.accesskey');
        console.log('term', term);
    },

    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function (component, event, helper) {
        try {
            var detailPage = component.get('v.detailPage');
            var partsList = [];
            
            var header = [];
            var sheetName = '';
            
            if(detailPage == '3Type') {
                partsList = component.get('v.partsList');
                header = ['주문번호', '항목', '주문품번', '공급품번', '품명', '요청수랑', '단위', '단가', '금액', '통화', '기종', '장비번호'];
                sheetName = 'partsList';
            } else if (detailPage == '4Type') {
                partsList = component.get('v.partsList2');
                header = ['항목', '주문품번', '품명', '수량', '단위', '통화', '고객판매가', '할인판매가', '할인판매금액', '출고수량', '미결수량', '변경요청수량', '최종요청수량', '대리점재고', '상태'];
                sheetName = 'Order_History';
            } else {
                helper.toast('INFO', $A.get("{!$Label.c.MPI_E_MSG_2}")); //'엑셀로 변경할 데이터가 없습니다.'
                return;
            }

            if (partsList.length == 0) {
                helper.toast('INFO', $A.get("{!$Label.c.MPI_E_MSG_2}")); //'엑셀로 변경할 데이터가 없습니다.'
                return;
            } else {

                var wb = XLSX.utils.book_new();
                var excelList = [];
                excelList = excelList.concat([header]);
                
                partsList.forEach(item => {
                    excelList.push([
                        item.partOrderNo     || '', // 주문번호
                        item.hang            || '', // 항목
                        item.orderPartNo     || '', // 주문품번
                        item.supplyPartNo    || '', // 공급품번
                        item.partName        || '', // 품명
                        item.quantity        || '', // 요청수량
                        item.unit            || '', // 단위
                        item.unitPrice.toLocaleString()       || '', // 단가
                        item.orderItemAmount.toLocaleString() || '', // 금액
                        item.currency        || '', // 통화
                        item.machine         || '', // 기종
                        item.equipment       || ''  // 장비번호
                    ]);
                });
                console.log('excelList >> ' +JSON.stringify(excelList,null,4))
                var ws = XLSX.utils.aoa_to_sheet(excelList);
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 15 },  // 주문번호
                    { wch: 15 },  // 항목
                    { wch: 15 },  // 주문품번
                    { wch: 15 },  // 공급품번
                    { wch: 15 },  // 품명
                    { wch: 15 },  // 요청수량
                    { wch: 15 },  // 단위
                    { wch: 15 },  // 단가
                    { wch: 15 },  // 금액
                    { wch: 15 },  // 통화
                    { wch: 15 },  // 기종
                    { wch: 15 },  // 장비번호
                ];
    
                const range = XLSX.utils.decode_range(ws['!ref']);
                range.e.c = Math.max(range.e.c, header.length - 1); 
                // const headerLength = header.length;
                for (let R = range.s.r; R <= range.e.r; R++) {
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
                        console.log('range.e.c >>>>>> '+JSON.stringify(range.e.c,null,4))
                        if (R === 0 && C <= range.e.c) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 밝은 청록색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }
                    }
                }

                for (let R = 1; R <= 2; R++) {
                    for (let C = 10; C <= range.e.c; C++) {
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

    downloadExcel2: function (component, event, helper) {
        try {
            let orderType       = component.get('v.orderType');
            let customerOrderNo = component.get('v.customerOrderNo');
            let deliveryDate    = component.get('v.deliveryDate');
            let consolidatedShipping = component.get('v.consolidatedShipping');
            let shippingLocation = component.get('v.shippingLocation');
            
            let shippingInfo = component.get('v.shippingInfo');
            let totalPrice   = component.get('v.totalPrice');

            let orderAmount  = component.get('v.orderAmount');
            let pcoCurrecny  = component.get('v.pcoCurrecny');
            
            var detailPage = component.get('v.detailPage');


            var partsList = [];

            var enter = [];
            
            var mainH = ['주문 유형', orderType, '고객주문번호', customerOrderNo, '요청배송일자', deliveryDate, '일괄배송여부', consolidatedShipping];
            var mainH2 = ['배송처', shippingLocation.shippingAddress, '수신자', shippingLocation.partManager, '전화번호', shippingLocation.partManagerMP];

            var shippingInfoHeader = ['배송정보'];
            var shippingInfoH = ['선적조건', '배송경로', '지급조건', '운송경로1', '운송경로2'];
            var shippingInfoA = [shippingInfo.shippingTerm, shippingInfo.shippingRoute, shippingInfo.paymentTerm, shippingInfo.transportationTermOne, shippingInfo.transportationTermTwo];

            var partsPirce = [`Parts List(총액 : ${orderAmount} KRW)`]
            let partsListHeader = [];
            var sheetName = '';


            
            if(detailPage == '3Type') {
                partsList = component.get('v.partsList');
                partsListHeader = ['주문번호', '항목', '주문품번', '공급품번', '품명', '요청수랑', '단위', '단가', '금액', '통화', '기종', '장비번호'];
                sheetName = 'total detail information';
            } else if (detailPage == '4Type') {
                partsList = component.get('v.partsList2');
                partsListHeader = ['항목', '주문품번', '품명', '수량', '단위', '통화', '고객판매가', '할인판매가', '할인판매금액', '출고수량', '미결수량', '변경요청수량', '최종요청수량', '대리점재고', '상태'];
                sheetName = 'Order_History';
            } else {
                helper.toast('INFO', $A.get("{!$Label.c.MPI_E_MSG_2}")); //엑셀로 변경할 데이터가 없습니다.
                return;
            }

            if (partsList.length == 0) {
                helper.toast('INFO', $A.get("{!$Label.c.MPI_E_MSG_2}")); //엑셀로 변경할 데이터가 없습니다.
                return;
            } else {

                var wb = XLSX.utils.book_new();
                var excelList = [];
                excelList = excelList.concat([mainH]);
                excelList = excelList.concat([mainH2]);
                excelList = excelList.concat([enter]);
                excelList = excelList.concat([shippingInfoHeader]);
                excelList = excelList.concat([shippingInfoH]);
                excelList = excelList.concat([shippingInfoA]);
                excelList = excelList.concat([enter]);
                excelList = excelList.concat([partsPirce]);
                excelList = excelList.concat([partsListHeader]);
                
                partsList.forEach(item => {
                    excelList.push([
                        item.partOrderNo     || '', // 주문번호
                        item.hang            || '', // 항목
                        item.orderPartNo     || '', // 주문품번
                        item.supplyPartNo    || '', // 공급품번
                        item.partName        || '', // 품명
                        item.quantity        || '', // 요청수량
                        item.unit            || '', // 단위
                        item.unitPrice.toLocaleString()       || '', // 단가
                        item.orderItemAmount.toLocaleString() || '', // 금액
                        item.currency        || '', // 통화
                        item.machine         || '', // 기종
                        item.equipment       || ''  // 장비번호
                    ]);
                });
                console.log('excelList >> ' +JSON.stringify(excelList,null,4))
                var ws = XLSX.utils.aoa_to_sheet(excelList);
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 20 },  // 주문번호
                    { wch: 20 },  // 항목
                    { wch: 20 },  // 주문품번
                    { wch: 20 },  // 공급품번
                    { wch: 20 },  // 품명
                    { wch: 20 },  // 요청수량
                    { wch: 20 },  // 단위
                    { wch: 20 },  // 단가
                    { wch: 20 },  // 금액
                    { wch: 20 },  // 통화
                    { wch: 20 },  // 기종
                    { wch: 20 },  // 장비번호
                ];
    
                // R 이 행(range.e.r),  C 가 열(range.e.c)
                const range = XLSX.utils.decode_range(ws['!ref']);
                // main header
                for (let R = range.s.r; R <= 1; R++) {
                    for (let C = range.s.c; C <= 7; C++) {
                        const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
                        if (!ws[cellAddress]) {
                            ws[cellAddress] = { t: 's', v: '', s: {} };
                        }
            
                        if (ws[cellAddress] != undefined) {
                            ws[cellAddress].s = {
                                alignment: { horizontal: 'center', vertical: 'center' },
                                border: {
                                    top: { style: 'thin', color: { rgb: '000000' } },
                                    bottom: { style: 'thin', color: { rgb: '000000' } },
                                    left: { style: 'thin', color: { rgb: '000000' } },
                                    right: { style: 'thin', color: { rgb: '000000' } }
                                }
                            };
                        }

                        // // 첫 번째 행(헤더)에 스타일 추가
                        if (R >= 0 && R <= 1 && C == 0) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 배경색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 볼드
                        }

                        if (R >= 0 && R <= 1 && C == 2) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 배경색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 볼드
                        }

                        if (R >= 0 && R <= 1 && C == 4) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 배경색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 볼드
                        }

                        if (R == 0 && C == 6) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 배경색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 볼드
                        }
                    }
                }

                // shipping info
                for (let R = 4; R <= 5; R++) {
                    for (let C = range.s.c; C <= 4; C++) {
                        const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
                        if (!ws[cellAddress]) {
                            ws[cellAddress] = { t: 's', v: '', s: {} };
                        }
            
                        if (ws[cellAddress] != undefined) {
                            ws[cellAddress].s = {
                                alignment: { horizontal: 'center', vertical: 'center' },
                                border: {
                                    top: { style: 'thin', color: { rgb: '000000' } },
                                    bottom: { style: 'thin', color: { rgb: '000000' } },
                                    left: { style: 'thin', color: { rgb: '000000' } },
                                    right: { style: 'thin', color: { rgb: '000000' } }
                                }
                            };
                        }

                        // 첫 번째 행(헤더)에 스타일 추가
                        if (R === 4 && C >= 0 && C <= 4) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 연한 하늘색 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }
                    }
                }

                // parts List
                for (let R = 8; R <= range.e.r; R++) {
                    for (let C = range.s.c; C <= range.e.c; C++) {
                        const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
                        if (!ws[cellAddress]) {
                            ws[cellAddress] = { t: 's', v: '', s: {} };
                        }
            
                        if (ws[cellAddress] != undefined) {
                            ws[cellAddress].s = {
                                alignment: { horizontal: 'center', vertical: 'center' },
                                border: {
                                    top: { style: 'thin', color: { rgb: '000000' } },
                                    bottom: { style: 'thin', color: { rgb: '000000' } },
                                    left: { style: 'thin', color: { rgb: '000000' } },
                                    right: { style: 'thin', color: { rgb: '000000' } }
                                }
                            };
                        }

                        // 첫 번째 행(헤더)에 스타일 추가
                        if (R === 8 && C >= 0 && C <= 11) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 볼드
                        }
                    }
                }                
                // for (let R = 0; R <= 2; R++) {
                //     for (let C = 10; C <= 11; C++) {
                //         const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
                //         if (!ws[cellAddress]) {
                //             ws[cellAddress] = { t: 's', v: '', s: {} };
                //         }
            
                //         if (ws[cellAddress] != undefined) {
                //             ws[cellAddress].s = {
                //                 alignment: { horizontal: 'center', vertical: 'center' },
                //                 border: {
                //                     top: { style: 'thin', color: { rgb: '000000' } },
                //                     bottom: { style: 'thin', color: { rgb: '000000' } },
                //                     left: { style: 'thin', color: { rgb: '000000' } },
                //                     right: { style: 'thin', color: { rgb: '000000' } }
                //                 }
                //             };
                //         }

                        // // 첫 번째 행(헤더)에 스타일 추가
                        // if (R === 0 && C >= 0 && C <= 8) {
                        //     ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 연한 하늘색 배경
                        //     ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        // }

                        // if (C === 10 && R >= 0 && R <= 2) {
                        //     ws[cellAddress].s.fill = { fgColor: { rgb: '69ADFB' } }; // 연한 하늘색 배경
                        //     ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        // }
                //     }
                // }

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

    // 부품번호 검색 Modal 띄우기
    openSearchProductNumber : function(component, event, helper) {
        $A.createComponent("c:DN_SearchProductNumber",
            {
                    "type" : "부품번호"
            },
            function(content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("SearchProductNumber");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // 대체품 검색 Modal 띄우기
    openSearchReplaceProductNumber : function(component, event, helper) {
        var originPartsNumber = event.getSource().get('v.accesskey');
        console.log('originPartsNumber', originPartsNumber);
        $A.createComponent("c:DN_SearchProductNumber",
            {
                    "type" : "대체품",
                    "originPartsNumber" : originPartsNumber
            },
            function(content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("SearchProductNumber");
                    container.set("v.body", content);
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // Event로 값 가져오기
    handleCompEvent : function(component, event, helper) {
        try {
            var modalName = event.getParam("modalName");
            var actionName = event.getParam("actionName");
            var message = event.getParam("message");
            console.log('modalName', modalName);
            console.log('actionName', actionName);
            console.log('message', message);
    
            if(modalName === 'DN_SearchProductNumber') {
                var partBasicInfo = {
                    'partName' : message.Name,          // 품명
                    // 'inventoryQty' : message.inventoryQty,  // 재고 수량
                    // 'unitPrice' : message.unitPrice,  // 단가
                    // 'consumerPrice' : message.consumerPrice,  // 소비자 가격
                    // 'priceEffectiveDate' : message.priceEffectiveDate,  // 가격 적용일
                    // 'purchase' : message.purchase,  // 구매 리드 타임
                    // 'replacement' : message.replacement,  // 대체품
                    // 'standard' : message.standard,  // 규격
                    // 'unit' : message.unit,  // 단위
                    // 'managementInternationalBusinessTravel' : message.managementInternationalBusinessTravel,  // 해외출장관리
                    // 'sign' : message.sign,  // 성명
                    // 'memo' : message.memo  // 대리상 메모
                }
                component.set('v.partBasicInfo', partBasicInfo);
                component.set('v.searchBarPartNo', partBasicInfo.partName);
            }    
        } catch(e) {
            console.log('에러 : '+e.message)
        }
 
    },

    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        table1.scrollTo({ top: scrollY, left: 0, behavior: 'auto' });
    },
})