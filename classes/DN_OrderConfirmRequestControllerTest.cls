/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-11-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class DN_OrderConfirmRequestControllerTest {
    @TestSetup
    static void makeData(){
        // Profile 생성
        // Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c korea = TestDataFactoryForSales.createKRCountry();
        insert korea;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', korea, null);
        insert dealerAcc;

        Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
        insert delaerCon;

        String servicePackage = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('ServicePackage').getRecordTypeId();

        Product2 prod = TestDataFactoryForService.createProduct();
        prod.recordTypeId = servicePackage;
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;


            Account acc = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForService.createContact('ContactPerson', acc.Id);
            insert con;
            Date today = Date.today();
            Opportunity opty = new Opportunity(
                // Id pBookId = Test.getStandardPricebookId();
                AccountId               = acc.Id,
                // RecordTypeId            = '012F7000000KW4VIAW',
                Name                    = 'test opportunity',
                StageName               = 'Identified',
                // LeadSource              = 'Employee Referral',
                // CurrencyIsoCode         = 'KRW',
                // opty.Pricebook2Id            = pBookId;
                OwnerId                 = user1.Id,
                // MainCategory__c         = 'MB',
                // SubCategory__c          = 'MB2',
                // IsTooling__c            = 'MY',
                // Country__c              = 'KR',
                // Budget__c               = 100000000,
                RequestDelieveryDate__c = today.addMonths(2),
                CloseDate               = today.addMonths(1)
                // OpportunityIdentifier__c = user1.Id,
                // Opportunity_Owner__c    = user1.Id
                // ForecastCategory        = 'ForecastCategory'

            );
            insert opty;


            // Opportunity opty1 = TestDataFactoryForSales.createDNSDomesticOpty(acc, user1, 'Service');
            // insert opty1;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(user1, opty, 'Service');
            insert quote;

            Asset equip = new Asset(Name = 'Test Equipment', AccountId = acc.Id);
            insert equip;
            opty.Equipment__c = equip.Id;
            update opty;


            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            Order order = TestDataFactoryForService.createDNSDomesticOrder(acc, opty, quote, user1, 'DNS');
            order.ERPPSONo__c  = 'test';
            order.Warranty__c  = 'B1D';
            order.OrderSegmentation__c  = 'DirectSales';
            order.ReqDeliveryDate_PSO__c = Date.today().addDays(5);
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            ServicePackageProduct__c spp = new ServicePackageProduct__c(
                Name = qItem.Product2.Name,
                Product__c = qItem.Product2Id,
                Equipments__c = qItem.Quote.EquipmentId__c,
                Order__c = order.Id,
                StartServiceDate__c = order.ReqDeliveryDate_PSO__c
            );
            insert spp;
    }
    
    @isTest
    static void serviceValidateOrderConfrimTest() {        
        Order order = [SELECT Id FROM Order LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
    
        Test.startTest();
        DN_OrderConfirmRequestController.serviceValidateOrderConfrim(order.Id);
        Test.stopTest();
    }

    @isTest
    static void servicePackageCreateTest() {
        Order ord = [SELECT Id, QuoteId, ReqDeliveryDate_PSO__c FROM Order LIMIT 1];
        List<Order> orderList = new List<Order>{ord};
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem LIMIT 1];
        ServicePackageProduct__c spp = [SELECT Id FROM ServicePackageProduct__c LIMIT 1];
        TriggerHandler.bypassedHandlers.add('AssetTriggerHandler');

        Test.startTest();
        DN_OrderConfirmRequestController.createServicePackage(orderList);
        Test.stopTest();
    }
    
    @isTest
    static void serviceRequestConfrimTest_Parts() {
        InterfaceCommonUtil.setInterface('IF-PARTS-005', 'IF_ERP_Parts_Order');
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        prod.ServicePackage__c = '보증연장';
        update prod;
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        oppty.ServiceOpportunityType__c = 'Parts';
        update oppty;
        Order order = [SELECT Id, QuoteId, ReqDeliveryDate_PSO__c, ServiceOpportunityType__c FROM Order LIMIT 1];

        
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem LIMIT 1];
        ServicePackageProduct__c spp = [SELECT Id FROM ServicePackageProduct__c LIMIT 1];
        TriggerHandler.bypassedHandlers.add('AssetTriggerHandler');

        Test.startTest();
        DN_OrderConfirmRequestController.serviceRequestConfrim(order.Id);
        Test.stopTest();
    }
    
    @isTest
    static void serviceRequestConfrimTest_Others() {
        InterfaceCommonUtil.setInterface('IF-ORDER-001', 'IF_ERP_Order');
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        oppty.ServiceOpportunityType__c = 'Others';
        update oppty;
        Order order = [SELECT Id, QuoteId, ReqDeliveryDate_PSO__c, ServiceOpportunityType__c FROM Order LIMIT 1];
        OrderItem oItem = [SELECT Id FROM OrderItem LIMIT 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem LIMIT 1];
        ServicePackageProduct__c spp = [SELECT Id FROM ServicePackageProduct__c LIMIT 1];
        TriggerHandler.bypassedHandlers.add('AssetTriggerHandler');

        Test.startTest();
        DN_OrderConfirmRequestController.serviceRequestConfrim(order.Id);
        Test.stopTest();
    }








}