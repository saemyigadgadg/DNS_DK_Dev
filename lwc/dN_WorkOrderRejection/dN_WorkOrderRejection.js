import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import createAssignReject from '@salesforce/apex/DN_WorkOrderRejectionController.createAssignReject';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class DN_WorkOrderRejection extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track rejectionReason;
    @track isRejectionCompleteVisible = false;
    @track isRejectionSelectVisible = true;
    cLabel = label;

    rejectionReasons = [
        { label: label.DNS_FSL_DispatchImpossible, value: '출동불가' },
        { label: label.DNS_FSL_Customer, value: '고객' },
        { label: label.DNS_FSL_DispatchDelay, value: '출동지연' },
        { label: label.DNS_FSL_TechnicalShortage, value: '기술부족' },
        { label: label.DNS_FSL_PartsNeeded, value: '부품필요' }
    ];

    /* SLDS Custom Styles */
    renderedCallback() {
        // if(this.isRejectionSelectVisible){
            const style = document.createElement('style');
            style.innerText = `
            .modal-01 .icon-wrap .slds-icon{fill: #0176D3 !important;}
            .modal-01 .input-wrap .slds-textarea{
                height: 10rem;
                border: 1px solid #aeaeae;
                font-size: 18px;
                padding: 0.75rem 1rem;
            }
            .modal-01 .button-wrap .slds-button{
                border: 1px solid #aeaeae;
                font-size: 18px;
                padding: 0 1.25rem;
            }
            .modal-01 .input-wrap .slds-input_faux {
                padding: 0.5rem 1.25rem;
            }

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
                padding: 0.5rem 0;
                border-radius: 0 !important;
                border-bottom: 1px solid #E5E5E5 !important;     
            }
            .input-wrap .slds-radio_button .slds-radio_faux{
                display: inline-block;
                width: 100%;
                text-align: left;
                padding: 0 1.5rem;
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
            `;
            this.template.querySelector('.common').appendChild(style);
        // }else{

        // }

    }

    //   |￣￣￣￣￣￣￣￣￣￣￣￣￣￣|
    //   |         화이팅~!         |
    //   |＿＿＿＿＿＿＿＿＿＿＿＿＿＿|
    //           \ (•◡•) /
    //            \      /

    handleChange(event) {
        this.rejectionReason = event.detail.value;
    }

    handleSubmit() {
        this.isLoading = true;
        createAssignReject({ workOrderId: this.recordId, rejectionReason: this.rejectionReason })
            .then(response => {
                if (response.isSuccess) {
                    this.isRejectionCompleteVisible = true;
                    this.isRejectionSelectVisible = false;
                    this.showToast(label.DNS_M_Success, this.cLabel.DNS_FSL_AssignmentRejectionReasonSave, 'success');
                } else if (response.errorMessage == '배정거절은 WorkOrder가 배정 상태일 때만 가능합니다.') {
                    this.showToast(label.DNS_FSL_Error, this.cLabel.DNS_FSL_PossibleAssignedStatus, 'error')
                } else if(response.errorMessage == '배정거절은 서비스요원이 배정 상태일 때만 가능합니다.') {
                    this.showToast(label.DNS_FSL_Error, '배정거절은 서비스요원이 배정 상태일 때만 가능합니다.', 'error')
                } else if (response.errorMessage == '작업자의 유형이 메인 작업자가 아닙니다.') {
                    this.showToast(label.DNS_FSL_Error, this.cLabel.DNS_FSL_AssignmentRejectionReasonFail, 'error')
                } 
                // else if (response.errorMessage == '현재 사용자와 담당자가 일치하지 않습니다.') {
                //     this.showToast(label.DNS_FSL_Error, '현재 사용자와 담당자가 일치하지 않습니다.', 'error')
                // }
                })
            .catch(error => {
                this.showToast(label.DNS_FSL_Error, label.DNS_M_GeneralError, 'error');
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
    
    closeScreen() {
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleCompleteClose() {
        this.isRejectionCompleteVisible = false;
        this.isModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );

        // this.handleBack;
    }
    
}