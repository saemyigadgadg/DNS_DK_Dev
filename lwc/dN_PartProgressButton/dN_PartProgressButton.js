/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 05-08-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-09   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import searchProducts from '@salesforce/apex/DN_PartBillingController.searchProducts';
import getPartRequests from '@salesforce/apex/DN_PartBillingController.getPartRequests';
import createProductRequest from '@salesforce/apex/DN_PartBillingController.createProductRequest';
import deleteProductRequest from '@salesforce/apex/DN_PartBillingController.deleteProductRequest';
import getDealerInventory from '@salesforce/apex/DN_PartBillingController.getDealerInventory';
import getDealerStocks from '@salesforce/apex/DN_PartBillingController.getDealerStocks';
import getPartProgress from '@salesforce/apex/DN_PartBillingController.getPartProgress';
import getWorkOrders from '@salesforce/apex/DN_PartBillingController.getWorkOrders';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class DN_PartProgressButton extends LightningElement {
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
    @track partList= [];
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
            .confirm-wrap .icon-wrap .slds-icon{
                fill: #0176D3;
            }
         `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

    connectedCallback() {
        this.loadPartRequests();
        this.isLoading = true;
        getWorkOrders({
            workOrderId: this.recordId
        }).then((result) => {
            if (result) {
                console.log('result:::' + result);
                var notiNum = result;
                this.isLoading = true;
                getPartProgress({
                    notiNum : notiNum
                }).then(result007 => {
                    console.log('result007 ::: ', JSON.stringify(result007));
                    if (result007.O_RETURN.TYPE == 'S') {
                        var partProgressList = result007.T_O_LIST;
                        partProgressList.forEach(part => {
                            var obj = {
                                MATNR : part.MATNR,         // 품번
                                MAKTX : part.MAKTX,         // 품명
                                MATNR_TXT : part.MATNR_TXT, // 상태
                                RECV_DT : part.RECV_DT,     // 접수일
                                PRETD3 : part.PRETD3,       // 평균실적납기일
                                PRETD : part.PRETD,         // 변경공급예정일
                                KWMENG : part.KWMENG,       // 수량
                                QDATU : part.QDATU,         // 불출일
                                RETURN_YN : part.RETURN_YN  // 반납구분
                            };
                            this.partList.push(obj);
                            console.log('partList ::: ', JSON.stringify(this.partList));
                        });
                    }
                    
                }).catch(error => {
                    console.log('Error007 ::: ', error.message);
                });
            }
        })
        .catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading status',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    loadDealerInventory() {
        console.log('Product Details:', this.productDetails); 
        this.isLoading = true;

        const productId = this.productDetails.Id;
        getDealerInventory({productId: productId})
            // .then(response => {
            //     this.dealerInventory = JSON.parse(response);
            //     console.log('Dealer Inventory:', this.dealerInventory);
            // })
            // .catch(error => {
            //     console.error('Error dealer inventory:', error);
            // });
            .then(response => {
                var obj = JSON.parse(response).ES_INFO;
                this.dealerInventoryList.push(obj);
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
                        ProductName: part.Product__r ? part.Product__r.Name : '품명이 없습니다.',
                        ProductCode: part.ProductCode__c ? part.ProductCode__c : '품번이 없습니다.',
                        Status: part.Status ? part.Status : '상태가 없습니다.',
                        quantity: part.Quantity__c ? part.Quantity__c : '수량이 없습니다.',
                        buttonStatus: part.Status === '신규'
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
            { label: label.DNS_FSL_ProductName, value: 'productName' },
            { label: label.DNS_FSL_Standard, value: 'productSpec' },
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
                    message: '검색 키워드를 최소 세 글자 이상 입력해야 됩니다.',
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
                this.showNotification('부품이 청구되었습니다.', 'success');
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
                        message: '수량을 입력해주세요.',
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
                this.showNotification('부품 요청이 취소되었습니다.', 'success');
            })
            .catch(error => {
                console.error('Error:', error);
                this.showNotification('이미 삭제된 상태입니다.', 'error');
            })
            .finally(() => {
                this.isModalOpen = false;
                this.partIdToDelete = null;
            });
    }

    showNotification(message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: '알림',
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