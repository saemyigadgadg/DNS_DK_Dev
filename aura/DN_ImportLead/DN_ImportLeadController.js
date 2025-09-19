/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-08   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);

        // DNS-DNSA 판단
        helper.apexCall(component, event, helper, 'getSalesOrg', {
        })
            .then($A.getCallback(function (result) {

                let salesOrg = result.r;
                // console.log('salesOrg :: ' + salesOrg);

                if (salesOrg == '4140') {
                    component.set('v.isDNSA', true);
                } else {
                    component.set('v.isDNSA', false);
                }

                var typeOptions = component.get("v.typeOptions");
                typeOptions = [
                    { 'label': 'Event Visitor', 'value': 'Event Visitor' },
                    { 'label': 'Catalog Downloader', 'value': 'Catalog Downloader' },
                    { 'label': 'On-site Visitor', 'value': 'On-site Visitor' },
                    { 'label': 'Other', 'value': 'Other' }
                ]

                component.set("v.typeOptions", typeOptions);
                component.set('v.isLoading', false);

            }))



    },

    handleUpload: function (component, event, helper) {
        // console.log('handleUpload Start :: ');
        component.set('v.isLoading', true);

        var uploadedFiles = event.getSource().get("v.files");
        var file = uploadedFiles[0];

        var templateType = component.get('v.templateType');
        var isDNSA = component.get('v.isDNSA');

        var selectedType = component.get("v.type");
        // console.log('selectedType :: ' + selectedType);


        if (selectedType == 'Catalog Downloader') {
            templateType = 'Catalog Downloader';
        } else {
            templateType = 'Event Visitor';
        }

        if (file) {
            var reader = new FileReader();

            // 파일이 로드된 후 실행되는 로직
            reader.onload = function (e) {

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
                    range: 2 // 3번째 행부터 시작
                });
                // console.log('Sheet Data JSON:', JSON.stringify(sheetData));

                // 세번째 행 가져오기
                var firstRow = XLSX.utils.sheet_to_json(sheet, { header: 1 })[2];
                // console.log('First Row JSON:', JSON.stringify(firstRow));

                helper.apexCall(component, event, helper, 'getImportLeadMetadata', {
                    templateType: templateType,
                    isDNSA: isDNSA

                }).then($A.getCallback(function (result) {
                    let expectedHeaders = result.r;
                    // console.log("expectedHeaders :: ", expectedHeaders);


                    // Header 완벽 비교
                    var isMatch = expectedHeaders.every(header => firstRow.includes(header));
                    if (!isMatch) {
                        // helper.toast(component, 'Error', 'The template does not match.', 'error');
                        helper.toast(component, 'Error', $A.get('{!$Label.c.DNS_M_TemplateMatch}'), 'error');
                        component.set('v.isFileUpload', false);
                        component.set('v.isLoading', false);
                        return;
                    } else {
                        component.set('v.excelData', sheetData);
                        component.set('v.fileName', file.name);
                        component.set('v.isFileUpload', true);
                        component.set('v.templateType', templateType);
                        component.set('v.type', selectedType);
                        component.set('v.expectedHeaders', expectedHeaders);
                        component.set('v.isLoading', false);
                    }


                })).catch(function (error) {
                    console.log('Error : ' + error.message);
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
                var templateType = component.get('v.templateType');
                var selectedType = component.get('v.type');
                var isDNSA = component.get('v.isDNSA');
                // console.log('Excel Data:', JSON.stringify(excelData));
                // console.log('expectedHeaders ::  ', expectedHeaders);


                if (excelData.length > 0) {
                    // 레코드 생성 로직 추가

                    var recordsToInsert = helper.prepareRecords(excelData, expectedHeaders, templateType);

                    var records = JSON.stringify(recordsToInsert);

                    // Record 생성
                    helper.apexCall(component, event, helper, 'upsertRecords', {
                        records: records,
                        templateType: templateType,
                        selectedType: selectedType,
                        isDNSA: isDNSA

                    }).then($A.getCallback(function (result) {

                        // let state = result.state;

                        // console.log('result :: ' + JSON.stringify(result));
                        component.set('v.isLoading', false);


                        if (result.r == 'Success') {
                            helper.toast(component, 'Success', 'Records imported successfully.', 'success');
                            window.history.back();


                        } else {
                            // var errors = result.r;
                            // console.error(errors);
                            // let errorMsg = errors && errors.length ? errors[0].message : 'There was an error processing the records.';

                            helper.toast(component, 'Error', result.r, 'error');
                        }

                    })).catch(function (error) {

                        console.log('Error: Something went wrong with the Excel file contents');
                        console.log('JSON.stringify error :: ' + JSON.stringify(error));

                        component.set('v.isLoading', false);


                        // 에러 메시지에서 구체적인 내용을 추출하고 사용자에게 전달
                        // helper.toast(component, 'Error', error[0].message, 'error');

                        // 에러 메시지에서 "first error: " 이후의 값을 추출
                        let errorMessage = error[0].message;
                        // let trimmedMessage = errorMessage.split('first error: ')[1] || 'Unknown error details';
                        let trimmedMessage = '';
                        if (errorMessage.includes('first error')) {
                            trimmedMessage = errorMessage.split('first error: ')[1] || 'Unknown error details';
                        } else {
                            trimmedMessage = errorMessage.split('Failed to upsert records: ')[1] || 'Unknown error details';
                        }

                        console.error('Error details: ', trimmedMessage);
                        helper.toast(component, 'Error', trimmedMessage, 'error');

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
        component.set('v.templateType', '');
    }








})