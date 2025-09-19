({
    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },

    doSearch : function(component, event, type) {
        component.set('v.isLoading', true);
        console.log(`${component.getName()}.doSearch`);
        let params = this.getSearchParams(component);
        console.log('doSearch');
        console.log( JSON.stringify(params));
        let self = this;
        this.apexCall(component, event, this, 'getHistoryData', params).then($A.getCallback(function(result) {
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
               
                if(!r.history || r.history.length ==0)
                self.toast('error', '검색조건에 맞는 데이터가 존재 하지 않습니다.');
                component.set('v.giList', r.history);
                component.set('v.isLoading', false);
            }
            else {
                self.toast('warning', ' 관리자한테 문의해주세요. ');
                component.set('v.isLoading', false);
            }
        }));

    },
      //검색 조건 가공 
    getSearchParams : function (component) {
        let headerParams = component.get('v.headerParams');
        console.log(`${component.getName()}.gfnGetSearchParams : `);
        
        let params = {};
        //판매처 필수 
        if (!('CustomerName__c' in headerParams)) {
            console.log();
            this.toast('warning', '판매처를 선택해 주세요.');
            component.set('v.isLoading', false);
            return;
        }
        for(const key in headerParams) {
            if(key === 'CustomerName__c') {
                if(headerParams[key] ==''){
                    this.toast('warning', ' 판매처를 선택해 주세요. ');
                    component.set('v.isLoading', false);
                    return;
                }
                params.distributor = headerParams[key];
            } else {
                
                params[key] = headerParams[key];
            }
        }
        return params;
    },
})