({
    init: function (component) {
        console.log('recordID', component.get('v.recordId'));
        var action = component.get('c.getConditionList');
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('res', JSON.stringify(result));
            if (response.getState() === 'SUCCESS') {
                component.set('v.conditionList', result);
            } else {
                console.log('error');
            }
        });
        $A.enqueueAction(action);
    },
})