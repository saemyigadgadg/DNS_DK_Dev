import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAnswersByMainParent from '@salesforce/apex/QnABoardEmailNotifier.getAnswersByMainParent';

export default class dN_QnaBoardHistoryList extends NavigationMixin(LightningElement) {
    @api recordId;
    mainId;
    answers;
    error;
    isType;
    icon;

    get componentStyle(){
        // let componentCss = 'related_wrapper';
        let componentCss = 'related_wrapper hide_component';
        return componentCss;
    }


    get cardStyle(){
        let cardCss = 'my_card';
        return cardCss;
    }

    // 테이블 컬럼 정의
    columns = [
        {
            label: 'Name', fieldName: 'linkName', type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_self' // 또는 '_blank' (새 탭)
            }
        },
        { label: 'Title', fieldName: 'Title__c', type: 'text' }
    ];
    
    connectedCallback() {
        console.log('recordID', this.recordId);
        if (!this.recordId) {
            const currentUrl = window.location.href;
            console.log('현재 URL:', currentUrl);
        
            const segments = currentUrl.split('/');
            console.log('segments >>' + segments);
            // 마지막 2번째 segment가 ID일 경우
            let recordId= segments[segments.length - 2];
            if(recordId == 'qnaboard') {
                recordId = segments[segments.length - 1];
            }
            
            console.log('추출된 recordId:', recordId);
            this.isType = 'portal';
            this.recordId = recordId;
        }
        if (this.recordId) {
            console.log('this.recordId >> ' +this.recordId);
            this.loadAnswers();
        }
    }

    loadAnswers() {
        var baseUrl = window.location.origin;
        const pathname = window.location.pathname;
        if (pathname.startsWith('/partners')) {
            baseUrl += '/partners';
        }
        console.log('baseUrl >>> ' + baseUrl);
        getAnswersByMainParent({ currentId: this.recordId })
            .then(data => {
                this.answers = data.map(row => ({
                    ...row,
                    linkName: this.isType === 'portal'
                        // ? `${baseUrl}/partners/s/qnaboard/${row.Id}`  // 개발
                        ? `${baseUrl}/s/qnaboard/${row.Id}`  // 운영
                        : '/' + row.Id,
                    createdDate: new Date(row.Date)
                    .toISOString()
                    .slice(0, 10)
                    .replace(/-/g, '.')
                })).slice(0, 3);
                console.log('data >>  '+JSON.stringify(data,null,4))
                this.mainId = data[0].Id;
                this.error = undefined;
            })
            .catch(error => {
                console.error('Apex 호출 실패:', error);
                this.answers = undefined;
                this.error = error;
            });
    }

    handleViewAll() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.mainId,
                objectApiName: 'QnABoard__c',
                relationshipApiName: 'QnABoardMain__r',
                actionName: 'view'
            }
        });
    }
}