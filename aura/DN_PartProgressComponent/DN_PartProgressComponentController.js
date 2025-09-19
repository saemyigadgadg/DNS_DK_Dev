/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-29
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-11   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {

        helper._apexCall(component, event, helper, 'getInit', {

        }).then(result => {
            component.set('v.searchObject', result.r);
        }).catch(error => {
            console.log('Error ::: ', JSON.stringify(error.message));
        });
        
    },

    handleSearch: function (component, event, helper) {

        try {
            component.set('v.isLoading', true);

            var searchObject = component.get('v.searchObject');
    
            console.log('searchObject ::: ', JSON.stringify(searchObject));
            if (!searchObject.CNFCheck && searchObject.searchCustomerName == '' && searchObject.searchGijong == '' && searchObject.searchHogi == '' && searchObject.searchOrderNumber == '' && searchObject.searchPartName == '' && searchObject.searchPartNumber == '' && searchObject.searchSerialNumber == '' && searchObject.searchStatus == '0') {
                helper.toast('접수일자 외에 조회조건을 하나이상 입력해주세요.', 'Error', 'error');
                component.set('v.isLoading', false);
            } else {
                // component.set('v.partList', []);
                helper._apexCall(component, event, helper, 'getPartsList', {
                    searchObject : searchObject
                }).then(result => {
                    // console.log('getPartsList result ::: ', JSON.stringify(result.r));
                    var r = result.r;
                    var partList = r.resultList;

                    if (r.isSuccess) {
                        if (r.type == 'Callout') {
                            var orderNumberList = [];
        
                            partList.forEach(part => {
                                orderNumberList.push(part.AUFNR);
                            });
        
                            // console.log('orderNumberList ::: ', JSON.stringify(orderNumberList));
                            helper._apexCall(component, event, helper, 'getPartsInfo', {
                                orderNumberList : orderNumberList
                            }).then(result2 => {
                                // console.log('getPartsInfo result ::: ', result2.r);
                                var resultPartList = [];
                                var requestDate = result2.r;
                                partList.forEach(part => {
                                    var partInfo = requestDate[part.AUFNR + '!' + part.QMSEQ];
                                    console.log('partInfo ::: ', partInfo);
                                    if (partInfo != undefined && partInfo != null) {
                                        part['REQDATE'] = partInfo.PartsRequestDate;
                                    } else {
                                        part['REQDATE'] = '0000-00-00';
                                    }
                                    resultPartList.push(part);
                                });
                                component.set('v.partList', resultPartList);
                                component.set('v.isLoading', false);
                            }).catch(error => {
                                console.log('Error ::: ', error.message);
                                component.set('v.isLoading', false);
                            })

                        } else {
                            component.set('v.partList', partList);
                            component.set('v.isLoading', false);
                        }
                        
                    } else {
                        // helper.toast(r.message, 'Error', 'error');
                        component.set('v.partList', []);
                        component.set('v.isLoading', false);
                    }
                    
                }).catch(error => {
                    console.log('Error ::: ', JSON.stringify(error.message));
                    component.set('v.isLoading', false);
                })
            }

        } catch (error) {
            console.log('Error ::: ', JSON.stringify(error.message));
            component.set('v.isLoading', false);
        }


    },

    handleSearchGijong: function (component, event, helper) {
        component.set('v.isLoading', true);

        var searchGijongModal = component.get('v.searchGijongModal');
        console.log('searchGijongModal', searchGijongModal);

        var giJongList = [];

        helper._apexCall(component, event, helper, 'searchGijongList', {
            searchTemp : searchGijongModal
        }).then(result => {

            console.log('result ::: ', JSON.stringify(result.r));

            var r = result.r;

            if (r.isSuccess) {
                giJongList = r.giJongList;
                component.set('v.giJongList', giJongList);
            } else {
                helper.toast(r.message, 'Error', 'error');
            }

            component.set('v.isLoading', false);
            
        }).catch(error => {
            console.log('error ::: ', error.message);
        });

    },

    handleCheckboxChange: function (component, event, helper) {
        var selectedIndex = component.get('v.selectedIndex');
        var index = event.target.name;
        var checkbox = component.find('checkbox');

        if (selectedIndex != null && selectedIndex != index) {
            checkbox[selectedIndex].set('v.checked', false);
        }

        component.set('v.selectedIndex', index);
    },

    handleSelectGijong: function (component, event, helper) {
        component.set('v.isLoading', true);
        var giJongList = component.get('v.giJongList');
        var searchObject = component.get('v.searchObject');

        if (giJongList.length > 0) {
            var checkbox = component.find('checkbox');
            var index;

            for (let i = 0; i < checkbox.length; i++) {
                if (checkbox[i].get('v.checked')) {
                    index = i;
                    break;
                }
            }

            if (index === undefined) {
                helper.toast('기종을 선택해주세요.', 'Error', 'error');
            } else {
                searchObject.searchGijong = String(giJongList[index].name);
                component.set('v.searchObject', searchObject);
                component.set('v.searchGijongModal', '');
                component.set('v.giJongList', []);
                component.set('v.isGijongModal', false);
            }
        } else {
            helper.toast('기종을 선택해주세요.', 'Error', 'error');
        }

        component.set('v.isLoading', false);
    },

    handleGijongModal: function (component, event, helper) {

        component.set('v.isGijongModal', true);

    },

    handleModalClose: function (component, event, helper) {
        component.set('v.searchGijongModal', '');
        component.set('v.giJongList', []);
        component.set('v.isGijongModal', false);

    },

    // handleDownloadExcel : function(component, event, helper) {
        // var partList = component.get("v.partList");
        // if (!partList || partList.length === 0) {
        //     alert("다운로드할 데이터가 없습니다.");
        //     return;
        // }

    //     // 헤더
    //     var csv = '\uFEFF' + '품번,품명,오더수,재고할당,포장완료,배송완료,상태,탁송구분,납기일,납품업체,불출일,반납대상,오더번호,SALES,송장번호,창고불출번호,배송처,업체명,대리점코드,대리점명,기종,호기,접수일,부품청구일,설치일자,Shipment,D/O 생성일,Seq\n';
    //     partList.forEach(function(part) {
    //         csv += `${part.MATNR},${part.MAKTX},${part.KWMENG},${part.BMENG},${part.VSMNG},${part.GSMNG},${part.MATNR_TXT},${part.DIVISION},${part.PRETD3},${part.VNDNM},${part.QDATU},${part.RETURN_YN},${part.AUFNR},${part.VBELN},${part.INVOICE},${part.VBELN_VL1},${part.NAME4},${part.NAME2},${part.DEALER_CD},${part.NAME1},${part.TYPBZ},${part.SERNR},${part.RECV_DT},${part.REQDATE},${part.GWLDT},${part.TKNUM},${part.DODAT},${part.QMSEQ}\n`;
    //     });

    //     var hiddenElement = document.createElement('a');
    //     hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
    //     hiddenElement.target = '_blank';
    //     hiddenElement.download = '부품진행상태_Excel.csv';
    //     hiddenElement.click();
    // },

    handleDownloadExcel: function(component, event, helper) {
        try {
            console.log('엑셀눌림');
            const partList = component.get('v.partList');

            if (partList.length > 0) {
                component.set('v.isLoading', true);
                const workbook = new ExcelJS.Workbook();
                const worksheet = workbook.addWorksheet('sheet1');

                const headerStyle = {
                    font: {
                        name: '돋움',
                        size: 9,
                        bold: true,
                        // color: { argb: "2f435c" }
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "dbe2ea" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: {
                        top: { style: 'thin', color: { argb: '657584' } },
                        bottom: { style: 'thin', color: { argb: '657584' } },
                        left: { style: 'thin', color: { argb: '657584' } },
                        right: { style: 'thin', color: { argb: '657584' } }
                    }
                };

                const colStyles = {
                    font: {
                        name: '돋움',
                        size: 9,
                        // bold: true,
                        // color: { argb: "2f435c" }  // 필요하면 색상 추가
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };
    
                const locationStyles = {
                    font: {
                        name: '돋움',
                        size: 9,
                        color: { argb: "2f435c" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "left"
                    },
                    border: headerStyle.border
                };
    
                const nameStyles = {
                    font: {
                        name: '돋움',
                        // color: { argb: "0a0aff" },
                        size: 9
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };    
                
                const statusStyles = {
                    font: {
                        name: '돋움',
                        // color: { argb: "2f435c" },
                        size: 9
                    },
                    // fill: {
                    //     type: 'pattern',
                    //     pattern: 'solid',
                    //     // fgColor: { argb: "ffff80" }
                    // },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };

                // 헤더 추가
                const header = ['품번', '품명', '오더수', '재고할당', '포장완료', '배송완료', '상태', '탁송구분', '납기일', '납품업체', '불출일', '반납대상', '오더번호', 'Shipping Origin', 'SALES', '송장번호', '창고불출번호', '배송처', '업체명', '대리점코드', '대리점명', '기종', '호기', '접수일', '부품청구일', '설치일자', 'Shipment', 'D/O 생성일', 'Seq'];                
                const headerRow = worksheet.addRow(header);
    
                headerRow.eachCell((cell) => {
                    cell.style = headerStyle;
                });
    
                // 데이터 추가
                partList.forEach(part => {
                    const dataRow = worksheet.addRow([
                        part.MATNR, part.MAKTX, part.KWMENG, part.BMENG, part.VSMNG, part.GSMNG, part.MATNR_TXT, part.DIVISION,
                        part.PRETD3, part.VNDNM, part.QDATU, part.RETURN_YN, part.AUFNR, part.VTEXT, part.VBELN, part.INVOICE, part.VBELN_VL1,
                        part.NAME4, part.NAME2, part.DEALER_CD, part.NAME1, part.TYPBZ, part.SERNR, part.RECV_DT, part.REQDATE,
                        part.GWLDT, part.TKNUM, part.DODAT, part.QMSEQ
                    ]);
                    // dataRow.getCell(1).style = colStyles;
                    // dataRow.getCell(2).style = colStyles;
                    // dataRow.getCell(3).style = nameStyles;
                    // dataRow.getCell(4).style = locationStyles;
                    // dataRow.getCell(5).style = colStyles;
                    // dataRow.getCell(6).style = locationStyles;
                    // dataRow.getCell(7).style = statusStyles;
                    // dataRow.getCell(8).style = colStyles;
                });

                worksheet.addRow([]);
                // 행 높이 설정
                worksheet.getRow(2).height = 20; // 제목 행
                worksheet.getRow(4).height = 20;
                for (let i = 5; i < partList.length + 5; i++) {
                    worksheet.getRow(i).height = 20; // 데이터 행
                }
                worksheet.getRow(partList.length + 6).height = 20; // 마지막 날짜

        
                // 열 너비 설정
                worksheet.getColumn(1).width = 19;
                worksheet.getColumn(2).width = 32;
                worksheet.getColumn(3).width = 7;
                worksheet.getColumn(4).width = 7;
                worksheet.getColumn(5).width = 7;
                worksheet.getColumn(6).width = 7;
                worksheet.getColumn(7).width = 7;
                worksheet.getColumn(8).width = 15;
                worksheet.getColumn(9).width = 11;
                worksheet.getColumn(10).width = 17;
                worksheet.getColumn(11).width = 11;
                worksheet.getColumn(12).width = 7;
                worksheet.getColumn(13).width = 11;
                worksheet.getColumn(14).width = 11;
                worksheet.getColumn(15).width = 10;
                worksheet.getColumn(16).width = 11;
                worksheet.getColumn(17).width = 28;
                worksheet.getColumn(18).width = 26;
                worksheet.getColumn(19).width = 9;
                worksheet.getColumn(20).width = 8;
                worksheet.getColumn(21).width = 16;
                worksheet.getColumn(22).width = 15;
                worksheet.getColumn(23).width = 11;
                worksheet.getColumn(24).width = 11;
                worksheet.getColumn(25).width = 11;
                worksheet.getColumn(26).width = 9;
                worksheet.getColumn(27).width = 11;
                worksheet.getColumn(28).width = 7;

                // 고정 행 설정
                worksheet.views = [
                    { state: 'frozen', ySplit: 1 }
                ];

                var localDate = new Date();
                // 로컬 시간에 맞는 년, 월, 일 추출
                var year = localDate.getFullYear();
                var month = String(localDate.getMonth() + 1).padStart(2, '0');
                var day = String(localDate.getDate()).padStart(2, '0'); 

                var dateString = year + month + day;

                // 파일 생성
                workbook.xlsx.writeBuffer().then((buffer) => {
                    // const blob = new Blob([buffer], { type: 'application/octet-stream' });
                    // FileSaver.saveAs(blob, 'example.xlsx');
                    const blob = new Blob([buffer], { type: 'application/octet-stream' });
                    const link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = dateString + ' 부품진행상태.xlsx';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    component.set('v.isLoading', false);

                });
            } else {
                alert("다운로드할 데이터가 없습니다.");
                console.log('에러 내역 알려주세요 ::: ' + error);
                console.log('에러 내역 알려주세요 ::: ' + error.message);
                
                return;
            }
        } catch (error) {
            // alert("다운로드할 데이터가 없습니다.");
            console.log('에러 내역 알려주세요 ::: ' + error);
            console.log('에러 내역 알려주세요 ::: ' + error.message);
            component.set('v.isLoading', false);

            // return;
        }
    },
    
    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },
    
})