({
    handleReceiveMessage : function(component, event) {
        console.log("handleReceiveMessage")
        var message = event.getParam("message");
        var recordId = component.get("v.recordId");
        var utilityBarAPI = component.find("utilitybar");
        var myUtilityInfo = null;

        var workspaceAPI = component.find("workspace");

        // Get all open tabs

        
        utilityBarAPI.getAllUtilityInfo().then(function(response) {
            // console.log(response);
            myUtilityInfo = response.find(ele => ele.panelHeaderLabel === 'Matrix Chat');
             console.log("myutily",myUtilityInfo,message.type);
            if(myUtilityInfo){
                let label = '';

                switch (message.type) {
                    case 'CUSTOMER_MESSAGE':
                        label = '고객메세지가있음';
                        if(recordId !== message.data.caseId){
                            utilityBarAPI.setUtilityHighlighted({
                                utilityId : myUtilityInfo.id,
                                highlighted: true
                            });
                            utilityBarAPI.setUtilityLabel({
                                utilityId : myUtilityInfo.id,
                                label: label
                            });
                            workspaceAPI.getAllTabInfo()
                            .then(function (tabs) {
                                console.log("Open Tabs: ", tabs);
                
                                // Loop through the tabs to find the desired one
                                var targetTab = tabs.find(function (tab) {
                                    console.log("tab.title: ", tab.title,message.data.caseNumber);
                                    if (tab.title.includes(message.data.caseNumber)) {
                                        return true;
                                    } 
                                    return false;
                                });
                
                                if (targetTab) {
                                    console.log("Target Tab Found: ", targetTab);
                
                                    // Update the tab label
                                    // return workspaceAPI.setTabLabel({
                                    //     tabId: targetTab.tabId,
                                    //     label: `${targetTab.title} 새로운 메시지지`
                                    // });
                                    return workspaceAPI.setTabHighlighted({
                                            tabId: targetTab.tabId,
                                            highlighted: true,
                                            options: {
                                                pulse: true,
                                                state: "success"
                                            }
                                        });
                                } else {
                                    console.warn("Target tab not found.");
                                }
                            })
                            .then(function () {
                                console.log("Tab label updated successfully.");
                            })
                            .catch(function (error) {
                                console.error("Error updating tab label: ", error);
                            });
                        }

                        break;
                    case 'EVENT_OPERATIONCALL':
                        label = '대기상담이 있음';
                        utilityBarAPI.setUtilityHighlighted({
                            utilityId : myUtilityInfo.id,
                            highlighted: true
                        })        
                        utilityBarAPI.setUtilityLabel({
                            utilityId : myUtilityInfo.id,
                            label: label
                        })
                        break;                
                    case 'EVENT_SETOPERATION':
                        label = '할당된 상담이 있음';
                        utilityBarAPI.setUtilityHighlighted({
                            utilityId : myUtilityInfo.id,
                            highlighted: true
                        })
                        utilityBarAPI.setUtilityLabel({
                            utilityId : myUtilityInfo.id,
                            label: label
                        })
                        break;                
                    case 'EVENT_EXPIREDSESSION':
                        label = '종료된 상담이 있음';
                        utilityBarAPI.setUtilityHighlighted({
                            utilityId : myUtilityInfo.id,
                            highlighted: true
                        })
                        utilityBarAPI.setUtilityLabel({
                            utilityId : myUtilityInfo.id,
                            label: label
                        })
                        break;  
                    case 'LIST_CLOSE':
                        utilityBarAPI.minimizeUtility({
                            utilityId : myUtilityInfo.id
                        })
        
                        break;                                 
                    default:
                      console.log("TYPE is not entered!");
                      break;
                };

            }

       }) 
        .catch(function(error) {
            console.log(error);
        });
    },
    doInit : function(component, event, helper) {
        console.log('doInit');
        var workspaceAPI = component.find("workspace");
        var utilityBarAPI = component.find("utilitybar");

        
        var myUtilityInfo = null;
        var eventHandler = function(response){
            console.log(`eventHa`);
            utilityBarAPI.setUtilityHighlighted({
                utilityId : response.utilityId,
                highlighted: false
            });
            utilityBarAPI.setUtilityLabel({
                utilityId : response.utilityId,
                label: 'Matrix Chat'
            })

        }
        
        utilityBarAPI.getAllUtilityInfo().then(function(response) {
            // console.log(response);
            myUtilityInfo = response.find(ele => ele.panelHeaderLabel === 'Matrix Chat');
            if(myUtilityInfo){
                utilityBarAPI.onUtilityClick({
                    utilityId : myUtilityInfo.id,
                    eventHandler : eventHandler
                })
            }

       }) 
        .catch(function(error) {
            console.log(error);
        });
    },

    onRecordIdChange : function(component, event, helper) {
        var newRecordId = component.get("v.recordId");
       
        console.log("RecordId",newRecordId);
        if (!newRecordId){
            component.find('kakaoListUseCase').handleChangeRecordId('', 0);
        } else{
            var action = component.get("c.getMatrixChatData");
            action.setParams({"Id": component.get("v.recordId")});
    
            // Create a callback that is executed after 
            // the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("RoomID changed",response.getReturnValue());
                    component.find('kakaoListUseCase').handleChangeRecordId(newRecordId, response.getReturnValue().MatrixChat_Room_Id__c);
    
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }

    },

    onTabFocused : function(component, event, helper) {
        console.log("Tab Focused");
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");     
        if (focusedTabId){
            workspaceAPI.setTabHighlighted({
                tabId: focusedTabId,
                highlighted: false,
            });
        }

    }

})