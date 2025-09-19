({
    gfnDoinit : function(component, event) {
        console.log(`${component.getName()}.gfnDoinit : `);
        let recordId = component.get('v.recordId');
        // component.set('v.isLoading', true);
        let self = this;
        this.apexCall(component, event, this, 'doDownloadQuote', {recordId})
               .then($A.getCallback(function(result) {

            let { r, state } = result;
            component.set('v.progressValue', '30');
            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {
                self.gfnExcelDownload(component, r.quote);
            }
            if(r.status.code === 500 ) {
                self.toast('warning', '엑셀 다운로드시에 에러가 발생하였습니다. 관리자한테 문의해주세요. ');
            }
            
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            
        });
    },
        
    gfnExcelDownload : function(component, quote) {
        console.log(`${component.getName()}.gfnExcelDownload()`)
        component.set('v.progressValue', '40');
        let excelName = `${quote.dealerName}_${quote.seq}_견적서`;
        // if(excelData.length === 0) {
        //     this.toast('Error', 'Excel data is empty.');
        //     return;
        // }
        let workbook = new ExcelJS.Workbook();
        let worksheet = workbook.addWorksheet(excelName);
        
        // 1. Header Section
        //B2 ~ I2
        for(let columnIdx = 2; columnIdx <= 9 ; columnIdx++) {
            worksheet.getCell(2,columnIdx).border = {
                top: {style:'thick'},            
            };
        }
        
        worksheet.mergeCells('D3:G3');
        worksheet.getCell('G3').value = '견적서';
        worksheet.getCell('G3').alignment = { vertical: 'middle', horizontal: 'center' };
        
        // 2. 내용
        //헤더
        //헤더 - 첫번째 열
        worksheet.getCell('B5').value = '고객사명'; 
        worksheet.mergeCells('C5:E5');
        worksheet.getCell('C5').value = quote.customerName;

        worksheet.getCell('B6').value = '기종 / 호기'; 
        worksheet.mergeCells('C6:E6');
        worksheet.getCell('C6').value = ((quote.machineName) ? quote.machineName : '') + ' / ' + ((quote.equipment) ? quote.equipment : '');

        worksheet.getCell('B7').value = '견적내용'; 
        worksheet.mergeCells('C7:E7');
        worksheet.getCell('C7').value = quote.description;


        //헤더 - 두번째 열
        worksheet.getCell('F5').value = '발행일자'; 
        worksheet.mergeCells('G5:I5');
        worksheet.getCell('G5').value = quote.publishDate;

        worksheet.getCell('F6').value = '발행자'; 
        worksheet.mergeCells('G6:I6');
        worksheet.getCell('G6').value = quote.dealerName;
        
        worksheet.getCell('F7').value = '발행번호'; 
        worksheet.mergeCells('G7:I7');
        worksheet.getCell('G7').value = quote.seq;

        //B5 ~ B7
        for(let rowIdx = 5; rowIdx <= 7; rowIdx++) {
            worksheet.getRow(rowIdx).eachCell({ includeEmpty: true }, (cell, colNumber) => {
                if(colNumber > 1) {
                    // cell.font = { bold: true };
                    cell.alignment = { horizontal: 'center' };
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' }
                    };
                }
            });
        }

        //품목
        //
        worksheet.getCell('B9').value = '순번';
        worksheet.getCell('C9').value = '품번';
        worksheet.mergeCells('C9:D9');
        worksheet.getCell('E9') .value = '품명';
        worksheet.mergeCells('E9:F9');
        worksheet.getCell('G9').value = '수량';
        worksheet.getCell('H9').value = '단가';
        worksheet.getCell('I9').value = '금액';
        let itemHeaderIdx = 9;
        
        quote.itemList.forEach((item, idx)=>{
            let startRow = itemHeaderIdx + idx +1;

            //B10 ~
            worksheet.getCell(startRow, 2).value = item.itemSeq;
            worksheet.getCell(startRow, 3).value = item.replacingPartName;
            worksheet.mergeCells(startRow, 3, startRow, 4);
            worksheet.getCell(startRow, 5).value = item.replacingPartDetails;
            worksheet.mergeCells(startRow, 5, startRow, 6);
            worksheet.getCell(startRow, 7).value = item.quantity;
            worksheet.getCell(startRow, 7).numFmt = '#,##0';
            worksheet.getCell(startRow, 8).value = item.discountPrice;
            worksheet.getCell(startRow, 8).numFmt = '#,##0';
            worksheet.getCell(startRow, 9).value = item.discountAmount;
            worksheet.getCell(startRow, 9).numFmt = '#,##0';
        });

        //B9 ~ B+
        let lastRowIdx = itemHeaderIdx + quote.itemList.length;
        for(let rowIdx = itemHeaderIdx; rowIdx <= lastRowIdx; rowIdx++) {
            worksheet.getRow(rowIdx).eachCell({ includeEmpty: true }, (cell, colNumber) => {
                if(colNumber > 1) {
                    
                    //colNumber 7이상 부터 숫자(수량 및 금액)
                    if(rowIdx != 9 && colNumber >=7)
                        cell.alignment = { horizontal: 'right' };
                    else 
                        cell.alignment = { horizontal: 'center' };

                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' }
                    };
                }
            });
        }

        //합계
        worksheet.getCell(lastRowIdx+1, 8).value = '합계';
        worksheet.getCell(lastRowIdx+1, 8).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(lastRowIdx+1, 8).alignment = { horizontal: 'center' };
        worksheet.getCell(lastRowIdx+1, 9).value = quote.itemList.reduce((acc, cur) => 
            acc + cur.discountAmount, 0);
        worksheet.getCell(lastRowIdx+1, 9).alignment = { horizontal: 'right' };
        worksheet.getCell(lastRowIdx+1, 9).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(lastRowIdx+1, 9).numFmt = '#,##0';

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

        // 3. Footer Section
        let footerStartIdx = lastRowIdx+1 + 3;
        
        worksheet.getCell(footerStartIdx, 2).value = '※ 상기 견적사항은 실제 작업 전에 임의로 작성된 것이기 때문에 이 외 추가사항 혹은 변경사항이 발생할 수 있으며,';
        worksheet.mergeCells(footerStartIdx, 2, footerStartIdx, 9);
        worksheet.getCell(footerStartIdx, 2).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(footerStartIdx + 1, 2).value = ' 이 경우 위 견적 내용 및 금액은 변경될 수 있음을 유의하시기 바랍니다.';
        worksheet.mergeCells(footerStartIdx + 1, 2, footerStartIdx +1, 9);
        worksheet.getCell(footerStartIdx + 1, 2).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(footerStartIdx + 2, 2).value = '※ 본 견적서는 발행일로부터 3개월간 유효합니다.'
        worksheet.mergeCells(footerStartIdx + 2, 2, footerStartIdx + 2, 9);
        worksheet.getCell(footerStartIdx + 2, 2).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(footerStartIdx + 3, 2).value = ` ${quote.dealerName}, ${ (quote.address) ? quote.address : ''} ${ (quote.postalCode) ? quote.postalCode : ''}`; // 대리점명, 주소
        worksheet.mergeCells(footerStartIdx + 3, 2, footerStartIdx + 3, 9);
        worksheet.getCell(footerStartIdx + 3, 2).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(footerStartIdx + 4, 2).value = ' Tel : '+ ((quote.phone) ? quote.phone: ''); // 대리점 폰정보
        worksheet.mergeCells(footerStartIdx + 4, 2, footerStartIdx + 4, 9);
        worksheet.getCell(footerStartIdx + 4, 2).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(footerStartIdx + 5, 2).value = ' Fax : '+((quote.fax) ? quote.fax: ''); // 대리점 Fax정보
        worksheet.mergeCells(footerStartIdx + 5, 2, footerStartIdx + 5, 9);
        worksheet.getCell(footerStartIdx + 5, 2).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell(footerStartIdx + 6, 2).value = ' '+quote.dealerName + ' (인) ';
        worksheet.mergeCells(footerStartIdx + 6, 2, footerStartIdx + 6, 9);
        worksheet.getCell(footerStartIdx + 6, 2).border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        for(let rowIdx = 2; rowIdx <= footerStartIdx + 6; rowIdx++ ) {
            let rowCells = worksheet.getRow(rowIdx);
            
            if(!rowCells.getCell(2).border) {
                rowCells.getCell(2).border = {
                    left: {style:'thick'},    
                };
            }else {
                if(rowCells.getCell(2).border.left && rowCells.getCell(2).border.left.style)
                    rowCells.getCell(2).border.left.style = 'thick';
                else
                    rowCells.getCell(2).border.left = {style:'thick'};  
                
            }   

            if(!rowCells.getCell(9).border) {
                rowCells.getCell(9).border = {
                    right: {style:'thick'},    
                };
            }else {
                if(rowCells.getCell(9).border.right && rowCells.getCell(9).border.right.style)
                    rowCells.getCell(9).border.right.style = 'thick';
                else 
                    rowCells.getCell(9).border.right = {style:'thick'};  
            }
            
        }

        
        worksheet.getCell(footerStartIdx + 6,2).border = {
            bottom: {style:'thick'},        
            left: {style:'thick'},        
            right: {style:'thick'},        
        };
        

        // Export file
        workbook.xlsx.writeBuffer().then(function (buffer) {
            var blob = new Blob([buffer], { type: 'application/octet-stream' });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = excelName + '.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            component.set('v.progressValue', '100');
            component.find("overlayLib").notifyClose();
        });
    }
})