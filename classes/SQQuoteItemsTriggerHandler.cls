/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class SQQuoteItemsTriggerHandler extends TriggerHandler {
    
    /**
     * SQ_QuoteLineitem_Junction__c 레코드 삽입 후, QuoteLineItem을 업데이트하고 Quote를 재생성합니다.
     */
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQ_QuoteLineitem_Junction__c AFTER_INSERT TRIGGER Start');
            List<SQ_QuoteLineitem_Junction__c> sqljList = (List<SQ_QuoteLineitem_Junction__c>) news;
            List<String> qlis = new List<String>();
            List<String> updateQlis = new List<String>();
        
            for(SQ_QuoteLineitem_Junction__c sqlj : sqljList) {
                System.debug('sqlj ::: ' + sqlj);
                if(sqlj.UPDATEFLAG__c != null) qlis.add(sqlj.QuoteLineItem__c);
            }

            if(!qlis.isEmpty()) DN_QuoteReCreateController.quoteReCreate(qlis, 'SQ');

            if(!qlis.isEmpty()) {
                List<QuoteLineItem> qliList = [SELECT Id, ReERPQuotation__c, ERPQuotationNo__c, QuotePriceIF__c FROM QuoteLineItem WHERE Id IN :qlis];
                List<QuoteLineItem> qliUpdateList = new List<QuoteLineItem>();
                for(QuoteLineItem qli : qliList) {
                    if(qli.ERPQuotationNo__c != null) {
                        // qli.ReERPQuotation__c = true;
                        qli.QuotePriceIF__c = false;
                    }
                    qliUpdateList.add(qli);
                }
                System.debug('qliUpdateList ::: ' + qliUpdateList);

                if(!qliUpdateList.isEmpty()) update qliUpdateList;
            }

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('SQ_QuoteLineitem_Junction__c AFTER_INSERT TRIGGER End');
        }
    }

    /**
     * SQ_QuoteLineitem_Junction__c 레코드 업데이트 후, UPDATEFLAG__c 변경 시 Quote를 재생성합니다.
     */
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQ_QuoteLineitem_Junction__c AFTER_UPDATE TRIGGER Start');
            List<SQ_QuoteLineitem_Junction__c> newList = (List<SQ_QuoteLineitem_Junction__c>) news;
            List<String> qlis = new List<String>();

            for(SQ_QuoteLineitem_Junction__c sqlj : newList) {
                if(oldMap.get(sqlj.Id).get('UPDATEFLAG__c') != sqlj.UPDATEFLAG__c) qlis.add(sqlj.QuoteLineItem__c);
            }
            
            // if(!qlis.isEmpty()) DN_QuoteReCreateController.quoteReCreate(qlis);

            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('SQ_QuoteLineitem_Junction__c AFTER_UPDATE TRIGGER End');
        }
    }

    /**
     * SQ_QuoteLineitem_Junction__c 레코드 삭제 전, 삭제 플래그를 설정한 클론 레코드를 생성하고 Quote를 재생성합니다.
     */
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if(isExecuting) {
            System.debug('SQ_QuoteLineitem_Junction__c BEFORE_DELETE TRIGGER Start');
            List<SQ_QuoteLineitem_Junction__c> sqljList = (List<SQ_QuoteLineitem_Junction__c>) dels;
            List<SQ_QuoteLineitem_Junction__c> clonedRecords = new List<SQ_QuoteLineitem_Junction__c>();
            Set<Id> qliIds = new Set<Id>();
            List<String> qliIdList = new List<String>();
            Set<Id> sqIds = new Set<Id>();

            for(SQ_QuoteLineitem_Junction__c sqlj : sqljList) {
                System.debug('sqlj ::: ' + sqlj);
                // if(String.isNotEmpty(sqlj.FM_ERPCODE__c)) {
                if(sqlj.POSNR__c != null && sqlj.POSNR__c != 0) {
                    qliIds.add(sqlj.QuoteLineItem__c);
                    qliIdList.add(sqlj.QuoteLineItem__c);
                    sqIds.add(sqlj.SQ__c);
                    SQ_QuoteLineitem_Junction__c clonedRecord = sqlj.clone(false, false, false);
                    clonedRecord.Id = null;
                    clonedRecord.UPDATEFLAG__c = 'D';
                    System.debug('clonedRecord ::: ' + clonedRecord);
                    clonedRecords.add(clonedRecord);
                }
            }

            if (!clonedRecords.isEmpty()) DN_WithoutSharingClass.insertSqlj(clonedRecords);
            DN_QuoteReCreateController.quoteReCreate(qliIdList, 'SQ');
            
            setting(false, TriggerOperation.BEFORE_DELETE);
            System.debug('SQ_QuoteLineitem_Junction__c BEFORE_DELETE TRIGGER End');
        }
    }

    /**
     * SQ_QuoteLineitem_Junction__c 레코드 삭제 후, 추가 작업을 수행합니다.
     */
    public override void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if(isExecuting) {
            System.debug('SQ_QuoteLineitem_Junction__c AFTER_DELETE TRIGGER Start');
            List<SQ_QuoteLineitem_Junction__c>  sqljList = (List<SQ_QuoteLineitem_Junction__c>) dels;
            
            setting(false, TriggerOperation.AFTER_DELETE);
            System.debug('SQ_QuoteLineitem_Junction__c AFTER_DELETE TRIGGER End');
        }
    }
}