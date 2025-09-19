({
    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },

    gfnDoInit : function(component, event) {
        let self = this;
        this.apexCall(component, event, this, 'init', {}).then($A.getCallback(function(result){
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                component.set('v.deliveryOptions' , r.shippingOptionList);
                component.set('v.processStatus', r.statusOptionList);
                component.set('v.isAdmin', r.isAdmin);
                component.set('v.dealerOptions', r.dealerOptionList);
                component.set('v.gradeRateMap', r.dealerGradeRateMap);
            }
            else {
                self.toast('Warning', ' 관리자한테 문의해주세요. ');
            }
        }));
    },

    gfnSearch : function(component, event) {
        component.set('v.isLoading', true);
        let params = component.get('v.headerParams');

        let self = this;
        this.apexCall(component, event, this, 'searchWarrnatyItems', params).then($A.getCallback(function(result){
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                component.set('v.partsList' , r.warrantyList);

                if(r.warrantyList.length == 0)
                    self.toast('Warning', '검색 조건에 맞는 데이터가 존재하지 않습니다.');
            }
            else {
                self.toast('Warning', ' 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        }));
    },

    gfnUpdateWarranty : function(component, event) {
        component.set('v.isLoading', true);
        let requestGoodsIssueList = component.get('v.partsList').filter(part=>part.isSelected && !part.isDisabled);
        if(requestGoodsIssueList.length == 0) {
            this.toast('Warning', '변경할 서비스 오더를 입력하세요');
            component.set('v.isLoading', false);
            return ;
        }
        
        let self = this;
        this.apexCall(component, event, this, 'updateWarranty', {requestGoodsIssueList}).then($A.getCallback(function(result){
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                if(r.updateWarrantyList.length > 0) {
                    self.toast('Success', '정상적으로 변경을 완료하였습니다. ');
                    setTimeout(()=>self.gfnSearch(component, event), 0);
                }
            }
            else {
                if(r.status.msg.indexOf('[N]') !== -1) {
                    self.toast('Warning', r.status.msg.replace('Exception : [N]', ''));
                }else {
                    self.toast('Warning', ' 관리자한테 문의해주세요. ');
                }
            }
            component.set('v.isLoading', false);
        }));
    },

    gfnCompleteGoodsIssue : function(component, event) {
        if(!component.get('v.deliveryDateTime')) {
            this.toast('Warning', '배송예정일을 입력하세요.');
            return ;
        }
        
        component.set('v.isLoading', true);
        let requestGoodsIssueList = component.get('v.partsList').filter(part=>part.isSelected && !part.isDisabled && part.status !== '3');
        if(requestGoodsIssueList.length == 0) {
            this.toast('Warning', '출고할 서비스 오더를 입력하세요');
            component.set('v.isLoading', false);
            this.gfnDeliveryCancel(component);
            return ;
        }
        this.gfnGoodIssueApexCall(component, requestGoodsIssueList);

        // if(isIncludeCancelStatus) {
        //     let self = this;
        //     this.openConfirm('진행상태가 취소인 항목이 포함되어 있습니다. 취소 항목을 제외하고 진행하시겠습니까?','default', 'headerless').then($A.getCallback(function(result){
        //         if(result) {
        //             let notInculdeCancelrequestGoodsIssueList = requestGoodsIssueList.filter((requestGoodsIssue)=> requestGoodsIssue.status !== '3');
        //             self.gfnGoodIssueApexCall(component, notInculdeCancelrequestGoodsIssueList);
        //         }else {
        //             component.set('v.isLoading', false);
        //         }
    
        //     }));
        // }else {
        //     this.gfnGoodIssueApexCall(component, requestGoodsIssueList);
        // }

    },

    gfnGoodIssueApexCall : function(component, requestGoodsIssueList) {
        let plannedDeliveryDateTime = component.get('v.deliveryDateTime');
        requestGoodsIssueList.forEach(goodsIssue=>{
            goodsIssue.plannedDeliveryDateTime = plannedDeliveryDateTime;
        });
        
        let dealerGradeRateAllMap = component.get('v.gradeRateMap');
        let self = this;
        this.apexCall(component, event, this, 'completeGoodsIssue', {requestGoodsIssueList, dealerGradeRateAllMap}).then($A.getCallback(function(result){
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                if(r.goodsIssueList.length > 0) {
                    self.toast('Success', '정상적으로 출고 완료하였습니다. ');
                    self.gfnDeliveryCancel(component);
                    setTimeout(()=>self.gfnSearch(component, event), 200);
                    
                }
            }
            else {
                if(r.status.msg.indexOf('[N]') !== -1) {
                    self.toast('Warning', r.status.msg.replace('Exception : [N]', ''));
                    // self.toast('Warning', '대리점에서 재고를 관리하지 않은 품목이 있습니다.');
                }else {
                    self.toast('Warning', ' 관리자한테 문의해주세요. ');
                }
            }
            component.set('v.isLoading', false);
        }));
    },

    gfnDeliveryCancel : function(component) {

        component.set('v.isDeliveryModal', false);
        component.set('v.deliveryDateTime', undefined);
    },

    gfnGetStockByChangeDealer : function(component, dealerId, warrantyId) {
        console.log('getStockByChangeDealer');
        let warrantyList = component.get('v.partsList');
        let warranty = warrantyList.find(part=> warrantyId == part.warrantyId);
        
        let partIdList = [warranty.part];
        let self = this;
        this.apexCall(component, null, this, 'getStockByChangeDealer', {dealerId, partIdList}).then($A.getCallback(function(result){
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                if(r.dealerStockMap ) {
                    if(r.dealerStockMap[warranty.part]) {
                        warranty.avaiableQuantity = r.dealerStockMap[warranty.part].AvailableQuantity__c;
                        warranty.isDisabled = false;
                    }else {
                        warranty.avaiableQuantity = 0;
                        warranty.isDisabled = true;
                        warranty.isSelected = false;
                    }
                    component.set('v.partsList', warrantyList);
                }
            }
            else {
                self.toast('Warning', ' 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        }));
    },

    gfnExcelDownload : function(component, event) {
        component.set('v.isLoading', true);
        let selectedOrder = component.get('v.partsList').filter(part=>part.isSelected && !part.isDisabled);

        let currentUserInfo = component.get('v.currentUserInfo');
        console.log(JSON.stringify(currentUserInfo));

        if (selectedOrder.length < 1) {
            this.toast('Error', '한 개 이상의 항목을 선택해주세요.');
            component.set('v.isLoading', false);
        } else {
            // 헤더 정의
            var header1 = ["대리점명", "생성일자", "생성시각"];
            var header2 = ["SVC오더번호", "배송 방법", "배송처", "배송처 주소", "", "담당자", "전화번호"];
            var header3 = ["순번", "종류", "문서번호", "품번", "품명", "수량", "재고위치"];

            // 데이터를 위한 빈 배열 생성
            var data = [];

            // 헤더 전의 행들을 위한 자리 표시자(행을 삽입하기 위한 그릇을 만드는거) 추가
            for (var i = 0; i < (selectedOrder.length + 6 + selectedOrder.length); i++) {
                data.push([]);
            }

            // 특정 행에 헤더 삽입
            data[0][4] = header1[0]; // E1
            data[0][5] = header1[1]; // F1
            data[0][6] = header1[2]; // G1
            data[3] = header2; // A4:G4
            data[selectedOrder.length + 5] = header3;

            // Data
            for (var i = 0; i < selectedOrder.length; i++) {
                data[i + 4][0] = selectedOrder[i].serviceOrderSeq;
                data[i + 4][1] = selectedOrder[i].shippingTypeLabel;
                data[i + 4][2] = selectedOrder[i].shipTo; //배송처
                data[i + 4][3] = selectedOrder[i].shipToAddress;
                data[i + 4][5] = selectedOrder[i].serviceEngineer; // 담당자 : 서비스기사로 매핑
                data[i + 4][6] = selectedOrder[i].shipToPhone;
                data[selectedOrder.length + (i + 6)][0] = i + 1;
                data[selectedOrder.length + (i + 6)][1] = '무상부품';
                data[selectedOrder.length + (i + 6)][2] = selectedOrder[i].serviceOrderSeq;
                data[selectedOrder.length + (i + 6)][3] = selectedOrder[i].partName;
                data[selectedOrder.length + (i + 6)][4] = selectedOrder[i].partDetails;
                data[selectedOrder.length + (i + 6)][5] = selectedOrder[i].requestQuantity;
                data[selectedOrder.length + (i + 6)][6] = selectedOrder[i].locName;     //재고위치?
            }

            // SheetJS 워크북 생성
            var workbook = XLSX.utils.book_new();
            var worksheet = XLSX.utils.aoa_to_sheet(data);

            // width 설정
            var wscols = [
                { wch: 15 },
                { wch: 10 },
                { wch: 20 },
                { wch: 15 },
                { wch: 25 },
                { wch: 15 },
                { wch: 15 }
            ];

            // 워크시트에 열 너비 설정
            worksheet['!cols'] = wscols;

            // Merge
            worksheet['!merges'] = [
                { s: { r: 0, c: 0 }, e: { r: 1, c: 1 } },
                { s: { r: 3, c: 3 }, e: { r: 3, c: 4 } },
                ...selectedOrder.map((_, i) => ({ s: { r: i + 4, c: 3 }, e: { r: i + 4, c: 4 } }))   // spread syntax 문법. 배송처 주소 Data 값 병합
            ];

            // 날짜와 시간 포맷팅
            var today = new Date();
            var dateStr = today.getFullYear() + '.' + (today.getMonth() + 1).toString().padStart(2, '0') + '.' + today.getDate().toString().padStart(2, '0');
            var timeStr = today.getHours().toString().padStart(2, '0') + ':' + today.getMinutes().toString().padStart(2, '0') + ':' + today.getSeconds().toString().padStart(2, '0');

            // Text 추가
            worksheet['A1'] = { t: 's', v: '무상부품_출고증' };
            worksheet['E2'] = { t: 's', v: currentUserInfo.name };
            worksheet['F2'] = { t: 's', v: dateStr };
            worksheet['G2'] = { t: 's', v: timeStr };


            // 헤더 스타일 정의
            var headerStyle = {
                font: {
                    name: '맑은 고딕',
                    // bold: true,
                    // color: { rgb: "FFFFFF" }
                },
                fill: {
                    fgColor: { rgb: "F2F2F2" } // 4F81BD > F2F2F2 > #C0C0C0
                    //F2F2F2
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

            // 스타일 적용
            worksheet['A1'].s = {
                alignment: {
                    vertical: "center",
                    horizontal: "center",
                }
            };
            worksheet['E2'].s = {
                alignment: {
                    vertical: "center",
                    horizontal: "center",
                }
            };
            worksheet['F2'].s = {
                alignment: {
                    vertical: "center",
                    horizontal: "center",
                }
            };
            worksheet['G2'].s = {
                alignment: {
                    vertical: "center",
                    horizontal: "center",
                }
            };
            worksheet['E1'].s = headerStyle;
            worksheet['F1'].s = headerStyle;
            worksheet['G1'].s = headerStyle;
            worksheet['A4'].s = headerStyle;
            worksheet['B4'].s = headerStyle;
            worksheet['C4'].s = headerStyle;
            worksheet['D4'].s = headerStyle;
            worksheet['E4'].s = headerStyle;
            worksheet['F4'].s = headerStyle;
            worksheet['G4'].s = headerStyle;
            worksheet['A' + (selectedOrder.length + 6)].s = headerStyle;
            worksheet['B' + (selectedOrder.length + 6)].s = headerStyle;
            worksheet['C' + (selectedOrder.length + 6)].s = headerStyle;
            worksheet['D' + (selectedOrder.length + 6)].s = headerStyle;
            worksheet['E' + (selectedOrder.length + 6)].s = headerStyle;
            worksheet['F' + (selectedOrder.length + 6)].s = headerStyle;
            worksheet['G' + (selectedOrder.length + 6)].s = headerStyle;

            // 워크북에 워크시트 추가
            XLSX.utils.book_append_sheet(workbook, worksheet, "무상부품_출고증");

            // 내보낼 파일 이름 설정
            XLSX.writeFile(workbook, "무상부품_출고증" + ".xlsx");
        }
        component.set('v.isLoading', false);
    }

})