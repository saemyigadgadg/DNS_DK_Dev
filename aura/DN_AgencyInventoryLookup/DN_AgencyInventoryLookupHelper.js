({
    // 쿼리 설정
    setQuery : function(component) { 
        let strQuery = [];
        let userInfo = component.get('v.currentUserInfo');
        //console.log(JSON.stringify(userInfo), ' < ==userInfo');
        component.set('v.whereCondition',{});
        component.set('v.excelData',[]);
        
    },
    setFilterChange : function(component, message) {
        let param =message.message;
        //console.log(JSON.stringify(param), '< ==param');
        let getWhere = component.get('v.whereCondition');
        //console.log(JSON.stringify(getWhere), ' < ==getWhere');
        //console.log(getWhere.field,' < ==getWhere.field');
        
        if(param.field !='location' && param.field !='productCode') {
            if(param.value !='') {
                getWhere[param.field] = param.value;
            } else {
                delete getWhere[param.field];
            }
        } else {
            if(param.value !='') {
                getWhere[param.field] = param.value;
                component.set('v.isNull', false);
            } else {
                if(param.label !='') {
                    component.set('v.isNull', true);
                } else {
                    component.set('v.isNull', false);
                    delete getWhere[param.field];
                }   
            }
        }
        
        
        

        
        //T00:00:00.000+0000
        //console.log(JSON.stringify(getWhere), ' < ==getWhere');
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
            //console.log(JSON.stringify(component.get('v.whereCondition')), ' ::::::QQQQ');
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
                //console.log(JSON.stringify(r), '  ::: RRRRR');
                component.set('v.seletedList', []);
                component.set('v.recordList', r.recordList);
                
                if(r.recordList.length == 0 ) {
                    self.toast('error', '검색되는 데이터가 없습니다.');
                } else {
                    self.toast('success', '검색이 완료되었습니다.');
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
                component.set('v.totalRecordSize',r.totalRecordSize);
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

    /**
     * 엑셀데이터는 백그라운드 처럼 로딩 시켜놓기
     * 데이터가 로딩이 완료되면 true로 변경
     * 엑셀버튼을 클릭한 경우 엑셀다운로드 버튼 클릭했는지 유무 체크 필드
     * 엑셀데이터가 로딩이 완료되면 해당 버튼클릭 유무로 바로 다운로드 실행 
     * 엑셀 버튼을 클릭했을떄 이미 데이터가 불러와진 상태면 다운로드 바로 실행
     */
    // //엑셀 데이터 로딩중
    setExcelData : function(component, nextPages) {
        //console.log( ' ::: setExcelData');
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
                //console.log(JSON.stringify(r.allData), ' :: r.allData');
                let allRecordList = r.allData;
                if(allRecordList.length >0) {
                    let excelName = `재고 조회`;
                    allRecordList.forEach(element => {
                        exceldata.push({
                            '대리점명' : element.dealerName,
                            '부품번호': element.partNumber,
                            '품명' : element.partName,
                            '규격' : element.partSpec,
                            '재고량' :element.currentStockQuantity,
                            '판매가' : element.listPrice,
                            '저장위치' : element.location,
                        }) 
                    });
                    component.set('v.excelData',exceldata);
                    component.set('v.excelName',excelName);
                    resolve();
                } else {
                    reject();
                }
                
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
            })
        });        
    },

    // 저장위치 클릭 시 해당 위치에 부품정보 전부 조회
    storageBinDetailInfo: function(component, event,fmLoc) {
        let self = this;
        component.set('v.isLoading', true);
        this.apexCall(component,event,this, 'storageBinDetailInfo', {
            fmLoc : fmLoc,
            dealerId : event.currentTarget.dataset.name
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            //console.log(JSON.stringify(result), ' ::: result');
            let location = r[0].DealerLocation__r.FM_Loc__c;
            let desc = '';
            let partList = [];
            if(r[0].DealerLocation__r.Description__c !=undefined) {
                desc = r[0].DealerLocation__r.Description__c;
            }
            r.forEach(element => {
                partList.push(element.Part__r.ProductCode);  
            });
            let selected = {
                location : location,
                description : desc,
                partNumber : partList
            }

            component.set('v.selectedRow', selected);
        })).catch(function(error) {
            self.toast('error', error[0].message);
            
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            
            component.set('v.isLoading', false);
        });
    }
})