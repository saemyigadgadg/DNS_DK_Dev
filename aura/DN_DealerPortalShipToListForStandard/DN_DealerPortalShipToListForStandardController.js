({
        doInit : function(component, event, helper) {
            console.log('test11111111');
            setTimeout(() => {
                console.log(component.get('v.recordId'),' test111');
                $A.createComponent(`c:DN_DealerPortalShipToList`,{
                    recordId: component.get('v.recordId'),
                    isHeaderChange: true,
                },
                    function (content, status, errorMessage) {
                        if (status === "SUCCESS") {
                            $A.getCallback(function () {
                                var container = component.find(`shipList`);//component.find(`${params.cmpName}`);
                                container.set("v.body", content);       
                            })();
                        } else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        } else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    });    
                console.log(' Created');
            }, 0);
         
            console.log('END');
        }
})