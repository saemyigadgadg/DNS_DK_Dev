/**
 * @description       : (포탈) 부품주문 > 오더 상태 >> 납기조회 모달
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-12
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-15-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({  
    doInit : function(component, event, helper) {
      component.set('v.isLoading', true);
      var partOrderNo = component.get('v.partOrderNo');
      var startDate   = component.get('v.startDate');
      var endDate     = component.get('v.endDate');

      const options = [
          {'label': '&nbsp;','value': 'false' },
          {'label': $A.get("$Label.c.DNS_F_Urgent"),'value': 'true' }
      ];
      component.set("v.UrgencyOptions", options);

      helper.apexCall(component, 'GetUserInfo', {})
      .then($A.getCallback(function(result) {
        let response = result.r;
        component.set('v.dealerInfo', response);

        var dealerInfo  = component.get('v.dealerInfo');
        var partList    = [partOrderNo];

        return helper.apexCall(component, 'GetOrderStatusDetail', {
          pon   : partList,
          sDate : startDate,
          eDate : endDate,
          dli   : dealerInfo
        })
      }))
      .then($A.getCallback(function(result) {
        let response = result.r;
        console.log('오더 상세 조회 값 >> ' +JSON.stringify(response,null,4));
        component.set('v.tList', response);
        var tList = component.get('v.tList');
        console.log('GetOrderStatusDetail 013 >> '+JSON.stringify(tList,null,4));
        // return helper.apexCall(component, 'GetPoiList', {pon : partOrderNo, poi : tList})
        const mergedMap = new Map();

        response.forEach(item => {
            let key = item.itemNo;
            if (!mergedMap.has(key)) {
                mergedMap.set(key, {
                  customerOrderNo: item.customerOrderNo,
                  estimatedSupplyDate: item.estimatedSupplyDate,
                  itemNo: item.itemNo,
                  // itemSpr: item.itemSpr,
                  orderDate: item.orderDate,
                  orderQty: item.orderQty,
                  partName: item.partName,
                  partOrderNo: item.partOrderNo,
                  shippingDate: item.shippingDate,
                  shippingSpot: item.shippingSpot,
                  stayQty: item.stayQty,
                  supplyPartNo: item.supplyPartNo,
                  urgency: item.urgency,
                  completeQty: parseInt(item.completeQty),
                  confirmQty: parseInt(item.confirmQty),
                  packingQty: parseInt(item.packingQty),
                  netPrice: parseInt(item.netPrice),
                  netCurrency: item.netCurrency
                });
            } else {
                const existing = mergedMap.get(key);
                existing.completeQty += parseInt(item.completeQty);
                existing.confirmQty += parseInt(item.confirmQty);
                existing.packingQty += parseInt(item.packingQty);
            }
        });

        const mergedList = [...mergedMap.values()];
        console.log('mergedList >> ' +JSON.stringify(mergedList,null,4));
        
        return helper.apexCall(component, 'GetPoiList', {pon : partOrderNo, poi : mergedList})
      }))
      .then($A.getCallback(function(result){
        console.log('POI 완료');
        let response = result.r;
        console.log('GetPoiList >> '+JSON.stringify(response,null,4));
        component.set('v.poiList', response);
        component.set('v.isLoading', false);
      }))
      .catch($A.getCallback(function(error) {
        component.set('v.isLoading', false);
        if(error && error[0] && error[0].message) {
            console.log('errors :: ' +error[0].message);
        }else {
            console.log('errors ㅇㅅㅇ???');
        }
      }))
    },

    doSave : function(component, event, helper) {
      console.log('save function');
      var pon = component.get('v.partOrderNo');
      var poiList = component.get('v.poiList');
      var itemsList = component.get('v.tList');
      var dealerInfo = component.get('v.dealerInfo');
      itemsList.forEach(e => {
        poiList.forEach(f => {
          if(e.itemNo === f.ItemNo__c) {
            f.Urgency__c = e.urgency == 'true';
          }
        })
      })
      if(!true) return;

      var action = component.get('c.ChangeUrgency');
      action.setParams({pon : pon, poi : poiList, dli : dealerInfo});
      action.setCallback(this, function(response) {
          var status = response.getState();
          if(status === 'SUCCESS') {
              helper.toast('SUCCESS',$A.get("$Label.c.DDM_S_MSG_1"));//'저장 성공');
              component.set('v.isLoading', false);
              component.set('v.orderStatusDetailModal', false);
              
              var close = component.get('c.ModalCancel');
              $A.enqueueAction(close);
              
          }else if(status === 'ERROR') {
              var errors = response.getError();
              component.set('v.isLoading', false);
              component.set('v.orderStatusDetailModal', false);
              helper.toast('WARNING', $A.get("$Label.c.BPI_E_MSG_5"));//'반복될 경우 관리자에게 문의 바랍니다.');
              if(errors && errors[0] && errors[0].message) {
                  console.log('에러 내용 :: ' +errors[0].message);
              } else{
                  console.log('무슨 에러인가요?? ㅇㅅㅇ???')
              }
          }
      })
      $A.enqueueAction(action)
  },
  
  // 사용자 입력값 처리
  handleChange : function(component, event, helper) {
    helper.updateFieldValue(component, event);
  },
  
  // 기종 모달 취소
  ModalCancel: function (component, event, helper) {

    let message = $A.get("$Label.c.DDM_E_MSG_1");//'납기조회 모달 닫음.';
    var cmpEvent = component.getEvent("cmpEvent")
    cmpEvent.setParams({
      "modalName"  : "DN_DeliveryDateInquiryModal",
      "actionName" : "Close",
      "message"    : message
    })

    cmpEvent.fire();

    helper.closedModal(component);

  },

  downModalExcel : function(component, event, helper) {
    console.log('모달 엑셀 다운');
    var pon = component.get('v.partOrderNo');
    var scn = component.get('v.tList')[0].customerOrderNo;
    var sod = component.get('v.tList')[0].orderDate;
    var isl = component.get('v.tList');
    var index = 1;
    isl.forEach((e) => {
        e.number = index; // 번호는 1부터 시작
        index++
    });
    console.log('isl :: ' +JSON.stringify(isl,null,4))
    var header1 = [
        ['주문번호', pon, '고객주문번호', scn, '주문날짜', sod],
    ];
    var header2 = [
        ['번호', '품목', '공급품번', '품명', '긴급도', '수량', null, null, null, '예상공급일', '변경공급예정일', '출고일', '발송지점'],
        [null, null, null, null, null, '주문', '확정', '대기', '완료', null, null, null, null]
    ]
    var sheetName = 'Order Status Detail';
    var wb = XLSX.utils.book_new();
    var excelData = [];
    excelData = excelData.concat(header1, header2);

    isl.forEach(part => {
        excelData.push([
            part.number, // 번호
            part.itemNo, // 항목
            part.supplyPartNo, // 공급품번
            part.partName, // 품명
            part.urgency = part.urgency == "true" ? '긴급' : '', // 긴급도
            part.orderQty, // 주문
            part.confirmQty || '', // 확정
            part.stayQty || '', // 대기
            part.completeQty    || '', // 완료
            part.estimatedSupplyDate  || '', // 예상공급일
            part.changeSupplyDate    || '', // 변경공급일
            part.shippingDate   || '', // 출고일
            part.shippingSpot   || '', // 발송지점
        ]);
    });

    console.log('excelData :: ' +JSON.stringify(excelData,null,4))
    var ws = XLSX.utils.aoa_to_sheet(excelData);
    /* 
       cA  cB  cC  cD  cE  cF
    r1 A1  B1  C1  D1  E1  F1
    r2 A2  B2  C2  D2  E2  F2
    r3 A3  B3  C3  D3  E3  F3
    r4 A4  B4  C4  D4  E4  F4
    */
    ws['!merges'] = [
        { s: { r: 0, c: 6 }, e: { r: 0, c: 12 } }, // 번호
        { s: { r: 1, c: 0 }, e: { r: 2, c: 0 } }, // 번호
        { s: { r: 1, c: 1 }, e: { r: 2, c: 1 } }, // 품목
        { s: { r: 1, c: 2 }, e: { r: 2, c: 2 } }, // 공급품번
        { s: { r: 1, c: 3 }, e: { r: 2, c: 3 } }, // 품명
        { s: { r: 1, c: 4 }, e: { r: 2, c: 4 } }, // 긴급도
        { s: { r: 1, c: 5 }, e: { r: 1, c: 8 } }, // 수량
        { s: { r: 1, c: 9 }, e: { r: 2, c: 9 } }, // 예상 공급일
        { s: { r: 1, c: 10 }, e: { r: 2, c: 10 } }, // 변경 공급 예정일
        { s: { r: 1, c: 11 }, e: { r: 2, c: 11 } }, // 출고일
        { s: { r: 1, c: 12 }, e: { r: 2, c: 12 } }, // 발송지점
    ];

    // 열 너비 설정
    ws['!cols'] = [
        { wch: 15 }, // 번호
        { wch: 15 }, // 품목
        { wch: 15 }, // 공급품번
        { wch: 25 }, // 품명
        { wch: 15 }, // 긴급도
        { wch: 15 },  // 주문
        { wch: 15 },  // 확정
        { wch: 15 },  // 대기
        { wch: 15 },  // 완료
        { wch: 15 }, // 예상
        { wch: 15 }, // 변경
        { wch: 15 }, // 출고일
        { wch: 25 }, // 지점
    ];     

    const range = XLSX.utils.decode_range(ws['!ref']);
    const skipCells = ['G1', 'H1', 'I1', 'J1', 'K1', 'L1', 'M1'];

    for (let R = range.s.r; R <= range.e.r; R++) {
        for (let C = range.s.c; C <= range.e.c; C++) {
            const cellAddress = XLSX.utils.encode_cell({ r: R, c: C });

            if (skipCells.includes(cellAddress)) {
              continue;
            }

            if (!ws[cellAddress]) {
              ws[cellAddress] = { t: 's', v: '', s: {} };
            }

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

},

})