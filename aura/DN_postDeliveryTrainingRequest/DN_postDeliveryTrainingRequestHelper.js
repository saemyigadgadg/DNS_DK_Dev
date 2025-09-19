/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-28-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-25-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    // toast 메세지
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    // apex 호출
    apexCall : function(component, methodName, params) {
        console.log('methodName' + ' || ' + methodName);
        console.log('params' + ' || ' + JSON.stringify(params,null,4));

        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);
                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's': response.getState()});
                    } else {
                        let errors = response.getError();
                        console.error('apexCall 에러 :: '+methodName +' '+ JSON.stringify(errors,null,4));
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },
    
    // 날짜 포멧 변환
    dayCount : function(selDay) {
        console.log('헬퍼 데이 카운트')
        let year  = selDay.getFullYear(); 
        let month = ('0' + (selDay.getMonth() + 1)).slice(-2);
        let day   = ('0' + selDay.getDate()).slice(-2);

        return year + '-' + month + '-' + day;
    },

    // 기간 계산
    dayCounter : function (sDate, eDate) {
        console.log('기간 계산')
        var diff = new Date(eDate) - new Date(sDate);
        var daySecond = 24*60*60*1000;
        var result = parseInt(diff/daySecond);
        return result
    },

    // 일시 입력
    dateCheck : function(component, event, helper) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");

        var today = new Date();
        var tommorow = component.get('v.tommorow');
        var eduDateOne = component.get('v.eduDateOne');
        var eduDateTwo = component.get('v.eduDateTwo');

        // 요청교육일시 순서 제한
        if(fieldName == 'eduDateOne') {
            let dateOne = new Date(today);
            let dateTwo = new Date(fieldValue);

            dateOne.setHours(0, 0, 0, 0);
            dateTwo.setHours(0, 0, 0, 0);            

            if (dateOne.getTime() > dateTwo.getTime()) {
                helper.toast('WARNING', '오늘보다 빠른 일자를 선택할 수 없습니다.');
                component.set('v.eduDateOne', tommorow);
                return;
            }
        }

        else if(fieldName == 'eduDateTwo') {
            
            if(eduDateOne == undefined || eduDateOne == null) {
                helper.toast('WARNING', '교육 요청 일시(1)를 먼저 작성해주세요.');
                component.set('v.eduDateTwo',null);
                return;
            } 

            let dateOne = new Date(eduDateOne);
            let dateTwo = new Date(fieldValue);

            dateOne.setHours(0, 0, 0, 0);
            dateTwo.setHours(0, 0, 0, 0);

            console.log(`${dateOne} 의 형태와 ${dateTwo} 의 형태 비교`);
            if (dateOne.getTime() >= dateTwo.getTime()) {
                helper.toast('WARNING', '교육 요청 일시(1) 보다 빠르거나 같은 날짜는 선택할 수 없습니다.');
                component.set('v.eduDateTwo', null);
                return;
            }
        } else if(fieldName == 'eduDateThr') {
            if(eduDateOne == undefined || eduDateOne == null) {
                helper.toast('WARNING', '교육 요청 일시(1)를 먼저 작성해주세요.');
                component.set('v.eduDateThr',null);
                return;
            } 
            else if(eduDateTwo == undefined || eduDateTwo == null) {
                helper.toast('WARNING', '교육 요청 일시(2)를 먼저 작성해주세요.');
                component.set('v.eduDateThr',null);
                return;
            }

            let dateOne = new Date(eduDateTwo);
            let dateTwo = new Date(fieldValue);

            dateOne.setHours(0, 0, 0, 0);
            dateTwo.setHours(0, 0, 0, 0);

            if (dateOne.getTime() >= dateTwo.getTime()) {
                helper.toast('WARNING', '교육 요청 일시(2) 보다 빠르거나 같은 날짜는 선택할 수 없습니다.');
                component.set('v.eduDateThr', null);
                return;
            }
        } else {
            component.set("v." + fieldName, fieldValue);
        }

        console.log(`${fieldName} 의 값은 ${fieldValue} 입니다.`);
    },

    // 속성값 입력
    updateFieldValue: function(component, event, helper) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");

        console.log('fieldName :: ' + fieldName);
        console.log('fieldValue :: ' + fieldValue);

        component.set("v." + fieldName, fieldValue);
 
        // 접수자 전화번호 수정
        if(fieldName === 'userMobilePhone') {
            console.log('접수자 전화번호 수정');
            var dealerInfo = component.get('v.dealerInfo');
            dealerInfo['userMobilePhone'] = fieldValue;
            component.set('v.dealerInfo', dealerInfo);
        }

        // 고객사 담당자 초기 정보
        if(fieldName === 'selectRep') {
            console.log('고객사 담당자 정보');
            let conList = component.get('v.conList');
            let selectRep = component.get('v.selectRep');
            
            console.log('conList :: ' +JSON.stringify(conList,null,4))
            console.log('selectRep :: ' +JSON.stringify(selectRep,null,4))
            let search = conList.filter(c => c.Id == selectRep);
            console.log('search>>> ' +JSON.stringify(search,null,4));

            component.set('v.repId', search[0].Id);
            component.set('v.repName', search[0].Name);
            component.set('v.repMP', search[0].MobilePhone ? search[0].MobilePhone : '번호 없음');
            component.set('v.repTitle', search[0].Title ? search[0].Title : '직책없음');
        }

        // 고객사 주소 수정
        if(fieldName === 'accAddress') {
            console.log('고객사 주소 수정');
            var accInfo = component.get('v.accInfo');
            accInfo['FM_Address__c'] = fieldValue;
            component.set('v.accInfo', accInfo);
        }

        if(fieldName == 'eduCnt') {
            if(fieldValue == '2회') {
                component.set('v.isED2', true);
                component.set('v.isED3', false);
            } else if (fieldValue == '3회') {
                component.set('v.isED2', true);
                component.set('v.isED3', true);
            } else {
                component.set('v.isED2', false);
                component.set('v.isED3', false);
            }
        }
    
    }, 

    // 납품 후 목록으로 돌아가기
    abackOrderInquiry: function (component, recordId, helper) {
        window.history.back();
    }, 

})