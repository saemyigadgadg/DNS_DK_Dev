({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var firstaction = component.get("c.initQueueList");
        firstaction.setParams({
            recordId : recordId
        });
        firstaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.queueList', result);

                var action = component.get("c.getQueueList");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set('v.options', result);
                    } else {
                        helper.showMyToast('ERROR', '정보를 불러오지 못했습니다. 관리자에게 문의하세요.');
                    }
                });
                $A.enqueueAction(action);
        
            } else {
                helper.showMyToast('ERROR', '정보를 불러오지 못했습니다. 관리자에게 문의하세요.');
            }
        });
        $A.enqueueAction(firstaction);
    },

    registerQueue : function(component, event, helper) {
        component.set('v.openRegisterQueue', true);
    },

    queueListCancel: function(component, event, helper) {
        component.set('v.openRegisterQueue', false);
    },

    changeQueue: function(component, event, helper) {
        var selectedValue = component.get('v.selectedValue');
        console.log('selectedValue', selectedValue);
        var options = component.get("v.options");
        var selectedLabel = "";
        for (var i = 0; i < options.length; i++) {
            if (options[i].value == selectedValue) {
                selectedLabel = options[i].label;
                break;
            }
        }
        console.log('selectedLabel', selectedLabel);
        component.set("v.selectedLabel", selectedLabel);
    },

    queueRegister: function(component, event, helper) {
        var recordId      = component.get('v.recordId');
        var selectedValue = component.get('v.selectedValue');
        var selectedLabel = component.get('v.selectedLabel');
        console.log('selectedValue', selectedValue);
        console.log('selectedLabel', selectedLabel);

        var action = component.get('c.submitQueue');
        action.setParams(
            {
                recordId        : recordId,
                selectedValue   : selectedValue,
                selectedLabel   : selectedLabel
            }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == "SUCCESS") {
                if (result.isSuccess == true) {
                    helper.showMyToast('SUCCESS', 'Queue 등록이 완료되었습니다.');
                    component.set('v.openRegisterQueue', false);
                    $A.getCallback(function() {
                        component.get("c.doInit").run();
                    })();
                } else {
                    helper.showMyToast('ERROR', 'Queue 가 이미 등록이 되어있습니다.');
                }
            } else {
                helper.showMyToast('ERROR', '등록에 실패하였습니다. 관리자에게 문의하십시오.');
            }
        });
        $A.enqueueAction(action);
    },

    queueDelete: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        console.log('rowIndex', rowIndex);
        var queueList = component.get('v.queueList');
        var queueId = queueList[rowIndex].Id;
        console.log('queueList', queueList);
        var action = component.get('c.deleteQueue');
        action.setParams(
            {
                queueId: queueId
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == "SUCCESS") {
                helper.showMyToast('Success', '등록된 Queue 가 삭제되었습니다.')
                $A.getCallback(function() {
                    component.get("c.doInit").run();
                })();
            } else {
                helper.showMyToast('Error', '등록된 Queue 삭제가 실패하였습니다.');
            }
        });
        $A.enqueueAction(action);
    }
})