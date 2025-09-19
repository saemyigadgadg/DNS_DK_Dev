({
    doInit: function (component, event, helper) {

    },

    changeTarget: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var selectedEquipment = component.get('v.selectedEquipment');
        console.log('selectedEquipment ::: ', JSON.stringify(selectedEquipment));
        var action = component.get('c.changeTargetEquipment');
        action.setParams({
            recordId: recordId,
            selectedEquipment: selectedEquipment
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                helper.showMyToast('SUCCESS', selectedEquipment.length + '건의 대상 장비가 등록 및 변경되었습니다.');
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

    cancelTarget: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})