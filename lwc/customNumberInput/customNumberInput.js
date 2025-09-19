import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CUSTOM_DATATABLE_MESSAGE from '@salesforce/messageChannel/CustomDatatableMC__c';

export default class CustomNumberInput extends LightningElement {

    @api value;
    @api rowKey;

    @wire(MessageContext) messageContext;

    handleAmountChange(event){
        console.log('CustomNumberInput - handleAmountChange', JSON.stringify(event.detail));
        const changedValue = event.detail.value;
        const payload = { 
            detail: {
                draftValues: [
                    {
                        key: this.rowKey
                        , quantity: changedValue
                    }
                ]
            }
        };
        publish(this.messageContext, CUSTOM_DATATABLE_MESSAGE, payload);
    }
}