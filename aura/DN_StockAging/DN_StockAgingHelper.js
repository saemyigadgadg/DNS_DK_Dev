({
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
            let currentPage = message=='Seach'? 1 : component.get('v.currentPage');
            component.set('v.currentPage', currentPage);
            let nextPage = message=='Seach'? 1 : component.get('v.nextPage');
            component.set('v.nextPage',nextPage)
            console.log(JSON.stringify(component.get('v.whereCondition')), ' ::::::QQQQ');
            this.apexCall(component,event,this, 'getDataListQuery', {
                page : {
                    strQuery : component.get('v.whereCondition'),
                    recordList : component.get('v.recordList'),
                    itemsPerPage : component.get('v.itemsPerPage'),
                    currentPage : component.get('v.currentPage'),
                    pagesPerGroup : component.get('v.pagesPerGroup'),
                    orderByField : component.get('v.orderByField'),
                    orderBy : component.get('v.orderBy'),
                },
                nextPage : component.get('v.nextPage')
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(JSON.stringify(r), '  ::: RRRRR');
                component.set('v.recordList', r.recordList);
                if(r.recordList.length == 0 ) {
                    self.toast('error', '검색되는 데이터가 없습니다.');
                    component.set('v.totalRecordSize', 0);
                } else {
                    if(message=='Seach') {
                        console.log(toastMessage,' ::: toastMessage');
                        self.toast('success',`${toastMessage}`);
                        component.set('v.totalRecordSize', r.totalRecordSize);
                    }
                }
                let totalRecordSize = component.get('v.totalRecordSize');
                component.set('v.totalPage',Math.ceil(totalRecordSize / r.itemsPerPage));
                let mas = {
                    'currentPage' : r.currentPage,
                    'itemsPerPage' : r.itemsPerPage,
                    'pagesPerGroup' : r.pagesPerGroup,
                    'currentRecordSize' : r.recordList.length,
                    'totalRecordSize' : totalRecordSize,
                    'startIdx' : r.startIdx,
                    'endIdx' : r.endIdx,
                    'totalPage' : component.get('v.totalPage'),
                    'eventType' : message
                };
                
                component.find("dealerPortalLMC").publish({
                    uuid : component.get('v.uuid'),
                    type : 'dataListSearch',
                    message : mas,
                    cmpName : 'dataTable'
                })
                resolve();
            })).catch(function(error) {
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
        return new Promise((resolve, reject) => {
            let self=this;
            self.apexCall(component,event,self, 'setExcelData', {
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
                //let pageMap = component.get('v.pageMap');
                console.log(JSON.stringify(r.allData), ' :: r.allData');
                console.log(r.allData.length, ' ::: r.allData length');
                console.log(nextPages,' ::: nextPages');
                let allRecordList = r.allData;
                if(allRecordList.length >0) {
                    let excelName = `StockAging`;
                    allRecordList.forEach(element => {
                        exceldata.push({
                            'Material': element.partName,
                            'Material Description' : element.partDesc,
                            'Stock' : Number(element.stocQty).toLocaleString(),
                            'Pur.Price' :Number(element.purPrice).toLocaleString(),
                            'Sales Price' : Number(element.salesPrice).toLocaleString(),
                            'Last GI Date' : element.lastGIDate,
                            'GI yr' : element.giyr,
                            'Last Gr Date' : element.lastGRDate,
                            'GR yr' : element.gryr,
                            'Total Value' : Number(element.totalValue).toLocaleString()
                        }) 
                    });
                    //pageMap[nextPages] = exceldata;
                    //component.set('v.pageMap',pageMap);
                    console.log(exceldata.length,' exceldata length');
                    component.set('v.excelData',exceldata);
                    component.set('v.excelName',excelName);
                    resolve();
                } else {
                    reject();
                }
            })).catch(function(error) {
                reject(error);
                self.toast('error Excel::', error[0].message);
            })
        });        
    },
})