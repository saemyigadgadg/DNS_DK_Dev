import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningConfirm from 'lightning/confirm';
import updateOnSiteDateTime from '@salesforce/apex/DN_ServiceAppointmentController.updateOnSiteDateTime';
import getOnSiteDateTime from '@salesforce/apex/DN_ServiceAppointmentController.getOnSiteDateTime';

export default class DN_OnsiteDateButton extends LightningElement {
    @api recordId;
    @track onSiteDateTime;
    @track isModalOpen = true; 
    @track isCompletionModalOpen = false;
    @track isLoading = false;
    cLabel = label;

    // SLDS Styles
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
        .total-wrap .icon-wrap .slds-icon {fill: #0176D3 !important;}
        .body .slds-input {
            width: calc(100vw - 3rem) !important;
            line-height: 4.25rem !important;
            height: 5rem !important;
            padding: 1.3rem !important;  
            font-size: 1.2rem !important;
        }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

    connectedCallback() {
        // this.onSiteDateTime = new Date().toISOString();
        this.isLoading = true;
        getOnSiteDateTime({ serviceAppointmentId: this.recordId })
            .then((result) => {
                if (result) {
                    this.onSiteDateTime = result;
                } else {
                    const now = new Date();
                    this.onSiteDateTime = now.toISOString().slice(0, 16); // 초와 밀리초 제거
                    this.setVh();
                    window.addEventListener('resize', this.setVh);
                }
            })
            .catch((error) => {
                const now = new Date();
                this.onSiteDateTime = now.toISOString().slice(0, 16); // 초와 밀리초 제거
                this.setVh();
                window.addEventListener('resize', this.setVh);
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Error loading status',
                //         message: error.body.message,
                //         variant: 'error'
                //     })
                // );
            })
            .finally(() => {
                this.isLoading = false;
            });

        
    }

    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    async handleConfirmClick() {
        this.isLoading = true;

        try {
            const existingOnsiteDate = await getOnSiteDateTime({ serviceAppointmentId: this.recordId });

            if (existingOnsiteDate) {
                const confirmResult = await LightningConfirm.open({
                    message: label.DNS_FSL_ExistingAppointmentTime,
                    variant: 'header',
                    label: label.DNS_FSL_CustomerAppointmentTimeSetting,
                    theme: 'alt-inverse'
                });

                if (!confirmResult) {
                    this.isLoading = false;
                    return;
                }
            }

            await updateOnSiteDateTime({ serviceAppointmentId: this.recordId, onsiteDateTime: this.onSiteDateTime });

            this.isModalOpen = false;
            this.isCompletionModalOpen = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: label.DNS_FSL_CustomerAppointmentSuccessfullySave,
                    variant: 'success'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: label.DNS_FSL_EnteredAfterCurrentTime,
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }

    closeCompletionModal() {
        this.isCompletionModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    handleDateTimeChange(event) {
        this.onSiteDateTime = event.target.value;
    }

    // Mobile Height Compatibility
    

    disconnectedCallback() {
        window.removeEventListener('resize', this.setVh);
    }

    setVh() {
        const vh = window.innerHeight * 0.01;
        document.documentElement.style.setProperty('--vh', `${vh}px`);
    }
}