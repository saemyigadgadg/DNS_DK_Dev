/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-20   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);

        var recordId = component.get("v.recordId");

        helper.apexCall(component, event, helper, 'checkAccountDuplication', {
            recordId: recordId

        }).then($A.getCallback(function (result) {
            let r = result.r;
            // console.log('r ::: ', r);

            // 중복이 아닌 경우 (고객 생성 가능)
            if (r == 'Success') {
                component.set("v.isERPChecked", true);
                component.set("v.isFlag", true);
                $A.get('e.force:refreshView').fire();

            // 중복일 경우 (ERP에 생성된 정보가 있는 경우)
            } else if (r == 'Duplicate') {
                component.set("v.isERPChecked", true);
                component.set("v.isFlag", false);

            // 이미 체크를 완료했을 경우
            } else if (r == 'Validated') {
                component.set("v.isValidated", true);

            // Validate를 위한 정보가 없을 경우 (Company, Representative)
            } else if (r == 'Required for Vaildate Missing') {
                component.set("v.isMissing", true);

            } else {
                doClose(component, event);
                component.find('overlayLib').notifyClose();
                helper.toast('An error occurred, please contact your administrator.', 'error');
            }

            component.set('v.isLoading', false);
            // console.log("Response from ERP check :: ", result.r);

        }))
            .catch($A.getCallback(function (error) {

                console.error('Error during ERP check:', error);
                component.set('v.isLoading', false);
            }));
    },


    doClose: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },


})