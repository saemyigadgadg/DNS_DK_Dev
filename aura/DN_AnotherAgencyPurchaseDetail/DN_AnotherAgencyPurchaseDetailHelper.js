({
    gfnDoinit : function(component, event) {
        console.log(`${component.getName()}.gfnDoinit`);
        let recordId = component.get('v.recordId');

        let type = this.getUrlParameter('c_type');

        let self = this;
        this.apexCall(component, event, this, 'detailInit', {
            recordId
        }).then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(` r: ${r}`);
                console.log(` state: ${state}`);


                if(r.status.code === 200 ) {
                    component.set('v.isReadOnly', r.isReadOnly);

                    if(type === 'readOnly') {
                        component.set('v.isReadOnly', true);
                    }

                    component.set('v.partsList', r.order.itemList);
                }else {
                    self.toast('Error', '구매요청 품목 가져오는데 오류가 발생하였습니다. 관리자한테 문의하세요.');
                }
        }));
    },

    gfnUpdateRequest : function(component, event) {
        console.log(`${component.getName()}.gfnUpdateRequest`);
        component.set('v.isLoading', true);
        let requestOrderItemList = component.get('v.partsList').filter((part)=> part.isSelected);
        // 2025 03 31 최종요청수량이 0보다 작을 경우 변경요청 불가 벨리데이션 추가 서일태
        for(let i=0; i<requestOrderItemList.length; i++) {
            if((requestOrderItemList[i].quantity*1 + requestOrderItemList[i].changeQuantity*1) <=0) {
                this.toast('Error', '최종요청수량이 0보다 작을 수 없습니다.');
                component.set('v.isLoading', false);
                return;
            }
        }
       
        //Validation 
        if(requestOrderItemList.length == 0) {
            this.toast('Error', '선택된 품목이 없습니다.');
            component.set('v.isLoading', false);
            return ;
        }

        let self = this;
        this.apexCall(component, event, this, 'doUpdateRequest', {
            requestOrderItemList
        }).then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log(` r: ${r}`);
            console.log(` state: ${state}`);

            if(r.status.code === 200 ) {
                self.gfnDoinit(component,event);
                self.toast('Success', '변경요청이 완료되었습니다.');
            }else {
                self.toast('Error', '변경요청 중에 오류가 발생하였습니다. 관리자한테 문의하세요.');
            }
            component.set('v.isLoading', false);
        }));
    },

    gfnDeleteRequest : function(component, event) {
        console.log(`${component.getName()}.gfnDeleteRequest`);
        component.set('v.isLoading', true);
        let requestOrderItemList = component.get('v.partsList').filter((part)=> part.isSelected);

        //Validation 
        if(requestOrderItemList.length == 0) {
            this.toast('Error', '선택된 품목이 없습니다.');
            component.set('v.isLoading', false);
            return ;
        }

        let self = this;
        this.apexCall(component, event, this, 'doDeleteRequest', {
            requestOrderItemList
        }).then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log(` r: ${r}`);
            console.log(` state: ${state}`);

            if(r.status.code === 200 ) {
                self.gfnDoinit(component,event);
                self.toast('Success', '삭제요청이 완료되었습니다.');
            }else {
                self.toast('Error', '삭제요청 중에 오류가 발생하였습니다. 관리자한테 문의하세요.');
            }
            component.set('v.isLoading', false);
        }));
    },

    gfnExcelHeader : function() {
        return {
            itemSeq:'항목',      
            replacingPartName:'주문품번',
            replacingPartDetails:'품명',
            quantity:'수량',
            unit:'단위',
            currencyCode:'통화',
            customerPrice:'고객판매가',
            discountPrice:'할인판매가',
            discountAmount:'할인판매금액',
            giQuantity:'출고수량',
            //미결수량
            changeQuantity:'변경요청수량',
            //최종요청수량
            currentStockQuantity:'요청대리점재고',
            deliveryStatus:'상태',
        };
    }
})