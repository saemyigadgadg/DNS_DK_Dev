({
    init : function(component, event, helper) {
        // Apex Call
        helper.apex(component, "getVOCInfo", {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            console.log('getVOCInfo',result);
            if(result.isSuccess){
                var ticketInfo = {FailureArea__c: '', ApplicationDateTime__c : new Date().toISOString() };
                Object.assign(ticketInfo, result.returnCase);
                component.set('v.majorOptions', result.fw.failureArea);
                component.set('v.ticketInfo', ticketInfo);
                component.set('v.isLoading', false);
            }else{
                component.set('v.isLoading', false);
            }
        });
    },
    handleSave : function(component, event, helper) {
        component.set('v.isLoading', true);
        var ticketInfo = component.get('v.ticketInfo');
        console.log('ticketInfo',JSON.stringify(ticketInfo));

        if(Array.isArray(ticketInfo.AccountId)){
            if(ticketInfo.AccountId.length > 0){
                ticketInfo.AccountId = ticketInfo.AccountId[0];
            }else{
                ticketInfo.AccountId = '';
            }
        }

        if(Array.isArray(ticketInfo.AssetId)){
            if(ticketInfo.AssetId.length > 0){
                ticketInfo.AssetId = ticketInfo.AssetId[0];
            }else{
                ticketInfo.AssetId = '';
            }
        }

        if (Array.isArray(ticketInfo.Requester__c)){
            if(ticketInfo.Requester__c.length > 0){
                ticketInfo.Requester__c = ticketInfo.Requester__c[0];
            }else{
                ticketInfo.Requester__c = '';
            }
        }

        delete ticketInfo.Id;

        const profileName = component.get('v.CurrentUser.Profile.Name');
        var isRequired = component.get('v.isRequired');
        var isFailure = component.get('v.isFailure');
        console.log('isFailure',isFailure);
        console.log('profileName',profileName);

        //접수일시&고장일시&수리요청일시
        var applicationDatetime = new Date(ticketInfo.ApplicationDateTime__c);
        var breakdownDatetime = new Date(ticketInfo.BreakdownDateTime__c);
        var requestedRepairDatetime = new Date(ticketInfo.RepairRequestDateTime__c);

        if (applicationDatetime != null && breakdownDatetime != null) {
            if (applicationDatetime < breakdownDatetime) {
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_TD_timeValidation'), 'Error');
                component.set('v.isLoading', false);
                return;
            }
        }

        if (applicationDatetime != null && requestedRepairDatetime != null) {
            if (applicationDatetime > requestedRepairDatetime) {
                helper.toast(component, 'ERROR',  $A.get('$Label.c.DNS_E_RepairDatetime'), 'Error');
                component.set('v.isLoading', false);
                return;
            }
        }

        //접수내용 & Ticket Type 필수값 처리
        if($A.util.isEmpty(ticketInfo.ReceptionDetails__c) || $A.util.isEmpty(ticketInfo.TicketType__c) || $A.util.isEmpty(ticketInfo.InternalTicketType__c)){
            helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
            component.set('v.isLoading', false);
            return;
        }
        
        //isRequired true면 asset 필수
        if(isRequired){
            if($A.util.isEmpty(ticketInfo.AssetId)){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                component.set('v.isLoading', false);
                return;
            }
        }

        //고장시간 < 접수시간 Validation
        if(ticketInfo.ApplicationDateTime__c!= null && ticketInfo.BreakdownDateTime__c != null){
            if(ticketInfo.BreakdownDateTime__c > ticketInfo.ApplicationDateTime__c){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_E_TimeCheck'), 'Error');
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

        helper.apex(component, "saveRecord", {
            ticketData : JSON.stringify(ticketInfo)
        })
        .then(function(result){
            console.log('saveRecord',result);
            if(result.isSuccess){
                helper.navigateToRecord(component, result.returnValue, 'Case');
                helper.toast(component, 'SUCCESS', $A.get('$Label.c.DNS_S_CreateTicketSuccess'), 'Success');
            }else{
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_E_TicketError'), 'Error');
                component.set('v.isLoading', false);
            }
        });
    },
    handleCancel : function(component, event, helper) {
        helper.closeModal(component);
    },

    handleUrgent: function(component, event, helper) {
        var ticketInfo = component.get('v.ticketInfo');
        ticketInfo.IsUrgency__c = event.getParam('checked');
        helper.checkBoxEvent(component);
    },
    handleRegenerate: function(component, event, helper) {
        var ticketInfo = component.get('v.ticketInfo');
        ticketInfo.IsReGenerate__c = event.getParam('checked');
        helper.checkBoxEvent(component);
    },
    handleAlarm: function(component, event, helper) {
        var ticketInfo = component.get('v.ticketInfo');
        ticketInfo.isAlarmToCustomer__c = event.getParam('checked');
    },
    //티켓유형(중) 변경
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
                var ticketInfo = component.get('v.ticketInfo');
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
                    component.set('v.ticketInfo', updatedTicketInfo);
                    console.log('Updated ticketInfo:', JSON.stringify(updatedTicketInfo));
                }
                
                component.set('v.isFailure', true);
                component.set('v.isMajorDisabled', false);
            }else{
                component.set('v.isFailure', false);
            }
        }
    },
    //고장부위 변경
    handleMajor : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo');
        console.log('FailureArea__c',ticketInfo.FailureArea__c);
        ticketInfo.FailureAreaValue__c = ticketInfo.FailureArea__c;

        var majorPick = ticketInfo.FailureArea__c;
        if(!$A.util.isEmpty(majorPick)){
            component.set('v.isLoading', true);

            var selectedValue = ticketInfo.FailureArea__c;
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
                    console.log('ticketInfo',ticketInfo);
                    ticketInfo.FailureAreaDetail__c = '';
                    ticketInfo.FailurePhenomenon__c = '';
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
    //고장부위 상세 변경
    handleMiddle : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo');
        console.log('FailureAreaDetail__c',ticketInfo.FailureAreaDetail__c);
        ticketInfo.FailureAreaDetailValue__c = ticketInfo.FailureAreaDetail__c;
        
        var majorPick = ticketInfo.FailureArea__c;
        var middlePick = ticketInfo.FailureAreaDetail__c;
        if(!$A.util.isEmpty(middlePick)){
            component.set('v.isLoading', true);

            var selectedValue = ticketInfo.FailureAreaDetail__c;
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
                    console.log('ticketInfo',ticketInfo);
                    ticketInfo.FailurePhenomenon__c = '';
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
    //고장 현상 변경
    handlePhenomenon : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo');
        var selectedValue = ticketInfo.FailurePhenomenon__c;
        ticketInfo.FailurePhenomenonValue__c = ticketInfo.FailurePhenomenon__c;
        const options = component.get("v.phenomenonOptions");
        const selectedOption = options.find(option => option.value === selectedValue);
        const selectedLabel = selectedOption ? selectedOption.label : null;
        console.log("Selected Label:", selectedLabel);
        component.set('v.phenomenonLabel', selectedLabel);
    },

    // Equipment검색 (2025-02-10 서영덕 추가)
    handleModalEquipment : function(component, event, helper){
        component.set('v.isSearchEquipment', true);
        var accountId = document.getElementById('ticketAccountId').value;
        console.log('accountId', accountId);
        if (accountId != null && accountId != '') {
            helper.apex(component, 'getEquipmentOfAccount', {
                accountId : accountId
            }).then(result => {
                console.log('result ::: ', result);
                component.set('v.resultList', result);
                // component.set('v.ticketModalAccountId', accountId);
                document.getElementById('ticketModalAccountId').value = accountId;
            });
        }
    },

    // Contact검색 (2025-02-10 서영덕 추가)
    handleModalContact : function(component, event, helper){
        component.set('v.isSearchContact', true);
        var accountId = document.getElementById('ticketAccountId').value;
        console.log('accountId ::: ' + accountId);
        if (accountId != null && accountId != '') {
            helper.apex(component, 'getContactOfAccount', {
                accountId : accountId
            }).then(result => {
                console.log('result ::: ', JSON.stringify(result));
                component.set('v.resultList', result);
                // component.set('v.ticketModalAccountId', accountId);
                document.getElementById('ticketModalAccountId').value = accountId;
            });
        }
    },

    // Equipment검색, Contact검색 Modal안의 검색 (2025-02-10 서영덕 추가)
    handleSearch : function(component, event, helper){
        var accountId = document.getElementById('ticketModalAccountId').value;
        if (accountId != null && accountId != '') {
            if (component.get('v.isSearchEquipment')) {
                helper.apex(component, 'getEquipmentOfAccount', {
                    accountId : accountId
                }).then(result => {
                    console.log('result ::: ', JSON.stringify(result));
                    component.set('v.resultList', result);
                });            
            } else if (component.get('v.isSearchContact')) {
                helper.apex(component, 'getContactOfAccount', {
                    accountId : accountId
                }).then(result => {
                    console.log('result ::: ', JSON.stringify(result));
                    component.set('v.resultList', result);
                });    
            }
        } else {
            helper.toast(component, 'Error', '고객사를 입력해주세요', 'error');
        }
    },
    
    // Equipment검색, Contact검색 Modal안의 검색 (2025-02-10 서영덕 추가)
    handleCheckboxChange : function(component, event, helper){
        try {
            var index = event.target.name;
            var checkbox = component.find('checkbox');
            var resultList = component.get('v.resultList');

            if (Array.isArray(checkbox)) {
                if (checkbox[index].get('v.checked')) {
                    for (let i = 0; i < checkbox.length; i++) {
                        if (i == index) continue;
                        checkbox[i].set('v.checked', false);
                    }
                    if (component.get('v.isSearchEquipment')) {
                        component.set('v.selectEquipId', resultList[index].Id);
                    } else if (component.get('v.isSearchContact')) {
                        component.set('v.selectContactId', resultList[index].Id);
                    }
                } else {
                    if (component.get('v.isSearchEquipment')) {
                        component.set('v.selectEquipId', '');
                    } else if (component.get('v.isSearchContact')) {
                        component.set('v.selectContactId', '');
                    }
                }
            } else {
                if (checkbox.get('v.checked')) {
                    if (component.get('v.isSearchEquipment')) {
                        component.set('v.selectEquipId', resultList[index].Id);
                    } else if (component.get('v.isSearchContact')) {
                        component.set('v.selectContactId', resultList[index].Id);
                    }                    
                } else {
                    if (component.get('v.isSearchEquipment')) {
                        component.set('v.selectEquipId', '');
                    } else if (component.get('v.isSearchContact')) {
                        component.set('v.selectContactId', '');
                    }
                }              
            }

        } catch (error) {
            console.log('Error : ' + error.message);
        }
    },

    // Equipment검색, Contact검색 Modal안의 검색 (2025-02-10 서영덕 추가)
    handleSelect : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo');
        document.getElementById('ticketAccountId').value = document.getElementById('ticketModalAccountId').value;
        ticketInfo.AccountId = document.getElementById('ticketModalAccountId').value;
        if (component.get('v.isSearchEquipment')) {
            document.getElementById('ticketAssetId').value = component.get('v.selectEquipId');
            ticketInfo.AssetId = component.get('v.selectEquipId');
            component.set('v.isLoading', true);
            helper.apex(component, "getMajorFailureArea", {
                assetId : ticketInfo.AssetId
            })
            .then(function(result){
                console.log('getMajorFailureArea',result);
                if(result.isSuccess == true){  
                    component.set('v.majorOptions', result.failurePick);
                    ticketInfo.FailureArea__c = '';
                    ticketInfo.FailureAreaDetail__c = '';
                    ticketInfo.FailurePhenomenon__c = '';
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
        } else if (component.get('v.isSearchContact')) {
            document.getElementById('ticketContactId').value = component.get('v.selectContactId');
            ticketInfo.Requester__c = component.get('v.selectContactId');
        }

        component.set('v.checkIndex', null);
        component.set('v.isSearchEquipment', false);
        component.set('v.isSearchContact', false);
        component.set('v.resultList', []);
    },

    // Equipment검색, Contact검색 Modal안의 검색 (2025-02-10 서영덕 추가)
    handleModalCancel : function(component, event, helper){
        component.set('v.checkIndex', null);
        component.set('v.isSearchEquipment', false);
        component.set('v.isSearchContact', false);
        component.set('v.resultList', []);
        
        component.set('v.isAddContact', false);
        component.set('v.newConName', '');
        component.set('v.newConMobilePhone', '');
    },

    addContact : function(component, event, helper){
        var isAddContact = component.get('v.isAddContact');
        if(isAddContact){
            component.set('v.isAddContact', false);
        }else{
            component.set('v.isAddContact', true);
        }
        
    },
    createContact : function(component, event, helper){
        var accountId = document.getElementById('ticketModalAccountId').value;
        console.log('accountId', accountId);
        var newContact = {
            Name : component.get('v.newConName'),
            MobilePhone : component.get('v.newConMobilePhone')
        };
        console.log('newContact',newContact);
        if($A.util.isEmpty(accountId)){
            helper.toast(component, 'ERROR', '고객사 정보를 입력해주세요.', 'Error');
            return;
        }
        
        if($A.util.isEmpty(newContact.Name) || $A.util.isEmpty(newContact.MobilePhone)){
            helper.toast(component, 'ERROR', '새로 등록할 연락처 정보를 입력해주세요.', 'Error');
            return;
        }

        var data = JSON.stringify(newContact);
        console.log('data', data);

        helper.apex(component, "contactSave", {
            accountId: accountId,
            data : data
        })
        .then(function(result){
            console.log('contactSave',result);
            if(result.isSuccess){  
                helper.toast(component, 'SUCCESS', '연락처가 등록되었습니다.', 'Success');
                component.set('v.isAddContact', false);
                component.set('v.resultList', result.returnList);
                
                var resultList = component.get('v.resultList');
                var checkbox = component.find('checkbox');
                if(Array.isArray(checkbox)){
                    for (let i = 0; i < checkbox.length; i++) {
                        if (i == 0) {
                            checkbox[i].set('v.checked', true);
                            component.set('v.selectContactId', resultList[i].Id);
                        }else{
                            checkbox[i].set('v.checked', false);
                        }
                    }
                }else{
                    if (checkbox.get('v.checked')) {
                        component.set('v.selectContactId', resultList[0].Id);
                    }
                }
            
            }else{
                component.set('v.isLoading', false);
            }
        });
    },
})