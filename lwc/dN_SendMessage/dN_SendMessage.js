import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getData from '@salesforce/apex/DN_SendMessageController.getData';
import setGrade from '@salesforce/apex/DN_SendMessageController.setGrade';
import getGradeUser from '@salesforce/apex/DN_SendMessageController.getGradeUser';
import setSendMessage from '@salesforce/apex/DN_SendMessageController.setSendMessage';
import deleteMessage from '@salesforce/apex/DN_SendMessageController.deleteMessage';
import readMessage from '@salesforce/apex/DN_SendMessageController.readMessage';

export default class DN_SendMessage extends LightningElement {
    @track isLoading = true;

    //수신함
    @track dateToValue;
    @track dateFromValue;
    @track sender;
    @track content;
    @track SelectSender;
    @track SelectSenderId;
    @track SelectSentDate;
    @track SelectContent;
    @track SelectMsgID = '';
    //발신함
    @track senderFromValue;
    @track senderToValue;
    @track recipient;
    @track sendSelectRecipient;
    @track sendSelectSentDate;
    @track sendSelectContent;
    //쪽지전송
    @track grade;
    @track recipUser;
    @track sendType;
    @track sendContent;
    @track gradeOptions=[];
    @track selectedRows=[];

    @track recipientTableData = [];
    recipientListColumns = [
        { label: '확인', fieldName: 'Status', type: 'text'},
        { label: '보낸이', fieldName: 'Sender', type: 'text'},
        { label: '보낸일자', fieldName: 'SentDate', type: 'text'},
        { label: '보낸시간', fieldName: 'SentTime', type: 'text'},
        { label: '유형', fieldName: 'Type', type: 'text'},
        { label: '내용', fieldName: 'Content', type: 'text'},
        { type: 'button', typeAttributes: {label: '상세보기'} }
    ];

    @track sentTableData = [];
    sentListColumns = [
        { label: '보낸일자', fieldName: 'SentDate', type: 'text'},
        { label: '보낸시간', fieldName: 'SentTime', type: 'text'},
        { label: '받는이', fieldName: 'Recipient', type: 'text'},
        { label: '받은일자', fieldName: 'ReceivedDate', type: 'text'},
        { label: '받은시간', fieldName: 'ReceivedTime', type: 'text'},
        { label: '발송유형', fieldName: 'Type', type: 'text'},
        { label: '내용', fieldName: 'Content', type: 'text'},
        { type: 'button', typeAttributes: {label: '상세보기'} }
    ];

    @track targetTableData = [];
    targetColumns = [
        { label: '사용자ID', fieldName: 'userId', type: 'text'},
        { label: '사용자명', fieldName: 'Name', type: 'text'},
        { label: '센터', fieldName: 'center', type: 'text'},
        { label: '팀', fieldName: 'team', type: 'text'},
        { label: '구분', fieldName: 'grade', type: 'text'}
    ];

    connectedCallback() {
        console.log('쪽지💬');
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1 해줘야 함
        const dd = String(today.getDate()).padStart(2, '0');


        // 'YYYY-MM-DD' 형식으로 날짜 값을 설정
        this.dateFromValue = `${yyyy}-${mm}-${dd}`;
        this.dateToValue = `${yyyy}-${mm}-${dd}`;
        this.senderFromValue = `${yyyy}-${mm}-${dd}`;
        this.senderToValue = `${yyyy}-${mm}-${dd}`;

        this.setGrade();
        this.handleReceivedSearch();
    }

    renderedCallback() {
        this.adjustStyles();
    }

    // 수신함 조회
    handleReceivedSearch(type){
        if(this.dateToValue==null || this.dateFromValue == null){
            this.showToast('오류', '수신일자는 필수 값 입니다.', 'error');
            return;
        }

        if (this.dateFromValue > this.dateToValue) {
            this.showToast('에러', '시작 날짜가 종료 날짜 이후일 수 없습니다.', 'error');
            return;
        }

        this.isLoading = true;
        getData({
             type : '수신'
            ,dateTo : this.dateToValue
            ,dateFrom : this.dateFromValue
            ,sender : this.sender==undefined?'':this.sender
            ,content : this.receivedContent==undefined?'':this.receivedContent
        }).then(result => {
            console.log('수신 리스트::: ', result);
            this.recipientTableData = result;
            if(type != 'detail'){
                //상세보기 클리어
                this.SelectSender = '';
                this.SelectSentDate = '';
                this.SelectContent = '';
                this.SelectMsgID = '';
                this.SelectSenderId = '';
            }
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => this.isLoading = false );

    }
    
    // 수신함-상세내용
    recipientRowAction(event) {
        const row = event.detail.row;
        this.SelectSender = row.Sender;
        this.SelectSentDate = row.SentDate+' '+row.SentTime;
        this.SelectContent = row.Content;
        this.SelectMsgID = row.Id;
        this.SelectSenderId = row.SenderId;
        if(row.Status == '읽음') return;
        
        readMessage({
            readMsgId : this.SelectMsgID
        }).then(result => {
            this.handleReceivedSearch('detail');
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => this.isLoading = false );
    }

    //수신함 - 삭제Button
    handleRecipientDelete(){
        this.selectedRows = this.refs.recipientList.getSelectedRows();
        
        if(this.selectedRows.length ==0){
            this.showToast('오류', '삭제 할 쪽지를 선택해주세요.', 'error');
            return;
        }

        this.isLoading = true;
        deleteMessage({
             type:'수신'
            ,deleteData : this.selectedRows
        }).then(result => {
            if(result == 'Success'){
                this.showToast('성공', '선택한 쪽지가 삭제되었습니다.', 'success');
                this.handleReceivedSearch();
                this.dataClear('수신');
            } else {
                this.showToast('오류', result, 'error');
            }
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => this.isLoading = false );
    }
    
    //수신함 - 답장Button
    handleReply(event){
        console.log('답장 버튼');
        if(this.SelectMsgID == ''){
            this.showToast('오류', '상세보기 된 쪽지의 답장만 가능합니다.\n 상세보기 버튼을 클릭해주세요.', 'error');
            return;
        }
        this.recipUser = this.SelectSender;
        this.template.querySelector('lightning-tabset').activeTabValue = 'SendMessage';
        this.handleGradeSearch('reply', this.SelectSenderId);
    }

    // 발신함 조회
    handleSentSearch(){
        if(this.senderToValue==null || this.senderFromValue == null){
            this.showToast('오류', '발신일자는 필수 값 입니다.', 'error');
            return;
        }

        if (this.senderFromValue > this.senderToValue) {
            this.showToast('에러', '시작 날짜가 종료 날짜 이후일 수 없습니다.', 'error');
            return;
        }

        this.isLoading = true;
        getData({
             type : '발신'
            ,dateTo : this.senderToValue
            ,dateFrom : this.senderFromValue
            ,sender : this.recipient==undefined?'':this.recipient
        }).then(result => {
            console.log('발신 리스트::: ', result);
            this.sentTableData = result;
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => this.isLoading = false );
    }

    //발신함 - 상세내용
    sentRowAction(event) {
        const row = event.detail.row;
        console.log('클릭! event ::: ', row);
        this.sendSelectRecipient = row.Recipient;
        this.sendSelectSentDate = row.SentDate+' '+row.SentTime;
        this.sendSelectContent = row.Content;
    }

    //발신함 - 삭제Button
    handleSendDelete(){
        this.selectedRows = this.refs.sendList.getSelectedRows();
        
        if(this.selectedRows.length ==0){
            this.showToast('오류', '삭제 할 쪽지를 선택해주세요.', 'error');
            return;
        }
        this.isLoading = true;
        deleteMessage({
             type : '발신'
            ,deleteData : this.selectedRows
        }).then(result => {
            if(result == 'Success'){
                this.showToast('성공', '선택한 쪽지가 삭제되었습니다.', 'success');
                this.dataClear('발신');
                this.handleSentSearch();
            } else {
                this.showToast('오류', result, 'error');
            }
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => this.isLoading = false );
    }


    // 쪽지 전송
    handleSend() {
        const inputField = this.template.querySelectorAll('[data-id="sendType"]')[0];
        this.sendType = inputField.value==null?'':inputField.value;
        this.sendContent = this.sendContent==undefined?'':this.sendContent;
        this.selectedRows = this.refs.targetList.getSelectedRows();
        
        if(this.selectedRows.length ==0){
            this.showToast('오류', '전송할 대상을 선택해주세요.', 'error');
            return;
        }
        if(this.sendType == ''){
            this.showToast('오류', '발송유형을 선택해주세요.', 'error');
            return;
        }
        if(this.sendContent == ''){
            this.showToast('오류', '내용을 입력해주세요.', 'error');
            return;
        }
        this.isLoading = true;
        setSendMessage({
             sendType : this.sendType
            ,sendContent : this.sendContent
            ,recipient : this.selectedRows
        }).then(result => {
            if(result == 'Success'){
                this.showToast('성공', '쪽지가 전송되었습니다.', 'success');
                this.dataClear('전송');
            } else {
                this.showToast('오류', result, 'error');
            }
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => this.isLoading = false );
    }

    //쪽지전송-상담원조회
    handleGradeSearch(type, senderId) {
        this.isLoading = true;
        getGradeUser({
             grade : this.grade==undefined?'':this.grade
            ,recipUser : this.recipUser==undefined?'':this.recipUser
        }).then(result => {
            console.log('result ::: ', result);
            this.targetTableData = result;
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => { 
            if(type == 'reply'){ //답장으로 넘어왔을 경우 조회된 상담원 체크 해주기_상담원Id 필드 받으면 상담원 Id로 1명만 체크
                if (this.targetTableData.length > 0) {
                    this.selectedRows = this.targetTableData.map(row => row.Id);
                }
            }
            this.isLoading = false
        });
    }

    // 쪽지전송 - 등급조회
    setGrade(){
        this.isLoading = true;
        setGrade({
       }).then(result => {
           this.gradeOptions = result;
       }).catch(error => {
           console.log('Error ::: ', error.message);
       }).finally(() => this.isLoading = false );
    }

    dataClear(type){
        if(type == '전송'){
            this.sendContent = '';
            this.sendType = '';
            this.targetTableData = [];
            this.recipUser = '';
            this.grade = '';
        } else if(type=='발신'){
            this.sentTableData = [];
            this.sendSelectRecipient = '';
            this.sendSelectSentDate = '';
            this.sendSelectContent = '';
        } else { //수신
            this.recipientTableData = [];
            this.SelectSender = '';
            this.SelectSentDate = '';
            this.SelectContent = '';
        }
        
    }

    handleGradeChange(event) {
        this.grade = event.detail.value;
    }

    handleDateChange(event) {
        if(event.target.name == "to") { //수신함 일자
            this.dateToValue = event.target.value;
        } else if(event.target.name == "from"){
            this.dateFromValue = event.target.value;
        } else if(event.target.name == "senderFrom") { //발신함 일자
            this.senderFromValue = event.target.value;
        } else if(event.target.name == "senderTo") {
            this.senderToValue = event.target.value;
        }
    }

    handleFormInputChange(event){
        console.log('event.target.name ::: ', event.target.name);
        console.log('event.target.value :::', event.target.value);

        if( event.target.name == 'recipUser' ){
            this.recipUser = event.target.value;
        }

        if( event.target.name == 'content' ){
            this.sendContent = event.target.value;
        }

        if( event.target.name == 'sender' ){
            this.sender = event.target.value;
        }

        if( event.target.name == 'receivedContent' ){
            this.receivedContent = event.target.value;
        }

        if( event.target.name == 'recipient' ){
            this.recipient = event.target.value;
        }
        
    }

    showToast(title, message, variant = 'info') {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // info, success, warning, error
        });
        this.dispatchEvent(evt);
    }

    adjustStyles(){
        const style = document.createElement('style');
        style.innerText = `   
            .oneUtilityBarPanel .slds-utility-panel__body:has(.total-wrap) {
                background: #f3f3f3 !important;
            }
            .body_container:has(.total-wrap) {
                background: #f3f3f3;
            }
            .slds-tabs_default__nav {
                background: #fff;
                margin-top: -1rem;
            }    
            .slds-textarea {
                min-height: 12rem;
            }
            .slds-tabs_default__content {
                padding: 0;
            }
            .card-01 .field-wrap .input-wrap .slds-form-element {
                width: 100%;
            }
            .card-01 .input-wrap .slds-button+.slds-button {
                margin-left: 0;
            }
            .input-wrap .slds-input,
            .input-wrap .slds-input_faux {
                min-width: 12rem;
            }
            table .slds-input {
                line-height: 1.75rem;
                min-height: 1.75rem;
            }
            table td:has(.slds-input) {
                padding: 0.25rem;
            }
            .footer .slds-button_brand {
                font-size: 13px;
            }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }
}