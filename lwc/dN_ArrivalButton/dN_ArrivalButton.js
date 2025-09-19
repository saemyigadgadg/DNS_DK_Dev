import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';

import updateArrivalTime from '@salesforce/apex/DN_ServiceAppointmentController.updateArrivalTime';

export default class DN_ArrivalButton extends LightningElement {
    @api recordId;
    @track arrivalTime;
    @track isModalOpen = true; // Modal is open by default
    @track isCompletionModalOpen = false;
    @track isLoading = false;
    cLabel = label;

    // SLDS Styles
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
        .total-wrap .icon-wrap .slds-icon{fill: #0176D3 !important;}
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    handleConfirmClick() {
        this.isLoading = true;
        // this.arrivalTime = new Date().toISOString();
        updateArrivalTime({ serviceAppointmentId: this.recordId})
            .then(result => {
                if (result === 'NO_DEPARTURE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_NoDepartureTime,
                            variant: 'error'
                        })
                    );
                } else if (result === 'UNCOMPLETED_DEPARTURE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_PreDayMissingArrAndPending,
                            variant: 'error'
                        })
                    );
                } else if (result === 'IS_CONFIRM_TRUE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_DispatchConfirm,
                            variant: 'error'
                        })
                    );
                } else {
                    this.isModalOpen = false;
                    this.isCompletionModalOpen = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: label.DNS_FSL_ArrivalSuccessSave,
                            variant: 'success'
                        })
                    );
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: label.DNS_FSL_ArrivalCannotSave,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    closeCompletionModal() {
        this.isCompletionModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    // Mobile Height Compatibility
    connectedCallback() {
        this.setVh();
        window.addEventListener('resize', this.setVh);
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.setVh);
    }

    setVh() {
        const vh = window.innerHeight * 0.01;
        document.documentElement.style.setProperty('--vh', `${vh}px`);
    }
}