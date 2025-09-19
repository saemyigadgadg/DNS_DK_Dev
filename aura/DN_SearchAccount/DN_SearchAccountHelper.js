({
    //Toast 기능
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    //Apex Class 실행
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
    //Service Console Tab 닫기
    closeTab : function(component){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log('tabId',tabId);
            if(tabId){
                workspaceAPI.closeTab({
                    tabId: tabId
                });
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    //Service Console Tab 열기
    openTab : function(component, workspaceAPI, recId){
        workspaceAPI.openTab({
            url: '/lightning/r/Case/'+recId+'/view',
        }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
       })
        .catch(function(error) {
            console.log(error);
        });
    },
    //Double Click 방지
    preventDbClick : function(component){
        let lastClickedTime = component.get("v.lastClickedTime");
        let currentTime = new Date().getTime();
        if (lastClickedTime && (currentTime - lastClickedTime) < 2000) {
            console.log("Double-click detected! Ignored.");
            return;
        }
        component.set("v.lastClickedTime", currentTime);
    },
    searchContact : function(component){
        console.log('selectContact');
        console.log('contactId',component.get('v.contactId'));
        var action = component.get('c.getContactInfo');
        action.setParams({
            contactId : component.get('v.contactId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result',result);
            if(result.isSuccess){
                if(result.returnList.length > 1){
                    component.set('v.phoneNumber', result.returnList[0].MobilePhone);
                    component.set('v.contactList', result.returnList);
                    component.set('v.isContact', true);
                }else{
                    var contactKey = result.returnList[0].Id;
                    component.set('v.contactId', result.returnList[0].Id);
                    this.getAssetInfo(component, contactKey);
                }         
            }else{
                component.find('notifLib').showToast({
                    "title": 'ERROR',
                    "message": 'Error :'+result.errMessage,
                    "variant": 'Error'
                });
            }           
        });
        $A.enqueueAction(action);
    },
    getAssetInfo : function(component, contact){
        console.log('contactKey', contact);
        console.log('taskId', component.get('v.taskId'));
        this.apex(component, "getAssetInfo", {
            contactId : contact,
            taskId : component.get('v.taskId')
        })
        .then(function(result){
            // console.log('getAssetInfo',result);
            if(result.isSuccess){
                var sw = result.searchWrap;
                component.set('v.contactKey', sw.conTerm);
                component.set('v.phoneKey', sw.phoneTerm);
                component.set('v.recType', result.recType); 
                component.set('v.accountKey', sw.accTerm);
                if(result.returnList.length > 0){
                    // console.log('@@ result.returnList : ' + JSON.stringify(result.returnList));
                    component.set('v.searchList', result.returnList); 
                    component.set('v.isSpinner', false);
                }else{
                    component.find('notifLib').showToast({
                        "title": 'ERROR',
                        "message": 'Error :'+result.msg,
                        "variant": 'Error'
                    });
                    // this.toast(component, result.msg, 'ERROR', 'Error');
                    component.set('v.isSpinner', false);
                }
            }else{
                console.log('error', result.errMessage);
                component.find('notifLib').showToast({
                    "title": 'ERROR',
                    "message": 'Error :'+result.msg,
                    "variant": 'Error'
                });
                component.set('v.isSpinner', false);
            }
        });  
    }
})