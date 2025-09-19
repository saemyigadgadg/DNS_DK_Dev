({
    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },

    getTargetEquipment: function (component, recordId) {
        var recordId = recordId;
        console.log('recordId', recordId);

        var action = component.get('c.getTargetEquipList');
        action.setParams(
            {
                recordId: recordId
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result', result);
                if(result.length == 0) {
                    this.showMyToast('Error', 'Ticket 을 생성할 대상 장비가 없습니다.');
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    component.set('v.targetList', result);
                }
            } else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    }
})