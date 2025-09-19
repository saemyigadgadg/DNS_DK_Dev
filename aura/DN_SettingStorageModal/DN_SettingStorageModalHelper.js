/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-06-05
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("settingStorageModal");
        var modalBackGround = component.find("settingStorageModalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
    },
    
    _showToast : function( component, type, title, message ) {
        component.find('notifLib').showToast({
            "variant": type,
            "header": title,
            "message": message,
            closeCallback: function() {}
        });
    },
    

    
})