/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-11-07
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-06   yuhyun.park@sbtglobal.com   Initial Version
**/
({


    handleClickSearch: function(component, event, helper) {
        var birth = component.get("v.birth");
        var name = component.get("v.name");
        var phone = component.get("v.phone");
        var gender = component.get("v.gender");

        component.set("v.isLoading", true); // Show loading spinner

        // Call Apex method to fetch data from ERP
        var action = component.get("c.getPersonalCreditInfo");
        action.setParams({
            "birth": birth,
            "name": name,
            "phone": phone,
            "gender": gender
        });

        // Handle the response
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
    },





    // handleClickSearch : function(component, event, helper) {
    //     try {
    //         component.set('v.isLoading', true);
    //         var name    = component.get('v.name');
    //         var birth   = component.get('v.birth');
    //         var phone   = component.get('v.phone');
    //         var gender  = component.get('v.gender');
    //         console.log(name + ' / ' + birth + ' / ' + phone + ' / ' + gender);
    //         component.set('v.isLoading', false);
    //     } catch (error) {
    //         console.log(error);
    //     }
    // }

})