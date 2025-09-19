/**
 * @description       : [SLS-DLV-010] 생성창과 Detail에 기 사용 Checklist 내 표 형태로 표출
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-01   yeongju.yun   Initial Version
**/
public with sharing class DN_PreparationTableController {
    
    /**
    * @description 사전설치점검표 테이블 항목 메타 데이터에서 가져오는 등 기본 값 설정
    * @author yeongju.yun | 2024-11-01 
    * @return List<TableWrapper> 
    **/
    @AuraEnabled
    public static List<TableWrapper> fetchTableItems(){
        try {

            // String language = UserInfo.getLanguage() == 'ko' ? 'ko' : 'en';
            List<PreparationChecklistItem__mdt> metaList = [
                SELECT  SectionNo__c, SectionName__c, ContentNo__c, Content__c
                        , PlannedField__c, CompletionField__c, SalesCheckField__c, CustomerCheckField__c
                FROM    PreparationChecklistItem__mdt
                // WHERE   Language__c = :language
                WHERE   Language__c = 'ko'
                ORDER BY SectionNo__c, ContentNo__c
            ];

            Map<String, List<PreparationChecklistItem__mdt>> metaMap = new Map<String, List<PreparationChecklistItem__mdt>>();
            for(PreparationChecklistItem__mdt meta : metaList) {

                if(metaMap.containsKey(meta.SectionName__c)) {
                    List<PreparationChecklistItem__mdt> innerList = metaMap.get(meta.SectionName__c);
                    innerList.add(meta);
                    metaMap.put(meta.SectionName__c, innerList);
                } else {
                    metaMap.put(meta.SectionName__c, new List<PreparationChecklistItem__mdt>{meta});
                }
            }
            System.debug('fetchTableItems - metaMap ::: ' +  metaMap);

            List<TableWrapper> wrapList = new List<TableWrapper>();
            for(String section : metaMap.keySet()) {

                Boolean isFirst = true;
                for(PreparationChecklistItem__mdt meta : metaMap.get(section)) {

                    TableWrapper wrap = new TableWrapper(meta);
                    wrap.isFirst      = isFirst;
                    
                    if(isFirst) {
                        wrap.count = metaMap.get(section).size();
                        isFirst = !isFirst;
                    }

                    wrapList.add(wrap);
                }

            }
            System.debug('fetchTableItems - wrapList ::: ' +  wrapList);

            return wrapList;
            
        } catch (Exception e) {
            System.debug('fetchTableItems : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Preparation Check List는 Ticket의 Status가 '요청(New)'이거나 '반려(Reject)'일 때 수정 가능
    * @author yeongju.yun | 2024-11-04 
    * @param recordId 
    * @return Boolean true = editable
    **/
    @AuraEnabled
    public static Boolean getMode(String recordId){
        Boolean result = false;
        try {
            
            List<Case> ticketList = [
                SELECT  Id, Status
                FROM    Case
                WHERE   PreparationChecklist__c =: recordId
            ];

            if(!ticketList.isEmpty()) {
                result = ticketList[0].Status == 'New' || ticketList[0].Status == 'Reject';
            }

            return result;
        } catch (Exception e) {
            System.debug('getMode : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 사전설치점검표 테이블 Wrapper
    **/
    public class TableWrapper{
        @AuraEnabled public Boolean isFirst      {get;set;}
        @AuraEnabled public String  sectionName  {get;set;}
        @AuraEnabled public Integer count        {get;set;}

        @AuraEnabled public String content       {get;set;}
        @AuraEnabled public String pField        {get;set;}
        @AuraEnabled public String cField        {get;set;}
        @AuraEnabled public String salesCheck    {get;set;}
        @AuraEnabled public String customerCheck {get;set;}

        public TableWrapper(){}
        public TableWrapper(PreparationChecklistItem__mdt meta){
            
            this.sectionName   = meta.SectionName__c;
            this.content       = meta.Content__c;
            this.pField        = meta.PlannedField__c;
            this.cField        = meta.CompletionField__c;
            this.salesCheck    = meta.SalesCheckField__c;
            this.customerCheck = meta.CustomerCheckField__c;
        }
    }

}