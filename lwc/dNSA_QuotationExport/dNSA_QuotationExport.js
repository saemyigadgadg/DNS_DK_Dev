import { LightningElement, api, track } from 'lwc';
import { showToast, style, label } from 'c/commonUtils';
import { loadScript } from 'lightning/platformResourceLoader';
import XLSX from '@salesforce/resourceUrl/ExcelJS';
import getInfo from '@salesforce/apex/DNSA_QuotationExportController.getInfo';
import getStaticResourceBody_EN from '@salesforce/apex/DNSA_QuotationExportController.getStaticResourceBody_EN';
import saveFile from '@salesforce/apex/DNSA_QuotationExportController.saveFile';
export default class DNSA_QuotationExport extends LightningElement {
    @api recordId;
    @track isLoading    = false;
    excelJsLoaded       = false;

    QuoteNumber         = '';
    Dealer              = '';
    AccountName         = '';
    Address             = '';
    CreatedDate         = '';
    ProductModelName    = '';
    zpr1                = '';
    prdDealerPrice      = '';
    RDD                 = '';
    CurrencyIsoCode     = '';
    Warranty            = '';
    currentRow          = 10;
    AdjustmentPrice     = 0;
    lineRow             = 0;
    firstSum            = 0;
    DCPrice             = 0;
    lastSum             = 0;
    usOptionStartRow    = 0;
    usOptionEndRow      = 0;
    totalPrice          = '';
    warrantyPriceRow    = 0;
    totalPriceRow       = 0;
    adjustMentRow       = 0;
    netPriceRow         = 0;

    sqTotal             = 0;
    facTotal            = 0;

    QuoteLineItems      = [];

    connectedCallback() {
        this.isLoading = true;

        loadScript(this, XLSX + '/unpkg/exceljs.min.js')
        .then(() => {
            this.excelJsLoaded = true;
            return getInfo({ 
                recordId: this.recordId 
            });
        })
        .then(result => {
            console.log('getInfo : ' + JSON.stringify(result));
            console.log('AccountName',result.quoteData[0].AccountName);
            console.log('Dealer',result.quoteData[0].Dealer);
            console.log('Address',result.quoteData[0].Address);
            console.log('CreatedDate',result.quoteData[0].CreatedDate);
            console.log('CurrencyIsoCode',result.quoteData[0].CurrencyIsoCode);

            console.log('QuoteLineItems',result.quoteData[0].usItemList);
            this.QuoteNumber        = result.quoteData[0].QuoteNumber;
            this.AccountName        = result.quoteData[0].AccountName;
            this.Dealer             = result.quoteData[0].Dealer;
            this.Address            = result.quoteData[0].Address;
            this.CreatedDate        = new Date(result.quoteData[0].CreatedDate).toISOString().slice(0, 10);
            this.CurrencyIsoCode    = result.quoteData[0].CurrencyIsoCode;
            this.Warranty           = result.quoteData[0].warrantyLabel;
            this.QuoteLineItems     = result.quoteData[0].usItemList;
            this.ProductModelName   = result.quoteData[0].headerInfo.ProductName;
            this.zpr1               = result.quoteData[0].headerInfo.ListPrice;
            this.prdDealerPrice     = result.quoteData[0].headerInfo.DealerPrice;
            this.RDD                = result.quoteData[0].headerInfo.RSD;
            this.AdjustmentPrice    = result.quoteData[0].headerInfo.AdjustmentPrice;
            this.DCPrice            = result.quoteData[0].headerInfo.DCPrice;

            this.sqTotal            = result.quoteData[0].sqTotal;
            this.facTotal           = result.quoteData[0].facTotal;

            console.log('zpr1 : ' + this.zpr1);
            console.log('prdDealerPrice : ' + this.prdDealerPrice);
            console.log('ProductModelName : ' + this.ProductModelName);
            console.log('Warranty : ' + this.Warranty);
            console.log('RDD : ' + this.RDD);
            this.exportToExcel();
        }).catch(error => {
            console.error('error 1 : ' + error.message);
        });
    }

    async exportToExcel() {
        this.excelJsLoaded = true;
        if (this.excelJsLoaded) {
            try {
                const ExcelJS = window.ExcelJS;
                const workbook = new ExcelJS.Workbook();
                const worksheet = workbook.addWorksheet('Quote', {pageSetup:{fitToPage : false, scale : 80}});
                worksheet.views = [
                    { 
                        showGridLines: false
                    }
                ];

                await this.populateWorksheet(worksheet)
                .then(result => {
                    this.returnRow = result;
                }).catch(error => {
                    console.log('error : ' + error);
                });

                await getStaticResourceBody_EN()
                .then(result => {
                    const dnLogoGlobalCv = workbook.addImage({
                        base64: result.dnLogoGlobalCv,
                        extension: 'png'
                    });
                    worksheet.addImage(dnLogoGlobalCv, {tl: { col: 8, row: 1 }, br: { col: 10, row: 2 },
                        ext: { width: 206.988, height: 41.202 }});
                });
                const buffer = await workbook.xlsx.writeBuffer();
                this.downloadExcelFile(buffer);

                this.isLoading = false;
                this.dispatchEvent(new CustomEvent('loadingcomplete'));
            } catch (error) {
                console.error('error 2 : ' + error.message);
            }
        }
    }

    async populateWorksheet(worksheet) {
        try {
            this.currentRow          = 8;
            this.lineRow             = 0;
            this.totalPrice          = '';
            this.returnRow           = 0;
            const setAllBorder = (column, row) => {
                worksheet.getCell(`${column}${row}`).border = {
                    top : { style : 'medium'},
                    left : { style : 'medium'},
                    right : { style : 'medium'},
                    bottom : { style : 'medium'}
                }
            }

            const columns = ['B','C','F','G','H','I','J'];
            const setLRBorder = (row) => {
                columns.forEach(column => {
                    worksheet.getCell(`${column}${row}`).border = {
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                });
            };

            const setVertical = (column, row) => {
                worksheet.getCell(`${column}${row}`).alignment = {
                    vertical: 'middle'
               };
            }
            worksheet.getColumn('A').width = 0.38;
            worksheet.getColumn('B').width = 3.88;
            worksheet.getColumn('C').width = 14.5;
            worksheet.getColumn('D').width = 24;
            worksheet.getColumn('E').width = 10.75;
            worksheet.getColumn('F').width = 33.5;
            worksheet.getColumn('G').width = 4.75;
            worksheet.getColumn('H').width = 17;
            worksheet.getColumn('I').width = 17;
            worksheet.getColumn('J').width = 17;

            worksheet.getRow(1).height = 7.5;
            worksheet.getRow(2).height = 30;
            worksheet.getRow(3).height = 7.5;
            worksheet.getRow(4).height = 24;
            worksheet.getRow(5).height = 24;
            worksheet.getRow(6).height = 24;
            worksheet.getRow(7).height = 6;

            worksheet.mergeCells('B2:J2');
            worksheet.getCell('B2').value = 'Quotation Sheet';
            worksheet.getCell('B2').font = {
                size : 14,
                bold : true,
                underline : true
            };
            worksheet.getCell('B2').alignment = {
                 vertical: 'middle', 
                 horizontal: 'center' 
            };

            worksheet.mergeCells('B4:C4');
            worksheet.getCell('B4').value = 'Dealer';
            setAllBorder('B', 4);
            setVertical('B', 4);

            worksheet.mergeCells('D4:H4');
            setAllBorder('D', 4);
            setVertical('D', 4);
            worksheet.getCell('D4').value = this.Dealer;

            worksheet.getCell('I4').value = 'Date';
            setAllBorder('I', 4);
            setVertical('I', 4);

            worksheet.getCell('J4').value = this.CreatedDate;
            setAllBorder('J', 4);
            setVertical('J', 4);

            worksheet.mergeCells('B5:C5');
            worksheet.getCell('B5').value = 'Customer';
            setAllBorder('B', 5);
            setVertical('B', 5);

            worksheet.mergeCells('D5:J5');
            worksheet.getCell('D5').value = this.AccountName;
            setAllBorder('D', 5);
            setVertical('D', 5);

            worksheet.mergeCells('B6:C6');
            worksheet.getCell('B6').value = 'Address';
            setAllBorder('B', 6);
            setVertical('B', 6);

            worksheet.mergeCells('D6:H6');
            worksheet.getCell('D6').value = this.Address;
            setAllBorder('D', 6);
            setVertical('D', 6);

            worksheet.getCell('I6').value = 'Warranty';
            setAllBorder('I', 6);
            setVertical('I', 6);

            worksheet.getCell('J6').value = this.Warranty;
            setAllBorder('J', 6);
            setVertical('J', 6);

            worksheet.getCell('B8').value = 'No';
            setAllBorder('B', 8);
            worksheet.getCell('B8').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.mergeCells('C8:E8');
            worksheet.getCell('C8').value = 'Description';
            setAllBorder('C', 8);
            worksheet.getCell('C8').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('C8').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('F8').value = '';
            setAllBorder('F', 8);
            worksheet.getCell('F8').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('F8').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('G8').value = 'Qty';
            setAllBorder('G', 8);
            worksheet.getCell('G8').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('G8').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('H8').value = 'List Price (' + this.CurrencyIsoCode + ')';
            setAllBorder('H', 8);
            worksheet.getCell('H8').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('H8').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('I8').value = 'Unit Price (' + this.CurrencyIsoCode + ')';
            setAllBorder('I', 8);
            worksheet.getCell('I8').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('I8').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('J8').value = 'Amount (' + this.CurrencyIsoCode + ')';
            setAllBorder('J', 8);
            worksheet.getCell('J8').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('J8').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };
            
            this.currentRow++;
            worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
            worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
            worksheet.getCell('C' + this.currentRow).value = 'Machine Model / Controller';
            worksheet.getCell('C' + this.currentRow).font = {
                bold : true
            };
            this.firstSum = this.currentRow;
            setLRBorder(this.currentRow);

            this.currentRow++;
            worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
            worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
            worksheet.getCell('C' + this.currentRow).value = this.ProductModelName;
            worksheet.getCell('F' + this.currentRow).value = this.RDD;
            worksheet.getCell('F' + this.currentRow).alignment = { horizontal : 'center'};
            worksheet.getCell('G' + this.currentRow).value = 1;
            worksheet.getCell('G' + this.currentRow).alignment = { horizontal : 'center'};
            worksheet.getCell('H' + this.currentRow).value = this.zpr1;
            worksheet.getCell('H' + this.currentRow).numFmt = '#,##0.00';
            worksheet.getCell('H' + this.currentRow).alignment = { horizontal: 'right' };
            worksheet.getCell('I' + this.currentRow).value = this.prdDealerPrice;
            worksheet.getCell('I' + this.currentRow).numFmt = '#,##0.00';
            worksheet.getCell('I' + this.currentRow).alignment = { horizontal: 'right' };
            worksheet.getCell('J' + this.currentRow).value = {formula : 'G' + this.currentRow + '*I' + this.currentRow};
            worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
            worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };
            setLRBorder(this.currentRow);

            this.currentRow++;
            worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
            worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
            worksheet.getCell('C' + this.currentRow).value = '-';
            worksheet.getCell('F' + this.currentRow).alignment = { horizontal : 'center'};
            worksheet.getCell('G' + this.currentRow).alignment = { horizontal : 'center'};
            worksheet.getCell('H' + this.currentRow).numFmt = '#,##0.00';
            worksheet.getCell('H' + this.currentRow).alignment = { horizontal: 'right' };
            worksheet.getCell('I' + this.currentRow).numFmt = '#,##0.00';
            worksheet.getCell('I' + this.currentRow).alignment = { horizontal: 'right' };
            worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
            worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };
            setLRBorder(this.currentRow);

            let isUsOption = false;
            for(let i = 0; i < this.QuoteLineItems.length; i++){
                this.currentRow++;
                this.lineRow++;
                
                worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                if(this.QuoteLineItems[i].itemValue == 'US Option') {
                    this.usOptionStartRow = this.currentRow + 1; // US Option 항목은 다음 행부터 시작
                    isUsOption = true;
                } else if(this.QuoteLineItems[i].itemValue == 'SQ' || this.QuoteLineItems[i].itemValue == 'Factory Option') {
                    if(isUsOption) {
                        this.usOptionEndRow = this.currentRow - 1; // US Option 섹션의 마지막 항목 행
                        isUsOption = false;
                    }
                }

                if (this.QuoteLineItems[i].itemValue == 'US Option' || this.QuoteLineItems[i].itemValue == 'SQ' || this.QuoteLineItems[i].itemValue == 'Factory Option'){
                    this.lineRow = 0;
                    worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                    worksheet.getCell('C' + this.currentRow).value = '';
                    worksheet.getCell('F' + this.currentRow).alignment = { horizontal : 'center'};
                    worksheet.getCell('G' + this.currentRow).alignment = { horizontal : 'center'};
                    worksheet.getCell('H' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('H' + this.currentRow).alignment = { horizontal: 'right' };
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('I' + this.currentRow).alignment = { horizontal: 'right' };
                    worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };
                    setLRBorder(this.currentRow);

                    this.currentRow++;

                    worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                    worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                    worksheet.getCell('B' + this.currentRow).value = '';
                    worksheet.getCell('C' + this.currentRow).value = this.QuoteLineItems[i].itemValue;
                    worksheet.getCell('C' + this.currentRow).font = {
                        bold : true
                    };
                } else {
                    worksheet.getCell('B' + this.currentRow).value = this.lineRow;
                    if(this.QuoteLineItems[i].type != 'SQ' && this.QuoteLineItems[i].type != 'option'){
                        worksheet.getCell('J' + this.currentRow).value = {formula : 'G' + this.currentRow + '*I' + this.currentRow};
                    }
                    worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };
                }

                worksheet.getCell('C' + this.currentRow).value = this.QuoteLineItems[i].itemValue;
                worksheet.getCell('G' + this.currentRow).value = this.QuoteLineItems[i].Qty;
                worksheet.getCell('G' + this.currentRow).alignment = { horizontal : 'center'};
                worksheet.getCell('I' + this.currentRow).value = this.QuoteLineItems[i].Price;
                worksheet.getCell('I' + this.currentRow).numFmt = '#,##0.00';
                worksheet.getCell('I' + this.currentRow).alignment = { horizontal: 'right' };

                setLRBorder(this.currentRow);
                
                if(i == this.QuoteLineItems.length - 1) {
                    if(isUsOption) {
                        this.usOptionEndRow = this.currentRow; // US Option이 마지막 섹션이면 현재 행이 끝
                        isUsOption = false;
                    }
                    worksheet.getCell('B' + this.currentRow).border = {
                        bottom : { style : 'medium'},
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                    worksheet.getCell('C' + this.currentRow).border = {
                        bottom : { style : 'medium'},
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                    worksheet.getCell('F' + this.currentRow).border = {
                        bottom : { style : 'medium'},
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                    worksheet.getCell('G' + this.currentRow).border = {
                        bottom : { style : 'medium'},
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                    worksheet.getCell('H' + this.currentRow).border = {
                        bottom : { style : 'medium'},
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                    worksheet.getCell('I' + this.currentRow).border = {
                        bottom : { style : 'medium'},
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                    worksheet.getCell('J' + this.currentRow).border = {
                        bottom : { style : 'medium'},
                        left : { style : 'medium'},
                        right : { style : 'medium'}
                    };
                    this.lastSum = this.currentRow;
                    this.currentRow++;
                    this.lineRow++;
                    setAllBorder('B',this.currentRow);

                    worksheet.mergeCells('B'+this.currentRow+':'+'I'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Machine List Price';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('J',this.currentRow);
                    worksheet.getCell('B'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('J'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('J'+this.currentRow).value = this.zpr1;
                    worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };

                    this.currentRow++;
                    this.lineRow++;
                    setAllBorder('B',this.currentRow);
                    this.adjustMentRow = this.currentRow;
                    worksheet.mergeCells('B'+this.currentRow+':'+'I'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Machine Discount';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('J',this.currentRow);
                    worksheet.getCell('J'+this.currentRow).value = this.DCPrice;
                    worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };
                    worksheet.getCell('J' + this.currentRow).font = {color: { argb: "FFFF0000" }};
                    
                    this.currentRow++;
                    this.lineRow++;
                    this.netPriceRow = this.currentRow;
                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'I'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Machine Dealer Price';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('J',this.currentRow);
                    worksheet.getCell('B'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('J'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('J'+this.currentRow).value = this.prdDealerPrice;
                    worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };

                    if(this.usOptionStartRow && this.usOptionEndRow) {
                        this.currentRow++;
                        this.lineRow++;
                        this.netPriceRow = this.currentRow;
                        setAllBorder('B',this.currentRow);
                        worksheet.mergeCells('B'+this.currentRow+':'+'I'+this.currentRow);
                        worksheet.getCell('B'+this.currentRow).value = 'US Option Total';
                        worksheet.getCell('B'+this.currentRow).alignment = {
                            vertical : 'middle',
                            horizontal : 'center'
                        };
                        setAllBorder('J',this.currentRow);
                        worksheet.getCell('J'+this.currentRow).value = {formula : 'SUM(J' + this.usOptionStartRow + ':J' + this.usOptionEndRow + ')'};
                        worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                        worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };
                    }

                    this.currentRow++;
                    this.lineRow++;
                    this.netPriceRow = this.currentRow;
                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'I'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'SQ/Factory Option Total';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('J',this.currentRow);
                    worksheet.getCell('J'+this.currentRow).value = this.sqTotal + this.facTotal;
                    worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };

                    this.currentRow++;
                    this.lineRow++;
                    this.netPriceRow = this.currentRow;
                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'I'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Total Price';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('J',this.currentRow);
                    worksheet.getCell('B'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('J'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('J'+this.currentRow).value = {formula : 'SUM(J' + (this.currentRow-3) + ':J' + (this.currentRow-1) + ')'};
                    worksheet.getCell('J' + this.currentRow).numFmt = '#,##0.00';
                    worksheet.getCell('J' + this.currentRow).alignment = { horizontal: 'right' };

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getRow(this.currentRow).height = 6.75;

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getCell('B'+this.currentRow).value = 'Comment : ';

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getCell('B'+this.currentRow).value = '       - Delivery date : discussed after contract completion';

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getCell('B'+this.currentRow).value = '       - Quotation validity period : 1month from submission date';
                }
            }
            return this.currentRow;
        } catch (error) {
            console.log('populateWorksheet error : ' + error.message);
            throw error;
        }
    }

    // downloadExcelFile(buffer) {
    //     try {
    //         const base64Data = this.arrayBufferToBase64(buffer);
    //         const link = document.createElement('a');
    //         const date = this.CreatedDate;
    //         const name = this.QuoteNumber + '_' + this.AccountName + '_' + date + '.xlsx';
        
    //         link.href = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + base64Data;
    //         link.download = name;
    //         link.click();

    //         setTimeout(() => {
    //             document.body.removeChild(link);
    //         }, 0);
    //     } catch (error) {
    //         console.log('downloadExcelFile : ' + error.message);
    //     }
    // }
    downloadExcelFile(buffer) {
        try {
            const base64Data = this.arrayBufferToBase64(buffer);
            const link = document.createElement('a');
            const date = this.CreatedDate;
            const name = this.QuoteNumber + '_' + this.AccountName + '_' + date + '.xlsx';
        
            link.href = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + base64Data;
            link.download = name;
            document.body.appendChild(link); // link를 document.body에 추가
            link.click();
            document.body.removeChild(link); // 클릭 후 제거
        } catch (error) {
            console.log('downloadExcelFile : ' + error.message);
        }
    }

    base64ToArrayBuffer(base64) {
        try {
            const binaryString = window.atob(base64);
            const len = binaryString.length;
            const bytes = new Uint8Array(len);
            for (let i = 0; i < len; i++) {
                bytes[i] = binaryString.charCodeAt(i);
            }
            return bytes.buffer;
        } catch (error) {
            console.error('base64ToArrayBuffer error:', error);
            throw new Error('Failed to convert Base64 to ArrayBuffer');
        }
    }

    arrayBufferToBase64(buffer) {
        try {
            let binary = '';
            const bytes = new Uint8Array(buffer);
            const len = bytes.byteLength;
            for (let i = 0; i < len; i++) {
                binary += String.fromCharCode(bytes[i]);
            }
            return window.btoa(binary);
        } catch (error) {
            console.error('arrayBufferToBase64 error:', error);
        }
    }
}