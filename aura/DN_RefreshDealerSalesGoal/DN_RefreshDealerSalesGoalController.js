/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-06   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {

    },


    handleRefresh : function(component, event, helper) {
        // console.log('Click !');
        component.set('v.isLoading', true);
        
        try {

            var recordId = component.get('v.recordId');

            helper.apexCall(component, event, helper, 'updateSalesGoal', {
                recordId: recordId

            }).then($A.getCallback(function (result) {
                let resultMessage = result.r;
                // console.log('resultMessage :: ' + resultMessage);

                $A.get('e.force:refreshView').fire();
                helper.toast('Success', 'Sales goal updated successfully!');
                component.set('v.isLoading', false);

            })).catch(function (error) {

                console.error('Error:', error);
                helper.toast('Error', 'Failed to update. Please contact your admin.');
                component.set('v.isLoading', false);

            });

            
        } catch (error) {
            console.error('An error occurred:', error);
            component.set('v.isLoading', false);
            helper.toast('Error', 'An unexpected error occurred: ' + error.message);
        }


        

    },

    
})