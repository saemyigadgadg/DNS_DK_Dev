import { LightningElement, api, track } from 'lwc';
import { showToast, style, label } from 'c/commonUtils';
import { loadScript } from 'lightning/platformResourceLoader';
import XLSX from '@salesforce/resourceUrl/ExcelJS';
import getInfo from '@salesforce/apex/DN_QuotationExportController.getInfo';
import saveFile from '@salesforce/apex/DN_QuotationExportController.saveFile';

export default class DNSA_CVExport extends LightningElement {
    @api recordId;
    @track isLoading    = false;
    excelJsLoaded       = false;
    ProductName         = '';
    CVInfo              = [];
    currentRow          = 0;
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
            // console.log('result.CVInfo : ' + JSON.stringify(result.CVInfo));
            if(result.CVInfo.length == 0){
                showToast(this, 'ERROR','ERROR', 'No Characteristic Values');
                this.isLoading = false;
                this.dispatchEvent(new CustomEvent('loadingcomplete'));

            }else{
                this.ProductName        = result.ProductName;
                this.CVInfo  = result.CVInfo;
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
                    this.CVInfo;
                    const worksheet = workbook.addWorksheet('CV');

                    await this.populateWorksheet(worksheet)
                    .then(result => {
                        this.returnRow = result;
                    }).catch(error => {
                        console.log('error : ' + error);
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
        try{
            worksheet.getColumn('A').width = 9;
            worksheet.getColumn('B').width = 40;
            worksheet.getColumn('C').width = 9;
            worksheet.getColumn('D').width = 40;
            worksheet.getColumn('E').width = 9;

            // console.log('this.CVInfo.length : ' + this.CVInfo.length);
            this.currentRow               = 2;
            worksheet.getCell('A1').value = 'C Code';
            worksheet.getCell('A1').font = {bold : true};

            worksheet.getCell('B1').value = 'C Description';
            worksheet.getCell('B1').font = {bold : true};

            worksheet.getCell('C1').value = 'V Code';
            worksheet.getCell('C1').font = {bold : true};

            worksheet.getCell('D1').value = 'V Description';
            worksheet.getCell('D1').font = {bold : true};

            worksheet.getCell('E1').value = 'Changed';
            worksheet.getCell('E1').font = {bold : true};

            for(var i = 0; i < this.CVInfo.length; i++){
                var num = i + this.currentRow;
                worksheet.getCell('A' + num).value = this.CVInfo[i].C_Code__c;
                worksheet.getCell('B' + num).value = this.CVInfo[i].C_Value__c;
                worksheet.getCell('C' + num).value = this.CVInfo[i].V_Code__c;
                worksheet.getCell('D' + num).value = this.CVInfo[i].V_Value__c;
                if(this.CVInfo[i].defChange__c == true){
                    worksheet.getCell('E' + num).value = 'O';
                    worksheet.getCell('E' + num).alignment = {
                        vertical: 'middle',
                        horizontal: 'center'
                   };
                    worksheet.getCell('A' + num).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FF30CA55' }
                    };
                    worksheet.getCell('B' + num).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FF30CA55' }
                    };
                    worksheet.getCell('C' + num).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FF30CA55' }
                    };
                    worksheet.getCell('D' + num).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FF30CA55' }
                    };
                    worksheet.getCell('E' + num).fill = {
                        type : 'pattern',
                        pattern: 'solid',
                        fgColor: { argb : 'FF30CA55' }
                    };

                }
            }
            const buffer = await workbook.xlsx.writeBuffer();
            this.downloadExcelFile(buffer);
            const base64Data = this.arrayBufferToBase64(buffer);
            const fileName = `${this.ProductName}.xlsx`;
            await saveFile({ base64Data, fileName, parentId: this.recordId });

            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('loadingcomplete'));

        }catch(error){
            console.log('populateWorksheet error : ' + JSON.stringify(error.message));
        }
    }

    downloadExcelFile(buffer) {
        const base64Data = this.arrayBufferToBase64(buffer);
        const link = document.createElement('a');
        const name = this.ProductName + '.xlsx';
    
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