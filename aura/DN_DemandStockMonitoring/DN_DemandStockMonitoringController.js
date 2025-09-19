/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-28-2025
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-28-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({

    doInit : function(component, event, helper) {
        console.log('test1111:::');
        component.set('v.excelData', []);
        //디폴트 쿼리 설정
        helper.setQuery(component);
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { 
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params)
                    break;
                case 'Seach':
                    let where = component.get('v.whereCondition');
                    console.log(JSON.stringify(where), ' :::where');
                    if(where.ABCIndicator =='ALL' && where.MRPType =='ALL') {
                        if(where.productCode ==undefined) {
                            helper.toast('error','부품번호 입력 또는 ABC Indicator 또는 MRP Type을 선택하세요');
                            return;
                        }
                    } 
                    helper.getDataQuery(component, params.type)
                        .then($A.getCallback(function(result) {
                            component.set('v.isExcelData', false);
                            component.set('v.isExcelButton',false);
                            component.set('v.excelData', []);
                            let promises = [];
                            const TOTALRECORDSIZE = component.get('v.totalRecordSize')
                            let index = 0; // 현재 처리 중인 인덱스
                            const batchSize = 25;// 한 번에 실행할 개수

                            if(TOTALRECORDSIZE > 0) {
                                const TOTALSIZE = component.get('v.totalPage');
                                function processNext() {
                                    if (index >= TOTALSIZE) {
                                        component.set('v.isExcelData', true);
                                        //setTimeout(() => {
                                            helper.excelDataSet(component)
                                            .then($A.getCallback(function(message) {
                                                if(component.get('v.isExcelButton')) {
                                                    helper.handleExcel(component,params.type);    
                                                    component.set('v.isExcelButton', false);
                                                }
                                            }))
                                            .catch($A.getCallback(function(error) {
                                                console.error('Excel 생성 실패:', error);
                                                //alert('Excel 파일 생성 중 오류가 발생했습니다.');
                                            }));
                                            return;    
                                        //}, 0);
                                    }
                                    let promises = [];
                                    for (let i = 0; i < batchSize && index < TOTALSIZE; i++, index++) {
                                        console.log(index + 1, ' Processing...');
                                        promises.push(helper.setExcelData(component, index + 1));
                                    }
    
                                    // 한 번에 batchSize만큼 실행 후 다음 프레임에서 처리
                                    Promise.all(promises)
                                        .then(() => {
                                            setTimeout(() => {
                                                requestAnimationFrame(processNext);
                                            }
                                            , 0);
                                            
                                        })
                                        .catch(error => {
                                            console.log(error, ' :: 처리 중 오류 발생');
                                        });
                                }
                                // 첫 번째 작업 시작
                                requestAnimationFrame(processNext);
                            }
                        })).then($A.getCallback(function(result) {
                            console.log('Excel 다운로드 완료');
                            
                        }))
                        .catch(error => {
                            console.log(error,' :: sserror');
                        });
                    break;
                case 'ExcelDownload': 
                    component.set('v.isLoading', true);
                    component.set('v.isExcelButton', true);
                    if(component.get('v.isExcelData')) {
                        helper.handleExcel(component);
                        component.set('v.isExcelButton',false);
                    } 
                    break;
                case 'PageChnage':
                    //console.log(JSON.stringify(msg), ' msg');
                    component.set('v.nextPage',params.message.nextpage);
                    component.set('v.currentPage',params.message.currentPage);
                    helper.getDataQuery(component,params.type);
                    break; 
                case 'Save':
                    helper.stockSave(component)
                    .then($A.getCallback(function(result) {
                        helper.getDataQuery(component, params.type)
                        .then($A.getCallback(function(result) {
                            component.set('v.excelData', []);
                            component.set('v.isExcelData', false);
                            let promises = [];
                            const TOTALSIZE = component.get('v.totalPage');
                            console.log(TOTALSIZE,' ::: TOTALSIZE');
                            for (let i = 0; i < TOTALSIZE; i++) {
                                //helper.setExcelData(component, i+1)
                                console.log(i+1, ' iiiiiii::');
                                promises.push(
                                    helper.setExcelData(component, i+1)
                                ); 
                            }
                            Promise.all(promises).then(() => {
                                component.set('v.isExcelData', true);
                                //엑셀 버튼 누른 경우
                                if(component.get('v.isExcelButton')) {
                                    helper.handleExcel(component);
                                }
                            }).catch(error => {
                                console.log(error,' :: aaaasserror');
                            });

                        })).then($A.getCallback(function(result) {
                            console.log(' 엑셀데이터 작업 종료');
                        }))
                        .catch(error => {
                            console.log(error,' :: sserror');
                        });

                    }))
                    .catch(error => {
                        console.log(error,' :: sserror');
                    });
                    break;
                default:
                    break;
            }  
        }
    },

    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        table1.scrollTo({ top: scrollY, left: 0, behavior: 'auto' });
    },
})