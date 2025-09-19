@isTest
public with sharing class DN_QuoteReCreateControllerTest {
    @TestSetup
    static void makeData(){

    }
    @isTest
    static void testRunning() {
        Test.startTest();
        DN_QuoteReCreateController.dummy();

        Test.stopTest();

    }
}