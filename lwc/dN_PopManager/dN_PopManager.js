/**
 * @description       : 
 * @author            : iltae.seo@sbtglobal.com
 * @group             : 
 * @last modified on  : 11-25-2024
 * @last modified by  : iltae.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-25-2024   iltae.seo@sbtglobal.com     Initial Version
**/
import { LightningElement,api,wire } from 'lwc';
//Apex class
import getBoardList from '@salesforce/apex/DN_PopManagerController.getBoardIds'; 
import getPreview from '@salesforce/apex/DN_PopManagerController.getPreview'; 
import portalURL from "@salesforce/label/c.DN_DealerPortalURL";
import {CurrentPageReference} from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class DN_POPManager extends LightningElement {
    currentUrl ='';
    isQuickAction = false;
    @api recordId;
    connectedCallback() {
        console.log(this.recordId,' < ==this.recordId');
        // // recordId유무
        // if(this.recordId ==undefined) {
        //     this.handlePopList();
        // } else {
        //     this.handlePreview();
        // }
        
    }
    renderedCallback() {
        if(this.isQuickAction) {
            this.handlePreview();
        } else {
            this.handlePopList();
        }
    }
    // wire를 통해 recordId 유무 확인
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(' wire 타는지 유무', currentPageReference.state.recordId);
            if(currentPageReference.state.recordId !=undefined) {
                this.isQuickAction = true;
                this.recordId = currentPageReference.state.recordId;
            }
        } 
    }
    // 미리보기
    handlePreview() {
        getPreview({
            recordId : this.recordId
        })
        .then(result =>{
            console.log('url', `${portalURL}Notice-PopUp?recordId=${result.Id}`);
            let scroll = result.IsScroll__c ? 'yes': 'no';
            window.open(`${portalURL}Notice-PopUp?recordId=${result.Id}`, `${result.Name}`, `top=10, left=10, width=${result.Width__c}, height=${result.Height__c}, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=${scroll}`);                
            this.dispatchEvent(new CloseActionScreenEvent());
        }).catch(error =>{
            console.log(error);
        });
    }

    /**
    * @description 팝업창 목록
    * @return List<Board__c>
    * @author iltae.seo | 2024-11-25
    **/
    handlePopList() {
        this.currentUrl = window.location.href;
        getBoardList({})
        .then(result =>{
            console.log(JSON.stringify(result), ' < === result111');
            result.forEach(element => {
                console.log('url', `${this.currentUrl}Notice-PopUp?recordId=${element.Id}`);
                let scroll = element.IsScroll__c ? 'yes': 'no';
                if(element.IsTodayView__c) {
                    let isExpiredays = this.getlocalStorage(element.Id);
                    if(!isExpiredays) {
                        window.open(`${this.currentUrl}Notice-PopUp?recordId=${element.Id}`, `${element.Name}`, `top=10, left=10, width=${element.Width__c}, height=${element.Height__c}, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=${scroll}`);                
                    }
                } else {
                    window.open(`${this.currentUrl}Notice-PopUp?recordId=${element.Id}`, `${element.Name}`, `top=10, left=10, width=${element.Width__c}, height=${element.Height__c}, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=${scroll}`);    
                }

                this.getlocalStorage(element.Id);
            });
        }).catch(error =>{
            console.log(error);
        });
    }

    /**
    * @description 현재 브라우저 상에서 하루동안 안보이기 설정 유무 확인
    * localStorage (key : recordId, value : 일자);
    * @author iltae.seo | 2024-11-25
    **/
    getlocalStorage(name) { 
        let todayDate = new Date();
        let isExpiredays = false;
        if (localStorage.getItem(name) != null) {
            isExpiredays = localStorage.getItem(name) > todayDate.getDate() ? true : false;
        }
        return isExpiredays;
    }

}