({
    doInit: function (component, event, helper) {
        console.log('preparation checklist new');
        
        let isDesktop = $A.get("$Browser.formFactor") == 'DESKTOP';
        component.set('v.isDesktop', isDesktop);

        if(isDesktop) {
            const baseUrl = window.location.pathname;
            component.set('v.isPortal', baseUrl.includes('/s/') || baseUrl.includes('/c/'));
        }

        let recordId = component.get('v.recordId');
        if(!recordId) { recordId = window.sessionStorage.getItem("parentRecordId"); }
        component.set('v.parentId', recordId);

        console.log('DN_PreparationNewBtn - doInit', isDesktop, component.get('v.isPortal'), recordId);
        
    },
    
    closeModal: function (component, event, helper) {
        const recordId = event.getParam('recordId');
        const value    = event.getParam('value');

        console.log('DN_PreparationNewBtn - closeModal - recordId ::: ', recordId, ' value ::: ', value);

        // if(value == 'cancel') {
        //     // component.find("overlayLib").notifyClose();
        //     $A.get("e.force:closeQuickAction").fire();
        // } else {

        //     component.find("navigation")
        //     .navigate({
        //         "type" : "standard__recordPage",
        //         "attributes": {
        //             "recordId"      : recordId,
        //             "actionName"    : "view"
        //         }
        //     }, true);
        // }
        component.find("navigation")
            .navigate({
                "type" : "standard__recordPage",
                "attributes": {
                    "recordId"      : recordId,
                    "actionName"    : "view"
                }
            }, true);
        if(value == 'cancel') $A.get('e.force:refreshView').fire();
    },

    handleNavigation : function (component, event, helper) {
        window.addEventListener("popstate", function () {
            window.location.reload();
        });
    }
})