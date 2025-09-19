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
    toast: function (component, title, message, variant) {
        sforce.one.showToast({
            "title": title,
            "message": message,
            "type": variant
        });
    },

    apexCall: function (component, event, helper, methodName, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            let action = component.get('c.' + methodName);

            if (typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({ 'c': component, 'h': helper, 'r': response.getReturnValue(), 'state': response.getState() });
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    prepareRecords: function(excelData, expectedHeaders, templateType) {
        // console.log('prepareRecords 입성');
    
        var recordsToInsert = [];

        excelData.forEach(function(row, rowIndex) {
            // console.log('Row ' + (rowIndex + 1) + ':');
    
            var record = {}; // 새로운 record 객체를 만듦
    
            // row의 값을 배열로 변환하여 위치로 접근
            var rowValues = Object.values(row);
    
            expectedHeaders.forEach(function(header, index) {
                var columnValue = rowValues[index]; // n번째 컬럼 위치 값을 가져옴
                
                // header 이름 대신 위치를 key로 사용
                var key = 'Column_' + index; // "Column_0", "Column_1" 형식의 key 사용
    
                // record에 key를 키로, columnValue를 값으로 할당
                if (columnValue !== undefined) {
                    record[key] = columnValue;
                }
                // console.log('Column ' + key + ' (index ' + index + '): ' + columnValue);
            });
    
            // 선택된 템플릿 유형 정보도 record에 추가
            record['TemplateType'] = templateType;
            recordsToInsert.push(record); // recordsToInsert에 record 추가
        });
    
        // console.log('Prepared Records(JSON):', JSON.stringify(recordsToInsert));
        return recordsToInsert;
    },




})