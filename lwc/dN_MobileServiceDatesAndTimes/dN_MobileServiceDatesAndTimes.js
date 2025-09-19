/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-04-07
 * @last modified by  : chungwoo.lee@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-27-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';

/*✔️ Apex Controller */
import getWorkOrderResults  from '@salesforce/apex/DN_MobileServiceDatesController.getWorkOrderResults';
import saveWorkOrderResults from '@salesforce/apex/DN_MobileServiceDatesController.saveWorkOrderResults';


export default class DN_MobileServiceDatesAndTimes extends LightningElement {
    @api recordId;
    @track checkedIds        = [];
    @track timeOptions       = [];
    @track workOrderResults  = [];

    deleteWorkResults        = [];
    ApplicationDateTime      = '';
    isLoading                = true;

    renderedCallback() {
	    this.styleCSS();	    
	}

    connectedCallback() {
        setTimeout(() => {
            this.loadWorkOrderResults();
        }, 5);
    }

    generateTimeOptions() {
        const options = [{ label: 'Select Option..', value: '' }];

        for (let hour = 0; hour < 24; hour++) {
            for (let minute = 0; minute < 60; minute += 15) {
                let period = hour < 12 ? 'AM' : 'PM';
                let displayHour = hour % 12 === 0 ? 12 : hour % 12;
                let label = `${period} ${String(displayHour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
                let value = `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}:00.000`;

                options.push({ label, value });
            }
        }

        this.timeOptions = options;
    }

    loadWorkOrderResults() {
        getWorkOrderResults({ serviceOrderId: this.recordId })
        .then((data) => {
            if(data.status == 'success') {
                this.handleDataLoadSuccess(data);
            } else {
                this.handleDataLoadError(data);
            }
        });
    }

    handleDataLoadSuccess(data) {
        console.log('✅ 받은 데이터:', JSON.stringify(data, null, 2));

        // 데이터 가공
        if(data.message != 'result is Empty') {
            this.workOrderResults = data.workOrderResults.map(record => ({
                resultId: record.resultId || '',
                WorkDate: record.WorkDate || '',
                WorkStartTime: record.WorkStartTime === 0 ? '00:00:00.000' : this.convertMillisecondsToTime(record.WorkStartTime || ''),
                WorkEndTime: record.WorkEndTime === 0 ? '00:00:00.000' : this.convertMillisecondsToTime(record.WorkEndTime || ''),
                WorkTime: record.WorkTime || '',
                TravelHour: record.TravelHour || '',
                AirTrip: record.AirTrip || ''
            }));
        }

        // console.log('this.workOrder 가공:::', JSON.stringify(this.workOrderResults, null, 2));
        if (data.applicationDateTime) {
            this.ApplicationDateTime = data.applicationDateTime || '';
        }

        if (this.workOrderResults.length === 0) {
            this.addEmptyWorkOrderResult();
        }

        this.generateTimeOptions();
        this.isLoading = false;
    }

    handleDataLoadError(error) {
        console.error('❌ 데이터 로딩 실패:', JSON.stringify(error,null,2));
        this.isLoading = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.message,
            variant: 'error'
        }));
    }

    convertMillisecondsToTime(ms) {
        if (ms === '' || ms === null || ms === undefined) {
            return '';
        }
        if (ms === 0) {
            return '00:00:00.000';
        }

        // 밀리초를 시간, 분, 초로 변환
        let hours = Math.floor(ms / (1000 * 60 * 60)); // 시간 추출
        let minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60)); // 분 추출
        let seconds = Math.floor((ms % (1000 * 60)) / 1000); // 초 추출

        // "HH:mm:ss.SSS" 형식으로 변환
        return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}.000`;
    }

    // 빈 레코드를 추가하는 함수
    addEmptyWorkOrderResult() {
        const emptyRecord = {
            resultId: 'temp-' + Date.now(),
            WorkDate: '',
            WorkStartTime: '',
            WorkEndTime: '',
            WorkTime: '',
            TravelHour: '',
            AirTrip: ''
        };
        this.workOrderResults = [...this.workOrderResults, emptyRecord];
    }

    checkhandler(event) {
        const recordId = event.target.dataset.id;
        const isChecked = event.target.checked;

        if (isChecked) {
            if (!this.checkedIds.includes(recordId)) {
                this.checkedIds = [...this.checkedIds, recordId];
            }
        } else {
            this.checkedIds = this.checkedIds.filter(id => id !== recordId);
        }

        // console.log('✅ 체크된 ID 리스트:', JSON.stringify(this.checkedIds, null, 2));
    }

    addLinesFunction() {
        this.addEmptyWorkOrderResult();
    }

    deleteWorkList() {
        if (this.checkedIds.length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: 'Please select the item you want to delete.',
                variant: 'warning'
            }));
            return;
        }

        this.workOrderResults = this.workOrderResults.filter(record => {
            if (this.checkedIds.includes(record.resultId)) {
                // temp-가 아닌 경우, deleteWorkResults에 ID 추가
                if (!record.resultId.startsWith('temp-')) {
                    this.deleteWorkResults.push(record.resultId);
                }
                return false;
            }
            return true;
        });

        this.checkedIds = [];
    }

    handleFieldChange(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        let recordId = event.target.dataset.id;

        let recordToUpdate = this.workOrderResults.find(record => record.resultId === recordId);

        if (recordToUpdate) {
            recordToUpdate[fieldName] = value;
            let workDate              = recordToUpdate.WorkDate;
            let startTime             = recordToUpdate.WorkStartTime;
            let endTime               = recordToUpdate.WorkEndTime;
            let applicationDateTime   = this.formatDateTime(this.ApplicationDateTime);

            // console.log('workDate ::: ', workDate);
            // console.log('startTime ::: ', startTime);
            // console.log('endTime ::: ', endTime);
            // console.log('applicationDateTime ::: ', applicationDateTime);
            // console.log(`Updated Record [${recordId}]:`, JSON.stringify(recordToUpdate, null, 2));

            let convertAppDateTime  = new Date(applicationDateTime);
            let convertAppDate      = convertAppDateTime.getFullYear() + '-' + String(convertAppDateTime.getMonth() + 1).padStart(2, '0') + '-' + String(convertAppDateTime.getDate()).padStart(2, '0');

            let hours               = String(convertAppDateTime.getHours()).padStart(2, '0');
            let minutes             = String(convertAppDateTime.getMinutes()).padStart(2, '0');
            let seconds             = String(convertAppDateTime.getSeconds()).padStart(2, '0');
            let convertAppTimeOnly  = `${hours}:${minutes}:${seconds}`;

            // 오늘 날짜 및 현재 시간
            let today = new Date();
            let convertToday    = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
            let currentHours    = String(today.getHours()).padStart(2, '0');
            let currentMinutes  = String(today.getMinutes()).padStart(2, '0');
            let currentSeconds  = String(today.getSeconds()).padStart(2, '0');
            let convertTime     = `${currentHours}:${currentMinutes}:${currentSeconds}`;

            // console.log('작업 날짜 :::', workDate);
            // console.log('접수 날짜 :::', convertAppDate);
            // console.log('오늘 날짜 / 시간 :::', today);
            // console.log('오늘 날짜 :::', convertToday);
            // console.log('오늘 시간 :::', convertTime);

            const dateObj = new Date(applicationDateTime);
            if (workDate) {
                if (!applicationDateTime || isNaN(dateObj.getTime())) {
                    this.showToast('ERROR', 'No information exists for Application Date Time.');
                    return;
                } else {
                    if (workDate > convertToday) {
                        this.showToast('WARNING', 'The working day must be less than or equal to today\'s date.');
                        recordToUpdate.WorkDate       = null;
                        recordToUpdate.WorkStartTime  = null;
                        recordToUpdate.WorkEndTime    = null;
                        recordToUpdate.WorkTime       = null;
                        this.workOrderResults         = [...this.workOrderResults];
                        setTimeout(() => {
                            recordToUpdate.WorkDate      = convertToday;
                            recordToUpdate.WorkStartTime = "";
                            recordToUpdate.WorkEndTime   = "";
                            recordToUpdate.WorkTime      = "";
                            this.workOrderResults        = [...this.workOrderResults];
                        }, 0);
                        return;
                    }

                    if (workDate < convertAppDate) {
                        this.showToast('WARNING', 'You cannot enter workdays prior to the date of receipt.');
                        recordToUpdate.WorkDate       = null;
                        recordToUpdate.WorkStartTime  = null;
                        recordToUpdate.WorkEndTime    = null;
                        recordToUpdate.WorkTime       = null;
                        this.workOrderResults         = [...this.workOrderResults];
                        setTimeout(() => {
                            recordToUpdate.WorkDate      = convertToday;
                            recordToUpdate.WorkStartTime = "";
                            recordToUpdate.WorkEndTime   = "";
                            recordToUpdate.WorkTime      = "";
                            this.workOrderResults        = [...this.workOrderResults];
                        }, 0);
                        return;
                    }
                }

                if (workDate == convertToday) {
                    if (startTime > convertTime || endTime > convertTime) {
                        this.showToast('WARNING', 'You cannot enter a date and time after the current time.');
                        recordToUpdate.WorkStartTime  = null;
                        recordToUpdate.WorkEndTime    = null;
                        recordToUpdate.WorkTime       = null;
                        this.workOrderResults         = [...this.workOrderResults];
                        setTimeout(() => {
                            recordToUpdate.WorkStartTime = "";
                            recordToUpdate.WorkEndTime   = "";
                            recordToUpdate.WorkTime      = "";
                            this.workOrderResults        = [...this.workOrderResults];
                        }, 0);
                        return;
                    }
                }
            }

            if (startTime) {
                if (!workDate) {
                    this.showToast('WARNING', 'You cannot enter a date and time after the current time.');
                    recordToUpdate.WorkStartTime  = null;
                    recordToUpdate.WorkEndTime    = null;
                    recordToUpdate.WorkTime       = null;
                    this.workOrderResults         = [...this.workOrderResults];
                    setTimeout(() => {
                        recordToUpdate.WorkStartTime  = "";
                        recordToUpdate.WorkEndTime    = "";
                        recordToUpdate.WorkTime       = "";
                        this.workOrderResults         = [...this.workOrderResults];
                    }, 0);
                    return;
                }

                if (workDate == convertAppDate) {
                    if (startTime < convertAppTimeOnly) {
                        this.showToast('WARNING', 'The work day and the reception date are the same. Please enter the start time as the time after the registration time.');
                        recordToUpdate.WorkStartTime  = null;
                        recordToUpdate.WorkEndTime    = null;
                        recordToUpdate.WorkTime       = null;
                        this.workOrderResults         = [...this.workOrderResults];
                        setTimeout(() => {
                            recordToUpdate.WorkStartTime  = "";
                            recordToUpdate.WorkEndTime    = "";
                            recordToUpdate.WorkTime       = "";
                            this.workOrderResults         = [...this.workOrderResults];
                        }, 0);
                        return;
                    }
                }
            }

            if (startTime && endTime) {
                try {
                    let start = new Date(`1970-01-01T${startTime}Z`);
                    let end = new Date(`1970-01-01T${endTime}Z`);

                    if (end <= start) {
                        this.showToast('WARNING', 'The end time cannot be less than or equal to the start time.');
                        recordToUpdate.WorkEndTime    = null;
                        recordToUpdate.WorkTime       = null;
                        this.workOrderResults         = [...this.workOrderResults];
                        setTimeout(() => {
                            recordToUpdate.WorkEndTime = "";
                            recordToUpdate.WorkTime    = "";
                            this.workOrderResults      = [...this.workOrderResults];
                        }, 0);
                        return;
                    }

                    let fromValue = start.getUTCHours() + (start.getUTCMinutes() / 60);
                    let toValue = end.getUTCHours() + (end.getUTCMinutes() / 60);
                    let timeDiff = Math.round((toValue - fromValue) * 10) / 10;

                    recordToUpdate.WorkTime = timeDiff.toFixed(1);
                    if (timeDiff > 12) {
                        this.showToast('WARNING', 'Operation time exceeded 12 hours.');
                        recordToUpdate.WorkEndTime    = null;
                        recordToUpdate.WorkTime       = null;
                        this.workOrderResults         = [...this.workOrderResults];
                        setTimeout(() => {
                            recordToUpdate.WorkEndTime    = "";
                            recordToUpdate.WorkTime       = "";
                            this.workOrderResults         = [...this.workOrderResults];
                        }, 0);
                        return;
                    }
                    if (timeDiff >= 8) {
                        this.showToast('WARNING', 'Operation time exceeded 8 hours.');
                    }

                } catch (error) {
                    console.error("Error during time validation:", error);
                    this.showToast("ERROR", "An error occurred during time calculation.");
                    return;
                }
            } else {
                recordToUpdate.WorkTime = "";
            }
            this.workOrderResults = [...this.workOrderResults];
        } else {
            console.error(`Record not found for recordId: ${recordId}`);
        }
    }

    showToast(title, message, variant = 'Warning') {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant.toLowerCase()
        }));
    }

    formatDateTime(isoString) {
        let date = new Date(isoString);

        let year = date.getFullYear();
        let month = String(date.getMonth() + 1).padStart(2, '0');
        let day = String(date.getDate()).padStart(2, '0');
        let hours = String(date.getHours()).padStart(2, '0');
        let minutes = String(date.getMinutes()).padStart(2, '0');
        let seconds = String(date.getSeconds()).padStart(2, '0');

        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    }

    saveResultHandler() {
        this.isLoading = true;
        // console.log('Save Work Result:::', JSON.stringify(this.workOrderResults,null,2));
        // console.log('Delete Work Result:::', JSON.stringify(this.deleteWorkResults,null,2));
        if(this.workOrderResults.length === 0) {
            this.showToast('ERROR', 'No data to save.');
            this.isLoading = false;
            return;
        } else {
             // 🔥 필수 필드 검증 (null 또는 공백 체크)
            let invalidRecords = this.workOrderResults.filter(record =>
                !record.WorkDate ||
                !record.WorkStartTime ||
                !record.WorkEndTime ||
                !record.WorkTime ||
                !record.TravelHour ||
                !record.AirTrip
            );

            if (invalidRecords.length > 0) {
                this.showToast('ERROR', 'There are missing required fields.');
                this.isLoading = false;
                return;
            }
        }
        // 🔥 TravelHour 값이 숫자(정수 또는 소수)인지 검증
        let invalidTravelHours = this.workOrderResults.filter(record => {
            let travelHour = record.TravelHour;

            if (isNaN(travelHour) || travelHour === '' || travelHour === null) {
                return true;
            }

            if (!/^\d+(\.\d{1})?$/.test(travelHour)) {
                return true;
            }

            return false;
        });

        if (invalidTravelHours.length > 0) {
            this.showToast('ERROR', 'Travel Hour must be a decimal number with at least one decimal place.');
            this.isLoading = false;
            return;
        }

        saveWorkOrderResults({
            workOrderId: this.recordId,
            saveResults: JSON.stringify(this.workOrderResults),
            deleteResults: this.deleteWorkResults
         })
        .then((data) => {
            if(data.isSuccess) {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: data.message,
                    variant: 'success'
                }));
                setTimeout(() => {
                    this.dispatchEvent(
                        new CloseActionScreenEvent()
                    );
                }, 1500);
            } else {
                this.showToast('ERROR', data.message);
                this.isLoading = false;
            }
        });
    }

    styleCSS() { // 함수 이름 바꿔줬음
        const style = document.createElement('style');
                style.innerText = `
                    .modal-container:has(c-d-n_-mobile-service-dates-and-times) {
                        width: 960px !important;
                        max-width: none !important;
                    }
                    .wrapper .btn-wrap .slds-button {
                        padding: 0.5rem;
                    }
                    .wrapper .btn-wrap .slds-button svg {
                        margin-right: 0;
                    }
                    .wrapper .input-wrap .slds-dropdown-trigger, .wrapper .input-wrap .input-text, .wrapper .input-wrap lightning-combobox>div {
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                    }
                    .wrapper .input-wrap .slds-form-element__control {
                        padding-left: 0;
                    }
                `;
                this.template.querySelector('div').appendChild(style);
    }
}