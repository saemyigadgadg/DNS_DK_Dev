/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-11-12
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-11   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    _apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise( $A.getCallback( function( resolve, reject ) {
            let action = component.get('c.' + methodName);
            action.setParams(params);
            action.setCallback(helper, function(response) {
                if( response.getState() === 'SUCCESS' ) {
                    resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                } else {
                    //helper.showToast('error', 'Error', 'ERROR');
                    let errors = response.getError();
                    console.log(JSON.stringify(errors));
                    reject({'c':component, 'h':helper, 'r':errors, 'state' : response.getState()});
                }
            });
            $A.enqueueAction(action);
        }));
    },
    
    toast: function (message, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    },
})