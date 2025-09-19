import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import searchProducts from '@salesforce/apex/DN_PartBillingController.searchProducts';
import getPartRequests from '@salesforce/apex/DN_PartBillingController.getPartRequests';
import createProductRequest from '@salesforce/apex/DN_PartBillingController.createProductRequest';
import deleteProductRequest from '@salesforce/apex/DN_PartBillingController.deleteProductRequest';
import getDealerInventory from '@salesforce/apex/DN_PartBillingController.getDealerInventory';
import getDealerStocks from '@salesforce/apex/DN_PartBillingController.getDealerStocks';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class DN_PartBillingButton extends LightningElement {
    @track dealerStocksList = [];
    @track partRequestList = [];
    @track dealerInventoryList = [];
    // @track isMainView = true;
    @track isAddPartView = true;
    @track isPartDetailsView = false;
    @track isConfirmationVisible = false;
    @track isModalOpen = false;
    @track searchKey = '';
    @track searchResults = [];
    @track productDetails = {};
    @track selectedFilter = 'productNumber';
    @track quantity = 1
    @track isLoading = false;
    @track dealerInventory = {};
    @api recordId;
    @api productCode;

    cLabel = label;


    /* SLDS Custom Styles */
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
            .page-01 .button-wrap .slds-button_neutral{
                border: none;
                border-left: 1px solid #E5E5E5;
                padding: 0.25rem 0.5rem;
                border-radius: 0;
                width: 5.25rem;
                height: 100%;
                font-size: 15px;
                font-weight: 400;
                line-height: 160%;
                word-break: break-all;
            }
            .page-01 .add-button .slds-button_brand{
                width: 100%;
                padding: 0.5rem;
                margin-top
            }
            .page-01 .header .button-wrap .slds-button_brand{
                font-size: 16px;
                line-height: 1.875rem;
            }
            .page-02 .search-wrap .slds-input{
                border: 1px solid #AEAEAE;                
            }
            .page-02 .search-wrap .slds-m-left_small{
                margin-left: 0;
            }
            .page-02 .search-wrap .slds-form-element{
                flex: auto;
            }
            .page-02 .search-wrap .slds-button{
                padding-left: 1.25rem;
                padding-right: 1.25rem;
                border: 1px solid #AEAEAE;
                font-size: 18px;
                text-wrap: nowrap;
            }
            .page-02 .filter-wrap .slds-radio_button-group{
                display: flex;
                border: none;
                border-radius: unset;
                gap: 0.5rem;
                align-items: stretch;
            }
            .page-02 .filter-wrap .slds-radio_button{
                flex: 1; 
                min-height: 3.25rem;   
                height: 3.25rem;
                display: flex; 
            }
            .page-02 .filter-wrap .slds-radio_button+.slds-radio_button{
                border: none;
            }
            .page-02 .filter-wrap .slds-radio_button__label{
                width: 100%;
                height: 100%;
                background-color: #f3f3f3;
                color: #444;
                border-radius: 0.25rem !important;
                padding: 0.25rem 0.75rem;
                font-size: 18px;
                text-align: center;
                line-height: 120%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 400;
            }
            .filter-wrap .slds-radio_button__label .slds-radio_faux {
                padding: 0 !important;
            }
            .page-02 .filter-wrap .slds-radio_button [type=radio]:checked+.slds-radio_button__label:focus,
            .page-02 .filter-wrap .slds-radio_button [type=radio]:checked+.slds-radio_button__label:hover{
                background-color: #0176D3 !important;
             }    
            .page-03 .button-wrap .slds-button_neutral{
                border: none;
                padding-left: 0;
            }
            .page-03 .input-wrap .slds-input{
                font-size: 18px !important;
                padding-left: 0.25rem !important;
            }
            .page-03 .field-wrap .quantity-input-wrap ..slds-form-element__control{
                padding-left: 0.25rem;
                margin-top: 0.5rem;
            }
            .page-03 .add-button .slds-button_brand{
                width: 100%;
                padding: 0.5rem;
            }
            .page-03 .field-wrap .input-wrap .slds-form-element__help {
                display: none !important;
            }
            .confirm-wrap .icon-wrap .slds-icon{
                fill: #0176D3;
            }

         `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

    connectedCallback() {
        this.loadPartRequests();
    }

    loadDealerInventory() {
        console.log('Product Details:', this.productDetails); 
        this.isLoading = true;
        const productId = this.productDetails.Id;
    
        getDealerInventory({ productId: productId })
            .then(response => {
                const result = JSON.parse(response);
                const inven = result.ES_INFO || {};
                inven.REPLACEMENT_NETPR = result.REPLACEMENT_NETPR; // 대체품 판매가 추가
                this.dealerInventoryList = [inven]; // 배열로 설정 (템플릿 반복 위해)
            })
            .catch(error => {
                console.error('Error:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    loadPartRequests() {
        this.isLoading = true;

        getPartRequests({workOrderId: this.recordId})
            .then(result => {
                this.partRequestList = result.map(part => {
                    return {
                        ...part, // ...part는 part 객체의 모든 속성을 새로운 객체로 복사합니다.
                        // ProductName: part.Product__r ? part.Product__r.Name : 'N/A'
                        ProductName: part.Product__r ? part.Product__r.Name : label.DNS_FSL_NoProductName,
                        ProductCode: part.ProductCode__c ? part.ProductCode__c : label.DNS_FSL_NoProductNumber,
                        Status: part.Status ? part.Status : label.DNS_FSL_NoState,
                        quantity: part.Quantity__c ? part.Quantity__c : label.DNS_FSL_NoQuantity,
                        buttonStatus: part.Status === label.DNS_FSL_New
                    };
                });
            })
            .catch(error => {
                console.error('Error:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    get filterOptions() {
        return [
            { label: label.DNS_FSL_ProductNumber, value: 'productNumber' },
            { label: label.DNS_FSL_ProductName, value: 'FM_MaterialDetails__c' },
            // { label: label.DNS_FSL_Standard, value: 'productSpec' },
        ];
    }

    openAddPartView() {
        this.isMainView = false;
        this.isAddPartView = true;
    }

    handleBack() {
        this.isLoading = true;
        this.productDetails = null;
        this.dealerInventoryList = [];
        
        searchProducts({ searchKey: this.searchKey, filter: this.selectedFilter })
            .then(result => {

                this.searchResults = result;
                this.isAddPartView = true;
                this.isPartDetailsView = false;
                this.isMainView = false;

                this.quantity = 1;
                
            })
            .catch(error => {
                console.error('Error:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        if (!this.searchKey || this.searchKey.length < 3) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: label.DNS_FSL_EnterLeastThreeCharacters,
                    variant: 'error',
                }),
            );
            return;
        }
        this.isLoading = true;

        searchProducts({ searchKey: this.searchKey, filter: this.selectedFilter })
            .then(result => {
                this.searchResults = result;
            })
            .catch(error => {
                console.error('Error:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });this.isLoading = true;

    }

    handleFilterChange(event) {
        this.selectedFilter = event.detail.value;
    }

    handleProductSelect(event) {
        const productId = event.currentTarget.dataset.id;
        this.productDetails = this.searchResults.find(product => product.Id === productId);
        this.isAddPartView = false;
        this.isPartDetailsView = true;
        this.loadDealerInventory();
        // 딜라재고
        getDealerStocks({ productId: productId })
        
            .then(result => {
                this.dealerStocksList = result;
                this.isAddPartView = false;
                this.isPartDetailsView = true;
            })
            .catch(error => {
                console.error('Error fetching dealer stocks:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });this.isLoading = true;
    }

    handleQuantity(event) {
        this.quantity = event.target.value;
    }

    openAddConfirmation() {
        this.isConfirmationVisible = true;
    }

    closeConfirmation() {
        this.isConfirmationVisible = false;
    }

    closeCancelSave() {
        this.isModalOpen = false;
    }

    handleAddPart() {
        this.isLoading = true;
        const productId = this.productDetails.Id;
        
        createProductRequest({ productId: productId, workOrderId: this.recordId, quantity: JSON.stringify(this.quantity) })
            .then(() => {
                this.showNotification(label.DNS_FSL_PartRequested, 'success');
                this.closeConfirmation();
                this.loadPartRequests();

                this.isMainView = true;
                this.isAddPartView = false;
                this.isPartDetailsView = false;
            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: label.DNS_FSL_PleaseEnterQuantity,
                        // message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
        this.quantity = 1;
    }

    handleCancelPart(event) {
        this.partIdToDelete = event.currentTarget.dataset.id;
        this.isModalOpen = true;
    }

    confirmCancelPart() {
        deleteProductRequest({ partId: this.partIdToDelete })
            .then(() => {
                this.partRequestList = this.partRequestList.filter(part => part.Id !== this.partIdToDelete);
                this.showNotification(label.DNS_FSL_PartrequestCanceled, 'success');
            })
            .catch(error => {
                console.error('Error:', error);
                this.showNotification(label.DNS_FSL_AlreadyDeleted, 'error');
            })
            .finally(() => {
                this.isModalOpen = false;
                this.partIdToDelete = null;
            });
    }

    showNotification(message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: label.DNS_FSL_Alarm,
                message: message,
                variant: variant,
            }),
        );
    }

    closeModal(event) {
        this.isModalOpen = false;
        this.partIdToDelete = null;
    }

    handleNotificationClose() {
        this.isNotificationVisible = false;
        // this.handleBack();
        this.isPartDetailsView = true;
    }

}