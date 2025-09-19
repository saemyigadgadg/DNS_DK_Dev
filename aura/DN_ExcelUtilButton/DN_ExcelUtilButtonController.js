/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 03-17-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-02   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    handleScriptsLoaded : function(component, event, helper) {
        console.log('ExcelJS library loaded.');
        component.set("v.libInitialized", true);
    },
    
    handleExcel : function(component, event, helper) {
        var excelJsLoaded = component.get('v.libInitialized');
        if(!excelJsLoaded) {
            console.error('ExcelJS is not loaded');
            return;
        }

        var excelData       = component.get('v.excelData');
        console.log("🚀 ~ excelData:", excelData)
        if(excelData.length === 0) {
            helper.toast('Error', 'Excel data is empty.');
            return;
        }
        var excelHeaderData = component.get('v.headerData');
        var excelName       = component.get('v.excelName');

        var workbook    = new ExcelJS.Workbook();
        var worksheet   = workbook.addWorksheet('Sheet1');

        if(excelHeaderData.length === 0) {
            var firstRecord = excelData[0];
            var columns     = Object.keys(firstRecord).map(function(key) {
                return { header: key.charAt(0).toUpperCase() + key.slice(1), key: key };
            });
            worksheet.columns = columns;
    
            excelData.forEach(function(record) {
                worksheet.addRow(record);
            });
        }

        worksheet.columns.forEach(function(column) {
            var maxLength       = 6;
            var headerCell      = worksheet.getCell(1, column.number);
            var headerLength    = headerCell.value ? headerCell.value.toString().length : 0;

            maxLength           = Math.max(maxLength, headerLength);

            worksheet.eachRow({ includeEmpty: true }, function(row) {
                var cell        = row.getCell(column.key);
                var cellValue   = cell.value;

                if (typeof cellValue === 'string' && cellValue.match(/^\d{4}-\d{2}-\d{2}$/)) {
                    var dateParts = cellValue.split('-');
                    var formattedDate = `${dateParts[0]}. ${dateParts[1]}. ${dateParts[2]}`;

                    cell.value = formattedDate;
                } else if (typeof cellValue === 'string' && cellValue.match(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/)) {
                    maxLength = Math.max(maxLength, cellValue.length + 6);

                } else if (typeof cellValue === 'string') {
                    maxLength = Math.max(maxLength, cellValue.length + 2);

                } else if (typeof cellValue === 'number') {
                    maxLength = Math.max(maxLength, String(cellValue).length);
                    cell.numFmt = "#,##0";
                
                }

            });

            column.width = maxLength + 2;

            headerCell.font         = { bold        : true };
            headerCell.alignment    = { vertical    : 'middle',     horizontal  : 'center' };
            headerCell.fill         = { type        : 'pattern',    pattern     : 'solid',  fgColor: { argb: 'D3D3D3' } };
        });

        worksheet.eachRow({ includeEmpty: false }, function(row, rowNumber) {
            row.eachCell({ includeEmpty: false }, function(cell, colNumber) {
                cell.border = {
                    top     : { style: 'thin' },
                    left    : { style: 'thin' },
                    bottom  : { style: 'thin' },
                    right   : { style: 'thin' }
                };
            });
        });

        workbook.xlsx.writeBuffer().then(function(buffer) {
            var blob        = new Blob([buffer], { type: 'application/octet-stream' });
            var link        = document.createElement('a');
            link.href       = URL.createObjectURL(blob);
            link.download   = excelName + '.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
    }
})