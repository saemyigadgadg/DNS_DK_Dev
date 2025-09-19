/**
 * @description       : (포탈) 부품정보 > 멀티부품 정보조회
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-10
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-05-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        helper.addPartList(component, event, helper, 1);

        console.log('** 사용자 정보 조회 **');
        var action = component.get('c.GetUserInfo');
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === 'SUCCESS') {
                var userResult = response.getReturnValue();
                if(userResult.userProfile == 'DNS CS Parts_Partner') {
                    component.set('v.isProfile', true);
                    component.set('v.isCSUser', true);
                }
                if(userResult.userProfile == 'DNSA CS Parts_Partner') {
                    component.set('v.isCSUser', true);
                }
                component.set('v.userInfo', userResult); 

            }else if(status === 'ERROR') {
                var errors = response.getError();
                helper.toast('ERROR', $A.get("$Label.c.BPI_E_MSG_5"));//'반복되는 경우 관리자에게 문의 바랍니다.');
                if(errors && errors[0] && errors[0].message) {
                    console.error('실패 사유: ' + errors[0].message);
                }else {
                    console.error('알수없는 오류가 발생했습니다.');
                }
            }
        })
        $A.enqueueAction(action);
    },

    doSearch : function(component, event, helper) {
        console.log('** 부품 정보 조회 **');
        component.set('v.isLoading', true);
        component.set('v.excelUploadModal', false);
        var userInfo  = component.get('v.userInfo');
        var partsList = component.get('v.partsList');
        var excelData = component.get('v.excelData');
    
        // 부품 엑셀 업로드 시
        if (excelData.length > 0) {
            console.log('*excelData*');
            if (partsList.length >= excelData.length) {
                for (let i = 0; i < excelData.length; i++) {
                    partsList[i].orderPartNo = excelData[i].toUpperCase().replace(/\s+/g, ''); 
                }
            } else {
                var diff = (excelData.length - partsList.length);
                helper.addPartList(component, event, helper, diff);
    
                for (let i = 0; i < excelData.length; i++) {
                    partsList[i].orderPartNo = excelData[i].replace(/\s+/g, '');
                }
            }
            component.set('v.excelData', []);
        }
        
        // 부품 직접 입력 시
        var searchList = partsList.filter(e => e.orderPartNo && e.orderPartNo.replace(/\s+/g, '') !== ''); 
        let detailList = [];
    
        for (let part of searchList) {
            detailList.push(part.orderPartNo.replace(/\s+/g, '')); 
        }

        console.log('detailList>>>> '+JSON.stringify(detailList,null,4));
    
        if (detailList.length === 0) {
            helper.toast('WARNING', $A.get("$Label.c.MPI_E_MSG_1"));//'조회할 부품을 입력해 주세요.');
            component.set('v.isLoading', false);
            return;
        } else {
            helper.apexCall(component, 'SearchPartNo', {pn: detailList})
            .then($A.getCallback(function(result){
                let response = result.r;

                console.log('멀티 부품 결과 >> ' +JSON.stringify(response,null,4));

                if(response.length == 0) {
                    component.set('v.isLoading', false);
                    return Promise.reject({type:'NO_PRODUCT', message: $A.get("$Label.c.BPI_E_MSG_2")});//등록된 제품이 아닙니다.'}); 
                }

                let partList = [];
                response.forEach(e => {
                    partList.push(e.Name);
                })

                console.log('partList >> ' +JSON.stringify(partList,null,4));
                return helper.apexCall(component, 'MultiSearch', { dl: partList, ui: userInfo })
            }))
            .then($A.getCallback(function(result) {
                let response = result.r;
                let resultList = [];
                detailList = [];
                excelData = [];
                if (response.length > 0 && Array.isArray(response)) {
                    for (let item of response) {
                        var rList = {
                            orderPartNo         : item.partNo.replace(/\s+/g, ''), 
                            productName         : item.partName,
                            stockQuantity       : item.stockQuantity,
                            stockQuantity2      : item.stockQuantity2,
                            unitPrice           : item.unitPrice.toLocaleString() + ' ' + item.pbiCurrency,
                            consumerPrice       : item.consumerPrice.toLocaleString() + ' ' + item.pbiCurrency,
                            priceEffectiveDate  : item.priceEffectiveDate,
                            purchaseLeadTime    : item.purchaseLeadTime,
                            serviceLeadTime     : item.serviceLeadTime,
                            replacementProduct  : item.replacementPart,
                            specification       : item.specification,
                            unit                : item.unit
                        };
                        resultList.push(rList);
                    }
    
                    component.set("v.partsList", resultList);
                    component.set("v.excelDown", resultList);
                    component.set('v.isLoading', false);
                }
            }))
            .catch($A.getCallback(function(errors) {
                component.set('v.isLoading', false);
                if(errors.type == 'NO_DATA') {
                    helper.toast('INFO', errors.message);
                }else if(errors.type == 'NO_PRODUCT') {
                    helper.toast('INFO', errors.message);
                }else{
                    helper.toast('ERROR', $A.get("$Label.c.BPI_E_MSG_5"));//'반복되는 경우 관리자에게 문의 바랍니다.');
                    console.error('errors :: ' +JSON.stringify(errors,null,4));
                }
            }))
        }
    }, 

    // 부품번호 검색 모달 열기
    openPartsNo: function (component, event, helper) {
        component.set('v.excelUploadModal', false);
        component.set("v.isLoading", true);
        var rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedPartsIndex', Number(rowIndex));
        var type = '부품번호';
        $A.createComponent("c:DN_SearchProductNumber",
            {
                'type': type
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("PartsNumberListModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    //th에 있는 checkbox선택 시 모든 checkbox 선택
    toggleAllCheckboxes: function(component, event, helper) {
        component.set('v.excelUploadModal', false);
        let isChecked = component.get("v.selectAll");
        let partsList = component.get("v.partsList");
        partsList.forEach(parts => {
            parts.checkbox = isChecked;
        });
        component.set("v.partsList", partsList);
    },
    
    toggleSelectAll: function(component, event, helper) {
        let allChecked = component.get("v.partsList").every(parts => parts.checkbox);
        component.set("v.selectAll", allChecked);
    },

    //parts list 추가
    addPartsList: function (component, event, helper) {
        component.set('v.excelUploadModal', false);
        helper.addPartList(component, event, helper, 1);
    },

    //parts list 삭제
    deletePartsList: function (component, event,helper) {
        component.set('v.excelUploadModal', false);
        let partsList = component.get("v.partsList");
        // 체크되지 않은 항목 다시 저장
        let updatedPartsList = partsList.filter(parts => !parts.checkbox);
        component.set("v.partsList", updatedPartsList);
        component.set("v.excelDown", updatedPartsList);
        //thead 체크 해제
        component.set("v.selectAll", false);
    },

    // 부품번호 지우기
    clearProductNumber: function (component, event, helper) {
        component.set('v.excelUploadModal', false);
        let index = event.getSource().get('v.accesskey'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index].orderPartNo) { 
            helper.toast('WARNING',  $A.get("$Label.c.BPI_E_MSG_6"));//"저장된 부품번호 값이 없습니다.");
            return;
        }
    
        partsList[index].orderPartNo        = ''; // 부품번호
        // partsList[index].productName        = ''; // 품명
        // partsList[index].stockQuantity      = ''; // 재고수량
        // partsList[index].unitPrice          = ''; // 단가
        // partsList[index].consumerPrice      = ''; // 소비자 가격
        // partsList[index].priceEffectiveDate = ''; // 가격 적용일
        // partsList[index].purchaseLeadTime   = ''; // 구매LT
        // partsList[index].serviceLeadTime    = ''; // SLT
        // partsList[index].replacementProduct = ''; // 대체품
        // partsList[index].specification      = ''; // 규격
        // partsList[index].unit               = ''; // 단위

        component.set('v.partsList', partsList);
        var excelData = partsList.filter(e => e.orderPartNo != '');
        component.set('v.excelDown', excelData);
    },

    // 테이블 세로 스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        table1.scrollTo({ top: scrollY, left: 0, behavior: 'auto' });
    },

    // 모달 선택 이벤트 
    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam('modalName');
        var message   = event.getParam('message');
        var idx       = component.get('v.selectedPartsIndex');
        var partsList = component.get("v.partsList");
    
        // 특정 모달에서의 부품 검색 결과 확인
        if (modalName === 'DN_SearchProductNumber') {
            if (idx !== undefined && idx >= 0 && idx < partsList.length) {
                console.log(`부품 ${idx + 1} row`);
                var parts = partsList[idx];
    
                parts.orderPartNo = message.ProductCode; // 부품 번호
                // parts.productName = message.Name;     // 품명
    
                component.set('v.partsList', partsList);
            } else {
                console.log('idx 가 유효하지 않음 => ' + idx);
            }
        }
    },

    // 엑셀 업로드 열기
    openUploadExcel : function(component, event, helper) {
        component.set('v.excelUploadModal', true);
    },

    // 엑셀 업로드 닫기
    closeUploadExcel : function (component, event, helper) {
        component.set('v.excelUploadModal', false);
    },
    
    // 엑셀 업로드 
    uploadExcel: function (component, event, helper) {
        console.log('**엑셀 업로드 실행**');
        component.set('v.partsList',[]);
        var file = event.getSource().get('v.files')[0];
        let excelData;
        if (file) {
            component.set('v.fileName', file.name);
            helper.readExcelFile(component, file)
                .then($A.getCallback(function(result) {
                    component.set('v.excelUploadModal', false);
                    excelData = component.get('v.excelData');
                    // excelData.forEach(e=> {
                    //     e = e.toUpperCase().trim();
                    // })
                    excelData = excelData.map(e => e.toUpperCase().trim());
                    console.log('excelData >> ' +JSON.stringify(excelData,null,4))
                    return helper.apexCall(component, 'CheckProduct', {psl : excelData})
                }))
                .then($A.getCallback(function(result) {
                    let response = result.r;
                    var matchingData = [];
                    response.forEach(e => {
                        matchingData.push(e.ProductCode)
                    });

                    var excelData2 = new Set(excelData);
                    excelData = [...excelData2];
                    var setDate = new Set(matchingData);
                    
                    // 엑셀 순서와 조회 순서를 일치
                    var detailList = excelData.filter(item => setDate.has(item));
                    component.set('v.excelData', detailList);
                }))
                .then($A.getCallback(function(result) {
                    var search = component.get('c.doSearch');
                    $A.enqueueAction(search);
                }))
                .catch(function (error) {
                    console.error('Error during Excel file processing:', error);
                });
        }
    },


    // 엑셀 다운로드
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },

    downloadExcel: function (component, event, helper) {
        try {
            let partsList = component.get('v.excelDown');
            console.log('excel down >> '+JSON.stringify(partsList,null,4))
            if (partsList.length == 0) {
                helper.toast('SUCCESS', $A.get("$Label.c.MPI_E_MSG_2"));//'엑셀로 변경할 데이터가 없습니다.');
                return;
            } else {
                var header = [
                    ['부품번호', '품명', '재고수량', '단가', '소비자 가격', '가격 적용일', '구매 Lead Time', 'Service Lead Time', '대체품', '규격', '단위' ]
                ];
    
                var sheetName = '멀티 부품 조회';
                var wb = XLSX.utils.book_new();
                var excelData = [];
                excelData = excelData.concat(header);
                
                partsList.forEach(item => {
                    if(item.productName != '') {
                        excelData.push([
                            item.orderPartNo,
                            item.productName,
                            item.stockQuantity,
                            item.stockQuantity2,
                            item.unitPrice,
                            item.consumerPrice,
                            item.priceEffectiveDate,
                            item.purchaseLeadTime,
                            item.serviceLeadTime,
                            item.replacementProduct,
                            item.specification,
                            item.unit
                        ]);
                    }
                });

                let maxLength = Math.max(...partsList.map(item => item.productName.length));
                console.log("가장 긴 productName 길이:", maxLength);

        
                var ws = XLSX.utils.aoa_to_sheet(excelData);
    
                // 열 너비 설정
                ws['!cols'] = [
                    { wch: 15 }, // 부품 번호
                    { wch: maxLength + 2 }, // 품명
                    { wch: 15 }, // 재고 수량
                    { wch: 15 }, // 단가
                    { wch: 15 }, // 소비자 가격
                    { wch: 15 }, // 가격 적용일
                    { wch: 15 }, // 구매LT
                    { wch: 18 }, // SLT
                    { wch: 15 }, // 대체품
                    { wch: 15 }, // 규격
                    { wch: 15 }, // 단위
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

    handleUpperCase: function (component, event, helper) {
        let inputCmp = event.getSource(); 
        let value = inputCmp.get("v.value");
        
        console.log('inputCmp >> '+inputCmp);
        console.log('value >> '+value);
    
        if (value) {
            inputCmp.set("v.value", value.toUpperCase());
        }
    },
    
})