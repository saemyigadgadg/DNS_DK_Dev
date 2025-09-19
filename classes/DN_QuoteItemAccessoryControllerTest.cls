@isTest 
public with sharing class DN_QuoteItemAccessoryControllerTest {
    @TestSetup
    static void makeData(){

        // User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        // System.debug('test01 - thisUser ::: ' + thisUser);

        // Country__c country = TestDataFactoryForSales.createKRCountry();
        // insert country;

        // TestDataFactoryForSales.activatePriceBook();

        // Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
        // TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        // User dealer;
        // System.runAs(thisUser) {
        //     Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
        //     insert dealerAcc;
    
        //     Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
        //     insert delaerCon;
    
        //     dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
        //     insert dealer;

        //     User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
        //     insert kaUser;
        // }

        // Product2 prod = TestDataFactoryForSales.createProduct();
        // insert prod;

        // PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        // insert entry;

        // List<AlertManager__c> alertList = new List<AlertManager__c>();
        // alertList.add(TestDataFactoryForSales.createAlertManager('OrderKeyAccountCreated'));
        // alertList.add(TestDataFactoryForSales.createAlertManager('OrderStatusConfirmed'));
        // alertList.add(TestDataFactoryForSales.createAlertManager('OrderCanceled'));
        // alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalApproved'));
        // alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalRejected'));
        // insert alertList;

        // Asset asset = TestDataFactoryForSales.createAsset();
        // insert asset;

        // System.runAs(dealer) {
        //     Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
        //     insert parentAcc;

        //     Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
        //     acc.CustomerCode__c   = '123456';
        //     acc.BusinessNumber__c = '5148171773';
        //     acc.Representative__c = 'realAcc';
        //     insert acc;

        //     SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
        //     insert area;
    
        //     Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        //     insert con;

        //     System.debug('test01 check query count 01 : ' + Limits.getQueries());
        //     Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
        //     insert opty;

        //     System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
        //     OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
        //     insert oItem;

        //     System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
        //     Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
        //     insert quote;

        //     System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
        //     QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
        //     insert qItem;

        //     System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
        //     SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
        //     insert sq;

        //     System.debug('test01 check query count 06 : ' + Limits.getQueries() + ' / ' + sq);
        //     Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
        //     insert accessory;

        //     Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
        //     insert dnsaQuote;

        //     QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
        //     insert dnsaQItem;
        // }
    }
    @isTest
    static void testFetchSearchInfo() {
        // List<QuoteLineItem> quoteLineItemIds = [SELECT Id, QuoteId FROM QuoteLineItem];
        // List<String> qlid = new List<String>();
        // List<String> qlid2 = new List<String>();
        // if(quoteLineItemIds.size() > 0){
        //     for(Integer i = 0 ; i < quoteLineItemIds.size(); i++){
        //         qlid.add(quoteLineItemIds[i].Id);
        //     }
        // }
        // QuoteLineItem qt2up = new QuoteLineItem();
        // qt2up.Id = qlid[1];
        // qt2up.ERPQuotationNo__c = '1111';
        // update qt2up;

        // Accessory__c accory = new Accessory__c();
        // accory.QuoteLineItem__c = qlid[0];
        // accory.Category__c = 'test';
        // accory.Key__c  = 'DNM4504-F0MP-1-K31';
        // accory.Name = 'DNM4504-F0MP-1-K31';
        // accory.Description__c ='test';
        // accory.Quantity__c = 1; 
        // accory.SalesUnit__c = '10';
        // accory.Delete__c = '';
        // accory.Quote__c = quoteLineItemIds[0].QuoteId;
        // // accory.ShipTo__c = acc.Id;
        // accory.MachineRequestShipDate__c = Date.today();
        // insert accory;

        // Accessory__c accoryerp = new Accessory__c();
        // accoryerp.QuoteLineItem__c = qlid[1];
        // accoryerp.Category__c = 'test';
        // accoryerp.Key__c  = 'DNM4504-F0MP-1-K31';
        // accoryerp.Name = 'DNM4504-F0MP-1-K31';
        // accoryerp.Description__c ='test';
        // accoryerp.Quantity__c = 1; 
        // accoryerp.SalesUnit__c = '10';
        // accoryerp.Delete__c = 'I';
        // accoryerp.Quote__c = quoteLineItemIds[1].QuoteId;
        // accoryerp.MachineRequestShipDate__c = Date.today();
        // insert accoryerp;

        // List<DN_QuoteItemAccessoryController.TableWrapper> selTableData = new List<DN_QuoteItemAccessoryController.TableWrapper>();
        // DN_QuoteItemAccessoryController.TableWrapper selTableData1 = new DN_QuoteItemAccessoryController.TableWrapper();
        // selTableData1.category       = 'test';
        // selTableData1.key            = 'DNM4504-F0MP-1-K31';
        // selTableData1.kit            = 'DNM4504-F0MP-1-K31';
        // selTableData1.description    = 'test';
        // selTableData1.quantity       = 1;
        // selTableData1.salesUnit      = '10';
        // selTableData1.del            = '';
        // selTableData1.shipDate       = Date.today();
        // selTableData.add(selTableData1);
        
        // DN_QuoteItemAccessoryController.TableWrapper selTableData2 = new DN_QuoteItemAccessoryController.TableWrapper();
        // selTableData2.category       = 'test';
        // selTableData2.key            = 'DNM4504-F0MP-1-K312';
        // selTableData2.kit            = 'DNM4504-F0MP-1-K312';
        // selTableData2.description    = 'test2';
        // selTableData2.quantity       = 1;
        // selTableData2.salesUnit      = '10';
        // selTableData2.del            = '';
        // selTableData2.shipDate       = Date.today();
        // selTableData.add(selTableData2);

        // // DN_QuoteItemAccessoryController.TableWrapper selTableData3 = new DN_QuoteItemAccessoryController.TableWrapper();
        // // selTableData3.category       = 'test';
        // // selTableData3.key            = 'DNM4504-F0MP-1-K313';
        // // selTableData3.kit            = 'DNM4504-F0MP-1-K313';
        // // selTableData3.description    = 'test3';
        // // selTableData3.quantity       = 1;
        // // selTableData3.salesUnit      = '10';
        // // selTableData3.del            = 'I';
        // // selTableData3.shipDate       = Date.today();
        // // selTableData.add(selTableData3);

        // InterfaceCommonUtil.setInterface('IF-OPTY-004', 'IF_ERP_Product');
        // InterfaceCommonUtil.setInterface('IF-OPTY-031', 'IF_ERP_Product');
        // InterfaceCommonUtil.setInterface('IF-OPTY-031', 'IF_ERP_ORDER');

        Test.startTest();
        // 검색어 설정
        // String searchTerm = '4504';

        // // 메서드 실행
        // DN_QuoteItemAccessoryController.fetchSearchInfo(searchTerm);
        // DN_QuoteItemAccessoryController.fetchModalInfo('DNM4504-F0MP-1-K31', qlid);
        // DN_QuoteItemAccessoryController.accessoryAvaliable('DNM4504-F0MP-1-K31');
        // DN_QuoteItemAccessoryController.saveAccessories(qlid, selTableData);
        DN_QuoteItemAccessoryController.dummy();

        Test.stopTest();
    }
}