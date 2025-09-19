/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-06-20
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-20   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'getDetail', {
            vbeln : component.get('v.docNum')
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result),' < ===responseData');
            let data = result.r.ET_LIST;
            let sum = 0;
            component.set('v.resultList',data);
            
            component.set('v.resultAmountSum',result.r.E_TOTAL);
        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
        });
        // component.set('v.resultList', resultList);
        // component.set('v.resultAmountSum', resultAmountSum);
        component.set('v.isLoading', false);
    },

    apListPopupModalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },
})