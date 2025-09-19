// export function createSheet1(sheet, language, data, tableMap){
export function createSheet1(sheet, data, tableMap, logo, ppt01, ppt02){
// export function createSheet1(sheet, data, tableMap){

    // common style
    for (let i = 1; i <= 33; i++) { // A(1) ~ AG(33)
        sheet.getColumn(i).width = 3;
    }
    sheet.pageSetup.fitToPage = true;
    sheet.pageSetup.fitToWidth = 1;
    sheet.pageSetup.fitToHeight = 0;

    // font
    const fontCommon = { size: 10 };
    const fontTitle  = { bold: true, size: 18 };

    // alignment
    const aligRight  = { vertical: 'middle', horizontal: 'right' };
    const aligLeft   = { vertical: 'middle', horizontal: 'left' };
    const aligCenter = { vertical: 'middle', horizontal: 'center' };

    const aligLeftWrap01   = { wrapText: true, vertical: 'middle', horizontal: 'left' };
    const aligLeftWrap02   = { wrapText: true, vertical: 'top', horizontal: 'left' };
    const aligCenterWrap = { wrapText: true, vertical: 'middle', horizontal: 'center' };

    // border
    const borderTitle = { bottom: { style: 'double' } };
    const borderData  = { bottom: { style: 'thin' } };
    const borderDesc  = { bottom: { style: 'dotted' } };

    // fill
    const fillTable = {type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD9D9D9' }};
    const fillDesc  = {fgColor: { argb: 'FFD9D9D9' }};

    // height
    const heightBlank01 = 15;
    const heightBlank02 = 10;
    const heightTable = 27;
    const heightDesc = 38;

    // header
    const headerStart = 1;
    const AGFirstCell = sheet.getCell(`AG${headerStart}`);
    AGFirstCell.value = 'Rev. V1. 20250224';
    AGFirstCell.style = { font : fontCommon, alignment : aligRight};

    sheet.getRow(headerStart+1).height = heightBlank01;
    sheet.getRow(headerStart+2).height = heightBlank01;
    
    sheet.getCell(`A${headerStart+3}`).value = '수신 : CS본부 Field Engineering팀장';
    sheet.getCell(`A${headerStart+3}`).style = { font : fontCommon, alignment : aligLeft};
    sheet.getCell(`A${headerStart+4}`).value = '참조 : 지역별 파트장 및 설치 배정 담당자';
    sheet.getCell(`A${headerStart+4}`).style = { font : fontCommon, alignment : aligLeft};
    sheet.getRow(headerStart+5).height = heightBlank01;
    sheet.getRow(headerStart+6).height = heightBlank01;

    sheet.addImage(logo, `AD${headerStart+3}:AG${headerStart+4}`);

    // title
    const titleStart = 8;
    sheet.getCell(`H${titleStart}`).value = '설치시운전 고객사 사전설치 점검표';
    sheet.getCell(`H${titleStart}`).style = { font : fontTitle, alignment: aligCenter, border: borderTitle};
    sheet.mergeCells(`H${titleStart}:Z${titleStart}`);
    sheet.getRow(titleStart+1).height = heightBlank01;
    sheet.getRow(titleStart+2).height = heightBlank01;

    // data section
    const dataStart = 11;
    const cleanedAddress = data.F_Address__c.replace(/\s+/g, ' ').trim();

    sheet.getCell(`A${dataStart}`).value = `고객사 : ${data.F_AccountName__c}`;
    sheet.getCell(`U${dataStart}`).value = `설치요청일 : ${data.PreferredInstallationDate__c}`;
    sheet.getCell(`A${dataStart+1}`).value = `고객사 담당자/소속 : ${data.F_ContactPersonName__c} / ${data.F_AccountName__c}`;
    sheet.getCell(`U${dataStart+1}`).value = `전화번호 : ${data.F_ContactPersonPhone__c ?? ''}`;
    sheet.getCell(`A${dataStart+2}`).value = `영업 담당자/소속 : ${data.F_SalesRepsName__c} / ${data.F_SalesRepBName__c}`;
    sheet.getCell(`U${dataStart+2}`).value = `전화번호 : ${data.F_SalesRepsPhone__c ?? ''}`;
    sheet.getCell(`A${dataStart+3}`).value = `고객사 주소 : ${cleanedAddress}`;
    sheet.getCell(`A${dataStart+4}`).value = `설치 설비명/대수 : ${data.F_ModelNumber__c} / 1대`;

    const sRow = dataStart, eRow = dataStart+4, sCol = 1, eCol = 33;
    for (let thisRow = sRow; thisRow <= eRow; thisRow++) {
        for (let thisCol = sCol; thisCol <= eCol; thisCol++) {
            
            if (thisRow < 14 && thisCol === 20) continue;

            const cell = sheet.getCell(thisRow, thisCol);
            cell.style = {border: borderData, font : fontCommon};
        }
    }
    sheet.getRow(dataStart+5).height = heightBlank01;
    sheet.getRow(dataStart+6).height = heightBlank01;

    // table header section
    const theadStart = 18;

    sheet.getRow(theadStart).height = 30;
    sheet.getCell(`A${theadStart}`).value = '항목';
    sheet.getCell(`F${theadStart}`).value = '설치시운전 고객사 준비사항';
    sheet.getCell(`V${theadStart}`).value = '예정일';
    sheet.getCell(`Y${theadStart}`).value = '완료일';
    sheet.getCell(`AB${theadStart}`).value = '영업확인';
    sheet.getCell(`AE${theadStart}`).value = '고객확인';
    sheet.mergeCells(`A${theadStart}:E${theadStart}`);
    sheet.mergeCells(`F${theadStart}:U${theadStart}`);
    sheet.mergeCells(`V${theadStart}:X${theadStart}`);
    sheet.mergeCells(`Y${theadStart}:AA${theadStart}`);
    sheet.mergeCells(`AB${theadStart}:AD${theadStart}`);
    sheet.mergeCells(`AE${theadStart}:AG${theadStart}`);

    const sTHCol = 1, eTHCol = 33;
    for (let thisCol = sTHCol; thisCol <= eTHCol; thisCol++) {
        const cell = sheet.getCell(theadStart, thisCol);
        cell.style.fill      = fillTable;
        cell.style.font      = fontCommon;
        cell.style.alignment = aligCenter;
        cell.style.border    = {
            top: { style: 'medium' }
            , left: { style: thisCol == 5 ? 'medium' : 'thin' }
            , bottom: { style: 'double' }
            , right: { style: thisCol == eTHCol ? 'medium' : 'thin' }
        };
    }

    // table body section
    let tbodyStart = 19;
    const tBodyEnd = 29;
    const tBodyEndMerge = 26;

    Object.keys(tableMap).forEach((section) => {
        const items = tableMap[section];

        let desc = section;
        if(section == '기초공사') desc = section + '¹⁾';

        const sectionCell = sheet.getCell(`A${tbodyStart}`);
        sectionCell.value = desc;
        sectionCell.style.font = fontCommon;
        sectionCell.style.alignment = aligCenter;
        sectionCell.style.border = {
            left     : {style: 'medium'}
            , bottom : {style: tbodyStart == tBodyEndMerge ? 'medium' : 'thin'}
            , right  : {style: 'thin'}
        };
        sheet.mergeCells(`A${tbodyStart}:E${tbodyStart + items.length - 1}`);

        items.forEach(item => {
            let content = item.content;
            if([1,2].includes(item.contentNo)) { content += '¹⁾'; }
            else if(item.contentNo == 6) { content += '²⁾'; }
            else if(item.contentNo == 11) { content += '³⁾'; }

            const contentCell = sheet.getCell(`F${tbodyStart}`);
            contentCell.value = content;
            contentCell.style.font = fontCommon;
            contentCell.style.alignment = aligLeftWrap01;
            contentCell.style.border = {right: {style: 'thin'}, bottom: {style: tbodyStart == tBodyEnd ? 'medium' : 'thin'}};
            sheet.mergeCells(`F${tbodyStart}:U${tbodyStart}`);

            const dCellBorder = {bottom : {style : tbodyStart == tBodyEnd ? 'medium' : 'thin'}};
            const dCellBorderLast = {right: {style: 'thin'}, bottom : {style : tbodyStart == tBodyEnd ? 'medium' : 'thin'}};

            // 예정일
            const plannedCellV = sheet.getCell(`V${tbodyStart}`);
            plannedCellV.value = item.planned != null ? item.planned : '';
            plannedCellV.style = {alignment : aligLeft, border : dCellBorder, font : fontCommon};
            
            const plannedCellW = sheet.getCell(`W${tbodyStart}`);
            plannedCellW.style.border = dCellBorder;
            
            const plannedCellX = sheet.getCell(`X${tbodyStart}`);
            plannedCellX.style.border = dCellBorderLast;

            // 완료일
            const completedCellY = sheet.getCell(`Y${tbodyStart}`);
            completedCellY.value = item.completed != null ? item.completed : '';
            completedCellY.style = {alignment : aligLeft, border : dCellBorder, font : fontCommon };

            const completedCellZ = sheet.getCell(`Z${tbodyStart}`);
            completedCellZ.style.border = dCellBorder;

            const completedCellAA = sheet.getCell(`AA${tbodyStart}`);
            completedCellAA.style.border = dCellBorderLast;

            // 영업확인
            const salesCheckCellAB = sheet.getCell(`AB${tbodyStart}`);
            salesCheckCellAB.value = item.salesCheck != null ? item.salesCheck : '';
            salesCheckCellAB.style = {alignment : aligLeft, border : dCellBorder, font : fontCommon };

            const salesCheckCellAC = sheet.getCell(`AC${tbodyStart}`);
            salesCheckCellAC.style.border = dCellBorder;

            const salesCheckCellAD = sheet.getCell(`AD${tbodyStart}`);
            salesCheckCellAD.style.border = dCellBorderLast;

            // 고객 확인
            const customerCheckCellAE = sheet.getCell(`AE${tbodyStart}`);
            customerCheckCellAE.value = item.customerCheck != null ? item.customerCheck : '';
            customerCheckCellAE.style = {alignment : aligLeft, border : dCellBorder, font : fontCommon };

            const customerCheckCellAF = sheet.getCell(`AF${tbodyStart}`);
            customerCheckCellAF.style.border = dCellBorder;

            const customerCheckCellAG = sheet.getCell(`AG${tbodyStart}`);
            customerCheckCellAG.style.border = {
                right: {style: 'medium'}
                , bottom : {style : tbodyStart == tBodyEnd ? 'medium' : 'thin'}
            };

            sheet.getRow(tbodyStart).height = heightTable;
            tbodyStart++;
        });
    });

    // etc
    const etcStart = 30;
    sheet.getRow(etcStart).height = heightBlank02;
    
    sheet.mergeCells(`A${etcStart+1}:AG${etcStart+1}`);
    const desc01 = sheet.getCell(`A${etcStart+1}`);
    desc01.value = '1) 기초공사 시방서 및 기초도면은 설비 계약시 또는 계약후 1주일 이내에 고객사에 직접 전달하고, 정상적으로 진행하지 않을 경우에 대한 발생 문제점에 대해서 내용 설명합니다.';
    desc01.style = { font : fontCommon, alignment : aligLeftWrap02 };
    sheet.getRow(etcStart+1).height = heightDesc;

    sheet.mergeCells(`A${etcStart+2}:AG${etcStart+2}`);
    const desc02 = sheet.getCell(`A${etcStart+2}`);
    desc02.value = '2) 설비 정밀도 유지를 위한 온도 변화 조건은 24시간에 ±2℃ 이하(30분에 1℃ 이하), 바닥에서 약 5미터 높이까지의 온도 차이가 1℃ 이하로 이상적인 온도는 20℃ ±1℃ 에 대해서 내용 설명합니다.(직사광선 유입 차단)';
    desc02.style = { font : fontCommon, alignment : aligLeftWrap02 };
    sheet.getRow(etcStart+2).height = heightDesc;

    sheet.mergeCells(`A${etcStart+3}:AG${etcStart+3}`);
    const desc03 = sheet.getCell(`A${etcStart+3}`);
    desc03.value = '3) 세미신세틱/신세틱 절삭유 사용 시 발생할 문제점에 대해서 설명합니다.';
    desc03.style = { font : fontCommon, alignment : aligLeftWrap02 };
    sheet.getRow(etcStart+3).height = heightDesc;

    const desc04 = sheet.getCell(`A${etcStart+4}`);
    desc04.value = '특기사항 :';
    desc04.style = { font : fontCommon, alignment : aligLeft };
    // sheet.getRow(etcStart+4).height = heightBlank01;

    const descRowStart = etcStart+4, descRowEnd = etcStart+8, descColStart = 1, descColEnd = 33;
    for (let thisRow = descRowStart; thisRow <= descRowEnd; thisRow++) {
        for (let thisCol = descColStart; thisCol <= descColEnd; thisCol++) {
            const cell = sheet.getCell(thisRow, thisCol);
            cell.style = {border: borderDesc, font : fontCommon};
        }
    }

    sheet.getRow(etcStart+9).height = heightBlank02;

    const desc05 = sheet.getCell(`A${etcStart+10}`);
    desc05.value = 'Note 1) 설비 출하 3일 전까지 고객사 준비사항 점검 후 수신/참조인에게 email 발송합니다.';
    // desc05.style = { font : fontCommon, alignment : aligLeft};
    sheet.getRow(etcStart+10).height = heightBlank01;

    const desc06 = sheet.getCell(`A${etcStart+11}`);
    desc06.value = 'Note 2) 준비 사항 미흡으로 인해 설치 지연 시 설치 비용이 발생할 수 있습니다.';
    // desc06.style = { font : fontCommon, alignment : aligLeft};
    sheet.getRow(etcStart+11).height = heightBlank01;

    const descRowStart0 = etcStart+10, descRowEnd0 = etcStart+11, descColStart0 = 1, descColEnd0 = 33;
    for (let thisRow = descRowStart0; thisRow <= descRowEnd0; thisRow++) {
        for (let thisCol = descColStart0; thisCol <= descColEnd0; thisCol++) {
            const cell = sheet.getCell(thisRow, thisCol);
            cell.style = {font : fontCommon, alignment : aligLeft, fill : fillTable};
        }
    }

    sheet.getRow(etcStart+12).height = heightBlank01;

    // image
    const imageStart01 = 43;
    sheet.addImage(ppt01, `A${imageStart01}:AG${imageStart01+25}`);

    const imageStart02 = 70;
    sheet.addImage(ppt02, `A${imageStart02}:AG${imageStart02+25}`);

}

export function createSheet2(workbook, sheet, image){
    let rowStart = 0; // 시작 행을 0으로 설정
    for (let base64Image of image) {
        
        const img = workbook.addImage({
            base64: base64Image,
            extension: 'jpeg',
        });
        
        // 각 이미지의 위치를 다르게 설정
        sheet.addImage(img, {
            tl: { col: 0, row: rowStart },
            ext: { width: 500, height: 300 }
        });

        rowStart += 20; // 각 이미지 사이에 여백 추가
    }
}