/**
 * @description       : 입회 검사
 * @author            : yeongju.yun
 * @last modified on  : 04-11-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-29   yeongju.yun   Initial Version
**/
public with sharing class DN_InspectionRelatedController {
    public static DN_OrderService ordSvc = new DN_OrderService();

    @AuraEnabled
    public static Map<String, Object> getInspectionInfo(String recordId){
        try {
            
            DescribeSObjectResult describe = SObjectType.Inspection__c;
            List<Inspection__c> insList = [
                SELECT  Id, Name, RecordType.Name, Name_Title_of_Visitors__c, Start_Date_of_Visit__c, End_Date_of_Visit__c
                FROM    Inspection__c
                WHERE   Order__c =: recordId
                ORDER BY CreatedDate desc
            ];

            Boolean isUser = ordSvc.IS_USER;
            String baseUrl = ordSvc.getBaseUrl(!isUser);

            Integer insNo = 1;
            List<Inspection> insWrapList = new List<Inspection>();
            if(!insList.isEmpty()) {
                for(Inspection__c ins : insList) {
                    if(insNo > 3) break;
                    Inspection insWrap = new Inspection(ins, baseUrl);
                    insWrapList.add(insWrap);
                    insNo++;
                }
            }

            DN_OrderService ordSvc = new DN_OrderService();
            Boolean isPortal       = !ordSvc.IS_USER;

            List<Order> orderList   = [SELECT Id, Status, IsInspectionNeeded__c FROM Order WHERE Id =: recordId];
            Boolean hasInspectionSQ = orderList.isEmpty() ? false : orderList[0].IsInspectionNeeded__c;

            // SLS-DLV-003 
            Boolean isButtonShow = orderList.isEmpty() ? false : !ordSvc.UPTO_PROGRESS.contains(orderList[0].Status);

            return new Map<String, Object>{
                'objName'           => describe.getLabel()
                , 'iconName'        => 'custom:custom111'
                , 'data'            => insWrapList
                , 'size'            => insList.size()
                , 'isPortal'        => isPortal
                , 'hasInspectionSQ' => hasInspectionSQ
                , 'isButtonShow'    => isButtonShow
            };

        } catch (Exception e) {
            System.debug('getInspectionInfo : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Inspection{
        @AuraEnabled public String recordId      {get;set;}
        @AuraEnabled public String recordName    {get;set;}
        @AuraEnabled public String link          {get;set;}
        @AuraEnabled public String visitor       {get;set;}
        @AuraEnabled public String typeName      {get;set;}
        @AuraEnabled public String startDateTime {get;set;}
        @AuraEnabled public String endDateTime   {get;set;}
        
        public Inspection(Inspection__c ins, String baseURL){

            this.recordId   = ins.Id;
            this.recordName = ins.Name;
            this.link       = baseUrl + '/' + ins.Id;
            this.visitor    = ins.Name_Title_of_Visitors__c;
            this.typeName   = ins.RecordType.Name;
            
            this.startDateTime = formatDatetime(ins.Start_Date_of_Visit__c);
            this.endDateTime   = formatDatetime(ins.End_Date_of_Visit__c);
            
        }

        private String formatDatetime(Datetime dt) {
            if (dt == null) { return null; }
            return dt.format('yyyy. MM. dd. a hh:mm');
        }
    }
}