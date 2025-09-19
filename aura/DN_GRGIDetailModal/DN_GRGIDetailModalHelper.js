({  

    getGRGIInformation : function(component, event, helper) {
        let self = this;
        self.apexCall(component, event, helper, 'getGRGIInformation', {
            docNo :component.get('v.docNo')
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result.r));
            component.set('v.resultList', result.r.resultList);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            // component.set('v.isSpinner', false);
        });
    },

    closeModal : function(component) {
        var modal = component.find("grgiDetailModal");
        var modalBackGround = component.find("grgiDetailModalBackGround");

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