import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
// Apex 
import getDataList from '@salesforce/apex/DN_CancelGRTableController.getDataList';
import gRCancel from '@salesforce/apex/DN_CancelGRTableController.gRCancel';


export default class DN_CancelGRTable extends LightningElement {
    @api isSpinner = false;
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;
    @api uuid;
    _SearchOption = {
        gRtype : '',
        dateGRStart : null,
        dateGREnd : null
    }
    _orderNumber ='';
    set orderNubmer(value) {
        this._orderNumber =  value =='2'? 'DNS 반품 요청번호' : '대리점 입고번호';
    }
    

    //데이터목록
    @track grList =[];
    //입고취소 목록
    @track cancelList =[];
    

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
            cmpName : 'dataTableExcel'
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
                switch (msg.type) {
                    case 'defaultFilter':
                        this.setFilterChange(msg.message);
                        // if(msg.type =='filterChange') {
                        //     this.setFilterChange(msg.message);
                        //     //console.log(JSON.stringify(msg.message), ' < ==msg.message');
                        // } 
                        // if(msg.type =='defaultFilter') {
                        //     //console.log(JSON.stringify(msg), '    :::::::defaultFilter');
                        //     this.setFilterChange(msg.message); 
                        // }
                        break;
                    case 'filterChange':
                        this.setFilterChange(msg.message);
                        break;    
                    case 'Seach':
                        this.cancelList = [];
                        this.handleSearch();
                        break;
                    case 'Save':
                        this.handleCancel();
                        break;
                    default:
                        break;
                }
            }
        });
    }

    // 입고문서 검색
    handleSearch() {
        this.isSpinner = true;
        console.log('this._SearchOption ==',JSON.stringify(this._SearchOption));
        getDataList({
            search : this._SearchOption
        }).then( result => {
           console.log(' reslut === ',JSON.stringify(result));
           

           this.grList = JSON.parse(JSON.stringify(result));
            if(this.grList.length == 0) {
                this.showToast('No data','검색 결과가 없습니다.','error');
            } else {
                this.showToast('검색완료','검색이 완료되었습니다.','success');
            }
           this.isSpinner = false;
        }).then( () => {
            console.log('then then');
            const checkList = this.template.querySelectorAll('[data-name="checkbox"]');
            console.log(checkList,' :: checkList');
            //checkList.checked = false;
            // for(let i=0; i<this.grList.length; i++) {
            //     this.template.querySelector(`[data-checked="${i}"]`).checked = false;    
            // }
            checkList.forEach(element => {
                //this.template.querySelector(`[data-checked="${i}"]`).checked = check;
                console.log(element,' ::: element');    
                element.checked = false;
            });
        }).catch(error => {
            this.isSpinner = false;
            console.log(JSON.stringify(error), '  get DataQuery  error');
        })
    }
    // 입고 취소
    // DESC : 두비즈에서는 현재고 기준으로 취소수량을 입력할 수 있으나
    // CRM에서는 취소가능 수량 기준으로 취소수량을 입력하는 벨리데이션으로 설정함
    handleCancel() {
        console.log(this.cancelList.length,' < ==111');
        let valcheck = false;
        let title='선택 확인';
        let msg = '취소할 항목을 선택해주세요.';
        if(this.cancelList.length == 0) {
            valcheck = true;
        } else {
            valcheck = this.cancelList.some((element) => {
                console.log(JSON.stringify(element),' < ==element');
                if(parseInt(element.cancelGRQty) <=0) {
                    title = '취소 수량 확인';
                    msg = '입고 취소 수량을 확인해주세요.';
                    return true;
                }
                if(element.cancelAvailableGRQty <=0) {
                    title = '취소 가능 수량 확인';
                    msg = '입고 취소 가능 수량을 확인해주세요.';
                    return true;
                }
                if(element.stockQty <=0) {
                    title = '재고 부족';
                    msg = `현재고가 부족합니다. ${element.pratNumber}`;
                    return true;
                }
                if(element.cancelAvailableGRQty < element.cancelGRQty) {
                    title = '재고 확인';
                    msg = `${element.pratNumber}의 재고가 부족합니다.`;
                    return true;
                }
                if(element.stockQty < element.cancelGRQty) {
                    title = '재고 확인';
                    msg = `${element.pratNumber}의 재고가 부족합니다.`;
                    return true;
                }
            });
        }
        
        console.log(valcheck,' < ==valcheck');
        //입고 취소 시 벨리데이션
        if(valcheck) {
            this.showToast(title,msg,'error');
            
        } else {
            this.isSpinner = true;
            gRCancel({
                cancelList : this.cancelList,
                type : this._SearchOption.gRtype
            }).then( result => {
               console.log(' reslut === ',JSON.stringify(result));
               let results = JSON.parse(JSON.stringify(result));
               this.cancelList =[];
               this.grList = [];
               let excelData = [];
               let headerData = [{
                                '대리점명': results.agencyName,
                                '참고문서번호' : results.doc,
                                '생성일자': results.createdDate,
                                '생성시각' : results.createdTime
                            }];
                let index =1;
                results.returnGRList.forEach(element => {
                    let location = element.DealerStock__r.DealerLocation__c == undefined ? '' : element.DealerStock__r.DealerLocation__r.FM_Loc__c;
                    console.log(location,' < ==location');
                    let docNumber = '';
                    
                    if(element.PurchaseOrderItem__c !=null) {
                        docNumber =element.PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c;
                    } else { //대리점 입고번호
                        docNumber =element.GoodsReceiptNumber__r.InventoryNumber__c;
                    }
                    console.log(docNumber,' :: docNumber');
                    excelData.push({
                        '순번' : index,
                        '종류':'입고취소',
                        '문서번호' : docNumber,
                        '품번' : element.Part__r.ProductCode || '',
                        '품명' : element.Part__r.FM_MaterialDetails__c || '',
                        '수량' : element.Quantity__c || 0,
                        '재고위치' : location
                    });
                    index ++;
                    console.log(JSON.stringify(excelData),' < ==excelData');
                });
              
               this.messagePublish('ExcelDownload',{
                    'excelData' : excelData,
                    'headerData' : headerData
               }); //eventType,msg
            }).then( () => {
                this.handleSearch();
            }).catch(error => {
                console.log(JSON.stringify(error), '  get DataQuery  error');
                this.isSpinner = false;
            });
        }
        
    }

    // 전체 선택
    handleAll(event) {
        let check = event.currentTarget.checked;
        console.log(check,' ::: check');
        for(let i=0; i<this.grList.length; i++) {
            this.template.querySelector(`[data-checked="${i}"]`).checked = check;    
        }
        if(check) {
            this.cancelList = this.grList;
        } else {
            this.cancelList = [];
        }
    }

    //체크박스 선택
    handleCheckboxChange(event) {
        let index = event.currentTarget.dataset.index;
        let check = event.currentTarget.checked;
        let rowData = this.grList[index];
        console.log(check);
        if(check) {
            this.cancelList.push(rowData);
        } else {
            this.cancelList = this.cancelList.filter(item => item !== rowData);
        }
        console.log(JSON.stringify(this.cancelList),' < ==this.cancelList');
    }
    // 취소요청수량 수정
    handleChangeValue(event) {
        let index = event.currentTarget.dataset.qty;
        let value = event.currentTarget.value;
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        this.grList[index].cancelGRQty = value;
        
        let element = this.template.querySelector(`[data-qty="${index}"]`);
        console.log(element,' :: element');
        element.value = value; // 화면 상 값 변경
        console.log(element[index].value +' :: element[index].value');
        
        
    }

    // 필터정보 변경
    setFilterChange(message) {
        console.log(JSON.stringify(message), ' testet');
        if(message.value) { //partId
            if(message.field == 'productCode') {
                this._SearchOption[message.field] = message.label;
                this._SearchOption['partId'] = message.value;
            } else {
                this._SearchOption[message.field] = message.value;
            }
        } else {
            if(message.field == 'productCode') {
                delete this._SearchOption[message.field];
                delete this._SearchOption['partId'];
            } else {
                delete this._SearchOption[message.field];
            }
        }
        if(message.field == 'gRtype') {
            this.orderNubmer = message.value;
        }
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
}