({
    init : function(component, event, helper) {

    },
    handleTarget : function(component, event, helper){
        // component.set('v.extractCondition', '');
    },
    handleCondition : function(component, event, helper){
        var extractTarget = component.get('v.extractTarget');
        var extractCondition = component.get('v.extractCondition');
        console.log(extractCondition);
        if(extractTarget == 'Work Order' && (extractCondition == '설치완료일자' || extractCondition == 'Warranty Start Date')){
            component.set('v.conditionDate', '설치완료일자');
        }else if(extractTarget == 'Ticket' && (extractCondition == '티켓종결일자' || extractCondition == 'Ticket Closed Date')){
            component.set('v.conditionDate', '티켓종결일자');
        }
    },
    handleCancel : function(component, event, helper) {
        helper.closeModal(component);
    },

    handleSave : function(component, event, helper){
        var extractTarget = component.get('v.extractTarget');
        if(extractTarget == ''){
            helper.toast(component, 'Error', '추출대상을 입력하여 주세요.', 'Error');
            return;
        }
        var extractCondition = component.get('v.extractCondition');
        if(extractCondition == ''){
            helper.toast(component, 'Error', '추출조건을 입력하여 주세요.', 'Error');
            return;
        }
        var conditionDate = component.get('v.conditionDate');
        console.log('conditionDate', conditionDate);
        var fromDate;
        var toDate;
        var ticketType;

        if(conditionDate == '설치완료일자'){
            fromDate = component.find('workOrderFromDate').get('v.value');
            toDate = component.find('workOrderToDate').get('v.value');
        }else if(conditionDate == '티켓종결일자'){
            fromDate = component.find('ticketFromDate').get('v.value');
            toDate = component.find('ticketToDate').get('v.value');
        }
        if(extractCondition == '티켓유형' || extractCondition == 'Ticket Type'){
            ticketType = component.get('v.ticketType');
            console.log('ticketType', ticketType);
        }
        if(fromDate == '' || toDate == '' || ticketType == ''){
            helper.toast(component, 'Error', '추출조건을 상세히 입력하여 주세요.', 'Error');
            return;
        }
        
        var extractionJson = {
            extractTarget : extractTarget,
            extractCondition : extractCondition,
            fromDate : fromDate,
            toDate : toDate,
            ticketType : ticketType 
        };
        var extractionData = JSON.stringify(extractionJson);
        console.log('extractionData',extractionData);

        var action = component.get('c.saveExtractionInfo');
        action.setParams({
            recordId : component.get('v.recordId'),
            extractionData : extractionData
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log(response.getState());
            if(response.getState() === 'SUCCESS'){
                console.log('result',response.getReturnValue());
                if(result.isSuccess){
                    helper.toast(component, 'Success', '성공적으로 추출조건이 등록되었습니다.', 'Success');
                }else{
                    helper.toast(component, 'Error :'+result.errMessage, 'ERROR', 'Error');     
                }
            }else{
                console.log('error',response.getReturnValue());
                helper.toast(component, 'Error :'+result.errMessage, 'ERROR', 'Error');
            }
        });
        $A.enqueueAction(action);
        helper.closeModal(component);
    }
})