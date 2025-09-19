/**
 * @description       : DealerSalesGoal__c Trigger Handler
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-25-2024   Hanyeong Choi   Initial Version
**/
public with sharing class DealerSalesGoalTriggerHandler extends TriggerHandler {

    private static final Id   dnsKGoalRT     = SObjectType.DealerSalesGoal__c.getRecordTypeInfosByDeveloperName().get('DNS_Korea').getRecordTypeId();
    private static final Id   dnsGGoalRT     = SObjectType.DealerSalesGoal__c.getRecordTypeInfosByDeveloperName().get('DNS_Global').getRecordTypeId();
    private static final Id   dnsaGoalRT    = SObjectType.DealerSalesGoal__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

    private static final Id   dnsKPlanRT     = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNS_Korea').getRecordTypeId();
    private static final Id   dnsGPlanRT     = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNS_Global').getRecordTypeId();
    private static final Id   dnsaPlanRT    = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {
                System.debug('DealerSalesGoal BEFORE_INSERT TRIGGER Start');
                List<DealerSalesGoal__c>    dsgList     = (List<DealerSalesGoal__c>) news;
                Set<String>                 yearSet     = new Set<String>();
                Map<Id, DealerSalesGoal__c> dsgForAccId = new Map<Id, DealerSalesGoal__c>();

                List<DealerSalesGoal__c> dsgListForPreviousField = new List<DealerSalesGoal__c>();
    
                for (DealerSalesGoal__c dsg : dsgList) {
                    validationCheck(dsg, null, 'insert');
                    yearSet.add(dsg.Year__c);
                    dsgForAccId.put(dsg.Dealer__c, dsg);

                    if(dsg.RecordTypeId == dnsaGoalRT){
                        dsgListForPreviousField.add(dsg);
                    }

                }
                checkYearDuplicate(dsgList, yearSet, dsgForAccId);
                getCountryAndSalesOffice(dsgList);

                if (!dsgListForPreviousField.isEmpty()) {
                    insertPreviousActualValues(dsgListForPreviousField);
                }
                
                setting(false, TriggerOperation.BEFORE_INSERT);
                System.debug('DealerSalesGoal BEFORE_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        try {
            if (isExecuting) {
                System.debug('DealerSalesGoal AFTER_INSERT TRIGGER Start');
                List<DealerSalesGoal__c>    dsgList     = (List<DealerSalesGoal__c>) news;
                List<DealerSalesGoal__c>    dnsaList    = new List<DealerSalesGoal__c>();

                for(DealerSalesGoal__c dsg : dsgList){
                    if(dsg.RecordTypeId == dnsaGoalRT){
                        dnsaList.add(dsg);
                    }
                }


                if(!dnsaList.isEmpty()){
                    createDNSAPlan(dnsaList);
                }


                System.debug('DealerSalesGoal AFTER_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        try {
            if(isExecuting) {
                System.debug('DealerSalesGoal BEFORE_UPDATE TRIGGER Start');
                List<DealerSalesGoal__c> dsgList = (List<DealerSalesGoal__c>) news;
    
                for (DealerSalesGoal__c dsg : dsgList) {
                    validationCheck(dsg, oldMap, 'update');
                }

                getCountryAndSalesOffice(dsgList);
    
                setting(false, TriggerOperation.BEFORE_UPDATE);
                System.debug('DealerSalesGoal BEFORE_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- Dealer(Account)에서 Country와 Sales Office 정보를 가져옴
     * @author Yuhyuun Park | 02-13-2025
     * @Parameter
     *  - dsgList	        : DealerSalesGoal__c Record
    **/ 
    private static void getCountryAndSalesOffice(List<DealerSalesGoal__c> dsgList) {
        Set<Id> dealerIds = new Set<Id>();

        for (DealerSalesGoal__c dsg : dsgList) {
            if(dsg.Dealer__c != null) {
                dealerIds.add(dsg.Dealer__c);
            }
        }

        System.debug('dealerIds :: ' + dealerIds);

        if(dealerIds.isEmpty()) return;
        
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, CountryLookup__c, SalesOffice__c 
            FROM Account 
            WHERE Id IN :dealerIds
        ]);

        System.debug('accountMap :: ' + accountMap);
        
        for (DealerSalesGoal__c dsg : dsgList) {
            if(dsg.Dealer__c != null && accountMap.containsKey(dsg.Dealer__c)) {
                Account acc = accountMap.get(dsg.Dealer__c);
                System.debug('acc :: ' + acc);
                
                if(dsg.Country__c != acc.CountryLookup__c) {
                    dsg.Country__c = acc.CountryLookup__c;
                }
                
                if(dsg.SalesOffice__c != acc.SalesOffice__c) {
                    dsg.SalesOffice__c = acc.SalesOffice__c;
                }
            }
        }
    }


    /**
     * @Description
     * 	- DealerSalesGoal__c의 필드 Validation check
     * @author Hanyeong Choi | 06-25-2024
     * @Parameter
     *  - sObj	        : DealerSalesGoal__c Record
    **/ 
    private static void validationCheck(DealerSalesGoal__c dsg, Map<Id, sObject> oldMap, String type) {
        if(dsg.Year__c != null) {
            Pattern yearPattern = Pattern.compile('^[1-9][0-9]{3}$');
            String  year        = dsg.Year__c;
            Matcher matcher     = yearPattern.matcher(year);
            if (!matcher.matches()) dsg.addError('Year__c', 'This field must be a 4-digit number and cannot start with 0.');
        }

        if(type == 'update') {
            if(dsg.OwnerId != oldMap.get(dsg.Id).get('OwnerId')) {
                if(!DN_DealerSalesGoalController.allowOwnerIdUpdate) dsg.addError('Can only be changed through the Sharing modal.');
            }
        }
        return;
    }


    /**
     * @Description
     * 	- DealerSalesGoal__c의 Year__c필드 duplicate check
     * @author Hanyeong Choi | 07-09-2024
     * @Parameter
     *  - dsgList	        : insert 되는 DealerSalesGoal__c의 레코드 List
     *  - yearSet	        : dsgList 레코드들의 Year__c 필드값 Set
     *  - dsgForAccId       : dsgList 레코드들의 Map (key:Dealer__c, value:DealerSalesGoal__c)
    **/ 
    private static void checkYearDuplicate(List<DealerSalesGoal__c> dsgList, Set<String> yearSet, Map<Id, DealerSalesGoal__c> dsgForAccId) {
        List<DealerSalesGoal__c> existingDsgList = [
            SELECT Id
                    , Dealer__c
                    , Year__c 
                    , RecordTypeId
            FROM DealerSalesGoal__c 
            WHERE Year__c IN :yearSet
            AND Dealer__c IN :dsgForAccId.keySet()
        ];

        Map<String, DealerSalesGoal__c> existingDsgMap = new Map<String, DealerSalesGoal__c>();
        for (DealerSalesGoal__c existingDsg : existingDsgList) {
            existingDsgMap.put(existingDsg.RecordTypeId + existingDsg.Year__c, existingDsg);
        }

        for (DealerSalesGoal__c dsg : dsgList) {
            if (existingDsgMap.containsKey(dsg.RecordTypeId + dsg.Year__c)) {
                dsg.addError('The year already exists.');
            }
        }
        return;
    }


    /**
     * @Description
     * 	- Dealer Sales Goal이 생성될 때, Dealer Sales Plan 자동생성(각 Target__c/12)
     *  - DNSA Record Type
     * @author Yuhyun Park | 12-02-2024
     * @Parameter
     *  - dsgList	        : insert 되는 DealerSalesGoal__c의 레코드 List
    **/
    private static void createDNSAPlan(List<DealerSalesGoal__c> dsgList){
        List<DealerSalesPlan__c> planToInsert = new List<DealerSalesPlan__c>();

        for(DealerSalesGoal__c dsg : dsgList){
            String year                         = dsg.Year__c;

            // 각 Target__c 필드
            Decimal totalOrderUnit              = dsg.Target_OrderUnit__c               != null ? dsg.Target_OrderUnit__c : 0;
            Decimal totalOrderAmount            = dsg.Target_OrderAmount__c             != null ? dsg.Target_OrderAmount__c : 0;
            Decimal totalHEOrderUnit            = dsg.Target_HEOrderUnit__c             != null ? dsg.Target_HEOrderUnit__c : 0;
            Decimal totalAvgMachinePrice        = dsg.Target_AvgMachineSalesPrice__c    != null ? dsg.Target_AvgMachineSalesPrice__c : 0;
            Decimal totalAutomationOrderUnit    = dsg.Target_AutomationOrderUnit__c     != null ? dsg.Target_AutomationOrderUnit__c : 0;

            // 각 Target__c의 정수 몫과 나머지
            Integer baseOrderUnit               = (Integer) Math.floor(totalOrderUnit / 12);
            Integer baseOrderAmount             = (Integer) Math.floor(totalOrderAmount / 12);
            Integer baseHEOrderUnit             = (Integer) Math.floor(totalHEOrderUnit / 12);
            Integer baseAutomationOrderUnit     = (Integer) Math.floor(totalAutomationOrderUnit / 12);

            Decimal restOrderUnit               = totalOrderUnit - (baseOrderUnit * 12);
            Decimal restOrderAmount             = totalOrderAmount - (baseOrderAmount * 12);
            Decimal restHEOrderUnit             = totalHEOrderUnit - (baseHEOrderUnit * 12);
            Decimal restAutomationOrderUnit     = totalAutomationOrderUnit - (baseAutomationOrderUnit * 12);

            // 나머지를 반올림
            Integer roundedOrderUnit            = (Integer) Math.round(restOrderUnit);
            Integer roundedOrderAmount          = (Integer) Math.round(restOrderAmount);
            Integer roundedHEOrderUnit          = (Integer) Math.round(restHEOrderUnit);
            Integer roundedAutomationOrderUnit  = (Integer) Math.round(restAutomationOrderUnit);


            // 1월부터 12월까지 DealerSalesPlan__c 생성
            for (Integer month = 1; month <= 12; month++) {
                String monthStr                     = (month < 10) ? '0' + String.valueOf(month) : String.valueOf(month); // 01, 02, ..., 12 형식

                // DealerSalesPlan__c 레코드 생성
                DealerSalesPlan__c plan             = new DealerSalesPlan__c();
                plan.DealerSalesGoal__c             = dsg.Id; // Master-Detail 관계 설정
                plan.Month__c                       = monthStr;
                plan.Name                           = year + '-' + monthStr; // Year-Month 형식
                plan.RecordTypeId                   = dnsaPlanRT; 

                
                // 각 Target 필드 설정 (큰 값이 앞쪽 달에, 작은 값이 뒤쪽 달에 배분되도록)
                if (month <= restOrderUnit) {
                    plan.Target_OrderUnit__c = baseOrderUnit + 1;
                } else {
                    plan.Target_OrderUnit__c = baseOrderUnit;
                }

                if (month <= restOrderAmount) {
                    plan.Target_OrderAmount__c = baseOrderAmount + 1;
                } else {
                    plan.Target_OrderAmount__c = baseOrderAmount;
                }

                if (month <= restHEOrderUnit) {
                    plan.Target_HEOrderUnit__c = baseHEOrderUnit + 1;
                } else {
                    plan.Target_HEOrderUnit__c = baseHEOrderUnit;
                }

                plan.Target_AvgMachineSalesPrice__c = totalAvgMachinePrice;

                if (month <= restAutomationOrderUnit) {
                    plan.Target_AutomationOrderUnit__c = baseAutomationOrderUnit + 1;
                } else {
                    plan.Target_AutomationOrderUnit__c = baseAutomationOrderUnit;
                }


                planToInsert.add(plan);
            }
        }


        if(!planToInsert.isEmpty()){
            System.debug('planToInsert :: ' + planToInsert);
            insert planToInsert;
        }
    }


    /**
     * @Description
     *  - 직전년도 Sales Goal이 존재할 경우, Previous Actual 필드에 할당 
     *  - DNSA Record Type
     * @author 
     * @Parameter
     *  - dsgList : insert 되는 DealerSalesGoal__c의 레코드 List
     **/
    private static void insertPreviousActualValues(List<DealerSalesGoal__c> dsgList) {

        Map<String, DealerSalesGoal__c> previousYearRecords = new Map<String, DealerSalesGoal__c>();
        Set<Id> dealerIds = new Set<Id>();
        Set<String> previousYears = new Set<String>();

        for (DealerSalesGoal__c dsg : dsgList) {
            dealerIds.add(dsg.Dealer__c);
            previousYears.add(String.valueOf(Integer.valueOf(dsg.Year__c) - 1));
        }

        List<DealerSalesGoal__c> existingRecords = [
            SELECT Dealer__c, Year__c, Actual_OrderUnit__c, Actual_OrderAmount__c, Actual_HEOrderUnit__c, Actual_AutomationOrderUnit__c
            FROM DealerSalesGoal__c
            WHERE Dealer__c IN :dealerIds
            AND Year__c IN :previousYears
            AND RecordTypeId = :dnsaGoalRT
        ];

        for (DealerSalesGoal__c record : existingRecords) {
            String key = record.Dealer__c + '-' + record.Year__c;
            previousYearRecords.put(key, record);
        }

        for (DealerSalesGoal__c dsg : dsgList) {
            String key = dsg.Dealer__c + '-' + String.valueOf(Integer.valueOf(dsg.Year__c) - 1);
            if (previousYearRecords.containsKey(key)) {
                DealerSalesGoal__c previousRecord           = previousYearRecords.get(key);
                dsg.PreviousActual_OrderUnit__c             = previousRecord.Actual_OrderUnit__c;
                dsg.PreviousActual_OrderAmount__c           = previousRecord.Actual_OrderAmount__c;
                dsg.PreviousActual_HEOrderUnit__c           = previousRecord.Actual_HEOrderUnit__c;
                dsg.PreviousActual_AutomationOrderUnit__c   = previousRecord.Actual_AutomationOrderUnit__c;
            }
        }
    }

}