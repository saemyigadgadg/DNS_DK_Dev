({
    gfnDoinit : function(component, event) {
        console.log(`${component.getName()}.gfnDoinit`);
        let recordId;
        
        recordId = this.getUrlParameter('c__pendingApprovalOrderId');
        if(recordId) component.set('v.approvalStatus' , true);

        let relationItems = this.getUrlParameter('c__relationItems');
        let dealerOrder = this.getUrlParameter('c__dealerOrder');

        let self = this;
        this.apexCall(component, event, this, 'detailInit', {
            recordId,
            'pageType':'APPROVAL'
        }).then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(` r: ${r}`);
                console.log(` state: ${state}`);

                if(r.status.code === 200 ) {
                    component.set('v.dealerPurchaseOrder', r.order);

                    let needApprovalPartsList = r.order.itemList.filter(item=> item.status != '0').filter(item => item.status != '5');
                    // if(relationItems) {
                    //     relationItems = relationItems.split(',');
                    //     needApprovalPartsList = needApprovalPartsList.filter(item=> relationItems.includes(item.itemId));
                    // }
                    if(dealerOrder) {
                        needApprovalPartsList = needApprovalPartsList.filter(item=> dealerOrder == item.customerOrderSeq);
                    }else {
                        needApprovalPartsList = needApprovalPartsList.filter(item=> (!item.customerOrderSeq));
                    }

                    component.set('v.partsList', needApprovalPartsList);
                }else {
                    self.toast('Error', '대리점간 거래승인 데이터 가져오는데 오류가 발생하였습니다. 관리자한테 문의하세요.');
                }
        }));
    },

    gfnApproval : function(component, event) {
        console.log(`${component.getName()}.gfnApproval`);
        component.set('v.isLoading', true);
        let approvalOrder = component.get('v.dealerPurchaseOrder');
        let selectedPartList = component.get('v.partsList').filter(part=> part.isSelected);
        console.log(`?? :` +JSON.stringify(selectedPartList));
        //Validation 
        if(!this.gfnValidation(selectedPartList)) {
            component.set('v.isLoading', false);
            return;
        }

        approvalOrder.itemList = selectedPartList;

        let self = this;
        this.apexCall(component, event, this, 'doApproval', {
            approvalOrder
        }).then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(` r: ${r}`);
                console.log(` state: ${state}`);
                
                if(r.status.code === 200 ) {
                    //Page 이동
                    self.toast('Success', '승인이 완료 되었습니다.');
                    let pagRef = self.gfnGetCommunityCustomPageRef('DealApprovalManagement__c');
                    self.navigationTo(component, pagRef);
                    
                } else {
                    self.toast('Error', '대리점간 거래 승인시 오류가 발생하였습니다. 관리자한테 문의하세요.');
                }
                component.set('v.isLoading', false);
        }));
    },

    gfnReject : function(component, event) {
        console.log(`${component.getName()}.gfnReject`);
        component.set('v.isLoading', true);
        let rejectOrder = component.get('v.dealerPurchaseOrder');
        let selectedPartList = component.get('v.partsList').filter(part=> part.isSelected);

        if(!this.gfnValidation(selectedPartList)) {
            component.set('v.isLoading', false);
            return;
        }

        rejectOrder.itemList = selectedPartList;

        let self = this;
        this.apexCall(component, event, this, 'doReject', {
            rejectOrder
        }).then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(` r: ${r}`);
                console.log(` state: ${state}`);
                
                if(r.status.code === 200 ) {
                    //Page 이동
                    self.toast('Success', '거절하였습니다.');
                    let pagRef = self.gfnGetCommunityCustomPageRef('DealApprovalManagement__c');
                    self.navigationTo(component, pagRef);
                } else {
                    self.toast('Error', '대리점간 거래 거절시 오류가 발생하였습니다. 관리자한테 문의하세요.');
                }
                component.set('v.isLoading', false);
        }));

    },

    gfnValidation : function(selectedPartList) {
        let isValid = true;

        if(selectedPartList.length === 0) {
            this.toast('Error', '선택된 항목이 없습니다.');
            isValid = false;
        }

        return isValid;
    }
})