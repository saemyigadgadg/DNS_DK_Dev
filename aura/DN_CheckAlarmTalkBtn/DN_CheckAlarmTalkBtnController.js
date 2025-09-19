({
    init : function(component, event, helper) {
        var action = component.get('c.getAlarmTalkInfo');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('getAlarmTalk',result);
            if(result.isSuccess){
                if(result.returnValue){
                    component.set('v.alarmTalk',result.returnValue);
                    component.set('v.fileList', result.returnValue.cvList);
                    console.log('alarmTalk',component.get('v.alarmTalk'));
                    component.set('v.isSpinner', false);
                }else{
                    console.log('return value is Empty....');
                    component.set('v.isSpinner', false);
                }
            }else{
                component.set('v.isSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    goAlarm : function(component, event, helper) {
        var ala = component.get('v.alarmTalk');
        window.open(
            'https://dn-solutions.lightning.force.com/lightning/r/AlarmTalk__c/'+ala.Id+'/view',
            '_blank' // <- This is what makes it open in a new window.
          );
    },
})