import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { subscribe, onError } from 'lightning/empApi';
import formFactor from '@salesforce/client/formFactor';

import { showToast, label, reduceErrors, style } from 'c/commonUtils';

import getInspectionInfo from '@salesforce/apex/DN_InspectionRelatedController.getInspectionInfo';

export default class DN_InspectionRelatedList extends NavigationMixin(LightningElement) {

    @api recordId;

    @track columns = [];
    @track data    = [];

    isLoading;
    hasInspectionSQ;
    
    cLabel = label;
    
    title;  // card title
    icon;   // card icon
    
    isPortal; // true : portal user, false : crm user
    _isDesktop;
    _isButtonShow = false; // SLS-DLV-003

    _channelName  = '/data/OrderChangeEvent';
    _subscription = {};

    get isDataShow(){
        return this.data.length > 0 && this._isDesktop;
    }

    get showPortalBtn(){
        console.log('showPortalBtn - ', this.isPortal, this._isButtonShow);
        
        return this.isPortal && this._isButtonShow;
    }

    get showCRMBtn(){
        return !this.isPortal && this._isDesktop && this._isButtonShow;
    }

    get showMobileBtn(){
        return !this.isPortal && !this._isDesktop;
    }

    get cardStyle(){
        let cardCss = 'my_card';
        let hasData = this.data.length > 0;

        if(hasData && this._isDesktop && !this.isPortal) {
            cardCss += ' crm_has_data';
        } else if(!hasData && this._isDesktop && !this.isPortal) {
            cardCss += ' crm_no_data';
        } else if(hasData && !this._isDesktop && !this.isPortal) {
            cardCss += ' mobile_has_data';
        } else if(!hasData && !this._isDesktop && !this.isPortal) {
            cardCss += ' mobile_no_data';
        } else if(hasData && this._isDesktop && this.isPortal) {
            cardCss += ' portal_has_data';
        } else if(!hasData && this._isDesktop && this.isPortal) {
            cardCss += ' portal_no_data';
        }
        return cardCss;
    }

    get componentStyle(){
        let componentCss = Boolean(this.hasInspectionSQ) ? 'related_wrapper' : 'related_wrapper hide_component';
        return componentCss;
    }

    connectedCallback(){
        this.doInit();
        this.registerErrorListener();
        this.handleSubscribe();
        style.set(this.customstyle);

        window.sessionStorage.setItem("parentRecordId", this.recordId); // for new preaparation button
        console.log('parentRecordId', this.recordId);
        
    }
    disconnectedCallback() {
        style.remove(this.customstyle);
    }

    handleSelect(){
        let backgroundStr = this.isPortal ? '/detail/' + this.recordId : '/lightning/r/Order/' + this.recordId + '/view';
        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Inspection__c',
                actionName: 'new'
            },
            state: {
                useRecordTypeCheck: '1',
                backgroundContext: backgroundStr,
                defaultFieldValues: encodeDefaultFieldValues({'Order__c' : this.recordId})
            }
        }, true);
    }

    handleEdit(event){
        this.callEditAction(event.detail.value);
    }

    handleViewAll(){
        console.log('handleViewAll');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Order',
                relationshipApiName: 'Inspection__r',
                actionName: 'view'
            }
        }, true);
    }
    
    handleRowAction(event){
        const row = event.detail.row;
        this.callEditAction(row.recordId);
    }

    callEditAction(toEditId){
        let backgroundStr = this.isPortal ? '/detail/' + this.recordId : '/lightning/r/Order/' + this.recordId + '/view';
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: toEditId,
                objectApiName: 'Inspection__c',
                actionName: 'edit'
            },
            state: {
                backgroundContext: backgroundStr,
            }
        }, true);
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.log(name, errorMsg);
        showToast(this, 'error', label.DNS_M_GeneralError, errorMsg);
    }

    handleSubscribe(){
        const messageCallback = (response) => {
            this.doRefresh(response);
        };

        subscribe(this._channelName, -1, messageCallback).then(response => {
            this._subscription = response;
        });
    }

    doRefresh(response){
        if(response.hasOwnProperty('data')){
            let jsonObj = response.data;
            
            if(jsonObj.hasOwnProperty('payload')){
                let payload   = response.data.payload;
                let recordIds = payload.ChangeEventHeader.recordIds;
                
                if(payload.ChangeEventHeader.changedFields.includes('Status')){
                    const recId = recordIds.find(element=> element == this.recordId);
                    if(recId !=undefined){
                        this.doInit();
                        console.log('DN_InspectionRelatedList - refreshed');
                    }
                }
            }
        }
    }

    doInit(){
        this.isLoading = true;
        this.isPortal  = false;
        this._isDesktop = formFactor == 'Large';

        getInspectionInfo({recordId : this.recordId})
        .then(result => {
            // console.log('getInspectionInfo result ::: ', JSON.stringify(result, null, 2));
            
            this.hasInspectionSQ = result.hasInspectionSQ;
            this._isButtonShow   = result.isButtonShow;

            this.isPortal = result.isPortal;
            if(this.isPortal) {
                this.columns = [
                    {label : label.DNS_C_InspectionName, fieldName : 'link', type : 'url', typeAttributes : { label : {fieldName : 'recordName'}, target : '_self'}, initialWidth: 150}
                    , {label : label.DNS_C_RecordType, fieldName : 'typeName', initialWidth: 150}
                    , {label : label.DNS_C_StartDateOfVisit, fieldName : 'startDateTime', initialWidth: 150}
                    , {label : label.DNS_C_EndDateOfVisit, fieldName : 'endDateTime', initialWidth: 150}
                    , {type: 'action', typeAttributes: { rowActions: [{ label: 'Edit', name: 'edit' }] }}
                ];
            }
            const dataSize = result.size > 3 ? '3+' : result.size;
            this.title = result.objName + ' (' + dataSize + ')';
            this.icon  = result.iconName;
            this.data  = result.data;

            this.isLoading = false;
        })
        .catch(error => {
            this.errorHandler('getInspectionInfo', error);
        });
    }

    registerErrorListener() {
        onError((error) => {
            console.log(`registerErrorListener : ${JSON.stringify(error, null, 2)}`);
        });
    }


    customstyle = {
        id: 'dN_InspectionRelatedList',
        style: `

            .my_card .slds-card__header{
                border-bottom-left-radius: 0;
                border-bottom-right-radius: 0;
                border-top-left-radius: 5px;
                border-top-right-radius: 5px;
                background-color: #F3F3F3;
            }


            .crm_has_data .slds-card__header{
                border-bottom: 1px solid rgb(201, 201, 201);
                padding: 0.7rem 0.75rem;
            }
            .crm_has_data .slds-card__footer{
                padding: 0 !important;
            }
            .crm_no_data .slds-card__header{
                padding: 0.8rem;
                margin: 0;
            }
            .crm_no_data .slds-card__body{
                margin: 0;
            }


            .portal_has_data .slds-card__header{
                margin: 0;
                padding: 1rem;
                border-bottom: 1px solid #D4D4D4;
            }
            .portal_has_data .slds-card__body
            , .portal_no_data .slds-card__body{
                margin: 0 !important;
            }
            .portal_has_data .slds-card__footer{
                margin: 0;
                padding: 0.3rem 0.7rem;
            }
            .portal_no_data .slds-card__header{
                margin: 0;
                padding: 1rem;
            }


            .mobile_has_data .slds-card__header
            , .mobile_no_data .slds-card__header{
                margin: 0;
                padding: 0.5rem 0.7rem;
                background-color: white;
            }
            .mobile_has_data .slds-card__body
            , .mobile_no_data .slds-card__body{
                margin: 0;
            }

            
            .hide_component {
                display: none;
            }
        `,
    }
    
}