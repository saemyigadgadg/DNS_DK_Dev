/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-10
 * @last modified by  : suheon.ha@sobetec.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-04-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import getQuoteLI from '@salesforce/apex/DN_OptyLineItemListController.getQuoteLI';
import getProduct from '@salesforce/apex/DN_OptyLineItemListController.getProduct';
import getQuoteDiscount from '@salesforce/apex/DN_OptyLineItemListController.getQuoteDiscount';
import deleteQuoteLineItem from '@salesforce/apex/DN_OptyLineItemListController.deleteQuoteLineItem';
import upsertQuoteProduct from '@salesforce/apex/DN_OptyLineItemListController.upsertQuoteProduct';
import loadLineItems from '@salesforce/apex/DN_OpptyLineItemCopyController.loadLineItems';
// import saveQuoteLineItems from '@salesforce/apex/DN_OpptyLineItemCopyController.saveQuoteLineItems';
import getGPESProduct from '@salesforce/apex/DN_OptyLineItemListController.getGPESProduct';
import getEquipmentName from '@salesforce/apex/DN_OptyLineItemListController.getEquipmentName';
import getQuoteProductPrice from '@salesforce/apex/DN_OptyLineItemListController.getQuoteProductPrice';

import { label } from 'c/commonUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DN_QuoteLineItemList extends LightningElement {
    cLabel = label;
    @track isLoading = false;
    @track isEditing = true;

    @api recordId;
    @track resultData = [];
    @track isExcelModal = false;
    @track excelData = '';
    @track lineItems = [];
    @track draftValues = [];
    @track unmatchedCodes = [];
    @track quoteDiscount = 0;
    @track columns = [
        { label: 'Name', fieldName: 'productName', type: 'text', editable: false },
        { label: 'Quantity', fieldName: 'quantity', type: 'number', editable: true },
    ];
    get isDisabled() {
        this.isEditing = true;
    }

    // GPES
    isGPESModal = false;
    handleMessage = null;
    apexPageURL = '/apex/IF_GPES_T?Gijong=&Hogi=';

    connectedCallback() {
        this.isLoading = true;

        getQuoteLI({ quoteId: this.recordId })
        .then(result => {
            console.log('result:::' + JSON.stringify(result));
            this.resultData = [];

            result.forEach((element, index) => {
                var row = {
                    QuoteLineItemId: element.QuoteLineItemId,
                    isChecked: false,
                    isManualAmount: element.isManualAmount || false,
                    isManualDiscount: element.isManualDiscount || false,
                    PartNo: String((index + 1) * 10).padStart(4, '0'),
                    ProductId: element.ProductId,
                    ProductName: element.ProductName,
                    Quantity: element.Quantity,
                    Unit: element.Unit,
                    UnitPrice: element.UnitPrice,
                    ListPrice: element.ListPrice,
                    Amount: element.Amount,
                    PricebookEntryId: element.PricebookEntryId,
                    Description: element.Description,
                    ProductCode: element.ProductCode,
                    QuoteProdCurrency: element.QuoteProdCurrency,
                    AvailableStock: element.AvailableStock,
                    SupplyProduct: element.SupplyProduct,
                    isApproved: element.isApproved,
                    Discount: element.Discount,
                    isCustom : element.isCustom,
                    isEditing: true
                };
                this.resultData.push(row);
            });

        })
        .catch(error => {
            console.error('Error ::: ', error.message);
        })
        .finally(() => {
            this.isLoading = false;
        });  

        getEquipmentName({
            recordId : this.recordId
        }).then(result => {
            console.log('장비 이름 ::: ', result);
            if (result != '') {
                var gijong = result.split('-')[0];
                var hogi = result.split('-')[1];
                var type = 'reqParts';
                this.apexPageURL = '/apex/IF_GPES_T?Gijong=' + gijong + '&Hogi=' + hogi + '&type=' + type;
            }
        }).catch(error => {
            console.log('Error ::: ', error.message);
        });
        
    }
    handleRefresh() {
        // window.location.reload();
        this.connectedCallback();
    }

    // getQuote() {
    //     getQuoteDiscount({ quoteId: this.recordId })
    //     .then(result => {
    //         console.log('할인율 ::: ', result);
    //         this.quoteDiscount = result;
    //         this.applyQuoteDiscount();
    //     })
    //     .catch(error => {
    //         console.error('Error ::: ', error.message);
    //     });
    // }

    applyQuoteDiscount() {
        this.resultData.forEach((row, index) => {
            if (!row.isManualDiscount) {
                row.Discount = this.quoteDiscount;
                this.calculateAmount(index);
            }
        });
    
        this.resultData = [...this.resultData];
    }
    renderedCallback() {
        this.adjustSldsStyles();
    }

    addRowClick( ) {
        this.resultData.push({
            QuoteLineItemId : '',
            isChecked : false,
            isManualAmount : false,
            isManualDiscount : false,
            PartNo : String((this.resultData.length + 1) * 10).padStart(4, '0'),
            ProductId : '',
            SupplyProduct : '',
            ProductName : '',
            Quantity : '',
            Unit : '',
            UnitPrice : '',
            ListPrice : 0,
            Amount : '',
            QuoteProdCurrency : '',
            AvailableStock : '',
            PricebookEntryId : '',
            Description : '',
            ProductCode : '',
            Discount : 0,
            isApproved : true,
            isDisabled: false,
            isEditing: false 
        });
        console.log('this.resultData:::', JSON.stringify(this.resultData));
    }

    deleteSelectedRows() {
        this.isLoading = true;
        const hasCheckedItem = this.resultData.some(element => element.isChecked);

        if (!hasCheckedItem) {
            console.log('No 삭제.');
            this.showToast('오류', '제품 삭제 전 제품을 선택해주세요.', 'error');
            this.isLoading = false;
            return;
        }
        var deleteRow = [];
        this.resultData.forEach(element => {
            console.log('element:::' + JSON.stringify(element));
            if(element.isChecked) {
                if(element.QuoteLineItemId != '') {
                    deleteRow.push(element.QuoteLineItemId);

                }
            }
        });
        console.log('deleteRow:::' + JSON.stringify(deleteRow));
        deleteQuoteLineItem({
            qliIds : deleteRow
        }).then(result => {
            console.log('result:::' + JSON.stringify(result));
            if (result.isSuccess) {
                this.showToast('성공', '제품 삭제가 완료되었습니다.', 'success');

                this.resultData = this.resultData.filter(element => element.isChecked === false);
                this.resultData.forEach((element, index) =>{
                    element.PartNo = String((index + 1) * 10).padStart(4, '0');
                });
                // this.connectedCallback();
                // this.isChecked = false;
                // window.location.reload();

            } else {
                this.showToast('오류', '제품 삭제 중 오류가 발생했습니다.', 'error');

            }
        }).catch(error => {
            console.log('error:::' + JSON.stringify(error));
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    checkCellClick(event) {
        var index = event.target.name;
        console.log('index:::', JSON.stringify(index));
        
        this.resultData[index].isChecked = !this.resultData[index].isChecked;
        console.log('this.resultData[index]:::', JSON.stringify(this.resultData[index]));
        
    }

    checkAllClick(event) {
        var isChecked = event.target.checked;
        console.log('isChecked:::' + JSON.stringify(isChecked));

        this.resultData.forEach(element => {
            element.isChecked = isChecked;
        });
        
    }

    productChange(event) {
        var index = event.target.name;
        var value = event.target.value;
        console.log('index:::', JSON.stringify(index));
        console.log('value:::', value);

        if (value == '') {
            this.resultData[index].ProductId = value;
            this.resultData[index].ProductName = '';
            this.resultData[index].ProductCode = '';
            this.resultData[index].SupplyProduct = '';
            this.resultData[index].Unit = '';
            this.resultData[index].Quantity = '';
            this.resultData[index].UnitPrice = '';
            this.resultData[index].ListPrice = 0;
            this.resultData[index].Amount = '';
            this.resultData[index].QuoteProdCurrency = '';
            this.resultData[index].AvailableStock = '';
            this.resultData[index].Discount = 0;
        } else {
            this.isLoading = true;
            getProduct({productId : value})
            .then(result => {
                console.log('result:::' + JSON.stringify(result));
                this.resultData[index].ProductId = result.Id;
                this.resultData[index].ProductName = result.Name;
                this.resultData[index].ProductCode = result.Name;
                if (result.Name == 'CS_MT_MAT' || result.Name == 'CS_MT_SVC') {
                    this.resultData[index].isApproved = false;
                }
                this.resultData[index].Unit = result.Unit__c;
                this.resultData[index].PricebookEntryId = result.PricebookEntries[0].Id;
                console.log('this.resultData[index]:::' + JSON.stringify(this.resultData[index]));
                this.handleSimulation();
            }).catch(error => {
                console.log('error:::' + JSON.stringify(error));
                this.isLoading = false;
            })
            // .finally(() => {
            // });
        }
    }

    handleSimulationButton() {
        console.log('시뮬레이션 버튼 클릭');
        let saveRow = this.resultData.filter(element => element.isChecked);
        if (saveRow.length === 0) {
            console.log('No 저장.');
            this.showToast('오류', '제품 저장 전 제품을 선택해주세요.', 'error');
            this.isLoading = false;
            return;
        } 
        console.log('선택된 로우 데이터:', JSON.stringify(saveRow));
        this.handleSimulation(saveRow);
    }

    handleSimulation() {
        this.isLoading = true;
        console.log('this.resultData:::', JSON.stringify(this.resultData));
    
        // 중복 제거 Map 생성
        let duplicationPart = new Map();
    
        this.resultData.forEach(row => {
            if (!row.isEditing) {
                if (!duplicationPart.has(row.ProductId)) {
                    console.log('New Parts');
                    duplicationPart.set(row.ProductId, { ...row });
                } else {
                    console.log('Existing Parts');
                    // 기존 ProductId 데이터가 있으면 같은 데이터로 통일
                    let existingRow = duplicationPart.get(row.ProductId);
                    row.UnitPrice = existingRow.UnitPrice;
                    row.ListPrice = existingRow.ListPrice;
                    row.Unit = existingRow.Unit;
                    row.ProductName = existingRow.ProductName;
                    row.ProductCode = existingRow.ProductCode;
                    row.SupplyProduct = existingRow.SupplyProduct;
                    row.Amount = row.Quantity * existingRow.UnitPrice;
                    row.QuoteProdCurrency = existingRow.QuoteProdCurrency;
                    row.AvailableStock = existingRow.AvailableStock;
                }
            }
        });
    
        // API 요청을 위한 최종 리스트 (isEditing이 false인 데이터만 포함)
        const filteredData = [...duplicationPart.values()];
        const partNumbers = filteredData.map(row => row.PartNo);
        const partNames = filteredData.map(row => row.ProductCode);
    
        console.log('Sending to SAP:', JSON.stringify({ partNumbers, partNames }));
    
        getQuoteProductPrice({ quoteId: this.recordId, partNumbers: partNumbers, partNames: partNames })
            .then(response => {
                const sapResponse = JSON.parse(response);
    
                console.log('SAP Response:', JSON.stringify(sapResponse));
    
                // 받아온 데이터를 partId가 같은 모든 항목에 적용
                let productDataMap = new Map();
                sapResponse.forEach(item => {
                    productDataMap.set(item.MATERIAL_ENT.trim().toLowerCase(), item);
                });
    
                this.resultData = this.resultData.map(row => {
                    if (!row.isEditing) {
                        const matchingMaterial = productDataMap.get(row.ProductName.trim().toLowerCase());
    
                        if (matchingMaterial) {
                            console.log(`Applying data to ProductId ${row.ProductId}:`, JSON.stringify(matchingMaterial));
    
                            row.UnitPrice = matchingMaterial.NET_PRICE;
                            row.ListPrice = matchingMaterial.NET_PRICE;
                            row.Unit = matchingMaterial.UOM;
                            row.ProductName = matchingMaterial.MATERIAL_TEXT;
                            row.SupplyProduct = matchingMaterial.MATERIAL;
                            row.Amount = row.Quantity * matchingMaterial.NET_PRICE;
                            row.QuoteProdCurrency = matchingMaterial.IF_CURRENCY;
                            row.AvailableStock = matchingMaterial.AVAIL_QTY1;
                        } else {
                            console.warn('No matching material found for ProductName:', row.ProductName);
                        }
                    }
                    return row;
                });
    
                console.log('Updated resultData:', JSON.stringify(this.resultData));
            })
            .catch(error => {
                console.error('Error SAP call:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    // handleOptyItemEdit() {
    //     this.isEditing = false;
    //     console.log('this.isEditing:::'+this.isEditing);

    //     this.resultData = this.resultData.map(row => {
    //         return { ...row, isEditing: false };
    //     });
    // }
    
    handleOptyItemEdit() {
        this.isEditing = false;
        console.log('this.isEditing:::'+this.isEditing);
        console.log('this.resultData:::'+this.resultData);

        this.resultData.forEach(row => {
            if (row.isCustom == true) {
                row.isApproved = false;
            }
            row.isEditing = false;
        });
    }
    
    handleDirectNameInputChange(event) {
        var index = event.target.name;
        var value = event.target.value;

        this.resultData[index].ProductName = value;
    }

    handleInputChange(event) {
        var index = event.target.name;
        var value = event.target.value == '' ? 0 : event.target.value;
    
        this.resultData[index].Quantity = value;
    
        if (!this.resultData[index].isManualAmount) {
            var unitPrice = this.resultData[index].UnitPrice == '' ? 0 : this.resultData[index].UnitPrice;
            this.resultData[index].Amount = String(this.resultData[index].Quantity * unitPrice);
        }
    
        this.resultData = [...this.resultData];
    }

    handleInputPrice(event) {
        var index = event.target.name;
        var value = event.target.value == '' ? 0 : event.target.value;
    
        this.resultData[index].UnitPrice = value;
    
        if (!this.resultData[index].isManualAmount) {
            var quantity = this.resultData[index].Quantity == '' ? 0 : this.resultData[index].Quantity;
            this.resultData[index].Amount = String(this.resultData[index].UnitPrice * quantity);
        }
    }

    handleInputDiscount(event) {
        var index = event.target.name;
        var value = event.target.value === '' ? 0 : parseFloat(event.target.value);
    
        this.resultData[index].Discount = value;
        this.resultData[index].isManualDiscount = true;
        this.calculateAmount(index);
    
        this.resultData = [...this.resultData];
    }
    calculateAmount(index) {
        let row = this.resultData[index];

        if (!row.isManualAmount) {
            let quantity = row.Quantity === '' ? 0 : parseFloat(row.Quantity);
            let unitPrice = row.UnitPrice === '' ? 0 : parseFloat(row.UnitPrice);
            let discount = row.Discount === '' ? 0 : parseFloat(row.Discount);
    
            row.Amount = (unitPrice * quantity * (1 - discount / 100)).toFixed(2);
        }

        // row.Amount = (unitPrice * quantity * (1 - discount / 100)).toFixed(2);
        this.resultData = [...this.resultData];
    }

    // isManualAmount는 사용자가 직접 입력했을 경우 true
    handleInputAmount(event) {
        var index = event.target.name;
        var value = event.target.value.trim() === '' ? 0 : parseFloat(event.target.value);
        console.log('index:::', JSON.stringify(index));
        console.log('value:::', value);
    
        this.resultData[index].Amount = value;
    
        if (value === 0) {
            this.resultData[index].isManualAmount = false;
            this.calculateAmount(index);
        } else {
            this.resultData[index].isManualAmount = true;
        }
    
        console.log('isManualAmount:::' + this.resultData[index].isManualAmount);
        this.resultData = [...this.resultData];
    }

    handleOptyItemSave() {
        this.isLoading = true;

        const hasCheckedItem = this.resultData.some(element => element.isChecked);
        if (!hasCheckedItem) {
            console.log('No 저장.');
            this.showToast('오류', '제품 저장 전 제품을 선택해주세요.', 'error');
            this.isLoading = false;
            return;
        }
    
        const hasValidItem = this.resultData.some(element => 
            element.ProductId && element.Quantity && element.UnitPrice
        );
        if (!hasValidItem) {
            console.log('No valid items for saving.');
            this.showToast('오류', '제품 저장 전 제품 정보를 입력해주세요.', 'error');
            this.isLoading = false;
            return;
        }
    
        let saveRow = this.resultData.filter(element => element.isChecked);
    
        console.log('선택된 로우 데이터:', JSON.stringify(saveRow));
        // console.log('resultData:::' + JSON.stringify(this.resultData));
    
        upsertQuoteProduct({
            requestProductList: saveRow,
            // requestProductList: this.resultData,
            quoteId: this.recordId
        })
        .then(result => {
            if (result.startsWith('다음 제품의 가격 목록이 없습니다') || result.startsWith('업데이트 오류 발생')) {
                this.showToast('오류', result, 'error');
            } else {
                this.showToast('성공', '제품 저장이 완료되었습니다.', 'success');
                this.connectedCallback();
                // this.getQuoteLI({quoteId: this.recordId});
                // this.dispatchEvent(new RefreshEvent());
                console.log('result:::' + result);
                window.location.reload();

            }
        })
        .catch(error => {
            let errorMessage = error.body && error.body.message ? error.body.message : '제품 저장 중 오류가 발생했습니다.';
            this.showToast('오류', '제품 추가 전 정보를 입력해주세요.', 'error');
            console.log('error:::' + JSON.stringify(error));
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
    
    // 엑셀 모달 열기
    openExcelModal() {
        this.isExcelModal = true;
        console.log('열림');
    }

    // 엑셀 모달 닫기
    closeExcelModal() {
        this.isExcelModal = false;
        this.excelData = '';
        this.lineItems = [];
    }

    // 제품코드 붙여넣기
    handleCopyInputChange(event) {
        this.excelData = event.target.value;
        console.log('this.excelData:::' + this.excelData);
        
    }

    handleLoadData() {
        if (!this.excelData) {
            alert('제품 코드를 붙여넣으세요');
            return;
        }
        console.log('this.excelData:::' + this.excelData);
    
        // 엑셀 데이터에서 제품 코드와 수량을 추출
        let productList = this.excelData.split('\n').map(row => {
            if (row.trim() !== '') {
                let columns = row.split('\t');
                return {
                    code: columns[0]?.trim(),
                    quantity: parseInt(columns[1]?.trim(), 10) || 1 // 기본값 1 설정
                };
            }
        }).filter(item => item); // 빈 데이터 제거
    
        console.log('Parsed Product List:', JSON.stringify(productList));
    
        loadLineItems({ productList })
            .then(result => {
                // this.resultData = [];
        
                // 코드값이 매칭되지 않은 경우 경고
                this.unmatchedCodes = result.unmatchedCodes;
                if (this.unmatchedCodes.length > 0) {
                    alert(`코드값이 없습니다. 다시 확인해 주세요. 해당 코드번호: ${this.unmatchedCodes.join(', ')}`);
                    console.log(`코드값이 없습니다. 다시 확인해 주세요. 해당 코드번호: ${this.unmatchedCodes.join(', ')}`);
                    
                    return;
                }

                result.lineItems.forEach((element, index) => {
                    this.resultData.push({
                        QuoteLineItemId: '',
                        isChecked: false,
                        PartNo : String((this.resultData.length + 1) * 10).padStart(4, '0'),
                        ProductId: element.ProductId,
                        ProductName: element.productName,
                        Quantity: element.quantity,
                        Unit: element.unit || '',
                        UnitPrice: element.UnitPrice || 0,
                        ListPrice: element.ListPrice || 0,
                        Amount: element.quantity * (element.UnitPrice || 0),
                        PricebookEntryId: element.pricebookEntryId,
                        Description: '',
                        ProductCode: element.productCode || '',
                        isApproved: true
                    });
                });
    
                this.isExcelModal = false;
                this.handleSimulation(this.resultData);
            })
            .catch(error => {
                console.error('Error loading line items:', error);
                alert('데이터 로드 중 오류가 발생했습니다. 제품 코드를 확인해 주세요.');
            });
    }

    // handleLoadData() {
    //     if (!this.excelData) {
    //         alert('제품 코드를 붙여넣으세요');
    //         return;
    //     }
    //     console.log('flag1');
    //     console.log('this.excelData:::' + this.excelData);
    //     let productList = this.excelData.split('\n').map(row => {
    //         console.log('flag2');
    //         console.log('row:::', typeof row);
    //         if (row != '') {
    //             let columns = row.split('\t');
    //             console.log('columns:::' + columns);
    //             console.log('flag3');
    
    //             return {
    //                 code: columns[0]?.trim(),
    //                 quantity: parseInt(columns[1].trim(), 10) || 1
    //             };
    //         } else {
    //             return {
    //                 code: '',
    //                 quantity: null
    //             };
    //         }
    //     });
    //     console.log('flag4');
    
    //     console.log('Parsed Product List:', JSON.stringify(productList));
    
    //     loadLineItems({ productList })
    //         .then(result => {
    //             this.lineItems = result.lineItems.map((item, index) => ({
    //                 id: String(index + 1),
    //                 productName: item.productName,
    //                 pricebookEntryId: item.pricebookEntryId,
    //                 quantity: item.quantity,
    //                 description: '',
    //                 expectedPrice: null
    //             }));
    //             this.unmatchedCodes = result.unmatchedCodes;

    //             if (this.unmatchedCodes.length > 0) {
    //                 alert(`코드값이 없습니다. 다시 확인해 주세요. 해당 코드번호: ${this.unmatchedCodes.join(', ')}`);
    //             }
    //         })
    //         .catch(error => {
    //             console.error('Error loading line items:', error);
    //             alert('데이터 로드 중 오류가 발생했습니다. 제품 코드를 확인해 주세요.');
    //         });
    // }
    // async handleSave() {
    //     this.isLoading = true;
    //     try {
    //         if (!this.lineItems || this.lineItems.length === 0) {
    //             alert('제품 코드를 먼저 로드해 주세요.');
    //             return;
    //         }
    
    //         console.log('기존 Line Items:', JSON.stringify(this.lineItems));
    
    //         // 1. ProductId(pricebookEntryId) 기준으로 데이터 통합
    //         let existingDataMap = new Map();
    
    //         let newLineItems = this.lineItems.map((item, index) => {
    //             let partNumbers = String((index + 1) * 10).padStart(4, '0'); // 0010, 0020, 0030...
                
    //             if (!existingDataMap.has(item.pricebookEntryId)) {
    //                 // 기존 데이터가 없으면 새로 추가
    //                 let newItem = {
    //                     partNumbers,
    //                     productName: item.productName,
    //                     quantity: item.quantity,
    //                     UnitPrice: 0,
    //                     ListPrice: 0,
    //                     Unit: '',
    //                     Amount: 0,
    //                     SupplyProduct: '',
    //                     QuoteProdCurrency: '',
    //                     AvailableStock: '',
    //                     pricebookEntryId: item.pricebookEntryId
    //                 };
    //                 existingDataMap.set(item.pricebookEntryId, newItem);
    //             }
    
    //             // 기존에 존재하는 데이터로 채우기
    //             let existingItem = existingDataMap.get(item.pricebookEntryId);
    //             return {
    //                 ...existingItem, // 기존 데이터를 먼저 적용
    //                 quantity: item.quantity, // 수량은 개별적으로 유지
    //                 Amount: item.quantity * existingItem.UnitPrice
    //             };
    //         });
    
    //         console.log('Updated Line Items before SAP:', JSON.stringify(newLineItems));
    
    //         // 2. 중복 제거 후, API 호출할 데이터 추출
    //         const uniqueItems = [...existingDataMap.values()];
    //         const partNumbers = uniqueItems.map(row => row.partNumbers);
    //         const partNames = uniqueItems.map(row => row.productName);
    
    //         console.log('Sending to SAP:', JSON.stringify({ partNumbers, partNames }));
    
    //         // 3. SAP 시뮬레이션 실행
    //         const response = await getQuoteProductPrice({
    //             quoteId: this.recordId,
    //             partNumbers: partNumbers,
    //             partNames: partNames
    //         });
    
    //         const sapResponse = JSON.parse(response);
    //         console.log('SAP Response:', JSON.stringify(sapResponse));
    
    //         // 4. SAP 응답 데이터를 ProductId 기준으로 저장
    //         let productDataMap = new Map();
    
    //         sapResponse.forEach(item => {
    //             productDataMap.set(item.MATERIAL_ENT.trim().toLowerCase(), item);
    //         });
    
    //         // 5. API 응답 데이터를 모든 같은 ProductId 제품에 적용
    //         newLineItems = newLineItems.map(row => {
    //             const matchingMaterial = productDataMap.get(row.productName.trim().toLowerCase());
    
    //             if (matchingMaterial) {
    //                 console.log(`Applying SAP data to pricebookEntryId ${row.pricebookEntryId}:`, JSON.stringify(matchingMaterial));
    
    //                 row.UnitPrice = matchingMaterial.NET_PRICE;
    //                 row.ListPrice = matchingMaterial.NET_PRICE;
    //                 row.Unit = matchingMaterial.UOM;
    //                 row.ProductName = matchingMaterial.MATERIAL_TEXT;
    //                 row.SupplyProduct = matchingMaterial.MATERIAL;
    //                 row.Amount = row.quantity * matchingMaterial.NET_PRICE;
    //                 row.QuoteProdCurrency = matchingMaterial.IF_CURRENCY;
    //                 row.AvailableStock = matchingMaterial.AVAIL_QTY1;
    
    //                 // 동일 ProductId 가진 다른 항목에도 같은 데이터 적용
    //                 existingDataMap.set(row.pricebookEntryId, { ...row });
    //             }
    
    //             return row;
    //         });
    
    //         console.log('Updated Line Items after Simulation:', JSON.stringify(newLineItems));
    
    //         // 6. 최종 저장 실행
    //         await saveQuoteLineItems({ lineItems: newLineItems, recordId: this.recordId });
    
    //         alert('견적 제품 저장 성공');
    //         this.excelData = '';
    //         this.isExcelModal = false;
    //         this.connectedCallback();
    //     } catch (error) {
    //         console.error('Error saving records:', error);
    //         alert('견적 제품 저장 오류. 다시 시도해 주세요.');
    //     } finally {
    //         this.isLoading = false;
    //     }
    // }
        
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    gpesModal() {
        this.isGPESModal = !this.isGPESModal;

        if (this.isGPESModal) {
            this.handleMessage = this.chargingPartHandleMessage.bind(this);
            window.addEventListener('message', this.handleMessage);
        } else {
            window.removeEventListener('message', this.handleMessage);
            this.handleMessage = null;
        }
    }

    // GPES메시지를 처리하는 메서드
    chargingPartHandleMessage(event) {
        // 메시지가 JSON인지 확인
        try {
            const data = event.data;
            console.log('이벤트 부품리스트 ::: ', data);
            console.log('이벤트 부품리스트 JSON ::: ', JSON.parse(data));

            var eventParts = JSON.parse(data);

            getGPESProduct({
                eventParts : eventParts
            }).then(result => {
                console.log('GPES result ::: ', JSON.stringify(result));

                result.epwList.forEach(element => {
                    this.resultData.push({
                        QuoteLineItemId : '',
                        isChecked : false,
                        PartNo : String((this.resultData.length + 1) * 10).padStart(4, '0'),
                        ProductId : element.productId,
                        ProductName : element.productName,
                        Quantity : element.quantity,
                        Unit : element.unit,
                        UnitPrice : element.unitPrice,
                        ListPrice : element.ListPrice,
                        Amount : element.quantity * element.unitPrice,
                        PricebookEntryId : element.pricebookEntryId,
                        Description : '',
                        ProductCode : element.productCode,
                        isApproved : true
                    });                        
                });

                if (!result.isSuccess) {
                    this.showToast('Error', result.message, 'error');
                }

                window.removeEventListener('message', this.handleMessage);
                this.handleMessage = null;
                this.isGPESModal = false;

            }).catch(error => {
                console.log('GPES Error ::: ', error.message);
            });

        } catch (error) {
            console.error('Invalid JSON data received:', error.message);
        }
    }    

    /* SDLS Styes */
    adjustSldsStyles() {
        const style = document.createElement('style');
        style.innerText = `
            .chargingParts .slds-modal__container {
                width: 72vw !important;
                max-width: calc(100vw - 8rem) !important;
                padding-bottom: 2rem;
            }
            .chargingParts .slds-modal__content {
                height: 42rem;
                max-height: calc(100vh - 16rem);
                padding: 0;
                overflow: hidden;
            }
            .stockModal .card-02 .section-control {
                border-raius: 0;
            }
            .stickModal .card-02 .slds-gutters .slds-form-element:nth-of-type(3) {
                grid-area: 2 / 1 / 2 / 3;
            }
            .slds-card__header .header-title .slds-media__figure {
                margin-right: 0 !important;
            }
            .table-wrap {
                overflow-x: auto;
            }
            .slds-table {
                background-color: white;
            }
            .slds-table td {
                padding: 0.25rem 0.5rem;
                white-space: nowrap;
            }
            .slds-table th {
                padding: 0.5rem;
                background-color: #f3f3f3;
                font-weight: bold;
            }
            .slds-input {
                min-height: 32px;
            }
            .slds-combobox {
                min-height: 32px;
            }
            lightning-input.slds-checkbox {
                margin-bottom: 0;
            }
            .slds-button_icon {
                color: #706e6b;
            }
            .slds-hint-parent:hover {
                background-color: #f3f3f3;
            }
            .slds-table td lightning-input,
            .slds-table td lightning-combobox {
                margin-bottom: 0;
            }
            .slds-table td lightning-input .slds-input,
            .slds-table td lightning-combobox .slds-combobox__input {
                height: 32px;
                padding: 0 0.5rem;
            }
            .table-wrap table tr td .slds-dropdown-trigger .slds-dropdown {
                max-height: 11rem;
                overflow: auto;
                height: fit-content;
            }
            .table-wrap table tr:nth-of-type(1) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown, 
            .table-wrap table tr:nth-of-type(2) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown, 
            .table-wrap table tr:nth-of-type(3) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown, 
            .table-wrap table tr:nth-of-type(4) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown {
                top: 100% !important;
                bottom: unset !important;
            }
            .table-wrap table tr:nth-last-of-type(1) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown,
            .table-wrap table tr:nth-last-of-type(2) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown,
            .table-wrap table tr:nth-last-of-type(3) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown,
            .table-wrap table tr:nth-last-of-type(4) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown {
                top: unset;
                bottom: 100%;
            }
            .action .slds-button_first, 
            .action .slds-button_last {
                height: 2rem;
            }
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
            @media all and (max-width: 1900px) {
                .button-container .slds-m-left_x-small {
                    margin-left: 0;
                }
            }
        `;
        this.template.querySelector('.chargingParts').appendChild(style);
    }

}