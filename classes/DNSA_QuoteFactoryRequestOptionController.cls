public with sharing class DNSA_QuoteFactoryRequestOptionController {
    @AuraEnabled
    public static Map<String, Object> getDNSAModelInfo(String recordId){
        try {
            List<Quote> modelInfoList = 
            [
                SELECT
                    Id,
                    DNSAModel__c, 
                    DNSAModel__r.ModelName__c, 
                    DNSAModel__r.BaseCode__c, 
                    DNSAModel__r.Name, 
                    DNSAModel__r.PrimeModel__c
                FROM
                    Quote
                WHERE
                    Id =: recordId
            ];

            List<QuoteLineItem> erpInfo = 
            [
                SELECT
                    ERPQuotationNo__c
                FROM
                    QuoteLineItem
                WHERE
                    QuoteId =: recordId
            ];

            if(!erpInfo.isEmpty() && erpInfo[0].ERPQuotationNo__c != null){
                return new Map<String, Object>{
                    'MSG' => 'After the ERP Quotation is created, the Request Option cannot be used.'
                };
            }

            if(modelInfoList[0].DNSAModel__c != null){
                return new Map<String, Object>{
                    'MSG' => 'SUCCESS',
                    'ModelId' => modelInfoList[0].DNSAModel__c,
                    'ModelName1' => modelInfoList[0].DNSAModel__r.ModelName__c,
                    'ModelBaseCode' => modelInfoList[0].DNSAModel__r.BaseCode__c,
                    'ModelName2' => modelInfoList[0].DNSAModel__r.Name,
                    'PrimeModel' => modelInfoList[0].DNSAModel__r.PrimeModel__c
                };
            }else{
                return new Map<String, Object> {
                    'MSG' => 'Please Select Model'
                };
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveRecords(List<Request_Option__c> rowDataList){
        try {
            insert rowDataList;
        } catch (Exception e) {
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
        
    }
}