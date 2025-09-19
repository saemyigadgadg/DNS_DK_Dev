({
	handleScriptsLoaded : function(component, event, helper) {
        console.log('ExcelJS library loaded.');
        component.set('v.isExcelJsLoading', true);
    },
})