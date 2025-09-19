/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-08   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.setDistrictOptions(component);
        component.set('v.isLoading', false);
    },


    handleUpload: function (component, event, helper) {

        // console.log('handleUpload Start :: ');

        var uploadedFiles = event.getSource().get("v.files");
        var file = uploadedFiles[0];
        // console.log('file :: ' + file);
        component.set('v.isLoading', true);

        var selectedDistrict = component.get('v.district');

        if (file) {
            var reader = new FileReader();

            // 파일이 로드된 후 실행되는 로직
            reader.onload = function (e) {
                // console.log('File reader loaded successfully');

                // Excel 데이터 처리
                var data = e.target.result;
                var workbook = XLSX.read(data, { type: "array" });
                // console.log('Workbook:', JSON.stringify(workbook));

                var sheetName = workbook.SheetNames[0];
                var sheet = workbook.Sheets[sheetName];
                // console.log('Sheet JSON:', JSON.stringify(sheet));

                // Excel 시트 데이터를 JSON 형식으로 변환
                var sheetData = XLSX.utils.sheet_to_json(sheet, {
                    raw: true,
                    defval: 0, // 빈 셀은 0으로 처리
                    range: 2 // 3번째 행부터 시작

                });
                // console.log('Sheet Data JSON:', JSON.stringify(sheetData));

                var expectedHeaders = [];

                // District에 따른 Header 분기 (Korea/Global)
                if (selectedDistrict == 'Korea') {
                    expectedHeaders = ["Customer", "대리점", "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"];
                } else if (selectedDistrict == 'Global') {
                    expectedHeaders = ["Customer", "대리점", "Target"];
                }

                // 세번째 행 가져오기
                var firstRow = XLSX.utils.sheet_to_json(sheet, { header: 1 })[2];
                // console.log('First Row JSON:', JSON.stringify(firstRow));

                // Header Check
                if (sheet && expectedHeaders.every(header => firstRow.includes(header))) {

                    // 조건을 모두 만족할 경우 Excel 데이터 설정
                    component.set('v.excelData', sheetData);
                    component.set('v.fileName', file.name);
                    component.set('v.isFileUpload', true);
                    component.set('v.expectedHeaders', expectedHeaders);
                    component.set('v.isLoading', false);

                } else {
                    // helper.toast(component, 'Error', 'The template does not match.', 'error');
                    helper.toast(component, 'Error', $A.get('{!$Label.c.DNS_M_TemplateMatch}'), 'error');
                    component.set('v.isFileUpload', false);
                    component.set('v.isLoading', false);

                }

            };
            reader.readAsArrayBuffer(file);

        } else {
            console.error('No file selected');
            component.set('v.isLoading', false);
        }
    },


    doImport: function (component, event, helper) {
        component.set('v.isLoading', true);

        window.setTimeout($A.getCallback(() => {
            try {
                // console.log('Lets Do Import !');

                var expectedHeaders = component.get('v.expectedHeaders');   //     row 추가해서 길이만큼 돌게하기
                var excelData = component.get('v.excelData');
                var selectedYear = component.get('v.year');
                var district = component.get('v.district');

                // console.log('Excel Data:', JSON.stringify(excelData));
                // console.log('expectedHeaders ::  ', expectedHeaders);
                // console.log('district ::  ', district);


                // 레코드 생성 가능 여부 체크
                var hasValidData = excelData.length > 0 && selectedYear;

                // console.log('hasValidData :: ' + hasValidData);

                if (hasValidData) {
                    // 레코드 생성 로직 추가

                    var recordsToInsert = helper.prepareRecords(excelData, expectedHeaders, selectedYear, district);
                    // console.log(typeof recordsToInsert);

                    var records = JSON.stringify(recordsToInsert);

                    // Record 생성
                    helper.apexCall(component, event, helper, 'insertRecords', {
                        records: records,
                        district: district,
                        year: selectedYear

                    }).then($A.getCallback(function (result) {

                        let state = result.state;
                        // console.log('state :: ' + state);
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
                    helper.toast(component, 'Error', $A.get('{!$Label.c.DNS_M_CheckFileValue}'), 'error');
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