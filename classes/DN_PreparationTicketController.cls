/**
 * @description       : [SLS-DLV-012] Preparation Checklist에서 Ticket 생성 및 사전설치 점검표 첨부
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-05   yeongju.yun   Initial Version
**/
public with sharing class DN_PreparationTicketController {

    private static final String sessionId = fetchUserSessionId();
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 사전설치점검표 초기값 및 기존 데이터 조회
    **/
    @AuraEnabled
    public static Map<String, Object> fetchPreChecklist(String recordId){
        try {

            WITHOUTWRAPPER wrapper = new WITHOUTWRAPPER();
            List<Case> caseList = wrapper.queryCase(recordId);

            if(!caseList.isEmpty()) {
                if(!ordSvc.TICKET_EDITABLE.contains(caseList[0].Status)) {
                    AuraHandledException e = new AuraHandledException('error');
                    e.setMessage(System.Label.DNS_M_PreparationChecklistSendError);
                    // The preparation checklist can only be sent when the ticket status is 'Reject'.
                    throw e;
                }
            }
            
            // get preparation checklist data
            List<PreparationChecklist__c> preList = [
                SELECT  Id, Name, OwnerId
                        , PreferredInstallationDate__c
                        , F_ModelNumber__c

                        , Account__c
                        , Account__r.ShippingPostalCode
                        , F_AccountName__c
                        , F_Address__c

                        , ContactPerson__c
                        , F_ContactPersonName__c
                        , F_ContactPersonPhone__c

                        , SalesReps__c
                        , F_SalesRepsName__c
                        , F_SalesRepsPhone__c
                        , SalesRepsBelonging__c
                        , F_SalesRepBName__c

                        , Table01C__c, Table01CusCheck__c, Table01P__c, Table01SalesCheck__c
                        , Table02C__c, Table02CusCheck__c, Table02P__c, Table02SalesCheck__c
                        , Table03C__c, Table03CusCheck__c, Table03P__c, Table03SalesCheck__c
                        , Table04C__c, Table04CusCheck__c, Table04P__c, Table04SalesCheck__c
                        , Table05C__c, Table05CusCheck__c, Table05P__c, Table05SalesCheck__c
                        , Table06C__c, Table06CusCheck__c, Table06P__c, Table06SalesCheck__c
                        , Table07C__c, Table07CusCheck__c, Table07P__c, Table07SalesCheck__c
                        , Table08C__c, Table08CusCheck__c, Table08P__c, Table08SalesCheck__c
                        , Table09C__c, Table09CusCheck__c, Table09P__c, Table09SalesCheck__c
                        , Table10C__c, Table10CusCheck__c, Table10P__c, Table10SalesCheck__c
                        , Table11C__c, Table11CusCheck__c, Table11P__c, Table11SalesCheck__c
                        
                        , Map__c, SpecialNotes__c
                FROM    PreparationChecklist__c
                WHERE   Id =:recordId
            ];

            if(String.isBlank(preList[0].Account__r.ShippingPostalCode)) {
                AuraHandledException e = new AuraHandledException('error');
                e.setMessage(System.Label.DNS_INSPECT_SHIPPINGPOSTAL);
                // 고객사의 우편번호가 존재하지않습니다. 고객사 정보의 우편번호를 기재해주시길 바랍니다.
                throw e;
            }

            // set table
            Map<String, List<TableWrapper>> tableMap = setTableData(preList[0]);

            // get image
            List<String> base64ImageList = new List<String>();
            if(preList[0].Map__c != null) {

                String instanceUrl  = URL.getOrgDomainUrl().toExternalForm();
                List<String> refIds = getRichTextImageUrls(preList[0].Map__c);
    
                for (String refId : refIds) {
                    String endpoint = instanceUrl + '/services/data/v62.0/sobjects/PreparationCheckList__c/' + recordId + '/richTextImageFields/Map__c/' + refId;
    
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(endpoint);
                    req.setMethod('GET');
                    req.setHeader('Authorization', 'Bearer ' + sessionId);
                    req.setHeader('Content-Type', 'application/json');
    
                    Http http = new Http();
                    HttpResponse res = http.send(req);
    
                    if (res.getStatusCode() == 200) {
                        Blob imageBlob     = res.getBodyAsBlob();
                        String base64Image = EncodingUtil.base64Encode(imageBlob);
                        base64ImageList.add('data:image/jpeg;base64,' + base64Image);
                    } else {
                        AuraHandledException e = new AuraHandledException('error');
                        e.setMessage(System.Label.DNS_M_NoLocationMap);
                        throw e;
                    }
                }
            }

            // logo, ppt1, ppt2 image
            Map<String, String> imageUrls = new Map<String, String>();
            List<StaticResource> resources = [
                SELECT  Name, Body
                FROM    StaticResource
                WHERE   Name IN ('preparationchecklist_logo', 'preparationchecklist_ppt01', 'preparationchecklist_ppt02')
            ];
            for (StaticResource sr : resources) {
                imageUrls.put(sr.Name, EncodingUtil.base64Encode(sr.Body));
            }

            return new Map<String, Object>{
                'preList'           => preList[0]
                , 'tableMap'        => tableMap
                , 'base64ImageList' => base64ImageList
                , 'imageUrls'       => imageUrls
            };
        } catch (Exception e) {
            System.debug('fetchPreChecklist : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description RichText의 이미지 텍스트 추출
    **/
    private static List<String> getRichTextImageUrls(String richText) {
        List<String> refIds = new List<String>();
        if (richText != null) {
            String imgTagPattern = '<img[^>]+src="([^">]+)"';
            Pattern p = Pattern.compile(imgTagPattern);
            Matcher m = p.matcher(richText);
    
            while (m.find()) {
                String relativeUrl = m.group(1);
                String refidPattern = 'refid=([a-zA-Z0-9]+)';
                Pattern refidP = Pattern.compile(refidPattern);
                Matcher refidM = refidP.matcher(relativeUrl);
    
                if (refidM.find()) {
                    String refid = refidM.group(1);
                    refIds.add(refid);
                }
            }
        }
        return refIds;
    }

    /**
    * @description RichText의 이미지를 불러오기 위한 Session  Id 호출
    **/
    private static String fetchUserSessionId(){
        String sessionId = '';

        if(!Test.isRunningTest()) {
            PageReference   reportPage  = Page.SessionId;
            String          vfContent   = reportPage.getContent().toString();
            Integer         startP      = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),

            endP        = vfContent.indexOf('End_Of_Session_Id');
            sessionId   = vfContent.substring(startP, endP);
        } else {
            User user = [SELECT Id FROM User LIMIT 1];
            sessionId = user.id;
        }
        return sessionId;
    }

    /**
    * @description 사전설치점검표 테이블 데이터 설정
    **/
    private static Map<String, List<TableWrapper>> setTableData(PreparationChecklist__c pre){

        List<PreparationChecklistItem__mdt> metaList = [
            SELECT  SectionNo__c, SectionName__c, ContentNo__c, Content__c
                    , PlannedField__c, CompletionField__c, SalesCheckField__c, CustomerCheckField__c
            FROM    PreparationChecklistItem__mdt
            WHERE   Language__c = 'ko'
            ORDER BY SectionNo__c, ContentNo__c
        ];

        Map<String, List<TableWrapper>> result = new Map<String, List<TableWrapper>>();
        for(PreparationChecklistItem__mdt meta : metaList) {

            TableWrapper tableWrap  = new TableWrapper();
            tableWrap.sectionNo     = meta.SectionNo__c;
            tableWrap.contentNo     = meta.ContentNo__c;
            tableWrap.content       = meta.Content__c;
            tableWrap.planned       = String.valueOf(pre.get(meta.PlannedField__c));
            tableWrap.completed     = String.valueOf(pre.get(meta.CompletionField__c));
            tableWrap.salesCheck    = String.valueOf(pre.get(meta.SalesCheckField__c));
            tableWrap.customerCheck = String.valueOf(pre.get(meta.CustomerCheckField__c));

            if(result.containsKey(meta.SectionName__c)) {
                List<TableWrapper> innerList = result.get(meta.SectionName__c);
                innerList.add(tableWrap);
                result.put(meta.SectionName__c, innerList);
            } else {
                result.put(meta.SectionName__c, new List<TableWrapper>{tableWrap});
            }
        }

        return result;
    }

    /**
    * @description 사전설치점검표 테이블 wrapper
    **/
    public class TableWrapper {
        @AuraEnabled public Decimal sectionNo    {get;set;}
        @AuraEnabled public Decimal contentNo    {get;set;}
        @AuraEnabled public String content       {get;set;}
        @AuraEnabled public String planned       {get;set;}
        @AuraEnabled public String completed     {get;set;}
        @AuraEnabled public String salesCheck    {get;set;}
        @AuraEnabled public String customerCheck {get;set;}

        public TableWrapper(){}
    }

    /**
    * @description [SLS-DLV-012] Preparation Checklist에서 Ticket 생성 및 사전설치 점검표 첨부
                   [SLS-DLV-013] 수정 후 'Send CS' 버튼 클릭 시, Ticket에 내용 업데이트 및 사전설치 점검표 파일 삭제 후 다시 생성
                                 Reject > New 변경 시 Ticket Owner에게 알림
    * @author yeongju.yun | 2024-11-07 
    * @param fileName 
    * @param file 
    * @param recordId 
    **/
    @AuraEnabled
    public static void uploadFile(String fileName, String file, String recordId){
        WITHOUTWRAPPER wrapper = new WITHOUTWRAPPER();

        List<Case> ticketList = wrapper.queryCase(recordId);

        PreparationCheckList__c pre = [
            SELECT  Id, IsCSSent__c, Account__c, ContactPerson__c
                    , Order__c, Order__r.OwnerId, Order__r.SOSerialNumber__c, Order__r.ERPOrderNo__c
                    , PreferredInstallationDate__c
            FROM    PreparationCheckList__c 
            WHERE   Id =: recordId
        ];

        Id orderId = pre.Order__c;
        String orderNo = pre.Order__r.ERPOrderNo__c;

        Savepoint sp = Database.setSavepoint();

        try {

            pre.IsCSSent__c = true;
            update pre;
            
            Case ticket = new Case();
            Boolean isRejectedCase = false;
            List<ContentVersion> toInsertCVs = new List<ContentVersion>();
            Set<Id> ticketLinkIds = new Set<Id>();
            if(ticketList.isEmpty()) { // new

                List<DeliveryOrder__c> doList = [SELECT Id FROM DeliveryOrder__c WHERE Order__c =:orderId];
                
                String ticketTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

                Case c = fetchPreToCase(new Case(), pre);
                c.RecordTypeId            = ticketTypeId;
                c.SalesOrder__c           = orderId;
                c.PreparationChecklist__c = recordId;
                c.TicketType__c           = 'Internal request';
                c.InternalTicketType__c   = 'Installation request';
                c.ApplicationDateTime__c  = Datetime.now();

                if(!doList.isEmpty()) {
                    c.DeliveryOrder__c = doList[0].Id;
                }
                insert c;

                ticket = c;
                
            } else { // update
                isRejectedCase = ticketList[0].Status == ordSvc.TICKET_REJECT;
                
                Case c = fetchPreToCase(ticketList[0], pre);
                wrapper.updateCase(c);
                
                ticket = c;

                List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
                Set<Id> cdIdSet = new Set<Id>();
                for(ContentDocumentLink link : cdlList) {
                    cdIdSet.add(link.ContentDocumentId);
                }

                List<String> targetTypeList = new List<String>{ordSvc.FILE_PREPARATIONCHECKLIST};
                List<ContentVersion> cvList = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId = :cdIdSet AND FileType__c IN :targetTypeList
                ];

                List<ContentDocument> toDeleteCds = new List<ContentDocument>();
                for(ContentVersion cv : cvList) {
                    ContentDocument cd = new ContentDocument(Id=cv.ContentDocumentId);
                    toDeleteCds.add(cd);
                }

                if(!toDeleteCds.isEmpty()) { delete toDeleteCds; }

                List<ContentDocumentLink> ticketCDLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: ticket.Id];
                for(ContentDocumentLink ticketCDLink : ticketCDLinks) {
                    ticketLinkIds.add(ticketCDLink.ContentDocumentId);
                }
                
            }

            // check files
            List<ContentDocumentLink> toInsertCDLs = new List<ContentDocumentLink>();

            Set<Id> preCDIds = new Set<Id>();
            List<ContentDocumentLink> preparationCDLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
            for(ContentDocumentLink preCDLink : preparationCDLinks) {
                preCDIds.add(preCDLink.ContentDocumentId);
            }

            for(Id cdId : preCDIds) {
                if(ticketLinkIds.contains(cdId)) continue; // prevent to duplicated

                ContentDocumentLink ticketLink = new ContentDocumentLink();
                ticketLink.ContentDocumentId   = cdId;
                ticketLink.LinkedEntityId      = ticket.Id;
                ticketLink.ShareType           = 'V';
                ticketLink.Visibility          = 'AllUsers';
                toInsertCDLs.add(ticketLink);
            }

            // preparation checklist
            ContentVersion pcCV   = new ContentVersion();
            pcCV.Title            = fileName;
            pcCV.PathOnClient     = fileName;
            pcCV.VersionData      = EncodingUtil.base64Decode(file);
            pcCV.ContentLocation  = 'S';
            pcCV.Origin           = 'H';
            pcCV.FileType__c      = ordSvc.FILE_PREPARATIONCHECKLIST;
            toInsertCVs.add(pcCV);

            insert toInsertCVs;

            Map<Id, ContentVersion> convertCVs = new Map<Id, ContentVersion>(toInsertCVs);
            Set<Id> newCDIdSet = new Set<Id>();
            List<ContentVersion> toGetCDIDs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: convertCVs.keySet()];
            for(ContentVersion cv : toGetCDIDs) {
                newCDIdSet.add(cv.ContentDocumentId);
            }

            for(Id cdId : newCDIdSet) {
                ContentDocumentLink addedCDLink    = new ContentDocumentLink();
                addedCDLink.ContentDocumentId      = cdId;
                addedCDLink.LinkedEntityId         = recordId;
                addedCDLink.ShareType              = 'V';
                addedCDLink.Visibility             = 'AllUsers';
                toInsertCDLs.add(addedCDLink);

                ContentDocumentLink ticketLink = new ContentDocumentLink();
                ticketLink.ContentDocumentId   = cdId;
                ticketLink.LinkedEntityId      = ticket.Id;
                ticketLink.ShareType           = 'V';
                ticketLink.Visibility          = 'AllUsers';
                toInsertCDLs.add(ticketLink);
            }            

            wrapper.insertFile(toInsertCDLs);

            // notification
            if(isRejectedCase) {
                Map<Id, String> userNameMap = new Map<Id, String>{ticketList[0].OwnerId => ticketList[0].Owner.Name};
                Map<Id, String> preNameMap  = new Map<Id, String>{ticketList[0].PreparationChecklist__c => ticketList[0].PreparationChecklist__r.Name};

                Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
                for(Case c : ticketList) {
                    targetUserMap.put(c.Id, new Set<Id>{c.OwnerId});
                }
                UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                    'PreparationChecklistEdited'
                    , 'bell'
                    , ticketList
                    , targetUserMap
                    , new Map<String, Object>{'userNameMap' => userNameMap, 'preNameMap' => preNameMap}
                );
                if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                    AuraHandledException e = new AuraHandledException('error');
                    e.setMessage(bellAlertResult.errMessage);
                    throw e;
                }

                UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                    'PreparationChecklistEdited'
                    , 'email'
                    , ticketList
                    , targetUserMap
                    , new Map<String, Object>{'userNameMap' => userNameMap, 'preNameMap' => preNameMap}
                );
                if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                    AuraHandledException e = new AuraHandledException('error');
                    e.setMessage(emailAlertResult.errMessage);
                    throw e;
                }
            }

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('uploadFile : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 사전설치점검표 데이터 기반으로 Ticket 필드 맵핑
    **/
    private static Case fetchPreToCase(Case c, PreparationChecklist__c pre) {
        c.AccountId                    = pre.Account__c;
        c.ContactId                    = pre.ContactPerson__c;
        c.InternalRequester__c         = pre.Order__r.OwnerId;
        c.Requester__c                 = pre.ContactPerson__c;
        c.AssetId                      = pre.Order__r.SOSerialNumber__c;
        c.Status                       = ordSvc.TICKET_NEW; // 신규일 때 'New', 반려일 때 수정 시 'New'
        c.ReceptionPath__c             = ordSvc.TICKET_PORTAL;
        c.RepairRequestDateTime__c     = pre.PreferredInstallationDate__c;
        c.isAlarmToCustomer__c         = false;
        c.ReceptionDetails__c          = System.Label.DNS_M_RequestTicket; // 설치시운전 요청

        return c;
    }

    /**
    * @description Dealer권한 제한으로 Sharing과 무관하게 조회용 wrapper
    **/
    public without sharing class WITHOUTWRAPPER{
        public WITHOUTWRAPPER(){}

        public void updateCase(Case c){
            update c;
        }

        public void insertFile(List<ContentDocumentLink> cdLinkList){
            insert cdLinkList;
        }

        public List<Case> queryCase(String recordId) {
            List<Case> ticketList = [
                SELECT  Id, CaseNumber, OwnerId, Owner.Name, AccountId, ContactId, InternalRequester__c, Requester__c
                        , RecordTypeId, Status, SalesOrder__c, AssetId
                        , PreparationChecklist__c, PreparationChecklist__r.Name
                        , TicketType__c, InternalTicketType__c, ReceptionPath__c
                FROM    Case 
                WHERE   PreparationCheckList__c =: recordId
            ];
            return ticketList;
        }
    }

}