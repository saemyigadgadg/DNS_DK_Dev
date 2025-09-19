import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class DN_AgencyCustomerReturnListModal extends LightningModal {
    @api orderId;

    handleClose() {
        this.close('');
    }
}