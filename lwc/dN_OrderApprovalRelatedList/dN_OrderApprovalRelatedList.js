import { LightningElement, api, track, wire } from 'lwc';

import { showToast, reduceErrors, style } from 'c/commonUtils';
import customLabels from "./labels";

import { getRecord } from 'lightning/uiRecordApi';
const ORDER_FIELDS = ['Order.Status', 'Order.ERPOrderNo__c', 'Order.InternalApprovalStatus__c'];
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import dN_OrderApprovalModal from "c/dN_OrderApprovalModal";

import initRelatedList from '@salesforce/apex/DN_OrderApprovalController.initRelatedList';
import doInternalApproval from '@salesforce/apex/DN_OrderApprovalController.doInternalApproval';
import validateApproval from '@salesforce/apex/DN_OrderApprovalController.validateApproval';
import rejectApproval from '@salesforce/apex/DN_OrderApprovalController.rejectApproval';
import approveApproval from '@salesforce/apex/DN_OrderApprovalController.approveApproval';

export default class DN_OrderApprovalRelatedList extends LightningElement {

    @api recordId;


    @track columns = [];
    @track data    = [];


    isLoading = false;
    isInteface = false;
    cLabel = customLabels;

    title;  // card title
    icon;   // card icon
    hasOpty = false;

    _isOptyClosed   = false;
    _optyStageName  = '';
    _optyStageOrder = '';

    _status     = '';
    _isManager  = false; // owner is a manager or not
    _isAdmin    = false; // current user is an admin or not
    _isApprover = false; // current user is the owner's approver or not
    _isOwner    = false; // current user is an owner or not
    _isCRMUser  = false; // current user is a CRM user or not
    _hideBtn    = false;
    _wiredOrderResult;
    @wire(getRecord, { recordId: '$recordId', fields: ORDER_FIELDS })
    wiredOrder(result) {
        this._wiredOrderResult = result;
        if (result.data) {
            this.doInit();
            getRecordNotifyChange([{ recordId: this.recordId }]);
            console.log('dN_OrderApprovalRelatedList - refreshed');
        }
    }


    get isDataShow(){
        return this.data.length > 0;
    }

    get openInternalBtn(){
        // NotStarted && ((dealer worker && owner) || admin)
        return ((this._status == 'NotStarted' || this._status == 'InternalApprovalRejected') 
                && ((!this._isManager && this._isOwner && !this._isCRMUser) || this._isAdmin));
    }

    get openRequestBtn(){
        // NotStarted && (((dealer manager || direct sales) && owner) || admin)
        return (this._status == 'NotStarted' && (((this._isManager || this._isCRMUser) && this._isOwner) || this._isAdmin));
    }

    get openApproveBtn(){
        // InternalApprovalRequested && (owner.approver || admin)
        return (this._status == 'InternalApprovalRequested' && (this._isApprover || this._isAdmin));
    }

    get openBtn(){
        return (this.openInternalBtn || this.openRequestBtn || this.openApproveBtn) && !this._hideBtn;
    }

    get table_style(){
        return this.data.length > 5 ? 'slds-card__body approval_datatable' : 'slds-card__body';
    }

    get optyBadgeClass() {
        return this._isOptyClosed ? 'slds-theme_success' : 'slds-theme_error';
    }

    get optyStageBadge(){
        return customLabels.DNS_F_OpportunityStage + ' : ' + this._optyStageName + ' (' + this._optyStageOrder +'/5)';
    }



    async connectedCallback(){
        style.set(this.customstyle);

        this.reverseSpinner();

        await this.doInit();

        
        this.reverseSpinner();
    }

    disconnectedCallback() {
        style.remove(this.customstyle);
    }

    /** handler */
    async handleInternalApproval(){
        console.log('handleInternalApproval');
        this.reverseSpinner();

        let isPass = await this.validationRule(true);
        if(!isPass) { 
            this.reverseSpinner();
            return; 
        }

        const modalResult = await this.openApproalModal('RQ');
        if(!modalResult.isProcessing) { 
            this.reverseSpinner();
            return; 
        }
        
        await doInternalApproval({recordId : this.recordId, comments : modalResult.comments})
        .then(() => {
            showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_ApprovalSubmitted);
            this.doInit();
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.reverseSpinner();
        })
        .catch(error => this.errorHandler('doInternalApproval', error));
    }

    async handleERPOrderCreation(){
        console.log('handleERPOrderCreation');
        this.reverseSpinner();
        this.isInteface = true;
        let isPass = await this.validationRule(false);
        if(!isPass) { 
            this.reverseSpinner();
            this.isInteface = false;
            return; 
        }
        
        const modalResult = await this.openApproalModal('C');
        if(!modalResult.isProcessing) { 
            this.reverseSpinner();
            this.isInteface = false;
            return; 
        }

        await this.createConfirmRecord(false);
        this.isInteface = false;
    }

    async handleApprove(){
        console.log('handleApprove');
        this.reverseSpinner();
        this.isInteface = true;

        const modalResult = await this.openApproalModal('AP');
        if(!modalResult.isProcessing) { 
            this.reverseSpinner();
            this.isInteface = false;
            return; 
        }

        await this.createConfirmRecord(true, modalResult.comments);
        this.isInteface = false;
    }

    async handleReject(){
        console.log('handleReject');
        this.reverseSpinner();

        const modalResult = await this.openApproalModal('RE');
        if(!modalResult.isProcessing) { 
            this.reverseSpinner();
            return; 
        }
        
        await rejectApproval({recordId : this.recordId, comments : modalResult.comments})
        .then(() => {
            showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_ApprovalRejected);
            this.doInit();
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.reverseSpinner();
        })
        .catch(error => this.errorHandler('rejectApproval', error));

    }
    
    
    


    /** private function */
    reverseSpinner(){
        this.isLoading = !this.isLoading;
    }

    

    async openApproalModal(type){
        let isProcessing = false;
        let comments     = '';
        await dN_OrderApprovalModal.open({type : type})
        .then(result => {
            console.log('openApproalModal - result', result);
            if(result && result.status == 'save') {
                isProcessing = true;
                comments     = result.comments;
            } else if(result && result.status == 'confirm') {
                isProcessing = true;
            }
        });
        
        return {isProcessing : isProcessing, comments : comments};
    }

    async createConfirmRecord(isApprove, comments) {
        console.log('createConfirmRecord', isApprove);
        
        await approveApproval({recordId : this.recordId, comments : comments, isApprove : isApprove})
        .then(result => {
            if(result.isSuccess) {
                showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_OrderConfirmRequested);
                this.doInit();
                getRecordNotifyChange([{ recordId: this.recordId }]);
                this.reverseSpinner();
            } else {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, result.errorMsg);
            }
        })
        .catch(error => this.errorHandler('approveApproval', error));
    }

    async validationRule(isWorkerRule){
        let isPass = false;
        await validateApproval({recordId : this.recordId, isWorkerRule : isWorkerRule})
        .then(result => {
            console.log('validateApproval result :::', JSON.stringify(result, null, 1));
            if(result.isSuccess) {
                isPass = result.isSuccess;
            } else {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, result.errMessage);
            }
        })
        .catch(error => this.errorHandler('validateApproval', error));
        return isPass;
    }

    async doInit(){
        await initRelatedList({recordId : this.recordId})
        .then(result => {
            console.log('initRelatedList result :::', JSON.stringify(result, null, 1));
            if(result.isSuccess) {
                const data   = result.data;
                this.title   = data.title;
                this.icon    = data.icon;
                this.hasOpty = data.hasOpty;

                this._isOptyClosed   = data.isOptyClosed;
                this._optyStageName  = data.optyStageName;
                this._optyStageOrder = data.optyStageOrder;

                this._status     = data.status;
                this._isManager  = data.isManager;
                this._isAdmin    = data.isAdmin;
                this._isApprover = data.isApprover;
                this._isOwner    = data.isOwner;
                this._isCRMUser  = data.isCRMUser;
                this._hideBtn    = data.hideBtn;

                const fieldInfo = data.fieldInfo;
                this.columns = [
                    {label : fieldInfo.Status__c, fieldName : 'link', type : 'url', typeAttributes : { label : {fieldName : 'status'}, target : '_self'}, initialWidth: 100}
                    // { label: fieldInfo.Status__c,         initialWidth: 100, fieldName: 'status' }
                    , {label : fieldInfo.StepName__c, fieldName : 'link', type : 'url', typeAttributes : { label : {fieldName : 'stepName'}, target : '_self'}, initialWidth: 100}
                    // , { label: fieldInfo.StepName__c,     initialWidth: 100, fieldName: 'stepName' }
                    , { label: fieldInfo.Requester__c,    initialWidth: 100, fieldName: 'requester' }
                    , { label: fieldInfo.RequestDate__c,  initialWidth: 150, fieldName: 'requestDate' , type: 'date-local'}
                    , { label: fieldInfo.Approver__c,     initialWidth: 100, fieldName: 'approver' }
                    , { label: fieldInfo.DecisionDate__c, initialWidth: 150, fieldName: 'decisionDate', type: 'date-local'}
                ];
                if(data.tableWrapList) this.data = data.tableWrapList;

            } else {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, result.errMessage);
            }
        })
        .catch(error => {
            this.errorHandler('initRelatedList', error);
        });
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.error(name, errorMsg);
        showToast(this, 'error', customLabels.DNS_M_GeneralError, errorMsg);
    }


    customstyle = {
        id: 'dN_OrderApprovalRelatedList',
        style: `
            .hide_component {
                display: none;
            }
        `,
    }
}