/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-10-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-10-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
//Apex 
import getDataList from '@salesforce/apex/DN_CreateAnotherAgencyPurchase.getDealerPurchaseOrderList';

export default class DN_DealApprovalManagementTable extends NavigationMixin(LightningElement) {
    searchParams = {};
    isLoading = false;
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;
    // 클래스에서 페이징 처리
    lastRecordId ='';
    recordList =[];
    // 공통 컴포넌트에서 페이지 관련 필드 상속받아옴
    @api itemsPerPage;
    @api currentPage;
    @api pagesPerGroup;
    @api orderByField;
    @api orderBy;
    nextPage =1;
    
    @api uuid;
    dataList=[];

    strQuery ='';
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
                // button 컴포넌트의 이벤트 : 검색,엑셀 등등
                switch (msg.cmpName) {
                    case 'dN_DealerPortalFilter':
                        if(msg.type =='filterChange') {
                            console.log(JSON.stringify(msg.message), ' < ==msg.message');
                            this.setFilterChange(msg.message);
                        } 
                        if(msg.type =='defaultFilter') {
                            console.log(JSON.stringify(msg.message), '    :::::::defaultFilter');
                            this.setFilterChange(msg.message); 
                        }
                        break;
                    case 'dN_DealerPortalButton':
                        if(msg.type =='Seach') {
                            console.log('serach11');
                            // console.log(JSON.stringify(this.searchParams));
                            this.getData();
                        }
                        break;
                    case 'dN_DealerPortalQueryPage':
                        //console.log(JSON.stringify(msg), ' msg');
                        this.nextPage = msg.message.nextpage;
                        this.currentPage = msg.message.currentPage;
                        // this.getData('PageChange');
                        break;  
                }
            }
        });
    }

    setFilterChange(message) {
        this.searchParams[message.field] = message.value;
    }

    getSearchParams() {
        let searchParams = {};
        Object.keys(this.searchParams).forEach(key=>{
            if(key === 'CustomerName__c') {
                searchParams['dealerId'] = this.searchParams[key];
            }else {
                searchParams[key] = this.searchParams[key];
            }
        });
        return searchParams;
    }

    //데이터 테이블 데이터 조회
    getData() {
        this.isLoading = true;
        getDataList(this.getSearchParams()).then(result=>{
            let { status, dealerPOList, pendingApprovalOrderList} = result;
            console.log(status);
            console.log(dealerPOList);
            if(status.code === 200) {
                //성공
                if(pendingApprovalOrderList.length == 0) {
                    this.showToast('', '조회된 데이터가 없습니다.', 'warning');

                }

                pendingApprovalOrderList.forEach(itemList=>{
                    if(itemList.status == '1') itemList.statusLabel = '생성';
                    else if(itemList.status == '2') itemList.statusLabel = '변경';
                });

                this.dataList = pendingApprovalOrderList;
            }
            this.isLoading = false;
        }).catch(error => {
            console.log(JSON.stringify(error), ' DN_DealApprovalManagementTable error');
            this.showToast('', '조회중에 에러가 발생하였습니다. 관리자에게 문의부탁드립니다.', 'error');
            this.isLoading = false;
        });

        // let searchParams = this.getSearchParams();
        // this.currentPage = type =='Search'? 1 : this.currentPage
        // this.nextPage = type =='Search'? 1 : this.nextPage
        // // 페이징 처리 데이터
        // let page = {
        //     itemsPerPage : this.itemsPerPage,
        //     currentPage : this.currentPage,
        //     pagesPerGroup : this.pagesPerGroup,
        //     orderByField : this.orderByField,
        //     orderBy : this.orderBy
        // }
        // let nextPage = this.nextPage;

        // console.log(`getData this.searchParams : ${JSON.stringify(searchParams)}`);
        // getDataList({...searchParams, page, nextPage}).then( result => {
        //     let { status, orderSummaryList, recordListSet, page } = result;
        //     console.log('recordListSet : '+ JSON.stringify(recordListSet));
        //     console.log('page : '+ JSON.stringify(page));
        //     if(status.code === 200) {
        //         //성공
        //         this.dataList = recordListSet;
        //     }

        //     if(status.code === 400) {
        //         this.dataList = [];
        //         console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
        //     }

        //     this.exceldata = this.dataList; // 추후 전체데이터 쿼리도 필요할 수 있음
        //     let mas = {
        //         'currentPage' : page.currentPage,
        //         'itemsPerPage' : page.itemsPerPage,
        //         'pagesPerGroup' : page.pagesPerGroup,
        //         'currentRecordSize' : this.dataList.length,
        //         'totalRecordSize' : page.totalRecordSize,
        //         'startIdx' : page.startIdx,
        //         'endIdx' : page.endIdx,
        //         'totalPage' : Math.ceil(page.totalRecordSize / page.itemsPerPage),
        //         'eventType' : type
        //     };
        //     this.messagePublish('dataListSearch',mas);
            
        //     if(status.code === 500) console.log(JSON.stringify(error), '관리자 한테 문의하세요.');
        // }).catch(error => {
        //     console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
        // });
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

    navigateToDetail(event) {
        console.log('navigateToDetail :: ');
        let rowIndex = event.currentTarget.getAttribute('accesskey');
        let orderId = this.dataList[rowIndex].id;
        let dealerOrder = this.dataList[rowIndex].customerOrderSeq;
        // this[NavigationMixin.Navigate]({
        //     "type": "standard__recordPage",
        //     "attributes": {
        //         "recordId": orderId,
        //         "objectApiName": "DealerOrder__c",
        //         "actionName": "view"
        //     }
        // });
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'DealerPurchaseOrderManagement__c'
            },
            state : {
                c__pendingApprovalOrderId : orderId,
                c__dealerOrder: dealerOrder
            }
        });
     
        
        
    }

}