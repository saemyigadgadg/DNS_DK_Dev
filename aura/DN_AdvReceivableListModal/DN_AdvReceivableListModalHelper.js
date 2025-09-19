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
    closeModal : function(component) {
        var modal = component.find("advListModal");
        var modalBackGround = component.find("modalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
    }
})