import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import searchProducts from '@salesforce/apex/DN_PartBillingController.searchProducts';
import getPartRequests from '@salesforce/apex/DN_PartBillingController.getPartRequests';
import createProductRequest from '@salesforce/apex/DN_PartBillingController.createProductRequest';
import deleteProductRequest from '@salesforce/apex/DN_PartBillingController.deleteProductRequest';
import getDealerInventory from '@salesforce/apex/DN_PartBillingController.getDealerInventory';
import getDealerStocks from '@salesforce/apex/DN_PartBillingController.getDealerStocks';
import getWorkOrder from '@salesforce/apex/DN_PartBillingController.getWorkOrder';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class DN_PartBillingButton extends LightningElement {
    @track dealerStocksList = [];
    @track partRequestList = [];
    @track dealerInventoryList = [];
    @track isMainView = true;
    @track isAddPartView = false;
    @track isPartDetailsView = false;
    @track isConfirmationVisible = false;
    @track isModalOpen = false;
    @track searchKey = '';
    @track searchResults = [];
    @track productDetails = {};
    @track selectedFilter = 'productNumber';
    @track quantity = 1;
    @track isLoading = false;
    @track isButtonDisabled = true;
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
            .page-03 .field-wrap .input-wrap .slds-form-element__help {
                display: none !important;
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
    }

    // loadDealerInventory() {
    //     console.log('Product Details:', this.productDetails); 
    //     this.isLoading = true;

    //     const productId = this.productDetails.Id;
    //     getDealerInventory({productId: productId})
    //         // .then(response => {
    //         //     this.dealerInventory = JSON.parse(response);
    //         //     console.log('Dealer Inventory:', this.dealerInventory);
    //         // })
    //         // .catch(error => {
    //         //     console.error('Error dealer inventory:', error);
    //         // });
    //         .then(response => {
    //             var obj = JSON.parse(response).ES_INFO;
    //             this.dealerInventoryList.push(obj);
    //         })
    //         .catch(error => {
    //             console.error('Error:', error);
    //         })
    //         .finally(() => {
    //             this.isLoading = false;
    //         });
    // }
    loadDealerInventory() {
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
                        ProductName: part.Product__r ? part.Product__r.FM_MaterialDetails__c : label.DNS_FSL_NoProductName,
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
        this.dealerInventoryList = [];
        this.loadDealerInventory();
        this.isLoading = true;
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
            });
    }

    handleQuantity(event) {
        this.quantity = event.target.value;
    }

    openAddConfirmation() {
        this.isLoading = true;
        this.isConfirmationVisible = true;

        getWorkOrder({ recordId: this.recordId })
            .then(result => {
                console.log('WorkOrder 타입:', result.OrderType__c);
                console.log('부품보증:', result.Case.FM_isDirect__c);
                // console.log('부품보증:', result.Case.Asset.FM_EquipmentWarrantyEquipmentParts__c.slice(-1));
                console.log('직영여부:', result.FM_isDirect__c);
                console.log('빌링여부:', result.Case.checkBillingStatus__c);
                this.OrderType__c = result.OrderType__c;
                //버튼제어
                let isButtonUse = false;
                if(result.Case.FM_PartsWarranty__c =='Y' || this.OrderType__c == '204' || this.OrderType__c == '218') {
                    console.log('부품보증 Y 또는 P-Claim');
                    isButtonUse = true;
                } else {
                    isButtonUse = false;
                    this.addLineDisabledMessage = '* 부품청구는 부품보증기간 내 및 P-Claim인 경우만 청구 가능합니다. 관리자에게 문의해주세요';
                }
                // if(result.Case.Asset.FM_EquipmentWarrantyEquipmentParts__c.slice(-1) =='Y'){ //case1
                //     console.log('부품보증 Y');
                //     isButtonUse = true;
                // }
                // if(result.Case.Asset.FM_EquipmentWarrantyEquipmentParts__c.slice(-1) =='Y' 
                //     && ['201', '202', '217'].includes(this.OrderType__c)){ //case1
                //     console.log('부품보증 Y &&  무상 Claim, 유상 Claim, 부품만청구인 경우');
                //     isButtonUse = true;
                // }
                // if(result.FM_isDirect__c && this.OrderType__c == '202') {
                //     console.log('직영여부 확인 && 유상 Claim');
                //     isButtonUse = true; //case2
                // }
                // if(this.OrderType__c == '204') {
                //     console.log('P-Claim');
                //     isButtonUse = true; //case3
                // } 
                // if(this.OrderType__c == '215' || this.OrderType__c == '214') { //case4
                //     console.log('유상SP입고수리 || 무상SP입고수리');
                //     isButtonUse = true;
                // }
                // if(this.OrderType__c == '202') {
                //     console.log('유상 Claim');
                //     isButtonUse = true; //case5
                // } 

                // if (result.Case.checkBillingStatus__c == 'N') { //빌링처리 체크
                //     isButtonUse = false;
                //     this.addLineDisabledMessage = '* 빌링처리가 되지 않은 장비는 부품 청구가 불가능합니다. 관리자에게 문의해주세요';
                // }
                
                console.log('버튼여부: '+isButtonUse);

                if(isButtonUse) {
                    this.isButtonDisabled = false;
                }

            })
            .catch(error => {
                console.error('WorkOrder 타입 회 류:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
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
        const quantity = this.quantity;
        /** checkBillingStatus == Y 일 때, 어떤 경우든 무조건 버튼 비활성화 후 메시지 출력
         *  case1. 오더타입, 추가버튼: 무상Claim(201), 유상 Claim(202), 부품만청구(217) 이면서 장비의 부품보증이 "Y" 인경우
            case2. 오더타입, 추가버튼: 유상 Claim(202) 오더의 출동 W/C가 직영인 경우
            case3. 오더타입, 추가버튼: P-Clamil(204) 장비의 부품 보증여부와 관계 없이 부품 청구 가능
            case4. 오더타입, 추가버튼: 유/무상 SP 입고수리 (215, 214)인 경우
            case5. 오더타입, 스핀들버튼: 유상 Claim(202) 일 땐, (유)스핀들 버튼 활성화
         */
        createProductRequest({ productId: productId, workOrderId: this.recordId, quantity: quantity })
            .then(result => {
                if (result === 'NO_BILLING') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: '빌링처리가 되지 않은 장비는 부품 청구가 불가능합니다. 관리자에게 문의해주세요.',
                            variant: 'error',
                        }),
                    );
                } else if (result === 'NOT_ORDERTYPE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: '무상Claim, 유상 Claim, 부품만청구 이면서 장비의 부품보증이 "Y"가 아니거나 메인작업자가 아닙니다.',
                            variant: 'error',
                        }),
                    );
                } else if (result === 'NOT_DIRECTCLAIM') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: '유상 Claim 오더의 출동 W/C가 직영이 아닙니다.',
                            variant: 'error',
                        }),
                    );
                } else if (result === 'NOT_PCLAIM') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'P-Claim 오더 타입이 아닙니다.',
                            variant: 'error',
                        }),
                    );
                } else if (result === 'NOT_SPREPAIR') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: '유/무상 SP 입고수리 오더 타입이 아닙니다.',
                            variant: 'error',
                        }),
                    );
                } else if (result === 'NOT_SPINDLEELIGIBLE') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: '스핀들 버튼 활성화 조건(유상 Claim)이 아닙니다.',
                            variant: 'error',
                        }),
                    );
                } if (result === 'SUCCESS') {
                    this.showNotification(label.DNS_FSL_PartRequested, 'success');
                    this.closeConfirmation();
                    this.loadPartRequests();
    
                    this.isMainView = true;
                    this.isAddPartView = false;
                    this.isPartDetailsView = false;
                } 

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
        this.partIdDelete = event.currentTarget.dataset.id;
        this.workOrderId = this.recordId;
        this.isModalOpen = true;
    }

    confirmCancelPart() {
        this.isLoading = true;

        deleteProductRequest({ partId: this.partIdDelete, workOrderId: this.recordId })
            .then(() => {
                this.partRequestList = this.partRequestList.filter(part => part.Id !== this.partIdDelete);
                this.showNotification(label.DNS_FSL_PartrequestCanceled, 'success');
            })
            .catch(error => {
                console.error('Error:', error);
                this.showNotification('이미 승인된 제품입니다.', 'error');
                // this.showNotification(label.DNS_FSL_AlreadyDeleted, 'error');
            })
            .finally(() => {
                this.isModalOpen = false;
                this.partIdDelete = null;
                this.isLoading = false;

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
        this.partIdDelete = null;
    }

    handleNotificationClose() {
        this.isNotificationVisible = false;
        // this.handleBack();
        this.isPartDetailsView = true;
    }

}