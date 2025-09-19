import { LightningElement, api } from 'lwc';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import sendNotification from '@salesforce/apex/DN_AnnouncementController.sendNotification';

export default class DN_AnnouncementNotiButton extends LightningElement {
    @api recordId;
    isModalOpen = true;
    cLabel = label;

    handleSendNoti() {
        sendNotification({ recordId: this.recordId })
            .then(() => {
                console.log('Notification sent successfully');
                this.isModalOpen = false;
                this.dispatchEvent(
                    new CloseActionScreenEvent()
                );
            })
            .catch(error => {
                console.error('Error sending notification', error);
            });
    }

    handleCloseModal() {
        this.isModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `         
            .uiModal--horizontalForm .modal-container {
                margin: 0 auto;
                width: 32rem !important;
                max-width: calc(100vw - 20rem) !important;
                min-width: 28rem !important;
            }     
            .slds-modal__footer {
                display: flex;
                justify-content: flex-end;
                gap: 0.5rem;
            }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }
}