({
    doInit: function(component, event, helper) {
        const cloneType = 
            [
                {'label': $A.get("$Label.c.DNS_B_Clone"), 'value': 'Clone'},
                {'label': $A.get("$Label.c.DNS_B_ChangeType"), 'value': 'ChangeType'}
            ];
            component.set('v.title', $A.get("$Label.c.DNS_T_OptyCloneTitle"));
            component.set('v.optyInfo', $A.get("$Label.c.DNS_T_OptyCloneOptyInfo"));
            component.set('v.validated', $A.get("$Label.c.DNS_T_OptyCloneValidated"));
            component.set('v.qualified', $A.get("$Label.c.DNS_T_OptyCloneQualified"));
            component.set('v.condiAgree', $A.get("$Label.c.DNS_T_OptyCloneCondiAgree"));
            component.set('v.addInfo', $A.get("$Label.c.DNS_T_OptyCloneAddInfo"));
            component.set('v.desc', $A.get("$Label.c.DNS_T_OptyCloneDesc"));
            component.set('v.systemInfo', $A.get("$Label.c.DNS_T_OptyCloneSystemInfo"));
            
            
        var action = component.get("c.getStage");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                // console.log(returnValue);
                //closed이면 change type안됨
                if(returnValue.includes('Closed')){
                    const cloneTypeFilter = cloneType.filter(item => item.value === 'Clone');
                    // console.log(cloneTypeFilter);
                    component.set('v.cloneType', cloneTypeFilter);
                }else{
                    component.set('v.cloneType', cloneType);
                }
            }else {
                console.error("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

    },


    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        const fields = event.getParam('fields');
        // console.log('inquiry : ' + fields['Inquiry_Type__c']);

        if(fields['Inquiry_Type__c'] == ''){
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.DNS_M_Error"),
                            "message": $A.get("$Label.c.DNS_M_InquiryTypeSelectError"),
                            "type": "error"
                        });
                        toastEvent.fire();
            return;
        }
        component.set("v.isLoading", true);

        // console.log('1 : ' + event.preventDefault());
        fields['StageName'] = 'Identified';
        // fields['Id'] = component.get("v.recordId");
        // console.log(fields);
        var action = component.get("c.opptyCloneCreate");
        action.setParams({
            oppty : fields,
            recordId : component.get("v.recordId"),
            changeType : component.get("v.changeType"),
            changeRecordType : component.get("v.changeRecordType")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var value = response.getReturnValue();
                if (state === "SUCCESS") {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type" : "Success",
                        "title": $A.get("$Label.c.DNS_M_Success"),
                        "message": $A.get("$Label.c.DNS_M_Success")

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                    
                    //생성된 record Page로 이동
                    var returnVal = response.getReturnValue();    
                        component.set("v.newRecordId", returnVal);

                        var navService = component.find("navService");
                        var pageReference = {
                        type: "standard__recordPage",
                        attributes: {
                            "recordId": returnVal,
                            "objectApiName": 'opportunity',
                            "actionName": "view"
                        }
                    };
                navService.navigate(pageReference);

                }else {
                    var errors = response.getError();
                    // console.log('error : ' + JSON.stringify(errors));
                    if (errors && errors[0] && errors[0].message) {
                        // 에러 메시지 표시
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.DNS_M_Error"),
                            "message": errors[0].message,
                            "type": "error"
                        });
                        toastEvent.fire();
                        // var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        // dismissActionPanel.fire();
                        component.set("v.isLoading", false);

                    }
                }
                    
        });
        $A.enqueueAction(action);
    },

    changeCloneType: function(component, event, helper){
        var getValue = event.getParam('value');
        component.set('v.changeType', getValue);
        
        if(getValue === 'ChangeType'){
            var action = component.get("c.changeRecordTypes");
            action.setParams({
                recordId : component.get("v.recordId")
            });
    
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    // console.log(response.getReturnValue()[0]);
                    var returnValue = response.getReturnValue();
                    if (returnValue && returnValue.length > 0) {
                        var firstRecord = returnValue[0];
                        var DeveloperName = firstRecord.DeveloperName;
                        var Name = firstRecord.Name;
                        // console.log(DeveloperName);
                        component.set('v.changeRecordType', DeveloperName);
                        component.set('v.changeRecordName', Name);
    
                    }
                }else {
                    console.error("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        }else if(getValue === 'Clone'){
            var action = component.get("c.getRecordName");
            action.setParams({
                recordId : component.get("v.recordId")
            });

            action.setCallback(this, function(response){
                var state = response.getState(); 
                if (state === "SUCCESS") {
                    // console.log(response.getReturnValue()[0]);
                    var returnValue = response.getReturnValue();
                    if (returnValue && returnValue.length > 0) {
                        var firstRecord = returnValue[0];
                        var DeveloperName = firstRecord.DeveloperName;
                        var Name = firstRecord.Name;
                        component.set('v.changeRecordType', DeveloperName);
                        component.set('v.changeRecordName', Name);
                        // console.log('DeveloperName : ' + DeveloperName);

                    }
                }else {
                    console.error("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        }else {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        }
    }
})