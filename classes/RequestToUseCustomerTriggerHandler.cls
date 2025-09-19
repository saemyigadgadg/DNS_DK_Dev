/**
 * @author            : Yu-Hyun Park
 * @description       : DNS_RequestToUseCustomer__c Trigger Handler
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-14   yuhyun.park@sbtglobal.com   Initial Version
 * 1.0   2024-07-05   Hanyeong Choi               IsBVC__c 로직 추가
 * 1.0   2024-07-08   Hanyeong Choi               SharingRule 로직 추가
 * 1.0   2024-07-30   Hanyeong Choi               SharingRule 로직 -> DNS_CustomerDealerAssociation__c insert 로직 변경
**/
public with sharing class RequestToUseCustomerTriggerHandler extends TriggerHandler {

    /**
     * DNS_RequestToUseCustomer__c 레코드 삽입 전, 소유자의 CustomerCode__c 또는 계정의 CustomerCode__c를 검증합니다.
     */
    public override void onBeforeInsert(List<sObject> news) {
        if(isExecuting){
            System.debug('DNS_RequestToUseCustomer__c BEFORE_INSERT TRIGGER Start');
            List<DNS_RequestToUseCustomer__c> reqList = (List<DNS_RequestToUseCustomer__c>) news;
            
            // 모든 레코드의 OwnerId 수집
            Set<Id> ownerIds = new Set<Id>();
            for(DNS_RequestToUseCustomer__c req : reqList){
                ownerIds.add(req.OwnerId);
            }
            
            // Owner 정보 쿼리 (CustomerCode__c와 AccountId 포함)
            Map<Id, User> ownerMap = new Map<Id, User>([
                SELECT Id, UserType, CustomerCode__c, AccountId
                FROM User
                WHERE Id IN :ownerIds
            ]);
            
            // Non-Standard인 경우, Owner의 Account에 CustomerCode__c가 있는지 확인해야 하므로 AccountId 수집
            Set<Id> accountIds = new Set<Id>();
            for(User u : ownerMap.values()){
                if(u.UserType != 'Standard' && u.AccountId != null){
                    accountIds.add(u.AccountId);
                }
            }
            
            Map<Id, Account> accountMap = new Map<Id, Account>();
            if(!accountIds.isEmpty()){
                accountMap = new Map<Id, Account>([
                    SELECT Id, CustomerCode__c
                    FROM Account
                    WHERE Id IN :accountIds
                ]);
            }
            
            // 각 요청 레코드에 대해 조건 검증
            for(DNS_RequestToUseCustomer__c req : reqList){
                User ownerUser = ownerMap.get(req.OwnerId);
                if(ownerUser != null){
                    if(ownerUser.UserType == 'Standard'){
                        // Standard 사용자인 경우, Owner의 CustomerCode__c가 필수
                        if(String.isBlank(ownerUser.CustomerCode__c)){
                            req.addError('Owner의 CustomerCode__c가 설정되어 있지 않습니다.');
                        }
                    } else {
                        // Standard가 아닌 경우, Owner의 Account의 CustomerCode__c가 필수
                        if(ownerUser.AccountId != null){
                            Account acc = accountMap.get(ownerUser.AccountId);
                            if(acc == null || String.isBlank(acc.CustomerCode__c)){
                                req.addError('Owner의 Account의 CustomerCode__c가 설정되어 있지 않습니다.');
                            }
                        } else {
                            req.addError('Owner의 Account가 없습니다.');
                        }
                    }
                }
            }
            
            System.debug('DNS_RequestToUseCustomer__c BEFORE_INSERT TRIGGER End');
        }
    }


    /**
     * DNS_RequestToUseCustomer__c 레코드 삽입 후, 포털 사용자에 대해 이메일 알림을 전송합니다.
     */
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){ 
        if (isExecuting) {
            System.debug('DNS_RequestToUseCustomer__c AFTER_INSERT TRIGGER Start');
            List<DNS_RequestToUseCustomer__c> reqList = (List<DNS_RequestToUseCustomer__c>) news;
            List<DNS_RequestToUseCustomer__c> reqListToEmail = new List<DNS_RequestToUseCustomer__c>();

            Set<Id> ownerIds = new Set<Id>();
            Set<Id> reqIds = new Set<Id>();

            for(DNS_RequestToUseCustomer__c req : reqList){
                ownerIds.add(req.OwnerId);
            }
            
            Map<Id, User> ownerMap = new Map<Id, User>([
                SELECT Id, UserType 
                FROM User 
                WHERE Id IN :ownerIds
            ]);

            for(DNS_RequestToUseCustomer__c req : reqList){

                User ownerUser = ownerMap.get(req.OwnerId);

                // Portal 사용자만 리스트에 포함
                if(ownerUser != null && ownerUser.UserType != 'Standard'){
                    reqListToEmail.add(req);
                }
            }

            if(!reqListToEmail.isEmpty()){
                for(DNS_RequestToUseCustomer__c req : reqListToEmail){
                    reqIds.add(req.Id);
                }
                alertEmail(reqIds);
            }

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('DNS_RequestToUseCustomer__c AFTER_INSERT TRIGGER End');
        }
    }


    /**
     * DNS_RequestToUseCustomer__c 레코드 업데이트 전, SimpleCustomerInfo__c를 통해 계정 정보를 설정하고 승인된 경우 공유 및 계정 팀을 관리합니다.
     */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting){
            System.debug('DNS_RequestToUseCustomer__c BEFORE_UPDATE TRIGGER Start');
            List<DNS_RequestToUseCustomer__c> reqList           = (List<DNS_RequestToUseCustomer__c>) news;
            Map<DNS_RequestToUseCustomer__c, Id> reqSciMap      = new Map<DNS_RequestToUseCustomer__c, Id>();
            List<DNS_RequestToUseCustomer__c> manageSharingList = new List<DNS_RequestToUseCustomer__c>();
            List<DNS_RequestToUseCustomer__c> manageSharingListForAccountTeam = new List<DNS_RequestToUseCustomer__c>();
                        
            for(DNS_RequestToUseCustomer__c req : reqList){
                DNS_RequestToUseCustomer__c oldReq = (DNS_RequestToUseCustomer__c)oldMap.get(req.Id);
                if (req.SimpleCustomerInfo__c != oldReq.SimpleCustomerInfo__c) {
                    reqSciMap.put(req, req.SimpleCustomerInfo__c);
                }

                if(req.ApprovalStage__c == 'Approved'){
                    System.debug('>>> req.CreatedById ::: ' + req.FM_CreatedByDealer__c);
                    if(String.isBlank(req.FM_CreatedByDealer__c)) {
                        manageSharingListForAccountTeam.add(req);
                    }else{
                        manageSharingList.add(req);
                    }
                } 
            }
            if(!reqSciMap.isEmpty()) addSimpleCustomerInfo(reqSciMap);

            System.debug('>>> manageSharingList ::: ' + manageSharingList);
            System.debug('>>> manageSharingListForAccountTeam ::: ' + manageSharingListForAccountTeam);

            // 딜러가 신청
            if(!manageSharingList.isEmpty()) manageSharing(manageSharingList);

            // 직영 영업이 신청
            if(!manageSharingListForAccountTeam.isEmpty()) insertAccountTeam(manageSharingListForAccountTeam);

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('DNS_RequestToUseCustomer__c BEFORE_UPDATE TRIGGER End');
        }
    }


    /**
     * @Description
     * 	- DNS_RequestToUseCustomer__c 레코드 insert 시, SimpleCustomerInfo__c 통하여 정보 가져오기
     * @author Hanyeong Choi | 10-08-2024
     * @Parameter
     *  - reqSciMap         : key: DNS_RequestToUseCustomer__c record, value: SimpleCustomerInfo__c Id
    **/
    private static void addSimpleCustomerInfo(Map<DNS_RequestToUseCustomer__c, Id> reqSciMap) {
        List<SimpleCustomerInfo__c> sciList = [
            SELECT Id,
                    Account__c,
                    FM_IsBVC__c
            FROM SimpleCustomerInfo__c
            WHERE Id IN :reqSciMap.values()
        ];

        for(DNS_RequestToUseCustomer__c req : reqSciMap.keySet()) {
            for(SimpleCustomerInfo__c sci : sciList) {
                if(req.SimpleCustomerInfo__c == sci.Id) {
                    if(sci.FM_IsBVC__c == 'Y') req.addError('보호 고객으로 잠재 고객 사용 요청 불가합니다.');

                    req.put('TargetAccount__c', sci.Account__c);
                }
            }
        }
        return;
    }


    /**
     * @Description
     * 	- DNS_RequestToUseCustomer__c의 ApprovalStage__c 필드가 Approved 되면, DNS_CustomerDealerAssociation__c에 insert
     *  - 딜러포탈 사용자
     * @author Hanyeong Choi | 07-30-2024
     * @Parameter
     *  - reqList       : DNS_RequestToUseCustomer__c Record List
    **/ 
    private static void manageSharing(List<DNS_RequestToUseCustomer__c> reqList) {

        System.debug('manageSharing >>');

        Map<Id, Id>             accForReqOwnerMap   = new Map<Id, Id>();
        List<Map<Id, Id>>       accSharingMap       = new List<Map<Id, Id>>();
        Set<Id>                 reqOwnerIds         = new Set<Id>();
        String ownerId;

        
        for(DNS_RequestToUseCustomer__c req : reqList) {
            Id targetAcc = req.TargetAccount__c;
            accForReqOwnerMap.put(req.OwnerId, targetAcc);
            accSharingMap.add(accForReqOwnerMap);
            reqOwnerIds.add(req.OwnerId);
            ownerId = req.OwnerId;
        }
        
        User u = [SELECT Id, UserType, AccountId, SalesOrganization__c, DistributionChannel__c, Division__c, CustomerCode__c FROM User WHERE Id = :ownerId LIMIT 1];

        if(!accSharingMap.isEmpty()) {
            List<DNS_CustomerDealerAssociation__c> insertCdaList = new List<DNS_CustomerDealerAssociation__c>();
            for(Map<Id, Id> accReqMap : accSharingMap) {
                DNS_CustomerDealerAssociation__c cda = new DNS_CustomerDealerAssociation__c();
                cda.Dealer__c               = u.AccountId;
                cda.Customer__c             = accReqMap.get(u.Id);
                insertCdaList.add(cda);
            }

            System.debug('>>> insertCdaList ::: ' + insertCdaList);

            if(!insertCdaList.isEmpty()){
                System.enqueueJob(new InsertCdaQueueable(insertCdaList, u));
            }

        }
        return;
    }


    /**
     *  - 직영영업 사용자
    **/ 
    private static void insertAccountTeam(List<DNS_RequestToUseCustomer__c> reqList) {

        System.debug('insertAccountTeam >>');

        Map<Id, Id> accForReqOwnerMap = new Map<Id, Id>();
        for(DNS_RequestToUseCustomer__c req : reqList) {
            accForReqOwnerMap.put(req.OwnerId, req.TargetAccount__c);
        }

        if(!accForReqOwnerMap.isEmpty()) {
            List<AccountTeamMember> insertList = new List<AccountTeamMember>();
            for(Id ownerId : accForReqOwnerMap.keySet()) {
                AccountTeamMember accTeam = new AccountTeamMember();
                accTeam.TeamMemberRole = 'Sales Manager';
                accTeam.AccountId = accForReqOwnerMap.get(ownerId);
                accTeam.UserId = ownerId;
                accTeam.AccountAccessLevel = 'Edit';
                accTeam.OpportunityAccessLevel = 'None';
                accTeam.CaseAccessLevel = 'None';
                accTeam.ContactAccessLevel = 'None';
                insertList.add(accTeam);
            }

            System.debug('>>> insertList ::: ' + insertList);

            if (!insertList.isEmpty()) {
                // AccountTeamMember 리스트와 현재 사용자를 매개변수로 전달
                System.enqueueJob(new InsertAccountTeamQueueable(insertList));
            }

        }
        return;
    }


    /**
     * @Description
     * 	- 포탈 사용자(딜러)가 영업지원(Queue) 또는 지사장에게 승인 요청시 Request To Use Customer 생성 & 해당 대상자에게 Email
     * @author Yuhyun Park | 04-03-2025
     * @Parameter
     *  - reqIds           : DNS_RequestToUseCustomer__c Record Id
    **/ 
    @future
    private static void alertEmail(Set<Id> reqIds){

        System.debug('alertEmail 진입 >>');

        List<DNS_RequestToUseCustomer__c> target = [
            SELECT Id, FM_TargetAccountName__c, FM_TargetAccountRepresentative__c, FM_TargetAccountCustomerCode__c, CreatedById, RequestReason__c
            FROM DNS_RequestToUseCustomer__c
            WHERE Id IN :reqIds
        ];

        //orderService 기생
        DN_OrderService ordSvc = new DN_OrderService();
        // Set<Id> targetUser = new Set<Id>();
        Set<Id> createdUser = new Set<Id>();

        System.debug('reqIds :: ' + reqIds);

        List<ProcessInstance> piList = [
            SELECT Id, TargetObjectId 
            FROM ProcessInstance 
            WHERE TargetObjectId IN :reqIds
        ];

        System.debug('piList :: ' + piList);

        // ProcessInstance Id와 해당 TargetObjectId(DNS_RequestToUseCustomer__c의 recordId)를 매핑하는 맵
        Map<Id, Id> processInstanceToRecordMap = new Map<Id, Id>();
        for(ProcessInstance pi : piList) {
            processInstanceToRecordMap.put(pi.Id, pi.TargetObjectId);
        }

        // 해당 Approval Process 인스턴스의 대기 중인(workitem) 승인자(OriginalActorId) 조회
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId, OriginalActorId, CreatedById 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstanceId IN :processInstanceToRecordMap.keySet()
        ];

        System.debug('workItems :: ' + workItems);

        // Map<String, Object> 형태로 구성 (Key: DNS_RequestToUseCustomer__c의 recordId, Value: List<ProcessInstanceWorkitem>)
        Map<String, Object> recordIdToWorkitems = new Map<String, Object>();

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();

        // 각 work item의 승인자 Id를 targetUser에 추가
        for(ProcessInstanceWorkitem workItem : workItems) {
            
            Id actorId = workItem.OriginalActorId;
            System.debug('actorId.getSObjectType() :: ' + actorId.getSObjectType());

            createdUser.add(workItem.CreatedById);

            // ProcessInstanceWorkitem에서 ProcessInstanceId로 대상 recordId 조회
            Id recordId = processInstanceToRecordMap.get(workItem.ProcessInstanceId);

            // noti 추가
            Set<Id> innerSet = targetUserMap.containsKey(recordId) ? targetUserMap.get(recordId) : new Set<Id>();

            if(recordId != null) {
                String key = String.valueOf(recordId); // Id를 String으로 변환
                if(!recordIdToWorkitems.containsKey(key)) {
                    recordIdToWorkitems.put(key, new List<ProcessInstanceWorkitem>());
                }
                // Object를 List<ProcessInstanceWorkitem>로 캐스팅하여 추가
                ((List<ProcessInstanceWorkitem>)recordIdToWorkitems.get(key)).add(workItem);
            }    

            if (actorId.getSObjectType() == Group.sObjectType) {

                // Queue (Group)의 경우
                List<GroupMember> groupMembers = [
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE GroupId = :actorId
                ];

                for(GroupMember gm : groupMembers) {
                    // targetUser.add(gm.UserOrGroupId);
                    innerSet.add(gm.UserOrGroupId);
                }

            } else {
                // 일반 사용자인 경우
                // targetUser.add(actorId);
                innerSet.add(actorId);
            }

            targetUserMap.put(recordId, innerSet);
            
        }

        // System.debug('targetUser :: ' + targetUser);
        System.debug('targetUserMap :: ' + targetUserMap);

        Map<Id, User> createdUserMap = new Map<Id, User>([
            SELECT Id, Name 
            FROM User 
            WHERE Id IN :createdUser
        ]);

        // Approver Name Map
        Map<Id, String> userNameMap = new Map<Id, String>();
        for (Id userId : createdUserMap.keySet()) {
            userNameMap.put(userId, createdUserMap.get(userId).Name);
        }

        Map<Id, String> recordMapForSend = new Map<Id, String>();
        for(String key : recordIdToWorkitems.keySet()){
            Id recId = (Id) key; // 문자열 키를 Id로 변환
            List<ProcessInstanceWorkitem> wiList = (List<ProcessInstanceWorkitem>) recordIdToWorkitems.get(key);
            String value = (wiList != null && !wiList.isEmpty()) ? String.valueOf(wiList[0].Id) : '';
            recordMapForSend.put(recId, value);
        }

        if(!targetUserMap.isEmpty()){

            // email 
            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'RequestToUseCustomerAlert'
                , 'email'
                , target
                , targetUserMap
                , new Map<String, Object>{'recordIdToWorkitems' => recordMapForSend, 'userNameMap' => userNameMap}
                // , recordIdToWorkitems
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(emailAlertResult.errMessage); }
        }
    }


    /**
     * @Description
     * 	- AccountTeamMember를 생성하기 직전에 Interface 송신 : Queueable 처리 
     *  - IF_DEALER_008
     *  - 직영영업 사용자
     * @author Yuhyun Park | 04-04-2025
     * @Parameter
     *  - insertList       : AccountTeamMember List to Insert
    **/ 
    public class InsertAccountTeamQueueable implements Queueable, Database.AllowsCallouts {
        private List<AccountTeamMember> insertList;
    
        public InsertAccountTeamQueueable(List<AccountTeamMember> insertList) {
            this.insertList = insertList;
        }
    
        public void execute(QueueableContext context) {

            // 각 AccountTeamMember 레코드에 대한 UserId(요청자 OwnerId) 수집
            Set<Id> ownerIds = new Set<Id>();
            for (AccountTeamMember atm : insertList) {
                if (atm.UserId != null) {
                    ownerIds.add(atm.UserId);
                }
            }

            // User Info Query
            Map<Id, User> ownerMap = new Map<Id, User>([
                SELECT Id, SalesOrganization__c, DistributionChannel__c, Division__c, CustomerCode__c
                FROM User
                WHERE Id IN :ownerIds
            ]);

            // ERP 처리에 필요한 Account 정보를 얻기 위해 관련 Account Id 수집
            Set<Id> accIds = new Set<Id>();
            for (AccountTeamMember atm : insertList) {
                if (atm.AccountId != null) {
                    accIds.add(atm.AccountId);
                }
            }
    
            // 관련 Account 정보를 쿼리 (ERP 호출에 사용될 CustomerCode__c 등)
            Map<Id, Account> accMap = new Map<Id, Account>([
                SELECT Id, CustomerCode__c
                FROM Account
                WHERE Id IN :accIds
            ]);
    
            // ERP 검증에 통과한 AccountTeamMember 레코드를 저장할 리스트
            List<AccountTeamMember> finalInsertList = new List<AccountTeamMember>();
    
            // 각 AccountTeamMember 레코드에 대해 ERP 호출
            for (AccountTeamMember atm : insertList) {
                User u = ownerMap.get(atm.UserId);

                IF_ERP_Dealer_Classes.IF_DEALER_008_Req erpParameters = new IF_ERP_Dealer_Classes.IF_DEALER_008_Req();
                
                // 예시로, AccountTeamMember의 AccountId를 사용하여 ERP 호출 파라미터 설정
                if (atm.AccountId != null && accMap.containsKey(atm.AccountId)) {
                    Account acc = accMap.get(atm.AccountId);
                    erpParameters.I_KUNNR = acc.CustomerCode__c;
                    erpParameters.I_DEALER = u.CustomerCode__c;
                    erpParameters.I_PARVW = 'ZM';
                }
                
                erpParameters.I_VKORG = u.SalesOrganization__c;
                erpParameters.I_VTWEG = u.DistributionChannel__c;
                erpParameters.I_SPART = u.Division__c;
                
                // ERP 호출
                IF_ERP_Dealer erpService = new IF_ERP_Dealer();
                IF_ERP_Dealer_Classes.IF_DEALER_008_Res erpResponse = erpService.IF_DEALER_008(erpParameters);
                
                if (erpResponse.O_RECODE == 'S') {
                    finalInsertList.add(atm);
                } else {
                    atm.addError('ERP validation failed: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : 'Unknown error'));
                }
            }
            
            if (!finalInsertList.isEmpty()) {

                DN_WithoutSharingClass.insertAccountTeamMember(finalInsertList);
                System.debug('InsertAccountTeamQueueable Executed successfully');
            }
        }
    }
}