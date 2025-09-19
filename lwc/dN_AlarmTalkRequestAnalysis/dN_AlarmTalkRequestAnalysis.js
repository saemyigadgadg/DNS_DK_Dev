/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-03-30
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getData from '@salesforce/apex/DN_AlarmTalkRequestAnalysisController.getData';
import getDetailData from '@salesforce/apex/DN_AlarmTalkRequestAnalysisController.getDetailData';

export default class DN_AlarmTalkRequestAnalysis extends LightningElement {
    isLoading = false;

    //알림톡 접수분석
    @track tableData = [];
    
    //알림톡 접수분석 상세
    @track detailData = [];
    detailColumns = [
        { label: '관할지사', fieldName: 'Branch', type: 'text', initialWidth: 120},
        { label: '접수번호', fieldName: 'CaseNumber', type: 'text', initialWidth: 120},
        { label: '오더번호', fieldName: 'OrderNumber', type: 'text', initialWidth: 120},
        { label: '기종', fieldName: 'Model', type: 'text', initialWidth: 120},
        { label: '제조번호', fieldName: 'SerialNumber', type: 'text', initialWidth: 120},
        { label: '접수일', fieldName: 'ReceivedDate', type: 'text', initialWidth: 120},
        { label: '시간', fieldName: 'ReceivedTime', type: 'text', initialWidth: 120},
        { label: '야간', fieldName: 'NightShift', type: 'text', initialWidth: 120},
        { label: '상담원', fieldName: 'Agent', type: 'text', initialWidth: 120},
        { label: '서비스맨', fieldName: 'ServiceTechnician', type: 'text', initialWidth: 120},
        { label: '전화번호', fieldName: 'PhoneNumber', type: 'text', initialWidth: 120},
        { label: '정비센터', fieldName: 'RepairCenter', type: 'text', initialWidth: 120},
        { label: '요청업체', fieldName: 'RequestingCompany', type: 'text', initialWidth: 120},
        { label: '요청자', fieldName: 'Requester', type: 'text', initialWidth: 120},
        { label: '접수채널', fieldName: 'IntakeChannel', type: 'text', initialWidth: 120},
        { label: '요청내용', fieldName: 'RequestDetails', type: 'text', initialWidth: 120},
        { label: '파일여부', fieldName: 'FileAvailable', type: 'text', initialWidth: 120}
    ];

    get tableDataWithIndex() {
        return this.tableData.map((row, index) => ({
            ...row,
            No: index + 1, // 넘버링
            AlarmTalkResponseRate: row.AlarmTalkResponseRate + ' %'
        }));
    }

    connectedCallback(){
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1 해줘야 함
        const dd = String(today.getDate()).padStart(2, '0');

        // 'YYYY-MM-DD' 형식으로 날짜 값을 설정
        this.dateFromValue = `${yyyy}-${mm}-01`; //매월초
        this.dateToValue = `${yyyy}-${mm}-${dd}`;

        this.search();
    }

    search(){
        console.log("from: "+this.dateFromValue);
        console.log("to: "+this.dateToValue);
        
        if(this.dateFromValue==null || this.dateToValue==null){
            this.showToast('에러', '근태일은 필수값 입니다.', 'error');
            return;
        }
        
        if (this.dateFromValue > this.dateToValue) {
            this.showToast('에러', '시작 날짜가 종료 날짜 이후일 수 없습니다.', 'error');
            return;
        }
        
        this.isLoading = true;
        getData({
             dateTo : this.dateToValue
            ,dateFrom : this.dateFromValue
        }).then(result => {
            console.log('result ::: ', result);
            this.tableData = result;
        }).catch(error => {
            console.log('Error ::: ', error.message);
        }).finally(() => this.isLoading = false );
    }

    //날짜 변경 시
    handleDateChange(event) {
        if(event.target.name == "to") {
            this.dateToValue = event.target.value;
        } else {
            this.dateFromValue = event.target.value;
        }
    }

    handleCellClick(event){
        const serviceCenterId = event.target.getAttribute('data-id');
        const column = event.target.getAttribute('data-column');
        console.log('클릭 Id::::'+serviceCenterId);
        console.log('클릭 column::::'+column);

        this.isLoading = true;
        getDetailData({
            type : column
           ,serviceCenterId : serviceCenterId
           ,dateTo : this.dateToValue
           ,dateFrom : this.dateFromValue
       }).then(result => {
           console.log('Detail result ::: ', result);
           this.detailData = result;
       }).catch(error => {
           console.log('Error ::: ', error.message);
       }).finally(() => this.isLoading = false );
    }

    showToast(title, message, variant = 'info') {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // info, success, warning, error
        });
        this.dispatchEvent(evt);
    }
}