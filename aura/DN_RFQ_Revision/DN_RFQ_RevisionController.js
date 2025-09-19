({
    doinit : function(component, event, helper){
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.currentStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal != 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_RFQRevisionError"),
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
            }else{
                const title = $A.get("$Label.c.DNS_M_RFQRevisionTitle");
                const confirm = $A.get("$Label.c.DNS_M_Confirm");
                const cancel = $A.get("$Label.c.DNS_M_Cancel");
                component.set('v.title', title);
                component.set('v.confirm', confirm);
                component.set('v.cancel', cancel);
                component.set('v.status', true);
            }
        });
        $A.enqueueAction(action);

    },
    versionUP : function(component, event, helper){
        component.set('v.isLoading', true);

        const fields = event.getParam('fields');
        // console.log(fields);
        // console.log(component.get("v.recordId"));
        const upRecord = {};

        upRecord.RequiredDelivryDate__c         = fields.RequiredDelivryDate__c;         
        upRecord.PartsforMachining__c           = fields.PartsforMachining__c;
        upRecord.MaterialHardness__c            = fields.MaterialHardness__c;
        upRecord.Type__c                        = fields.Type__c;
        upRecord.ProcessesBeforeMachining__c    = fields.ProcessesBeforeMachining__c;
        upRecord.ProductionVolumeYearly__c      = fields.ProductionVolumeYearly__c;
        upRecord.OperationRate__c               = fields.OperationRate__c;
        upRecord.WorkingHoursDaily__c           = fields.WorkingHoursDaily__c;
        upRecord.CycleTimeRequired__c           = fields.CycleTimeRequired__c;
        upRecord.WorkingDaysMonthly__c          = fields.WorkingDaysMonthly__c;
        upRecord.MachineType__c                 = fields.MachineType__c;
        upRecord.Quantity__c                    = fields.Quantity__c;
        upRecord.Model__c                       = fields.Model__c;
        upRecord.PSModel__c                     = fields.PSModel__c;
        upRecord.ChuckType__c                   = fields.ChuckType__c;
        upRecord.RecommendedToolMaker__c        = fields.RecommendedToolMaker__c;
        upRecord.FixtureClamp__c                = fields.FixtureClamp__c;
        upRecord.AutomationType__c              = fields.AutomationType__c;
        upRecord.LoadCapacity__c                = fields.LoadCapacity__c;
        // upRecord.CustomerRequirement__c         = fields.CustomerRequirement__c;
        upRecord.CustomerDesc__c         = fields.CustomerDesc__c;

        var recordId = component.get("v.recordId");
            var action = component.get("c.rfqnewVersion");
            action.setParams({
                recordId : recordId,
                upRecord : upRecord
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var returnVal = response.getReturnValue();
                // console.log("Response returnVal: " + returnVal);
                if(returnVal === "SUCCESS"){
                    
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success") + '!',
                            "message": $A.get("$Label.c.DNS_M_Success")
    
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
                }else{
                    // 에러 메시지 표시
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_RFQRevisionError"),
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            });
        $A.enqueueAction(action);
        
    },
    handleClickClose: function(component, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
    }
})