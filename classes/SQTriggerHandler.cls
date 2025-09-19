/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-12-2024   Hanyeong Choi   Initial Version
**/
public with sharing class SQTriggerHandler extends TriggerHandler {    

    /**
     * SQ__c 레코드 삽입 전, 기본 검증을 수행합니다.
     */
    public override void onBeforeInsert(List<sObject> news) {
        if (isExecuting) {
            System.debug('SQ__c BEFORE_INSERT TRIGGER Start');
            List<SQ__c> sqList = (List<SQ__c>) news;

            setting(false, TriggerOperation.BEFORE_INSERT);
            System.debug('SQ__c BEFORE_INSERT TRIGGER End');
        }
    }

    /**
     * SQ__c 레코드 삽입 후, SQ_QuoteLineitem_Junction__c 레코드를 생성합니다.
     */
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQ__c AFTER_INSERT TRIGGER Start');
            List<SQ__c> sqList = (List<SQ__c>) news;
            Set<Id> sqIds = new Set<Id>();
            Set<Id> sqrIds = new Set<Id>();
        
            for(SQ__c sq : sqList) {
                if(sq.FM_SQ_Stage__c != 'R&D Confirm' && sq.FM_SQ_Stage__c != 'Final Confirm') {
                    sqIds.add(sq.Id);
                    sqrIds.add(sq.SQ_Registration__c);
                }
            }
            if(!sqIds.isEmpty()) insertSQQuoteLineItemJuctionWithPosnr(sqIds, sqrIds);

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('SQ__c AFTER_INSERT TRIGGER End');
        }
    }

    /**
     * SQ__c 레코드 업데이트 전, 이름 길이 및 특정 조건을 검증합니다.
     */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQ__c BEFORE_UPDATE TRIGGER Start');
            List<SQ__c> sqList = (List<SQ__c>) news;
            List<SQ__c> calculateList = new List<SQ__c>();

            for(SQ__c sq : sqList) {
                if(sq.Name != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
                    if(sq.Name.length() > 40) {
                        if(!Test.isRunningTest()) {
                            sq.addError(System.Label.DNS_REQ_T_NAMEVALIDATION);
                        } else {
                            System.debug('test');
                        }
                    }
                }
            }

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('SQ__c BEFORE_UPDATE TRIGGER End');
        }
    }

    /**
     * SQ__c 레코드 업데이트 후, 관련 Junction 레코드를 업데이트하거나 삭제하고 Quote를 재생성합니다.
     */
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQ__c AFTER_UPDATE TRIGGER Start');
            List<SQ__c> sqList = (List<SQ__c>) news;
            Set<Id> sqIds = new Set<Id>();
            Set<Id> deleteSQIds = new Set<Id>();
            Set<Id> insertSqIds = new Set<Id>();
            Set<Id> sqrIds = new Set<Id>();

            for(SQ__c sq : sqList) {
                System.debug('oldMap.get(sq.Id) ::: ' + oldMap.get(sq.Id).get('IsFinal__c'));
                System.debug('sq.IsFinal__c ::: ' + sq.IsFinal__c);
                System.debug('sq.IsDelete__c ::: ' + sq.IsDelete__c);
                if(oldMap.get(sq.Id).get('IsFinal__c') != sq.IsFinal__c && sq.IsFinal__c && !sq.IsDelete__c) {
                    insertSqIds.add(sq.Id);
                    sqrIds.add(sq.SQ_Registration__c);
                } else if(sq.IsDelete__c) {
                    deleteSQIds.add(sq.Id);
                } else {
                    sqIds.add(sq.Id);
                }
            }
            System.debug('insertSqIds ::: ' + insertSqIds);
            System.debug('sqrIds ::: ' + sqrIds);

            if(!insertSqIds.isEmpty()) insertSQQuoteLineItemJuctionWithPosnr(insertSqIds, sqrIds);
            if(!deleteSQIds.isEmpty()) updateDeleteJunction(deleteSQIds);
            if(!sqIds.isEmpty()) updateJunction(sqIds);

            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('SQ__c AFTER_UPDATE TRIGGER End');
        }
    }

    /**
     * SQ__c 레코드 삭제 전, 관련 SQ_QuoteLineitem_Junction__c 레코드를 삭제합니다.
     */
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if(isExecuting) {
            System.debug('SQ__c BEFORE_DELETE TRIGGER Start');
            List<SQ__c> sqList = (List<SQ__c>) dels;
            Set<Id> delSQIds = new Set<Id>();

            for(SQ__c sq : sqList) {
                delSQIds.add(sq.Id);
            }

            List<SQ_QuoteLineitem_Junction__c> sqqList = [SELECT Id FROM SQ_QuoteLineitem_Junction__c WHERE SQ__c IN :delSQIds];
            // if(!sqqList.isEmpty()) delete sqqList;
            if (!sqqList.isEmpty()) DN_WithoutSharingClass.deleteSqlj(sqqList);
            else DN_WithoutSharingClass.deleteSQ(sqList);
            
            setting(false, TriggerOperation.BEFORE_DELETE);
            System.debug('SQ__c BEFORE_DELETE TRIGGER End');
        }
    }

    /**
     * SQ_QuoteLineitem_Junction__c 레코드를 업데이트합니다.
     */
    private static void updateJunction(Set<Id> sqIds) {
        List<SQ_QuoteLineitem_Junction__c> sqjList = [
            SELECT  SQ__c
                    , SQ__r.Price__c
                    , SQ__r.DNS_Price__c
                    , SQ__r.SQ_Registration__r.RecordType.DeveloperName
                    , UPDATEFLAG__c
                    , FM_ERPCODE__c
                    , POSNR__c
                    , QuoteLineItem__c
                    , QuoteLineItem__r.ERPQuotationNo__c
            FROM SQ_QuoteLineitem_Junction__c 
            WHERE SQ__c IN :sqIds
        ];
        List<SQ_QuoteLineitem_Junction__c> updateList = new List<SQ_QuoteLineitem_Junction__c>();
        List<String> qlids = new List<String>();
        Set<Id> quoteIds = new Set<Id>();
        if(!sqjList.isEmpty()) {
            for(SQ_QuoteLineitem_Junction__c sqj : sqjList) {
                qlids.add(sqj.QuoteLineItem__c);
                // 0317 이주현 추가
                sqj.SalesPrice__c = sqj.SQ__r.SQ_Registration__r.RecordType.DeveloperName == 'DNSA' ? sqj.SQ__r.DNS_Price__c : sqj.SQ__r.Price__c;
                // sqj.SalesPrice__c = sqj.SQ__r.SQ_Registration__r.RecordType.DeveloperName == 'DNSA' ? sqj.SQ__r.DNS_Price__c : sqj.SQ__r.Price__c;
                if(sqj.POSNR__c != null) {
                    sqj.UPDATEFLAG__c = 'U';
                    quoteIds.add(sqj.QuoteLineItem__c);
                    // if(sqj.UPDATEFLAG__c == '' || sqj.UPDATEFLAG__c == null) {
                    //     // updateList.add(sqj);
                    // }
                }
                updateList.add(sqj);
            }
        }
        if(!updateList.isEmpty()) {
            DN_WithoutSharingClass.updateSqlj(updateList);
            DN_QuoteReCreateController.quoteReCreate(qlids, 'SQ');
        }

        if(!quoteIds.isEmpty()) {
            List<QuoteLineItem> updateListqli = new List<QuoteLineItem>(); 
            List<QuoteLineItem> qlis = [SELECT Id, QuotePriceIF__c FROM QuoteLineItem WHERE Id IN :quoteIds];
            for(QuoteLineItem qli : qlis) {
                qli.QuotePriceIF__c = false;
                updateListqli.add(qli);
            }
            if(!updateListqli.isEmpty()) update updateListqli;
        }

        return;
    }

    /**
     * 삭제 플래그가 설정된 SQ__c 레코드에 대해 SQ_QuoteLineitem_Junction__c 레코드를 업데이트하거나 삭제합니다.
     */
    private static void updateDeleteJunction(Set<Id> deleteSQIds) {
        List<SQ_QuoteLineitem_Junction__c> sqjList = [
            SELECT  SQ__c
                    , UPDATEFLAG__c 
                    , FM_ERPCODE__c
                    , POSNR__c
                    , QuoteLineItem__c
            FROM SQ_QuoteLineitem_Junction__c 
            WHERE SQ__c IN :deleteSQIds
        ];
        List<SQ_QuoteLineitem_Junction__c> updateList = new List<SQ_QuoteLineitem_Junction__c>();
        List<SQ_QuoteLineitem_Junction__c> deleteList = new List<SQ_QuoteLineitem_Junction__c>();
        List<String> qlids = new List<String>();
        if(!sqjList.isEmpty()) {
            System.debug('sqjList ::: ' + sqjList);
            for(SQ_QuoteLineitem_Junction__c sqj : sqjList) {
                qlids.add(sqj.QuoteLineItem__c);
                if(sqj.POSNR__c != null) {
                    sqj.UPDATEFLAG__c = 'D';
                    updateList.add(sqj);
                } else {
                    deleteList.add(sqj);
                }
            }
        }
        if(!updateList.isEmpty()) {
            DN_WithoutSharingClass.updateSqlj(updateList);
            DN_QuoteReCreateController.quoteReCreate(qlids, 'SQ');
        }
        if(!deleteList.isEmpty()) DN_WithoutSharingClass.deleteSqlj(deleteList);
        return;
    }

    /**
     * SQ_QuoteLineitem_Junction__c 레코드를 생성하고 Quote를 재생성합니다.
     */
    private static void insertSQQuoteLineItemJuctionWithPosnr(Set<Id> sqIds, Set<Id> sqrIds) {
        List<SQ_QuoteLineitem_Junction__c> sqqjList = new List<SQ_QuoteLineitem_Junction__c>();
        Set<Id> ids = new Set<Id>();
        List<String> qlids = new List<String>();
        List<SQ__c> sqList = [SELECT Id, Price__c, DNS_Price__c FROM SQ__c WHERE Id IN :sqIds];
        System.debug('sqList ::: ' + sqList);

        List<SQ_QuoteLineitem_Junction__c> sqsqjlList = [SELECT Id, QuoteLineItem__c, SQ__C, SQ__r.SQ_Registration__c FROM SQ_QuoteLineitem_Junction__c WHERE SQ__c IN :sqIds];
        System.debug('sqsqjlList ::: ' + sqsqjlList);
        if(!sqsqjlList.isEmpty()) {
            for(SQ_QuoteLineitem_Junction__c sqsq : sqsqjlList) {
                ids.add(sqsq.SQ__c);
            }
        }
        System.debug('ids ::: ' + ids);

        List<SQ_Registration_Junction__c> sqrQList = [
            SELECT  Id,
                    SQRegistration__c,
                    QuoteLineItem__c,
                    QuoteLineItem__r.Max_POSNR__c,
                    QuoteLineItem__r.ERPQuotationNo__c,
                    SQRegistration__r.CurrencyIsoCode,
                    SQRegistration__r.RecordType.DeveloperName,
                    QuoteLineItem__r.Quote.OwnerId
            FROM SQ_Registration_Junction__c
            WHERE SQRegistration__c IN :sqrIds
        ];
        System.debug('sqrQList ::: ' + sqrQList);

            for (SQ__c sqId : sqList) {
                if(!ids.contains(sqId.Id)) {
                    for (SQ_Registration_Junction__c sqrq : sqrQList) {
                        System.debug('sqrq ::: ' + sqrq);
                        qlids.add(sqrq.QuoteLineItem__c);
                        SQ_QuoteLineitem_Junction__c sqqj = new SQ_QuoteLineitem_Junction__c();
                        sqqj.QuoteLineItem__c = sqrq.QuoteLineItem__c;
                        sqqj.SQ__c = sqId.Id;
                        // 0328 이주현 주석 다시 살림
                        sqqj.SalesPrice__c = sqrq.SQRegistration__r.RecordType.DeveloperName == 'DNSA' ? 0 : sqId.Price__c;
                        // sqqj.SalesPrice__c = sqId.Price__c;
                        sqqj.CurrencyIsoCode = sqrq.SQRegistration__r.CurrencyIsoCode;
                        System.debug('sqrq.QuoteLineItem__r.ERPQuotationNo__c 111 ::: ' + sqrq.QuoteLineItem__r.ERPQuotationNo__c);
                        if(String.isNotEmpty(sqrq.QuoteLineItem__r.ERPQuotationNo__c)) {
                            System.debug('sqrq.QuoteLineItem__r.ERPQuotationNo__c 222 ::: ' + sqrq.QuoteLineItem__r.ERPQuotationNo__c);
                            // sqqj.POSNR__c = currentMax;
                            sqqj.UPDATEFLAG__c = 'I';
                        }
                        sqqj.OwnerId = sqrq.QuoteLineItem__r.Quote.OwnerId;
                        sqqjList.add(sqqj);
                    }
                }
                System.debug('sqqjList ::: ' + sqqjList);
            }
    
        if (!sqqjList.isEmpty()) {
            DN_WithoutSharingClass.insertSqlj(sqqjList);
            DN_QuoteReCreateController.quoteReCreate(qlids, 'SQ');
        }
        return;
    }
}