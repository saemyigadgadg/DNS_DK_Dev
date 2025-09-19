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
        console.log(JSON.stringify(getWhere), ' < ==getWhere');
        console.log(getWhere.field,' < ==getWhere.field');
        if(getWhere.field == param.field) {
            getWhere.field = param.value;
        } else {
            getWhere[param.field] = param.value;
        }
        
        //T00:00:00.000+0000
        console.log(JSON.stringify(getWhere), ' < ==getWhere');
        component.set('v.whereCondition',getWhere);
        // console.log(JSON.stringify(component.get('v.whereCondition')), ' >< testet');
    },

    // 데이터 조회
    getDataQuery : function(component) {
        console.log(' 데이터 조회 시작:::::');
        component.set('v.selectedGIs', []);
        component.set('v.isLoading', true);
        let self = this;
        this.apexCall(component,event,this, 'getData', {
            whereCondition : component.get('v.whereCondition'),
            orderByField : component.get('v.orderByField'),
            orderBy : component.get('v.orderBy')
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            component.set('v.giList',r);
            if(r.length > 0) {
                component.set('v.isSearched', true);
                self.toast('success', '검색이 완료되었습니다.');
            } else {
                component.set('v.isSearched', false);
                self.toast('success', '조건에 해당하는 데이터가 없습니다.');
            }
        })).catch(function(error) {
            self.toast('error', error[0].message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },
    // 출고취소
    cancelGI : function(component) {
        console.log(' 데이터 조회 시작:::::');
        component.set('v.isLoading', true);
        let cancelGIDoc = '';
        let self = this;
        this.apexCall(component,event,this, 'cancelGI', {
            otherGiList : component.get('v.selectedGIs')
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log(JSON.stringify(result), ' :::: result');
            
            let res = result.r;
            let headerData = [{
                '대리점명': r.agencyName,
                '참고문서번호' : r.doc,
                '생성일자': r.createdDate,
                '생성시각' : r.createdTime
            }];
            let exceldata = [];
            let index =1;
            res.returnGIList.forEach(element => {
                console.log(JSON.stringify(element), ' ::: element');
                console.log(element.DealerStock__c,' ::: element.DealerStock__c');
                let location = element.DealerStock__r.DealerLocation__c == undefined ? '' : element.DealerStock__r.DealerLocation__r.FM_Loc__c;
                console.log(location, '111111111');
                console.log(element.GoodsIssue__r.InventoryNumber__c, '222222');
                console.log(element.Part__r.ProductCode, '333333');
                console.log(element.Part__r.FM_MaterialDetails__c, '444444');
                console.log(element.Quantity__c, '555555');
                
                exceldata.push({
                    '순번' : index,
                    '종류':'출고취소',
                    '문서번호' : element.GoodsIssue__r.InventoryNumber__c || '',
                    '품번' : element.Part__r.ProductCode || '',
                    '품명' : element.Part__r.FM_MaterialDetails__c || '',
                    '수량' : element.Quantity__c || 0,
                    '재고위치' : location
                });
                cancelGIDoc = element.InventoryNumber__c;
                index ++;
            });
            console.log(location, '222222222');
            component.set('v.excelName',`${headerData[0]['참고문서번호']}_출고취소_입고증`);
            component.set('v.headerData',headerData);
            component.set('v.excelGRData',exceldata);
            console.log(location, '333333333');
        })).then($A.getCallback(function(result) {
            self.handleGIGRDocumentExcel(component);
            self.getDataQuery(component);
            self.toast('success', `${cancelGIDoc} 출고취소 문서가 생성되었습니다.`);
        })).catch(function(error) {
            self.toast('error', error[0].message);
            component.set('v.isLoading', false);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            //component.set('v.isLoading', false);
        });
    }
    
})