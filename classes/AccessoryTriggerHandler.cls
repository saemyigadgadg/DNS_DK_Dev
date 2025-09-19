/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-03-2025   Hanyeong Choi   Initial Version
**/
public with sharing class AccessoryTriggerHandler extends TriggerHandler {
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        try {
            if(isExecuting) {
                System.debug('Accessory__c AFTER_INSERT TRIGGER Start');
                List<Accessory__c> accList = (List<Accessory__c>) news;
                Set<Id> quoteIds = new Set<Id>();
                
                for(Accessory__c acc : accList) {
                    quoteIds.add(acc.Quote__c);
                }
                if(!quoteIds.isEmpty()) updateAccessoryPrice(quoteIds);

                setting(false, TriggerOperation.AFTER_INSERT);
                System.debug('Accessory__c AFTER_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        try {
            if(isExecuting) {
                System.debug('Accessory__c AFTER_UPDATE TRIGGER Start');
                List<Accessory__c> accList = (List<Accessory__c>) news;
                Set<Id> quoteIds = new Set<Id>();

                for(Accessory__c acc : accList) {
                    if(oldMap.get(acc.Id).get('Price__c') != acc.Price__c) {
                        quoteIds.add(acc.Quote__c);
                    }
                }
                if(!quoteIds.isEmpty()) updateAccessoryPrice(quoteIds);

                setting(false, TriggerOperation.AFTER_UPDATE);
                System.debug('Accessory__c AFTER_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void updateAccessoryPrice(Set<Id> quoteIds) {
        List<Accessory__c> accList = [SELECT Id, Price__c, FM_TotalPrice__c FROM Accessory__c WHERE Quote__c IN :quoteIds];
        List<Quote> quoteList = [SELECT Id, Accessory_TotalPrice__c FROM Quote WHERE Id IN :quoteIds];
        List<QuoteLineItem> qliList = [SELECT Id, Accessory_Total__c FROM QuoteLineItem WHERE QuoteId IN :quoteIds];

        Decimal totalPrice = 0;
        for(Accessory__c acc : accList) {
            totalPrice += acc.FM_TotalPrice__c; 
        }

        List<Quote> quoteListToUpdate = new List<Quote>();
        List<QuoteLineItem> qliListToUpdate = new List<QuoteLineItem>();
        for(Quote quote : quoteList) {
            quote.Accessory_TotalPrice__c = totalPrice;
            quoteListToUpdate.add(quote);
        }
        for(QuoteLineItem qli : qliList) {
            qli.Accessory_Total__c = totalPrice;
            qliListToUpdate.add(qli);
        }

        if(!quoteListToUpdate.isEmpty()) update quoteListToUpdate;
        if(!qliListToUpdate.isEmpty()) update qliListToUpdate;
    }
}