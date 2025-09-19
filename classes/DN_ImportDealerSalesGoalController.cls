/**
 * @author            : Yu-Hyun Park
 * @description       : Dealer Sales Goal 엑셀 임포트 컨트롤러
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-08   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DN_ImportDealerSalesGoalController {

    private static final Id   goalKRT      = SObjectType.DealerSalesGoal__c.getRecordTypeInfosByDeveloperName().get('DNS_Korea').getRecordTypeId();
    private static final Id   goalGRT      = SObjectType.DealerSalesGoal__c.getRecordTypeInfosByDeveloperName().get('DNS_Global').getRecordTypeId();

    private static final Id   planKRT      = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNS_Korea').getRecordTypeId();
    private static final Id   planGRT      = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNS_Global').getRecordTypeId();
    
    private static final Id   dealerRT      = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    
    // 로그인 사용자 정보 확인
    @AuraEnabled
    public static User getUserInfo() {

        try {

            // 현재 로그인된 사용자의 정보
            User userInfo = [
                SELECT SalesDistrict__c, SalesOrganization__c, Profile.Name, SalesOffice__c 
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


    // 레코드 생성
    @AuraEnabled
    public static String insertRecords(String records, String district, String year) {
        System.debug('insertRecords Controller 진입 ::  ' );
        System.debug('records :: ' + records);
        System.debug('district :: ' + district);

        try{
            // JSON 문자열을 Map 형태로 역직렬화
            List<Object> recordObjects = (List<Object>) JSON.deserializeUntyped(records);
            List<Map<String, Object>> recordMaps = new List<Map<String, Object>>();
    
            Integer rowNumber = 3; // 행 번호 추적
    
            System.debug('recordObjects :: ' + recordObjects);
    
            for (Object obj : recordObjects) {
                recordMaps.add((Map<String, Object>) obj);
            }
    
            System.debug('recordMaps :: ' + recordMaps);
    
            Set<String> customerCodeSet = new Set<String>();
    
            for (Map<String, Object> recordMap : recordMaps) {
    
                rowNumber++; // 현재 행 번호 증가
    
                // customerCode : Column_0
                String customerCode = String.valueOf(recordMap.get('Column_0'));
    
                // Dealer Code가 없을 경우 에러 처리
                if (customerCode == null ||  String.isEmpty(customerCode) || customerCode == '0') {
                    String recordDetails = 'Undefined Dealer Code in Row ' + rowNumber;
                    System.debug('recordDetails :: ' + recordDetails);
                    return recordDetails;

                }else{

                    customerCodeSet.add(customerCode);
                }
            }
    
            // Account 쿼리: CustomerCode__c에 해당하는 Account ID 조회
            Map<String, Account> accountIdMap = new Map<String, Account>();
            List<Account> accList = [SELECT Id, Name, CustomerCode__c, CurrencyIsoCode, RecordTypeId  FROM Account WHERE CustomerCode__c IN :customerCodeSet AND RecordTypeId =: dealerRT];
            for (Account acc : accList) {
                accountIdMap.put(acc.CustomerCode__c, acc);
            }
            
            // 기존 레코드 중복 체크
            // 기존 레코드 쿼리
            Map<String, DealerSalesGoal__c> existingRecordsMap = new Map<String, DealerSalesGoal__c>();
            List<DealerSalesGoal__c> existingRecords = new List<DealerSalesGoal__c>();
    
            // Korea
            if(district == 'Korea'){
                existingRecords = [
                    SELECT  Id, Dealer__c, Dealer__r.Name, Dealer__r.CustomerCode__c, Year__c, RecordTypeId, CurrencyIsoCode
                    FROM    DealerSalesGoal__c
                    WHERE   Dealer__r.CustomerCode__c IN: customerCodeSet
                    AND     Year__c =: year
                    AND     RecordTypeId =: goalKRT
                ];
    
            // Global
            }else if(district == 'Global'){
                existingRecords = [
                    SELECT  Id, Dealer__c, Dealer__r.Name, Dealer__r.CustomerCode__c, Year__c, RecordTypeId, CurrencyIsoCode
                    FROM    DealerSalesGoal__c
                    WHERE   Dealer__r.CustomerCode__c IN: customerCodeSet
                    AND     Year__c =: year
                    AND     RecordTypeId =: goalGRT
                ];
            }
    
            if(!existingRecords.isEmpty()){
                String recordDetails = 'An already created record exists : ' + existingRecords[0].Year__c + existingRecords[0].Dealer__r.Name;
                System.debug('recordDetails :: ' + recordDetails);
                return recordDetails;
            }
    
    
            // 레코드를  생성
            List<DealerSalesGoal__c> goalsToInsert = new List<DealerSalesGoal__c>();
    
            // 다시 행 번호 초기화
            rowNumber = 3;
    
            for (Map<String, Object> recordMap : recordMaps) {
                System.debug('<< Goal insert >>');
    
                rowNumber++;
    
                String customerCode = String.valueOf(recordMap.get('Column_0'));
    
                // 새로운 레코드 생성
                DealerSalesGoal__c newRecord = new DealerSalesGoal__c();
    
                // newRecord.Name = year + ' Target';
                newRecord.Year__c = year;
    
                // Korea
                if(district == 'Korea'){
                    newRecord.RecordTypeId = goalKRT;
    
                // Global
                }else if(district == 'Global'){
                    newRecord.RecordTypeId = goalGRT;
                    newRecord.Target__c    = (Decimal) recordMap.get('Column_2');
                }
                
                if (!(accountIdMap.containsKey(customerCode) && accountIdMap.get(customerCode).Id != null)) {
                    String recordDetails = 'Undefined Dealer Code in Row ' + rowNumber;
                    return recordDetails;
                }else{
                    newRecord.Dealer__c         = accountIdMap.get(customerCode).Id;
                    newRecord.CurrencyIsoCode   = accountIdMap.get(customerCode).CurrencyIsoCode;
                }
    
                goalsToInsert.add(newRecord);
    
            }
    
            if (!goalsToInsert.isEmpty()) {
                insert goalsToInsert;
                System.debug('Inserted DealerSalesGoal__c Records: ' + goalsToInsert);
    
    
                // DealerSalesPlan__c 생성
                List<DealerSalesPlan__c> plansToInsert = new List<DealerSalesPlan__c>();
                Map<Id, Decimal> goalTotalTargetMap = new Map<Id, Decimal>(); // 합계 저장용
    
                for (Integer i = 0; i < goalsToInsert.size(); i++) {
                    System.debug('<< Plan insert >>');
    
                    DealerSalesGoal__c goal = goalsToInsert[i];
                    Map<String, Object> recordMap = recordMaps[i];
    
    
                    // Korea
                    if(district == 'Korea'){
                        Decimal totalTarget = 0;
    
                        // 1월~12월 데이터 맵핑
                        for (Integer month = 1; month <= 12; month++) {
                            String monthStr     = (month < 10) ? '0' + String.valueOf(month) : String.valueOf(month); // 01, 02, ..., 12 형식
        
                            String columnKey    = 'Column_' + (month + 1); // Column_2부터 시작 (1월)
                            Decimal target      = (Decimal) recordMap.get(columnKey);
                            totalTarget         += target;
        
                            // DealerSalesPlan__c 레코드 생성
                            DealerSalesPlan__c plan = new DealerSalesPlan__c();
                            plan.DealerSalesGoal__c = goal.Id;
                            plan.Month__c           = monthStr;
                            plan.Name               = goal.Year__c + '-' + monthStr;
                            plan.RecordTypeId       = planKRT;
                            plan.Target__c          = target;
                            plan.CurrencyIsoCode    = goal.CurrencyIsoCode;
        
                            plansToInsert.add(plan);
                        }
    
                    goalTotalTargetMap.put(goal.Id, totalTarget);
    
    
                    // Global
                    }else if(district == 'Global'){
    
                        Decimal totalTarget     = goal.Target__c;
                        Integer baseTarget      = (Integer) Math.floor(totalTarget / 12);   // Target__c를 12로 나눈 정수 값(몫)
                        Decimal restTarget      = totalTarget - (baseTarget * 12);          // 나머지
    
                        for (Integer month = 1; month <= 12; month++) {
    
                            String monthStr     = (month < 10) ? '0' + String.valueOf(month) : String.valueOf(month); // 01, 02, ..., 12 형식
        
                            // DealerSalesPlan__c 레코드 생성
                            DealerSalesPlan__c plan = new DealerSalesPlan__c();
                            plan.DealerSalesGoal__c = goal.Id;
                            plan.Month__c           = monthStr;
                            plan.Name               = goal.Year__c + '-' + monthStr;
                            plan.RecordTypeId       = planGRT;
                            plan.CurrencyIsoCode    = goal.CurrencyIsoCode;
    
                            // 큰 값이 앞쪽 달에 먼저 배분되고, 작은 값이 뒤쪽 달에 배분되도록
                            if (month <= restTarget) {              // 앞쪽 restTarget 개월은 큰 값
                                plan.Target__c = baseTarget + 1;
                            } else {                                // 나머지 달은 작은 값
                                plan.Target__c = baseTarget;
                            }
                            plansToInsert.add(plan);
                        
                        }
                    }
                }
    
    
                if(!plansToInsert.isEmpty()){
                    insert plansToInsert;
                    System.debug('Inserted DealerSalesPlan__c Records: ' + plansToInsert);
    
                    // Korea만 Goal에 Target__c 합산 금액 입력
                    if(district == 'Korea'){
                        // SalesGoal 업데이트: TotalTarget__c
                        List<DealerSalesGoal__c> goalsToUpdate = new List<DealerSalesGoal__c>();
                        for(Id goalId : goalTotalTargetMap.keySet()){
                            goalsToUpdate.add(
                                new DealerSalesGoal__c(
                                    Id          = goalId,
                                    Target__c   = goalTotalTargetMap.get(goalId)
                                )
                            );
                        }
        
                        if(!goalsToUpdate.isEmpty()){
                            update goalsToUpdate;
                            System.debug('Updated DealerSalesGoal__c Records: ' + goalsToUpdate);
                        }
                    }
                }

                return 'Success';
                
            } else {
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