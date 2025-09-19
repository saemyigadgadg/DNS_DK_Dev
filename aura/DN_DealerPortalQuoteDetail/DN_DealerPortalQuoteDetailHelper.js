({
    gfnDoinit : function(component, event) {
        console.log(`${component.getName()}.gfnDoinit : `);
        let recordId = component.get('v.recordId');
        console.log('recordId : ', recordId);
        // component.set('v.isLoading', true);
        let self = this;
        this.apexCall(component, event, this, 'doDownloadQuote', {recordId})
               .then($A.getCallback(function(result) {

            let { r, state } = result;
            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {
                component.set('v.partsList', r.quote.itemList);
                self.gfnTotalQuotePriceCalculation(component, r.quote.itemList);
            }
            if(r.status.code === 500 ) {
                self.toast('warning', '품목 데이터 가져오다가 에러가 발생하였습니다. 관리자한테 문의해주세요. ');
            }
            
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            
        });
    },

    gfnTotalQuotePriceCalculation : function(component, partsList)     {
        //마지막에 총 합계 계산
        const partList = partsList.filter(parts => !parts.disabled);
        const quoteTotal = partList.reduce((total, parts) => {
            return total + (parts.discountAmount || 0);
        }, 0);
    
        component.set("v.quoteTotal", quoteTotal);
    },
})