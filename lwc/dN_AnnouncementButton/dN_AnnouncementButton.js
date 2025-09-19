/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-01-31
 * @last modified by  : suheon.ha@sobetec.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-23   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { showToast, style, label } from 'c/commonUtils';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getBoard from '@salesforce/apex/DN_AnnouncementController.getBoard';
import getBoards from '@salesforce/apex/DN_AnnouncementController.getBoards';
import createQnA from '@salesforce/apex/DN_AnnouncementController.createQnA';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class DN_AnnouncementButton extends NavigationMixin(LightningElement) {
    @track announcementList = [];
    @track qnaList = [];
    @track activeTab = 'announcement';
    @track activeTab = 'qna';
    // @track selectedAnnouncement = {};
    // @track selectedQnA = {};
    // @track selectedFiles = [];
    @track isMainView = true;
    @track isDetailView = false;
    @track isQnaDetailView = false;
    @track isCreateView = false;
    // flowApiName = 'CS_Create_Q_A';
    // isFlowVisible = false;
    // @track editObject = {};
    @track newName = ''; // Q&A Name
    @track newPostingDate = ''; // Posting Date
    @track newQuestion = ''; // Question content
    @track isLoading = false;

    // @track sortBy = 'date';
    @track sortDirection = 'desc';
    cLabel = label;

    get sortOptions() {
        return [
            { label: '제목', value: 'name' },
            { label: '날짜', value: 'date' }
        ];
    }

    connectedCallback() {
        this.isLoading = true;
        this.retrievedAnnouncements('announceDate');
        // 날짜를 yyyy-MM-dd변환
        const today = new Date();
        this.newPostingDate = today.toISOString().split('T')[0];
    }

    async retrievedAnnouncements(sortBy) {
        try {
            // const sortBy = 'announceName';
            // const isAnnouncement = true;
            const data = await getBoards({ sortBy : sortBy });
            console.log('Data retrieved:', data);


            // 데이터를 분리하여 공지사항과 Q&A 리스트 구성
            this.announcementList = data.filter(board => board.recordType === '공지사항').map(board => ({
                id: board.Id,
                title: board.Name,
                user: board.OwnerName,
                date: new Date(board.CreatedDate).toLocaleDateString(),
                content: board.Contents,
                files: board.Files.map(file => ({
                    title: file.Title,
                    downloadLink: file.DownloadLink
                }))
            }));

            this.qnaList = data.filter(board => board.recordType === 'Q & A').map(board => ({
                id: board.Id,
                title: board.Name,
                user: board.OwnerName,
                date: new Date(board.CreatedDate).toLocaleDateString(),
                dateOfReply: new Date(board.CreatedDate).toLocaleDateString(),
                content: board.Contents,
                answerContent: board.AnswerContent,
                questionContent: board.QuestionContent,
                respondent: board.Respondent,
                // files: board.Files
                files: board.Files.map(file => ({
                    title: file.Title,
                    downloadLink: file.DownloadLink
                }))
            }));

            this.isLoading = false;

            console.log('Announcement List:', this.announcementList);
            console.log('Q & A List:', this.qnaList);
        } catch (error) {
            console.error('Error retrieving announcements:', error);
        }
    }

    // async getBoards() {
    //     try {
            
    //         const data = await getBoard();
    //         console.log('Data retrieved:', data);

    //         // 데이터를 분리하여 공지사항과 Q&A 리스트 구성
    //         this.announcementList = data.filter(board => board.recordType === '공지사항').map(board => ({
    //             id: board.Id,
    //             title: board.Name,
    //             user: board.OwnerName,
    //             date: new Date(board.CreatedDate).toLocaleDateString(),
    //             content: board.Contents,
    //             files: board.Files.map(file => ({
    //                 title: file.Title,
    //                 downloadLink: file.DownloadLink
    //             }))
    //         }));

    //         this.qnaList = data.filter(board => board.recordType === 'Q & A').map(board => ({
    //             id: board.Id,
    //             title: board.Name,
    //             user: board.OwnerName,
    //             date: new Date(board.CreatedDate).toLocaleDateString(),
    //             dateOfReply: new Date(board.CreatedDate).toLocaleDateString(),
    //             content: board.Contents,
    //             answerContent: board.AnswerContent,
    //             questionContent: board.QuestionContent,
    //             respondent: board.Respondent,
    //             // files: board.Files
    //             files: board.Files.map(file => ({
    //                 title: file.Title,
    //                 downloadLink: file.DownloadLink
    //             }))
    //         }));

    //         this.isLoading = false;

    //         console.log('Announcement List:', this.announcementList);
    //         console.log('Q & A List:', this.qnaList);
    //     } catch (error) {
    //         console.error('Error retrieving announcements:', error);
    //     }
    // }

    handleActive(event) {
        console.log('탭전환');
        this.activeTab = event.target.label;
        if (this.activeTab == label.DNS_FSL_Announcement) {
            this.isCreateView = false;
            this.isQnaDetailView = false;
            this.isDetailView = false;
            this.isMainView = true;
            this.newName = null;
            this.newQuestion = null;
            this.newPostingDate = null;
            
        }
        if (this.activeTab == 'Q & A') {
            this.isCreateView = false;
            this.isQnaDetailView = false;
            this.isDetailView = false;
            this.isMainView = true;
            this.newName = null;
            this.newQuestion = null;
            this.newPostingDate = null;
            
        }
        console.log('this.activeTab::'+this.activeTab);

    }

    handleTabChange(event) {
        this.activeTab = event.target.value; // 탭 전환
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            console.log('Flow execution completed.');
            this.isFlowVisible = false;
        } else if (event.detail.status === 'ERROR') {
            console.error('Flow execution error:', event.detail.error);
        }
    }

    handleNewQnA() {
        console.log('플로우~');
        this.isCreateView = true;
        this.isMainView = false;
        
        const today = new Date();
        this.newPostingDate = today.toISOString().split('T')[0];
    }

    handleNew() {
        this.isLoading = true;
        createQnA({
            newName: this.newName,
            newPostingDate: this.newPostingDate, 
            newQuestion: this.newQuestion     
        })
        .then(() => {
            this.isCreateView = false;
            this.isMainView = true;
            // this.handleRefresh(); 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: label.DNS_FSL_QnACreated,
                    variant: 'success'
                }),

                new CloseActionScreenEvent()

            );
            this.connectedCallback()
            
        })
        .catch(error => {
            console.error('Error creating Q&A:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating Q&A',
                    message: label.DNS_FSL_QnACreateFailed,
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
    
    handleNameChange(event) {
        this.newName = event.target.value;
    }

    handlePostingDateChange(event) {
        this.newPostingDate = event.target.value;
    }

    handleQuestionContentChange(event) {
        this.newQuestion = event.target.value;
    }

    
    // JS Sorting
    sortAnnouncements() {
        this.announcementList = [...this.announcementList].sort((a, b) => {
            let fieldA = this.sortBy === 'date' ? new Date(a.date) : a.title.toLowerCase();
            let fieldB = this.sortBy === 'date' ? new Date(b.date) : b.title.toLowerCase();
    
            if (fieldA < fieldB) return this.sortDirection === 'desc' ? 1 : -1;
            if (fieldA > fieldB) return this.sortDirection === 'desc' ? -1 : 1;
            return 0;
        });
    }
    
    sortQnAs() {
        this.qnaList = [...this.qnaList].sort((a, b) => {
            let fieldA = this.sortBy === 'date' ? new Date(a.date) : a.title.toLowerCase();
            let fieldB = this.sortBy === 'date' ? new Date(b.date) : b.title.toLowerCase();
    
            if (fieldA < fieldB) return this.sortDirection === 'desc' ? 1 : -1;
            if (fieldA > fieldB) return this.sortDirection === 'desc' ? -1 : 1;
            return 0;
        });
    }

    
    handleSortAnChange(event) {
        this.sortBy = event.detail.value;
        this.sortDirection = this.sortBy === 'date' ? 'desc' : 'asc';
        this.sortAnnouncements();
    }
    
    handleSortQnAChange(event) {
        this.sortBy = event.detail.value;
        this.sortDirection = this.sortBy === 'date' ? 'desc' : 'asc';
    
        this.sortQnAs();
    }

    // 버튼
    handleAnnounceSortName() {
        this.isLoading = true;
        this.retrievedAnnouncements('announceName');
    }

    handleAnnounceSortDate() {
        this.isLoading = true;

        this.retrievedAnnouncements('announceDate');
    }

    handleQnASortName() {
        this.isLoading = true;

        this.retrievedAnnouncements('qnaName');
    }

    handleQnASortDate() {
        this.isLoading = true;

        this.retrievedAnnouncements('qnaDate');
    }
    // 
    handleSortByName() {
        this.loadBoards('Name', false);
    }

    handleSortByDate() {
        this.loadBoards('CreatedDate', true);
    }

    loadBoards(sortBy, isAnnouncement) {
        let boardMethod = isAnnouncement ? getBoard : getBoards;
        
        boardMethod({ sortBy, isAnnouncement })
            .then(result => {
                this.boardList = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.boardList = undefined;
            });
    }
    // sortByName() {
    //     this.sortBy = 'name';
    //     this.sortDirection = 'desc';
    //     this.sortAnnouncements();
    // }

    // sortByDate() {
    //     this.sortBy = 'date';
    //     this.sortDirection = 'desc';
    //     this.sortAnnouncements();
    // }

    sortAnnouncements() {
        this.announcementList = [...this.announcementList].sort((a, b) => {
            let fieldA = this.sortBy === 'date' ? new Date(a.date) : a.title.toLowerCase();
            let fieldB = this.sortBy === 'date' ? new Date(b.date) : b.title.toLowerCase();
            if (fieldA < fieldB) return 1;
            if (fieldA > fieldB) return -1;
            return 0;
        });
    }

    sortQnAs() {
        this.qnaList = [...this.qnaList].sort((a, b) => {
            let fieldA = this.sortBy === 'date' ? new Date(a.date) : a.title.toLowerCase();
            let fieldB = this.sortBy === 'date' ? new Date(b.date) : b.title.toLowerCase();
            if (fieldA < fieldB) return 1;
            if (fieldA > fieldB) return -1;
            return 0;
        });
    }
    

    renderedCallback() {
        this.adjustStyles();
    }

    navigateToViewBoardPage(recId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: 'Board__c',
                actionName: 'view'
            },
        });
    }

    handleAnnouncementClick(event) {
        console.log('handleAnnouncementClick');
        // const announcementId = event.currentTarget.dataset.id;
        // this.navigateToViewBoardPage(announcementId);
        
        const announcementId = event.currentTarget.dataset.id;
        console.log('Clicked Announcement ID:', announcementId);
        
        this.selectedAnnouncement = this.announcementList.find(announcement => announcement.id === announcementId);
        if (!this.selectedAnnouncement) {
            console.error('Selected announcement not found.');
            return;
        }
        console.log('Selected announcement:', JSON.stringify(this.selectedAnnouncement));
    
        if (this.selectedAnnouncement.files && this.selectedAnnouncement.files.length > 0) {
            this.selectedFiles = this.selectedAnnouncement.files;
            console.log('Files:', this.selectedFiles);
        } else {
            console.log('No files available.');
            this.selectedFiles = [];
        }
    
        this.isMainView = false;
        this.isDetailView = true;
    }

    handleQnAClick(event) {
        try {
            console.log('handleQnAClick');
            
            const qnaId = event.currentTarget.dataset.id;
            console.log('Clicked qna ID:', qnaId);
            
            this.selectedQnA = this.qnaList.find(qna => qna.id === qnaId);
            if (!this.selectedQnA) {
                console.error('Selected qna not found.');
                return;
            }
            console.log('Selected qna:', JSON.stringify(this.selectedQnA));
        
            if (this.selectedQnA.files && this.selectedQnA.files.length > 0) {
                this.selectedFiles = this.selectedQnA.files;
                console.log('Files:', this.selectedFiles);
            } else {
                console.log('No files available.');
                this.selectedFiles = [];
            }
    
            this.isMainView = false;
            // this.isDetailView = true;
            this.isQnaDetailView = true;
        
            // 디버깅 로그
            console.log('isMainView:', this.isMainView,'isDetailView',this.isDetailView, 'isQnaDetailView:', this.isQnaDetailView);
            
        } catch (error) {
            console.log('error ', error.message);
        }
    }
    

    

    handleBack() {
        this.isMainView = true;
        this.isDetailView = false;
        this.isCreateView = false;
        this.newName = null;
        this.newQuestion = null;
        this.newPostingDate = null; 
        this.isQnaDetailView = null; 
    }

    handleFileDownload(event) {
        const downloadLink = event.target.dataset.downloadLink;
        console.log('Download link:', downloadLink);
    
        // a 태그를 동적으로 생성하여 파일 다운로드 처리
        const link = document.createElement('a');
        link.href = downloadLink;
        link.target = '_self';  // 현재 창에서 파일 다운로드
        link.download = '';  // 파일 다운로드 기능을 활성화
        console.log('link:::', link);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        if (downloadLink && downloadLink !== '파일 URL을 찾을 수 없습니다.') {
            window.open(downloadLink, '_self');
        } else { 
            alert(label.DNS_FSL_NoFilesDownload);
        }
    }

    // SLDS Styles
    adjustStyles(){
        const style = document.createElement('style');
        style.innerText = `         
            .total-wrap .slds-tabs_default__nav {
                background: #0026B6;
            }
            .total-wrap .slds-tabs_default__nav .slds-tabs_default__link {
                font-size: 16px;
                color: #fff;
                opacity: 0.6;
            }
            .total-wrap .slds-tabs_default .slds-tabs_default__item {
                text-align: center;
                padding: 0.25rem 1rem;
            }
            .total-wrap .slds-tabs_default__item.slds-is-active:after {
                background-color: #fff !important;
                margin: 0 0.5rem;
            }
            .total-wrap .slds-tabs_default__item.slds-is-active .slds-tabs_default__link:hover {
                color: #fff !important;
            }
            .total-wrap .slds-tabs_default__item.slds-is-active .slds-tabs_default__link {
                font-weight: 400 !important;
                opacity: 1;
            }
            .total-wrap .back .slds-button {
                background: none !important;
                border: none !important;
                padding: 0.5rem;
            }           
            .page-01 .slds-form-element .slds-input_faux {
                line-height: 2.25rem;
                border: 1px solid #A0A0A0;
            }
            .page-01 .slds-listbox_vertical .slds-listbox__option_plain {
                font-size: 16px;
            }
            .page-01 .button-wrap .slds-button_neutral {
                background: none;
                border: none;
                padding: 0.5rem;
            }
            .page-01.tab-02 .slds-button {
                padding: 0.5rem;
            }
            .page-01.tab-02 .slds-m-left_x-small {
                display: flex;
                justify-content: flex-end;
                margin: -1.25rem 0;
                margin-left: 0 !important;
            }
            .page-01 .slds-form-element__label {
                font-size: 16px;
                color: #939393;
            }
           
            .modal-01 .slds-form-element__label {
                color: #444;
                font-size: 15px;
                margin-bottom: 0.5rem;
            }
          
            .modal-01 .button-wrap .slds-button {
                background: none;
                border: none;
            }
            .modal-01 .field-container .slds-input_faux {
                border: 1px solid #A0A0A0;
                line-height: 2.25rem;
            }
            .modal-01 .button-wrap.create lightning-button {
                width: 100%;
                }
            .modal-01 .button-wrap.create .slds-button_brand {
                width: 100%;
                padding: 0.25rem;
                line-height: 2.25rem;
                background: #007AE1;
            }
            .modal-01 .slds-input {
                width: 100% !important;
                margin: 0;
                line-height: 2.25rem;
                height: 2.5rem;
                border: none;
            }
            .modal-01 .slds-textarea {
                width: 100% !important;
                margin: 0;
                height: 10rem;
                border: none !important;
            }
            .total-wrap .slds-show {
                padding: 0.35rem;
            }
            .total-wrap:has(.modal-01) .slds-show  {
                padding: 0 !important;
            }
            .page-02 .card-header .button-wrap .slds-button__icon,
            .modal-01 .button-wrap .slds-button__icon {
                fill: #fff  !important;
                width: 1rem  !important;
                height: 1rem  !important;
            }
            .page-02 .file-wrap .files li .slds-button_neutral{
                border: 1px solid #c9c9c9;
                justify-content: start;
                width: 100%;
                font-size: 18px;
                padding: 0 1.25rem;
            }            
            .slds-tabs_default:has(.page-01) {
                display: flex !important;
                flex-direction: column !important;
                height: 100vh;
                touch-action: none;
                overflow: hidden;
            }
            .slds-tabs_default__content:has(.page-01) {
                overflow-y: auto !important;
                padding: 0 !important;
                flex: auto !important;
            }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }
   
}