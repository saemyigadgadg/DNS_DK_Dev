import { LightningElement, api, track } from 'lwc';

import { showToast, label, reduceErrors } from 'c/commonUtils';

import fetchTableItems from '@salesforce/apex/DN_PreparationTableController.fetchTableItems';
import getMode from '@salesforce/apex/DN_PreparationTableController.getMode';

export default class DN_PreparationChecklistTable extends LightningElement {

    @api recordId;

    @track items = [];
    
    isEditMode = false;
    isEditable = false;
    isLoading  = false;

    cLabel = label;
    
    get isEditButtonShow(){
        return !this.isEditMode && this.isEditable;
    }
    get isSaveButtonShow(){
        return this.isEditMode && this.isEditable;
    }

    async connectedCallback(){
        console.log('DN_PreparationChecklistTable', this.recordId);
        
        this.isLoading = true;
        await fetchTableItems()
        .then(result => {
            // console.log('fetchTableItems ::: ', JSON.stringify(result, null, 2));
            this.items = result;
        })
        .catch(error => this.errorHandler('fetchTableItems', error));

        await this.checkEditable();

        this.isLoading = false;
    }
    handleSubmit(event){
        event.preventDefault();
        this.isLoading = true;

        const fields       = event.detail.fields;
        fields.IsCSSent__c = false;
        this.template.querySelector('lightning-record-edit-form').submit(fields);

    }

    handleSuccess(){
        showToast(this, 'success', label.DNS_M_Success, label.DNS_M_PreparationCheckSaved);
        this.isLoading = false;
        this.isEditMode = false;
    }

    handleEditBtn(){
        this.isEditMode = true;
    }

    handleCancelBtn(){
        this.isEditMode = false;
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.log(name, errorMsg);
        showToast(this, 'error', label.DNS_M_GeneralError, errorMsg);
    }

    async checkEditable(){
        await getMode({recordId : this.recordId})
        .then(result => {
            console.log('getMode ::: ', result);
            this.isEditable = result;
            this.isEditable = true;
        })
        .catch(error => this.errorHandler('fetchTableItems', error));
    }
}