({
    navigationTo: function (component, pageReference, isReplace) {
        console.log(JSON.stringify(pageReference));
        let navService = component.find("navService");
        navService.navigate(pageReference, isReplace);
    },

    navigationToURL: function (component, pageReference, isReplace) {
        console.log(JSON.stringify(pageReference));
        let navService = component.find("navService");
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            location.href = url;
        }), $A.getCallback(function(error) {
            console.error('error ! ');
        }));
        
        // .navigate(pageReference, isReplace);
    },
})