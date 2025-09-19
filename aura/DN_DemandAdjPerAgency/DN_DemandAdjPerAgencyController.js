({

    doInit : function(component, event, helper) {
        //console.log('test1111:::');
        component.set('v.excelData', []);
        component.set('v.selectedPart', {});
        //디폴트 쿼리 설정
        helper.setQuery(component);
        helper.getMonth(component);
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
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
                    //console.log(JSON.stringify(component.get('v.whereCondition')), 'testet111');//{"abcIndicatior":"ALL","MRPType":"ALL"} 
                    if(component.get('v.whereCondition').abcIndicatior =='ALL') {
                        if(component.get('v.whereCondition').MRPType =='ALL' || component.get('v.whereCondition').MRPType =='ND') {
                            if(component.get('v.whereCondition').productCode ==undefined ) {
                                helper.toast('error', ' 부품번호는 필수로 입력 또는 부품번호가 올바르지 않습니다.');
                                return; 
                            }
                        }
                    }
                    // if(component.get('v.whereCondition').productCode ==undefined) {
                    //     helper.toast('error', ' 부품번호는 필수로 입력해야 합니다.');
                    // } else {
                        component.set('v.itemAmtList', []);
                        component.set('v.arrowDownBtnClicked', false);
                        component.set('v.materialCodeDate', '');
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
                                        //console.log(index + 1, ' Processing...');
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
                            //console.log('Excel 다운로드 완료');
                            
                        }))
                        .catch(error => {
                            //console.log(error,' :: sserror');
                        });
                    //}
                    break;
                case 'ExcelDownload': 
                    component.set('v.isLoading', true);
                    component.set('v.isExcelButton', true);
                    if(component.get('v.isExcelData')) {
                        helper.handleExcel(component);
                    } 
                    break;
                case 'PageChnage':
                    //console.log(JSON.stringify(msg), ' msg');
                    component.set('v.nextPage',params.message.nextpage);
                    component.set('v.currentPage',params.message.currentPage);
                    helper.getDataQuery(component,params.type);
                    break; 
                default:
                    break;
            }  
        }
    },



    handleScriptsLoaded: function(component, event, helper) {
        //console.log('SheetJS loaded successfully.');
    },

    clickArrowBtn: function(component, event){
        var clickedFlag = component.get('v.arrowDownBtnClicked');

        clickedFlag = !clickedFlag;

        //console.log('clickedFlag :: 값' + clickedFlag);

        component.set('v.arrowDownBtnClicked', clickedFlag);
    },

    clickMatQty: function(component, event,helper) {
        component.set('v.arrowDownBtnClicked', false);
        let lastParts = event.currentTarget.dataset.name;
        let yyyymm = event.currentTarget.dataset.yyyymm;
        let part = event.currentTarget.dataset.part;
        let index = event.currentTarget.dataset.index;
        let alldata = component.get('v.recordList');
        /**
         * 선택한 목록 - 노란색 
         */
        let prevTd = component.get("v.selectedTd");
        if (prevTd) {
            prevTd.classList.remove("selected-td"); // 이전 선택된 td에서 클래스 제거
        }
        // 현재 클릭한 td 가져오기
        let clickedTd = event.currentTarget;
        clickedTd.classList.add("selected-td"); // 새로운 td에 클래스 추가
        // 선택된 td 업데이트
        component.set("v.selectedTd", clickedTd);

        let seleted = {
            'lastParts' : lastParts,
            'Part' : part,
            'yyyymm' : yyyymm,
            'customerprice' : alldata[index].customerPrice
        };
        //console.log(JSON.stringify(seleted), ' :: seleted');
        component.set('v.selectedPart', []);
        component.set('v.selectedPart', seleted);
        component.set('v.isLoading', true);
        helper.apexCall(component,event,helper, 'getDetails', {
            seleted : seleted,
            type : 'Dealer'
        })
        .then($A.getCallback(function(result) {
            
            component.set('v.itemAmtList', result.r);
            component.set('v.arrowDownBtnClicked', true);
            component.set('v.materialCodeDate', `${part} (${yyyymm})`);
        })).catch(function(error) {
           
        }).finally(function () {
            component.set('v.isLoading', false);
        });
        
    }, 
    
    registerPartsByMulti : function(component, eventm, helper){
        $A.createComponent("c:DN_DemandAdjPerAgencyPopupResMultiPart",{},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    //console.log('팝업창');
                    var container = component.find("RegisterMultiPartsModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    //console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    //console.log("Error: " + errorMessage);
                }
            }
        );
    },
    // Sticky Tables Vertical Scroll Synchronization
    handleScroll : function(component, event, helper) {          
        var table2 = event.target; 
        var scrollY = table2.scrollTop; 
        var table1 = component.find('leftTableDiv').getElement(); 
        table1.scrollTo({top:scrollY, left:0, behavior:'auto'}); 
    },
    
    // currentQTY 저장기능
    handleSave :function(component, event, helper) {
        //console.log(JSON.stringify(component.get('v.selectedPart')), ' test1111');
        helper.openConfirm(`저장하시겠습니까?`, 'default', 'headerless')
            .then($A.getCallback(function(result) {
                if(result) {
                    component.set('v.isLoading', true);
                    let saveList = component.find('DemandAdjPerAgencyChild').get('v.lineItemList');
                    helper.apexCall(component,event,helper, 'dealerOrderSummarySave', {
                        detailList : saveList,
                        seleted : component.get('v.selectedPart'),
                    })
                    .then($A.getCallback(function(result) {
                        helper.getDataQuery(component, 'Seach');
                        component.set('v.arrowDownBtnClicked', false);
                    })).catch(function(error) {
                    
                    }).finally(function () {
                        component.set('v.isLoading', false);
                    });            
                }
            }))
            .catch(error => {
                console.error("Error during confirmation:", error);
            });
    },


})