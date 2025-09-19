@isTest
public with sharing class CS_SequenceGenerator_TEST {
    @TestSetup
    static void makeData(){
        AssignmentRule__c assignRule = new AssignmentRule__c(
            Name ='기술상담사 순차배정',
            Description__c ='기술상담사 배정 Rule 관리',
            AssignmentType__c = 'Owner',
            Corporation__c = 'DNS'
        );
        insert assignRule;

        List<AssignmentMember__c> sequenceList = new List<AssignmentMember__c>();
        AssignmentMember__c assignment = new AssignmentMember__c(
            User__c = UserInfo.getUserId(),
            AssignmentRule__c = assignRule.Id,
            CurrentAssignment__c = false,
            Index__c = 1
        );
        sequenceList.add(assignment);
        AssignmentMember__c assignment2 = new AssignmentMember__c(
            User__c = UserInfo.getUserId(),
            AssignmentRule__c = assignRule.Id,
            CurrentAssignment__c = true,
            Index__c = 2
        );
        sequenceList.add(assignment2);
        insert sequenceList;
    }

    @isTest
    static void getSequence() {
        test.startTest();
            try {
                CS_SequenceGenerator sequenceGenerator = new CS_SequenceGenerator('기술상담사 순차배정');
                Integer lastIndex = sequenceGenerator.lastIndex;
                sequenceGenerator.generate(sequenceGenerator.startIndex);
                sequenceGenerator.updateForCurrentAssignment();
            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            try {
                CS_SequenceGenerator sequenceGenerator = new CS_SequenceGenerator('test');
                Integer lastIndex = sequenceGenerator.lastIndex;
                sequenceGenerator.generate(sequenceGenerator.startIndex);
                sequenceGenerator.updateForCurrentAssignment();
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        test.stopTest();
    }
}