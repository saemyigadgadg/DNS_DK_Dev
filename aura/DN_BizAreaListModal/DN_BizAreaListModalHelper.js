/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-05
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-05   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("bizAreaListModal");
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