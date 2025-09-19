/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-12
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-17-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        const options = [
            {'label': $A.get("$Label.c.DS_SelectAll"), 'value': ''},
            {'label': $A.get("$Label.c.DS_PendingShipment"), 'value': 'A'},
            {'label': $A.get("$Label.c.DS_DeliveryCompleted"), 'value': 'B'}
        ];
        component.set("v.orderOptions", options);
        

        // 날짜 초기값 셋팅
        let eDay      = new Date();
        let sDay      = new Date();
        sDay.setDate(1);

        let endDate   = helper.dayCount(eDay);
        let startDate = helper.dayCount(sDay);

        component.set('v.endDate', endDate);
        component.set('v.startDate', startDate);

        // 사용자 정보
        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('딜러 정보 :: ' +JSON.stringify(response,null,4));
            component.set('v.dealerInfo', response);
            component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.log('errors :: ' +errors[0].message);
            }else {
                console.log('errors :: 에러 사유 확인 불가');
            }
            helper.toast('ERROR', $A.get("$Label.c.BPI_E_MSG_5"));//'반복되면 관리자에게 문의 바랍니다.');
            component.set('v.isLoading', false);
        }))
    },

    // 입력
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },

    doSearch : function(component, event, helper) {
        component.set('v.isLoading', true);
        var startDate       = component.get('v.startDate');
        var endDate         = component.get('v.endDate');
        var deliveryNo      = component.get('v.deliveryNo');
        var orderNo         = component.get('v.orderNo');
        var shippingNo      = component.get('v.shippingNo');
        var customerOrderNo = component.get('v.customerOrderNo');
        var partNo          = component.get('v.partNo');
        var shippingState   = component.get('v.shippingState');
        var dealerInfo      = component.get('v.dealerInfo');

       //기간 계산 validation
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

       var searchTerms = {
        startDate       : startDate,
        endDate         : endDate,
        deliveryNo      : deliveryNo,
        orderNo         : orderNo,
        shippingNo      : shippingNo,
        customerOrderNo : customerOrderNo,
        partNo          : partNo,
        shippingState   : shippingState,
        dealerInfo      : dealerInfo
       }
       
       component.set('v.searchTerms', searchTerms);
       console.log('배송번호 조회 searchTerms :: ' + JSON.stringify(searchTerms,null,4));

       helper.apexCall(component, 'GetDeliveryStateInfo', {dli : dealerInfo, sts : searchTerms})
       .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('배송정보 조회 결과 response: '+JSON.stringify(response,null,4))
            let changeResponse = response.map(e => {
                e.departureDate = helper.formatDate(e.departureDate);
                e.arrivalDate   = helper.formatDate(e.arrivalDate);
                e.totalWeight   = e.totalWeight == '0.00' ? '0' : e.totalWeight;
                return e;
            });
            response = changeResponse;
            if(response.length > 0) {
                component.set('v.isSearched', true);
                component.set('v.resultList', response);
                
                var headOrder = [
                    'customerOrderNo'
                    ,'orderNo'
                    ,'deliveryStatus'
                    ,'deliveryNo'
                    ,'shippingInstructionNo'
                    ,'waybillNo'
                    ,'boxQty'
                    ,'totalWeight'
                    ,'unit'
                    ,'shippingType'
                    ,'deliverer'
                    ,'departureDate'
                    ,'arrivalDate'
                    ,'destination'
                ];

                var headMapping ={
                    'customerOrderNo'        : '고객주문번호'
                    ,'orderNo'               : '오더번호'
                    ,'deliveryStatus'        : '상태'
                    ,'deliveryNo'            : '배송번호'
                    ,'shippingInstructionNo' : '출하지시번호'
                    ,'waybillNo'             : '운송장번호'
                    ,'boxQty'                : '박스수량 '
                    ,'totalWeight'           : '총중량'
                    ,'unit'                  : '단위'
                    ,'shippingType'          : '출하유형'
                    ,'deliverer'             : '운송업자'
                    ,'departureDate'         : '출발일자'
                    ,'arrivalDate'           : '도착일자'
                    ,'destination'           : '도착지'
                }
                var transformedData = response.map(record => {
                    var newRecord = {};
                    headOrder.forEach(field => {
                        newRecord[headMapping[field]] = record[field] || ''; 
                    });
                    return newRecord;
                });
                component.set('v.excelData', transformedData);
                component.set('v.isLoading', false);
            }else {
                helper.toast('SUCCESS',$A.get("$Label.c.DS_E_MSG_1"));//'검색 결과가 없습니다. 조건을 수정 해주세요.');
                component.set('v.isSearched', false);
                component.set('v.resultList', []);
                component.set('v.isLoading', false);
            }
       }))
       .catch($A.getCallback(function(errors) {
        component.set('v.isLoading', false);
        helper.toast('ERROR',$A.get("$Label.c.BPI_E_MSG_5"));//'반복되면 관리자에게 문의 해주세요.');
        if(errors && errors[0] & errors[0].message) {
            console.log('errors :: ' +errors[0].message);
        }else {
            console.log('errors :: errors??');
        }
       }))
    },

    clearDeliveryNumber : function (component, event, helper) {
        // var deliveryNumber = component.find("deliveryNumber");
        // deliveryNumber.set("v.deliveryNumber", "");
        component.set('v.deliveryNo','');
    },

    // 배송 번호 모달
    openDeliveryDetail: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set("v.deliveryDetailModal", true);
        component.set('v.rowDetail', '');
        
        var rowIndex = event.target.getAttribute("data-deliveryno");
        var resultList = component.get('v.resultList')[rowIndex];

        var dealerInfo = component.get('v.dealerInfo');
        var searchTerms = {
            startDate : component.get('v.startDate'),
            endDate    : component.get('v.endDate'),
            deliveryNo  : resultList.deliveryNo,
            orderNo      : resultList.orderNo,
            customerOrderNo : resultList.customerOrderNo,
        }

        helper.apexCall(component, 'GetDeliveryDetail', {dli : dealerInfo, sts : searchTerms})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('배송번호에 따른 상세 정보 response :: ' + JSON.stringify(response,null,4));
            response.forEach(e => {
                e.unitPrice = Math.round(Number(e.unitPrice));
            }) ;
            // let changeResponse = response.map(e => {
            //     e.unitPrice = Math.floor(Number(e.unitPrice) / Number(e.quantity));
            //     return e;
            // });
            // response = changeResponse;
            console.log('상세정보 수정 값 ' + JSON.stringify(response,null,4));
            component.set('v.rowDetail', response);
            if(response.length > 0) {
                component.set('v.isDetailed', true)
                var headOrder = [
                    ,'deliveryNo'
                    ,'orderNo'
                    ,'customerOrderNo'
                    ,'orderPartNo'
                    ,'supplyPartNo'
                    ,'description'
                    ,'quantity'
                    ,'unitPrice'
                    ,'ddCurrency'
                    ,'sendTo'
                    ,'sendTo2'
                ];

                var headMapping = {
                    'deliveryNo'        : '탁송번호'
                    ,'orderNo'          : '오더번호'
                    ,'customerOrderNo'  : '고객주문번호'
                    ,'orderPartNo'      : '주문품번'
                    ,'supplyPartNo'     : '공급품번'
                    ,'description'      : '설명'
                    ,'quantity'         : '수량'
                    ,'unitPrice'        : '단위가격'
                    ,'ddCurrency'       : '통화'
                    ,'sendTo'           : 'Shipping Origin'
                    ,'sendTo2'          : '송부처2'
                }
                var transformedData = response.map(record => {
                    var newRecord = {};
                    headOrder.forEach(field => {
                        newRecord[headMapping[field]] = record[field] || ''; 
                    });
                    return newRecord;
                });
                component.set('v.detailExcelData', transformedData);
                component.set('v.isLoading', false);

            }else {
                component.set('v.isDetailed', false)
                component.set('v.isLoading', false);
            }
        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].messgae) {
                console.log('errors :: '+errors[0].messgae)
            }else {
                console.log('errors :: errors')
            }
        }))
    },

    // 가격정보 모달 cancle
    closeDeliveryDetail:function (component, event, helper) {
        component.set("v.deliveryDetailModal", false);
    },

    openPopup: function (component, event, helper) {
        const barcodeNo = event.target.getAttribute("data-barcode");
        
        const popupWidth = 650;
        const popupHeight = 800;
        const popupX = (window.screen.width / 2) - (popupWidth / 2);
        const popupY = (window.screen.height / 2) - (popupHeight / 2);
        
        // Construct the URL
        // const url = `https://kdexp.com/service/delivery/etc/delivery.do?barcode=${barcodeNo}`;
        const baseUrl = component.get("v.waybillUrl");
        const url = baseUrl + barcodeNo;
        
        // Open the popup window
        window.open(
            url, 
            "barcode_popup", 
            `scrollbars=yes,toolbar=no,location=no,resizable=yes,status=yes,menubar=no,width=${popupWidth},height=${popupHeight},left=${popupX},top=${popupY}`
        );
    }
})