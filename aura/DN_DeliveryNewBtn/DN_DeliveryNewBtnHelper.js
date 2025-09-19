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
        console.log('close', isCancel);

        if(!component) {
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        } else {

            const targetPageId = isCancel ? component.get('v.recordId') : component.get('v.doId');
    
            component.find("navigation")
            .navigate({
                "type" : "standard__recordPage",
                "attributes": {
                    "recordId"      : targetPageId,
                    "actionName"    : "view"
                }
            }, true);
            $A.get('e.force:refreshView').fire();
        }

    }


    , uploadFile: function (component, fieldName, fileName, base64Data, contentType) {
        console.log('uploadFile', fileName, contentType, fieldName);
        const self = this;

        const action = component.get("c.uploadFile");
        action.setParams({
            fileName: fileName,
            base64Data: base64Data,
            contentType: contentType,
            fileType: fieldName
        });

        action.setCallback(self, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const fileId = response.getReturnValue();
                const fileFields = component.get("v.fileFields");
                const field = fileFields.find((f) => f.name === fieldName);

                if (field) {
                    field.fileName = fileName;
                    field.fileId = fileId;
                }

                component.set("v.fileFields", fileFields);
                self.reverseLoading(component);
            } else {
                self.handleError('uploadFile', response.getError());
                self.reverseLoading(component);
            }
        });

        $A.enqueueAction(action);
    }

    , deleteFile: function (component, fileIds) {
        console.log('deleteFile', fileIds);
        
        const self = this;
        const action = component.get("c.deleteFiles");
        action.setParams({ fileIds : fileIds });

        action.setCallback(self, function (response) {
            const state = response.getState();
            if (state !== "SUCCESS") {
                self.handleError('deleteFile', response.getError());
            }
            self.reverseLoading(component);
        });

        $A.enqueueAction(action);
    }

    , createTicket : function (component, deliveryOrder, wrapper, helper) {
        console.log('createTicket');
        const self = this;
        if(!wrapper.isRequired) {
            self.toast('success', $A.get("$Label.c.DNS_M_DOCreated")); // Delivery order has been successfully created.
            self.close(component, false);
            return;
        }

        // 배송처
        wrapper.accountId               = component.get("v.shipToId");
        wrapper.accountShippingAddress  = component.get('v.shipToAddress');
        
        // 판매 대리점
        wrapper.salesDealer             = component.get("v.currentUser").AccountId;
        wrapper.receptionist            = component.get("v.currentUser").Id;
        wrapper.FM_ReceptionistMP       = component.get('v.currentUser').conMP;

        wrapper.receptionDetails  = component.get("v.ReceptionDetails__c");

        let Requester = wrapper.selectRep && wrapper.selectRep.shipToRepId ? wrapper.selectRep.shipToRepId : null;

        if(Requester == null) {
            var shipToRepName  = wrapper.shipToRepName;
            var shipToRepMP    = wrapper.shipToRepMP;
            var shipToRepTitle = wrapper.shipToRepTitle;
            var shipToId       = component.get('v.shipToId');

            let action = component.get('c.createContact');
            action.setParams({
                shipToRepName  : shipToRepName,
                shipToRepMP    : shipToRepMP,
                shipToRepTitle : shipToRepTitle,
                shipToId       : shipToId
            });
            action.setCallback(self, function(response) {
                if(response.getState() === "SUCCESS") {
                    let result = response.getReturnValue();
                    console.log('result >> ' +JSON.stringify(result,null,4));

                    wrapper.shipToRepId = result;
                    console.log('wrapper 1 >> '+JSON.stringify(wrapper,null,4))
                    console.log('deliveryOrder >> '+JSON.stringify(deliveryOrder,null,4))
                    self.saveTicket(component, wrapper, deliveryOrder);
                }else{
                    console.log('errors >> '+response.getError());
                }
            })
            $A.enqueueAction(action);
        }else {
            wrapper.shipToRepId = Requester;
            console.log('wrapper 2 >> ' +JSON.stringify(wrapper,null,4))
            self.saveTicket(component, wrapper, deliveryOrder);
        }


        // return new Promise(function(resolve, reject) {
        //     let action = component.get("c.saveTicket");
        //     action.setParams({deliveryOrder : deliveryOrder, wrapper : wrapper});
        //     action.setCallback(self, function(response) {
        //         if (response.getState() === "SUCCESS") {
        //             self.toast('success', $A.get("$Label.c.DNS_M_DOCreated")); // Delivery order has been successfully created.
        //             $A.get('e.force:refreshView').fire();
        //             self.close(component, false);
        //         } else {
        //             reject(response.getError());
        //         }
        //     });
        //     $A.enqueueAction(action);
        // });
    }

    , saveTicket : function(component, wrapper, deliveryOrder) {
        console.log('wrapper >> '+JSON.stringify(wrapper,null,4))
        console.log('deliveryOrder >> '+JSON.stringify(deliveryOrder,null,4))
        const self = this; 
        return new Promise(function(resolve, reject) {
            let action = component.get("c.saveTicket");
            action.setParams({
                deliveryOrder: deliveryOrder,
                wrapper: wrapper
            });
            action.setCallback(self, function(response) {
                if (response.getState() === "SUCCESS") {
                    self.toast('success', $A.get("$Label.c.DNS_M_DOCreated"));
                    $A.get('e.force:refreshView').fire();
                    self.close(component, false);
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
    
    , fieldValue : function(component, name, selectedValue, helper) {
        const attributeName = "v." + name;
        const self = this;
        component.set(attributeName, selectedValue);
        console.log('attributeName :: ' +attributeName);
        console.log('selectedValue :: ' +selectedValue);

        if(name == 'ContactId') {
            var accRepInfo = component.get('v.accRepInfo');
            let selectRep = accRepInfo.filter(e => e.repId == selectedValue);
            component.set('v.selectRep', selectRep[0]);
            console.log('select :: ' +JSON.stringify(component.get('v.selectRep'),null,4))
        }

        if(name == 'TrainingCount__c') {
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
        }

        const td = new Date();
        var todayDate = td.toISOString().split('T')[0];
    
        if(name == 'TrainingDateTime1__c') {
            console.log('날짜 비교1');
            
            var valueDate = selectedValue.split('T')[0];
            console.log('valueDate >> ' +valueDate);

            if(todayDate >= valueDate) {
                self.toast('error', '오늘이나 과거를 선택할 수 없습니다.');
                component.set(attributeName, null);
            }
        }

        if(name == 'TrainingDateTime2__c') {
            console.log('날짜 비교2');
            var eduDate = component.get('v.TrainingDateTime1__c');
            console.log('eduDate >> ' +eduDate);
            console.log('selectedValue >> ' +selectedValue);

            if(eduDate > selectedValue) {
                self.toast('error', '요청일시(1)보다 과거를 선택할 수 없습니다.');
                component.set(attributeName, null);
            }
        }

        if(name == 'TrainingDateTime3__c') {
            console.log('날짜 비교3');
            var eduDate = component.get('v.TrainingDateTime2__c');
            console.log('eduDate >> ' +eduDate);
            console.log('selectedValue >> ' +selectedValue);

            if(eduDate > selectedValue) {
                self.toast('error', '요청일시(2)보다 과거를 선택할 수 없습니다.');
                component.set(attributeName, null);
            }
        }

    }
})