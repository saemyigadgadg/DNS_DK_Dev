/**
 * @author            : Yu-Hyun Park
 * @description       : Dealer KPI 엑셀 임포트 컨트롤러
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-29   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DN_ImportDealerKPIController {
    private static final Id   koreaYearRT       = SObjectType.DealerKPI__c.getRecordTypeInfosByDeveloperName().get('KoreaYear').getRecordTypeId();
    private static final Id   koreaHalfRT       = SObjectType.DealerKPI__c.getRecordTypeInfosByDeveloperName().get('KoreaHalf').getRecordTypeId();
    private static final Id   globalYearRT      = SObjectType.DealerKPI__c.getRecordTypeInfosByDeveloperName().get('GlobalYear').getRecordTypeId();
    private static final Id   globalQuarterRT   = SObjectType.DealerKPI__c.getRecordTypeInfosByDeveloperName().get('GlobalQuarter').getRecordTypeId();

    private static final Id   dealerRT      = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();


    // 로그인 사용자 정보 확인
    @AuraEnabled
    public static User getUserInfo() {

        try {
            // 현재 로그인된 사용자의 정보
            User userInfo = [
                SELECT SalesDistrict__c, SalesOrganization__c, SalesOffice__c, Profile.Name 
                FROM User 
                WHERE Id = :UserInfo.getUserId()
            ];

            // 디버그 로그에 정보 이름 출력
            System.debug('Login User Info: ' + userInfo);
            return userInfo;
            
        } catch (Exception e) {
            System.debug('Error in getUserInfo: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }

    }

    // KPI 메타데이터 조회
    @AuraEnabled
    public static List<String> getKPIMetadata(String templateType) {

        try {
            // Korea용 
            templateType = (templateType == 'KoreaYear' || templateType == 'KoreaHalf') ? 'Korea' : templateType;
    
            System.debug('templateType :: ' + templateType);
            System.debug('getKPIMetadata 호출');
    
            String query = 'SELECT Type__c, DeveloperName, MappingFieldAPI__c, ColumnName__c, Order__c FROM KPI__mdt';
    
            if(templateType != null && templateType != '') query += ' WHERE Type__c = \'' +  templateType + '\'';
    
            query += ' ORDER BY Order__c ASC';
    
            System.debug('query: ' + query);
    
    
            // 동적 쿼리 실행
            List<KPI__mdt> allMeta = Database.query(query);
    
            System.debug('allMeta: ' + allMeta);
    
            List<String> expectedHeaders = new List<String>();
    
            for (KPI__mdt meta : allMeta) {
                System.debug('meta: ' + meta);
                expectedHeaders.add(meta.ColumnName__c);
            }
    
            System.debug('expectedHeaders: ' + expectedHeaders);
            return expectedHeaders;

            
        } catch (Exception e) {

            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }

    }


    // 레코드 업서트
    @AuraEnabled
    public static String upsertRecords(String records, String templateType) {

        System.debug('upsertRecords Controller 진입 ::  ' );
        System.debug('records :: ' + records);
        System.debug('templateType :: ' + templateType);

        try{
            // JSON 문자열을 Map 형태로 역직렬화
            List<Object> recordObjects = (List<Object>) JSON.deserializeUntyped(records);
            List<Map<String, Object>> recordMaps = new List<Map<String, Object>>();
    
    
            System.debug('recordObjects :: ' + recordObjects);
    
            for (Object obj : recordObjects) {
                recordMaps.add((Map<String, Object>) obj);
            }
    
            System.debug('recordMaps :: ' + recordMaps);
    
            List<DealerKPI__c> upsertList = new List<DealerKPI__c>();
            // 기존 레코드 쿼리를 위한 Set
            Set<String> recordKeySet = new Set<String>();
            Set<String> customerCodeSet = new Set<String>();
    
            Integer rowNumber = 3; // 행 번호 추적
    
            for (Map<String, Object> recordMap : recordMaps) {

                rowNumber++; // 현재 행 번호 증가
    
                // customerCode : Column_0
                String customerCode = String.valueOf(recordMap.get('Column_0'));
                String recordType = String.valueOf(recordMap.get('TemplateType'));
                String year = String.valueOf(recordMap.get('Year'));
                String period = String.valueOf(recordMap.get('Period'));
    
                // Dealer Code가 없을 경우 에러 처리
                if (customerCode == null ||  String.isEmpty(customerCode) || customerCode == '0') {
                    String recordDetails = 'Undefined Dealer Code in Row ' + rowNumber;
                    System.debug('recordDetails :: ' + recordDetails);
                    return recordDetails;
                }
                
                // recordKey에 Period가 null이 아닐 때만 추가
                String recordKey = customerCode + '-' + recordType + '-' + year;
                if (period != null) {
                    recordKey += '-' + period;
                }
    
                System.debug('recordKey :: ' + recordKey);
                customerCodeSet.add(customerCode);
                recordKeySet.add(recordKey);
            }
    
            // Account 쿼리: CustomerCode__c에 해당하는 Account ID 조회
            Map<String, Account> accountIdMap = new Map<String, Account>();
            List<Account> accList = [SELECT Id, Name, CustomerCode__c FROM Account WHERE CustomerCode__c IN :customerCodeSet AND RecordTypeId =: dealerRT];
            for (Account acc : accList) {
                accountIdMap.put(acc.CustomerCode__c, acc);
            }
    
            // 기존 레코드 쿼리
            Map<String, DealerKPI__c> existingRecordsMap = new Map<String, DealerKPI__c>();
            List<DealerKPI__c> existingRecords = new List<DealerKPI__c>();
    
            //타입별 필드 분기처리
            if(templateType == 'KoreaYear' || templateType == 'KoreaHalf'){
                existingRecords = [
                    SELECT  Id, Dealer__c, Key__c,
                            Sales__c, SalesIncrease__c, RegularOrderRatio__c, SpecialDCRatio__c, CMComplianceRate__c, Subtotal_SalesProfit__c,
                            TradeCustomerCount__c, StrategicCustomersCount__c, Subtotal_Customer__c,
                            FulltimeEmployeesCount__c, ExclusiveDealersCount__c, Subtotal_DealerResource__c,
                            InquiriesCount__c, NormalOrderRate__c, OrderHitRate__c, Subtotal_SalesRoyalty__c,
                            WholesaleOverdueInterest__c, PolicyCompliance__c, Subtotal_Bonus__c, Total__c
                    FROM    DealerKPI__c
                    WHERE   Key__c IN: recordKeySet
                ];
    
            }else if(templateType == 'GlobalYear'){
                existingRecords = [
                    SELECT  Id, Dealer__c, Key__c,
                            AnnualOrderIntakeperProduct__c, RegularPriceOrderIntake__c, OrderIntakeforHighendProducts__c,
                            NoOfNewCustomersRatio__c, MarketSharebyterritory__c, CustomerSatisfaction__c, Total__c
    
                    FROM    DealerKPI__c
                    WHERE   Key__c IN: recordKeySet
                ];
    
            }else if(templateType == 'GlobalQuarter'){
                existingRecords = [
                    SELECT  Id, Dealer__c, Key__c,
                            NoOfSalesPersonnel__c, RegularPriceOrderIntake__c, NoOfExhibitionParticipation__c, ShowroomSize__c, 
                            NoOfNewCustomers__c, NoOfKeyAccounts__c, AEPersonnelToRevenueRatio__c, CSPersonnelToRevenueRatio__c, NoOfViolations__c,
                            OrderIntakeProportionAutomation__c, OrderIntakeforAutomation__c, OrderIntakeProportionHighend__c, 
                            OrderIntakeHighendProducts__c, OrderIntakeProportionPartsCS__c, OrderIntakeforPartsCS__c, 
                            OrderIntakeVersusTarget__c, DealerCreditAssessment__c, DelinquentPayments__c, Total__c
                    FROM    DealerKPI__c
                    WHERE   Key__c IN: recordKeySet
                ];
            }
    
            // Update 대상
            if(!existingRecords.isEmpty()){
                for (DealerKPI__c record : existingRecords) {
                    existingRecordsMap.put(record.Key__c, record);
                }
                
            }
    
            // 다시 행 번호 초기화
            rowNumber = 3; 
    
            // 레코드를 업데이트 또는 생성
            Map<String, DealerKPI__c> upsertMap = new Map<String, DealerKPI__c>(); // 중복 방지용 Map
            for (Map<String, Object> recordMap : recordMaps) {

                rowNumber++;

                // key 생성
                String customerCode = String.valueOf(recordMap.get('Column_0'));
                String recordType = String.valueOf(recordMap.get('TemplateType'));
                String year = String.valueOf(recordMap.get('Year'));
                String period = String.valueOf(recordMap.get('Period'));
    
                String recordKey = customerCode + '-' + recordType + '-' + year + (period != null ? '-' + period : '');
                
                if(existingRecordsMap.containsKey(recordKey)){
    
                    System.debug('<< update >>');
                    
                    // 기존 레코드 업데이트
                    DealerKPI__c existingRecord = existingRecordsMap.get(recordKey);
    
                    if(templateType == 'KoreaYear' || templateType == 'KoreaHalf'){
    
                        existingRecord.Sales__c                     = (recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0;
                        existingRecord.SalesIncrease__c             = (recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0;
                        existingRecord.RegularOrderRatio__c         = (recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0;
                        existingRecord.SpecialDCRatio__c            = (recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0;
                        existingRecord.CMComplianceRate__c          = (recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0;
                        existingRecord.Subtotal_SalesProfit__c      = (recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0;
                        existingRecord.TradeCustomerCount__c        = (recordMap.values()[9] != null) ? (Decimal) recordMap.values()[9] : 0;
                        existingRecord.StrategicCustomersCount__c   = (recordMap.values()[10] != null) ? (Decimal) recordMap.values()[10] : 0;
                        existingRecord.Subtotal_Customer__c         = (recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0;
                        existingRecord.FulltimeEmployeesCount__c    = (recordMap.values()[12] != null) ? (Decimal) recordMap.values()[12] : 0;
                        existingRecord.ExclusiveDealersCount__c     = (recordMap.values()[13] != null) ? (Decimal) recordMap.values()[13] : 0;
                        existingRecord.Subtotal_DealerResource__c   = (recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0;
                        existingRecord.InquiriesCount__c            = (recordMap.values()[15] != null) ? (Decimal) recordMap.values()[15] : 0;
                        existingRecord.NormalOrderRate__c           = (recordMap.values()[16] != null) ? (Decimal) recordMap.values()[16] : 0;
                        existingRecord.OrderHitRate__c              = (recordMap.values()[17] != null) ? (Decimal) recordMap.values()[17] : 0;
                        existingRecord.Subtotal_SalesRoyalty__c     = (recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0;
                        existingRecord.WholesaleOverdueInterest__c  = (recordMap.values()[19] != null) ? (Decimal) recordMap.values()[19] : 0;
                        existingRecord.PolicyCompliance__c          = (recordMap.values()[20] != null) ? (Decimal) recordMap.values()[20] : 0;
                        existingRecord.Subtotal_Bonus__c            = (recordMap.values()[21] != null) ? (Decimal) recordMap.values()[21] : 0;
                        
                        existingRecord.Total__c                     = ((recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0)
                                                                        + ((recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0)
                                                                        + ((recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0)
                                                                        + ((recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0)
                                                                        + ((recordMap.values()[21] != null) ? (Decimal) recordMap.values()[21] : 0);
                    
                    }else if(templateType == 'GlobalYear'){
                        existingRecord.AnnualOrderIntakeperProduct__c       = (recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0;
                        existingRecord.RegularPriceOrderIntake__c           = (recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0;
                        existingRecord.OrderIntakeforHighendProducts__c     = (recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0;
                        existingRecord.NoOfNewCustomersRatio__c             = (recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0;
                        existingRecord.MarketSharebyterritory__c            = (recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0;
                        existingRecord.CustomerSatisfaction__c              = (recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0;
                        
                        existingRecord.Total__c                             = ((recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0)
                                                                                + ((recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0)
                                                                                + ((recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0)
                                                                                + ((recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0)
                                                                                + ((recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0)
                                                                                + ((recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0);
    
                    }else if(templateType == 'GlobalQuarter'){
                        existingRecord.NoOfSalesPersonnel__c                = (recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0;
                        existingRecord.RegularPriceOrderIntake__c           = (recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0;
                        existingRecord.NoOfExhibitionParticipation__c       = (recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0;
                        existingRecord.ShowroomSize__c                      = (recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0;
                        existingRecord.NoOfNewCustomers__c                  = (recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0;
                        existingRecord.NoOfKeyAccounts__c                   = (recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0;
                        existingRecord.AEPersonnelToRevenueRatio__c         = (recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0;
                        existingRecord.CSPersonnelToRevenueRatio__c         = (recordMap.values()[9] != null) ? (Decimal) recordMap.values()[9] : 0;
                        existingRecord.NoOfViolations__c                    = (recordMap.values()[10] != null) ? (Decimal) recordMap.values()[10] : 0;
                        existingRecord.OrderIntakeProportionAutomation__c   = (recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0;
                        existingRecord.OrderIntakeforAutomation__c          = (recordMap.values()[12] != null) ? (Decimal) recordMap.values()[12] : 0;
                        existingRecord.OrderIntakeProportionHighend__c      = (recordMap.values()[13] != null) ? (Decimal) recordMap.values()[13] : 0;
                        existingRecord.OrderIntakeHighendProducts__c        = (recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0;
                        existingRecord.OrderIntakeProportionPartsCS__c      = (recordMap.values()[15] != null) ? (Decimal) recordMap.values()[15] : 0;
                        existingRecord.OrderIntakeforPartsCS__c             = (recordMap.values()[16] != null) ? (Decimal) recordMap.values()[16] : 0;
                        existingRecord.OrderIntakeVersusTarget__c           = (recordMap.values()[17] != null) ? (Decimal) recordMap.values()[17] : 0;
                        existingRecord.DealerCreditAssessment__c            = (recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0;
                        existingRecord.DelinquentPayments__c                = (recordMap.values()[19] != null) ? (Decimal) recordMap.values()[19] : 0;
    
                        existingRecord.Total__c                             = ((recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0)
                                                                                + ((recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0)
                                                                                + ((recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0)
                                                                                + ((recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0)
                                                                                + ((recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0)
                                                                                + ((recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0)
                                                                                + ((recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0)
                                                                                + ((recordMap.values()[9] != null) ? (Decimal) recordMap.values()[9] : 0)
                                                                                + ((recordMap.values()[10] != null) ? (Decimal) recordMap.values()[10] : 0)
                                                                                + ((recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0)
                                                                                + ((recordMap.values()[12] != null) ? (Decimal) recordMap.values()[12] : 0)
                                                                                + ((recordMap.values()[13] != null) ? (Decimal) recordMap.values()[13] : 0)
                                                                                + ((recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0)
                                                                                + ((recordMap.values()[15] != null) ? (Decimal) recordMap.values()[15] : 0)
                                                                                + ((recordMap.values()[16] != null) ? (Decimal) recordMap.values()[16] : 0)
                                                                                + ((recordMap.values()[17] != null) ? (Decimal) recordMap.values()[17] : 0)
                                                                                + ((recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0)
                                                                                + ((recordMap.values()[19] != null) ? (Decimal) recordMap.values()[19] : 0);
                    }
    
                    upsertMap.put(recordKey, existingRecord); 
    
                } else{
    
                    System.debug('<< insert >>');
                    // 새로운 레코드 생성
                    DealerKPI__c newRecord = new DealerKPI__c();
    
                    newRecord.Name = year + '-' + (period != null ? period : 'Annual');

                    Id dealerId = accountIdMap.containsKey(customerCode) ? accountIdMap.get(customerCode).Id : null;

                    if (dealerId == null) {
                        String recordDetails = 'Undefined Dealer Code in Row ' + rowNumber;
                        System.debug(recordDetails);
                        return recordDetails;
                    }

                    newRecord.Dealer__c = dealerId;
                    newRecord.Key__c = recordKey;
                    newRecord.Year__c = year;
    
                    if(period != null){
                        newRecord.PeriodType__c = period;
                    }
    
                    if(templateType == 'KoreaYear' || templateType == 'KoreaHalf'){
                        if(templateType == 'KoreaYear'){
                            newRecord.RecordTypeId = koreaYearRT;
                        }else if(templateType == 'KoreaHalf'){
                            newRecord.RecordTypeId = koreaHalfRT;
                        }
    
                        newRecord.Sales__c                     = (recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0;
                        newRecord.SalesIncrease__c             = (recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0;
                        newRecord.RegularOrderRatio__c         = (recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0;
                        newRecord.SpecialDCRatio__c            = (recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0;
                        newRecord.CMComplianceRate__c          = (recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0;
                        newRecord.Subtotal_SalesProfit__c      = (recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0;
                        newRecord.TradeCustomerCount__c        = (recordMap.values()[9] != null) ? (Decimal) recordMap.values()[9] : 0;
                        newRecord.StrategicCustomersCount__c   = (recordMap.values()[10] != null) ? (Decimal) recordMap.values()[10] : 0;
                        newRecord.Subtotal_Customer__c         = (recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0;
                        newRecord.FulltimeEmployeesCount__c    = (recordMap.values()[12] != null) ? (Decimal) recordMap.values()[12] : 0;
                        newRecord.ExclusiveDealersCount__c     = (recordMap.values()[13] != null) ? (Decimal) recordMap.values()[13] : 0;
                        newRecord.Subtotal_DealerResource__c   = (recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0;
                        newRecord.InquiriesCount__c            = (recordMap.values()[15] != null) ? (Decimal) recordMap.values()[15] : 0;
                        newRecord.NormalOrderRate__c           = (recordMap.values()[16] != null) ? (Decimal) recordMap.values()[16] : 0;
                        newRecord.OrderHitRate__c              = (recordMap.values()[17] != null) ? (Decimal) recordMap.values()[17] : 0;
                        newRecord.Subtotal_SalesRoyalty__c     = (recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0;
                        newRecord.WholesaleOverdueInterest__c  = (recordMap.values()[19] != null) ? (Decimal) recordMap.values()[19] : 0;
                        newRecord.PolicyCompliance__c          = (recordMap.values()[20] != null) ? (Decimal) recordMap.values()[20] : 0;
                        newRecord.Subtotal_Bonus__c            = (recordMap.values()[21] != null) ? (Decimal) recordMap.values()[21] : 0;
                        
                        newRecord.Total__c                     = ((recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0)
                                                                    + ((recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0)
                                                                    + ((recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0)
                                                                    + ((recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0)
                                                                    + ((recordMap.values()[21] != null) ? (Decimal) recordMap.values()[21] : 0);
    
                    }else if(templateType == 'GlobalYear'){
    
                        newRecord.RecordTypeId = globalYearRT;
    
                        newRecord.AnnualOrderIntakeperProduct__c       = (recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0;
                        newRecord.RegularPriceOrderIntake__c           = (recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0;
                        newRecord.OrderIntakeforHighendProducts__c     = (recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0;
                        newRecord.NoOfNewCustomersRatio__c             = (recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0;
                        newRecord.MarketSharebyterritory__c            = (recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0;
                        newRecord.CustomerSatisfaction__c              = (recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0;
                        
                        newRecord.Total__c                             = ((recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0)
                                                                            + ((recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0)
                                                                            + ((recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0)
                                                                            + ((recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0)
                                                                            + ((recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0)
                                                                            + ((recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0);
                    }else if(templateType == 'GlobalQuarter'){
                        newRecord.RecordTypeId = globalQuarterRT;
    
                        newRecord.NoOfSalesPersonnel__c                = (recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0;
                        newRecord.RegularPriceOrderIntake__c           = (recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0;
                        newRecord.NoOfExhibitionParticipation__c       = (recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0;
                        newRecord.ShowroomSize__c                      = (recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0;
                        newRecord.NoOfNewCustomers__c                  = (recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0;
                        newRecord.NoOfKeyAccounts__c                   = (recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0;
                        newRecord.AEPersonnelToRevenueRatio__c         = (recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0;
                        newRecord.CSPersonnelToRevenueRatio__c         = (recordMap.values()[9] != null) ? (Decimal) recordMap.values()[9] : 0;
                        newRecord.NoOfViolations__c                    = (recordMap.values()[10] != null) ? (Decimal) recordMap.values()[10] : 0;
                        newRecord.OrderIntakeProportionAutomation__c   = (recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0;
                        newRecord.OrderIntakeforAutomation__c          = (recordMap.values()[12] != null) ? (Decimal) recordMap.values()[12] : 0;
                        newRecord.OrderIntakeProportionHighend__c      = (recordMap.values()[13] != null) ? (Decimal) recordMap.values()[13] : 0;
                        newRecord.OrderIntakeHighendProducts__c        = (recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0;
                        newRecord.OrderIntakeProportionPartsCS__c      = (recordMap.values()[15] != null) ? (Decimal) recordMap.values()[15] : 0;
                        newRecord.OrderIntakeforPartsCS__c             = (recordMap.values()[16] != null) ? (Decimal) recordMap.values()[16] : 0;
                        newRecord.OrderIntakeVersusTarget__c           = (recordMap.values()[17] != null) ? (Decimal) recordMap.values()[17] : 0;
                        newRecord.DealerCreditAssessment__c            = (recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0;
                        newRecord.DelinquentPayments__c                = (recordMap.values()[19] != null) ? (Decimal) recordMap.values()[19] : 0;
    
                        newRecord.Total__c                             = ((recordMap.values()[2] != null) ? (Decimal) recordMap.values()[2] : 0)
                                                                            + ((recordMap.values()[3] != null) ? (Decimal) recordMap.values()[3] : 0)
                                                                            + ((recordMap.values()[4] != null) ? (Decimal) recordMap.values()[4] : 0)
                                                                            + ((recordMap.values()[5] != null) ? (Decimal) recordMap.values()[5] : 0)
                                                                            + ((recordMap.values()[6] != null) ? (Decimal) recordMap.values()[6] : 0)
                                                                            + ((recordMap.values()[7] != null) ? (Decimal) recordMap.values()[7] : 0)
                                                                            + ((recordMap.values()[8] != null) ? (Decimal) recordMap.values()[8] : 0)
                                                                            + ((recordMap.values()[9] != null) ? (Decimal) recordMap.values()[9] : 0)
                                                                            + ((recordMap.values()[10] != null) ? (Decimal) recordMap.values()[10] : 0)
                                                                            + ((recordMap.values()[11] != null) ? (Decimal) recordMap.values()[11] : 0)
                                                                            + ((recordMap.values()[12] != null) ? (Decimal) recordMap.values()[12] : 0)
                                                                            + ((recordMap.values()[13] != null) ? (Decimal) recordMap.values()[13] : 0)
                                                                            + ((recordMap.values()[14] != null) ? (Decimal) recordMap.values()[14] : 0)
                                                                            + ((recordMap.values()[15] != null) ? (Decimal) recordMap.values()[15] : 0)
                                                                            + ((recordMap.values()[16] != null) ? (Decimal) recordMap.values()[16] : 0)
                                                                            + ((recordMap.values()[17] != null) ? (Decimal) recordMap.values()[17] : 0)
                                                                            + ((recordMap.values()[18] != null) ? (Decimal) recordMap.values()[18] : 0)
                                                                            + ((recordMap.values()[19] != null) ? (Decimal) recordMap.values()[19] : 0);
    
                    }
    
                    upsertMap.put(recordKey, newRecord); 
                }
            }
    
            System.debug('Final upsertList :: ' + upsertMap.values());
            for(DealerKPI__c obj : upsertMap.values()){
                System.debug(obj);
            }
    
            // 업서트 수행
            if (!upsertMap.isEmpty()) {
                upsert upsertMap.values();
                return 'Success';
            } else{
                System.debug('No records to update.');
                return 'No records to update.';
            }
        
        } catch (Exception e) {
                
            System.debug('Error occurred while processing record: ' + e.getMessage());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Failed to upsert records: ' + e.getMessage());
        }        
    }
}