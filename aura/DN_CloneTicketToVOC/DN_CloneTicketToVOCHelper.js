({
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
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
})