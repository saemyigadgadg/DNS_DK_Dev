({
    gfnDoInit : function(component, event) {
        let self = this;
        this.apexCall(component, event, this, 'init', {}).then($A.getCallback(function(result){
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                component.set('v.isAdmin', r.isAdmin);
                component.set('v.gradeRateMap', r.dealerGradeRateMap);
            }
            else {
                self.toast('Warning', ' 관리자한테 문의해주세요. ');
            }
        }));
    },

    gfnSearch : function(component, event, isNotShowToast) {
        component.set('v.isLoading', true);
        let params = component.get('v.headerParams');
        component.find("headerCheckbox").set("v.checked", false);
        params.dealerGradeRateAllMap = component.get('v.gradeRateMap');
        let self = this;
        this.apexCall(component, event, this, 'searchCostWarrnatyItems', params).then($A.getCallback(function(result){
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                component.set('v.partsList' , r.settlementAmountList);
                self.gfnTotalCalculate(component);

                if(r.settlementAmountList.length == 0 && !isNotShowToast) {
                    self.toast('Warning', '검색 조건에 맞는 데이터가 존재하지 않습니다.');
                }
            }
            else {
                self.toast('Warning', ' 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        }));
    },

    gfnConvertParams : function(params, headerParam) {
        if(headerParam.fieldType === 'YearMonth') {
            let yaerMonthList = headerParam.value.split('-');
            let startDate = new Date(yaerMonthList[0], Number(yaerMonthList[1])-1, 1);
            let startDateStr = `${startDate.getFullYear()}-${this.gfnPadStart(startDate.getMonth()+1,2,'0')}-${this.gfnPadStart(startDate.getDate(),2,'0')}`;
            params[headerParam.field+'Start'] = startDateStr;
            startDate.setMonth(startDate.getMonth()+1);
            startDate.setDate(0);
            let endDateStr = `${startDate.getFullYear()}-${this.gfnPadStart(startDate.getMonth()+1,2,'0')}-${this.gfnPadStart(startDate.getDate(),2,'0')}`;
            params[headerParam.field+'End'] = endDateStr;
            // console.log(` startDateStr : ${startDateStr} , endDateStr : ${endDateStr} `);
        }else if(headerParam.field === 'CustomerName__c') {
            params['customerId'] = headerParam.value;
        }else {
            params[headerParam.field] = headerParam.value;
        }
        
        return params;
    },

    // 상태값 변경
    gfnUpdateWarranty: function (component,helper) {
        let self = this;
        let updateList = component.get('v.partsList').filter((part)=>part.isSelected);

        if(updateList.length == 0) {
            self.toast('Warning', 'Order를 선택하시기 바랍니다.');
            return ;
        }

        self.apexCall(component, event, helper, 'statusUpdate', {
            updateList,
            statusCode : component.get('v.statusCode')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log(JSON.stringify(result), ' ::: result');
            self.toast('Success', '성공적으로 상태가 변경 되었습니다.');
            self.gfnSearch(component, null, true);
        }))
        .catch(function(error) {
            self.toast('Warning', error[0].message);
        });
    },

    createExcel: function (component) {
        component.set('v.isLoading', true);
        var partsList = component.get('v.partsList');

        // Excel Header
        var exportHeader = [
            '오더번호',
            '품번',
            '품명',
            '청구수량',
            '공급수량',
            '부품금액',
            '20%보상금액',
            '최종보상금액',
            '진행상태',
            '배송 방법',
            '배송처',
            '발송완료일자',
            '배송정보',
            '고객명',
            '정비업체',
            '서비스기사',
            '접수일',
            '확정일',
            '기종',
            '호기',
            '공급대리점'
        ];

        var data = [];
        data.push(exportHeader);
        let index=1;
        partsList.forEach(function (item) {
            var rowArray = [];
            var deliveryInfo = item.plannedDeliveryDateTimeString; //item.PDATE + ' ' + item.PTIME;
            rowArray.push(item.serviceOrderSeq);
            rowArray.push(item.partName);
            rowArray.push(item.partDetails);
            rowArray.push(item.requestQuantity);
            rowArray.push(item.giQuantity);
            rowArray.push(Number(item.customerPrice).toLocaleString());
            rowArray.push(Number(item.compensationAmount).toLocaleString());
            rowArray.push(Number(item.finalCompensationAmount).toLocaleString());
            rowArray.push(item.statusLabel);
            rowArray.push(item.shippingTypeLabel);
            rowArray.push(item.shipTo);
            rowArray.push(item.deliveryDate);
            rowArray.push(deliveryInfo);
            rowArray.push(item.customerName);
            rowArray.push(item.centerName);
            rowArray.push(item.serviceEngineer);
            rowArray.push(item.approvalDate);
            rowArray.push(item.confirmDateStr);
            rowArray.push(item.machineName);
            rowArray.push(item.equipment);
            rowArray.push(item.dealerName);

            data.push(rowArray);
            index++;
        });
        // 데이터 하단에 합산값 추가
        data.push(["보상금액 총합", "", "","","","","","","","","","","","","","",Number(component.get('v.totalCompensationAmount')).toLocaleString(),"","",""]);
       

        // SheetJS 워크북 생성
        var workbook = XLSX.utils.book_new();
        var worksheet = XLSX.utils.aoa_to_sheet(data);
       

        // width 설정
        var wscols = [
            { wch: 15 },
            { wch: 25 },
            { wch: 30 },
            { wch: 5 },
            { wch: 5 },
            { wch: 15 },
            { wch: 15 },
            { wch: 15 },
            { wch: 10 },
            { wch: 10 },
            { wch: 30 },
            { wch: 15 },
            { wch: 20 },
            { wch: 15 },
            { wch: 15 },
            { wch: 15 },
            { wch: 10 },
            { wch: 10 },
            { wch: 20 },
            { wch: 20 },
            { wch: 10 }
        ];
        // 워크시트에 열 너비 설정
        worksheet['!cols'] = wscols;
        
                     // 보상금액 설정
        let lastIndex = data.length-1;
        //worksheet.mergeCells(`A${lastIndex}:P${lastIndex}`);
       
                       
                           



        // Header Style 설정
        function applyStyles(worksheet) {
            const range = XLSX.utils.decode_range(worksheet['!ref']);
            const lastRowIndex = range.e.r; // 마지막 행 인덱스
            // A~P 열까지 병합 (열 0~15)
            const mergeAtoP = {
                s: { r: lastRowIndex, c: 0 },  // 첫 번째 열 (A열)
                e: { r: lastRowIndex, c: 15 }  // 마지막 행의 P열 (16번째 열)
            };

            // Q~U 열까지 병합 (열 16~20)
            const mergeQtoU = {
                s: { r: lastRowIndex, c: 16 },  // 첫 번째 열 (Q열)
                e: { r: lastRowIndex, c: 20 }  // 마지막 행의 U열 (21번째 열)
            };

            // 병합 정보 추가 (셀 병합)
            worksheet['!merges'] = worksheet['!merges'] || [];
            worksheet['!merges'].push(mergeAtoP);
            worksheet['!merges'].push(mergeQtoU);

            for (var C = range.s.c; C <= range.e.c; ++C) {
                
                const cellAddress = XLSX.utils.encode_cell({ c: C, r: 0 });
                const lastAddress = XLSX.utils.encode_cell({ c: C, r: lastIndex });
              
                // 마지막 행 설정
                if(worksheet[lastAddress]) {
                    worksheet[lastAddress].s = {
                        font: {
                            name: '맑은 고딕',
                            bold: true,
                            color: { rgb: "FFFFFF" }
                        },
                        fill: {
                            fgColor: { rgb: "4F81BD" }
                        },
                        alignment: {
                            vertical: "right",
                            horizontal: "right"
                        },
                        border: {
                            top: { style: 'thin', color: { rgb: '000000' } },
                            bottom: { style: 'thin', color: { rgb: '000000' } },
                            left: { style: 'thin', color: { rgb: '000000' } },
                            right: { style: 'thin', color: { rgb: '000000' } }
                        }
                    };
                } 
                //첫번쨰 행 설정
                if (worksheet[cellAddress]) {
                    worksheet[cellAddress].s = {
                        font: {
                            name: '맑은 고딕',
                            bold: true,
                            color: { rgb: "FFFFFF" }
                        },
                        fill: {
                            fgColor: { rgb: "4F81BD" }
                        },
                        alignment: {
                            vertical: "center",
                            horizontal: "center"
                        },
                        border: {
                            top: { style: 'thin', color: { rgb: '000000' } },
                            bottom: { style: 'thin', color: { rgb: '000000' } },
                            left: { style: 'thin', color: { rgb: '000000' } },
                            right: { style: 'thin', color: { rgb: '000000' } }
                        }
                    };
                } 
                
            }
        }
        


        // 워크북에 워크시트 추가
        XLSX.utils.book_append_sheet(workbook, worksheet, "비용정산대상항목조회");
        // header 변경
        XLSX.utils.sheet_add_aoa(worksheet, [exportHeader], { origin: "A1" });

        // 스타일 적용
        applyStyles(worksheet);

        // 내보낼 파일 이름 설정
        XLSX.writeFile(workbook, "비용정산"+ ".xlsx");

        component.set('v.isLoading', false);
    },

    gfnTotalCalculate : function (component) {
        let totalCompensationAmount = component.get('v.partsList').reduce((acc, currVal)=>{
            return acc + currVal.finalCompensationAmount;
        }, 0);
        component.set('v.totalCompensationAmount', totalCompensationAmount);
    }
})