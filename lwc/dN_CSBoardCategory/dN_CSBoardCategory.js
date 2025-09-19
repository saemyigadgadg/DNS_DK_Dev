/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-10-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import BOARD_OBJECT from '@salesforce/schema/Board__c';
import CATEGORY_FIELD from '@salesforce/schema/Board__c.Category__c';

export default class DN_CSBoardCategory extends LightningElement {
    @api recordTypeId; 
    pickListValues = []; 
    searchCategory; 

    @wire(getPicklistValuesByRecordType, { objectApiName: BOARD_OBJECT, recordTypeId: '$recordTypeId' })

    pickListValues({ error, data }) {
        if (data) {
            console.log(data);
            console.log(data.picklistFieldValues.Category__c.values);
            this.pickListValues = data.picklistFieldValues.Category__c.values.map(item => ({ label: item.label, value: item.value }));
        } else if (error) {
            console.error('Error loading picklist values: ', error);
        }
        
        // if (data) {
        //     this.pickListValues = data.fields.Category__c.picklistValues.map(item => ({
        //         label: item.label,
        //         value: item.value 
        //     }));
        // } else if (error) {
        //     console.error('Error loading picklist values: ', error);
        // }
    }

    handleChange(event) {
        this.searchCategory = event.detail.value;
        const changeEvent = new CustomEvent('change', {
            detail: { value: this.searchCategory }
        });
        this.dispatchEvent(changeEvent); 
    }
}