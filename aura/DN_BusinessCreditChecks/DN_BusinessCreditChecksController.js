/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-11-07
 * @last modified by  : yuhyun.park@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-07   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    handleClickSearch : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            var name = component.get('v.name');
            console.log(name);
            component.set('v.isLoading', false);


            var action = component.get("c.getBusinessCreditInfo");
            action.setParams({
                "name": name
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.badList", result.badList);
                    component.set("v.goodList", result.goodList);
                    component.set("v.infoList", result.infoList);
                } else {
                    console.log("Error:", response.getError());
                }
                component.set("v.isLoading", false); // Hide loading spinner
            });
    
            $A.enqueueAction(action);


        } catch (error) {
            console.log(error);
        }
    }
})