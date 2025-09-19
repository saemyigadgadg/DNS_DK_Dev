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
    getData : function(component) {
        let self = this;
        component.set('v.isLoading', true);
        this.apexCall(component,event,this, 'getDataList', {
            whereCondition : component.get('v.whereCondition')
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            component.set('v.tslList', r['AreaROPCalculationFactorConfiguration']);
            component.set('v.weightList', r['AreaMaxStockWeightingFactor']);
            //self.toast('success', '검색이 완료되었습니다.');
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },


    ////handleValue
    saveData : function(component) {
        let self = this;
        component.set('v.isLoading', true);
        let saveMap = {
            'AreaROPCalculationFactorConfiguration': component.get('v.tslList'),
            'AreaMaxStockWeightingFactor' : component.get('v.weightList')
        }
        console.log(JSON.stringify(saveMap), ' :: saveMap');
        this.apexCall(component,event,this, 'ropFactorSave', {
            saveMap : saveMap
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            self.toast('success', '저장되었습니다.');
            self.getData(component);
           
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },
})