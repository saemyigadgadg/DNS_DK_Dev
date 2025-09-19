({
    doInit: function (component, event, helper) {
        let isDesktop = $A.get("$Browser.formFactor") == 'DESKTOP';
        component.set('v.isDesktop', isDesktop);

        if(isDesktop) {
            const baseUrl = window.location.pathname;
            component.set('v.isPortal', baseUrl.includes('/s/') || baseUrl.includes('/c/'));
        }
    },

    closeModal: function (component, event, helper) {
        const recordId = event.getParam('recordId');
        const value    = event.getParam('value');

        console.log('DN_PreparationEditBtn - closeModal - recordId ::: ', recordId, ' value ::: ', value);
        
        component.find("navigation")
        .navigate({
            "type" : "standard__recordPage",
            "attributes": {
                "recordId"      : recordId,
                "actionName"    : "view"
            }
        }, true);
        $A.get('e.force:refreshView').fire();
    },

    handleNavigation : function (component, event, helper) {
        window.addEventListener("popstate", function () {
            window.location.reload();
        });
    }
})