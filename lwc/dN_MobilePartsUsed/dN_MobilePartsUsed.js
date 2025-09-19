/**
 * @description       :
 * @author            : youjin.shim@sbtglobal.com
 * @group             :
 * @last modified on  : 04-04-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-28-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';

/*✔️ Apex Controller */
import getWorkOrderResultParts from '@salesforce/apex/DN_MobileServiceDatesController.getWorkOrderResultParts';
import saveWorkOrderResultsParts from '@salesforce/apex/DN_MobileServiceDatesController.saveWorkOrderResultsParts';
import getPartsInfo from '@salesforce/apex/DN_PortalModalController.getPartsInfo';


export default class DN_MobilePartsUsed extends LightningElement {
    @api recordId;
    @track checkedIds        = [];
    @track timeOptions       = [];
    @track workOrderResults  = [];
    @track productList       = [];

    deleteWorkResults        = [];
    ApplicationDateTime      = '';
    isLoading                = true;
    isModalOpen              = false;
    partNumber               = '';
    partName                 = '';
    selectedResultId         = '';

    renderedCallback() {
	    this.styleCSS();
	}

    connectedCallback() {
        setTimeout(() => {
            this.loadWorkOrderResults();
        }, 5);
    }

    loadWorkOrderResults() {
        getWorkOrderResultParts({ serviceOrderId: this.recordId })
        .then((data) => {
            if(data.status == 'success') {
                this.handleDataLoadSuccess(data);
            } else {
                this.handleDataLoadError(data);
            }
        });
    }

    handleDataLoadSuccess(data) {
        console.log('✅ 받은 데이터:', JSON.stringify(data, null, 2));

        // 데이터 가공
        this.workOrderResults = data.workOrderResults.map(record => ({
            resultId: record.resultId || '',
            ProductNumber: record.ProductNumber || '',
            ProductName: record.ProductName || '',
            IsCause: record.IsCause || false,
            Quantity: record.Quantity || '',
            Note: record.Note || '',
        }));

        if (this.workOrderResults.length === 0) {
            this.addLinesFunction();
        }

        this.isLoading = false;
    }

    handleDataLoadError(error) {
        console.error('❌ 데이터 로딩 실패:', JSON.stringify(error,null,2));
        this.isLoading = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.message,
            variant: 'error'
        }));
    }

    checkhandler(event) {
        const recordId = event.target.dataset.id;
        const isChecked = event.target.checked;

        if (isChecked) {
            if (!this.checkedIds.includes(recordId)) {
                this.checkedIds = [...this.checkedIds, recordId];
            }
        } else {
            this.checkedIds = this.checkedIds.filter(id => id !== recordId);
        }

        console.log('✅ 체크된 ID 리스트:', JSON.stringify(this.checkedIds, null, 2));
    }

    addLinesFunction() {
        const emptyRecord = {
            resultId: 'temp-' + Date.now(),
            ProductNumber: '',
            ProductName: '',
            IsCause: false,
            Quantity: '',
            Note: ''
        };
        this.workOrderResults = [...this.workOrderResults, emptyRecord];
        console.log('this.workOrderResults:::', JSON.stringify(this.workOrderResults,null,2));
    }

    deleteWorkList() {
        if (this.checkedIds.length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: 'Please select the item you want to delete.',
                variant: 'warning'
            }));
            return;
        }

        this.workOrderResults = this.workOrderResults.filter(record => {
            if (this.checkedIds.includes(record.resultId)) {
                // temp-가 아닌 경우, deleteWorkResults에 ID 추가
                if (!record.resultId.startsWith('temp-')) {
                    this.deleteWorkResults.push(record.resultId);
                }
                return false;
            }
            return true;
        });

        this.checkedIds = [];
    }

    searchProductCode(event) {
        this.selectedResultId = event.currentTarget.dataset.id;
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedResultId = '';
        this.partNumber = '';
        this.partName   = '';
        this.productList = [];
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleValueChange(event) {
        const recordId = event.target.dataset.id;
        const fieldName = event.target.name;
        let value;

        switch (event.target.type) {
            case 'checkbox':
                value = event.target.checked;
                break;
            case 'number':
                value = event.target.value ? parseFloat(event.target.value) : null;
                break;
            default:
                value = event.target.value;
        }

        this.workOrderResults = this.workOrderResults.map(record => {
            if (record.resultId === recordId) {
                return { ...record, [fieldName]: value };
            }
            return record;
        });
    }

    handleProductSearch() {
        this.isLoading = true;
        // console.log('this.partNumber:::', this.partNumber);
        // console.log('this.partName:::', this.partName);
        // console.log('this.selectedResultId:::', this.selectedResultId);

        // 입력값 검증 함수
        if ((!this.partNumber || this.partNumber.trim() == '') && (!this.partName || this.partName.trim() == '')) {
            this.showToast('WARNING', 'You must enter one of the part number or product name.');
            this.isLoading = false;
            return;
        }
        if(this.partNumber && this.partNumber.length < 3) {
            this.showToast('WARNING', 'Please enter a part number of at least 3 digits.');
            this.isLoading = false;
            return;
        }
        if(this.partName && this.partName.length < 3) {
            this.showToast('WARNING', 'Please enter a product name of at least 3 digits.');
            this.isLoading = false;
            return;
        }

        let partCode = this.partNumber != undefined ? this.partNumber.trim() : null;
        let partName = this.partName != undefined ? this.partName.trim() : null;

        // console.log('af partCode :::' + partCode);
        // console.log('af partName :::' + partName);

        getPartsInfo({
            partCode: partCode,
            partName: partName,
            partList: [] // 필요 없는 Param
        })
        .then((data) => {
            if(data) {
                this.isLoading = false;
                if(data.length > 0) {
                    console.log('Data 설정');
                    this.productList = data;
                } else {
                    this.showToast('WARNING', 'No parts found.');
                }
            } else {
                // this.showToast('ERROR', 'error');
                this.isLoading = false;
            }
        });
    }

    handleRowClick(event) {
        const selectedProductCode = event.currentTarget.dataset.productcode;
        const selectedProductName = event.currentTarget.dataset.productname;

        let recordId = this.selectedResultId;
        let updatedRecords = this.workOrderResults.map(record => {
            if (record.resultId === recordId) {
                return {
                    ...record,
                    ProductNumber: selectedProductCode,
                    ProductName: selectedProductName
                };
            }
            return record;
        });

        this.workOrderResults = updatedRecords;
        console.log('this.workOrderResults:::', JSON.stringify(this.workOrderResults,null,2));
        this.closeModal();
    }

    showToast(title, message, variant = 'Warning') {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant.toLowerCase()
        }));
    }

    saveResultHandler() {
        // this.isLoading = true;
        console.log('Save Work Result:::', JSON.stringify(this.workOrderResults,null,2));
        console.log('Delete Work Result:::', JSON.stringify(this.deleteWorkResults,null,2));
        this.isLoading = true;
        if(this.workOrderResults.length === 0) {
            this.showToast('ERROR', 'No data to save.');
            this.isLoading = false;
            return;
        } else {
            // 🔥 필수 필드 검증 (null 또는 공백 체크)
            let invalidRecords = this.workOrderResults.filter(record =>
                !record.ProductNumber ||
                !record.ProductName ||
                !record.Quantity
            );

            if (invalidRecords.length > 0) {
                this.showToast('ERROR', 'There are missing required fields.');
                this.isLoading = false;
                return;
            }
        }
        saveWorkOrderResultsParts({
            workOrderId: this.recordId,
            saveResults: JSON.stringify(this.workOrderResults),
            deleteResults: this.deleteWorkResults
        })
        .then((data) => {
            if(data.isSuccess) {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: data.message,
                    variant: 'success'
                }));
                setTimeout(() => {
                    this.dispatchEvent(
                        new CloseActionScreenEvent()
                    );
                }, 1500);
            } else {
                this.showToast('ERROR', data.message);
                this.isLoading = false;
            }
        });
    }

    styleCSS() { // 함수 이름 바꿔줬음
        const style = document.createElement('style');
                style.innerText = `
                    .modal-container:has(c-d-n_-mobile-parts-used) {
                        width: 480px !important;
                        max-width: 480px !important;
                    }
                    .wrapper .btn-wrap .slds-button {
                        padding: 0.5rem;
                    }
                    .wrapper .btn-wrap .slds-button svg {
                        margin-right: 0;
                    }
                    .wrapper .input-wrap .slds-dropdown-trigger, .wrapper .input-wrap .input-text, .wrapper .input-wrap lightning-combobox>div {
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                    }
                    .wrapper .slds-checkbox .slds-checkbox__label .slds-form-element__label {
                        padding: 0;
                    }
                    .wrapper .input-wrap .slds-form-element__control {
                        padding-left: 0;
                    }
                    .wrapper .input-wrap lightning-input {
                        width: 100%;
                    }

                    /*modal*/
                    .wrapper .slds-table_striped tbody tr:nth-of-type(even)>td {
                        background-color: #f1f3f5;-
                    }

                `;
                this.template.querySelector('div').appendChild(style);
    }
}