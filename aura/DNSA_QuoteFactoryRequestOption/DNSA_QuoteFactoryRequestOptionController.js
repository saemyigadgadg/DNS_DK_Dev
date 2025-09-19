({
    doinit: function(component, event, helper){
        var recordId = component.get('v.recordId');
        var action = component.get('c.getDNSAModelInfo');
        action.setParams({recordId : recordId});
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            if(returnVal.MSG == 'SUCCESS'){
                component.set('v.ModelId', returnVal.ModelId);
                component.set('v.ModelName1', returnVal.ModelName1);
                component.set('v.ModelBaseCode', returnVal.ModelBaseCode);
                component.set('v.ModelName2', returnVal.ModelName2);
                component.set('v.PrimeModel', returnVal.PrimeModel);
            }else{
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                "type" : "Error",
                "title": 'Error',
                "message": returnVal.MSG
                
                });
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    handleClickAddButton: function(component, event, helper) {
        // 기존 rowDataList 가져오기
        var rowDataList = component.get("v.rowDataList");

        // 새로운 행 추가 (필요한 필드를 초기화)
        var newRow = {
            Option_Name__c: "",
            Quantity__c: null,
            Ship_To__c: null,
            Requested_Delivery_Date__c: null,
            Description__c: "",
            Quote__c: component.get("v.recordId"),
            DNSA_Model__c: component.get("v.ModelId")
        };

        // 리스트에 추가 후 업데이트
        rowDataList.push(newRow);
        component.set("v.rowDataList", rowDataList);
        console.log('rosDataaList : ' + JSON.stringify(component.get('v.rowDataList')));
    },

    handleClickdeleteButton: function(component, event, helper) {
        var rowDataList = component.get("v.rowDataList");
        
        // 클릭한 버튼의 index 찾기
        var index = event.getSource().get("v.value");

        // 리스트에서 해당 index의 항목 제거
        rowDataList.splice(index, 1);

        // 업데이트된 리스트 저장
        component.set("v.rowDataList", rowDataList);
    },

    handleSaveRecord: function(component, event, helper){
        var rowDataList = component.get("v.rowDataList");
        if(rowDataList.length == 0){
            var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                "type" : "Error",
                "title": 'Error',
                "message": 'Please Check Option Information'
                
                });
                resultsToast.fire();
            return;
        }

        let isValid = true;

        // 모든 필드 검사
        let requiredFields = ["Option_Name__c", "Quantity__c", "Ship_To__c", "Requested_Delivery_Date__c"];
        for (let i = 0; i < rowDataList.length; i++) {
            let row = rowDataList[i];
            for (let field of requiredFields) {
                if (!row[field]) {
                    isValid = false;
                    break;
                }
            }
        }
    
        if (!isValid) {
            var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                "type" : "Error",
                "title": 'Error',
                "message": 'Please Check Required Fields'
                
                });
                resultsToast.fire();
            return;
        }

        var action = component.get("c.saveRecords");

        action.setParams({ rowDataList: rowDataList });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                "type" : "Success",
                "title": 'Success',
                "message": 'Request Option Created!'
                
                });
                resultsToast.fire();
            } else {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                "type" : "Error",
                "title": 'Error',
                "message": response.getError()[0].message
                
                });
                resultsToast.fire();
            }
        });

        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    handleClose: function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})