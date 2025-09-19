({
    doInit : function(component, event, helper) {
        helper.apexCall(component, event, helper, 'getCVInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('CV', r);
            
            component.set('v.CVList', r.getCVDatas);
            component.set('v.isWorker', r.checkWorker);
        }))
        .catch(function(error) {
            console.log('# getCVDatas error : ' + error.message);
        });
    },
});