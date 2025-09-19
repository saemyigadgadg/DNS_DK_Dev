({
    doInit: function(component, event, helper) {

        helper.reverseLoading(component);

        // set options
        var options = [
            {label: '필요'  , value: 'required'},
            {label: '불필요', value: 'notRequired'}
            ];
        component.set("v.options", options);

        component.set('v.fileFields', [
            {'name': 'bizReg', 'label': '사업자등록증', 'fileId': null},
            {'name': 'map',    'label': '출하처 약도',  'fileId': null},
            {'name': 'bond',   'label': '채권',       'fileId': null},
        ]);

        let recordId = component.get('v.recordId');
        if(!recordId) { recordId = window.sessionStorage.getItem("parentRecordId"); }
        component.set('v.recordId', recordId);
        console.log('test01 ::: ' + recordId);

        // set default values
        var action = component.get("c.getOrderInfos");
        action.setParams({ orderId: recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log('getOrderInfos Result ::: ' + JSON.stringify(result, null, 2));
                if(!result.isPass) {
                    helper.handleError('getOrderInfos', result.errorMsg);
                    helper.close(component, true);
                } else {
                    
                    component.set("v.account",        result.account);
                    component.set('v.accRepInfo',     result.contactOptions);
                    
                    component.set("v.trainingCountOptions", result.trainingCountOptions);
                    component.set("v.trainingTypeOptions", result.trainingTypeOptions);
                    component.set("v.trainingSortOptions", result.trainingSortOptions);
                    component.set("v.traineeLevelOptions", result.traineeLevelOptions);
                    
                    component.set("v.doFieldWrapList", result.doFieldWrapList);
                    component.set("v.requiedFields",   result.requiedFields);
                    
                    component.set("v.ownerId", result.ownerId);
                    component.set("v.shipToId", result.shipToId);
                    component.set("v.shipToAddress", result.shipToAddress);
                    component.set("v.currentUser", result.currentUser);
                    
                    // let dealerInfo = helper.addUserInfo(result.currentUser);
                    // component.set("v.currentUser", dealerInfo);
                    // console.log('dealerInfo :: ' + JSON.stringify(dealerInfo,null,4))
                    
                    let contactOptions = result.contactOptions.map(rep => {
                        return {label : rep.repName, value : rep.repId}
                    })
                    component.set("v.contactOptions", contactOptions);
                    let eduRepOptions = result.eduRep.map(edu => {
                        return {label : edu.UserOrGroup.Name, value : edu.UserOrGroup.Id}
                    })
                    component.set('v.trainingOwnerOptions',eduRepOptions)
                    
                    helper.reverseLoading(component);
                }

            } else {
                helper.handleError('getOrderInfos', response.getError());
                helper.close();
            }
        });

        $A.enqueueAction(action);
    }

    , handleClose : function(component, event, helper) {
        const fileFields = component.get("v.fileFields");
        const fileIdsToDelete = fileFields.filter((field) => field.fileId).map((field) => field.fileId);

        // DD 250220
        const fileList = component.get('v.fileList');
        const listIdsToDelete = fileList.filter((field) => field.fileId).map((field) => field.fileId);

        const mergedIdsToDelete = fileIdsToDelete.concat(listIdsToDelete);

        if (mergedIdsToDelete.length > 0) {
            // helper.deleteFile(component, fileIdsToDelete);
            helper.deleteFile(component, mergedIdsToDelete);
        }
        helper.close(component, true);
    }

    , handleSave : function(component, event, helper) {
        helper.reverseLoading(component);

        const requiedFields = component.get('v.requiedFields')
        , deliveryOrder = component.get('v.deliveryOrder');

        // validation rule
        console.log('deliveryOrder', JSON.stringify(deliveryOrder, null, 2));
        let isPass = true;
        requiedFields.forEach(field => {
            let fieldValue = deliveryOrder[field];
            if(fieldValue) { fieldValue = fieldValue.trim(); }
            if(fieldValue == 'undefined' || fieldValue == null || fieldValue === '') { isPass = false; }
        });

        if(!isPass) { 
            helper.toast('error', $A.get("$Label.c.DNS_M_RequiredMissing")); // Required field(s) is missing.
            helper.reverseLoading(component);
            return; 
        }

        deliveryOrder.Order__c = component.get("v.recordId");
        // deliveryOrder.OwnerId  = component.get("v.ownerId");
        
        let wrapper = {};
        wrapper.isRequired = component.get("v.isRequired");

        const fileFields = component.get('v.fileFields');
        console.log('fileFields ::: ', JSON.stringify(fileFields, null, 2));
        
        const files = fileFields.filter((field) => field.fileId).map((field) => field.fileId);
        console.log('files ::: ', JSON.stringify(files, null, 2));

        var fileList = component.get('v.fileList');
        var fileIdList = [];
        fileList.forEach(e=> {
            fileIdList.push(e.fileId)
        })

        // DD 250220
        wrapper.fileId = fileIdList;
        
        var selectRep = component.get('v.selectRep');
        console.log('selectRep >> ' + JSON.stringify(selectRep,null,4));
        var cnt2 = component.get('v.cnt2');
        var cnt3 = component.get('v.cnt3');

        wrapper.shipToRepId    = selectRep.repId || null;
        wrapper.shipToRepName  = selectRep.repName || '';
        wrapper.shipToRepMP    = selectRep.repMp || '';
        wrapper.shipToRepTitle = selectRep.repTitle || '';

        wrapper.trainingType      = component.get("v.TrainingType__c");
        wrapper.trainingCount     = component.get("v.TrainingCount__c");
        wrapper.traineeLevel      = component.get("v.TraineeLevel__c");
        wrapper.trainingDateTime1 = component.get("v.TrainingDateTime1__c");
        wrapper.trainingDateTime2 = component.get("v.TrainingDateTime2__c");
        wrapper.trainingDateTime3 = component.get("v.TrainingDateTime3__c");

        wrapper.owner             = component.get('v.Owner');

        console.log('wrapper >> ' +JSON.stringify(wrapper,null,4))

        // DD 250326 티켓 생성시 필수값 설정함. 없는 경우 티켓 생성 안함.
        if(wrapper.isRequired) {
            if(selectRep == '') {
                helper.toast('error', '필수 값을 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }
            
            if(wrapper.shipToRepName.trim() == '') {
                helper.toast('error', '고객사 담당자 명을 입력해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(wrapper.shipToRepMP.trim() == '') {
                helper.toast('error', '고객사 연락처를 입력해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(wrapper.shipToRepTitle.trim() == '') {
                helper.toast('error', '직책을 입력해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(wrapper.trainingType == null) {
                helper.toast('error', '교육 종류를 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(wrapper.trainingCount == null) {
                helper.toast('error', '교육 횟수를 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(wrapper.traineeLevel == null) {
                helper.toast('error', '피교육자 수준을 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(wrapper.owner == null) {
                helper.toast('error', '교육 담당자를 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(wrapper.trainingDateTime1 == null) {
                helper.toast('error', '교육일자(1)을 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }
            
            if(cnt2 && wrapper.trainingDateTime2 == null) {
                helper.toast('error', '교육일자(2)을 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }

            if(cnt3 && wrapper.trainingDateTime3 == null) {
                helper.toast('error', '교육일자(3)을 선택해 주세요.');
                helper.reverseLoading(component);
                return;
            }
        }
        console.log('wrapper >>> '+JSON.stringify(wrapper,null,4));

        
        var action = component.get("c.saveDO");
        action.setParams({ deliveryOrder : deliveryOrder, files : files });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                const doId = response.getReturnValue();
                component.set('v.doId', doId);
                deliveryOrder.Id = doId;
                helper.createTicket(component, deliveryOrder, wrapper);
            } else {
                helper.handleError('saveDO', response.getError());
                helper.reverseLoading(component);
            }
        });
        $A.enqueueAction(action);
    }

    , handleFileChange : function(component, event, helper) {
        helper.reverseLoading(component);
        const fileInput = event.getSource().get("v.files")[0];
        const fieldName = event.getSource().get("v.name");
        const MAX_SIZE = 2 * 1024 * 1024; // 2MB
        console.log('handleFileChange - ', fieldName, fileInput, MAX_SIZE);

        
        if (fileInput.size > MAX_SIZE) {
            helper.handleError('handleFileChange', $A.get("$Label.c.DNS_M_FileSizeError")); // File size must not exceed 2MB.
            helper.reverseLoading(component);
            return;
        }


        if (fileInput) {
            const reader = new FileReader();
            reader.onload = $A.getCallback(function () {
                const base64 = reader.result.split(",")[1];
                helper.uploadFile(component, fieldName, fileInput.name, base64, fileInput.type);
            });
            reader.readAsDataURL(fileInput);
        }
    }

    , handleDelete : function(component, event, helper) {
        helper.reverseLoading(component);

        const fileId = event.getSource().get("v.value");
        const fileFields = component.get("v.fileFields");
        const field = fileFields.find((f) => f.fileId === fileId);

        if (field) {
            field.fileName = null;
            field.fileId = null;
        }

        helper.deleteFile(component, [fileId]);
        component.set("v.fileFields", fileFields);
    }

    , handleNavigation : function (component, event, helper) {
        window.addEventListener("popstate", function () {
            window.location.reload();
        });
    }














    , handleEducationRequired: function(component, event, helper) {
        var selectedValue = component.get("v.EduValue");
        console.log("selectedValue", selectedValue);
        
        //필요일 때 isRequired를 보이게 하고 불필요일 때 사라지게
        if (selectedValue === 'required') {
            component.set("v.isRequired", true);
            console.log("isRequired set to true");
        } else {
            component.set("v.isRequired", false);
            console.log("isRequired set to false");
        }
    }

    // 선택값 매칭
    , odValue: function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var selectedValue = event.getParam("value");

        helper.fieldValue(component, name, selectedValue, helper);
    }

    , handleDoChange : function(component, event, helper) {
        var name  = event.getSource().get("v.name");
        var value = event.getParam("value");

        let deliveryOrder   = component.get('v.deliveryOrder');
        deliveryOrder[name] = value;
        component.set('v.deliveryOrder', deliveryOrder);
    }

    // DD 250220
    , handleUploadFinished: function(component, event, helper) {
        console.log('DO 업로드');
        var uploadedFiles = event.getParam("files"); 
        var fileList = component.get("v.fileList"); 
        console.log('uploadedFiles >> ' + JSON.stringify(uploadedFiles,null,4));

        uploadedFiles.forEach(function(file) {
            fileList.push({
                fileId: file.documentId,
                fileName: file.name,
                fileVer: file.contentVersionId
            });
        });
    
        component.set("v.fileList", fileList);
        var fileList = component.get('v.fileList');
        console.log('fileList :::' +JSON.stringify(fileList,null,4))
        setTimeout(() => {
            let inputField = component.find("educationFiles");
            if (inputField) {
                inputField.getElement().focus();
            }
        }, 0);
    }

    // 파일 remove     
    , removeFile: function (component, event, helper) {
        var fileName = event.currentTarget.dataset.file; 
        var fileList = component.get("v.fileList");

        // fileName과 일치하는 항목의 인덱스 찾기
        var fileIndex = fileList.findIndex(function(file) {
            return file.fileName.trim() === fileName.trim();
        });
        console.log('fileIndex : >>' +JSON.stringify(fileIndex,null,4));

        var fileIdList = [];
        fileIdList.push(fileList[fileIndex].fileId);

        if (fileIdList.length > 0) {
            helper.deleteFile(component, fileIdList);
            component.set('v.isLoading', true);
        }
        

        if (fileIndex > -1) {
            fileList.splice(fileIndex, 1);
            console.log("File removed:", fileName);
        } else {
            console.warn("fileName not found in fileList.");
        }


    
        // 업데이트된 fileList를 다시 설정
        component.set("v.fileList", fileList);
        console.log('fileIdList ::: >> ' +JSON.stringify(fileIdList,null,4))
        console.log("Updated fileList:", JSON.stringify(fileList, null, 4));
    }

    , inputContact : function(component, event, helper) {
        const fieldName = event.getSource().get("v.name");
        var value = event.getParam("value");
        console.log('fieldName >>  '+ fieldName);
        console.log('value >>  '+ value);

        let currentRep = component.get("v.selectRep") || {};

        let updatedRep = Object.assign({}, currentRep);
        updatedRep[fieldName] = value;

        console.log('selectRep >> ' + JSON.stringify(updatedRep,null,4))

        component.set("v.selectRep", updatedRep);
    }
    
    
})