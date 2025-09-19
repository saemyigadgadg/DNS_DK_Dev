/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-02-19
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-18   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    handleInterface : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        component.set('v.isLoading', true);
        helper.apexCall(component, event, helper, 'callAssetIF', {
            recordId : recordId
        }).then(result => {
            var r = result.r;
            console.log('result ::: ', result);
            console.log('r ::: ', r);
            if (!r.isSuccess) {
                helper.toast(component, 'Error', r.message, 'error');
            } else {
                helper.toast(component, 'Success', r.message, 'success');
                window.location.reload();
            }
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => {
            component.set('v.isLoading', false);
        });
    }
})