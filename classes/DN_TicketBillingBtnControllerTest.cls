/**
 * @description       : DN_TicketBillingBtnController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-25
 * @last modified by  : Hayeong Min
 * @Percentage        :
**/
@isTest
public with sharing class DN_TicketBillingBtnControllerTest {
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
 
        RecordType product_recordType = TestDataFactoryForSales.getRecordType('ServicePackage', 'Product2');
 
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
 
        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler', 'QuoteLineItemTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
   
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
   
            dealer = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        prod.RecordTypeId = product_recordType.Id;
        prod.Field2__c = '1개월;2개월;3개월;4개월;';
        prod.StandardDay__c = '설치일';
        prod.IsActive = true;
        insert prod;

        List<Order> orderList = new List<Order>();
        List<Asset> assetList = new List<Asset>();
        List<Case> caseList = new List<Case>();
        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            Contact con = TestDataFactoryForSales.createContact('CSCustomer', acc.Id);
            insert con;

            PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
            insert entry;    

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem1 = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem1;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;
            System.debug('quote RecordType :: '+quote.RecordTypeId);


            QuoteLineItem qItem1 = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem1, prod);
            qItem1.Quote_RecordType__c = 'Korea';
            insert qItem1;

            Order order1 = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order1.CreatedDate = Date.newInstance(2025, 1, 22);
            orderList.add(order1);

            Order order2 = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order2.CreatedDate = Date.newInstance(2025, 1, 22);
            order2.IsBilled__c = 'Y';
            orderList.add(order2);

            insert orderList;

            Asset asset1 = TestDataFactoryForService.createAsset(acc.Id);
            assetList.add(asset1);

            Asset asset2 = TestDataFactoryForService.createAsset(acc.Id);
            asset2.Order__c = order1.Id;
            assetList.add(asset2);
            
            Asset asset3 = TestDataFactoryForService.createAsset(acc.Id);
            asset3.Order__c = order2.Id;
            assetList.add(asset3);

            insert assetList;
            
            Case ticket1 = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, asset1.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            caseList.add(ticket1);
            Case ticket2 = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, asset2.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            caseList.add(ticket2);
            Case ticket3 = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, asset3.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            caseList.add(ticket3);

            insert caseList;

        }
        
    }

    @isTest
    static void testChangeBillingStatus(){   
        Case ticket1 = [SELECT Id FROM Case WHERE Asset.Order__c = null LIMIT 1];
        Case ticket2 = [SELECT Id FROM Case WHERE Asset.Order__r.isBilled__c = 'N' LIMIT 1];
        Case ticket3 = [SELECT Id FROM Case WHERE Asset.Order__r.isBilled__c = 'Y' LIMIT 1];

        Test.startTest();
        DN_TicketBillingBtnController.changeBillingStatus(ticket1.Id);
        DN_TicketBillingBtnController.changeBillingStatus(ticket2.Id);
        DN_TicketBillingBtnController.changeBillingStatus(ticket3.Id);
        DN_TicketBillingBtnController.changeBillingStatus('Exception');
        Test.stopTest();
    }
}