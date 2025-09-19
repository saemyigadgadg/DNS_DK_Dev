@isTest
public with sharing class DN_BoardYoutubeController_TEST {
    @IsTest
    static void test1(){
        Test.startTest();
        Board__c board = new Board__c(
            Name = 'test board',
            Youtube__c = 'test.com'
        );
        insert board;
        DN_BoardYoutubeController.getYoutubeId(board.Id);
        Test.stopTest();
    }


    @IsTest // catchs
    static void test2(){
        try {

            Test.startTest();
                DN_BoardYoutubeController.getYoutubeId('catchIds');
            Test.stopTest();    
        } catch (Exception e) {
            
        } 
        
    }
}