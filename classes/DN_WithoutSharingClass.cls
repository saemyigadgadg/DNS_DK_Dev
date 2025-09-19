/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-14   yuhyun.park@sbtglobal.com   Initial Version
 * 1.0   2024-07-05   Hanyeong Choi               getAccMap() Account 쿼리 IsBVC__c 추가
**/
public without sharing class DN_WithoutSharingClass {
    private static final Id   prospectCustomerRT  = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id   tradeCustomerRT     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();

    private static DN_WithoutSharingClass instance = null;
    private DN_WithoutSharingClass(){}
    

    /**
     * 싱글톤 인스턴스를 반환합니다.
     */
    public static DN_WithoutSharingClass getInstance(){
        if(instance == null){
            instance = new DN_WithoutSharingClass();
        }
        return instance;
    }

    /*
     * @Description
     *  - CRM 고객 Account 대상 중복 고객 체크
    * 
     * @Parameter
     *  - accountName       : 고객 이름
     *  - representative    : 대표자 이름
     */ 
    public boolean isDuplicatedAccount(String accountName, String representative){
        System.debug('[isDuplicatedAccount] accountName & representative ::: ' +  accountName + '&' + representative);
        List<Account> accountList = [
            SELECT Id
                    , Name
                    , CustomerCode__c
                    , CRM_CustomerCode__c 
            FROM Account 
            WHERE Name = :accountName 
                AND Representative__c = :representative 
                AND RecordType.Name != 'Dealer'
                LIMIT 1];
        System.debug('[isDuplicatedAccount] isDuaccountList.size() ::: ' +  accountList.size());
        if(accountList.size() == 1) {
            return true;
        }
        return false;
    }

    /*
     * @Description
     *  - 영업 포탈 고객 생성 시 Account 대상 중복 고객 체크 및 보호고객 여부
     *  - 25/01/02 AND 조건에서 OR 조건으로 변경 (이주현)
    * 
     * @Parameter
     *  - accountName       : 고객 이름
     *  - representative    : 대표자 이름
     */ 
    public static List<Account> isAccountbyPortal(String accountName, String representative, String searchBusiness) {
        List<SObject> returnObjectList = new List<SObject>();
        String strSql = ' SELECT Id, Name, CustomerCode__c, Representative__c, CreatedDate, CRM_CustomerCode__c , IsBVC__c, RecordType.Name, RecordTypeId FROM Account ';
        // strSql += '\n     WHERE  Name = :accountName';
        if (String.isNotBlank(accountName)) {
        strSql += '\n     WHERE Name LIKE \'%' + accountName + '%\'';

            if (String.isNotBlank(representative)) {
                strSql += '\n   AND (Representative__c = :representative) ';
            }
    
            if (String.isNotBlank(searchBusiness)) {
                strSql += '\n   AND (BusinessNumberDuplCheck__c = :searchBusiness) ';
            }
            strSql += '\n     AND RecordTypeId IN (:prospectCustomerRT, :tradeCustomerRT) ';
            strSql += '\n     AND SalesOrganization__c = \'1800\' ';
        } else {
            if (String.isNotBlank(representative)) {
                strSql += '\n   WHERE Representative__c = :representative ';
                if (String.isNotBlank(searchBusiness)) {
                    strSql += '\n   AND (BusinessNumberDuplCheck__c = :searchBusiness) ';
                }
                strSql += '\n     AND RecordTypeId IN (:prospectCustomerRT, :tradeCustomerRT) ';
                strSql += '\n     AND SalesOrganization__c = \'1800\' ';
            } else if(String.isNotBlank(searchBusiness)) {
                strSql += '\n   WHERE BusinessNumberDuplCheck__c = :searchBusiness ';
        strSql += '\n     AND RecordTypeId IN (:prospectCustomerRT, :tradeCustomerRT) ';
                strSql += '\n     AND SalesOrganization__c = \'1800\' ';
            }
        }
        strSql += '\n     ORDER BY CreatedDate DESC LIMIT 200';
        System.debug(strSql);
        List<Account> accountList =  Database.query(strSql);

        return accountList;
    }

    /*
     * @Description
     *  - DNS_RequestToUseCustomer (고객사용요청) 생성/수정 시, Account에서 값 조회
     *  - Account에서 값 조회 (IsBVC__c 추가) | Hanyeong Choi
     * @Parameter
     *  - accNameSet        : 고객 이름
     *  - repNameSet        : 대표자 이름
     */ 
    public static Map<String, Account> getAccMap(Set<String> accNameSet, Set<String> repNameSet){
        Map<String, Account> accMap = new Map<String, Account>();

        if (accNameSet.isEmpty() || repNameSet.isEmpty()) {
            return accMap;
        }

        List<Account> accList = [
            SELECT Id
                    , Name
                    , Representative__c
                    , CustomerCode__c
                    , CRM_CustomerCode__c
                    , IsBVC__c
            FROM Account 
            WHERE Name IN :accNameSet 
            AND Representative__c IN :repNameSet
        ];

        for(Account acc : accList){
            String accKey = acc.Name + '|' + acc.Representative__c;
            accMap.put(accKey, acc);
        }
        return accMap;
    }

    /**
     * @Description
     *  - Account에 이미 같은 사업자번호가 있는지 조회
     * @author Hanyeong Choi | 07-05-2024
     * @Parameter
     *  - businessNumber    : Account 사업자번호
    **/ 
    public static Boolean checkBusinessNumberDuplicate(String businessNumber) {
        List<Account> accList = [
                SELECT Id
                FROM Account
                WHERE BusinessNumberDuplCheck__c = :businessNumber
            ];
            System.debug('accList ::: ' + accList);

            if(accList.size() > 1) {
                return true;
            } else {
                return false;
            }
    }


    /**
     * 사업자 번호 리스트를 받아 중복된 Account의 사업자 번호를 반환합니다.
     */
    public static List<String> checkBusinessNumberDuplicateList(List<String> businessNumbers) {
        List<String> bsNumList = new List<String>();
        List<Account> accList = [
            SELECT Id, BusinessNumber__c, BusinessNumberDuplCheck__c
            FROM Account
            WHERE BusinessNumberDuplCheck__c IN :businessNumbers
        ];

        if(!accList.isEmpty()) {
            for(Account acc : accList) {
                bsNumList.add(acc.BusinessNumberDuplCheck__c);
            }
        }
        return bsNumList;
    }

    /**
     * @Description
     *  - User 기반으로 연결된 Contact 정보
     * @author Hanyeong Choi | 07-09-2024
     * @Parameter
     *  - accId     : Account record Id
    **/ 
    public static List<User> getDealerInfo(Set<Id> accIds) {
        List<User> userList = [
            SELECT Id
                    , Name
                    , Contact.Name
                    , Contact.Email
                    , Contact.MobilePhone
                    , Contact.Position__c
                    , Contact.Role__c
                    , AccountId
                    , Account.Name
                    , Account.Representative__c
                    , UserRole.PortalRole
            FROM User
            WHERE AccountId IN :accIds
            AND UserRole.PortalRole = 'Manager'
            AND isActive = true
            ORDER BY Name
        ];

        System.debug('userList :: ' + userList);
        
        return userList;

        
    }

    /**
     * @Description
     *  - Contact 기반, DNS direct 기반의 User 정보
     * @author Hanyeong Choi | 07-25-2024
     * @Parameter
     *  - dealerContactIds      : Contact Id Set
     *  - dnsDirectIds          : DNS Direct User Id Set
    **/ 
    public static List<User> sharingSetting_getDealerInfo(Set<Id> dealerContactIds, Set<Id> dnsDirectIds) {
        List<User> userList = new List<User>();

        if(dnsDirectIds == null || dnsDirectIds.isEmpty()) {
            userList = [
                SELECT Id
                        , Name
                        , UserRoleId
                        , AccountId
                        , Account.Name
                        , Account.Representative__c
                FROM User
                WHERE ContactId IN :dealerContactIds
                AND IsActive = true
            ];
        } else {
            userList = [
                SELECT Id
                        , Name
                        , UserRoleId
                        , AccountId
                        , Account.Name
                        , Account.Representative__c
                        , ContactId
                FROM User
                WHERE Id IN :dnsDirectIds
                AND IsActive = true
            ];
        }
        
        if(!userList.isEmpty()) {
            return userList;
        } else {
            return null;
        }
    }

    /**
     * @Description
     *  - Insert Account Sharing
     * @author Hanyeong Choi | 07-25-2024
     * @Parameter
     *  - accShrList        : AccountShare List
    **/
    public static void insertAccShrList(List<AccountShare>  accShrList) {
        if(!accShrList.isEmpty()) {
            insert accShrList;
        }
        return;
    }

    /**
     * @Description
     *  - Delete Account Sharing
     * @author Hanyeong Choi | 07-25-2024
     * @Parameter
     *  - accShrList        : AccountShare List
    **/
    public static void deleteAccShrList(List<AccountShare>  accShrList) {
        if(!accShrList.isEmpty()) {
            delete accShrList;
        }
        return;
    }

    /**
     * 사업자 번호로 Account 중복 여부를 확인합니다.
     */
    public static String searchDupl(String search) {
        List<Account> accBusinessList = [
            SELECT  Id
                    , BusinessNumberDuplCheck__c 
            FROM Account 
            WHERE BusinessNumberDuplCheck__c = :search
        ];
        
        if(!accBusinessList.isEmpty()) {
            return 'dupl';
        } else {
            return 'notdupl';
        }
    }

    /**
     * 키워드를 기반으로 Account를 검색하여 SearchWrapper 리스트로 반환합니다.
     */
    public static List<DN_AccountLayoutController.SearchWrapper> searchAccount(String keyword) {
        Id currentUserId = UserInfo.getUserId();
        Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        List<Account> accList = [
            SELECT  Id
                    , Name
                    , Representative__c
                    , RecordType.Name
                    , FM_Address__c
                    , Owner.Name
                    , IsBVC__c
            FROM Account
            WHERE Name LIKE :keyword
            AND (RecordTypeId = :prospectCustomerRT
            OR RecordTypeId = :tradeCustomerRT)
            AND SalesOrganization__c = '1800'
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
        
        List<DN_AccountLayoutController.SearchWrapper> swList = new List<DN_AccountLayoutController.SearchWrapper>();
        if(!accList.isEmpty()) {
            for(Account acc : accList) {
                if(!acc.Name.contains('삭제')) {
                    DN_AccountLayoutController.SearchWrapper sw = new DN_AccountLayoutController.SearchWrapper();
                    sw.accId            = acc.Id;
                    sw.accName          = acc.Name;
                    sw.representative   = acc.Representative__c;
                    sw.recordTypeName   = acc.RecordType.Name;
                    sw.address          = acc.FM_Address__c;
                    sw.accOwner         = acc.Owner.Name;
                    sw.isBVC            = acc.IsBVC__c;
                    swList.add(sw);
                }
            }
        }
        return swList;
    }

    /**
     * AccountShare 정보를 조회합니다.
     */
    public static List<AccountShare> searchAccShare(String recordId, User currentUser) {
        return [
            SELECT  Id
                    , AccountId
                    , UserOrGroupId
            FROM AccountShare
            WHERE AccountId = :recordId
            AND UserOrGroupId = :currentUser.Id
        ];
    }

    /**
     * Account의 소유자 ID를 조회합니다.
     */
    public static String searchAccOwner(String recordId) {
        System.debug('recordId ::: ' + recordId);
        Account acc =  [
            SELECT  Id
                    , OwnerId
            FROM Account
            WHERE Id = :recordId
            LIMIT 1
        ];
        return acc.OwnerId;
    }

    /**
     * @Description
     *  - Update Portal Service Report to Asset
     * @author Chungwoo Lee | 12-18-2024
     * @Parameter
     *  - accShrList        : AccountShare List
    **/
    public static void withoutUpdateAsset(Asset assetData) {
        System.debug('assetData ::: ' + assetData);
        if(assetData != null) {
            update assetData;
        }
        return;
    }

    /**
     * @Description
     *  - Portal 서비스 이력 조회 (영업포탈) List
     * @author Chungwoo Lee | 12-20-2024
    **/
    public static List<WorkOrder> withoutSearchWorkOrder(String queryString) {
        List<WorkOrder> serviceHistoryList = new List<WorkOrder>();
        System.debug('queryString ::: ' + queryString);
        return serviceHistoryList = Database.query(queryString);
    }

    /**
     * @Description
     *  - Update Portal Service Report to Case
     * @author Chungwoo Lee | 01-10-2025
    **/
    public static void withoutUpdateCase(Case caseData) {
        System.debug('caseData ::: ' + caseData);
        if(caseData != null) {
            update caseData;
        }
        return;
    }

    /**
     * @Description
     *  - Portal 서비스 리포트 저장 시 작업 내역 삭제
     * @author Chungwoo Lee | 01-10-2025
    **/
    public static void withoutDeleteWorkOrderResult(List<WorkOrderResult__c> worList) {
        if(worList != null) {
            delete worList;
        }
        return;
    }

    /**
     * @Description
     *  - Portal 서비스 리포트 저장 시 작업 내역 기반 SA 업데이트
     * @author Chungwoo Lee | 01-10-2025
    **/
    public static void withoutUpdateSA(List<ServiceAppointment> appointmentsToUpdate) {
        if(appointmentsToUpdate != null) {
            update appointmentsToUpdate;
        }
        return;
    }

    /**
     * @Description
     *  - 딜러포털에서 판매처 리스트 조회
     * @author KYJUNG | 01.23.2025
    **/
    public static Map<String, Account> withoutSearchSeller(String queryString) {
        Map<String, Account> sellerMap = new Map<String, Account>();
        System.debug('queryString 판매처 ::: ' + queryString);
        for(Account acc : Database.query(queryString)){
            sellerMap.put(acc.CustomerCode__c , acc);
        }
        return sellerMap;
    }


    /**
     * QuoteLineItem 레코드를 삭제합니다.
     */
    public static void deleteQuoteLineItems(List<QuoteLineItem> qlis) {
        delete qlis;
        return;
    }

    /**
     * Accessory 레코드를 삭제합니다.
     */
    public static void deleteAccessories(List<Accessory__c> accs) {
        delete accs;
        return;
    }

    /**
     * Order 레코드를 삭제합니다.
     */
    public static void deleteOrders(List<Order> orders) {
        delete orders;
        return;
    }

    /**
     * SQ Review 레코드를 삭제합니다.
     */
    public static void deleteSQReview(List<SQReview__c> reviews) {
        delete reviews;
        return;
    }

    /**
     * SQ 레코드를 삭제합니다.
     */
    public static void deleteSQ(List<SQ__c> sq) {
        delete sq;
        return;
    }

    /**
     * QuoteLineItem 레코드를 업데이트합니다.
     */
    public static void updateQli(List<QuoteLineItem> qli) {
        update qli;
        return;
    }

    /**
     *  SQ_QuoteLineitem_Junction__c 레코드를 생성합니다.
     */
    public static void insertSqlj(List<SQ_QuoteLineitem_Junction__c> sqlj) {
        insert sqlj;
        return;
    }

    /**
     *  SQ_QuoteLineitem_Junction__c 레코드를 수정합니다.
     */
    public static void updateSqlj(List<SQ_QuoteLineitem_Junction__c> sqlj) {
        update sqlj;
        return;
    }

    /**
     *  SQ_QuoteLineitem_Junction__c 레코드를 삭제합니다.
     */
    public static void deleteSqlj(List<SQ_QuoteLineitem_Junction__c> sqlj) {
        delete sqlj;
        return;
    }

    /**
     *  SQ 레코드를 수정합니다.
     */
    public static void updateSQ(List<SQ__c> sq) {
        update sq;
        return;
    }

    /**
     * 사용자 ID를 기반으로 사용자 정보를 조회합니다.
     */
    public static User getUserEmail(String userId) {
        List<User> u = [SELECT Id, Email, LanguageLocaleKey, SalesOffice__c, Manager.Id, Manager.Email, Profile.Name, ManagerId, Account.CustomerCode__c, IsPortalEnabled, MobilePhone FROM User WHERE Id = :userId AND IsActive = true LIMIT 1];
        return u[0];
    }

    /**
     * 사용자 ID 집합을 기반으로 사용자 정보를 조회합니다.
     */
    public static List<User> getUserEmails(Set<Id> userIds) {
        List<User> u = [SELECT Id, Email, LanguageLocaleKey, IsPortalEnabled, SalesOffice__c,ManagerId, Manager.Id, Manager.Email, Profile.Name, internal_approver__r.Id, internal_approver__r.Email, LastName, IsActive FROM User WHERE Id IN :userIds AND IsActive = true];
        return u;
    }

    /**
     * 직원 번호를 기반으로 사용자 정보를 조회합니다.
     */
    public static List<User> getEmployeeEmails(Set<String> empls) {
        List<User> u = [SELECT Id, Email, LanguageLocaleKey, SalesOffice__c, Manager.Id, Manager.Email, Profile.Name, internal_approver__r.Id, internal_approver__r.Email, LastName, Portal_EmployeeNumber__c FROM User WHERE Portal_EmployeeNumber__c IN :empls AND IsActive = true];
        return u;
    }

    /**
     * 프로필 이름을 기반으로 사용자 정보를 조회합니다.
     */
    public static List<User> getProfileUser(String profileName) {
        List<User> u = [SELECT Id, Email, LanguageLocaleKey, SalesOffice__c FROM User WHERE Profile.Name = :profileName AND IsActive = true];
        return u;
    }

    /**
     * DNS_RequestToUseCustomer__c 레코드를 삽입합니다.
     */
    public static String insertRQU(DNS_RequestToUseCustomer__c req) {
        try {
            insert req;
            return 'success';
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            return e.getLineNumber() + ' / ' + e.getMessage();
        }
    }

    /**
     * Account ID를 기반으로 Account의 CustomerCode__c를 조회합니다.
     */
    public static List<Account> getAccountCustomerCode(String AccountId){
        List<Account> u = [SELECT CustomerCode__c FROM Account WHERE Id =:AccountId];
        return u;
    }

    /**
     * RequestedSQ__c 레코드를 삽입합니다.
     */
    public static void insertReq(RequestedSQ__c req) {
        insert req;
        return;
    }

    /**
     * AccountTeamMember 레코드를 삽입합니다.
     */
    public static void insertAccountTeamMember(List<AccountTeamMember> atList) {
        insert atList;
        return;
    }

    /**
     * 재고 번호를 기반으로 QuoteLineItem 레코드를 조회합니다.
     */
    public static List<QuoteLineItem> queryQuoteLineItems(String stockNumber) {
        // return [SELECT Id, QuoteId, StockResSO__c, Quote.Waiting_Seq__c, CreatedById FROM QuoteLineItem WHERE StockResSO__c = :stockNumber AND Quote.Waiting_Seq__c != '1'];
        return [SELECT Id, QuoteId, StockResSO__c, Quote.Waiting_Seq__c, CreatedById FROM QuoteLineItem WHERE StockResSO__c = :stockNumber];
    }

    /**
     * 재고 번호 집합을 기반으로 QuoteLineItem 레코드를 조회합니다.
     */
    public static List<QuoteLineItem> queryQuoteLineItemsSet(Set<String> stockNumber) {
        // return [SELECT Id, QuoteId, StockResSO__c, Quote.Waiting_Seq__c, CreatedById FROM QuoteLineItem WHERE StockResSO__c = :stockNumber AND Quote.Waiting_Seq__c != '1'];
        return [SELECT Id, QuoteId, StockResSO__c, Quote.Waiting_Seq__c, CreatedById FROM QuoteLineItem WHERE StockResSO__c IN :stockNumber];
    }

    /**
     * Quote ID 집합을 기반으로 QuoteLineItem 레코드를 조회합니다.
     */
    public static List<QuoteLineItem> queryQuoteLineItemsQuoteIds(Set<Id> quoteIds) {
        // return [SELECT Id, QuoteId, StockResSO__c, Quote.Waiting_Seq__c, CreatedById FROM QuoteLineItem WHERE StockResSO__c = :stockNumber AND Quote.Waiting_Seq__c != '1'];
        return [SELECT Id, QuoteId, StockResSO__c, Quote.Waiting_Seq__c, CreatedById FROM QuoteLineItem WHERE QuoteId IN :quoteIds];
    }

    /**
     * Quote ID 집합을 기반으로 Quote 레코드를 조회합니다.
     */
    public static List<Quote> queryQuotes(Set<Id> quoteIds) {
        return [SELECT Id, Waiting_Seq__c, IsBooking__c, ReserveExpirationDate__c, StockResSO__c FROM Quote WHERE Id IN :quoteIds];
    }

    /**
     * Quote 레코드를 업데이트합니다.
     */
    public static void updateQuotes(List<Quote> quoteList) {
        update quoteList;
        return;
    }

    /**
     * 단일 Quote 레코드를 업데이트합니다.
     */
    public static void updateQuote(Quote quote) {
        update quote;
        return;
    }

    /**
     * OrderItem 레코드를 업데이트합니다.
     */
    public static void updateOrderItems(List<OrderItem> ois) {
        update ois;
        return;
    }

    /**
     * PS__c 객체의 최대 Inquiry_Seq2__c 값을 조회하고 다음 값을 반환합니다.
     */
    public static Decimal getInquirySeq2() {
        List<AggregateResult> inquirySeqList = [SELECT MAX(Inquiry_Seq2__c) Inquiry_Seq2__c FROM PS__c];
        return (Decimal)inquirySeqList[0].get('Inquiry_Seq2__c') + 1;

    }

    /**
     * T_COND_ELMT__c 레코드를 삭제합니다.
     */
    public static void deleteTCONDELMT(List<T_COND_ELMT__c> tceList) {
        delete tceList;
        return;
    }

    /**
     * Opportunity 레코드를 업데이트합니다.
     */
    public static void updateOppty(Opportunity oppty) {
        update oppty;
        return;
    }

    /**
     * @description Account의 HasOrder__c 필드를 업데이트 
     * - Insert : 새 Order로 인해 해당 Account가 주문을 가진 경우 true
     * - Update/Delete : 해당 Account에 연결된 Order 개수를 집계하여, 0보다 크면 true, 아니면 false로 업데이트
     * @param accountIds   : 대상 Account ID 집합
     * @param operation    : 'insert', 'update', 'delete'
     */
    public static void updateAccountHasOrder(Set<Id> accountIds, String operation) {
        if(accountIds == null || accountIds.isEmpty()) {
            return;
        }
        List<Account> accountsToUpdate = new List<Account>();
        // Account의 현재 HasOrder__c 값을 가져옴
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, HasOrder__c FROM Account WHERE Id IN :accountIds]);
        if(operation == 'insert') {
            // Insert 시 : 새로 생성된 Order가 있으므로, 해당 Account의 HasOrder__c를 true로 설정 (이미 true이면 변경 없음)
            for(Account acc : accMap.values()) {
                if(acc.HasOrder__c != true) {
                    acc.HasOrder__c = true;
                    accountsToUpdate.add(acc);
                }
            }
        } else if(operation == 'update' || operation == 'delete') {

            // Update/Delete 시 : 해당 Account에 연결된 Order 개수를 집계하여 업데이트
            // Aggregate Query를 통해 각 Account별 Order 개수를 가져옴
            Map<Id, Integer> orderCountMap = new Map<Id, Integer>();
            for(AggregateResult ar : [SELECT AccountId accId, COUNT(Id) cnt FROM Order WHERE AccountId IN :accountIds GROUP BY AccountId]) {
                orderCountMap.put((Id) ar.get('accId'), Integer.valueOf(ar.get('cnt')));
            }
            for(Account acc : accMap.values()) {
                Boolean shouldHaveOrder = orderCountMap.containsKey(acc.Id) && orderCountMap.get(acc.Id) > 0;
                if(acc.HasOrder__c != shouldHaveOrder) {
                    acc.HasOrder__c = shouldHaveOrder;
                    accountsToUpdate.add(acc);
                }
            }
        }

        TriggerHandler.bypass('AccountTriggerHandler');
        Database.SaveResult[] results = Database.update(accountsToUpdate, false);
        
        List<TriggerExceptionLog__c> exLogs = new List<TriggerExceptionLog__c>();

        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                Account failedAcc = accountsToUpdate[i];
                for (Database.Error err : results[i].getErrors()) {
                    TriggerExceptionLog__c exLog = new TriggerExceptionLog__c();
                    exLog.Message__c               = 'OrderTriggerHandler(updateAccountHasOrder) : ' + err.getMessage() + ' & Failed Account Id : ' + failedAcc.Id;
                    exLog.ExceptionType__c         = String.valueOf(err.getStatusCode());
                    exLogs.add(exLog);
                }
            }
        }
        
        if (!exLogs.isEmpty()) {
            insert exLogs;
        }

        TriggerHandler.clearBypass('AccountTriggerHandler');
    }


    /**
     * @Description
     *  - Account에 관련된 Account Team Member List 조회
     * @author Yuhyun Park | 2025-05-29
     * @Parameter
     *  - recordId    : AccountTeamMember Id
    **/
    @AuraEnabled
    public static List<AccountTeamMember> getTeamMemberList(String recordId) {
        System.debug('getTeamMemberList in without');
            return [
                SELECT  Id,
                        UserId,
                        User.Name,
                        User.SmallPhotoUrl,
                        User.Email
                FROM    AccountTeamMember
                WHERE   Id = :recordId
        ];
    }


    /**
     * @Description
     *  - 전달받은 Account Team Member List 삭제
     * @author Yuhyun Park | 2025-05-29
     * @Parameter
     *  - recordId        : Account Team Member Id
    **/
    @AuraEnabled
    public static String deleteTeamMembers(String recordId) {
        System.debug('deleteTeamMembers in without');
        if (recordId == null ) return '';

        AccountTeamMember toDel = [
            SELECT Id, AccountId FROM AccountTeamMember WHERE Id = :recordId LIMIT 1
        ];

        String accId = todel.AccountId;

        delete toDel;
        return accId;
    }

}