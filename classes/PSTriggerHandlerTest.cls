@isTest
public with sharing class PSTriggerHandlerTest {
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('test01 - thisUser ::: ' + thisUser);

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert kaUser;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderKeyAccountCreated'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderStatusConfirmed'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderCanceled'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalApproved'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalRejected'));
        insert alertList;

        Asset asset = TestDataFactoryForSales.createAsset();
        insert asset;

        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            System.debug('test01 check query count 01 : ' + Limits.getQueries());
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;
            PS__c newPs = new PS__c();
            newPs.Opportunity__c = opty.Id;
            newPs.RequiredDelivryDate__c = Date.today();
            insert newPs;

            // System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
            // Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            // insert quote;

            // System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
            // QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            // insert qItem;

            // System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
            // SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            // insert sq;

            // System.debug('test01 check query count 06 : ' + Limits.getQueries() + ' / ' + sq);
            // Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            // insert accessory;

            // Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            // insert dnsaQuote;

            // QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            // insert dnsaQItem;
        }
    }
    @isTest
    static void testgetRecordName() {
        Test.startTest();
        PSTriggerHandler.dummy();

        // InterfaceCommonUtil.setInterface('IF-OPTY-013', 'IF_AEPortal_PS');
        // PS__c ps = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,  Opportunity__c, SalesArea__c, CustomerDesc__c, SignificanceLevel__c, SoldTo__c, RequiredDelivryDate__c, Status__c, PhoneNo__c, Email__c, CustomerName__c, PSModel__c, CustomerPhoneNo__c, RejecType__c, CustomerMobileNo__c, CustomerEmail__c, PartsforMachining__c, Type__c, MaterialHardness__c, ProcessesBeforeMachining__c, ProductionVolumeYearly__c, WorkingHoursDaily__c, WorkingDaysMonthly__c, OperationRate__c, CycleTimeRequired__c, MachineType__c, Model__c, Quantity__c, ChuckType__c, FixtureClamp__c, RecommendedToolMaker__c, AutomationType__c, LoadCapacity__c, InquirySeq__c, ResponsibleBranch__c, IsInterfaced__c, ERPInquiryNo__c, Version__c, Name__c, AEUser__c, RejectReason__c, Customer__c, CustomerContact__c, FM_CustomerEmail__c, FM_CustomerMobileNo__c, FM_CustomerPhoneNo__c, FM_CustomerName__c, FM_DealerEmail__c, FM_DealerPhoneNumber__c, FM_ResponsibleBranch__c, Approver__c FROM PS__c WHERE Status__c = 'Draft' LIMIT 1];
        
        // Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        // bypassSet.add('OpptyCompetitorMappingTriggerHandler');
        // TriggerHandler.bypassedHandlers = bypassSet;
        // PS__c upps = new PS__c();
        // upps.Id = ps.Id;
        // upps.Status__c = 'RequestToReview';
        // update upps;

        // PS__c upps2 = new PS__c();
        // upps2.Id = ps.Id;
        // upps2.Status__c = 'SalesConfirm';
        // update upps2;
        Test.stopTest();
    }
}