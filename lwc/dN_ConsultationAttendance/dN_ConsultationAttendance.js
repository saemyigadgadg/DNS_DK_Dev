/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-17
 * @last modified by  : Hyerin Ro
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-04-07   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

import setInquiryType from '@salesforce/apex/DN_ConsultationAttendanceController.setInquiryType';
import getData from '@salesforce/apex/DN_ConsultationAttendanceController.getData';
import setData from '@salesforce/apex/DN_ConsultationAttendanceController.setData';

export default class DN_ConsultationAttendance extends LightningElement {
    isLoading = false;

    @track dateToValue;
    @track dateFromValue;
    @track inquiryType='';
    @track inquiryTypeOptions=[];
    @track consultantId='';
    @track consultantName='';

    //상세정보
    @track selectRow='';
    @track selectConsultationType='';
    @track selectConsultantId='';
    @track selectConsultantName='';
    @track selectAttendanceDate='';
    @track selectAttendanceType='';
    @track selectOffStartTime='';
    @track selectOffEndTime='';

    @track tableData = [];
    tableListColumns = [
        { label: '상담유형', fieldName: 'ConsultantType', type: 'text'},
        { label: '상담원 ID', fieldName: 'ConsultantId', type: 'text'},
        { label: '상담원 성명', fieldName: 'ConsultantName', type: 'text'},
        { label: '근태일', fieldName: 'AttendanceDate', type: 'text'},
        { label: '근태구분', fieldName: 'AttendanceType', type: 'text'},
        { label: 'off 시작 시간', fieldName: 'OffStartTime', type: 'text'},
        { label: 'off 종료 시간', fieldName: 'OffEndTime', type: 'text'},
        { type: 'button', typeAttributes: {label: '상세보기'} }
    ];

    connectedCallback(){
        console.log('서비스요원 근태관리');
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1 해줘야 함
        const dd = String(today.getDate()).padStart(2, '0');


        // 'YYYY-MM-DD' 형식으로 날짜 값을 설정
        this.dateFromValue = `${yyyy}-${mm}-${dd}`;
        this.dateToValue = `${yyyy}-${mm}-${dd}`;

        this.setInquiryType();
    }

    renderedCallback() {
        this.adjustSLDSStyles();
    }

    //조회 Button
    handleSearch(event){
        //일자는 필수값
        console.log('FROM'+this.dateFromValue);
        console.log('TO'+this.dateToValue);
        console.log('ID'+this.consultantId);
        console.log('NAME'+this.consultantName);
        
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
            ,constructortype : this.inquiryType
            ,constructorId : this.consultantId
            ,constructorName : this.consultantName
        }).then(result => {
            console.log('result::: ', result);
            this.tableData = result;
        }).catch(error => {
            console.log('Error ::: ', error);
        }).finally(() => this.isLoading = false );
    }

    //상세내용
    tableRowAction(event) {
        const row = event.detail.row;
        
        // 에러메시지 초기화
        let startTime = this .template.querySelector(".startTime"); 
        let endTime = this .template.querySelector(".endTime"); 
        startTime.setCustomValidity('');
        endTime.setCustomValidity('');
        endTime.reportValidity();
        startTime.reportValidity();
        
        const inputField = this.template.querySelector('[data-id="selectAttendanceType"]');
        inputField.value = row.AttendanceType;
        this.selectRow = row;
        this.selectConsultationType = row.ConsultantType;
        this.selectConsultantId = row.ConsultantId;
        this.selectConsultantName = row.ConsultantName;
        this.selectAttendanceType = row.AttendanceType;
        this.selectOffStartTime = row.OffStartTime;
        this.selectOffEndTime = row.OffEndTime;
        this.selectAttendanceDate = row.AttendanceDate;
    }

    // 상담유형 (접수상담/기술상담)
    setInquiryType(){
        this.isLoading = true;
        setInquiryType({
        }).then(result => {
            this.inquiryTypeOptions = result;
            this.inquiryTypeOptions.unshift({
                label: '전체',
                value: ''
            }); 
        }).catch(error => {
            console.log('Error ::: ', error);
        }).finally(() => this.isLoading = false );
    }

    //근태 초기화 Button
    async handleReset(){
        console.log('>>'+JSON.stringify(this.tableData));

        if(this.tableData.length == 0){
            this.showToast('에러', '조회 된 데이터가 없습니다.', 'error');
            return;
        }

        const confirmResult  = await LightningConfirm.open({
            message: '조회된 데이터의 근태를 모두 초기화 시키겠습니까?',
            variant: 'header',
            label: '근태 초기화',
            theme: 'alt-inverse'
        });

        if(!confirmResult){
            return;
        }

        this.isLoading = true;
        setData({
            type: 'RESET',
            dataList : this.tableData
        }).then(result => {
            console.log('result::: ', result);
            if(result == 'S'){
                this.showToast('성공', '근태 초기화 완료', 'success');
                this.handleSearch();
            } else {
                this.showToast('경고', result, 'warning');
            }
        }).catch(error => {
            console.log('Error ::: ', error);
        }).finally(() => this.isLoading = false );
    }

    //근태 전체 적용 Button
    async handleAllSubmit(){
        const inputField = this.template.querySelector('[data-id="selectAttendanceType"]');
        
        if(this.tableData.length == 0){
            this.showToast('에러', '조회 된 데이터가 없습니다.', 'error');
            return;
        }

        let hasError = this.template.querySelectorAll(".slds-has-error");
        if(hasError.length>0){
            this.showToast('에러', '올바른 값을 입력해주세요.', 'error');
            return;
        }

        const confirmResult  = await LightningConfirm.open({
            message: '조회된 데이터의 근태를 전체 적용 시키겠습니까?',
            variant: 'header',
            label: '근태 전체 적용',
            theme: 'alt-inverse'
        });

        if(!confirmResult){
            return;
        }


        this.isLoading = true;
        setData({
            type: 'ALLSAVE',
            dataList : this.tableData,
            attendanceType : inputField.value,
            offStartTime : this.selectOffStartTime.replace(':', ''),
            offEndTime : this.selectOffEndTime.replace(':', '')
        }).then(result => {
            console.log('result::: ', result);
            if(result == 'S'){
                this.showToast('성공', '근태 전체 적용 완료', 'success');
                this.handleSearch();
            } else {
                this.showToast('경고', result, 'warning');
            }
        }).catch(error => {
            console.log('Error ::: ', error);
        }).finally(() => this.isLoading = false );
    }

    // 저장 Button
    handleSave(){
        const inputField = this.template.querySelector('[data-id="selectAttendanceType"]');
        console.log('>>'+this.selectRow);
        if(this.selectRow==null || this.selectRow.length == 0){
            this.showToast('에러', '조회 된 데이터가 없습니다.', 'error');
            return;
        }

        let hasError = this.template.querySelectorAll(".slds-has-error");
        if(hasError.length>0){
            this.showToast('에러', '올바른 값을 입력해주세요.', 'error');
            return;
        }

        
        this.isLoading = true;
        setData({
            type: 'SAVE',
            dataList : [this.selectRow],
            attendanceType : inputField.value,
            offStartTime : this.selectOffStartTime.replace(':', ''),
            offEndTime : this.selectOffEndTime.replace(':', '')
        }).then(result => {
            console.log('result::: ', result);  
            if(result == 'S'){
                this.showToast('성공', '근태 적용 완료', 'success');
                this.handleSearch();
            } else {
                this.showToast('오류', result, 'error');
            }
        }).catch(error => {
            console.log('Error ::: ', error);
        }).finally(() => this.isLoading = false );
    }
    
    

    handleTypeChange(event){
        this.inquiryType = event.detail.value;
    }

    handleInputChange(event){
        if( event.target.name == 'ID' ){
            this.consultantId = event.target.value;
        }

        if( event.target.name == 'Name' ){
            this.consultantName = event.target.value;
        }
    }

    handleAttendanceTypeChange(event){
        this.SelectAttendanceType = event.target.value;

        switch(event.target.value){
            case 'Holiday(Full Day)':
            case 'Education(Full Day)':
                this.selectOffStartTime = '08:00';
                this.selectOffEndTime = '17:20';
                break;
            case 'Holiday(AM)':
            case 'Education(AM)':
                this.selectOffStartTime = '08:00';
                this.selectOffEndTime = '12:00';
                break;
            case 'Holiday(PM)':
            case 'Education(PM)':
                this.selectOffStartTime = '12:00';
                this.selectOffEndTime = '17:20';
                break;
            default:
                this.selectOffStartTime = '';
                this.selectOffEndTime = '';
                break;
        }
    }

    handleTimeChange(event){
        let inputNmae = event.target.name;

        //숫자 아님
        if (isNaN(event.target.value.charAt(event.target.value.length - 1)) || event.target.value.charAt(event.target.value.length - 1) == ' ') {
            event.target.value = event.target.value.slice(0, -1);
        }

        //4자리 초과
        if(event.target.value.length > 4){
            event.target.value = event.target.value.slice(0, -1);
        }

        if(inputNmae == 'endTime') this.selectOffEndTime = event.target.value;
        else this.selectOffStartTime = event.target.value;
        
    }

    handleFocus(event){
        event.target.value = event.target.value.replace(':', '');
    }

    handleBlur(event){
        let inputNmae = event.target.name;
        let inputValue = event.target.value;
        let endTime = this .template.querySelector(".endTime"); 
        let startTime = this .template.querySelector(".startTime"); 
        let errorMsg = '';

        if(inputValue.length < 4 && inputValue.length > 0){
            errorMsg = '올바른 시간을 입력해주세요. ex)08:00';
            if(inputNmae == 'endTime') endTime.setCustomValidity(errorMsg);
            else startTime.setCustomValidity(errorMsg);
        } else {
            if(inputNmae == 'endTime') endTime.setCustomValidity('');
            else startTime.setCustomValidity('');
        }
        
        if(inputValue.length == 4){
            let hh = inputValue.substring(0, 2);
            let mm = inputValue.substring(2, 4);
            if(hh > 24 || mm >= 60){
                errorMsg = '24시를 넘을 수 없습니다. 올바른 시간을 입력해주세요.';
                if(inputNmae == 'endTime') endTime.setCustomValidity(errorMsg);
                else startTime.setCustomValidity(errorMsg);
            } else {
                if(inputNmae == 'endTime') endTime.setCustomValidity('');
                else startTime.setCustomValidity('');
            }
        }

        if(inputNmae == 'endTime')endTime.reportValidity();
        else startTime.reportValidity();

        if (inputValue.length > 2) {
            inputValue = inputValue.substring(0, 2) + ':' + inputValue.substring(2, 4);
        }
       
        event.target.value = inputValue;
    }

    handleDateChange(event) {
        if(event.target.name == "to") {
            this.dateToValue = event.target.value;
        } else {
            this.dateFromValue = event.target.value;
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

    adjustSLDSStyles() {
        const style = document.createElement('style');
        style.innerText = `
            .consultationAttendance .card-01 .slds-form-element {
                width: 12rem;
            }    
            .consultationAttendance .card-01 .slds-button_brand {
                text-wrap-mode: nowrap;
            }
            .consultationAttendance .card-01 .input-wrap .slds-form-element__help {
                display: none;
            }
            .consultationAttendance .container-01 .card-header .slds-icon-standard-lead-list {
                background-color: #5867e8 !important;
            }
         `;
        this.template.querySelector('.consultationAttendance').appendChild(style);
    }
}