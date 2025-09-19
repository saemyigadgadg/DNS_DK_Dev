/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-04
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        
    },

    // Excel
    handleScriptsLoaded: function (component, event, helper) {

        console.log('Excel Test');

        // var objIds = component.get('v.objIds');
        var objType = component.get('v.objType');
        var objName = component.get('v.objName');
        // var jsonString = component.get('v.jsonString');
        var listviewId = component.get('v.listviewId');
        var returnUrl = component.get('v.returnUrl');

        helper.apexCall(component, event, helper, 'getInit', {
            objectType : objType,
            filterId : listviewId
        }).then($A.getCallback(function(result) {
            var r = result.r;
            var data = r.getData;
            console.log('dataaa ::: ', data);
            var header = data.columnsLabelList;
            var apiList = data.columnsApiNameList;
            var objList = data.resultList;

            var excelData = [];
            
            objList.forEach(obj => {
                var row = [];
                apiList.forEach(apiName => {
                    var dataString = '';
                    if (apiName.includes('.')) {
                        if (obj[apiName.split('.')[0]] != null) {
                            dataString = obj[apiName.split('.')[0]][apiName.split('.')[1]];
                        }
                    } else {
                        if (obj[apiName] != null) {
                            dataString = obj[apiName];
                        }
                    }
                    
                    var isTagPass = helper.replaceTagFormatTest(dataString);
                    if (isTagPass) {
                        dataString = helper.replaceTagFormat(dataString);
                    }

                    var isDatePass = helper.isISO8601Format(dataString);
                    if (isDatePass) {
                        dataString = helper.formatUTCDate(dataString, navigator.language);
                    }
                    row.push(dataString);
                });
                excelData.push(row);
            });

            console.log('excelData', JSON.stringify(excelData));

            const workbook = new ExcelJS.Workbook();
            const worksheet = workbook.addWorksheet('sheet1');

            const headerStyle = {
                font: {
                    name: '돋움',
                    size: 11,
                    color: { argb: "2f435c" },
                    bold: true
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
                    size: 10,
                    color: { argb: "2f435c" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "left",
                    indent: 1
                },
                border: headerStyle.border
            };

            // 헤더 추가
            const headerRow = worksheet.addRow(header);

            headerRow.eachCell((cell) => {
                cell.style = headerStyle;
            });

            // 데이터 추가
            excelData.forEach(rowData => {
                const dataRow = worksheet.addRow(rowData);
                for (let i = 1; i <= rowData.length; i++) {
                    dataRow.getCell(i).style = colStyles; // 셀 스타일
                    worksheet.getColumn(i).width = 30; // 열 너비
                }
            });

            worksheet.getRow(1).height = 20; // Header 행 높이

            for (let i = 2; i < excelData.length + 2; i++) {
                worksheet.getRow(i).height = 17; // 데이터 행 높이
            }

            // 고정 행 설정
            worksheet.views = [
                { state: 'frozen', xSplit: 0, ySplit: 1, topLeftCell: 'A2', activeCell: 'A2' }
            ];            

            // 파일 생성
            workbook.xlsx.writeBuffer().then((buffer) => {
                const blob = new Blob([buffer], { type: 'application/octet-stream' });
                saveAs(blob, objName + ' Listview.xlsx');
            });

            setTimeout(function() {
                console.log('returnUrl ::: ', returnUrl);
                window.open(returnUrl, '_self');
                // window.history.back();
            }, 3000);

        })).catch(function(error) {
            console.log('ExcelError ::: ' + error.message);
        });
    },

    // Excel
    handleScriptsLoaded2: function (component, event, helper) {
        console.log('FileSaver Test');
    }

})