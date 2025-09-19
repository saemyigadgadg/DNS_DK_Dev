/**
 * @author            : Yu-Hyun Park
 * @description       : (포탈) 영업 > 채권관리 > 기간별 수금실적
 * @last modified on  : 03-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-04   yuhyun.park@sbtglobal.com   Initial Version
 * 1.1   2024-11-21   youjin.shim@sbtglobal.com   검색조건 변경
**/
({
    doInit : function(component, event, helper) {
        let eDay      = new Date();
        let sDay      = new Date();
        sDay.setDate(eDay.getDate() - 90);

        let endDate   = helper.dayCount(eDay);
        let startDate = helper.dayCount(sDay);

        component.set('v.endDate', endDate);
        component.set('v.startDate', startDate);

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let userResult = result.r;

            console.log('check userInfo :: ' + JSON.stringify(userResult,null,4))
            component.set('v.dealerInfo', userResult);
        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.error('에러 발생 : ' + errors[0].message);
            }else{
                console.error('에러 발생 : 에러 확인 불가');
            }
        }))
    },

    //검색
    doSearch: function(component, event, helper) {
        component.set("v.isLoading", true);
        var customerInfo = component.get('v.customerInfo');
        var dealerInfo   = component.get('v.dealerInfo');
        var startDate    = component.get('v.startDate');
        var endDate      = component.get('v.endDate');
        var result       = helper.dayCounter(startDate, endDate);

        // 날짜 조건
        if (result > 90) {
            helper.toast('WARNING', '조회기간은 90일 제한입니다.');
            component.set('v.isLoading', false);
            return ;
        } else if (result < 0) {
            helper.toast('WARNING', '날짜가 유효하지 않습니다.');
            component.set('v.isLoading', false);
            return ;
        }

        var params = {
            startDate    : startDate.replace(/-/g, ''),
            endDate      : endDate.replace(/-/g, ''),
            customerCode : customerInfo.customerCode || ''
        }
        console.log('params :: ' +JSON.stringify(params,null,4));
        // if(true) return
        helper.apexCall(component, 'GetArInfo', {param : params, dli : dealerInfo})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('기간별수금실적 I/F 결과 :: ' +JSON.stringify(response,null,4));

            if(response.length > 0) {
                // 총합 
                var totalTotal    = 0;
                var totalAmount   = 0;
                var totalInterest = 0;

                //품목 수량, 주문금액 합
                response.forEach(function(item) {
                    item.saleDate    = item.saleDate.replace(/-/g,'.')    || ''; // 판매일
                    item.netDueDate  = item.netDueDate.replace(/-/g,'.')  || ''; // 수금예정일
                    item.issueDate   = item.issueDate.replace(/-/g,'.')   || ''; // 발행일
                    item.postingDate = item.postingDate.replace(/-/g,'.') || ''; // 반제일자

                    totalTotal     += Number(item.recTotal) || 0; 
                    totalAmount    += Number(item.recAmount)  || 0; 
                    totalInterest  += Number(item.overdueInterest) || 0; 
                });

                component.set('v.clearedARList', response);
                component.set("v.totalTotal", totalTotal);
                component.set("v.totalAmount" , totalAmount);
                component.set("v.totalInterest" , totalInterest);
                component.set("v.currenyKey", response[0].currenyKey);

                component.set('v.isLoading', false);
                component.set("v.isSearched", true);
            } else {
                component.set('v.clearedARList', '');
                component.set("v.isLoading", false);
                helper.toast('WARNING', '검색결과가 존재하지 않습니다.');
            }
            
        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                component.set("v.isLoading", false);
                helper.toast('ERROR', '에러가 발생했습니다. 반복될 경우 관리자에게 문의 부탁 드립니다.');
                console.error('발생 에러 : '+errors[0].message);
            }else {
                console.error('발생 에러 : 에러 메세지 확인 불가');
            }
        }))
    },

    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function (component, event, helper) {
        try {
            var clearedARList = component.get('v.clearedARList');
            var totalTotal    = component.get("v.totalTotal");
            var totalAmount   = component.get("v.totalAmount" );
            var totalInterest = component.get("v.totalInterest" );
            var currenyKey    = component.get("v.currenyKey");

            totalTotal    = totalTotal.toLocaleString();
            totalAmount   = totalAmount.toLocaleString();
            totalInterest = totalInterest.toLocaleString();
            
            if (clearedARList.length == 0) {
                helper.toast('SUCCESS', '엑셀로 변경할 데이터가 없습니다.');
                return;
            } else {
                var header = [
                    ['판매부서', '고객코드', '수금처', '대표자명', '실출하처', '판매일', '오더번호', '수금예정일', '발행일', '반제일자', '지급조건', '총액', '금액', '연체이자', '타입', '문서번호', '유저ID', '유저명', '통화']
                ];
                
                var sheetName = '기간별 수금실적';
                var wb = XLSX.utils.book_new();
                var excelData = [];
                excelData = excelData.concat(header);
                
                clearedARList.forEach(item => {
                    excelData.push([
                        item.salesOffice,  // 판매부서
                        item.customerCode, // 고객코드
                        item.customerName, // 수금처
                        item.ceoName,      // 대표자명
                        item.shipToParty,  // 실 출하처
                        item.saleDate    = item.saleDate.replace(/-/g,'.'),     // 판매일
                        item.orderNo,      // 오더번호
                        item.netDueDate  = item.netDueDate.replace(/-/g,'.'),   // 수금예정일
                        item.issueDate   = item.issueDate.replace(/-/g,'.'),    // 발행일
                        item.postingDate = item.postingDate.replace(/-/g,'.'),  // 반제일자
                        item.paymentTerm,  // 지급조건
                        item.recTotal  = Number(item.recTotal).toLocaleString(),   // 총액
                        item.recAmount = Number(item.recAmount).toLocaleString(),  // 금액
                        item.overdueInterest = item.overdueInterest.split('.')[0], // 연체이자
                        item.bondType,     // 타입
                        item.docNo,        // 문서번호
                        item.userId,       // 유저 ID
                        item.userName,     // 유저명
                        item.currenyKey,   // 통화
                    ]);
                });
                excelData.push([
                    null, null, null, null, null, null, null, null, null, null, 'Total', totalTotal, totalAmount, totalInterest, null, null, null, null, currenyKey
                ]);
                console.log('excelData >>> '+JSON.stringify(excelData,null,4))
                var ws = XLSX.utils.aoa_to_sheet(excelData);
    
                let totalRowIndex = clearedARList.length + 1;

                // 병합 설정
                ws['!merges'] = [
                    { s: { r: totalRowIndex, c: 0 }, e: { r: totalRowIndex, c: 8 } },
                    { s: { r: totalRowIndex, c: 14 }, e: { r: totalRowIndex, c: 17 } }, 
                ];
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 15 }, // 판매부서
                    { wch: 15 }, // 고객코드
                    { wch: 25 }, // 수금처
                    { wch: 15 }, // 대표자명
                    { wch: 25 }, // 실 출하처
                    { wch: 15 }, // 판매일
                    { wch: 15 }, // 오더번호
                    { wch: 15 }, // 수금예정일
                    { wch: 15 }, // 발행일
                    { wch: 15 }, // 지급조건
                    { wch: 15 }, // 총액
                    { wch: 15 }, // 금액
                    { wch: 15 }, // 연체이자
                    { wch: 15 }, // 타입
                    { wch: 15 }, // 문서번호
                    { wch: 15 }, // 유저 ID
                    { wch: 15 }, // 유저명
                    { wch: 15 }, // 통화
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
                                    top     : { style: 'thin', color: { rgb: '000000' } },
                                    bottom  : { style: 'thin', color: { rgb: '000000' } },
                                    left    : { style: 'thin', color: { rgb: '000000' } },
                                    right   : { style: 'thin', color: { rgb: '000000' } }
                                }
                            };
                        }

                        // 배경생 추가
                        if (R === 0) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: 'ADD8E6' } }; // 연한 하늘색 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex && C === 10 ) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 딴 색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex && C === 11 ) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 딴 색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex && C === 12 ) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 딴 색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex && C === 13 ) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 딴 색
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex && C === 18 ) {
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

    // 속성 이름과 값 매칭
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },

    //Local
    handleCheckboxChange: function(component, event, helper) {
        var isChecked = component.get("v.isChecked");
        console.log("체크박스 상태: " + isChecked);
    },
   
    // 고객 모달 열기 (From)
    openCustomerFromList : function(component, event, helper) {
        component.set("v.isLoading", true);
        
        var customerType = component.find("customerFrom").get("v.name");
        console.log(customerType, ' customerType');
        $A.createComponent("c:DN_CustomerListModalforScheduleCollection",
                {
                    "customerType" : customerType
                },
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

    // 고객 데이터 삭제
    clesrCustomerFrom : function(component, event, helper) {
        const fieldValue = component.get('v.customerInfo').customerName;
        if (!fieldValue) {
            helper.toast("WARNING", `저장된 고객값이 없습니다.`);
            return;
        }
        component.set('v.customerInfo', "");
    },

    // 모달
    handleCompEvent : function(component, event, helper) {
        var modalName = event.getParam("modalName");
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");

        if(modalName == 'DN_CustomerListModalforScheduleCollection') {
            message.customerCode = message.customerCode.padStart(10, "0");
            component.set('v.customerInfo', message);
            console.log(JSON.stringify(message,null,4));
        }
    },
})