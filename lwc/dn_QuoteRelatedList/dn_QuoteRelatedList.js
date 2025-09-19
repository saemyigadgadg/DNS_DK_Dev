import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { onError } from 'lightning/empApi';

import formFactor from '@salesforce/client/formFactor';

import { showToast, label, reduceErrors, style } from 'c/commonUtils';
import getQuoteInfo from '@salesforce/apex/DN_QuoteRelatedController.getQuoteInfo';
import getQuoteExist from '@salesforce/apex/DN_QuoteRelatedController.getQuoteExist';
import deleteQuote from '@salesforce/apex/DN_QuoteRelatedController.deleteQuote';
import getOptyPath from '@salesforce/apex/DN_QuoteRelatedController.getOptyPath';

export default class Dn_QuoteRelatedList extends NavigationMixin(LightningElement) {

    @api recordId;

    @track columns = [];
    @track data    = [];

    isLoading;

    cLabel = label;
    
    title;  // card title
    icon;   // card icon

    opportunityName;
    isPortal;
    _isDesktop;
    _isButtonShow = false;
    isExist = false; //quote존재하면 new버튼 안보이게
    isQualified = false; //Qualified단계에서만 버튼 보이게
    chkStgPrd = false;
    hasData = false;
    type;
    currentStageName = true;
    get isDataShow(){
        return this._isDesktop;
    }
    get showPortalBtn(){
        // return this.isPortal && this._isButtonShow && !this.isExist && this.isQualified;
        return this.isPortal && this._isButtonShow && !this.isExist;
    }

    get showCRMBtn(){
        // return !this.isPortal && this._isDesktop && this._isButtonShow && !this.isExist && this.isQualified;
        return !this.isPortal && this._isDesktop && this._isButtonShow && !this.isExist;
    }

    get showMobileBtn(){
        return !this.isPortal && !this._isDesktop;
    }
    get cardStyle(){
        let cardCss = 'my_card';
        // let hasData = this.data.length > 0;

        if(this._isDesktop && !this.isPortal) {
            cardCss += ' crm_has_data';
        } 
        // else if(!hasData && this._isDesktop && !this.isPortal) {
        //     cardCss += ' crm_no_data';
        // } 
        else if(!this._isDesktop && !this.isPortal) {
            cardCss += ' mobile_has_data';
        } 
        // else if(!hasData && !this._isDesktop && !this.isPortal) {
        //     cardCss += ' mobile_no_data';
        // } 
        else if(this._isDesktop && this.isPortal) {
            cardCss += ' portal_has_data';
        } 
        // else if(!hasData && this._isDesktop && this.isPortal) {
        //     cardCss += ' portal_no_data';
        // }
        return cardCss;
    }
    get componentStyle(){
        // let componentCss = Boolean(this.chkStgPrd) ? 'related_wrapper' : 'related_wrapper hide_component';
        let componentCss;
        if(this.type == 'Turn-Key (AE)'){
            componentCss = 'related_wrapper hide_component';
        }else{
            componentCss = 'related_wrapper';
        }
        return componentCss;
    }
    connectedCallback(){
        // console.log('recordId : ' + this.recordId);
        this.doInit();
        // this.registerErrorListener();
        style.set(this.customstyle);
    }
    disconnectedCallback() {
        style.remove(this.customstyle);
    }
    handleSelect(){
        const quoteAutoName = label.DNS_M_QuoteAutoName;
        getQuoteExist({recordId : this.recordId})
        .then(result => {
            this.isExist = result.isExist;
            this.isQualified = result.isQualified;
            if(!this.isQualified){
                showToast(this, 'error', label.DNS_M_GeneralError, label.DNS_M_QuoteCreate);
                return;
            }
            // console.log('isportal : ' + this.isPortal);
            // console.log('isportal : ' + this.opportunityName);
            let backgroundStr = this.isPortal ? '/detail/' + this.recordId : '/lightning/r/Opportunity/' + this.recordId + '/view';
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Quote',
                    actionName: 'new'
                },
                state: {
                    useRecordTypeCheck: '1',
                    backgroundContext: backgroundStr,
                    defaultFieldValues: encodeDefaultFieldValues({'OpportunityId' : this.recordId, 'Name' : quoteAutoName}) //견적명은 자동 생성 됩니다.
                    // defaultFieldValues: encodeDefaultFieldValues({'OpportunityId' : this.recordId})
                }
            }, false);

        });

        
    }

    handleEdit(event){
        // console.log(event.detail.value);
        // const parseData = JSON.parse(event.detail.value);
        // const id = parseData.id;
        // const action = parseData.action;
        this.callEditAction(event.detail.value);
        // this.callEditAction(id, action);
    }

    handleViewAll(){
        // console.log('handleViewAll');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                relationshipApiName: 'Quotes',
                actionName: 'view'
            }
        }, true);
    }

    handleRowAction(event){
        // console.log('여기옴?');
        const row = event.detail.row;
        // console.log(row.Id);
        this.callEditAction(row.Id);
    }
    callEditAction(toEditId){
        // callEditAction(toEditId, action){

        // if (action == 'edit') {
            // console.log(action);

            // Edit을 실행
            let backgroundStr = this.isPortal ? '/detail/' + this.recordId : '/lightning/r/Opportunity/' + this.recordId + '/view';
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: toEditId,
                    objectApiName: 'Quote',
                    actionName: 'edit'
                },
                state: {
                    backgroundContext: backgroundStr,
                }
            }, true);
    
        // } 
        // else if (action == 'delete') {
        //     // Delete를 실행
        //     console.log(action);
        //     deleteQuote({ quoteId: toEditId })
        //         .then(() => {
        //             showToast(this,'success', 'Quote deleted successfully');
        //             this.doInit(); // 데이터 새로고침
        //         })
        //         .catch(error => {
        //             showToast(this,'error', 'Error deleting Quote');
        //         });
        // }

    }
    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        // console.log(name, errorMsg);
        showToast(this, 'error', label.DNS_M_GeneralError, errorMsg);
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
                        // console.log('DN_QuoteRelatedController - refreshed');
                    }
                }
            }
        }
    }
    
    doInit(){
        this.isLoading = true;
        this.isPortal  = false;
        this._isDesktop = formFactor == 'Large';
        // console.log('0 : ' + label.DNS_C_QuoteName);
        // console.log('1');
        getQuoteInfo({recordId : this.recordId})
        .then(result => {
            // console.log('result : ' + result.data.link);
            // console.log('getQuote result ::: ', JSON.stringify(result, null, 2));
            
            this.chkStgPrd = result.chkStgPrd;
            this._isButtonShow   = result.isButtonShow;
            this.opportunityName = result.opportunityName;

            this.isPortal = result.isPortal;
            if(result.data.length > 0) {
                // if(this.isPortal && result.data.length > 0) {
                this.columns = [
                    {label : label.DNS_M_VersionCnt, fieldName : 'Version', initialWidth: 70},
                    {label : label.DNS_C_QuoteName, fieldName : 'link', type : 'url', typeAttributes : {label : {fieldName : 'Name'}, target : '_self'}},
                    {fieldName : 'QuoteNumber', initialWidth: 75}
                    // {fieldName : 'link', type : 'url', typeAttributes : { label : {fieldName : 'QuoteNumber'}, target : '_self'}, initialWidth: 75}
                    // {label : label.DNS_C_QuoteExpirationDate, fieldName : 'ExpirationDate', initialWidth: 150}
                    , {type: 'action', typeAttributes: { rowActions: [{ label: 'Edit', name: 'edit' }] }, initialWidth: 30}
                ];
            }

            this.title = result.objName + ' (' + result.size + ')';
            this.icon = result.iconName;
            this.data = result.data || [];
            this.hasData = this.data.length > 0;
            if(this.data.length > 0){
                // for (let i = 0; i < this.data.length; i++) {
                //     this.data[i].editValue = JSON.stringify({ id: this.data[i].Id, action: 'edit' });
                //     this.data[i].deleteValue = JSON.stringify({ id: this.data[i].Id, action: 'delete' });
                // }
                this.hasData = true;
            }else{
                this.data = [];
                this.hasData = false;
            }
            this.isLoading = false;
            // console.log('isDataShow : ' + this.isDataShow);
            this.type = result.type;
        })
        .catch(error => {
            this.errorHandler('getQuoteInfo', error);
        });
        // console.log(this._isDesktop);
        // console.log(this.isPortal);
        // console.log(this.cardStyle);
        getQuoteExist({recordId : this.recordId})
        .then(result => {
            // console.log('path result : ' + JSON.stringify(result));
            this.isExist = result.isExist;
            this.isQualified = result.isQualified;
        });
        // getOptyPath({recordId : this.recordId})
        // .then(result => {
        //     if(result){
        //         console.log('pathresult : ' + result);
                
        //         this.isQualified = true;
        //     }else{
        //         this.isQualified = false;
        //     }
        // });
    }
 

    // registerErrorListener() {
    //     onError((error) => {
    //         console.log(`registerErrorListener : ${JSON.stringify(error, null, 2)}`);
    //     });
    // }
    customstyle = {
        id: 'dN_QuoteRelatedList',
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
            .slds-card__header {
                margin-bottom: 0 !important;
            }
            .slds-card__body {
                margin-top: 0 !important;
            }
        `,
    }
}