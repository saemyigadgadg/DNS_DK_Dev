({
    doInit: function (component, event, helper) {
    },

    cancelRule: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    executeRule: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        console.log('recordId', recordId);
        var action = component.get('c.executeBatch');
        action.setParams(
            {
                recordId: recordId
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                helper.showMyToast('SUCCESS', 'Ticket Escalation Rule 실행이 성공적으로 완료되었습니다.');
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
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
    },
})