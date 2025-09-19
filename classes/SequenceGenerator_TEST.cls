@isTest
public with sharing class SequenceGenerator_TEST {
    @TestSetup
    static void makeData(){
        List<Sequence__c> sequenceList = new List<Sequence__c>();
        Sequence__c seq1 = new Sequence__c(
            Name ='DealerCustomer_Dealer',
            Type__c = 'Dealer', 
            Pattern__c = '1{000000}',
            SObjectAPI__c = 'DealerCustomer__c',
            StartNumber__c = 1
        );
        sequenceList.add(seq1);

        Sequence__c seq2 = new Sequence__c(
            Name ='DealerCustomer_Customer',
            Type__c = 'Customer', 
            Pattern__c = '5{000000}',
            SObjectAPI__c = 'DealerCustomer__c',
            StartNumber__c = 1
        );
        sequenceList.add(seq2);
        insert sequenceList;
    }

    @isTest
    static void getSequence() {
        test.startTest();

        SequenceGenerator seqGenerator = new SequenceGenerator('DealerCustomer__c');
        String dealerSequnce = seqGenerator.generate('Dealer');
        System.assert('1000001' == dealerSequnce , ' Not Equal Dealer Sequence');

        String customerSequnce = seqGenerator.generate('Customer');
        System.assert('5000001' == customerSequnce , ' Not Equal Customer Sequence');

        seqGenerator.updateNextSequenceInfo();

        try {
            seqGenerator.setSObjectAPI('Account');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        try {
            seqGenerator.generate('');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        

        test.stopTest();
    }
}