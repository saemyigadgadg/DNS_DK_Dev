/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-29   yuhyun.park@sbtglobal.com   Initial Version
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


    setDistrictOptions: function (component) {
        // Apex 호출
        this.apexCall(component, null, this, 'getUserInfo', {})
            .then($A.getCallback(function (result) {
                let userInfo = result.r;
    
                // console.log('userInfo :: ' + JSON.stringify(userInfo));
                component.set('v.userInfo', userInfo);
    
                // System Admin
                if (userInfo.Profile.Name === 'System Administrator' || userInfo.Profile.Name === '시스템 관리자') {
                    component.set('v.districtOptions', [
                        { 'label': 'Korea', 'value': 'Korea' },
                        { 'label': 'Global', 'value': 'Global' }
                    ]);
                }

                // only Global
                else if (userInfo.SalesOffice__c === '1140') {

                    component.set('v.district', 'Global');
                    component.set('v.districtOptions', [
                        { 'label': 'Global', 'value': 'Global' }
                    ]);

                }
                // only Korea 
                else {
                    
                    component.set('v.districtOptions', [
                        { 'label': 'Korea', 'value': 'Korea' }
                    ]);

                }

    
                // console.log('userInfo :: ' + JSON.stringify(userInfo));
    
                // Call updateRecordTypeOptions after setting districtOptions
                this.updateRecordTypeOptions(component);
    
            }.bind(this))) // Ensure correct `this` context for updateRecordTypeOptions
            .catch(function (error) {
                console.error('Error fetching user profile:', error);
            });
    },
    
    updateRecordTypeOptions: function (component) {
        var district = component.get("v.district");
        // console.log('district :: ' + district);
        var recordTypeOptions;

        if (district === "Korea") {
            recordTypeOptions = [
                { 'label': 'Year', 'value': 'Year' },
                { 'label': 'Half', 'value': 'Half' }
            ];
        } else if (district === "Global") {
            recordTypeOptions = [
                { 'label': 'Year', 'value': 'Year' },
                { 'label': 'Quarter', 'value': 'Quarter' }
            ];
        }

        component.set("v.recordTypeOptions", recordTypeOptions);

        // 선택된 recordType 값 초기화
        component.set("v.recordType", recordTypeOptions[0].value);
    },

    updatePeriodOptions: function (component) {
        var recordType = component.get("v.recordType");
        var periodOptions;
        var showPeriodOptions = true;

        if (recordType === "Year") {
            showPeriodOptions = false; // Year일 때는 Period 선택 숨김
        } else if (recordType === "Half") {
            periodOptions = [
                { 'label': '상반기', 'value': '상반기' },
                { 'label': '하반기', 'value': '하반기' }
            ];
        } else if (recordType === "Quarter") {
            periodOptions = [
                { 'label': 'Q1', 'value': 'Q1' },
                { 'label': 'Q2', 'value': 'Q2' },
                { 'label': 'Q3', 'value': 'Q3' },
                { 'label': 'Q4', 'value': 'Q4' }
            ];
        }

        component.set("v.periodOptions", periodOptions);
        component.set("v.showPeriodOptions", showPeriodOptions);
    },


    prepareRecords: function (excelData, expectedHeaders, selectedYear, selectedPeriod, templateType) {
        // console.log('prepareRecords 입성');

        var recordsToInsert = [];

        excelData.forEach(function (row, rowIndex) {
            // console.log('Row ' + (rowIndex + 1) + ':');

            var record = {}; // 새로운 record 객체를 만듦

            // row의 값을 배열로 변환하여 위치로 접근
            var rowValues = Object.values(row);

            expectedHeaders.forEach(function (header, index) {
                var columnValue = rowValues[index]; // n번째 컬럼 위치 값을 가져옴

                // header 이름 대신 위치를 key로 사용
                var key = 'Column_' + index; // "Column_0", "Column_1" 형식의 key 사용

                // record에 key를 키로, columnValue를 값으로 할당
                if (columnValue !== undefined) {
                    record[key] = columnValue;
                }
                // console.log('Column ' + key + ' (index ' + index + '): ' + columnValue);
            });

            // 선택된 연도 및 기간, 템플릿 유형 정보도 record에 추가
            record['TemplateType'] = templateType;
            record['Year'] = selectedYear;
            if (selectedPeriod != null) {
                record['Period'] = selectedPeriod;
                // console.log('selectedPeriod != null ');
            } else {
                // console.log('selectedPeriod is null ');
            }

            recordsToInsert.push(record); // recordsToInsert에 record 추가
        });

        // console.log('Prepared Records(JSON):', JSON.stringify(recordsToInsert));
        return recordsToInsert;
    },



})