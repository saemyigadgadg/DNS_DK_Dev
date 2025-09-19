/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-06-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        
        // 로컬스토리지에 남은 caseNo 있으면 우선 사용 - 추가
        const stored = localStorage.getItem('caseNo');
        if (stored) {
            component.set('v.caseNo', stored);
            localStorage.removeItem('caseNo');
        }
        
        // 사용자 정보 셋팅
        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            console.log('사용자(=딜러) 정보 가져오기');
            let response = result.r;
            
            component.set('v.dealerInfo', response);
            console.log('dealerInfo :: ' +JSON.stringify(response,null,4));
            
            /* 기존 코드
            const urlParams = new URLSearchParams(window.location.search);
            const caseNumber = urlParams.get('orderNumber');
            component.set('v.caseNo', caseNumber);
            */

            const pageRef = component.get('v.pageReference');
            let caseNumber = null;
            // 메인 오그
            if (pageRef && pageRef.state && pageRef.state.c__orderNumber) {
                caseNumber = pageRef.state.c__orderNumber;
            // 딜러 포탈
            } else {
                const urlParams = new URLSearchParams(window.location.search);
                caseNumber = urlParams.get('orderNumber');
            }
            
            component.set('v.caseNo', caseNumber);

            // 기존 코드
            //return helper.apexCall(component, 'GetTicketInfo', { dealerInfo : response, erpPSONo : null, accId : null, caseNo : caseNumber, machineName : null, assetName : null, startDate : null, endtDate : null });
            return helper.apexCall(component, 'GetTicketInfo', { dealerInfo : response, erpPSONo : null, accId : null, caseNo : caseNumber, machineName : null, assetName : null, startDate : null, endDate : null });
        }))
        .then($A.getCallback(function(result) {
            let response = result.r;
            var ticketList = helper.processResponse(component, response);
            component.set('v.ticketInfo', ticketList[0]);
            console.log('ticketInfo :: ' +JSON.stringify(component.get('v.ticketInfo'),null,4));
        }))            
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.log('에러 발생 사유 :: ' + errors[0].message);
            } else {
                console.log('에러 발생 사유 :: 알 수 없음');
            }
        }))


    },
    // 납품 후 교육 목록을 통해서 들어왔을 때 생기는 뒤로가기 버튼
    /* 기존 코드
    goBack: function (component, event, helper) {
        component.set('v.isLoading', true);
        localStorage.removeItem('caseNo');
        const navTrainingList = component.find("navTrainingList");
        const page = {
            type: "standard__webPage",
            attributes: {
                // url: "/partners/s/post-delivery-training-list",  // 개발
                url: "/post-delivery-training-list",     // 운영
            }
        };
        navTrainingList.navigate(page);
        component.set('v.isLoading', false);
    },
    */

    // 납품 후 교육 목록을 통해서 들어왔을 때 생기는 뒤로가기 버튼 - 딜러포탈 / 메인오그 분기
    goBack: function (component, event, helper) {
         component.set('v.isLoading', true);
         localStorage.removeItem('caseNo');
         const nav = component.find("navTrainingList");
         const path = window.location.pathname;
 
         // 메인 오그(Lightning Experience)일 경우
         if (!path.includes('/s/')) {
             nav.navigate({
                 type: 'standard__navItemPage',
                 attributes: { apiName: 'DN_postDeliveryTrainingList' }
             });
         }
         // 딜러포탈(Experience Cloud)일 경우
         else {
             nav.navigate({
                 type: 'standard__webPage',
                 attributes: { url: '/post-delivery-training-list' }
             });
         }

        component.set('v.isLoading', false);
    },



    doDownload : function(component, event, helper) {
        let fId = event.getSource().get("v.value");
        console.log("File ID: " + fId);

        let baseUrl = window.location.origin;
        let dlUrl = component.get('v.dlUrl');
        // let downloadUrl = baseUrl + '/partners/sfc/servlet.shepherd/document/download/' + fId;  // 개발
        // let downloadUrl = baseUrl + '/sfc/servlet.shepherd/document/download/' + fId;  // 운영
        let downloadUrl = baseUrl + dlUrl + fId;
        console.log('Download URL:', downloadUrl);
        window.open(downloadUrl, '_blank');
        // return downloadUrl;
    },
})