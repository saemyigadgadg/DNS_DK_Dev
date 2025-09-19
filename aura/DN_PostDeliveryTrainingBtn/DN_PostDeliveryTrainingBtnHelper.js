({
    handleError : function(methodName, errorMsg) {
        var msg = errorMsg;
        if(typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
        if(msg.message) { msg = msg.message; }

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        this.toast('error', msg);
    }

    , toast: function (type, msg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: msg
        });
        toastEvent.fire();
    }

    , reverseLoading : function(component){
        console.log('reverseLoading');
        component.set('v.isLoading', !component.get('v.isLoading'));
    }

    , close : function(component, isCancel){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }

    , deleteFile: function (component, fileIds) {
        const self = this;
        const action = component.get("c.deleteFiles");
        action.setParams({ fileIds : fileIds });

        action.setCallback(self, function (response) {
            const state = response.getState();
            if (state !== "SUCCESS") {
                self.handleError('deleteFile', response.getError());
                self.reverseLoading(component);
            }
        });
        $A.enqueueAction(action);
    }

    , fieldValue : function(component, name, selectedValue) {
        const self = this;
        const attributeName = "v." + name;

        const today = new Date();
        const todayDate = today.toISOString().split('T')[0];

        component.set(attributeName, selectedValue);

        console.log('fieldValue - ', attributeName, selectedValue);

        if(name == 'contactId') {

            var accRepInfo = component.get('v.accRepInfo');
            let selectRep = accRepInfo.filter(e => e.repId == selectedValue);
            component.set('v.selectRep', selectRep[0]);

        } else if(name == 'TrainingCount__c') {

            if(selectedValue == '2회') {
                component.set('v.cnt2', true);
                component.set('v.cnt3', false);
                component.set('v.TrainingDateTime3__c', null);
            } else if(selectedValue == '3회') {
                component.set('v.cnt2', true);
                component.set('v.cnt3', true);
            } else {
                component.set('v.cnt2', false);
                component.set('v.cnt3', false);
                component.set('v.TrainingDateTime2__c', null);
                component.set('v.TrainingDateTime3__c', null);
            }
        } else if(name == 'TrainingDateTime1__c') {
            
            var valueDate = selectedValue.split('T')[0];
            if(todayDate >= valueDate) {
                self.toast('error', '오늘이나 과거를 선택할 수 없습니다.');
                component.set(attributeName, null);
            }
        } else if(name == 'TrainingDateTime2__c') {

            var eduDate = component.get('v.TrainingDateTime1__c');
            if(eduDate > selectedValue) {
                self.toast('error', '요청일시(1)보다 과거를 선택할 수 없습니다.');
                component.set(attributeName, null);
            }
        } else if(name == 'TrainingDateTime3__c') {

            var eduDate = component.get('v.TrainingDateTime2__c');
            if(eduDate > selectedValue) {
                self.toast('error', '요청일시(2)보다 과거를 선택할 수 없습니다.');
                component.set(attributeName, null);
            }
        }
    }

    , validateWrapper : function(component, wrapper) {
        let errorMsg = '';

        const cnt2 = component.get('v.cnt2');
        const cnt3 = component.get('v.cnt3');

        if(wrapper.shipToRepName == '') {
            errorMsg = '고객사 담당자 명을 입력해 주세요.';
        } else if(wrapper.shipToRepMP == '') {
            errorMsg = '고객사 연락처를 입력해 주세요.';
        } else if(wrapper.shipToRepTitle == '') {
            errorMsg = '직책을 입력해 주세요.';
        } else if(wrapper.trainingType == null) {
            errorMsg = '교육 종류를 선택해 주세요.';
        } else if(wrapper.trainingCount == null) {
            errorMsg = '교육 횟수를 선택해 주세요.';
        } else if(wrapper.traineeLevel == null) {
            errorMsg = '피교육자 수준을 선택해 주세요.';
        } else if(wrapper.owner == null) {
            errorMsg = '교육 담당자를 선택해 주세요.';
        } else if(wrapper.trainingDateTime1 == null) {
            errorMsg = '교육일자(1)을 선택해 주세요.';
        } else if(cnt2 && wrapper.trainingDateTime2 == null) {
            errorMsg = '교육일자(2)을 선택해 주세요.';
        } else if(cnt3 && wrapper.trainingDateTime3 == null) {
            errorMsg = '교육일자(3)을 선택해 주세요.';
        }

        return errorMsg;
    }
    
    , saveTicket : function(component, wrapper){
        const self = this; 

        return new Promise(function(resolve, reject) {
            let action = component.get("c.createTicket");
            action.setParams({recordId : component.get('v.recordId'), wrapper : wrapper});
            action.setCallback(self, function(response) {
                if (response.getState() === "SUCCESS") {
                    self.toast('success', '납품 후 교육이 생성되었습니다.');
                    $A.get('e.force:refreshView').fire();
                    self.close();
                    resolve();
                } else {
                    let errors = response.getError();
                    console.error('saveTicket error:', JSON.stringify(errors, null, 4));
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action);
        });
    }
})