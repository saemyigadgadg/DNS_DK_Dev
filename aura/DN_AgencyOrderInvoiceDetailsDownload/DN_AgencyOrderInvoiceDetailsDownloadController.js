({
    doInit: function (component, event, helper) {
        // helper.gfnDoinit(component,event);
    },

    excelLoadingComplete : function(component, event, helper) {
        console.log(`${component.getName()}.excelLoadingComplete : `);
        component.set('v.progressValue', '10');
        helper.gfnDoinit(component, event);
    }
})