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

    gfnSearchReturnOrder : function(component, event, type) {
        console.log(`${component.getName()}.gfnSearchReturnOrder`);
        component.set('v.isLoading', true);
        let page = this.gfnGetPageInfo(component, type);
        let nextPage = component.get('v.nextPage');

        let params = this.gfnGetSearchParams(component);
        params.page = page;
        params.nextPage = nextPage;
        let self = this;
        this.apexCall(component, event, this, 'searchReturnOrder', params).then($A.getCallback(function(result) {
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                component.set('v.returnOrderList', r.returnOrderList);
            
                if(!r.returnOrderList || r.returnOrderList.length ==0)
                    self.toast('Warning', '검색조건에 맞는 데이터가 존재 하지 않습니다.');

                // let page = r.page;
                // let mas = {
                //     'currentPage' : page.currentPage,
                //     'itemsPerPage' : page.itemsPerPage,
                //     'pagesPerGroup' : page.pagesPerGroup,
                //     'currentRecordSize' : r.returnRequestList.length,
                //     'totalRecordSize' : page.totalRecordSize,
                //     'startIdx' : page.startIdx,
                //     'endIdx' : page.endIdx,
                //     'totalPage' : Math.ceil(page.totalRecordSize / page.itemsPerPage),
                //     'eventType' : type
                // };
                // self.messagePublish(component,'dataListSearch',mas);
            }
            else {
                self.toast('warning', ' 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        }));

    },

    //검색 조건 가공 
    gfnGetSearchParams : function (component) {
        //{"CustomerName__c":"a2XF7000000MykiMAC","productCode":"01tF7000008ice9IAA","orderSeq":"TEST"}
        //{"CustomerName__c":"9999999999","productCode":"01tF7000008ice9IAA","orderSeq":"TEST"}
        let headerParams = component.get('v.headerParams');
        console.log(`${component.getName()}.gfnGetSearchParams : `);
        console.log( JSON.stringify(headerParams))
        let params = {};

        for(const key in headerParams) {

            if(key === 'CustomerName__c') {
                if(headerParams[key] === '9999999999') {
                    params.customerCode = headerParams[key];
                } else {
                    params.customerName = headerParams[key];
                }
            }else if(key === 'productCode') {
                if(headerParams[key])
                    params.partIdList = headerParams[key].split(',');
            }else {
                params[key] = headerParams[key];
            }
            
        }

        return params;
    },

    gfnGetPageInfo : function (component, type) {
        console.log(`${component.getName()}.gfnGetPageInfo :`);

        let currentPage = type =='Search'? 1 : component.get('v.currentPage');
        let nextPage = type =='Search'? 1 : component.get('v.nextPage');
        component.set('v.nextPage', nextPage);
        component.set('v.currentPage', currentPage);
        // 페이징 처리 데이터
        let page = {
            itemsPerPage : component.get('v.itemsPerPage'),
            currentPage : currentPage,
            pagesPerGroup : component.get('v.pagesPerGroup')
            // orderByField : this.orderByField,
            // orderBy : this.orderBy
        };
        
        return page;
        
    },

    gfnDeleteReturnOrder : function(component, event) {
        component.set('v.isLoading', true);
        let returnOrderList = component.get('v.returnOrderList').filter((returnOrder)=> returnOrder.isSelected);

        let self = this;
        this.apexCall(component, event, this, 'deleteReturnOrder', {returnOrderList }).then($A.getCallback(function(result){
            let { r, state } = result;
            console.log(`${component.getName()}.gfnDeleteReturnOrder`)
            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                self.gfnSearchReturnOrder(component, event, 'Search');
                component.set('v.confirmModal', false);
            }
            else {
                self.toast('warning', '삭제중에 에러가 발생하였습니다. 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        }));

    }

})