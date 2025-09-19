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

    // 속성값 입력
    updateFieldValue: function(component, event) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");

        console.log('fieldName :: ' + fieldName);
        console.log('fieldValue :: ' + fieldValue);
 
        component.set("v." + fieldName, fieldValue);
    }, 

    // 사용자 정보 가져오기
    addUserInfo : function(response) {
        var userInfo = {};

        if(response.Profile.Name === 'System Administrator') {
            userInfo = {
                userName    : response.Name,
                userId      : response.Id,
                userProfile : response.Profile.Name,
                dnUserId    : 'S_MTDO',  // CRM userId 확립되면 그거 쓸 것.
                conId       : '', 
                conCC       : '1124140', // 고객코드
                conSO       : '1800',    // 판매조직(DN Solutions)
                conDV       : '40',      // 제품군(Machine Tools)
                conAcc      : '',
                conAccId    : '',
                conMP       : '010-111-1234',

            };                    
        } else {
            userInfo = {
                userName    : response.Name,
                userId      : response.Id,
                userProfile : response.Profile.Name,
                dnUserId    : 'S_MTDO',
                conId       : response.Contact.Id || '', 
                conCC       : response.Contact && response.Contact.FM_CustomerCode__c ? response.Contact.FM_CustomerCode__c : '',
                conSO       : response.Contact && response.Contact.SalesOrganization__c ? response.Contact.SalesOrganization__c : '',
                conDV       : response.Contact && response.Contact.Division__c ? response.Contact.Division__c : '',
                conAcc      : response.Contact && response.Contact.Account.Name ? response.Contact.Account.Name : '',
                conAccId    : response.Contact && response.Contact.AccountId ? response.Contact.AccountId : '',
                conMP       : response.Contact && response.Contact.MobilePhone ? response.Contact.MobilePhone : '010-0000-0000',
            };
        }

        return userInfo;
    },

    processResponse: function(component, response) {
        const formatDate = (dateString) => {
            const date = new Date(dateString);
            return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
        };

        const processedResponse = response.map(item => {
            item.CaseNumber = item.CaseNumber.replace(/^0+/, '');

            item.CreatedDate = formatDate(item.CreatedDate);
            item.TrainingDateTime1__c = formatDate(item.TrainingDateTime1__c);
            item.TrainingDateTime2__c = item.TrainingDateTime2__c !=null ? formatDate(item.TrainingDateTime2__c) : '';
            item.TrainingDateTime3__c = item.TrainingDateTime3__c !=null ? formatDate(item.TrainingDateTime3__c) : '';

            return item;
        });

        return processedResponse;
    }
})