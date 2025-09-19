/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-04
 * @last modified by  : yeongdeok.seo@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-04-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire, track} from 'lwc';

import getData from '@salesforce/apex/DN_InnovationManageController.getData';

export default class DN_InnovationManagementReport extends LightningElement {
    @track res={};
    @track dateToValue;
    @track dateFromValue;

    isLoading = false;

    connectedCallback(){
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1 해줘야 함
        const dd = String(today.getDate()).padStart(2, '0');

        // 'YYYY-MM-DD' 형식으로 날짜 값을 설정
        this.dateToValue = `${yyyy}-${mm}-${dd}`;
        this.dateFromValue = `${yyyy}-${mm}-${dd}`;

        this.search();
    }

    renderedCallback(){
        this.adjustSldsStyles();
    }

    search(){
        this.isLoading = true;
        console.log("from: "+this.dateFromValue);
        console.log("to: "+this.dateToValue);

        getData({
             dateTo : this.dateToValue
            ,dateFrom : this.dateFromValue
        }).then(result => {
            console.log('result ::: ', result);
            this.res = result;

        }).catch(error => {
            console.log('Error ::: ', error);
        }).finally(() => this.isLoading = false );

    }

    //날짜 변경 시
    handleDateChange(event) {
        if(event.target.name == "to") {
            this.dateToValue = event.target.value;
        } else {
            this.dateFromValue = event.target.value;
        }
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

}