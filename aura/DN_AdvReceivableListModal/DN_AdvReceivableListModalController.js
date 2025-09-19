/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 02-13-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-21   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var advList = component.get("v.advList");
        advList.forEach(e => {
            e.amount = e.amount.split('.')[0];
            // e.confirmAmt = Number(e.confirmAmt.split('.')[0]) * -1;
        })

        console.log('advList ::: ' +JSON.stringify(advList,null,4));
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },
})