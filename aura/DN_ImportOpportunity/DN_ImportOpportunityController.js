/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-09
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-23   yuhyun.park@sbtglobal.com   Initial Version
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
                    defval: '', // 빈 셀 처리
                    range: 3 // 5번째 행부터 시작
                });
                // console.log('Sheet Data JSON:', JSON.stringify(sheetData));

                // 5번째 행 가져오기
                var firstRow = XLSX.utils.sheet_to_json(sheet, { header: 1 })[3];
                // console.log('First Row JSON:', JSON.stringify(firstRow));

                // Apex 호출
                helper.apexCall(component, event, helper, 'getImportOpportunityMetadata', {
                }).then($A.getCallback(function (result) {
                    let expectedHeaders = result.r;
                    // console.log("expectedHeaders :: ", expectedHeaders);

                    // Header 완벽 비교
                    var isMatch = expectedHeaders.every(header => firstRow.includes(header));
                    // console.log("isMatch :: ", isMatch);

                    if (!isMatch) {
                        // helper.toast(component, 'Error', 'The template does not match.', 'error');
                        helper.toast(component, 'Error', $A.get('{!$Label.c.DNS_M_TemplateMatch}'), 'error');
                        component.set('v.isFileUpload', false);
                        component.set('v.isLoading', false);
                        // console.log('miss match');
                        return;
                    } else {
                        component.set('v.excelData', sheetData);
                        component.set('v.fileName', file.name);
                        component.set('v.isFileUpload', true);
                        component.set('v.expectedHeaders', expectedHeaders);
                        component.set('v.isLoading', false);
                        // console.log('match');
                    }
                })).catch(function (error) {
                    console.log('Error : ' + error.message);
                    console.log('catch error');
                    component.set('v.isLoading', false);

                });
            };
            reader.readAsArrayBuffer(file);

        } else {
            console.error('No file selected');
            component.set('v.isLoading', false);
        }
    },


    doImport: function (component, event, helper) {
        // console.log('Lets Do Import !');
        component.set('v.isLoading', true);

        window.setTimeout($A.getCallback(() => {
            try {

                var expectedHeaders = component.get('v.expectedHeaders');   //     row 추가해서 길이만큼 돌게하기
                var excelData = component.get('v.excelData');
                // console.log('Excel Data:', JSON.stringify(excelData));
                // console.log('expectedHeaders ::  ', expectedHeaders);

                if (excelData.length > 0) {

                    var recordsToInsert = helper.prepareRecords(excelData, expectedHeaders);
                    var records = JSON.stringify(recordsToInsert);

                    // Apex Call : upsertRecords
                    helper.apexCall(component, event, helper, 'upsertRecords', {
                        records: records

                    }).then($A.getCallback(function (result) {

                        // console.log('result :: ' + JSON.stringify(result));
                        component.set('v.isLoading', false);

                        if (result.r == 'Success') {
                            helper.toast(component, 'Success', 'Records imported successfully.', 'success');
                            // Navigate to Opportunity List View
                            var navEvent = $A.get("e.force:navigateToObjectHome");
                            navEvent.setParams({
                                "scope": "Opportunity" // 이동할 객체
                            });
                            navEvent.fire();
                            $A.get('e.force:refreshView').fire();

                        } else {

                            // Error Message
                            // var errors = response.getError();
                            // console.error(errors);
                            helper.toast(component, 'Error', result.r, 'error');
                        }
                    })).catch(function (error) {

                        // Error Message
                        component.set('v.isLoading', false);
                        console.log('Error : ' + error);
                        console.log('Error.message : ' + error.message);
                        console.log('Error[0] : ' + error[0]);
                        // console.log('Error[0].message : ' + error[0].message);
                        helper.toast(component, 'Error', error[0].message, 'error');

                    });

                    // Excel 데이터 초기화
                    component.set('v.excelData', []);

                    // 파일 이름과 업로드 상태 초기화
                    component.set('v.fileName', 'fileName.xlsx');
                    component.set('v.isFileUpload', false);


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
    },


})