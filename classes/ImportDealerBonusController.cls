/**
 * @author            : Yu-Hyun Park
 * @description       : Dealer Bonus 엑셀 임포트 컨트롤러
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-18   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class ImportDealerBonusController {

    @AuraEnabled
    public static String upsertRecords(String records) {

        try{

            List<Object> recordObjects = (List<Object>) JSON.deserializeUntyped(records);
            List<Map<String, Object>> recordMaps = new List<Map<String, Object>>();

            for (Object obj : recordObjects) {
                recordMaps.add((Map<String, Object>) obj);
            }


            List<DealerBonus__c> upsertList = new List<DealerBonus__c>();
            Set<String> customerCodes = new Set<String>();

            for (Map<String, Object> recordMap : recordMaps) {

                String customerCode = String.valueOf(recordMap.get('CustomerCode__c'));

                // 고객 코드와 연도-월 조합 추가
                customerCodes.add(customerCode);
            }

            // 기존 레코드 쿼리
            Map<String, DealerBonus__c> existingRecordsMap = new Map<String, DealerBonus__c>();
            List<DealerBonus__c> existingRecords = [SELECT Id, CustomerCode__c, Year__c, Month__c, SalesCommission__c, Incentive__c, Bounty__c, SalesActivityBonus__c
                                                    FROM DealerBonus__c
                                                    WHERE CustomerCode__c IN :customerCodes];

            System.debug('existingRecords :: ' + existingRecords);

            // 쿼리된 레코드를 "CustomerCode-Year-Month" 형태로 맵핑
            for (DealerBonus__c record : existingRecords) {
                String key = record.CustomerCode__c + '-' + record.Year__c + '-' + record.Month__c;
                existingRecordsMap.put(key, record);
            }

            // Account 쿼리: CustomerCode__c에 해당하는 Account ID 조회
            Map<String, Id> accountIdMap = new Map<String, Id>();
            List<Account> accList = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN :customerCodes];
            for (Account acc : accList) {
                accountIdMap.put(acc.CustomerCode__c, acc.Id);
            }

            // SheetName별 rowNumber관리
            Map<String, Integer> sheetRowNumbers = new Map<String, Integer>();

            // SheetName별 CustomerCode저장
            Map<String, String> previousCustomerCodeMap = new Map<String, String>();


            // 레코드를 업데이트 또는 생성
            Map<String, DealerBonus__c> upsertMap = new Map<String, DealerBonus__c>(); // 중복 방지용 Map
            for (Map<String, Object> recordMap : recordMaps) {

                System.debug('recordMap :: ' + recordMap);

                String sheetName = String.valueOf(recordMap.get('SheetName'));
                String customerCode = String.valueOf(recordMap.get('CustomerCode__c'));
                String year = (String) recordMap.get('Year__c');
                String month = (String) recordMap.get('Month__c');
                
                Decimal salesCommission = (recordMap.get('SalesCommission__c') != null) ? (Decimal) recordMap.get('SalesCommission__c') : 0;
                Decimal incentive = (recordMap.get('Incentive__c') != null) ? (Decimal) recordMap.get('Incentive__c') : 0;
                Decimal bounty = (recordMap.get('Bounty__c') != null) ? (Decimal) recordMap.get('Bounty__c') : 0;
                Decimal salesActivityBonus = (recordMap.get('SalesActivityBonus__c') != null) ? (Decimal) recordMap.get('SalesActivityBonus__c') : 0;

                // 새로운 SheetName이면 rowNumber 초기화
                if (!sheetRowNumbers.containsKey(sheetName)) {
                    sheetRowNumbers.put(sheetName, 4);
                    System.debug('sheetRowNumbers :: ' + sheetRowNumbers);
                    previousCustomerCodeMap.put(sheetName, customerCode); // 초기 CustomerCode 저장
                }

                Integer rowNumber = sheetRowNumbers.get(sheetName); // 현재 Sheet의 행 번호 가져오기
                System.debug('rowNumber :: ' + rowNumber);

                // CustomerCode가 이전 값과 다르면 rowNumber 증가
                if (previousCustomerCodeMap.containsKey(sheetName) && 
                    previousCustomerCodeMap.get(sheetName) != customerCode) {
                    rowNumber++;
                }

                // 현재 CustomerCode 저장 (비교를 위해)
                previousCustomerCodeMap.put(sheetName, customerCode);

                // 업데이트된 rowNumber 저장
                sheetRowNumbers.put(sheetName, rowNumber);

                System.debug('Processing Row ' + rowNumber + ' for Sheet: ' + sheetName + ', CustomerCode: ' + customerCode);
                
                // CustomerCodes 추가
                customerCodes.add(customerCode);

                // Dealer Code가 없을 경우 에러 처리
                if (customerCode == null ||  String.isEmpty(customerCode) || customerCode == '0') {
                    String recordDetails = 'Undefined Dealer Code ' + sheetName + ' in Row ' + rowNumber;
                    System.debug('recordDetails :: ' + recordDetails);
                    return recordDetails;
                }

                String key = customerCode + '-' + year + '-' + month;
                
                if (existingRecordsMap.containsKey(key)) {

                    System.debug('<< update >>');

                    // 기존 레코드 업데이트
                    DealerBonus__c existingRecord = existingRecordsMap.get(key);
            
                    // 시트 이름에 따라 필드를 업데이트
                    if (sheetName == '판매수수료') {
                        existingRecord.SalesCommission__c = salesCommission;
                    } else if (sheetName == '인센티브') {
                        existingRecord.Incentive__c = incentive;
                    } else if (sheetName == '포상금') {
                        existingRecord.Bounty__c = bounty;
                    } else if (sheetName == '영업활동 장려금') {
                        existingRecord.SalesActivityBonus__c = salesActivityBonus;
                    }
            
                    upsertMap.put(key, existingRecord); 
            
                } else {

                    System.debug('<< insert >>');

                    // 새로운 레코드 생성
                    if(upsertMap.containsKey(key)){

                        System.debug('<< insert : Queue Record >>');
                        DealerBonus__c queueRecord = upsertMap.get(key);
                        // 시트 이름에 따라 필드를 설정
                        if (sheetName == '판매수수료') {
                            queueRecord.SalesCommission__c = salesCommission;
                        } else if (sheetName == '인센티브') {
                            queueRecord.Incentive__c = incentive;
                        } else if (sheetName == '포상금') {
                            queueRecord.Bounty__c = bounty;
                        } else if (sheetName == '영업활동 장려금') {
                            queueRecord.SalesActivityBonus__c = salesActivityBonus;
                        }

                        upsertMap.put(key, queueRecord); 

                    }else{
                        System.debug('<< insert : New Record >>');
                        // 새로운 레코드 생성
                        DealerBonus__c newRecord = new DealerBonus__c();

                        newRecord.Name = year + '-' + month;
                        newRecord.CustomerCode__c = customerCode;
                        newRecord.Dealer__c = accountIdMap.get(customerCode);

                        // Dealer Code가 없을 경우 에러 처리
                        if (newRecord.Dealer__c == null ) {
                            String recordDetails = 'Undefined Dealer Code ' + sheetName + ' in Row ' + rowNumber;
                            System.debug('recordDetails :: ' + recordDetails);
                            return recordDetails;
                        }

                        newRecord.Year__c = year;
                        newRecord.Month__c = month;
                
                        // 시트 이름에 따라 필드를 설정
                        if (sheetName == '판매수수료') {
                            newRecord.SalesCommission__c = salesCommission;
                        } else if (sheetName == '인센티브') {
                            newRecord.Incentive__c = incentive;
                        } else if (sheetName == '포상금') {
                            newRecord.Bounty__c = bounty;
                        } else if (sheetName == '영업활동 장려금') {
                            newRecord.SalesActivityBonus__c = salesActivityBonus;
                        }
                    
                        upsertMap.put(key, newRecord);
                    }
                }
            }

            System.debug('Final upsertList :: ' + upsertMap.values());
            for(DealerBonus__c obj : upsertMap.values()){
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