/**
 * @description       : 순회서비스 Ticket 추출
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2024-07-22
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-22-2024   junyeong.choi@sbtglobal   Initial Version
**/
({
    doInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId', recordId);
        var action = component.get('c.confirmExtract');
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
                if (result.isSuccess) {
                    if (result.registerCheck) {
                        helper.showMyToast('Error', '대상 장비를 등록해주십시오.')
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    // if (result.extractCheck) {
                    //     helper.showMyToast('Error', '이미 추출이 완료되었습니다.');
                    // }
                } else {
                    console.log("Error message: " + result.errMessage);
                }
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
        $A.get("e.force:closeQuickAction").fire();

        helper.getTargetEquipment(component, recordId);
    },

    cancelExtract: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    executeExtract: function (component, event, helper) {
        component.set('v.isLoading', true);
        var targetList = component.get('v.targetList');
        var index = event.getSource().get('v.accesskey');
        console.log('index', index);

        if(targetList.length < 1) {
            helper.showMyToast('ERROR', 'Ticket 을 생성할 대상 장비가 없습니다.');
            component.set('v.isLoading', false);
            return;
        }

        for (var i = 0; i < targetList.length; i++) {
            var manager = targetList[i].Manager;
            console.log('targetList[i].Manager:', manager);
    
            if (!manager || manager.length == 0 || manager[0] == null) {
                helper.showMyToast('Error', "'" + targetList[i].Name + "'"+ ' 장비의 담당자가 없습니다.');
                component.set('v.isLoading', false);
                return;
            }
        }
    
        var targetData = targetList.map(function(target) {
            return {
                Id: target.Id,
                Manager: target.Manager
            };
        });

        var jsonTargetData = JSON.stringify(targetData);
        var recordId = component.get('v.recordId');
        console.log('recordId', recordId);
        var action = component.get('c.extractTicket');
        action.setParams(
            {
                recordId: recordId,
                targetData: jsonTargetData
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                helper.showMyToast('SUCCESS', '티켓 생성이 성공적으로 완료되었습니다.')
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
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
        });
        $A.enqueueAction(action);
    },
})