/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-23-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-07-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function (component, event, helper) {
        var baseUrl = window.location.origin;
        component.set("v.baseUrl", baseUrl);
        
        helper.apexCall(component, event, helper, 'getLoginUserInfo', {
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result), ' <M ==result');
            let urlSet = '/apex/DN_ReturnedScrapReceipt';
            component.set('v.apexUrl', urlSet);
  
            component.set('v.WorkCenter', {
                Name : result.r.workerInfo.Service_Territory__r.Name,
                Code : result.r.workerInfo.Service_Territory__r.WCID__c,
                UserName : result.r.workerInfo.RelatedRecord.Name,
                WERKS : result.r.workerInfo.RelatedRecord.Plant__c,
                CustomerCode : result.r.workerInfo.Service_Territory__r.WCCode__c
            })

            const todaySet = new Date();
            const msInADay = 24 * 60 * 60 * 1000;
            const firstDayOfMonth = new Date(Date.UTC(todaySet.getFullYear(), todaySet.getMonth(), 1));
            console.log(firstDayOfMonth.toLocaleDateString(),' < ==firstDayOfMonth');
            component.set('v.StartDate',firstDayOfMonth.toISOString());
            component.set('v.EndDate',todaySet.toISOString());            
        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
        });
    },
    //검색
    doSearch : function (component, event, helper) {
        let workCenter = component.get('v.WorkCenter');
        let searchSet ={
            I_DATUM_FROM : component.get("v.StartDate"), // 접수일 시작
            I_DATUM_TO : component.get("v.EndDate"), // 접수일 종료
            I_ARBPL : workCenter.CustomerCode, // 딜러정보 추후 CRM에 데이터 적재시 변경
            I_RETURN_TYPE : component.get('v.returnValue'), // 반납구분
            I_RETURN_YN : component.get('v.returnStatusValue'), //반납여부
            I_AUFNR : component.get('v.OrderNumber'), //오더번호
            I_MATNR : component.get('v.PartsNumber'), //품번
            WERKS : workCenter.WERKS
        }
        console.log(JSON.stringify(searchSet), ' < ===searchSet');

        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'getNonReturnedList', {
            search : searchSet
        })
        .then($A.getCallback(function(result) {

            let excelData = [];
            if(result.r.T_LIST.length> 0) {
                
                console.log(JSON.stringify(result.r.T_LIST), ' < ===result.r.T_LIST');

                result.r.T_LIST.forEach(element => {
                    element.AUFNR = element.AUFNR.substring(3,element.AUFNR.length);
                    switch (element.RETURN_TYPE) {
                        case '1':
                            element.RETURN_TYPE = '신품';
                            break;
                        case '2':
                            element.RETURN_TYPE = '폐품';
                            break;
                        case '3':
                            element.RETURN_TYPE = '소모성';
                            break;    
                        case '4':
                            element.RETURN_TYPE = '망실';
                            break;
                        case '5':
                            element.RETURN_TYPE = '인수증';
                            break;     
                        case '6':
                            element.RETURN_TYPE = '해외부품';
                            break;            
                        case '7':
                            element.RETURN_TYPE = '미반납 대상';
                            break;
                    } 
                    element.NO_QTY = parseInt(element.NO_QTY);
                    element.PRT_DATE  = element.PRT_DATE + ' ' + element.PRT_TIME;

                    console.log(element.RETURN_TYPE,' < ==element.RETURN_TYPE');

                    excelData.push({
                        '오더번호': element.AUFNR,
                        '기종':element.TYPBZ,
                        '장비번호':element.SERNR,
                        '고객사':element.NAME1,
                        '품번':element.MATNR,
                        '품명':element.MAKTX,
                        '미반납수량':element.NO_QTY,
                        '반납구분':element.RETURN_TYPE,
                        '공급구분':element.SUPPLY_TYPE,
                        '대리점':element.NAME2,
                        '반납여부':element.RETURN_END_YN,
                        'Work Center':element.KTEXT,
                        '작업자':element.SVCMAN,
                        '내역':element.TEXT,
                        '전표 발행일자':element.PRT_DATE
                    })
                });
                component.set('v.excelData', excelData);
                component.set('v.nonReturnList', result.r.T_LIST);     
            } else {
                component.set('v.nonReturnList', "");
                component.set('v.isLoading', false);
                helper.toast("WARNING", "해당 검색에 조회건이 없습니다.");
                return;
            }
            component.set('v.isLoading', false);

        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
           component.set('v.isLoading', false);
        });
    },

    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();

        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

    // 전표발행 시 선택
    handleCheck: function (component, event, helper) { 
        let allData = component.get('v.nonReturnList');
        let selectedList = component.get('v.selectedList');
        let check = event.getSource().get("v.checked");
        let row = event.getSource().get("v.name");
        console.log(row,' < ===row');

        if(check) {
            selectedList.push(allData[row]);
        } else {
            selectedList = selectedList.filter(item => item !== allData[row]);
        }
        console.log(JSON.stringify(selectedList), ' < ==selectedList');
        component.set('v.selectedList', selectedList);
    },

    //전체 선택
    selectAll: function (component, event, helper) { 
        let checkboxes = component.find("checkbox");
        let isChecked = component.find("headerCheckbox").get("v.checked");
        let allData = component.get('v.nonReturnList');
        let selectedIndices = [];
        if (Array.isArray(checkboxes)) {
            checkboxes.forEach(function (checkbox, index) {
                checkbox.set("v.checked", isChecked);
                if (isChecked) {
                    selectedIndices.push(allData[index]);
                }
            });
        } else {
            checkboxes.set("v.checked", isChecked);
            if (isChecked) {
                selectedIndices.push(allData[0]);
            }
        }
        component.set('v.selectedList',selectedIndices);
    },

    // 전표발행 모달 open
    openScrapReceipt: function (component, event, helper) {
        
        let isVal = true;
        let selectedList = component.get('v.selectedList');

        console.log('responseData ::: ', JSON.stringify(selectedList, null, 2));

        selectedList.forEach(element => {
            console.log(element.RETURN_TYPE,' <> ==element.RETURN_TYPE');
            if(element.RETURN_TYPE =='') {
                helper.toast("WARNING", "조치결과 입력 -> 부품사용내역 -> 반납구분 입력-> 저장 후 전표발행을 진행하여 주세요"); // 데이터가 없을시
                isVal = false;
                return;
            }

            // if (element.RETURN_TYPE === '신품') {
            //     helper.toast("WARNING", "반납정보 업데이트 후 전표발행하세요.");
            //     isVal = false;
            //     return;
            // }
        });
        if(selectedList.length ==0) {
            helper.toast("WARNING", "체크박스를 선택해주세요"); // 데이터가 없을시
            isVal = false;
            return;
        }
        // 벨 체크후 실행

        component.set('v.isLoading', true);

        if(isVal) {
            let searchSet  = [];
            let MATNR = '';
            let AUFNR ='';
            selectedList.forEach(element => {
                searchSet.push({
                    AUFNR : '000'+element.AUFNR,
                    MATNR : element.MATNR
                });    
                MATNR += element.MATNR+',';
                AUFNR += element.AUFNR+',';
            });
            console.log(MATNR, ' < ==MATNR');
            console.log(AUFNR, ' < ==AUFNR');
            MATNR = MATNR.substring(0, MATNR.length-1);
            AUFNR = AUFNR.substring(0, AUFNR.length-1);
            console.log('selectedList ::: ', JSON.stringify(component.get('v.selectedList'), null, 2));

            var currentUrl = component.get("v.baseUrl");

            if (currentUrl.includes("--dev.sandbox")) {
                currentUrl += "/partners/apex/DN_ReturnedScrapReceipt?MATNR=" + MATNR + "&AUFNR=" + AUFNR;
            } else {
                currentUrl += "/apex/DN_ReturnedScrapReceipt?MATNR=" + MATNR + "&AUFNR=" + AUFNR;
            }
            
            component.set('v.apexUrl', currentUrl);
            console.log('apexUrl ::: ', JSON.stringify(component.get('v.apexUrl'), null, 2));
            component.set("v.pdfModalOpen", true);
        }
        
        component.set('v.isLoading', false);
        
    },

    //프린트 모달 close
    modalCancel : function (component, event, helper) {
        component.set("v.pdfModalOpen", false);
    },
})