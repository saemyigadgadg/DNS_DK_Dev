/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-12-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import FORM_FACTOR from '@salesforce/client/formFactor'; // Large : Desktop, Medium : Tablet, Small : Phone
const { userAgent } = navigator;
import DNS_U_LaunchingExcellenceURL from "@salesforce/label/c.DNS_U_LaunchingExcellenceURL";

export default class DN_InstallationInspectionBtn extends LightningElement{ 
    isSpinner = true; 
    @api recordId;
    @api userId = Id;
    @api isDesktop = false;
    @api device = FORM_FACTOR;
    // @api iframeURL = 'https://dn-solutions.my.site.com/s?recordId=';
    // @api iframeURL = 'https://dn-solutions--dev.sandbox.my.site.com/s?recordId=';
    @api iframeURL = DNS_U_LaunchingExcellenceURL +'/s?recordId=';
    
    get isIOS() {
        return userAgent.match(/iPhone|iPad|iPod/i) != null;
    }

    get isAndroid() {
        return userAgent.match(/Android/i) != null;
    }

    get isWindows() {
        return userAgent.match(/Windows/i) != null;
    }

    connectedCallback() {        
        console.log('FORM_FACTOR', FORM_FACTOR);
        console.log('isWindows',this.isWindows); // true
        console.log('isIOS',this.isIOS);     // false
        console.log('isAndroid',this.isAndroid); // false
        // this.doInit();
        // this.showTaost('SUCCESS','isWindows :'+this.isWindows +'  isIOS :'+ this.isIOS + '  isAndroid :'+this.isAndroid,'SUCCESS');
        if(FORM_FACTOR =='Large'){
            this.isDesktop = true;
        }else{
            if(this.isAndroid){
                this.device = 'Android';
            }else{
                this.device = 'IOS';
            }
        }

        this.iframeURL += this.recordId;
        this.iframeURL += '&chName=InstallationInspection&userId=';
        this.iframeURL += this.userId;
        this.iframeURL += '&device=';
        this.iframeURL += this.device;
        console.log('iframeURL',this.iframeURL);

        window.addEventListener('message', this.handleMessage.bind(this));
    }

    handleMessage(event) {
        try {
            const message = JSON.parse(event.data);
            console.log('message.action :: '+message.action);
            if(message.action === 'startSpinner'){
                this.isSpinner = true;
            }else if(message.action === 'stopSpinner'){
                this.isSpinner = false;
            }else if (message.action === 'closeIframe') {
                if(this.device == 'Android'){
                    this.closeModal();
                }else{
                    this.showTaost('SUCCESS', '저장되었습니다.', 'success');
                    this.closeModal();
                }
            }else if(message.action === 'toastErrMsg'){
                this.showTaost('ERROR', '저장하는데 문제가 발생했습니다.', 'ERROR');
                this.isSpinner = false;
            }
        } catch (error) {
            console.error('Error parsing message:', error);
        }
    }

    disconnectedCallback() {
        // 메시지 수신 이벤트 제거
        window.removeEventListener('message', this.handleMessage.bind(this));
    }

    showTaost(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    myframeLoad() {
        this.isSpinner = false;
    }
    
    handleCancel(){
        this.closeModal();
        console.log("cancle-------");
    }

    closeModal(){
        if(FORM_FACTOR !='Large'){
            this.isSpinner = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        }else{
            const event = new CustomEvent('closeButton', {
                detail: {
                    isDesktop : this.isDesktop,
                }
            });
            this.dispatchEvent(event);            
        }
    }

    renderedCallback() {
        const style = document.createElement('style');
            style.innerText = `       
                .slds-modal__container {
                    margin: 0;
                }         
                .slds-modal__container:has(c-d-n_-installation-inspection-btn) {
                    padding-bottom: 2rem !important;
                    margin: 0 auto !important;
                }                    
                .custom-icon-download { 
                    --slds-c-icon-color-foreground-default: #0250d9;
                }         
                @media all and (max-width: 479px) {
                    .slds-modal__container:has(c-d-n_-installation-inspection-btn) {
                        width: 100vw% !important;
                        max-width: unset !important;
                        padding: 0 !important;
                        margin: 0 !important;
                        height: 100vh !important;
                    }
                    .slds-modal__content:has(c-d-n_-installation-inspection-btn) {
                        height: 100vh !important;
                        padding: 0 !important;
                    }
                    .installationInspectionBtn .slds-modal__container {
                        display: flex;
                        flex-direction: column;
                        height: 100vh !important;
                    }  
                    .installationInspectionBtn .slds-modal__header {
                        display: none;
                    }
                    .installationInspectionBtn .slds-modal__content {
                        flex: auto;
                    }
                    .installationInspectionBtn .slds-modal__footer {
                        padding-bottom: 2rem;
                    }
            `;
            this.template.querySelector('.installationInspectionBtn').appendChild(style);
    }
}