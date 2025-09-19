import { LightningElement, wire, api } from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import User_Id from "@salesforce/user/Id";
import { NavigationMixin, CurrentPageReference  } from 'lightning/navigation';

import getUserEmail from '@salesforce/apex/MatrixChatController.getUserEmail';
import getUserInfo from '@salesforce/apex/MatrixChatController.getUserInfo';
import updateOwnerId from "@salesforce/apex/MatrixChatController.updateOwnerId";
import findCase from "@salesforce/apex/MatrixChatController.findCase";

import saveMessage from "@salesforce/apex/MatrixChatController.saveMessage";
import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { closeTab , getFocusedTabInfo } from 'lightning/platformWorkspaceApi';



export default class KakaoListUseCase extends NavigationMixin(LightningElement) {
    iframeWindow = null;
    email ='';
    matrixChat ;
    userId = User_Id;
    matrixUserId = '';



    @wire(getRecord, { recordId: '$Id' })
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
            console.log("data",this.record);
        }
    }

    constructor() {
        super();
        window.addEventListener('message', this.receiveMessage.bind(this));

    }


    connectedCallback() {
        console.log('userid',this.userId);
    }

    @api handleChangeRecordId(caseId,roomId) {
        // Handle the event from Aura component
        console.log("Message from Aura: roomId", caseId,roomId);
        const sendData = {
            type:'LIST_TO_PROVIDE_CHANGED_ROOM_ID',
            data:{
                caseId,
                roomId
            }
        }
        this.sendMessageToIframe(JSON.stringify(sendData));
        // this.iframeWindow.postMessage(JSON.stringify(sendData), '*');)
        // this.iframeWindow.postMessage(JSON.stringify(sendData), '*');

        
    }

    async getMatrixChatData(){
        this.matrixChat = await getMatrixChatData({Id:this.recordId});
        // console.log("kakaoListUseCase matrixChat  = ", this.matrixChat);
    }

    renderedCallback() {

        // this.iframeWindow = this.template.querySelector('iframe').contentWindow;
        // console.log("rendercallbaclk",this.userId, this.record)

        this.getUserEmail();
        // this.getRoomId();


    }



    async receiveMessage(event) {
        
        if (event.origin !== 'https://chat.matrixcloud.kr') {
            return;
        }

        const { data: orgData = {}, origin = "" } = event;
        const { type, data } = orgData;
        const sendData = {};
        let message = null;
        // console.log('lko Received message from chatlist iframe:',event, type, JSON.stringify(data));

        switch (type) {
            case "LIST_FROM_ASSIGN":
                if ( this.email !== data.email){
                    console.warn(`${this.email} is not equal to ${data.email}`);
                    return;
                }

                this.updateOwnerId(data.roomId);

                message = {
                    type: 'LIST_CLOSE',
                    data
                    }
                this.handleReceviceMessage(message);
            break;
            case "LIST_FROM_USER_DATA":
                console.log("LIST_FROM_USER_DATA",data);
                this.matrixUserId = data.userid;
            break;              
            case "LIST_FROM_OPEN":
                this.openCase(data.roomId);

              break;
            case 'LIST_FROM_READY':
                console.log('LIST_FROM_READY');
                const sendData = {
                    type:'LIST_TO_PROVIDE_EMAIL',
                    data:{
                        email: this.email,
                        centerid: 'dns',
                    }
                }
                console.log("LIST_TO_PROVIDE_EMAIL",typeof sendData,JSON.stringify(sendData));
                this.sendMessageToIframe(JSON.stringify(sendData));
                // this.iframeWindow.postMessage(JSON.stringify(sendData), '*');
                break;
            case 'LIST_FROM_CUSTOMER_MESSAGE':
                console.log("LIST_FROM_CUSTOMER_MESSAGE",data);
                this.checkMyCase(data.roomId)
                .then(result => {
                    if (result){
                        this.handleCustomerMessage(data);
                    }
                }).catch(error =>{
                    console.log('checkMyCase error',error);
                })


                break;
            case 'LIST_FROM_EVENT_OPERATIONCALL':
                console.log("LIST_FROM_EVENT_OPERATIONCALL",data);
                message = {
                    type: 'EVENT_OPERATIONCALL',
                    data
                }
                this.handleReceviceMessage(message);

                break;                
            case 'LIST_FROM_EVENT_SETOPERATION':
                console.log("LIST_FROM_EVENT_SETOPERATION",data.operationRoom);
 
                if ( String(this.matrixUserId) === String(data.operationRoom.operatorId)){
                    message = {
                        type: 'EVENT_SETOPERATION',
                        data
                    }
                    this.handleReceviceMessage(message);
                    // this.updateOwnerIdWithOutOpenCase(data.operationRoom.id)
                }

                break; 
            case 'LIST_FROM_EVENT_SETOPERATORTRANSFER':
                console.log("LIST_FROM_EVENT_SETOPERATORTRANSFER",data.operationRoom);
                
                this.dispatchEvent(new RefreshEvent());
                if (data.operationRoom.operatorEmail === this.email){
                    message = {
                        type: 'EVENT_SETOPERATION',
                        data
                    }
                    this.handleReceviceMessage(message);
                }

                // this.updateOwnerIdWithOutOpenCase(data.operationRoom.id)
                break;                                 
            case 'LIST_FROM_EVENT_EXPIREDSESSION':
                console.log("LIST_FROM_EVENT_EXPIREDSESSION",data,String(this.matrixUserId));
                if ( String(this.matrixUserId) === String(data.endRoom.operatorId)){

                    // this.iframeWindow.postMessage(JSON.stringify(tempsendData), '*');
                    message = {
                        type: 'EVENT_EXPIREDSESSION',
                        data
                    }
                    this.handleReceviceMessage(message);
                }


                break;     
            case 'LIST_FROM_PROVIDE_ALLMESSAGE':
                console.log("LIST_FROM_PROVIDE_ALLMESSAGE", JSON.stringify(data,undefined,2));

                this.saveChatMessage(data);
                // setTimeout(() => this.openCase(data.roomId),500);
                break;
            case 'LIST_FROM_PROVIDE_ALLMESSAGE_FOR_CUSTOMER':
    
                  break;                      
            default:
            //   console.log("TYPE is not entered!");
              break;
        }
    }

    async handleReceviceMessage(message) {
        // Get the labels of selected checkboxes

        const receiveMessageEvent = new CustomEvent("receivemessage", {
          detail: { message },
        });
        // Fire the custom event
        this.dispatchEvent(receiveMessageEvent);
        // console.log('send event')
    }

    async checkMyCase(roomId){
        const findedCase = await findCase({ roomId });

        // console.log(`findedCase ownerId : ${JSON.stringify(findedCase)} userid : ${this.userId}`);

        if (findedCase.OwnerId !== this.userId){
            return false;
        }
        return true;
    }



    async handleCustomerMessage(data) {
        // Get the labels of selected checkboxes
        
        const findedCase = await findCase({ roomId: data.roomId });


        const message = {
            type: 'CUSTOMER_MESSAGE',
            data : {
                caseId: findedCase.Id,
                caseNumber : findedCase.CaseNumber,
            }
        }
        // console.log(`handleCustomerMessage ${JSON.stringify(message)}`);

        const receiveMessageEvent = new CustomEvent("receivemessage", {
          detail: { message },
        });
        // Fire the custom event
        this.dispatchEvent(receiveMessageEvent);
        
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




    async updateOwnerId(roomId) {
       
    
        const findedCase = await findCase({ roomId });
        // console.log("updateOwnerId findedCase  = ", findedCase);
        // const userInfo = await getUserInfo();

        // console.log("userinfo", JSON.stringify(userInfo));
    

        const matrixChatToUpdate = {
            Id: findedCase.Id,
            OwnerId: this.userId // Replace with your data
        };
    
        // console.log("matrixChatToUpdate Object:", JSON.stringify(matrixChatToUpdate));

        await updateOwnerId({ matrixChatToUpdate })


  //      this.openMatrixChat(matrixChat.Id);
        this[NavigationMixin.Navigate]({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: findedCase.Id,
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    }
 
    async updateOwnerIdWithOutOpenCase(roomId) {
       
    
        const findedCase = await findCase({ roomId });
        // console.log("updateOwnerIdWithOutOpenCase findedCase  = ", findedCase);
        // const userInfo = await getUserInfo();

        // console.log("userinfo", JSON.stringify(userInfo));
    

        const matrixChatToUpdate = {
          Id: findedCase.Id,
          OwnerId: this.userId // Replace with your data
        };
    
        // console.log("matrixChatToUpdate Object:", JSON.stringify(matrixChatToUpdate));

        await updateOwnerId({ matrixChatToUpdate })


    } 

    async openCase(roomId){
        const findedCase = await findCase({ roomId });
        // console.log("findedCase  = ", findedCase);

        const message = {
            type: 'LIST_CLOSE',
            data: {}
        }
        this.handleReceviceMessage(message);
        const sendData = {
            type:'LIST_TO_PROVIDE_CHANGED_ROOM_ID',
            data:{
                // email: login.email,
                caseId: findedCase.id,
                roomId: roomId,
            }
        }
        this.sendMessageToIframe((JSON.stringify(sendData)));
        // this.iframeWindow.postMessage(JSON.stringify(sendData), '*');
    
        this[NavigationMixin.Navigate]({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: findedCase.Id,
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                }
            }
        });
    }

    async saveChatMessage(data) {
       
        try {
            const detail = data.messages.join('\n');
            const findedCase = await findCase({ roomId: data.roomId });
    
    
    
            const matrixChatToUpdate = {
              Id: findedCase.Id,
              MatrixChat_Contents__c: detail, // Replace with your data
            };
        
            // console.log("saveChatMessage Object:", JSON.stringify(matrixChatToUpdate));
    
            // await saveMessage({ caseId: findedCase.Id, messages: data.messages });
    
            // await saveMessage({ caseId: findedCase.Id, messages: data.messages });
    
            // this.showToast(
            //     "Success!!",
            //     "상담이력 저장됨!!",
            //     "success",
            //     "dismissable"
            // );
            // this.dispatchEvent(new RefreshEvent());
            saveMessage({ caseId: findedCase.Id, messages: data.messages })
            .then((result) => {
              // Handle successful update
            //   console.log("saveChatMessage Object:", result);
            //   this.showToast(
            //     "Success!!",
            //     "상담이력 저장됨!!",
            //     "success",
            //     "dismissable"
            //   );
              this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
              // Handle update error
              console.error("Error updating saveChatMessage:", JSON.stringify(error));
            });
        }catch(error){
            console.log("Error in saveChatMessage:", JSON.stringify(error));
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