import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CUSTOM_DATATABLE_MESSAGE from '@salesforce/messageChannel/CustomDatatableMC__c';

export default class CustomRecordPicker extends LightningElement {

    @api objectApiName;
    @api rowKey;
    @api selectedValue;
    @api selectedLabel;
    @api filter;

    @wire(MessageContext) messageContext;

    handleRecordSelect(event) {
        console.log('CustomRecordPicker - handleRecordSelect');
        // const prevRecord = event.target.value;
        const selectedRecord = event.detail.recordId;
        // this.dispatchEvent(new CustomEvent('cellchange', {
        //     detail: {
        //         draftValues: [
        //             {
        //                 key: this.rowKey
        //                 , shipToId: selectedRecord
        //             }
        //         ]
        //     }
        // }));
        const payload = { 
            detail: {
                draftValues: [
                    {
                        key: this.rowKey
                        , shipToId: selectedRecord
                    }
                ]
            }
        };
        publish(this.messageContext, CUSTOM_DATATABLE_MESSAGE, payload);
    }
}