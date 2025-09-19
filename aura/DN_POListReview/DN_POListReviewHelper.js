({
    initJob : function(component) {
        console.log('test1111');
        let self = this;
        self.apexCall(component,event,self, 'initJob', {})
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            //console.log(r, 'rrrrrr');
            if(r.length > 0) {
                component.set('v.jobDetail',r[0]);
            }
        })).catch(function(error) {
            
            self.toast('error', error[0].message);
        })
    },

    // 쿼리 설정
    setQuery : function(component) { 
        let strQuery = [];
        let userInfo = component.get('v.currentUserInfo');
        console.log(JSON.stringify(userInfo), ' < ==userInfo');
        component.set('v.whereCondition',{});
    },
    setFilterChange : function(component, message) {
        let param =message.message;
        console.log(JSON.stringify(param), '< ==param');
        let getWhere = component.get('v.whereCondition');
        //console.log(JSON.stringify(getWhere), ' < ==getWhere');
        //console.log(getWhere.field,' < ==getWhere.field');
        if(param.value !='') {
            getWhere[param.field] = param.value;
            // if(param.field =='productCode') {
            //     getWhere[param.field] = param.value;
            // } else {
            //     getWhere[param.field] = param.value;
            // }
        } else {
            delete getWhere[param.field];
        }
        
        //T00:00:00.000+0000
        console.log(JSON.stringify(getWhere), ' < ==getWhere');
        component.set('v.whereCondition',getWhere);
        // console.log(JSON.stringify(component.get('v.whereCondition')), ' >< testet');
    },
    
    //데이터 조회
    getDataQuery : function(component, message, toastMessage) {
        console.log(toastMessage,' ::: toastMessage');
        return new Promise((resolve, reject) => {
            component.set('v.isLoading', true);
            let self = this;
            if(message == 'Seach') component.set('v.isShouldStop', true);

            let currentPage = message=='Seach'? 1 : component.get('v.currentPage');
            component.set('v.currentPage', currentPage);
            let nextPage = message=='Seach'? 1 : component.get('v.nextPage');
            component.set('v.nextPage',nextPage)
            let recordList = [];
            console.log(JSON.stringify(component.get('v.whereCondition')), ' ::::::QQQQ');
            this.apexCall(component,event,this, 'getDataListQuery', {
                page : {
                    strQuery : component.get('v.whereCondition'),
                    recordList,
                    itemsPerPage : component.get('v.itemsPerPage'),
                    currentPage : component.get('v.currentPage'),
                    pagesPerGroup : component.get('v.pagesPerGroup'),
                    orderByField : component.get('v.orderByField'),
                    orderBy : component.get('v.orderBy'),
                },
                nextPage : component.get('v.nextPage'),
                isExcelLoad : false
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(JSON.stringify(r), '  ::: RRRRR');
                component.set('v.recordList', r.recordList);
                if(r.recordList.length == 0 ) {
                    self.toast('error', '검색되는 데이터가 없습니다.');
                } else {
                    console.log(toastMessage,' ::: toastMessage');
                    self.toast('success',`${toastMessage}`);
                }
                
                let mas = {
                    'currentPage' : r.currentPage,
                    'itemsPerPage' : r.itemsPerPage,
                    'pagesPerGroup' : r.pagesPerGroup,
                    'currentRecordSize' : r.recordList.length,
                    'totalRecordSize' : r.totalRecordSize,
                    'startIdx' : r.startIdx,
                    'endIdx' : r.endIdx,
                    'totalPage' : Math.ceil(r.totalRecordSize / r.itemsPerPage),
                    'eventType' : message
                };
                component.set('v.totalRecordSize', r.totalRecordSize);
                component.set('v.totalPage',Math.ceil(r.totalRecordSize / r.itemsPerPage));
                component.find("dealerPortalLMC").publish({
                    uuid : component.get('v.uuid'),
                    type : 'dataListSearch',
                    message : mas,
                    cmpName : 'dataTable'
                })
                resolve();
            })).catch(function(error) {
                reject(error);
                component.set('v.excelData', []);
                self.toast('error', error[0].message);
                console.log('# addError error : ' + error.message);
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
        console.log( ' ::: setExcelData');
        return new Promise((resolve, reject) => {
            // resolve();
            let self = this;
            self.apexCall(component,event,self, 'getDataListQuery', {
                page : {
                    strQuery : component.get('v.whereCondition'),
                    // recordList : component.get('v.recordList'),
                    itemsPerPage : 20, //component.get('v.itemsPerPage'),
                    currentPage : component.get('v.currentPage'),
                    pagesPerGroup : component.get('v.pagesPerGroup'),
                    orderByField : component.get('v.orderByField'),
                    orderBy : component.get('v.orderBy'),
                },
                nextPage : nextPages,
                isExcelLoad : true
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                let exceldata = [];//component.get('v.excelData');
                let pageMap = component.get('v.pageMap');
                console.log(JSON.stringify(r.recordList), ' :: r.allData');
                let allRecordList = r.recordList;
                if(allRecordList.length >0) {
                    
                    allRecordList.forEach(element => {
                        exceldata.push({
                            'Material': element.material,
                            'Meterial Description' : element.materialDesc,
                            'BO Qty' : element.boQTY,
                            'PO Qty' : element.poQTY,	
                            'Price' : Number(element.price).toLocaleString(),
                            'Current Stock' : element.availableQTY || 0,
                            'DNS Stock' : element.dnsQTY,
                            'Other Dealer Stock' : element.otherQTY,
                            'Due Out' : element.dueOut,
                            'Due In' : element.dueIn,
                            'W.AMD' : element.wAMD,
                            'MRP Type' : element.mrpType,
                            'ROP' : element.rop,
                            'Max Lv.' : element.maxLv,
                            'Min Lot' :	element.minLot,
                            'R-VAL' : element.rVal, 
                            'PDT' : element.pdt

                        }) 
                    });
                    pageMap[nextPages] = exceldata;
                    component.set('v.pageMap',pageMap);
                    // component.set('v.excelData',exceldata);
                }else {
                    // component.set('v.isShouldStop', true);
                }
                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
            })
        });        
    },

    getExcelDataAll : function(component) {
        component.set('v.isExcelData', false);
        component.set('v.isExcelButton',false);
        component.set('v.isShouldStop', false);
        component.set('v.excelData', []);
        component.set('v.pageMap', {});
        component._isExcelLoading = false;
        let self = this;
        let totalRecordSize = component.get('v.totalRecordSize');
        if(totalRecordSize > 0) {
            //GPT 형 형만 믿는다고!
            function runWithPromisePool(component, poolSize, totalTasks, taskFn) {
                let index = 0;
                let active = 0;
                let results = [];
                let isShouldStop = false;
        
                return new Promise(function (resolve, reject) {
                    function next() {

                        // 모든 작업이 끝났으면 resolve
                        if ((index >= totalTasks && active === 0)) {
                            console.log('result.length : ' + results.length);
                            component._isExcelLoading = true;
                            resolve(Promise.allSettled(results));
                            return;
                        }
        
                        // 풀 사이즈 초과하지 않게 조절
                        while (active < poolSize && index < totalTasks) {
                            (function (i) {
                                active++;
                                let p = taskFn(i + 1)
                                    .then(function (res) {
                                        results.push(Promise.resolve(res));
                                    })
                                    .catch(function (err) {
                                        results.push(Promise.reject(err));
                                    })
                                    .finally(function () {

                                        if(component.get('v.isShouldStop')) {
                                            isShouldStop = true;
                                        }
                
                                        if(isShouldStop) {
                                            console.log('강제 종료');
                                            
                                            return reject();   
                                        }

                                        active--;
                                        next(); // 다음 작업 시작
                                    });
                            })(index);
                            index++;
                        }
                    }
        
                    next(); // 최초 실행
                });
            }

            let poolSize = 5;
            let totalTasks = Math.ceil(totalRecordSize / 20);
    
            return runWithPromisePool(component, poolSize, totalTasks, function (index) {
                console.log(index, ' ::: index');
                return self.setExcelData(component, index);
            });
        }
    },

    executeExcelGenerate : function(component) {
        let self = this;
        self.getExcelDataAll(component).then($A.getCallback(function(result) {
            if(component.get('v.isShouldStop')) {
                console.log(' 엑셀데이터 작업 즉시 종료');
                component.set('v.excelData', []);
                component.set('v.isShouldStop', false);
                return Promise.reject();
            }

            if(component._isExcelLoading) {
                let pageMap = component.get('v.pageMap');
                if(Object.keys(pageMap).length > 0) {
                    let excelName = `PO List Review`;
                    component.set('v.excelName',excelName);
                    component.set('v.excelData',Object.values(pageMap).flat());
                }else {
                    component.set('v.excelData', []);
                }
                return self.excelDataSet(component);
            }
            return Promise.reject();
        }))
        .then($A.getCallback(function(result) {
            
            component.set('v.isExcelData', true);
            if(component.get('v.isExcelButton')) {
                self.handleExcelDownload(component);
                component.set('v.isExcelButton', false);
            }
        })).catch(error => {
            console.log(error,' :: executeExcelGenerate sserror');
        });
        
    }
})