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
        component.set('v.whereCondition',getWhere);  
    },
    //데이터 조회
    getDataQuery : function(component, message, toastMessage) {
        return new Promise((resolve, reject) => {
            console.log(toastMessage,' ::: toastMessage');
            let self = this;
            component.set('v.isLoading', true);
            // if(message=='Seach') {
            //     component.set('v.isExcelData', true);
            // }
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
                component.set('v.seletedList', []);
                self.toast('success', `${toastMessage}`);
                component.set('v.recordList', r.recordList);
                component.set('v.excelData',[]);
                component.set('v.excelName',[]);
                component.set('v.totalRecordSize',r.totalRecordSize);
                // if(component.get('v.isExcelData')) {
                //     let exceldata = [];
                //     let allRecordList = r.allData;
                //     if(allRecordList.length >0) {
                //         let excelName = `${allRecordList[0].Dealer__r.Name}_저장 위치`;
                //         allRecordList.forEach(element => {
                //             exceldata.push({
                //                 '저장위치' : element.FM_Loc__c || '',
                //                 '설명' : element.Description__c || ''
                //             }) 
                //         });
                //         component.set('v.excelData',exceldata);
                //         component.set('v.excelName',excelName);
                //     }
                    
                //     console.log(component.get('v.excelName'), ' :: Excel Name');
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
                component.find("dealerPortalLMC").publish({
                    uuid : component.get('v.uuid'),
                    type : 'dataListSearch',
                    message : mas,
                    cmpName : 'dataTable'
                })
                resolve();
            })).catch(function(error) {
                reject('');
                this.toast('error', error[0].message);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                // 모든 호출 완료 후 로딩 상태 해제
                component.set('v.isExcelData', false);
                component.set('v.isLoading', false);
            });
        });      
    },

    setExcelData : function(component, nextPages) {
        console.log( ' ::: setExcelData');
        return new Promise((resolve, reject) => {
            let self=this;
            self.apexCall(component,event,self, 'setExcelData', {
                page : {
                    strQuery : component.get('v.whereCondition'),
                    recordList : component.get('v.recordList'),
                    itemsPerPage : 200,
                    currentPage : component.get('v.currentPage'),
                    pagesPerGroup : component.get('v.pagesPerGroup'),
                    orderByField : component.get('v.orderByField'),
                    orderBy : component.get('v.orderBy'),
                },
                nextPage : nextPages
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                let excelData = [];
                let pageMap = component.get('v.pageMap');
                console.log(nextPages,' ::: nextPages');
                console.log(JSON.stringify(r.allData), ' :: r.allData');
                let allRecordList = r.allData;
                //pageMap[nextPages] = allRecordList;
                if(allRecordList.length >0) {
                    allRecordList.forEach(element => {
                        excelData.push({
                            '저장위치' : element.FM_Loc__c || '',
                            '설명' : element.Description__c || ''
                        }) 
                    });
                    pageMap[nextPages] = excelData;
                    
                }
                
                console.log(JSON.stringify(pageMap), ' :: pageMap');
                
                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
            })
        });        
    },

    // 삭제
    locationDelete : function(component,event) {
        let self = this;
        console.log(component.get('v.seletedList'),' ::::List');
        let selected = component.get('v.seletedList');
        let recordIds = [];
        selected.forEach(element => {
            recordIds.push(element.Id);
        });
        this.apexCall(component,event,this, 'locationDelete', {
            recordIds : recordIds
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            self.getDataQuery(component,'Seach','삭제되었습니다.');
        })).catch(function(error) {
            this.toast('error', error[0].message);
            console.log('# addError error : ' + error.message);
        }).finally(function () {
            component.set('v.isLoading', false);
        });
    },
})