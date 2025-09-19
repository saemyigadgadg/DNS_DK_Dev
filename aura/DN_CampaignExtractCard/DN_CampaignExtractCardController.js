({
    init: function (component, event, helper) {
        component.set("v.setExtractConditionLabel", $A.get("$Label.c.DNS_B_SetExtractCondition"));
        var action = component.get("c.getObjectType");
        action.setParams(
            {
                recordId: component.get("v.recordId")
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.SObjectName", result.objType);
            } else {
                helper.showMyToast('Error', '에러가 발생하였습니다.');
            }
        });
        $A.enqueueAction(action);

        // Platform Event
        try {
            helper.init(component);
            // SUCCESS
            var empApi = component.find("empApi");
            console.log(empApi);
            empApi.setDebugFlag(true); // active debug log
            var channel = "/event/RegisterTarget__e";
            console.log('ch', channel);
            var replayId = -1; // 최신 이벤트만 받기 위해 -1로 설정
            var callback = function (message) {
                helper.init(component);
            };
            empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
                console.log("Successfully Event ");
            }));

        } catch (e) {
            console.log(e);
        }

    },

    clickRefresh : function (component, event, helper) {
        helper.init(component);
    },

    conditionDelete: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        console.log('rowIndex', rowIndex);
        var happyCallList = component.get('v.happyCallList');
        var hcId = happyCallList[rowIndex].Id;
        var action = component.get('c.deleteCondition');
        action.setParams(
            {
                hcId: hcId
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result:', result);
                helper.showMyToast('Success', '추출 조건이 삭제되었습니다.')
                helper.init(component);
            } else {
                helper.showMyToast('Error', '추출 조건 삭제가 실패하였습니다.');
            }
        });
        $A.enqueueAction(action);
    },

    handleExtract: function (component, event, helper) {
        component.set("v.isLoading", true);
        var recordId = component.get('v.recordId');
        $A.createComponent("c:DN_SetExtractCondition",
            {
                'recordId' : recordId
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    console.log('Open SetExtractCondition');
                    var container = component.find("SetExtractCondition");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
        // modal창 켰을 때 배경 scroll 사라지게
        document.body.style.overflow = 'hidden';
    },

    cancelExtract: function (component, event, helper) {
        component.set('v.executeExtract', false);
        // modal창 껐을 때 배경 scroll 생기게
        document.body.style.overflow = 'auto';
    },

    campaignExtract: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var action = component.get('c.extractCampaign');
        action.setParams(
            {
                recordId: recordId
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);

            if (state == 'SUCCESS') {
                helper.showMyToast('SUCCESS', '추출이 성공적으로 완료되었습니다.')
                $A.get('e.force:refreshView').fire();
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
        component.set('v.executeExtract', false);
    },
})