import DNS_H_Split from '@salesforce/label/c.DNS_H_Split'; 
import DNS_F_NumberOfInstallments from '@salesforce/label/c.DNS_F_NumberOfInstallments'; 
import DNS_F_PaymentInterval from '@salesforce/label/c.DNS_F_PaymentInterval'; 
import DNS_B_Cancel from '@salesforce/label/c.DNS_B_Cancel'; 
import DNS_B_Save from '@salesforce/label/c.DNS_B_Save'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_RequiredMissing from '@salesforce/label/c.DNS_M_RequiredMissing'; 

import LightningModal from "lightning/modal";

import { showToast, style } from 'c/commonUtils';

export default class DN_OrderPaymentSplitModal extends LightningModal {
    
    cLabel = {
        DNS_H_Split // Split, 분할
        , DNS_F_NumberOfInstallments // Number of Installments, 분할 횟수
        , DNS_F_PaymentInterval // Payment Interval (Months), 납입 주기(월)
        , DNS_B_Cancel // Cancel, 취소
        , DNS_B_Save // Save, 저장
    }

    isLoading = false;

    async connectedCallback(){
        style.set(this.customstyle);
    }
    disconnectedCallback() {
        style.remove(this.customstyle);
    }

    handleBlur(event){
        let inputValue = event.target.value;
        if(inputValue == '')         { inputValue = 0; }
        if(/^0\d+/.test(inputValue)) { inputValue = inputValue.replace(/^0+/, ''); }
        event.target.value = inputValue;
    }

    handleCancel(){
        this.close();
    }
    handleSave(){
        this.isLoading = true;
        const installment = this.template.querySelector(`[data-value="numberOfInstallments"]`).value;
        const interval    = this.template.querySelector(`[data-value="paymentInterval"]`).value;

        if(installment <= 0 || installment == '' || interval <= 0 || interval == '') {
            showToast(this, 'error', DNS_M_GeneralError, DNS_M_RequiredMissing);
        } else {
            this.close({
                'installment' : installment
                , 'interval'  : interval
            });
        }
    }

    customstyle = {
        id: 'dN_OrderPaymentSplitModal',
        style: `
            .slds-modal__container {
                width: 30rem !important;
                min-width: 30rem !important;
            }
        `,
    }
}