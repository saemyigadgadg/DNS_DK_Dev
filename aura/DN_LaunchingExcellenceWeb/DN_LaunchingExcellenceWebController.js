({
    handleButtonClick : function(component, event, helper) {
        const isDesktop = event.getParams('detail').isDesktop;
        if(isDesktop){
            var closeModal = $A.get("e.force:closeQuickAction");
            closeModal.fire()
        }
    },
})