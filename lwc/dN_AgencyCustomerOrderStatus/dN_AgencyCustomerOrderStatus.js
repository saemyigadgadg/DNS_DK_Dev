/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-14-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-14-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { api, LightningElement } from 'lwc';

//Modal
import stockStatusModal  from 'c/dN_StockStatusModal';

import getDataList from '@salesforce/apex/DN_AgencyCustomerOrderCreateController.detailInit';

export default class DN_AgencyCustomerOrderStatus extends LightningElement {
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
                this.orderItemInfos = order.itemList
            }else {
                console.error(e);
            }
            this.isLoading = false;
        });
    }

    async openInventoryModal(event) {
        let rowIndex = event.currentTarget.getAttribute('accesskey');
        let orderItemId = this.orderItemInfos[rowIndex].itemId;

        const result = await stockStatusModal.open({
            orderItemId,
        });
    }

}