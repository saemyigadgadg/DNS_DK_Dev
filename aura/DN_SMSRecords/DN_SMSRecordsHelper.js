({
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
            component.set('v.isLoading');
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
        console.log(sendInfo);
        var self = this;
        self.apex(component, "sendSMS", {sendInfo : sendInfo})
        .then(function(result){
            console.log('sendSMS result' , result);       
        }).then(function(result){
            component.set('v.isLoading');
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
    
})