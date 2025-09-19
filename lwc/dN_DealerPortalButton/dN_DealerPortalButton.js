/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-05-2024   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
// import userId from '@salesforce/user/Id';
export default class DN_DealerPotalButton extends NavigationMixin(LightningElement) {
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    isBTN = false;
    // deafult value 유무
    isDefaultValue = false;
    defaultMsgList = []; //this.messagePublish('ButtonPickList',msg,'dN_DealerPortalButton');
    /**
     * publish 
     * 
     */
    messagePublish(eventType,msg,cmpName) {
      let messagePush = {
          uuid : this.uuid,
          type : eventType,
          message : msg,
          cmpName : cmpName
      }
      //console.log(JSON.stringify(messagePush), ' BUTTON MESSAGE');
      publish(this.messageContext, DealerPortalLMC, messagePush);
    }
    

    // 커넥티드 콜백
    connectedCallback() {
      // if(!this.subscription) {
      //   this.setSubscriptionLMC();        
      // }
    }

    // wire보다 get/set이 먼저 실행되므로 순서차이로 인해 랜더링콜백에서 디폴트 벨류 설정
    renderedCallback() {
      if(this.isDefaultValue) {
        this.defaultMsgList.forEach(element => {
          this.messagePublish('ButtonPickList',element,'dN_DealerPortalButton');
        });
        this.isDefaultValue = false;
      }
    }

    @api objectName;
    @api uuid;
    _displayButtonMdtList =[];
    
    // 버튼 목록 get set
    @api
    get displayButtonMdtList() {
      return this._displayButtonMdtList;
    }
    set displayButtonMdtList(value) {
      this._displayButtonMdtList = value;
      let defaultButtonSetting = JSON.parse(JSON.stringify(this._displayButtonMdtList));
      defaultButtonSetting.forEach(element => {
          //button Type이 PickList인 경우 디폴트 값 설정
          if(element.buttonType == 'PickList') {
            //console.log(element.buttonType, ' < ==element.buttonType');
            let msg = {
              'field' : element.buttonIcon,
              'value' :  element.modalComponent,
              'fieldType' : 'Text'
            }
            this.defaultMsgList.push(msg);
          }
      });
      this.isDefaultValue = true;
    }

    // 클릭 이벤트 발생 -검색,액셀 등등 상단 버튼 기능이벤트
    handleClick(event) {
      if(this.isBTN) {
        return;
      }
      //console.log(' BUTTON 중복');
      this.isBTN = true;
      let param = event.target.dataset.param ==undefined ? '' : event.target.dataset.param;
      ////console.log('Button CMP Click Event',event.target.dataset.id);
      ////console.log(param,' < ==param');
      if(event.target.dataset.id =='StandardNew') {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: `${param}`,
                actionName: 'new',
            },
        })
      } else {
        
        let modal = event.target.dataset.modal;
        let param =event.target.dataset.param == undefined ? '' : event.target.dataset.param;
        let msg = {
          'modalName' : modal,
          'param' :  param
        }
        let type = event.target.dataset.id;
        if(event.target.dataset.id =='Seach' ||event.target.dataset.id =='Save') {
          type= event.target.dataset.id + 'Filter';
        }
        //console.log(JSON.stringify(type),' TYPE :::');
        //console.log(JSON.stringify(msg),' msg :::');
        this.messagePublish(type,msg,'dN_DealerPortalButton');
      }

      setTimeout(() => {
        this.isBTN = false;
      }, 3000);
    }

    // 버튼이 선택인 경우
    handleChange(event) {
       //console.log('event111');
       let msg = {
         'field' : event.target.dataset.id,
         'value' :  event.target.value,
         'fieldType' : 'Text'
       }
       this.messagePublish('ButtonPickList',msg,'dN_DealerPortalButton');
    }
    
}