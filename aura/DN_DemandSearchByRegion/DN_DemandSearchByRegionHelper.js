({
    // 쿼리 설정
    setQuery : function(component) { 
        let strQuery = [];
        let userInfo = component.get('v.currentUserInfo');
        //console.log((JSON.stringify(userInfo), ' < ==userInfo');
        component.set('v.whereCondition',{});
        component.set('v.excelData',[]);
        
        
    },
    setFilterChange : function(component, message) {
        let param =message.message;
        //console.log((JSON.stringify(param), '< ==param');
        let getWhere = component.get('v.whereCondition');
        //console.log(JSON.stringify(getWhere), ' < ==getWhere');
        //console.log(getWhere.field,' < ==getWhere.field');
        if(param.value !='') {
            getWhere[param.field] = param.value;
        } else {
            delete getWhere[param.field];
        }
        
        //T00:00:00.000+0000
        //console.log((JSON.stringify(getWhere), ' < ==getWhere');
        component.set('v.whereCondition',getWhere);
        // console.log(JSON.stringify(component.get('v.whereCondition')), ' >< testet');
    },
    //데이터 조회
    getDataQuery : function(component, message) {
        return new Promise((resolve, reject) => {
            let self=this;
            component.set('v.isLoading', true);
            if(message=='Seach') {
                component.set('v.isExcelData', true);
            }
            let currentPage = message=='Seach'? 1 : component.get('v.currentPage');
            component.set('v.currentPage', currentPage);
            let nextPage = message=='Seach'? 1 : component.get('v.nextPage');
            component.set('v.nextPage',nextPage)
            //console.log((JSON.stringify(component.get('v.whereCondition')), ' ::::::QQQQ');
            this.apexCall(component,event,this, 'getAreaListQuery', {
                page : {
                    strQuery : component.get('v.whereCondition'),
                    recordList : component.get('v.recordList'),
                    itemsPerPage : component.get('v.itemsPerPage'),
                    currentPage : component.get('v.currentPage'),
                    pagesPerGroup : component.get('v.pagesPerGroup'),
                    orderByField : component.get('v.orderByField'),
                    orderBy : component.get('v.orderBy'),
                },
                nextPage : component.get('v.nextPage'),
                type : message
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                //console.log((r.recordList, '  ::: r.recordList');
                //console.log((component.get('v.nextPage'),' next page111');
                
                component.set('v.recordList', r.recordList);
                if(message =='Seach') {
                    component.set('v.excelData',[]);
                    component.set('v.totalPage',Math.ceil(r.totalRecordSize / r.itemsPerPage));
                    component.set('v.totalRecordSize',r.totalRecordSize);
                }
                let totalPage = component.get('v.totalPage');
                let totalRecordSize = component.get('v.totalRecordSize');
                //console.log((totalPage + ' ::: totalPage');
                //console.log((totalRecordSize + ' ::: totalRecordSize');
                let mas = {
                    'currentPage' : r.currentPage,
                    'itemsPerPage' : r.itemsPerPage,
                    'pagesPerGroup' : r.pagesPerGroup,
                    'currentRecordSize' : r.recordList.length,
                    'totalRecordSize' : totalRecordSize,
                    'startIdx' : r.startIdx,
                    'endIdx' : r.endIdx,
                    'totalPage' : totalPage,
                    'eventType' : message
                };
               
                
                component.find("dealerPortalLMC").publish({
                    uuid : component.get('v.uuid'),
                    type : 'dataListSearch',
                    message : mas,
                    cmpName : 'dataTable'
                })
                resolve();
            })).
            catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
                //console.log(('# addError error : ' + error.message);
            }).finally(function () {
                
                component.set('v.isLoading', false);
            });
        });    
    },
    getMonth : function(component) {
        return new Promise((resolve, reject) => {
            let self = this;
            this.apexCall(component,event,this, 'getMonth', {
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                //console.log((JSON.stringify(r), ' ::: MONTH R');
                component.set('v.materialListbyMonth', r);
                resolve();
            })).
            catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
                //console.log(('# addError error : ' + error.message);
            }).finally(function () {
                
                component.set('v.isLoading', false);
            });
        });    
    },

    /**
     * 엑셀데이터는 백그라운드 처럼 로딩 시켜놓기
     * 데이터가 로딩이 완료되면 true로 변경
     * 엑셀버튼을 클릭한 경우 엑셀다운로드 버튼 클릭했는지 유무 체크 필드
     * 엑셀데이터가 로딩이 완료되면 해당 버튼클릭 유무로 바로 다운로드 실행 
     * 엑셀 버튼을 클릭했을떄 이미 데이터가 불러와진 상태면 다운로드 바로 실행
     */
    // //엑셀 데이터 로딩중
    setExcelData : function(component, nextPages) {
        //console.log(( ' ::: setExcelData');
        return new Promise((resolve, reject) => {
            let self=this;
            self.apexCall(component,event,self, 'getAreaExcelData', {
                page : {
                    strQuery : component.get('v.whereCondition'),
                    recordList : component.get('v.recordList'),
                    itemsPerPage : component.get('v.itemsPerPage'),
                    currentPage : component.get('v.currentPage'),
                    pagesPerGroup : component.get('v.pagesPerGroup'),
                    orderByField : component.get('v.orderByField'),
                    orderBy : component.get('v.orderBy'),
                },
                nextPage : nextPages
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                let exceldata = component.get('v.excelData');
                let allRecordList = r.allData;
                if(allRecordList.length >0) {
                    let monHeader = allRecordList[0].monthlyList.map(item => item.yyyymm);
                    let excelName = `지역별 수요조정`;
                    let excelField =[];
                    const indexSet = ['Repl','부품번호','품명','지역',...monHeader,'UNIT', 'ABC Indicator','MRP Type'
                    ];
                    /**
                     * 'm24','m23',
                        'm22','m21','m20','m19','m18','m17','m16','m15','m14',
                        'm13','m12','m11','m10','m9','m8','m7','m6','m5','m4',
                        'm3','m2','m1','m0',
                     */
                    indexSet.forEach(element => {
                        excelField.push({
                            header : element,
                            key : element
                        })
                    })
                    
                    allRecordList.forEach(element => {
                        let repl = element.repl =='RED'? 'X' : '';
                        let obj = {
                            'Repl' : repl,
                            '부품번호' : element.partCode,
                            '품명' : element.partDetails,
                            '지역' : element.area,
                            'UNIT' : element.unit,
                            'ABC Indicator' : element.aBC,
                            'MRP Type' : element.mrpType

                        }
                        for(let i=0; i<element.monthlyList.length; i++) {
                            obj[element.monthlyList[i].yyyymm] = element.monthlyList[i].quantity;
                        }
                        exceldata.push(obj);
                        
                    });
                    component.set('v.excelField',excelField);
                    component.set('v.excelData',exceldata);
                    component.set('v.excelName',excelName);
                }
                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
            })
        });        
    },
})