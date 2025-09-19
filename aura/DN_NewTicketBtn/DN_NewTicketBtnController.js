/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-09-15
 * @last modified by  : sunwoong.han@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-20   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    //Get Recently Viewed Ticket List 화면 Id
    init : function(component, event, helper) {

        // 2025-02-26 하수헌 추가
        var recordId = String(window.location.search).replaceAll('%2F', '/').split('/')[4];
        component.set('v.recordId', recordId);
        console.log('window.location.search ::: ', window.location.search);
        console.log('recordId ::: ', recordId);
        

        helper.apex(component, "getRecordInfo", {})
        .then(function(result){
            console.log('getRecordInfo', result);
            if(result.isSuccess){
                component.set('v.listId', result.returnValue);
                component.set('v.country', result.country);
                component.set('v.recordTypeOptions', result.picklist);
                component.set('v.radioValue', result.picklist[0].value);
                component.set('v.radioLabel', result.picklist[0].label);
                if(result.picklist[0].label.includes('Ticket')){
                    component.set('v.isTicket', true);
                }else{
                    component.set('v.isTicket', false);
                }
                console.log('isTicket', component.get('v.isTicket'));
            }else{
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_E_FetchDataError'), 'Error');
            }
        });
    },
    //Record Type 선택
    handleRadio : function(component, event, helper) {
        const selectedValue = event.getParam('value');
        console.log('Selected Value:', selectedValue);

        const picklist = component.get('v.recordTypeOptions');
        const selectedOption = picklist.find(option => option.value === selectedValue);

        if (selectedOption) {
            component.set('v.radioLabel', selectedOption.label);
            if(selectedOption.label.includes('Ticket')){
                component.set('v.isTicket', true);
            }else{
                component.set('v.isTicket', false);
            }            
            console.log('selectedOption.label',selectedOption.label);
        }
    },
    //선택한 Ticket 유형에 맞춰서 기본값 Setting
    handleNext : function(component, event, helper) {
        component.set('v.isLoading', true);
        console.log('length',component.get('v.ticketInfo').length);
        console.log('radioValue', component.get('v.radioValue'));
        component.set('v.isNext', true);

        const currentDatetime = new Date().toISOString();
        const ticketInfo = [{ApplicationDateTime__c: currentDatetime}];
        console.log('radioLabel', component.get('v.radioLabel'));
        console.log('isTicket', component.get('v.radioLabel').includes('Ticket'));
        if(component.get('v.radioLabel').includes('Ticket')){
            ticketInfo[0].FailureArea__c = '';
            ticketInfo[0].FailureAreaDetail__c = '';
            ticketInfo[0].FailurePhenomenon__c = '';
            ticketInfo[0].TicketType__c = 'Technical inquiry';
            ticketInfo[0].ReceptionPath__c = 'Indirect application';
        }
        console.log('majorOptions',component.get('v.majorOptions'));
        component.set("v.ticketInfo", ticketInfo);
        console.log('ticketInfo',ticketInfo);
        component.set('v.isLoading', false);
    },
    //Ticket 저장
    handleSaveRecord: function(component, event, helper) {
        component.set('v.isLoading', true);
        var ticketInfo = component.get('v.ticketInfo')[0];
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

        var isTicket = component.get('v.isTicket');
        var isRequired = component.get('v.isRequired');

        const profileName = component.get('v.CurrentUser.Profile.Name');
        var isFailure = component.get('v.isFailure');


        if(isTicket){

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

            //isFailure true면 고장정보 필수
            if(isFailure == true && (profileName != 'DNS CS Receptionist')){
                if($A.util.isEmpty(ticketInfo.FailureArea__c) ||
                   $A.util.isEmpty(ticketInfo.FailureAreaDetail__c) ||
                   $A.util.isEmpty(ticketInfo.FailurePhenomenon__c)){
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

            //접수일시 필수
            if($A.util.isEmpty(ticketInfo.ApplicationDateTime__c)){
                helper.toast(component, 'ERROR',$A.get('$Label.c.DNS_E_EnterApplicationDate'), 'Error');
                component.set('v.isLoading', false);
                return;
            }

        }else{
            //접수내용 필수값 처리
            if($A.util.isEmpty(ticketInfo.AssetId) || $A.util.isEmpty(ticketInfo.ReceptionDetails__c)){
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
                component.set('v.isLoading', false);
                return;
            }
        }
        
        // Apex Call
        helper.apex(component, "saveTicket", {
            recordTypeId      : component.get('v.radioValue'),
            ticketData      : JSON.stringify(ticketInfo)
        })
        .then(function(result){
            console.log('saveTicket',result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', $A.get('$Label.c.DNS_S_CreateTicketSuccess'), 'Success');
                helper.navigateRecord(component, result.returnValue);
            }else{
                helper.toast(component, 'ERROR', result.errMessage, 'Error');
                component.set('v.isLoading', false);
            }
        });
    },
    // 2025-03-01 하수헌 추가
    handleCancel: function(component, event, helper) {
        var recordId = component.get("v.recordId");
    
        if (recordId) {
            helper.checkRecord(component, recordId);
        } else {
            helper.navigateList(component);
        }

        // 2025-09-15 lwc event listener 추가.
        const el = component.find('evt-listener');
        el.doCancel();
    },
    // handleCancel: function(component, event, helper) {
    //     helper.navigateList(component);
    // },
    //DNSA의 Ticket인 경우, 티켓유형(대)가 General Inquiry일 때 고객/장비정보 필수 제외
    handleMajorType : function(component, event, helper){
        console.log('ticket type ', event.getParam('value'));
        component.set('v.ticketMajorType', event.getParam('value'));
        var value = event.getParam('value');
        var country = component.get('v.country');
        if(country == 'DNSA' && value == 'General inquiry'){
            component.set('v.isRequired', false);
        }else{
            component.set('v.isRequired', true);
        }
    },
    //티켓유형(중)이 고장접수면 고장상태 필수 입력
    //티켓유형(대)가 내부요청이면 장비 필수 입력
    handleTicketType : function(component, event, helper){
        console.log('ticket type ', event.getParam('value'));
        var ticketType = event.getParam('value');
        var ticketMajorType = component.get('v.ticketMajorType');
        var country = component.get('v.country');
        
        if(ticketType == 'Installation request' || (country == 'DNSA' && ticketMajorType == 'General inquiry')){
            component.set('v.isRequired', false);
        }else{
            component.set('v.isRequired', true);
        }

        const profileName = component.get('v.CurrentUser.Profile.Name');
        if(ticketType == 'Failure receipt' || ticketType == 'Customer Support' ){
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

            if(profileName != 'DNS CS Receptionist'){
                component.set('v.isFailure', true);
            }else{
                component.set('v.isFailure', false);
            }
        }else{
            component.set('v.isFailure', false);
        }

        // if(profileName != 'DNS CS Receptionist'){
        //     if(ticketType == 'Failure receipt'){
        //         var ticketInfo = component.get('v.ticketInfo')[0];
        //         if(ticketInfo.ApplicationDateTime__c != null){
        //             var applicationDate = new Date(ticketInfo.ApplicationDateTime__c);
        //             var updatedTicketInfo = Object.assign({}, ticketInfo);
        //             if(ticketInfo.BreakdownDateTime__c == null){
        //                 updatedTicketInfo.BreakdownDateTime__c = applicationDate.toISOString();
        //             }
        //             if(ticketInfo.RepairRequestDateTime__c == null){
        //                 var repairRequestDate = new Date(applicationDate);
        //                 repairRequestDate.setHours(repairRequestDate.getHours() + 1);
        //                 updatedTicketInfo.RepairRequestDateTime__c = repairRequestDate.toISOString();
        //             }
        //             component.set('v.ticketInfo', [updatedTicketInfo]);
        //         }
        //         component.set('v.isFailure', true);
        //     }else{
        //         component.set('v.isFailure', false);
        //     }
        // }
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
    handleAsset: function(component, event, helper) {
        var equipmentArr = event.getParam('value');
        var ticketInfo = component.get('v.ticketInfo');
        console.log('ticketInfo asset', JSON.stringify(ticketInfo[0]));
        console.log('equipmentArr', equipmentArr);
        var isTicket = component.get('v.isTicket');

        //장비 선택 시 고객사 정보 가져오기 & 고장부위 정보 가져오기
        if(equipmentArr.length > 0){
            var equipment = equipmentArr[0];
            console.log('Equipment Id :', equipment);
            component.set('v.isLoading', true);
            helper.apex(component, "getMajorFailureArea", {
                assetId : equipment,
                country : component.get('v.country')
            })
            .then(function(result){
                console.log('getMajorFailureArea',result);
                if(result.isSuccess == true){  
                    component.set('v.majorOptions', result.failurePick);
                    var ticketInfo = component.get('v.ticketInfo');
                    console.log('ticketInfo',ticketInfo[0]);
                    ticketInfo[0].AccountId = result.returnValue;
                    ticketInfo[0].Dealer__c = result.SoldTo;
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
            if(isTicket){
                ticketInfo[0].AccountId = '';
                ticketInfo[0].Dealer__c = '';
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
    handleAccount : function(component, event, helper){
        var accArr = event.getParam('value');
        console.log('accArr',accArr);
        if(accArr.length == 0){
            var ticketInfo = component.get('v.ticketInfo');
            ticketInfo[0].AssetId = '';
            component.set('v.ticketInfo',ticketInfo);
        }
    },

    // 2025-01-20 Account의 Equipment검색
    handleModalEquipment : function(component, event, helper){
        component.set('v.isSearchEquipment', true);
        var accountId = document.getElementById('ticketAccountId').value;
        if (accountId != null && accountId != '') {
            helper.apex(component, 'getEquipmentOfAccount', {
                accountId : accountId
            }).then(result => {
                console.log('result ::: ', JSON.stringify(result));
                component.set('v.resultList', result);
                document.getElementById('ticketModalAccountId').value = accountId;
            });
        }
    },

    // 2025-01-20 Account의 Contact검색
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
                document.getElementById('ticketModalAccountId').value = accountId;
            });
        }
    },

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
            helper.toast(component, 'Error', $A.get('$Label.c.DNS_E_EnterAccount'), 'error');
        }
    },

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

    handleSelect : function(component, event, helper){
        var ticketInfo = component.get('v.ticketInfo')[0];
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

    handleModalCancel : function(component, event, helper){
        component.set('v.checkIndex', null);
        component.set('v.isSearchEquipment', false);
        component.set('v.isSearchContact', false);
        component.set('v.isAddContact', false);
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
            helper.toast(component, 'ERROR', $A.get("$Label.c.DNS_E_EnterAccount"), 'Error');
            return;
        }
        
        if($A.util.isEmpty(newContact.Name) || $A.util.isEmpty(newContact.MobilePhone)){
            helper.toast(component, 'ERROR', $A.get("$Label.c.DNS_E_EnterContact"), 'Error');
            return;
        }

        var data = JSON.stringify(newContact);

        helper.apex(component, "contactSave", {
            accountId: accountId,
            data : data
        })
        .then(function(result){
            console.log('contactSave',result);
            if(result.isSuccess){  
                helper.toast(component, 'SUCCESS', $A.get("$Label.c.DNS_S_CreateContactSuccess"), 'Success');
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

    // addRow : function(component, event, helper){

    //     var newList = component.get("v.newList");
    //     var addRow = {
    //         "Name" : "",
    //         "MobilePhone" : ""
    //     }
    //     newList.push(addRow);
    //     component.set("v.newList", newList);

    // },
    // delRow : function(component, event, helper){
    //     var rowIndex = event.getSource().get('v.accesskey');
    //     var newList = component.get("v.newList");
    //     newList.splice(rowIndex, 1);
    //     component.set('v.newList',newList);
    // },
    // saveNewContact : function(component, event, helper){
    //     var accountId = document.getElementById('ticketModalAccountId').value;
    //     console.log('accountId', accountId);
    //     var newList = component.get('v.newList');
    //     var data = JSON.stringify(newList);
    //     console.log('newList', data);

    //     if($A.util.isEmpty(accountId)){
    //         helper.toast(component, 'ERROR', '고객사 정보를 입력해주세요.', 'Error');
    //         return;
    //     }
    //     if(newList.length == 0){
    //         helper.toast(component, 'ERROR', '새로 등록할 연락처 정보를 입력해주세요.', 'Error');
    //         return;
    //     }
    
    //     component.set('v.isLoading', true);
    //     helper.apex(component, "contactSave", {
    //         accountId: accountId,
    //         data : data
    //     })
    //     .then(function(result){
    //         console.log('saveNewContact',result);
    //         if(result.isSuccess){  
    //             console.log('saveContact',result);
    //             helper.toast(component, 'SUCCESS', '연락처가 등록되었습니다.', 'Success');
    //             component.set('v.isAddContact', false);
    //             component.set('v.isLoading', false);
    //         }else{
    //             component.set('v.isLoading', false);
    //         }
    //     });
    //     // component.set('v.isAddContact', false);
    // },
    // handlePrev : function(component, event, helper){
    //     component.set('v.isAddContact', false);
    //     component.set('v.newList', []);
    // },
})