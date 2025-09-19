/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-18
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-08   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    toast: function (component, title, message, variant) {
        // console.log(' << toast >> ');
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
        let self = this; // this를 저장
        // Apex 호출
        this.apexCall(component, null, this, 'getUserInfo', {})
            .then($A.getCallback(function (result) {
                let userInfo = result.r;

                // console.log('userInfo :: ' + JSON.stringify(userInfo));
                component.set('v.userInfo', userInfo);

                // DNSA 유저는 접근 차단
                if(userInfo.SalesOrganization__c == '4140'){
                    // console.log('DNSA User');

                    self.toast(component, 'Error', 'Access is not allowed.', 'error');
                    window.history.back();                    


                } else {

                    // System Admin
                    if(userInfo.Profile.Name == 'System Administrator' || userInfo.Profile.Name == '시스템 관리자'){
                        component.set('v.districtOptions', [
                            { 'label': 'Korea', 'value': 'Korea' },
                            { 'label': 'Global', 'value': 'Global' }
                        ]);
                    }

                    // Global
                    else if (userInfo.SalesOffice__c == '1140') {

                        component.set('v.districtOptions', [
                            { 'label': 'Global', 'value': 'Global' }
                        ]);

                        component.set('v.district', 'Global');

                    // Korea
                    }else {

                        component.set('v.districtOptions', [
                            { 'label': 'Korea', 'value': 'Korea' }
                        ]);
                    }

                    // // only Korea
                    // else if (userInfo.SalesDistrict__c == 'A1KR') {
                    //     component.set('v.districtOptions', [
                    //         { 'label': 'Korea', 'value': 'Korea' }
                    //     ]);

                    // // only Global 
                    // }else {
                    //     component.set('v.districtOptions', [
                    //         { 'label': 'Global', 'value': 'Global' }
                    //     ]);
                    //     component.set('v.district', 'Global');
                    // }


                }

            }))
            .catch(function (error) {
                console.error('Error fetching user info:', error);
            });
    },


    prepareRecords: function (excelData, expectedHeaders, selectedYear, district) {

        // console.log('prepareRecords 입성');

        var recordsToInsert = [];

        excelData.forEach(function (row, rowIndex) {

            // 새로운 record 객체
            var record = {};

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

            // Year, Record Type 추가
            record['Year'] = selectedYear;
            record['RecordType'] = district;

            recordsToInsert.push(record); // recordsToInsert에 record 추가

        });

        // console.log('Prepared Records(JSON):', JSON.stringify(recordsToInsert));
        return recordsToInsert;
    },



})