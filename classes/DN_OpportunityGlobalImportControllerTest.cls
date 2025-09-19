@isTest
public with sharing class DN_OpportunityGlobalImportControllerTest {
    @TestSetup
    static void makeData(){

    }

    @isTest
    static void testFetchSearchInfo() {
        Test.startTest();
        DN_OpportunityGlobalImportController.dummy();
        Test.stopTest();
    }
}