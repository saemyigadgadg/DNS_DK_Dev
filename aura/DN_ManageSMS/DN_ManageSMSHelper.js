({
    refreshContent: function(component) {
        //화면 초기화하도록 설정
        // var utilityAPI = component.find('utilitybar');
        // utilityAPI.toggleModalMode({
        //     enableModalMode: true
        // });
        var self = this;
		self.apex(component,"getWorkCenterList",{})
        .then(function(result){

            console.log('result' , result);
            component.set('v.startDate', convertDate(new Date()));
            component.set('v.endDate', convertDate(new Date()));

            component.set('v.targetList', result.stPick);
            component.set('v.workCenterList', result.wcPick);
            component.set('v.workCenter', 'all');   
            component.set('v.dispatchStaffList', []);        
            component.set('v.dispatchStaff', 'all');        
            component.set('v.searchList', []);        
            component.set('v.selectedList', []);        
            component.set('v.inboundNum', '');
            component.set('v.smsContent', '');
        }).then(function(result){
            component.set('v.isLoading');
        });


        function convertDate(date) {
            var yyyy = date.getFullYear().toString();
            var mm = (date.getMonth()+1).toString();
            var dd  = date.getDate().toString();
            
            var mmChars = mm.split('');
            var ddChars = dd.split('');
            
            return yyyy + '-' + (mmChars[1]?mm:"0"+mmChars[0]) + '-' + (ddChars[1]?dd:"0"+ddChars[0]);
        }
    },
    getStaffList : function(component){
        var self        = this, 
            workCenter 	= component.get('v.workCenter');
		self.apex(component,"getStaffList",{recordID : workCenter})
        .then(function(result){
            console.log('dispatchStaffList' , result);
            component.set('v.dispatchStaffList', result);
            component.set('v.dispatchStaff', 'all');           
        }).then(function(result){
            component.set('v.isLoading');
        });
    },
    getSearchList : function(component){
        var self = this, 
        workCenter = component.get('v.workCenter'),
        dispatchStaff = component.get('v.dispatchStaff');
        self.apex(component, "getSearchList", {workCenter:workCenter, dispatchStaff : dispatchStaff})
        .then(function(result){
            console.log('result' , result);
            component.set('v.searchList', result);
            //component.set('v.dispatchStaff', result[0].value);           
        }).then(function(result){
            component.set('v.isLoading', false);
        });
    },
    getSMSList : function(component){
        //발송대상 추가
        console.log('getSMSList');

        var startDate = component.get('v.startDate');
        var endDate = component.get('v.endDate');
        var searchTarget = component.get('v.searchTarget');
        var serviceResourceId = component.get('v.serviceResourceId');
        var accountId = component.get('v.accountId');
        var workOrderId = component.get('v.workOrderId');
        var data = {
            startDate : startDate,
            endDate : endDate,
            searchTarget : searchTarget,
            serviceResourceId : serviceResourceId,
            accountId : accountId,
            workOrderId : workOrderId
        };

        var self = this, 
        searchKey = JSON.stringify(data);

        self.apex(component, "getSMSList", {searchKey : searchKey})
        .then(function(result){
            console.log('getSMSList result' , result);
            component.set('v.searchResultList', result);        
        }).then(function(result){
            component.set('v.isLoading');
        });
    },
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },

    snedSMS : function(component, sendInfo){
        console.log('helper', sendInfo);
        var self = this;
        self.apex(component, "sendSMSConfirm", {sendInfo : sendInfo})
        .then(function(result){
            console.log('sendSMS result' , result);
            if (result.isSuccess == true) {
                console.log('success');
                self.toast(component, 'SUCCESS', '성공적으로 SMS 발신이 완료되었습니다.', 'Success');
                component.set('v.isLoading', false);
                component.set('v.confirmModal', false);
            } else {
                console.log('error');
                self.toast(component, 'ERROR', 'SMS 발신이 실패하였습니다.', 'Error');
                component.set('v.isLoading', false);
                component.set('v.confirmModal', false);
            }
        }).then(function(result){
        });
    },
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },
    clearChecked : function(component){
        component.find('checkboxAllR').set('v.checked', false);
        component.find('checkboxAllL').set('v.checked', false);
    },
    applyHeight: function(component, event, helper) {
        window.setTimeout(function () {
            let sendWrapper = component.find('sendwrapper');
            console.log('@@@@@@@@@@@@@@@@@sendWrapper');
            console.log(sendWrapper);
            console.log(sendWrapper.getElement);
            console.log('@@@@@@@@@@@@@@@@@@@@@@@@@');
            if(sendWrapper && sendWrapper.getElement) {
                sendWrapper.getElement().style.height = '900px';
            }
        }, 0);
    }
})