/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-07   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DN_DealerIFController {

    /**
     * @Description
     * 	- 조회할 대상의 딜러 정보 
     * @author Yuhyun Park | 2024-12-13
     * @Parameter
     *  - recordId          : 딜러가 아닌 Internal User일 경우, Account(Dealer) Record Id로 조회 
    **/ 
    @AuraEnabled
    public static Map<String, Object> getDealerInfo(String recordId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            User currentUser = [SELECT Id, UserType FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

            // Experience Cloud user
            if (currentUser.UserType == 'PowerPartner' || currentUser.UserType == 'Partner') {
                User user = [
                    SELECT  Id, Account.Name, Account.CustomerCode__c, Account.Representative__c, 
                            SalesOrganization__c, DistributionChannel__c, Division__c
                    FROM    User 
                    WHERE   Id = :UserInfo.getUserId()
                    AND     Account.CustomerCode__c != null
                    LIMIT   1
                ];

                if (user != null && user.Account != null) {
                    result.put('userType', 'ExperienceCloudUser');
                    result.put('info', user);
                }
            } 

            // Internal User
            else if (currentUser.UserType == 'Standard') {
                Account acc = [
                    SELECT  Id, Name, CustomerCode__c, Representative__c, SalesOrganization__c, 
                            DistributionChannel__c, Division__c
                    FROM    Account 
                    WHERE   Id = :recordId
                    AND     CustomerCode__c != null
                    LIMIT   1
                ];

                if (acc != null) {
                    result.put('userType', 'InternalUser');
                    result.put('info', acc);
                }
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }

        System.debug('result :: ' + result);
        return result;
    }



    /**
     * @Description
     * 	- Interface (담보 조회)
     * @author Yuhyun Park | 2024-12-13
     * @Parameter
     *  - dealerInfo        : 조회한 dealer info
    **/ 
    @AuraEnabled
    public static IF_ERP_Dealer_Classes.IF_DEALER_004_Res interfaceDealer004(Map<String, Object> fieldMap, String processOption) {

        System.debug('fieldMap :: ' + fieldMap);
        System.debug('processOption :: ' + processOption);

        try {
    
            IF_ERP_Dealer_Classes.IF_DEALER_004_Req erpParameters = new IF_ERP_Dealer_Classes.IF_DEALER_004_Req();
            erpParameters.I_DROP        = processOption == 'Process' ? 'P' : 'O' ;
    
            // I_LOG
            IF_ERP_Dealer_Classes.IF_DEALER_004_Req_I_LOG log = new IF_ERP_Dealer_Classes.IF_DEALER_004_Req_I_LOG();
            log.KUNNR                   = (String) fieldMap.get('dealerCode');
            erpParameters.I_LOG         = log;
    
                // I_CONDITION
                IF_ERP_Dealer_Classes.IF_DEALER_004_Req_I_CONDITION condition = new IF_ERP_Dealer_Classes.IF_DEALER_004_Req_I_CONDITION();
                condition.BUKRS            = (String) fieldMap.get('companyCode');
                condition.VKORG            = (String) fieldMap.get('companyCode');
                condition.SPART            = (String) fieldMap.get('salesArea2');
                erpParameters.I_CONDITION  = condition;
    
            System.debug(' erpParameters :: ' + erpParameters);
    
            IF_ERP_Dealer erpService = new IF_ERP_Dealer();
            return erpService.IF_DEALER_004(erpParameters);

        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }


    /**
     * @Description
     * 	- Interface를 통해 호출한 담보금액의 합을 Account의 MortgageAmount__c에 업데이트
     * @author Yuhyun Park | 2024-12-16
     * @Parameter
     *  - fieldMap          : 조회한 dealer info
     *  - recordId          : 현재 Account Id
    **/ 
    @AuraEnabled
    public static void updateTotalMortgageAmount(List<Map<String, Object>> fieldMapList, String recordId) {

        try {
            
            System.debug('fieldMapList :: ' + fieldMapList);
            System.debug('recordId :: ' + recordId);
            
            Decimal totalAmount = 0;
            
            // 'AMOUNT' 필드의 값을 합산
            for (Map<String, Object> fieldMap : fieldMapList) {
                if (fieldMap.containsKey('AMOUNT') && fieldMap.get('AMOUNT') != null) {
                    totalAmount += (Decimal) fieldMap.get('AMOUNT');
                }
            }
            
            System.debug('totalAmount :: ' + totalAmount);

            // Total__c 필드 업데이트
            Account acc = [SELECT Id, MortgageAmount__c FROM Account WHERE Id = :recordId LIMIT 1];
            if (acc.MortgageAmount__c != totalAmount) {
                acc.MortgageAmount__c = totalAmount;
                update acc;
            }
            
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
    }


    /**
     * @Description
     * 	- Interface (여신 조회)
     * @author Yuhyun Park | 2024-12-17
     * @Parameter
     *  - dealerInfo        : 조회한 dealer info
    **/ 
    @AuraEnabled
    public static IF_ERP_Dealer_Classes.IF_DEALER_003_Res interfaceDealer003(Map<String, Object> fieldMap) {

        try {

            System.debug('fieldMap :: ' + fieldMap);
    
            IF_ERP_Dealer_Classes.IF_DEALER_003_Req erpParameters = new IF_ERP_Dealer_Classes.IF_DEALER_003_Req();
    
            erpParameters.I_BUKRS       = (String) fieldMap.get('companyCode');
            erpParameters.I_VKORG       = (String) fieldMap.get('companyCode');
            erpParameters.I_SPART       = (String) fieldMap.get('salesArea2');
            erpParameters.I_KUNNR       = (String) fieldMap.get('dealerCode');
            erpParameters.I_VTWEG       = (String) fieldMap.get('salesArea1');
    
            System.debug(' erpParameters :: ' + erpParameters);
    
            IF_ERP_Dealer erpService = new IF_ERP_Dealer();
            return erpService.IF_DEALER_003(erpParameters);
            
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- Interface (여신 : 월별 수금 계획)
     * @author Yuhyun Park | 2024-12-20
     * @Parameter
     *  - dealerInfo        : 조회한 dealer info
    **/
    @AuraEnabled
    public static Map<String, List<IF_ERP_Dealer_Classes.IF_DEALER_010_Res_T_LIST>> interfaceDealer010(Map<String, Object> fieldMap) {

        try {

            System.debug('fieldMap :: ' + fieldMap);
    
            // 날짜 계산
            Date today = Date.today();
            Date fiveMonthsLater = today.addMonths(5);
        
            // 5개월 뒤의 마지막 날짜 계산
            Date endOfMonth = Date.newInstance(fiveMonthsLater.year(), fiveMonthsLater.month(), 1).addMonths(1).addDays(-1);
        
            // 날짜 형식 지정 (YYYYMMDD 형식)
            String startDate = String.valueOf(today.year()) + 
                                (today.month() < 10 ? '0' + String.valueOf(today.month()) : String.valueOf(today.month())) + 
                                (today.day() < 10 ? '0' + String.valueOf(today.day()) : String.valueOf(today.day()));
        
            String endDate = String.valueOf(endOfMonth.year()) + 
                                (endOfMonth.month() < 10 ? '0' + String.valueOf(endOfMonth.month()) : String.valueOf(endOfMonth.month())) + 
                                (endOfMonth.day() < 10 ? '0' + String.valueOf(endOfMonth.day()) : String.valueOf(endOfMonth.day()));
        

            String startDateMonth   = startDate.substring(0, 6);  // 첫 6글자 (YYYYMM)
            String endDateMonth     = endDate.substring(0, 6);  // 첫 6글자 (YYYYMM)

            // 디버깅 확인
            System.debug('Start Date: ' + startDate);
            System.debug('End Date: ' + endDate);
        
            // dealerCode에 자릿수 채우기(000 추가)
            String dealerCode = '000' + (String) fieldMap.get('dealerCode');
        
            // ERP 요청 파라미터 생성
            IF_ERP_Dealer_Classes.IF_DEALER_010_Req erpParameters = new IF_ERP_Dealer_Classes.IF_DEALER_010_Req();
            erpParameters.I_DEALER = dealerCode;
            erpParameters.I_ERDAT_F = startDate;
            erpParameters.I_ERDAT_T = endDate;
        
            System.debug('erpParameters :: ' + erpParameters);
        
            // ERP 서비스 호출
            IF_ERP_Dealer erpService = new IF_ERP_Dealer();
            IF_ERP_Dealer_Classes.IF_DEALER_010_Res response = erpService.IF_DEALER_010(erpParameters);

            System.debug('response :: ' + response);
            System.debug('response.T_LIST :: ' + response.T_LIST);


            // 필터링된 결과를 담을 Map 생성 (key: m0, m1, m2 ...)
            Map<String, List<IF_ERP_Dealer_Classes.IF_DEALER_010_Res_T_LIST>> filteredMap = new Map<String, List<IF_ERP_Dealer_Classes.IF_DEALER_010_Res_T_LIST>>();

            // T_LIST에서 데이터 필터링 (EST_DAT이 startDate와 endDate 범위 내에 일치하는 값만)
            Integer counter = 0;
            for (IF_ERP_Dealer_Classes.IF_DEALER_010_Res_T_LIST item : response.T_LIST) {
                String estDate = item.EST_DAT;  // EST_DAT 값 (yyyyMM 형식)
                System.debug('estDate :: ' + estDate);

                // EST_DAT이 startDate와 endDate 범위 내에 있고, startDate와 일치하는지 확인
                if (estDate >= startDateMonth && estDate <= endDateMonth) {
                    // m0, m1, m2, ... 와 같은 key로 Map에 담기
                    String key = 'm' + counter;
                    if (!filteredMap.containsKey(key)) {
                        filteredMap.put(key, new List<IF_ERP_Dealer_Classes.IF_DEALER_010_Res_T_LIST>());
                    }
                    filteredMap.get(key).add(item);
                    counter++;
                }
            }

            // 디버깅 출력
            System.debug('Filtered Map: ' + filteredMap);

            // Map 형태로 필터링된 결과만 반환
            return filteredMap;
            
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }



}