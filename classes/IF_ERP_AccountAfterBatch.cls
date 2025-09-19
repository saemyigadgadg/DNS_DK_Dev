public with sharing class IF_ERP_AccountAfterBatch 
                                                implements 
                                                        Database.Batchable<IF_Account__c> , 
                                                        Database.AllowsCallouts, 
                                                        Database.Stateful  {
    public IF_ERP_AccountAfterBatch(List<IF_Account__c> ifAccounts) {
        this.ifAccounts = ifAccounts;
    }

    private final List<IF_Account__c> ifAccounts;

    public Iterable<IF_Account__c> start(Database.BatchableContext BC){
        
        List<IF_Account__c> updateIfList = this.ifAccounts;
        System.debug('UPDATE IF ACCOUNT SIZE : '+updateIfList.size());
        return updateIfList;
    }

    public void execute(Database.BatchableContext BC, List<IF_Account__c> scope){
        update scope;
    }

    public void finish(Database.BatchableContext BC){
        System.debug('update If Account');
    }
}