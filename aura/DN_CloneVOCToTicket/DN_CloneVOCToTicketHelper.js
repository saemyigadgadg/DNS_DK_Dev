({
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    closeModal : function(component) {
        var actionModal = $A.get("e.force:closeQuickAction");
        actionModal.fire();
    },
    navigateToRecord : function(component, recordId, objApiName) {
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objApiName,
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
    },
    checkBoxEvent : function(component){
        var ticketInfo = component.get('v.ticketInfo');
        var isurgency = ticketInfo.IsUrgency__c ? ticketInfo.IsUrgency__c : false;
        var isregenerate = ticketInfo.IsReGenerate__c ? ticketInfo.IsReGenerate__c : false;

        // 정규식 처리
        let cleanedText = ticketInfo.ReceptionDetails__c ? ticketInfo.ReceptionDetails__c.replace(/\[긴급\]|\[재발생\]/g, '') : '';
        console.log('Cleaned text:', cleanedText);

        let prefix = '';
        if(isurgency){
            prefix += '[긴급]';
        }
        if(isregenerate){
            prefix += '[재발생]';
        }
        ticketInfo.ReceptionDetails__c = prefix + cleanedText;
        component.set('v.ticketInfo', ticketInfo);
    },
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() );
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },
})