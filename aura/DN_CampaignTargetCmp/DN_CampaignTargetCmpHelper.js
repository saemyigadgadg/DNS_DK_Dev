({
    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },

    openObjectRecord: function (recordId, objtype) {
        var url = '/lightning/r/' + objtype + '/' + recordId + '/view';
        window.open(url, '_blank');
    },

    callDoInit: function (component, event) {
        component.set('v.isLoading', true);
        component.set('v.alamTalkSend', $A.get("$Label.c.DNS_B_AlamTalkSend"));
        component.set('v.satisfactionResult', $A.get("$Label.c.DNS_B_SatisfactionResult"));

        // 첫 번째 서버 호출: getCampaignTarget
        var action = component.get("c.getHappyCallResult");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', JSON.stringify(result));
                component.set("v.ctList", result);
                component.set("v.surveyName", result[0].surveyName);
                component.set('v.originalCTList', JSON.parse(JSON.stringify(result)));

                component.set("v.options", result[0].surveyResultValues);
        
            } else {
                helper.showMyToast('Error', '정보를 불러오는 중 문제가 발생하였습니다.');
            }
        });
        $A.enqueueAction(action);

        // // 두 번째 서버 호출: getHeaderWrapper
        // var action2 = component.get("c.getHeaderWrapper");
        // action2.setParams({
        //     recordId: component.get("v.recordId")
        // });
        // action2.setCallback(this, function (response2) {
        //     var state2 = response2.getState();
        //     console.log('state2:', state2);
        //     if (state2 === "SUCCESS") {
        //         var result2 = response2.getReturnValue();
        //         console.log('result2', result2);
        //         component.set("v.headerList", result2);
        //     } else {
        //         helper.showMyToast('Error', '정보를 불러오는 중 문제가 발생하였습니다.');
        //     }
        // });
        // $A.enqueueAction(action2);

        // 세 번째 서버 호출: getObjectType
        var action3 = component.get("c.getObjectType");
        action3.setParams({
            recordId: component.get("v.recordId")
        });
        action3.setCallback(this, function (response3) {
            var state3 = response3.getState();
            console.log('state3:', state3);
            if (state3 == "SUCCESS") {
                var result3 = response3.getReturnValue();
                console.log('result3:', result3.happyCallType);
                component.set("v.happyCallType", result3.happyCallType);
                component.set('v.isLoading', false);

            } else {
                helper.showMyToast('Error', 'HappyCall Type 의 값이 Null 입니다.');
            }
        });
        $A.enqueueAction(action3);
    },

    // handleGlobalClick: function (component, event) {
    //     console.log("handleGlobalClick:", event);
    //     var ctList = component.get('v.ctList');
    //     for(var i = 0; i < ctList.length; i++) {
    //         ctList[0].campaignTargetWrapper[i].isEditing = false;
    //     }
    // }
    
})