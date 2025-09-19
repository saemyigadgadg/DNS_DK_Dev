({
    doInit : function(component, event, helper) {
        component.set("v.isLoaded", true);

        var baseUrl = window.location.origin;
        if(!baseUrl.includes("--dev.sandbox")) {
            baseUrl += '/s'
        } else {
            baseUrl += '/partners/s'
        }
        component.set("v.baseUrl", baseUrl);

        console.log(component.get('v.recordType'), ' recordType');
        console.log(component.get('v.header'), ' header');
        let today           = new Date();
        let year            = today.getFullYear();
        let month           = today.getMonth()+1;
        let billingMonth    = year + '-' + month;
        component.set("v.searchBoardMonth", billingMonth);

        console.log('search Board Month ::: ', JSON.stringify(component.get('v.searchBoardMonth'), null, 2));

        helper.fetchBoardList(component, event, helper);
        component.set('v.isLoaded', false);
    },

    // 스탠다드 페이지 이동
    // handleClick : function(component, event, helper){
    //      // Board List
    //      let navService = component.find("navService");
    //      let pageReference = {
    //          type: 'standard__objectPage',
    //          attributes: {
    //              objectApiName: 'Board__c',
    //              actionName: 'list'
    //          },
             
    //      };
    //      navService.navigate(pageReference);
    // },
    
    // Custom Page 이동
    handleClick : function(component, event, helper){
        // Board List
        let url = component.get('v.pageURL'); //window.location.href+
        console.log(url,' < ==url');
        console.log(JSON.stringify(window.location.href));
        let navService = component.find("navService");
        let pageReference = {
            type: "comm__namedPage",
            attributes: {
                name: url
            }
        };
        navService.navigate(pageReference);
   },
    

})