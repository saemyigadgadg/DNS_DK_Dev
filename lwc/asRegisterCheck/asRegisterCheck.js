/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-04-12
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkAlarmTalk from '@salesforce/apex/DN_ASRegisterController.checkAlarmTalk';
import cancelAlarmTalk from '@salesforce/apex/DN_ASRegisterController.cancelAlarmTalk';
import linkFileToAlarmTalk from '@salesforce/apex/DN_ASRegisterController.linkFileToAlarmTalk';
import getAttachedFiles from '@salesforce/apex/DN_ASRegisterController.getAttachedFiles';
import checkRepairRequestDateTime from '@salesforce/apex/DN_ASRegisterController.checkRepairRequestDateTime';
import deleteFile from '@salesforce/apex/DN_ASRegisterController.deleteFile';
import getPartsProgress from '@salesforce/apex/DN_ASRegisterController.getPartsProgress';
import getTicketInfo from '@salesforce/apex/DN_ASRegisterController.getTicketInfo';
import getOrderInfo from '@salesforce/apex/DN_ASRegisterController.getOrderInfo';
import ToastContainer from 'lightning/toastContainer';
import Toast from 'lightning/toast';


export default class AsRegisterCheck extends LightningElement {
    @track currentPage = 1;
    @track phoneNumber = '';
    @track alarmTalkList = [];
    @track showCancelDialog = false;
    @track showMediaDialog = false;
    @track selectedAlarmTalkId = '';
    @track uploadedFiles = [];
    @track isLoading = false;
    @track selectedCancelReason = '';
    @track showMediaSpinner = false;
    @track showMediaPreview = false;
    @track selectedMedia = null;
    @track showPartsDialog = false;
    @track partsList = [];
    @track isTicketNo = false;

    ticketNumber;
    toastVisible = false;
    message = false;

    get isPageOne() {
        return this.currentPage === 1;
    }

    get isPageTwo() {
        return this.currentPage === 2;
    }

    get cancelReasons() {
        return [
            { label: '이미 해결되었습니다.', value: '이미 해결되었습니다.' },
            { label: '지금은 바쁘니 나중에 다시 접수 할게요', value: '지금은 바쁘니 나중에 다시 접수 할게요' },
            { label: '기타', value: '기타' }
        ];
    }

    get acceptedFormats() {
        return ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.avi'];
    }

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxToasts = 5;
        toastContainer.toastPosition = 'top-right';
        
        console.log('connectedCallback');
        const urlParams = new URLSearchParams(window.location.search);
        console.log('urlParams', urlParams);
        if (urlParams.size > 0) {
            //ticket 번호 있을 때
            const ticket = urlParams.get('ticket');
            const SOrder = urlParams.get('serviceOrder');
            console.log('ticket', ticket);
            if (ticket != null) {
                this.ticketNumber = ticket;
                this.useTicketNo(ticket);
            } else {
                this.useOrderNo(SOrder);
            }
        }
    }

    renderedCallback() {
        this.adjustStyles();
    }

    useTicketNo(ticketNo) {
        this.isLoading = true;
        getTicketInfo({ ticketNo: ticketNo })
            .then((result) => {
                console.log('useTicketNO', result);
                if (result.isSuccess) {
                    console.log('useTicketNO result', result.returnList);
                    this.isTicketNo = true;
                    this.alarmTalkList = result.returnList;
                    this.currentPage = 2;
                } else {
                    console.log('ERROR', result.errMessage);
                    // this.showToast('오류', '조회된 A/S 정보가 없습니다.', 'error');
                    this.message = '조회된 A/S 정보가 없습니다.';
                    this.toastVisible = true;

                    setTimeout(() => {
                        this.toastVisible = false;
                    }, 3000);
                }   
            })
            .catch((error) => {
                console.error('Exception occurred:', error);
                // this.showToast('오류', '시스템 오류가 발생했습니다.', 'error');
                this.message = '시스템 오류가 발생했습니다.';
                this.toastVisible = true;

                setTimeout(() => {
                    this.toastVisible = false;
                }, 3000);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    useOrderNo(SOrder) {
        this.isLoading = true;
        getOrderInfo({ SOrder: SOrder })
            .then((result) => {
                console.log('useTicketNO', JSON.stringify( result));
                if (result.isSuccess) {
                    console.log('useTicketNO result', result.returnList);
                    console.log('useTicketNO CaseNumber', result.CaseNumber);
                    this.ticketNumber = result.CaseNumber;
                    this.isTicketNo = true;
                    this.alarmTalkList = result.returnList;
                    this.currentPage = 2;
                } else {
                    console.log('ERROR', result.errMessage);
                    // this.showToast('오류', '조회된 A/S 정보가 없습니다.', 'error');
                    this.message = '조회된 A/S 정보가 없습니다.';
                    this.toastVisible = true;

                    setTimeout(() => {
                        this.toastVisible = false;
                    }, 3000);
                }   
            })
            .catch((error) => {
                console.error('Exception occurred:', error);
                // this.showToast('오류', '시스템 오류가 발생했습니다.', 'error');
                this.message = '시스템 오류가 발생했습니다.';
                this.toastVisible = true;

                setTimeout(() => {
                    this.toastVisible = false;
                }, 3000);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // 알림톡 조회
    async handleSearch() {
        if (!this.isValidPhoneNumber(this.phoneNumber)) {
            // this.showToast('오류', '유효하지 않은 번호입니다. 번호를 제대로 기입해주세요.', 'error');
            this.message = '유효하지 않은 번호입니다. 번호를 제대로 기입해주세요.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);
            return;
        }

        try {
            this.isLoading = true;
            const result = await checkAlarmTalk({ phoneNumber: this.phoneNumber });
            if (result && result.length > 0) {
                console.log('result:::::::::::::'+JSON.stringify(result));
                this.alarmTalkList = result;
                this.currentPage = 2;
            } else {
                // this.showToast('알림', '조회된 A/S 정보가 없습니다.', 'info');
                this.message = '조회된 A/S 정보가 없습니다.';
                this.toastVisible = true;

                setTimeout(() => {
                    this.toastVisible = false;
                }, 3000);
            }
        } catch (error) {
            // this.showToast('오류', error.body?.message || '조회 중 오류가 발생했습니다.', 'error');
            this.message = error.body?.message + ' 조회 중 오류가 발생했습니다.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);
        } finally {
            this.isLoading = false;
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


    // 접수 취소
    handleCancel() {
        if (!this.selectedAlarmTalkId) {
            // this.showToast('오류', 'AS 접수 정보를 찾을 수 없습니다.', 'error');
            this.message = 'AS 접수 정보를 찾을 수 없습니다.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);
            return;
        }

        if (!this.selectedCancelReason) {
            // Toast.show({
            //     label: '취소사유를 선택하여 주십시오.',
            //     // labelLinks : [{
            //     //      'url': 'https://www.lightningdesignsystem.com/components/toast/',
            //     //      'label': 'Toast link'
            //     // }],
            //     // message: '취소사유를 선택하여 주세요.',
            //     // messageLinks: [{
            //     //     url: 'http://www.salesforce.com',
            //     //     label: 'Salesforce link'
            //     // }],
            //     // mode: 'sticky',
            //     variant: 'error',
            //     onclose: () => {
            //        // Do something after the toast is closed
            //     }
            //  }, this);
            // this.showToast('오류', '취소사유를 선택하여 주십시오.', 'error');
            this.message = '취소사유를 선택하여 주십시오.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);

            return;
        }

        this.isLoading = true;
        console.log('Cancel4 ::');

        // 서비스오더가 완료되었거나, 출발 혹은 도착 했을 경우 취소 실패
        checkRepairRequestDateTime({ caseId: this.selectedAlarmTalkId })
            .then((repairRequestCheck) => {
                console.log('repairRequestCheck', repairRequestCheck);

                if (repairRequestCheck.CancelCheck=='Y') {
                    // this.showToast('오류', '해당 건은 이미 서비스 완료 되었거나, 서비스 기사가 출발 하였습니다.', 'error');
                    this.message = '해당 건은 이미 서비스 완료 되었거나, 서비스 기사가 출발 하였습니다.';
                    this.toastVisible = true;

                    setTimeout(() => {
                        this.toastVisible = false;
                    }, 3000);
                    this.showCancelDialog = false;
                    throw new Error('서비스 완료 또는 출발 상태');
                }

                this.isLoading = true;
                return cancelAlarmTalk({
                    caseId: this.selectedAlarmTalkId,
                    cancelReason: this.selectedCancelReason
                });
            })
            .then((result) => {
                
                console.log('result', result);
                if (result === 'SUCCESS') {
                    console.log('성공 ::');
                    // this.showToast('성공', '접수가 취소되었습니다.', 'success');
                    this.message = '접수가 취소되었습니다.';
                    this.toastVisible = true;

                    setTimeout(() => {
                        this.toastVisible = false;
                    }, 3000);
                    this.isLoading = false;
                    this.showCancelDialog = false;
                    this.refreshData();
                } else {
                    console.log('실패 ::');
                    // this.showToast('오류', '취소에 실패하였습니다. 서비스센터에 문의하여 주십시오.', 'error');
                    this.message = '취소에 실패하였습니다. 서비스센터에 문의하여 주십시오.';
                    this.toastVisible = true;

                    setTimeout(() => {
                        this.toastVisible = false;
                    }, 3000);
                    this.isLoading = false; 
                }
            })
            .catch((error) => {
                console.error('오류 발생:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // 파일 업로드 처리
    async handleUploadFinished(event) {
        console.log('파일업로드:', JSON.stringify(event.detail));
        console.log('파일업로드 recordId::', this.selectedAlarmTalkId);
        if (!this.selectedAlarmTalkId) {
            // this.showToast('오류', 'AS 접수 정보를 찾을 수 없습니다.', 'error');
            this.message = 'AS 접수 정보를 찾을 수 없습니다.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);
            return;
        }
        
        const uploadedFiles = event.detail.files;
        try {
            this.showMediaSpinner = true;

            if(uploadedFiles.length > 0) {
                const promises = uploadedFiles.map(file =>
                    linkFileToAlarmTalk({
                        contentVersionId: file.contentVersionId, //file.documentId,
                        caseId: this.selectedAlarmTalkId
                    })
                );
                await Promise.all(promises);
                // this.showToast('성공', '파일이 업로드되었습니다.', 'success');
                this.message = '파일이 업로드되었습니다.';
                this.toastVisible = true;

                setTimeout(() => {
                    this.toastVisible = false;
                }, 3000);
                // 파일 목록 새로고침
                this.uploadedFiles = [];  // 목록 초기화
                await this.refreshMediaList();
                await this.refreshAlarmTalkList();
            } else {
                // this.showToast('오류','파일 업로드 중 오류가 발생했습니다.', 'error');
                this.message = '파일 업로드 중 오류가 발생했습니다.';
                this.toastVisible = true;

                setTimeout(() => {
                    this.toastVisible = false;
                }, 3000);
            }
            
        } catch (error) {
            // this.showToast('오류', error.body?.message || '파일 업로드 중 오류가 발생했습니다.', 'error');
            this.message = error.body?.message + ' 파일 업로드 중 오류가 발생했습니다.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);
        } finally {
            this.showMediaSpinner = false;
        }
    }

    // 파일 삭제 처리
    async handleDeleteFile(event) {
        event.stopPropagation();
        const contentDocumentId = event.target.dataset.id;

        try {
            this.showMediaSpinner = true;
            await deleteFile({ contentDocumentId:contentDocumentId, caseId: this.selectedAlarmTalkId });
            // this.showToast('성공', '파일이 삭제되었습니다.', 'success');
            this.message = '파일이 삭제되었습니다.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);

            // 파일 목록 새로고침
            this.uploadedFiles = [];  // 목록 초기화
            await this.refreshMediaList();
            await this.refreshAlarmTalkList();
        } catch (error) {
            // this.showToast('오류', error.body?.message || '파일 삭제 중 오류가 발생했습니다.', 'error');
            this.message = error.body?.message + ' 파일 삭제 중 오류가 발생했습니다.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);
        } finally {
            this.showMediaSpinner = false;
        }
    }

    // AS 접수 목록 새로고침
    async refreshAlarmTalkList() {
        console.log('this.phoneNumber>>'+this.phoneNumber);
        if (this.phoneNumber) {
            const result = await checkAlarmTalk({ phoneNumber: this.phoneNumber });
            if (result) {
                this.alarmTalkList = result;
            }
        } else {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.size > 0) {
                const ticket = urlParams.get('ticket');
                if(ticket != null) {
                    const result = await getTicketInfo({ ticketNo: this.ticketNumber })
                    if (result) {
                        this.alarmTalkList = result.returnList;
                    }
                }
            }
        }       

        
    }

    // 미디어 목록 새로고침
    async refreshMediaList() {
        if (!this.selectedAlarmTalkId) return;
        console.log('새로고침 selectedCaseId>>>'+this.selectedAlarmTalkId);
        try {
            const files = await getAttachedFiles({ caseId: this.selectedAlarmTalkId });
            this.uploadedFiles = [...files];  // 새로운 배열로 할당
            console.log('파일목록:::'+JSON.stringify(this.uploadedFiles));
        } catch (error) {
            this.uploadedFiles = [];
            // this.showToast('오류', error.body?.message || '파일 목록 조회 중 오류가 발생했습니다.', 'error');
            this.message = error.body?.message + ' 파일 목록 조회 중 오류가 발생했습니다.';
            this.toastVisible = true;

            setTimeout(() => {
                this.toastVisible = false;
            }, 3000);
        }
    }

    // 유틸리티 메서드
    isValidPhoneNumber(phone) {
        return /^[0-9]{10,11}$/.test(phone.replace(/-/g, ''));
    }

    // 이벤트 핸들러
    handlePhoneNumberChange(event) {
        this.phoneNumber = event.target.value;
    }

    handlePrevious() {
        this.currentPage = 1;
        this.alarmTalkList = [];
    }

    handleCancelReasonChange(event) {
        console.log('취소사유 선택');
        this.selectedCancelReason = event.detail.value;
    }

    toggleCancelDialog(event) {
        if (event) {
            this.selectedAlarmTalkId = event.currentTarget.dataset.id;
        }
        this.showCancelDialog = !this.showCancelDialog;
        if (!this.showCancelDialog) {
            this.selectedCancelReason = '';
        }
    }

    // 미디어 모달 토글
    async toggleMediaDialog(event) {
        if (event) {
            this.selectedAlarmTalkId = event.currentTarget.dataset.id;
            if (!this.showMediaDialog) {
                this.showMediaSpinner = true;
                try {
                    await new Promise(resolve => setTimeout(resolve, 100));
                    await this.refreshMediaList();
                } catch (error) {
                    console.error("목록 조회 실패:", error);
                } finally {
                    this.showMediaSpinner = false;
                }
            }
        }
        this.showMediaDialog = !this.showMediaDialog;
    }

    // 데이터 새로고침
    async refreshData() {
        if (this.phoneNumber) {
            await this.handleSearch();
        }
    }

    get accountName() {
        return this.alarmTalkList.length > 0 ?
            (this.alarmTalkList[0].Account__r ? this.alarmTalkList[0].Account__r.Name : '') : '';
    }

    get equipmentName() {
        return this.alarmTalkList.length > 0 ?
            (this.alarmTalkList[0].Equipment__r ? this.alarmTalkList[0].Equipment__r.Name : '') : '';
    }

    // 데이터 변환
    get computedAlarmTalks() {
        const statuses = ['Arrived', 'Started', 'Completed'];
        return this.alarmTalkList.map(talk => ({
            ...talk,
            CreatedDate: this.formatDateTime(talk.CreatedDate),
            computedAccountName: talk.AccountName,
            computedEquipmentName: talk.EquipmentMachineName,//talk.EquipmentName,
            computedEquipmentNumber: talk.EquipmentSerialNumber==''?talk.EquipmentName:talk.EquipmentSerialNumber, //시리얼번호가 없으면 Name
            computedCaseNumber: talk.CaseNumber,
            computedOrderNumber: talk.NotiNumber,
            computedPhone: talk.Phone || '',
            computedPhoneLink: `tel:${talk.Phone || ''}`,
            computedAddress: talk.Address || '',
            computedSymptom: talk.Symptom || '',
            computedRequest: talk.RequestedTerm || '',
            computedRequestedTerm: this.formatDateTime(talk.RepairRequestDateTime),
            computedServiceEngineer: talk.ServiceResource?talk.ServiceResource+' ('+talk.WorkCenter+')':null,
            computedServicePhone: talk.ServiceResourcePhone,
            computedServicePhoneLink: talk.ServiceResourcePhone ? `tel:${talk.ServiceResourcePhone}` : null,
            computedServicePart: talk.ServicePart || '',
            isCancelDisabled:talk.Name?.includes('[완료]') || talk.WorkOrderStatus?.includes('NoCancel'),
            mediaButtonLabel: talk.ContentDocumentLinks?.length > 0
                ? `사진/동영상 보기 (${talk.ContentDocumentLinks.length})`
                : '사진/동영상 추가'
        }));
    }


    formatDateTimeWithDay(dateTimeStr) {
        if (!dateTimeStr) return '';
        const dt = new Date(dateTimeStr);
        const days = ['일', '월', '화', '수', '목', '금', '토'];
        return dt.toLocaleDateString('ko-KR', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        }) + ` (${days[dt.getDay()]}요일)`;
    }

    formatDateTime(dateTimeStr) {
        if (!dateTimeStr) return '';
        const dt = new Date(dateTimeStr);
        return dt.toLocaleString('ko-KR', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });
    }

    // 미디어 클릭 처리
    handleMediaClick(event) {
        const fileId = event.currentTarget.dataset.id;
        const file = this.uploadedFiles.find(f => f.id === fileId);
        if (!file) return;

        if (file.isImage) {
            this.selectedMedia = file;
            this.showMediaPreview = true;
        } else if (file.isVideo) {
            window.open(file.downloadUrl, '_blank');
        }
    }

    // 파일 다운로드
    handleDownload() {
        if (this.selectedMedia) {
            window.open(this.selectedMedia.downloadUrl, '_blank');
        }
    }

    closeMediaPreview() {
        this.showMediaPreview = false;
        this.selectedMedia = null;
    }

    // 샘플 부품 데이터
    get sampleParts() {
        return {
            orderDate: '2024.12.02',
            serviceOrderNumber: '403930421',
            deliveryLocation: '엠엔티(MNT)부산사',
            items: [
                {
                    id: '1',
                    number: 'R45084',
                    name: '에어유니트/FILTER-REGULATOR',
                    quantity: 1,
                    status: '배송완료',
                    statusClass: 'slds-text-color_success',
                    deliveryDate: '2024.12.02'
                }
            ]
        };
    }

    async togglePartsDialog(event) {
        if (event) {
            this.selectedAlarmTalkId = event.currentTarget.dataset.id;
            try {
                this.isLoading = true;
                const selectedTalk = this.alarmTalkList.find(talk => talk.Id === this.selectedAlarmTalkId);
                
                if(selectedTalk.NotiNumber == '' || selectedTalk.NotiNumber ==undefined){
                    // this.showToast('오류', '출동기사가 배정되기 전으로 부품정보를 조회할 수 없습니다.', 'error');
                    this.message = '출동기사가 배정되기 전으로 부품정보를 조회할 수 없습니다.';
                    this.toastVisible = true;

                    setTimeout(() => {
                        this.toastVisible = false;
                    }, 3000);
                    return;
                }
                this.partsList = [];
                // 부품정보 조회 API 호출 
                const result = await getPartsProgress({
                    startDate: selectedTalk.CreatedDate,//접수일자
                    // partNumber: selectedTalk.computedServicePart,//서비스부품
                    orderNumber: selectedTalk.NotiNumber//오더번호
                });
                if(result.O_RETURN.TYPE == 'E'){
                    // this.showToast('오류', '부품정보가 없습니다.', 'error');
                    this.message = '부품정보가 없습니다.';
                    this.toastVisible = true;

                    setTimeout(() => {
                        this.toastVisible = false;
                    }, 3000);
                    return;
                }
                if (result.O_RETURN.TYPE == 'S' && result.T_O_LIST) {
                    this.partsList = result.T_O_LIST.map(part => ({
                        number: part.MATNR,
                        name: part.MAKTX,
                        quantity: part.KWMENG,
                        status: part.MATNR_TXT,
                        deliveryDate: part.PRETD3,
                        orderNumber: part.AUFNR
                    }));
                }
            } catch (error) {
                // this.showToast('오류', '부품정보 조회 중 오류가 발생했습니다.', 'error');
                this.message = '부품정보 조회 중 오류가 발생했습니다.';
                this.toastVisible = true;

                setTimeout(() => {
                    this.toastVisible = false;
                }, 3000);
                return;
            } finally {
                this.isLoading = false;
            }
        }
        this.showPartsDialog = !this.showPartsDialog;
    }

    togglePartsCloseDialog(){
        this.showPartsDialog = !this.showPartsDialog;
    }

    get isMediaButtonDisabled() {
        return !this.uploadedFiles || this.uploadedFiles.length === 0;
    }

    get mediaButtonLabel() {
        return this.uploadedFiles && this.uploadedFiles.length > 0
            ? `사진/동영상 보기 (${this.uploadedFiles.length})`
            : '사진/동영상 추가';
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
            @media screen and (max-width: 720px){
                .button-section {
                    flex-direction: column;
                    align-items: stretch;                    
                    gap: 0.5rem;
                    width: auto;
                    padding: 0 0.5rem;
                }
                .button-section > div {
                    width: 100%;
                }
                .button-section .slds-button {
                    width: 100%;
                }
            }
        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }
}