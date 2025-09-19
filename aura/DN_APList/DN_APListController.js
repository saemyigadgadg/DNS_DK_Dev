/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 03-17-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-20   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        helper.apexCall(component, event, helper, 'getLoginUserInfo', {
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result),' < ===responseData');
            component.set('v.WorkCenter', {
                Name : result.r.workerInfo.Account.Name,
                I_KUNNR : '000'+result.r.workerInfo.Account.CustomerCode__c,
                I_SPART : result.r.workerInfo.Division__c,
                I_VKORG : result.r.workerInfo.SalesOrganization__c,
                I_VTWEG : result.r.workerInfo.DistributionChannel__c,
                CustomerCode : result.r.workerInfo.Account.CustomerCode__c,
                //
            })
            
            console.log(JSON.stringify(component.get('v.WorkCenter')), ' testetset');
            const todaySet = new Date();
            // const msInADay = 24 * 60 * 60 * 1000;
            // const daySet = new Date(todaySet.getTime() - parseInt(22) * msInADay);

            // DD 250305 기간 시작 날짜 수정.
            const sDate = new Date();
            sDate.setDate(1);

            // Start와 End 필드 값 설정
            component.find('Start').set('v.value', sDate.toISOString());
            component.find('End').set('v.value', todaySet.toISOString());
            
            let sd = sDate.toISOString();
            let ed = todaySet.toISOString();

            sd = sd.split('T')[0];
            ed = ed.split('T')[0];

            component.set('v.searchStartDate', sd);
            component.set('v.searchEndDate', ed);
        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
        });
    },

    searchResultList: function (component, event, helper) {
        component.set('v.isLoading', true);
        let workCenter = component.get('v.WorkCenter');

        let startDate = component.get('v.searchStartDate');
        let endDate = component.get('v.searchEndDate');

        let diffDate = helper.dayCounter(startDate, endDate);

        if (diffDate > 180) {
            helper.toast('WARNING', '검색 기간은 180일을 초과할 수 없습니다.');
            component.set('v.isLoading', false);
            return ;
        } else if (diffDate < 0) {
            helper.toast('WARNING', '시작 일자가 종료 일자보다 클 수 없습니다.');
            component.set('v.isLoading', false);
            return ;
        }

        startDate = startDate.replace(/-/g,'');
        endDate = endDate.replace(/-/g,'');

        console.log('search sd >> '+startDate);
        console.log('search ed >> '+endDate);

        console.log('diffDate >> ' +JSON.stringify(diffDate,null,4));

        let resultList =[];
        let excelList =[];
        let serachSet = {
            I_KUNNR : workCenter.I_KUNNR,//workCenter.CustomerCode__c, // 딜러코드 : 0001244220 / 명성기계
            I_SPART : workCenter.I_SPART,//workCenter.I_SPART, // 40
            I_VKORG : workCenter.I_VKORG,//workCenter.I_VKORG, // 1846
            I_VTWEG : workCenter.I_VTWEG,//workCenter.I_VTWEG, // 10
            I_F_VBELN : component.get('v.startDocNum'),
            I_T_VBELN : component.get('v.endDocNum'),
            I_F_BLDAT : startDate,
            I_T_BLDAT : endDate
        }
        console.log('serachSet :::', JSON.stringify(serachSet));
        helper.apexCall(component, event, helper, 'getInvoiceList', {
            search : serachSet
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result.r.T_INVOICE),' < ===responseData');
            for(let i=0;i<result.r.T_INVOICE.length; i++) {
                let rowData = result.r.T_INVOICE[i];
                rowData.WRBTR = parseInt(rowData.WRBTR).toLocaleString('ko-KR');
                rowData.WRSHB = parseInt(rowData.WRSHB).toLocaleString('ko-KR');
                excelList.push({
                    '번호' : i+1,
                    'Billing No': rowData.VBELN,
                    '지급조건': rowData.VTEXT,
                    '순서' : rowData.BUZEI,
                    '문서일자' : rowData.BLDAT,
                    '만기일' : rowData.FAEDT,
                    '금액' : rowData.WRBTR,
                    '통화' :rowData.WAERK,
                    '미결잔액' : rowData.WRSHB 
                })
            }
            component.set('v.excelList', excelList);
            component.set('v.resultList', result.r.T_INVOICE);
            component.set('v.isLoading', false);    
        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
           component.set('v.isLoading', false);
        });
        //component.set('v.resultList', resultList);
        
    },

    openAPListPopupModal: function (component, event, helper) {
        var docNum = event.target.value;
        console.log('docNum', docNum);
        $A.createComponent("c:DN_APListPopupModal",
            {
                'docNum' : docNum
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("apListPopupModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }
})