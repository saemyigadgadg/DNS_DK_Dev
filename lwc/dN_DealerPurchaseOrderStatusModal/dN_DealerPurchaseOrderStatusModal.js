/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-17-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-17-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class DN_DealerPurchaseOrderStatusModal extends LightningModal {
    @api orderId;

    renderedCallback() {
        this.styleCss();
    }

    handleClose() {
        this.close('');
    }

    styleCss() {
        const style = document.createElement('style');
		style.innerText = `
            .slds-modal__content:has(.modal.customerOrderStatus) {
                background: #f3f3f3;
            }
            .modal.customerOrderStatus .card-01 {
                grid-template-columns:repeat(4 , 1fr)
            }`;
		this.template.querySelector('div').appendChild(style);
    }
}