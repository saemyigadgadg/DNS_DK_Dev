import { LightningElement } from 'lwc';
//Apex 
import getSession from '@salesforce/apex/DN_DealerPortalSessionController.getSession';
export default class DN_DealerPortalSession extends LightningElement {

    connectedCallback() {
        setInterval(() => {
            this.sessionCheck();
        },60000);
    }
    // renderedCallback() {//highlights slds-clearfix slds-page-header slds-page-header_record-home
    //     setTimeout(() => {
    //         // 최상위 컨테이너 찾기
    //         const parentElements = document.querySelectorAll('.forceCommunityRecordHeadline');
    //         if (parentElements.length > 0) {
    //             parentElements.forEach((parentElement) => {
    //                 console.log('탭 컨테이너 찾음:', parentElement);
    //                 // 수정 버튼 찾기
    //                 const editButtons = parentElement.querySelectorAll('button.slds-button[name="DealerOrder__c.Edit"]');
    //                 editButtons.forEach((btn) => {
    //                     console.log('수정 버튼 찾음:', btn);
    //                     btn.style.display = 'none'; // 삭제 버튼 숨기기
    //                     // btn.click(); // 클릭하려면 주석 해제
    //                 });

    //                 // 삭제 버튼 찾기
    //                 const deleteButtons = parentElement.querySelectorAll('button.slds-button[name="DealerOrder__c.Delete"]');
    //                 deleteButtons.forEach((btn) => {
    //                     console.log('삭제 버튼 찾음:', btn);
    //                     btn.style.display = 'none'; // 삭제 버튼 숨기기
    //                     // btn.click(); // 클릭하려면 주석 해제
    //                 });
    //             });
    //         }
    //     }, 5000);
        

    //     // setTimeout(() => {
    //     //     //forcegenerated-record-layout2
    //     //     console.log(document.querySelector('.ui-widget'), ' ::::: ');
    //     // }, 3000);
    //     //class="ui-widget"
    //     //console.log(document.querySelector('.slds-col.slds-no-flex.slds-grid.slds-grid_vertical-align-center.horizontal.actionsContainer'), ' ::::: ');
    // }
    sessionCheck() {
        getSession({
        }).then( result => {
            ///console.log('Id ==>', result);
        }).catch(error => {
            let errorMsg = error.body.message;
            
            window.location.reload(true);
            
            console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
        });
    }
}