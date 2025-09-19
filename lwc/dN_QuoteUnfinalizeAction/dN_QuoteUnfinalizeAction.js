/* Final Quote 해지 js - 2025.08.14
 dN_QuoteUnfinalizeAction.js*/

import { LightningElement, api } from 'lwc';
import { showToast, style, label } from 'c/commonUtils';

import { CloseActionScreenEvent } from 'lightning/actions';

import getFinalQuoteBackStatus from '@salesforce/apex/DN_FinalQuoteCheckController.getFinalQuoteBackStatus';
import backOutFinalQuote from '@salesforce/apex/DN_FinalQuoteCheckController.backOutFinalQuote';

// Title & Buttons
import DNS_T_QuoteUnfinalizeTitle from '@salesforce/label/c.DNS_T_QuoteUnfinalizeTitle';
import DNS_M_Cancel from '@salesforce/label/c.DNS_M_Cancel';
import DNS_M_Confirm from '@salesforce/label/c.DNS_M_Confirm';

// 성공 메시지(성공시에만 사용)
import DNS_M_UnfinalizeSuccess from '@salesforce/label/c.DNS_M_UnfinalizeSuccess';
// 예외 대비(네트워크/런타임 등)
import DNS_M_Unfinalize_Generic from '@salesforce/label/c.DNS_M_Unfinalize_Generic';

export default class DN_QuoteUnfinalizeAction extends LightningElement {
  @api recordId;
  labels = {
    title: DNS_T_QuoteUnfinalizeTitle,
    cancel: DNS_M_Cancel,
    confirm: DNS_M_Confirm
  };


  isLoading = false;
  isShow = false;
    
  connectedCallback(){
      this.doInit();
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleConfirm() {
        backOutFinalQuote({ recordId: this.recordId })
        .then(result => {
            if (result === 'SUCCESS') {
            showToast(this, 'success', 'success', DNS_M_UnfinalizeSuccess );
            this.isLoading = false;
            }
          });
        
        this.dispatchEvent(new CloseActionScreenEvent());
        if (window.location.pathname.includes('/partners/')) {
            window.location.href = window.location.origin + '/partners/s/quote/' + this.recordId;
        }else {
            window.location.href = window.location.origin + '/lightning/r/Quote/' + this.recordId + '/view';
        }
  }
  
  doInit(){     
    if (window.location.pathname.includes('/partners/')) {
        const path = window.location.pathname; 
        const parts = path.split('/');
        this.recordId = parts[4]; 
    } else {
        const url = window.location.href; 
        console.log('url : ' + url);
        const params = new URLSearchParams(new URL(url).search);
        this.recordId = params.get('recordId');

    }

    console.log('recordId : ' + this.recordId);
    //console.log('여기옴?');
    
    getFinalQuoteBackStatus({ recordId: this.recordId })
    .then(result => {
    console.log('status : ' + String(result));
      if (result === 'SUCCESS') {
        this.isShow = true;
        this.isLoading = false;
      } else {
        showToast(this, 'Fail', 'warning', result );
        this.dispatchEvent(new CloseActionScreenEvent());
      }
    }).catch(error => {
            console.error('error 1 : ' + error.message);
        showToast(this, 'error', 'error', DNS_M_Unfinalize_Generic );
        this.dispatchEvent(new CloseActionScreenEvent());
        });
    }
}