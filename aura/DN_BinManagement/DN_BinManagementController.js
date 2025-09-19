/**
 * @author            : Jun-Yeong Choi
 * @Description       : 
 * @last modified on  : 01-10-2025
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.pageMap',{});
        //디폴트 쿼리 설정
        helper.setQuery(component);
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(" setSubscriptionLMC");
            console.log(JSON.stringify(params), ' < ==BINMANAGEMENTCONTROLER');
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach':
                    helper.getDataQuery(component, params.type, '검색이 완료되었습니다.')
                        .then($A.getCallback(function(result) {
                            component.set('v.isExcelData', false);
                            component.set('v.isExcelButton', false);
                            component.set('v.excelData', []);
                            component.set('v.pageMap', {});
                            let batchSize = 5; // 한 번에 실행할 요청 개수
                            let promises = [];
                            let totalRecord = component.get('v.totalRecordSize');
                            const TOTALSIZE = Math.ceil(totalRecord / 200);
                            console.log(TOTALSIZE, ' :::TOTALSIZE');
                            let batchPromises = [];
                            for (let i = 0; i < TOTALSIZE; i++) {
                                //helper.setExcelData(component, i+1)
                                console.log(i+1, ' iiiiiii::');
                                promises.push(
                                    helper.setExcelData(component, i+1)
                                ); 
                                if (promises.length === batchSize || i === TOTALSIZE - 1) {
                                    batchPromises.push(Promise.allSettled(promises));
                                    promises = [];  // 초기화 후 다음 배치 준비
                                }
                            }
                            return Promise.all(batchPromises);
                        })).then($A.getCallback(function(result) {
                            let totalRecord = component.get('v.totalRecordSize');
                            const TOTALSIZE = Math.ceil(totalRecord / 200);
                            console.log(TOTALSIZE,' :: TOTALSIZE');
                            console.log(totalRecord,' :: totalRecord');
                            let excelMap = component.get('v.pageMap');
                            console.log(JSON.stringify(excelMap[1]),' :: excelMap');
                            let userInfo = component.get('v.currentUserInfo');
                            console.log(userInfo,' :: userInfo')
                            let excelName = `${userInfo.accountName}_저장 위치`;
                            console.log(excelName,' ::: excelName');
                            let exceldata = []; 
                            for(let i = 0; i < TOTALSIZE; i++) {
                                exceldata.push(...excelMap[i+1]);
                            }
                            console.log(exceldata.length,' :: exceldata');
                            component.set('v.excelData',exceldata);
                            component.set('v.excelName',excelName);
                            component.set('v.isExcelData', true);
                            helper.excelDataSet(component)
                                .then($A.getCallback(function(message) {
                                    if(component.get('v.isExcelButton')) {
                                        console.log('test111');
                                        helper.handleExcelDownload(component,params.type);    
                                        component.set('v.isExcelButton', false);
                                        component.set('v.isLoading', false);
                                    }
                                }))
                                .catch($A.getCallback(function(error) {
                                    console.error('Excel 생성 실패:', error);
                                    //alert('Excel 파일 생성 중 오류가 발생했습니다.');
                                }));
                        }))
                        .catch(error => {
                            console.log(error,' :: sserror');
                        })
                    break;
                case 'Delete':  // 저장위치 삭제
                    helper.setDelete(component,params.type);
                    break;
                case 'ExcelDownload': 
                    component.set('v.isLoading', true);
                    component.set('v.isExcelButton', true);
                    if(component.get('v.isExcelData')) {
                        helper.handleExcelDownload(component,params.type);    
                        component.set('v.isExcelButton', false)
                    }
                    // if(component.get('v.isExcelData')) {
                    //     if(component.get('v.isExcelButton')) {
                    //         helper.handleExcel(component,params.type);    
                    //     } else {
                    //         component.set('v.isExcelButton', true);
                    //     }
                    // } else {
                    //     component.set('v.isExcelButton', true);
                    // }
                    //component.set('v.isExcelData', false);                    
                    break;
                case 'Output':
                    helper.handleOutput(component,params.type);
                    break;    
                case 'PageChnage':
                    //console.log(JSON.stringify(msg), ' msg');
                    component.set('v.nextPage',params.message.nextpage);
                    component.set('v.currentPage',params.message.currentPage);
                    helper.getDataQuery(component,params.type, '검색이 완료되었습니다.');
                    break; 
                case 'Create':
                    console.log('table !!');
                    helper.getDataQuery(component,'Seach','생성되었습니다.');
                default:
                    break;
            }  
        }
    },
    // 체크박스 선택
    handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        let allList = component.get('v.recordList');
        let seletedList = component.get('v.seletedList');
        if(check) {
            seletedList.push(allList[index]);
        } else {
            seletedList = seletedList.filter(item => item !== allList[index]);
        }
        component.set('v.seletedList', seletedList);
    },
    //올 선택
    selectAll: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let checkboxes = component.find("checkbox");
        let allList = component.get('v.recordList');
        let seletedList = component.get('v.seletedList');
        console.log(check,' ::: check');
        if(check) {
            checkboxes.forEach(function (checkbox, index) {
                checkbox.set("v.checked", check);
                seletedList.push(allList[index]);
            });
        } else {
            checkboxes.forEach(function (checkbox, index) {
                checkbox.set("v.checked", check);
            });
            seletedList = [];
        }
        component.set('v.seletedList', seletedList);
    },


    // print
    handleOutput: function(component, event, helper) {
        let self = this;
        let seleted = component.get('v.seletedList');
        console.log(JSON.stringify(seleted), ' ::::seleted');
        let recordIds = '';
        for(let i=0;i<seleted.length; i++) {
            recordIds += seleted[i].Id+',';
        }
        recordIds = recordIds.substring(0,recordIds.length-1);
        console.log(JSON.stringify(recordIds),'<==recordIds');
        if(seleted.length > 0) {
            //gRQuantity
            component.set('v.openUrl', `/s/DealerPortalPrintView?c_record=${recordIds}&c_type=저장소`);
            helper.handleprint(component);
        } else {
            helper.toast('error', '출력할 항목을 선택해주세요.');
        }  
    },

    //삭제
    handleDelete : function(component, event,helper) {
        let seleted = component.get('v.seletedList');
        console.log(JSON.stringify(seleted), ' :::seleted');
        if(seleted.length > 0) {
            helper.locationDelete(component,event);
        } else {
            helper.toast('error', '삭제할 항목을 선택해주세요.');
        }
    },

})