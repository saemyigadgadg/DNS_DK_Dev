/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-17
 * @last modified by  : yuhyun.park@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-04-17   yuhyun.park@sbtglobal.com   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import { loadScript } from 'lightning/platformResourceLoader';
import XLSX from '@salesforce/resourceUrl/ExcelJS';
// import getTemplateFile_KR from '@salesforce/apex/DN_QuotationExportController.getTemplateFile_KR';
import getInfo from '@salesforce/apex/DN_QuotationExportController.getInfo';
import getStaticResourceBody_KR from '@salesforce/apex/DN_QuotationExportController.getStaticResourceBody_KR';
import saveFile from '@salesforce/apex/DN_QuotationExportController.saveFile';

export default class DN_QuotationExport_KR extends LightningElement {
    @api recordId;
    @track isLoading    = false;
    excelJsLoaded       = false;

    QuoteNumber         = '';
    AccountName         = '';
    ExpirationDate      = '';
    Incoterms           = '';
    TermsOfPayment      = '';
    CreatedDate         = '';
    QuoteLineItems      = [];
    ProductCode         = '';
    ModelName         = '';
    Quantity            = '';
    TotalPrice          = '';

    currentRow          = 26;

    prdQtyRow           = 26;
    prdPriceRow         = 26;
    prdTotalPrice       = [];

    cvFirstRow          = 0;
    cvLastRow           = 0;
    cvTotalPrice        = [];

    lineRow             = 27;

    totalPrice          = '';
    returnRow           = 0;
    
    quotesalesoffice         = '';
    quoteaddress         = '';
    mainphone         = '';
    mobilephone         = '';
    roleType    = '';
    distiName    = '';
    distiRep    = '';
    mainphoneRep    = '';
    mobilephoneRep    = '';
    mailRep    = '';
    mainEmail = '';
    tempRow = 0;
    connectedCallback() {
        this.isLoading = true;

        loadScript(this, XLSX + '/unpkg/exceljs.min.js')
        .then(() => {
            this.excelJsLoaded = true;
            // console.log('ExcelJS loaded successfully');
        }).catch(error => {
            console.error('Failed to load ExcelJS:', error);
        });

        getInfo({ 
            recordId    : this.recordId
        })
        .then(result => {
            if(result.keyField != 'SUCCESS'){
                showToast(this, 'ERROR','ERROR', result.keyField);
                this.isLoading = false;
                this.dispatchEvent(new CustomEvent('loadingcomplete'));
            }else{
                this.QuoteNumber        = result.QuoteNumber;
                this.AccountName        = result.AccountName;
                this.ExpirationDate     = result.ExpirationDate;
                this.Incoterms          = result.Incoterms;
                this.TermsOfPayment     = result.TermsOfPayment;
                this.CreatedDate        = result.CreatedDate.substring(0,result.CreatedDate.indexOf('T',0));
                this.AllQuoteLineItems  = result.QuoteLineItems;
                // this.QuoteLineItems     = result.QuoteLineItems;
                // this.ProductCode        = this.QuoteLineItems[0].ProductCode;
                // this.Quantity           = this.QuoteLineItems[0].Quantity;
                // this.TotalPrice         = this.QuoteLineItems[0].TotalPrice;
                this.TotalPrice         = '';

                this.quotesalesoffice   = result.quotesalesoffice;
                this.quoteaddress       = result.quoteaddress;
                this.mainphone          = result.mainphone;
                this.mobilephone        = result.mobilephone;
                this.roleType           = result.roleType;
                this.distiName          = result.distiName;
                this.distiRep           = result.distiRep;
                this.mainphoneRep       = result.mainphoneRep;
                this.mobilephoneRep     = result.mobilephoneRep;
                this.mailRep            = result.mailRep;
                this.mainEmail          = result.mainEmail;
                // console.log(this.AccountName);
                // console.log(this.ExpirationDate);
                // console.log(this.Incoterms);
                // console.log(this.TermsOfPayment);
                // console.log(this.CreatedDate);
                // console.log(this.QuoteLineItems);
                console.log('result : ' + JSON.stringify(result));
                this.exportToExcel();
            }
            
        }).catch(error => {
            console.error('Failed to getInit:' + JSON.stringify(error));
        });
    }

    async exportToExcel() {
        this.excelJsLoaded = true;
        if (this.excelJsLoaded) {
            try {
                // const templateFileBase64 = await getTemplateFile_KR();
                // if(templateFileBase64 != 'fail') {
                    const ExcelJS = window.ExcelJS;
                    const workbook = new ExcelJS.Workbook();
                    for(var i = 0; i < this.AllQuoteLineItems.length; i++){
                        this.QuoteLineItems = [];
                        const object = this.AllQuoteLineItems[i];
                        this.QuoteLineItems.push(object);
                        //엑셀파일 만들 때 scale을 80으로 설정 후 contentVersion에 insert, 실제 다운로드할 때는 100%로 보임
                        // const worksheet = workbook.addWorksheet('Quote_' + (i + 1) + '_' + this.AllQuoteLineItems[i].ProductCode, {pageSetup:{fitToPage : false, scale : 80}});
                        const worksheet = workbook.addWorksheet('Quote_' + (i + 1), {pageSetup:{fitToPage : false, scale : 80}});
                        //배경 테두리 삭제하기위해 설정
                        worksheet.views = [
                            { 
                                showGridLines: false  // Hide gridlines
                            }
                        ];

                        await this.populateWorksheet(worksheet, this.QuoteLineItems[0].RDD)
                        .then(result => {
                            // console.log('result : ' + result);
                            this.returnRow = result;
                        }).catch(error => {
                            console.log('error : ' + error);
                        });


                        // 이미지 삽입 
                        await getStaticResourceBody_KR({ recordId : this.AllQuoteLineItems[i].QuoteLineId})
                        .then(result => {
                            const dnLogoCv = workbook.addImage({
                                base64: result.dnLogoCv,
                                extension: 'png'
                            });
                            worksheet.addImage(dnLogoCv, {tl: { col: 9, row: 1 }, br: { col: 11, row: 3 },
                                ext: { width: 206.988, height: 41.202 }}); // 삽입할 셀 범위 설정


                            // console.log('returnRow : ', this.returnRow);
                            const dnSealCv = workbook.addImage({
                                base64: result.dnSealCv,
                                extension: 'png'
                                });
                            if(this.roleType == 'Manager'){
                                
                                worksheet.addImage(dnSealCv, {tl: { col: 4, row: this.returnRow},
                                    ext: { width: 66.966, height: 62.37 }}); // 삽입할 셀 범위 설정
                                worksheet.addImage(dnLogoCv, {tl: { col: 2, row: this.returnRow -4}, br: { col: 4, row: this.returnRow -2},
                                    ext: { width: 206.988, height: 41.202 }}); // 삽입할 셀 범위 설정
                            }else if(this.roleType == 'Worker'){
                                
                                worksheet.addImage(dnSealCv, {tl: { col: 4, row: this.returnRow -4},
                                    ext: { width: 66.966, height: 62.37 }}); // 삽입할 셀 범위 설정
                                worksheet.addImage(dnLogoCv, {tl: { col: 2, row: this.returnRow -8}, br: { col: 4, row: this.returnRow -6},
                                    ext: { width: 206.988, height: 41.202 }}); // 삽입할 셀 범위 설정
                            }else{
                                worksheet.addImage(dnSealCv, {tl: { col: 4, row: this.returnRow +2},
                                    ext: { width: 66.966, height: 62.37 }}); // 삽입할 셀 범위 설정
                                worksheet.addImage(dnLogoCv, {tl: { col: 2, row: this.returnRow -3}, br: { col: 4, row: this.returnRow -1},
                                    ext: { width: 206.988, height: 41.202 }}); // 삽입할 셀 범위 설정
                            }
                            

                            if(this.roleType == 'Manager'){
                                const dnDealerLogoCv = workbook.addImage({
                                base64: result.dnDealerLogoCv,
                                extension: 'png'
                                });
                                worksheet.addImage(dnDealerLogoCv, {tl: { col: 7, row: this.returnRow -4},
                                    ext: { width: 66.966, height: 62.37 }}); // 삽입할 셀 범위 설정
                            }else if(this.roleType == 'Worker'){
                                const dnDealerLogoCv = workbook.addImage({
                                base64: result.dnDealerLogoCv,
                                extension: 'png'
                                });
                                worksheet.addImage(dnDealerLogoCv, {tl: { col: 7, row: this.returnRow -8 },
                                    ext: { width: 66.966, height: 62.37 }}); // 삽입할 셀 범위 설정
                            }

                            const dnPrdCv = workbook.addImage({
                                base64: result.dnPrdCv,
                                extension: 'png'
                            });
                            worksheet.addImage(dnPrdCv, {tl: { col: 8, row: 9 },
                                ext: { width: 238, height: 174.31 }}); // 삽입할 셀 범위 설정
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
                console.error(error.message);
            }
        }
    }

    async populateWorksheet(worksheet, RDD) {
        try {
            this.currentRow     = 26;
            this.lineRow        = 27; // 첫 행을 27로 설정
            this.totalPrice     = '';
            this.prdTotalPrice  = [];
            this.cvTotalPrice   = [];
            this.returnRow      = 0;

            worksheet.getCell('F6').value = '견';
            worksheet.getCell('F6').font = {
                size : 20,
                bold : true
            };
            worksheet.getCell('G6').value = '적';
            worksheet.getCell('G6').font = {
                size : 20,
                bold : true
            };
            worksheet.getCell('H6').value = '서';
            worksheet.getCell('H6').font = {
                size : 20,
                bold : true
            };
            worksheet.mergeCells('C20:D20');
            worksheet.getRow(8).height = 38.25;
            worksheet.getRow(9).height = 38.25;
            worksheet.getColumn('A').width = 2;
            worksheet.getColumn('B').width = 2;
            worksheet.getColumn('D').width = 21.13;
            worksheet.getColumn('H').width = 11;
            worksheet.getColumn('I').width = 31;
            worksheet.getColumn('J').width = 14.25;
            worksheet.getColumn('K').width = 14.25;
            worksheet.getCell('E20').value = '원';
            //고정값
            worksheet.getCell('C3').value   = '견적번호 : ' + this.QuoteNumber;
            worksheet.getCell('C8').value   = this.AccountName + '         貴中';
            worksheet.getCell('C8').font = {
                size : 14,
                bold : true
            }
            worksheet.getCell('C8').border = { bottom : {style : 'thin'} };
            worksheet.getCell('D8').border = { bottom : {style : 'thin'} };

            // worksheet.getCell('C10').value  = '남기 예상일 : ' + this.ExpirationDate;
            worksheet.getCell('C10').value  = '납기 예상일 : ' + RDD;
            worksheet.getCell('C10').font = { size : 10 };
            worksheet.getCell('C11').value  = '인도 조건 : ' + this.Incoterms;
            worksheet.getCell('C11').font = { size : 10 };
            worksheet.getCell('C12').value  = '지불 조건 : ' + this.TermsOfPayment;
            worksheet.getCell('C12').font = { size : 10 };
            worksheet.getCell('C13').value  = '견적 작성 일 : ' + this.CreatedDate.split('-')[0] 
                                                               + '.' 
                                                               + this.CreatedDate.split('-')[1] 
                                                               + '.' 
                                                               + this.CreatedDate.split('-')[2];
            worksheet.getCell('C13').font = { size : 10 };
            worksheet.getCell('C14').value  = '견적 유효 기간 : 제출 일+1개월';
            worksheet.getCell('C14').font = { size : 10 };
            worksheet.getCell('C15').value  = '무상 보증 기간 : 부품 2년, 공임 1년 무상 제공';
            worksheet.getCell('C15').font = { size : 10 };
            worksheet.getCell('C18').value  = '예상 견적 가격 (VAT 별도)';
            worksheet.getCell('C18').font = {
                color : { argb: '0000FF' },
                size : 10
            }
            worksheet.getRow(19).height = 7;

            worksheet.getCell('C23').value = '제품 선택 사항';
            worksheet.getCell('C23').font = { bold : true };
            
            worksheet.getCell('I23').value = '수량';
            worksheet.getCell('I23').alignment = { horizontal : 'right'};
            worksheet.getCell('J23').value = '단가';
            worksheet.getCell('J23').alignment = { horizontal : 'right'};
            worksheet.getCell('K23').value = '금액';
            worksheet.getCell('K23').alignment = { horizontal : 'right'};

            const columns = ['C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];
            const setBorder = (row, style) => {
                columns.forEach(column => {
                    worksheet.getCell(`${column}${row}`).border = {
                        bottom: { style: style }
                    };
                });
            };
            
            const columns2 = ['C', 'D', 'I', 'J', 'K'];
            const setMiddle = (row) => {
                columns.forEach(columns2 => {
                    worksheet.getCell(`${columns2}${row}`).alignment = {
                        vertical: 'middle'
                   };
                });
            };

            // 초기 테두리 설정
            setBorder(4, 'thick');
            setBorder(24, 'thick');

            
            // console.log('1');
            for (let i = 0; i < this.QuoteLineItems.length; i++) {

                this.TotalPrice     = '';
                this.prdTotalPrice  = [];
                this.cvTotalPrice   = [];
                if(i == 0) {
                    // 기본 라인 설정
                    setBorder(this.lineRow, 'dashed');
                }else {
                    this.lineRow += 3;
                    this.currentRow += 3;
                    setBorder(this.lineRow, 'dashed');
                }
                
                worksheet.getCell('C' + this.currentRow).value = 'Model';
                worksheet.getCell('C' + this.currentRow).alignment = {
                    vertical: 'middle'
                };
                worksheet.getCell('C' + this.currentRow).font = {
                                size: 11,  // 글자 크기 (포인트 단위)
                                bold: true  // 굵은 글꼴 여부
                            };
                worksheet.getRow(this.currentRow).height = 34;
                worksheet.getCell('D' + this.currentRow).value  = this.QuoteLineItems[i].ModelName + '\n' + this.QuoteLineItems[i].ProductCode;
                worksheet.getCell('D' + this.currentRow).alignment = { wrapText: true }; // 줄바꿈 활성화
                worksheet.getCell('D' + this.currentRow).alignment = {
                    vertical: 'middle'
                };
                // worksheet.getCell('E' + this.currentRow).value  = this.QuoteLineItems[i].Desc;
                worksheet.getCell('E' + this.currentRow).value  = this.QuoteLineItems[i].Description;
                worksheet.getCell('E' + this.currentRow).alignment = { wrapText: true };
                worksheet.getCell('E' + this.currentRow).alignment = {
                    vertical: 'middle'
                };
                worksheet.getColumn('E').width = this.QuoteLineItems[i].DescLength;
                worksheet.getCell('I' + this.currentRow).value  = this.QuoteLineItems[i].Quantity;
                worksheet.getCell('I' + this.currentRow).alignment = {
                    vertical: 'middle'
                };
                worksheet.getCell('I8').value  = this.QuoteLineItems[i].ModelName;
                worksheet.getCell('I8').font = {
                    size : 14,
                    bold : true
                }
                worksheet.getCell('I9').value  = this.QuoteLineItems[i].ModelDescription;
                worksheet.getRow(9).height = 17.5;
                worksheet.getCell('I18').value  = '* 상기 대표 이미지는 제품 사양 및 구성에 따라 상이할 수 있습니다.';

                worksheet.getCell('J' + this.currentRow).value  = this.QuoteLineItems[i].TotalPrice;
                worksheet.getCell('J' + this.currentRow).alignment = {
                    vertical: 'middle'
                };
                worksheet.getCell('J' + this.currentRow).numFmt = '#,##0';
                worksheet.getCell('K' + this.currentRow).value  = {formula : 'I' + this.currentRow + '*J' + this.currentRow};
                worksheet.getCell('K' + this.currentRow).numFmt = '#,##0';
                worksheet.getCell('K' + this.currentRow).alignment = {
                    vertical: 'middle'
                };
                // setMiddle(this.currentRow);
                //소계에서 셀 참조 할 수 있게 저장
                this.prdQtyRow = this.currentRow;
                this.prdPriceRow = this.currentRow;

                this.currentRow += 3;
                worksheet.getCell('G' + this.currentRow).value  = '소계';
                // worksheet.getCell('I' + this.currentRow).value  = {formula : 'I' + this.prdQtyRow};
                // worksheet.getCell('J' + this.currentRow).value  = {formula : 'J' + this.prdPriceRow};
                worksheet.getCell('J' + this.currentRow).numFmt = '#,##0';
                worksheet.getCell('K' + this.currentRow).value  = {formula : 'K' + this.prdPriceRow};
                worksheet.getCell('K' + this.currentRow).numFmt = '#,##0';
                this.prdTotalPrice.push('K' + this.currentRow);


                this.lineRow += 3; // 기본적으로 3줄 증가
                setBorder(this.lineRow, 'thin');
            
                if (this.QuoteLineItems[i].CharacteristicValues.length > 0) {

                    this.currentRow += 3;
                    
                    // console.log('6');

                    this.cvFirstRow = this.currentRow; //cv의 첫번째 row 저장
                    for (let j = 0; j < this.QuoteLineItems[i].CharacteristicValues.length; j++) {
                        
                        if(j > 0){
                            this.currentRow++;
                        }
                        this.cvLastRow = this.currentRow; //cv마지막 row저장
                        var opVal = this.QuoteLineItems[i].CharacteristicValues[j].Option
                        worksheet.getCell('C' + this.currentRow).value  = opVal;
                        // console.log('option : ' + this.QuoteLineItems[i].CharacteristicValues[j].Option);
                        // worksheet.getCell('C' + this.currentRow).value  = 'Option';
    
                        worksheet.getCell('C' + this.currentRow).font = {
                            size: 11,  // 글자 크기 (포인트 단위)
                            bold: true  // 굵은 글꼴 여부
                        };
                        // worksheet.getCell('E' + this.currentRow).value  = this.QuoteLineItems[i].CharacteristicValues[j].Character + this.QuoteLineItems[i].CharacteristicValues[j].Value;
                        // console.log('desc : ' + this.QuoteLineItems[i].CharacteristicValues[j].Descrip);
                        worksheet.getCell('E' + this.currentRow).value  = this.QuoteLineItems[i].CharacteristicValues[j].Character;
                        worksheet.getCell('I' + this.currentRow).value  = this.QuoteLineItems[i].CharacteristicValues[j].cvQty;
                        worksheet.getCell('J' + this.currentRow).value  = this.QuoteLineItems[i].CharacteristicValues[j].Price;
                        worksheet.getCell('J' + this.currentRow).numFmt = '#,##0';
                        if(opVal == ""){
                            worksheet.getCell('K' + this.currentRow).value  = {formula : 'I' + this.currentRow + '*J' + this.currentRow};
                            worksheet.getCell('K' + this.currentRow).numFmt = '#,##0';
                        }
                        

                        if (j === this.QuoteLineItems[i].CharacteristicValues.length - 1) {
                            this.lineRow = this.currentRow + 1; // 각 CharacteristicValue마다 3줄 증가
                            setBorder(this.lineRow, 'dashed');
                            this.currentRow += 3;
                            worksheet.getCell('G' + this.currentRow).value  = '소계';
                            // worksheet.getCell('I' + this.currentRow).value  = {formula : 'SUM(I' + this.cvFirstRow + ':' + 'I' + this.cvLastRow + ')'};
                            // worksheet.getCell('J' + this.currentRow).value  = {formula : 'SUM(J' + this.cvFirstRow + ':' + 'J' + this.cvLastRow + ')'};
                            // worksheet.getCell('J' + this.currentRow).numFmt = '#,##0';
                            // worksheet.getCell('K' + this.currentRow).value  = {formula : 'I' + this.currentRow + '*J' + this.currentRow};
                            worksheet.getCell('K' + this.currentRow).value  = {formula : 'SUM(K' + this.cvFirstRow + ':' + 'K' + this.cvLastRow + ')'};
                            worksheet.getCell('K' + this.currentRow).numFmt = '#,##0';
                            this.cvTotalPrice.push('K' + this.currentRow);
                            this.lineRow += 3; // 마지막 CharacteristicValue에서는 추가로 3줄 증가

                            if (i === this.QuoteLineItems.length - 1) {
                                setBorder(this.lineRow, 'thick');
                            } else {
                                setBorder(this.lineRow, 'thin');
                            }
                        }
                    }
                    
                } else {

                    this.currentRow += 3;
                    worksheet.getCell('C' + this.currentRow).value  = 'Option';
                    worksheet.getCell('C' + this.currentRow).font = {
                        size: 11,  // 글자 크기 (포인트 단위)
                        bold: true  // 굵은 글꼴 여부
                    };
                    worksheet.getCell('I' + this.currentRow).value  = 0;
                    worksheet.getCell('J' + this.currentRow).value  = 0;
                    worksheet.getCell('K' + this.currentRow).value  = 0;

                    this.lineRow = this.currentRow + 1; // 각 CharacteristicValue마다 3줄 증가
                    setBorder(this.lineRow, 'dashed');
                    this.currentRow += 3;
                    worksheet.getCell('G' + this.currentRow).value  = '소계';
                    worksheet.getCell('I' + this.currentRow).value  = 0;
                    worksheet.getCell('J' + this.currentRow).value  = 0;
                    worksheet.getCell('K' + this.currentRow).value  = 0;

                    this.lineRow = this.currentRow + 1; // 각 CharacteristicValue마다 3줄 증가
                    if (i === this.QuoteLineItems.length - 1) {
                        setBorder(this.lineRow, 'thick');
                    } else {
                        setBorder(this.lineRow, 'thin');
                    }
                }
                
            }
            this.prdTotalPrice.forEach((result, index) => {
                // 인덱스를 사용하여 마지막 요소인지 확인
                if (index === this.prdTotalPrice.length - 1) {
                    this.totalPrice += result;
                // console.log('여기2 : ' + this.totalPrice);

                } else {
                    this.totalPrice += result + '+';
                // console.log('여기1 : ' + this.totalPrice);

                }
            });
            this.cvTotalPrice.forEach(result => {
                this.totalPrice += '+' + result;
                // console.log('여기3 : ' + this.totalPrice);
            })
            
            this.currentRow += 3;
            // console.log(this.totalPrice);
            worksheet.getCell('G' + this.currentRow).value = '총 예상 구입가 (VAT 별도)';
            worksheet.getCell('G' + this.currentRow).font = { bold : true };
            worksheet.getCell('G' + this.currentRow).fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFD9E1F2' }  // RGB 217, 225, 242에 해당하는 ARGB 값
            };
            worksheet.getCell('H' + this.currentRow).fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFD9E1F2' }  // RGB 217, 225, 242에 해당하는 ARGB 값
            };
            worksheet.getCell('I' + this.currentRow).fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFD9E1F2' }  // RGB 217, 225, 242에 해당하는 ARGB 값
            };
            worksheet.getCell('J' + this.currentRow).fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFD9E1F2' }  // RGB 217, 225, 242에 해당하는 ARGB 값
            };
            worksheet.getCell('K' + this.currentRow).value  = {formula : this.totalPrice};
            worksheet.getCell('K' + this.currentRow).numFmt = '#,##0';
            worksheet.getCell('K' + this.currentRow).font = { bold : true };
            worksheet.getCell('K' + this.currentRow).fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFD9E1F2' }  // RGB 217, 225, 242에 해당하는 ARGB 값
            };
            worksheet.getCell('C20').value  = {formula : 'K' + this.currentRow};
            worksheet.getCell('C20').font = {
                size : 22
            }
            worksheet.getCell('C20').numFmt = '#,##0'; //천원자리에 , 콤마 처리

            this.currentRow += 2;
            worksheet.getCell('C' + this.currentRow).value = '알립니다.';
            worksheet.getCell('C' + this.currentRow).font = {
                size : 14,
                bold : true
            };

            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = ' - 본 견적서는 고객님의 의사결정에 도움이 되고자 작성한 것으로 법적인 효력은 없으며, 계약 내용은 최종 계약서를 기준으로 합니다.';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};
            
            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = ' - 최종 계약 시, 기계 매매대금은 디엔솔루션즈 전용계좌 또는 디엔솔루션즈 지정 영업대리점 전용계좌로 입금하셔야 합니다.';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};

            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = '   당사는 타 계좌 입금으로 발생되는 문제에는 책임지지 않습니다. (대납 피해 주의!)';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};
            
            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = ' - 제품 설치 공장의 유틸리티 준비는 고객사(User)에서 준비하여야 합니다. ';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};
                        
            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = '   (예시, 공장 전원 220V아닐 경우 변압기(Transformer) 준비, 항온항습 필요시설 준비, 에어컴프레셔 준비 등)';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};
                                    
            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = ' - 본 제품은 국외 수출시 대외무역법 제 19조 제 1,2항 및 동법 시행령 제 33조에 따라 반드시 산업통상자원부로부터 전략물자 수출허가를 ';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};
                                                
            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = '   득하여야 함을 고지하며, 제 3자 양도 또는 재 판매(중고 거래)할 경우에도 동일한 의무사항을 준수해야 합니다. ';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};
                                                            
            this.currentRow++;
            worksheet.getCell('C' + this.currentRow).value = ' - 상기 견적 제출 후 당사 가격 및 정책 변경에 따라 동일 조건의 제품에 대한 견적이 일치하지 않을 수 있습니다.';
            worksheet.getCell('C' + this.currentRow).font = { size : 10};

            this.currentRow += 3;
            worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };

            this.currentRow++;
            worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };

            this.currentRow++;
            worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };

            this.tempRow = this.currentRow + 2;
            worksheet.getCell('F' + this.tempRow).border = { right : {style : 'thin'} };
            worksheet.getCell('C' + this.tempRow).value = '경남 창원시 성산구 정동로 162번길 40';
            if(this.roleType == 'Manager' || this.roleType == 'Worker'){
                worksheet.getCell('I' + this.currentRow).value = this.distiName; //대리점명
            }else{
                worksheet.getCell('I' + this.currentRow).value = this.quotesalesoffice;
            }

            this.currentRow++;
            worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
            this.tempRow = this.currentRow + 2;
            worksheet.getCell('F' + this.tempRow).border = { right : {style : 'thin'} };
            worksheet.getCell('C' + this.tempRow).value = '대표번호 : 055-280-4114';
            worksheet.getCell('I' + this.currentRow).value = this.quoteaddress;
            
            this.currentRow++;
            worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
            if(this.roleType == 'Manager' || this.roleType == 'Worker'){
                worksheet.getCell('I' + this.currentRow).value = this.distiRep; //대표자
            }else{
                worksheet.getCell('I' + this.currentRow).value = this.mainphone;
            }
            
            this.currentRow++;
            worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
            this.tempRow = this.currentRow + 3;
            worksheet.getCell('F' + this.tempRow).border = { right : {style : 'thin'} };
            worksheet.getCell('C' + this.tempRow).value = '대표이사 김 원 종';
            worksheet.getCell('C' + this.tempRow).font = {
                size : 14,
                bold : true
            };
            if(this.roleType == 'Manager' || this.roleType == 'Worker'){
                worksheet.getCell('I' + this.currentRow).value = this.mainphoneRep; //대표번호
            }else{
                worksheet.getCell('I' + this.currentRow).value = this.mobilephone;
            }

            if(this.roleType == 'Manager' || this.roleType == 'Worker'){
                this.currentRow++;
                worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
                worksheet.getCell('I' + this.currentRow).value = this.mobilephoneRep; //대표휴대폰
            }else{
                this.currentRow++;
                worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
                worksheet.getCell('I' + this.currentRow).value = this.mainEmail; //직영 이메일
            }
            if(this.roleType == 'Manager' || this.roleType == 'Worker'){
                this.currentRow++;
                worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
                worksheet.getCell('I' + this.currentRow).value = this.mailRep; //대표Email
            }
            
            if(this.roleType == 'Worker'){
                this.currentRow++;
                worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
                this.currentRow++;
                worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
                worksheet.getCell('I' + this.currentRow).value = this.quotesalesoffice; //대리점 직원

                this.currentRow++;
                worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
                worksheet.getCell('I' + this.currentRow).value = this.mobilephone; //대리점 휴대폰

                this.currentRow++;
                worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };
                worksheet.getCell('I' + this.currentRow).value = this.mainEmail; //대리점 직원 이메일
            }
                        
            this.currentRow++;
            worksheet.getCell('F' + this.currentRow).border = { right : {style : 'thin'} };



        return this.currentRow - 3;
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