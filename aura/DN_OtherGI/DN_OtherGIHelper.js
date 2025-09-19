({
    insertGIList : function(component, event) {
        console.log('insertGRList');
        let dmlGIList =[];
        let giList = component.get('v.selectedGI');
        let self = this;
        giList.forEach(element => {
            
            dmlGIList.push({
                'Part__c' : element.Part__c,
                'Unit__c' : element.Unit__c,
                'Quantity__c' : element.REQTY,
                'CustomerPrice__c' : element.NETPR,
                'DiscountPrice__c' : element.STPR,
                'DiscountAmount__c' : Number(element.REQTY) * Number(element.STPR),
                'Reason__c' : element.REASON,
                'Comment__c': element.DESC,
                'InventoryItemNumber__c' : element.hang
            })
        });
        component.set('v.isLoading', true);
        this.apexCall(component,event,this, 'insertGI', {
            insertGIList : dmlGIList
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log('r : ',  JSON.stringify(r));
            console.log('state : ',  state);
            let headerData = [{
                '대리점명': r.agencyName,
                '참고문서번호' : r.docNumber,
                '생성일자': r.createDate,
                '생성시각' : r.createTime
            }];
            let exceldata = [];
            let index =1;
            let docType = '기타출고';
            r.excelDataList.forEach(element => {
                docType = element.type;
                exceldata.push({
                    '순번' : index,
                    '종류': element.type || '',
                    '문서번호' : element.dcoNumber || '',
                    '품번' : element.partNumber || '',
                    '품명' : element.partName || '',
                    '수량' : element.quantity || '',
                    '재고위치' : element.location || ''
                });
                index ++;
            });
            component.set('v.headerData',headerData);
            component.set('v.excelGRData',exceldata);
            component.set('v.excelName', `${r.docNumber}_${docType}증`);
            //$A.get('e.force:refreshView').fire();
            
        })).then($A.getCallback(function(result) {
            if(component.get('v.headerData').length > 0) {
                self.handleGIGRDocumentExcel(component); 
            }
        })).catch(function(error) {
            console.log('# addError error : ' + error[0].message);
            //component.set('v.isLoading', false);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    "message": '기타출고 처리되었습니다.',
                    "type": 'SUCCESS'
                });
                toastEvent.fire();
            } else {
                alert('기타출고 처리되었습니다.');
            }
            $A.get('e.force:refreshView').fire();
            component.set('v.isLoading', false);
        });
    },
})