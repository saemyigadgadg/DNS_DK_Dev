/**
 * @author            : Junyeong, Choi
 * @Description       : 
 * @last modified on  : 2024-12-03
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-12-03   Junyeong.Choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.alamTalkSend', $A.get("$Label.c.DNS_B_AlamTalkSend"));
        component.set('v.satisfactionResult', $A.get("$Label.c.DNS_B_SatisfactionResult"));
    
        var today = new Date();
        var yyyy = today.getFullYear();
        var mm = (today.getMonth() + 1).toString().padStart(2, '0');
        var dd = today.getDate().toString().padStart(2, '0');
        var todayStr = yyyy + '-' + mm + '-' + dd;
    
        // 오늘 기준으로 7일 전 날짜 계산
        var sevenDaysAgo = new Date(today);
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
        var sYyyy = sevenDaysAgo.getFullYear();
        var sMm = (sevenDaysAgo.getMonth() + 1).toString().padStart(2, '0');
        var sDd = sevenDaysAgo.getDate().toString().padStart(2, '0');
        var startDateStr = sYyyy + '-' + sMm + '-' + sDd;
    
        component.set('v.startDate', startDateStr);
        component.set('v.endDate', todayStr);
                // // Document에 클릭 이벤트 리스너 추가
        // document.addEventListener("click", function (e) {
        //     helper.handleGlobalClick(component, e);
        // });
        
        // 첫 번째 서버 호출: getCampaignTarget
        var action = component.get("c.getHappyCallResult");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', JSON.stringify(result));
                component.set("v.ctList", result);
                component.set("v.surveyName", result[0].surveyName);
                component.set('v.originalCTList', JSON.parse(JSON.stringify(result)));

                component.set("v.options", result[0].surveyResultValues);
                var campaignDateSplit = result[0].CampaignName.split('_');

                if (campaignDateSplit.length > 1) {
                    var campaignDate = campaignDateSplit[1].replaceAll('.', '-'); // '2025.06.16'
                    component.set('v.startDate', campaignDate);
                    component.set('v.endDate', campaignDate);
                }
        
            } else {
                helper.showMyToast('Error', '정보를 불러오는 중 문제가 발생하였습니다.');
            }
        });
        $A.enqueueAction(action);

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
                $A.getCallback(function() {
                    component.get("c.clickSearch").run();
                })();
        } else {
                helper.showMyToast('Error', 'HappyCall Type 의 값이 Null 입니다.');
            }
        });
        $A.enqueueAction(action3);
    },

    clickSearch: function (component, event, helper) {
        component.set('v.isLoading', true);
        var startDate      = component.get('v.startDate');
        var endDate        = component.get('v.endDate');
        if(startDate == null || endDate == null) {
            component.set('v.isLoading', false);
            helper.showMyToast('Error', '요청기간 입력은 필수입니다.');
            return;
        }

        var start = new Date(startDate);
        var end   = new Date(endDate);
    
        // 한 달 차이 초과 확인
        var monthLater = new Date(start);
        monthLater.setMonth(monthLater.getMonth() + 1);
    
        if (end > monthLater) {
            component.set('v.isLoading', false);
            helper.showMyToast('Error', '조회기간은 최대 1개월까지 가능합니다.');
            return;
        }
    
        var action = component.get('c.getTargetList');
        action.setParams({
            recordId    : component.get("v.recordId"),
            startDate   : startDate,
            endDate     : endDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                // component.set("v.ctList", result);
                console.log('asdfasdf ::: ', result[74]);
                component.set('v.surveyAnswer', result);
            } else {
                helper.showMyToast('Error', '정보를 검색하는데 문제가 발생하였습니다. 관리자에게 문의하십시오.');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    clickRefresh: function (component, event, helper) {
        helper.callDoInit(component, event);
    },

    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox");
        var isChecked = component.find("headerCheckbox").get("v.checked");
        var clist = [];
        var ctList = component.get('v.ctList');

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked == true) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    checkbox.set("v.checked", isChecked);
                    clist.push(ctList[index]);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
                clist.push(0);
            }
        } else {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
            clist = [];
        }
        component.set('v.selectedCampaignTarget', clist);
        var selectedCampaignTarget = component.get('v.selectedCampaignTarget');
        console.log('selectedProd:', JSON.stringify(selectedCampaignTarget));
    },

    handleCheckboxChange: function (component, event, helper) {
        console.log('check');
        var checkbox = component.find('checkbox');
        var ctList = component.get('v.ctList');
        // checkbox가 단일 오브젝트일 때 예외처리
        if (!Array.isArray(checkbox)) {
            checkbox = [checkbox];
            console.log('checkbox', JSON.stringify(checkbox.length));
        }

        var selectedCampaignTarget = component.get('v.selectedCampaignTarget') || [];
        for (var i = 0; i < checkbox.length; i++) {
            var equipment = ctList[i];
            if (checkbox[i].get("v.checked")) {
                if (!selectedCampaignTarget.some(item => item.Id === equipment.Id)) {
                    selectedCampaignTarget.push(equipment); // 새로 추가
                }
            } else {
                selectedCampaignTarget = selectedCampaignTarget.filter(item => item.Id !== equipment.Id); // 선택 해제
            }
        }
        console.log('selectedCampaignTarget::', JSON.stringify(selectedCampaignTarget));
        component.set('v.selectedCampaignTarget', selectedCampaignTarget);
    },

    openCampaignTarget: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.openObjectRecord(recordId, 'CampaignTarget__c');
    },

    openTicket: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.openObjectRecord(recordId, 'Case');
    },

    openEquipment: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.openObjectRecord(recordId, 'Asset');

    },

    openUser: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.openObjectRecord(recordId, 'User');
    },

    openAccount: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.openObjectRecord(recordId, 'Account');
    },

    openServiceOrder: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.openObjectRecord(recordId, 'WorkOrder');
    },

    openURL: function (component, event, helper) {
        var url = event.currentTarget.getAttribute('data-url');
        console.log('url', url);
        if (url) {
            window.open(url, '_blank');
        } else {
            helper.showMyToast('Error', '해당 URL에 접속할 수 없습니다.');
        }
    },

    openAlarmTalk: function (component, event, helper) {
        var selectedCampaignTarget = component.get('v.selectedCampaignTarget');
        console.log('selectedCampaignTarget', selectedCampaignTarget);
        if (selectedCampaignTarget.length < 1) {
            helper.showMyToast('Error', '최소 하나 이상의 캠페인 타겟을 선택하여 주십시오.');
        } else {
            component.set('v.sendAlarmTalkModal', true);
            document.body.style.overflow = 'hidden';
        }
    },

    toggleEditing: function (component, event, helper) {
        var ctList = component.get('v.ctList');
        if (ctList.length < 1) {
            helper.showMyToast('Error', '생성된 대상 목록이 없습니다.');
        } else {
            var isEditing = component.get("v.isEditing");
            component.set("v.isEditing", !isEditing);
        }
    },

    resultCancel: function (component, event, helper) {
        component.set('v.isEditing', false);
        var originalCTList = component.get("v.originalCTList");

        var clonedCTList = JSON.parse(JSON.stringify(originalCTList));
        component.set("v.ctList", clonedCTList);
    },

    inputSurveyResult: function (component, event, helper) {
        var selectedValue = event.getSource().get('v.value');
        console.log('selectedValue', selectedValue);
        var index = event.getSource().get('v.accesskey');
        console.log('index', index);
        var ctList = component.get('v.ctList');
        ctList[0].campaignTargetWrapper[index].SurveyResult = selectedValue;
        component.set('v.ctList', ctList);
    },

    // 만족도 결과 입력 Save
    resultSave: function (component, event, helper) {
        component.set('v.isLoading', true);
        var ctList = component.get('v.ctList');
        console.log('ctList', ctList);
        var resultUpdate = [];
        ctList.forEach(function (res) {
            res.campaignTargetWrapper.forEach(function (wrapper) {
                var surveyResult = wrapper.SurveyResult;
                resultUpdate.push({
                    Id: wrapper.Id,
                    SurveyResult__c: surveyResult
                });
            });
        });
        console.log('resultUpdate', JSON.stringify(resultUpdate));
        var action = component.get("c.updateSurveyResult");
        action.setParams({ "resultUpdate": resultUpdate });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state', state);
            if (state == "SUCCESS") {
                helper.showMyToast('SUCCESS', '성공적으로 저장이 완료되었습니다.');
                component.set("v.isEditing", false);
            } else {
                helper.showMyToast('Error', '저장에 실패하였습니다. 관리자에게 문의하여 주십시오.');
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    cancelSend: function (component, event, helper) {
        component.set('v.sendAlarmTalkModal', false);
        document.body.style.overflow = 'auto';
    },

    clickSend: function (component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var selectedCampaignTarget = component.get('v.selectedCampaignTarget');
        console.log('selectedCampaignTarget', selectedCampaignTarget);
        var action = component.get("c.sendAlarmTalk");
        action.setParams({
            "selectedCampaignTarget": selectedCampaignTarget,
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                helper.showMyToast('SUCCESS', '성공적으로 발송이 완료되었습니다.');
            } else {
                helper.showMyToast('ERROR', '알림톡 발송에 실패하였습니다.');
            }
            component.set('v.sendAlarmTalkModal', false);
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    enableEdit: function (component, event, helper) {
        var rowIndex = event.currentTarget.getAttribute('data-index');
        console.log('rowIndex', rowIndex);
        var surveyAnswer = component.get("v.surveyAnswer");
        surveyAnswer[rowIndex].isEditing = true;
        component.set("v.surveyAnswer", surveyAnswer);
    },

    enableScoreEdit: function (component, event, helper) {
        var rowIndex = event.currentTarget.getAttribute('data-index');
        console.log('rowIndex', rowIndex);
        var surveyAnswer = component.get("v.surveyAnswer");
        surveyAnswer[rowIndex].isScoreEditing = true;
        component.set("v.surveyAnswer", surveyAnswer);
    },

    handleBlur: function (component, event, helper) {
        var accesskey = event.getSource().get('v.accesskey');
        console.log('blurAccess', accesskey);
        var surveyAnswer = component.get("v.surveyAnswer");
        if (surveyAnswer[accesskey]) {
            surveyAnswer[accesskey].isEditing = false;
        }
        component.set("v.surveyAnswer", surveyAnswer);
    },

    handleScoreBlur: function (component, event, helper) {
        component.set('v.isLoading', true);
        var accesskey = event.getSource().get('v.accesskey');
        console.log('blurAccess', accesskey);
        var surveyAnswer = component.get("v.surveyAnswer");
        if (surveyAnswer[accesskey]) {
            surveyAnswer[accesskey].isScoreEditing = false;
            var recordToUpdate = surveyAnswer[accesskey];
            var action = component.get("c.saveSurveyScore");
            action.setParams({
                recordId: recordToUpdate.Id,
                score: recordToUpdate.AdjustScore === '' ? null : recordToUpdate.AdjustScore
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    component.set('v.isLoading', false);
                } else {
                    helper.showMyToast('Error', '점수 저장이 실패하였습니다.');
                }
            });
    
            $A.enqueueAction(action);
        }
        component.set("v.surveyAnswer", surveyAnswer);    
    },

    handleMemoChange: function (component, event, helper) {
        var accesskey = event.getSource().get('v.accesskey');
        var newValue = event.getSource().get("v.value");
    
        var surveyAnswer = component.get("v.surveyAnswer");
    
        if (surveyAnswer[accesskey]) {
            surveyAnswer[accesskey].Memo = newValue;
        }
    
        component.set("v.surveyAnswer", surveyAnswer);
    },

    handleScoreChange: function (component, event, helper) {
        var accesskey = event.getSource().get('v.accesskey');
        var newValue = event.getSource().get("v.value");
    
        var surveyAnswer = component.get("v.surveyAnswer");
    
        if (surveyAnswer[accesskey]) {
            surveyAnswer[accesskey].AdjustScore = newValue;
        }
    
        component.set("v.surveyAnswer", surveyAnswer);
    },

    deleteMemo: function (component, event, helper) {
        var accesskey = event.getSource().get('v.accesskey');
        console.log('accesskey', accesskey);
        var surveyAnswer = component.get("v.surveyAnswer");
        if (surveyAnswer[accesskey]) {
            surveyAnswer[accesskey].Memo = '';
        }
        component.set("v.surveyAnswer", surveyAnswer);
    },

    saveMemo: function (component, event, helper) {
        component.set('v.isLoading', true);
        var accesskey = event.getSource().get('v.accesskey');
        console.log('accesskey', accesskey);
        var surveyAnswer = component.get("v.surveyAnswer");

        var memo = '';
        var ctId = '';
    
        if (surveyAnswer[accesskey]) {
            memo = surveyAnswer[accesskey].Memo;
            ctId = surveyAnswer[accesskey].Id;
        }
        console.log('Memo:', memo, 'ctId:', ctId);
        var action = component.get("c.updateMemo");
        action.setParams(
            {
                "memo": memo,
                "ctId": ctId
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state', state);
            if (state == "SUCCESS") {
                helper.showMyToast('SUCCESS', '저장되었습니다.');
                if (surveyAnswer[accesskey]) {
                    surveyAnswer[accesskey].isEditing = false;
                }
                component.set("v.surveyAnswer", surveyAnswer);
            } else {
                helper.showMyToast('ERROR', '저장에 실패하였습니다.');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    clickReSend: function (component, event, helper) {
        component.set('v.isLoading', true);
        var accesskey = event.getSource().get('v.accesskey');
        console.log('accesskey', accesskey);
        var surveyAnswer = component.get("v.surveyAnswer");
        var phone = '';
        var ctId = '';
        var ticketId = '';
        var requester = '';
        var surveyURL = '';
        var firstSend = null;
        if (surveyAnswer[accesskey]) {
            phone = surveyAnswer[accesskey].PhoneNumber;
            ctId = surveyAnswer[accesskey].Id;
            requester = surveyAnswer[accesskey].CustomerName;
            surveyURL = surveyAnswer[accesskey].SurveyURL;
            firstSend = surveyAnswer[accesskey].FirstSend;
            ticketId = surveyAnswer[accesskey].TicketId;
        }
        
        console.log('surveyURL:::', surveyURL);
        console.log('firstSend:::', firstSend);
        if (phone == null || phone == '') {
            helper.showMyToast('ERROR', '대상의 Phone 이 비워져있습니다.');
            component.set('v.isLoading', false);
            return;
        }
        var action = component.get("c.reSendAlarmTalk");
        action.setParams(
            {
                "ticketId": ticketId,
                "phone": phone,
                "recordId": component.get("v.recordId"),
                "ctId": ctId,
                "requester": requester,
                "surveyURL": surveyURL,
                "firstSend": firstSend
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state', state);
            if (state == "SUCCESS") {
                helper.showMyToast('SUCCESS', '전송에 성공하였습니다.');
                $A.get('e.force:refreshView').fire();
            } else {
                helper.showMyToast('ERROR', '전송에 실패하였습니다.');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    
})