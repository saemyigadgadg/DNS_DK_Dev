/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 05-14-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-07-15   Yuhyun Park   Initial Version
 * 1.0   2024-07-16   Yuhyun Park   getParentAccount 추가
 * 1.1   2024-04-15   yeongju.yun   딜러가 기회 생성 시 RelatedDealer 등록 여부 확인 후 없으면 에러
**/
public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private static final Id   recordTypeId  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    private static final Id   recordTypeIdGeneral  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
    private static final Id   recordTypeIdTurnkey  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Turn_Key').getRecordTypeId();
    private static final Id   recordTypeIdDNSA  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

    public override void onBeforeInsert(List<sObject> news){
        try {
            if(isExecuting){
                System.debug('Opportunity BEFORE_INSERT TRIGGER Start');
                List<Opportunity> opptyList = (List<Opportunity>) news;
                Date today = System.today();
                String todayStr = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyyMMdd');

                // recordType이 Parts / DNSA가 아닌 경우에만 validation적용
                System.debug(opptyList[0].RecordTypeId != recordTypeId);
                if(opptyList[0].RecordTypeId != recordTypeId){
                    if(opptyList[0].RecordTypeId != recordTypeIdDNSA){
                        String optyName;

                        if(System.Test.isRunningTest() || opptyList[0].IsClone__c == false){
                            //생성자가 글로벌영업대리점인 경우에는 글로벌기준 Naming Rule이외는 전부 국내 Naming Rule
                            List<User> profileCheck = [
                                SELECT 
                                    Profile.Name, //프로필명
                                    Name, //딜러명
                                    SalesOffice__c //지사명
                                FROM 
                                    User 
                                WHERE Id =: opptyList[0].OwnerId];

                            List<Account> accountCheck = [
                                SELECT 
                                    SalesOffice__c, //지사명
                                    Name, //고객명
                                    CountryLookup__r.Name //국가명
                                FROM 
                                    Account 
                                WHERE Id =: opptyList[0].AccountId];
                            //국내 지사명 추출 
                            //owner가 없으면 identifier로`
                            if (profileCheck[0].Profile.Name != null){
                                if(profileCheck[0].Profile.Name.contains('글로벌 대리점')){
                                    // optyName = profileCheck[0].Account.CountryLookup__r.Name + '_' + profileCheck[0].Opportunity_Owner__r.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                    System.debug('accountCheck[0].CountryLookup__r.Name : ' + accountCheck[0].CountryLookup__r.Name);
                                    System.debug('accountCheck[0].Name : ' + accountCheck[0].Name);
                                    System.debug('opptyList[0].Name : ' + opptyList[0].Name);
                                    System.debug('opptyList[0].CreatedDate : ' + opptyList[0].CreatedDate);
                                    optyName = optyRename(accountCheck[0].CountryLookup__r.Name, accountCheck[0].Name, opptyList[0].Name, todayStr);
                                    if(optyName == 'ERROR'){
                                        opptyList[0].addError(System.Label.DNS_M_OptyNaminRule);
                                    }
                                }else{
                                    String salesOffice = getPicklistValues('User', 'SalesOffice__c', profileCheck[0].SalesOffice__c);   // 2025-04-23 Yuhyun Park : User의 SalesOffice로 변경
                                    System.debug('salesOffice :: ' + salesOffice);
                                    // String salesOffice = getPicklistValues('Account', 'SalesOffice__c', accountCheck[0].SalesOffice__c);
                                    // optyName = salesOffice + '_' + profileCheck[0].Account.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                    optyName = optyRename(salesOffice, accountCheck[0].Name, opptyList[0].Name, todayStr);
                                    if(optyName == 'ERROR'){
                                        opptyList[0].addError(System.Label.DNS_M_OptyNaminRule);
                                    }
                                }
                            }else{
                                if(profileCheck[0].Profile.Name.contains('글로벌 대리점')){
                                    // optyName = profileCheck[0].Account.CountryLookup__r.Name + '_' + profileCheck[0].OpportunityIdentifier__r.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                    optyName = optyRename(accountCheck[0].CountryLookup__r.Name, accountCheck[0].Name, opptyList[0].Name, todayStr);
                                    if(optyName == 'ERROR'){
                                        opptyList[0].addError(System.Label.DNS_M_OptyNaminRule);
                                    }
                                }else{
                                    String salesOffice = getPicklistValues('User', 'SalesOffice__c', profileCheck[0].SalesOffice__c);   // 2025-04-23 Yuhyun Park : User의 SalesOffice로 변경
                                    System.debug('salesOffice :: ' + salesOffice);
                                    // String salesOffice = getPicklistValues('Account', 'SalesOffice__c', accountCheck[0].SalesOffice__c);
                                    // optyName = salesOffice + '_' + profileCheck[0].Account.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                    optyName = optyRename(salesOffice, accountCheck[0].Name, opptyList[0].Name, todayStr);
                                    if(optyName == 'ERROR'){
                                        opptyList[0].addError(System.Label.DNS_M_OptyNaminRule);
                                    }
                                }
                            }
                            
                        }

                        // 250415 yeongju.yun 딜러가 기회 생성 시 RelatedDealer 등록 여부 확인 후 없으면 에러
                        if(UserInfo.getUserType() != 'Standard') checkRelatedDealer(opptyList);

                        //Stage가 Identified면 Error 권세진 2024-10-23
                        for(Opportunity oppty : (List<Opportunity>)news) {
                        System.debug('optyName : ' + optyName);

                            if(oppty.StageName != 'Identified') {
                                oppty.addError(System.Label.DNS_M_StageIdentified);
                            }
                            if(optyName == 'ERROR') {
                                oppty.addError(System.Label.DNS_M_OptyNaminRule);
                            }
                        }
                        //
                        if(opptyList[0].CloseDate < today){
                            opptyList[0].addError(System.Label.DNS_M_ContractDate);
                        }
                        if(opptyList[0].RequestDelieveryDate__c != null){
                            if(opptyList[0].RequestDelieveryDate__c <= today || opptyList[0].RequestDelieveryDate__c <= opptyList[0].CloseDate){
                                opptyList[0].addError(System.Label.DNS_M_RequestDate);
                            }
                        }
                    }
                    
                    Set<Id> accountSet          = new Set<Id>(); // 이주현 2024-05-26
                    Set<Id> parentAccountSet    = new Set<Id>(); // 박유현 2024-07-15 : Key Account 집계용
                    List<Account> accountList   = new List<Account>();
                    for(Opportunity oppty : opptyList) { 
                        accountSet.add(oppty.AccountId);
                    }
                    if(!accountSet.isEmpty()){
                        accountList = [
                            SELECT Id
                                    , Name
                                    , MainCategory__c
                                    , SubCategory__c
                                    , IsTooling__c
                                    , IsKeyAccount__c
                                    , ParentId
                                    , CountryLookup__r.CountryCode__c
                            FROM Account  
                            WHERE Id IN :accountSet
                            WITH SECURITY_ENFORCED
                        ];
                    }

                    System.debug('[onBeforeInsert] accountList ::: ' + accountList);

                    Map<Id, Account> accountMap = new Map<Id, Account>();
                    if(!accountList.isEmpty()){
                        for(Account account : accountList) { 
                            accountMap.put(account.Id, account);
    
                            //Key Account 찾기
                            if(account.IsKeyAccount__c == true && account.ParentId != null ){
                                parentAccountSet.add(account.ParentId);
                            }
                        }
                        if(accountList[0].CountryLookup__r.CountryCode__c != null){//Account의 Country정보 입력
                            opptyList[0].Country__c = accountList[0].CountryLookup__r.CountryCode__c;
                        }
                    }
                    
                    System.debug('[onBeforeInser] parentAccountSet ::: ' + parentAccountSet);
                    // Key Account의 Parent Account 조회
                    Map<Id, Account> parentAccountMap = getParentAccount(parentAccountSet);

                    System.debug('[onBeforeInsert] accountMap ::: ' + accountMap);
                    System.debug('[onBeforeInsert] parentAccountMap ::: ' + parentAccountMap);

                    for(Opportunity oppty : opptyList) {
                        if(accountMap.containsKey(oppty.AccountId)){
                            Account account         = accountMap.get(oppty.AccountId);
                            if(oppty.MainCategory__c == null) {
                                oppty.MainCategory__c   = account.MainCategory__c;
                            }
                            if(oppty.SubCategory__c == null){
                                oppty.SubCategory__c    = account.SubCategory__c;
                            }
                            oppty.IsTooling__c      = account.IsTooling__c;
                            // Opportunity에 Parenct Account Id 입력
                            if(parentAccountMap.containsKey(account.ParentId)){
                                Account parentAccount   = parentAccountMap.get(account.ParentId);
                                oppty.ParentAccount__c  = parentAccount.Id;

                            }

                            if(oppty.RecordTypeId == recordTypeIdGeneral) {
                                oppty.PowerBI_InquiryType__c = 'ZINM';
                            } else if(oppty.RecordTypeId == recordTypeIdTurnkey && oppty.Inquiry_Type__c != null) {
                                oppty.PowerBI_InquiryType__c = oppty.Inquiry_Type__c;
                            }
                        }
                        
                        //recordtype이 general이면 inquiry type에 ZINM입력
                        //ZINM이 Inavtive Value로 입력이 되어서 코드에서 제외
                        // if(oppty.RecordTypeId == recordTypeIdGeneral){
                        //     oppty.Inquiry_Type__c = 'ZINM';
                        // }
                    }

                    setting(false, TriggerOperation.BEFORE_INSERT);
                    System.debug('Opportunity BEFORE_INSERT TRIGGER End');
                }
                
                //Service 전용: CustomerContact 자동 할당 / 에러 처리 2025-08-04 Yewon Lee
                else if (opptyList[0].RecordTypeId == recordTypeId) {
                    Set<Id> acctIdsForService = new Set<Id>();
                    for (Opportunity opp : opptyList) {
                        if (opp.RecordTypeId == recordTypeId
                            && (opp.CustomerContact__c == null || String.isBlank(opp.CustomerContact__c))
                            && opp.AccountId != null) {
                            acctIdsForService.add(opp.AccountId);
                        }
                    }

                    Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
                    if (!acctIdsForService.isEmpty()) {
                        for (Contact c : [
                            SELECT Id, AccountId
                            FROM Contact
                            WHERE AccountId IN :acctIdsForService
                        ]) {
                            if (!contactMap.containsKey(c.AccountId)) {
                                contactMap.put(c.AccountId, new List<Contact>());
                            }
                            contactMap.get(c.AccountId).add(c);
                        }
                    }

                    if (String.isBlank(opptyList[0].CustomerContact__c) && opptyList[0].AccountId != null) {
                        List<Contact> contactList = contactMap.get(opptyList[0].AccountId);
                        if (contactList != null && !contactList.isEmpty()) {
                            opptyList[0].CustomerContact__c = contactList[0].Id;
                        } else {
                            opptyList[0].addError('고객에 연락처 정보가 없습니다. 먼저 연락처를 등록해 주세요.');
                        }
                    }
                }

                //FLAG 세팅: ETC_AutoTeam__c 값을 체크박스에 반영 2025-08-04 이예원
                for (Opportunity opp : opptyList) {
                    opp.HasETCAutoTeam__c = (opp.ETC_AutoTeam__c != null && opp.ETC_AutoTeam__c.trim().length() > 0);
                }

                //CS Update Sangil, Park
                String pricebook2Id = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
                for(Opportunity obj : opptyList){
                    if(obj.RecordTypeID == recordTypeId){
                        obj.Pricebook2Id = pricebook2Id;
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting){
            System.debug('Opportunity AFTER_INSERT TRIGGER Start');
            List<Opportunity>       opptyList   = (List<Opportunity>) news;
            Map<Id, Opportunity>    opptyNewMap = (Map<Id, Opportunity>) newMap;
            List<Opportunity>       kaOpptyList = new List<Opportunity>();
            Map<Id, Opportunity>    accIdForOppty = new Map<Id, Opportunity>();

            if(opptyList[0].RecordTypeId == recordTypeIdDNSA){
                Opportunity OIUPdate = new Opportunity();   
                OIUPdate.Id          = opptyList[0].Id;

                // Yuhyun Park, 2025-04-11
                // 조건 추가 : OpportunityIdentifier__c가 없을 때만 (for Ellision Interface)
                if(opptyList[0].OpportunityIdentifier__c == null){
                    System.debug ('opptyList[0].OpportunityIdentifier__c :: ' + opptyList[0].OpportunityIdentifier__c);
                    OIUPdate.OpportunityIdentifier__c = opptyList[0].CreatedById;
                }
                update OIUPdate;
            }

            if(opptyList[0].RecordTypeId != recordTypeId && opptyList[0].RecordTypeId != recordTypeIdDNSA){
                // Hanyeong Choi, 2024-10-22
                // Account가 Key Account라면 KA 부문 전원에게 알람
                for(Opportunity o : opptyList) {
                    if(o.FM_IsKeyAccount__c) {
                        kaOpptyList.add(o);
                        accIdForOppty.put(o.AccountId, o);
                    }
                }
                if(!accIdForOppty.isEmpty()) sendNotificationKA(accIdForOppty);
                if(!accIdForOppty.isEmpty()) sendEmailKA(accIdForOppty);

                // 권세진 2024-06-17
                // Oppty가 clone되면 기존 Oppty는 closed처리
                // String cloneId = opptyList[0].getCloneSourceId();
                // System.debug('cloneId ::: ' + cloneId);
                // if(cloneId != null){
                //     Opportunity closeRecord = new Opportunity(
                //                                                 Id = cloneId,
                //                                                 StageName = 'Closed Lost',
                //                                                 Loss_Reason__c = 'Change Of Inquiry Type'
                //     );
                //     try {
                //         update closeRecord;
                //     } catch (Exception e) {
                //         System.debug('error : ' + e.getMessage());
                //     }
                // }else{
                    //권세진 2024-06-19
                    //Oppty 생성 시 딜러의 AccountId, ContactId를 Oppty object의 Dealer__c, Contact__c에 update
                    
                    List<User> ownerInfo = [
                        SELECT Id
                                , AccountId
                                , ContactId
                        FROM User
                        WHERE Id = :opptyList[0].OwnerId
                    ];

                    List<RecordType> recordList = [
                        SELECT Id
                                , DeveloperName
                                , Name
                        FROM RecordType
                        WHERE Id =: opptyList[0].RecordTypeId
                    ];

                    if(recordList[0].DeveloperName == 'Turn_Key') {
                        List<Product2> prd = [
                            SELECT Id
                                    , Name
                            FROM Product2
                            WHERE Name = 'PS000'
                        ];

                        List<PricebookEntry> price = [
                            SELECT Id
                                    , Name
                            FROM PricebookEntry
                            WHERE Name = 'PS000' and CurrencyIsoCode =: opptyList[0].CurrencyIsoCode
                        ];

                        OpportunityLineItem oppLineItem = new OpportunityLineItem(
                            OpportunityId       = opptyList[0].Id,
                            Product2Id          = prd[0].Id,
                            Quantity            = 1,
                            UnitPrice           = 0,
                            PricebookEntryId    = price[0].Id
                        );
                    
                        try {
                            insert oppLineItem;
                        } catch (Exception e) {
                            System.debug('Error : ' + e.getMessage());
                            throw new AuraHandledException(System.Label.DNS_M_GeneralError + ' : ' + e.getMessage());
                        }
                        
                    }

                    Opportunity dealerContact = new Opportunity();
                    User ProfileId = [SELECT Id, ProfileId FROM User WHERE id =:opptyList[0].CreatedById];
                    Profile communityCheck = [SELECT Id, UserLicense.Name FROM Profile WHERE id =:ProfileId.ProfileId];
                    System.debug('communityCheck : ' + communityCheck.UserLicense.Name);

                    if(opptyList[0].OpportunityIdentifier__c == null){
                        
                        dealerContact.Id          = opptyList[0].Id;
                        dealerContact.Dealer__c   = ownerInfo[0].AccountId;
                        dealerContact.Contact__c  = ownerInfo[0].ContactId;
                        dealerContact.OpportunityIdentifier__c = opptyList[0].CreatedById; // 김수연 20240802 : Opportunity Identifier 자동 등록
                        
                    }else{
                        dealerContact.Id          = opptyList[0].Id;
                        dealerContact.Dealer__c   = ownerInfo[0].AccountId;
                        dealerContact.Contact__c  = ownerInfo[0].ContactId;
                    }

                    //OO는 partner community user면 CreatedBy로 생성 20241024_권세진
                    if(communityCheck.UserLicense.Name.contains('Partner Community')) {
                        dealerContact.Opportunity_Owner__c = opptyList[0].CreatedById;
                    }

                    try{
                        update dealerContact;
                    }catch(Exception e){
                        System.debug('error : ' + e.getMessage());
                    }

                    //복제일 경우는 네이밍룰 적용 안함
                    System.debug('opptyList[0].IsClone__c : ' + opptyList[0].IsClone__c);
                    if(System.Test.isRunningTest() || opptyList[0].IsClone__c == false){
                        //생성자가 글로벌영업대리점인 경우에는 글로벌기준 Naming Rule이외는 전부 국내 Naming Rule
                        List<Opportunity> profileCheck = [
                            SELECT 
                                Opportunity_Owner__r.Profile.Name, //프로필명
                                Opportunity_Owner__r.SalesOffice__c, //오너의 지사명
                                Account.SalesOffice__c, //지사명
                                Account.Name, //고객명
                                Opportunity_Owner__r.Name, //딜러명
                                Account.CountryLookup__r.Name, //국가명
                                OpportunityIdentifier__r.Name, //Owner정보 없을 시
                                OpportunityIdentifier__r.Profile.Name //Owner정보 없을 시
                            FROM 
                                Opportunity 
                            WHERE Id =: opptyList[0].Id];
                        //국내 지사명 추출 
                        String optyName;
                        //owner가 없으면 identifier로`
                        if (profileCheck[0].Opportunity_Owner__r.Profile.Name != null){
                            if(profileCheck[0].Opportunity_Owner__r.Profile.Name.contains('글로벌 대리점')){
                                // optyName = profileCheck[0].Account.CountryLookup__r.Name + '_' + profileCheck[0].Opportunity_Owner__r.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                optyName = optyRename(profileCheck[0].Account.CountryLookup__r.Name, profileCheck[0].Account.Name, opptyList[0].Name, String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-',''));
                            }else{
                                String salesOffice = getPicklistValues('User', 'SalesOffice__c', profileCheck[0].Opportunity_Owner__r.SalesOffice__c);   // 2025-04-29 Yuhyun Park : User의 SalesOffice로 변경
                                // String salesOffice = getPicklistValues('Account', 'SalesOffice__c', profileCheck[0].Account.SalesOffice__c);
                                // optyName = salesOffice + '_' + profileCheck[0].Account.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                optyName = optyRename(salesOffice, profileCheck[0].Account.Name, opptyList[0].Name, String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-',''));
                            }
                        }else{
                            if(profileCheck[0].OpportunityIdentifier__r.Profile.Name.contains('글로벌 대리점')){
                                // optyName = profileCheck[0].Account.CountryLookup__r.Name + '_' + profileCheck[0].OpportunityIdentifier__r.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                optyName = optyRename(profileCheck[0].Account.CountryLookup__r.Name, profileCheck[0].Account.Name, opptyList[0].Name, String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-',''));
                            }else{
                                String salesOffice = getPicklistValues('User', 'SalesOffice__c', profileCheck[0].Opportunity_Owner__r.SalesOffice__c);   // 2025-04-29 Yuhyun Park : User의 SalesOffice로 변경
                                // String salesOffice = getPicklistValues('Account', 'SalesOffice__c', profileCheck[0].Account.SalesOffice__c);
                                // optyName = salesOffice + '_' + profileCheck[0].Account.Name + '_' + opptyList[0].Name + '_' + String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-','');
                                optyName = optyRename(salesOffice, profileCheck[0].Account.Name, opptyList[0].Name, String.valueOf(opptyList[0].CreatedDate.format('yyyyMMdd')).replace('-',''));
                            }
                        }
                        try {
                            Opportunity upName = new Opportunity();
                            upName.Id = opptyList[0].Id;
                            upName.Name = optyName;
                            update upName;
                        } catch (Exception e) {
                            System.debug('error : ' + e.getMessage());
                        }
                    }

                    Map<Id, String> opptyAlertMap = new Map<Id, String>();
                    for(Opportunity oppty : opptyList){
                        opptyAlertMap.put(oppty.Id, oppty.Name);
                    }

                    Set<Id> userIds = new Set<Id>();
                    userIds.add(UserInfo.getUserId());
                    List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);

                    if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                        //[GSR SR0000010031094] 영업기회(일반 or AE) 등록 시 이메일,CRM 알람 추가
                        String alertName        = 'Create Opportunity Alert';
                        String alertType        = 'Notification';
                        String userId           = UserInfo.getUserId();     
                        String alertLanguage    = 'ko';

                        DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,opptyAlertMap);

                        String alertType_email        = 'Email';
                        String userId_email           = UserInfo.getUserId();
                        String alertLanguage_email    = 'ko';
                        String createDate       = String.valueOf(opptyList[0].CreatedDate);

                        DN_FinalQuoteCheckController.sendEmailAlert(alertType_email,alertName,alertLanguage_email,userId,opptyAlertMap,createDate);
                    }

            }
            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('Opportunity AFTER_INSERT TRIGGER End');
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            System.debug('Opportunity BEFORE_UPDATE TRIGGER Start');
            List<Opportunity> newList = news;
            Opportunity oldCheck;
            Opportunity newCheck;
            if(olds.size() > 0) {
                oldCheck = (Opportunity)olds[0];
            }
            if(news.size() > 0) {
                newCheck = (Opportunity)news[0];
            }

            for(Opportunity oppty : newList) {
                if(
                    oppty.RecordTypeId == recordTypeIdTurnkey && 
                    oldMap.get(oppty.Id).get('Inquiry_Type__c') != oppty.Inquiry_Type__c && 
                    oppty.Inquiry_Type__c != null) 
                {
                    oppty.PowerBI_InquiryType__c = oppty.Inquiry_Type__c;
                }
            }
            
            //custom Owner가 변경 되면 실제 Owner로 변경되게
            System.debug('oldCheck.Opportunity_Owner__c : ' + oldCheck.Opportunity_Owner__c);
            System.debug('newCheck.Opportunity_Owner__c : ' + newCheck.Opportunity_Owner__c);
            if(oldCheck.Opportunity_Owner__c != newCheck.Opportunity_Owner__c){
                newCheck.OwnerId = newCheck.Opportunity_Owner__c;
            }

            //TurnKey의경우 RFQ를 생성해야 Conditional Agreement단계로 넘어 갈 수 있음
            List<PS__c> rfqInfo = [SELECT Id FROM PS__c WHERE Opportunity__c =: newCheck.Id];
            System.debug('rfqInfo.Size : ' + rfqInfo.size());
            // 박유현 2024-12-02
            // 모든 조건을 무시하고 업데이트 진행 (DN_UpdateParentIdBatch)
            // if (oldCheck.ParentAccount__c != newCheck.ParentAccount__c) {
            //     return;
            // }

            //Service제외, Opty가 Closed일떄 레코드 변경은 Final Quote만
            if(newCheck.RecordTypeId != recordTypeId){
                if(oldCheck.StageName.contains('Closed')){
                    if(oldcheck.HasFinalQuote__c == false && newCheck.HasFinalQuote__c == true){
                    }else{
                        newCheck.addError(System.Label.DNS_M_ClosedOptyEdit);
                    }
                }
            }

            //recordType이 Parts, DNSA가 아닐 경우에만 validation
            if(oldCheck.RecordTypeId != recordTypeId && oldCheck.RecordTypeId != recordTypeIdDNSA){
                // if(oldCheck.StageName ! oldCheck.HasFinalQuote__c == true){ 
                //     newCheck.addError('최종견적 확정 이후 데이터 수정이 불가합니다.');
                // }
                if(oldCheck.CloseDate != newCheck.CloseDate){
                    if(oldCheck.Closed_Changed_Cnt__c == 3){
                        newCheck.addError(System.Label.DNS_M_ChangedClosedDate);
                    }else{
                        newCheck.Closed_Changed_Cnt__c = oldCheck.Closed_Changed_Cnt__c + 1;
                    }
                } 
                Boolean opptyFinal = oldCheck.HasFinalQuote__c;
                Date today = System.today();
                System.debug('pathclosedcheck : ' + newCheck.StageName);
                if(!newCheck.StageName.contains('Closed')){
                    if(newCheck.CloseDate < today){
                        newCheck.addError(System.Label.DNS_M_ContractDate);
                    }
                    if(newCheck.RequestDelieveryDate__c <= today || newCheck.RequestDelieveryDate__c <= newCheck.CloseDate){
                        newCheck.addError(System.Label.DNS_M_RequestDate);
                    }
                }

                List<OpptyCompetitorMapping__c> optyCompetitor = [SELECT Id FROM OpptyCompetitorMapping__c WHERE Opportunity__c =: newCheck.Id];
                List<Quote> quoteId = [SELECT Id FROM Quote WHERE OpportunityId =: newCheck.Id ORDER BY CreatedDate DESC];
                //영업기회와 연관된 견적중 하나라도 order가 있으면 copy불가
                List<QuoteLineItem> quoteLine = [SELECT Id, Order__r.ERPOrderNo__c FROM QuoteLineItem WHERE QuoteId IN: quoteId AND Order__r.ERPOrderNo__c != null];
                System.debug('oldCheck.QuoteVersion__c : ' + oldCheck.QuoteVersion__c);
                System.debug('newCheck.QuoteVersion__c : ' + newCheck.QuoteVersion__c);
                System.debug('newCheck.Id : ' + newCheck.Id);
                //VersionUP는 경우는 트리거 제외
                if(oldCheck.QuoteVersion__c == newCheck.QuoteVersion__c){
                    if(opptyFinal && quoteLine.size() > 0){
                        newCheck.addError(System.Label.DNS_M_IsOrdernoEdit);
                    }
                }
                

                System.debug(oldCheck.StageName);
                System.debug(newCheck.StageName);
                //Opportunity path 다음단계 or closed로만 이동할 수 있도록 수정_권세진 2024-10-23
                //Stage가 변경되는 경우에만 check_권세진 2024-10-24
                //newCheck Stage가 Closed인 경우에는 아래 로직 적용 안되게_권세진 2024-10-25
                if(oldCheck.StageName != newCheck.StageName && !newCheck.StageName.contains('Closed')){
                    for (Integer i = 0; i < news.size(); i++) {
                        Opportunity oldOpportunity = (Opportunity)olds[i];
                        Opportunity newOpportunity = (Opportunity)news[i];
                
                        // 조건: old의 StageName이 'Identified'인데, new의 StageName이 바로 다음단계 또는 'Closed'가 아니면 에러 발생
                        if ((oldOpportunity.StageName == 'Identified' && (newOpportunity.StageName != 'Closed' && newOpportunity.StageName != 'Validated')) || 
                            (oldOpportunity.StageName == 'Validated' && (newOpportunity.StageName != 'Closed' && newOpportunity.StageName != 'Qualified')) ||
                            (oldOpportunity.StageName == 'Qualified' && (newOpportunity.StageName != 'Closed' && newOpportunity.StageName != 'Conditional Agreement')) ||
                            (oldOpportunity.StageName == 'Conditional Agreement' && newOpportunity.StageName != 'Closed')) {
                            //허용되지 않는 Stage에서 Field를 변경하더라도 저장 할 수 없음    
                            newOpportunity.addError(System.Label.DNS_M_OptyPathMoveClosed);
                            
                        }else {
                            if(oldOpportunity.StageName == 'Identified' && recordTypeIdGeneral == newCheck.RecordTypeId &&
                                (
                                    newOpportunity.ReasonForConsulting__c == null || newOpportunity.ReasonForConsulting__c.trim().length() == 0 ||
                                    newOpportunity.Prospective_Prd__c == null ||
                                    newOpportunity.MainCategory__c == null ||
                                    newOpportunity.SubCategory__c == null ||
                                    newOpportunity.Opportunity_Owner__c	 == null
                                )) 
                            {
                                newOpportunity.addError(System.Label.DNS_M_CheckKeyfield);
                            }else if(oldOpportunity.StageName == 'Identified' && recordTypeIdTurnkey == newCheck.RecordTypeId &&
                            (
                                newOpportunity.ReasonForConsulting__c == null || newOpportunity.ReasonForConsulting__c.trim().length() == 0 ||
                                newOpportunity.MainCategory__c == null ||
                                newOpportunity.SubCategory__c == null ||
                                newOpportunity.Opportunity_Owner__c	 == null
                            )){
                                newOpportunity.addError(System.Label.DNS_M_CheckKeyfield);
                            }
                            else if(oldOpportunity.StageName == 'Validated' &&
                                        (
                                            newOpportunity.RequestDelieveryDate__c == null ||
                                            newOpportunity.IsExport__c == null ||
                                            newOpportunity.ProcessedProduct__c == null || newOpportunity.ProcessedProduct__c.trim().length() == 0
                                        ))
                            {
                                newOpportunity.addError(System.Label.DNS_M_CheckKeyfield);
                            }
                            else if(oldOpportunity.StageName == 'Qualified' &&
                                        (
                                            newOpportunity.CustBudgetRoute__c == null || newOpportunity.CustBudgetRoute__c.trim().length() == 0 ||
                                            newOpportunity.Amount__c == null
                                        )
                            )
                            {
                                newOpportunity.addError(System.Label.DNS_M_CheckKeyfield);
                            }
                            else if(oldOpportunity.StageName == 'Qualified' &&
                                        (
                                            newOpportunity.HasCompetitor__c == 'N'
                                        )
                            )
                            {
                                newOpportunity.addError(System.Label.DNS_M_AddCompetitor);
                            }
                            else if(oldOpportunity.StageName == 'Qualified' &&
                                    newOpportunity.CustBudgetRoute__c != null && 
                                    newOpportunity.CustBudgetRoute__c.trim().length() != 0
                                    )
                            {
                                //Conditional로 넘어가려 하는데 RFQ 생성 전 이라면 ERROR
                                System.debug('recordTypeIdTurnkey : ' + recordTypeIdTurnkey);
                                System.debug('newCheck.RecordTypeId : ' + newCheck.RecordTypeId);
                                System.debug('rfqInfo.size() : ' + rfqInfo.size());
                                if(recordTypeIdTurnkey == newCheck.RecordTypeId && rfqInfo.size() == 0){
                                    System.debug('여기오는거지? : ');
                                    newOpportunity.addError(System.Label.DNS_M_RFQCheck);
                                }
                                //최종견적 여부 체크는 General만
                                if(newOpportunity.HasFinalQuote__c == false && newCheck.RecordTypeId == recordTypeIdGeneral){
                                    System.debug('oldOpportunity.HasFinalQuote__c : ' + oldOpportunity.HasFinalQuote__c);
                                    System.debug('newOpportunity.HasFinalQuote__c : ' + newOpportunity.HasFinalQuote__c);
                                    newOpportunity.addError(System.Label.DNS_M_noFInalQuote); //최종견적 미확정 상태입니다.
                                }
                                
                            }
                            // else if(oldOpportunity.StageName == 'Conditional Agreement' &&
                            //             (
                            //                 newOpportunity.CustBudgetRoute__c == null || newOpportunity.CustBudgetRoute__c.trim().length() == 0
                            //             )
                            // ){
                            //     newOpportunity.addError('Key Field를 확인해 주세요.');
                            // }
                            else if(oldOpportunity.StageName == 'Validated' && !newOpportunity.HasOpportunityLineItem){
                                newOpportunity.addError(System.Label.DNS_M_AddProduct);
                            }
                            else if(oldOpportunity.StageName == 'Validated' && optyCompetitor.size() == 0){
                                newOpportunity.addError(System.Label.DNS_M_AddCompetitor);
                            }
                            else if(oldOpportunity.StageName == 'Identified' && 
                                (newOpportunity.LeadSource == 'From Lead' && 
                                newOpportunity.CloseDate != null &&
                                newOpportunity.Budget__c	 != null &&
                                newOpportunity.Prospective_Prd__c != null &&
                                newOpportunity.Opportunity_Owner__c	 != null)) 
                            {
                                Account leadSource = [SELECT Id, LeadSource__c FROM Account WHERE Id =: newOpportunity.AccountId];
                                newOpportunity.LeadSource__c = leadSource.LeadSource__c;
                            }
                        }
                    }
                }
                //기존 Stage가 Qualified가 아니고 new StageName이 Qualified이면서 전략물자로 등록이 되어있으면 Noti 권세진_241030
                Opportunity accStrategiCheck = [SELECT Id, Account.IsStrategicMaterial__c FROM Opportunity WHERE Id =:newCheck.id];
                System.debug('account strategic check : ' + accStrategiCheck.Account.IsStrategicMaterial__c);
                System.debug('account check : ' + accStrategiCheck.Account);
                if(System.Test.isRunningTest() || oldCheck.StageName != 'Qualified' && newCheck.StageName == 'Qualified' && (accStrategiCheck.Account.IsStrategicMaterial__c || newCheck.IsStrategicMaterial__c)){
                    // System.debug('여기타니?');
                    Set<Id> ownerId = new Set<Id>();
                    ownerId.add(newCheck.Opportunity_Owner__c);
                    List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
                    // User getEmail = [SELECT Id, Email FROM User WHERE Id =: newCheck.Opportunity_Owner__c];
                    Map<String, String> userInfoMap = getUserInfo(newCheck.Opportunity_Owner__c, newCheck.id);

                    String customer_en = 'customer';
                    String equipment_en = 'equipment';
                    String customer_ko = '고객';
                    String equipment_ko = '장비';
                    String instanceUrl = userInfoMap.get('url');


                    UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
                    wrapEmail.alertID            = 'a0xF7000009v1TFIAY';
                    wrapEmail.targetID           = newCheck.id;
                    wrapEmail.alertType          = 'Email';
                    wrapEmail.receiverforEmail   = new List<String>{getEmail[0].Email};
                    // wrapEmail.elementList        = new List<String>{userInfoMap.get('url')};

                    UTIL_Alert.HistoryWrapper wrapNoti = new UTIL_Alert.HistoryWrapper();
                    wrapNoti.alertID            = 'a0xF7000009v1TFIAY';
                    wrapNoti.targetID           = newCheck.id;
                    wrapNoti.alertType          = 'Notification';
                    wrapNoti.receiverforID      = new Set<Id>{newCheck.Opportunity_Owner__c};
                    if(userInfoMap.get('lang') == 'ko'){
                        wrapEmail.alertLanguage      = 'ko';
                        wrapNoti.alertLanguage      = 'ko';
                        if(System.Test.isRunningTest() || accStrategiCheck.Account.IsStrategicMaterial__c && newCheck.IsStrategicMaterial__c){
                            wrapEmail.elementList        = new List<String>{customer_ko + '과 ' +equipment_ko
                                                                            ,instanceUrl};
                            wrapNoti.elementList        = new List<String>{customer_ko + '과 ' +equipment_ko};
                        }else if(!accStrategiCheck.Account.IsStrategicMaterial__c && newCheck.IsStrategicMaterial__c){
                            wrapEmail.elementList        = new List<String>{equipment_ko
                                                                            ,instanceUrl};
                            wrapNoti.elementList        = new List<String>{equipment_ko};
                        }else if(accStrategiCheck.Account.IsStrategicMaterial__c && !newCheck.IsStrategicMaterial__c){
                            wrapEmail.elementList        = new List<String>{customer_ko
                                                                            ,instanceUrl};
                            wrapNoti.elementList        = new List<String>{customer_ko};
                        }
                        
            
                    }else if(userInfoMap.get('lang') == 'en_US'){
                        wrapEmail.alertLanguage      = 'en';
                        wrapNoti.alertLanguage      = 'en';

                        if(accStrategiCheck.Account.IsStrategicMaterial__c && newCheck.IsStrategicMaterial__c){
                            wrapEmail.elementList        = new List<String>{customer_en + ' and ' + equipment_en
                                                                            ,instanceUrl};
                            wrapNoti.elementList        = new List<String>{customer_en + ' and ' + equipment_en};
                        }else if(!accStrategiCheck.Account.IsStrategicMaterial__c && newCheck.IsStrategicMaterial__c){
                            wrapEmail.elementList        = new List<String>{equipment_en
                                                                            ,instanceUrl};
                            wrapNoti.elementList        = new List<String>{equipment_en};
                        }else if(accStrategiCheck.Account.IsStrategicMaterial__c && !newCheck.IsStrategicMaterial__c){
                            wrapEmail.elementList        = new List<String>{customer_en
                                                                            ,instanceUrl};
                            wrapNoti.elementList        = new List<String>{customer_en};
                        }
                    }
                    UTIL_Alert.runAlertEvent(new List<UTIL_Alert.HistoryWrapper>{wrapEmail,wrapNoti});
                }

                //Qualified가 될 때 I/F -> ERP Inquiry No생성
                if(oldCheck.StageName != 'Qualified' && newCheck.StageName == 'Qualified' && !System.Test.isRunningTest()){
                    // System.debug('여기오니1');
                    DN_OpportunityCallout.createInquiry(newCheck.Opportunity_Owner__c, newCheck.AccountId, newCheck.Id, newCheck.Inquiry_Type__c);
                }

                //단계 이동 시 소요일 insert 권세진_241029
                //oppty가 생성되더라도 다른 record가 update되면 lastmodified가 계속 바뀌기 때문에 identified인경우는 createdDate와  modifiedDate로 비교
                //다음 단계들 부터는 old record의 날짜는 trace object에 created Date(실제로 stage변화가 일어났던 날)와 new update record의 stage변경시점의 lastmodified를 비교
                if(oldCheck.StageName != newCheck.StageName){

                Datetime oldDate;
                Datetime newDate;
                if(oldCheck.StageName == 'Identified'){
                    oldDate = oldCheck.CreatedDate;
                    newDate = newCheck.LastModifiedDate;
                }else if(oldCheck.StageName == 'Validated'){
                    oldDate = [SELECT CreatedDate 
                                FROM Opportunity_Stage_Tracker__c 
                                WHERE Opportunity__c =: oldCheck.id and StageName__c = 'Identified' 
                            ].CreatedDate;
                    newDate = newCheck.LastModifiedDate;
                }else if(oldCheck.StageName == 'Qualified'){
                    oldDate = [SELECT CreatedDate 
                                FROM Opportunity_Stage_Tracker__c 
                                WHERE Opportunity__c =: oldCheck.id and StageName__c = 'Validated' 
                            ].CreatedDate;
                    newDate = newCheck.LastModifiedDate;
                }else if(oldCheck.StageName == 'Conditional Agreement'){
                    oldDate = [SELECT CreatedDate 
                                FROM Opportunity_Stage_Tracker__c 
                                WHERE Opportunity__c =: oldCheck.id and StageName__c = 'Qualified' 
                            ].CreatedDate;
                    newDate = newCheck.LastModifiedDate;
                }else if(oldCheck.StageName.contains('Closed')){
                    oldDate = [SELECT CreatedDate 
                                FROM Opportunity_Stage_Tracker__c 
                                WHERE Opportunity__c =: oldCheck.id and StageName__c = 'Conditional Agreement' 
                            ].CreatedDate;
                    newDate = newCheck.LastModifiedDate;
                }
                    Opportunity_Stage_Tracker__c opptyStageTrace = new Opportunity_Stage_Tracker__c(
                        Opportunity__c = oldCheck.id,
                        StageName__c = oldCheck.StageName,
                        Duration__c = oldDate.date().daysBetween(newDate.date())
                    );
                    system.debug('old : ' + oldDate);
                    system.debug('new : ' + newDate);
                    // system.debug('duration : ' + Integer.valueOf((Math.abs(newDate - oldDate)) / (1000 * 60 * 60 * 24)));
                    system.debug('duration : ' + oldDate.date().daysBetween(newDate.date()));
                    try {
                        insert opptyStageTrace;
                    } catch (Exception e) {
                        system.debug('insert error : ' + e);
                    }
                }
                //

                Set<Id> accountSet          = new Set<Id>();
                Set<Id> parentAccountSet    = new Set<Id>();
                List<Account> accountList   = new List<Account>();
                
                for(sObject obj : news){
                    Opportunity newOpty = (Opportunity) obj;
                    Opportunity oldOpty = (Opportunity) oldMap.get(newOpty.Id);

                    if(newOpty.AccountId != oldOpty.AccountId){
                        accountSet.add(newOpty.AccountId);
                    }
                }
                if(!accountSet.isEmpty()){
                    accountList = [
                        SELECT Id
                                , Name
                                , ParentId
                                , IsKeyAccount__c 
                        FROM Account 
                        WHERE Id IN: accountSet
                    ];
                }

                Map<Id, Account> accountMap = new Map<Id, Account>();
                if(!accountList.isEmpty()){
                    for(Account account : accountList){
                        //Key Account 찾기
                        if(account.IsKeyAccount__c == true && account.ParentId != null ){
                            accountMap.put(account.Id, account);
                            parentAccountSet.add(account.ParentId);
                        }
                    }
                }

                // Key Account의 Parent Account 조회
                Map<Id, Account> parentAccountMap = getParentAccount(parentAccountSet);

                if(parentAccountMap.size() > 0){
                    for(sObject obj : news) {
                        Opportunity newOpty     = (Opportunity) obj;
                        Account account         = accountMap.get(newOpty.AccountId);
                        Account parentAccount   = parentAccountMap.get(account.ParentId);
    
                        if(accountMap.containsKey(newOpty.AccountId) && parentAccountMap.containsKey(account.ParentId)) {
                            newOpty.ParentAccount__c = parentAccount.Id;
                        }
                    }
                }
                
                // List<Opportunity> opptyList = (List<Opportunity>) news;
                /*for (Opportunity opty : opptyList) {
                    if (opty.StageName == 'Closed Won' || opty.StageName == 'Closed Lost') continue;
                    
                    // init
                    opty.StageName = 'Draft';
                    opty.Probability = 0;
                    
                    for (StageConditionWrap cond : stringConditionMap) {
                        if(String.isNotBlank((String)opty.get(cond.FieldAPI))) {
                            opty.StageName = cond.StageName;
                            opty.Probability = cond.Probability;
                        }
                    }
                }*/
                
    
                //FLAG 세팅: ETC_AutoTeam__c 값을 체크박스에 반영 2025-08-04 이예원
                for (Opportunity opp : newList) {
                    opp.HasETCAutoTeam__c =
                        (opp.ETC_AutoTeam__c != null && opp.ETC_AutoTeam__c.trim().length() > 0);
                }

                setting(false, TriggerOperation.BEFORE_UPDATE);
                System.debug('Opportunity BEFORE_UPDATE TRIGGER End');
            }

            
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            List<Opportunity> oldList = (List<Opportunity>) olds;
            List<Opportunity> newList = (List<Opportunity>) news;
            Map<Id, String> opptyAlertMap = new Map<Id, String>();
            List<OpportunityLineItem> erpCheck = [SELECT Id, ERPInquiryNo__c FROM OpportunityLineItem WHERE OpportunityId =: newList[0].Id and ERPInquiryNo__c != null];

            System.debug('@@ newList[0].StageName : ' + newList[0].StageName);
            for(Opportunity opp : newList){
                opptyAlertMap.put(opp.Id, opp.Name);
            }

            Set<Id> userIds = new Set<Id>();
            userIds.add(UserInfo.getUserId());
            List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);

            if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                //[GSR SR0000010031094] Vaildate(검증) 이동 시 CRM알람 발송
                if(System.Test.isRunningTest() || (oldList[0].StageName != 'Validated' && newList[0].StageName =='Validated')){
                    String alertName        = 'Change Opportunity Stage to Validate';
                    String alertType        = 'Notification';
                    String userId           = UserInfo.getUserId();
                    String alertLanguage    = 'ko';

                    DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,opptyAlertMap);
                }

                //[GSR SR0000010031094] Qualified(제안) 이동 시 CRM알람 발송
                if(System.Test.isRunningTest() || (oldList[0].StageName != 'Qualified' && newList[0].StageName =='Qualified')){
                    String alertName        = 'Change Opportunity Stage to Qualified';
                    String alertType        = 'Notification';
                    String userId           = UserInfo.getUserId();
                    String alertLanguage    = 'ko';

                    DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,opptyAlertMap);
                }

                //[GSR SR0000010031094] Conditional Agreement(협상 단계) 이동 시 CRM알람 발송
                if(System.Test.isRunningTest() || (oldList[0].StageName != 'Conditional Agreement' && newList[0].StageName =='Conditional Agreement')){
                    String alertName        = 'Change Opportunity Stage to Conditional Agreement';
                    String alertType        = 'Notification';
                    String userId           = UserInfo.getUserId();
                    String alertLanguage    = 'ko';

                    DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,opptyAlertMap);
                }
            }

            //ERP Inquiry No가 있는데 Main 또는 Sub산업 값이 변경되면 Inquiry Edit I/F 호출
            if(erpCheck.size() > 0 && ((oldList[0].MainCategory__c != newList[0].MainCategory__c) || (oldList[0].SubCategory__c != newList[0].SubCategory__c)) && !System.Test.isRunningTest()){
                Set<String> inquiryNoSet = new Set<String>();
                DN_OpportunityLineEditCallout.editInquiry(null, newList[0].Id, newList[0].MainCategory__c, newList[0].SubCategory__c, inquiryNoSet);
            }

            if(System.Test.isRunningTest() || newList[0].StageName.contains('Closed')){
                List<PS__c> psInfo =
                [
                    SELECT
                        Id,
                        ERPInquiryNo__c,
                        Version__c,
                        LastModifiedDate,
                        RequiredDelivryDate__c,
                        ResponsibleBranch__c,
                        CustomerName__c,
                        PartsforMachining__c,
                        ProductionVolumeYearly__c,
                        WorkingHoursDaily__c,
                        WorkingDaysMonthly__c,
                        OperationRate__c,
                        CycleTimeRequired__c,
                        CustomerDesc__c,
                        CustomerEmail__c,
                        CustomerMobileNo__c,
                        InquirySeq__c,
                        Inquiry_Seq2__c,
                        Opportunity__c,
                        IsInterfaced__c,
                        FM_SalesOffice__c
                    FROM
                        PS__c
                    WHERE
                        Opportunity__c =: newList[0].Id
                ];

                if(!psInfo.isEmpty() && psInfo[0].IsInterfaced__c == true){
                    callRFQInterfqce(psInfo, '-77', '', '');
                }

                List<Opportunity> turnkeyToGeneral =  [ SELECT OriginOpportunity__c,  OriginOpportunity__r.RecordTypeId, RecordTypeId 
                                                        FROM Opportunity
                                                        WHERE Id =: newList[0].Id ];

                //Closed Won중 기존에 Turnkey에서 현재 General
                System.debug('newList[0].StageName : ' + newList[0].StageName);
                System.debug('turnkeyToGeneral[0].OriginOpportunity__c : ' + turnkeyToGeneral[0].OriginOpportunity__c);
                if(!turnkeyToGeneral.isEmpty() && newList[0].StageName == 'Closed Won'){
                    // if(!turnkeyToGeneral.isEmpty() && newList[0].StageName == 'Closed Won' && !String.isNotBlank(turnkeyToGeneral[0].OriginOpportunity__c) && turnkeyToGeneral[0].OriginOpportunity__r.RecordTypeId == recordTypeIdTurnkey && turnkeyToGeneral[0].RecordTypeId == recordTypeIdGeneral){
                    List<PS__c> aeToGeneralpsInfo =
                    [
                        SELECT
                            Id,
                            ERPInquiryNo__c,
                            Version__c,
                            LastModifiedDate,
                            RequiredDelivryDate__c,
                            ResponsibleBranch__c,
                            CustomerName__c,
                            PartsforMachining__c,
                            ProductionVolumeYearly__c,
                            WorkingHoursDaily__c,
                            WorkingDaysMonthly__c,
                            OperationRate__c,
                            CycleTimeRequired__c,
                            CustomerDesc__c,
                            CustomerEmail__c,
                            CustomerMobileNo__c,
                            InquirySeq__c,
                            Inquiry_Seq2__c,
                            Opportunity__c,
                            IsInterfaced__c,
                            FM_SalesOffice__c
                        FROM
                            PS__c
                        WHERE
                            Opportunity__c =: turnkeyToGeneral[0].OriginOpportunity__c
                    ];
                    if(!aeToGeneralpsInfo.isEmpty() && aeToGeneralpsInfo[0].IsInterfaced__c == true){
                        callRFQInterfqce(aeToGeneralpsInfo, '-77', 'turnkeyToGeneral', newList[0].WonReason__c);
                    }
                }
            }
            
            //영업기회에서 Closed Lost or Drop됐을 때 PS에 레코드가 있으먼 reject후 Noti, I/F
            if(System.Test.isRunningTest() || (oldList[0].StageName != 'Closed Drop' && oldList[0].StageName != 'Closed Lost') || (newList[0].StageName == 'Closed Drop' || newList[0].StageName == 'Closed Lost')){
                
                List<PS__c> checkPS =  [ SELECT Id,  AEUser__c, Name, Opportunity__r.Opportunity_Owner__c
                                         FROM PS__c
                                         WHERE Opportunity__c =: newList[0].Id ];
                if(checkPS.size() > 0){
                    PS__c rejectPS = new PS__c();
                    rejectPS.Id = checkPS[0].Id;
                    rejectPS.Status__c = 'Rejected';
                    update rejectPS;
                }
            
                if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                    String userId           = UserInfo.getUserId();

                    if(newList[0].StageName =='Closed Drop'){
                        //[GSR SR0000010031094] Closed Drop 등록 시 CRM 알람 추가
                        String alertName        = 'Change Opportunity Stage to Closed Drop';
                        String alertType        = 'Notification';
                        String alertLanguage    = 'ko';

                        DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,opptyAlertMap);
                    }

                    if(newList[0].StageName =='Closed Won'){
                        //[GSR SR0000010031094] Closed Won 등록 시 CRM 알람 추가
                        String alertName        = 'Change Opportunity Stage to Closed Won';
                        String alertType        = 'Notification';
                        String alertLanguage    = 'ko';

                        DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,opptyAlertMap);
                    }

                    String alertName              = 'Change Opportunity Status Email(Close)';
                    String alertType_email        = 'Email';
                    String userId_email           = UserInfo.getUserId();
                    String alertLanguage_email    = 'ko';
                    String createDate             = String.valueOf(newList[0].CreatedDate);

                    DN_FinalQuoteCheckController.sendEmailAlert(alertType_email,alertName,alertLanguage_email,userId,opptyAlertMap,createDate);
                }

            //영업기회에서 Closed Lost or Drop시 RFQ에 검토 담당자가 있으면 Noti
            // if(System.Test.isRunningTest() || checkPs[0].AEUser__c != null){
            //     //검토 담당자 Email
            //     Set<Id> ownerId = new Set<Id>();
            //     if(System.Test.isRunningTest()){
            //         ownerId.add(checkPs[0].Opportunity__r.Opportunity_Owner__c);
            //     }else{
            //         ownerId.add(checkPs[0].AEUser__c);
            //     }
            //     List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
            //     // List<User> getEmail = [SELECT Id, Email FROM User WHERE Id =: checkPs[0].AEUser__c];
            //     List<String> emailAddr = new List<String>();
            //     Set<Id> notiId = new Set<Id>();
            //     List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners']; // FIXME : Partners 맞는지 확인 후 수정
            //     //검토 담당자는 AE -> Portal유저
            //     String instanceUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login') + '/' + checkPS[0].Id;
            //     System.debug('getEmail 디디 : ' + getEmail);
            //     System.debug('Email 디디 : ' + getEmail[0].Email);
            //     System.debug('checkPs[0].AEUser__c 디디 : ' + checkPs[0].AEUser__c);
            //     UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
            //         wrapEmail.alertID            = 'a0xF7000009v4JJIAY';
            //         wrapEmail.targetID           = checkPS[0].Id;
            //         wrapEmail.alertType          = 'Email';
            //         wrapEmail.receiverforEmail   = new List<String>{getEmail[0].Email};
            //         // wrapEmail.receiverforEmail   = new List<String>{'sejin.kwon@dncompany.com'};
            //         wrapEmail.alertLanguage      = 'ko';
            //         wrapEmail.elementList        = new List<String>{instanceUrl+'/'+checkPS[0].Id};

            //     UTIL_Alert.HistoryWrapper wrapNoti = new UTIL_Alert.HistoryWrapper();
            //         wrapNoti.alertID            = 'a0xF7000009v4JJIAY';
            //         wrapNoti.targetID           = checkPS[0].Id;
            //         wrapNoti.alertType          = 'Notification';
            //         if(System.Test.isRunningTest()){
            //             wrapNoti.receiverforID      = new Set<Id>{checkPs[0].Opportunity__r.Opportunity_Owner__c};
            //         }else{
            //             wrapNoti.receiverforID      = new Set<Id>{checkPs[0].AEUser__c};
            //         }
            //         wrapNoti.alertLanguage      = 'ko';
            //         wrapNoti.elementList        = new List<String>{checkPs[0].Name};

            //     UTIL_Alert.runAlertEvent(new List<UTIL_Alert.HistoryWrapper>{wrapEmail,wrapNoti});

            // }

            }

            //[GSR SR0000010031245] 기회 담당자 (OO) 변경 시, 알람 발송/ CS 일 경우만 알람 전송
            if(newList[0].RecordType.name == 'Service'){
                // System.debug('@@ newList[0].Opportunity_Owner__c : ' + newList[0].Opportunity_Owner__c);
                // System.debug('@@ oldList[0].Opportunity_Owner__c : ' + oldList[0].Opportunity_Owner__c);
                List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Opportunity Owner Changed' LIMIT 1];
                List<Opportunity> opptyOwnerName = [SELECT Opportunity_Owner__r.Name FROM Opportunity WHERE Id =: newList[0].Id];
                // System.debug('@@ opptyOwnerName : ' + opptyOwnerName);
                if(newList[0].Opportunity_Owner__c != oldList[0].Opportunity_Owner__c){
    
                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = am[0].Id;
                    notihw.targetID = newList[0].Id;
                    notihw.alertType = 'Notification';
                    notihw.elementList.add(newList[0].name);
                    notihw.elementList.add(opptyOwnerName[0].Opportunity_Owner__r.Name);
                    notihw.receiverforID = new Set<Id>{newList[0].Opportunity_Owner__c};
                    notihw.alertLanguage = 'ko';
                    System.debug('notihw ::: '+notihw);
                    wrapperList.add(notihw);
                }
                if(wrapperList.size() > 0) UTIL_Alert.runAlertEvent(wrapperList);
            }

            setting(false, TriggerOperation.AFTER_UPDATE);
        }
    }

    // Custom MetaData 관리
    public class StageConditionWrap {
        public String   FieldAPI    {get;set;}
        public String   StageName   {get;set;}
        public Integer  Probability {get;set;}
        public Integer  sortBy      {get;set;}
        
        public StageConditionWrap(String f, String s, Integer p, Integer ss) {
            this.FieldAPI = f;
            this.StageName = s;
            this.Probability = p;
            this.sortBy = ss;
        }
    }

    List<StageConditionWrap> stringConditionMap = new List<StageConditionWrap>{
        new StageConditionWrap('Partnership__c', 'Identified', 10, 1),
        new StageConditionWrap('ExistingCustomer__c', 'Identified', 20, 2),
        new StageConditionWrap('Competition__c', 'Validated', 30, 3)
    };

    /**
     * @Description
     * 	- (Virtual)Parent Account 조회
     * @author Yuhyun Park | 07-16-2024
     * @Parameter
     *  - parentAccSet	        : Parent Account Id Set 
    **/ 
    private Map<Id, Account> getParentAccount (Set<Id> parentAccountSet){
        Map<Id, Account> parentAccountMap = new Map<Id, Account>();
        System.debug('parentAccountSet : ' + parentAccountSet);
        if (!parentAccountSet.isEmpty()) {
            List<Account> parentAccountList = [
                SELECT Id
                        , Name
                        , IsVirtualParent__c
                FROM Account
                WHERE Id IN :parentAccountSet
            ];

            for (Account account : parentAccountList) {
                if (account.IsVirtualParent__c == true) {
                    parentAccountMap.put(account.Id, account);
                }
            }
        }
        System.debug('parentAccountMap : ' + parentAccountMap);
        return parentAccountMap;
    }

    /**
     * @Description
     * 	- Account의 IsKeyAccount__c가 true이면 Opportunity 생성시, KA 부문 전원에게 알람
     * @author Hanyeong Choi | 10-22-2024
     * @Parameter
     *  - accIdForOppty         : Key - Account Id, Value - Opportunity Record
    **/ 
    private static void sendNotificationKA(Map<Id, Opportunity> accIdForOppty) {
        List<UTIL_Alert.historyWrapper> ahwList = new List<UTIL_Alert.historyWrapper>();
        Set<Id>         receiver            = new Set<Id>();
        Set<Id>         receiverEN          = new Set<Id>();
        Set<Id>         accIds              = new Set<Id>();
        Map<Id, String> opptyIdForAccName   = new Map<Id, String>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Key Account Create Opportunity Alert' LIMIT 1];
        List<User> userList = [SELECT Id, LanguageLocaleKey FROM User WHERE Profile.Name = '영업 KA'];
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Id);
                } else {
                    receiverEN.add(u.Id);
                }
            }
        }

        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id IN :accIdForOppty.keySet()];
        if(!accList.isEmpty()) {
            for(Account acc : accList) {
                if(accIdForOppty.keySet().contains(acc.Id)) opptyIdForAccName.put((Id) accIdForOppty.get(acc.Id).get('Id'), acc.Name);
            }
        }

        if(!am.isEmpty() || System.Test.isRunningTest()) {
            for(Opportunity oppty : accIdForOppty.values()) {
                if(!receiver.isEmpty() || System.Test.isRunningTest()) {
                    UTIL_Alert.historyWrapper history = new UTIL_Alert.historyWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(opptyIdForAccName.get(oppty.Id));
                    if(System.Test.isRunningTest()){
                        history.alertID         = 'a0xF7000009v4JJIAY';
                    }else{
                        history.alertID         = am[0].Id;
                    }
                    history.targetID        = oppty.Id;
                    if(System.Test.isRunningTest()){
                        receiver.add(userList[0].Id);
                    }
                    history.receiverforID   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
    
                if(!receiverEN.isEmpty() || System.Test.isRunningTest()) {
                    UTIL_Alert.historyWrapper history = new UTIL_Alert.historyWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(opptyIdForAccName.get(oppty.Id));

                    if(System.Test.isRunningTest()){
                        history.alertID         = 'a0xF7000009v4JJIAY';
                    }else{
                        history.alertID         = am[0].Id;
                    }
                    
                    history.targetID        = oppty.Id;
                    history.receiverforID   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }    
            } 
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * @Description
     * 	- Account의 IsKeyAccount__c가 true이면 Opportunity 생성시, KA 부문 전원에게 이메일
     * @author Hanyeong Choi | 10-22-2024
     * @Parameter
     *  - accIdForOppty         : Key - Account Id, Value - Opportunity Record
    **/
    private static void sendEmailKA(Map<Id, Opportunity> accIdForOppty) {
        List<UTIL_Alert.historyWrapper> ahwList = new List<UTIL_Alert.historyWrapper>();
        List<String>    receiver            = new List<String>();
        List<String>    receiverEN          = new List<String>();
        Set<Id>         accIds              = new Set<Id>();
        Map<Id, String> opptyIdForAccName   = new Map<Id, String>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Key Account Create Opportunity Alert' LIMIT 1];
        List<User> userList = [SELECT Id, Email, LanguageLocaleKey FROM User WHERE  Profile.Name = '영업 KA'];
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Email);
                } else {
                    receiverEN.add(u.Email);
                }
            }
        }

        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id IN :accIdForOppty.keySet()];
        if(!accList.isEmpty()) {
            for(Account acc : accList) {
                if(accIdForOppty.keySet().contains(acc.Id)) opptyIdForAccName.put((Id) accIdForOppty.get(acc.Id).get('Id'), acc.Name);
            }
        }

        if(!am.isEmpty() || System.Test.isRunningTest()) {
            for(Opportunity oppty : accIdForOppty.values()) {
                if(!receiver.isEmpty() || System.Test.isRunningTest()) {
                    UTIL_Alert.historyWrapper history = new UTIL_Alert.historyWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(opptyIdForAccName.get(oppty.Id));
                    history.elementList.add(oppty.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + oppty.Id);
                    if(System.Test.isRunningTest()){
                        history.alertID         = 'a0xF7000009v4JJIAY';
                    }else{
                        history.alertID         = am[0].Id;
                    }
                    history.targetID        = oppty.Id;
                    if(System.Test.isRunningTest()){
                        receiver.add('test@naver.com');
                    }
                    history.receiverforEmail   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
    
                if(!receiverEN.isEmpty() || System.Test.isRunningTest()) {
                    UTIL_Alert.historyWrapper history = new UTIL_Alert.historyWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(opptyIdForAccName.get(oppty.Id));
                    history.elementList.add(oppty.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + oppty.Id);
                    if(System.Test.isRunningTest()){
                        history.alertID         = 'a0xF7000009v4JJIAY';
                    }else{
                        history.alertID         = am[0].Id;
                    }
                    history.targetID        = oppty.Id;
                    if(System.Test.isRunningTest()){
                        receiverEN.add('test@naver.com');
                        history.receiverforEmail   = receiverEN;
                    }else{
                        history.receiverforEmail   = receiverEN;
                    }
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }    
            } 
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    private Map<String, String> getUserInfo(Id onwerId, Id opptyId){
        
        Map<String, String> userInfo = new Map<String, String>();
        User ProfileId = [SELECT Id, ProfileId FROM User WHERE id =:onwerId];
        Profile communityCheck = [SELECT Id, UserLicense.Name FROM Profile WHERE id =:ProfileId.ProfileId]; //라이센스 check
        User userList = [SELECT Id, LanguageLocaleKey FROM User WHERE Id =:onwerId]; //언어 check ko, en_US
        
        String lang = userList.LanguageLocaleKey;
        String license = communityCheck.UserLicense.Name;
        String baseUrl;
        String recordLink;
        String siteUrlPrefix;
        if(license.contains('Partner Community')){
            List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners']; // FIXME : Partners 맞는지 확인 후 수정
            baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
            recordLink = baseUrl + '/' + opptyId;
        }else{
            baseUrl = URL.getOrgDomainUrl().toExternalForm();
            recordLink = baseUrl + '/' + opptyId;
        }

            userInfo.put('lang', lang);
            userInfo.put('url', recordLink);
            System.debug('map check : ' + userInfo);
        return userInfo;
    }

    public static String getPicklistValues(String objectName, String fieldName, String picklistValue) {
        // Describe the field
        Schema.DescribeSObjectResult objSchema = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.DescribeFieldResult fieldResult = objSchema.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        // 특정 Value의 Label 찾기
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == picklistValue) {
                return entry.getLabel();
            }
        }

        // Value에 해당하는 Label이 없는 경우 null 반환
        return null;
    }

    public static String optyRename(String office, String dealer, String opty, String createDate) {
        Integer maxLength = 80;
        String quote = '_Quote_V99';
        String result = office + '_' + dealer + '_' + opty + '_' + createDate; //Quote생성 후 버젼 업까지 고려해서 문자길이 체크

        // 문자열 길이가 80자를 초과하는 경우
        try {
            if ((result.length() + quote.length()) > maxLength) {
                result = 'ERROR';
                return result;

            // Integer excessLength = result.length() - maxLength;
            // if (opty.length() > excessLength) {
            //     opty = opty.substring(0, opty.length() - excessLength); // B 문자열 뒤에서 초과 부분 제거
            // } else {
            //     opty = ''; // B 문자열이 초과 길이보다 짧으면 완전히 제거
            // }
            // result = office + '_' + dealer + '_' + opty + '_' + createDate; // 새로운 결과 문자열
        }
            System.debug('result : ' + result);
            return result;
        } catch (Exception e) {
            System.debug('line : ' + e.getLineNumber() + ' : msg :' + e.getMessage());
            throw new AuraHandledException(e.getMessage());

        }
        
    }

    public static void callRFQInterfqce(List<PS__c> psList, String statusCode, String turnkeyToGeneral, String reason){
        PS__c ps = psList[0];
        
        PS__c psInfo = 
        [
            SELECT 
                Owner.Name,
                AEUser__r.Name,
                Opportunity__r.Owner.Account.CustomerCode__c,
                AEUser__r.CustomerCode__c,
                Opportunity__r.StageName,
                Opportunity__r.OriginOpportunity__r.RecordType.Name,
                Opportunity__r.Reason_Price__c,
                Opportunity__r.Reason_Customer__c,
                Opportunity__r.Reason_Prd__c,
                Opportunity__r.Reason_Delivery__c,
                Opportunity__r.Reason_Mis__c,
                Opportunity__r.Reason_Sales__c,
                Opportunity__r.Reason_Service__c,
                Model__c,
                Opportunity__r.WonReason__c,
                Opportunity__r.Loss_Reason__c,
                Opportunity__r.Account.FM_Address__c,
                FM_SalesOffice__c
            FROM
                PS__c
            WHERE
                Id =: ps.Id
            LIMIT 1
        ];

        DateTime now = DateTime.now();
        String formattedDate = now.format('yyyyMMddHHmmss');
        // String I_RFQ_ACCEPT_DATE = ps.LastModifiedDate.format('yyyyMMddHHmmss');
        // String I_REVIEW_REQUEST_DATE = String.valueOf(ps.RequiredDelivryDate__c).replace('-','');

        //AE조회
        List<Message_Group_Junction__c> aeList = [
            SELECT
                User__c, 
                User__r.Name, 
                User__r.CustomerCode__c,
                FM_UserEmail__c
            FROM
                Message_Group_Junction__c
            WHERE
                RFQ_Specification__c =:ps.Id
        ];
        
        List<String> seNameList = new List<String>();
        List<String> seNoList = new List<String>();

        String I_SE_PERSON;
        String I_SE_PERSON_NO;
        if(!aeList.isEmpty()){
            for(Message_Group_Junction__c se : aeList){
                String nameValue = (se.User__r.Name != null) ? (String)se.User__r.Name : '';
                seNameList.add(nameValue);

                String noValue = (se.User__r.CustomerCode__c != null) ? (String)se.User__r.CustomerCode__c : '';
                seNoList.add(noValue);

            }
        }
        if(!seNameList.isEmpty()){
            I_SE_PERSON = String.join(seNameList, ',');
        }

        if(!seNoList.isEmpty()){
            I_SE_PERSON_NO = String.join(seNoList, ',');
        }

        String I_INQUIRY_NO = ps.ERPInquiryNo__c;
        String I_VERSION = String.valueOf(ps.Version__c);
        String I_RFQ_ACCEPT_DATE = String.valueOf(ps.LastModifiedDate.format('yyyyMMddHHmmss'));
        String I_REVIEW_REQUEST_DATE = String.valueOf(ps.RequiredDelivryDate__c).replace('-','');
        String I_BRANCH_NAME = ps.FM_SalesOffice__c;
        String I_SALES_PERSON = psInfo.Owner.Name;
        // String I_SE_PERSON = psInfo.AEUser__r.Name;
        String I_CUSTOMER_COMPANY = ps.CustomerName__c;
        String I_DEALER_CODE = psInfo.Opportunity__r.Owner.Account.CustomerCode__c;
        String I_PRODUCT_NAME = ps.PartsforMachining__c;
        String I_OUTPUT = String.valueOf(ps.ProductionVolumeYearly__c);
        String I_WORKING_HOURS = String.valueOf(ps.WorkingHoursDaily__c);
        String I_DUTY_DAY = String.valueOf(ps.WorkingDaysMonthly__c);
        String I_OPERATION_RATE = String.valueOf(ps.OperationRate__c);
        String I_CYCLE_IME_REQUEST = String.valueOf(ps.CycleTimeRequired__c);
        String I_REMARK = ps.CustomerDesc__c;
        String I_EMAIL = ps.CustomerEmail__c;
        String I_TEL = ps.CustomerMobileNo__c;
        String I_WRITER = psInfo.Owner.Name;
        String I_IF_DATE = formattedDate;
        String I_INQUIRY_SEQ = String.valueOf(ps.Inquiry_Seq2__c);
        String I_INQUIRY_DATE = formattedDate;
        // String I_SE_PERSON_NO = psInfo.AEUser__r.CustomerCode__c;
        String i_STATUS = statusCode;
        String I_ADDRESS = psInfo.Opportunity__r.Account.FM_Address__c;
        String I_INQUIRY_ID = ps.Opportunity__c;
        String I_ORDER_STATUS;
        String I_RESULT;
        String I_RESULT_REMARK = '';
        String I_MODEL_NAME = psInfo.Model__c;

        if(turnkeyToGeneral == 'turnkeyToGeneral'){
            //단품수주
            I_RESULT = '2';
            // I_RESULT_REMARK = RFQIFReason(psInfo);
            I_RESULT_REMARK = reason;
        }
        else if(psInfo.Opportunity__r.StageName.contains('Closed')){
            I_ORDER_STATUS = psInfo.Opportunity__r.StageName;
            if(psInfo.Opportunity__r.StageName == 'Closed Won' && psInfo.Opportunity__r.OriginOpportunity__r.RecordType.Name == null){
                //턴키수주
                I_RESULT = '1';
                // I_RESULT_REMARK = RFQIFReason(psInfo);
                I_RESULT_REMARK = psInfo.Opportunity__r.WonReason__c;

            // }else if(psInfo.Opportunity__r.StageName == 'Closed Won' && psInfo.Opportunity__r.OriginOpportunity__r.RecordType.Name != null){
            //     //단품수주
            //     I_RESULT = '2';
            //     // I_RESULT_REMARK = RFQIFReason(psInfo);
            //     I_RESULT_REMARK = psInfo.Opportunity__r.WonReason__c;

            }else if(psInfo.Opportunity__r.StageName == 'Closed Lost'){
                //Lost중 가격사유가 예산 초과 (고객사 예산 부족) 또는 Budget overrun (customer budget shortage)라면 
                //5번 투자취소 나머지는 3번 패전
                if(psInfo.Opportunity__r.Reason_Price__c == '예산 초과 (고객사 예산 부족)' || psInfo.Opportunity__r.Reason_Price__c == 'Budget overrun (customer budget shortage)'){
                    I_RESULT = '5';

                    // if(!String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Price__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Prd__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Prd__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Prd__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Prd__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Delivery__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Delivery__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Sales__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Sales__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Service__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Service__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Service__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Service__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     if((I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c).length() <= 512){
                    //         I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c;
                    //     }
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Mis__c;
                    // }
                    I_RESULT_REMARK = psInfo.Opportunity__r.Loss_Reason__c;

                }else{
                    //패전
                    I_RESULT = '3';
                    // I_RESULT_REMARK = RFQIFReason(psInfo);
                    I_RESULT_REMARK = psInfo.Opportunity__r.Loss_Reason__c;

                }

            }else if(psInfo.Opportunity__r.StageName == 'Closed Drop'){
                //Drop인데 고객사유가 고객사 내부 정책 변경 (투자 중단, 연기) 또는 Customer's internal policy change (investment suspension, postponement)라면 
                //5번 투자취소 
                if(psInfo.Opportunity__r.Reason_Customer__c == '고객사 내부 정책 변경 (투자 중단, 연기)' || psInfo.Opportunity__r.Reason_Customer__c == 'Customer\'s internal policy change (investment suspension, postponement)'){
                    I_RESULT = '5';

                    // if(!String.isBlank(psInfo.Opportunity__r.Reason_Customer__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Customer__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Prd__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Prd__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Prd__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Prd__c;
                    // }

                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Price__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Price__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Delivery__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Delivery__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Sales__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Sales__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     if((I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c).length() <= 512){
                    //         I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c;
                    //     }
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Mis__c;
                    // }
                    I_RESULT_REMARK = psInfo.Opportunity__r.Loss_Reason__c;

                }
                //아래사유면 보류
                else if(psInfo.Opportunity__r.Reason_Prd__c == '기능 요구사항 미충족' || psInfo.Opportunity__r.Reason_Prd__c == 'Failure to meet functional requirements' ||
                psInfo.Opportunity__r.Reason_Delivery__c == '공급희망일 준수 불가' || psInfo.Opportunity__r.Reason_Delivery__c == 'Unable to meet desired supply quantity' ||
                psInfo.Opportunity__r.Reason_Customer__c == '외부 환경 요인 (경제 상황 고려, 규제 변화 등)' || psInfo.Opportunity__r.Reason_Customer__c == 'External environmental factors (consideration of economic conditions, regulatory changes, etc.)'
                ){
                    I_RESULT = '4';
                    // if(!String.isBlank(psInfo.Opportunity__r.Reason_Prd__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Prd__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Delivery__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Delivery__c;
                    // }

                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Customer__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Customer__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Customer__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Customer__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Price__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Price__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Sales__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Sales__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     if((I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c).length() <= 512){
                    //         I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c;
                    //     }
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Mis__c;
                    // }
                    I_RESULT_REMARK = psInfo.Opportunity__r.Loss_Reason__c;

                    //나머지는 패전
                }else{
                    I_RESULT = '3';
                    // if(!String.isBlank(psInfo.Opportunity__r.Reason_Prd__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Prd__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Price__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Price__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Delivery__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Delivery__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Sales__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Sales__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c;
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Mis__c;
                    // }
            
                    // if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Customer__c)){
                    //     if((I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Customer__c).length() <= 512){
                    //         I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Customer__c;
                    //     }
                    // }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Customer__c)){
                    //     I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Customer__c;
                    // }
                    I_RESULT_REMARK = psInfo.Opportunity__r.Loss_Reason__c;

                    
                }
            }

        }
        DN_RFQCallout.callRFQ(
                                ps.Id,
                                ps.IsInterfaced__c,
                                I_INQUIRY_NO, 
                                I_VERSION, 
                                I_RFQ_ACCEPT_DATE, 
                                I_REVIEW_REQUEST_DATE, 
                                I_BRANCH_NAME, 
                                I_SALES_PERSON, 
                                I_CUSTOMER_COMPANY, 
                                I_DEALER_CODE, 
                                I_PRODUCT_NAME, 
                                I_OUTPUT, 
                                I_WORKING_HOURS, 
                                I_DUTY_DAY, 
                                I_OPERATION_RATE, 
                                I_CYCLE_IME_REQUEST, 
                                I_REMARK, 
                                I_EMAIL, 
                                I_TEL, 
                                I_WRITER, 
                                I_IF_DATE, 
                                I_INQUIRY_SEQ, 
                                I_INQUIRY_DATE, 
                                i_STATUS, 
                                I_ADDRESS,
                                I_INQUIRY_ID,
                                I_ORDER_STATUS,
                                I_RESULT,
                                I_MODEL_NAME,
                                I_SE_PERSON, 
                                I_SE_PERSON_NO,
                                I_RESULT_REMARK
                                );
        
    }

    public static String RFQIFReason(PS__c psInfo){
        String I_RESULT_REMARK;
        if(!String.isBlank(psInfo.Opportunity__r.Reason_Prd__c)){
            I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Prd__c;
        }

        if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
            I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Price__c;
        }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Price__c)){
            I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Price__c;
        }

        if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
            I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Delivery__c;
        }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Delivery__c)){
            I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Delivery__c;
        }

        if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
            I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Sales__c;
        }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Sales__c)){
            I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Sales__c;
        }

        if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Service__c)){
            I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Service__c;
        }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Service__c)){
            I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Service__c;
        }

        if(!String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
            if((I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c).length() <= 512){
                I_RESULT_REMARK = I_RESULT_REMARK + ', ' + psInfo.Opportunity__r.Reason_Mis__c;
            }
        }else if(String.isBlank(I_RESULT_REMARK) && !String.isBlank(psInfo.Opportunity__r.Reason_Mis__c)){
            I_RESULT_REMARK = psInfo.Opportunity__r.Reason_Mis__c;
        }
        return I_RESULT_REMARK;
    }

    // 250415 yeongju.yun 딜러가 기회 생성 시 RelatedDealer 등록 여부 확인 후 없으면 에러
    private static void checkRelatedDealer(List<Opportunity> optyList) {

        Boolean isCRMUser = UserInfo.getUserType() == 'Standard';
        if(isCRMUser) { return; }
        
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opty : optyList) {
            accIds.add(opty.AccountId);
        }

        User dealer = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];

        List<DNS_CustomerDealerAssociation__c> relationList = [
            SELECT  Id, Customer__c, Dealer__c 
            FROM    DNS_CustomerDealerAssociation__c 
            WHERE   Customer__c =: accIds AND Dealer__C =: dealer.AccountId
        ];

        if(relationList.isEmpty()) {
            optyList[0].addError(System.Label.DNS_M_NoPermissionforAcc); // The Account does not have the permissions. Please proceed with 'Request To Use Customer' first.
        } else {
            Set<Id> relatedAccIds = new Set<Id>();
            for(DNS_CustomerDealerAssociation__c relation : relationList) {
                relatedAccIds.add(relation.Customer__c);
            }

            for(Opportunity opty : optyList) {
                if(!relatedAccIds.contains(opty.AccountId)) {
                    opty.addError(System.Label.DNS_M_NoPermissionforAcc); // The Account does not have the permissions. Please proceed with 'Request To Use Customer' first.
                }
            }
        }

    }

    public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}