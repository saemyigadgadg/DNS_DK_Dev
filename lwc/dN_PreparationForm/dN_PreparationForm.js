import { LightningElement, api, track } from 'lwc';
import formFactor from '@salesforce/client/formFactor';

import { showToast, label, reduceErrors } from 'c/commonUtils';
import customLabels from "./labels";

import fetchTableItems from '@salesforce/apex/DN_PreparationTableController.fetchTableItems';
import checkCreatePermission from '@salesforce/apex/DN_PreparationFormController.checkCreatePermission';
import getDefaultValues from '@salesforce/apex/DN_PreparationFormController.getDefaultValues';
import getBelonging from '@salesforce/apex/DN_PreparationFormController.getBelonging';
import checkEditPermission from '@salesforce/apex/DN_PreparationFormController.checkEditPermission';
import getContactOption from '@salesforce/apex/DN_PreparationFormController.getContactOption';

export default class DN_PreparationForm extends LightningElement {

    @api recordId;
    @api parentId;
    @api isNew; // true : new modal, false : edit modal

    @track items = [];

    isLoading = false;
    cLabel = customLabels;

    contactOption = [];
    salesRepOption = [];
    defaultValues = [];
    // userFilter    = {};
    // contactFilter = {};

    get title(){
        return this.isNew ? customLabels.DNS_S_NewPrepararionChecklist : customLabels.DNS_S_EditPreparationChecklist;
    }

    get inputVarient(){
        // return formFactor == 'Large' ? 'label-inline' : 'label-stacked';
        return 'label-stacked';
    }

    async connectedCallback(){
        console.log('connectedCallback', this.recordId, this.parentId, this.isNew);
        this.isLoading = true;

        let isPass;
        let errorMsg;
        if(this.isNew) {
            await checkCreatePermission({parentId : this.parentId})
            .then(result => {
                isPass   = result.isPass;
                errorMsg = result.errorMsg;
            })
            .catch(error => this.errorHandler('checkCreatePremission', error));
        } else {
            await checkEditPermission({recordId : this.recordId})
            .then(result => {
                isPass   = result.isPass;
                errorMsg = result.errorMsg;
            })
            .catch(error => this.errorHandler('checkEditPermission', error));
        }

        console.log('isPass ::: ', isPass);
        
        if(!isPass) {
            showToast(this, 'error', errorMsg);
            this.handleClose();
            return;
        }
        
        await fetchTableItems()
        .then(result => this.items = result )
        .catch(error => this.errorHandler('fetchTableItems', error));

        const baseId = this.isNew ? this.parentId : this.recordId;
        await getDefaultValues({recordId : baseId})
        .then(result => {
            // console.log('new getDefaultValues ::: ' + JSON.stringify(result, null, 2));
            this.defaultValues      = result;
            this.contactOption      = result.cOptions;
            this.salesRepOption     = result.uOptions;

            // this.userFilter = {
            //     criteria: [
            //         {
            //             fieldPath : 'Id'
            //             , operator : 'in'
            //             , value : this.defaultValues.belonging
            //         }
            //     ]
            // }
            
            // this.contactFilter = {
            //     criteria: [
            //         {
            //             fieldPath : 'AccountId'
            //             , operator : 'eq'
            //             , value : this.defaultValues.shipTo
            //         }
            //     ]
            // }

            if(this.isNew) {
                this.template.querySelector('[data-id="Account"]').value      = this.defaultValues.shipTo;
                this.template.querySelector('[data-id="SalesRep"]').value     = this.defaultValues.orderOwner;
            } else {
                this.template.querySelector('[data-id="Contact"]').value      = this.defaultValues.contact;
                this.template.querySelector('[data-id="SalesRep"]').value     = this.defaultValues.salesRep;
            }
        })
        .catch(error => this.errorHandler('fetchTableItems', error));

        this.isLoading = false;
    }

    async handleSubmit(event){
        this.isLoading = true;
        event.preventDefault();

        const fields = event.detail.fields;

        if(this.isNew) {
            fields.Order__c = this.parentId;
            fields.DeliveryOrder__c = this.defaultValues.delivery;
        }

        fields.ContactPerson__c = this.template.querySelector('[data-id="Contact"]').value;
        fields.SalesReps__c     = this.template.querySelector('[data-id="SalesRep"]').value;
        fields.IsCSSent__c      = false;
        
        // validate
        const requiredFields = ['Account__c', 'PreferredInstallationDate__c', 'ContactPerson__c', 'SalesReps__c'];
        let isValid = true;
        requiredFields.forEach(fieldName => {
            const fieldValue = fields[fieldName];
            if(!fieldValue || fieldValue == '' || fieldValue == null) {
                isValid = false;
            }
        });

        if(!isValid) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_RequiredMissing);
            return;
        }

        await getBelonging({userIds : [fields.SalesReps__c]})
        .then(result => {
            // console.log('getBelonging - result ::: ', result);
            
            fields.SalesRepsBelonging__c    = result[fields.SalesReps__c];
        });

        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.isLoading = false;
    }

    handleAccChange(event) {
        this.isLoading = true;
        const changedValues = event.detail.value;
        const isSelected = event.detail.value.length > 0;
        console.log('handleAccChange', JSON.stringify(changedValues), isSelected);
        if(isSelected) {
            getContactOption({accountId : changedValues[0]})
            .then(result => {
                this.contactOption = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.errorHandler('getContactOption', error);
                this.isLoading = false;
            });
        } else {
            this.contactOption = [];
            this.isLoading = false;
        }
    }

    handleSuccess(event){
        const targetRecordId = event.detail.id;
        this.closeModal(targetRecordId, 'save');
    }

    handleError(event){
        let message = event.detail.detail;
        console.log('handleError : ' , message);
        
        showToast(this, 'error', customLabels.DNS_M_GeneralError, message);
    }

    handleClose(){
        let closeLocation = this.isNew ? this.parentId : this.recordId;
        this.closeModal(closeLocation, 'cancel');
    }

    closeModal(msg, func){
        this.dispatchEvent(new CustomEvent('close', {detail: {recordId : msg, value : func}}));
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.log(name, errorMsg);
        showToast(this, 'error', customLabels.DNS_M_GeneralError, errorMsg);
    }

    renderedCallback() {
        this.sldsStyles();
    }

    sldsStyles(){
        const style = document.createElement('style');
        style.innerText = `
            .preparation_form_wrapper .slds-modal__header {
                border-radius: 0.25rem 0.25rem 0 0;
            }
            .preparation_form_wrapper .slds-modal__content {
                max-height: calc(100vh - 16rem);
            }
            @media all and (max-width: 479px) {
                .slds-rich-text-editor__textarea:last-child .slds-rich-text-area__content {
                    min-height: 10rem;
                }
                .slds-p-around_small {
                    padding: 0.5rem 0.75rem;
                }
                .slds-form-element_stacked {
                    width: 100% !important;
                    padding: 0 !important;
                    margin: 0 !important;
                }
                .slds-form-element_stacked .slds-form-element__control {
                    width: 100%; !important;
                    padding: 0 !important;
                    margin: 0 !important;
                }
                .slds-form-element_stacked .slds-input {
                    min-width: 16rem !important;
                    width: 100% !important;
                    min-height: 2.125rem !important;
                }
                .slds-input {
                    width: 100% !important;
                    margin: 0 !important;
                }
                .slds-truncate {
                    padding: 0 !important;
                    margin: 0 !important;
                }
                .slds-pill {
                    min-height: 2.75rem !important;
                    display: flex !important;
                    align-items: center;
                }
            }
         `;
        this.template.querySelector('.preparation_form_wrapper').appendChild(style);
    }

}