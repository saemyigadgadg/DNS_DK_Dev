({
    doInit : function(component, event, helper) {
        var recordId          = component.get('v.recordId');
        var selectedEquipment = component.get('v.selectedEquipment');
        console.log('selectedEquipment -> ', selectedEquipment);
        var action = component.get('c.initEquipment');
        action.setParams(
            {
                recordId: recordId
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set('v.targetList', result);
            } else {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex Error: " + errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleCheckboxChange: function(component, event, helper) {
        var checkbox = component.find('checkbox');
        var targetList = component.get('v.targetList');

        // checkbox 가 단일 오브젝트일때 예외처리
        if (!Array.isArray(checkbox)) {
            checkbox = [checkbox];
            console.log('checkbox', JSON.stringify(checkbox.length));
        }
        var selectedEquipment = [];
        for (var i = 0; i < checkbox.length; i++) {
            if (checkbox[i].get("v.checked")) {
                selectedEquipment.push(targetList[i]);
            }
        }
        console.log('selectedEquipment::', JSON.stringify(selectedEquipment));
        component.set('v.selectedEquipment', selectedEquipment);
    },

    cancelSendEmail: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    sendEmail: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var selectedEquipment = component.get('v.selectedEquipment');
        console.log('selectedEquipment ->', JSON.stringify(selectedEquipment));

        if (selectedEquipment.length < 1) {
            helper.showMyToast('Error', 'Please select at least one Target Equipment.');
            component.set('v.isLoading', false);
            return;
        }

        for (var i = 0; i < selectedEquipment.length; i++) {
            var email = selectedEquipment[i].Email;
            console.log('selectedEquipment[i].email:', email);
            var billingDate = selectedEquipment[i].BillingDate;
            console.log('selectedEquipment[i].billingDate:', billingDate);
            var isBilled = selectedEquipment[i].IsBilled;
            console.log('selectedEquipment[i].IsBilled:', isBilled);

            if (isBilled == false) {
                helper.showMyToast('Error', "The equipment has not been billed. '" + selectedEquipment[i].SerialNumber + "'.");
                component.set('v.isLoading', false);
                return;
            }
    
            if (email == null || email == '') {
                helper.showMyToast('Error', "Email is missing for the equipment with Serial Number '" + selectedEquipment[i].SerialNumber + "'.");
                component.set('v.isLoading', false);
                return;
            }
        }

        var selectedData = [];
        for (var i = 0; i < selectedEquipment.length; i++) {
            selectedData.push(
                {
                    tId              : selectedEquipment[i].tId,
                    SerialNumber     : selectedEquipment[i].SerialNumber,
                    Model            : selectedEquipment[i].Model,
                    Account          : selectedEquipment[i].Account, 
                    AccountAddress   : selectedEquipment[i].AccountAddress,
                    Dealer           : selectedEquipment[i].Dealer, 
                    EmailStatus      : selectedEquipment[i].EmailStatus, 
                    Email            : selectedEquipment[i].Email
                }
            )
        }
        var jsonSelectedData = JSON.stringify(selectedData);
        console.log('jsonSelectedData', jsonSelectedData);
        var action = component.get('c.sendPreCallEmail');
        action.setParams(
            {
                recordId: recordId,
                jsonSelectedData: jsonSelectedData
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.isSuccess == true) {
                    console.log('Success');
                    console.log(result.isSuccess);
                    helper.showMyToast('SUCCESS', 'Your mail has been sent successfully.');
                } else {
                    helper.showMyToast('ERROR', 'Error');
                }
            } else {
                // 오류 핸들링
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    console.log("에러 발생");
                }
            }
            component.set('v.isLoading', false);
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },

})