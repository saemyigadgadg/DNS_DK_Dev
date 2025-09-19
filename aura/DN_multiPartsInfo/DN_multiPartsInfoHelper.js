/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-26-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    apexCall : function(component, methodName, params) {
        console.log('helper 동작 확인');
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's': response.getState()});
                    } else {
                        let errors = response.getError();
                        console.error(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    addPartList : function(component, event, helper, num) {
        let partsList = component.get("v.partsList");
        for(var i = 0; i < num; i++) {
            var newList = {
                orderPartNo         : '', // 부품 번호
                productName         : '', // 품명
                stockQuantity       : '', // 재고수량
                unitPrice           : '', // 단가
                consumerPrice       : '', // 소비자 가격
                priceEffectiveDate  : '', // 가격 적용일
                purchaseLeadTime    : '', // 구매 LT
                serviceLeadTime     : '', // SLT
                replacementProduct  : '', // 대체품
                specification       : '', // 규격
                unit                : ''  // 단위
            };
            partsList.push(Object.assign({}, newList));
        }
        component.set("v.partsList", partsList);
    },

    // 엑셀 업로드
    readExcelFile: function (component, file) {
        return new Promise(function (resolve, reject) {
            var reader = new FileReader();
            var partList = [];
            reader.onload = function (e) {
                try {
                    var data = new Uint8Array(e.target.result);
                    var workbook = XLSX.read(data, { type: "array" });
    
                    var firstSheetName = workbook.SheetNames[0];
                    var worksheet = workbook.Sheets[firstSheetName];
    
                    var jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 }); // 첫행을 포함해서 배열 형태로
                    // var jsonData = XLSX.utils.sheet_to_json(worksheet, { header: A }); 첫행을 JSON 의 key 로 사용.

                    jsonData = jsonData.flat();
                    jsonData.shift();
    
                    component.set('v.excelData', jsonData);
                    resolve(); // 작업 성공
                } catch (error) {
                    reject(error); // 작업 실패
                }
            };
    
            reader.readAsArrayBuffer(file);
        });
    },
    

    closedExcel : function (component, event, helper) {
        component.set('v.excelUploadModal', false);  
    },
})