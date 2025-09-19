/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-11-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class IF_PowerBI_Valid_Opportunity_Test {
    public IF_PowerBI_Valid_Opportunity_Test() {}

    public class IF_OPTY_035_HttpMock implements HttpCalloutMock {
        public IF_OPTY_035_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_MSGTY":"S","E_MSGTX":"Success"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TriggerHandler.bypassedHandlers = new Set<String>{
            'AccountTriggerHandler'
            , 'OpportunityTriggerHandler'
        };

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        insert acc;

        Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        insert con;

        Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, thisUser, 'General');
        opty.Inquiry_Type__c = 'ZIPA';
        opty.CurrencyIsoCode = 'KRW';
        insert opty;

        OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
        oItem.ERPInquiryNo__c = 'ERP1';
        insert oItem;
    }

    @isTest
    static void IF_PowerBI_Valid_Opportunity_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-035', 'IF_PowerBI_Valid_Opportunity');

        Test.startTest();

        // 배치 실행
        IF_PowerBI_Valid_Opportunity batch = new IF_PowerBI_Valid_Opportunity();
        batch.batchYear   = 2024;
        batch.batchMonth  = 12;

        Database.executeBatch(batch, 1);

        Test.stopTest();
    }
    @isTest
    private static void IF_PowerBI_Opportunity_Schedule_Test(){
        InterfaceCommonUtil.setInterface('IF-OPTY-035', 'IF_PowerBI_Valid_Opportunity');
        Test.startTest();
        IF_PowerBI_Valid_Opportunity scheduler = new IF_PowerBI_Valid_Opportunity();
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }
}