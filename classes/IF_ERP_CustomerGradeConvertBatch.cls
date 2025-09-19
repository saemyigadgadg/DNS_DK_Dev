public with sharing class IF_ERP_CustomerGradeConvertBatch 
                            implements Database.Batchable<SObject>, 
                                                        Database.AllowsCallouts, 
                                                        Database.Stateful  {
    public IF_ERP_CustomerGradeConvertBatch() {}

    public List<ExceptionDto> exceptionList = new List<ExceptionDto>();

// START     
    public Iterable<SObject> start(Database.BatchableContext BC) {
        String objectNm = 'IF_CustomerGrade__c';
        List<IF_CustomerGrade__c> records;

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
            .get(objectNm)
            .getDescribe()
            .fields.getMap();

        String queryFields = String.join(new List<String>(fieldMap.keySet()), ', ');
        String query       = 'SELECT ' + queryFields + ' FROM ' + objectNm + ' WHERE IsConverted__c = false';

        return  Database.query(query);            
    }

// EXECUTE    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('execute -- start');

        // 1. Get CustomerGradeList 
        List<IF_CustomerGrade__c>  customerGradeList     = (List<IF_CustomerGrade__c>) scope;

        // 2. Get Map Id, Account 
        Map<String,Account>            accountMap        = findAccountByKunnr(customerGradeList);

        // 3. Get Account Dealer Id
        String                         accountDealerId   = getAccountDealerId();

        Map<Id, Account>               successAccountMap = new Map<Id, Account>();

        // 3. loop 
        for(IF_CustomerGrade__c customerGrade : customerGradeList) {
            customerGrade.IsConverted__c = true;
            String  sapKey  = String.valueOf(Integer.valueOf(customerGrade.KUNNR__c));
            System.debug('sapKey : '+sapKey);
            Account account = accountMap.get(sapKey);

            if( account == null){
                System.debug('-- NOT FOUND ACCOUNT --');
                this.exceptionList.add(new ExceptionDto().NOT_FOUND_ACCOUNT(sapKey));
                accountMap.remove(sapKey);
                continue;
            }

            if( account.RecordTypeId != accountDealerId ){
                System.debug('-- IS NOT DEALER --');
                this.exceptionList.add(new ExceptionDto().IS_NOT_DEALER(sapKey));
                continue;
            }
            System.debug('account.DealerGrade__c : '+account.DealerGrade__c);
            System.debug('customerGrade.KVGR4__c : '+customerGrade.KVGR4__c);

            account.DealerGrade__c = customerGrade.KVGR4__c;
            successAccountMap.put(account.Id, account);
        }

        for(Account accout : accountMap.values()){
            System.debug('accout : '+accout.Id);
        }

        update customerGradeList;

        Database.SaveResult[] accountResults = Database.update(successAccountMap.values(), false);


        for (Database.SaveResult res : accountResults) {
            if (!res.isSuccess()) {
                for (Database.Error err : res.getErrors()) {
                    System.debug('계정 업데이트 오류: ' + err.getMessage());
                }
            }
        }
    }

// FINISH    
    public void finish(Database.BatchableContext BC) {
    }


    private Map<String,Account> findAccountByKunnr(List<IF_CustomerGrade__c>  customerGradeList){
        Set<String>         kunnrList     = getKunnrSet(customerGradeList);
        return getAccountMapByKuunrSet(kunnrList);
    }

    private Set<String>         getKunnrSet(List<IF_CustomerGrade__c>  customerGradeList){
        Set<String> kunnrList = new Set<String>();

        for(IF_CustomerGrade__c customerGrade : customerGradeList){
            String kunnr = String.valueOf(Integer.valueOf(customerGrade.KUNNR__c));
            kunnrList.add(kunnr);
        }
        System.debug('getKunnrSet - result :  kunnrList.size() '+kunnrList.size());
        System.debug('KunnrSet - result :  kunnrList '+kunnrList);
        return kunnrList;
    }

    private Map<String,Account> getAccountMapByKuunrSet(Set<String> kunnrList){
        Map<String,Account> accountMap  = new Map<String,Account>();

        List<Account>   accountList = [SELECT Id, CustomerCode__c, DealerGrade__c, RecordTypeId  FROM Account WHERE CustomerCode__c IN :kunnrList];

        if(!accountList.isEmpty()){
            for(Account account : accountList){
                accountMap.put(account.CustomerCode__c, account);
            }
        }

        System.debug('getAccountMapByKuunrSet - result :  accountList.size() '+accountList.size());
        return accountMap;
    } 

    private String              getAccountDealerId(){
        RecordType recordType = [
                                SELECT Id, Name, DeveloperName, SobjectType  
                                FROM RecordType 
                                WHERE DeveloperName = 'Dealer'
                                AND Name = 'Dealer'
                                And SobjectType = 'Account'
                                LIMIT 1];
        if(recordType == null){
            throw new SystemException();
        }                               
        return recordType.Id;
    }

    public class ExceptionDto{
        private String key ;
        private String value; 
        private String errorMesage;
        public ExceptionDto(){}
        public ExceptionDto(String key, String value, String errorMesage){
            this.key = key;
            this.value = value;
            this.errorMesage = errorMesage;
        }

        public ExceptionDto NOT_FOUND_ACCOUNT(String value){
            return new ExceptionDto('KUNNR',value,'Not Exist Account. KUNNR : '+value);
        }

        public ExceptionDto IS_NOT_DEALER(String value){
            return new ExceptionDto('RecordType',value,'THIS ACCOUNT IS NOT DEALER. ACCOUNT Id : '+value);
        }
    } 

    public class SystemException extends Exception{}

}