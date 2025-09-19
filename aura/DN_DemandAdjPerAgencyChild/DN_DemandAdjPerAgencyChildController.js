({
    doInit : function(component, event, helper) {
        let allData = component.get('v.lineItemList');
        console.log(JSON.stringify(allData),' ::allData');
        let ordQtySum = 0;
        let curQtySum = 0;
        let adjQtySum = 0;
        allData.forEach(element => {
            adjQtySum += element.adJustQuantity;
            ordQtySum += element.orderQuantity;
            curQtySum += element.currentQuantity;
        });
        component.set('v.ordQtySum', ordQtySum);
        component.set('v.curQtySum', curQtySum);
        component.set('v.adjQtySum', adjQtySum);
    },

    handleRefresh : function(component, event, helper){
        try {
            var result = component.get("v.lineItemList");
            var ordQtySum = 0;
            var curQtySum = 0;
            var adjQtySum = 0;
            
            for(let i = 0; i<result.length; i++){
                ordQtySum += Number(result[i].ordqty);
                curQtySum += Number(result[i].curqty);
                adjQtySum += Number(result[i].adjqty);
            }
        } catch (error) {
            console.log('에러 찍어주세요 ::: ' + error);
        }
        finally{
            console.log('합계', ordQtySum , curQtySum, adjQtySum);
            component.set('v.ordQtySum', ordQtySum);
            component.set('v.curQtySum', curQtySum);
            component.set('v.adjQtySum', adjQtySum);
        }
    },


    handleChage : function(component, event, helper){
        let value = event.getSource().get("v.value");
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        // 값 업데이트
        event.getSource().set("v.value",value);
        let allData = component.get('v.lineItemList');
        let ordQtySum = 0;
        let curQtySum = 0;
        let adjQtySum = 0;
        allData.forEach(element => {
            element.adJustQuantity = parseInt(element.currentQuantity) - parseInt(element.orderQuantity);
            adjQtySum += parseInt(element.adJustQuantity);
            ordQtySum += parseInt(element.orderQuantity);
            curQtySum += parseInt(element.currentQuantity); 
        });
        console.log(curQtySum,' ::: curQtySum');
        component.set('v.lineItemList', allData);
        component.set('v.ordQtySum', ordQtySum);
        component.set('v.curQtySum', curQtySum);
        component.set('v.adjQtySum', adjQtySum);
    },

    handleSave : function(component, event, helper){
        console.log('handleSave');
        
    },
})