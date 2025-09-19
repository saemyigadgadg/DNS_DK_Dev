/**
* @Class : TicketTriggerHandler
*
* @Author : Hayeong, Min
* @Date : 2024. 06. 14.
* @Version : 1.0
* @Modified : 2024. 08. 05
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-14 | Hayeong, Min   | 최초작성
*
*/
public without sharing class TicketTriggerHandler extends TriggerHandler  {
    
    public Map<String, String> alertManagerMap;
    private Map<String, Schema.RecordTypeInfo> ticketRecordTypeInfoMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

    // 2025.03.05 서영덕 AlertManagerMap 전역변수로 추가
    public TicketTriggerHandler() {
        this.alertManagerMap = new Map<String, String>();

        List<AlertManager__c> alertManagerList = [SELECT Id, Name FROM AlertManager__c WHERE Part__c = 'Service'];
        System.debug('alertManagerList :: '+alertManagerList);

        for (AlertManager__c alert : alertManagerList) {
            this.alertManagerMap.put(alert.Name, alert.Id);
        }
    }

    public override void onBeforeInsert(List<sObject> news){
        System.debug('Ticket Trigger Before Insert!');

        String triggerType = 'Before Insert';
        System.debug('Ticket OperationType ::: ' + triggerType);

        if(isExecuting){
            List<Case> ticketList = (List<Case>) news;
            
            // Ticket 생성시 센터장을 Owner로 변경하는 메서드
            installationChangeOwner(ticketList);

            // CS담당자 & 협조부서 팀 매핑하는 메서드
            assignCSMemberAndCooperationTeam(ticketList, null, triggerType);

            // 미오후납 티켓 생성시, 장비의 생산처, 설치업체 정보 가져와서 넣어주는 메서드
            missingPartTicketEquipmentInfo(ticketList);

            // 순차배정 메서드
            ticketInsertSequentialAssignment(ticketList);

            // 요청자 번호 자동맵핑 메서드
            setRequesterPhone(ticketList, null, triggerType);
            
            // Ticket insert시 조건별 정보 자동맵핑 메서드
            setBeforeInsertInfo(ticketList);
        }
    }

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){

        String triggerType = 'After Insert';
        System.debug('Ticket OperationType ::: ' + triggerType);

        if(isExecuting){
            List<Case> ticketList = (List<Case>) news;

            // After Insert일때 조건에 따라 Email, Notification, AlarmTalk을 전송하는 메서드
            sendAfterInsertAlert(ticketList);

            // 처음 배정된 Owner를 Ticket Team Member에 insert하는 메서드
            insertTicketTeamMember(ticketList, null, triggerType);

            // 납품 후 교육 생성시 Owner에게 SMS발송 하는 메서드 (2025-01-22 서영덕 추가)
            sendAfterInsertSMS(ticketList);

            // 출하에서 생성된 티켓일 경우, 출하의 부품 전송 날짜가 티켓의 수리요청일시에 자동 기입되는 메서드 
            //UpdateRequestDate(ticketList);
        }
    }

    //1. 티켓유형(대)가 기술문의(Technical inquiry) 이면서 티켓유형(중)이 고장접수 일 경우 => 기술상담사 순차 배정
    //2. 기존 Owner는 Team Member에 추가
    //3. 변경된 Owner에게 Noti & Email 발송
    //4. Closed로 Status 변경 시 반드시 종결사유 입력하도록 Validation
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){

        String triggerType = 'Before Update';
        System.debug('Ticket OperationType ::: ' + triggerType);

        if(isExecuting) {
            List<Case> ticketList = (List<Case>) news;

            // CS담당자 & 협조부서 팀 매핑하는 메서드
            assignCSMemberAndCooperationTeam(ticketList, oldMap, triggerType);

            // Update일때 순차배정 메서드
            ticketUpdateSequentialAssignment(ticketList, oldMap);

            // 요청자 번호 자동맵핑 메서드
            setRequesterPhone(ticketList, oldMap, triggerType);

            // 진행중인 오더가 있는데 고객취소할 때 취소 불가 validation 메서드
            customerCancelValidation(ticketList, oldMap);

            // 고객 변경시 삭제된 고객사 Validation 메서드
            accountUpdateValidation(ticketList, oldMap);

            // Ticket update시 조건별 정보 자동맵핑 & validation 메서드
            setBeforeUpdateInfo(ticketList, oldMap);
        }
    }

    //241127 by Hayeong Min
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){

        String triggerType = 'After Update';
        System.debug('Ticket OperationType ::: ' + triggerType);

        if(isExecuting) {
            List<Case> ticketList = (List<Case>) news;

        //     for(Case ca : ticketList){
        //         Case oldMaps = (Case) oldMap.get(ca.Id);
        //         Boolean isChanged = isFieldSetChanged(ca,oldMaps);
    
        //         if(!isChanged){
        //         // After Update일때 조건에 따라 Email, Notification, AlarmTalk을 전송하는 메서드
                    sendAfterUpdateAlert(ticketList, oldMap);
        //     }
        // }

            // Owner변경 시 변경된 Owner를 Ticket Team Member로 insert하는 메서드
            insertTicketTeamMember(ticketList, oldMap, triggerType);

            // 수리요청일 변경 관련 메서드
            changedRepairDate(ticketList, oldMap);

            // 접수내용 변경 관련 메서드
            changedReceptionDetail(ticketList, newMap, oldMap);
        }
    } 


    /**
    * @description User 정보 Map으로 반환
    * @author yeongju.yun | 2024-10-24 
    * TicketTriggerHandler.getUserInfoMap();
    **/
    private static Map<Id, UserWrapper> getUserInfoMap(){
        List<User> users = [SELECT Id, FirstName, LastName, Email, LanguageLocaleKey FROM User WHERE IsActive = TRUE];
        Map<Id, UserWrapper> userMap = new Map<Id, UserWrapper>();
        for(User u : users){
            UserWrapper uw = new UserWrapper();
            uw.Id = String.valueOf(u.Id);
            if(u.FirstName == null){
                uw.Name = u.LastName;
            }else{
                uw.Name = u.LastName+' '+u.FirstName;
            }
            uw.Email = u.Email;
            uw.language = (u.LanguageLocaleKey == 'ko') ? 'ko' : 'en';
            userMap.put(u.Id, uw);
        }
        return userMap;
    }
          
    /**
    * @description 수리요청일시 변경되면 연결된 Service Appointment들의 DueDate 당일 23:59분으로 Update
    * @author Hayeong Min | 2024-10-24 
    * @param ticketIds : 변경되어야 하는 Ticket Id Set
    * TicketTriggerHandler.changeServiceAppointmentDueDate(Set<Id> ticketIds);
    **/
    private void changeServiceAppointmentDueDate(Set<Id> ticketIds){
        System.debug('changeServiceAppointmentDueDate 실행됨...');
        List<WorkOrder> woList = [SELECT Id, Case.RepairRequestDateTime__c FROM WorkOrder WHERE CaseId IN :ticketIds];
        // Set<Id> woIds = new Set<Id>();
        Map<Id, DateTime> duedateMap = new Map<Id, DateTime>();
        for(WorkOrder wo : woList){
            // woIds.add(wo.Id);
            DateTime dt = wo.Case.RepairRequestDateTime__c;
            duedateMap.put(wo.Id, DateTime.newInstance(dt.year(), dt.month(), dt.day(), 23, 59, 59));
        }
        System.debug('duedateMap : '+duedateMap);

        List<ServiceAppointment> saList = [SELECT Id, DueDate, ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN : duedateMap.keySet()];
        System.debug('saList Length : '+saList.size());
        for(ServiceAppointment sa : saList){
            sa.DueDate = duedateMap.get(sa.ParentRecordId);
        }
        update saList;
    }

    // 하수헌 24.11.20
    private Map<Id, Id> assignTicketOwner(List<Case> tickets) {
        Map<Id, String> accountZipMap = new Map<Id, String>();
        Set<Id> accountIds = new Set<Id>();
    
        // 1. Account ID 수집
        for (Case ticket : tickets) {
            if (ticket.AccountId != null) {
                accountIds.add(ticket.AccountId);
            }
        }
        System.debug('Account ID:::' + accountIds);
    
        // 2. Account ZipCode 매핑
        if (!accountIds.isEmpty()) {
            for (Account acc : [SELECT Id, ShippingPostalCode FROM Account WHERE Id IN :accountIds]) {
                if (acc.ShippingPostalCode != null && acc.ShippingPostalCode.length() >= 3) {
                    accountZipMap.put(acc.Id, acc.ShippingPostalCode.substring(0, 3));
                }
            }
        }
        System.debug('Account Zip Map:::' + accountZipMap);
    
        // 3. JurisdictionalInformation ZipCode 수집
        Set<String> zipCodes = new Set<String>();
        for (Case ticket : tickets) {
            String zip3 = accountZipMap.get(ticket.AccountId);
            if (zip3 != null) {
                zipCodes.add(zip3);
            }
        }
        System.debug('Zip Codes:::' + zipCodes);
    
        // 4. ZipCode별 JurisdictionalInformation 수집
        Map<String, List<JurisdictionalInformation__mdt>> zipToJurisdictionMap = new Map<String, List<JurisdictionalInformation__mdt>>();
        if (!zipCodes.isEmpty()) {
            List<JurisdictionalInformation__mdt> jurisdictionList = [
                SELECT Id, CityCounty2__c, zipcode__c
                FROM JurisdictionalInformation__mdt
            ];
            for (JurisdictionalInformation__mdt jurisdiction : jurisdictionList) {
                if (!zipToJurisdictionMap.containsKey(jurisdiction.zipcode__c)) {
                    zipToJurisdictionMap.put(jurisdiction.zipcode__c, new List<JurisdictionalInformation__mdt>());
                }
                zipToJurisdictionMap.get(jurisdiction.zipcode__c).add(jurisdiction);
            }
        }
        System.debug('Zip Jurisdiction Map:::' + zipToJurisdictionMap);
    
        // 5. JurisdictionalInfo 수집
        Set<String> jurisdictionNames = new Set<String>();
        for (List<JurisdictionalInformation__mdt> jurisdictions : zipToJurisdictionMap.values()) {
            for (JurisdictionalInformation__mdt jurisdiction : jurisdictions) {
                jurisdictionNames.add(jurisdiction.CityCounty2__c);
            }
        }
        System.debug('Jurisdiction Names:::' + jurisdictionNames);
    
        Map<String, JurisdictionalInfo__c> jurisdictionInfoMap = new Map<String, JurisdictionalInfo__c>();
        if (!jurisdictionNames.isEmpty()) {
            List<JurisdictionalInfo__c> jurisdictionalInfoList = [
                SELECT Id, Name, WorkCenter__c
                FROM JurisdictionalInfo__c
                WHERE Name IN :jurisdictionNames
            ];
            for (JurisdictionalInfo__c inpo : jurisdictionalInfoList) {
                jurisdictionInfoMap.put(inpo.Name, inpo);
            }
        }
        System.debug('Jurisdiction Info Map:::' + jurisdictionInfoMap);
    
        // 6. WorkCenter 관련 ServiceResource 수집
        Set<Id> workCenterIds = new Set<Id>();
        for (JurisdictionalInfo__c inpo : jurisdictionInfoMap.values()) {
            if (inpo.WorkCenter__c != null) {
                workCenterIds.add(inpo.WorkCenter__c);
            }
        }
        System.debug('WorkCenter ID:::' + workCenterIds);
    
        Map<Id, ServiceResource> serviceResourceMap = new Map<Id, ServiceResource>();
        if (!workCenterIds.isEmpty()) {
            List<ServiceTerritory> territoryList = [
                SELECT Id, BranchManager__c, BranchManager__r.RelatedRecordId
                FROM ServiceTerritory
                // WHERE Id IN :workCenterIds
                WHERE Id IN :workCenterIds AND classify__c IN ('지사', 'POST')
            ];
            for (ServiceTerritory territory : territoryList) {
                if (territory.BranchManager__c != null) {
                    serviceResourceMap.put(territory.Id, territory.BranchManager__r);
                }
            }
        }
        System.debug('ServiceResource Map:::' + serviceResourceMap);
    
        // 7. Ticket Owner 지정

        NotiReceptionList__c ticketOwner = NotiReceptionList__c.getInstance('TicketOwner');
        String ticketOwnerName = ticketOwner != null ? ticketOwner.UserName__c : null;

        Id defaultOwnerId;
        List<User> defaultUsers = [SELECT Id FROM User WHERE Username = :ticketOwnerName LIMIT 1];
        if (!defaultUsers.isEmpty()) {
            defaultOwnerId = defaultUsers[0].Id;
        }
        System.debug('defaultOwnerId:::' + defaultOwnerId);

        Map<Id, Id> ticketOwnerMap = new Map<Id, Id>();
        for (Case ticket : tickets) {
            if (ticket.InternalRequester__c != null && ticket.InternalTicketType__c == 'Installation request') {
                String zip3 = accountZipMap.get(ticket.AccountId);
                if (zip3 != null && zipToJurisdictionMap.containsKey(zip3)) {
                    for (JurisdictionalInformation__mdt jurisdiction : zipToJurisdictionMap.get(zip3)) {
                        JurisdictionalInfo__c inpo = jurisdictionInfoMap.get(jurisdiction.CityCounty2__c);
                        if (inpo != null && inpo.WorkCenter__c != null) {
                            ServiceResource resource = serviceResourceMap.get(inpo.WorkCenter__c);
                            if (resource != null && resource.RelatedRecordId != null) {
                                ticketOwnerMap.put(ticket.Id, resource.RelatedRecordId);
                            }
                        }
                    }
                }
            } else if(ticket.InternalTicketType__c == 'Regular Inspections') {
                String zip3 = accountZipMap.get(ticket.AccountId);
                if (zip3 != null && zipToJurisdictionMap.containsKey(zip3)) {
                    for (JurisdictionalInformation__mdt jurisdiction : zipToJurisdictionMap.get(zip3)) {
                        JurisdictionalInfo__c inpo = jurisdictionInfoMap.get(jurisdiction.CityCounty2__c);
                        if (inpo != null && inpo.WorkCenter__c != null) {
                            ServiceResource resource = serviceResourceMap.get(inpo.WorkCenter__c);
                            if (resource != null && resource.RelatedRecordId != null) {
                                ticketOwnerMap.put(ticket.Id, resource.RelatedRecordId);
                            }
                        }
                    }
                } else {
                    ticketOwnerMap.put(ticket.Id, defaultOwnerId);    // 박서은 매니저님 고정
                }
            }
        }
        System.debug('TicketOwner Map:::' + ticketOwnerMap);
    
        return ticketOwnerMap;
        // // 8. Ticket 업데이트
        // if (!ticketOwnerMap.isEmpty()) {
        //     List<Case> updatedTickets = new List<Case>();
        //     for (Id ticketId : ticketOwnerMap.keySet()) {
        //         updatedTickets.add(new Case(Id = ticketId, OwnerId = ticketOwnerMap.get(ticketId)));
        //     }
        //     update updatedTickets;
        //     System.debug('Updated Tickets:::' + updatedTickets);
        // }
    }


    private static CS_Util.AssignmentWrapper setOwnerSequential(String ruleName, Integer ticketCnt){
        Id ruleId = [SELECT Id FROM AssignmentRule__c WHERE Name = :ruleName].Id;
        CS_Util.AssignmentRequest assign = new CS_Util.AssignmentRequest();
        assign.aID = ruleId;
        assign.size = ticketCnt;
        CS_Util.AssignmentWrapper assignResult = CS_Util.getAssignmentUser(assign);
        return assignResult;
    }

    private static List<CaseTeamMember> createCSMem(Set<Id> csMemIds, List<Case> ticketList){
        Map<String, String> csProfile = new Map<String, String>();
        Map<Id, String> csMemUser = new Map<Id, String>();
        for (CaseTeamRole p : [SELECT ID, Name FROM CaseTeamRole]) {
            csProfile.put(p.Name, p.ID);
        }
        for (User u : [SELECT Id, Profile.Name FROM User WHERE Id IN :csMemIds]) {
            csMemUser.put(u.Id, u.Profile.Name);
            System.debug('csMemUser :: '+u.Profile.Name);
        }
        
        List<CaseTeamMember> csMem = new List<CaseTeamMember>();
        for(Case obj : ticketList){
            CaseTeamMember mem = new CaseTeamMember();
            mem.MemberId = obj.OwnerId;
            mem.ParentId = obj.Id;
            String teamRoleId = '';
            if(csMemUser.get(obj.OwnerId) == 'DNS CS Receptionist'){
                teamRoleId = csProfile.get('접수상담사(Reception Consultant)');
            }else if(csMemUser.get(obj.OwnerId) == 'DNS CS Technical Consultant'){
                teamRoleId = csProfile.get('기술상담사(Technical Consultant)');
            }else{
                teamRoleId = csProfile.get('ETC');
            }
            mem.TeamRoleId = teamRoleId;
            csMem.add(mem);
        }
        return csMem;
    }

    //미오후납 장비의 설치업체, 생산처 정보 반환
    private static Map<Id, Asset> getMissingInfo(Set<Id> assetIds){
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        // 2025-05-26 장비 ModelCode로 CS담당자 & 협조부서 팀 매핑을 위한 Name 추가
        List<Asset> assetList = [SELECT ID, InstWorkCenter__c, ManufacturerName__c, Name FROM Asset WHERE Id IN :assetIds];
        for(Asset asset : assetList){
            assetMap.put(asset.Id, asset);
        }
        return assetMap;
    }

    //DNSA 장비 존재 여부 확인
    private static Map<String, String> checkEquipNumber(Set<String> equipNumbers){
        List<Asset> equipList = [SELECT Id, Name FROM Asset WHERE SerialNumber != NULL AND Name IN : equipNumbers];
        Map<String, String> equipMap = new Map<String, String>();
        if(equipList.size()>0){
            for(Asset equip : equipList){
                equipMap.put(equip.Name, equip.Id);
            }
        }

        return equipMap;
    }
    
    // 납품 후 교육 생성시 Owner에게 SMS발송 (2025-01-22 서영덕 추가)
    @future(callout=true)
    public static void sendSMS(Set<String> ticketIds) {
        try {
            List<Case> ticketList = [SELECT Id, AccountId, Account.Name, Account.ShippingPostalCode, TrainingDateTime1__c, ContactName__c, ContactPhone__c, OwnerId, InternalRequester__c, InternalRequester__r.Name, InternalRequester__r.MobilePhone FROM Case WHERE Id IN :ticketIds];

            Map<String, String> accountZipMap = new Map<String, String>();            
            Set<Id> userIds = new Set<Id>();
            for (Case ticket : ticketList) {
                userIds.add(ticket.OwnerId);
                userIds.add(ticket.InternalRequester__c);
            }

            Map<Id, User> userMap = new Map<Id, User>([
                SELECT Id, Name, MobilePhone, Phone, AccountId, ContactId, toLabel(Contact.SalesOffice__c) FROM User WHERE Id IN :userIds
            ]);

            System.debug('userMap :: '+userMap);
            List<IF_BIZ_SMS.T_SMS_DATA> smsList = new List<IF_BIZ_SMS.T_SMS_DATA>();
        
            List<SMSHistory__c> smsHistoryList = new List<SMSHistory__c>();
            for (Case ticket : ticketList) {
                User owner = userMap.get(ticket.OwnerId);
                User internalRequester = userMap.get(ticket.InternalRequester__c);
                // String ownerPhoneNumber = owner.MobilePhone == '' || owner.MobilePhone == null ? owner.Phone : owner.MobilePhone;

                System.debug('owner :: '+owner);


                if (owner.MobilePhone == '' || owner.MobilePhone == null) continue;
                // owner.MobilePhone.replace('+82 ', '');
                String sendPhoneNumber = String.valueOf(owner.MobilePhone).replace('+82 ', '');
                System.debug('sendPhoneNumber :: '+sendPhoneNumber);
                String salesOffice = internalRequester == null ? '' : (internalRequester.Contact.SalesOffice__c == null ? 'test' : internalRequester.Contact.SalesOffice__c);
                String internalRequesterName = ticket.InternalRequester__r.Name == null ? '' : ticket.InternalRequester__r.Name;
                String internalRequesterPhone = ticket.InternalRequester__r.MobilePhone == null ? '' : ticket.InternalRequester__r.MobilePhone;                
                internalRequesterPhone = internalRequesterPhone == '' ? '' : String.valueOf(internalRequesterPhone).replace('+82 ', '');

                String contentBody = '[납품후교육접수]\n';
                contentBody += '[' + ticket.Account.Name + '] 교육이 접수되었습니다.\n';
                contentBody += '교육요청일시 - ' + ticket.TrainingDateTime1__c.format('yyyy.MM.dd hh:mm:ss') + '\n';
                contentBody += '판매담당자 - [' + internalRequesterName + ']\n';
                contentBody += '판매담당전화 - [' + internalRequesterPhone + ']\n';
                contentBody += '관할지역 - [' + salesOffice + ']';

                IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                sms.TRAN_PHONE = sendPhoneNumber;     // 수신자 번호
                sms.TRAN_CALLBACK = '1600-4522';        // 발신자 번호 (콜센터 대표번호)
                sms.TRAN_MSG = contentBody;             // 본문(\n 으로 다음줄 조절)
                sms.TRAN_ETC1 = 'CRM';
                smsList.add(sms);


                //History 내역 남기기
                SMSHistory__c smshistory1 = new SMSHistory__c();
                smshistory1.OutBoundCall__c = '1600-4522';     
                smshistory1.InboundCall__c = sendPhoneNumber;
                smshistory1.Content__c = contentBody;
                smshistory1.SendTargetList__c = '내부직원';
                smsHistoryList.add(smshistory1);

                if (internalRequesterPhone != '') {
                    IF_BIZ_SMS.T_SMS_DATA sms2 = new IF_BIZ_SMS.T_SMS_DATA();
                    sms2.TRAN_PHONE = internalRequesterPhone;     // 수신자 번호
                    sms2.TRAN_CALLBACK = '1600-4522';        // 발신자 번호 (콜센터 대표번호)
                    sms2.TRAN_MSG = contentBody;             // 본문(\n 으로 다음줄 조절)
                    sms2.TRAN_ETC1 = 'CRM';
                    smsList.add(sms2);

                    //History 내역 남기기
                    SMSHistory__c smshistory2 = new SMSHistory__c();
                    smshistory2.OutBoundCall__c = '1600-4522';     
                    smshistory2.InboundCall__c = internalRequesterPhone;
                    smshistory2.Content__c = contentBody;
                    smshistory2.SendTargetList__c = '내부직원';
                    smsHistoryList.add(smshistory2);
                }
            }

            System.debug('smsList :: '+smsList);
            IF_BIZ_SMS.DICCSAP_SEND_SMS_WP send = new IF_BIZ_SMS.DICCSAP_SEND_SMS_WP();
            if (smsList.size() > 0) System.debug(send.DICCSAP_SEND_SMS_M(smsList));
            if (smsHistoryList.size()>0) insert smsHistoryList;

        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }
    }
    
    /*
     * @Description 
     *  - User 정보 Wrapper
     * 
     * @Variable 
     *  - Id 	    : 사용자 아이디
     *  - Name 	    : 사용자 이름
     *  - Email 	: 사용자 이메일
     *  - language 	: 사용자 언어
     */ 
    public class UserWrapper{
        @AuraEnabled public String Id       { get; set;}
        @AuraEnabled public String Name     { get; set;}
        @AuraEnabled public String Email    { get; set;}
        @AuraEnabled public String language { get; set;}
        
        public UserWrapper(){
            this.Id = '';
            this.Name = '';
            this.Email = '';
            this.language = '';
        }
    }
    
    public class TicketEmailQueueable implements Queueable {
        private List<Case> news;

        public TicketEmailQueueable(List<Case> news) {
            this.news = news;
        }

        public void execute(QueueableContext context) {
            TriggerExceptionLog__c exLog = new TriggerExceptionLog__c();
            exLog.Message__c = 'dNSASendEmailAfterInsert\n';
            final String TARGET_TO_ADDRESS = 'cs.dnsacrm@dncompany.com';
            // final String TARGET_TO_ADDRESS = 'cs.dnsacrm@y-y6765e02co2wp9fpmew0gk11p3mm78yxbq7rzbzphl2q8pumo.f7-20d3mai.kor2s.case.sandbox.salesforce.com';
            Set<Id> newCaseIds = new Set<Id>();
            for (Case c : this.news) {
                newCaseIds.add(c.Id);
            }
            try {
                // Case에 연결된 EmailMessage 중, 지정된 ToAddress에 해당하는 것만 필터
                List<EmailMessage> relevantEmails = [
                    SELECT Id, ParentId, ToAddress 
                    FROM EmailMessage 
                    WHERE ParentId IN :newCaseIds AND ToAddress = :TARGET_TO_ADDRESS
                    ORDER BY CreatedDate DESC LIMIT 1
                ];
                
                exLog.Message__c += relevantEmails + '\n';
                System.debug('@@@@@@ : ' + relevantEmails);

                // 조건에 맞는 Case ID만 추출
                Set<Id> filteredCaseIds = new Set<Id>();
                for (EmailMessage em : relevantEmails) {
                    filteredCaseIds.add(em.ParentId);
                }

                // if (filteredCaseIds.isEmpty()) {
                //     return; // 해당하는 Case가 없으면 종료
                // }

                Id techRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = 'DNSA EmailToTicket 이메일 발송'].Id;
                if (techRuleId == null) {
                    return;
                }
                exLog.Message__c += techRuleId + '\n';
                List<AssignmentMember__c> members = [SELECT Id, User__r.Email FROM AssignmentMember__c WHERE AssignmentRule__c = :techRuleId ORDER BY Index__c ASC];
                if (members.isEmpty()) {
                    return;
                }

                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                
                for (Case c : this.news) {
                    if (!filteredCaseIds.contains(c.Id)) {
                        continue;
                    }

                    for (AssignmentMember__c amUser : members) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{ amUser.User__r.Email });
                        mail.setSubject('특정 이메일로 생성된 Case: ' + c.CaseNumber);
                        mail.setPlainTextBody(
                            '다음과 같은 Case가 생성되었습니다.\n\n' +
                            '제목: ' + c.Subject + '\n' +
                            '설명: ' + c.Description + '\n' +
                            'Case Number: ' + c.CaseNumber + '\n' +
                            '상태: ' + c.Status + '\n'
                        );
                        emails.add(mail);
                        exLog.Message__c += amUser.User__r.Email + '\n';
                    }
                }

                if (!emails.isEmpty()) {
                    Messaging.sendEmail(emails);
                }
                insert exLog;
            } catch (Exception ex) {
                // TriggerExceptionLog__c exLog = new TriggerExceptionLog__c();
                exLog.LineNumber__c = ex.getLineNumber();
                exLog.Message__c = 'TicketTriggerHandler : ' + ex.getStackTraceString() + ex.getMessage();
                exLog.ExceptionType__c = ex.getTypeName();
                exLog.ProgramEndTimemilles__c = System.currentTimeMillis();
                insert exLog;
            }
        }
    }

    // Ticket생성시 센터장을 Owner로 변경하는 메서드
    public void installationChangeOwner(List<Case> ticketList) {

        List<Case> filterInstallation = new List<Case>();

        // 2024.11.20 suheon.ha 주소 확인 후 Owner변경
        // Installation 조건을 만족하는 Case 레코드만 필터링
        for (Case obj : ticketList) {
            System.debug('Ticket Type :: '+ obj.TicketType__c);
            System.debug('InternalTicketType__c :: '+ obj.InternalTicketType__c);
            if (obj.InternalRequester__c != null && obj.InternalTicketType__c == 'Installation request') {
                filterInstallation.add(obj);
            } else if(obj.InternalTicketType__c == 'Regular Inspections') {
                filterInstallation.add(obj);
            }
        }

        // 2024.11.20 by Suheon.Ha
        if (!filterInstallation.isEmpty()) {
            Map<Id, Id> caseOwnerMap = assignTicketOwner(filterInstallation);
            System.debug('caseOwnerMap ::'+caseOwnerMap);
            for (Case obj : filterInstallation) {
                if (caseOwnerMap.containsKey(obj.Id)) {
                    System.debug('OwnerId ::: ' + caseOwnerMap.get(obj.Id));
                    obj.OwnerId = caseOwnerMap.get(obj.Id);
                }
            }
        }
    }

    // CS담당자 & 협조부서 팀 매핑하는 메서드
    public void assignCSMemberAndCooperationTeam(List<Case> ticketList, Map<Id, sObject> oldMap, String triggerType) {

        Set<Id> assetIds = new Set<Id>();

        for (Case obj : ticketList) {
            // 2025-05-26 장비 ModelCode로 CS담당자 & 협조부서 팀 매핑
            if (triggerType == 'Before Insert') {
                if(String.isNotEmpty(obj.AssetId)){
                    assetIds.add(obj.AssetId);
                }
            } else if (triggerType == 'Before Update') {
                Case oldObj = (Case) oldMap.get(obj.Id);
                if(String.isNotEmpty(obj.AssetId) && obj.AssetId != oldObj.AssetId){
                    assetIds.add(obj.AssetId);
                }
            }
        }

        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        if(assetIds.size() > 0){
            assetMap = getMissingInfo(assetIds);
        }

        // 2025-05-26 장비 ModelCode로 CS담당자 & 협조부서 팀 매핑
        Set<String> modelCodes = new Set<String>();
        if(!assetMap.isEmpty()){
            for (String key: assetMap.keySet()) {
            Asset modelAsset = assetMap.get(key);
            modelCodes.add(modelAsset.Name.split('-')[0]);
        }
        }

        System.debug('modelCodes ::: ' +modelCodes);

        Map<String, ModelManager__c> modelMap = new Map<String, ModelManager__c>();
        if (modelCodes.size() > 0) {
            List<ModelManager__c> modelList = [SELECT Id, ModelCode__c, Manager__c, cooperationTeam__c FROM ModelManager__c WHERE ModelCode__c IN :modelCodes];
            
            for (ModelManager__c model : modelList) {
                modelMap.put(model.ModelCode__c, model);
            }

            for (Case obj : ticketList) {
                // 2025-05-26 장비 ModelCode로 CS담당자 & 협조부서 팀 매핑
                if (String.isNotEmpty(obj.AssetId)) {
                    Asset ticketAsset = assetMap.get(obj.AssetId);
                    String assetModelCode = ticketAsset.Name.split('-')[0];
                    if(modelMap.containsKey(assetModelCode)) {
                        ModelManager__c ticketModel = modelMap.get(assetModelCode);
                        obj.CSMember__c = ticketModel.Manager__c;
                        obj.CooperationTeam__c = ticketModel.cooperationTeam__c;
                    }
                }
            }
        }
    }

    // 미오후납 티켓 생성시, 장비의 생산처, 설치업체 정보 가져와서 넣어주는 메서드
    public void missingPartTicketEquipmentInfo(List<Case> ticketList) {

        Set<Id> missingIds = new Set<Id>();

        for (Case obj : ticketList) {
            //미오후납 티켓 생성시, 장비의 생산처, 설치업체 정보 가져와서 넣어주기
            if(obj.TicketType__c == 'Internal request' && obj.InternalTicketType__c == 'Missing Part, Wrong Part'){
                missingIds.add(obj.AssetId);
            }
        }

        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        if(missingIds.size()>0){
            assetMap = getMissingInfo(missingIds);
        }

        for (Case obj : ticketList) {
            if(obj.TicketType__c == 'Internal request' && obj.InternalTicketType__c == 'Missing Part, Wrong Part'){
                if(assetMap.containsKey(obj.AssetId)){
                    obj.Producer__c = assetMap.get(obj.AssetId).ManufacturerName__c;
                    obj.InstallationWC__c = assetMap.get(obj.AssetId).InstWorkCenter__c;
                }
            }
        }

    }

    // Insert 일때 순차배정 메서드
    public void ticketInsertSequentialAssignment(List<Case> ticketList) {

        //Ticket 국내 RecordType ID 
        Id recordType_ticket = ticketRecordTypeInfoMap.get('Ticket_Domestic').getRecordTypeId();
        Id recordType_voc = ticketRecordTypeInfoMap.get('VOC_Domestic').getRecordTypeId();

        //일반상담사 순차배정
        Integer generalCnt = 0;
    
        //기술상담사 순차배정
        Integer techCnt = 0;

        //프로그램상담사 순차배정
        Integer pgCnt = 0;

        //VOC 배정 Rule 추후 적용
        Integer vocCnt = 0;

        //VOC 홈페이지 접수 -> 김성엽 파트장님
        Integer vocHome = 0;

        // 설치담당자 배정 -> 김창우 책임님
        Integer installCnt = 0;

        for (Case obj : ticketList) {
            //241126 일반상담사 랜덤 순차 배정 by Hayeong Min
            System.debug('generalCnt :: '+generalCnt);
            System.debug('RecordTypeId :: '+obj.RecordTypeId);
            System.debug('TicketType__c :: '+obj.TicketType__c);
            List<AssignmentMember__c> generalAgents = [SELECT Id, User__c FROM AssignmentMember__c WHERE AssignmentRule__r.Name = '일반상담사 순차배정' AND User__c = :obj.CreatedById ];
            //국내 일반 상담사 순차 배정
            if(obj.RecordTypeId == recordType_ticket && obj.TicketType__c == 'General inquiry' && obj.isSelf__c == FALSE && generalAgents.size() < 1){
                generalCnt++;
            }
            System.debug('generalCnt :: '+ generalCnt);
            //241126 기술상담사 랜덤 순차 배정 by Hayeong Min
            // 모바일 간접접수, 미오후납 -suheon.ha
            if(obj.ReceptionPath__c == 'Mobile Indirect application' && obj.TicketType__c == 'Internal request'){
                obj.TicketType__c = 'Internal request';
                obj.InternalTicketType__c = 'Missing Part, Wrong Part';
                if(obj.FM_Country__c == 'DNS'){//국내의 경우, 배정 Rule 적용
                    installCnt ++;
                }
            }

            //기술상담이면 기술상담사에게 순차배정
            if(obj.FM_Country__c == 'DNS' && obj.TicketType__c == 'Technical inquiry' && obj.isSelf__c == FALSE && obj.InternalTicketType__c != 'Program Inquiry'){
                techCnt ++;
            }

            if(obj.FM_Country__c == 'DNS' && obj.TicketType__c == 'Technical inquiry' && obj.isSelf__c == FALSE && obj.InternalTicketType__c == 'Program Inquiry'){
                pgCnt++;   
            }

            if(obj.RecordTypeId == recordType_voc){
                obj.Status = 'Proceeding';

                if(obj.FM_Country__c == 'DNS'){
                    if(obj.ApplicationRoute2__c == 'Website'){
                        //김성엽파트장님
                        vocHome++;
                    }else{//홈페이지 외 접수시 순차배정
                        obj.OwnerId = UserInfo.getUserID();
                        // vocCnt++;
                    }
                }
            }
        }

        System.debug('generalCnt :: '+generalCnt);
        if(generalCnt > 0){
            Id generalRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = '일반상담사 순차배정'].Id;
            CS_Util.AssignmentRequest generalAssign = new CS_Util.AssignmentRequest();
            generalAssign.aID = generalRuleId;
            generalAssign.size = generalCnt;
            CS_Util.AssignmentWrapper generalAssignResult = CS_Util.getAssignmentUser(generalAssign);
            System.debug('generalAssignResult : '+generalAssignResult);
            System.debug('generalCnt : '+generalCnt);
            Integer generalNum = 0;
            for(Case obj : ticketList){
                if(obj.RecordTypeId == recordType_ticket && obj.TicketType__c == 'General inquiry' && obj.isSelf__c == FALSE){
                    obj.OwnerId = generalAssignResult.userList[generalNum];
                    generalNum++;
                }
            }
        }

        if(installCnt > 0){
            Id installRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = '설치담당자'].Id;
            CS_Util.AssignmentRequest installAssign = new CS_Util.AssignmentRequest();
            installAssign.aID = installRuleId;
            installAssign.size = installCnt;
            CS_Util.AssignmentWrapper installAssignResult = CS_Util.getAssignmentUser(installAssign);
            System.debug('installAssignResult : '+installAssignResult);
            System.debug('installCnt : '+installCnt);
            Integer installNum = 0;
            for(Case obj : ticketList){
                if(obj.ReceptionPath__c == 'Mobile Indirect application' && obj.TicketType__c == 'Internal request'){
                    obj.OwnerId = installAssignResult.userList[installNum];
                    installNum++; 
                }
            }
        }

        if(techCnt > 0){
            // Id techRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = '기술상담사 순차배정'].Id;
            
            // //상담사가 휴가 or 교육일 경우는 제외
            // List<ConsultationAttendance__c> caList = [SELECT Id, Name, CurrencyIsoCode, Consultant__c, Consultant__r.Name, AttendanceDate__c, AttendanceType__c, OffStartTime__c, OffEndTime__c  
            //                                         FROM ConsultationAttendance__c
            //                                         WHERE AttendanceDate__c = TODAY];
            // System.debug('caList : ' + Json.serialize(caList));
            // SET<ID> userIDs = new SET<ID>();            
            // for(ConsultationAttendance__c obj : caList){
            //     if(obj.AttendanceType__c != 'Waiting' &&  obj.OffStartTime__c != null){
            //         Integer startHours = String.isEmpty(obj.OffStartTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(0,2));
            //         Integer startMinute = String.isEmpty(obj.OffStartTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(2,4));
            //         Integer endHours = String.isEmpty(obj.OffEndTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(0,2));
            //         Integer endMinute = String.isEmpty(obj.OffEndTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(2,4));
                    
            //         Datetime offStartDatetime = Datetime.newinstance(Date.today(), Time.newInstance(startHours, startMinute,0,0));
            //         Datetime offEndDatetime = Datetime.newinstance(Date.today(), Time.newInstance(endHours, endMinute,0,0));
                    
            //         if(offStartDatetime <= System.now() && offEndDatetime >= System.now()){
            //             userIDs.add(obj.Consultant__c);
            //         }  
            //     }
            // }
            // System.debug('userIDs : ' + Json.serialize(userIDs));


            // //모든 기술상담원 
            // List<AssignmentMember__c> members = [
            //                                 SELECT Id, User__c, Index__c, CurrentAssignment__c
            //                                 FROM AssignmentMember__c
            //                                 WHERE AssignmentRule__c = :techRuleId
            //                                 ORDER BY Index__c ASC
            //                             ];

            // List<Id> resultUserIds = new List<Id>();

            // Integer currentIndex = -1;
            // for (Integer i = 0; i < members.size(); i++) {
            //     if (members[i].CurrentAssignment__c == true) {
            //         currentIndex = i;
            //         break;
            //     }
            // }

            // Integer memberCount = members.size();
            // Integer startIndex = (currentIndex == -1) ? 0 : (currentIndex + 1 >= memberCount ? 0 : currentIndex + 1);

            // // 휴가자 제외 순차 배정
            // Integer assignedCount = 0;
            // Integer idx = startIndex;
            
            // while (assignedCount < techCnt) {
            //     AssignmentMember__c member = members[idx];

            //     if (!userIDs.contains(member.User__c)) {
            //         resultUserIds.add(member.User__c);
            //         assignedCount++;
            //     }

            //     idx = (idx + 1 >= memberCount) ? 0 : idx + 1;
            // }

            // // 모든 멤버 CurrentAssignment__c 초기화
            // for (AssignmentMember__c m : members) {
            //     m.CurrentAssignment__c = false;
            // }

            // // 마지막 배정된 사용자만 true
            // Id lastUserId = resultUserIds[resultUserIds.size() - 1];
            // for (AssignmentMember__c m : members) {
            //     if (m.User__c == lastUserId) {
            //         m.CurrentAssignment__c = true;
                    
            //         break;
            //     }
            // }
            // set<String> ids = new set<String>();
            // for(AssignmentMember__c ass : members) {
            //     ids.add(ass.Id);
            // }
            // LIst<AssignmentMember__c> assList = [SELECT Id, User__c, Index__c, CurrentAssignment__c
            //                                 FROM AssignmentMember__c
            //                                 WHERE Id IN: ids FOR UPDATE
            //                                 ];
            // System.debug(assList + ' :: assList');
            // Integer techNum = 0;
            CS_SequenceGenerator sequenceGenerator = new CS_SequenceGenerator('기술상담사 순차배정');
            Integer lastIndex = sequenceGenerator.lastIndex;
            for(Case obj : ticketList){
                if(obj.TicketType__c == 'Technical inquiry' && obj.InternalTicketType__c  != 'Program Inquiry'){
                    if(sequenceGenerator.startIndex > lastIndex){
                        sequenceGenerator.startIndex =1;
                    } 
                    obj.OwnerId = sequenceGenerator.generate(sequenceGenerator.startIndex);
                    System.debug('sequenceGenerator.startIndex aa '+ sequenceGenerator.startIndex);
                    System.debug('OwnerId aa '+obj.OwnerId);
                    //기술상담사면 해당 Ticket의 기술상담사 & 일시 입력
                    obj.TechnicalCounselor__c = obj.OwnerId;
                    obj.TechAssignedDatetime__c = System.now();
                    sequenceGenerator.startIndex ++;
                    // techNum++;
                }
                
            }
            
            sequenceGenerator.updateForCurrentAssignment();
            //update members;
        }

        if(pgCnt > 0){
            Id pgRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = '프로그램상담사 순차배정'].Id;
            CS_Util.AssignmentRequest pgAssign = new CS_Util.AssignmentRequest();
            pgAssign.aID = pgRuleId;
            pgAssign.size = pgCnt;
            CS_Util.AssignmentWrapper pgAssignResult = CS_Util.getAssignmentUser(pgAssign);
            System.debug('pgAssignResult : '+pgAssignResult);
            System.debug('pgCnt : '+pgCnt);
            Integer pgNum = 0;
            for(Case obj : ticketList){
                if(obj.TicketType__c == 'Technical inquiry' && obj.InternalTicketType__c  == 'Program Inquiry'){
                    obj.OwnerId = pgAssignResult.userList[pgNum];
                    pgNum++;
                }
            }
        }

        if(vocCnt > 0){
            CS_Util.AssignmentWrapper vocAssignResult = setOwnerSequential('VOC 순차배정', vocCnt);
            Integer vocNum = 0;
            for(Case obj : ticketList){
                if(obj.RecordTypeId == recordType_voc && obj.ApplicationRoute2__c != 'Website'){
                    obj.OwnerId = vocAssignResult.userList[vocNum];
                    vocNum++;
                }
            }
        }

        if(vocHome > 0){
            CS_Util.AssignmentWrapper vocAssignResult = setOwnerSequential('VOC_홈페이지접수', vocHome);
            for(Case obj : ticketList){
                if(obj.RecordTypeId == recordType_voc && obj.ApplicationRoute2__c == 'Website'){
                    obj.OwnerId = vocAssignResult.userList[0];
                }
            }
        }
    }

    // Update일때 순차배정 메서드
    public void ticketUpdateSequentialAssignment(List<Case> ticketList, Map<Id, sObject> oldMap) {
        
        Integer techCnt = 0;
        Integer pgCnt = 0;

        for(Case obj : ticketList){
            Case oldObj = (Case) oldMap.get(obj.Id);

            //Technical inquiry && Failure receipt일 때 기술상담사 순차 배정 by Hayeong-Min
            //Technical inquiry && Program Inquiry일 때 PG상담사 순차 배정 by Hayeong-Min
            if(obj.FM_Country__c == 'DNS' && (obj.TicketType__c != oldObj.TicketType__c)){//국내 접수의 경우 Ticket 유형(대)가 변경될 때
                if(obj.InternalTicketType__c == 'Failure receipt' || obj.InternalTicketType__c == 'Technical consultation'){//고장접수 & 기술상담 
                    techCnt++;
                }else if(obj.InternalTicketType__c == 'Program Inquiry'){
                    pgCnt++;
                }
            }


        }

        // 기술상담사 순차배정 번호 Update
        if(techCnt > 0){
            // Id techRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = '기술상담사 순차배정'].Id;
            
            // //상담사가 휴가 or 교육일 경우는 제외
            // List<ConsultationAttendance__c> caList = [SELECT Id, Name, CurrencyIsoCode, Consultant__c, Consultant__r.Name, AttendanceDate__c, AttendanceType__c, OffStartTime__c, OffEndTime__c  
            //                                         FROM ConsultationAttendance__c
            //                                         WHERE AttendanceDate__c = TODAY];
            // System.debug('caList : ' + Json.serialize(caList));
            // SET<ID> userIDs = new SET<ID>();            
            // for(ConsultationAttendance__c obj : caList){
            //     if(obj.AttendanceType__c != 'Waiting' &&  obj.OffStartTime__c != null){
            //         Integer startHours = String.isEmpty(obj.OffStartTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(0,2));
            //         Integer startMinute = String.isEmpty(obj.OffStartTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(2,4));
            //         Integer endHours = String.isEmpty(obj.OffEndTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(0,2));
            //         Integer endMinute = String.isEmpty(obj.OffEndTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(2,4));
                    
            //         Datetime offStartDatetime = Datetime.newinstance(Date.today(), Time.newInstance(startHours, startMinute,0,0));
            //         Datetime offEndDatetime = Datetime.newinstance(Date.today(), Time.newInstance(endHours, endMinute,0,0));
                    
            //         if(offStartDatetime <= System.now() && offEndDatetime >= System.now()){
            //             userIDs.add(obj.Consultant__c);
            //         }  
            //     }
            // }
            // System.debug('userIDs : ' + Json.serialize(userIDs));


            // //모든 기술상담원 
            // List<AssignmentMember__c> members = [
            //                                 SELECT Id, User__c, Index__c, CurrentAssignment__c
            //                                 FROM AssignmentMember__c
            //                                 WHERE AssignmentRule__c = :techRuleId
            //                                 ORDER BY Index__c ASC
            //                             ];

            // List<Id> resultUserIds = new List<Id>();

            // Integer currentIndex = -1;
            // for (Integer i = 0; i < members.size(); i++) {
            //     if (members[i].CurrentAssignment__c == true) {
            //         currentIndex = i;
            //         break;
            //     }
            // }

            // Integer memberCount = members.size();
            // Integer startIndex = (currentIndex == -1) ? 0 : (currentIndex + 1 >= memberCount ? 0 : currentIndex + 1);

            // // 휴가자 제외 순차 배정
            // Integer assignedCount = 0;
            // Integer idx = startIndex;
            
            // while (assignedCount < techCnt) {
            //     AssignmentMember__c member = members[idx];

            //     if (!userIDs.contains(member.User__c)) {
            //         resultUserIds.add(member.User__c);
            //         assignedCount++;
            //     }

            //     idx = (idx + 1 >= memberCount) ? 0 : idx + 1;
            // }

            // // 모든 멤버 CurrentAssignment__c 초기화
            // for (AssignmentMember__c m : members) {
            //     m.CurrentAssignment__c = false;
            // }

            // // 마지막 배정된 사용자만 true
            // Id lastUserId = resultUserIds[resultUserIds.size() - 1];
            // for (AssignmentMember__c m : members) {
            //     if (m.User__c == lastUserId) {
            //         m.CurrentAssignment__c = true;
            //         break;
            //     }
            // }
            // System.debug('resultUserIds :: '+resultUserIds);
            
            // update members;
            
            Integer techNum = 0;
            Map<Id, UserWrapper> userInfo = getUserInfoMap();
          
            CS_SequenceGenerator sequenceGenerator = new CS_SequenceGenerator('기술상담사 순차배정');
            Integer lastIndex = sequenceGenerator.lastIndex;
            for(Case obj : ticketList){
                Case oldObj = (Case) oldMap.get(obj.Id);
                System.debug(sequenceGenerator.startIndex + ' :: sequenceGenerator.startIndex');
                if(sequenceGenerator.startIndex > lastIndex){
                    System.debug(sequenceGenerator.startIndex + ' if Start Index' );
                    System.debug(lastIndex + ' if lastIndex' );
                    sequenceGenerator.startIndex =1;
                } 
                if(obj.TicketType__c != oldObj.TicketType__c){ //일반문의 -> 기술문의
                    if(obj.InternalTicketType__c == 'Failure receipt' || obj.InternalTicketType__c == 'Technical consultation'){//고장접수 & 기술상담 
                        SYstem.debug(sequenceGenerator.startIndex + ' ::: sequenceGenerator.startIndex');
                        System.debug(sequenceGenerator.lastIndex + ' :: sequenceGenerator.lastIndex');
                        obj.OwnerId = sequenceGenerator.generate(sequenceGenerator.startIndex);
                        obj.TechnicalCounselor__c = sequenceGenerator.generate(sequenceGenerator.startIndex);
                        obj.TechAssignedDatetime__c = System.now();
                        sequenceGenerator.startIndex ++;
                        techNum++;

                    }
                }else{ // Ticket 유형 (대)가 동일한 경우
                    if(oldObj.InternalTicketType__c == 'Program Inquiry' && (obj.InternalTicketType__c == 'Failure receipt' || obj.InternalTicketType__c == 'Technical consultation')){
                        obj.OwnerId = sequenceGenerator.generate(sequenceGenerator.startIndex);
                        obj.TechnicalCounselor__c = sequenceGenerator.generate(sequenceGenerator.startIndex);
                        obj.TechAssignedDatetime__c = System.now();
                        sequenceGenerator.startIndex ++;
                        techNum++;
                    }
                }
            }
            sequenceGenerator.updateForCurrentAssignment();
        }

        // 프로그램상담사 순차배정 번호 Update
        if(pgCnt > 0){
            Id pgRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = '프로그램상담사 순차배정'].Id;
            CS_Util.AssignmentRequest pgAssign = new CS_Util.AssignmentRequest();
            pgAssign.aID = pgRuleId;
            pgAssign.size = pgCnt;
            CS_Util.AssignmentWrapper pgAssignResult = CS_Util.getAssignmentUser(pgAssign);
            System.debug('pgAssignResult : '+pgAssignResult);
            System.debug('pgCnt : '+pgCnt);
            Integer pgNum = 0;
            for(Case obj : ticketList){
                Case oldObj = (Case) oldMap.get(obj.Id);
                if(obj.TicketType__c != oldObj.TicketType__c){ //일반문의 -> 기술문의
                    if(obj.InternalTicketType__c == 'Program Inquiry'){
                        obj.OwnerId = pgAssignResult.userList[pgNum];
                        pgNum++;
                    }
                }else{ // Ticket 유형 (대)가 동일한 경우
                    if((oldObj.InternalTicketType__c == 'Failure receipt' || oldObj.InternalTicketType__c == 'Technical consultation') && obj.InternalTicketType__c == 'Program Inquiry'){
                        obj.OwnerId = pgAssignResult.userList[pgNum];
                        pgNum++;
                    }
                }
            }
        }
    }

    // 요청자 번호 자동맵핑 메서드
    public void setRequesterPhone(List<Case> ticketList, Map<Id, sObject> oldMap, String triggerType) {
        Set<Id> contactIds = new Set<Id>();

        for(Case obj : ticketList){
            if (triggerType == 'Before Insert') {
                if(obj.Requester__c != null){
                    contactIds.add(obj.Requester__c);
                }
            } else if (triggerType == 'Before Update') {
                Case oldObj = (Case) oldMap.get(obj.Id);

                if(obj.Requester__c != oldObj.Requester__c){
                    contactIds.add(obj.Requester__c);
                }
            }
        }

        //요청자 정보를 기반으로 phone 정보 자동 맵핑
        if(!contactIds.isEmpty()){
            List<Contact> contactList = [SELECT Id, MobilePhone FROM Contact WHERE ID IN :contactIds];
            Map<Id, String> conMap = new Map<Id, String>();
            for(Contact con : contactList){
                conMap.put(con.Id, con.MobilePhone);
            }
            System.debug('conMap :: '+conMap);

            for(Case obj : ticketList){
                if (triggerType == 'Before Insert') {
                    if(obj.Requester__c != null){
                        obj.Phone__c = conMap.get(obj.Requester__c);
                    }
                } else if (triggerType == 'Before Update') {
                    Case oldObj = (Case) oldMap.get(obj.Id);
                    if(obj.Requester__c != oldObj.Requester__c){
                        obj.Phone__c = conMap.get(obj.Requester__c);
                    }
                }
            }
        }
    }

    // Ticket 생성시 조건별 정보 자동맵핑
    public void setBeforeInsertInfo(List<Case> ticketList) {

        // Ticket DNSA RecordType ID 
        Id recordType_ticket_dnsa = ticketRecordTypeInfoMap.get('Ticket_DNSA').getRecordTypeId();

        Set<Id> accountIds = new Set<Id>();
        for(Case ca : ticketList){
            if(ca.AccountId != null){
                accountIds.add(ca.AccountId);
            }
        }

        Map<Id, Account> accMap = new Map<Id, Account>(
        [SELECT Id, SalesOffice__c FROM Account WHERE Id IN :accountIds]);
        System.debug('@@ accMap : ' + accMap);

        for(Case obj : ticketList){
            // DNSA Ticket 일 경우 Escalation Lv2 시작 - Sangil,Park 2025-03-07
            if(obj.RecordTypeID == recordType_ticket_dnsa) obj.EscLev__c = 'Esc.Lev 2';

            obj.InstallationDefect__c = 'N';
            obj.SkillCheck__c = 'N';

            System.debug('obj.isSelf__c ::: ' +obj.isSelf__c);
            if(!obj.isSelf__c){
                obj.ApplicationDateTime__c = System.now(); 
            }

            //접수일시는 입력하지 않으면 자동으로 생성일로 지정
            if(obj.ApplicationDateTime__c == NULL){
                obj.ApplicationDateTime__c = System.now();
            }

            //수리요청일시는 입력하지 않으면 자동으로 생성일 + 1시간 넣기 by 김창우 책임님 요청
            if(obj.RepairRequestDateTime__c == NULL){
                obj.RepairRequestDateTime__c = obj.ApplicationDateTime__c.addHours(1);
            }

            // 티켓을 기술상담>고장접수로 저장할때 사용자가 입력한 값이 없으면
            // 고장일시 : 접수일시와 동일값, 수리요청일시 : 접수일시 + 1시간
            if(obj.TicketType__c == 'Technical inquiry' && obj.InternalTicketType__c == 'Failure receipt'){
                
                //고장일시도 입력하지 않으면 자동으로 접수일시로 지정
                if(obj.BreakdownDateTime__c == NULL){
                    obj.BreakdownDateTime__c = obj.ApplicationDateTime__c;
                }
            }

            // 내부요청 > 납품 후 교육
            // 수리요청일시 : 티켓 생성 시 교육 요청일(1)  값으로 기본 생성
            if(obj.TicketType__c == 'Internal request' && obj.InternalTicketType__c == 'Post-delivery training'){
                obj.RepairRequestDateTime__c  = obj.TrainingDateTime1__c;
            }

            //알림톡 접수분석 관련 Field 매핑 - Sangil,Park, 2025-02-18
            obj.IsAlarmTalk__c = obj.ReceptionPath__c == 'Alarm Talk' ? 1 : 0;
            obj.IsCallCenter__c = obj.ReceptionPath__c == 'Call Center(Representative)' ? 1 : 0;
            obj.IsReceptionNight__c = obj.ApplicationDateTime__c.Hour() >= 17 && obj.ApplicationDateTime__c.MINUTE() >= 30 ? 1 : 0;

            //티켓 Account 의 Sales Office 값을 Ticket.Sales_Office__c 에 넣어줌
            Account acc = accMap.get(obj.AccountId);
            obj.Sales_Office__c = (acc != null) ? acc.SalesOffice__c : '';
        }
    }

    // 조건에 따라 Email, Notification, AlarmTalk을 전송하는 메서드 (After Insert)
    public void sendAfterInsertAlert(List<Case> ticketList) {

        List<UTIL_Alert.HistoryWrapper> hwList = new List<UTIL_Alert.HistoryWrapper>();

        Map<Id, UserWrapper> userInfo = getUserInfoMap();
        
        // 2024.11.18 Suheon.Ha 간접접수시 오우현 직장을 포함한 특정 그룹에 알람 반드시 포함
        NotiReceptionList__c indirectRecep = NotiReceptionList__c.getInstance('IndirectReception');
        String indirectRecepName = indirectRecep.UserName__c;
        User indrectUser = [SELECT Id FROM User WHERE UserName =:indirectRecepName];
        
        //20250122_박지영 불완전 알림톡 접수 시 접수상담사 리더(김윤수)에게도 Noti 전송 (알림톡 일반 접수 시) 
        //20250227 by Hayeong Min 홈페이지 접수 시 접수상담사 리더에게도 Noti 전송
        NotiReceptionList__c noRecep = NotiReceptionList__c.getInstance('AlarmTalk');
        String alarmLeaderName = noRecep.UserName__c;
        User alarmLeader = [SELECT Id FROM User WHERE UserName =:alarmLeaderName];

        //20250227 by Hayeong Min 홈페이지 접수 시 '홈페이지 문의입니다.' 추가한 알림 발송
        // String homepageTicketAssignId = [SELECT Id FROM AlertManager__c WHERE Name = 'Homepage Ticket Assignment Alert' AND IsActive__c = TRUE].Id;
        // String homepageLeaderId = [SELECT Id FROM AlertManager__c WHERE Name = 'Homepage Ticket Assignment Receptionist Alert' AND IsActive__c = TRUE].Id;

        // 프로그램 순차배정 AssignmentRule ID
        AssignmentRule__c pgRule = [SELECT ID FROM AssignmentRule__c  WHERE Name ='프로그램상담사 순차배정' LIMIT 1];
        List<AssignmentMember__c> pgMembers = [SELECT Id, User__c FROM AssignmentMember__c WHERE AssignmentRule__c = :pgRule.Id];

        for(Case obj : ticketList){
            //AlertType : Notfication
            UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
            if(obj.ReceptionPath__c == 'Alarm Talk' && obj.TicketType__c =='General inquiry'){
                //20250225_박지영 불완전 알림톡 접수 시 담당자에게 Noti 전송 (알림톡 일반 접수 시)
                notihw.alertID = this.alertManagerMap.get('Incomplete Alarm Talk Ticket Assignment Alert');
                notihw.targetID = obj.Id;
                notihw.alertType = 'Notification';
                notihw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                notihw.receiverforID = new Set<Id>{obj.OwnerId};
                notihw.alertLanguage = userInfo.get(obj.OwnerId).language;
                System.debug('notihw ::: '+notihw);
                hwList.add(notihw);
            } else {
                //241024 Ticket을 배정받은 담당자에게 Noti 전송 by Hayeong Min
                if(obj.Origin != 'DNS_Homepage' && obj.Origin != 'DNSA_Email'){
                    notihw.alertID = this.alertManagerMap.get('Ticket Assignment Alert');
                    notihw.targetID = obj.Id;
                    notihw.alertType = 'Notification';
                    notihw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                    notihw.receiverforID = new Set<Id>{obj.OwnerId};
                    notihw.alertLanguage = userInfo.get(obj.OwnerId).language;
                    System.debug('notihw ::: '+notihw);
                    hwList.add(notihw);
                }
            }

            
            if(obj.FM_Country__c == 'DNS'){
                //250307 by Hayeong Min 설치요청 Ticket 배정 이메일 Ticket Owner(센터장)에게 발송
                if(obj.TicketType__c == 'Internal request' && obj.InternalTicketType__c == 'Installation request'){
                    UTIL_Alert.historyWrapper emailhw = new UTIL_Alert.HistoryWrapper();
                    emailhw.alertID = this.alertManagerMap.get('Ticket Assignment Alert');
                    emailhw.targetID = obj.Id;
                    emailhw.alertType = 'Email';
                    // emailhw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                    emailhw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c, URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Case/' + obj.Id + '/view'};
                    emailhw.receiverforEmail = new List<String>{userInfo.get(obj.OwnerId).Email};
                    emailhw.alertLanguage = userInfo.get(obj.OwnerId).language;
                    System.debug('emailhw ::: ' + emailhw);
                    hwList.add(emailhw);
                }

                // 간접접수시 오우현 직장 알람 반드시 포함 --> 국내
                if(obj.ReceptionPath__c == 'Indirect application' || obj.ReceptionPath__c == 'Mobile Indirect application'){
                    UTIL_Alert.historyWrapper extraNotiHw = new UTIL_Alert.HistoryWrapper();
                    // extraNotiHw.alertID = alertManagerId;
                    extraNotiHw.alertID = this.alertManagerMap.get('Ticket Assignment Alert');
                    extraNotiHw.targetID = obj.Id;
                    extraNotiHw.alertType = 'Notification';
                    extraNotiHw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                    extraNotiHw.receiverforID = new Set<Id>{indrectUser.Id};
                    extraNotiHw.alertLanguage = userInfo.get(indrectUser.Id).language;
                    System.debug('extraNotiHw ::: ' + extraNotiHw);
                    hwList.add(extraNotiHw);
                }

                // 알림톡 일반 접수 시 접수리더(김윤수) 알람
                if(obj.ReceptionPath__c == 'Alarm Talk' && obj.TicketType__c =='General inquiry'){
                    UTIL_Alert.historyWrapper alarmNoti = new UTIL_Alert.historyWrapper();
                    // alarmNoti.alertID = leaderAlertManagerId;
                    alarmNoti.alertID = this.alertManagerMap.get('Ticket Assignment Receptionist Alert');
                    alarmNoti.targetID = obj.Id;
                    alarmNoti.alertType = 'Notification';
                    alarmNoti.elementList.add(obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c);
                    alarmNoti.elementList.add(userInfo.get(obj.OwnerId).Name);
                    alarmNoti.receiverforID = new Set<Id>{alarmLeader.Id};
                    alarmNoti.alertLanguage = userInfo.get(alarmLeader.Id).language;
                    System.debug('alarmNoti ::: '+alarmNoti);
                    hwList.add(alarmNoti);
                }

                //콜백 티켓 접수 시 접수리더(김윤수) 알람
                if(obj.InternalTicketType__c == 'Request callback' && obj.TicketType__c =='General inquiry'){
                    UTIL_Alert.historyWrapper alarmNoti = new UTIL_Alert.historyWrapper();
                    alarmNoti.alertID = this.alertManagerMap.get('Callback Ticket Assignment Receptionist Alert');
                    alarmNoti.targetID = obj.Id;
                    alarmNoti.alertType = 'Notification';
                    alarmNoti.elementList.add(obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c);
                    alarmNoti.elementList.add(userInfo.get(obj.OwnerId).Name);
                    alarmNoti.receiverforID = new Set<Id>{alarmLeader.Id};
                    alarmNoti.alertLanguage = userInfo.get(alarmLeader.Id).language;
                    System.debug('alarmNoti ::: '+alarmNoti);
                    hwList.add(alarmNoti);
                }

                //프로그램 문의 접수 시 PG 상담사에게 모두 알림 발송
                if(obj.TicketType__c == 'Technical inquiry' && obj.InternalTicketType__c == 'Program Inquiry'){
                    if(pgMembers.size()>0){
                        for(AssignmentMember__c pg : pgMembers){
                            if (obj.OwnerId == pg.User__c) continue;
                            UTIL_Alert.historyWrapper alarmNoti = new UTIL_Alert.historyWrapper();
                            System.debug('alert ID ::: '+ this.alertManagerMap.get('Program inquiry Alert'));
                            alarmNoti.alertID = this.alertManagerMap.get('Program inquiry Alert');
                            alarmNoti.targetID = obj.Id;
                            alarmNoti.alertType = 'Notification';
                            alarmNoti.elementList.add(obj.FM_TicketName__c);
                            alarmNoti.elementList.add(userInfo.get(obj.OwnerId).Name);
                            alarmNoti.receiverforID = new Set<Id>{pg.User__c};
                            alarmNoti.alertLanguage = userInfo.get(pg.User__c).language;
                            System.debug('alarmNoti ::: '+alarmNoti);
                            hwList.add(alarmNoti);
                        }
                    }
                }
            }

            //기술상담이면 기술상담사에게 순차배정 알림 by hayeong min
            if(obj.FM_Country__c == 'DNS' && obj.TicketType__c == 'Technical inquiry' && obj.isSelf__c == FALSE && obj.InternalTicketType__c != 'Program Inquiry'){
                UTIL_Alert.historyWrapper admindNoti = new UTIL_Alert.HistoryWrapper();
                admindNoti.alertID = this.alertManagerMap.get('AdminTechAlert');
                admindNoti.targetID = obj.Id;
                admindNoti.alertType = 'Email';
                // admindNoti.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                admindNoti.elementList = new List<String>{obj.CaseNumber+ ' - '+userInfo.get(obj.OwnerId).Name, URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Case/' + obj.Id + '/view'};
                admindNoti.receiverforEmail = new List<String>{'sangil.park@dncompany.com'};
                // admindNoti.receiverforEmail = new List<String>{'hayeong.min@dncompany.com'};
                admindNoti.alertLanguage = 'ko';
                System.debug('admindNoti ::: ' + admindNoti);
                hwList.add(admindNoti);
            }
        }

        System.debug('hwList :: '+hwList);
        if(hwList.size() > 0) UTIL_Alert.runAlertEvent(hwList);
    }

    // 조건에 따라 Email, Notification, AlarmTalk을 전송하는 메서드 (After Update)
    public void sendAfterUpdateAlert(List<Case> ticketList, Map<Id, sObject> oldMap) {

        Map<Id, UserWrapper> userInfo = getUserInfoMap();
        AssignmentRule__c pgRule = [SELECT ID FROM AssignmentRule__c  WHERE Name ='프로그램상담사 순차배정' LIMIT 1];
        List<AssignmentMember__c> pgMembers = [SELECT Id, User__c FROM AssignmentMember__c WHERE AssignmentRule__c = :pgRule.Id];

        Set<Id> ownerChanged = new Set<Id>();//Owner 변경 관리용 Set

        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();

        for(Case obj : ticketList){
            Case oldObj = (Case) oldMap.get(obj.Id);

            //Owner 변경 시 Alert 전송
            if(obj.OwnerId != oldObj.OwnerId){
                ownerChanged.add(obj.Id);

                // 20250424 서영덕 DNSA Ticket Owner 변경시 Email발송 추가
                if (obj.FM_RecordType__c == 'Ticket(DNSA)') {

                    UserWrapper originOwner = userInfo.get(oldObj.OwnerId);
                    UserWrapper changeByOwner = userInfo.get(obj.OwnerId);

                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = this.alertManagerMap.get('DNSA Ticket Owner Changed');
                    notihw.targetID = obj.Id;
                    notihw.alertType = 'Email';
                    notihw.title = obj.FM_DNSA_TicketName__c + ' TICKET OWNER IS CHANGED';
                    notihw.elementList = new List<String>{obj.FM_DNSA_TicketName__c, originOwner.Name, changeByOwner.Name};
                    notihw.receiverforEmail = new List<String>{changeByOwner.Email};
                    notihw.alertLanguage = 'en';
                    wrapperList.add(notihw);
                }

                //250112 Ticket을 배정받은 담당자에게 Noti 전송 by Hayeong Min
                //Owner 변경 시 ticket TeamMember에게 Noti 전송
                if(obj.Origin == 'DNS_Homepage'){
                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = this.alertManagerMap.get('Homepage Ticket Assignment Alert');
                    notihw.targetID = obj.Id;
                    notihw.alertType = 'Notification';
                    notihw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                    notihw.receiverforID = new Set<Id>{obj.OwnerId};
                    notihw.alertLanguage = 'ko';
                    System.debug('notihw ::: '+notihw);
                    wrapperList.add(notihw);
                } else if (obj.EscLev__c != oldObj.EscLev__c) {
                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = this.alertManagerMap.get('Ticket Change Escalation');
                    notihw.targetID = obj.Id;
                    notihw.alertType = 'Notification';
                    notihw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c, obj.EscLev__c};
                    notihw.receiverforID = new Set<Id>{obj.OwnerId};
                    notihw.alertLanguage = userInfo.get(obj.OwnerId).language;
                    System.debug('notihw ::: '+notihw);
                    wrapperList.add(notihw);
                } else{
                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = this.alertManagerMap.get('Ticket Assignment Alert');
                    notihw.targetID = obj.Id;
                    notihw.alertType = 'Notification';
                    notihw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                    notihw.receiverforID = new Set<Id>{obj.OwnerId};
                    notihw.alertLanguage = userInfo.get(obj.OwnerId).language;
                    System.debug('notihw ::: '+notihw);
                    wrapperList.add(notihw);
                }

                // 프로그램 문의 접수 시 PG 상담사에게 모두 알림 발송
                if((oldObj.InternalTicketType__c != obj.InternalTicketType__c) && (obj.InternalTicketType__c == 'Program Inquiry')){
                    if(pgMembers.size()>0){
                        for(AssignmentMember__c pg : pgMembers){
                            if (pg.User__c == obj.OwnerId) continue;
                            UTIL_Alert.historyWrapper alarmNoti = new UTIL_Alert.historyWrapper();
                            System.debug('alert ID ::: '+ this.alertManagerMap.get('Program inquiry Alert'));
                            alarmNoti.alertID = this.alertManagerMap.get('Program inquiry Alert');
                            alarmNoti.targetID = obj.Id;
                            alarmNoti.alertType = 'Notification';
                            alarmNoti.elementList.add(obj.FM_TicketName__c);
                            alarmNoti.elementList.add(userInfo.get(obj.OwnerId).Name);
                            alarmNoti.receiverforID = new Set<Id>{pg.User__c};
                            alarmNoti.alertLanguage = userInfo.get(pg.User__c).language;
                            System.debug('alarmNoti ::: '+alarmNoti);
                            wrapperList.add(alarmNoti);
                        }
                    }
                }

                // 일반문의 -> 기술문의
                if(obj.TicketType__c != oldObj.TicketType__c){
                    if(obj.InternalTicketType__c == 'Failure receipt' || obj.InternalTicketType__c == 'Technical consultation'){//고장접수 & 기술상담                         
                        UTIL_Alert.historyWrapper admindNoti = new UTIL_Alert.HistoryWrapper();
                        admindNoti.alertID = this.alertManagerMap.get('AdminTechAlert');
                        admindNoti.targetID = obj.Id;
                        admindNoti.alertType = 'Email';
                        admindNoti.elementList = new List<String>{obj.CaseNumber+ ' - '+userInfo.get(obj.OwnerId).Name, URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Case/' + obj.Id + '/view'};
                        admindNoti.receiverforEmail = new List<String>{'sangil.park@dncompany.com'};
                        admindNoti.alertLanguage = 'ko';
                        System.debug('admindNoti ::: ' + admindNoti);
                        wrapperList.add(admindNoti);

                    }
                }else{ // Ticket 유형 (대)가 동일한 경우
                    if(oldObj.InternalTicketType__c == 'Program Inquiry' && (obj.InternalTicketType__c == 'Failure receipt' || obj.InternalTicketType__c == 'Technical consultation')){
                        UTIL_Alert.historyWrapper admindNoti = new UTIL_Alert.HistoryWrapper();
                        admindNoti.alertID = this.alertManagerMap.get('AdminTechAlert');
                        admindNoti.targetID = obj.Id;
                        admindNoti.alertType = 'Email';
                        admindNoti.elementList = new List<String>{obj.CaseNumber+ ' - '+userInfo.get(obj.OwnerId).Name, URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Case/' + obj.Id + '/view'};
                        admindNoti.receiverforEmail = new List<String>{'sangil.park@dncompany.com'};
                        admindNoti.alertLanguage = 'ko';
                        System.debug('admindNoti ::: ' + admindNoti);
                        wrapperList.add(admindNoti);
                    }
                }
            }

            // 설치시운전티켓 상태 Reject 시 내부요청자에게 메일 발송
            if((oldObj.Status != obj.Status) && obj.Status == 'Reject' && obj.InternalTicketType__c == 'Installation request') {
                UTIL_Alert.HistoryWrapper wrapper = new UTIL_Alert.HistoryWrapper();
                wrapper.alertID         = this.alertManagerMap.get('Install Request Reject Noti');
                wrapper.targetID        = obj.Id;
                wrapper.alertType       = 'Notification';
                wrapper.elementList.add(obj.CaseNumber);
                wrapper.receiverforID   = new Set<Id>{obj.InternalRequester__c};
                wrapper.alertLanguage   = 'ko';
                wrapperList.add(wrapper);
            }

            Boolean isChanged = isFieldSetChanged(obj,oldObj);
            System.debug('==============');
            System.debug(isChanged);
            System.debug('==============');
            // Callservice 종결 티켓 알림톡 발송
            if (obj.Status == 'Closed' && obj.EndOfReason__c == 'Call Service' && obj.isAlarmToCustomer__c && isChanged) {
                System.debug('알림톡');
                UTIL_Alert.HistoryWrapper wrapper = new UTIL_Alert.HistoryWrapper();
                wrapper.alertID             = this.alertManagerMap.get('Ticket CallService Completed');
                wrapper.targetID            = obj.Id;
                wrapper.alertType           = 'AlarmTalk';
                wrapper.receiverforPhone    = new Set<String>{obj.FM_PhoneNumber__c};
                wrapper.alertLanguage       = 'ko';
                wrapper.elementMap          = new Map<String, String>();
                wrapperList.add(wrapper);
            }
        }

        if(ownerChanged.size()>0){
            List<CaseTeamMember> members = [SELECT Id, MemberId, Member.Name, ParentId, Parent.OwnerId, Parent.FM_RecordType__c, Parent.FM_TicketName__c, TeamRoleId, TeamRole.Name, Parent.Owner.Name FROM CaseTeamMember WHERE ParentId IN :ownerChanged];
            if(members.size() > 0){
                for(CaseTeamMember obj : members){
                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = this.alertManagerMap.get('Ticket Owner Changed');
                    notihw.targetID = obj.ParentId;
                    notihw.alertType = 'Notification';
                    notihw.elementList = new List<String>{obj.Parent.FM_RecordType__c +'  '+ obj.Parent.FM_TicketName__c, obj.Parent.Owner.Name};
                    notihw.receiverforID = new Set<Id>{obj.MemberId};
                    notihw.alertLanguage = userInfo.get(obj.MemberId).language;
                    System.debug('notihw ::: '+notihw);
                    wrapperList.add(notihw);
                }
            }
        }

        if(wrapperList.size() > 0) UTIL_Alert.runAlertEvent(wrapperList);

    }

    // Owner를 Ticket Team Member에 insert하는 메서드
    public void insertTicketTeamMember(List<Case> ticketList, Map<Id, sObject> oldMap, String triggerType) {

        Set<Id> ownerChanged = new Set<Id>();
        Set<Id> csMemIds = new Set<Id>();

        for(Case obj : ticketList){
            if (triggerType == 'After Insert') {
                //처음 배정된 Owner Ticket Team Member에 넣기
                if(obj.Origin != 'DNS_Homepage'){
                    csMemIds.add(obj.OwnerId);
                }
            } else if (triggerType == 'After Update') {
                Case oldObj = (Case) oldMap.get(obj.Id);

                if(obj.OwnerId != oldObj.OwnerId){
                    ownerChanged.add(obj.Id);
                    csMemIds.add(obj.OwnerId);
                }
            }
        }

        // Owner를 Ticket Team Member에 insert
        if (triggerType == 'After Insert') {
            if(csMemIds.size() > 0){
                List<CaseTeamMember> csMems = createCSMem(csMemIds, ticketList);
                System.debug('TicketTeamMember ::: '+csMems);
                insert csMems;
            }
        } else if (triggerType == 'After Update') {
            if(ownerChanged.size()>0){

                List<CaseTeamMember> members = [SELECT Id, MemberId, Member.Name, ParentId, Parent.OwnerId, Parent.FM_RecordType__c, Parent.FM_TicketName__c, TeamRoleId, TeamRole.Name, Parent.Owner.Name FROM CaseTeamMember WHERE ParentId IN :ownerChanged];
                System.debug('Ticket Team Member : '+members);
                Map<String, List<String>> ownerCheckMap = new Map<String, List<String>>();
                if(members.size()>0){
                    for(CaseTeamMember obj : members){
                        List<String> valueList = new List<String>();
                        if (ownerCheckMap.get(obj.ParentId) != null)  valueList = ownerCheckMap.get(obj.ParentId);
                        valueList.add(obj.MemberId);
                        ownerCheckMap.put(obj.ParentId, valueList);
                    }
                }

                // Changed Owner insert
                List<Case> ownerChangeTicket = [SELECT Id, OwnerId FROM Case WHERE Id IN :ownerChanged];
                
                System.debug('ownerChanged ::'+ownerChanged);
                List<CaseTeamMember> csMem = createCSMem(csMemIds, ownerChangeTicket);
                System.debug('CaseTeamMember ::: '+csMem);

                List<CaseTeamMember> insertCsMem = new List<CaseTeamMember>();
                for (CaseTeamMember member : csMem) {
                    if (ownerCheckMap.containsKey(member.ParentId)) {
                        if (!ownerCheckMap.get(member.ParentId).contains(member.MemberId)) {
                            insertCsMem.add(member);
                        }
                    }
                }

                if (insertCsMem.size() > 0) insert insertCsMem;
            }
        }
    }

    // 납품 후 교육 생성시 Owner에게 SMS발송 하는 메서드 (2025-01-22 서영덕 추가)
    public void sendAfterInsertSMS(List<Case> ticketList) {

        Set<String> smsTicketIds = new Set<String>();

        for(Case obj : ticketList){
            
            if (obj.InternalTicketType__c == 'Post-delivery training') {
                smsTicketIds.add(obj.Id);
            }
        }

        // Owner에게 SMS발송
        if (smsTicketIds.size() > 0) sendSMS(smsTicketIds);

    }

    // 진행중인 오더가 있는데 고객취소할 때 취소 불가 validation 메서드
    public void customerCancelValidation(List<Case> ticketList, Map<Id, sObject> oldMap) {

        Map<Id, Boolean> customerCanceled = new Map<Id, Boolean>();

        for(Case obj : ticketList) {
            Case oldObj = (Case) oldMap.get(obj.Id);

            //250526 진행중인 오더가 있는데 고객취소할 때 취소 불가 validation 
            if(obj.EndOfReason__c != oldObj.EndOfReason__c && obj.EndOfReason__c == 'Customer Cancellation'){
                customerCanceled.put(obj.Id, true);
            }
        }

        if(!customerCanceled.isEmpty()){
            List<WorkOrder> woList = [SELECT Id, CaseId, Status FROM WorkOrder WHERE CaseId IN : customerCanceled.keySet()];
            if(woList.size()>0){
                for(WorkOrder wo : woList){
                    if(wo.Status != 'Canceled'){
                        customerCanceled.put(wo.CaseId, false);
                    }
                }
            }
        }

        for(Case obj : ticketList){
            Case oldObj = (Case) oldMap.get(obj.Id);

            //250526 진행중인 오더가 있는데 고객취소할 때 취소 불가 validation 
            if(customerCanceled.containsKey(obj.Id) && customerCanceled.get(obj.Id) == false){
                obj.addError(System.Label.DNS_E_ProgressServiceOrderExist);
            }
        }
    }

    // 고객 변경시 삭제된 고객사 Validation 메서드
    public void accountUpdateValidation(List<Case> ticketList, Map<Id, sObject> oldMap) {
        Set<Id> accIds = new Set<Id>();

        for(Case obj : ticketList) {
            Case oldObj = (Case) oldMap.get(obj.Id);
            
            if(obj.AccountId != oldObj.AccountId && obj.AccountId != null){
                //변경한 AccountID의 IsErpDelete__c가 True인 경우에는 Update 막기
                accIds.add(obj.AccountId);
            }
        }


        Map<Id, Boolean> isDelAcc = new Map<Id, Boolean>();
        if(accIds.size()>0){
            List<Account> accList = [SELECT Id, IsErpDelete__c FROM Account WHERE ID IN : accIds];
            for(Account acc : accList){
                isDelAcc.put(acc.Id, acc.IsErpDelete__c);
            }
        }

        for(Case obj : ticketList) {
            Case oldObj = (Case) oldMap.get(obj.Id);

            if(obj.AccountId != oldObj.AccountId && obj.AccountId != null && isDelAcc.containsKey(obj.AccountId) && isDelAcc.get(obj.AccountId) == true){
                obj.addError(System.Label.DNS_E_DelAccount);
            }
        }
    }

    // Ticket update시 조건별 정보 자동맵핑 & validation 메서드
    public void setBeforeUpdateInfo(List<Case> ticketList, Map<Id, sObject> oldMap) {

        for(Case obj : ticketList) {

            Case oldObj = (Case) oldMap.get(obj.Id);

            if((oldObj.AccountId != null && obj.AccountId == null) || (oldObj.AssetId != null && obj.AssetId == null)) {
                obj.addError('');
            }

            //240614 Staus 종결로 변경 시 종결사유 필수 입력 by Hayeong-Min
            if(obj.Status != oldObj.Status && obj.Status == 'Closed' && String.isEmpty(obj.EndOfReason__c)){
                obj.addError(System.Label.DNS_M_EnterClosedReason);
            }

            // Ticket 종결 시 진행상태 종결
            if(obj.Status == 'Closed'){
                obj.Pendingprocessing__c = 'Closing';
            }

            //알림톡 접수분석 관련 Field 매핑 - Sangil,Park, 2025-02-18
            obj.IsAlarmTalk__c = obj.ReceptionPath__c == 'Alarm Talk' ? 1 : 0;
            obj.IsCallCenter__c = obj.ReceptionPath__c == 'Call Center(Representative)' ? 1 : 0;
            obj.IsReceptionNight__c = obj.ApplicationDateTime__c.Hour() >= 17 && obj.ApplicationDateTime__c.MINUTE() >= 30 ? 1 : 0;

        }

    }

    // 수리요청일 변경 관련 메서드
    public void changedRepairDate(List<Case> ticketList, Map<Id, sObject> oldMap) {

        Set<Id> repairDateChanged = new Set<Id>(); // 수리요청일시 변경 관리용 Set

        for(Case obj : ticketList){
            Case oldObj = (Case) oldMap.get(obj.Id);

            //수리요청일시 변경시 관련 service appointment의 1일이내 수리완료(목표)를 해당 날짜의 23:59분으로 변경
            if(obj.RepairRequestDateTime__c != oldObj.RepairRequestDateTime__c){
                repairDateChanged.add(obj.Id);
            }
        }

        if(repairDateChanged.size()>0){
            System.debug('수리요청일시 변경됨');
            changeServiceAppointmentDueDate(repairDateChanged);
        }

    }

    // 접수내용 변경 관련 메서드
    public void changedReceptionDetail(List<Case> ticketList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {

        Set<Id> receptionDetailsChanged = new Set<Id>();//접수내용 변경 관리용 Set


        for(Case obj : ticketList){
            Case oldObj = (Case) oldMap.get(obj.Id);

            // 접수내용 변경 시 WorkOrder 반영 - Sangil,Park 2025-01-09
            if(obj.ReceptionDetails__c != oldObj.ReceptionDetails__c){
                System.debug('obj.ReceptionDetails__c :' + obj.ReceptionDetails__c);
                System.debug('oldObj.ReceptionDetails__c :' + oldObj.ReceptionDetails__c);
                receptionDetailsChanged.add(obj.Id);
            }
        }

        if(receptionDetailsChanged.size() > 0){
            List<WorkOrder> woList = [SELECT ID, ReceptionDetail__c, CaseId FROM WorkOrder WHERE CaseID IN: receptionDetailsChanged];
            if (woList.size() > 0) {
                for(WorkOrder obj : woList){
                    Case newCase = (Case)newMap.get(obj.caseId);
                    obj.ReceptionDetail__c = newCase.ReceptionDetails__c;
                }
                update woList;
            }
        }
    }

    //출하에서 티켓이 생성될경우, 제품 도착시간이 티켓의 수리요청일시에 추가
    //  public void UpdateRequestDate(List<Case> ticketList) {
    //     Set<String> ticketIds = new Set<String>();
    //     List<Case> ticketListUpdate = new List<Case>();

    //     for(Case obj : ticketList){
    //         if(obj.Id != ''){
    //             ticketIds.add(obj.Id);
    //         }
    //     }
        
    //     List<Case> ticketInfo = [ SELECT ID, InternalTicketType__c, DeliveryOrder__c, DeliveryOrder__r.DeliveryDate__c FROM Case WHERE ID IN :ticketIds ];
    //     for(Case ca : ticketInfo){
    //         if(ca.DeliveryOrder__c !=''){
    //             Case updateCase = new Case();
    //             updateCase.Id = ca.Id;
    //             updateCase.RepairRequestDateTime__c= ca.DeliveryOrder__r.DeliveryDate__c;

    //             ticketListUpdate.add(updateCase);
    //         }
    //     }
    //     System.debug('@@ ticketListUpdate : ' + ticketListUpdate);

    //     if(!ticketListUpdate.isEmpty()){
    //         update ticketListUpdate;
    //     }
    // }
 
    /**
    * @description Field Set에 입력한 Ticket 필드 수정 시 방어로직 추가
    * @operationtype after update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    public static Boolean isFieldSetChanged(SObject newObj, SObject oldObj) {
        System.debug('@@isFieldSetChanged');
        Schema.DescribeSObjectResult describeResult = Case.SObjectType.getDescribe();
        Schema.FieldSet fieldSet = describeResult.fieldSets.getMap().get('UpdateTicket');

        System.debug('@@fieldSet' + fieldSet);
        for (Schema.FieldSetMember member : fieldSet.getFields()) {
            String fieldApiName = member.getFieldPath();
            
            Object newVal = newObj.get(fieldApiName);
            Object oldVal = oldObj.get(fieldApiName);
            
            if ((newVal != null && !newVal.equals(oldVal)) ||
                (newVal == null && oldVal != null)) {
                return true; // 하나라도 변경되었으면 true
            }
        }
        return false; 
    }
}