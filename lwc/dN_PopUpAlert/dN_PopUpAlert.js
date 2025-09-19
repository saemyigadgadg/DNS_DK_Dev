/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 11-25-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-25-2024   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, track } from 'lwc';
//Apex class
import getfileInfo from '@salesforce/apex/DN_PopManagerController.getFileInfo';
export default class DN_POPUpAlert extends LightningElement {
    recordId;
    @track notice = {};
    
    connectedCallback() {
        let params = new URL(window.location.href).searchParams;
        this.recordId = params.get('recordId');
        if(this.recordId) {
            this.getfileInfoList();
        }
    }

    /**
    * @description renderedCallback 불필요한 화면 제거
    * @author youjin.shim | 2024-11-25
    **/
    renderedCallback() {
        const targetDiv = document.querySelector('.cHeaderWrapper.cHeaderWrapper--fixed:has(~div .tb_layout)');
        const targetDIV2 = document.querySelector('.cCenterPanel:has(.tb_layout)');
        const siteforcePrmBody = document.querySelector('.siteforcePrmBody');
        siteforcePrmBody.className ='';
        if (targetDiv) {
            //popup header display none
            targetDiv.style.display = 'none';
        }
        if (targetDIV2) {
            //popup padding-top none
            targetDIV2.style.setProperty('padding', '0px', 'important');
        }

    }
    
    /**
    * @description 팝업창 close
    * @author iltae.seo | 2024-11-25
    **/
    handleClose() {
        window.close();
    }

    /**
    * @description 팝업창 close(하루동안 표기x)
    * @author iltae.seo | 2024-11-25
    **/
    handleTodayClose() {
        let todayDate = new Date();
        localStorage.setItem(this.recordId, todayDate.getDate() +1);        
        window.close();
    }

    /**
    * @description 공지사항 Info
    * @author iltae.seo | 2024-11-25
    **/
    getfileInfoList() {
        console.log(' 공지사항 정보!!');
        getfileInfo({recordId : this.recordId})
        .then(result =>{
            this.notice = result;
            console.log(JSON.stringify(this.notice), '< ==this.notice');
        }).catch(error =>{
            console.log(error);
        });
    }
}