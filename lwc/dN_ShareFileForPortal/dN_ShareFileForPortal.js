import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';

import formFactor from '@salesforce/client/formFactor';
import LightningConfirm from 'lightning/confirm';

import customLabels from "./labels";
import { showToast, reduceErrors, style } from 'c/commonUtils';

import fetchInit from '@salesforce/apex/DN_ShareFileForPortalController.fetchInit';
import uploadFiles from '@salesforce/apex/DN_ShareFileForPortalController.uploadFiles';
import deleteFile from '@salesforce/apex/DN_ShareFileForPortalController.deleteFile';

const COLUMNS = [
    { label: customLabels.DNS_F_FileName, fieldName: 'cdId', type: 'button', initialWidth: 250
        , typeAttributes: {
            label: { fieldName: 'title' }, name: 'preview', variant: 'base' 
        }
        , cellAttributes: {
            class: 'slds-truncate file_name_style'
        }
    }
    , { label: customLabels.DNS_C_OwnerName, fieldName: 'ownerName', initialWidth: 200}
    , { label: customLabels.DNS_C_LastModifiedDate, fieldName: 'lastModifiedDate', type: 'date-local', initialWidth: 200}
    , { type: 'button-icon', initialWidth: 50,
        typeAttributes: {
            iconName: 'utility:delete', name: 'delete', alternativeText: 'Delete', title: 'Delete', variant: 'bare'
        }
    }
];

export default class DN_ShareFileForPortal extends NavigationMixin(LightningElement) {

    @api recordId;

    @track isPortal = true;
    @track isShow   = false;

    @track tableColumns = COLUMNS;
    @track tableFiles   = [];

    isLoading = false;
    cLabel    = customLabels;
    cardIcon = 'standard:file';



    get cardTitle(){
        let baseTitle = this.isPortal ? customLabels.Files : customLabels.DNS_H_PortalFileTitle;
        return baseTitle + ' (' + this.tableFiles.length + ')';
    }

    get isDataShow(){
        return this.tableFiles.length > 0;
    }

    get componentStyle(){
        let componentCss = this.isShow ? 'shared_file_wrapper' : 'shared_file_wrapper hide_component';
        return componentCss;
    }

    get table_style(){
        return this.tableFiles.length > 5 ? 'slds-card__body file_datatable' : 'slds-card__body';
    }



    async connectedCallback(){
        style.set(this.customstyle);

        this.reverseSpinner();

        if(formFactor == 'Large') {
            const baseUrl = window.location.pathname;
            this.isPortal = baseUrl.includes('/s/') || baseUrl.includes('/c/');
        }
        
        await this.doInit();
        
        this.reverseSpinner();
    }

    disconnectedCallback() {
        style.remove(this.customstyle);
    }

    renderedCallback(){
        console.log('renderedCallback');
        
    }


    /** handler */
    async handleFileChange(event){
        this.reverseSpinner();
        const files = event.target.files;
        if (!files.length) return;
        
        console.log('handleFileChange', JSON.stringify(files, null, 1));

        let fileList = [];
        let promises = [];
        Array.from(files).forEach(file => {
            const reader = new FileReader();
            const promise = new Promise((resolve, reject) => {
                reader.onload = () => {
                    fileList.push({ fileName: file.name, base64Data: reader.result.split(',')[1] });
                    resolve();
                };
                reader.onerror = error => reject(error);
            });
            reader.readAsDataURL(file);
            promises.push(promise);
        });

        Promise.all(promises)
        .then(() => {
            console.log('handleFileChange - fileList ::: ', JSON.stringify(fileList, null, 1));
            return uploadFiles({ recordId: this.recordId, files: fileList });
        })
        .then(() => {
            showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_FileSuccess);
            this.doInit();
        })
        .catch(error => this.errorHandler('handleFileChange', error))
        .finally(() => this.reverseSpinner());
    }

    async handleRowAction(event){
        const row = event.detail.row;
        const actionName = event.detail.action.name;
        console.log('handleRowAction - ', actionName, JSON.stringify(event.detail.row));

        if(actionName == 'delete'){
            this.reverseSpinner();

            await LightningConfirm.open({
                message : customLabels.DNS_M_DeleteFileConfirm
                , variant: 'headerless'
                , style: 'background-color: red;'
            })
            .then(result => {
                console.log('handleRowAction - delete confirm ::: ' + result);
                if(result) {
                    deleteFile({ cdId: row.cdId })
                    .then(() => {
                        showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_DeleteFileSuccess);
                        this.doInit();
                        this.reverseSpinner();
                    });
                } else {
                    this.reverseSpinner();
                }
            });

        } else if(actionName == 'preview'){

            // portal 사용 불가
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: { pageName: 'filePreview' },
                state: { selectedRecordId: row.cdId }
            });
        }
    }

    /** private function */
    reverseSpinner(){
        this.isLoading = !this.isLoading;
    }

    async doInit(){
        
        await fetchInit({recordId : this.recordId})
        .then(result => {
            this.isShow     = result.data.isShow;
            this.tableFiles = result.data.files;
        })
        .catch(error => this.errorHandler('fetchInit', error));

        getRecordNotifyChange([{ recordId: this.recordId }]);
        this.dispatchEvent(new RefreshEvent());

        console.log('doInit result ::: ', this.isPortal, this.isShow);
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.error(name, errorMsg);
        showToast(this, 'error', customLabels.DNS_M_GeneralError, errorMsg);
    }

    customstyle = {
        id: 'dN_ShareFileForPortal',
        style: `
            .hide_component {
                display: none;
            }

            .shared_file_wrapper .slds-file-selector
            , .shared_file_wrapper .slds-file-selector__dropzone {
                width: 100%;
                height: 4rem;
                align-content: center;
                text-align: center;
            }

            .file_name_style .slds-button{
                white-space: nowrap;
            }
        `,
    }
}