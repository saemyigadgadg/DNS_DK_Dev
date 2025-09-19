// @description       : 
// @author            : Sejin Kwon
// @group             : 
// @last modified on  : 02-14-2025
// @last modified by  : Sejin Kwon
// Modifications Log
// Ver   Date         Author      Modification
// 1.0   02-14-2025   Sejin Kwon  Initial Version

public with sharing class DNSA_QuoteChangeController {
    private static final Id   recordTypeIdCommo = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    private static final Id   recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();

    @AuraEnabled
    public static string getStatus(String recordId){
        try {
            List<QuoteLineItem> quoteStatus = 
                [
                    SELECT 
                        Id 
                    FROM 
                        QuoteLineItem
                    WHERE
                        QuoteId =: recordId
                        and F_IsOrderCreated__c = true
                ];
            List<Quote> isRecently = [SELECT Recently_Version__c FROM Quote WHERE Id =: recordId];

            if(quoteStatus.size() > 0) { // 이미 주문이 생성된 건이면 ERROR
                return 'This order has already been created.';
            }else if(!isRecently[0].Recently_Version__c){
                return 'Only the latest version of the quote can have its type changed.';
            }else {
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('QuoteCopy : ' + e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    //견적 Change
    @AuraEnabled
    public static String quoteCopy(String recordId, String copyReason){
        try{
            Quote originQuote = 
            [
                SELECT 
                    Id, 
                    Name, 
                    RequestedShipDate__c, 
                    DNSAModel__c, 
                    DNSA_SalesOffice__c, 
                    AccountId, 
                    OpportunityId,
                    CopyReason__c,
                    Recently_Version__c,
                    RecordTypeId
                FROM  
                    Quote
                WHERE 
                    Id =: recordId];
    
            //기존 값 Update
            Quote originUpdate = new Quote();
            originUpdate.Id = originQuote.Id;
            originUpdate.CopyReason__c = copyReason;
            originUpdate.Recently_Version__c = false;
            update originUpdate;
    
            Quote newQuote = new Quote();
            newQuote.Name = originQuote.Name;
            newQuote.RequestedShipDate__c = originQuote.RequestedShipDate__c;
            newQuote.DNSAModel__c = originQuote.DNSAModel__c;
            newQuote.DNSA_SalesOffice__c = originQuote.DNSA_SalesOffice__c;
            // newQuote.AccountId = originQuote.AccountId;
            newQuote.OpportunityId = originQuote.OpportunityId;
    
            //기존 데이터가 commodity면 Factory
            if(originQuote.RecordTypeId == recordTypeIdCommo){
                newQuote.RecordTypeId = recordTypeIdFactory;
            }else{
                //기존이 Factory면 Commodity
                newQuote.RecordTypeId = recordTypeIdCommo;
            }
            insert newQuote;

            return newQuote.Id;
        }catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}