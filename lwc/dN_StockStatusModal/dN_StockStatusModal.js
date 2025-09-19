import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class StockStatusModal extends LightningModal {
    @api orderItemId;

    handleClose() {
        this.close('');
    }
}