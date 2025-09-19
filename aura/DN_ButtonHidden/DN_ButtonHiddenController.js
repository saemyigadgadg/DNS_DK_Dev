/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-03-24
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-26   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doinit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.hiddenInit');

        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            // console.log('filter', response.getReturnValue());
            var result = response.getReturnValue();
            component.set('v.objectName', result.objectName);
            console.log('result.isAccountActivity');
            console.log(result.isAccountActivity);
            component.set('v.isAccountPortal', result.isAccountActivity);

            if(result.objectName == 'Quote') {
                component.set('v.version', result.getVersion);
                if(result.isPortal && result.recordType == 'Global' && result.worker == 'Worker'){
                    component.set('v.portalGlobal', true);
                }
            } else if(result.objectName == 'SQRegistration__c') {
                component.set('v.filter', result.getSqRegistrationFilter);
                component.set('v.currentProfile', result.getCurrentProfile);
            } else if(result.objectName == 'Lead'){
                component.set('v.isValidated', result.getValidated);
            }
        });
        $A.enqueueAction(action);
    },

    handleRecordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;

        if (changeType === "CHANGED") {
            // 레코드 변경 시 자동 새로고침

            // console.log('changed :: ');

            // $A.get('e.force:refreshView').fire();
            // component.find("leadRecordLoader").reloadRecord();
            window.location.reload();


        }
    }
    
})