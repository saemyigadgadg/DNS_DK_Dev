/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Hyerin Ro
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-06   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, api } from 'lwc';
import { label } from 'c/commonUtils';

import getServiceResourceList from '@salesforce/apex/DN_SearchFilterComboboxController.getServiceResourceList';
import getWorkcenterId from '@salesforce/apex/DN_SearchFilterComboboxController.getWorkcenterId';
import getSearchWorker from '@salesforce/apex/DN_SearchFilterComboboxController.getSearchWorker';


export default class DN_SearchFilterCombobox extends LightningElement {

    @api isSelect = false;
    isDropdownOpen = false; 
    @api serviceTerritoryId = '';
    @api workerId = '';
    @api isSP = false;
    searchKey = '';
    srMap;
    cLabel = label;

    connectedCallback() {
        // 초기 로드 시 값이 있으면 콤보박스 값 표시
        this.searchData();
    }

    renderedCallback() {
        this.adjustStyles();        
    }

    //수정된 내용 by 민하영
    searchData(){
        console.log('this.serviceTerritoryId',this.serviceTerritoryId);
        console.log('this.workerId',this.workerId);

        getServiceResourceList({
            workcenterId : this.serviceTerritoryId,
            workerId : this.workerId
        })
        .then(result => {
            console.log('getServiceResourceList', result);  
            this.srMap = result;    

            if(this.workerId){
                console.log('this.Worker', this.workerId);
                this.isSelect = true;
            }
            
        }).catch(error => {
            console.log('Error', error);
        });
    }

    searchWorkcenter(){
        getWorkcenterId({
            workerId : this.workerId
        })
        .then(result => {
            console.log('getWorkcenterId', result);  
            this.serviceTerritoryId = result;
            this.dispatchEvent(new CustomEvent('valuechange', { detail: { lookupValue: this.serviceTerritoryId, selectedValue : this.workerId} }));

            this.searchData(); 
        }).catch(error => {
            console.log('Error', error);
        });
    }

    searhcWorkerWithKey(){
        getSearchWorker({
            searchKey : this.searchKey,
            workcenterId : this.serviceTerritoryId
        })
        .then(result => {
            console.log('getSearchWorker', result);  
            this.srMap = result;    
        }).catch(error => {
            console.log('Error', error);
        });
    }

    changeWorkcenter(event){
        console.log('changeWorkcenter');
        if(event.target.value){
            this.serviceTerritoryId = event.target.value;
        }else{
            this.workerId = '';
            this.isSelect = false;
            this.isDropdownOpen = false;
            this.serviceTerritoryId = '';
        }
        this.searchData();
        this.dispatchEvent(new CustomEvent('valuechange', { detail: { lookupValue: this.serviceTerritoryId, selectedValue : this.workerId} }));
    }

    changeWorker(event){
        if(event.target.value){
            this.workerId = event.target.value;
        }else{
            this.workerId = '';
            this.searchData();
            this.isSelect = false;
        }
        this.dispatchEvent(new CustomEvent('valuechange', { detail: { lookupValue: this.serviceTerritoryId, selectedValue : this.workerId} }));
    }
    
    workerFocus(){
        console.log('Focus됨');
        this.isDropdownOpen = true;
    }
    wokerOutFocus(){
        if (this.preventBlur) {
            this.preventBlur = false;
            return;
        }
        this.isDropdownOpen = false;
    }
    searchWorker(event){
        //검색
        this.searchKey = event.target.value;
        this.searhcWorkerWithKey();
        console.log('Search됨');
    }
    handleMouseDown(event) {
        this.preventBlur = true; // blur 이벤트를 무시하도록 설정
    }
    handleWorker(event){
        event.preventDefault();
        const selectedValue = event.currentTarget.dataset.value;
        this.workerId = selectedValue;
        this.searchWorkcenter();
        this.isSelect = true;
        // 드롭다운 닫기
        this.isDropdownOpen = false;
        // this.dispatchEvent(new CustomEvent('valuechange', { detail: { lookupValue: this.serviceTerritoryId, selectedValue : this.workerId} }));
    }

    @api handleAuraValueChange() {
        console.log('Selected serviceTerritoryId is:', this.serviceTerritoryId);
        console.log('Selected workerId is:', this.workerId);
        console.log('Selected isSelect is:', this.isSelect); 
        this.searchData();
    }

    // 🎨 SLDS Styles
    adjustStyles(){        
        const style = document.createElement('style');
        style.innerText = `
            .input-wrap .input-label:before {
                content: ${this.isRequired ? '"*"' : '""'};
                color: #ba0517;
                cursor: help;
                margin: 0 0.125rem;
            }
            .input-wrap .slds-input__icon_left{
                right: 0.28rem;
                width: 1rem !important;
                height: 1rem !important;
                left: unset !important;
            }
            .input-wrap .slds-listbox_vertical .slds-listbox__option_entity{
                padding: 0.5rem;
            }
            .input-wrap .slds-input{
                padding-left: 0.5rem;
            }
            .input-wrap .slds-icon_small{
                width: 1.25rem;
                height: 1.25rem;
            }
            .input-wrap .slds-media__figure{
                margin-right: 0.5rem;
            }
            .selected-wrap .slds-media_center{
                padding: 0.25rem;
                border: 1px solid #747474;
                border-radius: 0.25rem;
                min-height: 2rem;
            }
            .selected-wrap .slds-input-has-icon_left-right .slds-input__icon_right{
                right: 0.5rem !important;
            }
            .input-field-wrap .slds-form-element .slds-form-element__control { 
                padding-left: 0 !important;
            }
            .input-field-wrap .slds-form-element .slds-form-element__label {
                display: none !important;
            }
            
            `;

        // 이전 스타일 제거
        const existingStyle = this.template.querySelector('style');
        if (existingStyle) {
            existingStyle.remove();
        }

        this.template.querySelector('.input-wrap').appendChild(style);
    }

    
}