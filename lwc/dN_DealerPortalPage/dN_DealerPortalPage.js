import { LightningElement, api,track,wire } from 'lwc';
// LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
export default class DN_DealerPortalPage extends LightningElement {
    // 상위 컴포넌트에서 상속받아오는 목록
    @api itemsPerPage; // 한 페이지당 표시할 데이터 수
    @api currentPage; // 현재 페이지
    @api pagesPerGroup; // 한 그룹에 표시할 페이지 수
    @api uuid;
    
    recordList =[]; // 전체 데이터 리스트
    totalItems; // 전체 데이터 수
    currentData = []; // 현재 페이지 데이터
    pageNumbers = []; // 현재 표시할 페이지 번호
    totalPages = 0; // 전체 페이지 수
    @track currentPageGroup = 1; // 현재 페이지 그룹
    isInit = false;

    get _isDisable() {
        return this.totalItems > 0 ? false : true;
    }
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
    messagePublish(eventType,msg,cmpName) {
      let messagePush = {
          uuid : this.uuid,
          type : eventType,
          message : msg,
          cmpName : cmpName
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
                    this.recordList = msg.message.dataList;
                    this.updatePagination(); // 페이지 설정
                    //this.setPageButtonSetting(); // 페이지 버튼 제어
                    //console.log(this.recordList,'<==this.recordList');
                }
            }     
        });
    }
    // 커넥티드 콜백
    connectedCallback() {
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }
        
    }
   

    
    
    renderedCallback() {
        if (!this.isInit) {
            // connectedCallback으로 할 경우 랜더링 문제로 인해 renderedCallback으로 변경
            this.updatePagination();
            //this.setPageButtonSetting();
            this.isInit = true;
        }
    }
    
    // 페이지 버튼 제어 : 처음 페이지그룹인 경우 < 제거 , 마지막 페이지그룹인 경우 > 제거 
    setPageButtonSetting() {
        const maxPageGroup = Math.ceil(this.totalPages / this.pagesPerGroup);
        if(this.currentPageGroup == maxPageGroup) {
            this.template.querySelector('[data-id="next"]').style.display = 'none';
        } else {
            if(this.totalItems > 0) {
                this.template.querySelector('[data-id="next"]').style.display = '';
            } else {
                this.template.querySelector('[data-id="next"]').style.display = 'none';
            }
            
            // 처음페이지 인경우
            if(this.currentPageGroup ==1){
                this.template.querySelector('[data-id="prev"]').style.display = 'none';
            } else {
                this.template.querySelector('[data-id="prev"]').style.display = '';
            }
            //console.log(this.currentPageGroup,' < ==this.currentPageGroup');
        }
    }

    // 페이지 목록 설정, pageNum === this.currentPage 비교해 현재 페이지인 경우 here로 표시
    updatePagination() {
        this.totalItems = this.recordList.length; //총 데이터 수
        this.totalPages = Math.ceil(this.totalItems / this.itemsPerPage); // 총페이지 수
        const startPage = (this.currentPageGroup - 1) * this.pagesPerGroup + 1;
        const endPage = Math.min(startPage + this.pagesPerGroup - 1, this.totalPages);
        this.pageNumbers = Array.from({ length: endPage - startPage + 1 }, (_, i) => {
            const pageNum = startPage + i;
            return {
                number: pageNum,
                className: pageNum === this.currentPage ? 'here' : 'numbers'
            };
        });
        this.updateCurrentData();
    }

    // 현재 페이지의 데이터를 추출 (slice)
    updateCurrentData() {
        const startIndex = (this.currentPage - 1) * this.itemsPerPage;
        const endIndex = startIndex + this.itemsPerPage;        
        this.currentData = this.recordList.slice(startIndex, endIndex);
        //버튼제어
        this.setPageButtonSetting();
        //message 전송
        this.messagePublish('pageChange',this.currentData,'dN_DealerPortalPage');
    }

    /**
     * 
     * click 이벤트 목록
     */
    // 선택한 페이지로 이동 및 페이지 목록 재설정
    handlePageClick(event) {
        //버튼제어
        //this.setPageButtonSetting();
        const selectedPage = parseInt(event.target.dataset.page, 10);
        this.currentPage = selectedPage;
        this.updatePagination();
    }

    // 이전 페이지 그룹으로 이동
    handlePrevPage() {
        //버튼제어
        //this.setPageButtonSetting();
        // 현재 페이지 그룹이 첫번째 그룹보다 큰 경우
        if (this.currentPageGroup > 1) {
            this.currentPageGroup -= 1; // 이전그롭으로 설정
            this.currentPage = (this.currentPageGroup - 1) * this.pagesPerGroup + 1; // 현재 페이지 그룹의 첫번째 페이지로 설정
            this.updatePagination();
        }
    }

    // 다음 페이지 그룹으로 이동
    handleNextPage() {
        const maxPageGroup = Math.ceil(this.totalPages / this.pagesPerGroup); // 최대 페이지 그룹 수 
        // 현재 페이지 그룹이 최대 페이지 그룹보다 작은 경우
        if (this.currentPageGroup < maxPageGroup) {
            this.currentPageGroup += 1; // 다음 그룹으로 이동
            this.currentPage = (this.currentPageGroup - 1) * this.pagesPerGroup + 1; // 현재 페이지 그룹의 첫번째 페이지로 설정
            this.updatePagination();
        } 
    }

    // 추후 필요한 경우 활성화
    // // 맨처음 페이지로 이동 1페이지
    // handleFirstPage() {
    //     this.currentPage = 1;
    //     this.currentPageGroup = 1;
    //     this.updatePagination();
    // }

    // // 제일 마지막 페이지로 이동
    // handleLastPage() {
    //     this.currentPage = this.totalPages;
    //     this.currentPageGroup = Math.ceil(this.totalPages / this.pagesPerGroup);
    //     this.updatePagination();
    // }

    // // 이전 페이지로 이동
    // handlePrevPage() {
    //     if (this.currentPage > 1) {
    //         this.currentPage -= 1;
    //         if (this.currentPage < (this.currentPageGroup - 1) * this.pagesPerGroup + 1) {
    //             this.currentPageGroup -= 1;
    //         }
    //         this.updatePagination();
    //     }
    // }

    // // 다음 페이지로 이동
    // handleNextPage() {
    //     if (this.currentPage < this.totalPages) {
    //         this.currentPage += 1;
    //         if (this.currentPage > this.currentPageGroup * this.pagesPerGroup) {
    //             this.currentPageGroup += 1;
    //         }
    //         this.updatePagination();
    //     }
    // }
}