({
    doInit : function(component, event, helper) {
        component.set("v.isLoaded", true);
        console.log(component.get('v.recordType'), ' recordType');
        console.log(component.get('v.header'), ' header');
        let today           = new Date();
        let year            = today.getFullYear();
        let month           = today.getMonth()+1;
        let billingMonth    = year + '-' + month;
        component.set("v.searchBoardMonth", billingMonth);

        helper.fetchBoardList(component, event, helper);
        component.set('v.isLoaded', false);
    },
    
    handleClick : function(component, event, helper){
        let navService = component.find("navService");
        let pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Board__c',
                actionName: 'list'
            },
        };
        navService.navigate(pageReference);
    },

})