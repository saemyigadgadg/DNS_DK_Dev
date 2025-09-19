({
    doInit : function(component, event, helper) {
        helper.reverseLoading(component);

        var action = component.get("c.fetchInit");
        action.setParams({ recordId: component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('fetchInit result ::: ' + JSON.stringify(result, null, 2));
                if(!result.isPass) {
                    helper.handleError('fetchInit', result.errorMsg);
                    helper.close();
                } else {
                    const data = result.data;
                    component.set('v.trainingOwnerOptions', data.trainingOwnerOptions);
                    component.set('v.shipToId',             data.shipToId);
                    component.set('v.shipToAddress',        data.shipToAddress);
                    component.set('v.accRepInfo',           data.accRepInfo);
                    component.set('v.contactOptions',       data.contactOptions);
                    component.set('v.currUserPhone',        data.currUserPhone);

                    component.set('v.trainingCountOptions', data.trainingCountOptions);
                    component.set('v.trainingTypeOptions',  data.trainingTypeOptions);
                    component.set('v.traineeLevelOptions',  data.traineeLevelOptions);

                    component.set('v.selectRep', {repId : '', repName : '', repMp : '', repTitle : ''});


                    helper.reverseLoading(component);
                }
            } else {
                helper.handleError('fetchInit', response.getError());
                helper.close();
            }
        });
        $A.enqueueAction(action);
    }
    
    , handleValues : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var selectedValue = event.getParam("value");

        helper.fieldValue(component, name, selectedValue);
    }

    , handleSalesRep : function(component, event, helper) {
        const fieldName = event.getSource().get("v.name");
        const value     = event.getParam("value");

        const selectRep = component.get("v.selectRep");
        selectRep[fieldName] = value;

        component.set("v.selectRep", selectRep);
    }

    , handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files"); 
        var fileList      = component.get("v.fileList"); 

        uploadedFiles.forEach(function(file) {
            fileList.push({
                fileId: file.documentId,
                fileName: file.name,
                fileVer: file.contentVersionId
            });
        });

        component.set("v.fileList", fileList);

        setTimeout(() => {
            let inputField = component.find("educationFiles");
            if (inputField) {
                inputField.getElement().focus();
            }
        }, 0);
    }

    , handleFileDelete : function(component, event, helper) {
        helper.reverseLoading(component);

        const fileId = event.currentTarget.dataset.file; 
        const fileList = component.get("v.fileList");
        console.log('handleFileDelete - fileId ::: ' , fileId);
        console.log('handleFileDelete - fileList ::: ' , JSON.stringify(fileList));

        let fileIds = [fileId];
        helper.deleteFile(component, fileIds);

        const filteredFiles = fileList.filter(f => f.fileId != fileId);
        component.set('v.fileList', filteredFiles);

        helper.reverseLoading(component);
    }

    , handleClose : function(component, event, helper) {
        helper.reverseLoading(component);

        const fileList = component.get('v.fileList');
        const fileIdsToDelete = fileList.filter(f => f.fileId).map((f) => f.fileId);

        if (fileIdsToDelete.length > 0) { helper.deleteFile(component, fileIdsToDelete); }
        helper.close();
    }

    , handleSave : function(component, event, helper) {
        helper.reverseLoading(component);

        // Set data
        let wrapper = {};

        const selectRep = component.get('v.selectRep');
        wrapper.shipToRepId    = selectRep.repId;
        wrapper.shipToRepName  = selectRep.repName.trim();
        wrapper.shipToRepMP    = selectRep.repMp.trim();
        wrapper.shipToRepTitle = selectRep.repTitle.trim();

        wrapper.trainingType      = component.get("v.TrainingType__c");
        wrapper.trainingCount     = component.get("v.TrainingCount__c");
        wrapper.traineeLevel      = component.get("v.TraineeLevel__c");
        wrapper.trainingDateTime1 = component.get("v.TrainingDateTime1__c");
        wrapper.trainingDateTime2 = component.get("v.TrainingDateTime2__c");
        wrapper.trainingDateTime3 = component.get("v.TrainingDateTime3__c");
        wrapper.receptionDetails  = component.get("v.ReceptionDetails__c");

        wrapper.owner      = component.get('v.owner');
        wrapper.accId      = component.get('v.shipToId');
        wrapper.accAddress = component.get('v.shipToAddress');
        

        const fileList = component.get('v.fileList');
        const fileIds  = fileList.filter(f => f.fileId).map((f) => f.fileId);

        wrapper.fileIds = fileIds;

        // Validation
        const errorMsg = helper.validateWrapper(component, wrapper);
        if(errorMsg != '') {
            helper.toast('error', errorMsg);
            helper.reverseLoading(component);
            return;
        }
        
        if(wrapper.shipToRepId == '') {
            console.log('handleSave', JSON.stringify(selectRep, null, 1));

            var action = component.get("c.createContact");
            action.setParams({ rep : selectRep, shipToId : wrapper.accId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    const contactId = response.getReturnValue();
                    wrapper.shipToRepId = contactId;
                    // component.set('v.doId', doId);
                    // deliveryOrder.Id = doId;
                    // helper.createTicket(component, deliveryOrder, wrapper);
                    helper.saveTicket(component, wrapper);
                } else {
                    helper.handleError('createContact', response.getError());
                    helper.reverseLoading(component);
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.saveTicket(component, wrapper);
        }
    }
})