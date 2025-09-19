({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId', recordId);
    },

    campaignExtract: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var action = component.get('c.extractCampaign');
        action.setParams(
            {
                recordId: recordId
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var data = response.getReturnValue();
                if(data.noCondition == false) {
                    helper.showMyToast('ERROR', '등록된 추출 조건이 없습니다.')
                } else {
                    helper.showMyToast('SUCCESS', '추출이 성공적으로 완료되었습니다.')
                    $A.get('e.force:refreshView').fire();
                }
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
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },

    cancelExtract: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        // modal창 껐을 때 배경 scroll 생기게
        document.body.style.overflow = 'auto';
    },


})