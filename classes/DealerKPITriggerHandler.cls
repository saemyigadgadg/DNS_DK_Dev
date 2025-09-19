/**
 * @description       : DealerKPI__c Trigger Handler
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-25-2024   Hanyeong Choi   Initial Version
 * 1.0   07-10-2024   Yuhyun Park     집계 method 생성 : aggregateDealer
 * 1.0   10-10-2024   Yuhyun Park     aggregateDealer 주석 처리 : Excel 업로드로 변경
**/
public with sharing class DealerKPITriggerHandler extends TriggerHandler {

    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {
                System.debug('DealerKPI BEFORE_INSERT TRIGGER Start');
                List<DealerKPI__c> kpiList = (List<DealerKPI__c>) news;

                for (DealerKPI__c kpi : kpiList) {
                    validationCheck(kpi);
                }

                setting(false, TriggerOperation.BEFORE_INSERT);
                System.debug('DealerKPI BEFORE_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        try {
            if(isExecuting) {
                System.debug('DealerKPI BEFORE_UPDATE TRIGGER Start');
                List<DealerKPI__c> kpiList      = (List<DealerKPI__c>) news;

                for (DealerKPI__c kpi : kpiList) {
                    validationCheck(kpi);
                }

                setting(false, TriggerOperation.BEFORE_UPDATE);
                System.debug('DealerKPI BEFORE_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- DealerKPI__c의 필드 Validation check
     * @author Hanyeong Choi | 06-26-2024
     * @Parameter
     *  - kpi	        : DealerKPI__c Record
    **/ 
    private void validationCheck(DealerKPI__c kpi) {
        if(kpi.get('Year__c') != null) {
            Pattern yearPattern = Pattern.compile('^[1-9][0-9]{3}$');
            String  year        = (String) kpi.get('Year__c');
            Matcher matcher     = yearPattern.matcher(year);
            if (!matcher.matches()) kpi.addError('Year__c', 'This field must be a 4-digit number and cannot start with 0.');
        }
        return;
    }

}