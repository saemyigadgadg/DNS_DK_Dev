import { LightningElement , api, track} from 'lwc';
import { showToast, style, label } from 'c/commonUtils';
import getFailureList from '@salesforce/apex/DN_CustomerReceivedHistoryController.getFailureList';

export default class DN_ServiceHistoryButton extends LightningElement { 
    @api searchData;
    @api recordId;
    @track isLoading    = false;

    cLabel = label;

    connectedCallback() {
      this.isLoading = true;  
      getFailureList({recordId : this.recordId,
                      operationType : 'Asset'
                    }).then( result => {
                      console.log('result ', result);
                      this.searchData = result;
                    }).then( result =>{
                        this.isLoading = false;
                    });
    }
    renderedCallback() {
        this.adjustSLDSStyles();
    }

    handleClick(event) {
        const button = event.target;
        const rowDiv = button.closest('.more');
        const p = rowDiv.querySelector('.value');
        p.classList.toggle('open');
    }

    adjustSLDSStyles() {
        const style = document.createElement('style');
        style.innerText = `
           .row .button-wrap .slds-button {
                text-wrap-mode: nowrap;
                font-size: 15px;
                border: 1px solid #c9c9c9;
                line-height: 1.6;
           }
         `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }
}