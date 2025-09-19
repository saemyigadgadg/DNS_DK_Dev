/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-10-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-10-2025   youjin.shim@sbtglobal.com   Initial Version
**/
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

    searchGRGIList : function(component, event, type) {
        console.log(`${component.getName()}.searchGRGIList`);
        component.set('v.isLoading', true);
        let params = this.getSearchParams(component);
        console.log(params);
        let self = this;
        this.apexCall(component, event, this, 'getSearchData', params).then($A.getCallback(function(result) {
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
               
                if(!r.recordListSet || r.recordListSet.length ==0){
                    self.toast('Warning', '검색조건에 맞는 데이터가 존재 하지 않습니다.');
                    component.set('v.isLoading', false);
                    return;
                }
                    
                component.set('v.resultList', r.recordListSet);
                self.calculateResult(component);
                component.set('v.isLoading', false);
            }
            else {
                component.set('v.isLoading', false);
                self.toast('warning', ' 관리자한테 문의해주세요. ');
            }
        }));

    },

    //검색 조건 가공 
    getSearchParams : function (component) {
        let headerParams = component.get('v.headerParams');
        console.log(`${component.getName()}.gfnGetSearchParams : `);
        console.log( JSON.stringify(headerParams))
     
        let params = {};
        for(const key in headerParams) {
            console.log(key);
            console.log(params[key]);
            if(key === 'CustomerName__c') {
                params.customerId = headerParams[key];
            } else {
                params[key] = headerParams[key];
            }
            
        }
        
        return params;
    },
 
    calculateResult : function (component) {
        let resultList = component.get('v.resultList');
       
        var grSum1 = 0;
        var grSum2 = 0;
        var grSum3 = 0;
        var grSum4 = 0;
        var grSum5 = 0;
        var grSum6 = 0;
        var grSumAll = 0;
        var giSum1 = 0;
        var giSum2 = 0;
        var giSum3 = 0;
        var giSum4 = 0;
        var giSum5 = 0;
        var giSum6 = 0;
        var giSumAll = 0;
        resultList.forEach(function (result) {
            if (result.searchDtFileter == 'S1'){//'DNS구매') {
                grSum2 += Number(result.discountAmount);
                
                grSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'S2'){//'대리점 구매') {
                grSum1 += Number(result.discountAmount);
                grSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'S3'){//'기타입고') {
                grSum3 += Number(result.discountAmount);
                grSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'SW'){//'무상출고 취소') {
                grSum4 += Number(result.discountAmount);
                grSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'SS'){//'주문서 반품') {
                grSum5 += Number(result.discountAmount);
                grSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'SO'){//'기타출고취소') {
                grSum6 += Number(result.discountAmount);
                grSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter =='H2'){// 'DNS반품//'두산반품') {
                giSum1 += Number(result.discountAmount);
                giSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'H1'){//'대리점구매반품') {
                giSum2 += Number(result.discountAmount);
                giSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'H3'){//'기타입고 취소') {
                giSum3 += Number(result.discountAmount);
                giSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'HS'){//'주문서 출고') {
                giSum4 += Number(result.discountAmount);
                giSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'HW'){//'무상출고') {
                giSum5 += Number(result.discountAmount);
                giSumAll += Number(result.discountAmount);
            } else if (result. searchDtFileter == 'HO'){//'기타출고') {
                giSum6 += Number(result.discountAmount);
                giSumAll += Number(result.discountAmount);
            }
        });
        component.set('v.grSum1', grSum1.toLocaleString());
        component.set('v.grSum2', grSum2.toLocaleString());
        component.set('v.grSum3', grSum3.toLocaleString());
        component.set('v.grSum4', grSum4.toLocaleString());
        component.set('v.grSum5', grSum5.toLocaleString());
        component.set('v.grSum6', grSum6.toLocaleString());
        component.set('v.grSumAll', grSumAll.toLocaleString());
        component.set('v.giSum1', giSum1.toLocaleString());
        component.set('v.giSum2', giSum2.toLocaleString());
        component.set('v.giSum3', giSum3.toLocaleString());
        component.set('v.giSum4', giSum4.toLocaleString());
        component.set('v.giSum5', giSum5.toLocaleString());
        component.set('v.giSum6', giSum6.toLocaleString());
        component.set('v.giSumAll', giSumAll.toLocaleString());
       

    },

    downloadExcel: function(component) {
        try {
            var listLength =  component.get('v.resultList');
            console.log(listLength);
            if(listLength < 1){
                alert('조회된 정보가 없습니다.');
                return;
            }
            if ( typeof XLSX === 'undefined'){
                console.log('XLSX is not loaded');
            }
            // 데이터를 생성.
            var excelData = [];
            //var excelData2 = [];
            var sheetName = '입출고관리';
            var fileName = '입출고관리';

            // 헤더에 스타일 적용
            var header = ["입출고 구분","세부 분류","구매처/고객사명","문서번호","생성일자","품번","품명","수량","저장위치","금액","통화","참고문서번호","기타","배송처"];
            var headerStyles = { 
                font: { 
                    name: '맑은 고딕', 
                    bold: true, 
                    color: { rgb: "000000" } 
                },
                fill: { 
                    fgColor: { rgb: "c0c0c0" } 
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
            var headerRow = header.map(item => ({ v: item, s: headerStyles }));
            excelData.push(headerRow);
           
            // 데이터 추가
            listLength.forEach((item, index) => {
                excelData.push([
                    { v: item.reordType || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                    { v: item.reordDTName || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.customerName|| '', s: { alignment: { vertical: "middle", horizontal: "left" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.giDocNumber || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.createdDate || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.productCode || '', s: { alignment: { vertical: "middle", horizontal: "left" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.productName || '', s: { alignment: { vertical: "middle", horizontal: "left" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.quantity.toLocaleString() || '', s: { alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.location || '', s: { alignment: { vertical: "middle", horizontal: "left" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.discountAmount.toLocaleString() || '',s:  { alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.currencyValue || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.refDocNumber || '', s: { alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.comment || '', s: { alignment: { vertical: "middle", horizontal: "left" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                    { v: item.shipToName || '', s: { alignment: { vertical: "middle", horizontal: "left" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } }
                ]);
            });

            // GR_AMT01 // 두산구매
            // GR_AMT02	// 대리점구매
            // GR_AMT03	// 기타입고
            // GR_AMT04	// 기타출고취소
            // GR_AMT05	// 무상출고취소
            // GR_AMT06 // 주문서반품
            // GR_TOT   // 입고 합계
            //var GR_AMT01 = component.get("v.psCount"), GR_AMT02 = 0, GR_AMT03 = 0, GR_AMT04 = 0, GR_AMT05 = 0, GR_AMT06 = 0, GR_TOT = 0;

            // GI_AMT01	// 두산반품 
            // GI_AMT02	// 대리점구매반품
            // GI_AMT03	// 기타입고 취소
            // GI_AMT04	// 기타출고
            // GI_AMT05	// 주문서 출고
            // GI_AMT06 // 무상출고
            // GI_TOT	// 출고 합계
           // var GI_AMT01 = 0, GI_AMT02 = 0, GI_AMT03 = 0, GI_AMT04 = 0, GI_AMT05 = 0, GI_AMT06 = 0, GI_TOT = 0;
            
            excelData.push([
                { v: 'DNS구매', s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                { v:  component.get("v.grSum1"), s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '대리점구매',s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v:  component.get("v.grSum2"), s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '기타입고', s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.grSum3"), s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '무상출고 취소', s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "cenmiddleter", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.grSum4"), s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '주문서 반품', s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.grSum5"), s:  { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '기타출고취소', s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.grSum6"), s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '입고 합계', s: { fill: { fgColor: { rgb: "FF6600" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.grSumAll"), s: { fill: { fgColor: { rgb: "FF6600" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } }
            ])

            excelData.push([
                { v: 'DNS반품', s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } }},
                { v: component.get("v.giSum1"), s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '대리점구매반품', s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.giSum2"), s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '기타입고 취소', s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.giSum3"), s: { fill: { fgColor: { rgb: "c0c0c0" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '주문서 출고', s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.giSum4"), s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '무상출고', s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.giSum5"), s:  { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '기타출고', s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.giSum6"), s: { fill: { fgColor: { rgb: "99CCFF" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: '출고 합계',s: { fill: { fgColor: { rgb: "FF6600" } }, alignment: { vertical: "middle", horizontal: "center" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } },
                { v: component.get("v.giSumAll"), s: { fill: { fgColor: { rgb: "FF6600" } }, alignment: { vertical: "middle", horizontal: "right" }, border: { top: { style: 'thin', color: { rgb: '000000' } }, bottom: { style: 'thin', color: { rgb: '000000' } }, left: { style: 'thin', color: { rgb: '000000' } }, right: { style: 'thin', color: { rgb: '000000' } } } } }
            ])

            // 워크북을 생성합니다.
            var wb = XLSX.utils.book_new();

            // 워크시트를 생성하고 데이터를 추가합니다.
            var ws = XLSX.utils.aoa_to_sheet(excelData);

            // 각 컬럼의 width 설정 값
            const wscols = [{wch:13},{wch:13},{wch:18},{wch:18},{wch:11},{wch:23},{wch:31},{wch:15},{wch:23},{wch:15},{wch:15},{wch:18},{wch:33},{wch:13}];
            ws['!cols'] = wscols;
            
           
            XLSX.utils.book_append_sheet(wb, ws, sheetName);
    
            // 엑셀 파일을 생성하고 다운로드합니다.
            var wbout = XLSX.write(wb, {bookType: 'xlsx', type: 'binary'});
    
            function s2ab(s) {
                var buf = new ArrayBuffer(s.length);
                var view = new Uint8Array(buf);
                for (var i = 0; i < s.length; i++) view[i] = s.charCodeAt(i) & 0xFF;
                return buf;
            }
    
            var blob = new Blob([s2ab(wbout)], {type: "application/octet-stream"});
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = fileName + '.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } catch (error) {
            console.log('에러 내역 알려주세요 ::: ' + error);
        }
    },

})