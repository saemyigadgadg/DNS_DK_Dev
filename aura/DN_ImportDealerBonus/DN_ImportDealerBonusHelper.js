/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-18   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    toast: function (component, title, message, variant) {
        sforce.one.showToast({
            "title": title,
            "message": message,
            "type": variant
        });
    },

    prepareRecords: function (excelData, selectedYear) {
        // console.log('prepareRecords 입성');

        var recordsToUpsert = [];
        var monthFields = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]; // 모든 월 컬럼

        excelData.forEach(function ([sheetName, sheetData]) {
            sheetData.forEach(function (row) {
                var customerCode = row["Customer"];

                monthFields.forEach(function (monthField, index) {
                    var amount = row[monthField]; // 해당 월의 데이터
                    var month = (index + 1).toString().padStart(2, '0'); // 두 자리 월 형식 변환

                    // console.log('month :: ' + month);

                    // 레코드에 필요한 값 설정
                    var record = {
                        'SheetName': sheetName,
                        'CustomerCode__c': customerCode,
                        'Year__c': selectedYear,
                        'Month__c': month,
                        'Name': selectedYear + '-' + month
                    };

                    // 시트 이름에 따라 필드 설정
                    if (sheetName === '판매수수료') {
                        record['SalesCommission__c'] = amount;
                        // console.log('판매수수료 :: ' + amount);
                    } else if (sheetName === '인센티브') {
                        record['Incentive__c'] = amount;
                        // console.log('인센티브 :: ' + amount);
                    } else if (sheetName === '포상금') {
                        record['Bounty__c'] = amount;
                        // console.log('포상금 :: ' + amount);
                    } else if (sheetName === '영업활동 장려금') {
                        record['SalesActivityBonus__c'] = amount;
                        // console.log('영업활동 장려금 :: ' + amount);
                    }

                    // console.log(record);
                    recordsToUpsert.push(record);
                });
            });

        });

        // console.log(recordsToUpsert);
        return recordsToUpsert;
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
    }


})