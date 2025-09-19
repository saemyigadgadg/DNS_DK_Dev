import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
const ORDER_FIELDS = ['Order.Status', 'Order.RecordTypeId'];

import ORDER_OBJECT from '@salesforce/schema/Order';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

import { showToast, reduceErrors, style } from 'c/commonUtils';

const grayStatus = ['Canceled', 'Returned'];

import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 

export default class DN_OrderPath extends LightningElement {
    @api recordId;
    
    @track statusOptions = [];
    @track grayOptions   = [];
    @track isGeneral = true;
    
    recordTypeId;
    currentStatus;
    
    _isFirstRender = true;
    
    @wire(getRecord, { recordId: '$recordId', fields: ORDER_FIELDS })
    orderRecordInfo({ error, data }) {
        console.log('orderRecordInfo');
        if (data) {
            this.recordTypeId  = data.fields.RecordTypeId.value;
            this.currentStatus = data.fields.Status.value;
            // console.log('DN_OrderPath - orderRecordInfo ::: ', this.recordTypeId, this.currentStatus);
        } else if (error) {
            this.errorHandler('orderRecordInfo', error);
        }
    }


    @wire (getPicklistValuesByRecordType, { objectApiName: ORDER_OBJECT, recordTypeId: '$recordTypeId' })
    statusInfo({ error, data }) {
        console.log('statusInfo');
        if (data) {

            this.statusOptions = [];
            let currOptions    = [];
            
            this.isGeneral = !grayStatus.includes(this.currentStatus);
            
            data.picklistFieldValues[STATUS_FIELD.fieldApiName].values.forEach(item => {
                let tempCurr   = this.currentStatus == item.value;
                let tempOption = { label: item.label, value: item.value, isCurr : tempCurr};

                if( (this.isGeneral && !grayStatus.includes(item.value)) || (!this.isGeneral && this.currentStatus == item.value) ) {
                    currOptions.push(tempOption);
                }
            });
            this.statusOptions = currOptions;
            // console.log('DN_OrderPath - statusInfo ::: ', JSON.stringify(this.statusOptions, null, 1));
        } else if (error) {
            this.errorHandler('statusInfo', error);
        }
    }

    connectedCallback(){
        style.set(this.customstyle);

        window.sessionStorage.setItem("parentRecordId", this.recordId); // for new preaparation & delivery button
    }

    disconnectedCallback() {
        style.remove(this.customstyle);
    }

    renderedCallback() {
        setTimeout(() => {
            // 1. 현재 활성화된 단계 찾기 (slds-is-current 클래스가 있는 요소)
            const currentStep = this.template.querySelector('.slds-is-current');
    
            if (currentStep && !currentStep.classList.contains('slds-is-active')) {
                console.log('Applying slds-is-active to:', currentStep);
                currentStep.classList.add('slds-is-active');
            }
        }, 0);
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.error(name, errorMsg);
        showToast(this, 'error', DNS_M_GeneralError, errorMsg);
    }

    customstyle = {
        id: 'dN_OrderPath',
        style: `
            
            .gray_path .slds-is-active:first-child:before
            , .gray_path .slds-is-active:first-child:after 
            , .gray_path .slds-is-active:first-child:hover 
            , .gray_path a.slds-path__link
            , .gray_path .slds-path__item {
                background: dimgray;
                border: 2px solid dimgray !important;
            }

            // .siteforceContentArea:has(.order_path_wrapper) .forceCommunityTabLayout .slds-tabs_default__content .record-body-container records-record-layout-block records-record-layout-section:last-of-type .slds-m-vertical_none .section__content .slds-form__row:last-of-type .slds-grid .item-left {
            //     display: none;
            // }

            //  .siteforceContentArea:has(.order_path_wrapper) .forceCommunityTabLayout .slds-tabs_default__content .record-body-container records-record-layout-block records-record-layout-section:last-of-type .slds-m-vertical_none .section__content .slds-form__row:last-of-type .slds-grid .item-right {
            //     min-height: unset;
            //     height: 1.5rem !important;
            // }

            .siteforceContentArea:has(.order_path_wrapper) .forceCommunityTabLayout .slds-tabs_default__content .record-body-container records-record-layout-block records-record-layout-section:last-of-type  {
                display: none;
            }

            .siteforceContentArea:has(.order_path_wrapper) .forceCommunityTabLayout .slds-tabs_default__content .record-body-container records-record-layout-block records-record-layout-section:nth-last-of-type(2) {
                margin-bottom: 1.5rem;
            }

            // .general_path .general_curr.slds-is-current:before
            // , .general_path .general_curr.slds-is-current:after{
            //     background: rgb(1, 68, 134);
            //     border: 2px solid rgb(1, 68, 134) !important;
            // }

            // .general_path .general_curr a.slds-path__link{
            //     color: rgb(255, 255, 255);
            // }
        `,
    }
}