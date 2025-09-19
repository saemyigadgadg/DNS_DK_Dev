({
    doinit : function(component, event, helper) {
        var recordId = component.get('v.recordId');

        var action = component.get('c.hiddenInit');
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();

            if(result == 'Hidden') {
                //RFQ Component전체 안보이게
                component.set('v.filter', result);
            } else if(result == 'NewHidden') {
                //New버튼만 안보이게
                component.set('v.filter', result);
            }

        });
        $A.enqueueAction(action);
    }
})