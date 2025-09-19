({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    // toast : function(component, title, message, variant){
    //     sforce.one.showToast({
    //         "title": title,
    //         "message": message,
    //         "type": variant
    //     });
    // },

    searchAccount : function(component, event, helper) {
        var self = this;
        component.set('v.isLoading', true);
        // Apex Call
        self.apexCall(component, event, self, 'searchAccount', {
            keyword : component.get('v.keyword')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            component.set('v.searchDataList', r);
            component.set('v.isLoading', false);
        }))
    },

    navigateList : function(component){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response', response);
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": component.get('v.listId'),
                "listViewName": null,
                "scope": "Account"
            });
            navEvent.fire();
        })
        .catch(function(error) {
            window.history.back();
        });
    },
    navigateToRecord: function(recordId, component) {
        var navigationService = $A.get("e.force:navigateToSObject");
        if (navigationService) {
            navigationService.setParams({
                "recordId": recordId,
                "slideDevName": "detail"
            });
            navigationService.fire();
        } else {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/" + recordId
            });
            urlEvent.fire();
        }
    },

    closeTabAndNavigateToRecord: function(recordId, component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            // 현재 탭 닫기
            workspaceAPI.closeTab({ tabId: focusedTabId }).then(function() {
                // 레코드 페이지로 이동
                var navigationService = $A.get("e.force:navigateToSObject");
                if (navigationService) {
                    navigationService.setParams({
                        "recordId": recordId,
                        "slideDevName": "detail" // 상세 페이지로 이동
                    });
                    navigationService.fire();
                } else {
                    // Fallback: navigateToURL
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/" + recordId
                    });
                    urlEvent.fire();
                }
            });
        })
        .catch(function(error) {
            console.log('# closeTabAndNavigateToRecord error: ' + error);
        });
    },
})