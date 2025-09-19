({
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
    navigateRecord : function (component, recId) {
        //visualforce page는 navigateToSObject를 이렇게 써야함
        //sforce.one.navigateToSObject(recId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response', response);
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});

            //먼저 Ticket List로 이동
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": component.get('v.listId'),
                "listViewName": null,
                "scope": "Case"
            });
            navEvent.fire();

            //생성된 Record Page로 이동
            workspaceAPI.openTab({
                url: '/lightning/r/Case/'+recId+'/view',
            }).then(function(response) {
                workspaceAPI.focusTab({tabId : response});
            })
            .catch(function(error) {
                console.log(error);
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    navigateList : function(component){
        // sforce.one.navigateToList(component.get('v.listId'), null , 'Case');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response', response);
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": component.get('v.listId'),
                "listViewName": null,
                "scope": "Case"
            });
            navEvent.fire();
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    toast : function(component, title, message, variant){
        //visualforce page는 toast를 이렇게 써야함
        // sforce.one.showToast({
        //     "title": title,
        //     "message": message,
        //     "type": variant
        // });
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    closeTab : function(component){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response', response);
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    checkBoxEvent : function(component){
        var country = component.get('v.country');
        var ticketInfo = component.get('v.ticketInfo')[0];
        var isurgency = ticketInfo.IsUrgency__c ? ticketInfo.IsUrgency__c : false;
        var isregenerate = ticketInfo.IsReGenerate__c ? ticketInfo.IsReGenerate__c : false;

        // 정규식 처리
        if(country == 'DNS'){
            let cleanedText = ticketInfo.ReceptionDetails__c ? ticketInfo.ReceptionDetails__c.replace(/\[긴급\]|\[재발생\]/g, '') : '';
            let prefix = '';
            if(isurgency){
                prefix += '[긴급]';
            }
            if(isregenerate){
                prefix += '[재발생]';
            }
            ticketInfo.ReceptionDetails__c = prefix + cleanedText;
            component.set('v.ticketInfo', [ticketInfo]);

        }else if(country == 'DNSA'){
            let cleanedText = ticketInfo.ReceptionDetails__c ? ticketInfo.ReceptionDetails__c.replace(/\[urgent\]|\[reoccurrence\]/g, '') : '';
            let prefix = '';
            if(isurgency){
                prefix += '[urgent]';
            }
            if(isregenerate){
                prefix += '[reoccurrence]';
            }
            ticketInfo.ReceptionDetails__c = prefix + cleanedText;
            component.set('v.ticketInfo', [ticketInfo]);
        }
        
    },
    closeModal: function () {
        var closeModal = $A.get("e.force:closeQuickAction");
        closeModal.fire();
    },

})