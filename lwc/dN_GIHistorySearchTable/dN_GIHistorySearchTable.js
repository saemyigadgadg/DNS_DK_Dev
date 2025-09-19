import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
 
//Apex 
import getDataList from '@salesforce/apex/DN_DealerPortalDisplayController.getDataList';

export default class DN_GIHistorySearchTable extends LightningElement {
   
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;

    @api uuid;
    dataList =[];
    strQuery ='';
    where = [];
    

    connectedCallback() {
       
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }

        
    }
    /**
     * publish 
     * 
     */
    messagePublish(eventType,msg) {
        let messagePush = {
            uuid : this.uuid,
            type : eventType,
            message : msg,
            cmpName : 'dataTable'
        }
        publish(this.messageContext, DealerPortalLMC, messagePush);
    }

    /**
     * set subscription
     */
    setSubscriptionLMC(){
        this.subscription = subscribe(this.messageContext, DealerPortalLMC, (msg) => {
            if(msg.uuid == this.uuid) {
                // 이벤트를 발생시키는 컴포넌트로 1차 분기처리
                switch (msg.cmpName) {
                    case 'dN_DealerPortalFilter':
                        if(msg.type =='filterChange') {
                            this.setFilterChange(msg.message);
                        }
                        break;
                    case 'dN_DealerPortalButton':
                        if(msg.type =='Seach') {
                            this.getData();
                        }
                        break;
                        //page Change
                    case 'dN_DealerPortalPage':
                        this.dataList = msg.message;
                        break;    

                    default:
                        break;
                }
            }
        });
    }
    

    //데이터 테이블 데이터 조회
    getData() {
        this.setQuery();
        //console.log(this.strQuery,' < ==this.strQuery');
        getDataList({
            query : this.strQuery
        }).then( result => {
            this.dataList = result;
            //this.dataList
            let mas = {
                'dataList' : this.dataList
            };
            this.messagePublish('dataListSearch',mas);
        }).catch(error => {
            console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
        });
    }

    // toast메세지
    showToast(title,message,variant) { //success, warning, 및 error.
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // 필터 체인지 설정
    setFilterChange(message) {
        const isCheck = this.where.some(item => item.field === message.field);
        if(isCheck) {
            if(message.value.trim().length > 0) {
                this.where.forEach(element => {
                    if(element.field == message.field) {
                        element.value = message.value;
                    }
                });
            } else {
                // 해당필터에 값이 없는 경우 제거
                this.where.forEach(element => {
                    console.log(element.field,' <element.field');
                    console.log(message.field,' <=message.field');
                    if(element.field == message.field) {
                        delete element.field;
                        delete element.value;
                        delete element.fieldType;
                    }
                });
                this.where = this.where.filter(item => Object.keys(item).length > 0);
            }
        } else {
            this.where.push(
                {
                    'field' : message.field,
                    'value' : message.value,
                    'fieldType' : message.fieldType
                }
            );
        }
        console.log(JSON.stringify(this.where),' < ===this.where'); 
    }
    

    // 쿼리 재설정
    setQuery() {
        // this.strQuery ='';
        // this.strQuery += 'select  Id, ERPCustomerCode__c,Name,FM_Address__c,Representative__c,Phone__c,PartsManager__r.Name ';
        // this.strQuery += ', PartsManager__c,FM_PartsManagerPhone__c,FM_CreatedDate__c,FM_PartsManagerName__c from DealerCustomer__c where Id !=null '; //limit 50000
        // //console.log(this.where.length, ' < ==this.where.length');
        // if(this.where.length > 0) {
        //     this.where.forEach(element => {
        //         switch (element.field) {
        //             case 'ERPCustomerCode__c':
        //                 this.strQuery += ` AND ERPCustomerCode__c LIKE '%${element.value}%'`;
        //                 break;
        //             case 'Name':
        //                 this.strQuery += ` AND Name LIKE '%${element.value}%'`;
        //                 break;
        //             case 'FM_CreatedDate__cStart':
        //                 this.strQuery += ` AND CreatedDate >=${element.value}T00:00:00.000+09:00`;
        //                 break;
        //             case 'FM_CreatedDate__cEnd':
        //                 this.strQuery += ` AND CreatedDate <=${element.value}T00:00:00.000+09:00`;
        //                 break;    
        //             case 'IsActive__c':
        //                 this.strQuery += ` AND IsActive__c =${element.value}`;
        //                 break;
        //             case 'Representative__c':
        //                 this.strQuery += ` AND Representative__c LIKE '%${element.value}%'`;
        //                 break;
        //             case 'Phone__c':
        //                 this.strQuery += ` AND Phone__c LIKE '%${element.value}%'`;
        //                 break;
        //         }
        //     });
        // }
        
    }
}