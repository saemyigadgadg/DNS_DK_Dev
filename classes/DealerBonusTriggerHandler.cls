/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-07   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DealerBonusTriggerHandler extends TriggerHandler {
    
    public override void onBeforeInsert(List<sObject> news){

        try {
            if(isExecuting) {
                System.debug('DealerBonus BEFORE_INSERT TRIGGER Start');
                List<DealerBonus__c> dbList = (List<DealerBonus__c>) news;

                getSalesOffice(dbList);
    
                setting(false, TriggerOperation.BEFORE_INSERT);
                System.debug('DealerBonus BEFORE_INSERT TRIGGER End');
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
                System.debug('DealerBonus BEFORE_UPDATE TRIGGER Start');
                List<DealerBonus__c> dbList = (List<DealerBonus__c>) news;
    
                for (DealerBonus__c db : dbList) {
                    validationCheck(db, oldMap, 'update');
                }

                getSalesOffice(dbList);
    
                setting(false, TriggerOperation.BEFORE_UPDATE);
                System.debug('DealerBonus BEFORE_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- DealerBonus__c의 필드 Validation check
     * @author Yuhyun Park | 12-07-2024
     * @Parameter
     *  - sObj	        : DealerBonus__c Record
    **/ 
    private static void validationCheck(DealerBonus__c db, Map<Id, sObject> oldMap, String type) {
        if(db.Year__c != null) {
            Pattern yearPattern = Pattern.compile('^[1-9][0-9]{3}$');
            String  year        = db.Year__c;
            Matcher matcher     = yearPattern.matcher(year);
            if (!matcher.matches()) db.addError('Year__c', 'This field must be a 4-digit number and cannot start with 0.');
        }

        if(type == 'update') {
            if(db.OwnerId != oldMap.get(db.Id).get('OwnerId')) {
                if(!DN_DealerSalesGoalController.allowOwnerIdUpdate) db.addError('Can only be changed through the Sharing modal.');
            }
        }
        return;
    }


    /**
     * @Description
     * 	- Dealer(Account)에서 Sales Office 정보를 가져옴
     * @author Yuhyuun Park | 02-13-2025
     * @Parameter
     *  - dbList	        : DealerBonus__c Record
    **/ 
    private static void getSalesOffice(List<DealerBonus__c> dbList) {
        Set<Id> dealerIds = new Set<Id>();
        for (DealerBonus__c db : dbList) {
            if(db.Dealer__c != null) {
                dealerIds.add(db.Dealer__c);
            }
        }
        if(dealerIds.isEmpty()) return;
        
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, SalesOffice__c 
            FROM Account 
            WHERE Id IN :dealerIds
        ]);
        
        for (DealerBonus__c db : dbList) {
            if(db.Dealer__c != null && accountMap.containsKey(db.Dealer__c)) {
                Account acc = accountMap.get(db.Dealer__c);

                if(db.SalesOffice__c != acc.SalesOffice__c) {
                    db.SalesOffice__c = acc.SalesOffice__c;
                }
            }
        }
    }
}