import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import lang from '@salesforce/i18n/lang';
import { CloseActionScreenEvent } from 'lightning/actions';

// import updateResourceAbsence from '@salesforce/apex/DN_ResourceAbsenceController.updateResourceAbsence';
import updateSRStatus from '@salesforce/apex/DN_ResourceAbsenceController.updateSRStatus';
import getSRStatus from '@salesforce/apex/DN_ResourceAbsenceController.getSRStatus';

export default class DN_ChangeStatusButton extends LightningElement {
    @api recordId;
    @track selectedStatus;
    @track selectedStatusLabel = label.DNS_FSL_Wait;
    @track isModalOpen = false;
    @track isSuccessModalOpen = false;
    @track isStatusSelectVisible = true;
    @track isLoading = false;
    @track isKorean = lang === 'ko';
    cLabel = label;


    statusOptions = [
        { label: label.DNS_FSL_Wait, value: 'Wait' },
        { label: label.DNS_FSL_Education, value: 'Education' },
        { label: label.DNS_FSL_Meeting, value: 'Meeting' },
        { label: label.DNS_FSL_Work, value: 'Work' },
        { label: label.DNS_FSL_SelfWork, value: 'SelfWork' },
        { label: label.DNS_FSL_Holiday, value: 'Holiday' },
    ];

    /* SLDS Custom Styles */
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
        .input-wrap .slds-radio_button-group{
            flex-direction: column;
            width: 100%;
            border: none;
            border-radius: unset;
        }
        .input-wrap .slds-radio_button{
            width: 100%;
            border: none !important;            
        }
        .input-wrap .slds-radio_button__label{
            width: 100%;
            text-align: left;
            padding: 0.75rem 0;
            border-radius: 0 !important;
            border-bottom: 1px solid #E5E5E5 !important;     
        }
        .input-wrap .slds-radio_button .slds-radio_faux{
            display: inline-block;
            width: 100%;
            text-align: left;
            padding: 0 1.5rem;
            font-size: 1rem;
        }
        .input-wrap .slds-radio_button .slds-radio_faux:after{
            content: '✓';
            color: #fff;
            font-weight: 700;
            font-size: 1.25rem;
            float: right;
        }
        .input-wrap .slds-radio_button [type=radio]:checked+.slds-radio_button__label:focus,
        .input-wrap .slds-radio_button [type=radio]:checked+.slds-radio_button__label:hover{
            background-color: #0176D3 !important;
        }
        .button-wrap .slds-button_brand{
            font-weight: 600;
            font-size: 1.125rem;
            width: 100%;
            padding: 0.5rem 0;
        }
        .modal-02 .icon-wrap .slds-icon {
            fill: #0176D3 !important;
        }
        .modal-02 .button-wrap .slds-button_brand {
            border: 1px solid #aeaeae;
            font-size: 18px;
            padding: 0 1.25rem;
        }
        .modal-01 .slds-modal__header .slds-modal__close {
            display: none;
        }
        .modal-01 .icon-wrap .slds-icon {fill: #0176D3 !important;}
         `;
        this.template.querySelector('.common').appendChild(style);
    }

    connectedCallback() {
        this.isLoading = true;
        getSRStatus({ workOrderId: this.recordId })
            .then((result) => {
                if (result) {
                    this.selectedStatus = result;
                    this.statusOptions.forEach(option => {
                        if (option.value === result) {
                            this.selectedStatusLabel = option.label;
                        }
                    });
                } else {
                    this.selectedStatusLabel = this.statusOptions.find(
                        (option) => option.value === this.selectedStatus
                    ).label;
                }
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading status',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.statusOptions.forEach(element => {
            if (element.value == this.selectedStatus) {
                this.selectedStatusLabel = element.label;
            }
        });
        
    }

    handleSave() {
        if (this.selectedStatus) {
            this.isModalOpen = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: label.DNS_FSL_PleaseSelectStatus,
                    variant: 'error'
                })
            );
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    confirmSave() {
        this.isLoading = true;
        updateSRStatus({ workOrderId: this.recordId, status: this.selectedStatus })
            .then(() => {
                this.isStatusSelectVisible = false;
                this.isModalOpen = false;
                this.isSuccessModalOpen = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        // message: cLabel.DNS_FSL_AssignmentRejectionReasonSave,
                        message: label.DNS_FSL_StatusChangeComplete,
                        variant: 'success'
                    })
                );
                
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving status',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCompleteClose() {
        this.isSuccessModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

}