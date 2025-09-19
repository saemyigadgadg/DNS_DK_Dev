/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-26
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-13   yeongdeok.seo@sbtglobal.com   Initial Version
**/
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
                    console.log('ERROR', callbackResult.getError());
                    // this.showMyToast('Error', callbackResult.getError()[0].message);
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'Error',
                        message: callbackResult.getError()[0].message
                    });
                    toastEvent.fire();
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

    showMyToast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    }
})