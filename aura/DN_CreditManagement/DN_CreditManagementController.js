/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-21
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-05-30   yuhyun.park@sbtglobal.com   Initial Version
**/
({

    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        var dealerInfo = component.get("v.dealerInfo");

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

                // dealerInfo가 있을 경우에만 interfaceDealer003 호출
                if (dealerInfo) {
                    return helper.apexCall(component, event, helper, 'interfaceDealer003', {
                        fieldMap: dealerInfo
                    });
                } else {
                    console.warn('dealerInfo is empty. Skipping interfaceDealer003.');
                    return Promise.resolve(); // 빈 Promise 반환
                }

            }))
            .then($A.getCallback(function (result) {

                if (result && result.r && result.r.T_TCREDIT && result.r.T_DCREDIT) {

                    let creditSummary = result.r.T_TCREDIT;
                    let creditDetailList = result.r.T_DCREDIT;

                    console.log('creditSummary :: ' + JSON.stringify(creditSummary));
                    console.log('creditDetailList :: ' + JSON.stringify(creditDetailList));

                    // 날짜&금액 format 처리
                    creditDetailList = helper.cleanFieldsFormat(creditDetailList);

                    creditSummary = helper.multipleCurrency(creditSummary);
                    console.log('creditDetailList (after cleaning) :: ' + JSON.stringify(creditDetailList));

                    // return table에서 매핑 처리
                    component.set("v.creditSummary", creditSummary);
                    component.set("v.creditDetailList", creditDetailList);

                    console.log('creditDetailList (with dealerInfo) :: ' + JSON.stringify(creditDetailList));

                    // Header 한글화
                    var koreanCreditDetailList = helper.convertToKoreanFieldNames(creditDetailList);
                    component.set("v.koreanCreditDetailList", koreanCreditDetailList);
                    console.log('koreanCreditDetailList :: ' + koreanCreditDetailList);
                }

                // dealerInfo가 있을 경우에만 interfaceDealer010 호출
                if (component.get("v.dealerInfo")) {
                    return helper.apexCall(component, event, helper, 'interfaceDealer010', {
                        fieldMap: component.get("v.dealerInfo")
                    });
                } else {
                    console.warn('dealerInfo is empty. Skipping interfaceDealer010.');
                    return Promise.resolve(); // 빈 Promise 반환
                }
            }))

                  
            .then($A.getCallback(function (result) {
                if (result) {
                    // console.log('interfaceDealer010 result :: ' + JSON.stringify(result));

                    let resultMap = result.r;

                    let incomingCollect = {};

                    for (let i = 0; i <= 5; i++) {
                        let key = 'm' + i;                       // 'm0', 'm1', …, 'm5'
                        let arr = resultMap[key] || [];         // undefined 방지
                        incomingCollect[key] = (arr.length > 0 && arr[0].EST_AMT)
                            ? parseFloat(arr[0].EST_AMT)       // 값이 있으면 숫자로 변환
                            : 0;                                // 없으면 0으로 기본값
                    }

                    // console.log('incomingCollect :: ' + JSON.stringify(incomingCollect));
                    component.set("v.incomingCollect", incomingCollect);

                }
            }))
            .catch(function (error) {
                console.error('Error: ' + error.message);
            })
            .finally(function () {
                // 모든 호출 완료 후 로딩 상태 해제
                component.set('v.isLoading', false);
            });
    }




})