({
    init : function(component, event, helper) {
        
        var action = component.get('c.getAvailableRecordType');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result', result);
            if(response.getState() == 'SUCCESS'){
                component.set('v.recordTypeOptions', result.picklist);
                component.set('v.radioValue', result.returnValue);
                component.set('v.radioLabel', result.returnLabel);
                component.set('v.recordTypeId', result.returnValue);
                if(result.returnLabel.includes('Ticket')){
                    component.set('v.isTicket', true);
                }else{
                    component.set('v.isTicket', false);
                }
                component.set('v.isLoading', false);
            }else{
                helper.toast(component, 'ERROR', 'ERROR', 'Error');
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleNext : function(component, event, helper) {
        console.log('radioValue', component.get('v.radioValue'));
        component.set('v.isLoading', true);
        component.set('v.isNext', true);
        
        helper.apex(component, "getTicketInfo", {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            console.log('getMajorFailureArea',result);
            if(result.isSuccess){
                if(result.fw){
                    component.set('v.majorOptions', result.fw.failureArea);
                    component.set('v.middleOptions', result.fw.failureAreaDeail);
                    component.set('v.phenomenonOptions', result.fw.failurePhenomenon);
                }
                
                if(!result.returnList[0].FailureArea__c){
                    result.returnList[0].FailureArea__c = '';
                    component.set('v.isMajorDisabled', false);
                }
                if(!result.returnList[0].FailureAreaDetail__c){
                    result.returnList[0].FailureAreaDetail__c = '';
                    component.set('v.isMiddleDisabled', false);
                }
                if(!result.returnList[0].FailurePhenomenon__c){
                    result.returnList[0].FailurePhenomenon__c = '';
                    component.set('v.isPhenomenonDisabled', false);
                }

                component.set('v.ticketInfo', result.returnList);

                console.log('ticketInfo', JSON.stringify(result.returnList));
                result.returnList[0].RecordTypeId = component.get('v.radioValue');
                component.set('v.recordTypeId', result.returnList[0].RecordTypeId);

                

                component.set('v.isLoading', false);   
            }else{
                helper.toast(component, 'ERROR', result.errMessage, 'Error');
                component.set('v.isLoading', false);
            }
        });
    },
    handleTicketType : function(component, event, helper) {
        var ticketType = event.getParam('value');
        if(ticketType == 'Installation request'){
            component.set('v.isRequired', false);
        }else{
            component.set('v.isRequired', true);
        }

        const profileName = component.get('v.CurrentUser.Profile.Name');
        if(profileName != 'DNS CS Receptionist'){
            if(ticketType == 'Failure receipt'){
                var ticketInfo = component.get('v.ticketInfo')[0];
                if(ticketInfo.ApplicationDateTime__c != null){
                    var applicationDate = new Date(ticketInfo.ApplicationDateTime__c);
                    var updatedTicketInfo = Object.assign({}, ticketInfo);
                    if(ticketInfo.BreakdownDateTime__c == null){
                        updatedTicketInfo.BreakdownDateTime__c = applicationDate.toISOString();
                    }
                    if(ticketInfo.RepairRequestDateTime__c == null){
                        var repairRequestDate = new Date(applicationDate);
                        repairRequestDate.setHours(repairRequestDate.getHours() + 1);
                        updatedTicketInfo.RepairRequestDateTime__c = repairRequestDate.toISOString();
                    }
                    component.set('v.ticketInfo', [updatedTicketInfo]);
                }
                component.set('v.isFailure', true);
            }else{
                component.set('v.isFailure', false);
            }
        }
    },
    handleUrgent: function(component, event, helper) {
        var ticketInfo = component.get('v.ticketInfo')[0];
        ticketInfo.IsUrgency__c = event.getParam('checked');
        helper.checkBoxEvent(component);
    },
    handleRegenerate: function(component, event, helper) {
        var ticketInfo = component.get('v.ticketInfo')[0];
        ticketInfo.IsReGenerate__c = event.getParam('checked');
        helper.checkBoxEvent(component);
    },
    handleAlarm: function(component, event, helper) {
        var ticketInfo = component.get('v.ticketInfo')[0];
        ticketInfo.isAlarmToCustomer__c = event.getParam('checked');
    },
    handleCancel : function(component, event, helper) {
        helper.closeModal(component);
    },
    handleSave : function(component, event, helper) {
        //저장
        component.set('v.isLoading', true);
        var isTicket = component.get('v.isTicket');
        var ticketInfo = component.get('v.ticketInfo')[0];
        var isRequired = component.get('v.isRequired');
        console.log('ticketInfo',JSON.stringify(ticketInfo));

        const profileName = component.get('v.CurrentUser.Profile.Name');
        var isFailure = component.get('v.isFailure');

        if(!isTicket){
            if($A.util.isEmpty(ticketInfo.AssetId) || $A.util.isEmpty(ticketInfo.ReceptionDetails__c)){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                component.set('v.isLoading', false);
                return;
            }
        }else{
            //접수내용 & Ticket Type 필수값 처리
            if($A.util.isEmpty(ticketInfo.ReceptionDetails__c) || $A.util.isEmpty(ticketInfo.TicketType__c) || $A.util.isEmpty(ticketInfo.InternalTicketType__c)){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                component.set('v.isLoading', false);
                return;
            }

            if(isRequired){
                if($A.util.isEmpty(ticketInfo.AssetId)){
                    helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                    component.set('v.isLoading', false);
                    return;
                }
            }

            //isFailure true면 고장정보 필수
            if(isFailure == true && (profileName != 'DNS CS Receptionist')){
                if($A.util.isEmpty(ticketInfo.FailureArea__c) ||
                   $A.util.isEmpty(ticketInfo.FailureAreaDetail__c) ||
                   $A.util.isEmpty(ticketInfo.FailurePhenomenon__c) ||
                   $A.util.isEmpty(ticketInfo.BreakdownDateTime__c)){
                    helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                    component.set('v.isLoading', false);
                    return;
                }
            }

            //고장관련 필드 value -> label로 변경
            if(!$A.util.isEmpty(ticketInfo.FailureArea__c)){
                ticketInfo.FailureArea__c = component.get('v.majorLabel');
                ticketInfo.FailureAreaDetail__c = component.get('v.middleLabel');
                ticketInfo.FailurePhenomenon__c = component.get('v.phenomenonLabel');
            }
        }
        
        var action = component.get('c.changeRecordType');
        action.setParams({
            recordId        : component.get('v.recordId'),
            recordTypeId    : component.get('v.radioValue'),
            ticketData      : JSON.stringify(ticketInfo)
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('change Record Type',result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', 'SUCCESS', 'Success');
                window.location.reload();
            }else{
                helper.toast(component, 'An error occurred, please contact your administrator.','ERROR');
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleAsset: function(component, event, helper) {
        var equipmentArr = event.getParam('value');
        var ticketInfo = component.get('v.ticketInfo');
        console.log('ticketInfo asset', JSON.stringify(ticketInfo[0]));
        console.log('equipmentArr', equipmentArr);
        var isTicket = component.get('v.isTicket');
        
        //Ticket이면 고장부위 정보가져오기
        if(isTicket){
            if(equipmentArr.length > 0){
                var equipment = equipmentArr[0];
                console.log('Asset', equipment);
    
                component.set('v.isLoading', true);
                helper.apex(component, "getMajorFailureArea", {
                    assetId : equipment
                })
                .then(function(result){
                    console.log('getMajorFailureArea',result);
                    if(result.isSuccess == true){  
                        component.set('v.majorOptions', result.failurePick);
                        var ticketInfo = component.get('v.ticketInfo');
                        console.log('ticketInfo',ticketInfo[0]);
                        ticketInfo[0].FailureArea__c = '';
                        ticketInfo[0].FailureAreaDetail__c = '';
                        ticketInfo[0].FailurePhenomenon__c = '';
                        component.set('v.ticketInfo',ticketInfo);
                        
                        component.set('v.majorLabel','');
                        component.set('v.middleLabel','');
                        component.set('v.phenomenonLabel','');
                        component.set('v.isMajorDisabled', false);
                        component.set('v.isMiddleDisabled', true);
                        component.set('v.isPhenomenonDisabled', true);
                        component.set('v.isLoading', false);
                    }else{
                        component.set('v.isLoading', false);
                    }
                });
            }else{
                var ticketInfo = component.get('v.ticketInfo');
                console.log('ticketInfo',ticketInfo[0]);
                ticketInfo[0].FailureArea__c = '';
                ticketInfo[0].FailureAreaDetail__c = '';
                ticketInfo[0].FailurePhenomenon__c = '';
                component.set('v.ticketInfo',ticketInfo);
                
                component.set('v.majorLabel','');
                component.set('v.middleLabel','');
                component.set('v.phenomenonLabel','');
            }
        }
    },
    handleMajor : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo');
        console.log('FailureArea__c',ticketInfo[0].FailureArea__c);
        ticketInfo[0].FailureAreaValue__c = ticketInfo[0].FailureArea__c;

        var majorPick = ticketInfo[0].FailureArea__c;
        if(!$A.util.isEmpty(majorPick)){
            component.set('v.isLoading', true);

            var selectedValue = ticketInfo[0].FailureArea__c;
            const options = component.get("v.majorOptions");
            const selectedOption = options.find(option => option.value === selectedValue);
            const selectedLabel = selectedOption ? selectedOption.label : null;
            console.log("Selected Label:", selectedLabel);
            component.set('v.majorLabel', selectedLabel);

            helper.apex(component, "getMiddleFailureArea", {
                major : majorPick
            })
            .then(function(result){
                console.log('getMiddleFailureArea',result);
                if(result.isSuccess == true){  
                    component.set('v.middleOptions', result.failurePick);
                    var ticketInfo = component.get('v.ticketInfo');
                    console.log('ticketInfo',ticketInfo[0]);
                    ticketInfo[0].FailureAreaDetail__c = '';
                    ticketInfo[0].FailurePhenomenon__c = '';
                    component.set('v.ticketInfo',ticketInfo);
                    component.set('v.middleLabel','');
                    component.set('v.phenomenonLabel','');

                    component.set('v.isMiddleDisabled', false);
                    component.set('v.isPhenomenonDisabled', true);
                    component.set('v.isLoading', false);
                }else{
                    component.set('v.isLoading', false);
                }
            });
        }
    },
    handleMiddle : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo');
        console.log('FailureAreaDetail__c',ticketInfo[0].FailureAreaDetail__c);
        ticketInfo[0].FailureAreaDetailValue__c = ticketInfo[0].FailureAreaDetail__c;
        
        var majorPick = ticketInfo[0].FailureArea__c;
        var middlePick = ticketInfo[0].FailureAreaDetail__c;
        if(!$A.util.isEmpty(middlePick)){
            component.set('v.isLoading', true);

            var selectedValue = ticketInfo[0].FailureAreaDetail__c;
            const options = component.get("v.middleOptions", selectedValue);
            const selectedOption = options.find(option => option.value === selectedValue);
            const selectedLabel = selectedOption ? selectedOption.label : null;
            console.log("Selected Label:", selectedLabel);
            component.set('v.middleLabel', selectedLabel);
            
            helper.apex(component, "getPhenomenonFailure", {
                major : majorPick,
                middle : middlePick
            })
            .then(function(result){
                console.log('getPhenomenonFailure',result);
                if(result.isSuccess == true){  
                    component.set('v.phenomenonOptions', result.failurePick);
                    var ticketInfo = component.get('v.ticketInfo');
                    console.log('ticketInfo',ticketInfo[0]);
                    ticketInfo[0].FailurePhenomenon__c = '';
                    component.set('v.ticketInfo',ticketInfo);

                    component.set('v.phenomenonLabel','');
                    component.set('v.isPhenomenonDisabled', false);
                    component.set('v.isLoading', false);
                }else{
                    component.set('v.isLoading', false);
                }
            });
        }
    },
    handlePhenomenon : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo');
        var selectedValue = ticketInfo[0].FailurePhenomenon__c;
        ticketInfo[0].FailurePhenomenonValue__c = ticketInfo[0].FailurePhenomenon__c;
        const options = component.get("v.phenomenonOptions");
        const selectedOption = options.find(option => option.value === selectedValue);
        const selectedLabel = selectedOption ? selectedOption.label : null;
        console.log("Selected Label:", selectedLabel);
        component.set('v.phenomenonLabel', selectedLabel);
    },
})