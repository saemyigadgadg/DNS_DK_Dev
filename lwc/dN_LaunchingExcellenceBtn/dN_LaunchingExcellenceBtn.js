import { LightningElement, api, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import FORM_FACTOR from '@salesforce/client/formFactor'; // Large : Desktop, Medium : Tablet, Small : Phone

import getPMActivityType from '@salesforce/apex/DN_LaunchingExcellenceBtnController.getPMActivityType';
import checkDocId from '@salesforce/apex/DN_LaunchingExcellenceBtnController.checkDocId';

import { publish, MessageContext } from 'lightning/messageService';
import {NavigationMixin} from 'lightning/navigation';
import { showToast, style, label } from 'c/commonUtils';

import DNS_U_LaunchingExcellenceURL from "@salesforce/label/c.DNS_U_LaunchingExcellenceURL";

const { userAgent } = navigator;
export default class DN_LaunchingExcellenceBtn extends NavigationMixin(LightningElement){
    @api recordId = '$recordId';
    @api isDesktop = false;
    cLabel = label;
    isDocList = true;
    isSpinner = false;
    isOZeForm = false;
    isDocDownload = false;
    selectedDocId = '';
    docTitle = '';
    docURL = '';
    @api selectedDoc = 'UserTraining';
    @api userId = Id;
    @api device = FORM_FACTOR;
    @api TESTURL = DNS_U_LaunchingExcellenceURL +'/s?recordId=';

    @wire(MessageContext)
    messageContext;

    sendMessage() {
        const message = { chName: 'UserTraining' };
        publish(this.messageContext, CH_NAME_CHANNEL, message);
    }

    get docOptions(){
        return [
            { label: '사용자교육', value: 'UserTraining' },
            { label: '설치체크시트', value: 'Install' },
            { label: '설치매뉴얼', value: 'InstallManual' },
            { label: '설치일정표', value: 'InstallSchedule' },
        ];
    }

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
        this.doInit();
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

        window.addEventListener('message', this.handleMessage.bind(this));
    }

    disconnectedCallback() {
        // 메시지 수신 이벤트 제거
        window.removeEventListener('message', this.handleMessage.bind(this));
    }

    handleMessage(event) {
        try {
            const message = JSON.parse(event.data);
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

    handleDoc(event){
        console.log('event.target.value',event.target.value);
        this.selectedDoc = event.target.value
    }

    handleNext(){
        console.log('selectedDoc',this.selectedDoc);
        var selectedDoc = this.selectedDoc;
        this.isDocList = false;
        if(selectedDoc == 'UserTraining' || selectedDoc == 'Install'){
            this.isSpinner = true;
            this.isOZeForm = true;
            
            this.TESTURL += this.recordId;
            this.TESTURL += '&chName=';
            this.TESTURL += this.selectedDoc;
            this.TESTURL += '&userId=';
            this.TESTURL += this.userId;
            this.TESTURL += '&device=';
            this.TESTURL += this.device;
            console.log('TESTURL',this.TESTURL);
            if(this.device == 'IOS'){
                window.top.location.href = this.TESTURL;
            }
        }else{
            this.isSpinner = true;
            this.isDocDownload = true;
            
            
            this.checkContentDocId();
            
        }
    }
    
    handleDownload(){
        this.downloadClick(this.selectedDocId);
    }

    // handlePreview(){
    //     this.navigatePreview(this.selectedDocId);
    // }

    // navigatePreview(docId){
    //     this[NavigationMixin.Navigate]({ 
    //         type:'standard__namedPage',
    //         attributes:{ 
    //             pageName:'filePreview'
    //         },
    //         state:{ 
    //             selectedRecordId: docId
    //         }
    //     })
    // }

    checkContentDocId(){
        checkDocId({
            recordId : this.recordId,
            sheetName : this.selectedDoc
        })
        .then(result => {
            console.log('checkDocId', result);
            if(result.isSuccess){
                this.selectedDocId = result.returnValue;
                this.docTitle = result.contentTitle;
                this.docURL = result.downloadURL;
                this.isSpinner = false;
            }else{
                this.showTaost('ERROR', result.errMessage, 'ERROR');
                this.isSpinner = false;
            }
        })
        .catch(error => {
            console.log('error', error);
        });
    }

    downloadClick(docId) {
        console.log('Download File ID ', docId);
        if(FORM_FACTOR =='Large'){
            // this.closeModal();
            window.open(this.docURL);
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.docURL
                }
            });
        }
    }

    handleCancel(){
        this.closeModal();
    }

    loadComplete(){
        
        this.isSpinner = false;
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
    
    closeModal(){
        if(FORM_FACTOR !='Large'){
            this.isSpinner = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        }else{
            console.log('DeskTop으로 보는 화면');
            const event = new CustomEvent('closeButton', {
                detail: {
                    isDesktop : this.isDesktop
                }
            });
            this.dispatchEvent(event);
        }
    }

    //설치시운전 아니면 close
    doInit(){
        this.isSpinner = true;
        
        getPMActivityType({recordId : this.recordId})
        .then(result => {
            if(!result){
                this.showTaost('ERROR', '설치오더에서만 조회가 가능합니다.', 'ERROR');
                setTimeout(() => {
                    this.closeModal();
                  }, "1000");
                
            }else{
                this.isSpinner = false;
            }
        })
        .catch(error => {
            this.errorHandler('getPMActivityType', error);
        });
    }

    renderedCallback() {
        const style = document.createElement('style');
            style.innerText = `       
                .slds-modal__container {
                    margin: 0;
                }         
                .slds-modal__container:has(c-d-n_-launching-excellence-btn) {
                    padding-bottom: 2rem !important;
                    margin: 0 auto !important;
                }                    
                .custom-icon-download { 
                    --slds-c-icon-color-foreground-default: #0250d9;
                }         
                .slds-p-around_medium:has(.radio) {
                    padding: 1.5rem 2rem !important;
                }
                .slds-p-around_medium:has(.radio) .slds-form-element__legend {
                    margin-bottom: 1rem;
                }
                .slds-p-around_medium:has(.radio) .slds-form-element__control .slds-radio {
                    margin-top: 0.5rem;
                }
                @media all and (max-width: 479px) {
                    .slds-modal__container:has(c-d-n_-launching-excellence-btn) {
                        width: 100vw% !important;
                        max-width: unset !important;
                        padding: 0 !important;
                        margin: 0 !important;
                        height: 100vh !important;
                    }
                    .slds-modal__content:has(c-d-n_-launching-excellence-btn) {
                        height: 100vh !important;
                        padding: 0 !important;
                    }
                    .launchingExcellenceBtn .slds-modal__container {
                        display: flex;
                        flex-direction: column;
                        height: 100vh !important;
                    }  
                    .launchingExcellenceBtn .slds-modal__header {
                        display: none;
                    }
                    .launchingExcellenceBtn .slds-modal__content {
                        flex: auto;
                    }
                    .launchingExcellenceBtn .slds-modal__footer {
                        padding-bottom: 2rem;
                    }
            `;
            this.template.querySelector('.launchingExcellenceBtn').appendChild(style);
    }
    
}