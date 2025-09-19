/**
 * @description       : [SLS-DLV-017] 출하 의뢰(D/O) 생성
 * @author            : Daewook.KIM
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-30   Daewook.KIM   Initial Version
 * 1.1   2025-01-03   yeongju.yun   EDIT01. 선수금입금여부 확인 Validation Rule 추가
 * 1.2   2025-02-17   yeongju.yun   EDIT02. CRM에서 생성 한 출하의뢰에 한해 주문의 Sales Reps. (=Dealer's Account)를 저장
 * 1.3   2025-03-13   yeongju.yun   EDIT03. 사전설치 점검표, 선수금입금여부 Validation Rule 삭제, Order Status 'Mapped'이후 생성 가능 Rule 추가
 * 1.4   2025-03-18   yeongju.yun   EDIT04. 여신 확인 후 출하 가능 여부 Validation Rule + IF 호출
 * 1.5   2025-04-29   yeongju.yun   EDIT05. 출하 한 번으로 제한
 * 1.6   2025-04-30   daewook.kim   EDIT06. 납품 후 교육 배송처 주소 쿼리 ShipTo 에서 ShipTo_PSO 로 변경
 * 1.7   2025-05-09   yeongju.yun   EDIT07. 주문의 IsDOBlock__c가 TRUE이면 DO 생성 불가
**/
public with sharing class DN_DeliveryRequestRegistrationController {

    public static DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description DO생성 전 Validate 및 주문 정보 전달
    * @author yeongju.yun | 2025-07-17 
    * @param Id orderId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getOrderInfos(Id orderId) {
        Map<String, Object> resultMap = new Map<String, Object>();

        Order order = [
            SELECT  Id, SalesChannelType__c, Status, TotalAmount, PSOAmount__c
                    , Owner__c, Owner__r.UserType, Owner__r.Account.CustomerCode__c
                    , Owner__r.SalesOrganization__c, Owner__r.Division__c, Owner__r.DistributionChannel__c
                    , IsDOBlock__c
                    , CurrencyIsoCode
            FROM    Order 
            WHERE   Id =: orderId
        ];

        List<DeliveryOrder__c> doList = [SELECT Id FROM DeliveryOrder__c WHERE Order__c =: orderId];

        if(!ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c)) {
            resultMap.put('isPass',   false);
            resultMap.put('errorMsg', System.Label.DNS_M_DODomestic); // Delivery order can only be created in the CRM for domestic orders.
            return resultMap;
        } 

        if(order.Status != ordSvc.ORDER_MAPPED && order.Status != ordSvc.ORDER_DELIVERY) {
            resultMap.put('isPass',   false);
            resultMap.put('errorMsg', System.Label.DNS_M_DeliveryOrderMapped); // Delivery can only be created when the status is 'Order Mapped'.
            return resultMap;
        }

        if(order.IsDOBlock__c) { // EDIT07. 주문의 IsDOBlock__c가 TRUE이면 DO 생성 불가
            resultMap.put('isPass',   false);
            resultMap.put('errorMsg', System.Label.DNS_M_DOBlock); // Delivery order creation is blocked for this order. Please request DNS to lift the delivery order block.
            return resultMap;
        }

        if(!doList.isEmpty()) {
            resultMap.put('isPass',   false);
            resultMap.put('errorMsg', System.Label.DNS_M_DeliveryOnlyOne); // Only one delivery order can be created per order.
            return resultMap;
        }

        Boolean isCRMUser = ordSvc.getUserFlag(order.Owner__r.UserType);
        if(!isCRMUser) {

            IF_ERP_Dealer_Classes.IF_DEALER_003_Res creditResponse = callCreditIF(order);
            if(creditResponse.O_RETURN.TYPE == 'E') {
                resultMap.put('isPass',   false);
                resultMap.put('errorMsg', creditResponse.O_RETURN.MESSAGE);
                return resultMap;
            }

            List<IF_ERP_Dealer_Classes.IF_DEALER_003_Res_T_TCREDIT> creditList = creditResponse.T_TCREDIT;
            IF_ERP_Dealer_Classes.IF_DEALER_003_Res_T_TCREDIT creditInfo = creditResponse.T_TCREDIT[0];
            Decimal orderAmt = order.PSOAmount__c == 0 || order.PSOAmount__c == null ? order.TotalAmount : order.PSOAmount__c;
            Decimal balance = Decimal.valueOf(creditInfo.RCLAT);
            // if(order.CurrencyIsoCode == 'KRW'){ //원화인 경우 100 곱해야함_250718
            //     balance = balance * 100;
            // }
            if(balance < orderAmt) {
                resultMap.put('isPass',   false);
                resultMap.put('errorMsg', System.Label.DNS_M_OrderAmountExceedsCredit); // The order amount exceeds the credit limit.
                return resultMap;
            }
        }

        resultMap.put('isPass', true);
        
        List<GroupMember> eduRep = [SELECT Id, GroupId, UserOrGroupId, UserOrGroup.Name, Group.Name, Group.DeveloperName
        FROM GroupMember
        WHERE Group.DeveloperName = 'eduRep'];

        resultMap.put('eduRep', eduRep);

        // get default values
        Order orderRecord = [
            SELECT Id, AccountId, Account.Name, Account.FM_Address__c, SalesOrganization__c, DistributionChannel__c, Division__c, CurrencyIsoCode, OwnerId, ShipTo_PSO__c, ShipTo_PSO__r.FM_Address__c
            FROM Order 
            WHERE Id = :orderId 
            LIMIT 1
        ];

        resultMap.put('ownerId', orderRecord.ownerId);
        resultMap.put('shipToId', orderRecord.ShipTo_PSO__c);
        resultMap.put('shipToAddress', orderRecord.ShipTo_PSO__r.FM_Address__c);

        if (orderRecord.ShipTo_PSO__c != null) { 
            
            List<Contact> contactList = [
                SELECT Id, Name, MobilePhone, Title
                FROM Contact 
                WHERE AccountId = :orderRecord.ShipTo_PSO__c
            ];

            List<AccRepInfo> contactOptions = new List<AccRepInfo>();
            for(Contact con : contactList) {
                AccRepInfo wrap = new AccRepInfo();
                wrap.repId = con.Id;
                wrap.repName = con.Name;
                wrap.repMp = con.MobilePhone != null ? con.MobilePhone : '000-0000-0000';
                wrap.repTitle = con.Title != null ? con.Title : '직책 없음';
                contactOptions.add(wrap);
            }

            resultMap.put('account',        orderRecord.Account); 
            resultMap.put('contactOptions', contactOptions);
        }

        User currentUser = [ SELECT Id, Name, AccountId, Profile.Name, ContactId, Contact.FM_CustomerCode__c, Contact.SalesOrganization__c, contact.Division__c, Contact.Account.Name, Contact.AccountId, Contact.MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
        resultMap.put('currentUser', currentUser);

        // convert picklist to options
        resultMap.put('trainingCountOptions', ordSvc.getPicklistWrap('Case', 'TrainingCount__c'));
        resultMap.put('trainingTypeOptions', ordSvc.getPicklistWrap('Case', 'TrainingType__c'));
        resultMap.put('trainingSortOptions', ordSvc.getPicklistWrap('Case', 'TrainingSort__c'));
        resultMap.put('traineeLevelOptions', ordSvc.getPicklistWrap('Case', 'TraineeLevel__c'));

        // get d/o field info and options
        List<String> targetList  = new List<String>{'PlannedGI__c', 'DestinationZone__c', 'DeliveryDate__c'};
        List<String> reqiredList = new List<String>();
        reqiredList.addAll(targetList);
        
        targetList.add('CapitalNo__c');
        targetList.add('Shipping__c');
        targetList.add('Note__c');

        resultMap.put('doFieldWrapList', ordSvc.getFieldInfo('DeliveryOrder__c', targetList, reqiredList));
        resultMap.put('requiedFields', reqiredList);

        return resultMap;
    }
    
    /**
    * @description CRM DO Creation
    * @author yeongju.yun | 2024-12-17 
    * @param deliveryOrder 
    * @param files 
    * @return String do id
    **/
    @AuraEnabled
    public static String saveDO(DeliveryOrder__c deliveryOrder, List<String> files) {

        Savepoint sp = Database.setSavepoint();
        WithoutWrapper wrap = new WithoutWrapper();

        try {
            Order order = [SELECT Id, SalesOrganization__c, DistributionChannel__c, Division__c, OwnerId, Status, SalesRep__c FROM Order WHERE Id =: deliveryOrder.Order__c];
            List<PreparationChecklist__c> preList = wrap.queryPreparation(deliveryOrder.Order__c);

            Map<Id, Boolean> userTypeMap = ordSvc.getUserFlag(new Set<Id>{UserInfo.getUserId()});
            Boolean isCRMUser = userTypeMap.get(UserInfo.getUserId());
            
            deliveryOrder.DistributionChannel__c = order.DistributionChannel__c;
            deliveryOrder.DealerAccount__c       = order.SalesRep__c; // EDIT02
            Boolean toSendERP = true;
            if(isCRMUser) {
                deliveryOrder.Status__c = ordSvc.DO_APPROVED;
            } else {
                User currUser = [SELECT Id, internal_approver__c, UserRole.PortalRole FROM User WHERE Id =: UserInfo.getUserId()];
                if(currUser.UserRole.PortalRole == 'Manager') {
                    // PartnerRole = Manager면 생성 시 호출
                    deliveryOrder.Status__c = ordSvc.DO_APPROVED;
                } else {
                    // Internal Approver > User정보에 있는 값
                    deliveryOrder.Status__c = ordSvc.DO_CREATED;
                    if(currUser.internal_approver__c != null) { deliveryOrder.InternalApprover__c = currUser.internal_approver__c; }
                    toSendERP = false;
                }
            }

            insert deliveryOrder;

            // Ticket에 DO연결 // 250219 - DO보다 사전설치 점검표 및 시운전이 먼저 생성 되었다면 연결, 아니면 PASS
            if(!preList.isEmpty()) {
                PreparationChecklist__c pre = preList[0];
                pre.DeliveryOrder__c = deliveryOrder.Id;
                wrap.updatePreparation(pre);
                
                List<Case> connectedCaseList = wrap.queryCase(pre.Id);
                if(!connectedCaseList.isEmpty()) {
                    Case connedtedCase = connectedCaseList[0];
                    connedtedCase.DeliveryOrder__c = deliveryOrder.Id;

                    wrap.updateCase(connedtedCase);
                }
            }

            // 등록된 파일이 있다면 DO와 연결
            if (!files.isEmpty()) {
                List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                for (String contentDocumentId : files) {
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.ContentDocumentId = contentDocumentId;
                    link.LinkedEntityId    = deliveryOrder.Id;
                    link.ShareType         = 'I';
                    link.Visibility        = 'AllUsers';
                    links.add(link);
                }
                wrap.insertCDL(links);
            }

            if(toSendERP) { 
                DeliveryOrder__c toSendDO = [
                    SELECT Id, Name, Order__c, SalesOffice__c, PlannedGI__c, DeliveryDate__c, CapitalNo__c, DestinationZone__c, Note__c
                            , OwnerId
                    FROM DeliveryOrder__c 
                    WHERE Id =: deliveryOrder.Id
                ];
                sendDoToERP(toSendDO, files); 

            }
            
            return deliveryOrder.Id;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Contact 정보 텍스트로 입력 시 Contact 생성
    **/
    @AuraEnabled
    public static String createContact(String shipToRepName, String shipToRepMP, String shipToRepTitle, String shipToId){
        try {
            Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSCustomer').getRecordTypeId();
            List<Contact> con = [SELECT Id, LastName, MobilePhone FROM Contact WHERE LastName =:shipToRepName  AND MobilePhone =:shipToRepMP LIMIT 1];
            if(!con.isEmpty()) {
                return con[0].Id;
            } else {
                Contact c = new Contact();
                c.LastName       = shipToRepName;
                c.MobilePhone    = shipToRepMP;
                c.Title          = shipToRepTitle;
                c.AccountId      = shipToId;
                c.RecordTypeId   = conRecordTypeId;
                insert c;
                
                return c.Id;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 납품 후 교육 추가 시 Case로 생성
    **/
    @AuraEnabled
    public static void saveTicket(DeliveryOrder__c deliveryOrder, DeliveryOrderWrapper wrapper){
        try {
            Id ticketRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticket').getRecordTypeId();
            
            User dealerInfo = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Order orderInfo = [SELECT Id, SOSerialNumber__c FROM Order WHERE Id = :deliveryOrder.Order__c];

            Case c = new Case();

            // 고객사 담당자 정보
            c.Requester__c			 = wrapper.shipToRepId;    // 고객사 담당자 Contact Id
            c.ContactName__c         = wrapper.shipToRepName;  // 고객사 담당자 이름
            c.ContactPhone__c        = wrapper.shipToRepMP;    // 고객사 담당자 전화번호
            c.ContactPosition__c     = wrapper.shipToRepTitle; // 고객사 담당자 직책

            // 배송처 정보
            c.AccountId                 = wrapper.accountId; // 고객사 Id
            c.AccountShippingAddress__c = wrapper.accountShippingAddress; // 고객사 주소

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
            c.SalesDealer__c         = dealerInfo.AccountId; // 판매 대리점
            c.InternalRequester__c   = dealerInfo.Id;        // 내부요청자
            c.FM_ReceptionistMP__c   = wrapper.FM_ReceptionistMP; // 내부 요청자 전화번호

            // 기타 정보
            c.RecordTypeId           = ticketRecordTypeId; // 레코드 타입 = Ticket

            c.SalesOrder__c          = deliveryOrder.Order__c;
            c.DeliveryOrder__c       = deliveryOrder.Id;
            c.AssetId				 = orderInfo.SOSerialNumber__c; // 장비 Id

            c.TicketType__c = 'Internal request';
            c.InternalTicketType__c = 'Post-delivery training';
            c.ReceptionPath__c = 'Dealer Portal';
 
            insert c;
            
            if (wrapper.fileId.size() >0) {
                List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                for (String contentDocumentId : wrapper.fileId) {
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
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 출하 의뢰 및 Ticket Wrapper
    **/
    public class DeliveryOrderWrapper {
        @AuraEnabled public Boolean isRequired          { get; set; }

        @AuraEnabled public String   shipToRepId        { get; set; }
        @AuraEnabled public String   shipToRepName      { get; set; }
        @AuraEnabled public String   shipToRepMP        { get; set; }
        @AuraEnabled public String   shipToRepTitle     { get; set; }

        @AuraEnabled public String   trainingType       { get; set; }
        @AuraEnabled public String   trainingCount      { get; set; }
        @AuraEnabled public String   traineeLevel       { get; set; }
        @AuraEnabled public Datetime trainingDateTime1  { get; set; }
        @AuraEnabled public Datetime trainingDateTime2  { get; set; }
        @AuraEnabled public Datetime trainingDateTime3  { get; set; }
        @AuraEnabled public String   receptionDetails   { get; set; }

        @AuraEnabled public String   accountId          { get; set; }
        @AuraEnabled public String   accountShippingAddress { get; set; }
        @AuraEnabled public String   salesDealer        { get; set; }
        @AuraEnabled public String   receptionist       { get; set; }

        @AuraEnabled public String   owner              { get; set; }
        @AuraEnabled public String   shipToId           { get; set; }
        @AuraEnabled public String   shipToAddress      { get; set; }

        @AuraEnabled public List<String> fileId         { get; set; }

        @AuraEnabled public String   FM_ReceptionistMP  { get; set; }
        @AuraEnabled public String   Requester          { get; set; }

        public DeliveryOrderWrapper(){}
    }

    public class AccRepInfo {
        @AuraEnabled public String repId     {get; set;} 
        @AuraEnabled public String repName   {get; set;} 
        @AuraEnabled public String repMp     {get; set;} 
        @AuraEnabled public String repTitle  {get; set;} 

        public AccRepInfo () {}
    }

    /**
    * @description 파일 업로드
    **/
    @AuraEnabled
    public static String uploadFile(String fileName, String base64Data, String contentType, String fileType) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.Title          = fileName;
            cv.PathOnClient   = fileName;
            cv.VersionData    = EncodingUtil.base64Decode(base64Data);
            cv.IsMajorVersion = true;
            cv.FileType__c    = fileType;
            insert cv;

            ContentVersion newCV = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :cv.Id
            ];

            return newCV.ContentDocumentId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 파일 삭제 (업로드 취소 혹은 모달 취소 클릭 시)
    **/
    @AuraEnabled
    public static void deleteFiles(List<String> fileIds) {
        try {
            List<ContentDocument> documentsToDelete = [
                SELECT Id FROM ContentDocument WHERE Id IN :fileIds
            ];
            delete documentsToDelete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description DO를 ERP로 전송 (매니저, 직영)
    **/
    public static void sendDoToERP(DeliveryOrder__c deliveryOrder, List<String> files) {
        
        List<String> fileCategories = new List<String>{ordSvc.FILE_BIZREG, ordSvc.FILE_MAP, ordSvc.FILE_BOND};
        List<ContentVersion> cvList = [
            SELECT  Id, Title, VersionData, ContentSize, FileExtension, FileType__c, ContentDocumentId
            FROM    ContentVersion
            WHERE   FileType__c =: fileCategories
            AND     ContentDocumentId =: files
        ];
        
        List<String> tempCVIdList = new List<String>();
        for(ContentVersion cv : cvList) {
            tempCVIdList.add(cv.Id);
        }

        // create html files by the uploaded files
        IF_FilePackingService service = new IF_FilePackingService();
        Map<Id, ContentVersion> htmlFileMap = service.packingToMapByHTML(tempCVIdList);

        System.enqueueJob(new DN_DeliveryOrderService(deliveryOrder, deliveryOrder.Order__c, htmlFileMap.values()));
    }

    /**
    * @description 여신 확인
    **/
    private static IF_ERP_Dealer_Classes.IF_DEALER_003_Res callCreditIF(Order order) {
        IF_ERP_Dealer_Classes.IF_DEALER_003_Req request = new IF_ERP_Dealer_Classes.IF_DEALER_003_Req();
        request.I_BUKRS = '1800'; // FIXED
        request.I_VKORG = '1800'; // FIXED
        request.I_SPART = '40';   // FIXED
        request.I_KUNNR = order.Owner__r.Account.CustomerCode__c;
        request.I_VTWEG = '10';

        IF_ERP_Dealer service = new IF_ERP_Dealer();
        IF_ERP_Dealer_Classes.IF_DEALER_003_Res response = service.IF_DEALER_003(request);

        return response;
    }

    /**
    * @description 권한 예외 처리 (for dealer)
    **/
    public without sharing class WithoutWrapper{
        public WithoutWrapper(){}

        public void updatePreparation(PreparationChecklist__c p){
            update p;
        }

        public void updateCase(Case c) {
            update c;
        }

        public void insertCDL(List<ContentDocumentLink> links) {
            insert links;
        }

        public List<PreparationCheckList__c> queryPreparation(String orderId){
            return [SELECT Id FROM PreparationChecklist__c WHERE Order__c =: orderId];
        }

        public List<Case> queryCase(String preId) {
            return [SELECT Id, DeliveryOrder__c FROM Case WHERE InternalTicketType__c = 'Installation request' AND PreparationChecklist__c =: preId];
        }
    }
    
}