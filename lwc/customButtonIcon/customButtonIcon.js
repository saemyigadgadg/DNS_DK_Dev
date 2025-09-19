import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CUSTOM_DATATABLE_MESSAGE from '@salesforce/messageChannel/CustomDatatableMC__c';

export default class CustomButtonIcon extends LightningElement {

    @api iconName;
    @api variant;
    @api actionName;
    @api rowKey;

    @wire(MessageContext) messageContext;

    handleClick(){
        console.log('CustomButtonIcon - handleClick');

        const payload = { 
            detail: {
                action: {
                    key: this.rowKey
                    , name: this.actionName
                }
            }
        };
        publish(this.messageContext, CUSTOM_DATATABLE_MESSAGE, payload);
    }
}