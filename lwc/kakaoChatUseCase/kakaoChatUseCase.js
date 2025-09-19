import { LightningElement, wire, api } from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import getUserEmail from '@salesforce/apex/MatrixChatController.getUserEmail';
import getMatrixChatData from "@salesforce/apex/MatrixChatController.getMatrixChatData";

import saveMessage from "@salesforce/apex/MatrixChatController.saveMessage";

import findCase from "@salesforce/apex/MatrixChatController.findCase";
import saveAISummary from "@salesforce/apex/MatrixChatController.saveAISummary";
import saveMessageWithOutSavingFile from "@salesforce/apex/MatrixChatController.saveMessageWithOutSavingFile";
import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin, CurrentPageReference  } from 'lightning/navigation';



export default class KakaoChatUseCase extends NavigationMixin(LightningElement) {
    @api recordId ; // This property is automatically populated with the current record ID in a record context
    iframeWindow = null;
    caseId = '';
    showIframe = true;
    email = '';
    record;
    error;
    matrixChat ;
    matrixUserId = '';


    @wire(getRecord, { recordId: '$recordId' })
    wiredRecord({ error, data }) {
        if (error) {
          this.error = "Unknown error";
          console.log("error",this.error);
          if (Array.isArray(error.body)) {
            this.error = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            this.error = error.body.message;
          }
          this.record = undefined;
        } else if (data) {
            this.record = data;
            console.log("error",this.record);
        }
      }

    constructor() {
        super();
        window.addEventListener('message', this.receiveMessage.bind(this));

    }


    connectedCallback() {

    }

    renderedCallback() {
        // console.log('The kakaochatuseCase has been renderedCallback',this.recordId);
        this.iframeWindow = this.template.querySelector('iframe').contentWindow;
        this.getMatrixChatData();
        this.getUserEmail();
        // this.saveFile('https://talk.kakaocdn.net/dna/Crrh/o0qSBAsyuY/Q5KPo1xueOKBOGnTDb6JI5/i_9546ad203995.png?credential=zf3biCPbmWRjbqf40YGePFLewdou7TIK&expires=1703131643&signature=5ug5fgaLRXULtvX0WxV3zN69Azo%3D');



    }

    // sendMessageToIframe() {
    //     // const message = { 'type': 'CASEID', 'text': String(this.recordId) };
    //     // const msg = { 'type':'caseId','text': this.recordId}
    //     // console.log("recoredId type",typeof this.recordId,typeof message, typeof msg)
    //     console.log("sendMessageToIframe",this.recordId,this.record);

    //     this.iframeWindow.postMessage(this.recordId, '*');
    // }
    receiveMessage(event) {
        // Always verify the origin of the message
       
        if (event.origin !== 'https://chat.matrixcloud.kr') {
            return;
        }


        const { data: orgData = {}, origin = "" } = event;

        const { type, data } = orgData;
        // console.log('lko Received message from chatcompoent iframe:',event, type, data);
        const {recordId} = data;
        if(recordId !== this.recordId && type !== 'CHAT_FROM_READY'){
            console.log("recordId is not matched",recordId,this.recordId);
            return;
        }


        switch (type) {
            case "CHAT_FROM_READY":
                if(this.email === ''){
                    const sendData = {
                        type:'CHAT_TO_DATA_NOT_READY',
                        data:{

                        }
                    }
                    console.log("CHAT_TO_DATA_NOT_READY",JSON.stringify(sendData));
                    this.sendMessageToIframe(JSON.stringify(sendData));
                    // this.iframeWindow.postMessage(JSON.stringify(sendData), '*');
                }else{
                    const sendData = {
                        type:'CHAT_TO_PROVIDE_ID',
                        data:{
                            id: this.recordId,
                            email: this.email,
                            matrixChat:{...this.matrixChat}
                        }
                    }
                    console.log("CHAT_TO_PROVIDE_ID", JSON.stringify(sendData));
                    this.sendMessageToIframe(JSON.stringify(sendData));
                    // this.iframeWindow.postMessage(JSON.stringify(sendData), '*');
                }

      
              break;
            case "CHAT_FROM_USER_DATA":
                console.log("CHAT_FROM_USER_DATA",JSON.stringify(data));
                this.matrixUserId = data.userid;  
            break;
            // case 'CHAT_FROM_AGENT_MESSAGE':

            //     if(data.fileUrl){
            //         this.saveFile(data.fileUrl)
            //     }
            //   break;
            // case 'CHAT_FROM_CUSTOMER_MESSAGE':
            //     if(data.fileUrl){
            //         this.saveFile(data.fileUrl)
            //     }
            //   break;
            case 'CHAT_FROM_PROVIDE_ALLMESSAGE':
                console.log("CHAT_FROM_PROVIDE_ALLMESSAGE",this.recordId, JSON.stringify(data,undefined,2));

                 this.saveChatMessage(data)

              break;    
            case 'CHAT_FROM_PROVIDE_AI_SUMMARY':
            console.log("CHAT_FROM_PROVIDE_AI_SUMMARY",this.recordId, JSON.stringify(data,undefined,2));

                this.saveAISummary(data)

            break;     
            
            case 'CHAT_FROM_EVENT_EXPIREDSESSION':
                console.log("CHAT_FROM_EVENT_EXPIREDSESSION",JSON.stringify(data,undefined,2),String(this.matrixUserId),this.email);
                // if ( this.email === data?.email){
                    const tempsendData = {
                        type:'CHAT_TO_AI_SUMMARY',
                        data:{
                            // email: login.email,
                            roomId: data?.roomId,
                            email: this.email
                        }
                    }
                    console.log("CHAT_TO_AI_SUMMARY",JSON.stringify(tempsendData));
                    this.sendMessageToIframe(JSON.stringify(tempsendData));
                // }


                // this.iframeWindow.postMessage(JSON.stringify(tempsendData), '*');
                // const tempsendData1 = {
                //     type:'CHAT_TO_GET_ALL_MESSAGE',
                //     data:{
                //         roomId: data?.endRoom?.id,
                // }
                // }
                // console.log("CHAT_TO_GET_ALL_MESSAGE",tempsendData1);
                // this.sendMessageToIframe(JSON.stringify(tempsendData1));


                break;             

            default:
            //   console.log("TYPE is not entered in chatUseCase!");
            //   setTimeout(()=>{
            //     this.showToast(
            //         "Success!!",
            //         "상담이력 저장됨!!",
            //         "success",
            //         "dismissable"
            //       );
            //     this.dispatchEvent(new RefreshEvent());
            //   },4000)

              break;
        }
        
    }
    async getUserEmail(){
        getUserEmail()
        .then(result => {
            this.email = result;
            console.log("getUserEmail",this.email)

        })
        .catch(error =>{
            console.log(error);
        });
        
    }

    async getMatrixChatData(){
        this.matrixChat = await getMatrixChatData({Id:this.recordId});
        console.log("matrixChat  = ", this.matrixChat);
    }



    async saveAISummary(data) {
        

        const findedCase = await findCase({ roomId: data.roomId });
        // console.log("findedCase  = ", findedCase);


        const matrixChatToUpdate = {
            Id: findedCase.Id,
            Matrix_Call_Category__c: data?.category || '' ,
            Matrix_Call_Emotion__c: data?.emotion || '',
            Matrix_Call_Summary__c: data?.summary || '',


        };

        // console.log("saveAISummary:", JSON.stringify(matrixChatToUpdate));

        const result = await saveAISummary({ matrixChatToUpdate})
        console.log("saveAISummary result",result);
        if(result === 'updated'){
            this.showToast(
                "Success!!",
                "상담 요약 저장 완료",
                "success",
                "dismissable"
            );
            this.dispatchEvent(new RefreshEvent());
        
        } else if(result === 'skipped'){
            this.showToast(
                "Warning!!",
                "상담요약 이미 저장됨",
                "warning",
                "dismissable"
            );
        } else {
            this.showToast(
                "Error!!",
                "상담 요약 저장 실패",
                "error",
                "dismissable"
            );
        }
    // //      this.openMatrixChat(matrixChat.Id);
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__app',
    //         attributes: {
    //             pageRef: {
    //                 type: 'standard__recordPage',
    //                 attributes: {
    //                     recordId: findedCase.Id,
    //                     objectApiName: 'Case',
    //                     actionName: 'view'
    //                 }
    //             }
    //         }
    //     });
    }   

    // get iframeUrl() {
    //     return 'https://chat.matrixcloud.kr/saleschat';
    // }

    async handleConsultSummaryusingOpenAI(){
        const sendData = {
            type:'CHAT_TO_GET_MESSAGE',
            data:{

            }
        }
        // console.log("CHAT_TO_GET_MESSAGE",sendData);
        
        this.sendMessageToIframe((JSON.stringify(sendData)));
        // this.iframeWindow.postMessage(JSON.stringify(sendData), '*');
    }

    async saveChatMessage(data) {
       
        try {

    
            await saveMessageWithOutSavingFile({ caseId: this.recordId, messages: data.allMessage });
    
            this.dispatchEvent(new RefreshEvent());
        }catch(error){
            console.log(JSON.stringify(error));
        }




    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: mode
        });
        this.dispatchEvent(evt);
      }
    sendMessageToIframe(sendData) {
    const iframe = this.template.querySelector('iframe');
    if (iframe) {
        iframe.contentWindow.postMessage(sendData, 'https://chat.matrixcloud.kr');
    }
    }      
}