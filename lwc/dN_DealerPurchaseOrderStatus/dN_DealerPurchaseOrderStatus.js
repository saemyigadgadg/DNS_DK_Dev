import { LightningElement, api } from 'lwc';

import getDataList from '@salesforce/apex/DN_CreateAnotherAgencyPurchase.detailInit';

export default class DN_DealerPurchaseOrderStatus extends LightningElement {
    
    orderInfo = {};
    orderItemInfos = [];

    _orderId;
    isLoading = false;
    orderInfo = {};
    orderItemInfos = [];

    @api get orderId() {
        return this._orderId;
    }

    set orderId(value) {
        this._orderId = value;
        this._getDataList(this._orderId);
    }

    _getDataList(recordId) {
        this.isLoading = true;
        getDataList({
            recordId
        }).then(result=>{
            let {status, order} = result;
            if(status.code === 200) {
                this.orderInfo = order;
                order.itemList.forEach(item=>{
                    switch (item.status) {
                        case '1', '2', '3', '4':
                            break;
                        default:
                            //1,2,3,4 상태값외에 출고사량의 상태값으로 노출
                            item.statusLabel = item.deliveryStatus;
                            break;
                    }
                });
                this.orderItemInfos = order.itemList;
            }else {
                console.error(e);
            }
            this.isLoading = false;
        });
    }
}