import LightningModal from "lightning/modal";
import {api} from 'lwc';

import { style } from 'c/commonUtils';

import DNS_F_Comments from '@salesforce/label/c.DNS_F_Comments'; 
import DNS_B_Cancel from '@salesforce/label/c.DNS_B_Cancel'; 
import DNS_B_Save from '@salesforce/label/c.DNS_B_Save'; 

import DNS_H_ApprovalRequest from '@salesforce/label/c.DNS_H_ApprovalRequest'; 
import DNS_B_Approval from '@salesforce/label/c.DNS_B_Approval'; 
import DNS_B_REJECT from '@salesforce/label/c.DNS_B_REJECT'; 
import DNS_M_RequestOrderConfrim from '@salesforce/label/c.DNS_M_RequestOrderConfrim'; 
import DNS_B_Confirm from '@salesforce/label/c.DNS_B_Confirm'; 

export default class DN_OrderApprovalModal extends LightningModal {
    @api type; // RQ : request, AP : Approval, RE : Reject, C : confirm

    cLabel = {
        DNS_F_Comments          // Comments, 설명
        , DNS_B_Cancel          // Cancel, 취소
        , DNS_B_Save            // Save, 저장
        , DNS_H_ApprovalRequest // Approval Request, 승인 요청
        , DNS_B_Approval        // Approval, 승인
        , DNS_B_REJECT          // Reject, 반려
        , DNS_B_Confirm         // Confirm, 확인
        , DNS_M_RequestOrderConfrim // Would you like to send this order to the ERP system to request confirmation?
    }
    
    isLoading = false;

    get isRequest(){
        return this.type === 'RQ';
    }

    get isApproval(){
        return this.type === 'AP';
    }

    get isReject(){
        return this.type === 'RE';
    }

    get isConfirm(){
        return this.type == 'C';
    }

    async connectedCallback(){
        style.set(this.customstyle);
    }

    disconnectedCallback() {
        style.remove(this.customstyle);
    }

    handleCancel(){
        this.close({status : 'cancel'});
    }

    handleSave(){
        this.isLoading = true;
        const comments = this.template.querySelector(`[data-value="comments"]`).value;
        console.log('handleSave - comments ::: ', comments);
        this.close({status : 'save', 'comments' : comments});
    }

    handleConfirm(){
        this.isLoading = true;
        this.close({status : 'confirm'});
    }

    customstyle = {
        id: 'dN_OrderApprovalModal',
        style: `
            .slds-modal__container {
                width: 30rem !important;
                min-width: 30rem !important;
            }

            .approval_wrapper .slds-textarea {
                height: 10rem;
            }
        `,
    }
}