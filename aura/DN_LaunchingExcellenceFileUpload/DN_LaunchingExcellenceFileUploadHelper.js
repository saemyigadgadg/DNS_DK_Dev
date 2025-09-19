({
    closeTab : function(component){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    navigateRecord : function (component, recId) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response', response);
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});

            //생성된 Record Page로 이동
            workspaceAPI.openTab({
                url: '/lightning/r/LaunchingExcellenceDoc__c/'+recId+'/view',
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
})