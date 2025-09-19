({
    /// 쿼리 설정
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
        let isPart = false;
        if(param.field == 'productCode') {
            isPart = param.value =='' ? true : false;
            component.set('v.isPart', isPart);
        }
        
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
    // 목록 조회
    getDataList : function(component, event) {
        return new Promise((resolve, reject) => {
            let self = this;
            component.set('v.isLoading', true);
            if(component.get('v.isPart')) {
                component.set('v.isLoading', false);
                component.set('v.recordList',[]);
                self.toast('error', '부품 번호가 올바르지 않습니다.');
            } else {
                console.log(JSON.stringify(component.get('v.whereCondition')),' 1111111');
                this.apexCall(component,event,this, 'getReplacementList', {
                    search : component.get('v.whereCondition')
                })
                .then($A.getCallback(function(result) {
                    let { r, state } = result;
                    console.log(JSON.stringify(r), ' :::::R');
                    component.set('v.recordList', r);
                    resolve();
                })).catch(function(error) {
                    reject(error);
                    console.log('# addError error : ' + error[0].message);
                }).finally(function () {
                    // 모든 호출 완료 후 로딩 상태 해제
                    component.set('v.isLoading', false);
                });
            }
            
        });     
    },
})