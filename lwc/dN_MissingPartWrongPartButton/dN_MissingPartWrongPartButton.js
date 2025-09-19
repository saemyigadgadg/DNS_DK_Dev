import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import createTicket from '@salesforce/apex/DN_MissingPartWrongPartController.createTicket';
import uploadFileContentVersion from '@salesforce/apex/DN_MissingPartWrongPartController.uploadFileContentVersion';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class DN_MissingPartWrongPartButton extends LightningElement {
    @track model = '';
    @track manufacturingNumber = '';
    @track dispatchStatus = '출동';
    @track completionStatus = '완료';
    @track receiptDetails = '';
    @track isModalOpen = true;
    @track accountId = '';
    @track contactId = '';
    @track assetId = '';
    @track uploadedFileIds = [];
    @track isLoading = false;
    @track isSubmitDisabled = true;
    @track filesToUpload = [];
    @track fileNames = [];

    @api recordId;

    flowApiName = 'CS_FieldServiceMobileFlow';
    isFlowVisible = false;

    cLabel = label;

    // connectedCallback() {
    //     this.isLoading = true;

    //     getWorkOrder({ recordId: this.recordId })
    //         .then(result => {
    //             console.log('flag1:::');
    //             console.log('WorkOrder 데이터:::', result);
    //             console.log('flag2:::');
    //             if (result.status === 'NO_DATA') {
    //                 console.log('flag5:::');
    //                 this.isSubmitDisabled = false;
    //                 this.accountId = result.accountId || '';
    //                 this.contactId = result.contactId || '';
    //                 this.assetId = result.assetId || '';

    //                 console.log('accountId:::', this.accountId);
    //                 console.log('contactId:::', this.contactId);
    //                 console.log('assetId:::', this.assetId);
    //             } else if (result.status === 'NO_INSTALL') {
    //                 console.log('flag3:::');
    //                 this.showToast('error', '설치오더가 아닙니다. 미오후납을 생성 불가능합니다.', 'error');
    //                 this.isSubmitDisabled = true;
    //             } else {
    //                 console.log('flag4:::');
    //                 // this.isSubmitDisabled - false;
    //                 this.accountId = result.accountId || '';
    //                 this.contactId = result.contactId || '';
    //                 this.assetId = result.assetId || '';
    //                 // this.accountId = result.accountId ? result.accountId : '';
    //                 // this.contactId = result.contactId ? result.contactId : '';
    //                 // this.assetId = result.assetId ? result.assetId : '';
    //                 console.log('accountId:::', this.accountId);
    //                 console.log('contactId:::', this.contactId);
    //                 console.log('assetId:::', this.assetId);
    //             }
                
    //         })
    //         .catch(error => {
    //             console.error('WorkOrder 조회 오류:', error);
    //         })
    //         .finally(() => {
    //             this.isLoading = false;
    //         });
    // }


    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            console.log('Flow completed successfully.');
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.zip', '.xlsx', '.csv', '.doc', '.docx', '.mp4'];
    }

    handleFileChange(event) {
        const files = Array.from(event.target.files); // FileList를 배열로 변환
        this.fileNames = [];
        if (files.length > 0) {
            for (let i = 0; i < files.length; i++) {
                this.fileNames.push(files[i].name);
            }
            this.filesToUpload = files;
            console.log('Files selected:', this.filesToUpload);
        } else {
            console.log('No files selected');
        }
    }

    async handleSubmit() {
        if (this.isSubmitDisabled) {
            return;
        }

        this.isLoading = true;

        try {
            const fileIds = await this.uploadFiles();
            await createTicket({
                accountId: this.accountId,
                contactId: this.contactId,
                assetId: this.assetId,
                receiptDetails: this.receiptDetails,
                uploadedFileIds: fileIds
            });

            this.showToast('Success', label.DNS_FSL_CaseFileUploadComplete, 'success');
            this.dispatchEvent(
                new CloseActionScreenEvent()
            );
            this.isModalOpen = false;
        } catch (error) {
            console.log('error:::'+ JSON.stringify(error));
            this.showToast('Error', label.DNS_FSL_SavingValue+`: ${error.message}`, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async uploadFiles() {
        const uploadedFileIds = [];
        for (let file of this.filesToUpload) {
            const base64Data = await this.readFileAsBase64(file);
            const result = await uploadFileContentVersion({
                fileName: file.name,
                base64Data: base64Data,
                contentType: file.type
            });
            uploadedFileIds.push(result);
        }
        return uploadedFileIds;
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result.split(',')[1]);
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    handleUploadFinished(event) {
        console.log('나 눌렸우');
        console.log('uploadedFileIds:::'+this.uploadedFileIds);
        const uploadedFiles = event.detail.files;
        this.uploadedFileIds = uploadedFiles.map(file => file.documentId);
        // alert('No. of files uploaded : ' + this.uploadedFileIds.length);
    }

    handleNewFile() {
        this.isFlowVisible = true;
        const flowParams = [
            { name: 'Id', type: 'String', value: this.recordId }
        ];
        
        setTimeout(() => {
            const flow = this.template.querySelector('lightning-flow');
            if (flow) {
                flow.startFlow(this.flowApiName, flowParams);
            }
        }, 0);
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            console.log('Flow execution completed.');
            this.isFlowVisible = false;
        } else if (event.detail.status === 'ERROR') {
            console.error('Flow execution error:', event.detail.error);
        }
    }

    renderedCallback() {
        const fileListContainer = this.template.querySelector('.file-list-container');
        if (fileListContainer) {
            fileListContainer.textContent = `Number of files: ${this.filesToUpload.length}`;
        }
        const style = document.createElement('style');
        style.innerText = `
        .total-wrap .slds-form-element__label{
            font-size: 18px !important;
            word-wrap: nowrap !important;
        }
        .total-wrap .box-03 .total-wrap .slds-form-element__label{
            font-size: 1.25rem !important;
        }
        .total-wrap .box-04 .slds-textarea{
            min-height: 8rem;
            font-size: 18px;
        }
        .total-wrap .box-04 .slds-form-element__label{                                                                                                                                                   
            font-weight: 600;
        }
        .button-wrap .slds-button_brand{
            padding: 0.5rem 0;
            font-weight: 600;
            font-size: 1.125rem;
            width: 100%;
        }
        .total-wrap .slds-input{
            border: 1px solid #aeaeae !important;
        }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

    submitDisabled() {
        this.isSubmitDisabled = !(this.accountId && this.contactId && this.assetId && this.receiptDetails);
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field === '접수내용') {
            this.receiptDetails = event.target.value;
        }
        this.submitDisabled();
    }
    // handleRecordPickerChange(event) {
    //     const fieldName = event.target.name;
    //     const selectedRecordId = event.detail.value;

    //     if (fieldName === '고객사') {
    //         this.accountId = selectedRecordId;
    //         console.log('this.accountId:::' + this.accountId);
    //     } else if (fieldName === '담당자') {
    //         this.contactId = selectedRecordId;
    //         console.log('this.contactId:::' + this.contactId);
    //     } else if (fieldName === '장비') {
    //         this.assetId = selectedRecordId;
    //         console.log('this.assetId:::' + this.assetId);
    //     }
    //     // this.submitDisabled();
    // }
    handleRecordPickerChange(event) {
        console.log('Event Detail:', event.detail);
        const field = event.target.name;
        let selectedId = '';

        if (field === '고객사') {
            this.accountId = event.detail.recordId;
            selectedId = this.accountId;
        } else if (field === '담당자') {
            this.contactId = event.detail.recordId;
            selectedId = this.contactId;
        } else if (field === '장비') {
            this.assetId = event.detail.recordId;
            selectedId = this.assetId;
        }
        this.submitDisabled();

    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
    
    closeScreen() {
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}