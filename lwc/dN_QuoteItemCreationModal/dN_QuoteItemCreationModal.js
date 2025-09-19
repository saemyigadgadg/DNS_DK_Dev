import { LightningElement, api, track } from 'lwc';

import { showToast, reduceErrors, style } from 'c/commonUtils';
import customLabels from "./labels";

import findProducts from '@salesforce/apex/DN_QuoteItemCreationController.findProducts';
import addQuoteProducts from '@salesforce/apex/DN_QuoteItemCreationController.addQuoteProducts';
import addOptyProduct from '@salesforce/apex/DN_QuoteItemCreationController.addOptyProduct';
import getRecordType from '@salesforce/apex/DN_QuoteItemCreationController.getRecordType';
import getUserType from '@salesforce/apex/DN_QuoteItemCreationController.getUserType';
import validateProducts from '@salesforce/apex/DN_QuoteItemCreationController.validateProducts';

const COLUMNS_DOM = [
    {label : customLabels.DNS_F_Product, fieldName : 'prodUrl', type : 'url', typeAttributes : { label : {fieldName : 'prodCode'}, target : '_blank'}, initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_Quantity, fieldName : 'quantity', type : 'number', editable : true, initialWidth: 150}
    , {label : customLabels.DNS_C_ProductModel, fieldName : 'model', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_NC, fieldName : 'ncSystem', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_B_Spindle, fieldName : 'spindle', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_CRTSize, fieldName : 'monitorSize', initialWidth: 100, sortable: true}
    , {label : customLabels.DNS_C_Region, fieldName : 'region', initialWidth: 100, sortable: true}
    , {label : customLabels.DNS_C_ProdDescription, fieldName : 'prodDescription', initialWidth: 250, sortable: true}
    , {label : customLabels.DNS_C_MOTOR, fieldName : 'motor', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_TOOL, fieldName : 'tool', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_ETC, fieldName : 'etc', initialWidth: 200, sortable: true}
];

const COLUMNS_OVE = [
    {label : customLabels.DNS_C_Quantity, fieldName : 'quantity', type : 'number', editable : true, initialWidth: 150}
    , {label : customLabels.DNS_C_ProductModel, fieldName : 'model', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_F_Product, fieldName : 'prodUrl', type : 'url', typeAttributes : { label : {fieldName : 'prodCode'}, target : '_blank'}, initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_ProdDescription, fieldName : 'prodDescription', initialWidth: 250, sortable: true}
    , {label : customLabels.DNS_C_NC, fieldName : 'ncSystem', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_MOTOR, fieldName : 'motor', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_B_Spindle, fieldName : 'spindle', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_TOOL, fieldName : 'tool', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_CRTSize, fieldName : 'monitorSize', initialWidth: 100, sortable: true}
    , {label : customLabels.DNS_C_Region, fieldName : 'region', initialWidth: 100, sortable: true}
    , {label : customLabels.DNS_C_ETC, fieldName : 'etc', initialWidth: 200, sortable: true}
    // , {label : customLabels.DNS_C_IsStrategicMaterial, fieldName : 'prodStrategic', type: 'boolean', cellAttributes: { alignment: 'center' }, initialWidth: 150, sortable: true}
];

const COLUMNS_DNSA = [
    {label : customLabels.DNS_F_Product, fieldName : 'prodUrl', type : 'url', typeAttributes : { label : {fieldName : 'prodCode'}, target : '_blank'}, initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_ProdDescription, fieldName : 'prodDescription', initialWidth: 250, sortable: true}
    , {label : customLabels.DNS_C_ProductModel, fieldName : 'model', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_NC, fieldName : 'ncSystem', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_B_Spindle, fieldName : 'spindle', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_CRTSize, fieldName : 'monitorSize', initialWidth: 100, sortable: true}
    , {label : customLabels.DNS_C_TOOL, fieldName : 'tool', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_MOTOR, fieldName : 'motor', initialWidth: 200, sortable: true}
    , {label : customLabels.DNS_C_Region, fieldName : 'region', initialWidth: 100, sortable: true}
    , {label : customLabels.DNS_C_ETC, fieldName : 'etc', initialWidth: 200, sortable: true}
];

export default class DN_QuoteItemCreationModal extends LightningElement {
    @api recordId;
    @api objName;

    @track searchKey;
    @track prdCode;
    // @track priceBook;

    @track tableColumns  = [];
    @track tableData     = [];
    @track selectedData  = [];

    @track showSelected = false;
    @track showViewAll  = false;

    isLoading = false;
    cLabel = customLabels;

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    get selectedCnt(){
        return this.selectedData.length ?? 0;
    }

    async connectedCallback(){
        style.set(this.customstyle);

        await validateProducts({recordId: this.recordId})
        .then(result => {
            if(!result.isPass) {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, result.errorMsg);
                this.closeModal();
            }
        });

        await getUserType({recordId : this.recordId})
        .then(result => {
            if(result == 'DNSA') { this.tableColumns = COLUMNS_DNSA; }
            else if(result == 'Global') { this.tableColumns = COLUMNS_OVE; }
            else { this.tableColumns = COLUMNS_DOM; }
        });

        await this.searchData();
    }
    disconnectedCallback() {
        style.remove(this.customstyle);
    }

    handleClose(){
        this.closeModal();
    }

    handleRowSelection(event){
        const selRows    = event.detail.selectedRows;
        const actionData = event.detail.config.value;
        // console.log('handleRowSelection : ', event.detail.config, selRows);
        
        let selectedData = this.selectedData;
        
        switch (event.detail.config.action) {
            case 'selectAllRows': 
                let prevSelIds = [];
                selectedData.forEach(x => prevSelIds.push(x.entryId));

                const addedRows = selRows.filter(x => !prevSelIds.includes(x.entryId));
                selectedData = [... addedRows];
                break;
            case 'deselectAllRows':
                let delIds = [];
                this.tableData.forEach(x => delIds.push(x.entryId));

                selectedData = selectedData.filter(x => !delIds.includes(x.entryId));
                break;
            case 'rowSelect':
                const addedRow = selRows.filter(x => x.entryId == actionData);
                selectedData.push(addedRow[0]);
                break;
            case 'rowDeselect':
                selectedData = selectedData.filter(x => x.entryId != actionData);
                break;
        }

        this.selectedData  = selectedData;
    }

    handleInputChange(event){
        this.searchKey = event.detail.value;
    }

    async handleInputSubmit(event){
        if (!event.target.value.length) { 
            this.searchKey   = ''; 
            this.showViewAll = false;
        } else {
            this.showViewAll = true;
        }
        this.showSelected = false;
        await this.searchData();
    }

    handleSave(){
        this.isLoading = true;
        const selectedData = this.selectedData;
        const draftValues  = this.template.querySelector('lightning-datatable').draftValues;
        const filteredData = draftValues.filter(x => x.quantity <= 0);
        console.log('selectedData : ' + JSON.stringify(selectedData, null, 1));
        console.log('draftValues  : ' + JSON.stringify(draftValues,  null, 1));
        console.log('filteredData : ' + JSON.stringify(filteredData, null, 1));

        getRecordType({recordId : this.recordId})
        .then(result => {
            console.log('count : ' + result.Count);
            if(selectedData.length > 1 && (result.Type == 'DNSA Commodity' || result.Type == 'DNSA Factory')){
                showToast(this, 'error', customLabels.DNS_M_GeneralError, 'Please Select Only One Product');
                this.isLoading = false;
                return;
            }else if (result.Count == 1 && (result.Type == 'DNSA Commodity' || result.Type == 'DNSA Factory')){
                showToast(this, 'error', customLabels.DNS_M_GeneralError, 'There are already selected products');
                this.isLoading = false;
                return;
            }
            else{
                if(selectedData.length == 0) {
                    showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_NoSelectItem);
                    this.isLoading = false;
                    return;
                } else if(filteredData.length > 0) {
                    showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_QuantityGreater0);
                    this.isLoading = false;
                    return;
                }
        
                draftValues.forEach(x => {
                    const thisData = selectedData.find(y => x.entryId == y.entryId);
                    if(thisData) {
                        thisData.quantity = parseInt(x.quantity, 10);
                    }
                });
        
                console.log('handleSave - selectedData ::: ', JSON.stringify(selectedData, null, 2));
                
                if(this.objName == 'Quote') {
                    addQuoteProducts({recordId : this.recordId, prods : selectedData})
                    .then(() => {
                        showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_ProductSaved); // The product has been saved.
                        this.closeModal();
                    })
                    .catch(error => {
                        this.errorHandler('addQuoteProducts', error);
                        this.isLoading = false;
                    });
                } else {
                    addOptyProduct({recordId : this.recordId, prods : selectedData})
                    .then(()=> {
                        showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_ProductSaved); // The product has been saved.
                        this.closeModal();
                    })
                    .catch(error => {
                        this.errorHandler('addOptyProduct', error)
                        this.isLoading = false;
                    });
                }
            }
        })
    }

    async handleShowSelected(){
        this.showSelected = !this.showSelected;

        if(this.showSelected) {
            this.tableData = this.selectedData;
            this.checkSelection();
        } else {
            await this.searchData();
        }
    }

    async handleShowViewAll(){
        this.showViewAll  = false;
        this.showSelected = false;
        this.searchKey    = '';
        await this.searchData();
    }

    handleSort(event){
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.tableData];

        let fieldName = sortedBy;
        if(sortedBy == 'prodUrl') { 
            fieldName = 'prodCode'; 
        } 
        
        cloneData.sort(this.sortBy(fieldName, sortDirection !== 'asc' ? -1 : 1));
        this.tableData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    
    
    
    checkSelection(){
        let selectedIds = [];
        this.selectedData.forEach(d => selectedIds.push(d.entryId));
        this.template.querySelector('lightning-datatable').selectedRows = selectedIds;
    }

    closeModal(msg){
        console.log('closeModal');
        this.dispatchEvent(new CustomEvent('closemodal', {detail: {value : msg}}));
    }

    async searchData(){
        this.isLoading = true;
        await findProducts({recordId : this.recordId, objName : this.objName, searchKey : this.searchKey, recordLimit : 100})
        .then(result => {
            // console.log('findProducts - result::: ', JSON.stringify(result, null, 2));
            // this.priceBook = result.priceBook;
            this.tableData = result.prods;
            
            this.checkSelection();
            this.isLoading = false;
        })
        .catch(error => this.errorHandler('findProducts', error));
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.error(name, errorMsg);

        if(errorMsg.includes('first error:')) {
            const splitMessage = errorMsg.split('first error:');
            errorMsg = splitMessage[1].trim();
            if(errorMsg.includes('EXCEPTION,')) {
                const splitMessage2 = errorMsg.split('EXCEPTION,');
                errorMsg = splitMessage2[1].trim();
                if(errorMsg.includes(':')) {
                    const splitMessage3 = errorMsg.split(':');
                    errorMsg = splitMessage3[0].trim();
                }
            }
        }
        showToast(this, 'error', customLabels.DNS_M_GeneralError, errorMsg);
    }

    sortBy(field, reverse, primer) {
        const key = primer 
                  ? (x) => (x[field] != null && x[field] !== '' ? primer(x[field]) : null) 
                  : (x) => (x[field] != null && x[field] !== '' ? x[field] : null);

        return function (a, b) {
            a = key(a);
            b = key(b);

            if (a === null && b === null) return 0;
            if (a === null) return reverse === 1 ? 1 : -1;
            if (b === null) return reverse === 1 ? -1 : 1;

            return reverse * ((a > b) - (b > a));
        };
    }

    customstyle = {
        id: 'dN_QuoteItemCreationModal',
        style: `
            
        `,
    }
}