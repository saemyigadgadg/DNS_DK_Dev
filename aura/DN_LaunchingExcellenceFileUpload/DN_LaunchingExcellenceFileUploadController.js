({
    init : function(component, event, helper) {
        component.set('v.isLoading', true);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response.pageReference' ,response.pageReference);
            var recordTypeId = response.pageReference.state.recordTypeId;
            console.log('recordTypeId' ,recordTypeId);
            if(response.pageReference.state.recordTypeId){
                component.set('v.recordTypeId', recordTypeId);

                var action = component.get('c.getInitInfo');
                action.setParams({
                    recordTypeId : recordTypeId
                });
                action.setCallback( this, function(response){
                    var result = response.getReturnValue();
                    console.log('getInitInfo', result);
                    if(result.isSuccess){
                        component.set('v.recId', result.returnValue);
                        component.set('v.isLoading', false);
                    }else{
                        helper.toast(component, 'ERROR', result.errMessage,'ERROR');
                        component.set('v.isLoading', false);
                    }
                });
                $A.enqueueAction(action);
            }
        })
        .catch(function(error) {
            console.log(error);
        });
        
    },
    fileClear : function (component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.isFileUpload', false);
        var action = component.get('c.deleteDoc');
        action.setParams({
            documentId : component.get('v.docId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('deleteDoc',result);
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    handleUploadFinished : function(component, event, helper) {
        component.set('v.isLoading', true);
        var uploadedFiles = event.getParam("files");
        // Get the file name
        uploadedFiles.forEach(file => {
            console.log('file',file);
            console.log(file.name + '_'+file.documentId);
            component.set('v.docTitle', file.name);
            component.set('v.docId', file.documentId);
            component.set('v.cvId', file.contentVersionId);
            if(file.mimeType.includes('pdf')){
                component.set('v.docIcon', 'doctype:pdf');
            }else{
                component.set('v.docIcon', 'doctype:excel');
            }
        });
        console.log('File Upload Complete!!');
        component.set('v.isFileUpload', true);
        component.set('v.isLoading', false);
    },
    handleSave: function(component, event, helper) {
        console.log('v.recId', component.get('v.recId'));
        console.log('v.docId', component.get('v.docId'));

        component.set('v.isLoading', true);
        var action = component.get('c.createPublicLink');
        action.setParams({
            recId : component.get('v.recId'),
            cvId : component.get('v.cvId'),
            docTitle : component.get('v.docTitle')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('createPublicLink', result);
            if(result.isSuccess){
                helper.toast(component, 'SUCCESS', 'SUCCESS', 'Success');
                helper.navigateRecord(component, component.get('v.recId'));
                component.set('v.isLoading', false);
            }else{
                helper.toast(component, 'There is an error to create the Record', 'ERROR', 'Error');
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleCancel: function(component, event, helper) {
        var action = component.get('c.deleteRec');
        action.setParams({
            recId : component.get('v.recId')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result', result);
            helper.closeTab(component);
        });
        $A.enqueueAction(action);
    },
})