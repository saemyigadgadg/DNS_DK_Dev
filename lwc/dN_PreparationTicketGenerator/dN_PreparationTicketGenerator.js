import { LightningElement, api } from 'lwc';

import XLSX from '@salesforce/resourceUrl/ExcelJS';
import { loadScript } from 'lightning/platformResourceLoader';

import { showToast, label, reduceErrors } from 'c/commonUtils';
import { createSheet1, createSheet2 } from './preparationChecklist.js';

import fetchPreChecklist from '@salesforce/apex/DN_PreparationTicketController.fetchPreChecklist';
import uploadFile from '@salesforce/apex/DN_PreparationTicketController.uploadFile';

export default class DN_PreparationTicketGenerator extends LightningElement {
    @api recordId;

    cLabel = label;
    excelJsLoaded = false;

    _data      = [];
    _tableMap  = [];
    _images    = [];
    _imageUrls = [];
    // _language = '';

    _fileName;
    _base64;

    async connectedCallback(){
        console.log('connectedCallback', this.recordId);
        
        await loadScript(this, XLSX + '/unpkg/exceljs.min.js')
        .then(() => this.excelJsLoaded = true )
        .catch(error => this.errorHandler('loadScript', error));

        await this.validateRecord();
        await this.createExcelFile();
        await this.fileUpload();
    }

    async validateRecord(){

        await fetchPreChecklist({recordId : this.recordId})
        .then(result => {
            // console.log('fetchPreChecklist result ::: ', JSON.stringify(result, null, 2));
            this._data     = result.preList;
            this._tableMap = result.tableMap;
            this._images   = result.base64ImageList;
            // this._language = result.language;
            this._imageUrls = result.imageUrls;
        })
        .catch(error => {
            this.errorHandler('fetchPreChecklist', error);
            this.closeModal();
        });
    }

    async createExcelFile(){
        if (this.excelJsLoaded) {
            const workbook = new ExcelJS.Workbook();
            const sheet1   = workbook.addWorksheet(label.DNS_C_PreparationChecklist);
            const sheet2   = workbook.addWorksheet(label.DNS_C_LocationMap);

            const logo  = workbook.addImage({base64: this._imageUrls.preparationchecklist_logo,  extension: 'png'});
            const ppt01 = workbook.addImage({base64: this._imageUrls.preparationchecklist_ppt01, extension: 'png'});
            const ppt02 = workbook.addImage({base64: this._imageUrls.preparationchecklist_ppt02, extension: 'png'});

            // createSheet1(sheet1, this._language, this._data, this._tableMap);
            // createSheet1(sheet1, this._data, this._tableMap);
            createSheet1(sheet1, this._data, this._tableMap, logo, ppt01, ppt02);
            if(this._images && this._images.length > 0) { createSheet2(workbook, sheet2, this._images); }

            const today    = new Date();
            const year     = today.getFullYear();
            const month    = String(today.getMonth() + 1).padStart(2, '0');
            const day      = String(today.getDate()).padStart(2, '0');
            // this._fileName = `${label.DNS_C_PreparationChecklist}_${year}${month}${day}.xlsx`;
            this._fileName = `설치시운전 고객사 사전설치 점검표_${year}${month}${day}.xlsx`;

            const buffer = await workbook.xlsx.writeBuffer();
            this._base64 = btoa(new Uint8Array(buffer).reduce((data, byte) => data + String.fromCharCode(byte), ''));

            // download
            // workbook.xlsx.writeBuffer().then(buffer => {
            //     const blob = new Blob([buffer], { type: 'application/octet-stream' });
            //     const link = document.createElement('a');
            //     link.href = URL.createObjectURL(blob);
            //     link.download = `${label.DNS_C_PreparationChecklist}_${year}${month}${day}.xlsx`;
            //     link.click();
            // });
        }
    }

    async fileUpload(){
        await uploadFile({fileName : this._fileName, file : this._base64, recordId : this.recordId})
        .then(() => this.handleSuccess())
        .catch(error => {
            this.errorHandler('fileUpload', error);
            this.closeModal();
        });
    }

    handleSuccess(){
        showToast(this, 'success', label.DNS_M_Success, label.DNS_M_PreparationTicketCreation);
        // Successfully reflected in the ticket.
        this.closeModal();
    }

    handleClose(){
        this.closeModal();
    }

    closeModal(msg){
        this.dispatchEvent(new CustomEvent('close', {detail: {value : msg}}));
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];

        if(errorMsg.includes('first error:')) errorMsg = errorMsg.split('first error:')[1];
        
        console.log(name, errorMsg);
        showToast(this, 'error', label.DNS_M_GeneralError, errorMsg);
    }



    
}