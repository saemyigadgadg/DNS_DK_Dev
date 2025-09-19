/**
 * @author            : Yu-Hyun Park
 * @description       : (포탈) 영업 > 채권 관리 > 주문별 수금 일정
 * @last modified on  : 05-15-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-05-31   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let userResult = result.r;
            
            component.set('v.dealerInfo', userResult);
        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.error('에러 발생 : ' + errors[0].message);
            }else{
                console.error('에러 발생 : 에러 확인 불가');
            }
        }))

        //증빙일 기본값 : today
        var today = new Date();
        var todayString = today.toISOString().split('T')[0];
        component.set("v.baseDate", todayString);
    },

    //검색
    doSearch: function(component, event, helper) {
        console.log('*** 검색 ***');
        var dealerInfo   = component.get('v.dealerInfo');
        var customerInfo = component.get('v.customerInfo');
        var orderNumber  = component.get('v.orderNoo');
        var baseDate     = component.get('v.baseDate');
        var isChecked    = component.get('v.isChecked');

        console.log('isChecked >> ' + isChecked);

        if(customerInfo == null) {
            helper.toast('ERROR', '고객을 선택해 주세요.');
            return;
        }
        var customerCode = customerInfo.customerCode;
        var requiredField = [customerCode, orderNumber, baseDate];

        if (requiredField.some(field => !field)) {
            helper.toast('ERROR', '필수값(고객 or 계약번호)이 입력되지 않았습니다.');
        } else {
            component.set("v.isLoading", true);
        helper.apexCall(component, 'GetOrderSchedule', {
            dli : dealerInfo,
            cc  : customerCode,
            oNo : orderNumber,
            rev : isChecked
        })
        .then($A.getCallback(function(result){
            let response = result.r;
            console.log('response no json:: ' +response);
            console.log('response json:: ' +JSON.stringify(response,null,4));
            if(JSON.stringify(response) === '{}') {
                helper.toast('SUCCESS','Data 가 없습니다.');
                component.set("v.isLoading", false);
                return
            } else {
                component.set('v.salesInfo', response);
                var complelte = response.isCollection == true ? '완료' :'미완료';
                component.set('v.isCollection', complelte);
                component.set('v.aar', response.aar);
    
                let totalAmount = 0;
                var contractDetail = response.ContractDetail;
                
                contractDetail.forEach(e=> {
                    totalAmount += Number(e.amount.replace(/,/g,'')) // 총액
                })
                component.set('v.totalAmount',totalAmount.toLocaleString('en-US'));
                component.set('v.contractDetail', contractDetail);
                component.set("v.isSearched", true);
                component.set("v.isLoading", false);
            }

        }))
        .catch($A.getCallback(function(errors) {
            component.set("v.isLoading", false);
            if(errors && errors[0] && errors[0].message) {
                console.log('errors :: '+JSON.stringify(errors[0].message,null,4));
            }else{
                console.log('미스매치로 인해 에러일 확률이 높습니다.');
            }
            component.set("v.isSearched", true);
        }))
        }
    },

    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function (component, event, helper) {
        try {
            var contractDetail = component.get('v.contractDetail');
            var totalAmount = component.get('v.totalAmount');
            
            if (contractDetail.length == 0) {
                helper.toast('SUCCESS', '엑셀로 변경할 데이터가 없습니다.');
                return;
            } else {
                var header = [
                    ['문서번호', '번호', '수금예정일', '지급조건', '금액', '확정금액', '문서일자', '년도', '반제전표', '일자', '입금일자', '계산 기준일자', '문서유형', '연체이자 발생액', '어음이자']
                ];
    
                var sheetName = '주문별 수금일정';
                var wb = XLSX.utils.book_new();
                var excelData = [];
                excelData = excelData.concat(header);
                
                contractDetail.forEach(item => {
                    excelData.push([
                        item.docNo,
                        item.itemNo,
                        item.colExpDt,
                        item.payTerm,
                        item.amount,
                        item.fixedAmt,
                        item.docDate,
                        item.soYear,
                        item.clearSlip,
                        item.soDate,
                        item.payDate,
                        item.calcRefDate,
                        item.docType,
                        item.odIntAmt,
                        item.noteInt,
                    ]);
                });
                excelData.push([null, null, null, 'Total', totalAmount, null, null, null, null, null, null, null, null, null, null])
                var ws = XLSX.utils.aoa_to_sheet(excelData);
    
                let totalRowIndex = contractDetail.length + 1;
                // 병합 설정
                ws['!merges'] = [
                    { s: { r: totalRowIndex, c: 0 }, e: { r: totalRowIndex, c: 2 } },
                    { s: { r: totalRowIndex, c: 5 }, e: { r: totalRowIndex, c: 14 } }, 
                ];
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 15 }, // 문서번호
                    { wch: 15 }, // 번호
                    { wch: 15 }, // 수금예정일
                    { wch: 15 }, // 지급조건
                    { wch: 15 }, // 금액
                    { wch: 15 }, // 확정금액
                    { wch: 15 }, // 문서일자
                    { wch: 15 }, // 년도
                    { wch: 15 }, // 반제전표
                    { wch: 15 }, // 일자
                    { wch: 15 }, // 입금일자
                    { wch: 15 }, // 계산 기준일자
                    { wch: 15 }, // 문서유형
                    { wch: 15 }, // 연체이자 발생액
                    { wch: 15 }  // 어음이자
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

                        // 첫 번째 행(헤더)에 스타일 추가
                        if (R === 0) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: 'ADD8E6' } }; // 연한 하늘색 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex && C === 3 ) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 딴 색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex && C === 4 ) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 딴 색
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
    
    deleteCustomer : function (component, event, helper) {
        component.set('v.customerInfo', null);
        component.set('v.isAccount', true);
    },  

    // 고객사명 모달 열기
    openCustomerList : function(component, event, helper) {
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_CustomerListModalforScheduleCollection",
                {},
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
                var container = component.find("CustomerListModal");
                container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);
    },

    deleteOrder : function(component, event, helper) {
        component.set('v.orderNoo', null);
        component.set('v.isOrder', true);
    },

    // 계약번호 모달 열기
    openSalesOrderList : function(component, event, helper) {
        component.set("v.isLoading", true);
        let customerInfo =component.get('v.customerInfo');
        $A.createComponent("c:DN_SalesOrderListModalforScheduleCollection",
            {
                'accountId' : customerInfo.id
            },
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
                var container = component.find("SalesOrderListModal");
                container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);
    },

    // 재조정 매출채권 모달 열기
    openAdvList : function(component, event, helper) {
        component.set("v.isLoading", true);
        var aar = component.get('v.aar');
        if(aar.length == 0) {
            helper.toast('INFO', '데이터가 없습니다.');
            component.set("v.isLoading", false);
        } else {
            console.log('재조정 매출채권 모달');
            $A.createComponent("c:DN_AdvReceivableListModal",
                { advList : aar },
                function(content, status, errorMessage) {
                    
                    if (status === "SUCCESS") {
                        var container = component.find("AdvReceivableListModal");
                        container.set("v.body", content);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    } 
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                    component.set("v.isLoading", false);
                }
            );
        }
    },

    // 모달
    handleCompEvent : function(component, event, helper) {
        var modalName = event.getParam("modalName");
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");
        if (modalName == 'DN_CustomerListModalforScheduleCollection') {
            component.set('v.customerInfo', message);
            if(message.id !=null) {
                component.set('v.isAccount', false);
            } 
        } else if (modalName == 'DN_SalesOrderListModalforScheduleCollection'){
            component.set('v.orderNoo', message.orderNumber)
            if(message.id !=null) {
                component.set('v.isOrder', false);
            }
        }
        console.log("message", message);
    },

    //증빙일 
    handleDateChange: function(component, event, helper) {
        var selectedDate = component.get("v.selectedDate");
        console.log("선택된 날짜: " + selectedDate);
    },

    //역 매출채권 포함
    handleCheckboxChange: function(component, event, helper) {
        var isChecked = component.get("v.isChecked");
        console.log("체크박스 상태: " + isChecked);
    },
})