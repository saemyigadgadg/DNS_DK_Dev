import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadScript } from 'lightning/platformResourceLoader';
import XLSX from '@salesforce/resourceUrl/ExcelJS';
import getInfo from '@salesforce/apex/DN_QuotationExportController.getInfo';
import getStaticResourceBody_EN from '@salesforce/apex/DN_QuotationExportController.getStaticResourceBody_EN';
import saveFile from '@salesforce/apex/DN_QuotationExportController.saveFile';
export default class DN_QuotationExport_EN extends LightningElement {
    @api recordId;
    @track isLoading    = false;
    excelJsLoaded       = false;

    QuoteNumber         = '';
    AccountName         = '';
    Dealer              = '';
    NewExist            = '';
    Address             = '';
    Representative      = '';
    PurposeofUse        = '';
    UsageofProduct      = '';
    PreInspection       = '';
    Competition         = '';
    ProductType         = '';
    Incoterms           = '';
    TermsOfPayment      = '';
    Industry            = '';
    ExMachine           = '';
    Port                = '';
    Port                = '';
    CreatedDate         = '';
    AllQuoteLineItems   = [];
    QuoteLineItems      = [];
    ProductName         = '';
    Quantity            = '';
    ListPrice           = '';
    RDD                 = '';
    leadTime            = '';
    CurrencyIsoCode     = '';

    currentRow          = 18;
    lineRow             = 0;
    prdQtyRow           = 18;
    prdPriceRow         = 18;
    prdTotalPrice       = [];

    cvFirstRow          = 0;
    cvLastRow           = 0;
    cvTotalPrice        = [];

    totalPrice          = '';
    returnRow           = 0;
    sheetNum            = 0;

    firstSum            = 0;
    lastSum             = 0;

    adjustMentPrice     = 0;
    warrantyPrice       = 0;

    totalPriceRow       = 0;
    adjustMentRow       = 0;
    netPriceRow         = 0;
    warrantyPriceRow    = 0;
    connectedCallback() {
        this.isLoading = true;

        loadScript(this, XLSX + '/unpkg/exceljs.min.js')
        .then(() => {
            this.excelJsLoaded = true;
            // console.log('ExcelJS loaded successfully');

            return getInfo({ 
                recordId: this.recordId 
            });
        })
        .then(result => {

            if(result.keyField != 'SUCCESS'){
                showToast(this, 'ERROR','ERROR', result.keyField);
                this.isLoading = false;
                this.dispatchEvent(new CustomEvent('loadingcomplete'));

            }else{
                this.QuoteNumber        = result.QuoteNumber;
                this.AccountName        = result.AccountName;
                this.Dealer             = result.Dealer;
                this.Industry           = result.Industry;
                this.NewExist           = result.NewExist;
                this.Incoterms          = result.Incoterms;
                this.TermsOfPayment     = result.TermsOfPayment;
                this.Address            = result.Address;
                this.CreatedDate        = result.CreatedDate.substring(0,result.CreatedDate.indexOf('T',0));
                this.Representative     = result.Representative;
                this.ProductType        = result.ProductType;
                this.PurposeofUse       = result.PurposeofUse;
                this.UsageofProduct     = result.UsageofProduct;
                this.PreInspection      = result.PreInspection;
                this.Competition        = result.Competition;
                this.ExMachine          = result.ExMachine;
                this.Port               = result.Port;
                this.CurrencyIsoCode    = result.Currency;
                this.AllQuoteLineItems  = result.QuoteLineItems;
                // this.QuoteLineItems     = result.QuoteLineItems;
                // this.Quantity           = this.AllQuoteLineItems[0].Quantity;
                // this.RDD                = this.AllQuoteLineItems[0].RDD;
    
                this.exportToExcel();
            }
            
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
                for(var i = 0; i < this.AllQuoteLineItems.length; i++){
                    this.QuoteLineItems = [];
                    const object = this.AllQuoteLineItems[i];
                    this.QuoteLineItems.push(object);
                    //엑셀파일 만들 때 scale을 80으로 설정 후 contentVersion에 insert, 실제 다운로드할 때는 100%로 보임
                    // const worksheet = workbook.addWorksheet('Quote_' + (i + 1) + '_' + this.AllQuoteLineItems[i].ProductName, {pageSetup:{fitToPage : false, scale : 80}});
                    const worksheet = workbook.addWorksheet('Quote_' + (i + 1), {pageSetup:{fitToPage : false, scale : 80}});
                    //배경 테두리 삭제하기위해 설정
                    worksheet.views = [
                        { 
                            showGridLines: false  // Hide gridlines
                        }
                    ];

                    await this.populateWorksheet(worksheet)
                    .then(result => {
                        // console.log('result : ' + result);
                        this.returnRow = result;
                    }).catch(error => {
                        console.log('error : ' + error);
                    });


                    // 이미지 삽입 
                    await getStaticResourceBody_EN()
                    .then(result => {
                        const dnLogoGlobalCv = workbook.addImage({
                            base64: result.dnLogoGlobalCv,
                            extension: 'png'
                        });
                        worksheet.addImage(dnLogoGlobalCv, {tl: { col: 7, row: 1 }, br: { col: 9, row: 2 },
                            ext: { width: 206.988, height: 41.202 }}); // 삽입할 셀 범위 설정

                    });
                }
                const buffer = await workbook.xlsx.writeBuffer();
                this.downloadExcelFile(buffer);

                //ContentVersion Obj에 저장하기 위한 부분 주석처리
                // const base64Data = this.arrayBufferToBase64(buffer);
                // const fileName = `${this.AccountName}_${this.CreatedDate}.xlsx`;
                // await saveFile({ base64Data, fileName, parentId: this.recordId });

                this.isLoading = false;
                this.dispatchEvent(new CustomEvent('loadingcomplete'));
            } catch (error) {
                console.error('error 2 : ' + error.message);
            }
        }
    }

    async populateWorksheet(worksheet) {
        try {
            this.currentRow          = 18;
            this.lineRow             = 0;
            this.totalPrice          = '';
            this.returnRow           = 0;
            //4면 테두리 세팅 함수
            const setAllBorder = (column, row) => {
                worksheet.getCell(`${column}${row}`).border = {
                    top : { style : 'medium'},
                    left : { style : 'medium'},
                    right : { style : 'medium'},
                    bottom : { style : 'medium'}
                }
            }

            const columns = ['B','C','F','G','H','I'];
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
            //초기 화면 디자인 세팅
            worksheet.getColumn('A').width = 0.38;
            worksheet.getColumn('B').width = 3.88;
            worksheet.getColumn('C').width = 14.5;
            // worksheet.getColumn('D').width = 13.75;
            worksheet.getColumn('D').width = 24;
            worksheet.getColumn('E').width = 10.75;
            // worksheet.getColumn('F').width = 8.5;
            worksheet.getColumn('F').width = 33.5;
            worksheet.getColumn('G').width = 4.75;
            worksheet.getColumn('G').width = 4.75;
            worksheet.getColumn('H').width = 17;
            worksheet.getColumn('I').width = 17;

            worksheet.getRow(1).height = 7.5;
            worksheet.getRow(2).height = 30;
            worksheet.getRow(3).height = 7.5;
            worksheet.getRow(4).height = 24;
            worksheet.getRow(5).height = 24;
            worksheet.getRow(6).height = 24;
            worksheet.getRow(7).height = 24;
            worksheet.getRow(8).height = 24;
            worksheet.getRow(9).height = 22.5;
            worksheet.getRow(10).height = 22.5;

            worksheet.getRow(11).height = 6;
            worksheet.getRow(12).height = 24;
            worksheet.getRow(13).height = 24;
            worksheet.getRow(14).height = 24;
            worksheet.getRow(15).height = 22.5;
            worksheet.getRow(16).height = 22.5;

            worksheet.getRow(17).height = 6;

            worksheet.mergeCells('B2:I2');
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

            worksheet.mergeCells('D4:G4');
            setAllBorder('D', 4);
            setVertical('D', 4);
            worksheet.getCell('D4').value = this.Dealer;

            worksheet.getCell('H4').value = 'Date';
            setAllBorder('H', 4);
            setVertical('H', 4);

            worksheet.getCell('I4').value = this.CreatedDate;
            setAllBorder('I', 4);
            setVertical('I', 4);

            worksheet.mergeCells('B5:C5');
            worksheet.getCell('B5').value = 'Customer';
            setAllBorder('B', 5);
            setVertical('B', 5);

            worksheet.mergeCells('D5:H5');
            worksheet.getCell('D5').value = this.AccountName;
            setAllBorder('D', 5);
            setVertical('D', 5);

            worksheet.getCell('I5').value = this.NewExist;
            setAllBorder('I', 5);
            setVertical('I', 5);

            worksheet.mergeCells('B6:C6');
            worksheet.getCell('B6').value = 'Address';
            setAllBorder('B', 6);
            setVertical('B', 6);

            worksheet.mergeCells('D6:I6');
            worksheet.getCell('D6').value = this.Address;
            setAllBorder('D', 6);
            setVertical('D', 6);

            worksheet.mergeCells('B7:C7');
            worksheet.getCell('B7').value = 'Representative';
            setAllBorder('B', 7);
            setVertical('B', 7);

            worksheet.getCell('D7').value = this.Representative;
            setAllBorder('D', 7);
            setVertical('D', 7);

            worksheet.getCell('E7').value = 'Industry';
            setAllBorder('E', 7);
            setVertical('E', 7);
            
            worksheet.mergeCells('F7:G7');
            worksheet.getCell('F7').value = this.Industry;
            setAllBorder('F', 7);
            setVertical('F', 7);

            worksheet.getCell('H7').value = 'Port';
            setAllBorder('H', 7);
            setVertical('H', 7);

            worksheet.getCell('I7').value = this.Port;
            setAllBorder('I', 7);
            setVertical('I', 7);
            
            worksheet.mergeCells('B8:C8');
            worksheet.getCell('B8').value = 'Incoterms';
            setAllBorder('B', 8);
            setVertical('B', 8);

            worksheet.getCell('D8').value = this.Incoterms;
            setAllBorder('D', 8);
            setVertical('D', 8);

            worksheet.getCell('E8').value = 'Payment';
            setAllBorder('E', 8);
            setVertical('E', 8);
            
            worksheet.mergeCells('F8:G8');
            worksheet.getCell('F8').value = this.TermsOfPayment;
            setAllBorder('F', 8);
            setVertical('F', 8);

            worksheet.mergeCells('H8:I8');
            worksheet.getCell('H8').value = this.ProductType;
            setAllBorder('H', 8);
            setVertical('H', 8);

            worksheet.mergeCells('B9:C9');
            worksheet.getCell('B9').value = 'Existing machine';
            worksheet.mergeCells('B10:C10');
            worksheet.getCell('B10').value = '(Brand/model/Qty)';
            worksheet.getCell('B9').border = {
                left : { style : 'medium'}
            }
            worksheet.getCell('B9').alignment = {
                vertical: 'bottom'
           };
            worksheet.getCell('B10').border = {
                left : { style : 'medium'},
                bottom : { style : 'medium'}
            }
            worksheet.getCell('B10').alignment = {
                vertical: 'top'
           };

            worksheet.mergeCells('D9:I10');
            worksheet.getCell('D9').value = this.ExMachine;
            setAllBorder('D', 9);
            setVertical('D', 9);


            worksheet.mergeCells('B12:C12');
            worksheet.getCell('B12').value = 'Purpose of Use';
            setAllBorder('B', 12);
            setVertical('B', 12);

            worksheet.mergeCells('D12:I12');
            worksheet.getCell('D12').value = this.PurposeofUse;
            setAllBorder('D', 12);
            setVertical('D', 12);

            worksheet.mergeCells('B13:C13');
            worksheet.getCell('B13').value = 'Usage of Product';
            setAllBorder('B', 13);
            setVertical('B', 13);

            worksheet.mergeCells('D13:I13');
            worksheet.getCell('D13').value = this.UsageofProduct;
            setAllBorder('D', 13);
            setVertical('D', 13);

            worksheet.mergeCells('B14:C14');
            worksheet.getCell('B14').value = 'Pre-Inspection';
            setAllBorder('B', 14);
            setVertical('B', 14);

            worksheet.mergeCells('D14:I14');
            worksheet.getCell('D14').value = this.PreInspection;
            setAllBorder('D', 14);
            setVertical('D', 14);

            worksheet.mergeCells('B15:C15');
            worksheet.getCell('B15').value = 'Competition';
            worksheet.mergeCells('B16:C16');
            worksheet.getCell('B16').value = '(Brand/model/Qty)';
            worksheet.getCell('B15').border = {
                left : { style : 'medium'}
            }
            worksheet.getCell('B15').alignment = {
                vertical: 'bottom'
           };
            worksheet.getCell('B16').border = {
                left : { style : 'medium'},
                bottom : { style : 'medium'}
            }
            worksheet.getCell('B16').alignment = {
                vertical: 'top'
           };

            worksheet.mergeCells('D15:I16');
            worksheet.getCell('D15').value = this.Competition;
            setAllBorder('D', 15);
            setVertical('D', 15);

            worksheet.getCell('B18').value = 'No';
            setAllBorder('B', 18);
            worksheet.getCell('B18').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.mergeCells('C18:E18');
            worksheet.getCell('C18').value = 'Description';
            setAllBorder('C', 18);
            worksheet.getCell('C18').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('C18').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('F18').value = 'RDD';
            setAllBorder('F', 18);
            worksheet.getCell('F18').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('F18').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('G18').value = 'Qty';
            setAllBorder('G', 18);
            worksheet.getCell('G18').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('G18').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('H18').value = 'Unit Price (' + this.CurrencyIsoCode + ')';
            setAllBorder('H', 18);
            worksheet.getCell('H18').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('H18').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };

            worksheet.getCell('I18').value = 'Amount (' + this.CurrencyIsoCode + ')';
            setAllBorder('I', 18);
            worksheet.getCell('I18').alignment = {
                vertical: 'middle',
                horizontal: 'center'
            };
            worksheet.getCell('I18').fill = {
                type : 'pattern',
                pattern: 'solid',
                fgColor: { argb : 'FFE3F4FC' }
            };
            // console.log(typeof(this.QuoteLineItems));
            for(let i = 0; i < this.QuoteLineItems.length; i++){
                this.currentRow++;
                // this.lineRow++;
                worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                // worksheet.getCell('B' + this.currentRow).value = this.lineRow;
                worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                worksheet.getCell('C' + this.currentRow).value = 'Machine Model / Controller';
                this.firstSum = this.currentRow;
                setLRBorder(this.currentRow);

                this.currentRow++;
                // this.lineRow++;
                worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                // worksheet.getCell('B' + this.currentRow).value = this.lineRow;
                worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                worksheet.getCell('C' + this.currentRow).value = this.QuoteLineItems[i].ProductName;
                worksheet.getCell('F' + this.currentRow).value = this.QuoteLineItems[i].RDD;
                worksheet.getCell('F' + this.currentRow).alignment = { horizontal : 'center'};
                worksheet.getCell('G' + this.currentRow).value = this.QuoteLineItems[i].Quantity;
                worksheet.getCell('G' + this.currentRow).alignment = { horizontal : 'center'};
                worksheet.getCell('H' + this.currentRow).value = this.QuoteLineItems[i].ListPrice;
                worksheet.getCell('H' + this.currentRow).numFmt = '#,##0';

                worksheet.getCell('I' + this.currentRow).value = {formula : 'G' + this.currentRow + '*H' + this.currentRow};
                worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';
                setLRBorder(this.currentRow);

                this.currentRow++;
                // this.lineRow++;
                worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                // worksheet.getCell('B' + this.currentRow).value = this.lineRow;
                worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                worksheet.getCell('C' + this.currentRow).value = '-';
                setLRBorder(this.currentRow);

                this.currentRow++;
                // this.lineRow++;
                worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                // worksheet.getCell('B' + this.currentRow).value = this.lineRow;
                worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                worksheet.getCell('C' + this.currentRow).value = 'Option';
                setLRBorder(this.currentRow);

                for(let j = 0; j < this.QuoteLineItems[i].CharacteristicValues.length; j++){
                    this.currentRow++;
                    this.lineRow++;
                    
                    worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                    worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                    if (this.QuoteLineItems[i].CharacteristicValues[j].Character == 'SQ' || this.QuoteLineItems[i].CharacteristicValues[j].Character == 'Accessory'){
                        this.lineRow = 0;
                        worksheet.getCell('B' + this.currentRow).value = '';
                    }else{
                        worksheet.getCell('B' + this.currentRow).value = this.lineRow;
                        if(this.QuoteLineItems[i].CharacteristicValues[j].Price != ''){
                            worksheet.getCell('I' + this.currentRow).value = {formula : 'G' + this.currentRow + '*H' + this.currentRow};
                        }
                        worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';
                    }

                    // worksheet.getCell('C' + this.currentRow).value = this.QuoteLineItems[i].CharacteristicValues[j].Character + ' - ' + this.QuoteLineItems[i].CharacteristicValues[j].Value;
                    worksheet.getCell('C' + this.currentRow).value = this.QuoteLineItems[i].CharacteristicValues[j].Character;
                    worksheet.getCell('G' + this.currentRow).value = this.QuoteLineItems[i].CharacteristicValues[j].cvQty;
                    worksheet.getCell('G' + this.currentRow).alignment = { horizontal : 'center'};
                    worksheet.getCell('H' + this.currentRow).value  = this.QuoteLineItems[i].CharacteristicValues[j].Price;
                    worksheet.getCell('H' + this.currentRow).numFmt = '#,##0';

                    setLRBorder(this.currentRow);
                }
                // console.log('i : ' + i);
                // console.log('length : ' + (this.QuoteLineItems.length - 1));
                if(i != this.QuoteLineItems.length - 1){
                    this.currentRow++;
                    this.lineRow++;
                    worksheet.mergeCells('C'+this.currentRow+':'+'E'+this.currentRow);
                    worksheet.getCell('B' + this.currentRow).value = this.lineRow;
                    worksheet.getCell('B' + this.currentRow).alignment = { horizontal : 'center'};
                    worksheet.getCell('C' + this.currentRow).value = '-';
                    setLRBorder(this.currentRow);
                }else {
                    // console.log('this.current : ' + this.currentRow);

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
                    this.lastSum = this.currentRow;
                    this.currentRow++;
                    this.lineRow++;
                    setAllBorder('B',this.currentRow);
                    this.totalPriceRow = this.currentRow;
                    worksheet.mergeCells('B'+this.currentRow+':'+'H'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Total Price';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    worksheet.getCell('I'+this.currentRow).value = {formula : 'SUM(I' + this.firstSum + ':' + 'I' + this.lastSum + ')'}
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';
                    setAllBorder('I',this.currentRow);
                    worksheet.getCell('B'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('I'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    //worksheet.getCell('I'+this.currentRow).value = {formula : 'SUM(I19:I'+this.currentRow+')'};
                    //worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';

                    this.currentRow++;
                    this.lineRow++;
                    setAllBorder('B',this.currentRow);
                    this.adjustMentRow = this.currentRow;
                    worksheet.mergeCells('B'+this.currentRow+':'+'H'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'DC FROM DN Solutions (' + this.QuoteLineItems[i].DCPercent + '%)';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('I',this.currentRow);
                    // worksheet.getCell('B'+this.currentRow).fill = {
                    //     type : 'pattern',
                    //     pattern: 'solid',
                    //     fgColor: { argb : 'FFE3F4FC' }
                    // };
                    // worksheet.getCell('I'+this.currentRow).fill = {
                    //     type : 'pattern',
                    //     pattern: 'solid',
                    //     fgColor: { argb : 'FFE3F4FC' }
                    // };
                    worksheet.getCell('I'+this.currentRow).value = this.QuoteLineItems[i].DCPrice;
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';
                    worksheet.getCell('I' + this.currentRow).font = {color: { argb: "FFFF0000" }};

                    this.currentRow++;
                    this.lineRow++;
                    this.netPriceRow = this.currentRow;
                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'H'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Total Net Price';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('I',this.currentRow);
                    worksheet.getCell('B'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('I'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('I'+this.currentRow).value = {formula : 'SUM(I' + this.totalPriceRow + ':' + 'I' + this.adjustMentRow + ')'}
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';

                    this.currentRow++;
                    this.lineRow++;
                    this.warrantyPriceRow = this.currentRow;

                    //
                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'H'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Adjustment Price';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('I',this.currentRow);
                    worksheet.getCell('I'+this.currentRow).value = this.QuoteLineItems[i].Adjustment;
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';

                    this.currentRow++;
                    this.lineRow++;

                    //
//------------------------------------------------------------------------
                    //
                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'H'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Total Net Price + Adjustment Price	';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('I',this.currentRow);
                    worksheet.getCell('B'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('I'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('I'+this.currentRow).value = {formula : 'SUM(I' + this.netPriceRow + ':' + 'I' + this.warrantyPriceRow + ')'}
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';

                    this.netPriceRow = this.currentRow;
                    this.currentRow++;
                    this.lineRow++;
                    this.warrantyPriceRow = this.currentRow;

                    //
                    
                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'H'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Warranty (' + this.QuoteLineItems[i].Warranty + ')';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('I',this.currentRow);
                    worksheet.getCell('I'+this.currentRow).value = this.QuoteLineItems[i].WarrantyPrice;
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';

                    this.currentRow++;
                    this.lineRow++;

                    setAllBorder('B',this.currentRow);
                    worksheet.mergeCells('B'+this.currentRow+':'+'H'+this.currentRow);
                    worksheet.getCell('B'+this.currentRow).value = 'Final Price';
                    worksheet.getCell('B'+this.currentRow).alignment = {
                        vertical : 'middle',
                        horizontal : 'center'
                    };
                    setAllBorder('I',this.currentRow);
                    worksheet.getCell('B'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('I'+this.currentRow).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FFE3F4FC' }
                    };
                    worksheet.getCell('I'+this.currentRow).value = {formula : 'SUM(I' + this.netPriceRow + ':' + 'I' + this.warrantyPriceRow + ')'}
                    worksheet.getCell('I' + this.currentRow).numFmt = '#,##0';

                    this.currentRow++;
                    this.lineRow++;

                    worksheet.getRow(this.currentRow).height = 6.75;

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getCell('B'+this.currentRow).value = 'Comment : ';

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getCell('B'+this.currentRow).value = '       - Delivery from Korea: ' + this.QuoteLineItems[i].leadTime +' months after confirmed order';

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getCell('B'+this.currentRow).value = '       - Delivery date : discussed after contract completion';

                    this.currentRow++;
                    this.lineRow++;
                    worksheet.getCell('B'+this.currentRow).value = '       - Quotation validity period : 1month from submission date';
                }
            }
            const buffer = await workbook.xlsx.writeBuffer();
            this.downloadExcelFile(buffer);
            const base64Data = this.arrayBufferToBase64(buffer);
            const fileName = `${this.AccountName}_${this.CreatedDate}.xlsx`;
            await saveFile({ base64Data, fileName, parentId: this.recordId });

            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('loadingcomplete'));
        } catch (error) {
            console.log('populateWorksheet error : ' + JSON.stringify(error));
        }
    }

    downloadExcelFile(buffer) {
        // const blob      = new Blob([buffer], { type: 'application/octet-stream' });
        // const url       = URL.createObjectURL(blob);
        // const link      = document.createElement('a');
        // const date      = this.CreatedDate;
        // const name      = this.AccountName + '_' + date + '.xlsx';
        // link.href       = url;
        // link.download   = name;
        // link.click();

        const base64Data = this.arrayBufferToBase64(buffer);
        const link = document.createElement('a');
        const date = this.CreatedDate;
        const name = this.QuoteNumber + '_' + this.AccountName + '_' + date + '.xlsx';
    
        link.href = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + base64Data;
        link.download = name;
        link.click();

        // 정리
        setTimeout(() => {
            document.body.removeChild(link);
            window.URL.revokeObjectURL(url);
        }, 0);
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
        let binary = '';
        const bytes = new Uint8Array(buffer);
        const len = bytes.byteLength;
        for (let i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return window.btoa(binary);
    }
}