/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-12
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-19-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit:function(component, event, helper) {

        const options = [
            { label: 'All', value: '' },
            { label: $A.get("$Label.c.PES_InProgress"), value: 'Q' },
            { label: $A.get("$Label.c.PES_Accepted"),  value: 'A' },
            { label: $A.get("$Label.c.PES_Rejected"),  value: 'R' }
        ];
        component.set("v.statusOption", options);

        
        let startDate = new Date();
        let endDate   = new Date();

        startDate.setDate(startDate.getDate() - 30);

        startDate = helper.dayCount(startDate);
        endDate   = helper.dayCount(endDate);
        
        component.set('v.startDate', startDate);
        component.set('v.endDate', endDate);

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result){
            let response = result.r;
            component.set('v.dealerInfo', response);
        }))
        .catch($A.getCallback(function(error){
            console.error('ERROR >> ' +error);
        }))
    },

    // 두비즈 기능 없는 거라 주석 처리함.
    doEnter : function(component, event, helper) {
        let enter = event.keyCode;
        // if(enter == 13) {
        //     let search = component.get('c.doSearch');
        //     $A.enqueueAction(search);
        // }
    },

    // 검색 버튼
    doSearch: function(component, event, helper) {
        component.set('v.isLoading', true);

        let startDate = component.get('v.startDate');
        let endDate   = component.get('v.endDate');
        let poNo      = component.get('v.poNo'); 
        let peNo      = component.get('v.peNo');
        let status    = component.get('v.status');

        let dealerInfo = component.get('v.dealerInfo');

        let param = {
            startDate : startDate.replace(/-/g,''),
            endDate   : endDate.replace(/-/g,''),
            poNo      : poNo.trim(),
            peNo      : peNo.trim(),
            pageNo    : null,
            status    : status
        }

        component.set('v.searchSet', param);

        console.log('param >>> '+JSON.stringify(param,null,4));

        helper.apexCall(component,'GetStatusList', {
            dli : dealerInfo,
            param : param,
        })
        .then($A.getCallback(function(result) {
            let response = result.r;
            let line = response.line;
            let list = response.list;

            console.log('line >> ' +JSON.stringify(line,null,4))
            console.log('list >> ' +JSON.stringify(list,null,4))

            if(peNo.trim() != '') {
                list = list.filter(e => e.peNo == peNo.trim());
                console.log('list >> ' +JSON.stringify(list,null,4))    
            }

            if(poNo.trim() != '') {
                list = list.filter(e => e.poNo == poNo.trim());
                console.log('list >> ' +JSON.stringify(list,null,4))    
            }

            component.set('v.statusList', list);
            component.set('v.line', line);

            if(list.length > 0) {
                try {
                    component.set('v.isStatus', true);
                    var dividePageCount = component.get('v.dividePageCount'); // Page당 보여주고 싶은 갯수
                    var totalPage = Math.ceil(list.length / dividePageCount);

                    var pageList = [];
                    var pageAllCountList = [];
                    var pageCountList = [];

                    for (let i = 0; i < totalPage; i++) {
                        if (pageCountList.length == 10) {
                            pageAllCountList.push(pageCountList);
                            pageCountList = [];
                        }
                        pageCountList.push(i);
                        var objList = list.slice(i * dividePageCount, (i + 1) * dividePageCount);
                        pageList.push(objList);
                    }

                    pageAllCountList.push(pageCountList);

                    component.set('v.pageAllCountList', pageAllCountList); // 2중배열 형태로 페이지 나열을 위한 List [[0 ~ 9], [10 ~ 19], ... , [나머지]]
                    component.set('v.pageCountList', pageAllCountList[0]); // 페이지 나열을 위한 List
                    component.set('v.pageList', pageList); // 2중배열의 형태로 [[1Page의 20개], [2Page의 20개], ... , [마지막 Page의 ?개]]
                    component.set('v.allResultCount', list.length); // 인터페이스로 가지고 온 총 갯수
                    component.set('v.resultList', list); // 인터페이스로 가지고 온 전체 List
                    component.set('v.totalPage', totalPage); // 인터페이스로 가지고 온 List의 총 Page 갯수
                    component.set('v.statusList', pageList[0]); // 1Page에서 보여줄 iteration할 List
                    component.set('v.currentPage', 1); // 첫 번째 페이지로 설정

                    console.log('pageList[0]>>>' +JSON.stringify(pageList));
                    component.set('v.excelData', helper.deepCopy(pageList[0]));

                    var currentUrl = new URL(window.location.href);
                    currentUrl.searchParams.set('currentPage', 1);
                    window.history.pushState({}, '', currentUrl.toString());
                    // // 테이블 밑에 합계를 넣기 위한 로직
                    // var itemQuantitySum = 0;
                    // var purchaseAmountSum = 0;
                    // pageList[0].forEach(function (obj) {
                    //     itemQuantitySum += Number(obj.KWMENG);
                    //     purchaseAmountSum += Number(obj.DMBTR);
                    // });

                    // component.set('v.itemQuantitySum', itemQuantitySum); // 1Page의 갯수 총합
                    // component.set('v.purchaseAmountSum', purchaseAmountSum); // 1Page의 가격 총합
                } catch (error) {
                    console.log('Error', error);
                }
            }else {
                helper.toast('INFO',$A.get("$Label.c.PES_E_MSG_1"));//'데이터가 없습니다.');
                component.set('v.isStatus', false);
            }
            component.set('v.isLoading', false);            
        }))
        .catch($A.getCallback(function(error) {
            component.set('v.isLoading', false);
            helper.toast('ERROR',$A.get("$Label.c.PES_E_MSG_2"));//'관리자에게 문의 바랍니다.');
            console.error('ERROR >> '+error);
        }))
    },

    handleChangePage: function (component, event, helper) {
        // 페이지 이동
        try {
            var pageCountListIndex = component.get('v.pageCountListIndex'); // pageCountList의 Index
            var pageAllCountList = component.get('v.pageAllCountList'); // 2중 배열
            var changePage = Number(event.target.value); // 바뀔 Page번호
            var name = event.target.name; // 바뀔 Page번호
            var pageList = component.get('v.pageList'); // 2중 배열

            if (name == 'first') {
                changePage = 1;
                pageCountListIndex = 0;
            } else if (name == 'previous') {
                pageCountListIndex--;
                if (pageCountListIndex < 0) {
                    pageCountListIndex = 0;
                    changePage = pageAllCountList[pageCountListIndex][0] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                }
            } else if (name == 'next') {
                pageCountListIndex++;
                if (pageCountListIndex >= pageAllCountList.length) {
                    pageCountListIndex = pageAllCountList.length - 1;
                    changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][0] + 1;
                }
            } else if (name == 'last') {
                changePage = pageList.length;
                pageCountListIndex = pageAllCountList.length - 1;
            }

            component.set('v.currentPage', changePage); // 바뀔 Page번호
            component.set('v.pageCountListIndex', pageCountListIndex); // 바뀔 pageCountList의 Index
            component.set('v.pageCountList', pageAllCountList[pageCountListIndex]); // 바뀔 pageCountList
            component.set('v.statusList', pageList[changePage - 1]); // 바뀔 Page에 해당하는 iteration할 List

            console.log('pageCountListIndex >>>>> '+pageCountListIndex);
            
            component.set('v.excelData', helper.deepCopy(pageList[changePage - 1]));

            // // 테이블 합계
            // var itemQuantitySum = 0;
            // var purchaseAmountSum = 0;
            // pageList[changePage - 1].forEach(function (obj) {
            //     itemQuantitySum += Number(obj.KWMENG);
            //     purchaseAmountSum += Number(obj.DMBTR);
            // });

            // component.set('v.itemQuantitySum', itemQuantitySum); // 바뀔 Page의 갯수 총합
            // component.set('v.purchaseAmountSum', purchaseAmountSum); // 바뀔 Page의 가격 총합

        } catch (error) {
            console.log('Error', JSON.stringify(error));
        }

    },
    
    openNo : function(component, event, helper) {
        component.set('v.isLoading', true);
        var peNo = event.target.dataset.peno;
        console.log('peNo>> '+peNo);
        const navPriceDetailView = component.find("navPriceDetailView");
        var pageMoveUrl = component.get('v.pageMoveUrl');
        const page = {
            type: "standard__webPage",
            attributes: {
                url: pageMoveUrl + encodeURIComponent(peNo),
            }
        };
        navPriceDetailView.navigate(page);
        component.set('v.isLoading', false);
    },

    //프린트 모달 close
    modalCancel : function (component, event, helper) {
        component.set("v.pdfModalOpen", false);
    },

    //프린트 모달 open
    openPrintPDF: function(component, event, helper) {
        let statusList = component.get('v.statusList');
        console.log('statusList >>> ' + JSON.stringify(statusList,null,4));
        if(statusList.length == 0) {
            helper.toast('INFO',$A.get("$Label.c.PES_E_MSG_3"));//"프린트할 데이터가 없습니다.");
            return;
        }

        let pdfUrl = component.get('v.pdfUrl');
        let searchSet = component.get('v.searchSet');

        let sDate  = searchSet.startDate;
        let eDate  = searchSet.endDate;
        let pon    = searchSet.poNo;
        let pen    = searchSet.peNo;
        let page   = component.get('v.currentPage');
        let status = searchSet.status;

        if (pon.trim() !== '' || pen.trim() !== '') {
            page = '';
        }        
        
        component.set('v.pdfUrl', `${pdfUrl}?sDate=${sDate}&eDate=${eDate}&pon=${pon}&pen=${pen}&page=${page}&status=${status}`);        
        component.set("v.pdfModalOpen", true);
    },

    // 엑셀 다운로드
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function (component, event, helper) {
        try {
            let partsList2 = component.get('v.excelData');
            let line = component.get('v.allResultCount');
            let currentPage = component.get('v.currentPage');
            let totalPage = component.get('v.totalPage');
            
            console.log('excel down >> '+JSON.stringify(partsList2,null,4))
            
            if (partsList2.length == 0) {
                helper.toast('INFO', $A.get("$Label.c.MPI_E_MSG_2"));//'엑셀로 변경할 데이터가 없습니다.');
                return;
            } else {
                let idx = 1;
                partsList2.forEach(e => {
                    e.number = idx;
                    e.icon = null;
                    e.status = e.status == 'Q' ? '확인중' : e.status == 'A' ? '승인' : '거절';
                    idx++;
                });
                
                var header = [
                    ['No', '작업상태', 'Remark', '거절사유', 'Inquiry PO No', 'PE Inquiry No', '생성일', '기종', '장비번호' , null, '총 레코드', line]
                ];
                let list2 = [
                    [null, null, null, null, null, null, null, null, null ]
                ]

                var sheetName = '진행 상태 조회';
                var wb = XLSX.utils.book_new();
                var excelList = [];
                excelList = excelList.concat(header);
                
                partsList2.forEach(item => {
                    excelList.push([
                        item.number,
                        // item.icon,
                        item.status,
                        item.remark,
                        item.rejectReason,
                        item.poNo,
                        item.peNo,
                        item.creationDate,
                        item.equipmentName,
                        item.equipmentNo,
                    ]);
                });

                console.log('excelList 내용 >> ' +JSON.stringify(excelList,null,4))
                console.log('excelList 길이 >> ' +excelList.length);
                excelList[1].push(...[null, '현재 레코드', partsList2.length]);

                if(excelList.length == 2) {
                    excelList = excelList.concat(list2);
                }
                excelList[2].push(...[null, '현재 페이지', `${currentPage} / ${totalPage}`]);

                var ws = XLSX.utils.aoa_to_sheet(excelList);
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 15 }, // No
                    // { wch: 15 }, // 상태
                    { wch: 15 }, // 작업상태
                    { wch: 15 }, // Remark
                    { wch: 15 }, // 거절 사유
                    { wch: 15 }, // PoNo
                    { wch: 15 }, // PeNo
                    { wch: 15 }, // 생성일
                    { wch: 15 }, // 기종
                    { wch: 15 }, // 장비번호
                    { wch: 1 }, // 빈 공간
                    { wch: 15 }, // 총 레코드
                    { wch: 15 }, // 현재 레코드
                ];
    
                const range = XLSX.utils.decode_range(ws['!ref']);
                for (let R = range.s.r; R <= range.e.r; R++) {

                    // 1열(A열, Column 0)의 셀 주소 가져오기
                    const firstCellAddress = XLSX.utils.encode_cell({ r: R, c: 0 });

                    // 1열 값이 비어 있으면 해당 행을 건너뜀
                    if (!ws[firstCellAddress] || !ws[firstCellAddress].v) {
                        continue; // 해당 행을 넘김
                    }

                    // for (let C = range.s.c; C <= range.e.c; C++) {
                    for (let C = range.s.c; C <= 8; C++) {
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
                        if (R === 0 && C >= 0 && C <= 8) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 연한 하늘색 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }
                    }
                }

                for (let R = 0; R <= 2; R++) {
                    for (let C = 10; C <= 11; C++) {
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
                        if (R === 0 && C >= 0 && C <= 8) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '3CFFD3' } }; // 연한 하늘색 배경
                            ws[cellAddress].s.font = { bold: true, color: { rgb: "000000" } }; // 검정색 볼드
                        }

                        if (C === 10 && R >= 0 && R <= 2) {
                            ws[cellAddress].s.fill = { fgColor: { rgb: '69ADFB' } }; // 연한 하늘색 배경
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
    }
    
})