/**
 * @author            : Hayeong Min
 * @description       : Ticket 상세화면에서 알림톡 버튼 화면
 * @last modified on  : 2025-07-21
 * @last modified by  : Hayeong Min
**/
public with sharing class DN_CheckAlarmTalkBtnController {

    /**
     * @Description
     * 	- 알림톡 접수 내용 및 관련 사진/동영상 정보 조회하는 Method
     * @author Hayeong Min 
    **/ 
    @AuraEnabled
    public static CommonWrapper getAlarmTalkInfo(String recordId){
        CommonWrapper cw = new CommonWrapper();
        try {
            AlarmTalkWrapper aw = new AlarmTalkWrapper();

            //티켓번호, 티켓상태, 접수일시, 요청자, 요청자번호, 고객사, 고객사주소, 장비번호, 기종, 상담사, 상담사 전화번호, 접수유형(이건 항상 티켓유형(중)의 고장접수일 예정)
            Case ticket = [SELECT Id, CaseNumber, toLabel(Status), ApplicationDateTime__c, Requester__c, Requester__r.Name, FM_PhoneNumber__c, 
                                AccountId, Account.Name, FM_AccountAddress__c, 
                                AssetId, Asset.Name, FM_AssetMachineName__c, Asset.InstallationFinish__c,
                                OwnerId, Owner.Name, Owner.Phone,
                                toLabel(InternalTicketType__c), Asset.FM_WarrantyPeriodWages__c, ReceptionPath__c
                                FROM Case WHERE Id = :recordId];
            String path = ticket.ReceptionPath__c;
            
            //알림톡 접수인 Ticket이면 알림톡에 입력된 내용 우선
                aw.ticketNumber = ticket.CaseNumber;
                aw.ticketStatus = ticket.Status;
                aw.receptionDate = ticket.ApplicationDateTime__c;
                aw.contact = ticket.Requester__r.Name;
                aw.customerPhone = ticket.FM_PhoneNumber__c;
                aw.account = ticket.Account.Name;
                aw.address = ticket.FM_AccountAddress__c;
                aw.equipment = ticket.Asset.Name;
                aw.model = ticket.FM_AssetMachineName__c;
                aw.consultant = ticket.Owner.Name;
                aw.consultantPhone = ticket.Owner.Phone;
                aw.installDate = ticket.Asset.InstallationFinish__c;
                aw.isWarranty = ticket.Asset.FM_WarrantyPeriodWages__c;
                aw.receptionType = ticket.InternalTicketType__c;

            //path가 알림톡인 경우에는 알림톡 오브젝트 기반으로 정보 표출
            if(path == 'Alarm Talk'){
                List<AlarmTalk__c> alarmTalkList = [SELECT Id, Name, Ticket__c,
                                                            FM_Account__c, FM_Address__c, FM_Equipment__c, 
                                                            Contact__c, Contact__r.Name, Phone__c, 
                                                            toLabel(TheWayOfProceeding__c), RepairRequestDateTime__c, RequestedTerm__c, Symptom__c, ServicePart__c, W_C__c, W_C__r.Name

                                                    FROM AlarmTalk__c WHERE Ticket__c = :recordId 
                                                    ORDER BY CreatedDate DESC LIMIT 1];
                
                AlarmTalk__c alarmTalk = alarmTalkList.get(0);
                aw.account = alarmTalk.FM_Account__c;
                aw.equipment = alarmTalk.FM_Equipment__c;
                aw.contact = alarmTalk.Contact__r.Name;
                aw.customerPhone = alarmTalk.Phone__c;
                aw.failureSymtom = alarmTalk.Symptom__c;
                aw.request = alarmTalk.RequestedTerm__c;
                aw.requestType = alarmTalk.TheWayOfProceeding__c;
                if(alarmTalk.TheWayOfProceeding__c == 'Dispatch repair'){
                    aw.isVisit = true;
                    aw.visitDate = alarmTalk.RepairRequestDateTime__c;
                }
                aw.workCenter = alarmTalk.W_C__r.Name;

                aw.Id = alarmTalk.Id;
                
                
                //알림톡에 연결된 이미지/동영상 파일 목록
                List<ContentDocumentLink> fileList = [SELECT Id, ContentDocumentId, ContentDocument.FileType 
                                                      FROM ContentDocumentLink 
                                                      WHERE LinkedEntityId = :recordId
                                                      AND ContentDocument.CreatedBy.Name ='사이트 게스트 사용자 서비스센터'];
                if(fileList.size()>0) aw.cvList = fileList;
            }

            //오더번호, 배정일자, W/C, 작업자, 작업자번호, 수리요청일시, 방문예약일시
            List<WorkOrder> workOrderList = [SELECT Id, WorkOrderNumber, CreatedDate,
            ServiceTerritory.Name, Worker__c, Worker__r.Name, Worker__r.RelatedRecord.Phone, 
            FM_RepairRequestDateTime__c, TimeAgreedOnSite__c, ServiceOrderNumber__c
                                            FROM WorkOrder WHERE CaseId = :recordId
                                            ORDER BY CreatedDate DESC LIMIT 1];
            if(!workOrderList.isEmpty()){
                WorkOrder workOrder = workOrderList.get(0);
                aw.orderNumber = workOrder.ServiceOrderNumber__c;
                aw.assignDate = workOrder.CreatedDate;
                aw.workCenter = workOrder.ServiceTerritory.Name;
                aw.serviceResource = workOrder.Worker__r.Name;
                aw.serviceResourcePhone = workOrder.Worker__r.RelatedRecord.Phone;
                aw.requestRepairDate = workOrder.FM_RepairRequestDateTime__c;
                if(workOrder.TimeAgreedOnSite__c != null){
                    aw.isVisit = true;
                    aw.visitDate = workOrder.TimeAgreedOnSite__c;
                }
                
            }
            
            cw.returnValue = aw;

        } catch (Exception e) {
            cw.errMessage = e.getMessage();
            cw.isSuccess  = false;
        }
        return cw;
    }

    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     * 		- returnValue 			: 성공시 Return 값 
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		{get; set;}
        @AuraEnabled
        public String errMessage		{get; set;} 
        @AuraEnabled
        public AlarmTalkWrapper returnValue		{get; set;}
        @AuraEnabled
        public List<ContentDocumentLink> cvList		{get; set;}

        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnValue 	= new AlarmTalkWrapper();
            this.cvList 	    = new List<ContentDocumentLink>();
        }
    }

    /*
     * @Description
     * 		- 알림톡 접수 정보 Wrapper
     */
    public class AlarmTalkWrapper {
        @AuraEnabled 
        public String ticketNumber	{get;set;}
        @AuraEnabled 
        public String ticketStatus 	{get;set;}
        @AuraEnabled 
        public DateTime receptionDate 	{get;set;}
        @AuraEnabled 
        public String contact 	{get;set;}
        @AuraEnabled 
        public String customerPhone 	{get;set;}
        @AuraEnabled 
        public String account 	{get;set;}
        @AuraEnabled 
        public String address 	{get;set;}
        @AuraEnabled 
        public String equipment 	{get;set;}
        @AuraEnabled 
        public String model 	{get;set;}
        @AuraEnabled 
        public String failureSymtom 	{get;set;}
        @AuraEnabled 
        public String request 	{get;set;}
        @AuraEnabled 
        public DateTime requestRepairDate 	{get;set;}
        @AuraEnabled 
        public String requestType 	{get;set;}
        @AuraEnabled 
        public String orderNumber 	{get;set;}
        @AuraEnabled 
        public DateTime assignDate 	{get;set;}
        @AuraEnabled 
        public String consultant 	{get;set;}
        @AuraEnabled 
        public String consultantPhone 	{get;set;}
        @AuraEnabled 
        public String workCenter 	{get;set;}
        @AuraEnabled 
        public String serviceResource 	{get;set;}
        @AuraEnabled 
        public String serviceResourcePhone 	{get;set;}
        @AuraEnabled 
        public Date installDate 	{get;set;}
        @AuraEnabled 
        public String isWarranty 	{get;set;}
        @AuraEnabled 
        public String receptionType 	{get;set;}
        @AuraEnabled 
        public Boolean isVisit 	{get;set;}
        @AuraEnabled 
        public DateTime visitDate 	{get;set;}
        @AuraEnabled 
        public String Id 	{get;set;}

        @AuraEnabled 
        public String message 	{get;set;}     
        @AuraEnabled 
        public List<ContentDocumentLink> cvList 	{get;set;}     

        public AlarmTalkWrapper(){
            this.ticketNumber = '';
            this.ticketStatus = '';
            this.receptionDate = System.now();
            this.contact = '';
            this.customerPhone = '';
            this.account = '';
            this.address = '';
            this.equipment = '';
            this.model = '';
            this.failureSymtom = '';
            this.request = '';
            this.requestRepairDate = System.now();
            this.requestType = '';
            this.orderNumber = '';
            this.assignDate = System.now();
            this.consultant = '';
            this.consultantPhone = '';
            this.workCenter = '';
            this.serviceResource = '';
            this.serviceResourcePhone = '';
            this.installDate = System.now().date();
            this.isWarranty = '';
            this.receptionType = '';
            this.isVisit = false;
            this.visitDate = System.now();
            this.Id = '';

            this.message = '';
            this.cvList 	= new List<ContentDocumentLink>();
        }
    }
}