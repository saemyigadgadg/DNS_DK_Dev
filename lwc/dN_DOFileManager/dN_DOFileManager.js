import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { showToast, reduceErrors} from 'c/commonUtils';
import customLabels from "./labels";
import formFactor from '@salesforce/client/formFactor';


import uploadFile from '@salesforce/apex/DN_DOFileManagerController.uploadFile';
import deleteFile from '@salesforce/apex/DN_DOFileManagerController.deleteFile';
import getUploadedFiles from '@salesforce/apex/DN_DOFileManagerController.getUploadedFiles';
import getFlagSentERP from '@salesforce/apex/DN_DOFileManagerController.getFlagSentERP';

export default class DN_DOFileManager extends NavigationMixin(LightningElement) {

    @api recordId;
    @track fileFields = [];

    isLoading = false;
    isSentERP = false;
    isPortal  = false;

    cLabel = customLabels;

    defaultFields = [
        { name: 'bizReg', label: customLabels.DNS_C_BizRegistrationCertificate, fileId: null, fileName: null, publicURL: null },
        { name: 'map',    label: customLabels.DNS_C_ShippingAddressMap, fileId: null, fileName: null, publicURL: null },
        { name: 'bond',   label: customLabels.DNS_C_Bond, fileId: null, fileName: null, publicURL: null }
    ];

    async connectedCallback() {
        // this.fileFields = structuredClone(this.defaultFields);
        await this.checkSentERP();
        await this.loadUploadedFiles();

        if(formFactor == 'Large') {
            const baseUrl = window.location.pathname;
            this.isPortal = baseUrl.includes('/s/') || baseUrl.includes('/c/');
        }
    }

    async checkSentERP(){
        getFlagSentERP({recordId : this.recordId})
        .then(result => this.isSentERP = result)
        .catch(error => this.errorHandler('getFlagSentERP', error));
    }

    async loadUploadedFiles() {
        this.isLoading = true;
        this.fileFields = structuredClone(this.defaultFields);
        
        await getUploadedFiles({ recordId: this.recordId })
        .then(result => {
            console.log('loadUploadedFiles ::: ', JSON.stringify(result, null, 2));
            
            this.fileFields = this.fileFields.map(field => {
                const file = result.find(f => f.fileType === field.name);
                if (file) {
                    field.fileId    = file.fileId;
                    field.fileName  = file.fileName;
                    field.publicURL = file.publicURL;
                } else {
                    field.fileId    = null;
                    field.fileName  = null;
                    field.publicURL = null;
                }
                return field;
            });
        })
        .catch(error => this.errorHandler('getUploadedFiles', error))
        .finally(() => this.isLoading = false);
    }

    async handleFileChange(event) {
        this.isLoading = true;
        const fileInput = event.target.files[0];
        const fieldName = event.target.dataset.name;
        const MAX_SIZE = 2 * 1024 * 1024; // 2MB
        console.log('handleFileChange', fieldName, fileInput, MAX_SIZE);

        if (fileInput.size > MAX_SIZE) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_FileSizeError);
            const prevFileInput = this.template.querySelector(`input[type="file"][data-name="${fieldName}"]`);
            if(prevFileInput) { prevFileInput.value = null; }
            this.isLoading = false;
            return;
        }

        if (fileInput) {
            const reader = new FileReader();
            reader.onload = async () => {
                const base64 = reader.result.split(',')[1];
                await uploadFile({
                    fileName : fileInput.name
                    , base64Data : base64
                    , contentType : fileInput.type
                    , fileType: fieldName
                    , recordId : this.recordId
                })
                .then(result => {
                    console.log('uploadFile', JSON.stringify(result, null, 2));
                    this.dispatchEvent(new CustomEvent('force:refreshView'));
                    this.loadUploadedFiles();
                })
                .catch(error => this.errorHandler('uploadFile', error))
                .finally(() => this.isLoading = false);
            };
            reader.readAsDataURL(fileInput);
        }
    }

    async handleDeleteFile(event) {
        this.isLoading = true;
        const fileId = event.target.dataset.id;

        await deleteFile({fileId : fileId})
        .then(()=> {
            this.fileFields = this.fileFields.map((field) => {
                if (field.fileId === fileId) {
                    field.fileId = null;
                    field.fileName = null;
                }
                return field;
            });
            this.dispatchEvent(new CustomEvent('force:refreshView'));
        })
        .catch(error => this.errorHandler('uploadFile', error))
        .finally(() => this.isLoading = false);
    }


    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.log(name, errorMsg);
        showToast(this, 'error', customLabels.DNS_M_GeneralError, errorMsg);
    }

    previewHandler(event) {
        const fileId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: fileId
            }
        });
    }

}