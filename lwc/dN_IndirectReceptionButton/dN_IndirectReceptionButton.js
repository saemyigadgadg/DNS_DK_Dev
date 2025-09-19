import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createTicket from '@salesforce/apex/DN_IndirectReceptionController.createTicket';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
// import searchAccounts from '@salesforce/apex/DN_IndirectReceptionController.searchAccounts';

export default class DN_IndirectReceptionButton extends LightningElement {

    @track model = '';
    @track onSiteDateTime;
    @track manufacturingNumber = '';
    @track dispatchStatus = 'Dispatch';
    @track completionStatus = 'Complete';
    @track receiptDetails = '';
    @track isModalOpen = true;
    @track accountId = '';
    @track contactId = '';
    @track assetId = '';
    @api recordId;
    @track isLoading = false;
    @track isSubmitDisabled = true;

    // Account 검색
    // @track matchingAccInfo = [];
    // @track displayAccInfo = [];

    cLabel = label;


    dispatchOptions = [
        { label: label.DNS_FSL_Dispatch, value: 'Dispatch' },
        { label: label.DNS_FSL_NotDispatched, value: 'Not Dispatch' },

    ];

    completionOptions = [
        { label: label.DNS_FSL_Complete, value: 'Complete' },
        { label: label.DNS_FSL_Incomplete, value: 'Not Complete' }
    ];

    renderedCallback() {
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
        // 기존 코드
        // const field = event.target.name;
        // if (field === '기종') {
        //     this.model = event.target.value;
        // } else if (field === '제조번호') {
        //     this.manufacturingNumber = event.target.value;
        // } else if (field === '접수내용') {
        //     this.receiptDetails = event.target.value;
        // }

        const field = event.target.name;
        if (field === '접수내용') {
            this.receiptDetails = event.target.value;
        }
        this.submitDisabled();
    }

    handleRadioChange(event) {
        const field = event.target.name;
        if (field === '출동여부') {
            this.dispatchStatus = event.target.value;
        } else if (field === '완료여부') {
            this.completionStatus = event.target.value;
        }
        this.submitDisabled();
    }

    handleDateTimeChange(event) {
        this.onSiteDateTime = event.target.value;
    }

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
        // console.log('Event Detail:', event.detail);
        // const field = event.target.name;
        // let selectedId = '';
        // // const searchAccount = event.detail.value;

        // if (field === '업체명') {
        //     searchAccounts({ searchAccount })
        //         .then((result) => {
        //             this.matchingAccInfo = result.map(account => ({ value: account.Id, label: account.Name }));
        //             this.displayAccInfo = this.matchingAccInfo;
        //         })
        //         .catch((error) => {
        //             console.error('검색 중 오류:', error);
        //         });
        // } else if (field === '담당자') {
        //     this.contactId = event.detail.recordId;
        //     selectedId = this.contactId;
        // } else if (field === '장비') {
        //     this.assetId = event.detail.recordId;
        //     selectedId = this.assetId;
        // }
        // this.submitDisabled();

    }
    async handleSubmit() {

        if (this.isSubmitDisabled) {
            return;
        }
    
        const details = {
            accountId: this.accountId,
            contactId: this.contactId,
            assetId: this.assetId,
            dispatchStatus: this.dispatchStatus,
            completionStatus: this.completionStatus,
            receiptDetails: this.receiptDetails
        };
        console.log('accountId:::', this.accountId);
        console.log('contactId:::', this.contactId);
        console.log('assetId:::', this.assetId);
    
        try {
            this.isLoading = true;
            const result = await createTicket({
                accountId: this.accountId,
                contactId: this.contactId,
                assetId: this.assetId,
                dispatchStatus: this.dispatchStatus,
                completionStatus: this.completionStatus,
                receiptDetails: this.receiptDetails,
                recordId: this.recordId,
                onsiteDateTime: this.onSiteDateTime
            });
    
            if (result === 'NOACCOUNT') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '오류',
                        message: '선택한 Asset의 고객 정보가 일치하지 않습니다.',
                        variant: 'error'
                    })
                );
                return;
            } else if (result === 'NOACCOUNTDNSA') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'The Customer Information For The Selected Asset Does Not Match.',
                        variant: 'error'
                    })
                );
                return;
            } else if (result === 'CASEFAIL') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '오류',
                        message: 'Case 생성에 실패했습니다.',
                        variant: 'error'
                    })
                );
                return;
            } else if (result === 'CASEFAIL') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: label.DNS_FSL_InputSuccessSaved,
                        variant: 'success'
                    })
                );
                return;
            }
    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: label.DNS_FSL_InputSuccessSaved,
                    variant: 'success'
                })
            );
    
            this.dispatchEvent(new CloseActionScreenEvent());
    
            // 컴포넌트를 숨기거나 다른 화면으로 이동하는 로직 추가
            // this.closeScreen();
            // this.isModalOpen = false;
            
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: label.DNS_FSL_ErrorOccurred + (error.body?.message || ''),
                    variant: 'error'
                })
            );
    
        } finally {
            this.isLoading = false;
        }
    
        console.log('Submitted Details:', details);
    }
    
    closeScreen() {
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}