({
    // 쿼리 설정
    setQuery : function(component) { 
        component.set('v.whereCondition',{});
    },
    setFilterChange : function(component, message) {
        let param =message.message;
        console.log(JSON.stringify(param), '< ==test!!!!!!');
        let getWhere = component.get('v.whereCondition');
        // console.log(JSON.stringify(getWhere), ' :: getWhere');
        // console.log(param.field, ' < ==param.field');
        // console.log(param.value,' < ==param.value');
        
        if(param.value) {
            console.log(param.value,' < ==param.value if');
            getWhere[param.field] = param.value;
            
        } else {
            console.log(param.value,' < ==param.value else');
            delete getWhere[param.field];
        }
        
        //T00:00:00.000+0000
        console.log(JSON.stringify(getWhere), ' < ==getWhere');
        component.set('v.whereCondition',getWhere);
        // console.log(JSON.stringify(component.get('v.whereCondition')), ' >< testet');
    },

    getDataQuery : function(component) {
        component.set('v.isLoading', true);
        let self = this;
        this.apexCall(component,event,this, 'getDataList', {
            whereCondition : component.get('v.whereCondition')
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result.r), ' result ::: data');
            component.set('v.recordList',result.r);
            //recordList
        })).catch(function(error) {
            self.toast('error', error[0].message);
            console.log('# addError error : ' + error.message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },
})