({
    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },

    searchData: function (component, event, helper) {
        component.set('v.isLoading', true);
        var accountId = component.get('v.accountName');
        console.log('accountId', JSON.stringify(accountId));
        var modelName = component.get('v.modelName');
        var assetName = component.get('v.assetName');
        var maintPlant = component.get('v.maintPlant');
        var planningPlant = component.get('v.planningPlant');

        if (Array.isArray(accountId)) {
            accountId = undefined;
        }
        
        if (modelName != null) {
            if (modelName.trim().length > 0 && modelName.trim().length < 3) {
                this.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_MODELSEARCH"));
                component.set('v.isLoading', false);
                return;
            }
        }

        if (assetName != null) {
            if (assetName.trim().length > 0 && assetName.trim().length < 3) {
                this.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_EQUIPMENTSEARCH"));
                component.set('v.isLoading', false);
                return;
            }
        }

        var action = component.get('c.searchTargetEquipments');
        action.setParams(
            {
                accountId: accountId,
                modelName: modelName,
                assetName: assetName,
                maintPlant: maintPlant,
                planningPlant: planningPlant
            }
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result:', result);
                var targetList = component.get('v.targetList');
                targetList = result;
                component.set('v.targetList', targetList);
            } else {
                this.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_NORESPONSE"));
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);

    }

    
})