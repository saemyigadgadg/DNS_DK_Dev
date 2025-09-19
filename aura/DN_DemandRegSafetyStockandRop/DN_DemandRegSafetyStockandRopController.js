({
    doInit : function(component, event, helper) {
        console.log('test1111:::');
        component.set('v.excelData', []);
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
            console.log(" setSubscriptionLMC");
            console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params)
                    break;
                case 'Seach':
                    if(component.get('v.whereCondition').ABCIndicator =='ALL' && component.get('v.whereCondition').MRPType =='ALL') {
                        if(component.get('v.whereCondition').productCode ==undefined) {
                            helper.toast('error','품번을 입력하세요');
                            return;
                        }
                    } 
                    helper.getDataQuery(component, params.type)
                        .then($A.getCallback(function(result) {
                            component.set('v.isExcelData', false);
                            component.set('v.excelData', []);
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
                    helper.ropSave(component);
                    break;    
                default:
                    break;
            }  
        }
    },
    
    handleScroll : function(component, event, helper) {          
        var table2 = event.target; 
        var scrollY = table2.scrollTop; 
        var table1 = component.find('leftTableDiv').getElement(); 
        table1.scrollTo({top:scrollY, left:0, behavior:'auto'}); 
    },

    handeQTYChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let recordList = component.get('v.recordList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        recordList[index].nROP = value;
        component.set('v.recordList', recordList);
        
    },
    handleMaxChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let recordList = component.get('v.recordList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        recordList[index].nMaxLv = value;
        component.set('v.recordList', recordList);
        
    },
    handeRoundValChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let recordList = component.get('v.recordList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        recordList[index].nRVal = value;
        component.set('v.recordList', recordList);
        
    },
    handeMinLotChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let recordList = component.get('v.recordList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        recordList[index].nMinLot = value;
        component.set('v.recordList', recordList);
        
    },

})