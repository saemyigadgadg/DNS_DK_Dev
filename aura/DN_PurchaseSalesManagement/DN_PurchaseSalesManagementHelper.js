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
    //검색 조건 가공 
    getSearchParams : function (component) {
        //해야함.
        let headerParams = component.get('v.headerParams');
        console.log(`${component.getName()}.gfnGetSearchParams : `);
        console.log( JSON.stringify(headerParams))
        let params = {};

        for(const key in headerParams) {
            console.log(key);
            params[key] = headerParams[key];
        }
        console.log( JSON.stringify(headerParams))
        return params;
    },

    forListSettup : function (component, event, type) {
        component.set('v.isLoading', true);
        console.log('forListSettup');
        let params = this.getSearchParams(component);
        let self = this;
        console.log('salesSearch',JSON.stringify(params));
    
        this.apexCall(component,event, this, 'getData', params).then($A.getCallback(function(result) {
            let {r} = result;

           console.log('r : ',  r);
           console.log('22');
           console.log('status : ',  r.status);
           if(r.status.code === 200 ) {  
                console.log('Inside Success');

                if(!r.recordListSet || r.recordListSet.length ==0) {
                    self.toast('Warning', '검색조건에 맞는 데이터가 존재 하지 않습니다.');
                    component.set('v.isLoading', false);
                    return;
                }
                   
                component.set('v.psList', r.recordListSet);
                var psList = component.get('v.psList');
                var psCount = 0;
                var salCount = 0;
                var psTotal = 0;
                var salTotal = 0;


                for (var i = 0; i < psList.length; i++) {
                    var parseDMBTR =parseInt(psList[i].discountAmount);// parseInt(psList[i].discountAmount.replace(/,/g, ''));

                    if (psList[i].reordType == '입고') {
                        psCount += psList[i].quantity//psList[i].MENGE
                        psTotal += parseDMBTR;
                    } else if (psList[i].reordType == '출고') {
                        salCount += psList[i].quantity//
                        salTotal += parseDMBTR;
                    }
                };

                var strPsTotal = psTotal.toLocaleString();
                var strSalTotal = salTotal.toLocaleString();

                console.log('psTotal:', strPsTotal);
                console.log('salTotal:', strSalTotal);
                console.log('psCount:', psCount);
                console.log('salCount:', salCount);

                component.set('v.psCount', psCount);
                component.set('v.salCount', salCount);
                component.set('v.psTotal', strPsTotal);
                component.set('v.salTotal', strSalTotal);
            } else {
                
                self.toast('warning', ' 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },
    ///입출고 필터 변경에 따라 세부분류 필터 제어
    getDetailTypeItem: function(component, dealerName, dealerId) {
        let partList = component.get('v.partsList');
        partList.forEach((part) => {
            part.dealer = dealerId;
            part.dealerName = dealerName;
        });
        component.set('v.partsList', partList);
    },

    downloadExcel: function (component, event, helper) {
        try {
            var psList = component.get("v.psList");
            console.log(psList);
            if(psList < 1){
                alert('조회된 정보가 없습니다.');
                return;
            }
            if ( typeof XLSX === 'undefined'){
                console.log('XLSX is not loaded');
            }
            // SheetJS library - create workbook
            var wb = XLSX.utils.book_new();

            //var psList = component.get("v.psList");
            var excelData = [];
            var sheetName = '매입매출관리';

            // Header styles
            var headerStyles = {
                font: {
                    name: '맑은 고딕',
                    bold: true
                },
                fill: {
                    fgColor: { rgb: "D5D5D5" }
                },
                alignment: {
                    vertical: "center",
                    horizontal: "center",
                    wrapText: true
                },
                border: {
                    top: { style: 'thin', color: { rgb: '000000' } },
                    bottom: { style: 'thin', color: { rgb: '000000' } },
                    left: { style: 'thin', color: { rgb: '000000' } },
                    right: { style: 'thin', color: { rgb: '000000' } }
                }
            };
            
            // Header data
            var header = ["입출고 구분", "세부 분류", "구매처/고객사명", "입출고 문서번호", "생성일자", "입출고 수량", "금액", "통화", "참고문서번호"];
            var headerRow = header.map(item => ({ v: item, s: headerStyles }));
            excelData.push(headerRow);
            
           
            // Data rows
            psList.forEach(item => {
                excelData.push([
                    { v: item.reordType  || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.reordDTName  || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.customerName || '',s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.giDocNumber || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.createdDate || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.quantity.toLocaleString() || '', s: { alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.discountAmount.toLocaleString() || '', s: { alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.currencyValue || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.refDocNumber || '',s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }}
                ]);
            });
            var footerStyles = {
                font: {
                    name: '맑은 고딕',
                    bold: true
                },
                fill: {
                    fgColor: { rgb: "D4F4FA" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "right",
                    wrapText: true
                },
                border: {
                    top: { style: 'thin', color: { rgb: '000000' } },
                    bottom: { style: 'thin', color: { rgb: '000000' } },
                    left: { style: 'thin', color: { rgb: '000000' } },
                    right: { style: 'thin', color: { rgb: '000000' } }
                }
            };
            
            
            // Footer data
            var footerRow1 = ["", "", "", "", {v:"입고 합계", s: footerStyles },{v:component.get("v.psCount"), s:footerStyles}, {v:component.get("v.psTotal"), s:footerStyles}, {v:"KRW", s:footerStyles}, ""];
            var footerRow2 = ["", "", "", "", {v:"출고 합계", s: footerStyles },{v:component.get("v.salCount"),s:footerStyles}, {v:component.get("v.salTotal"), s:footerStyles}, {v:"KRW", s:footerStyles}, ""];
          
            excelData.push(footerRow1, footerRow2);
        
            var ws = XLSX.utils.aoa_to_sheet(excelData);

            // Set column widths
            var wscols = [
                { wch: 15 },  // 입출고 구분
                { wch: 15 },  // 세부 분류
                { wch: 20 },  // 구매처/고객사명
                { wch: 20 },  // 입출고 문서번호
                { wch: 15 },  // 생성일자
                { wch: 15 },  // 입출고 수량
                { wch: 20 },  // 금액
                { wch: 10 },  // 통화
                { wch: 20 }   // 참고문서번호
            ];
            ws['!cols'] = wscols;

            // Append sheet to workbook
            XLSX.utils.book_append_sheet(wb, ws, sheetName);

            // Generate Excel binary
            var wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'binary' });

            // Convert binary string to ArrayBuffer
            function s2ab(s) {
                var buf = new ArrayBuffer(s.length);
                var view = new Uint8Array(buf);
                for (var i = 0; i < s.length; i++) view[i] = s.charCodeAt(i) & 0xFF;
                return buf;
            }

            // Create Blob and download link
            var blob = new Blob([s2ab(wbout)], { type: "application/octet-stream" });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = '매입매출관리.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } catch (error) {
            console.error("에러 내역 알려주세요 ::: " + error);
        }
    },
})