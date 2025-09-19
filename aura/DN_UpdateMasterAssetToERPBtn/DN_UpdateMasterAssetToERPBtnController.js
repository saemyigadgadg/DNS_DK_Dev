/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-02-20
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-19   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    updateAsset : function(component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        console.log('recordId ::: ', recordId);

        helper.apexCall(component, event, helper, 'updateAssetFromERP', {
            recordId: recordId
        }).then(result => {

            var r = result.r;
            console.log('r ::: ', r);

            if (r.isSuccess) {
                helper.toast(component, 'Success', r.message, 'success');
                window.location.reload();
            } else {
                helper.toast(component, 'Error', r.message, 'error');
            }

        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => {
            component.set('v.isLoading', false);
        });
    },

    closeModal : function(component, event, helper) {
        helper.closeModal();
    }
})