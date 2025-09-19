({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        // Apex Call
        helper.apexCall(component, event, helper, 'dnsaModelInit', {
            recordId : component.get('v.recordId'),
            objectName : component.get('v.objectName')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('DNSA result', r);
            
            component.set('v.fieldList', r.getFieldList);
            component.set('v.modelId', r.getModelId);
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# dnsaModelInit error : ' + error.message);
        });
    }
})