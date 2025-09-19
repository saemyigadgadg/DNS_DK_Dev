/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-06-17
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-17   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit : function (component, event, helper) {
        console.log('modal');

        console.log(component.get('v.docNo'));
        console.log(component.get('v.type'));
        console.log(component.get('v.docNo'));
        helper.getGRGIInformation(component, event, helper);
    },

    grgiDetailModalCancel : function(component, event, helper) {
        helper.closeModal(component);
    },
    handleModalEvent: function (component, event, helper) {
        console.log('handleModalEvent');
        var message = event.getParam("message");
        var modalBg = component.find("modalBackground");
        // Close Modal BG
        $A.util.removeClass(modalBg, "slds-backdrop_open");
        if (message === 'Close') {
            component.set('v.selectedComponent', '');
        }
    }

    
})