/**
 * @author            : iltea.seo
 * @Description       : 
 * @last modified on  : 12-20-2024
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-21   iltae.seo@sbtglobal.com       Initial Version
**/
public class DN_CustomerListModalController {
    /**
    * @description CustomerCode가 있는 실고객 목록 조회
    * @author iltae.seo | 2024-11-21 
    **/
    @AuraEnabled
    public static List<Customer> getCustomList(String customCode, String customName){
        try {
            //	Trade Customer 실고객
            List<String> conditions = new List<String>();
            List<Customer> customerList = new List<Customer>();
            String query = 'select Id, Name, CustomerCode__c, BusinessNumber__c,BillingPostalCode,FM_Address__c  from Account where RecordType.Name =\'Trade Customer\' AND BusinessNumber__c !=null ';

            if (String.isNotBlank(customName)) {
                conditions.add(' AND Name LIKE \'%' + String.escapeSingleQuotes(customName) + '%\'');
            }
            if (String.isNotBlank(customCode)) {
                conditions.add(' AND BusinessNumber__c LIKE \'%' + String.escapeSingleQuotes(customCode) + '%\'');
            }
            if(conditions.size() > 0) {
                query += String.join(conditions, '');
            }
            List<Account> accList = database.query(query + ' LIMIT 500');
            for(Account acc : accList) {
                Customer cus = new Customer(acc);
                customerList.add(cus);
            }
            return customerList;
        } catch (Exception e) {

            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 고객 클래스
    * @author iltae.seo | 2024-11-21 
    **/
    public class Customer {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String customerCode {get;set;}
        @AuraEnabled public String customerName {get;set;}
        @AuraEnabled public String businessNumber {get;set;}
        @AuraEnabled public String postelCode {get;set;}
        @AuraEnabled public String address {get;set;}
        public Customer(Account acc) {
            this.id = acc.Id;
            this.customerCode = acc.CustomerCode__c;
            this.customerName = acc.Name;
            this.businessNumber = acc.BusinessNumber__c;
            this.postelCode = acc.BillingPostalCode;
            this.address = acc.FM_Address__c;
        }

    }

}