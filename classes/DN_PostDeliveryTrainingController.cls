/**
 * @related           : DN_PostDeliveryTrainingBtn
 * @description       : DO 내 납품 후 교육 생성
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-05-14   yeongju.yun   Initial Version
**/
public with sharing class DN_PostDeliveryTrainingController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 납품 후 교육 검증 규칙 & 초기값 셋팅
    **/
    @AuraEnabled
    public static ResultWrapper fetchInit(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {

            DeliveryOrder__c dOrder = [
                SELECT  Id, DeliveryDate__c
                        , Order__r.ShipTo_PSO__c, Order__r.ShipTo_PSO__r.FM_Address__c
                FROM    DeliveryOrder__c
                WHERE   Id =: recordId
            ];

            if (dOrder.DeliveryDate__c != null && dOrder.DeliveryDate__c < System.today().addMonths(-12)) {
                result.isPass   = false;
                result.errorMsg = System.Label.DNS_M_PostDeliveryTraining6Month; // Post-delivery training can only be created for delivery order with a delivery date within 6 months.
                return result;
            }

            List<GroupMember> groupMembers = [
                SELECT  Id, UserOrGroupId, UserOrGroup.Name
                FROM    GroupMember
                WHERE   Group.DeveloperName = 'eduRep'
            ];

            List<OptionWrapper> trainingOwnerOptions = new List<OptionWrapper>();
            for(GroupMember groupMember : groupMembers) {
                trainingOwnerOptions.add(new OptionWrapper(groupMember.UserOrGroup.Name, groupMember.UserOrGroupId));
            }
            result.data.put('trainingOwnerOptions', trainingOwnerOptions);

            // ShipTo_PSO__c
            result.data.put('shipToId', dOrder.Order__r.ShipTo_PSO__c);
            result.data.put('shipToAddress', dOrder.Order__r.ShipTo_PSO__r.FM_Address__c);

            List<Contact> contactList = [
                SELECT Id, Name, MobilePhone, Title
                FROM Contact 
                WHERE AccountId = :dOrder.Order__r.ShipTo_PSO__c
            ];

            List<AccRepInfo> accRepInfo = new List<AccRepInfo>();
            List<OptionWrapper> contactOptions = new List<OptionWrapper>();
            for(Contact con : contactList) {
                AccRepInfo wrap = new AccRepInfo();
                wrap.repId      = con.Id;
                wrap.repName    = con.Name;
                wrap.repMp      = con.MobilePhone != null ? con.MobilePhone : '000-0000-0000';
                wrap.repTitle   = con.Title != null ? con.Title : '직책 없음';
                accRepInfo.add(wrap);

                contactOptions.add(new OptionWrapper(wrap.repName, wrap.repId));
            }
            result.data.put('accRepInfo', accRepInfo);
            result.data.put('contactOptions', contactOptions);

             // convert picklist to options
            result.data.put('trainingCountOptions', ordSvc.getPicklistWrap('Case', 'TrainingCount__c'));
            result.data.put('trainingTypeOptions', ordSvc.getPicklistWrap('Case', 'TrainingType__c'));
            result.data.put('traineeLevelOptions', ordSvc.getPicklistWrap('Case', 'TraineeLevel__c'));

            User currentUser = [ SELECT Id, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
            result.data.put('currUserPhone', currentUser.MobilePhone ?? '');

            return result;
        } catch (Exception e) {
            System.debug('fetchInit : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 파일 삭제
    **/
    @AuraEnabled
    public static void deleteFiles(List<String> fileIds) {
        try {
            List<ContentDocument> documentsToDelete = [
                SELECT Id FROM ContentDocument WHERE Id IN :fileIds
            ];
            delete documentsToDelete;
        } catch (Exception e) {
            System.debug('deleteFiles : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 텍스트로 입력 된 Contact정보 레코드로 생성
    **/
    @AuraEnabled
    public static string createContact(AccRepInfo rep, String shipToId){
        try {
            Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSCustomer').getRecordTypeId();
            List<Contact> contacts = [
                SELECT  Id, LastName, MobilePhone 
                FROM    Contact 
                WHERE   LastName =:rep.repName
                AND     MobilePhone =:rep.repMp
                LIMIT 1
            ];

            if(contacts.isEmpty()) {
                Contact c = new Contact();
                c.LastName       = rep.repName;
                c.MobilePhone    = rep.repMp;
                c.Title          = rep.repTitle;
                c.AccountId      = shipToId;
                c.RecordTypeId   = conRecordTypeId;
                insert c;
                
                return c.Id;
            } else {
                return contacts[0].Id;
            }
            
        } catch (Exception e) {
            System.debug('createContact : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 납품 후 교육 생성
    **/
    @AuraEnabled
    public static void createTicket(String recordId, DeliveryOrderWrapper wrapper){
        try {
            Id ticketRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticket').getRecordTypeId();

            User currUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            DeliveryOrder__c dOrder = [
                SELECT  Id
                        , Order__c, Order__r.SOSerialNumber__c, Order__r.RelatedDealer__c
                FROM    DeliveryOrder__c
                WHERE   Id =: recordId
            ];

            // 라이선스 검사 로직 추가
            String userId = UserInfo.getUserId();
            Boolean direct = false;
            List<User> directInfo = [
                SELECT Profile.UserLicense.Name
                FROM User
                WHERE Id = :userId
            ];
            if (!directInfo.isEmpty()
                && directInfo[0].Profile.UserLicense.Name.contains('Salesforce')) {
                direct = true;
            }

            Case c = new Case();

            // 고객사 담당자 정보
            c.Requester__c			 = wrapper.shipToRepId;    // 고객사 담당자 Contact Id
            c.ContactName__c         = wrapper.shipToRepName;  // 고객사 담당자 이름
            c.ContactPhone__c        = wrapper.shipToRepMP;    // 고객사 담당자 전화번호
            c.ContactPosition__c     = wrapper.shipToRepTitle; // 고객사 담당자 직책

            // 배송처 정보
            c.AccountId                 = wrapper.accId; // 고객사 Id
            c.AccountShippingAddress__c = wrapper.accAddress; // 고객사 주소

            // 교육 신청 내용
            c.TrainingType__c        = wrapper.trainingType;  // 교육 종류
            c.TrainingCount__c       = wrapper.trainingCount; // 교육 회수
            c.TraineeLevel__c        = wrapper.traineeLevel;  // 교육 수준
            c.TrainingDateTime1__c   = wrapper.trainingDateTime1; // 교육 요청 일자 1
            c.TrainingDateTime2__c   = wrapper.trainingDateTime2; // 교육 요청 일자 2
            c.TrainingDateTime3__c   = wrapper.trainingDateTime3; // 교육 요청 일자 2
            c.ReceptionDetails__c    = wrapper.receptionDetails;  // 접수 내용

            c.RepairRequestDateTime__c = wrapper.trainingDateTime1;
            c.OwnerId                  = wrapper.owner; // 교육 담당자를 레코드 owner 로 설정

            // 판매 대리점
            c.SalesDealer__c       = dOrder.Order__r.RelatedDealer__c; // 판매 대리점 
            c.InternalRequester__c = UserInfo.getUserId();  // 내부요청자
            c.FM_ReceptionistMP__c = wrapper.currUserPhone; // 내부 요청자 전화번호

            // 기타 정보
            c.RecordTypeId          = ticketRecordTypeId; // 레코드 타입 = Ticket
            c.SalesOrder__c         = dOrder.Order__c;
            c.DeliveryOrder__c      = dOrder.Id;
            c.AssetId               = dOrder.Order__r.SOSerialNumber__c;
            c.TicketType__c         = 'Internal request';
            c.InternalTicketType__c = 'Post-delivery training';

            //ReceptionPath 분기 처리
            if (direct) {
                c.ReceptionPath__c = 'Direct Sales';
            } else {
                c.ReceptionPath__c = 'Dealer Portal';
            }

            insert c;

            if (wrapper.fileIds.size() > 0) {
                List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                for (String contentDocumentId : wrapper.fileIds) {
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.ContentDocumentId = contentDocumentId;
                    link.LinkedEntityId    = c.Id;
                    link.ShareType         = 'I';
                    link.Visibility        = 'AllUsers';
                    links.add(link);
                }
                insert links;
            }
            
        } catch (Exception e) {
            // System.debug('createTicket : ' + e.getLineNumber() + ' / ' + e.getMessage());
            System.debug(LoggingLevel.ERROR,'✳️ ' + e.getTypeName() + ' : ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getLineNumber() + ' / ' + e.getMessage());
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isPass   {get;set;}
        @AuraEnabled public String  errorMsg {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}

        public ResultWrapper(){
            this.isPass   = true;
            this.errorMsg = '';
            this.data     = new Map<String, Object>();
        } 
    }

    /**
    * @description Picklist > Component Option 변환 Wrapper
    **/
    public class OptionWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public OptionWrapper(){
            this.label = '';
            this.value = '';
        }

        public OptionWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    /**
    * @description Account Wrapper
    **/
    public class AccRepInfo {
        @AuraEnabled public String repId     {get; set;} 
        @AuraEnabled public String repName   {get; set;} 
        @AuraEnabled public String repMp     {get; set;} 
        @AuraEnabled public String repTitle  {get; set;} 

        public AccRepInfo() {
            this.repId    = '';
            this.repName  = '';
            this.repMp    = '';
            this.repTitle = '';
        }
    }

    /**
    * @description 츨하 의뢰 및 입력 된 납품 후 교육 Wrapper
    **/
    public class DeliveryOrderWrapper {
        @AuraEnabled public String   shipToRepId        { get; set; }
        @AuraEnabled public String   shipToRepName      { get; set; }
        @AuraEnabled public String   shipToRepMP        { get; set; }
        @AuraEnabled public String   shipToRepTitle     { get; set; }

        @AuraEnabled public String   accId              { get; set; }
        @AuraEnabled public String   accAddress         { get; set; }

        @AuraEnabled public String   trainingType       { get; set; }
        @AuraEnabled public String   trainingCount      { get; set; }
        @AuraEnabled public String   traineeLevel       { get; set; }
        @AuraEnabled public Datetime trainingDateTime1  { get; set; }
        @AuraEnabled public Datetime trainingDateTime2  { get; set; }
        @AuraEnabled public Datetime trainingDateTime3  { get; set; }
        @AuraEnabled public String   receptionDetails   { get; set; }

        @AuraEnabled public String   owner              { get; set; }
        @AuraEnabled public String   currUserPhone      { get; set; }

        @AuraEnabled public List<String> fileIds { get; set; }

        public DeliveryOrderWrapper(){}
    }
}