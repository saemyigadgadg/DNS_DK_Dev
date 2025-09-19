({
    doInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId', recordId);
    },

    handleTarget: function (component, event, helper) {
        console.log(event.getSource());
        var value = event.getSource().get('v.value');
        console.log('value', value);
    },

    handleCondition: function (component, event, helper) {
        var extractTarget = component.get('v.extractTarget');
        var extractCondition = component.get('v.extractCondition');
        console.log(extractCondition);
        if (extractTarget == 'Service Order' && (extractCondition == '설치완료일자' || extractCondition == 'Warranty Start Date')) {
            component.set('v.conditionDate', '설치완료일자');
        } else if (extractTarget == 'Ticket' && (extractCondition == '티켓종결일자' || extractCondition == 'Ticket Closed Date')) {
            component.set('v.conditionDate', '티켓종결일자');
            
        } else if (extractTarget == 'Ticket' && (extractCondition == '티켓 유형' || extractCondition == 'Ticket Type')) {
            console.log('티켓 유형');
            component.set('v.conditionDate', null);
        }
    },

    handleCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    handleSave: function (component, event, helper) {
        var fromDate;
        var toDate;
        var ticketType;
        var ticketTypeMiddle;
        var conditionDate = component.get('v.conditionDate');
        console.log('conditionDate', conditionDate);
        
        var extractTarget = component.get('v.extractTarget');
        if (extractTarget == '' || extractTarget == null) {
            helper.showMyToast('Error', '추출대상을 입력하여 주십시오.');
            return;
        }

        var extractCondition = component.get('v.extractCondition');
        if (extractCondition == '' || extractCondition == null) {
            helper.showMyToast('Error', '추출조건을 입력하여 주십시오.');
            return;
        }

        var closedDateType = component.get('v.closedDateType');
        if(conditionDate == '티켓종결일자') {
            if(closedDateType == '' || closedDateType == null) {
                helper.showMyToast('Error', '티켓유형을 입력하여 주세요.');
                return;
            }
        }

        if (conditionDate == '설치완료일자') {
            fromDate = component.find('workOrderFromDate').get('v.value');
            toDate = component.find('workOrderToDate').get('v.value');
            if (fromDate == null || fromDate == '' || toDate == '' || toDate == null) {
                helper.showMyToast('Error', '일자를 입력하여 주십시오.');
                return;
            }
            if (fromDate > toDate) {
                helper.showMyToast('Error', '시작일자가 종료일자보다 빠릅니다.');
                return;
            }
        } else if (conditionDate == '티켓종결일자' && closedDateType == '종결 날짜 지정') {
            fromDate = component.find('ticketFromDate').get('v.value');
            toDate = component.find('ticketToDate').get('v.value');
            if (fromDate == null || fromDate == '' || toDate == '' || toDate == null) {
                helper.showMyToast('Error', '일자를 입력하여 주십시오.');
                return;
            }
            if (fromDate > toDate) {
                helper.showMyToast('Error', '시작일자가 종료일자보다 빠릅니다.');
                return;
            }
        }

        if (extractCondition == '티켓유형' || extractCondition == 'Ticket Type') {
            ticketType = component.get('v.ticketType');
            console.log('ticketType', ticketType);
            ticketTypeMiddle = component.get('v.ticketTypeMiddle');
            if (ticketType == null || ticketType == '') {
                helper.showMyToast('Error', '티켓유형을 입력하여 주세요.');
                return;
            }
            if (ticketTypeMiddle == null || ticketTypeMiddle == '') {
                helper.showMyToast('Error', '티켓유형(중분류)를 입력하여 주세요.');
                return;
            }
        }

        var extractionJson = {
            extractTarget: extractTarget,
            extractCondition: extractCondition,
            fromDate: fromDate,
            toDate: toDate,
            ticketType: ticketType,
            ticketTypeMiddle: ticketTypeMiddle,
            closedDateType: closedDateType
        };
        var extractionData = JSON.stringify(extractionJson);
        console.log('extractionData', extractionData);

        // setCallback
        var action = component.get('c.saveExtractionInfo');
        action.setParams({
            recordId: component.get('v.recordId'),
            extractionData: extractionData
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (result.isSuccess) {
                helper.showMyToast('Success', '성공적으로 추출조건이 등록되었습니다.');
                // window.location.reload()
                $A.get('e.force:refreshView').fire();
                helper.closeModal(component);
            } else {
                console.log('error', response.getReturnValue());
                helper.showMyToast('Error', '중복된 추출 조건의 등록은 불가능합니다.');
            }
        });
        $A.enqueueAction(action);
    }

})