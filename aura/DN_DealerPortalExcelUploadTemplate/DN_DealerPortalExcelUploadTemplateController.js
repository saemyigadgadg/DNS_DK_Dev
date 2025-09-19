({
    doInit: function (component, event, helper) {
        console.log(component.get('v.uploadName'),' 11111');
        helper.apexCall(component,event,this, 'getTemplate', {
            uploadName : component.get('v.uploadName')
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result.r), ' :::::RRRR');
            component.set('v.uploadTemplate',result.r);
        })).catch(function(error) {
            helper.toast('error', error[0].message);
            console.log('# addError error : ' + error.message);
        }).finally(function () {

        });
        
    },
    handleTemplate : function(component, event, helper) {
        let uploadTemplate = component.get('v.uploadTemplate');
        let workbook    = new ExcelJS.Workbook();
        let worksheet   = workbook.addWorksheet(uploadTemplate.tabName);
        let columns     = [];
        
        uploadTemplate.columnList.forEach(element => {
            columns.push({
                header : element.columnLabel,
                key : element.columnLabel
            })
        });
        worksheet.columns = columns;
        console.log('test111');
        worksheet.columns.forEach(function(column) {
            var maxLength       = 6;
            var headerCell      = worksheet.getCell(1, column.number);
            var headerLength    = headerCell.value ? headerCell.value.toString().length : 0;

            maxLength           = Math.max(maxLength, headerLength);

            worksheet.eachRow({ includeEmpty: true }, function(row) {
                var cell        = row.getCell(column.key);
                var cellValue   = cell.value;
                if (typeof cellValue === 'string' && cellValue.match(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/)) {
                    maxLength = Math.max(maxLength, cellValue.length + 6);
                } else if (typeof cellValue === 'string') {
                    maxLength = Math.max(maxLength, cellValue.length + 2);
                } else if (typeof cellValue === 'number') {
                    maxLength = Math.max(maxLength, String(cellValue).length);
                }
            });

            column.width = maxLength + 2;

            headerCell.font         = { bold        : true };
            headerCell.alignment    = { vertical    : 'middle',     horizontal  : 'center' };
            headerCell.fill         = { type        : 'pattern',    pattern     : 'solid',  fgColor: { argb: 'D3D3D3' } };
        });
        console.log('test2222');
        worksheet.eachRow({ includeEmpty: false }, function(row, rowNumber) {
            row.eachCell({ includeEmpty: false }, function(cell, colNumber) {
                // 셀 테두리 스타일 적용
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' }
                };
        
                // 셀 값이 문자열이고 '*' 포함 시 글자색 빨간색 적용
                if (typeof cell.value === 'string' && cell.value.includes('*')) {
                    cell.font = { color: { argb: 'FF0000' } ,bold        : true};
                }
            });
        });
        console.log('test3333');
        workbook.xlsx.writeBuffer().then(function(buffer) {
            var blob        = new Blob([buffer], { type: 'application/octet-stream' });
            var link        = document.createElement('a');
            link.href       = URL.createObjectURL(blob);
            link.download   = uploadTemplate.fileName + '.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
    },

    handleScriptsLoaded : function(component, event, helper) {
        console.log('ExcelJS library loaded.');
        component.set('v.isExcelJsLoading', true);
    },
})