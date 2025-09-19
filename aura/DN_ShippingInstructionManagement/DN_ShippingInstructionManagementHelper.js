({
    // 쿼리 설정
    setQuery : function(component) { 
        let strQuery = [];
        let userInfo = component.get('v.currentUserInfo');
        console.log(JSON.stringify(userInfo), ' < ==userInfo');
        component.set('v.whereCondition',{});
    },
    setFilterChange : function(component, message) {
        let param =message.message;
        console.log(JSON.stringify(param), '< ==param');
        let getWhere = component.get('v.whereCondition');
        console.log(JSON.stringify(getWhere), ' < ==getWhere');
        console.log(getWhere.field,' < ==getWhere.field');
        if(getWhere.field == param.field) {
            getWhere.field = param.value;
        } else {
            getWhere[param.field] = param.value;
        }
        
        //T00:00:00.000+0000
        console.log(JSON.stringify(getWhere), ' < ==getWhere');
        component.set('v.whereCondition',getWhere);
        // console.log(JSON.stringify(component.get('v.whereCondition')), ' >< testet');
    },

    // 출고지시 수량 저장
    updateQTy : function(component, message) {    
        let self = this;
        component.set('v.isLoading',true); 
        let recordList = component.get('v.recordList');
        let updateData = [];
        for(let i=0; i<recordList.length; i++) {
            let element = recordList[i];
            if(element.Quantity__c =='' || element.Quantity__c == 0) {
                self.toast('error', `출고지시번호 ${element.DeliveryOrder__c}의 출고지시 수량을 확인해주세요.`);
                component.set('v.isLoading',false); 
                return;
            }
            
            updateData.push({
                id : element.Id,
                quantity : element.Quantity__c
            });
        }
        
        console.log(JSON.stringify(updateData), ' < =updateData');
        this.apexCall(component,event,this, 'updateQuantity', {
            shipList : updateData
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            self.toast('success', '출고지시가 저장되었습니다.');
            self.getDataQuery(component,'Search');
        })).catch(function(error) {
            self.toast('error', error[0].message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    }, 

    //데이터 조회
    getDataQuery : function(component, message) {
        component.set('v.isLoading', true);
        let self = this;
        let currentPage = message=='Seach'? 1 : component.get('v.currentPage');
        component.set('v.currentPage', currentPage);
        let nextPage = message=='Seach'? 1 : component.get('v.nextPage');
        component.set('v.nextPage',nextPage)
        this.apexCall(component,event,this, 'getDataListQuery', {
            page : {
                strQuery : component.get('v.whereCondition'),
                recordList : component.get('v.recordList'),
                itemsPerPage : component.get('v.itemsPerPage'),
                currentPage : component.get('v.currentPage'),
                pagesPerGroup : component.get('v.pagesPerGroup'),
                orderByField : component.get('v.orderByField'),
                orderBy : component.get('v.orderBy')
            },
            nextPage : component.get('v.nextPage')
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            console.log(JSON.stringify(r), '  ::: RRRRR');
            component.set('v.seletedList', []);
            component.set('v.recordList', r.recordList);
            component.set('v.excelReturnList',r.excelReturnList);
            let mas = {
                'currentPage' : r.currentPage,
                'itemsPerPage' : r.itemsPerPage,
                'pagesPerGroup' : r.pagesPerGroup,
                'currentRecordSize' : r.recordList.length,
                'totalRecordSize' : r.totalRecordSize,
                'startIdx' : r.startIdx,
                'endIdx' : r.endIdx,
                'totalPage' : Math.ceil(r.totalRecordSize / r.itemsPerPage),
                'eventType' : message
            };
            component.find("dealerPortalLMC").publish({
                uuid : component.get('v.uuid'),
                type : 'dataListSearch',
                message : mas,
                cmpName : 'dataTable'
            })
            if(r.recordList.length == 0) {
                self.toast('success', '검색되는 데이터가 없습니다.');
            }
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },

    // 출고지시 다운로드
    handleShippingOrder : function(component, message) {
        component.set('v.isLoading', true);    

        let seleted = component.get('v.seletedList')[0];
        console.log(JSON.stringify(component.get('v.seletedList')) + ' :::test');
        let excelReturnList = component.get('v.excelReturnList');
        excelReturnList = excelReturnList.filter(item => item.id == seleted.Id);
        let excelData = excelReturnList[0];
        console.log(JSON.stringify(seleted), ' < ==seleted');
        console.log(JSON.stringify(excelData), ' < ==excelData');
        // let exceldataSet = {
        //     '고객사명' : seleted.Order__r.FM_CustomerName__c,
        //     '출고지시번호': seleted.DeliveryOrder__c,
        //     '출고지시일자': seleted.FM_DeliveryDate__c,
        //     '출고지시시간': excelData.deliveryTime,
        //     '대표주소' : seleted.DealerOrderItem__r.Order__r.Customer__r.FM_Address__c,
        //     '우편번호' : seleted.DealerOrderItem__r.Order__r.Customer__r.Address__PostalCode__s,
        //     '대표자명' : seleted.DealerOrderItem__r.Order__r.Customer__r.Representative__c,
        //     '전화번호' : seleted.DealerOrderItem__r.Order__r.Customer__r.Phone__c,
        //     '배송 방법' : seleted.DealerOrderItem__r.Order__r.ShippingType__c,
        //     '주문번호' : seleted.DealerOrderItem__r.Order__r.OrderNumber__c,
        //     '품번' : seleted.DealerOrderItem__r.Part__r.ProductCode,
        //     '품명' : seleted.DealerOrderItem__r.Part__r.FM_MaterialDetails__c,
        //     '수량' : seleted.Quantity__c,
        //     '저장위치' : excelData.location
        // }
        //console.log(JSON.stringify(exceldataSet), ' <M ==exceldataSet' );
        var workbook = new ExcelJS.Workbook();
        var worksheet = workbook.addWorksheet('Sheet1');
        worksheet.mergeCells('A1:G1');
        worksheet.getCell('A1').value = '출고지시서';        
        worksheet.getCell('A1').alignment = { vertical: 'middle', horizontal: 'center' };

        worksheet.mergeCells('A2:B6');
        worksheet.getCell('A2').value = 'DN 솔루션즈';
        worksheet.getCell('A2').alignment = { vertical: 'middle', horizontal: 'center' };
        
        worksheet.mergeCells('C2:D2');
        worksheet.getCell('C2').value = '고객사명';
        worksheet.getCell('C2').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('E2').value = '출고지시번호';
        worksheet.getCell('F2').value = '출고지시일자';
        worksheet.getCell('G2').value = '출고지시시간';
        
        worksheet.mergeCells('C3:D3');
        worksheet.getCell('C3').value = seleted.DealerOrderItem__r.Order__r.FM_CustomerName__c;
        worksheet.getCell('E3').value = seleted.DeliveryOrder__c;
        worksheet.getCell('F3').value = seleted.FM_DeliveryDate__c;
        worksheet.getCell('G3').value = excelData.deliveryTime;
        worksheet.getCell('C4').value = '대표주소';
        worksheet.mergeCells('D4:E4');
        worksheet.getCell('D4').value = seleted.DealerOrderItem__r.Order__r.FM_ShipToName__c;
        worksheet.getCell('F4').value = '우편번호';
        worksheet.getCell('G4').value = seleted.DealerOrderItem__r.Order__r.FM_PostalCode__c;
        worksheet.getCell('C5').value = '대표자명';
        worksheet.mergeCells('D5:E5');
        worksheet.getCell('D5').value = seleted.DealerOrderItem__r.Order__r.FM_Representative__c;
        worksheet.getCell('F5').value = '전화번호';
        worksheet.getCell('G5').value = seleted.DealerOrderItem__r.Order__r.FM_Phone__c;
        worksheet.getCell('C6').value = '배송 방법';
        worksheet.mergeCells('D6:E6');
        worksheet.getCell('D6').value = seleted.DealerOrderItem__r.Order__r.ShippingType__c;
        
        const font = { bold: true };
        const fill = {type: 'pattern',pattern: 'solid',fgColor: { argb: 'F2F2F2' }};
        const alignment = { horizontal: 'center' };
        worksheet.getCell('A8').value = 'No';
        worksheet.getCell('A8').font = font;
        worksheet.getCell('A8').fill = fill;
        worksheet.getCell('A8').alignment = { horizontal: 'center' };

        worksheet.getCell('B8').value = '고객주문번호';
        worksheet.getCell('B8').font = font;
        worksheet.getCell('B8').fill = fill;
        worksheet.getCell('B8').alignment = { horizontal: 'center' };

        worksheet.getCell('C8').value = '주문번호';
        worksheet.getCell('C8').font = font;
        worksheet.getCell('C8').fill = fill;
        worksheet.getCell('C8').alignment = { horizontal: 'center' };

        worksheet.getCell('D8').value = '품번';
        worksheet.getCell('D8').font = font;
        worksheet.getCell('D8').fill = fill;
        worksheet.getCell('D8').alignment = { horizontal: 'center' };

        worksheet.getCell('E8').value = '품명';
        worksheet.getCell('E8').font = font;
        worksheet.getCell('E8').fill = fill;
        worksheet.getCell('E8').alignment = { horizontal: 'center' };

        worksheet.getCell('F8').value = '수량';
        worksheet.getCell('F8').font = font;
        worksheet.getCell('F8').fill = fill;
        worksheet.getCell('F8').alignment = { horizontal: 'center' };

        worksheet.getCell('G8').value = '저장위치';
        worksheet.getCell('G8').font = font;
        worksheet.getCell('G8').fill = fill;
        worksheet.getCell('G8').alignment = { horizontal: 'center' };

        
        
        worksheet.getCell('A9').value = '1';
        worksheet.getCell('B9').value = seleted.DealerOrderItem__r.Order__r.CustomerPurchaseOrderNumber__c;
        worksheet.getCell('C9').value = seleted.DealerOrderItem__r.Order__r.OrderNumber__c;
        worksheet.getCell('D9').value = seleted.DealerOrderItem__r.Part__r.ProductCode;
        worksheet.getCell('E9').value = seleted.DealerOrderItem__r.Part__r.FM_MaterialDetails__c;
        worksheet.getCell('F9').value = seleted.Quantity__c;
        worksheet.getCell('G9').value = excelData.location;
        

        for (let row = 1; row <= 9; row++) {
            const rowObj = worksheet.getRow(row);
            // 테두리 스타일 정의
            const borderStyle = {
              top: { style: 'thin' },
              left: { style: 'thin' },
              bottom: { style: 'thin' },
              right: { style: 'thin' }
            };
            
            // 각 셀에 테두리 적용
            for (let col = 1; col <= worksheet.columns.length; col++) {
              const cell = rowObj.getCell(col);
              cell.border = borderStyle;
            }
        }

        // 열 너비 자동 조정
        worksheet.columns.forEach((column) => {
            let maxLength = 0;
            column.eachCell({ includeEmpty: true }, (cell) => {
                const cellValue = cell.value ? cell.value.toString() : '';
                maxLength = Math.max(maxLength, cellValue.length);
            });
        
            column.width = maxLength + 2; // 여유 공간을 더하기 위해 2를 추가
        });

        // worksheet.eachRow({ includeEmpty: false }, function(row, rowNumber) {
        //     row.eachCell({ includeEmpty: false }, function(cell, colNumber) {
        //         cell.border = {
        //             top     : { style: 'thin' },
        //             left    : { style: 'thin' },
        //             bottom  : { style: 'thin' },
        //             right   : { style: 'thin' }
        //         };
        //     });
        // });
        // worksheet.columns.forEach((column) => {
        //     let maxLength = 0;
        //     column.eachCell({ includeEmpty: true }, (cell) => {
        //         if (cell.value) {
        //             maxLength = Math.max(maxLength, cell.value.toString().length);
        //         }
        //     });
        //     column.width = Math.max(maxLength + 2, 15);
        // });
        // Export file
        workbook.xlsx.writeBuffer().then(function (buffer) {
            var blob = new Blob([buffer], { type: 'application/octet-stream' });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = '출고지시번호_'+seleted.DeliveryOrder__c + '.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });


        component.set('v.isLoading', false);    
    }
})