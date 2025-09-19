/**
 * AS 접수 테스트 시나리오
 * 
 * 1. URL 파라미터 접근 시나리오
 *    - Case 1: ?tel=전화번호 파라미터로 접근
 *      > 자동으로 전화번호 입력 및 고객 조회
 *      > 조회 성공 시 2페이지(장비정보)로 자동 이동
 *    - Case 2: ?hogi=장비번호 파라미터로 접근
 *      > 2페이지에서 제조번호 옵션 자동 선택 및 번호 입력
 * 
 * 2. 일반 접근 시나리오 (파라미터 없음)
 *    - Case 1: 신규 고객
 *      > 1페이지에서 이름, 전화번호 필수 입력
 *      > 다음 버튼 클릭 시 고객 정보 조회
 *      > 고객 정보 없음 확인 후 2페이지로 이동
 *      > 제조번호 입력 옵션 자동 선택
 *    - Case 2: 기존 고객
 *      > 1페이지에서 이름, 전화번호 필수 입력
 *      > 다음 버튼 클릭 시 고객 정보 조회
 *      > 고객 정보 및 장비 목록 확인 후 2페이지로 이동
 * 
 * 3. 장비 정보 입력 시나리오
 *    - Case 1: 장비선택
 *      > 기존 고객의 장비 목록에서 선택
 *      > 장비 검색 기능으로 필터링 가능
 *    - Case 2: 제조번호 입력
 *      > 신규 장비 제조번호 직접 입력
 *    - Case 3: 명판사진 업로드
 *      > 장비 명판 사진 업로드 (이미지 파일만 가능)
 * 
 * 4. 페이지 이동 시나리오
 *    - Case 1: 이전 버튼으로 1페이지 복귀
 *      > 1페이지로 돌아가면 이름, 전화번호 재검증 필요
 *      > 다음 버튼 클릭 시 고객 정보 재조회
 *    - Case 2: 각 페이지 유효성 검사
 *      > 1페이지: 이름, 전화번호 필수
 *      > 2페이지: 선택된 옵션에 따른 필수값 검증
 *      > 3페이지: 필수 입력 항목 검증
 * 
 * 5. 에러 처리 시나리오
 *    - Case 1: 고객 정보 조회 실패
 *      > 에러 메시지 토스트 알림 표시
 *    - Case 2: 장비 정보 저장 실패
 *      > 에러 메시지 토스트 알림 표시
 *    - Case 3: 필수 입력값 누락
 *      > 해당 필드에 에러 메시지 표시
 */

import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCustomerAssetList from '@salesforce/apex/DN_ASRegisterController.getCustomerAssetList';
import setEquipInfo from '@salesforce/apex/DN_ASRegisterController.setEquipInfo';
import setCustomerRequest from '@salesforce/apex/DN_ASRegisterController.setCustomerRequest';
import getServiceCenterList from '@salesforce/apex/DN_ASRegisterController.getServiceCenterList';
import createNewCustomer from '@salesforce/apex/DN_ASRegisterController.createNewCustomer';
import searchAssets from '@salesforce/apex/DN_ASRegisterController.searchAssets';
import getEquipmentBySerialNo from '@salesforce/apex/DN_ASRegisterController.getEquipmentBySerialNo';
import checkWorkingHours from '@salesforce/apex/DN_ASRegisterController.checkWorkingHours';
import getExistEngineer from '@salesforce/apex/DN_ASRegisterController.getExistEngineer';
import deleteFiles from '@salesforce/apex/DN_ASRegisterController.deleteFiles';
import validationNow from '@salesforce/apex/DN_ASRegisterController.validationNow';

import ToastContainer from 'lightning/toastContainer';
import Toast from 'lightning/toast';


// 디버깅을 위한 유틸리티 함수 추가
function debugLog(...args) {
    // Experience Site에서도 보이는 디버그 로그
    if (window.location.href.includes('experience.')) {
        // 개발자 도구의 Elements 탭에서 확인 가능한 HTML 코멘트로 로그 출력
        const debugElement = document.createElement('div');
        debugElement.style.display = 'none';
        debugElement.className = 'debug-log';
        debugElement.textContent = JSON.stringify(args);
        document.body.appendChild(debugElement);
    } else {
        // 일반 환경에서는 console.log 사용
        console.log(...args);
    }
}

export default class AsRegister extends NavigationMixin(LightningElement) {
    @api recordId;
    @track currentSection = 'account'; // account, asset, request
    @track isLoading = false;
    @track isMobile = true; // 모바일 환경 기본값
    @track showCheckComponent = false;

    // 고객정보
    @track contactName = '';
    @track contactPhoneNumber = '';

    // 장비정보
    @track selectedOption = '';
    @track radioOptions = [
        { label: '장비선택', value: '1' },
        { label: '제조번호', value: '2' },
        { label: '명판사진', value: '3' }
    ];
    @track assetOptions = [];
    @track filteredAssetOptions = [];
    @track selectedAssetId = '';
    @track serialNumber = '';
    @track nameplateFiles = [];
    @track assetMessage = '';

    // 요청정보
    @track accountName = '';
    @track postalCode = '';
    @track address = '';
    @track addressDetail = '';
    @track symptom = '';
    @track servicePart = '';
    @track request = '';
    @track selectedProgressMethod = 'technicalCouncel';
    @track isRepairService = false;
    @track progressMethodOptions = [
        { label: '기술상담', value: 'technicalCouncel' },
        { label: '출동수리', value: 'repairService' }
    ];
    @track requestDate = '';
    @track requestTime = '';
    @track timeType = 'morning';
    @track uploadedFiles = [];

    @track serviceCenters = [];
    @track selectedServiceCenter;

    @track selectedDate;
    @track selectedTime = '11:00';

    @track serialNo = '';
    @track isNewEquipment = false;

    @track assetSearchKey = '';
    @track showAssetDropdown = false;
    @track selectedAsset = null;
    @track isSearching = false;
    @track existEngineer = true;
    
    @track receiptMethod = 'KAKAO';

    @track notification = {
        show: false,
        variant: 'info',
        message: ''
    };

    @track uploadedFileIds=[]; //파일업로드 ID

    // 디버그 관련 추가
    @track debugMode = true;  // 디버그 모드 활성화
    @track debugMessages = [];  // 디버그 메시지 저장 배열
    @track lastToast = null;  // 마지막 토스트 메시지 저장

    @track isNightShift = false;

    // 섹션 표시 부
    get isAccountInfoSection() {
        return this.currentSection === 'account';
    }

    get isAssetInfoSection() {
        return this.currentSection === 'asset';
    }

    get isRequestInfoSection() {
        return this.currentSection === 'request';
    }

    // 장비정보 관련
    get isAssetSelectOption() {
        return this.selectedOption === '1';
    }

    get isSerialNumberOption() {
        return this.selectedOption === '2';
    }

    get isNameplatePhotoOption() {
        return this.selectedOption === '3';
    }

    get isAssetSearchDisabled() {
        return !this.accountId;
    }

    get isSerialNumberDisabled() {
        return !this.isSerialNumberOption;
    }

    get isNameplateUploadDisabled() {
        return !this.isNameplatePhotoOption;
    }

    // 파일 업로드 관련
    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg', '.gif', '.mp4'];
    }

    get acceptedImageFormats() {
        return ['.png', '.jpg', '.jpeg'];
    }

    // 요청시간 관련
    get isRepairService() {
        return this.selectedProgressMethod === 'repairService';
    }

    get showCustomTimeSelect() {
        return this.timeType === 'custom';
    }

    get isMorningSelected() {
        return this.timeType === 'morning' ? 'brand' : 'neutral';
    }

    get isAfternoonSelected() {
        return this.timeType === 'afternoon' ? 'brand' : 'neutral';
    }

    get isCustomTimeSelected() {
        return this.timeType === 'custom' ? 'brand' : 'neutral';
    }

    get timeOptions() {
        return [
            { label: '오전 7시', value: '7' },
            { label: '오전 8시', value: '8' },
            { label: '오전 9시', value: '9' },
            { label: '오전 10시', value: '10' },
            { label: '오전 11시', value: '11' },
            { label: '오후 12시', value: '12' },
            { label: '오후 1시', value: '13' },
            { label: '오후 2시', value: '14' },
            { label: '오후 3시', value: '15' },
            { label: '오후 4시', value: '16' },
            { label: '오후 5시', value: '17' },
            { label: '오후 6시', value: '18' },
            { label: '오후 7시', value: '19' },
            { label: '오후 8시', value: '20' },
            { label: '오후 9시', value: '21' },
            { label: '오후 10시', value: '22' }
        ];
    }

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxToasts = 5;
        toastContainer.toastPosition = 'top-right';

        // URL 쿼리 파라미터 처리
        const urlParams = new URL(window.location.href).searchParams;
        const tel = urlParams.get('tel');
        const hogi = urlParams.get('hogi');

        if (tel) {
            this.receiptMethod = 'ARS';
            this.contactPhoneNumber = tel;
            this.accountPhone = tel;
            // tel 파라미터가 있을 경우에만 자동으로 2페이지로 이동
            this.searchCustomerInfo(true);
        }

        if (hogi) {
            this.receiptMethod = 'QR';
            this.currentSection = 'asset';
            this.serialNumber = hogi;
            this.serialNo = hogi;
            this.selectedOption = '2';
            
            // hogi 파라미터가 있는 경우 장비 정보 조회 후 3페이지로 이동
            this.handleSerialNoSubmit().then((result) => {
                if (result && result.success) {
                    if (!this.isNewEquipment) {
                        // 기존 장비인 경우 정보 표시
                        this.accountName = result.accountName || '';
                        this.address = result.state||'';
                        if(this.address != '')  this.address+=' ';
                        this.address += result.city||'';
                        this.addressDetail = result.street || '';
                        // this.address = result.street || '';
                        // this.addressDetail = result.city || '';
                        this.postalCode = result.postalCode || '';
                    }
                    // 3페이지로 이동
                    this.currentSection = 'request';
                }
            }).catch(error => {
                console.error('Error in hogi processing:', error);
                this.showToast('오류', '장비 정보 조회 중 오류가 발생했습니다.', 'error');
            });
        }

        this.checkMobileDevice();
        window.addEventListener('resize', this.checkMobileDevice.bind(this));
        // const now = new Date();
        // const hours = now.getHours();
        // const minutes = now.getMinutes();
        // if ((hours > 17 || (hours === 17 && minutes >= 20)) && hours < 21) {
        //     this.loadServiceCenters();
        // }
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.checkMobileDevice.bind(this));
    }
    
    checkMobileDevice() {
        this.isMobile = window.innerWidth <= 768;
    }

    // 연락처로 고객정보 검색
    async searchCustomerInfo(moveToAsset = false) {
        if (!this.isLoading) {
            this.isLoading = true;
            try {
                const result = await getCustomerAssetList({ 
                    searchText: this.contactPhoneNumber, 
                    searchType: 'phone' 
                });
                
                if (result) {
                    // ID 값들을 명시적으로 저장
                    this.accountId = result.accountId;
                    this.contactId = result.contactId;
                    
                    // 나머지 정보 저장
                    this.accountName = result.accountName || '';
                    this.accountPhone = result.accountPhone || '';
                    this.postalCode = result.postalCode || '';
                    // this.address = result.street || '';
                    this.address = result.state||'';
                    if(this.address != '')  this.address+=' ';
                    this.address += result.city||'';
                    this.addressDetail = result.street || '';
                    
                    if (result.accountId) {
                        await this.searchAssets('');
                        if (!this.assetOptions.length) {
                            this.selectedOption = '2'; // 제조번호 옵션
                        }
                        // URL에서 tel 파라미터로 접근한 경우에만 2페이지로 이동
                        if (moveToAsset) {
                            this.currentSection = 'asset';
                        }
                    } else {
                        // 고객 정보가 없는 경우 새로운 고객 생성
                        // const customerResult = await createNewCustomer({
                        //     name: this.contactName,
                        //     phone: this.contactPhoneNumber
                        // });
                        // if (customerResult) {
                        //     this.accountId = customerResult.accountId;
                        //     this.contactId = customerResult.contactId;
                        //     this.accountName = customerResult.accountName || '';
                        //     this.accountPhone = customerResult.accountPhone || '';
                        //     this.postalCode = customerResult.postalCode || '';
                        //     this.address = customerResult.street || '';
                        // }
                        // this.assetMessage = result.assetMessage || '고객 정보가 없습니다.';
                    }
                }
            } catch (error) {
                console.error('Error:', error);
                this.showToast('오류', error.body?.message || '고객 정보 조회 중 오류가 발생했습니다.', 'error');
            } finally {
                this.isLoading = false;
            }
        }
    }

    // 제조번호로 Asset(장비) 조회
    async handleSerialNoSubmit() {
        if (!this.serialNo && !this.serialNumber) {
            this.showToast('경고', '장비 번호를 입력해주세요.', 'warning');
            return;
        }
        
        const serialNoToUse = this.serialNo || this.serialNumber;
        const searchPhoneNumber = this.contactPhoneNumber;
        try {
            this.isLoading = true;
            const result = await getEquipmentBySerialNo({ serialNo: serialNoToUse, contactPhoneNumber: searchPhoneNumber});
            if (result.success) {
                if (result.found) {
                    // 장비를 찾은 경우
                    this.accountId = result.accountId;
                    this.accountName = result.accountName;
                    this.accountPhone = result.accountPhone;
                    this.postalCode = result.postalCode;
                    this.address = result.state||'';
                    if(this.address != '')  this.address+=' ';
                    this.address += result.city||'';
                    this.addressDetail = result.street || '';
                    // this.address = result.street;
                    // this.addressDetail = result.city;
                    this.serialNo = result.serialNo;
                    this.serialNumber = result.serialNo;
                    this.selectedAssetId = result.equipmentId;
                    return result;
                } else {
                    // 장비를 찾지 못한 경우에도 입력된 제조번호로 계속 진행
                    this.serialNo = serialNoToUse;
                    this.serialNumber = serialNoToUse;
                    this.selectedAssetId = '';
                    return { success: true };
                }
            }
            return { success: true };
        } catch (error) {
            console.error('Error in handleSerialNoSubmit:', error);
            // 에러가 발생하더라도 입력된 제조번호로 계속 진행
            if (error.body?.message?.includes('List has no rows for assignment')) {
                this.serialNo = serialNoToUse;
                this.serialNumber = serialNoToUse;
                return { success: true };
            } else {
                this.showToast('오류', '장비 정보 조회 중 오류가 발생했습니다.', 'error');
                return { success: false };
            }
        } finally {
            this.isLoading = false;
        }
    }

    async loadServiceCenters() {
        try {
            // 근무시간 체크
            const workingHoursResult = await checkWorkingHours();
            
            // API 응답 결과 상세 출력
            console.log('=== 근무시간 체크 API 응답 ===');
            console.log('성공 여부:', workingHoursResult.success);
            console.log('근무시간 여부:', workingHoursResult.isWork);
            console.log('근무 코드:', workingHoursResult.code);
            console.log('근무 상태:', workingHoursResult.name);
            console.log('스케줄 타입:', workingHoursResult.scheduleType);
            console.log('스케�� 이름:', workingHoursResult.scheduleName);
            console.log('전체 응답 데이터:', workingHoursResult.responseData);
            
            this.isNightShift = !workingHoursResult.isWork;
            console.log('야간근무 여부:', this.isNightShift);
            
            // 야간근무일 때만 서비스센터 목록 로드
            if (this.isNightShift) {
                const result = await getServiceCenterList();
                this.serviceCenters = result;
                console.log('서비스센터 목록:', this.serviceCenters);
            } else {
                this.serviceCenters = [];
                console.log('주간근무 시간으로 서비스센터 목록이 표시되지 않습니다.');
            }
        } catch (error) {
            console.error('근무시간 체크 오류:', error);
            this.showToast('오류', '근무시간 API 오류', 'error');
        }
    }

    // 이벤트 핸들러
    handleContactNameChange(event) {
        this.contactName = event.target.value;
    }

    handlePhoneNumberChange(event) {
        this.contactPhoneNumber = event.target.value;
        
        // URL에서 tel 파라미터로 접근한 경우가 아닐 때는 자동 조회하지 않음
        const urlParams = new URL(window.location.href).searchParams;
        const tel = urlParams.get('tel');
        if (!tel) return;
        
        // tel 파라미터가 있는 경우에만 자동 조회
        if (this.contactPhoneNumber && this.contactPhoneNumber.length >= 10) {
            if (this.searchTimer) {
                clearTimeout(this.searchTimer);
            }
            this.searchTimer = setTimeout(() => {
                this.searchCustomerInfo(true);
            }, 300);
        }
    }
    
    //장비 검색
    async searchAssets(searchKey) {
        this.addDebugMessage('Searching Assets', { searchKey, accountId: this.accountId });
        
        if (!this.isSearching && this.accountId) {
            this.isSearching = true;
            try {
                const result = await searchAssets({ 
                    accountId: this.accountId, 
                    searchKey: searchKey 
                });
                
                this.addDebugMessage('Search Result', result);
                
                if (result) {
                    this.selectedOption = '1';
                    this.assetOptions = result.options || [];
                    this.filteredAssetOptions = [...this.assetOptions];
                    this.showAssetDropdown = true;
                    
                    // 이전에 선택된 장비가 있다면 해당 장비 정보 복원
                    if (this.selectedAssetId) {
                        const selectedOption = this.assetOptions.find(option => option.value === this.selectedAssetId);
                        if (selectedOption) {
                            this.assetSearchKey = selectedOption.label;
                        }
                    }
                    
                    if (this.assetOptions.length === 0) {
                        this.assetMessage = '검색된 장비가 없습니다';
                    } else {
                        this.assetMessage = '';
                    }
                }
            } catch (error) {
                this.addDebugMessage('Search Error', error);
                this.showToast('오류', error.body?.message || '장비 검색 중 오류가 발생했습니다', 'error');
                this.assetMessage = '장비 검색 중 오류가 발생했습니다';
            } finally {
                this.isSearching = false;
            }
        }
    }

    handleAssetOptionChange(event) {
        const previousOption = this.selectedOption;
        this.selectedOption = event.target.value;
        
        // 옵션 변경 시 이전 데이터 초기화
        this.selectedAssetId = '';
        this.serialNo = '';
        this.serialNumber = '';
        this.assetSearchKey = '';
        this.selectedAsset = null;
        
        if (this.selectedOption === '1') {
            // 장비 선택 옵션으로 변경 시
            this.showAssetDropdown = true;
            if (previousOption !== '1') {
                // 전체 목록 복원
                this.filteredAssetOptions = [...this.assetOptions];
            }
        }
    }

    handleAssetSearch(event) {
        const searchText = event.target.value.toLowerCase();
        this.assetSearchKey = event.target.value;
        // 검색어에 따라 필터링된 목록 업데이트
        this.filteredAssetOptions = this.assetOptions.filter(option => 
            option.label.toLowerCase().includes(searchText)
        );
        this.showAssetDropdown = true;
    }

    handleAssetSelect(event) {
        const selectedValue = event.currentTarget.dataset.value;
        console.log('Selected Value:', selectedValue);
        
        // 전체 목록에서 선택된 장비 찾기
        const selectedOption = this.assetOptions.find(option => option.value === selectedValue);
        console.log('Found Selected Option:', JSON.stringify(selectedOption));
        
        if (selectedOption) {
            // 상태 업데이트
            this.selectedAsset = selectedOption;
            this.selectedAssetId = selectedValue;
            this.equipmentNo = selectedValue;
            this.assetSearchKey = selectedOption.label;
            
            // 제조번호 직접 설정 (ML0006-006231 형식)
            this.serialNo = selectedOption.label.split(' ')[0];
            this.serialNumber = this.serialNo;
            console.log('Set Serial No:', this.serialNo);
            
            // 드롭다운 닫기
            this.showAssetDropdown = false;

            this.handleSerialNoSubmit().then((result) => {
                if (result && result.success && result.found) {
                    this.accountName = result.accountName || '';
                    this.address = result.state||'';
                    if(this.address != '')  this.address+=' ';
                    this.address += result.city||'';
                    this.addressDetail = result.street || '';
                    this.postalCode = result.postalCode || '';
                }
            }).catch(error => {
                this.showToast('오류', '장비 정보 조회 중 오류가 발생했습니다.', 'error');
            });

            // 상태 업데이트 확인
            console.log('Updated State:', {
                selectedAssetId: this.selectedAssetId,
                equipmentNo: this.equipmentNo,
                serialNo: this.serialNo,
                serialNumber: this.serialNumber,
                assetSearchKey: this.assetSearchKey
            });
        }
    }

    handleAssetSearchBlur() {
        // 클릭 이벤트가 발생할 시간을 주기 위해 지연 추가
        setTimeout(() => {
            if (!this.template.contains(document.activeElement)) {
                this.showAssetDropdown = false;
            }
        }, 300);
    }

    handleAssetSearchFocus() {
        if (this.selectedOption === '1') {
            // 포커스 시 전체 목록 복원 및 드롭다운 표시
            this.filteredAssetOptions = [...this.assetOptions];
            this.showAssetDropdown = true;
        }
    }

    handleSerialNumberChange(event) {
        const value = event.target.value;
        this.serialNo = value;
    }

    // 제조번호 입력 완료 시 자동 조회
    // async handleSerialNumberBlur(event) {
    //     const serialNumber = event.target.value;
    //     console.log('serialNumber1', serialNumber);
    //     if (serialNumber && serialNumber.trim()) {
    //         await this.handleSerialNoSubmit();
    //     }
    // }

    handleNameplateUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const imageTypes = ['png', 'jpg', 'jpeg'];

        // console.log('recordId', recordId);
        console.log('명판:', JSON.stringify(event.detail));
        console.log('명판:', JSON.stringify(uploadedFiles));
        
        // 이미지 파일 형식 검증
        const invalidFiles = uploadedFiles.filter(file => {
            const extension = file.name.split('.').pop().toLowerCase();
            return !imageTypes.includes(extension);
        });

        if (invalidFiles.length > 0) {
            this.showToast('경고', '이미지 파일(PNG, JPG, JPEG)만 업로드 가능합니다.', 'warning');
            return;
        }

        this.uploadedFileIds = [...this.uploadedFileIds, ...uploadedFiles.map(file => file.contentVersionId)];
        this.nameplateFiles = [...this.nameplateFiles, ...uploadedFiles.map(file => ({
            contentVersionId: file.contentVersionId,
            title: file.name,
            downloadUrl: `/sfc/servlet.shepherd/version/download/${file.ContentVersionId}`
        }))];

        console.log('명판업로드:'+JSON.stringify(this.uploadedFileIds));
        console.log('명판업로드:'+JSON.stringify(this.nameplateFiles));
        this.showToast('성공', '명판사진이 성공적으로 업로드되었습니다.', 'success');
    }

    handleNameplateDelete(event) {
        const contentVersionId = event.currentTarget.dataset.id;
        this.isLoading = true;
        //화면에서 파일삭제
        this.uploadedFileIds = this.uploadedFileIds.filter(fileId => {
            const file = this.nameplateFiles.find(f => f.contentVersionId === contentVersionId);
            return file ? file.contentVersionId !== fileId : true;
        });
        this.nameplateFiles = this.nameplateFiles.filter(file => file.contentVersionId !== contentVersionId);

        //파일obj 에서 삭제
        deleteFiles({ contentVersionId: contentVersionId })
        .then(() => {
            this.showToast('성공', '파일이 삭제되었습니다.', 'success');
        })
        .catch(error => {
            console.error('Error deleting record:', error);
            this.showToast('오류', error.body?.message || '파일 삭제 중 오류가 발생했습니다.', 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
        this.isLoading = false;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        
        if (uploadedFiles && uploadedFiles.length > 0) {
            // 파일 크기 검증 (50MB)
            const oversizedFiles = uploadedFiles.filter(file => file.size > 52428800);
            if (oversizedFiles.length > 0) {
                this.showToast('경고', '50MB 이하의 파일만 업로드 가능합니다.', 'warning');
                return;
            }
            
            this.uploadedFileIds = [...this.uploadedFileIds, ...uploadedFiles.map(file => file.contentVersionId)];
            this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles.map(file => ({
                contentVersionId: file.contentVersionId,
                title: file.name,
                downloadUrl: `/sfc/servlet.shepherd/version/download/${file.contentVersionId}`
            }))];
            console.log('Uploaded files:', JSON.stringify(this.uploadedFiles));
            this.showToast('성공', '파일이 성공적으로 업로드되었습니다.', 'success');
        } else {
            console.error('No files were uploaded or files array is empty');
        }
    }

    async handleDeleteFile(event) {
        const contentVersionId = event.currentTarget.dataset.id;
        this.isLoading = true;
        //화면에서 파일삭제
        this.uploadedFileIds = this.uploadedFileIds.filter(fileId => {
            const file = this.uploadedFiles.find(f => f.contentVersionId === contentVersionId);
            return file ? file.contentVersionId !== fileId : true;
        });
        this.uploadedFiles = this.uploadedFiles.filter(file => file.contentVersionId !== contentVersionId);

        console.log('삭제할 파일::::'+contentVersionId);
        //파일obj 에서 삭제
        deleteFiles({ contentVersionId: contentVersionId })
        .then(() => {
            this.showToast('성공', '파일이 삭제되었습니다.', 'success');
        })
        .catch(error => {
            console.error('Error deleting record:', error);
            this.showToast('오류', error.body?.message || '파일 삭제 중 오류가 발생했습니다.', 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
        this.isLoading = false;
    }

    handleProgressMethodChange(event) {
        this.selectedProgressMethod = event.target.value;
        this.isRepairService = this.selectedProgressMethod === 'repairService';
        console.log('Progress method changed:', this.selectedProgressMethod);
        console.log('Is repair service:', this.isRepairService);
    }

    handleMorningClick() {
        this.timeType = 'morning';
    }

    handleAfternoonClick() {
        this.timeType = 'afternoon';
    }

    handleCustomTimeClick() {
        this.timeType = 'custom';
    }

    handleRequestDateChange(event) {
        this.requestDate = event.target.value;
    }

    handleRequestTimeChange(event) {
        this.requestTime = event.target.value;
    }

    handleAccountNameChange(event) {
        this.accountName = event.target.value;
        console.log('accountName changed:', this.accountName);
    }

    handlePostalCodeChange(event) {
        this.postalCode = event.target.value;
        console.log('postalCode changed:', this.postalCode);
    }

    handleAddressChange(event) {
        this.address = event.target.value;
        console.log('address changed:', this.address);
    }

    handleAddressDetailChange(event) {
        this.addressDetail = event.target.value;
        console.log('addressDetail changed:', this.addressDetail);
    }

    handleSymptomChange(event) {
        this.symptom = event.target.value;
        console.log('symptom changed:', this.symptom);
    }

    handleServicePartChange(event) {
        this.servicePart = event.target.value;
        console.log('servicePart changed:', this.servicePart);
    }

    handleRequestChange(event) {
        this.request = event.target.value;
        console.log('request changed:', this.request);
    }

    // 네비게이션
    async handleNext() {
        switch(this.currentSection) {
            case 'account':
                if (!this.validateFirstPage()) return;
                
                try {
                    this.isLoading = true;
                    const result = await getCustomerAssetList({
                        searchText: this.contactPhoneNumber,
                        searchType: 'phone'
                    });
                    
                    if (result) {
                        this.accountId = result.accountId;
                        this.contactId = result.contactId;
                        this.accountName = result.accountName || '';
                        this.accountPhone = result.accountPhone || '';
                        this.postalCode = result.postalCode || '';
                        this.address = result.state||'';
                        if(this.address != '')  this.address+=' ';
                        this.address += result.city||'';
                        this.addressDetail = result.street || '';
                        // this.address = result.street || '';
                        // this.addressDetail = result.street || '';
                        
                        if (result.accountId) {
                            await this.searchAssets('');
                        } else {
                            this.assetMessage = result.assetMessage || '고객 정보가 없습니다.';
                            this.selectedOption = '2';
                        }
                        this.currentSection = 'asset';
                    }
                } catch (error) {
                    this.showToast('오류', error.body?.message || '고객 정보 조회 중 오류가 발생했습니다.', 'error');
                } finally {
                    this.isLoading = false;
                }
                break;

            case 'asset':
                if (!this.validateAssetInfo()) return;
                
                // 장비 선택 옵션인 경우 선택된 장비의 정보 확인
                if (this.selectedOption === '1' && this.selectedAssetId) {
                    const selectedOption = this.assetOptions.find(option => option.value === this.selectedAssetId);
                    if (selectedOption) {
                        const serialMatch = selectedOption.label.split(' ');//selectedOption.label.match(/\((.*?)\)/);
                        if (serialMatch && serialMatch[0]) {
                            this.serialNo = serialMatch[0];
                            this.serialNumber = serialMatch[0];
                            console.log('Setting serialNo in handleNext:', this.serialNo);
                        }
                    }
                }
                // 제조번호 입력 옵션인 경우 입력된 값 확인
                else if (this.selectedOption === '2') {
                    const serialNoToUse = this.serialNo || this.serialNumber;
                    console.log('serialNo =>', this.serialNo);
                    console.log('serialNoToUse =>', serialNoToUse);
                    console.log('user =>', this.accountId);
                    console.log('phone =>', this.contactPhoneNumber);
                    const result = await getEquipmentBySerialNo({
                        serialNo: this.serialNo,
                        contactPhoneNumber: this.contactPhoneNumber
                    });

                    console.log('result => ', result);
                    console.log('result => ', JSON.stringify(result));

                    if(result) {
                        this.accountId = result.accountId || '';
                        this.contactId = result.contactId || '';
                        this.accountName = result.accountName || '';
                        this.accountPhone = result.accountPhone || '';
                        this.postalCode = result.postalCode || '';
                        this.address = result.state||'';
                        if(this.address != '')  this.address+=' ';
                        this.address += result.city||'';
                        this.addressDetail = result.street || '';
                    }


                }   
                
                console.log('selectedAssetId ::: ', this.selectedAssetId);
                const result = await getExistEngineer({
                    selectedAssetId: this.selectedAssetId
                });
                console.log('result', result);
                this.existEngineer = !result;
        
                // 3페이지로 이동하기 전에 serialNo 값 확
                console.log('Moving to request page with serialNo:', this.serialNo);
                this.currentSection = 'request';
                break;

            case 'request':
                console.log('handleSubmit 실행!');
                this.handleSubmit();
                break;
        }
    }

    handlePrevious() {
        console.log('이전버튼::::'+this.currentSection);
        if (this.currentSection === 'asset') {
            // 장비 정보 초기화
            this.selectedOption = '';
            this.selectedAssetId = '';
            this.serialNo = '';
            this.assetSearchKey = '';
            this.selectedAsset = null;
            this.currentSection = 'account';
        } else if (this.currentSection === 'request') {
            this.currentSection = 'asset';
            //주소 초기화
            this.accountId = '';
            this.contactId = '';
            this.accountName = '';
            this.accountPhone = '';
            this.postalCode = '';
            this.addressDetail = '';
            this.address = '';

        }
    }

    // 유효성 검사
    validateAccountInfo() {
        const inputs = [...this.template.querySelectorAll('lightning-input')];
        return inputs.reduce((valid, input) => {
            input.reportValidity();
            return valid && input.checkValidity();
        }, true);
    }

    validateAssetInfo() {
        console.log('[Debug] Validating Asset Info:', {
            selectedOption: this.selectedOption,
            selectedAsset: this.selectedAsset,
            selectedAssetId: this.selectedAssetId,
            serialNo: this.serialNo,
            nameplateFiles: this.nameplateFiles
        });

        if (!this.selectedOption) {
            this.showToast('오류', '장비선택 옵션을 선택해주세요.', 'error');
            return false;
        }

        // 선택된 옵션에 따라서만 유효성 검사
        switch(this.selectedOption) {
            case '1': // 장비선택
                if (!this.selectedAssetId && !this.selectedAsset) {
                    console.log('[Debug] Asset Selection Failed:', {
                        selectedAssetId: this.selectedAssetId,
                        selectedAsset: this.selectedAsset
                    });
                    this.showToast('오류', '장비를 선택해주세요.', 'error');
                    return false;
                }
                break;
            case '2': // 제조번호
                if (!this.serialNo) {
                    this.showToast('오류', '제조번호를 입력해주세요.', 'error');
                    return false;
                }
                break;
            case '3': // 명판사진
                if (!this.nameplateFiles.length) {
                    this.showToast('오류', '명판사진을 업로드해주세요.', 'error');
                    return false;
                }
                break;
        }
        
        console.log('[Debug] Asset Info Validation Passed');
        return true;
    }

    validateRequestInfo() {
        // 이름과 전화번호 검증
        if (!this.contactName || !this.contactPhoneNumber) {
            this.showToast('오류', '이름과 전화번호를 입력해주세요.', 'error');
            return false;
        }

        // 업체명 주소 검증
        if (!this.accountName || !this.address) {
            this.showToast('오류', '업체명과 주소를 입력해주세요.', 'error');
            return;
        }

        // 증상 입력 검증
        if (!this.symptom || this.symptom.trim() === '') {
            this.showToast('오류', '증상을 입력해주세요.', 'error');
            return false;
        }

        // 출동수리인 경우 요청시간 검증
        if (this.selectedProgressMethod === 'repairService') {
            if (!this.selectedDate) {
                this.showToast('오류', '요청일자를 선택해주세요.', 'error');
                return false;
            }
            if (!this.selectedTime) {
                this.showToast('오류', '요청시간을 선택해주세요.', 'error');
                return false;
            }
            
            // 야간근무일 때만 서비스센터 선택 필수
            if (this.isNightShift && !this.selectedServiceCenter) {
                this.showToast('오류', '서비스센터를 선택해주세요.', 'error');
                return false;
            }
        }

        return true;
    }

    // 접수 처리
    async handleSubmit() {
        console.log('handleSubmit 실행');
        if (!this.validateRequestInfo()) {
            return;
        }
        
        this.isLoading = true;

        try {
            if(this.selectedProgressMethod == 'repairService'){
                const result = await validationNow({
                    selectedDate: this.selectedDate,
                    selectedTime: this.selectedTime
                });
                if(result == 'Error'){
                    this.showToast('오류', '요청시간은 현재시간 이후로 선택가능합니다.', 'error');
                    return;
                }
            }
            // if (!this.contactId) {
            //     const customerResult = await createNewCustomer({
            //         name: this.contactName,
            //         phone: this.contactPhoneNumber,
            //         accountName: this.accountName,
            //         postalCode: this.postalCode,
            //         street: this.address,
            //         city: this.addressDetail
            //     });
                
            //     if (customerResult) {
            //         this.accountId = customerResult.accountId;
            //         this.contactId = customerResult.contactId;
            //     }
            // }

            // 장비 정보 설정
            console.log('accountId => ', this.accountId);
            console.log('serialNo => ', this.serialNo);
            console.log('equipmentNo => ', this.selectedAssetId);

            const equipmentInfo = {
                accountId: this.accountId == undefined?'':this.accountId,
                contactId: this.contactId == undefined?'':this.contactId,
                accountName: this.accountName,
                accountPostalCode: this.postalCode,
                accountAddress: this.address,
                accountDetailAddress: this.addressDetail,
                symptom: this.symptom,
                servicePart: this.servicePart,
                request: this.request,
                progressWay: this.selectedProgressMethod,
                selectedFileIds: this.uploadedFileIds,
                contactPhoneNumber: this.contactPhoneNumber,
                contactName: this.contactName,
                repairRequestDate: this.selectedDate,
                requestTime: this.selectedTime,
                serialNo: this.serialNo,
                equipmentNo: this.selectedAssetId,
                selectedServiceCenter: this.selectedServiceCenter,
                nightShift: this.isNightShift,
                existEngineer: this.existEngineer,
                receiptMethod: this.receiptMethod,
                equipmentCheck: this.selectedOption
            };

            console.log('접수데이터🎉🎉:::'+JSON.stringify(equipmentInfo));
            // return;
            await setCustomerRequest(equipmentInfo);
            Toast.show({
                label: '성공적으로 A/S 접수가 완료되었습니다.',
                variant: 'Success',
                onclose: () => {
                }
             }, this);

            this.showCheckComponent = true;
        } catch (error) {
            console.error('Error in handleSubmit:', error);
            this.showToast('오류', error.body?.message || 'AS 접수 중 오류가 발생했습니다.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // 퍼 메소드
    getFormattedReservationTime() {
        if (!this.isRepairService || !this.requestDate) return null;

        let timeStr = '';
        if (this.timeType === 'morning') {
            timeStr = '오전';
        } else if (this.timeType === 'afternoon') {
            timeStr = '오후';
        } else if (this.timeType === 'custom' && this.requestTime) {
            const hour = parseInt(this.requestTime);
            timeStr = hour < 12 ? `오전 ${hour}시` : `오후 ${hour - 12}시`;
        }

        return `${this.requestDate} ${timeStr}`;
    }

    resetForm() {
        this.currentSection = 'account';
        this.contactName = '';
        this.contactPhoneNumber = '';
        this.selectedOption = '';
        this.selectedAssetId = '';
        this.serialNumber = '';
        this.uploadedFileIds = [];
        this.accountName = '';
        this.postalCode = '';
        this.address = '';
        this.addressDetail = '';
        this.symptom = '';
        this.servicePart = '';
        this.request = '';
        this.selectedProgressMethod = 'technicalCouncel';
        this.requestDate = '';
        this.requestTime = '';
        this.timeType = 'morning';
        this.nameplateFiles = [];
        this.uploadedFiles = [];
    }

    showToast(title, message, variant) {
        // Experience Site URL 체크
        const isExperienceSite = window.location.href.includes('my.site.com');
        
        if (isExperienceSite) {
            // Experience Site용 커스텀 토스트
            const toastContainer = document.createElement('div');
            toastContainer.style.cssText = `
                position: fixed;
                top: 16px;
                right: 16px;
                z-index: 10000;
                min-width: 320px;
                max-width: 480px;
                background: white;
                box-shadow: 0 3px 6px rgba(0,0,0,0.16);
                border-radius: 4px;
                padding: 12px 16px;
                font-size: 14px;
                transition: all 0.3s ease;
                opacity: 0;
                transform: translateY(-20px);
            `;

            const variantColors = {
                success: '#2ecc71',
                error: '#e74c3c',
                warning: '#f1c40f',
                info: '#3498db'
            };

            toastContainer.innerHTML = `
                <div style="display: flex; align-items: flex-start;">
                    <div style="flex-grow: 1;">
                        <div style="font-weight: bold; margin-bottom: 4px; color: ${variantColors[variant] || variantColors.info}">
                            ${title}
                        </div>
                        <div style="color: #666;">
                            ${message}
                        </div>
                    </div>
                    <button style="background: none; border: none; color: #999; cursor: pointer; padding: 0 4px;" 
                            onclick="this.parentElement.parentElement.remove()">
                        
                    </button>
                </div>
            `;

            document.body.appendChild(toastContainer);

            // 애니메이션 효과
            requestAnimationFrame(() => {
                toastContainer.style.opacity = '1';
                toastContainer.style.transform = 'translateY(0)';
            });

            // 3초 후 자동으로 제거
            setTimeout(() => {
                toastContainer.style.opacity = '0';
                toastContainer.style.transform = 'translateY(-20px)';
                setTimeout(() => {
                    if (toastContainer.parentElement) {
                        toastContainer.remove();
                    }
                }, 300);
            }, 3000);
        } else {
            // Lightning Experience용 기 토스트
            this.dispatchEvent(
                new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: variant,
                    mode: 'dismissable'
                })
            );
        }
    }

    handleNotificationClose() {
        this.notification.show = false;
    }

    

    handleServiceCenterChange(event) {
        this.selectedServiceCenter = event.detail.value;
        console.log('Selected Service Center:', this.selectedServiceCenter);
    }

    get formattedReservationTime() {
        if (this.selectedProgressMethod !== 'repairService' || !this.selectedDate) {
            return null;
        }
        return `${this.selectedDate} ${this.selectedTime}:00`;
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
        console.log('Selected date:', this.selectedDate);
    }

    handleTimeChange(event) {
        this.selectedTime = event.target.value;
        console.log('Selected time:', this.selectedTime);
    }

    //???어디사용???
    async handlePhoneSearch() {
        if (!this.accountPhone) {
            this.showToast('경고', '전화번호를 입력해주세요.', 'warning');
            return;
        }

        try {
            this.isLoading = true;
            const result = await getCustomerAssetList({
                searchText: this.accountPhone,
                searchType: 'phone'
            });

            if (result) {
                this.accountId = result.accountId;
                this.accountName = result.accountName;
                this.postalCode = result.postalCode;
                this.address = result.state||'';
                if(this.address != '')  this.address+=' ';
                this.address += result.city||'';
                this.addressDetail = result.street || '';
                // this.address = result.street;
                // this.addressDetail = result.city;
                
                if (result.assetMessage) {
                    // 고객 정보가 없는 경우
                    this.showToast('알림', result.assetMessage, 'info');
                    const newCustomer = await createNewCustomer({
                        searchText: this.accountPhone
                    });
                    if (newCustomer) {
                        this.accountId = newCustomer.accountId;
                    }
                }
            }
        } catch (error) {
            console.error('Error:', error);
            this.showToast('오류', error.body?.message || '고객 정보 조회 중 오류가 발생했습니다.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleSerialNoChange(event) {
        this.serialNo = event.target.value;
    }

    

    // 콤보박스 관련 getter
    get comboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${
            this.showAssetDropdown ? 'slds-is-open' : ''
        }`;
    }

    get searchPlaceholder() {
        return this.accountId ? '장비를 검색하세요' : '장비정보가 없습니다';
    }

    // 알림톡 저장 시 필요한 데이터 검증
    validateCustomerInfo() {
        if (!this.contactPhoneNumber) {
            this.showToast('오류', '전화번호를 입력해주세요.', 'error');
            return false;
        }
        return true;
    }

    // 진행 상태 시 관련 getter
    get progressValue() {
        switch(this.currentSection) {
            case 'account': return 33;
            case 'asset': return 66;
            case 'request': return 100;
            default: return 0;
        }
    }

    get progressStyle() {
        return `width: ${this.progressValue}%`;
    }

    get progressText() {
        return `${this.progressValue}%`;
    }

    get nextButtonLabel() {
        return this.currentSection === 'request' ? '제출' : '다음';
    }

    // 첫 페이지 유효성 검사
    validateFirstPage() {
        let isValid = true;
        const inputs = this.template.querySelectorAll('lightning-input');
        
        inputs.forEach(input => {
            if (input.name === 'contactName' || input.name === 'contactPhoneNumber') {
                if (!input.value) {
                    input.setCustomValidity('이 필드는 필수입니다.');
                } else {
                    input.setCustomValidity('');
                }
                input.reportValidity();
                if (!input.checkValidity()) {
                    isValid = false;
                }
            }
        });
        
        if (!this.contactName || !this.contactPhoneNumber) {
            this.showToast('오류', '이름과 전화번호를 입력해주세요.', 'error');
            return false;
        }
        
        return isValid;
    }

    // 디버그 메시지 추가 메소드
    addDebugMessage(message, data) {
        const timestamp = new Date().toLocaleTimeString();
        this.debugMessages.unshift({
            time: timestamp,
            message: message,
            data: JSON.stringify(data, null, 2)
        });
        // 최대 50개까지만 저장
        if (this.debugMessages.length > 50) {
            this.debugMessages.pop();
        }
    }

    // 디버그 정보 표시를 위한 getter
    get debugInfo() {
        return {
            currentSection: this.currentSection,
            accountId: this.accountId,
            contactId: this.contactId,
            assetOptions: this.assetOptions?.length || 0,
            filteredAssetOptions: this.filteredAssetOptions?.length || 0,
            showAssetDropdown: this.showAssetDropdown,
            assetMessage: this.assetMessage,
            isSearching: this.isSearching,
            lastToast: this.lastToast
        };
    }

    // 장비번호 라벨 getter 추가
    get equipmentNumberLabel() {
        // 장비선택 옵션인 경우 '장비번호'로 표시
        if (this.selectedOption === '1') {
            return '장비번호';
        }
        // 그 외의 경우(hogi 모드, 제조번호 입력) '제조번호'로 표시
        return '제조번호';
    }
}