import { LightningElement, track, api } from 'lwc';
import loadLineItems from '@salesforce/apex/DN_OpptyLineItemCopyController.loadLineItems';
import saveLineItems from '@salesforce/apex/DN_OpptyLineItemCopyController.saveLineItems';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class DN_OpptyLineItem_Copy extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track excelData = '';
    @track lineItems = [];
    @track draftValues = [];
    @track unmatchedCodes = [];
    @track columns = [
        { label: '품명', fieldName: 'productName', type: 'text', editable: false },
        // { label: 'Name', fieldName: 'productName', type: 'text', editable: false },
        { label: '수량', fieldName: 'quantity', type: 'number', editable: true },
        // { label: 'Quantity', fieldName: 'quantity', type: 'number', editable: true },
        { label: '설명', fieldName: 'description', type: 'text', editable: true },
        // { label: 'Line Description', fieldName: 'description', type: 'text', editable: true },
        { label: '단가', fieldName: 'expectedPrice', type: 'currency', editable: true },
        // { label: 'Expected Price', fieldName: 'expectedPrice', type: 'currency', editable: true },
    ];

    handleInputChange(event) {
        this.excelData = event.target.value;
    }

    handleLoadData() {
        if (!this.excelData) {
            alert('제품 코드를 붙여넣으세요');
            return;
        }

        loadLineItems({ data: this.excelData })
            .then(result => {
                this.lineItems = result.lineItems.map((item, index) => ({
                    id: index + 1,
                    productName: item.productName,
                    pricebookEntryId: item.pricebookEntryId,
                    quantity: null,
                    description: '',
                    expectedPrice: null
                }));
                this.unmatchedCodes = result.unmatchedCodes;

                if (this.unmatchedCodes.length > 0) {
                    alert(`코드값이 없습니다. 다시 확인해 주세요. 해당 코드번호: ${this.unmatchedCodes.join(', ')}`);
                }
            })
            .catch(error => {
                console.error('Error loading line items:', error);
                alert('데이터 로드 중 오류가 발생했습니다. 제품 코드를 확인해 주세요.');
            });
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
    
        // 데이터 검증
        console.log('Draft Values:', updatedFields);
        if (!updatedFields || updatedFields.length === 0) {
            alert('저장할 데이터가 없습니다.');
            return;
        }
    
        const updatedLineItems = this.lineItems.map(lineItem => {
            const draft = updatedFields.find(d => d.id === lineItem.id);
            return draft ? { ...lineItem, ...draft } : lineItem;
        });
    
        // 값 확인
        console.log('Updated Line Items:', updatedLineItems);
    
        // 데이터 유효성 검사
        const invalidItems = updatedLineItems.filter(
            item => !item.quantity || !item.expectedPrice || !item.pricebookEntryId
        );
        if (invalidItems.length > 0) {
            console.error('Invalid data detected:', invalidItems);
            alert('수량, 가격, 또는 PricebookEntryId 값이 누락되었습니다.');
            return;
        }
    
        this.isLoading = true;
    
        saveLineItems({ lineItems: updatedLineItems, recordId: this.recordId })
            .then(() => {
                alert('Opportunity Line Item 저장 성공');
                this.draftValues = [];
                this.dispatchEvent(
                    new CloseActionScreenEvent()
                );
            })
            .catch(error => {
                console.error('Error saving records:', error);
                alert('레코드 저장 오류. 다시 시도해 주세요.');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `         
            .slds-modal__container:has(c-d-n_-oppty-line-item_-copy) {
                width:100%;
                max-width: 60rem;
                padding: 0;
            }
            .slds-modal__content:has(c-d-n_-oppty-line-item_-copy) {
                height:auto !important;
                max-height:none !important;
                padding: 0;
                overflow-y: clip;
            }
            .forceChatterBasePublisher :not(.PHONE) .cuf-content:has(c-d-n_-oppty-line-item_-copy) {
                padding:0;
            }
            .runtime_platform_actionsQuickActionWrapper .quick-actions-panel:has(c-d-n_-oppty-line-item_-copy){
                overflow: hidden !important;
            }
            .slds-modal__content .slds-textarea {
                height: 5rem;
            }
            .input-container .slds-form-element {
                flex: auto;
            }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

}