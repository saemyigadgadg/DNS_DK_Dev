import { LightningElement, api } from 'lwc';

export default class CustomNotification extends LightningElement {
    @api variant = 'info';
    @api message = '';
    @api autoClose = false;
    @api duration = 3000;
    showNotification = false;

    connectedCallback() {
        this.showNotification = true;
        if (this.autoClose) {
            setTimeout(() => {
                this.closeNotification();
            }, this.duration);
        }
    }

    get notificationClass() {
        return `slds-notify slds-notify_toast slds-theme_${this.variant}`;
    }

    get iconName() {
        const icons = {
            success: 'utility:success',
            warning: 'utility:warning',
            error: 'utility:error',
            info: 'utility:info'
        };
        return icons[this.variant] || icons.info;
    }

    closeNotification() {
        this.showNotification = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}