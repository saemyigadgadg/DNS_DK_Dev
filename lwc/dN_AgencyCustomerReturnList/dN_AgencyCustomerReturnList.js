import { LightningElement, api } from 'lwc';

import getDataList from '@salesforce/apex/DN_AgencyCustomerOrderCreateController.getReturnListFromOrderSummary';

export default class DN_AgencyCustomerReturnList extends LightningElement {
    _orderId;
    isLoading = false;
    returnItemList = [];
    

    @api get orderId() {
        return this._orderId;
    }

    set orderId(value) {
        this._orderId = value;
        this._getDataList(this._orderId);
    }

    _getDataList(orderId) {
        this.isLoading = true;
        getDataList({
            orderId
        }).then(result=>{
            let {status, returnOrderList} = result;
            if(status.code === 200) {
                this.returnItemList = returnOrderList;
            }else {
                console.error(e);
            }
            this.isLoading = false;
        });
    }
}