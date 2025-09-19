import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';

import updateDepartmentTime from '@salesforce/apex/DN_ServiceAppointmentController.updateDepartmentTime';

export default class DN_DepartureButton extends LightningElement {
    @api recordId;
    @track departureTime;
    @track isModalOpen = true;
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
        this.departureTime = new Date().toISOString();
        updateDepartmentTime({ serviceAppointmentId: this.recordId, departmentTime: this.departureTime })
            .then(result => {
                if (result === 'DEPARTURE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_DepartureCannotSave,
                            variant: 'error'
                        })
                    );
                } else if (result === 'CANCLELATION') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_TicketCanceled, // Tickets that have already been canceled.
                            variant: 'error'
                        })
                    );
                } else if (result === 'BEFORE_DEPARTURE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_PreDayMissingPending, // 전날 미결을 누르지 않았습니다.
                            variant: 'error'
                        })
                    );
                } else if (result === 'UNCOMPLETED_DEPARTURE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_PreDayMissingArrAndPending, // 전날 도착 및 미결을 누르지 않았습니다.
                            variant: 'error'
                        })
                    );
                } else if (result === 'IS_CONFIRM_TRUE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: label.DNS_FSL_DispatchConfirm, // 확정 오더
                            variant: 'error'
                        })
                    );
                } else if (result === 'SUCCESS') {
                    this.isModalOpen = false;
                    this.isCompletionModalOpen = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: label.DNS_FSL_DepartureSuccessSave,
                            variant: 'success'
                        })
                    );
                }
            })
            .catch(error => {
                let errorMessage = label.DNS_FSL_SavingValue;
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
                // this.isModalOpen = false;

            })
            .finally(() => {
                this.isLoading = false;
            });
            // DNS_FSL_SavingValue
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