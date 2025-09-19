/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   10-31-2024   Hanyeong Choi   Initial Version
**/
public with sharing class DN_SQController {
    private static final Id   koreaRT   = SObjectType.SQRegistration__c.getRecordTypeInfosByDeveloperName().get('SQ').getRecordTypeId();
    private static final Id   globalRT  = SObjectType.SQRegistration__c.getRecordTypeInfosByDeveloperName().get('GlobalSQ').getRecordTypeId();
    private static final Id   dnsaRT    = SObjectType.SQRegistration__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
    private static final User currentUser = setCurrentUser();

    /**
     * 현재 사용자 정보를 설정합니다.
     */
    private static User setCurrentUser() {
        return [SELECT Id, Profile.Name, Email, AccountId, UserRole.DeveloperName, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    /* ***************************************************************************** SQ Registration Create Modal ***************************************************************************** */
    /* **************************************************************************************************************************************************************************************** */

    /**
     * @Description
     * 	- SQ Registration 생성 화면 진입시, SQ Registration의 Field Set 데이터 get
     * @author Hanyeong Choi | 10-31-2024
     * @Parameter
     *
    **/ 
    @AuraEnabled
    public static Map<String, Object> getInit(String recordId, String lineItemId, String objectName) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('initDatas',             getFieldSetDatas(objectName));
            resMap.put('getCategoryPicklist',   getCategoryPicklist());
            resMap.put('getProductModel',       getProductModel(lineItemId));
            resMap.put('getDefaultField',       getDefaultField(recordId));
            resMap.put('getRecordTypeId',       getRecordTypeId(recordId));

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Quote 레코드 타입에 따라 SQ Registration 레코드 타입 ID를 반환합니다.
     */
    private static Id getRecordTypeId(String recordId) {
        Quote quote = [SELECT Id, RecordType.Name FROM Quote WHERE Id = :recordId LIMIT 1];
        if(quote.RecordType.Name == 'Korea') {
            return koreaRT;
        } else if(quote.RecordType.Name == 'Global') {
            return globalRT;
        } else if(quote.RecordType.Name == 'Service') {
            return koreaRT;
        } else {
            return dnsaRT;
        }
    }

    /**
     * SQ Registration의 기본 필드 값을 설정합니다.
     */
    private static Map<String, String> getDefaultField(String recordId) {
        Map<String, String> resMap = new Map<String, String>();
        resMap.put('globalGroupId', null);
        User user = [SELECT LanguageLocaleKey, AccountId, Account.CountryLookup__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Quote quote = [SELECT Id, AccountId, OpportunityId, CurrencyIsoCode, RecordType.DeveloperName, Account.CountryLookup__c FROM Quote WHERE Id = :recordId LIMIT 1];
        List<MessageGroup__c> mg = [SELECT Id FROM MessageGroup__c WHERE Name LIKE '%영업지원%' LIMIT 1];
        List<MessageGroup__c> globalMg = [SELECT Id FROM MessageGroup__c WHERE Country__c = :quote.Account.CountryLookup__c LIMIT 1]; //250812_이원정 추가
        // if(user.AccountId != null) { //250812_이원정 주석
        //     List<MessageGroup__c> globalMg = [SELECT Id FROM MessageGroup__c WHERE Country__c = :user.Account.CountryLookup__c AND Country__r.CountryCode__c != 'KR' LIMIT 1];
        //     if(!globalMg.isEmpty()) resMap.put('globalGroupId', globalMg[0].Id);
        // }
        
        if(quote.RecordType.DeveloperName == 'Korea'){//250812_이원정 추가
            if(!mg.isEmpty()) resMap.put('groupId', mg[0].Id);
        }else{
            if(!globalMg.isEmpty()) resMap.put('globalGroupId', globalMg[0].Id);
        }
       
        resMap.put('Account',     quote.AccountId);
        resMap.put('Opportunity', quote.OpportunityId);
        resMap.put('Stage',       'Request');
        resMap.put('CurrencyIsoCode', quote.CurrencyIsoCode);
        resMap.put('RecordTypeName', quote.RecordType.DeveloperName);
        resMap.put('language', user.LanguageLocaleKey);
        // if(!mg.isEmpty()) resMap.put('groupId', mg[0].Id);
 
        System.debug('@@ resMap : ' + resMap);
        return resMap;
    }

    /**
     * 현재 사용자 정보를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> getFieldInfo(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getCurrentUser', getCurrentUser());

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- SQ Registration 생성
     * @author Hanyeong Choi | 10-31-2024
     * @Parameter
     * - recordId       : Quote Id
    **/ 
    @AuraEnabled
    public static Map<String, String> insertSQRegistration(String recordId, String lineItemList, String requestedSQ, List<Map<String, String>> searchDatas, String sqrId) {
        Map<String, String> resMap = new Map<String, String>();
        
        try {
            List<DN_QuoteLineItemsController.QuoteLineItemWrapper> qliWrappers = new List<DN_QuoteLineItemsController.QuoteLineItemWrapper>();
            qliWrappers = (List<DN_QuoteLineItemsController.QuoteLineItemWrapper>) JSON.deserialize(lineItemList, List<DN_QuoteLineItemsController.QuoteLineItemWrapper>.class);
            List<Id> lineItemIds = new List<Id>();

            Boolean allSalesSQExistsAndRndSQNull = false;
            List<RequestedSQWrapper> reqSQs = new List<RequestedSQWrapper>();
            System.debug('@@ requestedSQ : ' + requestedSQ);
            if(requestedSQ != 'null') {
                reqSQs = (List<RequestedSQWrapper>) JSON.deserialize(requestedSQ, List<RequestedSQWrapper>.class);
                allSalesSQExistsAndRndSQNull = true;
            }

            System.debug('@@ reqSQs : ' + reqSQs);

            for (RequestedSQWrapper rw : reqSQs) {
                System.debug('@@ rw.salesSQ : ' + rw.salesSQ);
                if (rw.salesSQ == null || rw.salesSQ == '') {
                    allSalesSQExistsAndRndSQNull = false;
                    break;
                }
            }

            for(DN_QuoteLineItemsController.QuoteLineItemWrapper qliWrapper : qliWrappers) {
                lineItemIds.add(qliWrapper.Id);
            }

            Quote quote = [ SELECT  Id , AccountId , OpportunityId , CurrencyIsoCode
                            FROM Quote 
                            WHERE Id = :recordId  LIMIT 1 ];

            QuoteLineItem qli = [ SELECT  Id , Product2Id , Product2.Model__r.Name
                                  FROM QuoteLineItem
                                  WHERE Id = :lineItemIds[0] LIMIT 1 ] ;

            SQRegistration__c sqReg = [SELECT Id, Name, Stage__c, Message_Group__c, OwnerId FROM SQRegistration__c WHERE Id = :sqrId LIMIT 1];
            List<Message_Group_Junction__c> mgjList = [SELECT User__c, FM_UserEmail__c, FM_UserProfile__c, FM_UserLanguage__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqReg.Message_Group__c AND User__r.IsActive = true];

            if(!reqSQs.isEmpty()) {
                insertRequestedSQ(sqrId, reqSQs, quote);
            }
            insertSQRegQuoteJunction(quote.Id, sqrId);
            insertSQRegJunction(sqrId, lineItemIds);
            if(!searchDatas.isEmpty()) {
                insertSearchHistory(sqrId, searchDatas);
            }

            System.debug('@@ allSalesSQExistsAndRndSQNull : ' + allSalesSQExistsAndRndSQNull);
            if(!allSalesSQExistsAndRndSQNull) {
                sendCreateSQRegistrationNotification(sqReg, mgjList);
                // sendCreateSQRegistrationEmail(sqReg, mgjList);
            } else {
                allSalseSQProcess(sqReg);
            }

            resMap.put('flag', 'success');

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    /**
     * 모든 Sales SQ가 존재하고 R&D SQ가 없을 경우 프로세스를 처리합니다.
     */
    private static void allSalseSQProcess(SQRegistration__c sqReg) {
        String result = cloneSQ(sqReg.Id, 'false');
        if(result == 'success') {
            sqReg.Stage__c = 'Final Confirm';
            update sqReg;
        }
    }

    /**
     * 카테고리 변경 시 설명을 업데이트합니다.
     */
    @AuraEnabled
    public static String changeCategory(String category, String selectedLabel, String language) {
        try {
            if (String.isEmpty(category)) {
                return 'fail';
            }

            if(category != '입회검사' && category != '기타') {
                List<SQ_Template__c> stList = new List<SQ_Template__c>();
                if(language == 'ko') {
                    stList = [
                        SELECT Id, Name, Description__c
                        FROM SQ_Template__c
                        WHERE Name = :category
                        LIMIT 1
                    ];

                } else {
                    stList = [
                        SELECT Id, Name, Description__c
                        FROM SQ_Template__c
                        WHERE Name = :selectedLabel
                        LIMIT 1
                    ];
                }

                if (!stList.isEmpty()) {
                    return stList[0].Description__c;
                } else {
                    return 'fail';
                }
            } else {
                return '';
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 검색 이력을 삽입합니다.
     */
    private static void insertSearchHistory(String recordId, List<Map<String, String>> searchDatas) {
        SQRegistration__c sqr = [
            SELECT  Id
                    , IsSearch__c
            FROM SQRegistration__c
            WHERE Id = :recordId
        ];

        List<SQ_SearchHistory__c> historyList = new List<SQ_SearchHistory__c>();
        for(Map<String, String> data : searchDatas) {
            SQ_SearchHistory__c searchHistory = new SQ_SearchHistory__c();
            searchHistory.SQRegistration__c = recordId;
            searchHistory.Keyword__c = data.get('keyword') != null && data.get('keyword') != '' ? data.get('keyword') : '';
            searchHistory.Model__c = data.get('model') != null && data.get('model') != '' ? data.get('model') : '';
            historyList.add(searchHistory);
        }
        insert historyList;

        sqr.IsSearch__c = true;
        sqr.Stage__c = 'Sales Review';
        update sqr;
        return;
    }

    /**
     * SQ Registration 생성 이메일 알림을 전송합니다.
     */
    private static void sendCreateSQRegistrationEmail(SQRegistration__c sqReg, List<Message_Group_Junction__c> mgjList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();

        User owner = DN_WithoutSharingClass.getUserEmail(sqReg.OwnerId);
        List<User> userList = DN_WithoutSharingClass.getProfileUser('영업 지사장');

        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.FM_UserEmail__c);
            } else {
                receiverEN.add(mgj.FM_UserEmail__c);
            }
        }
        if(!userList.isEmpty()) {
            for(User user : userList) {
                if(user.SalesOffice__c == owner.SalesOffice__c) {
                    if(user.LanguageLocaleKey == 'ko') {
                        receiver.add(user.Email);
                    } else {
                        receiverEN.add(user.Email);
                    }
                }
            }
        }

        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Registration Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Email';
                history.elementList.add(sqReg.Name);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforEmail   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }
            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Email';
                history.elementList.add(sqReg.Name);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforEmail   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }

            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * SQ Registration 생성 알림을 전송합니다.
     */
    private static void sendCreateSQRegistrationNotification(SQRegistration__c sqReg, List<Message_Group_Junction__c> mgjList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        User owner = DN_WithoutSharingClass.getUserEmail(sqReg.OwnerId);
        List<User> userList = DN_WithoutSharingClass.getProfileUser('영업 지사장');

        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.User__c);
            } else {
                receiverEN.add(mgj.User__c);
            }
        }
        if(!userList.isEmpty()) {
            for(User user : userList) {
                if(user.SalesOffice__c == owner.SalesOffice__c) {
                    if(user.LanguageLocaleKey == 'ko') {
                        receiver.add(user.Id);
                    } else {
                        receiverEN.add(user.Id);
                    }
                }
            }
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Registration Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(sqReg.Name);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforID   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }
            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(sqReg.Name);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforID   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 현재 사용자 정보를 가져옵니다.
     */
    private static User getCurrentUser() {
        return [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    /**
     * 제품 모델 정보를 가져옵니다.
     */
    private static Map<String, String> getProductModel(String lineItemId) {
        Map<String, String> resMap = new Map<String, String>();
        QuoteLineItem qli = [
            SELECT  Id
                    , Product2Id
                    , Product2.Model__c
                    , Product2.Model__r.Name
                    , Product2.ProductCode
            FROM QuoteLineItem
            WHERE Id = :lineItemId
            LIMIT 1
        ];
        resMap.put('id', qli.Product2.Model__c);
        resMap.put('productId', qli.Product2Id);
        resMap.put('name', qli.Product2.Model__r.Name);
        resMap.put('code', qli.Product2.ProductCode);
        return resMap;
    }

    /**
     * 객체의 필드 세트 데이터를 가져옵니다.
     */
    private static List<String> getFieldSetDatas(String objectName) {
        List<String> result = new List<String>();
        for(Schema.FieldSetMember f : getFields(objectName, null)) {
            result.add(f.getFieldPath());
        }
        return result;
    }

    /**
     * 필드 세트 멤버를 가져옵니다.
     */
    private static List<Schema.FieldSetMember> getFields(String objectName, String category) {
        List<Schema.FieldSetMember> result = new List<Schema.FieldSetMember>();
        if(objectName == 'SQRegistration__c') {
            result = SObjectType.SQRegistration__c.FieldSets.SQ_Registration_Layout.getFields();
        } else if(objectName == 'RequestedSQ__c') {
            if(category != '입회검사') {
                result = SObjectType.RequestedSQ__c.FieldSets.RequestedSQLayout.getFields();
            }
        }
        return result;
    }

    /**
     * 편집 필드 세트 멤버를 가져옵니다.
     */
    private static List<Schema.FieldSetMember> getEditFields (String objectName) {
        List<Schema.FieldSetMember> result = new List<Schema.FieldSetMember>();
        if(objectName == 'RequestedSQ__c') {
            result = SObjectType.RequestedSQ__c.FieldSets.RequestedSQEditLayout.getFields();
        }
        return result;
    }

    /**
     * 카테고리 픽리스트 값을 가져옵니다.
     */
    private static List<PicklistWrapper> getCategoryPicklist() {
        List<PicklistWrapper> picklistValues        = new List<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult      = Schema.SObjectType.RequestedSQ__c.fields.getMap().get('Category__c').getDescribe();
        List<Schema.PicklistEntry> picklistEntries  = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(new PicklistWrapper(entry.getLabel(), entry.getValue()));
        }
        return picklistValues;
    }

    /**
     * Requested SQ를 삽입합니다.
     */
    private static void insertRequestedSQ(String sqRegId, List<RequestedSQWrapper> reqSQs, Quote quote) {
        List<RequestedSQ__c> reqSQList = new List<RequestedSQ__c>();

        System.debug('@@ insertRequestedSQ reqSQs : ' + reqSQs.size());
        if(!reqSQs.isEmpty()) {
            for(RequestedSQWrapper reqSq : reqSQs) {
                reqSQList.add(new RequestedSQ__c (
                    Name                    = reqSq.sqTitle,
                    Category__c             = reqSq.sqCategory,
                    Description__c          = reqSq.descriptionHtml,
                    SQRegistration__c       = sqRegId,
                    Sales_SQ__c             = reqSq.salesSQ,
                    rndSQ__c                = reqSq.rndSQ,
                    Price__c                = reqSq.price != null ? reqSq.price : 0,
                    DeliveryDate_months__c  = reqSq.month,
                    CurrencyIsoCode         = quote.CurrencyIsoCode,
                    IsInitialRequest__c     = true
                ));
            }
            
            if(!reqSQList.isEmpty()) insert reqSQList;
        }
        return;
    }

    /**
     * SQ Registration과 QuoteLineItem의 Junction을 삽입합니다.
     */
    private static void insertSQRegJunction(String sqRegId, List<String> lineItemIds) {
        List<SQ_Registration_Junction__c> sqRegJunList = new List<SQ_Registration_Junction__c>();
        for(String lineItemId : lineItemIds) {
            sqRegJunList.add(new SQ_Registration_Junction__c(
                SQRegistration__c   = sqRegId,
                QuoteLineItem__c    = lineItemId
            ));
        }
        if(!sqRegJunList.isEmpty()) insert sqRegJunList;
        return;
    }

    /**
     * SQ Registration과 Quote의 Junction을 삽입합니다.
     */
    private static void insertSQRegQuoteJunction(String quoteId, String sqRegId) {
        SQregistration_Quote__c sqRegQuoteJun = new SQregistration_Quote__c();
        sqRegQuoteJun.Quote__c = quoteId;
        sqRegQuoteJun.SQ_Registration__c = sqRegId;
        
        insert sqRegQuoteJun;
        return;
    }

    /* ***************************************************************************** SQ Search Modal ***************************************************************************** */
    /* *************************************************************************************************************************************************************************** */

    /**
     * 검색 버튼 초기화 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> initSearchButton(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            SQRegistration__c sqr = [SELECT Id, Model__c, BaseCode__c, BaseCode__r.ProductCode, RecordType.Name, Stage__c, IsSearch__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            resMap.put('getModel', sqr.Model__c != null ? sqr.Model__c : '');
            resMap.put('getCode', sqr.BaseCode__c != null ? sqr.BaseCode__r.ProductCode : '');
            if(sqr.Stage__c == 'Request' || sqr.Stage__c == 'Sales Review') {
                resMap.put('checkInit', true);
            } else {
                resMap.put('checkInit', false);
            }

            if(sqr.Stage__c == 'Request') {
                sqr.Stage__c = 'Sales Review';
                sqr.IsSearch__c = true;
                update sqr;
            }

            User u = [SELECT Id, Profile.Name, Profile.UserLicense.Name, SalesDistrict__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            resMap.put('getUserDistrict', u.SalesDistrict__c);
            resMap.put('checkGlobal', sqr.RecordType.Name);
            resMap.put('getUserLicense', u.Profile.UserLicense.Name);

            resMap.put('checkQuoteLineItems', checkQuoteLineItems(recordId));

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 글로벌 검색 여부를 확인합니다.
     */
    @AuraEnabled
    public static Boolean initSearchCheckGlobal(String recordId) {
        try {
            Quote quote = [SELECT RecordType.Name FROM Quote WHERE Id = :recordId LIMIT 1];
            if(quote.RecordType.Name == 'Global') {
                return true;
            }
            return false;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 검색 모달 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> initSearchModal(String modelName, String recordId, String productCode) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            User u = [SELECT Id, Profile.Name, Profile.UserLicense.Name, SalesDistrict__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            resMap.put('getInitDatas', getInitDatas(modelName, recordId, productCode));
            resMap.put('getUserDistrict', u.SalesDistrict__c);
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * SQ를 검색합니다.
     */
    @AuraEnabled
    public static List<SearchModalWrapper> searchSQ(String keyword, String modelName, String recordId, String productCode) {
        List<SearchModalWrapper> wrapperList = new List<SearchModalWrapper>();
        if((keyword == '' || keyword == null) && (modelName == '' || modelName == null)) {
            return getInitDatas(modelName, recordId, productCode);
        }
        
        try {
            List<Model__c> mod = new List<Model__c>();
            if(String.isNotBlank(modelName)) {
                mod = [SELECT Id, Code__c FROM Model__c WHERE Name = :modelName LIMIT 1];
            }
            User user = [SELECT Id, Profile.UserLicense.Name, CurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            List<SQRegistration__c> sqr = [SELECT Id, RecordType.Name, CurrencyIsoCode, BaseCode__c, BaseCode__r.ProductCode FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            List<SQ_Pricing__c> prList = [SELECT Id, FM_RegionCode__c, CurrencyIsoCode, Land__c, Rate__c, Markup__c FROM SQ_Pricing__c];
            String product = '';
            String prdCode = '';
            String currencyCode = '';
            Decimal rate = 0;
            Decimal markUp = 0;

            Quote q = new Quote();
            Boolean isSQR = true;
            if(sqr.isEmpty()) {
                q = [SELECT Id, CurrencyIsoCode, RecordType.Name FROM Quote WHERE Id = :recordId LIMIT 1];
                isSQR = false;
                product = productCode;
                prdCode = product.substring(product.length() - 3, product.length() - 2);
                currencyCode = q.CurrencyIsoCode;
            } else {
                product = productCode;
                prdCode = product.substring(product.length() - 3, product.length() - 2);
                currencyCode = sqr[0].CurrencyIsoCode;
            }

            if(prdCode != '') {
                for(SQ_Pricing__c sqp : prList) {
                    if(prdCode == sqp.FM_RegionCode__c && sqp.CurrencyIsoCode == currencyCode) {
                        rate = sqp.Rate__c;
                        markUp = sqp.Markup__c;

                        if(sqp.FM_RegionCode__c == 'X' && sqp.Land__c == 'IN') {
                            rate = 1120;
                            markUp = 0.45;
                        }
                    }
                }
            }

            String  queryString  = 'SELECT Id, Name, Price__c, Description__c, Cost__c, SQ_Type__c, SQ_Registration__c, Category__c, ReviewApprovalDate__c, Delivery_Date_months__c,';
                    queryString += ' listPrice__c, Dealer_Price__c, FM_BaseCode__c, FM_ModelName__c, SQ_Comments__c, IsReview__c FROM SQ__c';
                    queryString += '\n WHERE CurrencyIsoCode = :currencyCode';
                    queryString += '\n AND IsDelete__c = false';
                    queryString += '\n AND IsReview__c = true';
                    queryString += '\n AND (SQ_Type__c != \'Sales SQ\' OR SalesSQ__c = null)';
            if(String.isNotBlank(modelName)) {
                queryString += '\n AND FM_ModelName__c = :modelName';
            }
            queryString += '\n ORDER BY CreatedDate DESC';
            List<SQ__c> reqSq = DataBase.query(queryString);

            List<OrderItem> oiList = [SELECT Id, SQ__c FROM OrderItem WHERE SQ__c != null];
            List<String> orSQList = new List<String>();
            for(OrderItem oi : oiList) {
                orSQList.add(oi.SQ__c);
            }

            for(SQ__c record : reqSq) {
                if(
                    record.Name.contains(keyword) ||
                    (record.SQ_Comments__c != null && decodeHtml(removeHtmlTags(record.Description__c)).contains(keyword))
                ) {
                    SearchModalWrapper sw = new SearchModalWrapper();
                    sw.rndSQ            = record.Id;
                    sw.baseCode         = record.FM_BaseCode__c;
                    sw.sqTitle          = record.Name;
                    sw.model            = record.FM_ModelName__c;
                    sw.description      = decodeHtml(removeHtmlTags(record.Description__c));
                    sw.descriptionHtml  = record.Description__c;
                    // sw.descriptionHover = record.SQ_Comments__c;
                    sw.sqType           = 'R&D SQ';
                    sw.price            = record.Price__c;
                    sw.sqCategory       = record.Category__c;
                    sw.isOrder          = orSQList.contains(record.Id) ? 'Y' : 'N';
                    sw.reviewDate       = record.ReviewApprovalDate__c;
                    sw.month            = record.Delivery_Date_months__c;
                    wrapperList.add(sw);
                }
            }

            String  query  = 'SELECT Id, Name, Description__c, List_Price__c, Category__c, Base_Code__r.Name, Model_Name__c, Cost__c, RecordType.Name FROM SalesSQ__c';
            
            if(sqr.isEmpty()) {
                if(q.RecordType.Name == 'Korea' || q.RecordType.Name == 'Service') {
                    query += '\n WHERE RecordType.Name = \'Domestic\' ';
                } else if(q.RecordType.Name == 'Global') {
                    query += '\n WHERE RecordType.Name = \'Global\' ';
                } else if(q.RecordType.Name == 'DNSA Factory') {
                    query += '\n WHERE (RecordType.Name = \'Global\' ';
                    query += '\n OR RecordType.Name = \'DNSA\') ';
                }
            } else {
                if(sqr[0].RecordType.Name == 'SQ') {
                    query += '\n WHERE RecordType.Name = \'Domestic\' ';
                } else if(sqr[0].RecordType.Name == 'Global SQ') {
                    query += '\n WHERE RecordType.Name = \'Global\' ';
                } else if(sqr[0].RecordType.Name == 'DNSA') {
                    query += '\n WHERE (RecordType.Name = \'Global\' ';
                    query += '\n OR RecordType.Name = \'DNSA\') ';
                }
            }

            // if(!mod.isEmpty()) {
            //     String mCode = mod[0].Code__c;
            //     query += '\n AND Model_Name__c = :mCode';
            // }
            if(String.isNotBlank(modelName)) {
                query += '\n AND Model_Name__c = :modelName';
            }
            
            query += '\n ORDER BY CreatedDate DESC';
            List<SalesSQ__c> salesSq = DataBase.query(query);

            if(!salesSq.isEmpty()) {
                for(SalesSQ__c record : salesSq) {
                    if(
                        record.Name.contains(keyword) ||
                        (record.Description__c != null && record.Description__c.contains(keyword))
                    ) {
                        SearchModalWrapper sw = new SearchModalWrapper();
                        sw.salesSQ          = record.Id;
                        sw.baseCode         = record.Base_Code__r.Name;
                        sw.sqTitle          = record.Name;
                        sw.model            = record.Model_Name__c;
                        sw.description      = decodeHtml(removeHtmlTags(record.Description__c));
                        sw.descriptionHtml  = record.Description__c;
                        sw.sqType           = 'Sales SQ';
                        // 국내는 List_Price__c, 글로벌은 Cost__c
                        if(sqr.isEmpty()) {
                            if(q.RecordType.Name == 'Global') {
                                // sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate).setScale(2, RoundingMode.HALF_UP) + (record.Cost__c / rate * markUp)).setScale(2, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                                sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / markUp / rate)).setScale(0, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                            } else {
                                sw.price = record.List_Price__c;     
                            }
                        } else {
                            if(sqr[0].RecordType.Name == 'Global SQ') {
                                // sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate).setScale(2, RoundingMode.HALF_UP) + (record.Cost__c / rate * markUp)).setScale(2, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                                sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / markUp / rate)).setScale(0, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                            } else {
                                sw.price = record.List_Price__c;     
                            }
                                // System.debug('salessq : ' + ((record.Cost__c / markUp / rate)).setScale(0, RoundingMode.HALF_UP));
                        }
                        sw.sqCategory       = record.Category__c;
                        sw.isOrder          = 'N';
                        wrapperList.add(sw);
                    }
                }
            }
            if(isSQR) insertSQSearchHistory(keyword, modelName, recordId);

            return wrapperList;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * DNSA SQ를 검색합니다.
     */
    @AuraEnabled
    public static List<SearchModalWrapper> DNSAsearchSQ(String modelName, String keyword, String recordId) {
        List<SearchModalWrapper> wrapperList = new List<SearchModalWrapper>();
        
        try {
            User user = [SELECT Id, Profile.UserLicense.Name, CurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            List<SQ_Pricing__c> prList = [SELECT Id, FM_RegionCode__c, CurrencyIsoCode, Land__c, Rate__c, Markup__c FROM SQ_Pricing__c];
            List<SQRegistration__c> sqr = [SELECT Id, RecordType.Name FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];

            Decimal rate = 0;
            Decimal markUp = 0;

            for(SQ_Pricing__c sqp : prList) {
                if('U' == sqp.FM_RegionCode__c && sqp.CurrencyIsoCode == 'USD') {
                    rate = sqp.Rate__c;
                    markUp = sqp.Markup__c;

                    if(sqp.FM_RegionCode__c == 'X' && sqp.Land__c == 'IN') {
                        rate = 1120;
                        markUp = 0.45;
                    }
                }
            }

            String  query  = 'SELECT Id, Name, Description__c, List_Price__c, Category__c, Base_Code__r.Name, Model_Name__c, Cost__c, RecordType.Name FROM SalesSQ__c';
            query += '\n WHERE (RecordType.Name = \'Global\' OR RecordType.Name = \'DNSA\') ';
            if(!String.isBlank(modelName)) {
                query += '\n AND Model_Name__c = :modelName';
            }
            query += '\n ORDER BY CreatedDate DESC';
            List<SalesSQ__c> salesSq = DataBase.query(query);

            if(!salesSq.isEmpty()) {
                for(SalesSQ__c record : salesSq) {
                    if(
                        record.Name.contains(keyword) ||
                        (record.Description__c != null && record.Description__c.contains(keyword))
                    ) {
                        SearchModalWrapper sw = new SearchModalWrapper();
                        sw.salesSQ          = record.Id;
                        sw.baseCode         = record.Base_Code__r.Name;
                        sw.sqTitle          = record.Name;
                        sw.model            = record.Model_Name__c;
                        sw.description      = decodeHtml(removeHtmlTags(record.Description__c));
                        sw.descriptionHtml  = record.Description__c;
                        sw.sqType           = 'Sales SQ';
                        // sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate).setScale(2, RoundingMode.HALF_UP) + (record.Cost__c / rate * markUp)).setScale(2, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                        sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate / markUp)).setScale(0, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                        
                        sw.sqCategory       = record.Category__c;
                        sw.isOrder          = 'N';
                        wrapperList.add(sw);
                    }
                }
            }
            insertSQSearchHistory(keyword, null, recordId);

            return wrapperList;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Requested SQ를 업데이트합니다.
     */
    @AuraEnabled
    public static Map<String, String> updateRequestedSQ(List<SearchModalWrapper> selectedTitle, List<SearchModalWrapper> selectedRows, String recordId) {
        Map<String, String> resMap = new Map<String, String>();
        System.debug('selectedTitle ::: ' + selectedTitle);
        System.debug('selectedRows ::: ' + selectedRows);
        try {
            Set<Id> requestedIds = new Set<Id>();
            if(!selectedTitle.isEmpty()) {

                for(SearchModalWrapper sw : selectedTitle) {
                    requestedIds.add(sw.Id);
                }
    
                SearchModalWrapper row = selectedRows[0];
    
                List<RequestedSQ__c> requestedList = [
                    SELECT  Id
                            , Name
                            , Description__c
                            , Price__c
                            , Category__c
                            , DeliveryDate_months__c
                            , Sales_SQ__c
                            , rndSQ__c
                    FROM RequestedSQ__c
                    WHERE Id = :requestedIds
                ];
    
                List<SalesSQ__c> salesList = new List<SalesSQ__c>();
                List<SQ__c> rndList = new List<SQ__c>();
                if(row.sqType == 'Sales SQ') {
                    salesList = [
                        SELECT  Id
                                , Name
                                , Description__c
                                , List_Price__c
                                , Cost__C
                                , Category__c
                                , Delivery_Month__c
                        FROM SalesSQ__c
                        WHERE Id = :row.salesSQ
                    ];
                } else {
                    rndList = [
                        SELECT  Id
                                , Name
                                , Description__c
                                , Cost__c
                                , Category__c
                                , Delivery_Date_months__c
                        FROM SQ__c
                        WHERE Id = :row.rndSQ
                    ];
                }
    
                List<RequestedSQ__c> updateList = new List<RequestedSQ__c>();
                for(RequestedSQ__c rsq : requestedList) {
                    rsq.Name                    = row.sqTitle;
                    rsq.Description__c          = row.description;
                    rsq.Price__c                = row.Price;
                    rsq.Category__c             = row.sqCategory;
                    rsq.Sales_SQ__c             = row.salesSQ;
                    rsq.rndSQ__c                = row.rndSQ;
                    rsq.DeliveryDate_months__c  = !salesList.isEmpty() ? salesList[0].Delivery_Month__c : rndList[0].Delivery_Date_months__c;
                    updateList.add(rsq);
                }
    
                if(!updateList.isEmpty()) update updateList;
            } else {
                SQRegistration__c sqr = [SELECT Id FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
                SearchModalWrapper row = selectedRows[0];

                List<SalesSQ__c> salesList = new List<SalesSQ__c>();
                List<SQ__c> rndList = new List<SQ__c>();
                if(row.salesSQ != null) {
                    salesList = [
                        SELECT  Id
                                , Name
                                , Description__c
                                , List_Price__c
                                , Cost__C
                                , Category__c
                                , Delivery_Month__c
                        FROM SalesSQ__c
                        WHERE Id = :row.salesSQ
                    ];
                } else {
                    rndList = [
                        SELECT  Id
                                , Name
                                , Description__c
                                , Cost__c
                                , Category__c
                                , Delivery_Date_months__c
                        FROM SQ__c
                        WHERE Id = :row.rndSQ
                    ];

                }


                RequestedSQ__c rsq = new RequestedSQ__c();
                rsq.Name                    = row.sqTitle;
                rsq.Description__c          = row.description;
                rsq.Price__c                = row.Price;
                rsq.Category__c             = row.sqCategory;
                rsq.Sales_SQ__c             = row.salesSQ;
                rsq.rndSQ__c                = row.rndSQ;
                rsq.DeliveryDate_months__c  = !salesList.isEmpty() ? salesList[0].Delivery_Month__c : rndList[0].Delivery_Date_months__c;
                rsq.SQRegistration__c       = sqr.Id;

                DN_WithoutSharingClass.insertReq(rsq);
            }
            
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }

    /**
     * 초기 검색 데이터를 가져옵니다.
     */
    private static List<SearchModalWrapper> getInitDatas(String modelName, String recordId, String productCode) {
        List<SearchModalWrapper> wrapperList = new List<SearchModalWrapper>();

        List<SQRegistration__c> sqr = [SELECT Id, RecordType.Name, CurrencyIsoCode, Quote__c, BaseCode__c, BaseCode__r.ProductCode FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        List<SQ_Pricing__c> prList = [SELECT Id, FM_RegionCode__c, CurrencyIsoCode, Land__c, Rate__c, Markup__c FROM SQ_Pricing__c];
        String product = '';
        String prdCode = '';
        String currencyCode = '';
        Decimal rate = 0;
        Decimal markUp = 0;
        Quote q = new Quote();
        if(sqr.isEmpty()) {
            q = [SELECT Id, CurrencyIsoCode, RecordType.Name FROM Quote WHERE Id = :recordId LIMIT 1];
            product = productCode;
            prdCode = product.substring(product.length() - 3, product.length() - 2);
            currencyCode = q.CurrencyIsoCode;
        } else {
            product = productCode;
            prdCode = product.substring(product.length() - 3, product.length() - 2);
            currencyCode = sqr[0].CurrencyIsoCode;
        }

        if(prdCode != '') {
            for(SQ_Pricing__c sqp : prList) {
                if(prdCode == sqp.FM_RegionCode__c && sqp.CurrencyIsoCode == currencyCode) {
                    rate = sqp.Rate__c;
                    markUp = sqp.Markup__c;

                    if(sqp.FM_RegionCode__c == 'X' && sqp.Land__c == 'IN') {
                        rate = 1120;
                        markUp = 0.45;
                    }
                }
            }
        }
        List<SQ__c> rsList = new List<SQ__c>();
        if(String.isNotBlank(modelName)) {
            rsList = [
                SELECT  Id
                        , Name
                        , Description__c
                        , Cost__c
                        , SQ_Type__c
                        , SQ_Registration__c
                        , Category__c
                        , Price__c
                        , listPrice__c
                        , Dealer_Price__c
                        , FM_BaseCode__c
                        , ReviewApprovalDate__c
                        , Delivery_Date_months__c
                        , FM_ModelName__c
                        , CurrencyIsoCode
                        , SQ_Comments__c
                FROM SQ__c 
                WHERE FM_ModelName__c = :modelName
                AND CurrencyIsoCode = :currencyCode
                AND IsDelete__c = false
                AND IsReview__c = true
                AND (SQ_Type__c != 'Sales SQ'
                OR SalesSQ__c = null)
                ORDER BY CreatedDate DESC
            ];
        } else {
            rsList = [
                SELECT  Id
                        , Name
                        , Description__c
                        , Cost__c
                        , SQ_Type__c
                        , SQ_Registration__c
                        , Category__c
                        , Price__c
                        , listPrice__c
                        , Dealer_Price__c
                        , ReviewApprovalDate__c
                        , FM_BaseCode__c
                        , Delivery_Date_months__c
                        , FM_ModelName__c
                        , CurrencyIsoCode
                        , SQ_Comments__c
                FROM SQ__c
                WHERE CurrencyIsoCode = :currencyCode
                AND IsDelete__c = false
                AND IsReview__c = true
                AND (SQ_Type__c != 'Sales SQ'
                OR SalesSQ__c = null)
                ORDER BY CreatedDate DESC
            ];
        }
        List<OrderItem> oiList = [SELECT Id, SQ__c FROM OrderItem WHERE SQ__c != null];
        List<String> orSQList = new List<String>();
        for(OrderItem oi : oiList) {
            orSQList.add(oi.SQ__c);
        }

        if(!rsList.isEmpty()) {
            for(SQ__c record : rsList) {
                SearchModalWrapper sw = new SearchModalWrapper();
                sw.rndSQ            = record.Id;
                sw.baseCode         = record.FM_BaseCode__c;
                sw.sqTitle          = record.Name;
                sw.model            = record.FM_ModelName__c;
                sw.description      = decodeHtml(removeHtmlTags(record.Description__c));
                sw.descriptionHtml  = record.Description__c;
                sw.sqType           = 'R&D SQ';
                sw.price            = record.Price__c;
                sw.sqCategory       = record.Category__c;
                sw.isOrder          = orSQList.contains(record.Id) ? 'Y' : 'N';
                sw.reviewDate       = record.ReviewApprovalDate__c;
                sw.month            = record.Delivery_Date_months__c;
                wrapperList.add(sw);
            }
        }

        String  query  = 'SELECT Id, Name, Description__c, List_Price__c, Category__c, DealerPrice__c, Base_Code__r.Name, Model_Name__c, Cost__c, RecordType.Name FROM SalesSQ__c';
            
        if(sqr.isEmpty()) {
            if(q.RecordType.Name == 'Korea' || q.RecordType.Name == 'Service') {
                query += '\n WHERE RecordType.Name = \'Domestic\' ';
            } else if(q.RecordType.Name == 'Global') {
                query += '\n WHERE RecordType.Name = \'Global\' ';
            } else if(q.RecordType.Name == 'DNSA Factory') {
                query += '\n WHERE (RecordType.Name = \'Global\' ';
                query += '\n OR RecordType.Name = \'DNSA\') ';
            }
        } else {
            if(sqr[0].RecordType.Name == 'SQ') {
                query += '\n WHERE RecordType.Name = \'Domestic\' ';
            } else if(sqr[0].RecordType.Name == 'Global SQ') {
                query += '\n WHERE RecordType.Name = \'Global\' ';
            } else if(sqr[0].RecordType.Name == 'DNSA') {
                query += '\n WHERE (RecordType.Name = \'Global\' ';
                query += '\n OR RecordType.Name = \'DNSA\') ';
            }
        }

        if(String.isNotBlank(modelName)) {
            query += '\n AND Model_Name__c = :modelName';
        }
        query += '\n ORDER BY CreatedDate DESC';
        List<SalesSQ__c> salesSQList = DataBase.query(query);
        System.debug('salesSQList ::: ' + salesSQList);

        if(!salesSQList.isEmpty()) {
            for(SalesSQ__c record : salesSQList) {
                SearchModalWrapper sw = new SearchModalWrapper();
                sw.salesSQ          = record.Id;
                sw.baseCode         = record.Base_Code__r.Name;
                sw.sqTitle          = record.Name;
                sw.model            = record.Model_Name__c;
                sw.description      = decodeHtml(removeHtmlTags(record.Description__c));
                sw.descriptionHtml  = record.Description__c;
                sw.sqType           = 'Sales SQ';
                if(sqr.isEmpty()) {
                    if(q.RecordType.Name == 'Global') {
                        // sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate).setScale(2, RoundingMode.HALF_UP) + (record.Cost__c / rate * markUp)).setScale(2, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                        sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate / markUp)).setScale(0, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                    } else {
                        sw.price = record.List_Price__c;     
                    }
                } else {
                    if(sqr[0].RecordType.Name == 'Global SQ') {
                        // sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate).setScale(2, RoundingMode.HALF_UP) + (record.Cost__c / rate * markUp)).setScale(2, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;
                        sw.price = rate != 0 && record.Cost__c != null ? ((record.Cost__c / rate / markUp)).setScale(0, RoundingMode.HALF_UP) : record.Cost__c == null ? 0 : record.Cost__c;        
                    } else {
                        sw.price = record.List_Price__c;     
                    }
                }
                sw.sqCategory       = record.Category__c;
                sw.isOrder          = 'N';
                wrapperList.add(sw);
            }
        }
        
        return wrapperList;
    }

    /**
     * SQ 검색 이력을 삽입합니다.
     */
    private static void insertSQSearchHistory(String keyword, String modelName, String recordId) {
        SQRegistration__c sqr = [
            SELECT  Id
                    , IsSearch__c
            FROM SQRegistration__c
            WHERE Id = :recordId
        ];

        SQ_SearchHistory__c searchHistory = new SQ_SearchHistory__c();
        searchHistory.SQRegistration__c = recordId;
        searchHistory.Keyword__c = keyword != null ? keyword : '';
        searchHistory.Model__c = modelName != null ? modelName : '';
        insert searchHistory;

        sqr.IsSearch__c = true;
        update sqr;
    }

    /**
     * 관련 리스트 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> getRelatedListInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getInitDatas'               , getRelatedListDatas(recordId));
            resMap.put('getRichTextValue'           , getRichTextValue(recordId));
            resMap.put('getCurrentStage'            , getCurrentStage(recordId));
            resMap.put('getUserFilter'              , getUserFilter());
            resMap.put('getDealerOwner'             , getDealerOwner(recordId));
            resMap.put('getBranchRepresentative'    , getBranchRepresentative(recordId));
            resMap.put('getSQdata'                  , getSQdata(recordId));
            resMap.put('checkWorker'                , checkWorker());
            resMap.put('checkPreAuth'               , checkPreAuth(recordId));
            resMap.put('checkGlobal'                , checkGlobal(recordId));
            resMap.put('checkDNSASalesTeam'         , checkDNSASalesTeam(recordId));
            resMap.put('checkQuoteLineItems'        , checkQuoteLineItems(recordId));
            resMap.put('checkJisajang'              , checkJisajang());
            resMap.put('checkRnd', checkRnds());

            SQRegistration__c sqr = [SELECT Id, IsReqSend__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            List<SQ_Registration_Junction__c> sqrPrdList = [
                SELECT 
                    Id, 
                    QuoteLineItem__c,
                    QuoteLineItem__r.Id,
                    QuoteLineItem__r.Product2Id,
                    QuoteLineItem__r.Product2.ProductCode 
                FROM 
                    SQ_Registration_Junction__c 
                WHERE 
                    SQRegistration__c = :sqr.Id 
                AND QuoteLineItem__r.Product2Id != null 
                LIMIT 1];
            resMap.put('isReqSend', sqr.IsReqSend__c);
            String sqrPrd = '';
            if(!sqrPrdList.isEmpty()){
                sqrPrd = sqrPrdList[0].QuoteLineItem__r.Product2.ProductCode;
            }
            System.debug('sqrPrdList : ' + sqrPrdList);
            resMap.put('sqProduct', sqrPrd);
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * R&D 프로필 여부를 확인합니다.
     */
    private static Boolean checkRnds() {
        User user = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(user.Profile.Name.contains('R&D')) {
            return true;
        }
        return false;
    }

    /**
     * DNSA Sales Team에 Requested SQ를 전송합니다.
     */
    @AuraEnabled
    public static String sendDNSSalesTeamRequestedSQ(String recordId) {
        String result = 'Success';
        try {
            List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
            Set<Id> notiReceiver = new Set<Id>();
            Set<Id> notiReceiverEN = new Set<Id>();
            List<String> emailReceiver = new List<String>();
            List<String> emailReceiverEN = new List<String>();
    
            SQRegistration__c sqr = [SELECT Id, Name, Message_Group__c, IsReqSend__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c, FM_UserEmail__c, FM_UserLanguage__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.Message_Group__c AND User__r.IsActive = true];
    
            if(!mgjList.isEmpty()) {
                for(Message_Group_Junction__c mgj : mgjList) {
                    if(mgj.FM_UserLanguage__c == 'ko') {
                        notiReceiver.add(mgj.User__c);
                        emailReceiver.add(mgj.FM_UserEmail__c);
                    } else {
                        notiReceiverEN.add(mgj.User__c);
                        emailReceiverEN.add(mgj.FM_UserEmail__c);
                    }
                }
    
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Requested SQ DNS Sales Team Alert' LIMIT 1];
    
                if(!am.isEmpty()) {
                    if(!notiReceiver.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType       = 'Notification';
                        history.elementList.add(sqr.Name);
                        history.alertID         = am[0].Id;
                        history.targetID        = sqr.Id;
                        history.receiverforID   = notiReceiver;
                        history.alertLanguage   = 'ko';
                        ahwList.add(history);
                    }
                    if(!notiReceiverEN.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType       = 'Notification';
                        history.elementList.add(sqr.Name);
                        history.alertID         = am[0].Id;
                        history.targetID        = sqr.Id;
                        history.receiverforID   = notiReceiverEN;
                        history.alertLanguage   = 'en';
                        ahwList.add(history);
                    }
                    if(!emailReceiver.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType           = 'Email';
                        history.elementList.add(sqr.Name);
                        history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id);
                        history.alertID             = am[0].Id;
                        history.targetID            = sqr.Id;
                        history.receiverforEmail    = emailReceiver;
                        history.alertLanguage       = 'ko';
                        ahwList.add(history);
                    }
                    if(!emailReceiverEN.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType           = 'Email';
                        history.elementList.add(sqr.Name);
                        history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id);
                        history.alertID             = am[0].Id;
                        history.targetID            = sqr.Id;
                        history.receiverforEmail    = emailReceiverEN;
                        history.alertLanguage       = 'en';
                        ahwList.add(history);
                    }
                    if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
                }
            }
            if(!sqr.IsReqSend__c) {
                sqr.IsReqSend__c = true;
                update sqr;
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result = e.getLineNumber() + ' / ' + e.getMessage();
        }
        return result;
    }

    /**
     * DNSA Sales Team 소속 여부를 확인합니다.
     */
    private static Boolean checkDNSASalesTeam(String recordId) {
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        SQRegistration__c sqr = [SELECT Id, DNSA_Sales_Team__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        if(sqr.DNSA_Sales_Team__c != null) {
            List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.DNSA_Sales_Team__c AND User__r.IsActive = true];
            if(!mgjList.isEmpty()) {
                for(Message_Group_Junction__c mgj : mgjList) {
                    if(mgj.User__c == user.Id) return true;
                }
            }
        }
        return false;
    }

    /**
     * QuoteLineItem과 관련된 Junction 존재 여부를 확인합니다.
     */
    private static Boolean checkQuoteLineItems(String recordId) {
        List<SQ_Registration_Junction__c> junction = [SELECT Id FROM SQ_Registration_Junction__c WHERE SQRegistration__c = :recordId];
        if(!junction.isEmpty()) return true;
        return false;
    }

    /**
     * 글로벌 Quote인지 확인합니다.
     */
    private static Boolean checkGlobal(String recordId) {
        List<SQregistration_Quote__c> sqr = [SELECT Id, Quote__r.RecordType.DeveloperName FROM SQregistration_Quote__c WHERE SQ_Registration__c = :recordId LIMIT 1];

        if(!sqr.isEmpty()) {
            if(sqr[0].Quote__r.RecordType.DeveloperName == 'Korea') {
                return true;
            }
        }
        return false;
    }

    /**
     * 사전 승인 권한을 확인합니다.
     */
    private static Boolean checkPreAuth(String recordId) {
        SQRegistration__c sqr = [SELECT Id, Stage__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        List<SQ__c> sqList = [SELECT Id FROM SQ__c WHERE SQ_Registration__c = :recordId AND IsDelete__c = false];

        if(!sqList.isEmpty()) {
            if(sqr.Stage__c == 'Request' || sqr.Stage__c == 'Sales Review' || sqr.Stage__c == 'R&D Review') {
                return true;
            }
        }
        return false;
    }

    /**
     * 워커 역할 여부를 확인합니다.
     */
    private static Boolean checkWorker() {
        User user = [SELECT Id, UserRole.PortalRole, SalesDistrict__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(user.UserRole.PortalRole == 'Worker' && user.SalesDistrict__c != 'A1KR') {
            return true;
        }else {
            return false;
        }
    }

    /**
     * SQ 데이터 존재 여부를 확인합니다.
     */
    private static Boolean getSQdata(String recordId) {
        List<SQ__c> sqList = [
            SELECT  Id
            FROM SQ__c
            WHERE SQ_Registration__c = :recordId
            AND IsDelete__c = false
        ];
        if(!sqList.isEmpty()) {
            return true;
        }else {
            return false;
        }
    }

    /**
     * 사용자 필터를 반환합니다.
     */
    private static String getUserFilter() {
        User user = [SELECT Id, Profile.UserLicense.Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<String> rndPro = new List<String>{'R&D', 'R&D Login'};
        if((user.Profile.UserLicense.Name == 'Partner Community' || user.Profile.UserLicense.Name == 'Partner Community Login' || user.Profile.UserLicense.Name == 'Customer Community Plus') && !rndPro.contains(user.Profile.Name)) {
            return 'Dealer';
        } else if (user.Profile.Name == 'R&D Login' || user.Profile.Name == 'R&D') {
            return 'RND';
        } else if (user.Profile.Name.contains('직영영업')) {
            return '직영';
        } else if (user.Profile.Name == 'System Administrator' || user.Profile.Name == '시스템 관리자') {
            return 'admin';
        } else {
            return 'crm';
        }
    }

    /**
     * 딜러 소유자 여부를 확인합니다.
     */
    private static Boolean getDealerOwner(String recordId) {
        SQRegistration__c sqr = [SELECT Id, OwnerId FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        if(currentUser.Id == sqr.OwnerId) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * 지사 대표 여부를 확인합니다.
     */
    private static Boolean getBranchRepresentative(String recordId) {
        SQRegistration__c sqr = [SELECT Id, Message_Group__c, DNSA_Sales_Team__c, RecordType.DeveloperName FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        if(sqr.Message_Group__c != null) {
            List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.Message_Group__c AND User__r.IsActive = true];
            
            if(!mgjList.isEmpty()) {
                for(Message_Group_Junction__c mgj : mgjList) {
                    if(currentUser.Id == mgj.User__c) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /**
     * 리치 텍스트 값을 저장합니다.
     */
    @AuraEnabled
    public static void saveRichTextValue(String richTextContent, String recordId, String type) {
        try {
            String field;
            switch on type {
                when 'requested' {
                    field = 'richValue__c';
                }
                when 'review' {
                    field = 'ReviewRichValue__c';
                }
                when 'sq' {
                    field = 'SQRichValue__c';
                }
            }
            String query = 'SELECT Id, ' +  field + ' FROM SQRegistration__c WHERE Id = :recordId LIMIT 1';
            SQRegistration__c sqr = Database.query(query);

            sqr.put(field, richTextContent);
            update sqr;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Requested SQ 필드 세트를 가져옵니다.
     */
    @AuraEnabled
    public static List<String> getRequestedSQFieldSet(String objectName, String category) {
        try {
            List<String> result = new List<String>();
            for(Schema.FieldSetMember f : getFields(objectName, category)) {
                result.add(f.getFieldPath());
            }
            return result;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 새로운 Requested SQ 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> newReqInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            User user = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            SQRegistration__c sqr = [SELECT Id, RecordType.DeveloperName FROM SQRegistration__c WHERE Id = :recordid LIMIT 1];

            resMap.put('checkIsReview', checkIsReview(recordId));
            resMap.put('language', user.LanguageLocaleKey);
            resMap.put('rt', sqr.RecordType.DeveloperName);
            resMap.put('categoryValues', getCategoryPicklist());
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Requested SQ 편집 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> editRequestedInit(String recordId, String objectName) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getRequestedSQEditFieldSet', getRequestedSQEditFieldSet(objectName));
            resMap.put('checkSalesSQ', checkSalesSQ(recordId));
            resMap.put('checkRndSQ', checkRndSQ(recordId));
            resMap.put('checkIsReview', checkIsReview(recordId));
            resMap.put('categoryValues', getCategoryPicklist());

            User user = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            resMap.put('language', user.LanguageLocaleKey);
            
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 리뷰 권한 여부를 확인합니다.
     */
    private static Boolean checkIsReview(String recordId) {
        List<SQRegistration__c> sqr = [SELECT Id, Message_Group__c, DNSA_Sales_Team__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        if(!sqr.isEmpty()) {
            if(sqr[0].DNSA_Sales_Team__c != null) {
                List<Message_Group_Junction__c> mgjs = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr[0].DNSA_Sales_Team__c AND User__r.IsActive = true];
                if(!mgjs.isEmpty()) {
                    for(Message_Group_Junction__c mg : mgjs) {
                        if(mg.User__c == UserInfo.getUserId()) return true; 
                    }
                }
            }

            if(sqr[0].Message_Group__c != null) {
                List<Message_Group_Junction__c> mgj = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr[0].Message_Group__c AND User__r.IsActive = true];
                if(!mgj.isEmpty()) {
                    for(Message_Group_Junction__c m : mgj) {
                        if(m.User__c == UserInfo.getUserId()) return true; 
                    }
                }
            }
        } else {
            RequestedSQ__c req = [SELECT Id, SQRegistration__c FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];
            SQRegistration__c sqrq = [SELECT Id, Message_Group__c, DNSA_Sales_Team__c FROM SQRegistration__c WHERE Id = :req.SQRegistration__c LIMIT 1];
            if(sqrq.DNSA_Sales_Team__c != null) {
                List<Message_Group_Junction__c> mgjs = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqrq.DNSA_Sales_Team__c AND User__r.IsActive = true];
                if(!mgjs.isEmpty()) {
                    for(Message_Group_Junction__c mg : mgjs) {
                        if(mg.User__c == UserInfo.getUserId()) return true; 
                    }
                }
            }

            if(sqrq.Message_Group__c != null) {
                List<Message_Group_Junction__c> mgj = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqrq.Message_Group__c AND User__r.IsActive = true];
                if(!mgj.isEmpty()) {
                    for(Message_Group_Junction__c m : mgj) {
                        if(m.User__c == UserInfo.getUserId()) return true; 
                    }
                }
            }
        }

        User user = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(user.Profile.Name == '시스템 관리자' || user.Profile.Name == 'System Administrator') {
            return true;
        }
        return false;
    }

    /**
     * Requested SQ 편집 필드 세트를 가져옵니다.
     */
    private static List<String> getRequestedSQEditFieldSet(String objectName) {
        List<String> result = new List<String>();
        for(Schema.FieldSetMember f : getEditFields(objectName)) {
            result.add(f.getFieldPath());
        }
        return result;
    }

    /**
     * Sales SQ 존재 여부를 확인합니다.
     */
    private static Boolean checkSalesSQ(String recordId) {
        RequestedSQ__c reqSQ = [SELECT Id, Sales_SQ__c FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];
        if(reqSQ.Sales_SQ__c != null) return true;
        else return false;
    }

    /**
     * R&D SQ 존재 여부를 확인합니다.
     */
    private static Boolean checkRndSQ(String recordId) {
        RequestedSQ__c reqSQ = [SELECT Id, rndSQ__c FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];
        if(reqSQ.rndSQ__c != null) return true;
        else return false;
    }

    /**
     * Requested SQ를 삭제합니다.
     */
    @AuraEnabled
    public static string deleteRequestedSQ(String recordId) {
        try {
            RequestedSQ__c rsq = [SELECT Id FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];
            delete rsq;
            return 'success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
    }

    /**
     * SQ를 복제합니다.
     */
    @AuraEnabled
    public static string cloneSQ(String recordId, String type) {
        try {
            Id factoryRT = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
            Id dnsaRT = SObjectType.SQRegistration__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

            List<RequestedSQ__c> rsqList = [
                SELECT  Id
                        , Name
                        , Description__c
                        , SQRegistration__c
                        , SQRegistration__r.Quote__c
                        , SQRegistration__r.Quote__r.RecordTypeId
                        , Category__c
                        , Price__c
                        , DeliveryDate_months__c
                        , CurrencyIsoCode
                        , Sales_SQ__c
                FROM RequestedSQ__c 
                WHERE SQRegistration__c = :recordId
            ];

            SQRegistration__c sqr = [SELECT Stage__c, Manager__c, Quote__c, Quote__r.RecordTypeId, RecordTypeId FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            List<SQ__c> existingSQList = [SELECT Id, RequestedSQ__c FROM SQ__c WHERE SQ_Registration__c = :recordId AND IsDelete__c = false];

            if(!rsqList.isEmpty()) {
                List<SQ__c> insertSQList = new List<SQ__c>();
                List<SQ__c> updateSQList = new List<SQ__c>();
                Set<Id> sqRegIds = new Set<Id>();
                Map<Id, SQ__c> existingSQMap = new Map<Id, SQ__c>();

                for (SQ__c sq : existingSQList) {
                    existingSQMap.put(sq.RequestedSQ__c, sq);
                }

                for(RequestedSQ__c req : rsqList) {
                    sqRegIds.add(req.SQRegistration__c);
                    SQ__c sq;

                    if (existingSQMap.containsKey(req.Id)) {
                        sq = existingSQMap.get(req.Id);
                    } else {
                        sq = new SQ__c();
                    }

                    sq.RequestedSQ__c           = req.Id;
                    sq.Name                     = req.Name;
                    sq.Category__c              = req.Category__c;
                    if(req.Sales_SQ__c != null) {
                        sq.SQ_Comments__c       = req.Description__c;
                    }
                    sq.SalesSQ__c               = req.Sales_SQ__c;
                    sq.SQ_Registration__c       = req.SQRegistration__c;
                    sq.Cost__c                  = 0;
                    sq.DNS_Price__c             = 0;
                    sq.Price__c                 = sqr.Quote__c != null ? (sqr.Quote__r.RecordTypeId == factoryRT ? 0 : req.Price__c) : req.Price__c;
                    sq.Price__c                 = req.Price__c;
                    if(sqr.RecordTypeId == dnsaRT) {
                        sq.DNS_Price__c         = req.Price__c;
                    }
                    sq.Delivery_Date_months__c  = req.DeliveryDate_months__c;
                    sq.ReviewApprovalDate__c    = Date.today();
                    sq.CurrencyIsoCode          = req.CurrencyIsoCode;
                    if(type != 'true') {
                        sq.IsFinal__c           = true;
                    }
                    sq.Quote__c                 = sqr.Quote__c != null ? (sqr.Quote__r.RecordTypeId == factoryRT ? sqr.Quote__c : null) : null;

                    if (existingSQMap.containsKey(req.Id)) {
                        updateSQList.add(sq);
                    } else {
                        insertSQList.add(sq);
                    }
                }

                if(!insertSQList.isEmpty() || !updateSQList.isEmpty()) {
                    if(type == 'true') {
                        sqr.Stage__c = 'R&D Confirm';
                        sqr.Manager__c = UserInfo.getUserId();
                        TriggerHandler.bypass('SQRegistrationTriggerHandler');
                        update sqr;
                        TriggerHandler.clearBypass('SQRegistrationTriggerHandler');

                        sendInsertSQEmail(sqRegIds);
                        sendInsertSQAlert(sqRegIds);
                    }

                    if(!insertSQList.isEmpty()) {
                        insert insertSQList;
                    }
                    if(!updateSQList.isEmpty()) {
                        update updateSQList;
                    }
                }

                return 'success';
            } else {
                return 'empty';
            }

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
    }

    /**
     * SQ 삽입 이메일 알림을 전송합니다.
     */
    private static void sendInsertSQEmail(Set<Id> sqRegIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> supportIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();

        List<SQRegistration__c> sqRegList = [
            SELECT  Id
                    , Name
                    , Representative__c
                    , Message_Group__c
                    , OwnerId
            FROM SQRegistration__c
            WHERE Id IN :sqRegIds
        ];

        for(SQRegistration__c sqr : sqRegList) {
            groupIds.add(sqr.Message_Group__c);
            ownerIds.add(sqr.OwnerId);
        }

        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c IN :groupIds
            AND User__r.IsActive = true
        ];

        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.FM_UserEmail__c);
            } else {
                receiverEN.add(mgj.FM_UserEmail__c);
            }
        }


        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(SQRegistration__c sqReg : sqRegList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforEmail    = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
            }
            if(!receiverEN.isEmpty()) {
                for(SQRegistration__c sqReg : sqRegList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforEmail    = receiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
            }
            System.debug('ahwList ::: ' + ahwList);
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * SQ 삽입 알림을 전송합니다.
     */
    private static void sendInsertSQAlert(Set<Id> sqRegIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();

        List<SQRegistration__c> sqRegList = [
            SELECT  Id
                    , Name
                    , Representative__c
                    , Message_Group__c
                    , OwnerId
            FROM SQRegistration__c
            WHERE Id IN :sqRegIds
        ];

        for(SQRegistration__c sqr : sqRegList) {
            groupIds.add(sqr.Message_Group__c);
            ownerIds.add(sqr.OwnerId);
        }

        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c IN :groupIds
            AND User__r.IsActive = true
        ];

        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.User__c);
            } else {
                receiverEN.add(mgj.User__c);
            }
        }


        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(SQRegistration__c sqReg : sqRegList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID    = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
            }
            if(!receiverEN.isEmpty()) {
                for(SQRegistration__c sqReg : sqRegList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID    = receiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 현재 SQ Registration 단계(stage)를 가져옵니다.
     */
    private static String getCurrentStage(String recordId) {
        SQRegistration__c sqr = [SELECT Id, Stage__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        return sqr.Stage__c;
    }

    /**
     * 리치 텍스트 값을 가져옵니다.
     */
    private static SQRegistration__c getRichTextValue(String recordId) {
        try {
            SQRegistration__c sqr = [
                SELECT  Id
                        , richValue__c
                        , ReviewRichValue__c
                        , SQRichValue__c
                FROM SQRegistration__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            return sqr;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 관련 리스트 데이터를 가져옵니다.
     */
    private static List<Map<String, Object>> getRelatedListDatas(String recordId) {
        List<Map<String, Object>> resMapList = new List<Map<String, Object>>();

        Map<String, String> categoryValueToLabelMap = new Map<String, String>();
        Schema.DescribeFieldResult categoryField = Schema.SObjectType.RequestedSQ__c.fields.getMap().get('Category__c').getDescribe();
        for (Schema.PicklistEntry entry : categoryField.getPicklistValues()) {
            categoryValueToLabelMap.put(entry.getValue(), entry.getLabel());
        }

        List<RequestedSQ__c> reqSQList = [
            SELECT  Id
                    , Name
                    , Description__c
                    , SQ_Type__c
                    , Sales_SQ__c
                    , Sales_SQ__r.Name
                    , rndSQ__c
                    , rndSQ__r.Name
                    , Category__c
                    , Price__c
                    , FM_InitialRequest__c
                    , RejectReason__c
                    , IsReRequest__c
                    , IsReview__c
                    , IsRefineComplete__c
            FROM RequestedSQ__c
            WHERE SQRegistration__c = :recordId
        ];

        if(!reqSQList.isEmpty()) {
            for(RequestedSQ__c req : reqSQList) {
                Map<String, Object> resMap = new Map<String, Object>();
                resMap.put('Id', req.Id);
                resMap.put('Name', req.Name);
                resMap.put('Description', req.Description__c);
                resMap.put('Type', req.SQ_Type__c);
                resMap.put('Sales', req.Sales_SQ__c);
                resMap.put('SalesName', req.Sales_SQ__r.Name);
                resMap.put('Rnd', req.rndSQ__c);
                resMap.put('RndName', req.rndSQ__r.Name);
                String categoryLabel = categoryValueToLabelMap.get(req.Category__c);
                resMap.put('Category', categoryLabel);
                resMap.put('Price', req.Price__c);
                resMap.put('initial', req.FM_InitialRequest__c);
                resMap.put('isReview', req.IsReview__c == true ? 'Y' : 'N');
                resMap.put('reject', req.RejectReason__c);
                resMap.put('isReRequest', req.IsReRequest__c);
                resMap.put('IsRefineComplete', req.IsRefineComplete__c);
                resMap.put('isExpanded ', false);
                resMapList.add(resMap);
            }
        }
        return resMapList;
    }

    /**
     * Requested SQ의 정제 완료 상태를 업데이트합니다.
     */
    @AuraEnabled
    public static Boolean updateRefineComplete(String recordId) {
        RequestedSQ__c req = [SELECT Id, IsRefineComplete__c FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];
        req.IsRefineComplete__c = false;
        update req;
        return false;
    }

    /* ***************************************************************************** SQ Registration ***************************************************************************** */
    /* *************************************************************************************************************************************************************************** */

    /**
     * SQ Registration의 단계(stage)를 업데이트합니다.
     */
    @AuraEnabled
    public static string updateSQRegistrationStage(String recordId) {
        try {
            SQRegistration__c sqr = [SELECT Id, Stage__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            sqr.Stage__c = 'Final Confirm';
            update sqr;
            return 'success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
    }

    /**
     * 정제 요구사항을 전송합니다.
     */
    @AuraEnabled
    public static string sendRefineRequirements(String recordId, String rowId, String reason) {
        try {
            sendRefineEmailNotification(recordId, rowId, reason);
            sendRefineAlertNotification(recordId, rowId, reason);
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
    }

    /**
     * 정제 이메일 알림을 전송합니다.
     */
    private static void sendRefineEmailNotification(String recordId, String rowId, String reason) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
            List<String> receiver = new List<String>();
            List<String> receiverEN = new List<String>();

            SQRegistration__c sqReg = [
                SELECT  Id
                        , OwnerId
                FROM SQRegistration__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            User u = DN_WithoutSharingClass.getUserEmail(sqReg.OwnerId);
            if(u.LanguageLocaleKey == 'ko') {
                receiver.add(u.Email); 
            } else {
                receiverEN.add(u.Email); 
            }

            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Requested SQ Refine Alert' LIMIT 1];

            RequestedSQ__c request = [
                SELECT  Id
                        , Name
                FROM RequestedSQ__c
                WHERE Id = :rowId
                LIMIT 1
            ];

            List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
            String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');

            if(!am.isEmpty()) {
                if(!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add(request.Name);
                    history.elementList.add(reason);
                    history.elementList.add(baseUrl + '/' + sqReg.Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforEmail    = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
                if(!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add(request.Name);
                    history.elementList.add(reason);
                    history.elementList.add(baseUrl + '/' + sqReg.Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforEmail    = receiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
            }
        return;
    }

    /**
     * 정제 알림을 전송합니다.
     */
    private static void sendRefineAlertNotification(String recordId, String rowId, String reason) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
            Set<Id> receiver = new Set<Id>();
            Set<Id> receiverEN = new Set<Id>();

            SQRegistration__c sqReg = [
                SELECT  Id
                        , OwnerId
                FROM SQRegistration__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            User u = DN_WithoutSharingClass.getUserEmail(sqReg.OwnerId);
            if(u.LanguageLocaleKey == 'ko') {
                receiver.add(u.Id); 
            } else {
                receiverEN.add(u.Id); 
            }

            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Requested SQ Refine Alert' LIMIT 1];

            RequestedSQ__c request = [
                SELECT  Id
                        , Name
                FROM RequestedSQ__c
                WHERE Id = :rowId
                LIMIT 1
            ];

            if(!am.isEmpty()) {
                if(!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(reason);
                    history.elementList.add(request.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = sqReg.Id;
                    history.receiverforID   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
                if(!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(reason);
                    history.elementList.add(request.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = sqReg.Id;
                    history.receiverforID   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
            }
        return;
    }

    /* ***************************************************************************** SQ ***************************************************************************** */
    /* ************************************************************************************************************************************************************** */

    /**
     * SQ 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> getSQInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getSQInitDatas',    getSQInitDatas(recordId));
            resMap.put('getSQRichText',     getRichTextValue(recordId));
            resMap.put('getSQCurrentStage', getSQCurrentStage(recordId));
            resMap.put('getUserFilter',     getUserFilter());
            resMap.put('checkProfile',      checkProfile());
            resMap.put('getSalesUser',      getSalesUser(recordId));
            resMap.put('getOrderData',      getOrderData(recordId));
            resMap.put('checkWorker',       checkWorker());
            resMap.put('checkRecordType',   checkRecordType(recordId));
            resMap.put('checkDNSAProfile',  checkDNSAProfile());
            resMap.put('checkJisajang',     checkJisajang());

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Quote의 레코드 타입이 DNSA Factory인지 확인합니다.
     */
    private static Boolean checkRecordType(String recordId) {
        Id factoryRT = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
        SQRegistration__c sqr = [SELECT Id, Quote__r.RecordTypeId FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        if(sqr.Quote__r.RecordTypeId == factoryRT) return true;
        return false;
    }

    /**
     * SQ 필드 세트를 가져옵니다.
     */
    @AuraEnabled
    public static List<String> getSQFieldSet() {
        try {
            List<String> result = new List<String>();
            for(Schema.FieldSetMember f : getSQFields()) {
                result.add(f.getFieldPath());
            }
            return result;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * SQ 필드 세트 멤버를 가져옵니다.
     */
    private static List<Schema.FieldSetMember> getSQFields() {
        List<Schema.FieldSetMember> result = new List<Schema.FieldSetMember>();
        result = SObjectType.SQ__c.FieldSets.SQEditLayout.getFields();
        return result;
    }

    /**
     * SQ를 삭제합니다.
     */
    @AuraEnabled
    public static string deleteSQ(String recordId) {
        try {
            SQ__c sq = [SELECT Id, IsDelete__c, SQ_Registration__c FROM SQ__c WHERE Id = :recordId LIMIT 1];
            List<SQ_QuoteLineitem_Junction__c> sqlj = [SELECT QuoteLineItem__c, FM_ERPCODE__c, POSNR__c FROM SQ_QuoteLineitem_Junction__c WHERE SQ__c = :sq.Id];

            List<SQ__c> updateList = new List<SQ__c>();
            List<SQ__c> deleteList = new List<SQ__c>();
            if(!sqlj.isEmpty()) {
                for(SQ_QuoteLineitem_Junction__c record : sqlj) {
                    if(record.POSNR__c != null) {
                        if(updateList.isEmpty()) {
                            sq.IsDelete__c = true;
                            updateList.add(sq);
                        }
                    } else {
                        if(deleteList.isEmpty()) {
                            deleteList.add(sq);
                        }
                    }
                }
            } else {
                deleteList.add(sq);
            }
            if(!updateList.isEmpty()) update updateList;
            if(!deleteList.isEmpty()) DN_WithoutSharingClass.deleteSQ(deleteList);
            return 'success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
    }

    /**
     * 주문 데이터 존재 여부를 확인합니다.
     */
    private static Boolean getOrderData(String recordId) {
        List<SQ__c> sqList = [SELECT Id FROM SQ__c WHERE SQ_Registration__c = :recordId];
        if(!sqList.isEmpty()) {
            Set<Id> sqIds = new Set<Id>();
            for(SQ__c sq : sqList) {
                sqIds.add(sq.Id);
            }
            List<OrderItem> oiList = [SELECT Id FROM OrderItem WHERE SQ__c IN :sqIds];
            if(!oiList.isEmpty()) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /**
     * 현재 SQ 단계(stage)를 가져옵니다.
     */
    private static String getSQCurrentStage(String recordId) {
        SQRegistration__c sqr = [SELECT Stage__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        return sqr.Stage__c;
    }

    /**
     * SQ 초기 데이터를 가져옵니다.
     */
    private static List<Map<String, Object>> getSQInitDatas(String recordId) {
        List<Map<String, Object>> resMapList = new List<Map<String, Object>>();
        List<SQ__c> sQList = [
            SELECT  Id
                    , Name
                    , Description__c
                    , ControlComments__c
                    , MachineComments__c
                    , SalesComments__c
                    , SQ_Type__c
                    , SalesSQ__c
                    , SalesSQ__r.Name
                    , Cost__c
                    , Price__c
                    , listPrice__c
                    , Dealer_Price__c
                    , Discount_Rate__c
                    , IsDelete__c
                    , SQ_Comments__c
                    , DNS_Price__c
                    , IsFirst__c
                    , DesignReviewRequired__c
                    , PreShipmentReview__c
                    , Delivery_Date_months__c
                    , Material_Cost__c
                    , Assembly_Cost__c
            FROM SQ__c
            WHERE SQ_Registration__c = :recordId
        ];

        if(!sQList.isEmpty()) {
            for(SQ__c sq : sQList) {
                Map<String, Object> resMap = new Map<String, Object>();
                resMap.put('Id', sq.Id);
                resMap.put('Name', sq.Name);
                resMap.put('Description', sq.Description__c);
                resMap.put('ControlComments', sq.ControlComments__c);
                resMap.put('MachineComments', sq.MachineComments__c);
                resMap.put('SalesComments', sq.SalesComments__c);
                resMap.put('SQComments', sq.Description__c);
                resMap.put('Type', sq.SQ_Type__c);
                resMap.put('Sales', sq.SalesSQ__c);
                resMap.put('SalesName', sq.SalesSQ__r.Name);
                resMap.put('Cost', sq.Cost__c);
                resMap.put('MaterialCost', sq.Material_Cost__c);
                resMap.put('AssemblyCost', sq.Assembly_Cost__c);
                resMap.put('Price', sq.Price__c);
                resMap.put('dnsPrice', sq.DNS_Price__c);
                resMap.put('delete', sq.IsDelete__c);

                resMap.put('isFirst', sq.IsFirst__c);
                resMap.put('designReviewRequired', sq.DesignReviewRequired__c);
                resMap.put('preShipmentReview', sq.PreShipmentReview__c);
                resMap.put('deliMonth', sq.Delivery_Date_months__c);
                
                resMap.put('isExpanded ', false);
                resMapList.add(resMap);
            }
        }
        return resMapList;
    }

    /* ***************************************************************************** CV ***************************************************************************** */
    /* ************************************************************************************************************************************************************** */

    /**
     * CV 데이터를 초기화합니다.
     */
    @AuraEnabled
    public static Map<String, Object> getCVInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getCVDatas', getCVDatas(recordId));
            resMap.put('checkWorker', checkWorker());
            
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * CV 데이터를 가져옵니다.
     */
    private static List<CVListWrapper> getCVDatas(String recordId) {
        List<CVListWrapper> cvListWrappers = new List<CVListWrapper>();

        List<SQ_Registration_Junction__c> sqItemJunctions = [
            SELECT  Id
                    , QuoteLineItem__c
                    , FM_ProductName__c
            FROM SQ_Registration_Junction__c
            WHERE SQRegistration__c = :recordId
        ];

        if (!sqItemJunctions.isEmpty()) {
            Set<Id> qItemIds = new Set<Id>();
            for (SQ_Registration_Junction__c sqItem : sqItemJunctions) {
                qItemIds.add(sqItem.QuoteLineItem__c);
            }
    
            List<CharacteristicValue__c> cvList = getQuoteLineItem(qItemIds);
    
            for (SQ_Registration_Junction__c sqItem : sqItemJunctions) {
                CVListWrapper wrapper = new CVListWrapper();
                wrapper.productName = sqItem.FM_ProductName__c;
    
                for (CharacteristicValue__c cv : cvList) {
                    if (cv.QuoteLineItem__c == sqItem.QuoteLineItem__c) {
                        CVWrapper cvWrapper = new CVWrapper(cv.C_Value__c, cv.V_Value__c);
                        wrapper.cvList.add(cvWrapper);
                    }
                }
                cvListWrappers.add(wrapper);
            }
        }
        return cvListWrappers;
    }

    /**
     * QuoteLineItem 데이터를 가져옵니다.
     */
    private static List<CharacteristicValue__c> getQuoteLineItem(Set<Id> qItemIds) {
        List<CharacteristicValue__c> cvList = [
            SELECT  Id
                    , C_Value__c
                    , V_Value__c
                    , QuoteLineItem__c
            FROM CharacteristicValue__c
            WHERE QuoteLineItem__c IN :qItemIds
        ];

        return cvList;
    }

    /* ***************************************************************************** SQ Review ***************************************************************************** */
    /* ********************************************************************************************************************************************************************* */

    /**
     * 리뷰 SQ를 생성합니다.
     */
    @AuraEnabled
    public static Map<String, String> createReviewSQ(String recordId) {
        Map<String, String> resMap = new Map<String, String>();
        try {
            List<RequestedSQ__c> rsqList = [
                SELECT  Id
                        , Name
                        , IsFirst__c
                        , PreshipmentReview__c
                        , DesignReviewRequired__c
                        , DeliveryDate_months__c
                        , Description__c
                        , Category__c
                        , CurrencyIsoCode
                        , IsReview__c
                FROM RequestedSQ__c
                WHERE SQRegistration__c = :recordId
                ORDER BY CreatedDate ASC
            ];

            List<SQ_Registration_Junction__c> sqrJunctionList = [
                SELECT  Id
                        , FM_ProductId__c
                        , QuoteLineItem__r.Product2.Model__c
                FROM SQ_Registration_Junction__c
                WHERE SQRegistration__c = :recordId
            ];

            Set<Id> productIds = new Set<Id>();
            if(!sqrJunctionList.isEmpty()) {
                for(SQ_Registration_Junction__c sqrJunction : sqrJunctionList) {
                    productIds.add(sqrJunction.QuoteLineItem__r.Product2.Model__c);
                }
            }

            List<Product_Representative__c> prList = new List<Product_Representative__c>();
            if(!productIds.isEmpty()) {
                prList = [
                    SELECT  Id
                            , User__c
                            , ControlUser__c
                    FROM Product_Representative__c
                    WHERE Model__c IN :productIds
                ];
            }

            if(prList.isEmpty()) {
                resMap.put('flag', 'Error');
                resMap.put('message', System.Label.DNS_REVIEW_T_NOTREPR);
                return resMap;
            }
            
            if(!rsqList.isEmpty()) {
                List<SQReview__c> insertList = new List<SQReview__c>();
                // Integer repIndex = 0;

                for(RequestedSQ__c rsq : rsqList) {
                    if(rsq.Category__c != '입회검사' && rsq.IsReview__c) {
                        for(Integer i = 0; i < 2; i++) {
                            SQReview__c review = new SQReview__c();
                            review.RequestedSQ__c           = rsq.Id;
                            review.SQTitle__c               = rsq.Name;
                            review.Description__c           = rsq.Description__c;
                            review.Category__c              = rsq.Category__c;
                            review.SQRegistration__c        = recordId;
                            review.CurrencyIsoCode          = rsq.CurrencyIsoCode;
                            review.Product_Representative__c = prList[0].Id;
                            review.Type__c = 'SQ';
                            if(i == 0) {
                                review.OwnerId = prList[0].User__c;
                                review.Part__c = '기계';
                            } else {
                                review.OwnerId = prList[0].ControlUser__c;
                                review.Part__c = '제어';
                            }
                            insertList.add(review);
    
                        }
                    } else {
                        SQReview__c review = new SQReview__c();
                        review.RequestedSQ__c           = rsq.Id;
                        review.SQTitle__c               = rsq.Name;
                        review.Description__c           = rsq.Description__c;
                        review.Category__c              = rsq.Category__c;
                        review.SQRegistration__c        = recordId;
                        review.CurrencyIsoCode          = rsq.CurrencyIsoCode;
                        review.IsReview__c              = false;
                        review.Type__c = 'SQ';

                        insertList.add(review);
                    }
                }
                updateStageReview(recordId);
                if(!insertList.isEmpty()) {
                    insert insertList;
                } 
                
                resMap.put('flag', 'Success');
                resMap.put('message', System.Label.DNS_REVIEW_T_COMPLETE);
            } else {
                resMap.put('flag', 'Error');
                resMap.put('message', System.Label.DNS_REVIEW_T_EMPTY);
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'Error');
            resMap.put('message', System.Label.DNS_ACC_T_ADMIN);
        }
        return resMap;
    }

    /**
     * 리뷰 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> getReviewInitDatas(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('initDatas',             getReviewDatas(recordId));
            resMap.put('getSQTitleList',        getSQTitleList(recordId));
            resMap.put('getReviewRichText',     getRichTextValue(recordId));
            resMap.put('getUserFilter',         getUserFilter());
            resMap.put('getSalesUser',          getSalesUser(recordId));
            resMap.put('getReviewOwner',        getReviewOwner(recordId));
            resMap.put('checkReviewOwner',      checkReviewOwner(recordId));
            resMap.put('getReviewCurrentStage', getReviewCurrentStage(recordId));
            resMap.put('checkRndManager',       checkRndManager());
            resMap.put('checkWorker',           checkWorker());
            resMap.put('checkDNSAProfile',      checkDNSAProfile());
            resMap.put('checkJisajang',         checkJisajang());
            
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * DNSA 프로필 여부를 확인합니다.
     */
    private static Boolean checkDNSAProfile() {
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
        return profileName != null && profileName.contains('DNSA');
    }

    /**
     * R&D 매니저 여부를 확인합니다.
     */
    private static Boolean checkRndManager() {
        if(currentUser.UserRole.DeveloperName == 'RDPartnerManager' || currentUser.UserRole.DeveloperName == 'RD1') {
            return true;
        } else {
            return false;
        }
    }

    /**
     * 프로필을 확인하여 역할에 따라 값을 반환합니다.
     */
    private static String checkProfile() {
        User user = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(user.Profile.Name.contains('영업 지원') || user.Profile.Name.contains('영업 글로벌 팀원')) {
            return 'dns';
        } else if(user.Profile.Name.contains('DNSA Sales Support')) {
            return 'dnsa';
        } else {
            return 'no';
        }
    }

    /**
     * 리뷰 편집 레이아웃을 가져옵니다.
     */
    @AuraEnabled
    public static List<String> getReviewEditLayout() {
        List<String> result = new List<String>();
        for(Schema.FieldSetMember f : getReviewEditFields()) {
            result.add(f.getFieldPath());
        }
        return result;
    }

    /**
     * 리뷰 권한 초기화를 확인합니다.
     */
    @AuraEnabled
    public static Boolean reviewReqInit(String recordId) {
        Boolean result = false;
        SQRegistration__c sqr = [SELECT Id, Message_Group__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        if(sqr.Message_Group__c != null) {
            List<Message_Group_Junction__c> mgjList = [SELECT User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.Message_Group__c AND User__r.IsActive = true];
            if(!mgjList.isEmpty()) {
                for(Message_Group_Junction__c mgj : mgjList) {
                    if(mgj.User__c == UserInfo.getUserId()) result = true;
                }
            }
        }

        if(!result) {
            User u = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(u.Profile.Name == 'System Administrator' || u.Profile.Name == '시스템 관리자') result = true;
        }
        return result;
    }

    /**
     * 리뷰 편집 필드 세트를 가져옵니다.
     */
    private static List<Schema.FieldSetMember> getReviewEditFields() {
        List<Schema.FieldSetMember> result = new List<Schema.FieldSetMember>();
        result = SObjectType.SQReview__c.FieldSets.SQReviewEditLayout.getFields();
        return result;
    }

    /**
     * 리뷰 소유자를 가져옵니다.
     */
    private static String getReviewOwner(String recordId) {
        return currentUser.Id;
    }

    /**
     * 세일즈 사용자 여부를 확인합니다.
     */
    private static Boolean getSalesUser(String recordId) {
        SQRegistration__c sqr = [SELECT Id, Message_Group__c, DNSA_Sales_Team__c, RecordType.DeveloperName FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        List<Message_Group_Junction__c> mgjList = new List<Message_Group_Junction__c>();
        mgjList = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.Message_Group__c AND User__r.IsActive = true];
        if(!mgjList.isEmpty()) {
            for(Message_Group_Junction__c mgj : mgjList) {
                if(currentUser.Id == mgj.User__c) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * 리뷰 소유자 여부를 확인합니다.
     */
    private static Boolean checkReviewOwner(String recordId) {
        List<SQReview__c> sqr = [SELECT Id, OwnerId FROM SQReview__c WHERE SQRegistration__c = :recordId];
        if(!sqr.isEmpty()) {
            for(SQReview__c r : sqr) {
                if(r.OwnerId == currentUser.Id) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * SQ 리뷰 코멘트를 설정합니다.
     */
    @AuraEnabled
    public static string setSQReviewComments(String recordId) {
        try {
            SQReview__c review = [
                SELECT  Id
                        , Comments__c
                        , IsComplete__c
                FROM SQReview__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            review.Comments__c = '[SKIP] : 해당 사항 없음';
            review.IsComplete__c = true;
            update review;
            
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * 리뷰의 배경색을 설정하고 거절 사유를 기록합니다.
     */
    @AuraEnabled
    public static String setRejectBackGroundColor(String reviewId, Boolean color, String reason) {
        String result;
        try {
            List<SQReview__c> records = [
                SELECT  Id
                        , SQTitle__c
                        , Color__c 
                        , Product_Representative__c
                        , Product_Representative__r.User__c
                        , Product_Representative__r.ControlUser__c
                        , Product_Representative__r.User__r.Email
                        , Product_Representative__r.ControlUser__r.Email
                        , Product_Representative__r.ControlTeam__c
                        , Product_Representative__r.MachineTeam__c
                        , Product_Representative__r.MachineUserLeader__c
                        , Product_Representative__r.MachineLeaderEmail__c
                        , Product_Representative__r.ControlUserLeader__c
                        , Product_Representative__r.ControlLeaderEmail__c
                        , Part__c
                        , SQRegistration__c
                        , RequestedSQ__c
                        , OwnerId
                        , FM_TeamName__c
                FROM SQReview__c 
                WHERE Id = :reviewId
            ];
            List<SQReview__c> updateList = new List<SQReview__c>();
            for(SQReview__c record : records) {
                if(!record.Color__c) {
                    record.Color__c = color;
                    result = 'true';
                    updateList.add(record);
                }
            }
            
            if(!updateList.isEmpty()) update updateList;
            sendEmailRejectNotification(records[0], reason);
            sendRejectNotification(records[0].SQRegistration__c, records[0].SQTitle__c, records[0]);

            if(records[0].RequestedSQ__c != null) {
                RequestedSQ__c req = [SELECT RejectReason__c, IsReRequest__c FROM RequestedSQ__c WHERE Id = :records[0].RequestedSQ__c LIMIT 1];
                req.RejectReason__c = req.RejectReason__c != null ? req.RejectReason__c + '\n' + '- ' + reason : '- ' + reason; 
                req.IsReRequest__c = true;
                update req;
            }

            return result;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * SQ 리뷰 검색 초기화를 확인합니다.
     */
    @AuraEnabled
    public static Boolean searchSQReviewInit() {
        try {
            if(currentUser.IsPortalEnabled && (currentUser.Profile.Name != 'R&D' && currentUser.Profile.Name != 'R&D Login')) {
                return true;
            }
            return false;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * SQ 리뷰를 검색합니다.
     */
    @AuraEnabled
    public static List<SearchModalWrapper> searchSQReview(String keyword, String modelName, String recordId) {
        List<SearchModalWrapper> wrapperList = new List<SearchModalWrapper>();
        
        try {
            String  queryString  = 'SELECT Id, SQTitle__c, Comments__c, Description__c, KRWcost__c, SQRegistration__c, Category__c, DesignReviewRequired__c, SQRegistration__r.Model__c';
            queryString += ', SalesPrice__c, IsFirst__c, PreShipmentReview__c, DeliveryDate_months__c, FM_Team__c, Product_Representative__r.Name, ReviewApprovalDate__c, Part__c,';
            queryString += ' Product_Representative__r.ControlTeam__c, Product_Representative__r.ControlUser__r.Name, Product_Representative__r.MachineTeam__c, Product_Representative__r.User__r.Name ';
            queryString +=' FROM SQReview__c';

            if(String.isNotBlank(modelName)) {
                queryString += '\n WHERE SQRegistration__r.Model__c = :modelName';    
            }
            queryString += '\n ORDER BY CreatedDate DESC';
            List<SQReview__c> reqSq = DataBase.query(queryString);

            for(SQReview__c record : reqSq) {
                if(
                    record.SQTitle__c.contains(keyword) ||
                    (record.Comments__c != null && record.Comments__c.contains(keyword))
                ) {
                    SearchModalWrapper sw = new SearchModalWrapper();
                    sw.id               = record.Id;
                    sw.sqTitle          = record.SQTitle__c;
                    sw.description      = decodeHtml(removeHtmlTags(record.Description__c));
                    sw.descriptionHtml  = record.Description__c;
                    sw.comments         = decodeHtml(removeHtmlTags(record.Comments__c));
                    sw.commentsHtml     = record.Comments__c;
                    sw.krwCost          = record.KRWcost__c;
                    sw.salesPrice       = record.SalesPrice__C;
                    sw.sqCategory       = record.Category__c;
                    sw.isFirst          = record.IsFirst__c;
                    sw.designReview     = record.DesignReviewRequired__c;
                    sw.preShipmentReview    = record.PreShipmentReview__c;
                    sw.deliveryDate     = record.DeliveryDate_months__c;
                    sw.reviewDate       = record.ReviewApprovalDate__c;
                    sw.modelName        = record.SQRegistration__r.Model__c;
                    sw.team             = record.Part__c  == '기계' ? record.Product_Representative__r.MachineTeam__c : record.Product_Representative__r.ControlTeam__c;
                    sw.repr             = record.Part__c  == '기계' ? record.Product_Representative__r.User__r.Name : record.Product_Representative__r.ControlUser__r.Name;
                    wrapperList.add(sw);
                }
            }
            if(recordId != null) insertSQSearchHistory(keyword, modelName, recordId);

            return wrapperList;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * SQ 리뷰 편집 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> getSQReviewEditInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getTypePicklist', getReviewTypePicklist());
            resMap.put('getReviewDatas', getReviewEditDatas(recordId));

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * SQ 리뷰를 삽입합니다.
     */
    @AuraEnabled
    public static string insertSQReview(List<Map<String, String>> records, String recordId) {
        try {
            List<SQReview__c> recordsToInsert = new List<SQReview__c>();
            List<RequestedSQ__c> reqInsert = new List<RequestedSQ__c>();

            SQRegistration__c sqr = [
                SELECT  Id
                        , BaseCode__r.Model__c
                        , CurrencyIsoCode
                FROM SQRegistration__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            List<Product_Representative__c> prjList = [
                SELECT  Id
                        , Product__c
                        , User__c
                        , ControlUser__c
                FROM Product_Representative__c
                WHERE Model__c = :sqr.BaseCode__r.Model__c
            ];

            List<String> partList = new List<String>();
            if(!prjList.isEmpty()) {
                for(Product_Representative__c prj : prjList) {
                    partList.add(prj.Id);
                }
            }

            List<RequestedSQ__c> reqInsertList = new List<RequestedSQ__c>();
            Map<String, String> rqeMap = new Map<String, String>();
            Integer i = 0;

            for(Integer j = 0; j < records.size(); j++) {
                System.debug('records ::: ' + records[j]);
            }
            for (Map<String, String> recordData : records) {
                if(i == 2) i = 0;
                if(i == 0) {
                    RequestedSQ__c req = new RequestedSQ__c();
                    req.Name = recordData.get('title');
                    req.CurrencyIsoCode = sqr.CurrencyIsoCode;
                    req.SQRegistration__c = recordId;
                    req.Category__c = '기타';
                    reqInsertList.add(req);
                }
                i += 1;
            }
            if(!reqInsertList.isEmpty()) {
                insert reqInsertList;
            } 
            if(!reqInsertList.isEmpty()) {
                for(RequestedSQ__c reqsq : reqInsertList) {
                    rqeMap.put(reqsq.Name, reqsq.Id);
                }
            } 

            i = 0;
            for (Map<String, String> recordData : records) {
                if(i == 2) i = 0;

                SQReview__c record = new SQReview__c();
                record.SQTitle__c           = recordData.get('title');
                record.Type__c              = recordData.get('type');
                record.CurrencyIsoCode      = sqr.CurrencyIsoCode;
                record.SQRegistration__c    = recordId;
                record.RequestedSQ__c       =  rqeMap.get(recordData.get('title'));
                if(recordData.get('type') == 'SQ') {
                    record.Product_Representative__c = partList[0];
                    if(i == 0) {
                        record.OwnerId = prjList[0].User__c;
                        record.Part__c = '기계';
                    } else {
                        record.OwnerId = prjList[0].ControlUser__c;
                        record.Part__c = '제어';
                    }
                }
                recordsToInsert.add(record);
                i += 1;

            }
            if(!recordsToInsert.isEmpty()) insert recordsToInsert;
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * SQ 리뷰를 삭제합니다.
     */
    @AuraEnabled
    public static string deleteSQReview(List<String> recordIds) {
        try {
            List<SQReview__c> reviews = [
                SELECT Id
                FROM SQReview__c
                WHERE Id IN :recordIds
            ];
            if(!reviews.isEmpty()) DN_WithoutSharingClass.deleteSQReview(reviews);
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * SQ 리뷰를 초기화합니다.
     */
    @AuraEnabled
    public static string clearSQReview(String recordId1, String recordId2) {
        try {
            List<SQReview__c> reviews = [
                SELECT Id, RequestedSQ__c
                FROM SQReview__c
                WHERE Id = :recordId1
                OR Id = :recordId2
            ];
            if(!reviews.isEmpty()) {
                RequestedSQ__c req = [SELECT Id, IsReview__c, RejectReason__c FROM RequestedSQ__c WHERE Id = :reviews[0].RequestedSQ__c LIMIT 1];
                req.IsReview__c = false;
                req.RejectReason__c = null;
                update req;
                DN_WithoutSharingClass.deleteSQReview(reviews);
            } 
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * SQ 리뷰를 재요청합니다.
     */
    @AuraEnabled
    public static string reRequestSQReview(String recordId1) {
        try {
            List<SQReview__c> reviews = [
                SELECT  Id
                        , SQTitle__c
                        , Color__c
                        , Product_Representative__c
                        , Product_Representative__r.User__c
                        , Product_Representative__r.ControlUser__c
                        , Product_Representative__r.User__r.Email
                        , Product_Representative__r.ControlUser__r.Email
                        , Product_Representative__r.ControlTeam__c
                        , Product_Representative__r.MachineTeam__c
                        , Product_Representative__r.ControlEmail__c
                        , Product_Representative__r.MachineEmail__c
                        , Part__c
                        , SQRegistration__c
                        , RequestedSQ__c
                        , OwnerId
                        , FM_TeamName__c
                FROM SQReview__c
                WHERE Id = :recordId1
            ];

            if(!reviews.isEmpty()) {
                RequestedSQ__c reqSQ = [SELECT Id, IsReRequest__c FROM RequestedSQ__c WHERE Id = :reviews[0].RequestedSQ__c LIMIT 1];
                Set<Id> RepresentativeIds = new Set<Id>();
                String sqrId = '';
                for(SQReview__c review : reviews) {
                    if(review.Product_Representative__c != null) {
                        RepresentativeIds.add(review.Product_Representative__c);
                        sqrId = review.SQRegistration__c;
                    }
                }
                if(!reviews.isEmpty()) sendEmailNotification(recordId1, 'Re Review');
                if(!reviews.isEmpty()) sendReNotification(reviews[0]);

                List<SQReview__c> updateList = new List<SQReview__c>();
                for(SQReview__c review : reviews) {
                    review.Color__c = false;
                    updateList.add(review);
                }
                update updateList;

                if(reqSQ.IsReRequest__c) {
                    reqSQ.IsReRequest__c = false;
                    update reqSQ;
                }
            }

            return 'Success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * 매니저 검색 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static List<ManagerWrapper> searchManagerInit() {
        List<ManagerWrapper> managerList = new List<ManagerWrapper>();
        try {
            List<User> userList = [SELECT Id, Name, Department FROM User WHERE Profile.Name LIKE 'R&D%' AND IsActive = true ORDER BY Name];

            // MachineTeam__c 결과 처리
            for (User  u : userList) {
                managerList.add(new ManagerWrapper(
                    u.Id,
                    u.Name,
                    u.Department,
                    ''
                ));
            }

            return managerList;
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 매니저를 검색합니다.
     */
    @AuraEnabled
    public static List<ManagerWrapper> searchManager(String keyword) {
        List<ManagerWrapper> managerList = new List<ManagerWrapper>();
        try {
            String queryString = 'SELECT Id, Name, Department FROM User WHERE Profile.Name LIKE \'R&D%\' AND IsActive = true';
            if (String.isNotBlank(keyword)) {
                queryString += ' AND Name LIKE \'%' + String.escapeSingleQuotes(keyword) + '%\'';
            }
            queryString += ' ORDER BY Name';
            List<User> managers = Database.query(queryString);
    
            for (User manager : managers) {
                managerList.add(new ManagerWrapper(
                    manager.Id,
                    manager.Name,
                    manager.Department,
                    ''
                ));
            }
    
            return managerList;
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }  

    /**
     * 리뷰 매니저를 변경합니다.
     */
    @AuraEnabled
    public static string setChangeReviewManager(String reviewId, List<ManagerWrapper> selectedRows) {
        try {
            SQReview__c review = [
                SELECT  Id
                        , SQTitle__c
                        , Product_Representative__c
                        , Product_Representative__r.User__c
                        , Product_Representative__r.ControlUser__c
                        , Product_Representative__r.User__r.Email
                        , Product_Representative__r.ControlUser__r.Email
                        , Product_Representative__r.ControlTeam__c
                        , Product_Representative__r.MachineTeam__c
                        , Product_Representative__r.ControlEmail__c
                        , Product_Representative__r.MachineEmail__c
                        , Part__c
                        , SQRegistration__c
                        , OwnerId
                FROM SQReview__c
                WHERE Id = :reviewId
                LIMIT 1
            ];

            review.OwnerId = selectedRows[0].id;
            update review;
            sendEmailNotification(reviewId, 'manager');
            sendAlertNotification(reviewId, 'manager');
            
            return 'Success';
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * 리뷰 설명 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static string getDescriptionData(String recordId) {
        try {
            SQReview__c sqr = [SELECT Id, Description__c FROM SQReview__c WHERE Id = :recordId LIMIT 1];
            return sqr.Description__c;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * SQ 리뷰 설명을 설정합니다.
     */
    @AuraEnabled
    public static string setSQReviewDescription(String recordId, String recordId2, String description) {
        try {
            List<SQReview__c> sqrList = [SELECT Id, Description__c FROM SQReview__c WHERE Id = :recordId OR Id = :recordId2];
            if(!sqrList.isEmpty()) {
                List<SQReview__c> updateList = new List<SQReview__c>();
                for(SQReview__c sqr : sqrList) {
                    sqr.Description__c = description;
                    updateList.add(sqr);
                }
                update updateList;
                return 'Success';
            } else {
                return 'empty';
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * 현재 리뷰 단계(stage)를 가져옵니다.
     */
    private static String getReviewCurrentStage(String recordId) {
        SQRegistration__c sqr = [SELECT Stage__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        return sqr.Stage__c;
    }

    /**
     * 리뷰 단계(stage)를 업데이트합니다.
     */
    private static void updateStageReview(String recordId) {
        SQRegistration__c sqReg = [SELECT Id, Stage__c, isReview__c, Manager__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
        sqReg.Stage__c = 'R&D Review';
        sqReg.Manager__c = UserInfo.getUserId();
        sqReg.isReview__c = true;
        update sqReg;
        return;
    }

    /**
     * 리뷰 데이터를 가져옵니다.
     */
    private static Map<String, List<SQReview__c>> getReviewDatas(String recordId) {
        Map<String, List<SQReview__c>> groupedReviewsByTitle = new Map<String, List<SQReview__c>>();

        List<SQReview__c> sqReviewList = [
            SELECT  Id
                    , SQTitle__c
                    , Product_Representative__r.User__r.Name
                    , Product_Representative__r.MachineTeam__c
                    , Product_Representative__r.ControlUser__r.Name
                    , Product_Representative__r.ControlTeam__c
                    , FM_Team__c
                    , Comments__c
                    , IsFirst__c
                    , PreShipmentReview__c
                    , DesignReviewRequired__c
                    , DeliveryDate_months__c
                    , KRWcost__c
                    , SalesPrice__c
                    , FM_Part__c
                    , Color__c
                    , Type__c
                    , OwnerId
                    , Owner.Name
                    , FM_TeamName__c
                    , RequestedSQ__c
                    , IsReview__c
                    , IsComplete__c
                    , Material_Cost__c
                    , Assembly_Cost__c
            FROM SQReview__c
            WHERE SQRegistration__c = :recordId
            AND Category__c != '입회검사'
            AND IsReview__c = true
            ORDER BY CreatedDate ASC
        ];

        if(!sqReviewList.isEmpty()) {
            for(SQReview__c review : sqReviewList) {
                if (!groupedReviewsByTitle.containsKey(review.RequestedSQ__c)) {
                    groupedReviewsByTitle.put(review.RequestedSQ__c, new List<SQReview__c>());
                }
                groupedReviewsByTitle.get(review.RequestedSQ__c).add(review);
            }
        }
        return groupedReviewsByTitle;
    }

    /**
     * SQ 완료 상태를 설정합니다.
     */
    @AuraEnabled
    public static string setComplete(String recordId) {
        try {
            List<SQReview__c> reviews = [
                SELECT Id, IsComplete__c
                FROM SQReview__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            if(!reviews.isEmpty()) {
                reviews[0].IsComplete__c = true;
                update reviews;
            }

        } catch (Exception e) {
            return e.getMessage();
        }
        return 'Success';
    }

    /**
     * SQ 타이틀 리스트를 가져옵니다.
     */
    private static Set<Id> getSQTitleList(String recordId) {
        Set<Id> result = new Set<Id>();
        List<SQReview__c> sqReviewList = [
            SELECT  Id
                    , SQTitle__c
                    , RequestedSQ__c
            FROM SQReview__c
            WHERE SQRegistration__c = :recordId
            AND Category__c != '입회검사'
            AND IsReview__c = true
            ORDER BY CreatedDate ASC
        ];
        if(!sqReviewList.isEmpty()) {
            for(SQReview__c review: sqReviewList) {
                result.add(review.RequestedSQ__c);
            }
        }
        return result;
    }

    /**
     * 리뷰 타입 픽리스트를 가져옵니다.
     */
    private static List<PicklistWrapper> getReviewTypePicklist() {
        List<PicklistWrapper> picklistValues        = new List<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult      = Schema.SObjectType.SQReview__c.fields.getMap().get('Type__c').getDescribe();
        List<Schema.PicklistEntry> picklistEntries  = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(new PicklistWrapper(entry.getLabel(), entry.getValue()));
        }
        return picklistValues;
    }

    /**
     * 리뷰 편집 데이터를 가져옵니다.
     */
    private static List<SQReviewWrapper> getReviewEditDatas(String recordId) {
        List<SQReviewWrapper> reviewWrappers = new List<SQReviewWrapper>();
    
        List<SQReview__c> reviews = [
            SELECT Id, SQTitle__c, Type__c
            FROM SQReview__c
            WHERE SQRegistration__c = :recordId
            AND Category__c != '입회검사'
            AND IsReview__c = true
            ORDER BY CreatedDate ASC
        ];
    
        for (Integer i = 0; i < reviews.size(); i++) {
            SQReview__c currentReview = reviews[i];
            SQReviewWrapper wrapper = new SQReviewWrapper();
    
            wrapper.Id1 = currentReview.Id;
            wrapper.title = currentReview.SQTitle__c;
            wrapper.type = currentReview.Type__c;
    
            if (i + 1 < reviews.size() && reviews[i + 1].SQTitle__c == currentReview.SQTitle__c) {
                wrapper.Id2 = reviews[i + 1].Id;
                i++;
            }
    
            reviewWrappers.add(wrapper);
        }
        
        return reviewWrappers;
    }

    /**
     * 이메일 거절 알림을 전송합니다.
     */
    private static void sendEmailRejectNotification(SQReview__c review, String reason) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();
        Map<String, Boolean> emailToIsPortalUser = new Map<String, Boolean>();
    
        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        String crmUrl = URL.getOrgDomainURL().toExternalForm();
    
        SQRegistration__c sqReg = [
            SELECT Id, Name, Representative__c, Message_Group__c, OwnerId, Manager__c, DNSA_Sales_Team__c, CreatedById
            FROM SQRegistration__c
            WHERE Id = :review.SQRegistration__c
            LIMIT 1
        ];
    
        List<Message_Group_Junction__c> mgjList = [
            SELECT User__c, FM_UserEmail__c, FM_UserProfile__c, FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c = :sqReg.Message_Group__c
            AND User__r.IsActive = true
        ];
    
        User owner = DN_WithoutSharingClass.getUserEmail(sqReg.CreatedById);
        List<User> userList = DN_WithoutSharingClass.getProfileUser('영업 지사장');
    
        if (sqReg.DNSA_Sales_Team__c != null) {
            User manager = DN_WithoutSharingClass.getUserEmail(sqReg.Manager__c);
            receiverEN.add(manager.Email);
            emailToIsPortalUser.put(manager.Email, false);
        }
    
        if(!mgjList.isEmpty()) {
            for (Message_Group_Junction__c mgj : mgjList) {
                Boolean isPortalUser = false;
                if (mgj.FM_UserLanguage__c == 'ko') {
                    receiver.add(mgj.FM_UserEmail__c);
                } else {
                    receiverEN.add(mgj.FM_UserEmail__c);
                }
                emailToIsPortalUser.put(mgj.FM_UserEmail__c, isPortalUser);
            }
        }
    
        for (User user : userList) {
            if (user.SalesOffice__c == owner.SalesOffice__c) {
                Boolean isPortalUser = true;
                if (user.LanguageLocaleKey == 'ko') {
                    receiver.add(user.Email);
                } else {
                    receiverEN.add(user.Email);
                }
                emailToIsPortalUser.put(user.Email, isPortalUser);
            }
        }
    
        User userManager = DN_WithoutSharingClass.getUserEmail(review.OwnerId);
        if(userManager.ManagerId != null) {
            receiver.add(userManager.Manager.Email);
            emailToIsPortalUser.put(userManager.Manager.Email, false);
        }
    
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'SQ Review Reject Alert' LIMIT 1];
    
        if (!am.isEmpty()) {
            if (!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Email';
                history.elementList.add(review.SQTitle__c);
                history.elementList.add(review.FM_TeamName__c != null ? review.FM_TeamName__c : '');
                history.elementList.add(sqReg.Name);
                history.elementList.add(reason);
                Boolean hasPortalUser = false;
                for (String email : receiver) {
                    if (emailToIsPortalUser.get(email)) {
                        hasPortalUser = true;
                        break;
                    }
                }
                String url = hasPortalUser ? baseUrl : crmUrl;
                history.elementList.add(url + '/' + sqReg.Id);
                history.alertID = am[0].Id;
                history.targetID = sqReg.Id;
                history.receiverforEmail = receiver;
                history.alertLanguage = 'ko';
                ahwList.add(history);
            }
    
            if (!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Email';
                history.elementList.add(review.SQTitle__c);
                history.elementList.add(review.FM_TeamName__c != null ? review.FM_TeamName__c : '');
                history.elementList.add(sqReg.Name);
                history.elementList.add(reason);
                Boolean hasPortalUser = false;
                for (String email : receiverEN) {
                    if (emailToIsPortalUser.get(email)) {
                        hasPortalUser = true;
                        break;
                    }
                }
                String url = hasPortalUser ? baseUrl : crmUrl;
                history.elementList.add(url + '/' + sqReg.Id);
                history.alertID = am[0].Id;
                history.targetID = sqReg.Id;
                history.receiverforEmail = receiverEN;
                history.alertLanguage = 'en';
                ahwList.add(history);
            }
    
            // Run alert event
            if (!ahwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(ahwList);
            }
        }
    }

    /**
     * 거절 알림을 전송합니다.
     */
    private static void sendRejectNotification(String sqrId, String name, SQReview__c review) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'SQ Review Reject Alert' LIMIT 1];
        
        SQRegistration__c sqReg = [
            SELECT  Id
                    , Name
                    , OwnerId
                    , Message_Group__c
                    , Manager__c
                    , DNSA_Sales_Team__c
            FROM SQRegistration__c
            WHERE Id = :sqrId
            LIMIT 1
        ];
        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c = :sqReg.Message_Group__c
            AND User__r.IsActive = true
        ];
        User owner = DN_WithoutSharingClass.getUserEmail(sqReg.OwnerId);
        List<User> userList = DN_WithoutSharingClass.getProfileUser('영업 지사장');

        if(sqReg.DNSA_Sales_Team__c != null) {
            receiverEN.add(sqReg.Manager__c);
        }

        if(!mgjList.isEmpty()) {
            for(Message_Group_Junction__c mgj : mgjList) {
                if(mgj.FM_UserLanguage__c == 'ko') {
                    receiver.add(mgj.User__c);
                } else {
                    receiverEN.add(mgj.User__c);
                }
            }
        }
        if(!userList.isEmpty()) {
            for(User user : userList) {
                if(user.SalesOffice__c == owner.SalesOffice__c) {
                    if(user.LanguageLocaleKey == 'ko') {
                        receiver.add(user.Id);
                    } else {
                        receiverEN.add(user.Id);
                    }
                }
            }
        }

        User userManager = DN_WithoutSharingClass.getUserEmail(review.OwnerId);
        receiver.add(userManager.ManagerId);


        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(name);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforID   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }

            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(name);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforID   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 재검토 알림을 전송합니다.
     */
    private static void sendReNotification(SQReview__c review) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();

        receiver.add(review.OwnerId);

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Re Review SQ Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(review.SQTitle__c);
                history.alertID         = am[0].Id;
                history.targetID        = review.SQRegistration__c;
                history.receiverforID   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 이메일 알림을 전송합니다.
     */
    private static void sendEmailNotification(String reviewId, String type) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();

        SQReview__c review = [
                SELECT  Id
                        , SQTitle__c
                        , Product_Representative__c
                        , Product_Representative__r.ControlEmail__c
                        , Product_Representative__r.MachineEmail__c
                        , Part__c
                        , SQRegistration__c
                        , OwnerId
                        , FM_TeamName__c
                FROM SQReview__c
                WHERE Id = :reviewId
                LIMIT 1
            ];

        User u = DN_WithoutSharingClass.getUserEmail(review.OwnerId);
        receiver.add(u.Email);

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');

        List<AlertManager__c> am = new List<AlertManager__c>();
        if(type == 'Re Review') {
            am = [SELECT Id FROM AlertManager__c WHERE Name = 'Re Review SQ Alert' LIMIT 1];
        } else if(type == 'manager') {
            am = [SELECT Id FROM AlertManager__c WHERE Name = 'Change SQ Review Manager' LIMIT 1];
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList.add(review.SQTitle__c);
                history.elementList.add(baseUrl + '/' + review.SQRegistration__c);
                history.alertID             = am[0].Id;
                history.targetID            = review.SQRegistration__c;
                history.receiverforEmail    = receiver;
                history.alertLanguage       = 'ko';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 알림을 전송합니다.
     */
    private static void sendAlertNotification(String reviewId, String type) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();

        SQReview__c review = [
                SELECT  Id
                        , SQTitle__c
                        , Product_Representative__c
                        , Product_Representative__r.ControlUser__c
                        , Product_Representative__r.User__c
                        , Part__c
                        , SQRegistration__c
                        , OwnerId
                FROM SQReview__c
                WHERE Id = :reviewId
                LIMIT 1
            ];

        receiver.add(review.OwnerId);

        List<AlertManager__c> am = new List<AlertManager__c>();
        if(type == 'Re Review') {
            am = [SELECT Id FROM AlertManager__c WHERE Name = 'Re Review SQ Alert' LIMIT 1];
        } else if(type == 'manager') {
            am = [SELECT Id FROM AlertManager__c WHERE Name = 'Change SQ Review Manager' LIMIT 1];
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Notification';
                history.elementList.add(review.SQTitle__c);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + review.SQRegistration__c);
                history.alertID             = am[0].Id;
                history.targetID            = review.SQRegistration__c;
                history.receiverforID       = receiver;
                history.alertLanguage       = 'ko';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }
    
    /* ********************* */

    /**
     * Drop 권한을 확인합니다.
     */
    @AuraEnabled
    public static string checkDropAuth(String recordId) {
        String result = 'fail';
        try {
            User user = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            SQRegistration__c sqr = [SELECT Id, Message_Group__c, DNSA_Sales_Team__c, RecordType.DeveloperName, OwnerId, Stage__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            List<Message_Group_Junction__c> mgjList = new List<Message_Group_Junction__c>();
            if(sqr.RecordType.DeveloperName != 'DNSA') {
                mgjList = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.Message_Group__c AND User__r.IsActive = true];
            } else {
                mgjList = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.DNSA_Sales_Team__c AND User__r.IsActive = true];
            }

            if(user.Profile.Name == 'System Administrator' || user.Profile.Name == '시스템 관리자') {
                result = 'success';
            } else if(sqr.OwnerId == UserInfo.getUserId()) {
                result = 'success';
            } else {
                for(Message_Group_Junction__c mgj : mgjList) {
                    if(mgj.User__c == UserInfo.getUserId()) {
                        result = 'success';
                    }
                }
            }

            if(sqr.Stage__c == 'Drop') {
                result = 'Already';
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result =  'fail';
        }
        return result;
    }

    /**
     * SQ를 Drop 상태로 설정합니다.
     */
    @AuraEnabled
    public static string dropSQ(String recordId, String reason) {
        try {
            SQRegistration__c sqr = [SELECT Id, Stage__c, DropReason__c, DropDate__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            sqr.Stage__c = 'Drop';
            sqr.DropReason__c = reason;
            sqr.DropDate__c = Date.today();
            update sqr;

            List<SQ__c> sqList = [SELECT Id, IsDelete__c FROM SQ__c WHERE SQ_Registration__c = :recordId];
            if(!sqList.isEmpty()) {
                List<SQ__c> sqUpdateList = new List<SQ__c>();
                for(SQ__c sq : sqList) {
                    sq.IsDelete__c = true;
                    sqUpdateList.add(sq);
                }
                if(!sqUpdateList.isEmpty()) update sqUpdateList;
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
        return 'success';
    }

    /**
     * 완료 알림과 이메일을 전송합니다.
     */
    @AuraEnabled
    public static string sendCompleteNotiAndEmail(String recordId) {
        try {
            RequestedSQ__c req = [SELECT Id, IsRefineComplete__c FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];
            req.IsRefineComplete__c = true;
            update req;
            sendCompleteEmail(recordId);
            sendCompleteNoti(recordId);
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
        return 'success';
    }

    /**
     * SQ 확인 초기화를 확인합니다.
     */
    @AuraEnabled
    public static Boolean sqConfirmInite(String recordId) {
        Boolean result = false;
        try {
            SQRegistration__c sqr = [SELECT Id, DNSA_Sales_Team__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];
            if(sqr.DNSA_Sales_Team__c != null) {
                List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c FROM Message_Group_Junction__c  WHERE Message_Group__c = :sqr.DNSA_Sales_Team__c AND User__r.IsActive = true];
                for(Message_Group_Junction__c mgj : mgjList){
                    if(mgj.User__c == UserInfo.getUserId()) {
                        result = true;
                    }
                } 
            } else {
                result = true;
            }

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    /**
     * QuoteLineItem 목록을 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> getQuoteLineItems(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            List<SQ_QuoteLineitem_Junction__c> sqljList = [
                SELECT Id, QuoteLineItem__r.QuoteId, QuoteLineItem__c
                FROM SQ_QuoteLineitem_Junction__c 
                WHERE SQ__c = :recordId
                AND QuoteLineItem__r.Quote.Recently_Version__c = TRUE
            ];

            resMap = DN_QuoteLineItemsController.getQuoteLineItemList(sqljList[0].QuoteLineItem__r.QuoteId);
            resMap.put('qliid', sqljList[0].QuoteLineItem__c);

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * SQ QuoteLineItem을 복제합니다.
     */
    @AuraEnabled
    public static String cloneSQQuoteLineItem(String recordId, String originalId, String qliId) {
        try {
            System.debug('recordId::: ' + recordId);
            System.debug('originalId::: ' + originalId);
            System.debug('qliId::: ' + qliId);
            SQ_QuoteLineItem_Junction__c originalSqlj = [
                SELECT  Id,
                        IsERP__c,
                        SalesPrice__c
                FROM SQ_QuoteLineItem_Junction__c 
                WHERE SQ__c = :recordId 
                AND QuoteLineItem__c = :originalId 
                LIMIT 1
            ];

            System.debug('originalSqlj ::: ' + originalSqlj);
            QuoteLineItem qli = [SELECT Id, ERPQuotationNo__c FROM QuoteLineItem WHERE Id = :qliId LIMIT 1];
            SQ_QuoteLineItem_Junction__c clonedSqlj = originalSqlj.clone(false, true, false, false);
            clonedSqlj.SQ__c = recordId;
            clonedSqlj.QuoteLineItem__c = qliId;
            clonedSqlj.IsERP__c = false;
            clonedSqlj.SalesPrice__c = originalSqlj.SalesPrice__c;

            if (qli.ERPQuotationNo__c != null) {
                clonedSqlj.UPDATEFLAG__c = 'I';
            }

            System.debug('clonedSqlj ::: ' + clonedSqlj);
            insert clonedSqlj;
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            return 'Fail';
        }
    }

    /**
     * 완료 이메일을 전송합니다.
     */
    private static void sendCompleteEmail(String recordId) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();

        RequestedSQ__c reqSQ = [SELECT Id, Name, SQRegistration__c FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];

        SQRegistration__c sqReg = [
            SELECT  Id
                    , Name
                    , Representative__c
                    , Message_Group__c
                    , OwnerId
            FROM SQRegistration__c
            WHERE Id = :reqSQ.SQRegistration__c
            LIMIT 1
        ];
        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c = :sqReg.Message_Group__c
            AND User__r.IsActive = true
        ];

        if(!mgjList.isEmpty()) {
            for(Message_Group_Junction__c mgj : mgjList) {
                if(mgj.FM_UserLanguage__c == 'ko') {
                    receiver.add(mgj.FM_UserEmail__c);
                } else {
                    receiverEN.add(mgj.FM_UserEmail__c);
                }
            }
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Refine Complete Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList.add(reqSQ.Name);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                history.alertID             = am[0].Id;
                history.targetID            = sqReg.Id;
                history.receiverforEmail    = receiver;
                history.alertLanguage       = 'ko';
                ahwList.add(history);
            }

            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList.add(reqSQ.Name);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                history.alertID             = am[0].Id;
                history.targetID            = sqReg.Id;
                history.receiverforEmail    = receiverEN;
                history.alertLanguage       = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 완료 알림을 전송합니다.
     */
    private static void sendCompleteNoti(String recordId) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Refine Complete Alert' LIMIT 1];
        
        RequestedSQ__c reqSQ = [SELECT Id, Name, SQRegistration__c FROM RequestedSQ__c WHERE Id = :recordId LIMIT 1];
        SQRegistration__c sqReg = [
            SELECT  Id
                    , Name
                    , Representative__c
                    , Message_Group__c
                    , OwnerId
            FROM SQRegistration__c
            WHERE Id = :reqSQ.SQRegistration__c
            LIMIT 1
        ];
        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c = :sqReg.Message_Group__c
            AND User__r.IsActive = true
        ];

        if(!mgjList.isEmpty()) {
            for(Message_Group_Junction__c mgj : mgjList) {
                if(mgj.FM_UserLanguage__c == 'ko') {
                    receiver.add(mgj.User__c);
                } else {
                    receiverEN.add(mgj.User__c);
                }
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(reqSQ.Name);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforID   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }

            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(reqSQ.Name);
                history.alertID         = am[0].Id;
                history.targetID        = sqReg.Id;
                history.receiverforID   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 지사장 여부를 확인합니다.
     */
    private static Boolean checkJisajang() {
        if(currentUser.Profile.Name.contains('지사장')) {
            return true;
        }
        return false;
    }

    /**
     * HTML 태그를 제거합니다.
     */
    private static String removeHtmlTags(String html) {
        if(String.isNotBlank(html)) {
            return html.replaceAll('<.*?>', '');
        } else {
            return null;
        }
    }
    
    /**
     * HTML 엔티티를 디코딩합니다.
     */
    private static String decodeHtml(String text) {
        if (text == null) return null;
    
        Map<String, String> htmlEntities = new Map<String, String>{
            '&quot;' => '"',
            '&amp;' => '&',
            '&lt;' => '<',
            '&gt;' => '>',
            '&nbsp;' => ' ',
            '&iexcl;' => '¡',
            '&cent;' => '¢',
            '&pound;' => '£',
            '&curren;' => '¤',
            '&yen;' => '¥',
            '&brvbar;' => '¦',
            '&sect;' => '§',
            '&uml;' => '¨',
            '&copy;' => '©',
            '&ordf;' => 'ª',
            '&laquo;' => '«',
            '&not;' => '¬',
            '&shy;' => '­',
            '&reg;' => '®',
            '&macr;' => '¯',
            '&deg;' => '°',
            '&plusmn;' => '±',
            '&sup2;' => '²',
            '&sup3;' => '³',
            '&acute;' => '´',
            '&micro;' => 'µ',
            '&para;' => '¶',
            '&middot;' => '·',
            '&cedil;' => '¸',
            '&sup1;' => '¹',
            '&ordm;' => 'º',
            '&raquo;' => '»',
            '&frac14;' => '¼',
            '&frac12;' => '½',
            '&frac34;' => '¾',
            '&iquest;' => '¿',
            '&Agrave;' => 'À',
            '&Aacute;' => 'Á',
            '&Acirc;' => 'Â',
            '&Atilde;' => 'Ã',
            '&Auml;' => 'Ä',
            '&Aring;' => 'Å',
            '&AElig;' => 'Æ',
            '&Ccedil;' => 'Ç',
            '&Egrave;' => 'È',
            '&Eacute;' => 'É',
            '&Ecirc;' => 'Ê',
            '&Euml;' => 'Ë',
            '&Igrave;' => 'Ì',
            '&Iacute;' => 'Í',
            '&Icirc;' => 'Î',
            '&Iuml;' => 'Ï',
            '&ETH;' => 'Ð',
            '&Ntilde;' => 'Ñ',
            '&Ograve;' => 'Ò',
            '&Oacute;' => 'Ó',
            '&Ocirc;' => 'Ô',
            '&Otilde;' => 'Õ',
            '&Ouml;' => 'Ö',
            '&times;' => '×',
            '&Oslash;' => 'Ø',
            '&Ugrave;' => 'Ù',
            '&Uacute;' => 'Ú',
            '&Ucirc;' => 'Û',
            '&Uuml;' => 'Ü',
            '&Yacute;' => 'Ý',
            '&THORN;' => 'Þ',
            '&szlig;' => 'ß',
            '&agrave;' => 'à',
            '&aacute;' => 'á',
            '&acirc;' => 'â',
            '&atilde;' => 'ã',
            '&auml;' => 'ä',
            '&aring;' => 'å',
            '&aelig;' => 'æ',
            '&ccedil;' => 'ç',
            '&egrave;' => 'è',
            '&eacute;' => 'é',
            '&ecirc;' => 'ê',
            '&euml;' => 'ë',
            '&igrave;' => 'ì',
            '&iacute;' => 'í',
            '&icirc;' => 'î',
            '&iuml;' => 'ï',
            '&eth;' => 'ð',
            '&ntilde;' => 'ñ',
            '&ograve;' => 'ò',
            '&oacute;' => 'ó',
            '&ocirc;' => 'ô',
            '&otilde;' => 'õ',
            '&ouml;' => 'ö',
            '&divide;' => '÷',
            '&oslash;' => 'ø',
            '&ugrave;' => 'ù',
            '&uacute;' => 'ú',
            '&ucirc;' => 'û',
            '&uuml;' => 'ü',
            '&yacute;' => 'ý',
            '&thorn;' => 'þ',
            '&yuml;' => 'ÿ'
        };
    
        for (String key : htmlEntities.keySet()) {
            text = text.replace(key, htmlEntities.get(key));
        }
    
        return text;
    }

    /* Search결과 Wrapper */
    public class SearchModalWrapper {
        @AuraEnabled public String id                   { get;set; }
        @AuraEnabled public String baseCode             { get;set; }
        @AuraEnabled public String sqTitle              { get;set; }
        @AuraEnabled public String model                { get;set; }
        @AuraEnabled public String description          { get;set; }
        @AuraEnabled public String descriptionHover     { get;set; }
        @AuraEnabled public String descriptionHtml      { get;set; }
        @AuraEnabled public String comments             { get;set; }
        @AuraEnabled public String commentsHtml         { get;set; }
        @AuraEnabled public String sqType               { get;set; }
        @AuraEnabled public Decimal price               { get;set; }
        @AuraEnabled public Decimal krwCost             { get;set; }
        @AuraEnabled public Decimal listPrice           { get;set; }
        @AuraEnabled public Decimal dealerPrice         { get;set; }
        @AuraEnabled public Decimal salesPrice          { get;set; }
        @AuraEnabled public String sqCategory           { get;set; }
        @AuraEnabled public Boolean isFirst             { get;set; }
        @AuraEnabled public Boolean designReview        { get;set; }
        @AuraEnabled public Boolean preShipmentReview   { get;set; }
        @AuraEnabled public Decimal deliveryDate        { get;set; }
        @AuraEnabled public String isOrder              { get;set; }
        @AuraEnabled public Date reviewDate             { get;set; }
        @AuraEnabled public String team                 { get;set; }
        @AuraEnabled public String repr                 { get;set; }
        @AuraEnabled public String salesSQ              { get;set; }
        @AuraEnabled public String rndSQ                { get;set; }
        @AuraEnabled public String modelName            { get;set; }
        @AuraEnabled public Decimal month                { get;set; }
    }

    /* 요청 SQ 정보 Wrapper */
    public class RequestedSQWrapper {
        @AuraEnabled public String salesSQ      { get;set; }
        @AuraEnabled public String rndSQ        { get;set; }
        @AuraEnabled public String sqCategory   { get;set; }
        @AuraEnabled public String sqTitle      { get;set; }
        @AuraEnabled public String description  { get;set; }
        @AuraEnabled public String descriptionHtml  { get;set; }
        @AuraEnabled public Decimal price  { get;set; }
        @AuraEnabled public Decimal listPrice  { get;set; }
        @AuraEnabled public Decimal month  { get;set; }
    }

    /* picklist 내용 wrapper */
    public class PicklistWrapper {
        @AuraEnabled public String label  {get;set;}
        @AuraEnabled public String value  {get;set;}

        public PicklistWrapper() {}

        public PicklistWrapper(String Label, String Value) {
            this.label = Label;
            this.value = Value;
        }
    }

    /* 제품별 CV리스트 정보 Wrapper */
    public class CVListWrapper {
        @AuraEnabled public String productName      { get; set; }
        @AuraEnabled public List<CVWrapper> cvList  { get; set; }
    
        public CVListWrapper() {
            this.cvList = new List<CVWrapper>();
        }
    }

    /* CV 정보 Wrapper */
    public class CVWrapper {
        @AuraEnabled public String characteristic { get; set; }
        @AuraEnabled public String value { get; set; }

        public CVWrapper(String characteristic, String value) {
            this.characteristic = characteristic;
            this.value = value;
        }
    }

    /* SQReview 정보 Wrapper */
    public class SQReviewWrapper {
        @AuraEnabled public Id Id1          { get; set; }
        @AuraEnabled public Id Id2          { get; set; }
        @AuraEnabled public String title    { get; set; }
        @AuraEnabled public String type     { get; set; }

        public SQReviewWrapper() {}
    }

    /* Manager 정보 Wrapper */
    public class ManagerWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String team { get; set; }
        @AuraEnabled public String part { get; set; }

        public ManagerWrapper() {}
    
        // 생성자 추가
        public ManagerWrapper(String id, String name, String team, String part) {
            this.id = id;
            this.name = name;
            this.team = team;
            this.part = part;
        }
    }
}