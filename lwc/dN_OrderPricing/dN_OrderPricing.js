import { LightningElement, api, track, wire } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';

import { showToast, reduceErrors } from 'c/commonUtils';
import customLabels from "./labels";

import { getRecord } from 'lightning/uiRecordApi';
const ORDER_FIELDS = ['Order.Status', 'Order.IsSyncPrice__c', 'Order.ERPOrderNo__c'];

import { publish, MessageContext } from 'lightning/messageService';
import ORDER_DATA_MESSAGE from '@salesforce/messageChannel/OrderDataMC__c';

import fetchInitData from '@salesforce/apex/DN_OrderPricingController.fetchInitData';
import savePricing from '@salesforce/apex/DN_OrderPricingController.savePricing';
import syncPrice from '@salesforce/apex/DN_OrderPricingController.syncPrice';

export default class DN_OrderPricing extends LightningElement {

    @api recordId;

    isLoading = false;
    cLabel = customLabels;

    // Data List
    @track priceInfo = {};
    @track promotion = [];
    @track incentive = [];
    @track special   = [];

    standardDCTotal;
    standardOptionTotal;
    standardDCRate;
    standardCVRate;
    standardSQRate;
    standardAccRate;
    standardDCOptionTotal;
    standardDCRateTotal;
    standardORateTotal;
    _standardTotal;
    specialStdRate;
    specialBodyOfContract01;
    specialBodyOfContract02;
    specialBodyOfContract03;
    specialOptionOfContract;
    specialBodyOfContractRate01;
    specialBodyOfContractRate02;
    specialBodyOfContractRate03;
    specialOptionOfContractRate;
    incentiveCnt;
    promotionCnt;

    offConsignment;
    offWholesale;
    offLongterm;

    isSyncPrice;
    openWholesale;
    // isSentERP;
    segmentation;
    productDCZero;
    prevetSave;
    onChange = false; // refresh 제어용, 현재 사용 X

    @track promotionPrice = [];
    @track promotionPriceTotal = 0; // Promotion Checked Total
    @track incentivePriceTotal = 0; // Promotion Checked Total

    // Special Amount Input Disabled
    @track isDisabled01; 
    @track isDisabled02;
    @track isDisabled03;

    // Special  Price
    inputPrice01 ='';
    inputPrice02 ='';
    inputPrice03 ='';

    @track specialCheckedPrice = '';
    @track spacialCheckedKey = '';
    @track checkedRow;
    @track checkDisable;
    @track inputDisable;

    async connectedCallback(){
        await this.doInit();
    }

    renderedCallback() {
        this.adjustSldsStyles();
    }

    async doInit(){
        this.isLoading = true;
        let isPass = true;

        this.removeAllCheckedRow();
        this.uncheckAllPromotion();
        this.uncheckAllIncentive();

        await fetchInitData({recordId : this.recordId})
        .then(result => {
            // console.log('fetchInitData result ::: ', JSON.stringify(result, null, 2));
            this.priceInfo     = result.priceInfo;
            this.special       = result.details.Special;
            this.promotion     = result.details.Promotion;
            this.incentive     = result.details.Incentive;
            
            this.isSyncPrice   = result.isSyncPrice;
            this.openWholesale = result.openWholesale;
            // this.isSentERP     = result.isSentERP;
            this.prevetSave    = result.prevetSave;
            this.segmentation  = result.segmentation;
        })
        .catch(error => {
            console.error('fetchInitData error ', JSON.stringify(error));
            showToast(this, 'error', customLabels.DNS_M_GeneralError);
            isPass = false;
        });
        
        if(isPass) await this.calcData();
        
        this.isLoading = false
    }

    async calcData(){
        this.setSyncPrice();
        this.activateOpenWholesale();
        if(this.openWholesale) {    
            this.disableConsignmentFee(true);
        } else if (this.segmentation == "Direct Sales" || this.segmentation == "직영") {
            this.disableConsignmentFee(true);
        }
        
        // if(this.isSyncPrice) {
        //     if(this.priceInfo.productDC === 0) {
        //         this.productDCZero = true;
        //     } 
        // }

        this.standardOptionTotal = (this.priceInfo.cvStd + this.priceInfo.sqStd + this.priceInfo.accStd) || 0;
        this.standardStdTotal    = (this.priceInfo.productStd + this.standardOptionTotal) || 0;

        this.standardDCOptionTotal = this.priceInfo.cvDC + this.priceInfo.sqDC + this.priceInfo.accDC;
        this.standardDCTotal       = this.priceInfo.productDC + this.standardDCOptionTotal;

        this.standardDCRate      = (this.priceInfo.productDC / this.priceInfo.productStd) || 0;
        this.standardCVRate      = (this.priceInfo.cvDC / this.priceInfo.cvStd) || 0;
        this.standardSQRate      = (this.priceInfo.sqDC / this.priceInfo.sqStd) || 0;
        this.standardAccRate     = (this.priceInfo.accDC / this.priceInfo.accStd) || 0;
        this.standardORateTotal  = (this.standardDCOptionTotal / this.standardOptionTotal) || 0;
        this.standardDCRateTotal = (this.standardDCTotal / this.standardStdTotal) || 0;

        this._standardTotal = this.standardStdTotal + this.standardDCTotal;

        this.promotionCnt = this.promotion.length + 1;
        this.incentiveCnt = this.incentive.length + 1;

        this.setSpecialInputValues();

        // 특별공급 > (계약가 기준) 본체 
        this.specialOptionOfContract     = this.standardOptionTotal + this.standardDCOptionTotal;
        this.specialOptionOfContractRate = ((this.specialOptionOfContract / this.standardOptionTotal) - 1) || 0;
        this.specialStdRate              = this.standardDCTotal / this.standardStdTotal || 0;
        this.specialBodyOfContract01     = (this.inputPrice01 - this.specialOptionOfContract) || 0;
        this.specialBodyOfContractRate01 = ((this.specialBodyOfContract01 / this.priceInfo.productStd) - 1);
        this.specialBodyOfContract02     = (this.inputPrice02 - this.specialOptionOfContract) || 0;
        this.specialBodyOfContractRate02 = ((this.specialBodyOfContract02 / this.priceInfo.productStd) - 1) || 0;
        this.specialBodyOfContract03     = (this.inputPrice03 - this.specialOptionOfContract) || 0;
        this.specialBodyOfContractRate03 = ((this.specialBodyOfContract03 / this.priceInfo.productStd) - 1) || 0;

        // Reprocessing Datas
        this.promotion.forEach(p => {
            if(p.isAuto){
                // % 기준으로 금액 계산 + Rate 유지
                p.price = (Math.trunc(((this.priceInfo.productStd + this.priceInfo.productDC) * (p.rate / 100)) / 10000) * 10000) || 0;
            } else if (!p.isAuto){
                // if(p.price){
                //     // price가 있으면 가격 기준으로 Rate 계산
                //     let rate = (p.price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0;
                //     p.rate = (rate * 100).toFixed(1); 
                // }else{
                //     // price가 없으면 어차피 둘 다 0
                //     p.rate = 0;
                // }
                let priceTotal = this.priceInfo.productStd + this.priceInfo.productDC;
                let rate = priceTotal !== 0 ? (p.price / priceTotal) : 0;
                p.rate = parseFloat((rate * 100).toFixed(1));
                // let rate = (p.price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0;
            }            
            p.dcRate =( p.price / this.standardStdTotal) || 0; 
            
            // if (p.price) {
            //     p.price = p.price; // 기존 값 유지
            //     p.rate = (p.price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0;
            // } else {
            //     p.price = (Math.trunc(((this.priceInfo.productStd + this.priceInfo.productDC) * (p.rate / 100)) / 10000) * 10000) || 0;
            //     p.rate   = (p.rate / 100) || 0;
            // }
        });

        this.incentive.forEach(i => {

            if(i.isFirstRow){
                i.rate = i.rate;                
                let price = (this.priceInfo.productStd + this.priceInfo.productDC) * i.rate / 100;
                i.price = Math.floor(price / 10000) * 10000;
            } else {
                if(i.isAuto) {
                    i.price = (Math.trunc(((this.priceInfo.productStd + this.priceInfo.productDC) * (i.rate / 100)) / 10000) * 10000) || 0;
                } else if (!i.isAuto){
                    i.price = (Math.trunc(((this.priceInfo.productStd + this.priceInfo.productDC) * (i.rate / 100)) / 10000) * 10000) || 0;
                    // let rate = (i.price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0;
                    // i.rate = parseFloat((rate * 100).toFixed(1)); 
                    i.rate = i.rate;         
                }
            }
            // if(i.isAuto) {
            //     i.price = (Math.trunc(((this.priceInfo.productStd + this.priceInfo.productDC) * (i.rate / 100)) / 10000) * 10000) || 0;
            // } else if (!i.isAuto){
            //     if(i.isFirstRow){
            //         i.rate = i.rate;                
            //         let price = (this.priceInfo.productStd + this.priceInfo.productDC) * i.rate;
            //         i.price = Math.floor(price / 10000) * 10000;
            //     } else {
            //         let rate = (i.price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0;
            //         i.rate = parseFloat((rate * 100).toFixed(1)); 
            //     }

            // if (i.price) {
            //     i.price = i.price; // 기존 값 유지
            //     i.rate = (i.price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0;
            // } else {
            //     i.price = (Math.trunc(((this.priceInfo.productStd + this.priceInfo.productDC) * (i.rate / 100)) / 10000) * 10000) || 0;
            //     i.rate = (i.rate / 100) || 0;
            // }
        });

        const checkedIndexesP = this.promotion.map((item, index) => item.isChecked ? index : -1).filter(index => index !== -1); 
        checkedIndexesP.forEach(index => {
            const checkedRow = this.template.querySelector(`table.promotion tbody tr[data-index="${index}"]`);
            return checkedRow.classList.add('checked-row');            
        });

        const checkedIndexes = this.incentive.map((item, index) => item.isChecked ? index : -1).filter(index => index !== -1); 
        checkedIndexes.forEach(index => {
            const checkedRow = this.template.querySelector(`table.incentive tbody tr[data-index="${index}"]`);
    
            return checkedRow.classList.add('checked-row');            
        });  

        this.setPromotionTotal();
        this.setIncentiveTotal();
    }

    async handleSyncPrice(){
        this.onChange = false;
        // console.log('onchange => false / handleSyncPrice');

        this.isLoading = true;
        let isPass = false;
        await syncPrice({orderId : this.recordId, quoteLineItemId : null})
        .then(result => {
            isPass = result.isPass;

            if(isPass) {

                this.dispatchEvent(new RefreshEvent());
            } else {
                showToast(this, 'error', customLabels.DNS_M_GeneralError, result.errorMsg);
            }
        })
        .catch(error => {
            this.errorHandler('handleSyncPrice', error)
            return;
        })
        .finally(() => this.isLoading = false );

        if(isPass) { 
            await this.doInit();
        }
    }

    errorHandler(name, error){
        var errorMsg = reduceErrors(error);
        if(Array.isArray(errorMsg)) errorMsg = errorMsg[0];
        console.error(name, errorMsg);
        showToast(this, 'error', customLabels.DNS_M_GeneralError, errorMsg);
    }

    // 🔖 Events

    handleSpecialCheckbox(event) { 
        this.onChange = true;
        // console.log('onchange => true / handleSpecialCheckbox');

        const selectedValue = event.target.value; 
        const selectedCheck = event.target.checked;  

        const consignmentRow = this.template.querySelector('tr.consignment ');
        const wholesaleRow   = this.template.querySelector('tr.wholesale');
        const longtermRow    = this.template.querySelector('tr.longterm');

        if(this.openWholesale){
            if(selectedCheck) {
                if (selectedValue === 'wholesale') {
                    this.isDisabled02 = false;
                    this.isDisabled03 = true;
                    this.promotionDisabledAll(true);
                } else if (selectedValue === 'longterm') {
                    this.isDisabled02 = true;
                    this.isDisabled03 = false;
                    this.promotionDisabledAll(true);
                }
            } else { // uncheck
                this.isDisabled02 = true;
                this.isDisabled03 = true;
    
                wholesaleRow.style.background   = "none";
                longtermRow.style.background    = "none";
    
               const promotionCheck = this.template.querySelectorAll('[data-name="promotionCheck"]');
                    const promotionInput = this.template.querySelectorAll('[data-name="promotionInput"]');
                    promotionCheck.forEach(checkbox => {
                        checkbox.disabled = false;
                    })
                    promotionInput.forEach(input => {
                        input.disabled = false;
                    });
                    // this.disableConsignmentFee(false);
            }

            this.uncheckAllPromotion();
            this.uncheckAllIncentive();

        } else { // this.openWholesale = false
            if(selectedCheck) {
                if (selectedValue === 'consignment') {
                    this.isDisabled01 = false;
                } else { // uncheck
                    this.isDisabled01 = true;
                    consignmentRow.style.background = "none";
                }
            }

            this.uncheckAllIncentive();            
        }

        // if(selectedCheck) {
        //     if (selectedValue === 'consignment') {
        //         this.isDisabled01 = false;
        //         // this.isDisabled02 = true;
        //         // this.isDisabled03 = true;
        //         // this.disableExceptConsignment();
        //     } else if (selectedValue === 'wholesale') {
        //         // this.isDisabled01 = true;
        //         this.isDisabled02 = false;
        //         this.isDisabled03 = true;
        //         this.promotionDisabledAll(true);
        //     } else if (selectedValue === 'longterm') {
        //         // this.isDisabled01 = true;
        //         this.isDisabled02 = true;
        //         this.isDisabled03 = false;
        //         this.promotionDisabledAll(true);
        //     }

        // } else { // uncheck
        //     this.isDisabled01 = true;
        //     this.isDisabled02 = true;
        //     this.isDisabled03 = true;

        //     consignmentRow.style.background = "none";
        //     wholesaleRow.style.background   = "none";
        //     longtermRow.style.background    = "none";

        //     if (this.openWholesale = false){
        //         this.promotionDisabledAll(false);
        //     } else {          
        //         const promotionCheck = this.template.querySelectorAll('[data-name="promotionCheck"]');
        //         const promotionInput = this.template.querySelectorAll('[data-name="promotionInput"]');
        //         promotionCheck.forEach(checkbox => {
        //             checkbox.disabled = false;
        //         })
        //         promotionInput.forEach(input => {
        //             input.disabled = false;
        //         });
        //         this.disableConsignmentFee(false);
        //     }
        // }

        // 비활성화 될 프로모션, 인센티브 초기화
        const checkedRow = this.template.querySelectorAll(`.checked-row`);

        checkedRow.forEach(row => {
            row.classList.remove('checked-row');
        });

        this.special.forEach(item => {
            if(item.key == selectedValue && selectedCheck) { item.isChecked = true; }
            else { item.isChecked = false; }
        });

        this.promotionPriceTotal = 0;
        this.incentivePriceTotal = 0;
    }

    handleInputChange(event) { // 특별공급 금액 직접입력
        this.onChange = true;
        // console.log('onchange => true / handleInputChange');

        const value = event.target.value;      
        if (this.isConsignment === true) {
            this.inputPrice01 = value; // 값 설정
            this.special[0].price = value;
            this.special[0].key = 'consignment';
            this.specialBodyOfContract01 = (this.inputPrice01 - this.specialOptionOfContract) || 0;
        } else if (this.isWholesale === true) {
            this.inputPrice02 = value;
            this.special[1].price = this.inputPrice02;
            this.special[1].key = 'wholesale';
            this.specialBodyOfContract02 = (this.inputPrice02 - this.specialOptionOfContract) || 0;
        } else if (this.isLongterm === true) {
            this.inputPrice03 = value;
            this.special[2].price = this.inputPrice03;
            this.special[2].key = 'longterm';
            this.specialBodyOfContract03 = (this.inputPrice03 - this.specialOptionOfContract) || 0;
        }
    }

    handlePromotionInput(event) {
        this.onChange = true;
        // console.log('onchange => true / handlePromotionInput');

        let price = event.target.value;
        let index = event.target.dataset.index;
        var input = event.target;

        // 양수 입력 시 오류
        if (price > 0) {
            input.setCustomValidity('Enter a negative value.');
        } else {
            input.setCustomValidity(''); 
        }
        input.reportValidity();

        // 입력 된 값 데이터 반환
        this.promotion[index].price = price;
        this.promotion[index].dcRate = (price / this.standardStdTotal) || 0;
        let rate = (price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0;
        this.promotion[index].rate = parseFloat((rate * 100).toFixed(1));

        // 선택된 값 합산
        const checkedItems = this.promotion.filter(p => p.isChecked === true);
        const totalPrice = checkedItems.reduce((sum, item) => {
            const price = Number(item.price); 
            return sum + (isNaN(price) ? 0 : price);
        }, 0);
        
        this.promotionPriceTotal = totalPrice;
    }

    handlePromotionCheck(event) {
        this.onChange = true;
        // console.log('onchange => true / handlePromotionCheck');

        const index = event.target.dataset.index; 
        const promotionItem = this.promotion[index]; 
        const checkedRow = this.template.querySelector(
            `table.promotion tbody tr[data-index="${index}"]`
        );

        // isChecked 상태 반전
        promotionItem.isChecked = !promotionItem.isChecked;

        // CSS 클래스 추가/제거
        if (promotionItem.isChecked) {
            checkedRow.classList.add('checked-row'); 
        } else {
            checkedRow.classList.remove('checked-row'); 
        }

        // 체크된 항목 필터링
        const checkedItems = this.promotion.filter(p => p.isChecked === true);

        // 체크된 항목들의 price 필드 값들 합 계산
        const totalPrice = checkedItems.reduce((sum, item) => {
            const price = Number(item.price); // 숫자로 변환
            return sum + (isNaN(price) ? 0 : price); // 변환 실패하면 0으로 처리
        }, 0);

        this.promotionPriceTotal = totalPrice; 

    }   

    handleIncentiveCheck(event) { 
        this.onChange = true;
        // console.log('onchange => true / handleIncentiveCheck');
        
        const index = event.target.dataset.index; 
        const incentiveItem = this.incentive[index]; 
        const checkedRow = this.template.querySelector(
            `table.incentive tbody tr[data-index="${index}"]`
        );

        // isChecked 상태 반전
        incentiveItem.isChecked = !incentiveItem.isChecked;

        // CSS 클래스 추가/제거
        if (incentiveItem.isChecked) {
            checkedRow.classList.add('checked-row'); // 체크되면 클래스 추가
        } else {
            checkedRow.classList.remove('checked-row'); // 체크 해제되면 클래스 제거
        }

        // 체크된 항목 필터링
        const checkedItems = this.incentive.filter(p => p.isChecked === true);

        // 체크된 항목들의 price 필드 값들의 합을 계산
        const totalPrice = checkedItems.reduce((sum, item) => {
            const price = Number(item.price); // 숫자 변환
            return sum + (isNaN(price) ? 0 : price); // 변환 실패하면 0으로 처리
        }, 0);

        this.incentivePriceTotal = totalPrice; 

    }   

    inputIncentivePrice(event) {
        this.onChange = true;
        // console.log('onchange => true / inputIncentivePrice');

        let price = event.target.value;
        let index = event.target.dataset.index;

        this.incentive[index].price = price;
        let rate = (price / (this.priceInfo.productStd + this.priceInfo.productDC)) || 0
        this.incentive[index].rate = parseFloat((rate * 100).toFixed(1));
        
        const checkedItems = this.incentive.filter(p => p.isChecked === true);
        const totalPrice = checkedItems.reduce((sum, item) => {
            const price = Number(item.price); 
            return sum + (isNaN(price) ? 0 : price);
        }, 0);
        
        this.incentivePriceTotal = totalPrice;
    }
    
    // 🔖 Getter Functions

    get handleSaveBtn(){
        return this.prevetSave || !this.isSyncPrice;
    }
    
    get dynamicBlurred() { // 데이터 변경 시 Sync Price 재활성화 및 스타일 초기화
        if(this.prevetSave) {
            return 'container';
        } else {

            if (this.isSyncPrice) {
                if(this.openWholesale === true) {
                    if(this.priceInfo.productDC === 0) {
                        this.productDCZero = true;
                    } 
                    else {
                        this.productDCZero = false;
                    }
                }
                return 'container';
            } else {
                this.highlightRow();
                this.productDCZero = false;
                return 'container blurred'; 
            }
        }
    }

    get isConsignment() { // Checked Radio Buttons Initial Setup
        if (!this.special || this.special.length === 0) return false;
        // if (this.special[0].isChecked === true) {
        //     // this.inputPrice01 = this.special[0].price;
        //     this.highlightRow('consignment');
        //     return true;
        // } else {
        //     return false;
        // }
        if(this.openWholesale === false) {
            this.offConsignment = true;
            this.highlightRow('consignment');

            // 250213 yeongju.yun Consignment 일때 Special - key == consignment의 isChecked가 false이면 무조건 check
            let consignRow = this.special.find(s => s.key == 'consignment');
            if(consignRow && !consignRow.isChecked) { consignRow.isChecked = true; }
            
            return true;
        } 
        
    }

    get isWholesale() {
        if(!this.special || this.special.length === 0) return false;

        let wholeSalesRow = this.special.find(s => s.key == 'wholesale');
        if(wholeSalesRow && wholeSalesRow.isChecked) {
            this.highlightRow('wholesale');
            return true;
        } else {
            return false;
        }
    }

    get isLongterm() {
        if(!this.special || this.special.length === 0) return false;

        let longtermRow = this.special.find(s => s.key == 'longterm');
        if(longtermRow && longtermRow.isChecked) {
            this.highlightRow('longterm');
            return true;
        } else {
            return false;
        }

        // if (this.special[2].isChecked === true) {
        //     // this.inputPrice03 = this.special[2].price; 
        //     this.highlightRow('longterm');
        //     return true; 
        // } else {
        //     return false;
        // }
    }

    calcSpecialDCPrice(inputPrice) {  // 특별공급 자동계산
        var result = inputPrice - (this.standardStdTotal + this.standardDCTotal)
        return result < 0 ? result : 0;
    }

    get specialDCPrice01() { // Price
        return this.calcSpecialDCPrice(this.inputPrice01);
    }
    
    get specialDCPrice02() { 
        return this.calcSpecialDCPrice(this.inputPrice02);
    }
    
    get specialDCPrice03() {
        return this.calcSpecialDCPrice(this.inputPrice03);
    }

    get specialRate01() { // D/C
        return ((this.inputPrice01 / this.standardStdTotal) - 1) || 0;   
    }

    get specialRate02() {
        return ((this.inputPrice02 / this.standardStdTotal) - 1) || 0;   
    }

    get specialRate03() {
        return ((this.inputPrice03 / this.standardStdTotal) - 1) || 0;   
    }

    get specialSpcRate01() { // Special D/C
        return (this.specialDCPrice01 / this.standardStdTotal) || 0;   
    }

    get specialSpcRate02() {
        return (this.specialDCPrice02 / this.standardStdTotal) || 0;   
    }
    
    get specialSpcRate03() {
        return (this.specialDCPrice03 / this.standardStdTotal) || 0;   
    }

    get specialDCTotal() { // 체크된 열 key, price 값 반환
        if(!this.special || this.special.length === 0) return;

        if (this.isConsignment === true) {
            // this.special[0].price = this.inputPrice01;
            // this.special[0].key = 'consignment'; 

            return this.specialDCPrice01;

        } else if (this.isWholesale === true) {
            // this.special[1].price = this.inputPrice02;
            // this.special[1].key = 'wholesale';
            return this.specialDCPrice02;

        } else if (this.isLongterm === true) {
            // this.special[2].price = this.inputPrice03;
            // this.special[2].key = 'longterm';
            return this.specialDCPrice03;
        } 
    }
    
    get specialDCRateTotal() { // 특별공급 할인율 합계
        return (this.specialDCTotal / this.standardStdTotal) || 0;   
    }

    get promotionRateTotal() {
        return (this.promotionPriceTotal / this.priceInfo.productStd) || 0;
    }

    get additionalDCTotal() {
        return ((this.specialDCTotal || 0 ) + (this.promotionPriceTotal || 0)) || 0;
    }

    get additionalDCRateTotal() { 
        return (this.additionalDCTotal / this.priceInfo.productStd) || 0;
    }  

    get incentiveRateTotal() { // 인센티브 총 할인율 
        const sum = this.priceInfo.productStd + this.standardDCTotal + this.additionalDCTotal;
        return sum == 0 ? 0 : ((this.incentivePriceTotal / sum) || 0 );
    }

    get finalOrderPrice() { // 최종 주문 금액

        if (this.isConsignment === true) {
            return this.inputPrice01;
        } else if (this.isWholesale === true) {
            return this.inputPrice02;
        } else if (this.isLongterm === true) {
            return this.inputPrice03;
        } else {
            return this.standardStdTotal + this.standardDCTotal + this.additionalDCTotal;
        }       
    }

    get finalOrderRate() { // 최종 할인율
        if (this.isConsignment === true) {
            return (((this.inputPrice01 / this.standardStdTotal) - 1) || 0 );
        } else if (this.isWholesale === true) {
            return (((this.inputPrice02 / this.standardStdTotal) - 1) || 0 );
        } else if (this.isLongterm === true) {
            return (((this.inputPrice03 / this.standardStdTotal) - 1) || 0 );
        } else {
            return (((this.finalOrderPrice / this.standardStdTotal) - 1) || 0 );
        }  
    }

    // 🔖 Setting Functions

    setPromotionTotal() {
        const proCheckedItems = this.promotion.filter(p => p.isChecked === true);
        const proTotalPrice = proCheckedItems.reduce((sum, item) => {
            const price = Number(item.price); 
            return sum + (isNaN(price) ? 0 : price);
        }, 0);
        this.promotionPriceTotal = proTotalPrice;
    }

    setIncentiveTotal() {
        const incCheckedItems = this.incentive.filter(p => p.isChecked === true);
        const incTotalPrice = incCheckedItems.reduce((sum, item) => {
            const price = Number(item.price); 
            return sum + (isNaN(price) ? 0 : price);
        }, 0);
        this.incentivePriceTotal = incTotalPrice;
    }

    // setSpecialInputValues() {  // Set Special Initial Input Values 
    //     const specialKey = this.special.filter(item => item.isChecked).map(item => item.key)[0];
    //     if(specialKey === 'consignment'){
    //         this.inputPrice01 = this.special[0].price;
    //         this.inputPrice02 = this._standardTotal;
    //         this.inputPrice03 = this._standardTotal;
    //     } else if(specialKey === 'wholesale'){
    //         this.inputPrice02 = this.special[1].price;
    //         this.inputPrice01 = this._standardTotal;
    //         this.inputPrice03 = this._standardTotal;
    //     } else if(specialKey === 'longterm'){
    //         this.inputPrice03 = this.special[2].price;
    //         this.inputPrice01 = this._standardTotal;
    //         this.inputPrice02 = this._standardTotal;
    //     } else {
    //         this.inputPrice01 = this._standardTotal;
    //         this.inputPrice02 = this._standardTotal;
    //         this.inputPrice03 = this._standardTotal;
    //     } 
    // }

    setSpecialInputValues() {  // Set Special Initial Input Values 
        const specialKey = this.special.filter(item => item.isChecked).map(item => item.key)[0];
        if(specialKey === 'consignment'){
            if(this.special[0].price !== 0){
                this.inputPrice01 = this.special[0].price;
            } else {
                this.inputPrice01 = this._standardTotal;
            }             
            this.inputPrice02 = this._standardTotal;
            this.inputPrice03 = this._standardTotal;
        } else if(specialKey === 'wholesale'){
            if(this.special[1].price !== 0){
                this.inputPrice02 = this.special[1].price;
            } else {
                this.inputPrice02 = this._standardTotal;
            } 
            this.inputPrice01 = this._standardTotal;
            this.inputPrice03 = this._standardTotal;
        } else if(specialKey === 'longterm'){
            if(this.special[2].price !== 0){
                this.inputPrice03 = this.special[2].price;
            } else {
                this.inputPrice03 = this._standardTotal;
            } 
            this.inputPrice01 = this._standardTotal;
            this.inputPrice02 = this._standardTotal;
        }
        else {
            this.inputPrice01 = this._standardTotal;
            this.inputPrice02 = this._standardTotal;
            this.inputPrice03 = this._standardTotal;
        } 
    }

    activateOpenWholesale() { // openWholesale 값에 따라 특별공급 구역 활성/비활성화

        // disabled
        if(this.openWholesale) {    
            this.disableConsignmentFee(true);
        } else {            
            this.disableConsignmentFee(false);
        }
        
        if (this.isConsignment === true) {
            this.isDisabled01 = false;
            this.isDisabled02 = true;
            this.isDisabled03 = true;
            // this.disableExceptConsignment();
        } else if (this.isWholesale === true) {
            this.isDisabled01 = true;
            this.isDisabled02 = false;
            this.isDisabled03 = true;
            this.promotionDisabledAll(true);
        } else if (this.isLongterm === true) {
            this.isDisabled01 = true;
            this.isDisabled02 = true;
            this.isDisabled03 = false;
            this.promotionDisabledAll(true);
        } else if (this.openWholesale && !this.isWholesale && !this.isLongterm) {  
            // this.disableConsignmentFee(false);
            this.isDisabled01 = true;
            this.isDisabled02 = true;
            this.isDisabled03 = true;   
        } else if (this.openWholesale && (this.isWholesale || this.isLongterm)){
            if (this.isWholesale){
                this.isDisabled01 = true;
                this.isDisabled02 = false;
                this.isDisabled03 = true;   
            } else if(this.isLongterm) {
                this.isDisabled01 = true;
                this.isDisabled02 = true;
                this.isDisabled03 = false;   
            }
            // this.disableConsignmentFee(true);
        }
         else {
            this.isDisabled01 = true;
            this.isDisabled02 = true;
            this.isDisabled03 = true;
            this.promotionDisabledAll(false);
        }
    }

    disableConsignmentFee(boolean) { // 인센티브 위탁판매 수수료 항시 disabled
        const incentiveCheck = this.template.querySelectorAll('[data-name="incentiveCheck"]');
        const incentiveInput = this.template.querySelectorAll('[data-name="incentiveInput"]');
        incentiveCheck.forEach(checkbox => {             
            const parentRow = checkbox.closest('tr');
            const rowIndex = parentRow.dataset.index; 
            if (rowIndex === '0') { // 첫 번째 tr의 checkbox는 활성화
                checkbox.disabled = boolean;
            } else {
                checkbox.disabled = !boolean;
            }
        })
        incentiveInput.forEach(input => {
            const parentRow = input.closest('tr');
            const rowIndex = parentRow.dataset.index; 
            if (rowIndex === '0') {
                input.disabled = boolean;
            } else {
                input.disabled = !boolean;
            }
        })
    }

    // 🔖 Common Functions 

    toggleSection(event) { // Section Toggle
        let button = event.target;
        const section = button.closest('section'); 
        const tableWrap = section.querySelector('.table-wrap');

        if (tableWrap.style.display === 'block') {
            tableWrap.style.display = 'none';
            button.iconName = 'utility:chevrondown'; 
        } else {
            tableWrap.style.display = 'block';
            button.iconName = 'utility:chevronup'; 
        }
    }

    setSyncPrice() {
        if(this.isSyncPrice || this.prevetSave) {
            this.template.querySelector('[data-id="container"]').classList.remove('blurred');
        } else {
            this.template.querySelector('[data-id="container"]').classList.add('blurred');
        }
    }

    removeAllCheckedRow() {
        const checkedRows = this.template.querySelectorAll('.checked-row');
        checkedRows.forEach(row => {
            row.classList.remove('checked-row');
        });
    }

    uncheckAllPromotion() {
        this.promotion.forEach(item => {
            if (item.isChecked) {
                item.isChecked = false;
            }
        });    
    }

    uncheckAllIncentive() {     
        this.incentive.forEach(item => {
            if (item.isChecked) {
                item.isChecked = false;
            }
        });
    }

    highlightRow(rowName) {
        const rowClasses = ['consignment', 'wholesale', 'longterm'];
        rowClasses.forEach(className => {
            const row = this.template.querySelector(`tr.${className}`);
            if (row) {
                row.style.background = className === rowName ? '#EEF4FF' : 'none';
            }
        });
    }

    // disableExceptConsignment () {
    //     const promotionCheck = this.template.querySelectorAll('[data-name="promotionCheck"]');
    //     const promotionInput = this.template.querySelectorAll('[data-name="promotionInput"]');
    //     promotionCheck.forEach(checkbox => {
    //         checkbox.disabled = true;
    //     })
    //     promotionInput.forEach(input => {
    //         input.disabled = true;
    //     });
    //     this.disableConsignmentFee(false);
    // }

    promotionDisabledAll(boolean) {
        const promotionCheck = this.template.querySelectorAll('[data-name="promotionCheck"]');
        const promotionInput = this.template.querySelectorAll('[data-name="promotionInput"]');
        // const incentiveCheck = this.template.querySelectorAll('[data-name="incentiveCheck"]');
        // const incentiveInput = this.template.querySelectorAll('[data-name="incentiveInput"]');
        promotionCheck.forEach(checkbox => {
            checkbox.disabled = boolean;
        })
        promotionInput.forEach(input => {
            input.disabled = boolean;
        });
        // incentiveCheck.forEach(checkbox => {
        //     checkbox.disabled = boolean;
        // })
        // incentiveInput.forEach(input => {
        //     input.disabled = boolean;
        // });
    }

    adjustSldsStyles() { // SLDS Styles
        const style = document.createElement('style');
        style.innerText = `
            
            .slds-table_cell-buffer tr>td:first-child,
            .slds-table_cell-buffer tr>th:first-child {
                padding-left: 0.5rem !important;
            }
            .slds-table_cell-buffer tr>td:last-child,
            .slds-table_cell-buffer tr>th:last-child {
                padding-right: 0.5rem !important;
            }
            .header-table .slds-truncate .slds-icon_container {
                cursor: pointer;
                padding: 0.25rem 1rem;
                border-radius: 0.25rem;
            }
            .header-table .slds-truncate:hover .slds-icon_container {
                background-color: rgba(0, 0, 0, 0.05);    
            }
            .table-wrap table .slds-form-element .slds-checkbox [type=checkbox]+.slds-checkbox__label .slds-checkbox_faux {
                margin-right: 0;
            }
            .table-wrap table td .slds-input {
                padding-right: 0.5rem;
                text-align: end;
                line-height: 1.5rem;
                min-height: 1.5rem;
                border-radius: 3px;
            }
            .slds-spinner_container {
                z-index: 95;
            }
            .table-wrap .slds-truncate:has(.slds-form-element__icon){
                display: flex;
                justify-content: space-between;
            }
            .table-wrap td .slds-checkbox [type=checkbox]:focus+.slds-checkbox__label .slds-checkbox_faux {
                box-shadow: none !important;
            }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);

    }

    // 📌 Control Save Button 

    async handleSave(event){
        this.onChange = false;
        // console.log('onchange => false / handleSave');

        this.isLoading = true;

        // note : validation rule 올렸어요. 에러 시 밑에 과정이 불필요합니다. ❔
        // validation rule
        if(this.template.querySelector('.promotion-input')){
            if(this.template.querySelector('.promotion-input').reportValidity() === false){
                this.isLoading = false;
                showToast(this, 'error', customLabels.DNS_M_GeneralError, customLabels.DNS_M_EnterRightValue);
                return;
            }
        }
       
        let param = {};
        
        // Note : specialKey 값 찍히게 수정했어요. 
        // special 전체 array > checked array 수정 
        const promotion = this.promotion.filter(x => x.isChecked === true);
        const incentive = this.incentive.filter(x => x.isChecked === true);
        let special   = this.special.filter(x => x.isChecked === true);

        param.Promotion = promotion;
        param.Incentive = incentive;
        param.Special   = special;

        special.forEach(s => {
            if (this.isConsignment === true && s.key == 'consignment') {
                s.sPrice = this.specialBodyOfContract01;
            } else if (this.isWholesale === true && s.key == 'wholesale') {
                s.sPrice = this.specialDCPrice02;
            } else if (this.isLongterm === true && s.key == 'longterm') {
                s.sPrice = this.specialDCPrice03;
            } 
        });
        
        // let finalTotalAmt  = this.finalOrderPrice; // 총액 셋팅
        let specialDC = 0;
        const specialKey = special.length > 0 ? special[0].key : '';
        
        if (specialKey === 'consignment') {
            specialDC = this.specialDCPrice01;
        } else if (specialKey === 'wholesale') {
            specialDC = this.specialDCPrice02;
        } else if (specialKey === 'longterm') {
            specialDC = this.specialDCPrice03;
        }

        // e.g. let promotion = [(값 셋팅 완료된 array)]; 
        // param.push({'promotion' : promotion}); // 값 넣기

        await savePricing({
            recordId            : this.recordId
            , detailsJSON       : JSON.stringify(param)
            , specialDC         : specialDC
            , finalOrderPrice   : this.finalOrderPrice
        })        
        .then(() => {
            this.isLoading = false;
            showToast(this, 'success', customLabels.DNS_M_Success, customLabels.DNS_M_OrderPricingSaved);
            publish(this.messageContext, ORDER_DATA_MESSAGE, {detail: {isChanged : true}});
            this.dispatchEvent(new RefreshEvent());
        })
        .catch(error => {
            console.error('ERROR', JSON.stringify(error, null, 2));
            this.isLoading = false; 
            showToast(this, 'error', customLabels.DNS_M_GeneralError);
        });
    }

    // catch order data update
    _wiredOrderResult;

    @wire(getRecord, { recordId: '$recordId', fields: ORDER_FIELDS })
    wiredOrder(result) {
        this._wiredOrderResult = result;
        if (result.data) {
            this.doInit();
            console.log('dN_OrderPricing - refreshed');
        }
    }

    // to refesh payment schedule
    @wire(MessageContext) messageContext;
}