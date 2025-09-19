/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   03-31-2025   Hanyeong Choi   Initial Version
**/
public with sharing class DNSA_QuoteCopyController {

    /**
     * Quote 레코드를 복제하여 새 버전을 생성합니다.
     */
    @AuraEnabled
    public static CommonWrapper cloneCommodityQuote(String recordId) {
        CommonWrapper cw = new CommonWrapper();
        try {
            Quote quote = [SELECT Id, Name, AccountId, OpportunityId, DNSAModel__c, DNSA_SalesOffice__c, RequestedShipDate__c, RecordTypeId FROM Quote WHERE Id = :recordId LIMIT 1];
            
            Quote clonedQuote = quote.clone(false, true, false, false);
            String baseName = quote.Name;
            Integer versionNumber = 2;
            String newName;

            if (baseName.contains('(v')) {
                String versionStr = baseName.substringAfterLast('(v').substringBefore(')');
                if (versionStr.isNumeric()) {
                    versionNumber = Integer.valueOf(versionStr) + 1;
                }
                baseName = baseName.substringBeforeLast('(v').trim();
            }

            List<Quote> existingQuotes = [SELECT Name FROM Quote WHERE Name  LIKE :baseName + '%(v%' AND Id != :recordId];

            if(!existingQuotes.isEmpty()) {
                for (Quote q : existingQuotes) {
                    String qVersionStr = q.Name.substringAfterLast('(v').substringBefore(')');
                    if (qVersionStr.isNumeric()) {
                        Integer qVersion = Integer.valueOf(qVersionStr);
                        if (qVersion >= versionNumber) {
                            versionNumber = qVersion + 1;
                        }
                    }
                }
            }

            newName = baseName + ' (v' + versionNumber + ')';
            clonedQuote.Name = newName;

            insert clonedQuote;
            cw.returnValue = clonedQuote.Id;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            // throw new AuraHandledException(e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * 결과 wrapper
     */
    public class CommonWrapper {
        @AuraEnabled public Boolean isSuccess   {get; set;}
        @AuraEnabled public String errMessage   {get; set;}
        @AuraEnabled public String returnValue  {get; set;}

        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
        }
    }
}