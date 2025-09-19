import { LightningElement, api,track,wire } from 'lwc';
// LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
export default class DN_DealerPortalPage extends LightningElement {
    @api uuid;
    isSpinner = false;
    _isDisable = true;
    currentPage =0; //현재페이지
    itemsPerPage; // 현제 페이지당 보여줄 레코드 수
    pagesPerGroup; // 화면에 보여줄 페이지 수
    totalRecordSize =0; // 전체 레코드 수 => 2000건으로 제한
    totalPage=0; // 총페이지수 2000건 제한 기준으로 계산
    startIdx; //시작 인덱스
    endIdx; //마지막 인덱스
    pageNumbers=[{"number":1,"className":"numbers"}] // 화면에 보여줄 페이지 넘버 1,2,3,4,5
    currentPageGroup =1; // 현재 페이지 그룹
    prevPage; // 이전 페이지 넘버
    nextPage // 다음페이지 넘버
    firstPage; // 첫페이지 넘버
    lastPage; // 마지막페이지 넘버
    
    // 전체 데이터 기준으로 페이지 및 레코드 수 게산
    _allPage =0;
    _totalRecordSize =0;

    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    //subscription = null;  
    /**
     * publish 
     * 
     */
    messagePublish(msg) {
      let messagePush = {
          uuid : this.uuid,
          type : 'PageChnage',
          message : msg,
          cmpName : 'dN_DealerPortalQueryPage'
      }
      publish(this.messageContext, DealerPortalLMC, messagePush);
    }
    /**
     * set subscription
     */
    setSubscriptionLMC(){
        this.subscription = subscribe(this.messageContext, DealerPortalLMC, (msg) => {
            if(msg.uuid == this.uuid) {
                if(msg.type =='dataListSearch') {
                    this.isSpinner = true;
                    // 데이터 받아오는거 및 화면 페이지 구성
                    //console.log(JSON.stringify(msg), ' page~~~~~~');
                    
                    this._isDisable=msg.message.totalRecordSize > 0 ? false : true;
                    this.currentPage = msg.message.currentPage;
                    this.itemsPerPage = msg.message.itemsPerPage;
                    this.pagesPerGroup = msg.message.pagesPerGroup;
                    this.totalRecordSize = 2000 < msg.message.totalRecordSize ? 2000: msg.message.totalRecordSize;                                            //msg.message.totalRecordSize;
                    this.totalPage = Math.ceil(this.totalRecordSize / this.itemsPerPage);   //msg.message.totalPage;
                    this.startIdx = msg.message.startIdx;
                    this.endIdx = msg.message.endIdx;
                    
                    // 총 조회 건수 설정
                    this._allPage           = msg.message.totalPage;
                    this._totalRecordSize   = msg.message.totalRecordSize;
                                        
                    if(msg.message.eventType=='Seach') {
                        // 데이터가 없는 경우
                        if(this._totalRecordSize ==0) {
                            this.currentPage =0;
                            this.pageNumbers=[{"number":1,"className":"numbers"}];
                            this.totalPage = 0;
                            this._allPage = 0;
                            this.currentPageGroup=0;
                            this.totalRecordSize = 0;
                            
                            this.isSpinner = false;
                            setTimeout(() => {
                                this.template.querySelector('[data-id="prev"]').style.display = ''; 
                                this.template.querySelector('[data-id="next"]').style.display = '';
                            }, );
                            return;
                        } else {
                            this.currentPageGroup =1;
                        }
                    }
                    this.setPageSetting();
                    //this.setNextWithPrev();
                    //this.updatePagination();     
                }
            }     
        });
    }

    // 페이지 next, prev 버튼 제어
    setPageSetting() {
        
        const startPage = (this.currentPageGroup - 1) * this.pagesPerGroup + 1;
        const endPage = Math.min(startPage + this.pagesPerGroup - 1, this.totalPage);
        this.pageNumbers = Array.from({ length: endPage - startPage + 1 }, (_, i) => {
            const pageNum = startPage + i;
            return {
                number: pageNum,
                className: pageNum === this.currentPage ? 'here' : 'numbers'
            };
        });
        this.setPageDisableSetting();
        
        this.prevPage = startPage -this.pagesPerGroup <0 ? 1 : startPage -this.pagesPerGroup;
        this.nextPage = endPage +1;
        this.firstPage = 1;
        this.lastPage = this.totalPage;
        this.isSpinner = false;
        //console.log(this.prevPage, ' < ==this.prevPage');
        //console.log(this.nextPage, ' < ==this.nextPage');
    }

    setPageDisableSetting() {
        //prev 페이지 숨김
        setTimeout(() => {
            // console.log(this.currentPageGroup,' currentPageGroup:::');
            if(this.currentPageGroup ==1) {
                this.template.querySelector('[data-id="first"]').style.display = 'none';
                this.template.querySelector('[data-id="prev"]').style.display = 'none';
            } else {
                this.template.querySelector('[data-id="first"]').style.display = '';
                this.template.querySelector('[data-id="prev"]').style.display = '';
            }
            // next 페이지 숨김
            if(this.currentPageGroup == Math.ceil(this.totalPage / this.pagesPerGroup)) {
                this.template.querySelector('[data-id="last"]').style.display = 'none';
                this.template.querySelector('[data-id="next"]').style.display = 'none';
            } else {
                this.template.querySelector('[data-id="last"]').style.display = '';
                this.template.querySelector('[data-id="next"]').style.display = '';
            }    
        }, );
    }

    // 커넥티드 콜백
    connectedCallback() {
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }

    }
   
    
    
    renderedCallback() {
        if (!this.isInit) {
            this.isInit = true;
            //window.document.onselectstart= new Function("return false");
        }
    }
    
    /**
     * 
     * click 이벤트 목록
     */
    // 선택한 페이지로 이동 및 페이지 목록 재설정
    handlePageClick(event) {
        if(this.totalRecordSize ==0) {
            return;
        }
        this.isSpinner = true;
        let selectPage = event.target.dataset.page;
        let nextpage =0;
        if(this.currentPage >= selectPage) {
            this.currentPage = selectPage;
            nextpage = selectPage;
        } else {
            nextpage = selectPage;
        }
        this.messagePublish({
            'nextpage' : event.target.dataset.page,
            'currentPage' : this.currentPage,
        })
        
    }   

    // 첫페이지로 이동
    handleFirstPage(event) {
        if(this.totalRecordSize ==0) {
            return;
        }
        this.isSpinner = true;
        this.currentPageGroup = 1;
        // 이벤트 발송
        this.messagePublish({
            'nextpage' : event.target.dataset.page,
            'currentPage' : this.currentPage,
        })
        
    }

    // 이전 페이지 그룹으로 이동
    handlePrevPage(event) {
        if(this.totalRecordSize ==0) {
            return;
        }
        this.isSpinner = true;
        this.currentPageGroup = this.currentPageGroup -1;
        // 이벤트 발송
        this.messagePublish({
            'nextpage' : event.target.dataset.page,
            'currentPage' : this.currentPage,
        })
        
    }

    // 다음 페이지 그룹으로 이동
    handleNextPage(event) {
        if(this.totalRecordSize ==0) {
            return;
        }
        this.isSpinner = true;
        this.currentPageGroup = this.currentPageGroup +1;
        this.messagePublish({
            'nextpage' : event.target.dataset.page,
            'currentPage' : this.currentPage,
        })
    }

    // 마지막 페이지로 이동
    handleLastPage(event) {
        if(this.totalRecordSize ==0) {
            return;
        }
        this.isSpinner = true;
        this.currentPageGroup = Math.ceil(this.totalPage / this.pagesPerGroup);
        this.messagePublish({
            'nextpage' : event.target.dataset.page,
            'currentPage' : this.currentPage,
        })
    }
}