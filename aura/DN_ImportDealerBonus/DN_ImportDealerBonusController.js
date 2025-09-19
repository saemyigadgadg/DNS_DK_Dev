/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-17   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {

    },

    handleUpload: function (component, event, helper) {
        // console.log('handleUpload Start :: ');

        var uploadedFiles = event.getSource().get("v.files");
        var file = uploadedFiles[0];
        // console.log('file :: ' + file);
        component.set('v.isLoading', true);

        var selectedYear = component.get('v.year');

        if (file && selectedYear) {
            var reader = new FileReader();

            reader.onload = function (e) {
                // console.log('Flag');
                var data = e.target.result;
                // console.log('data :: ' + JSON.stringify(data));

                var workbook = XLSX.read(data, { type: "array" });
                // console.log('workbook :: ' + JSON.stringify(workbook));

                var sheets = ['판매수수료', '인센티브', '포상금', '영업활동 장려금'];
                var expectedHeaders = ["Customer", "대리점", "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월", "계", "총계(백만원 단위)"];

                // allData를 Map으로 초기화
                var allData = new Map();
                var hasError = false;

                sheets.forEach(function (sheetName) {
                    var sheet = workbook.Sheets[sheetName];
                    // console.log('sheetName :: ' + sheetName);
                    // console.log('sheet :: ' + JSON.stringify(sheet));

                    // JSON으로 변환
                    var sheetData = XLSX.utils.sheet_to_json(sheet, {
                        raw: true,
                        defval: 0, // 표의 빈 값은 0으로 처리
                        range: 2 // 3번째 행부터 시작
                    });

                    // console.log('sheetData :: ' + JSON.stringify(sheetData));

                    // 세번째 행 가져오기
                    var firstRow = XLSX.utils.sheet_to_json(sheet, { header: 1 })[2];
                    // console.log('firstRow :: ' + firstRow);

                    if (!sheet || !expectedHeaders.every(header => firstRow.includes(header))) {
                        // helper.toast(component, 'Error', 'The template does not match.', 'error');
                        helper.toast(component, 'Error', $A.get('{!$Label.c.DNS_M_TemplateMatch}'), 'error');
                        component.set('v.isFileUpload', false);
                        component.set('v.isLoading', false);
                        hasError = true;
                        return; // 종료
                    } else {
                        // Map에 시트 이름을 키로 사용하고, 데이터를 값으로 설정
                        allData.set(sheetName, sheetData);
                    }
                });

                if (!hasError) {
                    // Map을 배열로 변환하여 컴포넌트에 설정
                    component.set('v.excelData', Array.from(allData));
                    component.set('v.fileName', file.name);
                    component.set('v.isFileUpload', true);
                    component.set('v.isLoading', false);
                    // console.log('excelData :: ' + JSON.stringify(Array.from(allData)));
                }
            };

            reader.readAsArrayBuffer(file);
            // console.log('handleUpload Finish :: ');
        } else {
            helper.toast(component, 'Error', $A.get('{!$Label.c.DNS_M_ValidYear}'), 'error');
            // console.log('Year Empty ');
            component.set('v.isLoading', false);
        }
    },

    doImport: function (component, event, helper) {
        component.set('v.isLoading', true);

        window.setTimeout($A.getCallback(() => {
            try {
                // console.log('Lets Do Import !');

                var excelData = component.get('v.excelData');
                // console.log('excelData :: ' + JSON.stringify(excelData));

                var selectedYear = component.get('v.year');
                // console.log('selectedYear :: ' + selectedYear);

                if (excelData.length > 0 && selectedYear) {
                    // console.log('True ::::: ');

                    var recordsToUpsert = helper.prepareRecords(excelData, selectedYear);
                    var records = JSON.stringify(recordsToUpsert);

                    helper.apexCall(component, event, helper, 'upsertRecords', {
                        records: records

                    }).then($A.getCallback(function (result) {

                        // console.log('result :: ' + JSON.stringify(result));
                        component.set('v.isLoading', false);

                        if (result.r == 'Success') {

                            helper.toast(component, 'Success', 'Records imported successfully.', 'success');
                            window.history.back();
                        } else {

                            helper.toast(component, 'Error', result.r, 'error');
                        }
                    })).catch(function (error) {

                        // Error Message
                        component.set('v.isLoading', false);
                        console.log('Error : ' + error);
                        console.log('Error.message : ' + error.message);
                        console.log('Error[0] : ' + error[0]);
                        helper.toast(component, 'Error', error[0].message, 'error');

                    });
                } else {
                    console.log('Error: Excel data or required value is missing.');
                    helper.toast(component, 'Error', 'Required value is missing', 'error');
                    component.set('v.isLoading', false);
                }

            } catch (error) {
                console.error('An error occurred:', error);
                component.set('v.isLoading', false);
                helper.toast(component, 'Error', 'An unexpected error occurred: ' + error.message, 'error');

            }
        }), 0); // setTimeout을 0ms로 설정하여 렌더링 우선 처리

    },

    doClose: function (component, event, helper) {
        window.history.back();
    },

    doCancel: function (component, event, helper) {
        // Excel 데이터 초기화
        component.set('v.excelData', []);

        // 파일 이름과 업로드 상태 초기화
        component.set('v.fileName', 'fileName.xlsx');
        component.set('v.isFileUpload', false);
    }



})