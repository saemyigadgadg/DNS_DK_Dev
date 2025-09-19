import { wire } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import customRecordPickerTemp from './customRecordPickerTemp.html';
import customButtonIconTemp from './customButtonIconTemp.html';
import customNumberInputTemp from './customNumberInputTemp.html';

import { subscribe, MessageContext } from 'lightning/messageService';
import CUSTOM_DATATABLE_MESSAGE from '@salesforce/messageChannel/CustomDatatableMC__c';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        customRecordPicker: {
            template: customRecordPickerTemp,
            standardCellLayout: true,
            typeAttributes: ['objectname', 'value', 'label', 'key', 'filter']
        }
        , customIconAction: {
            template: customButtonIconTemp,
            standardCellLayout: true,
            typeAttributes: ['iconName', 'variant', 'actionName', 'key']
        }
        , customNumberInput: {
            template: customNumberInputTemp,
            standardCellLayout: true,
            typeAttributes: ['key', 'qty']
        }
    };

    @wire(MessageContext)
    messageContext;

    _subscription = null;

    connectedCallback() {
        console.log('customDatatable - connectedCallback');
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this._subscription) {
            this._subscription = subscribe(
                this.messageContext,
                CUSTOM_DATATABLE_MESSAGE,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        console.log(`customDatatable - handleMessage message : ${JSON.stringify(message, null, 1)}`);

        const detail = message.detail;
        if(!detail) return;

        if(detail.action) {
            if(detail.action.name == 'remove') {
                const changeEvent = new CustomEvent('rowaction', { detail: detail });
                this.dispatchEvent(changeEvent);
                console.log('customDatatable - handleMessage - remove!?');
            }
        } else {
            const changeEvent = new CustomEvent('cellchange', { detail: detail });
            this.dispatchEvent(changeEvent);
        }
    }

}