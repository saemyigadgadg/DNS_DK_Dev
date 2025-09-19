({
    handleScriptsLoaded: function (component, event, helper) {
        console.log('ExcelJS library loaded.');
        component.set("v.libInitialized", true);
    },

    handleExcel: function (component, event, helper) {
        var excelJsLoaded = component.get('v.libInitialized');
        if (!excelJsLoaded) {
            console.error('ExcelJS is not loaded');
            return;
        }
        
        var excelData = component.get('v.excelData');
        var excelHeaderData = component.get('v.headerData');
        var excelName = component.get('v.excelName');

        var workbook = new ExcelJS.Workbook();
        var worksheet = workbook.addWorksheet('Sheet1');
        
        // 1. Header Section
        worksheet.getCell('A1').value = 'Header';
        worksheet.getCell('A1').font = { bold: true, size: 14 };
        
        // Header table structure (based on image)
        let firstRecord = excelHeaderData[0];
        const headerColumns = Object.keys(firstRecord);//['정산월', '무상서비스', '설치시운전', '납품후교육', '업무대행', '합계'];
        worksheet.getRow(2).values = headerColumns;
        // Style header table
        worksheet.getRow(2).eachCell((cell) => {
            cell.font = { bold: true };
            cell.alignment = { horizontal: 'center' };
            cell.border = {
                top: { style: 'thin' },
                left: { style: 'thin' },
                bottom: { style: 'thin' },
                right: { style: 'thin' }
            };
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'F2F2F2' }
            };
        });
        console.log('1111111');
        // Add header data row
        let headerDataStart = 3;
        if (excelHeaderData && excelHeaderData.length > 0) {
            for(let i=0; i<excelHeaderData.length; i++) {
                let headerdata =excelHeaderData[i];
                let startRow = headerDataStart+i;
                let dataList = [];
                for(let j=0; j<headerColumns.length; j++) {
                    dataList.push(headerdata[headerColumns[j]]);
                }
                worksheet.getRow(startRow).values = dataList
                //headerDataEnd =startRow;
            }
        }
        let headerDataEnd = headerDataStart +excelHeaderData.length +1;
        

        // 2. Item Section
        worksheet.getCell(`A${headerDataEnd}`).value = 'Item';
        worksheet.getCell(`A${headerDataEnd}`).font = { bold: true, size: 14 };

        let itemDataStart =headerDataEnd+1;
        // // Item table headers (based on image)
        let itemCol =excelData[0];
        const itemColumns = Object.keys(itemCol);/*[
            '오더유형','오더번호',	
            '고객명','기종',	
            '호기','접수일',
            '확정일','업체명',
            '작업배정','작업자',
            '작업내용','시작일',
            '시작시간','종료일',
            '종료시간',	'작업유형',
            '메인','가설치',
            '옵션',	'기타',	
            '합계시간','할증여부',
            '작업합계','표준공수',
            '지급공수',	'금액'];*/
        worksheet.getRow(itemDataStart).values = itemColumns;
        worksheet.getRow(itemDataStart).eachCell((cell) => {
            cell.font = { bold: true };
            cell.alignment = { horizontal: 'center' };
            cell.border = {
                top: { style: 'thin' },
                left: { style: 'thin' },
                bottom: { style: 'thin' },
                right: { style: 'thin' }
            };
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'F2F2F2' }
            };
        });
        itemDataStart = itemDataStart +1;
        // 데이터
        if (excelData && excelData.length > 0) {
            for(let i=0; i<excelData.length; i++) {
                let excelDataRow =excelData[i];
                let startRow = itemDataStart+i;
                let dataList = [];
                for(let j=0; j<itemColumns.length; j++) {
                    dataList.push(excelDataRow[itemColumns[j]]);
                }
                worksheet.getRow(startRow).values = dataList    
            }
        }
        
        // Adjust column widths
        worksheet.columns.forEach((column) => {
            let maxLength = 0;
            column.eachCell({ includeEmpty: true }, (cell) => {
                if (cell.value) {
                    maxLength = Math.max(maxLength, cell.value.toString().length);
                }
            });
            column.width = Math.max(maxLength + 2, 15);
        });

        // Export file
        workbook.xlsx.writeBuffer().then(function (buffer) {
            var blob = new Blob([buffer], { type: 'application/octet-stream' });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = excelName + '.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
    }
})