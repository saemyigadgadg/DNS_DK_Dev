({
    init : function(component, event, helper) {
        var recId = component.get("v.recordId");

        if (recId) {
            console.log("레코드 ID 있음: " + recId);
            // 여기서 Apex 호출 또는 로직 실행 가능
        } else {
            console.log("레코드 ID 없음");
        }
        if (recId) {
        // if (component.get('v.isFromRecordPage')) {
            helper.refreshContent(component);
            component.set('v.hasUtilityBar', false);
            helper.applyHeight(component, event, helper);
        } else {
            var utilityAPI = component.find('utilitybar');
    
            utilityAPI.getAllUtilityInfo().then(function (response) {
                console.log('response',response);
                console.log(typeof response !== 'undefined');
                if (typeof response !== 'undefined') {
                    utilityAPI.toggleModalMode({
                        enableModalMode: true
                    });
                   utilityAPI.setPanelWidth({
                       widthPX: 1200,
                   });
                   utilityAPI.setPanelHeight({
                       heightPX:900
                   });
                    component.set('v.hasUtilityBar', true);
                    utilityAPI.onUtilityClick({
                        eventHandler: function() {
                            console.log('refreshContent');
                            helper.refreshContent(component);
                        }
                    });
                } else {
                    component.set('v.hasUtilityBar', false);
                }
            });
        }
        
    },
    handleworkCenter : function(component, event, helper) {
        component.set('v.isLoading', false);
        helper.getStaffList(component);
    },
    handledispatchStaff : function(component, event, helper) {
        
    },
    handleSearch : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.getSearchList(component);
    },
    handleLeftCheck : function(component, event, helper) {
        var searchList = component.get('v.searchList');
        var idx = event.getSource().get('v.accesskey');

        // var isSelect = [];
        var status = event.getSource().get('v.checked');
        if(status){
            searchList[idx].isChecked = true;
        }else{
            searchList[idx].isChecked = false;
        }
        console.log('searchList',searchList);
        component.set('v.searchList',searchList);
    },
    handleLeftAll : function(component, event, helper) {
        console.log('handleLeftAll');
        var isChecked = event.getSource().get('v.checked');
        var searchList = component.get('v.searchList');
        if(isChecked){
            searchList.forEach(ele => {
                ele.isChecked = true;
            });
        }else{
            searchList.forEach(ele => {
                ele.isChecked = false;
            });
        }
        var newList = searchList;
        console.log('searchList',searchList);
        component.set('v.searchList',newList);
    },
    
    handleRightCheck : function(component, event, helper) {
        var selectedList = component.get('v.selectedList');
        var idx = event.getSource().get('v.accesskey');
        var status = event.getSource().get('v.checked');        
        if(status){
            selectedList[idx].isChecked = true;
        }else{
            selectedList[idx].isChecked = false;
        }
        console.log('selectedList', JSON.stringify(selectedList));
        component.set('v.selectedList',selectedList);
    },

    handleRightAll : function(component, event, helper){
        console.log('handleRightAll');
        var isChecked = event.getSource().get('v.checked');
        var selectedList = JSON.parse(JSON.stringify(component.get('v.selectedList')));
        if(isChecked){
            selectedList.forEach(ele => {
                ele.isChecked = true;
            });
        }else{
            selectedList.forEach(ele => {
                ele.isChecked = false;
            });
        }
        component.set('v.selectedList',selectedList);

        selectedList.forEach(element => {
            console.log('element.isChecked',element.isChecked);
        });
        console.log('selectedList',Array.isArray(selectedList));
        
    },

    handleRight : function(component, event, helper) {
        var searchList = component.get('v.searchList');
        var selectedList = component.get('v.selectedList');
        var plusSelectedList = searchList.filter(ele => (ele.isChecked === true) && (!$A.util.isEmpty(ele.Phone))); 
        var noPhoneSelectedList = searchList.filter(ele => (ele.isChecked === true) && ($A.util.isEmpty(ele.Phone))); 
        searchList = searchList.filter(ele => (ele.isChecked === false) || ($A.util.isEmpty(ele.Phone))); 
        // searchList = searchList.filter(ele => ele.isChecked === false); 

        if(noPhoneSelectedList.length > 0){
            helper.toast(component, 'Error',noPhoneSelectedList[0].StaffName + '의 전화번호가 없습니다.' ,'ERROR');
        }
        if(plusSelectedList.length > 0){
            plusSelectedList.forEach(ele => {
                ele.isChecked = false;
            });
        }
        component.set('v.searchList',searchList);
        component.set('v.selectedList',selectedList.concat(plusSelectedList));
        helper.clearChecked(component);
    },
    handleLeft : function(component, event, helper) {
        var searchList = component.get('v.searchList');
        var selectedList = component.get('v.selectedList');
        var plusSearchList = selectedList.filter(ele => ele.isChecked === true); 
        selectedList = selectedList.filter(ele => ele.isChecked === false); 
        
        if(plusSearchList.length > 0){
            plusSearchList.forEach(ele => {
                ele.isChecked = false;
            });
        }
        component.set('v.searchList',searchList.concat(plusSearchList));
        component.set('v.selectedList',selectedList);
        helper.clearChecked(component);
    },
    handleInit : function(component, event, helper) {
        console.log('handleInit');
        helper.refreshContent(component);
    },

    openSMSConfirmModal : function(component, event, helper) {
        var selectedList = component.get('v.selectedList');
        console.log('selectedList', JSON.stringify(selectedList));
        var smsContent = component.get('v.smsContent');
        var inboundNum = component.get('v.inboundNum');
        console.log('inboundNum', inboundNum);
        if(selectedList.length == 0 && !inboundNum) {
            helper.toast(component, 'ERROR', '수신자의 휴대폰 번호를 확인해주세요.', 'Error');
            return null;
        }
        if(!smsContent) {
            helper.toast(component, 'ERROR', 'SMS 내용을 입력하여 주십시오.', 'Error');
            return null;
        }
        component.set('v.confirmModal', true);
    },

    cancelSMS : function(component, event, helper) {
        component.set('v.confirmModal', false);
    },

    sendSMS : function(component, event, helper) {
        component.set('v.isLoading', true);
        console.log('handleSend');
        var selectedList = component.get('v.selectedList');
        console.log('selectedList', JSON.stringify(selectedList));
        var smsContent = component.get('v.smsContent');
        var inboundNum = component.get('v.inboundNum');
        console.log('inboundNum', inboundNum);
        var outboundNum = component.get('v.outboundNum');
        
        var data = JSON.stringify({
            selectedList: selectedList,
            smsContent: smsContent,
            inboundNum: inboundNum,
            outboundNum: outboundNum
        });
        console.log('data', data);
        helper.snedSMS(component, data);
    },
    handleSMSList : function(component, event, helper){
        helper.getSMSList(component);
    },
    handleSearchTarget : function(component, event, helper){
        //helper.getSMSList(component);
    },
    handleManageTab : function(component, event, helper){
        console.log('handleManageTab');
        var recId = component.get("v.recordId");

        if (recId) {
            console.log("레코드 ID 있음: " + recId);
            // 여기서 Apex 호출 또는 로직 실행 가능
        } else {
            console.log("레코드 ID 없음");
        }
        if (recId) {
        // if (component.get('v.isFromRecordPage')) {
            helper.refreshContent(component);
            component.set('v.hasUtilityBar', false);
            helper.applyHeight(component, event, helper);
        } else {
            var utilityAPI = component.find('utilitybar');
            utilityAPI.getAllUtilityInfo().then(function (response) {
                console.log('response',response);
                if (typeof response !== 'undefined') {
                    utilityAPI.toggleModalMode({
                        enableModalMode: true
                    });
                utilityAPI.setPanelWidth({
                    widthPX: 1200,
                });
                utilityAPI.setPanelHeight({
                    heightPX:900
                });
                    component.set('v.hasUtilityBar', true);
                    utilityAPI.onUtilityClick({
                        eventHandler: function() {
                            console.log('refreshContent');
                            helper.refreshContent(component);
                        }
                    });
                } else {
                    component.set('v.hasUtilityBar', false);
                }
            });
        }
    },
    handleSendTab : function(component, event, helper){
        console.log('handleSendTab');
        var recId = component.get("v.recordId");

        if (recId) {
            console.log("레코드 ID 있음: " + recId);
            // 여기서 Apex 호출 또는 로직 실행 가능
        } else {
            console.log("레코드 ID 없음");
        }
        if (recId) {
        // if (component.get('v.isFromRecordPage')) {
            helper.refreshContent(component);
            component.set('v.hasUtilityBar', false);
            helper.applyHeight(component, event, helper);
        } else {
            var utilityAPI = component.find('utilitybar');
            utilityAPI.getAllUtilityInfo().then(function (response) {
                console.log('response',response);
                if (typeof response !== 'undefined') {
                    
                    utilityAPI.toggleModalMode({
                        enableModalMode: true
                    });
                utilityAPI.setPanelWidth({
                    widthPX: 1000,
                });
                utilityAPI.setPanelHeight({
                    heightPX:900
                });
                    component.set('v.hasUtilityBar', true);
                    utilityAPI.onUtilityClick({
                        eventHandler: function() {
                            console.log('refreshContent');
                            helper.refreshContent(component);
                        }
                    });
                } else {
                    component.set('v.hasUtilityBar', false);
                }
            });
            console.log('send dhksdyf');
        }
    }
})