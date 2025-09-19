/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Hyerin Ro
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-18   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        console.log('test1111:::');
        component.set('v.excelData', []);
        //디폴트 쿼리 설정
        helper.setQuery(component);
        
    },


    resetMaterial: function (component, event, helper) {
        component.set('v.material', null);
    },
    handleScroll : function(component, event, helper) {          
        var table2 = event.target; 
        var scrollY = table2.scrollTop; 
        var table1 = component.find('leftTableDiv').getElement(); 
        table1.scrollTo({top:scrollY, left:0, behavior:'auto'}); 
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
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach':
                    helper.getDataList(component)
                    .then($A.getCallback(function(result) {
                        // // 엑셀데이터 설정
                        component.set('v.isExcelButton', false);
                        let excelData = [];
                        let excelField = [];
                        let excelName = `대체품 해체 이력 조회`;
                        let data = component.get('v.recordList');
                        console.log(JSON.stringify(data), ' ::: data');
                        if(data.length > 0) {
                            
                            const indexSet = ['Material', 'Material Description',
                                'Last Parts','M-18','M-17','M-16','M-15',
                                'M-14','M-13','M-12','M-11','M-10','M-9',
                                'M-8','M-7','M-6','M-5','M-4','M-3','M-2',
                                'M-1','단위','6M','12M','18M','금액','ABC Ind.',
                                'ROP','Max Lv.','변경 일자','오더 Block','구매 Block'
                            ];
                            indexSet.forEach(element => {
                                excelField.push({
                                    header : element,
                                    key : element
                                })
                            })
                        }
                        data.forEach(element => {
                            
                           let obj = {
                            'Material' : element.material,
                            'Material Description' : element.materialDesc,
                            'Last Parts' : element.lastParts,
                            '단위' : element.unit,
                            '금액' : Number(element.amount).toLocaleString() +'  '+element.currencyCode,
                            'ABC Ind.' : element.abc,
                            'ROP' : element.rop,
                            'Max Lv.' : element.maxLv,
                            '변경 일자' : element.changeDate, 
                            '오더 Block' : element.orderBlock, 
                            '구매 Block' : element.salesBlock,
                            '6M' : element.m6.qty || 0,
                            '12M' : element.m12.qty || 0,
                            '18M' : element.m18.qty || 0,
                           }
                           element.monthlyList.forEach(ele => {
                                obj[ele.monKey] = ele.qty; 
                           });
                           excelData.push(obj);
                        });
                        component.set('v.excelData',excelData);
                        component.set('v.excelName',excelName);
                        component.set('v.excelField',excelField);
                    })).then($A.getCallback(function(result) {
                        component.set('v.isExcelData', true);
                        //엑셀 버튼 누른 경우
                        if(component.get('v.isExcelButton')) {
                            helper.handleExcel(component);
                        }
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
                
                default:
                    break;
            }  
        }
    },
    
})