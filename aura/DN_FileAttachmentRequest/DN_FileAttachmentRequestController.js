/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-02
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-31   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    sendAlarmtalk : function(component, event, helper) {
        component.set('v.isLoading', true);
        try {
            var recordId = component.get('v.recordId');
            console.log('recordId ::: ', recordId);
            var closeModal = $A.get("e.force:closeQuickAction");
    
            helper.apexCall(component, event, helper, 'sendFileAlarmtalk', {
                recordId: recordId
            }).then(result => {
    
                var r = result.r;
    
                console.log('r ::: ', r);
    
                if (r.isSuccess) {
                    var successMessage = $A.get('$Label.c.DNS_FAR_Success');
                    helper.toast(component, 'Success', successMessage, 'success');
                    closeModal.fire();
                } else {
                    helper.toast(component, 'Error', r.message, 'error');
                }
    
            }).catch(error => {
                console.log('Error ::: ', error.message);
            }).finally(() => {
                component.set('v.isLoading', false);
            });
        } catch (error) {
            console.log('Error ::: ', error.message);
        }
    },

    closeModal : function(component, event, helper) {
        helper.closeModal();
    }
})