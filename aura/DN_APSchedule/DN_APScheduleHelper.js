({
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    apexCall : function(component, methodName, params) {
        console.log('helper 동작 확인' + ' || ' + methodName)
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
                        console.log(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    addUserInfo : function(response) {
        var userInfo = {};

        if(response.Profile.Name === 'System Administrator') {
            userInfo = {
                userName    : response.Name,
                userId      : response.Id,
                userProfile : response.Profile.Name,
                dnUserId    : 'P_MTDO',
                conId       : '', 
                conCC       : '1244220',
                conSO       : '1846',
                conDV       : '40',
            };                    
        } else {
            userInfo = {
                userName    : response.Name,
                userId      : response.Id,
                userProfile : response.Profile.Name,
                dnUserId    : 'P_MTDO',
                conId       : response.ContactId || '', 
                conCC       : response.Contact && response.Contact.FM_CustomerCode__c ? response.Contact.FM_CustomerCode__c : '',
                conSO       : response.Contact && response.Contact.SalesOrganization__c ? response.Contact.SalesOrganization__c : '',
                conDV       : response.Contact && response.Contact.Division__c ? response.Contact.Division__c : '',
            };
        }

        return userInfo;
    },
})