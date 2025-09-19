/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-19-2024
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-19-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    insertGRList : function(component, event) {
        console.log('insertGRList');
        let dmlGRList =[];
        let grList = component.get('v.selectedGR');
        let self = this;
        console.log(JSON.stringify(grList), ' ::: grList');
        grList.forEach(element => {
            
            dmlGRList.push({
                'Part__c' : element.Part__c,
                'Quantity__c' : element.GRQTY,
                'Unit__c' : element.UNIT,
                'CustomerPrice__c' : element.NETPR,
                'DiscountPrice__c' : element.STPR,
                'DiscountAmount__c' : parseInt(element.GRQTY) * parseInt(element.STPR),
                'Reason__c' : element.REASON,
                'Comment__c': element.DESC,
                'InventoryItemNumber__c' : element.hang
            })
        });
        component.set('v.isLoading', true);
        this.apexCall(component,event,this, 'insertGRList', {
            inventoryList : dmlGRList
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log('r : ',  JSON.stringify(r));
            console.log('state : ',  state);
            let headerData = [{
                '대리점명': r.agencyName,
                '참고문서번호' : r.doc,
                '생성일자': r.createdDate,
                '생성시각' : r.createdTime
            }];
            let exceldata = [];
            let index =1;
            r.returnGRList.forEach(element => {
                // console.log(element.Location__c,' <===element.Location__r.FM_Loc__c');
                let location = '';
                if(element.DealerStock__c !=null) {
                    location =  element.DealerStock__r.DealerLocation__c==null ? '' : element.DealerStock__r.DealerLocation__r.FM_Loc__c;
                }
                exceldata.push({
                    '순번' : index,
                    '종류':'기타입고',
                    '문서번호' : element.InventoryNumber__c || '',
                    '품번' : element.Part__r.ProductCode || '',
                    '품명' : element.Part__r.FM_MaterialDetails__c || '',
                    '수량' : element.Quantity__c || 0,
                    '재고위치' : location
                });
                index ++;
            });
            component.set('v.headerData',headerData);
            component.set('v.excelGRData',exceldata);
            component.set('v.excelName', `${r.doc}_기타입고`);
            
        })).then($A.getCallback(function(result) {
            self.handleGIGRDocumentExcel(component); 
            
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            component.set('v.noPartNumber', []);
            // component.set('v.isLoading', false);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    "message": '입고처리 처리되었습니다.',
                    "type": 'SUCCESS'
                });
                toastEvent.fire();
            } else {
                alert('입고처리 처리되었습니다.');
            }
            component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
            //component.set('v.isLoading', false);
        });
    },
    
})