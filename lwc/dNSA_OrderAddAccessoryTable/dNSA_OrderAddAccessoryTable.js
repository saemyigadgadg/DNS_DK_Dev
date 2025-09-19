import { LightningElement, api } from 'lwc';

export default class DNSA_OrderAddAccessoryTable extends LightningElement {
    @api columns;
    @api selTableData;
    @api draftValues;

    connectedCallback(){
        console.log('connectedCallback - DNSA_OrderAddAccessoryTable');
    }

    handleRemoveAction(){

    }

    handleCellChange(){

    }
}