({
    init : function(component){
        const today = new Date();
        const year = today.getFullYear(); 
        const month = String(today.getMonth() + 1).padStart(2, '0');;
        const day = String(today.getDate()).padStart(2, '0');
        const formatedDate = year+'-'+month+'-'+day;
        component.set('v.startDate', formatedDate);
        component.set('v.endDate', formatedDate);
    },
    
    handleSearch : function(component, event, helper) {
        console.log('startDate',component.get('v.startDate'));
        console.log('endDate',component.get('v.endDate'));

        if($A.util.isEmpty(component.get('v.startDate')) || $A.util.isEmpty(component.get('v.endDate'))){
            console.log('조회기간 입력 안됨');
            helper.toast(component, 'ERROR', '조회기간을 입력해주세요', 'ERROR');
            return;
        }

        component.set('v.isLoading', true);
        var action = component.get('c.getCallCenterData');
        action.setParams({
            startDate : component.get('v.startDate'),
            endDate : component.get('v.endDate')
        });
        action.setCallback(this, function(response){
            
            console.log('state',response.getState());
            console.log('result',response.getReturnValue());
            if(response.getState() == 'SUCCESS'){
                component.set("v.date", response.getReturnValue());
                component.set("v.data", response.getReturnValue());
                component.set('v.isLoading', false);
            }else{
                helper.toast(component, 'ERROR', '데이터를 조회하는데 문제가 발생했습니다.', 'ERROR');
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    handleScroll : function(component, event, helper) {          
        var table2 = event.target; 
        var scrollY = table2.scrollTop; 
        var table1 = component.find('leftTableDiv').getElement(); 
        table1.scrollTo({top:scrollY, left:0, behavior:'auto'}); 
    }
})