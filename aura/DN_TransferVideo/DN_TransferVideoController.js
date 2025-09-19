({
    init : function(component, event, helper) {
        var action = component.get('c.getViedoURL');
        action.setParams({
            recordId : component.get('v.recordId'),
            searchKey : component.get('v.searchKey'),
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result', result);
            if(response.getState() === 'SUCCESS' && result.isSuccess == true){
                console.log('result', result);
                component.set('v.videoList', result.returnList);
                component.set('v.contactId', result.returnValue);
                component.set('v.phone', result.phoneNum);
            }else{
                console.log('error', result.errMessage);
            }
        });
        $A.enqueueAction(action);
    },
    handleContact : function(component, event, helper) {
        console.log('handleContact');
        //var contactId = component.find('contact').get('v.value');
        var contactId = component.get('v.contactId')[0];
        if(!$A.util.isEmpty(contactId)){
            component.set('v.isSpinner', true);
            var action = component.get('c.getContactPhone');
            action.setParams({
                contactId : contactId
            });
            action.setCallback(this, function(response){
                var result = response.getReturnValue();
                console.log(result);
                if(response.getState() === 'SUCCESS' && result.isSuccess == true){
                    component.set('v.phone', result.returnValue);
                }else{
                    console.log('error', result.errMessage);
                }
            });
            $A.enqueueAction(action);
            component.set('v.isSpinner', false);
        }else{
            component.set('v.phone', '');
        }
        
    },
    handleSearch : function(component, event, helper){
        component.set('v.isLoading', true);
        console.log('handleSearch');
        var action = component.get('c.getViedoURL');
        action.setParams({
            recordId : component.get('v.recordId'),
            searchKey : component.get('v.searchKey'),
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result', result);
            if(response.getState() === 'SUCCESS' && result.isSuccess == true){
                console.log('result', result);
                component.set('v.videoList', result.returnList);
                component.set('v.contactId', result.returnValue);
                component.set('v.phone', result.phoneNum);
            }else{
                console.log('error', result.errMessage);
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    hadleCheck : function(component, event, helper) {
        console.log('hadleCheck');
        var checkbox = component.find('checkbox');
        var videoList = component.get('v.videoList');

        // checkbox 가 단일 오브젝트일때 예외처리
        if (!Array.isArray(checkbox)) {
            checkbox = [checkbox];
            console.log('checkbox', JSON.stringify(checkbox.length));
        }
        var selectedVideoList = [];
        for (var i = 0; i < checkbox.length; i++) {
            if (checkbox[i].get("v.checked")) {
                selectedVideoList.push(videoList[i]);
            }
        }
        console.log('selectedVideoList::', JSON.stringify(selectedVideoList));
        component.set('v.selectedVideoList', selectedVideoList);
    },

    handleCancel : function(component, event, helper) {
        helper.closeModal(component);
    },

    handleSend : function(component, event, helper) {
        component.set('v.isLoading', true);
        var selectedVideoList   = component.get('v.selectedVideoList');
        var recordId            = component.get('v.recordId');
        var phone               = component.get('v.phone');
        console.log('selectedVideoList',selectedVideoList);
        console.log('recordId',recordId);
        console.log('phone',phone);

        if(phone == null || phone == '') {
            helper.showMyToast('Error', '전화번호를 입력하여 주십시오.');
            component.set('v.isLoading', false);
            return;
        }

        var phonePattern = /^(?:\d{3}-\d{4}-\d{4}|\d{11})$/;
        if (!phonePattern.test(phone)) {
            helper.showMyToast('Error', '잘못된 전화번호 형식입니다.');
            component.set('v.isLoading', false);
            return;
        }

        if(selectedVideoList.length < 1) {
            helper.showMyToast('Error', '최소 1개이상의 영상자료를 선택하여 주십시오.');
            component.set('v.isLoading', false);
            return;
        }

        var action = component.get('c.sendVideoURL');
        action.setParams(
            {
                'recordId': recordId,
                'phone': phone,
                'selectedVideoList': selectedVideoList
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                helper.showMyToast('SUCCESS', '성공적으로 발송되었습니다.')
                component.set('v.isLoading', false);
                helper.closeModal(component);
            } else {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                    helper.showMyToast('Error', '발송에 실패하였습니다. 관리자에게 문의하십시오.')
                    component.set('v.isLoading', false);
                } else {
                    helper.showMyToast('Error', '발송에 실패하였습니다. 관리자에게 문의하십시오.')
                    component.set('v.isLoading', false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})