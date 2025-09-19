/**
 * @description       : Portal Service 화면 별 Wrapper 
 * @author            : Chungwoo Lee
 * @last modified on  : 03-10-2025
 * @last modified by  : Chungwoo Lee
**/
public with sharing class DN_PortalServiceWrapper {

    @AuraEnabled public String      workOrderId                 { get; set; } // WorkOrder ID
    @AuraEnabled public String      workOrderNumber             { get; set; } // CRM 워크오더번호
    @AuraEnabled public String      serviceOrderNumber          { get; set; } // SAP 워크오더번호
    @AuraEnabled public String      templateNumber              { get; set; } // 컴포넌트 확인 및 오더 유형2 라벨 
    @AuraEnabled public Boolean     isSavePortal                { get; set; } // 리포트 저장 유무 확인
    @AuraEnabled public Boolean     isConfirmed                 { get; set; } // 리포트 Confirmed 확인
    @AuraEnabled public String      workOrderResultId           { get; set; } // WorkOrderResult Id
    @AuraEnabled public String      resultType                  { get; set; } // Work Order Result Type
    @AuraEnabled public String      actionDetail                { get; set; } // 조치내역
    @AuraEnabled public Decimal     inspectionScore             { get; set; } // 검수점수

    @AuraEnabled public ServiceReportInfo           serviceReportInfo        { get; set; }
    @AuraEnabled public InstallTestInfo             installTestInfo          { get; set; }
    @AuraEnabled public RepairHistoryInfo           repairHistoryInfo        { get; set; }
    @AuraEnabled public List<WorkList>              workList                 { get; set; }
    @AuraEnabled public List<DefectList>            defectList               { get; set; }
    @AuraEnabled public List<StandardWorkList>      standardWorkList         { get; set; }
    @AuraEnabled public List<ProductRequestList>    productRequestList       { get; set; }

    public DN_PortalServiceWrapper () {
        this.serviceReportInfo          = new ServiceReportInfo();
        this.installTestInfo            = new InstallTestInfo();
        this.repairHistoryInfo          = new RepairHistoryInfo();
        this.workList                   = new List<WorkList>();
        this.defectList                 = new List<DefectList>();
        this.standardWorkList           = new List<StandardWorkList>();
        this.productRequestList         = new List<ProductRequestList>();
    }
    
    // 서비스 리포트 Common 정보
    public class ServiceReportInfo {
        @AuraEnabled public String      machineName             { get; set; } // 기종
        @AuraEnabled public String      assetName               { get; set; } // 호기
        @AuraEnabled public String      objectType              { get; set; } // 수리내역 고장부위 그룹 Type
        @AuraEnabled public String      notiNumber              { get; set; } // 통지번호
        @AuraEnabled public String      warranty                { get; set; } // 보증여부(공임/부품)
        @AuraEnabled public String      installDate             { get; set; } // 설치 완료일
        @AuraEnabled public String      orderType               { get; set; } // 오더유형 1
        @AuraEnabled public String      workOrderType           { get; set; } // 오더유형 2
        @AuraEnabled public String      workOrderTypeCode       { get; set; } // 오더유형 2 코드
        @AuraEnabled public Date        createdDate             { get; set; } // 작업배정일
        @AuraEnabled public Boolean     warrantyService         { get; set; } // 본사배정여부

        @AuraEnabled public String      accountName             { get; set; } // 고객사
        @AuraEnabled public String      requester               { get; set; } // 요청자
        @AuraEnabled public String      contactPhone            { get; set; } // 연락처
        @AuraEnabled public String      representative          { get; set; } // 대표자명
        @AuraEnabled public String      accountAddress          { get; set; } // 고객사 주소
        @AuraEnabled public String      accountTel              { get; set; } // 고객사 전화번호
        @AuraEnabled public String      applicationDateTime     { get; set; } // 접수 일시
        @AuraEnabled public String      repairRequestDateTime   { get; set; } // 수리 요청 일시
        @AuraEnabled public String      ReceptionDetails        { get; set; } // 접수내용
        @AuraEnabled public String      failureStatus           { get; set; } // 고장상태

        @AuraEnabled public String      workCenter              { get; set; } // W/C
        @AuraEnabled public String      confirmedDate           { get; set; } // 확정처리일시

        @AuraEnabled public String      siteManager             { get; set; } // 현장책임자
        @AuraEnabled public String      siteManagerPhone        { get; set; } // 현장책임자 휴대폰
        @AuraEnabled public String      mainWorker              { get; set; } // 주 작업자
        @AuraEnabled public String      mainWorkerPhone         { get; set; } // 주 작업자 휴대폰

        // Model Manager Data
        @AuraEnabled public Decimal     mainInstallTime         { get; set; } // 본설치시간 (Hours)
        @AuraEnabled public Decimal     tempInstallTime         { get; set; } // 가설치시간 (Hours)
        @AuraEnabled public Decimal     fenseApcCover           { get; set; } // Fense/APC Cover Time
        @AuraEnabled public Decimal     semiSplashGuard         { get; set; } // Semi Splash Guard Time
        @AuraEnabled public Decimal     overTools               { get; set; } // 90 Tools 이상 
        @AuraEnabled public Decimal     isOPTNHR4               { get; set; } // 6PMG Time
        @AuraEnabled public Decimal     isACC6stUp              { get; set; } // AAC(6st 이상) Time

        // DNSA
        @AuraEnabled public String      reportType              { get; set; } // DNSA Service Report : Report Type
        @AuraEnabled public String      controllerModel         { get; set; } // DNSA Service Report : Controller Model
        @AuraEnabled public String      controllerSerial        { get; set; } // DNSA Service Report : Controller Serial #

        @AuraEnabled public Date        repairStartDate         { get; set; } // DNSA Service Report : Repair Start Date
        @AuraEnabled public Date        repairEndDate           { get; set; } // DNSA Service Report : Repair End Date
        @AuraEnabled public String      failureDate             { get; set; } // DNSA Service Report : Fialure Date

        @AuraEnabled public Boolean     isMachineDown           { get; set; } // DNSA Service Report : Machine Down
        @AuraEnabled public String      serviceEngineerName     { get; set; } // DNSA Service Report : Service Engineer Name
        @AuraEnabled public Date        signatureDate           { get; set; } // DNSA Service Report : Signature Date
        @AuraEnabled public String      customerName            { get; set; } // DNSA Service Report : Customer Name
        @AuraEnabled public String      customerPosition        { get; set; } // DNSA Service Report : Customer Position
    }

    public class InstallTestInfo {
        @AuraEnabled public String      workOrderResultId       { get; set; } 
        @AuraEnabled public String      resultType              { get; set; } // Work Order Result Type
        @AuraEnabled public Date        installationFinish      { get; set; } // 설치 시운전 완료일
        @AuraEnabled public Boolean     isHEModel               { get; set; } // HE Care 1612 (대상 장비 여부)
        @AuraEnabled public Boolean     isHECare                { get; set; } // HE Care 1612 (체크 가능여부) 
        @AuraEnabled public Boolean     isHECareByAsset         { get; set; } // HE Care 1612 (체크 시 해당 장비에 케어 대상 여부)
        @AuraEnabled public Decimal     mainInstallTime         { get; set; } // 본설치시간 (Hours)
        @AuraEnabled public Decimal     tempInstallTime         { get; set; } // 가설치시간 (Hours)
        @AuraEnabled public Boolean     isTemporaryInstall      { get; set; } // 가설치 체크박스
        @AuraEnabled public Boolean     isHoliday               { get; set; } // (공)휴일여부
        @AuraEnabled public Decimal     specInstallTime         { get; set; } // 사양설치시간 (Hours)
        @AuraEnabled public Boolean     isFenseApcCover         { get; set; } // Fense/APC Cover
        @AuraEnabled public Boolean     isSemiSplashGuard       { get; set; } // Semi Splash Guard
        @AuraEnabled public Boolean     isOverTools             { get; set; } // 90 Tools 이상
        @AuraEnabled public Boolean     isPMG                   { get; set; } // 6PMG
        @AuraEnabled public Boolean     isAAC                   { get; set; } // AAC(6st 이상)
        @AuraEnabled public Boolean     isEtc                   { get; set; } // 기타 체크박스
        @AuraEnabled public Decimal     etcTime                 { get; set; } // 기타 시간 (Hours)   
        @AuraEnabled public String      reasonOfETC             { get; set; } // 사유
        @AuraEnabled public String      preparationOptions      { get; set; } // 고객사 준비상태
        @AuraEnabled public String      inspectionDetails       { get; set; } // 점검 확인 내용
        @AuraEnabled public Decimal     totalInstallTime        { get; set; } // 전체 설치시간
        @AuraEnabled public Decimal     totalInputTime          { get; set; } // 전체 입력시간

        @AuraEnabled public Decimal     fenseApcCover           { get; set; } // Fense/APC Cover Time (Hours)
        @AuraEnabled public Decimal     semiSplashGuard         { get; set; } // Semi Splash Guard Time (Hours)
        @AuraEnabled public Decimal     overTools               { get; set; } // 90 Tools 이상 Time  (Hours)
        @AuraEnabled public Decimal     pmgTime                 { get; set; } // 6PMG Time (Hours)
        @AuraEnabled public Decimal     accTime                 { get; set; } // AAC(6st 이상) Time (Hours)
    }

    public class RepairHistoryInfo {

        public RepairHistoryInfo(){
            this.selectedBrokenArea     = new SelectedBrokenArea();
            this.selectedPhenomenon     = new SelectedPhenomenon();
            this.selectedCauseArea      = new SelectedCauseArea();
            this.selectedRepairAction   = new SelectedRepairAction();
            this.selectedBrokenStatus   = new SelectedBrokenStatus();
        }   
            @AuraEnabled public String      workOrderResultId               { get; set; } // Work Order Id
            @AuraEnabled public String      resultType                      { get; set; } // Work Order Result Type
            @AuraEnabled public String      worker                          { get; set; } // 보고자
            @AuraEnabled public Date        defectDate                      { get; set; } // 하자발생일
            @AuraEnabled public Date        receiptDate                     { get; set; } // 접수일
            @AuraEnabled public Date        actionCallDate                  { get; set; } // 조치 요구일

            @AuraEnabled public String      responsibleDepartment           { get; set; } // 책임 부서
            @AuraEnabled public String      pendingOrCustomerMatters        { get; set; } // 미결 또는 고객 이슈
            @AuraEnabled public Decimal     totalWorkTime                   { get; set; } // 총 작업 시간
            @AuraEnabled public Decimal     totalStandardWorkTime           { get; set; } // 총 표준 작업 시간
            @AuraEnabled public Decimal     overWork                        { get; set; } // 초과 작업 시간
            @AuraEnabled public String      reasonForOrverWork              { get; set; } // 초과 작업 사유
            @AuraEnabled public String      repairHistoryReporter           { get; set; } // 보고자 (임시)

            @AuraEnabled public SelectedBrokenArea selectedBrokenArea       { get; set; } // 고장 부위
            @AuraEnabled public SelectedPhenomenon selectedPhenomenon       { get; set; } // 고장 현상
            @AuraEnabled public SelectedCauseArea selectedCauseArea         { get; set; } // 고장 원인
            @AuraEnabled public SelectedRepairAction selectedRepairAction   { get; set; } // 조치 사항
            @AuraEnabled public SelectedBrokenStatus selectedBrokenStatus   { get; set; } // 고장 상태 
        }

        public class SelectedBrokenArea { 
            public SelectedBrokenArea(){}
            
            @AuraEnabled public String      brokenAreaGroup             { get; set; } // 고장 부위 그룹
            @AuraEnabled public String      brokenAreaCode              { get; set; } // 고장 부위 코드
            @AuraEnabled public String      failureArea                 { get; set; } // 고장 부위
            @AuraEnabled public String      failureAreaDetail           { get; set; } // 고장 부위 상세
            @AuraEnabled public String      brokenAreaPart              { get; set; } // 고장 부위 + 부위 상세  
            @AuraEnabled public String      phenomenonGroup             { get; set; } // 고장 현상 그룹
        }

        public class SelectedPhenomenon {             
            public SelectedPhenomenon(){}
            
            @AuraEnabled public String      phenomenonCode              { get; set; } // 고장 현상 코드
            @AuraEnabled public String      phenomenonPart              { get; set; } // 고장 현상
            @AuraEnabled public String      phenomenonDetail            { get; set; } // 고장 현상 상세
            @AuraEnabled public String      causeAreaGroup              { get; set; } // 고장 원인 그룹
        }

        public class SelectedCauseArea {             
            public SelectedCauseArea(){}
            
            @AuraEnabled public String      causeAreaCode               { get; set; } // 고장 원인 코드
            @AuraEnabled public String      causeAreaPart               { get; set; } // 고장 원인
            @AuraEnabled public String      causeAreaDetail             { get; set; } // 고장 원인 상세
        }

        public class SelectedRepairAction {             
            public SelectedRepairAction(){}
            
            @AuraEnabled public String      repairActionCode            { get; set; } // 수리 조치 코드
            @AuraEnabled public String      repairActionPart            { get; set; } // 수리 조치
            @AuraEnabled public String      repairActionDetail          { get; set; } // 수리 조치 상세
        }

        public class SelectedBrokenStatus {             
            public SelectedBrokenStatus(){}
            
            @AuraEnabled public String      brokenStatusCode            { get; set; } // 고장 상태 코드
            @AuraEnabled public String      brokenStatusPart            { get; set; } // 고장 상태 
        }

        public class WorkList {
            public WorkList(){
                this.worker     = new Worker();
            }

            @AuraEnabled public Worker      worker                      { get; set; } // 작업자
            @AuraEnabled public Date        workDate                    { get; set; } // 작업일
            @AuraEnabled public Date        workEndDate                 { get; set; } // 작업종료일 (설치시운전에서만 사용)
            @AuraEnabled public String      workStartTime               { get; set; } // 시작시간
            @AuraEnabled public String      workEndTime                 { get; set; } // 종료시간
            @AuraEnabled public String      workTime                    { get; set; } // 작업시간
            @AuraEnabled public String      workType                    { get; set; } // 작업구분
            @AuraEnabled public String      description                 { get; set; } // 작업내용
            @AuraEnabled public String      travelHour                  { get; set; } // DNSA Report Travel Hour
            @AuraEnabled public String      airTripType                 { get; set; } // DNSA Report Air Trip
            @AuraEnabled public Boolean     isHoliday                   { get; set; } // 납품 후 교육 휴일 여부

            @AuraEnabled public String      workOrderResultId           { get; set; } // Work Order Result Id
            @AuraEnabled public String      serviceAppointmentId        { get; set; } // Service Appointment Id
            @AuraEnabled public String      saKey                       { get; set; } // Work Order Result Id
            @AuraEnabled public String      resultType                  { get; set; } // Work Order Result Type
        }

        public class Worker {
            @AuraEnabled public String      Id                          { get; set; } // Service Resource Id
            @AuraEnabled public String      Name                        { get; set; } // Service Resource Name
            @AuraEnabled public Boolean     workerType                  { get; set; } // Service Resource (Main) or (Sub)
        }
        
        public class DefectList {
            public DefectList(){}

            @AuraEnabled public String      defectType                  { get; set; } // 작업일
            @AuraEnabled public String      defectDetail                { get; set; } // 시작시간
            @AuraEnabled public String      defectAction                { get; set; } // 종료시간
            @AuraEnabled public String      note                        { get; set; } // 작업시간
            
            @AuraEnabled public String      workOrderResultId           { get; set; } // Work Order Result Id
            @AuraEnabled public String      resultType                  { get; set; } // Work Order Result Type
        }

        public class StandardWorkList {
            public StandardWorkList(){}

            @AuraEnabled public String      breakDownPart               { get; set; } // 고장 부위
            @AuraEnabled public String      standardWorkItem            { get; set; } // 표준 공수 이름
            @AuraEnabled public Decimal     standardWorkTime            { get; set; } // 표준 공수 시간
            @AuraEnabled public Decimal     standardWorkPeople          { get; set; } // 표준 공수 인원
            @AuraEnabled public Boolean     isChangeStandardWork        { get; set; } // 표준 공수 변경 여부
            @AuraEnabled public Decimal     actualWorkTime              { get; set; } // 실제 공수 시간
            @AuraEnabled public Decimal     actualWorkPeople            { get; set; } // 실제 공수 인원
            @AuraEnabled public String      changeRequestReason         { get; set; } // 표준 공수 변경 사유
            @AuraEnabled public String      standardHourId              { get; set; } // 표준 공수 마스터 ID

            @AuraEnabled public String      workOrderResultId           { get; set; } // Work Order Result Id
            @AuraEnabled public String      resultType                  { get; set; } // Work Order Result Type
        }

        public class ProductRequestList {
            // public ProductRequestList(){
            //     this.product     = new Product();
            // }

            @AuraEnabled public String      productCode                 { get; set; } // 품번
            @AuraEnabled public String      productName                 { get; set; } // 품명
            @AuraEnabled public Boolean     isCause                     { get; set; } // 원인부품
            @AuraEnabled public Decimal     quantity                    { get; set; } // 수량
            @AuraEnabled public String      returnNote                  { get; set; } // 비고

            @AuraEnabled public String      workOrderResultId           { get; set; } // Work Order Result Id
            @AuraEnabled public String      resultType                  { get; set; } // Work Order Result Type
        }

        // public class Product {
        //     @AuraEnabled public String      ProductCode                 { get; set; } // Product Code
        //     @AuraEnabled public String      Name                        { get; set; } // Product Name
        // }
        
}