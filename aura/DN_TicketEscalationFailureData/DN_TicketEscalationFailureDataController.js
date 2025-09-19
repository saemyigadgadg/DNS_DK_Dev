({
    doInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getObjectType');
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('objectType:', result);
                component.set('v.objectTypeOptions', result);
            } else {
                // 오류 핸들링
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    console.log("에러 발생");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    // Object Type 선택시 나오는 고장부위(대) Options
    handleObjectTypeChange: function (component, event, helper) {
        var selectedObjectType = component.get('v.selectedObjectType');
        console.log('selectedObjectType', selectedObjectType);
        var action = component.get('c.getFailureMain');
        action.setParams({
            selectedObjectType: selectedObjectType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('failureMainOptions:', JSON.stringify(result));
                component.set('v.failureMainOptions', result);
            } else {
                // 오류 핸들링
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    console.log("에러 발생");
                }
            }
        });
        $A.enqueueAction(action);
        var selectedFailureMiddle = component.get('v.selectedFailureMiddle');
        var selectedFailurePhenomenon = component.get('v.selectedFailurePhenomenon');
        if (selectedFailureMiddle != null || selectedFailureMiddle != '') {
            component.set('v.selectedFailureMiddle', null);
        }
        if (selectedFailurePhenomenon != null || selectedFailurePhenomenon != '') {
            component.set('v.selectedFailurePhenomenon', null);
        }
    },

    handleFailureMainChange: function (component, event, helper) {
        var selectedFailureMain = component.get('v.selectedFailureMain');
        console.log('selectedFailureMain', selectedFailureMain);
        var action = component.get('c.getFailureMiddle');
        action.setParams({
            selectedFailureMain: selectedFailureMain,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('failureMiddleOptions:', JSON.stringify(result));
                component.set('v.failureMiddleOptions', result);
            } else {
                // 오류 핸들링
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    console.log("에러 발생");
                }
            }
        });
        $A.enqueueAction(action);
        var selectedFailurePhenomenon = component.get('v.selectedFailurePhenomenon');
        if (selectedFailurePhenomenon != null || selectedFailurePhenomenon != '') {
            component.set('v.selectedFailurePhenomenon', null);
        }
    },

    handleFailureMiddleChange: function (component, event, helper) {
        var selectedFailureMain = component.get('v.selectedFailureMain');
        var selectedFailureMiddle = component.get('v.selectedFailureMiddle');
        console.log('selectedFailureMain', selectedFailureMain);
        console.log('selectedFailureMiddle', selectedFailureMiddle);
        var action = component.get('c.getPhenomenon');
        action.setParams({
            selectedFailureMain: selectedFailureMain,
            selectedFailureMiddle: selectedFailureMiddle
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('failurePhenomenonOptions:', JSON.stringify(result));
                component.set('v.failurePhenomenonOptions', result);
            } else {
                // 오류 핸들링
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    console.log("에러 발생");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleSave: function (component, event, helper) {
        component.set('v.isLoading', true);

        // value 가져오기 및 null 처리
        var selectedObjectType = component.get('v.selectedObjectType') || '';
        if (selectedObjectType === '') {
            helper.showMyToast('Error', 'Object Type 선택은 필수입니다.');
            component.set('v.isLoading', false);
            return;
        }
    
        var selectedFailureMain = component.get('v.selectedFailureMain') || '';
        if (selectedFailureMain === '') {
            helper.showMyToast('Error', '고장부위(대) 선택은 필수입니다.');
            component.set('v.isLoading', false);
            return;
        }
    
        var selectedFailureMiddle = component.get('v.selectedFailureMiddle') || '';
        var selectedFailurePhenomenon = component.get('v.selectedFailurePhenomenon') || '';
    
        // label 가져오기
        var failureMainOptions = component.get("v.failureMainOptions") || [];
        var failureMiddleOptions = component.get("v.failureMiddleOptions") || [];
        var failurePhenomenonOptions = component.get("v.failurePhenomenonOptions") || [];
    
        var selectedFailureMainLabel = "";
        var selectedFailureMiddleLabel = "";
        var selectedFailurePhenomenonLabel = "";
    
        for (var i = 0; i < failureMainOptions.length; i++) {
            if (failureMainOptions[i].value === selectedFailureMain) {
                selectedFailureMainLabel = failureMainOptions[i].label;
                break;
            }
        }
        console.log('selectedFailureMainLabel : ', selectedFailureMainLabel);
    
        for (var i = 0; i < failureMiddleOptions.length; i++) {
            if (failureMiddleOptions[i].value === selectedFailureMiddle) {
                selectedFailureMiddleLabel = failureMiddleOptions[i].label;
                break;
            }
        }
        console.log('selectedFailureMiddleLabel : ', selectedFailureMiddleLabel);
    
        for (var i = 0; i < failurePhenomenonOptions.length; i++) {
            if (failurePhenomenonOptions[i].value === selectedFailurePhenomenon) {
                selectedFailurePhenomenonLabel = failurePhenomenonOptions[i].label;
                break;
            }
        }
        console.log('selectedFailurePhenomenonLabel : ', selectedFailurePhenomenonLabel);
    
        var data = JSON.stringify({
            selectedObjectType: selectedObjectType,
            selectedFailureMain: selectedFailureMain,
            selectedFailureMainLabel: selectedFailureMainLabel,
            selectedFailureMiddle: selectedFailureMiddle,
            selectedFailureMiddleLabel: selectedFailureMiddleLabel,
            selectedFailurePhenomenon: selectedFailurePhenomenon,
            selectedFailurePhenomenonLabel: selectedFailurePhenomenonLabel
        });
    
        var recordId = component.get('v.recordId') || '';
        console.log('recordId : ', recordId);
    
        var action = component.get('c.failureSave');
        action.setParams({
            data: data,
            'recordId': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.isSuccess) {
                    helper.showMyToast('SUCCESS', '성공적으로 저장이 완료되었습니다.');
                    component.set('v.isLoading', false);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.showMyToast('ERROR', '조건이 이미 등록되었습니다.')
                }
            } else {
                // 오류 핸들링
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    helper.showMyToast('ERROR', '저장이 실패하였습니다.');
                    component.set('v.isLoading', false);
                }
            }
        })
        $A.enqueueAction(action);
    },

})