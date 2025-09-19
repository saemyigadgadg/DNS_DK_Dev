({
    // 목록 조회
    getDataList : function(component, event) {
        component.set('v.isLoading', true);
        let self = this;
        let search = component.get('v.whereCondition');
        search.orderByField = component.get('v.orderByField');
        search.orderBy = component.get('v.orderBy');
        this.apexCall(component,event,this, 'getWarrantyHistory', {
            search : search
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log(JSON.stringify(r), ' ::::R');
            component.set('v.warrantyList', r);
        })).catch(function(error) {
            self.toast('error', error[0].message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },
    setFilterChange : function(component, event) {
        let whereCondition = component.get('v.whereCondition');
        
        let listSet = [];
        listSet = listSet.concat(event);
        console.log(JSON.stringify(listSet), ' :::listSet');
        listSet.forEach(element => {
            console.log(element,' < ===element');
            if(element.value !='') {
                whereCondition[element.field] = element.value;
            } else {
                whereCondition[element.field] = element.label;
            }
            
        });
        console.log(JSON.stringify(whereCondition), ' ::: whereCondition');
        component.set('v.whereCondition',whereCondition);
    },
})