({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var firstaction = component.get("c.initRoleList");
        firstaction.setParams({
            recordId : recordId
        });
        firstaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.roleList', result);

                var action = component.get("c.getRoleList");
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

    registerRole : function(component, event, helper) {
        component.set('v.openRegisterRole', true);
    },

    roleListCancel: function(component, event, helper) {
        component.set('v.openRegisterRole', false);
    },

    changeRole: function(component, event, helper) {
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

    roleRegister: function(component, event, helper) {
        var recordId      = component.get('v.recordId');
        var selectedValue = component.get('v.selectedValue');
        var selectedLabel = component.get('v.selectedLabel');
        console.log('selectedValue', selectedValue);
        console.log('selectedLabel', selectedLabel);

        var action = component.get('c.submitRole');
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
            if (state == "SUCCESS") {
                if (result.isSuccess == true) {
                    helper.showMyToast('SUCCESS', 'Role 등록이 완료되었습니다.');
                    component.set('v.openRegisterRole', false);
                    $A.getCallback(function() {
                        component.get("c.doInit").run();
                    })();
                } else {
                    helper.showMyToast('ERROR', 'Role이 이미 등록되어있습니다.');
                }
            } else {
                helper.showMyToast('ERROR', 'Role 등록이 실패하였습니다.');
            }
        });
        $A.enqueueAction(action);
    },

    roleDelete: function (component, event, helper) {
        component.set('v.isLoading', true);
        var rowIndex = event.getSource().get('v.accesskey');
        console.log('rowIndex', rowIndex);
        var roleList = component.get('v.roleList');
        var roleId = roleList[rowIndex].Id;
        console.log('roleId',roleId);
        var action = component.get('c.deleteRole');
        action.setParams(
            {
                roleId: roleId
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == "SUCCESS") {
                helper.showMyToast('Success', '등록된 Role 이 삭제되었습니다.')
                $A.getCallback(function() {
                    component.get("c.doInit").run();
                })();
            } else {
                helper.showMyToast('Error', '등록된 Role 삭제가 실패하였습니다.');
            }
        });
        component.set('v.isLoading', false);
        $A.enqueueAction(action);
    }
})