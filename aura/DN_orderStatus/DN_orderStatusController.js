/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-12
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-02-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        const options = [
            {'label': $A.get("$Label.c.service_lbl_all"),'value': 'All'},
            {'label': $A.get("$Label.c.POS_DeliveryCompleted"),'value': 'Shipped'},
            {'label': $A.get("$Label.c.POS_Backorder"), 'value': 'Carryover'}
        ];
        component.set("v.shippingStateList", options);

        // 날짜 초기값 셋팅
        let eDay      = new Date();
        let sDay      = new Date();
        sDay.setDate(1);

        let endDate   = helper.dayCount(eDay);
        let startDate = helper.dayCount(sDay);

        component.set('v.endDate', endDate);
        component.set('v.startDate', startDate);

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            console.log('딜러 정보 가져오기');
            let response = result.r;
            console.log('딜러 정보 ::: ' +JSON.stringify(response,null,4));
            component.set('v.dealerInfo', response);

            if(response.userProfile == 'DNSA CS Parts_Partner'){
                component.set('v.orderType', 'YDOR');
                component.set('v.isDNSA', true);
            }
        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.log('에러 발생 :: ' +errors[0].message);
            }else {
                console.log('에러 발생... 왜 발생했지?');
            }
        }))
    },

    // 사용자 입력값 처리
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },
    
    // 검색 버튼
    doSearch : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.orderItems', []);
        var partOrderNo   = component.get('v.partOrderNo')
        , customerOrderNo = component.get('v.customerOrderNo')
        , orderType       = component.get('v.orderType')
        , startDate       = component.get('v.startDate')
        , endDate         = component.get('v.endDate')
        , partNo          = component.get('v.partNo')
        , shippingState   = component.get('v.shippingState')
        , dealerInfo      = component.get('v.dealerInfo')

        var result = helper.dayCounter(startDate, endDate);

        // 날짜 조건
        if (result > 180) {
            helper.toast('WARNING', $A.get("$Label.c.ORI_E_MSG_1"));//'검색 기간은 180일을 초과할 수 없습니다.');
            component.set('v.isLoading', false);
            return ;
        } else if (result < 0) {
            helper.toast('WARNING', $A.get("$Label.c.POS_E_MSG_2"));//'시작 일자가 종료 일자보다 클 수 없습니다.');
            component.set('v.isLoading', false);
            return ;
        }

        // 매개변수
        var orderStatusTerm = {
            partOrderNo     : partOrderNo,
            customerOrderNo : customerOrderNo,
            orderType       : orderType,
            startDate       : startDate,
            endDate         : endDate,
            partNo          : partNo,
            shippingState   : shippingState,
            dealerInfo      : dealerInfo
        };

        // 오더 상태 조회
        helper.apexCall(component, 'GetOrderStatus', {osi : orderStatusTerm})
        .then($A.getCallback(function(result) {
            let response = result.r;
            component.set('v.isLoading', false);
            console.log('조회 값 >> '+JSON.stringify(response,null,4))
            if(response.length > 0) {
                component.set('v.isSearched', true);
                response.forEach(e => {
                    // 이월 주문이 없고 배송이 전부 완료된 경우 납기조회 값이 false 임.
                    e.lookup = e.OrderQty__c != e.DeliveryQty__c ? $A.get("$Label.c.DNS_B_Search") : null;
                })
                component.set('v.orderItems', response);
            } else {
                component.set('v.isSearched', false);
                component.set('v.orderItems', []);
            }
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            if(errors && errors[0] && errors[0].message) {
                console.log('오더 상태 조회 : 에러 =>> '+errors[0].message);
            }else {
                console.log('오더 상태 조회 : 에러 =>> ????');
            }
        }))
    },

    //납기조회 모달 오픈
    openModal : function(component, event, helper) {
        console.log('납기조회 모달 오픈')
        const target = event.currentTarget;
        
        const partOrderNo   = target.getAttribute('data-orderNo');
        var startDate       = component.get('v.startDate')
            ,endDate        = component.get('v.endDate')
            ,dealerInfo     = component.get('v.dealerInfo');

        $A.createComponent("c:DN_DeliveryDateInquiryModal",
            {
                'type' : '납기조회',
                partOrderNo : partOrderNo,
                startDate   : startDate,
                endDate     : endDate,
                dealerInfo  : dealerInfo
            },
            function(content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("orderStatusDetailModal");
                    container.set("v.body", content);
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    handleCompEvent : function(component, event, helper) {
        var modalName = event.getParam('modalName');
        var message   = event.getParam('message');
        
        if(modalName === 'DN_DeliveryDateInquiryModal') {
            var doSearch = component.get('c.doSearch');
            $A.enqueueAction(doSearch);
        }
    },

    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function (component, event, helper) {
        try {
            var partsList = component.get('v.orderItems');
            console.log('partsList excel >> ' +JSON.stringify(partsList,null,4))
            if (partsList.length == 0) {
                helper.toast('SUCCESS', $A.get("$Label.c.MPI_E_MSG_2"));//'엑셀로 변경할 데이터가 없습니다.');
                return;
            } else {
                var header = [
                    ['고객주문번호', '주문번호', '품목수량', '주문유형', '납기조회', 'BLOCK', '수량', null, null, null, null, '선적조건', '통화'],
                    [null, null, null, null, null, null, '주문', '확정', '포장완료', '배송완료', '이월주문(미결오더)', null, null]
                ];
    
                var sheetName = '오더 상태';
                var wb = XLSX.utils.book_new();
                var excelData = [];
                excelData = excelData.concat(header);
                
                partsList.forEach(part => {
                    excelData.push([
                        part.CustomerOrderNo__c || '',
                        part.PartOrderNo__c || '',
                        part.TotalItems__c || '',
                        part.OrderType__c || '',
                        part.lookup || '',
                        part.BLOCK__c || 'N',
                        part.OrderQty__c || 0,
                        part.ConfirmedQty__c || 0,
                        part.PackingQty__c || 0,
                        part.DeliveryQty__c || 0,
                        part.CarryoverQty__c || 0,
                        part.ShippingTerm__c || '',
                        part.CurrencyIsoCode || ''
                    ]);
                });
                var ws = XLSX.utils.aoa_to_sheet(excelData);
    
                // 병합 설정
                ws['!merges'] = [
                    { s: { r: 0, c: 6 }, e: { r: 0, c: 10 } },
                    { s: { r: 0, c: 0 }, e: { r: 1, c: 0 } }, 
                    { s: { r: 0, c: 1 }, e: { r: 1, c: 1 } }, 
                    { s: { r: 0, c: 2 }, e: { r: 1, c: 2 } },
                    { s: { r: 0, c: 3 }, e: { r: 1, c: 3 } },
                    { s: { r: 0, c: 4 }, e: { r: 1, c: 4 } },
                    { s: { r: 0, c: 5 }, e: { r: 1, c: 5 } },
                    { s: { r: 0, c: 11 }, e: { r: 1, c: 11 } },
                    { s: { r: 0, c: 12 }, e: { r: 1, c: 12 } }
                ];
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 30 },
                    { wch: 15 },
                    { wch: 10 },
                    { wch: 19 },
                    { wch: 10 },
                    { wch: 10 },
                    { wch: 10 },
                    { wch: 10 },
                    { wch: 10 },
                    { wch: 10 },
                    { wch: 19 },
                    { wch: 15 },
                    { wch: 10 }
                ];
    
                
                const range = XLSX.utils.decode_range(ws['!ref']);
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
                                    top: { style: 'thin', color: { rgb: '000000' } },
                                    bottom: { style: 'thin', color: { rgb: '000000' } },
                                    left: { style: 'thin', color: { rgb: '000000' } },
                                    right: { style: 'thin', color: { rgb: '000000' } }
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

    allDownExcel : function(component, event, helper) {
        console.log('전체 모달 다운');
        var pon = component.get('v.partOrderNo') || '';
        var con = component.get('v.customerOrderNo') || '';
        var sDate = component.get('v.startDate');
        var eDate = component.get('v.endDate');
        var date = sDate + ' ~ ' + eDate;
        var ois = component.get('v.orderItems');

        console.log('pon :: ' +pon);
        console.log('con :: ' +con);
        console.log('date :: ' +date);
        console.log('ois :: ' +JSON.stringify(ois,null,4));

        if(ois.length == 0) {
            helper.toast('SUCCESS', $A.get("$Label.c.POS_E_MSG_3"));//'다운받을 엑셀 데이터가 없습니다.');
            return;
        }

        var header1 = [
            ['주문번호', pon, '고객주문번호', con, '주문날짜', date]
        ];
        console.log('1')
        var header2 = [
            ['고객주문번호', '주문번호', '주문날짜', '품목', '주문유형', '주문품번', '공급품번', '품명', '수량', null, null, null, null, '최초 공급 예정일', '변경 공급 예정일', '출고지시일', '발송지점'],
            [null, null, null, null, null, null, null, null, '주문', '확정', '포장완료', '배송완료', '이월주문(미결오더)', null, null, null, null]
        ]
        var sheetName = 'Order Status All Data';
        var wb = XLSX.utils.book_new();
        var excelData = [];
        excelData = excelData.concat(header1, header2);
        
        ois.forEach(part => {
            part.PurchaseOrderItems__r.forEach(item => {
                excelData.push([
                item.customerOrderNo    = part.CustomerOrderNo__c || '', // 고객주문번호
                item.partOrderNo        = part.PartOrderNo__c || '',     // 주문번호
                item.orderDate          = String(part.CreatedDate).split('T')[0].replace(/-/g, '.') || '',       // 주문날짜
                item.ItemNo__c          = item.ItemNo__c.replace(/^0+/, '') || '', // 품목
                item.orderType          = part.OrderType__c || '',       // 주문유형
                item.OrderPartNo__c     = item.OrderPartNo__c || '',     // 주문품번
                item.SupplyPartNo__c    = item.SupplyPartNo__c || '',    // 공급품번
                item.PartName__c        = item.PartName__c || '',        // 품명
                item.Quantity__c        = item.Quantity__c || 0,        // 수량 > 주문
                item.ConfirmedQty__c    = item.ConfirmedQty__c || 0,    // 수량 > 확정
                item.packingQty         = item.ConfirmedQty__c || 0,    // 수량 > 포장
                item.CompletedQty__c    = item.CompletedQty__c || 0,    // 수량 > 배송
                item.CarryoverQty       = (Number(item.Quantity__c || 0) - Number(item.CompletedQty__c || 0)) || 0, // 수량 > 이월
                
                item.ExpectedSupplyDate__c = item.ExpectedSupplyDate__c || '', // 최초 공급 예정일
                item.RevisedSupplyDate__c  = item.RevisedSupplyDate__c || '', // 변경 공급 예정일
                item.ShipmentDate__c       = item.ShipmentDate__c || '',       // 출고 지시일
                item.DepartureSite__c      = item.DepartureSite__c || '',      // 발송시점
                ]);
            });
        });
    
        console.log('excelData :: ' +JSON.stringify(excelData,null,4))
        if(!true) return;
        var ws = XLSX.utils.aoa_to_sheet(excelData);

        // 병합 설정
        ws['!merges'] = [
            { s: { r: 0, c: 6 }, e: { r: 0, c: 16 } },
            { s: { r: 1, c: 0 }, e: { r: 2, c: 0 } },
            { s: { r: 1, c: 1 }, e: { r: 2, c: 1 } },
            { s: { r: 1, c: 2 }, e: { r: 2, c: 2 } },
            { s: { r: 1, c: 3 }, e: { r: 2, c: 3 } },
            { s: { r: 1, c: 4 }, e: { r: 2, c: 4 } },
            { s: { r: 1, c: 5 }, e: { r: 2, c: 5 } },
            { s: { r: 1, c: 6 }, e: { r: 2, c: 6 } },
            { s: { r: 1, c: 7 }, e: { r: 2, c: 7 } },
            { s: { r: 1, c: 8 }, e: { r: 1, c: 12 } },
            { s: { r: 1, c: 13 }, e: { r: 2, c: 13 } },
            { s: { r: 1, c: 14 }, e: { r: 2, c: 14 } },
            { s: { r: 1, c: 15 }, e: { r: 2, c: 15 } },
            { s: { r: 1, c: 16 }, e: { r: 2, c: 16 } },
            
        ];

        // 열 너비 설정
        ws['!cols'] = [
            { wch: 30 }, // 고객주문번호
            { wch: 15 }, // 주문번호
            { wch: 15 }, // 주문날짜
            { wch: 7 }, // 품목
            { wch: 25 }, // 주문유형
            { wch: 20 },  // 주문품번
            { wch: 20 },  // 공급품번
            { wch: 30 },  // 품명
            { wch: 10 },  // 주문
            { wch: 10 }, // 확정
            { wch: 10 }, // 포장완료
            { wch: 10 }, // 배송완료
            { wch: 19 }, // 이월주문
            { wch: 17 }, // 최초
            { wch: 17 }, // 변경
            { wch: 15 }, // 출고
            { wch: 25 }, // 지점
        ];        

        const range = XLSX.utils.decode_range(ws['!ref']);
        const skipCells = ['G1', 'H1', 'I1', 'J1', 'K1', 'L1', 'M1', 'N1', 'O1', 'P1', 'Q1'];
        for (let R = range.s.r; R <= range.e.r; R++) {
            for (let C = range.s.c; C <= range.e.c; C++) {
                const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });

                if (skipCells.includes(cellAddress)) continue

                if (!ws[cellAddress]) { ws[cellAddress] = { t: 's', v: '', s: {} } }

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
})