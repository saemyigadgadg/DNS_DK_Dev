/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 02-25-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-07-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var action = component.get('c.GetUserInfo');
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === 'SUCCESS') {
                var userResult = response.getReturnValue();
                component.set('v.userInfo', userResult);
            }else if(status === 'ERROR') {
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message) {
                    console.log('실패 사유: ' + errors[0].message);
                }else {
                    console.log('알수없는 오류가 발생했습니다.');
                }
            }
        })
        $A.enqueueAction(action);
    },

    doSearch : function(component, event, helper) {
        component.set("v.isLoading", true)

        var dealerInfo = component.get('v.userInfo');
        var action = component.get('c.GetApList');
        action.setParams({dli : dealerInfo});
        action.setCallback(this, function(response) {
            let status = response.getState();
            if(status === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.resultList', result.T_RECEIPT);

                var resultList = component.get('v.resultList');
                var wrbtrSum = 0;
                var wrbtrOverdueSum = 0;
                var wrshbSum = 0;

                resultList.forEach(function (result) {
                    wrbtrSum += parseInt(result.WRBTR);
                    wrbtrOverdueSum += parseInt(result.WRBTR_OVERDUE);
                    wrshbSum += parseInt(result.WRSHB);
                });
                
                component.set('v.wrbtrSum', wrbtrSum);
                component.set('v.wrbtrOverdueSum', wrbtrOverdueSum);
                component.set('v.wrshbSum', wrshbSum);
            }
            else if(status === 'ERROR') {
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message) {
                    console.log('실패 사유: ' + errors[0].message);
                }else {
                    console.log('알수없는 오류가 발생했습니다.');
                }
            }
        component.set("v.isLoading", false);
        })
        $A.enqueueAction(action);
    },

    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function (component, event, helper) {
        try {
            let resultList      = component.get('v.resultList');
            let wrbtrSum        = component.get('v.wrbtrSum');
            let wrbtrOverdueSum = component.get('v.wrbtrOverdueSum');
            let wrshbSum        = component.get('v.wrshbSum');

            wrbtrSum = wrbtrSum.toLocaleString();
            wrshbSum = wrshbSum.toLocaleString();
            
            if (resultList.length == 0) {
                helper.toast('SUCCESS', '엑셀로 변경할 데이터가 없습니다.');
                return;
            } else {
                var header = [
                    ['만기일', '매입금액', '연체이자', '부분합계']
                ];
    
                var sheetName = '주문별 수금일정';
                var wb = XLSX.utils.book_new();
                var excelData = [];
                excelData = excelData.concat(header);

                resultList.forEach(e => {
                    e.maturityDate = e.FAEDT,
                    e.purchaseAMT  = Number(e.WRBTR).toLocaleString(),
                    e.overDue      = e.WRBTR_OVERDUE == 0.00 ? 0 : e.WRBTR_OVERDUE,
                    e.subTotal     = Number(e.WRSHB).toLocaleString()
                })
                
                resultList.forEach(item => {
                    excelData.push([
                        item.maturityDate,
                        item.purchaseAMT,
                        item.overDue,
                        item.subTotal
                    ]);
                });
                excelData.push([null, wrbtrSum, wrbtrOverdueSum, wrshbSum])
                var ws = XLSX.utils.aoa_to_sheet(excelData);
    
                let totalRowIndex = resultList.length + 1;
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 15 }, // 만기일
                    { wch: 15 }, // 매입금액
                    { wch: 15 }, // 연체이자
                    { wch: 15 }, // 부분합계
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
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 연한 하늘색 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (R === totalRowIndex ) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: 'ADD8E6' } }; // 딴 색
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
})