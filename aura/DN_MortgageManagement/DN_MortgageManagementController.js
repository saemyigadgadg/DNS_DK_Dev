/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-05-31   yuhyun.park@sbtglobal.com   Initial Version
**/
({

    doInit: function (component, event, helper) {

        component.set('v.isLoading', true);

        var dealerInfo = component.get("v.dealerInfo");
        var processOptions = [
            { 'label': '진행중', 'value': 'Process' },
            { 'label': '취소(기한완료)', 'value': 'Overdue' }
        ]
        var processOption = component.get("v.processOption");

        component.set("v.processOptions", processOptions);

        // 첫번째 Apex : Dealer Info 
        helper.apexCall(component, event, helper, 'getDealerInfo', {
            recordId: component.get('v.recordId')
        })
            .then($A.getCallback(function (result) {

                let dealerInfoWrapper = result.r;

                // console.log('dealerInfoWrapper :: ' + JSON.stringify(dealerInfoWrapper));

                if (dealerInfoWrapper.userType == 'ExperienceCloudUser') {

                    dealerInfo = {
                        "dealerCode": dealerInfoWrapper.info.Account.CustomerCode__c,
                        "dealerName": dealerInfoWrapper.info.Account.Name,
                        "companyCode": dealerInfoWrapper.info.SalesOrganization__c,
                        "salesArea1": dealerInfoWrapper.info.DistributionChannel__c,
                        "salesArea2": dealerInfoWrapper.info.Division__c,
                        "representative": dealerInfoWrapper.info.Account.Representative__c
                    }

                } else if (dealerInfoWrapper.userType == 'InternalUser') {

                    dealerInfo = {
                        "dealerCode": dealerInfoWrapper.info.CustomerCode__c,
                        "dealerName": dealerInfoWrapper.info.Name,
                        "companyCode": dealerInfoWrapper.info.SalesOrganization__c,
                        "salesArea1": dealerInfoWrapper.info.DistributionChannel__c,
                        "salesArea2": dealerInfoWrapper.info.Division__c,
                        "representative": dealerInfoWrapper.info.Representative__c
                    }
                }

                // console.log('dealerInfo :: ' + JSON.stringify(dealerInfo));
                component.set("v.dealerInfo", dealerInfo);

                // dealerInfo가 있을 경우에만 interfaceDealer004 호출
                if (dealerInfo) {
                    return helper.apexCall(component, event, helper, 'interfaceDealer004', {
                        fieldMap: dealerInfo,
                        processOption: processOption
                    });
                } else {
                    console.warn('dealerInfo is empty. Skipping interfaceDealer004.');
                    return Promise.resolve(); // 빈 Promise 반환
                }

            }))
            .then($A.getCallback(function (result) {

                if (result && result.r && result.r.T_RETURN) {
                    let mortgageDetailList = result.r.T_RETURN;

                    // console.log('mortgageDetailList :: ' + JSON.stringify(mortgageDetailList));

                    // 날짜&금액 format 처리
                    mortgageDetailList = helper.cleanFieldsFormat(mortgageDetailList);
                    // console.log('mortgageDetailList (after cleaning) :: ' + JSON.stringify(mortgageDetailList));

                    // return table에서 매핑 처리
                    component.set("v.mortgageDetailList", mortgageDetailList);

                    // console.log('mortgageDetailList (with dealerInfo) :: ' + JSON.stringify(mortgageDetailList));

                    // Header 한글화
                    var koreanMortgageDetailList = helper.convertToKoreanFieldNames(mortgageDetailList);
                    component.set("v.koreanMortgageDetailList", koreanMortgageDetailList);
                    // console.log('koreanMortgageDetailList :: ' + koreanMortgageDetailList);

                    // MortgageAmount 합산
                    if (processOption === 'Process') {
                        // console.log('MortgageAmount 합산 !!');
                        helper.apexCall(component, event, helper, 'updateTotalMortgageAmount', {
                            fieldMapList: mortgageDetailList,
                            recordId: component.get('v.recordId')
                        }).then($A.getCallback(function () {
                            // 레코드 새로고침
                            $A.get('e.force:refreshView').fire();
                        }));
                    }
                }

            }))
            .catch(function (error) {
                console.error('Error: ' + error.message);
            })
            .finally(function () {
                // 모든 호출 완료 후 로딩 상태 해제
                component.set('v.isLoading', false);
            });

    },


    searchMortgageDetailList: function (component, event, helper) {
        component.set("v.isLoading", true);

        // var mortgageDetailList = component.get("v.mortgageDetailList");
        var processOption = component.get("v.processOption");
        var dealerInfo = component.get("v.dealerInfo");

        // console.log('processOption :: ' + processOption);
        // console.log('dealerInfo :: ' + JSON.stringify(dealerInfo));


        helper.apexCall(component, event, helper, 'interfaceDealer004', {
            fieldMap: dealerInfo,
            processOption: processOption
        })
            .then($A.getCallback(function (result) {

                let filteredMortgageList = result.r.T_RETURN;

                // console.log('filteredMortgageList :: ' + JSON.stringify(filteredMortgageList));

                // 날짜&금액 format 처리
                filteredMortgageList = helper.cleanFieldsFormat(filteredMortgageList);
                // console.log('filteredMortgageList (after cleaning) :: ' + JSON.stringify(filteredMortgageList));

                // reutrn table에서 맵핑 처리
                component.set("v.mortgageDetailList", filteredMortgageList);

                // Header 한글화
                var koreanMortgageDetailList = helper.convertToKoreanFieldNames(filteredMortgageList);
                component.set("v.koreanMortgageDetailList", koreanMortgageDetailList);
                // console.log('koreanMortgageDetailList :: ' + koreanMortgageDetailList);

                // MortgageAmount 합산
                if (processOption === 'Process') {
                    // console.log('MortgageAmount 합산 !!');
                    helper.apexCall(component, event, helper, 'updateTotalMortgageAmount', {
                        fieldMapList: filteredMortgageList,
                        recordId: component.get('v.recordId')
                    }).then($A.getCallback(function () {
                        // 레코드 새로고침
                        $A.get('e.force:refreshView').fire();
                    }));
                }
            }))

            .catch(function (error) {
                console.error('Error: ' + error.message);
            })

        component.set("v.isLoading", false);

    },


})