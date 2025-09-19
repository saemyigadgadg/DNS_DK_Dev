({
    doInit: function (component, event, helper) {

    },

    changeLevel: function (component, event, helper) {
        var selectedLevel = component.get('v.selectedLevel');
        console.log('selectedLevel ::: ', selectedLevel);
        var action = component.get('c.getLevelData');
        action.setParams(
            {
                selectedLevel: selectedLevel
            }
        )
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result', JSON.stringify(result));
                component.set('v.ruleList', result);
            } else {
                console.log('state', state);
            }
        });
        $A.enqueueAction(action);
    },

    setRuleTarget: function (component, event, helper) {
        var idx             = event.currentTarget.title;
        console.log('idx', idx);
        var ruleList        = component.get('v.ruleList');
        var ruleTargetIndex = component.get('v.ruleTargetIndex');

        if(ruleTargetIndex != null){
            var selectTr 	= document.querySelector("#rule_" + ruleTargetIndex);
            console.log('selectTr ->', selectTr);
            selectTr.style.backgroundColor = '#ffffff';
        }

        // 신규 선택 항목 Style 생성
        var selectTr 	= document.querySelector("#rule_" + idx);
        selectTr.style.backgroundColor = '#D7BA7D';
        console.log('selectTr -->', selectTr);

        console.log('ruleList[idx]', ruleList[idx]);
        component.set('v.ruleTargetIndex', idx);
        component.set('v.ruleTarget', ruleList[idx]);
    },
    
    handleMove: function (component, event, helper) {
        var targetBtn 		= event.getSource().get('v.title'),
            ruleList  		= component.get('v.ruleList'),
            ruleTargetIndex	= Number(component.get('v.ruleTargetIndex')),
            ruleTarget		= component.get('v.ruleTarget');

        console.log('targetBtn', targetBtn);
        console.log('ruleTargetIndex', ruleTargetIndex);
        console.log('ruleTarget', ruleTarget);

        if(targetBtn == 'Up'){
            if(ruleTargetIndex == 0){
                return null;
            }

            ruleList.splice(ruleTargetIndex, 1);
            ruleList.splice(ruleTargetIndex-1, 0, ruleTarget);

            component.set('v.ruleTargetIndex', ruleTargetIndex - 1);
            component.set('v.ruleList',ruleList);
        }else if(targetBtn == 'Down'){
            if(ruleTargetIndex == ruleList.length-1){
                return null;
            }

            ruleList.splice(ruleTargetIndex, 1);
            ruleList.splice(ruleTargetIndex+1, 0, ruleTarget);

            component.set('v.ruleTargetIndex', ruleTargetIndex + 1);
            component.set('v.ruleList',ruleList);
        }

        console.log("#rule_" + (ruleTargetIndex-1));
        var newSelectTr 	= document.querySelector("#rule_" + (ruleTargetIndex));
        newSelectTr.style.backgroundColor = '#e9ecef';
    },

    handleSave: function (component, event, helper) {
        component.set('v.isLoading', true);
        var ruleList = component.get('v.ruleList');
        var jsonRuleList = JSON.stringify(ruleList);
        var action = component.get('c.saveEscIndex');
        action.setParams({
            jsonRuleList: jsonRuleList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                helper.showMyToast('SUCCESS', '성공적으로 저장이 완료되었습니다.');
                $A.get('e.force:refreshView').fire();
            } else {
                helper.showMyToast('ERROR', '저장이 실패하였습니다.');
            }            
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);

    }
})