/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-07-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-08-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function (component, event, helper) {
        var baseUrl = window.location.origin;
        component.set("v.baseUrl", baseUrl);

        var today = new Date();
        var todayString = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
        component.set("v.dateTo", todayString);

        var firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        var firstDayString = firstDayOfMonth.getFullYear() + '-' + ('0' + (firstDayOfMonth.getMonth() + 1)).slice(-2) + '-' + ('0' + firstDayOfMonth.getDate()).slice(-2);
        component.set("v.dateFrom", firstDayString);

        component.set("v.isLoading", true);

        let action = component.get("c.getLoginUserInfo");
        
        action.setParams({ });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let r = response.getReturnValue();
                console.log(JSON.stringify(r, null, 2));
                console.log('init WCCode__c ::: ',r.workerInfo.Service_Territory__r.WCCode__c);
                console.log('test ::: ', r.isRepresentative);
                if (r.isRepresentative == true) {
                    component.set("v.isRepresentative", r.isRepresentative);
                    component.set("v.WorkCenterName", r.workerInfo.Service_Territory__r.Name);
                    component.set("v.WorkCenterCode", r.workerInfo.Service_Territory__r.WCCode__c);    
                }
                component.set("v.isLoading", false);
                component.set("v.isInit", true);
            } else {
                console.log("getLoginUserInfo Error");
                component.set("v.isLoading", false);
                component.set("v.isInit", true);
            }
        });
        $A.enqueueAction(action);        
    },

     // 워크센터 모달 열기 
     openDealerModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        var type = '워크센터';
        $A.createComponent("c:DN_dealerModal",
            {
                'type': type
                
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("dealerModal");
                    console.log("container", container);
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    handleDealerSelection: function (component, event, helper) {
        if (event.getParam("modalName") === "dealerModal" && event.getParam("actionName") === "selectDealer") {
            const message = event.getParam("message");
            component.find("workCenterInput").set("v.value", message.workCenterCode);
        }
    },

    // 검색 전 작업계획일 Validation
    handleDayCountCheck : function (component, event, helper) {
        var selectStartDate = component.get('v.dateFrom');
        var selectEndDate   = component.get('v.dateTo');
        var result = helper.daycounter(selectStartDate, selectEndDate);

        if (selectEndDate < selectStartDate) {
            helper.toast('WARNING', '시작일이 종료일 보다 클 수 없습니다.');
            selectEndDate = selectStartDate;
            component.set('v.dateTo', selectEndDate);
            component.find('endDate').focus();
            return ;
        }

        if (result > 365) {
            helper.toast('WARNING', '기간은 365일을 초과할 수 없습니다.');
            selectEndDate = selectStartDate;
            component.set('v.dateTo', selectEndDate);
            component.find('endDate').focus();
            return ;
        }
    },

    // ERP IF 조회
    handleSearch : function (component, event, helper) {
        let dateFrom    = component.get("v.dateFrom");
        let dateTo      = component.get("v.dateTo");
        let workCenterCode    = component.get("v.WorkCenterCode");
        let orderType    = component.get('v.orderTypeValue');
        let orderNum    = component.get('v.orderNum');

        console.log('WCCode__c ::: ',workCenterCode);

        if (!dateFrom || !dateTo) {
            helper.toast('WARNING', 'Check the settlement date you wish to view.');
            component.set('v.isLoading', false);
            return;
        }

        let fieldMap = {
            dateFrom      : dateFrom.replaceAll('-',''),
            dateTo       : dateTo.replaceAll('-',''),
            workCenterCode: workCenterCode ,
            orderType     : orderType,
            orderNumber   : orderNum.trim() ,
        };

        console.log('fieldMap to apex ::: ', JSON.stringify(fieldMap, null, 2));

        component.set('v.isLoading', true);
        
        helper.apexCall(component, event, helper, 'serviceCostAdjustment', {
            fieldMap : fieldMap
        })
        .then($A.getCallback(function(result) {
            const responseData = result.r.erpResponse;

            console.log('response Data ::: ', JSON.stringify(responseData, null, 2));

            if (responseData.ET_HD && responseData.ET_ITEM) {
                if (responseData.ET_HD.length === 0 || responseData.ET_ITEM.length === 0) {
                    helper.toast('SUCCESS', '조회된 Header 와 Item이 없습니다.');
                    component.set("v.searchHeaderList", []);
                    component.set("v.searchItemList", []);
                    component.set("v.isSearched", true);
                    component.set('v.isLoading', false);
                    return;
                }

                helper.toast('SUCCESS', 'Searched Success.');

                component.set("v.searchHeaderList", responseData.ET_HD);
                
                responseData.ET_ITEM.forEach(element => {
                    if(element.WEB_CHK =='X') {
                        element.WEB_CHK = true;
                    } else {
                        element.WEB_CHK = false;
                    }
                });
                component.set("v.searchItemList", responseData.ET_ITEM);
                
                // 엑셀데이터 가공 처리
                let headExcelData = [];
                let excelData = [];
                // 헤더 데이터 가공
                responseData.ET_HD.forEach(element => {
                    headExcelData.push({
                        '정산월' : element.SPMON,
                        '무상서비스' : element.TLCST.replace(/\B(?=(\d{3})+(?!\d))/g, ","),
                        '설치시운전' : element.INCST.replace(/\B(?=(\d{3})+(?!\d))/g, ","),
                        '납품후교육' : element.EDCST.replace(/\B(?=(\d{3})+(?!\d))/g, ","),
                        '업무대행'  : element.COCST.replace(/\B(?=(\d{3})+(?!\d))/g, ","),
                        '합계' : element.TTCST.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                    });
                });
                component.set('v.headExcelData',headExcelData);
                responseData.ET_ITEM.forEach(element => {
                    excelData.push({
                        '오더유형': element.ILATX,
                        '오더번호': parseInt(element.AUFNR),
                        '고객명' : element.NAME1,
                        '기종' : element.TYPBZ, 
                        '호기' : element.SERNR,
                        '접수일' : element.ERDAT.replaceAll('-', '.'),
                        '확정일' : element.ERSDA.replaceAll('-', '.'),
                        'Work Center' : element.KTEXT,
                        '작업자' : element.SVCMAN_NAME,
                        '작업내용' : element.LTXA1,
                        '시작일' : element.ISDD.replaceAll('-', '.'),
                        '시작시간' : element.ISDZ,
                        '종료일' : element.AUSBS.replaceAll('-', '.'),
                        '종료시간' : element.AUZTB,
                        '작업유형' : element.WORKCD_NM,
                        '메인' : element.MAINHR,
                        '가설치' : element.TEMPHR,
                        '옵션' : element.OPTNHR,
                        '기타' : element.ETC_HR,
                        '합계시간' : element.ISMNW,
                        '할증여부' : element.EXFLG,
                        '작업합계' : element.WORK_SUM,
                        '표준공수' : element.STD_MH,
                        '지급공수' : element.PAY_MH,
                        '금액' : element.TLCST.replace(/\B(?=(\d{3})+(?!\d))/g, ",")

                    })
                });
                
                component.set('v.excelData',excelData);
                component.set("v.isSearched", true);
                // component.set('v.isLoading', false);
            } else if(responseData.ET_HD && !responseData.ET_ITEM) {
                helper.toast('SUCCESS', 'Item 데이터가 없습니다.');
                component.set("v.searchHeaderList", responseData.ET_HD);
                component.set("v.searchItemList", []);
                component.set("v.isSearched", true);
                // component.set('v.isLoading', false);
            } else if(!responseData.ET_HD && responseData.ET_ITEM) {
                helper.toast('SUCCESS', 'Header 데이터가 없습니다.');
                component.set("v.searchHeaderList", []);
                component.set("v.searchItemList", responseData.ET_ITEM);
                component.set("v.isSearched", true);
                // component.set('v.isLoading', false);
            } else {
                helper.toast('SUCCESS', '조회된 Header 와 Item이 없습니다.');
                component.set("v.searchHeaderList", []);
                component.set("v.searchItemList", []);
                component.set("v.isSearched", true);
                // component.set('v.isLoading', false);
            }
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# error : ' + error.message);
            // component.set('v.isLoading', false);
        })
        .finally(() => {
            component.set('v.isLoading', false);
        });
    },

    //비용정산 저장(I/F)
    handleSave: function (component, event, helper) {
        component.set('v.isLoading',true);
        console.log(JSON.stringify(component.get("v.selectItemList")),' < ==');
        helper.apexCall(component, event, helper, 'serviceCostAdjustmentSend', {
            saveList : component.get("v.selectItemList")
        })
        .then($A.getCallback(function(result) {
            component.set('v.selectItemList',[]);
            component.set('v.searchHeaderList',[]);
            component.set('v.searchItemList',[]);
            const responseData = result.r.erpResponse;
            console.log('response Data ::: ', JSON.stringify(responseData));

            $A.get('e.force:refreshView').fire();
            let action = component.get("c.handleSearch");
            action.setParams({ });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let r = response.getReturnValue();
                } else {
                    console.log("serviceCostAdjustmentSend Error");
                }
            });
            $A.enqueueAction(action);
            
            
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    toggleAllItem: function (component, event, helper) {
        
        let allCheckBox = component.find('checkboxAll')
        const items = component.get("v.searchItemList");
        let selectList = [];
        const selectAll = event.getSource().get("v.checked");
        for(let i=0; i<allCheckBox.length; i++) {
            
            allCheckBox[i].set('v.checked',selectAll);
            selectList.push({
                AUFNR : items[i].AUFNR,
                SEQNO : items[i].SEQNO,
                WEB_CHK : selectAll? 'X' : ''
            });
        }
      
        
        component.set('v.selectItemList',selectList);
        console.log(JSON.stringify(component.get('v.selectItemList')), ' 선택한 값들');
    },

    // 목록에서 선택값
    selectItem: function (component, event, helper) {
        let selectList = component.get('v.selectItemList');
        let check = event.getSource().get("v.checked");
        let row = event.getSource().get("v.name");
        
        // 검색결과 및 선택값 추출
        let allList = component.get('v.searchItemList');
        let checkSelect = allList[row];
        selectList.push({
            AUFNR : checkSelect.AUFNR,
            SEQNO : checkSelect.SEQNO,
            WEB_CHK : check? 'X' : ''
        });
        
        component.set('v.selectItemList',selectList)
        console.log(JSON.stringify(component.get("v.selectItemList")), ' < ==111');
    },

    //오더번호 클릭시 서비스 페이지로 이동
    openOrderWrapper : function (component, event, helper) {
        const element = event.currentTarget;
        const fullOrderNumber = event.currentTarget.dataset.orderNumber;
        const orderNumber = fullOrderNumber.substring(3); // 왼쪽 3자리 제거
        console.log('element ::: ',element);
        console.log('fullOrderNumber ::: ',fullOrderNumber);
        console.log('orderNumber ::: ',orderNumber);
        //css 변경 위해 class 추가
        element.classList.add("visited");
        
        component.set("v.orderNumber", orderNumber);

        var currentUrl = component.get("v.baseUrl");
        if (currentUrl.includes('--dev.sandbox')) {
            currentUrl += '/partners/s/service-wrap?orderNumber=' + orderNumber;
        } else {
            currentUrl += '/s/service-wrap?orderNumber=' + orderNumber;
        }
        console.log('currentUrl ::: ', currentUrl);
        window.open(currentUrl, "_blank");
    },

    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        table1.scrollTo({ top: scrollY, left: 0, behavior: 'auto' });
    },
    
})