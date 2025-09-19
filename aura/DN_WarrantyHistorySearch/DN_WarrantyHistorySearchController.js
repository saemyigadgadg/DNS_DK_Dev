/**
 * @author            : Jun-Yeong Choi
 * @description       : 
 * @last modified on  : 2024-06-18
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   2024-06-18   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component.set('v.warrantyList', []);
        component.set('v.whereCondition',{
            Type :'',
            SerialNumber : '',
            historyStart : null,
            historyEnd : null,
            orderByField : '',
            orderBy : '',
        });
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params.message);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params.message);
                    break;
                case 'Seach':
                    if(component.get('v.whereCondition').SerialNumber =='' && component.get('v.whereCondition').Type=='') {
                        helper.toast('error', '기종 또는 장비번호는 필수로 입력해주세요');
                    } else {
                        helper.getDataList(component);    
                    }
                    break;
                default:
                    break;
            }  
        }
    },

    // handleCompEvent : function(component, event, helper) {
    //     var modalName = event.getParam("modalName");
    //     var action = event.getParam("action");
    //     var message = event.getParam("message");

    //     if(modalName == 'DN_ModelSearchModal') {
    //         component.set('v.modelValue', message.SVC_MODEL);

    //     }

    // },

})