/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-03-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-28   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire, track} from 'lwc';

import getData from '@salesforce/apex/DN_MonitoringAdminController.getData';

export default class DN_MonitoringAdminStatistics extends LightningElement {
    @track res={};
    @track isLoading = false;

    renderedCallback(){
        this.adjustSldsStyles();
    }

    adjustSldsStyles() { // SLDS Styles
        const style = document.createElement('style');
        style.innerText = `
        .slds-table_bordered {
            border-top: none;
        }
        `;
        this.template.querySelector('.total-wrap').appendCD
    }

    connectedCallback(){
        this.isLoading = true;
        this.search();
     }

     search(){
        this.isLoading = true;

        getData({
        }).then(result => {
            console.log('result ::: ', result);
            this.res = result;

        }).catch(error => {
            console.log('Error ::: ', error);
        }).finally(() => this.isLoading = false );

    }


}