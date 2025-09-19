({
    // 쿼리 설정
    setQuery : function(component) { 
        let strQuery = [];
        let userInfo = component.get('v.currentUserInfo');
        console.log(JSON.stringify(userInfo), ' < ==userInfo');
        component.set('v.whereCondition',{});
        component.set('v.excelData',[]);
        
    },
    setFilterChange : function(component, message) {
        let param =message.message;
        console.log(JSON.stringify(param), '< ==param');
        let getWhere = component.get('v.whereCondition');
        //console.log(JSON.stringify(getWhere), ' < ==getWhere');
        //console.log(getWhere.field,' < ==getWhere.field');
        if(param.value !='') {
            getWhere[param.field] = param.value;
        } else {
            delete getWhere[param.field];
        }
        
        //T00:00:00.000+0000
        console.log(JSON.stringify(getWhere), ' < ==getWhere');
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
            console.log(JSON.stringify(component.get('v.whereCondition')), ' ::::::QQQQ');
           
                this.apexCall(component,event,this, 'getSafetyStockList', {
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
                    isExcel : false
                })
                .then($A.getCallback(function(result) {
                    let { r, state } = result;
                    console.log(JSON.stringify(r), '  ::: RRRRR');
                    component.set('v.recordList', r.recordList);
                    
                    // if(r.recordList.length == 0 ) {
                    //     self.toast('error', '검색되는 데이터가 없습니다.');
                    // } else {
                    //     self.toast('success', '검색이 완료되었습니다.');
                    // }
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
                    component.set('v.totalPage',Math.ceil(r.totalRecordSize / r.itemsPerPage));
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
                    console.log('# addError error : ' + error.message);
                }).finally(function () {
                    
                    component.set('v.isLoading', false);
                });
        });    
    },
    
    ropSave : function(component) {
        component.set('v.isLoading',true);
        let self = this;
        this.apexCall(component,event,this, 'ropSave', {
            saveData : component.get('v.recordList')
        })
        .then($A.getCallback(function(result) {
            self.getDataQuery(component,'Seach');
        })).
        catch(function(error) {
            self.toast('error', error[0].message);
        })
    },

    getMonth : function(component) {
        return new Promise((resolve, reject) => {
            let self = this;
            this.apexCall(component,event,this, 'getMonth', {
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(JSON.stringify(r), ' ::: MONTH R');
                component.set('v.materialListbyMonth', r);
                resolve();
            })).
            catch(function(error) {
                reject(error);
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
        let isExcel = true;
        return new Promise((resolve, reject) => {
            let self=this;
            self.apexCall(component,event,self, 'getSafetyStockList', {
                page : {
                    strQuery : component.get('v.whereCondition'),
                    recordList : component.get('v.recordList'),
                    itemsPerPage : component.get('v.itemsPerPage'),
                    currentPage : component.get('v.currentPage'),
                    pagesPerGroup : component.get('v.pagesPerGroup'),
                    orderByField : component.get('v.orderByField'),
                    orderBy : component.get('v.orderBy'),
                },
                nextPage : nextPages,
                isExcel : true
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                
                let allRecordList = r.recordList;
                if(allRecordList.length >0) {
                    let excelName = `안전재고 대상 & ROP 목록`;
                    let exceldata = component.get('v.excelData');
                    let excelField = [];
                    let monHeader = allRecordList[0].monthlyList.map(item => item.yyyymm);
                    const indexSet = ['Meterial','Meterial Description',...monHeader,
                        'Unit', 'C.ROP', 'N.ROP', 'C.Max Lv.', 'N.Max Lv.',	'MRP Type',	
                        'Fix', 'C.R-Val.', 'N.R-Val.', 'C.Min Lot',	'N.Min Lot','6M',	
                        '12M', '18M', 'Price', 'ABC', 'PDT','Weight','W.AMD','STDEV',
                        'Parts Note'
                    ];
                    indexSet.forEach(element => {
                        excelField.push({
                            header : element,
                            key : element
                        })
                    })
                    
                    allRecordList.forEach(element => {
                        let fix = element.flx? 'X' : '';
                        let obj = {
                            'Meterial'              : element.material,
                            'Meterial Description'  : element.materialDesc,
                            'Unit'                  : element.unit,
                            'C.ROP'                 : element.cROP,
                            'N.ROP'                 : element.nROP,
                            'C.Max Lv.'             : element.cMaxLv,
                            'N.Max Lv.'             : element.nMaxLv,
                            'MRP Type'              : element.mrpType,
                            'Fix'                   : fix,
                            'C.R-Val.'              : element.cRVal,
                            'N.R-Val'               : element.nRVal,
                            'C.Min Lot'             : element.cMinLot,
                            'N.Min Lot'             : element.nMinLot,
                            '6M'                    : element.m6,
                            '12M'                   : element.m12,
                            '18M'                   : element.m18,
                            'Price'                 : element.price,
                            'ABC'                   : element.abc,
                            'PDT'                   : element.pdt,
                            'Weight'                : element.weight,
                            'W.AMD'                 : element.wAMD,
                            'STDEV'                 : element.sTDEV,
                            'Parts Note'            : element.partsNote,
                        };
                        // 년월별 키
                        for(let i=0; i<element.monthlyList.length; i++) {
                            //console.log(monList[i],' :: monList[i]');
                            obj[element.monthlyList[i].yyyymm] = element.monthlyList[i].quantity;
                        }
                        exceldata.push(obj);
                    });
                    component.set('v.excelData',exceldata);
                    component.set('v.excelName',excelName);
                    component.set('v.excelField',excelField);
                }
                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
            })
        });        
    },
})