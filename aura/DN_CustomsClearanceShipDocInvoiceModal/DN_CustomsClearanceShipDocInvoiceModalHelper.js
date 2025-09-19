({
    closeModal : function(component) {
        var modal = component.find("customsClearanceShipDocInvoiceModal");
        var modalBackGround = component.find("customsClearanceShipDocInvoiceModalBackGround");

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