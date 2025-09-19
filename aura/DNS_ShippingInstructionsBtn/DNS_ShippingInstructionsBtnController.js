({
    init : function(component, event, helper) {
        console.log('v.sObjectName',component.get('v.sObjectName'));

        var action = component.get('c.getInitInfo');
        action.setParams({
            recordId : component.get('v.recordId'),
            objName : component.get('v.sObjectName')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result.isSuccess){
                component.set('v.model', result.model);
                component.set('v.assetId', result.assetId);
                
                helper.searchDoc(component);

            }else{
                helper.toast(component, 'ERROR', result.errMessage, 'Error');
                component.set('v.isSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleAsset :  function(component, event, helper) {
        var assetId = event.getParam('value')[0];
        console.log('assetId', assetId);

        if(!$A.util.isEmpty(component.get('v.assetId'))){
            component.set('v.isSpinner', true);

            var action = component.get('c.getAssetInfo');
            action.setParams({
                assetId : assetId
            });
            action.setCallback(this, function(response){
                var result = response.getReturnValue();
                console.log('result', result);
                if(result.isSuccess){
                    component.set('v.model', result.model);
                    component.set('v.assetId', result.assetId);
                    // component.set('v.isSpinner', false);
                    helper.searchDoc(component);
                }else{
                    component.set('v.isSpinner', false);
                }
            });
            $A.enqueueAction(action);
        }       
    },
    handleSearch : function(component, event, helper) {
        helper.searchDoc(component);
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})