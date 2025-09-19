import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
//Apex 
import getDataList from '@salesforce/apex/DN_DealerPortalDisplayController.getDataList';
import getCustomerList from '@salesforce/apex/DN_DealerPortalDisplayController.getCustomerList';

export default class DN_CustomerManagementTable extends NavigationMixin(LightningElement)  {
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;

    @api uuid;
    @api currentUserInfo;
    dataList =[];
    exceldata = [];
    strQuery ='';
    where = [];
    customerName ='';
    isSpinner = false;

    connectedCallback() {
        // console.log(`currentUserInfo : `+ JSON.stringify(this.currentUserInfo));
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
                console.log(JSON.stringify(msg) + ' ::: msg');
                switch (msg.cmpName) {
                    case 'dN_DealerPortalFilter':
                        if(msg.type =='filterChange') {
                            console.log(' 견적서 필터 변경');
                            this.setFilterChange(msg.message);
                        } 
                        if(msg.type =='defaultFilter') {
                            this.setFilterChange(msg.message); 
                        }
                        break;
                    case 'dN_DealerPortalButton':
                        if(msg.type =='Seach') {
                            this.isSpinner =true;
                            this.getData();

                        }
                        if(msg.type =='ExcelDownload'){
                            this.handleExcelDownload();
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
        console.log(this.strQuery,' < ==this.strQuery');
        getDataList({
            query : this.strQuery
        }).then( result => {
            this.dataList = result;
            this.exceldata = result;
            //this.dataList
            let mas = {
                'dataList' : this.dataList
            };
            this.messagePublish('dataListSearch',mas);
            this.isSpinner = false;
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
    async setFilterChange(message) {
        if(message.field=='CustomerName__c') {
            await this.handleCustomerName(message.value);
        }
        console.log(message, ' ::: message');
        let isCheck = false;
        if(message.length >1) {
            for(let i=0; i<message.length; i++) {
                let ele = message[i];
                isCheck = this.where.some(item => item.field === ele.field);
                if(isCheck) {
                    break;
                }
            }
        } else {
            isCheck = this.where.some(item => item.field === message.field);
        }
        console.log(isCheck,' ::: isCheck');
        if(isCheck) {
            if(message.length >1) {
                message.forEach(ele => {
                    if(ele.value.trim().length > 0) {
                        this.where.forEach(element => {
                            if(element.field == ele.field) {
                                element.value = ele.value;
                            }
                        });
                    } else {
                        // 해당필터에 값이 없는 경우 제거
                        this.where.forEach(element => {
                            if(element.field == ele.field) {
                                delete element.field;
                                delete element.value;
                                delete element.fieldType;
                            }
                        });
                        this.where = this.where.filter(item => Object.keys(item).length > 0);
                    }
                });
            } else {
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
            }
            
        } else {
            if(message.length >1) {
                message.forEach(element => {
                    this.where.push(
                        {
                            'field' : element.field,
                            'value' : element.value,
                        }
                    );
                });
            } else {
                this.where.push(
                    {
                        'field' : message.field,
                        'value' : message.value,
                        'fieldType' : message.fieldType
                    }
                );
            }
           
        }
       
        console.log(JSON.stringify(this.where),' < ===this.where'); 
    }
    // handleDetal
    handleDetail(event) {
        console.log(event.target.dataset.id,' < ===event.target.dataset.id');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: `${event.target.dataset.id}`,
                actionName: 'view',
            },
        })
    }

    // 쿼리 재설정
    setQuery() {
        console.log(JSON.stringify(this.where), ' ::: this.where');
        this.strQuery ='';
        this.strQuery += ' select FM_QuoteNumbermber__c,FM_CustomerName__c,FM_PublishDate__c,Name,Description__c,MachineName__c,Equipment__c,FM_DealerName__c from DealerQuote__c ';
        this.strQuery += ` where Id !=null AND Status__c NOT IN ('D','C') `;
        if(this.currentUserInfo.accountId) this.strQuery += ` AND Dealer__c = '${this.currentUserInfo.accountId}' `;
        
        if(this.where.length > 0) {
            this.where.forEach(element => {
                switch (element.field) {
                    case 'SerialNumber':
                        this.strQuery += ` AND Equipment__c ='${element.value}'`;
                        break;
                    case 'Type':
                        this.strQuery += ` AND MachineName__c ='${element.value}'`;
                        break;
                    case 'Name':
                        this.strQuery += ` AND Name ='${element.value}'`;
                        break;
                    case 'CustomerName__c':
                        if(element.value == '9999999999') {
                            this.strQuery += ` AND CustomerCode__c LIKE '%${element.value}%'`;    
                        } else {
                            this.strQuery += ` AND Customer__c ='${element.value}'`;
                        }
                        

                        break;    
                    case 'FM_PublishDate__cStart':
                        this.strQuery += ` AND CreatedDate >=${element.value}T00:00:00.000+09:00`;
                        break;
                    case 'FM_PublishDate__cEnd':
                        this.strQuery += ` AND CreatedDate <=${element.value}T23:59:59.000+09:00`;
                        break;    
                }
            });
        }
    }

    // 고객사ID로 고객사명 가져오기
    async handleCustomerName(customerName) {
        await getCustomerList({
            customIds : customerName
        }).then( result => {
            for(let i=0; i<result.length; i++) {
                let data = result[i];
                this.customerName = data.Name;
            }
        }).catch(error => {
            console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
        });
    }

}