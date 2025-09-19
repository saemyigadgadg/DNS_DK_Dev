import { LightningElement, api } from 'lwc';

//Apex
import getDataList from '@salesforce/apex/DN_AgencyCustomerOrderCreateController.getInventoryStatusList';

export default class DN_InventoryStatus extends LightningElement {
    orderItemList = [];
    _orderItemId;
    @api get orderItemId() {
        return this._orderItemId;
    }

    set orderItemId(value) {
        this._orderItemId = value;
        this._getDataList(this._orderItemId);
    }

    _getDataList(ordeItemId) {
        this.isLoading = true;
        getDataList({
            ordeItemId
        }).then(result=>{
            let {status, orderItemList} = result;
            if(status.code === 200) {
                orderItemList.reverse();
                this.orderItemList = orderItemList;
            }else {
                console.error(e);
            }
            this.isLoading = false;
        });
    }
}