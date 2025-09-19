import { LightningElement, api, track, wire } from 'lwc';

import { showToast, reduceErrors, style } from 'c/commonUtils';
import customLabels from "./labels";

import dN_OrderPaymentSplitModal from "c/dN_OrderPaymentSplitModal";

import { getRecord } from 'lightning/uiRecordApi';
const ORDER_FIELDS = ['Order.IsSyncPrice__c', 'Order.ERPOrderNo__c', 'Order.HasPricingProcessed__c', 'Order.DCAmount__c'];

import { subscribe, MessageContext } from 'lightning/messageService';
import ORDER_DATA_MESSAGE from '@salesforce/messageChannel/OrderDataMC__c';

import fetchFieldInfo from '@salesforce/apex/DN_OrderPaymentScheduleController.fetchFieldInfo';
import fetchInitData from '@salesforce/apex/DN_OrderPaymentScheduleController.fetchInitData';
import savePaymentSchedule from '@salesforce/apex/DN_OrderPaymentScheduleController.savePaymentSchedule';
import checkDraftNo from '@salesforce/apex/DN_OrderPaymentScheduleController.checkDraftNo';
import sendScheduleToERP from '@salesforce/apex/DN_OrderPaymentScheduleController.sendScheduleToERP';

const FORMATDAYS = {
    'C006' : 5
    , 'C007' : 30
    , 'C008' : 45
    , 'C009' : 60
}

export default class DN_OrderPaymentScheduleCmp extends LightningElement {
    
    @api recordId;

    @track fields;
    @track tableData  = [];
    @track headerData = [];

    draftDisabled       = true;
    isLoading           = false;
    hasPricingProcessed = false;
    preventEdit         = false;
    preventDraft        = false;
    cLabel = customLabels;
    draftOption = [];
    planNo;

    _isNew        = false;
    _capitals     = [];
    _typeDName    = 'P01';  // type
    _typeDDefault = 'CP00'; // payment terms, downpayment defalut value
    _typeCDefault = 'C007'; // payment terms, closing invoice defalut value
    _draftReset   = 'NotRequested';
    _itemEmptyRow = {};
    _draftValue;
    _dataSize = 0;

    get fieldOpen(){
        return this.fields;
    }

    get checkBtn(){
        return this.tableData.filter(d => d.isChecked).length <= 0;
    }

    get draftStatus(){
        let className = '';
        if(this._draftValue == 'Fail')    { className = 'red_button'; }
        else if(this._draftValue == 'Success') { className = 'green_button'; }
        // console.log('draftStatus', className);
        
        return className;
    }

    get draftBtnDisabled(){
        let isDisabled = true;
        console.log('draftBtnDisabled', this.headerData.hasPricingProcessed, this.preventEdit, this.preventDraft);
        
        if(this.headerData && this.headerData.hasPricingProcessed && !this.preventEdit && !this.preventDraft) {
            isDisabled = false;
        }
        console.log('draftBtnDisabled', isDisabled);

        return isDisabled;
    }

    async connectedCallback(){
        style.set(this.customstyle);

        this.isLoading = true;
        this.subscribeToMessageChannel();
        await this.getFieldInfo();
        await this.doInit();
        this.isLoading = false;
    }
    disconnectedCallback() {
        style.remove(this.customstyle);
    }
    
    renderedCallback() {
        if(this._dataSize != this.tableData.length) {
            console.log('renderedCallback - table changed');
            
            this._dataSize = this.tableData.length;

            if(this._dataSize === 0) {
                this.template.querySelector('[data-name="allCheckbox"]').checked = false;
                this.tableData = [JSON.parse(JSON.stringify(this._itemEmptyRow))];
            } else {
                let num = 1;
                let checked = 0;
                this.tableData.forEach(d => {
                    d.num = num;
                    num++;
    
                    if(d.isChecked) { checked++; }
                });
    
                if(checked == this._dataSize) { this.template.querySelector('[data-name="allCheckbox"]').checked = true; }
                else { this.template.querySelector('[data-name="allCheckbox"]').checked = false; }
            }
        }
        
        const table = this.template.querySelector('.table_section table');
        const scrollContent = this.template.querySelector('.scroll_content');
        if (table && scrollContent) { scrollContent.style.width = `${table.scrollWidth}px`; }
    }
    
    handleSave(event){
        // validation rule
        if(this.headerData.balance != 0) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_RemainAmt);
            return;
        } 

        const noScheduleDates = this.tableData.filter(d => !d.scheduleDate || d.scheduleDate == null);
        console.log('handleSave noScheduleDates::: ', noScheduleDates.length, JSON.stringify(noScheduleDates, null, 2));
        
        if(noScheduleDates.length > 0) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_EnterPlannedDate);
            return;
        }

        const over1000Days = this.tableData.filter(d => d.days > 999);
        console.log('handleSave over1000Days::: ', over1000Days.length, JSON.stringify(over1000Days, null, 2));

        if(over1000Days.length > 0) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_Over1000);
            return;
        }
        
        this.isLoading = true;

        console.log('handleSave', JSON.stringify(this.headerData, null, 1));
        savePaymentSchedule({recordId : this.recordId, psInfo : this.headerData, itemWrapStr : JSON.stringify(this.tableData)})
        .then(() => showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_PaymentScheduleSaved))
        .catch(error => this.errorHandler('savePaymentSchedule', error))
        .finally(() => this.isLoading = false);
    }

    handleDocDate(event){
        const docValue = event.target.value;

        if(docValue == '' || docValue == null) {
            event.target.value = this.headerData.reqDDate;
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_SetDocumentDate);
            return;
        }

        let isDPass = true;
        let isCPass = true;
        this.tableData.forEach(d => {
            if(d.scheduleDate && d.paymentTerms && FORMATDAYS[d.paymentTerms]) {
                d.scheduleDate = this.dateFormatter(docValue, FORMATDAYS[d.paymentTerms]);
                d.days = this.dataDiff(docValue, d.scheduleDate);
            }

            if(!d.scheduleDate) return;

            let dDate = new Date(docValue);
            let sDate = new Date(d.scheduleDate);
            if(d.type != this._typeDName && sDate < dDate) {
                isCPass        = false;
                d.scheduleDate = null;
            } else if(d.type == this._typeDName && sDate > dDate) {
                isDPass        = false;
                d.scheduleDate = null;
            }
        });

        if(!isCPass) { showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_EarlierDocDate); }
        if(!isDPass) { showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_DownPaymentOnlyPast); }

        this.headerData.docuDate = docValue;
    }

    handleDraftChange(event) {
        const selectedValue = event.detail.value;
        const fieldName     = event.target.dataset.wrapname;

        this.headerData.draftcheck = this._draftReset;
        this._draftValue = this._draftReset;

        if(fieldName == 'draftPick') {
            this.headerData.draftPick = selectedValue;
            if(selectedValue == 'etc') {
                this.draftDisabled = false;
                this.headerData.draftText = '';
            } else {
                this.draftDisabled = true;
                this.headerData.draftText  = selectedValue;
                this._draftValue = 'Success';
                this.headerData.draftcheck = this._draftValue;
            }
        } else {
            this.headerData.draftText = selectedValue;
        }
    }

    handleDraftCheck(event){
        if(!this.headerData.draftText || this.headerData.draftText == '') {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_NoDraftNo);
            return;
        }

        this.isLoading = true;

        checkDraftNo({draftNo : this.headerData.draftText, draftLabel : this.headerData.draftPick, recordId : this.recordId})
        .then(result => {
            // console.log('checkDraftNo result ::: ', result);
            
            if(result.isSuccess) {
                this._draftValue = 'Success';
            } else {
                this._draftValue = 'Fail';
                showToast(this, 'error', customLabels.DNS_M_GeneralError, result.errorMsg);
            }

            this.headerData.draftcheck = this._draftValue;
        })
        .catch(error => this.errorHandler('checkDraftNo', error))
        .finally(() => this.isLoading = false);
    }

    async handleSplit(){

        const checkedRow      = this.tableData.find(d => d.isChecked);
        const checkedRowIndex = this.tableData.findIndex(d => d.isChecked);

        if(checkedRow.length > 1) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_SelectOne);
        } else if(checkedRow.principal <= 0) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_EnterAmt);
        } else if(checkedRow.scheduleDate == '' || !checkedRow.scheduleDate) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_EnterScheduleDate);
        } else if(checkedRow.type == 'P01') {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_NotAllowedSplit);
        }else {
            await dN_OrderPaymentSplitModal.open()
            .then(result => {
                // console.log('handleSplit - result ::: ', JSON.stringify(result, null, 2));
                if(!result) return;
                
                const docDate  = new Date(this.headerData.docuDate);
                const baseDate = new Date(checkedRow.scheduleDate);

                const installment = parseInt(result.installment, 10);
                const interval    = parseInt(result.interval, 10);

                const principal  = parseInt(checkedRow.principal, 10);
                const baseAmount = Math.ceil(principal / installment);
                const lastAmount = principal - (baseAmount * (installment - 1));


                const rows = [];
                for (let i = 0; i < installment; i++) {
                    const newRow        = JSON.parse(JSON.stringify(checkedRow));
                    newRow.type         = 'P02';
                    newRow.paymentTerms = 'C002';
                    newRow.isChecked    = false;

                    // date
                    const nextDate = new Date(baseDate);
                    nextDate.setDate(1);
                    nextDate.setMonth(baseDate.getMonth() + interval * i);

                    const lastDayOfMonth = new Date(nextDate.getFullYear(), nextDate.getMonth() + 1, 0).getDate();
                    if (baseDate.getDate() > lastDayOfMonth) { nextDate.setDate(lastDayOfMonth); } 
                    else { nextDate.setDate(baseDate.getDate()); }

                    newRow.scheduleDate = nextDate.toISOString().split('T')[0];

                    // days
                    newRow.days = this.dataDiff(docDate, nextDate);

                    // amount
                    newRow.inputAmt  = i === installment - 1 ? lastAmount : baseAmount;
                    newRow.principal = newRow.inputAmt;

                    rows.push(newRow);
                }

                this.tableData.splice(checkedRowIndex, 1, ...rows);
            })
            .catch(error => this.errorHandler('fetchFieldInfo', error));
        }
        
    }

    handleAddRow(event){
        let tempRow = JSON.parse(JSON.stringify(this._itemEmptyRow));
        this.tableData.push(tempRow);
    }
    handleDeleteRow(event){
        this.tableData = this.tableData.filter(d => !d.isChecked);
        let tableSum = 0;
        this.tableData.forEach(d => {
            tableSum += Number(d.principal);
        });

        this.headerData.inputAmt = tableSum;
        this.headerData.balance  = this.headerData.totalAmt - tableSum;
    }

    handleCheckbox(event){
        const isChecked    = event.target.checked;
        const checkedValue = event.target.value;
        // console.log('Checkbox is checked:', isChecked, checkedValue);

        if(checkedValue == 'all') {
            this.tableData.forEach(d => d.isChecked = isChecked);
        } else {
            const checkRow = this.tableData.find(d => d.num == checkedValue);
            checkRow.isChecked = isChecked;

            const checkCnt = this.tableData.filter(d => d.isChecked).length;
            
            if(checkCnt == 0) {
                this.template.querySelector('[data-name="allCheckbox"]').checked = false;
            } else if(this.tableData.length == checkCnt) {
                this.template.querySelector('[data-name="allCheckbox"]').checked = true;
            }
        }
    }

    handleTypeChange(event){
        const typeValue  = event.target.value;
        const rowNum     = event.target.dataset.num;
        // console.log('handleTypeChange typeValue : ', typeValue, rowNum);

        if(typeValue == this._typeDName) {
            const checkType = this.tableData.filter(x => x.type == this._typeDName);
            if(checkType && checkType.length > 0) {
                event.target.value = '';
                showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_DownpaymentExist);
                return;
            }
        }

        this.tableData.forEach(d => {
            if(d.num != rowNum) return;
            d.type = typeValue;

            if(typeValue == this._typeDName) {
                d.paymentTerms    = this._typeDDefault;
                d.paymentDisabled = true;
                d.capitalCom      = '';
                d.capitalDisabled = true;

                let sDate = new Date(d.scheduleDate);
                let dDate = new Date(this.headerData.docuDate);

                if(dDate < sDate) {
                    showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_DownPaymentOnlyPast);
                    d.scheduleDate = null;
                }
            } else {
                d.paymentTerms    = this._typeCDefault;
                d.paymentDisabled = false;
                
                d.scheduleDate = this.dateFormatter(this.headerData.docuDate, 30);

                if(d.scheduleDate) { d.days = this.dataDiff(this.headerData.docuDate, d.scheduleDate); }
            }
            
        });
    }

    handlePaymentTerms(event){
        const paymentValue = event.target.value;
        const rowNum       = event.target.dataset.num;
        // console.log('handlePaymentTerms paymentValue : ', paymentValue, rowNum);

        this.tableData.forEach(d => {
            if(d.num != rowNum) return;
            d.paymentTerms = paymentValue;

            // set capital
            if(this._capitals.includes(paymentValue)) {
                d.capitalDisabled = false;
            } else {
                d.capitalDisabled = true;
                d.capitalCom      = '';
            }

            // set date
            if(FORMATDAYS[paymentValue]) { d.scheduleDate = this.dateFormatter(this.headerData.docuDate, FORMATDAYS[paymentValue]); }
            if(d.scheduleDate) { d.days = this.dataDiff(this.headerData.docuDate, d.scheduleDate); }
        });
    }

    handleSchduleChange(event){
        const rowNum       = event.target.dataset.num;
        const changedValue = event.target.value;

        this.tableData.forEach(d => {
            if(d.num != rowNum) return;

            let cDate = new Date(changedValue);
            let dDate = new Date(this.headerData.docuDate);
            if(d.type && d.type != this._typeDName && cDate < dDate) {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_EarlierDocDate);
                event.target.value = d.scheduleDate;
            } else if(d.type && d.type == this._typeDName && cDate > dDate) {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_DownPaymentOnlyPast);
                event.target.value = d.scheduleDate;
            } else {
                d.scheduleDate = changedValue;
            }

            if(d.scheduleDate) { d.days = this.dataDiff(this.headerData.docuDate, d.scheduleDate); }
        });
        
    }

    handleInputChange(event){
        const rowNum       = event.target.dataset.num;
        const changedField = event.target.dataset.wrapname;
        const changedValue = event.target.value;

        this.tableData.forEach(d => {
            if(d.num != rowNum) return;
            d[changedField] = changedValue;
        });
    }

    handleBlurAmt(event){
        const rowNum   = event.target.dataset.num;
        let inputValue = event.target.value;

        if(inputValue == '')         { inputValue = 0; }
        if(/^0\d+/.test(inputValue)) { inputValue = inputValue.replace(/^0+/, ''); }
        
        let tableSum = Number(inputValue);
        this.tableData.forEach(d => {
            if(d.num == rowNum) return;
            tableSum += Number(d.principal);
        });

        if(this.headerData.totalAmt < tableSum) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_ExceedTotal);
            event.target.value = 0;
        } else {
            let editedRow = this.tableData.find(r => r.num == rowNum);
            editedRow.inputAmt  = Number(inputValue);
            editedRow.principal = Number(inputValue);

            this.headerData.inputAmt = tableSum;
            this.headerData.balance  = this.headerData.totalAmt - tableSum;
        }
    }

    handleAmtEnter(event){
        const rowNum = event.target.dataset.num;

        // console.log('handleAmtEnter', event.key);
        if(event.key == 'Enter') {
            this.tableData.forEach(d => {
                if(d.num != rowNum) return;
                d.inputAmt = Number(this.headerData.balance);
            });
        }
    }



    async getFieldInfo(){
        await fetchFieldInfo({recordId : this.recordId})
        .then(result => {
            // console.log('fetchFieldInfo - result : ', JSON.stringify(result, null, 2));
            this.fields = result;
        })
        .catch(error => this.errorHandler('fetchFieldInfo', error));
    }

    async doInit(){
        await fetchInitData({recordId : this.recordId})
        .then(result => {
            // console.log('fetchInitData - result : ', JSON.stringify(result, null, 2));
            
            this.tableData     = result.psItems;
            this._capitals     = result.capitals;
            this._itemEmptyRow = result.itemEmptyRow;
            this._draftValue   = result.ps.draftcheck;
            this.draftOption   = result.draftOption;
            this.preventEdit   = result.preventEdit;
            this.preventDraft  = result.preventDraft;
            this.planNo        = result.planNo;

            if(this.preventEdit) { this.draftDisabled = true; }
            
            let tempAmt = 0;
            this.tableData.forEach(data => {
                tempAmt += data.principal;
            });

            let ps = result.ps;
            ps.inputAmt = tempAmt;
            ps.balance  = ps.totalAmt - tempAmt;

            if(!ps.docuDate) { ps.docuDate = ps.reqDDate; }
            this.headerData = ps;

            this._dataSize    = 0;
        })
        .catch(error => this.errorHandler('fetchInitData', error));

    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.error(name, errorMsg);
        showToast(this, 'error', customLabels.DNS_M_GeneralError, errorMsg);
    }

    syncScroll(event) {
        const source = event.target;
        const scrollbar = this.template.querySelector('.scrollbar_section');
        const tableSection = this.template.querySelector('.table_section');
    
        if (source === scrollbar) {
            tableSection.scrollLeft = scrollbar.scrollLeft; // 스크롤바 -> 테이블
        } else if (source === tableSection) {
            scrollbar.scrollLeft = tableSection.scrollLeft; // 테이블 -> 스크롤바
        }
    }

    dateFormatter(dateTxt, addDate){
        var tempDate = new Date(dateTxt);
        tempDate.setDate(tempDate.getDate() + addDate);
        tempDate = tempDate.toISOString().split('T')[0];
        return tempDate;
    }

    dataDiff(baseDate, otherDate){
        let date1 = new Date(baseDate);
        let date2 = new Date(otherDate);

        if (date1 > date2) { return 0; }

        let diffInMilliseconds = date1 - date2;
        return Math.abs(diffInMilliseconds) / (1000 * 60 * 60 * 24);
    }

    sendToERP(){
        this.isLoading = true;

        const over1000Days = this.tableData.filter(d => d.days > 999);
        console.log('handleSave over1000Days::: ', over1000Days.length, JSON.stringify(over1000Days, null, 2));

        if(over1000Days.length > 0) {
            showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_Over1000);
            this.isLoading = false;
            return;
        }
        
        sendScheduleToERP({recordId : this.recordId})
        .then(result => {
            if(result.isSuccess) {
                showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_PaymentSchedultTransmitted);
                this.doInit();
            } else {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, result.errorMsg);
            }
        })
        .catch(error => this.errorHandler('sendScheduleToERP', error))
        .finally(() => this.isLoading = false);
    }
    
    // catch order data update
    _wiredOrderResult;
    @wire(getRecord, { recordId: '$recordId', fields: ORDER_FIELDS })
    wiredOrder(result) {
        this._wiredOrderResult = result;
        if (result.data) {
            this.doInit();
            console.log('dN_OrderPaymentScheduleCmp - refreshed');
        }
    }

    // to refesh payment schedule
    @wire(MessageContext) messageContext;
    _subscription = null;
    subscribeToMessageChannel() {
        if (!this._subscription) {
            this._subscription = subscribe(
                this.messageContext,
                ORDER_DATA_MESSAGE,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        if (message.detail && message.detail.isChanged) {
            this.doInit();
            console.log('dN_OrderPaymentScheduleCmp handleMessage - refreshed');
        }
    }
    

    customstyle = {
        id: 'dN_OrderPaymentScheduleCmp',
        style: `
            .card-body .input-wrap .slds-form-element__control  {
                padding-left: 0;
            }
            .card-body .draft-field lightning-layout {
                display:block;
            }
            .card-body .draft-field lightning-layout .slds-slot {
                display:flex;
                gap: 0.5rem;
            }
            .card-body .draft-field lightning-layout-item:has(lightning-input){
                width: 100%;
            }
            .table_section .slds-table th:nth-child(1) .slds-form-element__control.slds-grow{
                padding: 0;
            }
            
            .table_section table.slds-datepicker__month td{
                border: none;
                background-color: #fff;
                padding: .25rem;
                font-size: .75rem;
            }
            .table_section table.slds-datepicker__month th{
                padding: .5rem;
                font-weight: 400;
                background-color: #fff;
                border: none;
            }
            .table_section table.slds-datepicker__month tr{
                border-bottom: none;
            }


            .green_button .slds-button{
                background-color: green;
                color: white;
                border:1px solid white;
            }

            .red_button .slds-button{
                background-color: red;
                color: white;
                border:1px solid white;
            }

        `,
    }
}