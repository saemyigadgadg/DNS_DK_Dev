({

    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.apexCall(component,event,this, 'getTslList', {
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log(JSON.stringify(r),' ::: r');
            component.set('v.sftList',r);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });

    },

    targetServiceLevelModalCancel : function (component, event, helper) {
        helper.closeModal(component);
    },

    // 검색결과 Row선택시 Event로 값 전달
    hadleClick : function (component, event, helper) {
        let index = event.currentTarget.name;
        let allData = component.get('v.sftList');
        
        // publish event
        const compEvent = component.getEvent("cmpEvent");
        compEvent.setParams({
            "modalName": 'DN_TargetServiceLevelModal',
            "actionName": 'Close',
            "message": allData[index]
        });
            
        compEvent.fire();
        helper.closeModal(component);
    }
})