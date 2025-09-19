({

    doInit : function(component, event, helper){
        // component.set("v.beforeStage", "Identified");
        // component.set("v.currentStage", "Identified");
        component.set("v.dataLoad", true);

        var action = component.get("c.getStage");
        action.setParams({recordId : component.get("v.recordId")});

        action.setCallback(component, 
            function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var returnValue = response.getReturnValue();
                    // console.log('getVal : ' + returnValue);
                    component.set("v.recordStage", returnValue);
                    //record Stage가 Closed이면 Title메세지에 Closed된 영업기회는 단계 이동이 불가합니다. 권세진_241025
                    //record Stage가 Closed이면 mark select버튼 hidden 권세진_241025
                    component.set("v.titleMsg", $A.get("$Label.c.DNS_M_OptyPathMove"));
                    component.set("v.save", $A.get("$Label.c.DNS_B_Save"));
                    component.set("v.cancel", $A.get("$Label.c.DNS_M_Cancel"));
                    component.set("v.Stage", $A.get("$Label.c.DNS_T_Stage"));
                    component.set("v.selectClosed", $A.get("$Label.c.DNS_T_SelectClosed"));

                    if(returnValue.includes('Closed')){
                        component.set("v.titleMsg", $A.get("$Label.c.DNS_M_ClosedMSG"));
                        component.set("v.btnBoolean", true);
                        component.set("v.color", "color: orange;");
                    }
                    if(returnValue == "Conditional Agreement") {
                        component.set("v.btnBoolean", true);
                        const recordId = component.get("v.recordId");
                        component.set("v.recordId", null);
                        // console.log(component.get("v.recordId"));
                        component.set("v.recordId", recordId);
                        // console.log(component.get("v.recordId"));

                    }


                } else {

                }
            }
        );

        $A.enqueueAction(action);
        
    },

    init : function(component, event, helper) {
        component.set("v.dataLoad", true);

        const empApi = component.find("empApi");
        const channel = "/data/OpportunityChangeEvent"; // CDC 채널 지정

        const replayId = -1;
        empApi.subscribe(channel, replayId, $A.getCallback(function(eventReceived) {
            // console.log('Received Opportunity Change Event: ', eventReceived);
            
            const changeType = eventReceived.data.payload.ChangeEventHeader.changeType;
            const stageName = eventReceived.data.payload.StageName;
            // const pathCheckValue = eventReceived.data.payload.pathCheck__c;

            // Stage가 변경되거나 pathCheck__c 필드가 변경된 경우 doInit 호출
            if (changeType === 'UPDATE' && stageName) {
                // if (changeType === 'UPDATE' && (stageName || pathCheckValue)) {
                // Stage가 변경되었을 때 doInit 호출
                component.get("c.doInit").run();
            }
        }))
        .then(function(subscription) {
            // console.log("Subscribed to channel:", subscription.channel);
            component.set("v.subscription", subscription);
        });
    },

    unsubscribe : function(component, event, helper) {
        const empApi = component.find("empApi");
        const subscription = component.get("v.subscription");

        if (subscription) {
            empApi.unsubscribe(subscription, $A.getCallback(function(unsubscribed) {
                // console.log("Unsubscribed from channel:", unsubscribed.channel);
            }));
        }
    },

    handleSelect : function (component, event, helper) {
        if(component.get("v.recordStage").includes('Closed')){
            component.set("v.titleMsg", $A.get("$Label.c.DNS_M_ClosedMSG"));
            component.set("v.btnBoolean", true);
            component.set("v.color", "color: orange;");
        }
        else{
            component.set("v.beforeStage", component.get('v.currentStage'));
            // console.log(event);
            var stepName = event.getParam("detail").value;
            component.set("v.currentStage", stepName);
    
            // console.log('before : ' + component.get("v.beforeStage"));
            // console.log('current : ' + component.get("v.currentStage"));
    
            var action = component.get("c.getStage");
            action.setParams({recordId : component.get("v.recordId")});
    
            action.setCallback(component, 
                function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var returnValue = response.getReturnValue();
                        // console.log('getVal : ' + returnValue);
                        component.set("v.recordStage", returnValue);
    
                        var recordStage = component.get("v.recordStage");
                        var before = component.get("v.beforeStage");
                        var current = component.get("v.currentStage");
                        var toastEvent = $A.get("e.force:showToast");
    
                        if(
                            (recordStage == "Identified" && (current == "Validated" || current == "Closed" || current == "Identified")) ||
                            (recordStage == "Validated" && (current == "Qualified" || current == "Closed" || current == "Validated")) ||
                            (recordStage == "Qualified" && (current == "Conditional Agreement" || current == "Closed" || current == "Qualified")) ||
                            (recordStage == "Conditional Agreement" && (current == "Closed" || current == "Conditional Agreement"))
                        ){
                            component.set("v.titleMsg", $A.get("$Label.c.DNS_M_OptyPathMove"));
                            component.set("v.color", "color: green;");
                            component.set("v.btnBoolean", false);

                            if(recordStage == "Conditional Agreement" && current == "Conditional Agreement") {
                                component.set("v.btnBoolean", true);
                            }

                            if(current == "Closed"){

                                var actionDuration = component.get("c.AbortClosed");
                                actionDuration.setParams({recordId : component.get("v.recordId")});
                                actionDuration.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var returnValue = response.getReturnValue();
                                        console.log('returnValue : ' + returnValue);
                                        if(returnValue < 15){
                                            component.set('v.isDuration', true);
                                        }
                                    }
                                });
                                $A.enqueueAction(actionDuration);


                                component.set("v.btnBoolean", true);
                                component.set("v.isModalOpen", true);
                                
                                var action = component.get("c.getPicklistValues");
                                action.setParams({stageName : "Closed Won"});
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var picklistValues = response.getReturnValue();
                                        // console.log('picklistPrd : ' + picklistValues.ReasonPrd);
                                        component.set("v.picklistPrd", picklistValues.ReasonPrd);
                                        component.set("v.picklistPrice", picklistValues.ReasonPrice);
                                        component.set("v.picklistDiv", picklistValues.ReasonDiv);
                                        component.set("v.picklistSales", picklistValues.ReasonSales);
                                        component.set("v.picklistService", picklistValues.ReasonService);
                                        component.set("v.picklistMis", picklistValues.ReasonMis);
                                        component.set("v.picklistCustomer", picklistValues.ReasonCustomer);
                                    }
                                });
                                $A.enqueueAction(action);
                            }
                        }else{
                            component.set("v.btnBoolean", true);
                            component.set("v.titleMsg", $A.get("$Label.c.DNS_M_OptyPathMoveClosed"));
                            component.set("v.color", "color: red;");
                        }
                        toastEvent.fire();
    
    
                    } else {
    
                    }
                }
            );
    
            $A.enqueueAction(action);
        }
        
    },
    saveDuration : function(component, event, helper){
        component.set('v.isDuration', false);
    },
    closeModal : function(component, event, helper){
        const now = new Date();
        var saveRecord = {
            Id                  : component.get("v.recordId"),
            pathCheck__c           : now
        };
        // var action = component.get("c.updateStage");
        //         action.setParams({closedUpdate : saveRecord});

        //         action.setCallback(component, 
        //             function(response){
        //                 var state = response.getState();
        //                 if(state === "SUCCESS"){
        //                     component.set("v.btnBoolean", true);
        //                     component.set("v.isModalOpen", false);
        //                     $A.get('e.force:refreshView').fire();
        //                 } else {
        //                     console.error("Error in server response: " + response.getError());
        //                 }
        //             }
        //         );

        //     $A.enqueueAction(action);

        //Closed모달창에서 Cancel누르면 화면 초기화 위해 recordId를 다시 넣어줌_권세진_241028
            component.set("v.btnBoolean", true);
            const recordId = component.get("v.recordId");
            component.set("v.recordId", null);
            // console.log(component.get("v.recordId"));
            component.set("v.recordId", recordId);
            // console.log(component.get("v.recordId"));

        // component.set("v.currentStage", "Conditional Agreement");

        component.set("v.isModalOpen", false);

        var action = component.get("c.getStage");
        action.setParams({recordId : component.get("v.recordId")});

        action.setCallback(component, 
            function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var returnValue = response.getReturnValue();
                    // console.log('getVal : ' + returnValue);
                    component.set("v.recordStage", returnValue);

                    if(returnValue == "Identified" || returnValue == "Validated" || returnValue == "Qualified") {
                        component.set("v.btnBoolean", false);
                        const recordId = component.get("v.recordId");
                        component.set("v.recordId", null);
                        // console.log(component.get("v.recordId"));
                        component.set("v.recordId", recordId);
                        // console.log(component.get("v.recordId"));

                    }
                } 
            }
        );

        $A.enqueueAction(action);
        // window.location.reload();

        // setTimeout(function() {
        //     $A.get('e.force:refreshView').fire();
        // }, 100); // 100ms 후에 호출


        // const links = document.querySelectorAll('.slds-path__link');
        // links.forEach(link => {
        //     link.setAttribute('aria-selected', 'false');
        //     link.setAttribute('tabindex', '-1');
        // });

        // if (links[3]) {
        //     links[3].setAttribute('aria-selected', 'true');
        //     link.setAttribute('tabindex', '0');

        // }


    },

    changeClosedStage : function(component, event, helper){
        component.set("v.selectedPrd","");
        component.set("v.selectedPrice","");
        component.set("v.selectedDiv","");
        component.set("v.selectedSales","");
        component.set("v.selectedService","");
        component.set("v.selectedMis","");
        component.set("v.selectedCustomer","");
        
        var changedStage = event.getSource().get("v.value");
        console.log(changedStage);

        if(changedStage == "Closed Won" || changedStage ==  "Closed Lost") {
            console.log('true');
            component.set("v.isCustomer", false);
            component.set("v.isService", true);
        }else{
            console.log('false');

            component.set("v.isCustomer", true);
            component.set("v.isService", false);
        }

        component.set("v.selectedStage", changedStage);
        var action = component.get("c.getPicklistValues");
            action.setParams({stageName : changedStage});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var picklistValues = response.getReturnValue();
                    console.log('picklistPrd : ' + picklistValues.ReasonPrd);
                    component.set("v.picklistPrd", picklistValues.ReasonPrd);
                    component.set("v.picklistPrice", picklistValues.ReasonPrice);
                    component.set("v.picklistDiv", picklistValues.ReasonDiv);
                    component.set("v.picklistSales", picklistValues.ReasonSales);
                    component.set("v.picklistService", picklistValues.ReasonService);
                    component.set("v.picklistMis", picklistValues.ReasonMis);
                    component.set("v.picklistCustomer", picklistValues.ReasonCustomer);
                }
            });
            $A.enqueueAction(action);
    },
    saveRecord : function(component, event, helper) {

        var saveRecord = {
            Id                  : component.get("v.recordId"),
            StageName           : component.get("v.selectedStage"),
            Reason_Prd__c       : component.get("v.selectedPrd"),
            Reason_Price__c     : component.get("v.selectedPrice"),
            Reason_Delivery__c  : component.get("v.selectedDiv"),
            Reason_Sales__c     : component.get("v.selectedSales"),
            Reason_Service__c   : component.get("v.selectedService"),
            Reason_Mis__c       : component.get("v.selectedMis"),
            Reason_Customer__c  : component.get("v.selectedCustomer")
        };

        //비어있지 않음 값 count
        var count = Object.values(saveRecord).filter(function(value){
            return value !== ''&& value !== '--None--';
        }).length;

        //Id와 StageName을 제외하고 비어있지 않은 값 \n로 join
        var totalReason = Object.entries(saveRecord)
        .filter(function([key, value]){
            return key !== 'Id' && key !== 'StageName' && value !== '';
        })
        .map(function([key, value], index){
            return (index + 1) + '. ' + value + '\n';
        })
        .join('');

        totalReason = totalReason.slice(0, -1);

        if(component.get("v.selectedStage") == 'Closed Won'){
            saveRecord.WonReason__c = totalReason;
        }else{
            saveRecord.Loss_Reason__c = totalReason;
        }

        console.log(JSON.stringify(saveRecord));
        console.log(count);
        if(count == 2){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.DNS_M_Error"),
                    "message": $A.get("$Label.c.DNS_M_OptyPathClosedReason"),
                    "type": "Error"
                });
            toastEvent.fire();
        }else{
            component.set("v.dataLoad", false);

            var action = component.get("c.updateStage");
                action.setParams({closedUpdate : saveRecord});

                action.setCallback(component, 
                    function(response){
                        var state = response.getState();
                        if(state === "SUCCESS"){
                            component.set("v.titleMsg", $A.get("$Label.c.DNS_M_ClosedMSG"));
                            component.set("v.btnBoolean", true);
                            component.set("v.color", "color: orange;");
                            component.set("v.isModalOpen", false);
                            $A.get('e.force:refreshView').fire();
                            component.set("v.dataLoad", true);

                        } else {
                            console.error("Error in server response: " + response.getError());
                        }
                    }
                );

            $A.enqueueAction(action);
        }
    }
})