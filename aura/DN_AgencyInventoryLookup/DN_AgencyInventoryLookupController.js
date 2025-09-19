({
    doInit : function(component, event, helper) {
        /**
         * <aura:attribute name="itemsPerPage" type="Integer"/>
  <aura:attribute name="currentPage" type="Integer"/>
         */
        //console.log(component.get('v.itemsPerPage'), ' :itemsPerPage');
        //console.log(component.get('v.pagesPerGroup'), ' :pagesPerGroup');
        component.set('v.excelData', []);
        //디폴트 쿼리 설정
        helper.setQuery(component);
        //document.querySelector('.slds-page-header.header.flexipageHeader').style.display = 'none';
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        // ////console.log(params.uuid, ' < ====params.uuid');
        // ////console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            //console.log(" setSubscriptionLMC");
            //console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params)
                    break;
                case 'Seach':
                    if(component.get('v.isNull')) {
                        helper.toast('error', '부품번호 또는 저장위치가 올바르지 않습니다.');
                    } else {
                        let sessionKey =crypto.randomUUID();
                        helper.getDataQuery(component, params.type)
                            .then($A.getCallback(function(result) {
                                component.set('v.isExcelData', false);
                                component.set('v.isExcelButton', false);
                                component.set('v.excelData', []);
                                let totalRecordSize = component.get('v.totalRecordSize');
                                let totalPage = component.get('v.totalPage');
                                
                                let currentKey = sessionKey;
                                //totalPage
                                if(totalRecordSize > 0) {
                                    const TOTALSIZE = totalPage;// Math.ceil(totalRecordSize / 35);
                                    //console.log(TOTALSIZE, ' ::: TOTALSIZE');

                                    let index = 0; // 현재 처리 중인 인덱스
                                    const batchSize = 25;// 한 번에 실행할 개수

                                    function processNext() {
                                        if (index >= TOTALSIZE) {
                                            component.set('v.isExcelData', true);
                                            //setTimeout(() => {
                                                helper.excelDataSet(component)
                                                .then($A.getCallback(function(message) {
                                                    //console.log('Excel 다운로드 완료');
                                                    if(component.get('v.isExcelButton')) {
                                                        helper.handleExcelDownload(component,params.type);    
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
                                            console.log('Processing...');
                                            if(currentKey !=sessionKey) {
                                                return Promise.reject();
                                            }
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
                                                //console.log(error, ' :: 처리 중 오류 발생');
                                            });
                                    }
                                    // 첫 번째 작업 시작
                                    requestAnimationFrame(processNext);
                                }
                                
                            })).then($A.getCallback(function(result) {
                                //console.log(' 엑셀데이터 작업 종료');
                            }))
                            .catch(error => {
                                //console.log(error,' :: sserror');
                            })    
                    }
                    break;
                case 'ExcelDownload': 
                    component.set('v.isLoading', true);
                    component.set('v.isExcelButton', true);
                    if(component.get('v.isExcelData')) {
                        helper.handleExcelDownload(component,params.type); 
                        component.set('v.isExcelButton', false);
                    }
                    break;
                case 'PageChnage':
                    ////console.log(JSON.stringify(msg), ' msg');
                    component.set('v.nextPage',params.message.nextpage);
                    component.set('v.currentPage',params.message.currentPage);
                    helper.getDataQuery(component,params.type);
                    break; 
                    
                default:
                    break;
            }  
        }
    },

    //저장위치 상세정보
    storageBinDetail: function (component, event, helper) {
        component.set('v.storageBin', true);
        var index = event.currentTarget.name;
        //console.log(event.currentTarget.dataset.id);
        helper.storageBinDetailInfo(component,event,event.currentTarget.dataset.id);
        //var data = component.get('v.recordList');
        // var selectedRow = data[index];
        // //console.log('selectedRow::', selectedRow);
        // component.set('v.selectedRow', selectedRow);
    },
    // 상세정보 닫기
    storageBinModalCancel: function (component, event, helper) {
        component.set('v.storageBin', false);
    },
})