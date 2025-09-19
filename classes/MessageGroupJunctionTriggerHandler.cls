/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 2025-05-30
 * @last modified by  : yuhyun.park@sbtglobal.com
**/
public with sharing class MessageGroupJunctionTriggerHandler extends TriggerHandler {
    public override void onBeforeInsert(List<sObject> news) {
        if (isExecuting) {
            Message_Group_Junction__c newCheck;
            if(news.size() > 0){
                newCheck = (Message_Group_Junction__c)news[0];
            }
            if(newCheck.RFQ_Specification__c != null){
                List<Message_Group_Junction__c> oldAECheck = [
                    SELECT
                        Id,
                        User__c,
                        RFQ_Specification__c
                    FROM
                        Message_Group_Junction__c
                    WHERE
                        RFQ_Specification__c =: newCheck.RFQ_Specification__c
                ];
                if(!oldAECheck.isEmpty()){
                    if(oldAECheck.size() == 5){
                        newCheck.addError(System.Label.DNS_M_5AE);
                    }
                    for(Message_Group_Junction__c dup: oldAECheck){
                        if(dup.User__c == newCheck.User__c){
                            newCheck.addError(System.Label.DNS_M_RFQAEDupCheck);
                        }
                    }
                }

                List<User> aeCheck =  [SELECT Id, Profile.Name FROM User WHERE Id =: newCheck.User__c AND Profile.Name LIKE '%AE%' LIMIT 1];
                if(aeCheck.isEmpty() && !Test.isRunningTest()){
                    newCheck.addError(System.Label.DNS_M_OnltyAE);
                }
            }
        }
    }
    
}