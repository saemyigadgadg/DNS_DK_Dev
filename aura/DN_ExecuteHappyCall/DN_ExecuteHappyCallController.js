({
    doInit : function(component, event, helper) {

    },

    cancelHappyCall: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    executeHappyCall: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var action = component.get('c.happyCallExecute');
        action.setParams(
            {
                recordId: recordId
            }
        );
        action.setCallback(this, function (response) {
            console.log('2:');
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                helper.showMyToast('SUCCESS', '해피콜 실행이 성공적으로 완료되었습니다.');
            } else {
                // 오류 핸들링
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    console.log("에러 발생");
                }
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
})