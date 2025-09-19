/**
 * @description       : (포탈) 영업 > 서비스 관리 > 납품후교육 생성 및 조회
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 04-30-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-16-2024   daewook.kim@sbtglobal.com   Initial Version
**/
public without sharing class DN_PortalSalesRequestEduController {
    public DN_PortalSalesRequestEduController() {}

    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        String userId = System.UserInfo.getUserId();
        return DN_PortalLoginUser.GetUserInfo(userId);
    }

    /**
    * @description 생성 > 요청정보 > 교육담당자 목록
    * @author daewook.kim@sbtglobal.com | 12-17-2024 
    * @return List<GroupMember> 
    **/
    @AuraEnabled
    public static List<GroupMember> GetEduRep(String eduRep){
        return [
            SELECT Id, GroupId, UserOrGroupId, UserOrGroup.Name, Group.Name, group.DeveloperName
            FROM GroupMember
            WHERE group.DeveloperName =:eduRep
        ];
    }

    /**
    * @description 생성에서 실제 검색하는 로직 > 장비번호 / 수주번호 검색
    * @author daewook.kim@sbtglobal.com | 12-17-2024 
    * @param String userProfile 
    * @param String userId 
    * @return List<Asset> 
    **/
    @AuraEnabled
    public static List<Order> GetAssetInfo(String type, DN_PortalLoginUser.DealerInfo dealerInfo, String erpPSONo){
        // 소유자에 따른 수주번호, 기종, 장비번호, 설치완료일, 공임 보증여부, NC종류, 고객사Id, 고객사명, 고객사 전화번호, 고객사 주소

        String profile = dealerInfo.userProfile;  // ex. 영업 국내 대리점 Login
        String userRole = dealerInfo.userRole;    // ex. 주식회사 더머신 파트너 사용자 / 관리자 / manager
        String accountId = dealerInfo.accountId;  // ex. Id 값 (딜러가 속한 회사 입니다.)
        String dealerId = dealerInfo.dealerId;    // ex. Id 값

        Boolean isManager = false;
        if (userRole != null) {
            String lowerRole = userRole.toLowerCase();
            system.debug('lowerRole >> ' +lowerRole);
            isManager = lowerRole.contains('관리자') || lowerRole.contains('manager');
        }

        String query = 'SELECT '
        + 'Id, OwnerId, Owner.Name, ERPPSONo__c, '
        + 'ShipTo_PSO__c, ShipTo_PSO__r.Name, ShipTo_PSO__r.Phone, ShipTo_PSO__r.FM_Address__c, '
        + 'AccountId, Account.Name, Account.Phone, Account.FM_Address__c, '
        + 'SOSerialNumber__c, SOSerialNumber__r.Name, SOSerialNumber__r.MachineName__c, SOSerialNumber__r.NCType__c, SOSerialNumber__r.FM_EquipmentWarrantyEquipmentParts__c, SOSerialNumber__r.InstallationFinish__c '
        + 'FROM Order '
        + 'WHERE ERPPSONo__c != null '
        + 'AND SOSerialNumber__c != null ';

        if (isManager) {
        query += 'AND Owner__r.AccountId = :accountId ';
        } else {
        query += 'AND OwnerId = :dealerId ';
        }

        if (type == 'erp') {
        query += 'AND ERPPSONo__c = :erpPSONo ';
        }

        if (type == 'asset') {
        query += 'AND SOSerialNumber__r.Name =: erpPSONo ';
        }

        System.debug('query 납품후교육 쿼리 문 (Order__c 기반) :: ' + query);

        return Database.query(query);
    }

    /**
    * @description 생성에서 사용
    * @author daewook.kim@sbtglobal.com | 12-17-2024 
    * @param String accId 
    * @return Account 
    **/
    @AuraEnabled
    public static Account GetAccContact(String accId){
            return [
                SELECT Id, name, (SELECT Id, name, MobilePhone, Title FROM Contacts)
                FROM Account
                WHERE Id =: accId
            ];
    }

    /**
    * @description 선택 취소한 업로드 파일 삭제.
    * @author daewook.kim@sbtglobal.com | 02-21-2025 
    * @param List<String> fileIds 
    **/
    @AuraEnabled
    public static void deleteFiles(String fileId) {
        try {
            ContentDocument documentRecord = [
                SELECT Id FROM ContentDocument WHERE Id =: fileId
            ];
            delete documentRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+'_//_'+e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String insertContact(Map<String, Object> ci){
        try {
            Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSCustomer').getRecordTypeId();
            String name = (String)ci.get('shipToRepName');
            String phone = (String)ci.get('shipToRepMP');

            system.debug('name >> ' + name);
            system.debug('phone >> ' + phone);
            List<Contact> con = [SELECT Id, LastName, MobilePhone FROM Contact WHERE LastName =:name  AND MobilePhone =:phone  LIMIT 1];

            if(!con.isEmpty()) {
                return con[0].Id;
            } else {
                Contact nc = new Contact();
                system.debug('ci >> ' +ci);
                nc.LastName = (String)ci.get('shipToRepName');
                nc.MobilePhone = (String)ci.get('shipToRepMP');
                nc.Title = (String)ci.get('shipToRepTitle');
                nc.AccountId = (String)ci.get('shipToId');
                nc.RecordTypeId = conRecordTypeId;
    
                insert nc;
                system.debug('생성된 contact >>>' + nc.Id);
                return nc.Id;
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error processing ticket: ' + e.getMessage()+'_____'+e.getStackTraceString());
        }
    }

    /**
    * @description ticket insert 로직
    * @author daewook.kim@sbtglobal.com | 12-17-2024 
    * @param Map<String Object> oi 
    * @param Map<String Object> ai 
    * @param Map<String Object> di 
    * @param Map<String Object> acc 
    * @param Map<String Object> ri 
    * @param Map<String Object> ei 
    * @return TicketWrapper 
    **/
    @AuraEnabled
    public static String insertTicket(Map<String, Object> oi, Map<String, Object> ai, Map<String, Object> di, Map<String, Object> si, Map<String, Object> ei, String fi) {
        try {

            system.debug('oi >>> ' + oi);
            system.debug('ai >>> ' + ai);
            system.debug('di >>> ' + di);
            system.debug('si >>> ' + si);
            system.debug('ei >>> ' + ei);
            system.debug('fi >>> ' + fi);        

            List<Object> fileList = (List<Object>) JSON.deserializeUntyped(fi);

            String recordTypeName = 'Ticket';
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
            
            String shipToRepId = (String)si.get('shipToRepId');
            
            Case nt = new Case();
            nt.RecordTypeId = recordTypeId;   // 레코드 타입 = Ticket !!!!!
            nt.AssetId      = (String) ai.get('assetId'); // 장비 Id
            

            // 배송처
            nt.AccountId                 = (String) si.get('shipToId');      // 고객사 Id
            nt.AccountShippingAddress__c = (String) si.get('shipToAddress'); // 고객사 주소

            nt.Requester__c         = (String)si.get('shipToRepId'); // 고객사 담당자 Id
            nt.ContactName__c       = (String)si.get('shipToRepName');         // 고객사 담당자 이름
            nt.ContactPhone__c      = (String)si.get('shipToRepMP');           // 고객사 담당자 전화번호
            nt.ContactPosition__c   = (String)si.get('shipToRepTitle');        // 고객사 담당자 직책

            // 판매 대리점
            nt.FM_ReceptionistMP__c = (String)di.get('userMobilePhone');    // 접수자 전화번호
            nt.SalesDealer__c       = (String)di.get('accountId');          // 판매대리점
            nt.InternalRequester__c = (String)di.get('dealerId');           // 내부요청자  ex.문장한

            // 교육정보
            nt.TrainingType__c  = (String)ei.get('eduLevel');  // 교육 종류
            nt.TrainingCount__c = (String)ei.get('eduCnt'); // 교육 회수
            nt.TraineeLevel__c  = (String)ei.get('stuLevel');  // 피교육자 수준
            nt.OwnerId          = (String)ei.get('eduRep');    // 교육담당자 Id
            
            String eduDateOne = (String)ei.get('eduDateOne');
            String eduDateTwo = (String)ei.get('eduDateTwo');
            String eduDateThr = (String)ei.get('eduDateThr');

            // 교육요청일자 1
            if (String.isNotBlank(eduDateOne)) {
                nt.TrainingDateTime1__c     = (DateTime)JSON.deserialize('"' + eduDateOne + '"', DateTime.class);
                nt.RepairRequestDateTime__c = (DateTime)JSON.deserialize('"' + eduDateOne + '"', DateTime.class);
            }
            // 교육요청일자 2
            if (String.isNotBlank(eduDateTwo)) {
                nt.TrainingDateTime2__c = (DateTime)JSON.deserialize('"' + eduDateTwo + '"', DateTime.class);
            }
            // 교육요청일자 3
            if (String.isNotBlank(eduDateThr)) {
                nt.TrainingDateTime3__c = (DateTime)JSON.deserialize('"' + eduDateThr + '"', DateTime.class);
            }

            nt.ReceptionDetails__c   = (String)ei.get('note'); // 접수내용
            nt.SalesOrder__c         = (String)oi.get('Id'); //주문

            nt.TicketType__c         = 'Internal request'; // 하드 코딩 조건
            nt.InternalTicketType__c = 'Post-delivery training';
            nt.ReceptionPath__c      = 'Dealer Portal';    //접수 경로
            insert nt;

            List<ContentDocumentLink> links = new List<ContentDocumentLink>();

            for(Object fil : fileList) {
                Map<String, Object> fileMap = (Map<String, Object>) fil;
                
                links.add(new ContentDocumentLink(
                    ContentDocumentId = (String) fileMap.get('contentDocumentId'),
                    LinkedEntityId = nt.Id,
                    ShareType = 'V'
                ));
            }

            insert links;
           
            String ticketId = nt.Id;

            Case nc = [SELECT CaseNumber FROM Case WHERE Id =: ticketId LIMIT 1];

            String caseNo = nc.CaseNumber;
            
            return caseNo;
        } catch (Exception e) {
            throw new AuraHandledException('Error processing ticket: ' + e.getMessage()+'_____'+e.getStackTraceString());
        }
    }

    /* ************************************************************************************************************************************************************ */
    /* *************************************************************************** 조 회 *************************************************************************** */
    /* ************************************************************************************************************************************************************ */

    @AuraEnabled
    public static List<Case> GetTicketInfo(DN_PortalLoginUser.DealerInfo dealerInfo, String erpPSONo, String accId, String caseNo, String machineName, String assetName, Date startDate, Date endDate){
        try {

            String profile = dealerInfo.userProfile;  // ex. 영업 국내 대리점 Login
            String userRole = dealerInfo.userRole;    // ex. 주식회사 더머신 파트너 사용자 / 관리자 / manager
            String accountId = dealerInfo.accountId;  // ex. Id 값 (딜러가 속한 회사 입니다.)
            String dealerId = dealerInfo.dealerId;    // ex. Id 값

            Boolean isManager = false;
            if (userRole != null) {
                String lowerRole = userRole.toLowerCase();
                isManager = lowerRole.contains('관리자') || lowerRole.contains('manager');
            }

            
            String caseQuery = 'SELECT Id, SalesOrder__r.ERPPSONo__c, CaseNumber, CreatedDate, toLabel(status), Requester__c, InternalRequester__c, InternalRequester__r.Name, FM_ReceptionistMP__c, SalesDealer__c, SalesDealer__r.Name, '
                                +'Asset.Order__r.ERPPSONo__c, FM_AssetMachineName__c, AssetId, Asset.Name, Asset.InstallationFinish__c, Asset.FM_EquipmentWarrantyEquipmentParts__c, Asset.NCType__c, '
                                +'AccountId, Account.Name, ContactId, Contact.Name, ContactName__c, ContactPhone__c, ContactPosition__c, Account.FM_Address__c, '
                                +'TrainingType__c, TrainingCount__c, TraineeLevel__c, OwnerId, Owner.Name, '
                                +'TrainingDateTime1__c, TrainingDateTime2__c, TrainingDateTime3__c, ReceptionDetails__c, FM_FileCount__c, FileCount__c, '
                                +'(SELECT ContentDocumentId, ContentDocument.title FROM ContentDocumentLinks) '
                                +'FROM Case '
                                +'WHERE SalesOrder__r.ERPPSONo__c != null '
                                +'AND RecordType.Name = \'Ticket\' '
                                +'AND TicketType__c = \'Internal request\' '
                                +'AND InternalTicketType__c = \'Post-delivery training\' '
                                +'AND ReceptionPath__c = \'Dealer Portal\' ';
            
            if(isManager) {
                caseQuery += 'AND CreatedBy.AccountId =: accountId ';
            } else {
                caseQuery += 'AND CreatedById =: dealerId ';
            }
            
            // startDate
            if(startDate != null) {
                caseQuery += 'AND CreatedDate >=: startDate ';
            }

            // endDate
            if(endDate != null) {
                caseQuery += 'AND CreatedDate <=: endDate ';
            }                                

            // Ticket 번호 있을 때 추가
            if(caseNo != null && caseNo.trim() != '') {
                caseQuery += 'AND CaseNumber =:caseNo ';
            }

            // 수주 번호 있을 때 추가
            if(erpPSONo != null && erpPSONo.trim() != '') {
                caseQuery += 'AND SalesOrder__r.ERPPSONo__c =:erpPSONo ';
            }

            // 고객사 정보 있을 때 추가
            if(accId != null && accId.trim() != '') {
                caseQuery += 'AND AccountId =:accId ';
            }

            // 기종 정보 있을 때 추가
            if(machineName != null && machineName.trim() != '') {
                caseQuery += 'AND FM_AssetMachineName__c =:machineName ';
            }

            // 장버번호 정보 있을 때 추가
            if(assetName != null && assetName.trim() != '') {
                caseQuery += 'AND Asset.Name =:assetName ';
            }
            caseQuery += 'ORDER BY CaseNumber DESC ';

            system.debug('caseQuery>> ' +caseQuery);
            List<Case> result = Database.query(caseQuery);

            System.debug('result :: ' + result);
            return result;
        } catch (Exception e) {        
            throw new AuraHandledException(e.getMessage());
        }
    }
}