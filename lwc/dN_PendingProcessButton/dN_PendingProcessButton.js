import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import cloneServiceAppointment from '@salesforce/apex/DN_ServiceAppointmentController.cloneServiceAppointment';
import getServiceAppointment from '@salesforce/apex/DN_ServiceAppointmentController.getServiceAppointment';

export default class DN_PendingProcessButton extends LightningElement {
    @api recordId; // ServiceAppointment 레코드 ID를 받아야 되는데 지금 Workorder에서 받아와서 Workorder 레코드 ID로 나옴
    // @api recordId; // ServiceAppointment 레코드 ID를 받음
    @track isPendingConfirmVisible = true;
    @track isPendingCompleteVisible = false;
    // @track receiptDetails = ''; 
    @track pendingDetails = ''; // 미결내용을 저장
    @track isLoading = false;
    // @track isReceiptDetailsEnabled = false;
    @track isConfirmDisabled = true;
    @track rejectionReason;
    cLabel = label;

    rejectionReasons = [
        { label: label.DNS_FSL_Parts, value: 'Parts' },
        // { label: label.DNS_FSL_Closing, value: 'Closing' },
        { label: label.DNS_FSL_Customer, value: 'Customer' },
        { label: label.DNS_FSL_NeedMorePerson, value: 'Person' },
        { label: label.DNS_FSL_Installation, value: 'Installation' },
        { label: label.DNS_FSL_TechnicalReview, value: 'Technical Review' },
        { label: label.DNS_FSL_TechnicalDesign, value: 'Technical Design' },
        { label: label.DNS_FSL_TechnicalCustomer, value: 'Technical Customer' },
        { label: label.DNS_FSL_TechnicalPersonnel, value: 'Technical Personnel' },
        { label: label.DNS_FSL_TechnicalParts, value: 'Technical Parts' },
        // { label: label.DNS_FSL_ResultNotEntered, value: 'Result Not entered' },
        { label: label.DNS_FSL_etc, value: 'ETC' }
    ];

    connectedCallback() {
        getServiceAppointment({ serviceAppointmentId: this.recordId})
            .then((result) => {
                if (result === 'IS_COMPLETE_TRUE') {
                    this.showToast('Error', label.DNS_FSL_DispatchCompleted, 'error');
                    this.isPendingConfirmVisible = false;
                } else if (result === 'IS_CANCELED_TRUE') {
                    this.showToast('Error', label.DNS_FSL_DispatchCanceled, 'error');
                    this.isPendingConfirmVisible = false;
                } else if (result === 'IS_CONFIRM_TRUE') {
                    this.showToast('Error', label.DNS_FSL_DispatchConfirm, 'error');
                    this.isPendingConfirmVisible = false;
                }             
            })
            .catch((error) => {
                console.error('Error saving value: ', error);
                this.showToast('Error', label.DNS_FSL_SavingValue, 'error');
            });
    }

    renderedCallback() {
        this.sldsStyles();
    }

    sldsStyles() {
        const style = document.createElement('style');
        style.innerText = `
            .total-wrap .icon-wrap .slds-icon{fill: #0176D3 !important;}
            .total-wrap .input-wrap .slds-textarea{
                height: 10rem;
                border: 1px solid #aeaeae;
                font-size: 18px;
                padding: 0.75rem 1rem;
            }
            .total-wrap .button-wrap .slds-button{
                border: 1px solid #aeaeae;
                font-size: 18px;
                padding: 0 1.25rem;
            }
            .total-wrap .input-wrap .slds-input_faux {
                padding: 0.5rem 1.25rem;
            }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

    handleInputChange(event) {
        this.pendingDetails = event.target.value;
        // 09.10
        // this.isConfirmDisabled = !this.receiptDetails;
        // this.isConfirmDisabled = !this.rejectionReason || (this.rejectionReason === '기타' && !this.receiptDetails);
    }

    handleCancel() {
        // this.isPendingConfirmVisible = false;
        // this.handleBack();
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    handleConfirm() {
        this.isLoading = true;
        cloneServiceAppointment({ recordId: this.recordId, pendingDetails: this.pendingDetails, pendingReasons: this.rejectionReason })
            .then(response => {
                // this.isPendingConfirmVisible = false;
                // this.isPendingCompleteVisible = true;
                if (response.isSuccess) {
                    this.showToast('Success', label.DNS_FSL_PendingProcessingCompleted, 'success');
                    this.isPendingConfirmVisible = false;
                    this.isPendingCompleteVisible = true;
                    
                } else if (response.errorMessage == '미결처리를 할 수 없습니다. 이미 미결 사유가 있습니다. 수동으로 출동예약을 생성해주세요.') {
                    this.showToast(label.DNS_FSL_Error, label.DNS_FSL_PendingProcessingNotPossible, 'error');
                    this.isPendingCompleteVisible = false;

                } else if (response.errorMessage == 'IS_CONFIRM_TRUE') {
                    this.showToast(label.DNS_FSL_Error, label.DNS_FSL_DispatchConfirm, 'error');
                    this.isPendingCompleteVisible = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    handleCompleteClose() {
        this.isPendingCompleteVisible = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );

        // this.handleBack;
    }

    handleChange(event) {
        this.rejectionReason = event.target.value;
        // this.isReceiptDetailsEnabled = this.rejectionReason === '기타';
        // this.isReceiptDetailsDisabled = !this.rejectionReason;
        this.isConfirmDisabled = !this.rejectionReason;
    }

    handleBack() {

    }
}