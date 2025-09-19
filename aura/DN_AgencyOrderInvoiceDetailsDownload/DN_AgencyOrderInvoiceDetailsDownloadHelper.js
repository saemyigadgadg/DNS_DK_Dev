({
    gfnDoinit : function(component, event) {
        console.log('gfnDoinit ::');
        let self = this;
        this.apexCall(component, event, this, 'detailInit', {
            recordId: component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {

            let { r, state } = result;
            console.log('detailInit.r : ',  r);
            console.log('detailInit.state : ',  state);
            if(r.status.code === 200 ) {
                self.gfnExcelDownload(component, r.order, r.orderDealer);
            }
            // component.set('v.isSpinner', false);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            // component.set('v.isSpinner', false);
        });
    },

    gfnExcelDownload : function(component, order, dealer) {
        console.log(`${component.getName()}.gfnExcelDownload()`)
        component.set('v.progressValue', '40');
        let excelName = `${order.dealerName}_${order.seq}_거래명세서`;
        // if(excelData.length === 0) {
        //     this.toast('Error', 'Excel data is empty.');
        //     return;
        // }
        let workbook = new ExcelJS.Workbook();
        let worksheet = workbook.addWorksheet(excelName);
        
        // 1. Header Section
        //A1 ~ C3
        worksheet.mergeCells('A1:C1');
        worksheet.getCell('C1').value = '권';
        worksheet.getCell('C1').alignment = { vertical: 'middle', horizontal: 'right' };
        worksheet.getCell('C1').border = {
                            top: { style: 'thick' },
                            left: { style: 'thick' },
                            bottom: { style: 'thin' },
                            right: { style: 'thin' }
        };
        //D1 ~ E1
        worksheet.mergeCells('D1:E1');
        worksheet.getCell('E1').value = '호';
        worksheet.getCell('E1').alignment = { vertical: 'middle', horizontal: 'right' };
        worksheet.getCell('E1').border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        //F1 ~ L1
        worksheet.mergeCells('F1:L1');
        worksheet.getCell('L1').value = '거 래 명 세 서';
        worksheet.getCell('L1').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('L1').border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thick' }
        };
        
        // // 2. 내용
        // //헤더
        // //헤더 - 첫번째 열
        worksheet.mergeCells('A2:E2');
        let lastUpdateDataList = order.lastModifiedDate.split('-');
        worksheet.getCell('E2').value = `${lastUpdateDataList[0]}년 ${lastUpdateDataList[1]}월 ${lastUpdateDataList[2]}일`; //수정일
        // worksheet.getCell('E2').numFmt = 'yyyy"년" mm"월" dd"일"';
        worksheet.getCell('E2').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('E2').border = {
            top: { style: 'thick' },
            left: { style: 'thick' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.mergeCells('A3:E4');
        worksheet.getCell('E4').value = '귀하';
        worksheet.getCell('E4').alignment = { vertical: 'middle', horizontal: 'right' };
        worksheet.getCell('E4').border = {
            top: { style: 'thin' },
            left: { style: 'thick' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.mergeCells('A5:E5');
        worksheet.getCell('E5').value = '아래와 같이 계산합니다.';
        worksheet.getCell('E5').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('E5').border = {
            top: { style: 'thin' },
            left: { style: 'thick' },
            bottom: { style: 'thick' },
            right: { style: 'thick' }
        };

        //헤더 - 두번째 열
        worksheet.getCell('F2').value = '공';
        worksheet.getCell('F2').border = {
            top: { style: 'thick' },
            left: { style: 'thick' },
            right: { style: 'thick' }
        };
        worksheet.getCell('F3').value = '급';
        worksheet.getCell('F3').border = {
            left: { style: 'thick' },
            right: { style: 'thick' }
        };
        worksheet.getCell('F4').value = '자';
        worksheet.getCell('F4').border = {
            left: { style: 'thick' },
            right: { style: 'thick' }
        };

        worksheet.getCell('F5').border = {
            left: { style: 'thick' },
            bottom: { style: 'thick' },
            right: { style: 'thick' }
        };

        //헤더 - 세번째 열
        worksheet.getCell('G2').value = '등록번호';
        worksheet.getCell('G2').border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells('H2:L2');
        worksheet.getCell('L2').value = dealer.BusinessNumber__c;
        worksheet.getCell('L2').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('L2').border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thick' }
        };

        worksheet.getCell('G3').value = '상호';
        worksheet.getCell('G3').border = {
            left: { style: 'thick' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells('H3:I3');
        worksheet.getCell('I3').value = order.dealerName; //현재 접속한 사용자 Account 명
        worksheet.getCell('I3').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('I3').border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.getCell('J3').value = '성명';
        worksheet.getCell('J3').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells('K3:L3');
        worksheet.getCell('L3').value = dealer.Representative__c; //대표자
        worksheet.getCell('L3').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('L3').border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thick' }
        };

        worksheet.getCell('G4').value = '주소';
        worksheet.getCell('G4').border = {
            left: { style: 'thick' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells('H4:L4');
        worksheet.getCell('L4').value = order.dealerAddress; //주소
        worksheet.getCell('L4').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('L4').border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thick' }
        };

        worksheet.getCell('G5').value = '업태';
        worksheet.getCell('G5').border = {
            left: { style: 'thick' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells('H5:I5');
        worksheet.getCell('I5').value = dealer.TypeOfIndustry__c; // 업태 Label
        worksheet.getCell('I5').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('I5').border = {
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };

        worksheet.getCell('J5').value = '종목';
        worksheet.getCell('J5').border = {
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells('K5:L5');
        worksheet.getCell('L5').value = '';//dealer.TypeOfBusiness__c; // 종목 Label??
        worksheet.getCell('L5').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('L5').border = {
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thick' }
        };
        // //B5 ~ B7
        // for(let rowIdx = 5; rowIdx <= 7; rowIdx++) {
        //     worksheet.getRow(rowIdx).eachCell({ includeEmpty: true }, (cell, colNumber) => {
        //         if(colNumber > 1) {
        //             // cell.font = { bold: true };
        //             cell.alignment = { horizontal: 'center' };
        //             cell.border = {
        //                 top: { style: 'thin' },
        //                 left: { style: 'thin' },
        //                 bottom: { style: 'thin' },
        //                 right: { style: 'thin' }
        //             };
        //         }
        //     });
        // }

        worksheet.mergeCells('A6:D6');
        worksheet.getCell('D6').value = '합계금액';
        worksheet.getCell('D6').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('D6').border = {
            left: { style: 'thick' },
            bottom: { style: 'thick' },
            right: { style: 'thick' }
        };
        worksheet.mergeCells('E6:L6');
        worksheet.getCell('L6').value = ''; // 합계금액
        worksheet.getCell('L6').numFmt = '"₩"#,##0';
        worksheet.getCell('L6').alignment = { vertical: 'middle', horizontal: 'right' };
        worksheet.getCell('L6').border = {
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thick' }
        };

        //품목
        //품목 헤더
        worksheet.getCell('A7').value = '월/일';
        // worksheet.getCell('A7').numFmt = 'mm월/dd일';
        worksheet.getCell('A7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('A7').border = {
            left: { style: 'thick' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.mergeCells('B7:C7');
        worksheet.getCell('C7').value = '품번';
        worksheet.getCell('C7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('C7').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.mergeCells('D7:F7');
        worksheet.getCell('F7').value = '품목';
        worksheet.getCell('F7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('F7').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.mergeCells('G7:H7');
        worksheet.getCell('H7').value = '규격';
        worksheet.getCell('H7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('H7').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.getCell('I7').value = '수량';
        worksheet.getCell('I7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('I7').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.getCell('J7').value = '단가';
        worksheet.getCell('J7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('J7').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.getCell('K7').value = '공급가액';
        worksheet.getCell('K7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('K7').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };

        worksheet.getCell('L7').value = '세액';
        worksheet.getCell('L7').alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell('L7').border = {
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thick' }
        };

        //Item Data
        let itemHeaderIdx = 7;
        order.itemList.forEach((item, idx)=>{
            let startRow = itemHeaderIdx + idx +1;
            //B10 ~
            let orderDateList = order.orderDate.split('-');
            worksheet.getCell(startRow, 1).value = `${orderDateList[1]}/${orderDateList[2]} `;
            worksheet.getCell(startRow, 1).alignment = { vertical: 'middle', horizontal: 'center' };
            // worksheet.getCell(startRow, 1).numFmt = 'mm월 dd 일';
            worksheet.getCell(startRow, 2).value = item.replacingPartName;
            worksheet.mergeCells(startRow, 2, startRow, 3);
            worksheet.getCell(startRow, 4).value = item.replacingPartDetails;
            worksheet.mergeCells(startRow, 4, startRow, 6);
            worksheet.getCell(startRow, 7).value = item.replacingPartSpec;///규격
            worksheet.mergeCells(startRow, 7, startRow, 8);
            worksheet.getCell(startRow, 9).value = item.quantity;
            worksheet.getCell(startRow, 9).numFmt = '#,##0';
            worksheet.getCell(startRow, 10).value = item.customerPrice;
            worksheet.getCell(startRow, 10).numFmt = '"₩"#,##0';
            worksheet.getCell(startRow, 11).value = item.discountAmount;
            worksheet.getCell(startRow, 11).numFmt = '"₩"#,##0';
            worksheet.getCell(startRow, 12).value = item.discountAmount / 10; //세액
            worksheet.getCell(startRow, 12).numFmt = '"₩"#,##0';
        });

        //B9 ~ B+
        let lastRowIdx = itemHeaderIdx + order.itemList.length;
        for(let rowIdx = itemHeaderIdx + 1; rowIdx <= lastRowIdx; rowIdx++) {
            worksheet.getRow(rowIdx).eachCell({ includeEmpty: true }, (cell, colNumber) => {
                    
                //colNumber 7이상 부터 숫자(수량 및 금액)
                // if(rowIdx != 9 && colNumber >=9)
                //     cell.alignment = { horizontal: 'right' };
                // else 
                //     cell.alignment = { horizontal: 'center' };
                let borderLeftStyle = colNumber == 1 ? 'thick' : 'thin';
                let borderRightStyle = colNumber == 12 ? 'thick' : 'thin';

                cell.border = {
                    top: { style: 'thin' },
                    left: { style: borderLeftStyle },
                    bottom: { style: 'thin' },
                    right: { style: borderRightStyle}
                };
            });
        }

        //합계
        worksheet.getCell(lastRowIdx+1, 1).value = '전잔액';
        worksheet.mergeCells(lastRowIdx+1, 1, lastRowIdx+1, 8);
        worksheet.getCell(lastRowIdx+1, 8).border = {
            top: { style: 'thick' },
            left: { style: 'thick' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.getCell(lastRowIdx+1, 9).value = '합계';
        worksheet.getCell(lastRowIdx+1, 9).border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.getCell(lastRowIdx+1, 10).value = order.itemList.reduce((acc, cur) => 
            acc + cur.discountAmount, 0);
        worksheet.mergeCells(lastRowIdx+1, 10, lastRowIdx+1, 12);
        worksheet.getCell(lastRowIdx+1, 12).border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thick' }
        };
        worksheet.getCell(lastRowIdx+1, 10).numFmt = '"₩"#,##0';
        worksheet.getCell(lastRowIdx+2, 1).value = '입금';
        worksheet.getCell(lastRowIdx+2, 1).alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell(lastRowIdx+2, 1).border = {
            top: { style: 'thick' },
            left: { style: 'thick' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells(lastRowIdx+2, 2, lastRowIdx+2, 6);
        worksheet.getCell(lastRowIdx+2, 2).border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.getCell(lastRowIdx+2, 7).value = '잔금';
        worksheet.getCell(lastRowIdx+2, 7).alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell(lastRowIdx+2, 7).border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells(lastRowIdx+2, 8, lastRowIdx+2, 9);
        worksheet.getCell(lastRowIdx+2, 8).border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };

        worksheet.getCell(lastRowIdx+2, 10).value = '인수자';
        worksheet.getCell(lastRowIdx+2, 10).alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getCell(lastRowIdx+2, 10).border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thin' }
        };
        worksheet.mergeCells(lastRowIdx+2, 11, lastRowIdx+2, 12);
        worksheet.getCell(lastRowIdx+2, 11).value = '(인)';
        worksheet.getCell(lastRowIdx+2, 11).alignment = { vertical: 'middle', horizontal: 'right' };
        worksheet.getCell(lastRowIdx+2, 11).border = {
            top: { style: 'thick' },
            left: { style: 'thin' },
            bottom: { style: 'thick' },
            right: { style: 'thick' }
        };
        
        // // Adjust column widths
        // worksheet.columns.forEach((column) => {
        //     let maxLength = 0;
        //     column.eachCell({ includeEmpty: true }, (cell) => {
        //         if (cell.value) {
        //             maxLength = Math.max(maxLength, cell.value.toString().length);
        //         }
        //     });
        //     column.width = Math.max(maxLength + 2, 15);
        // });

        // // 3. Footer Section
        // let footerStartIdx = lastRowIdx+1 + 3;
        
        // worksheet.getCell(footerStartIdx, 2).value = '※ 상기 견적사항은 실제 작업 전에 임의로 작성된 것이기 때문에 이 외 추가사항 혹은 변경사항이 발생할 수 있으며,';
        // worksheet.mergeCells(footerStartIdx, 2, footerStartIdx, 9);
        // worksheet.getCell(footerStartIdx, 2).border = {
        //     top: { style: 'thin' },
        //     left: { style: 'thin' },
        //     bottom: { style: 'thin' },
        //     right: { style: 'thin' }
        // };
        // worksheet.getCell(footerStartIdx + 1, 2).value = ' 이 경우 위 견적 내용 및 금액은 변경될 수 있음을 유의하시기 바랍니다.';
        // worksheet.mergeCells(footerStartIdx + 1, 2, footerStartIdx +1, 9);
        // worksheet.getCell(footerStartIdx + 1, 2).border = {
        //     top: { style: 'thin' },
        //     left: { style: 'thin' },
        //     bottom: { style: 'thin' },
        //     right: { style: 'thin' }
        // };
        // worksheet.getCell(footerStartIdx + 2, 2).value = '※ 본 견적서는 발행일로부터 3개월간 유효합니다.'
        // worksheet.mergeCells(footerStartIdx + 2, 2, footerStartIdx + 2, 9);
        // worksheet.getCell(footerStartIdx + 2, 2).border = {
        //     top: { style: 'thin' },
        //     left: { style: 'thin' },
        //     bottom: { style: 'thin' },
        //     right: { style: 'thin' }
        // };
        // worksheet.getCell(footerStartIdx + 3, 2).value = ` ${order.dealerName}, ${order.address} ${order.postalCode}`; // 대리점명, 주소
        // worksheet.mergeCells(footerStartIdx + 3, 2, footerStartIdx + 3, 9);
        // worksheet.getCell(footerStartIdx + 3, 2).border = {
        //     top: { style: 'thin' },
        //     left: { style: 'thin' },
        //     bottom: { style: 'thin' },
        //     right: { style: 'thin' }
        // };
        // worksheet.getCell(footerStartIdx + 4, 2).value = ' Tel : '+ ((order.phone) ? order.phone: ''); // 대리점 폰정보
        // worksheet.mergeCells(footerStartIdx + 4, 2, footerStartIdx + 4, 9);
        // worksheet.getCell(footerStartIdx + 4, 2).border = {
        //     top: { style: 'thin' },
        //     left: { style: 'thin' },
        //     bottom: { style: 'thin' },
        //     right: { style: 'thin' }
        // };
        // worksheet.getCell(footerStartIdx + 5, 2).value = ' Fax : '+((order.fax) ? order.fax: ''); // 대리점 Fax정보
        // worksheet.mergeCells(footerStartIdx + 5, 2, footerStartIdx + 5, 9);
        // worksheet.getCell(footerStartIdx + 5, 2).border = {
        //     top: { style: 'thin' },
        //     left: { style: 'thin' },
        //     bottom: { style: 'thin' },
        //     right: { style: 'thin' }
        // };
        // worksheet.getCell(footerStartIdx + 6, 2).value = ' '+order.dealerName + ' (인) ';
        // worksheet.mergeCells(footerStartIdx + 6, 2, footerStartIdx + 6, 9);
        // worksheet.getCell(footerStartIdx + 6, 2).border = {
        //     top: { style: 'thin' },
        //     left: { style: 'thin' },
        //     bottom: { style: 'thin' },
        //     right: { style: 'thin' }
        // };

        // for(let rowIdx = 2; rowIdx <= footerStartIdx + 6; rowIdx++ ) {
        //     let rowCells = worksheet.getRow(rowIdx);
            
        //     if(!rowCells.getCell(2).border) {
        //         rowCells.getCell(2).border = {
        //             left: {style:'thick'},    
        //         };
        //     }else {
        //         if(rowCells.getCell(2).border.left && rowCells.getCell(2).border.left.style)
        //             rowCells.getCell(2).border.left.style = 'thick';
        //         else
        //             rowCells.getCell(2).border.left = {style:'thick'};  
                
        //     }   

        //     if(!rowCells.getCell(9).border) {
        //         rowCells.getCell(9).border = {
        //             right: {style:'thick'},    
        //         };
        //     }else {
        //         if(rowCells.getCell(9).border.right && rowCells.getCell(9).border.right.style)
        //             rowCells.getCell(9).border.right.style = 'thick';
        //         else 
        //             rowCells.getCell(9).border.right = {style:'thick'};  
        //     }
            
        // }

        
        // worksheet.getCell(footerStartIdx + 6,2).border = {
        //     bottom: {style:'thick'},        
        //     left: {style:'thick'},        
        //     right: {style:'thick'},        
        // };
        

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