/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class DN_OptyLineItemListControllerTest {
    
    @TestSetup
    static void makeData(){
        // Profile 생성
        // Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c korea = TestDataFactoryForSales.createKRCountry();
        insert korea;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', korea, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;

        Product2 prod = TestDataFactoryForService.createProduct();
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

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            // Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, user1, 'DNS');
            // order.ERPPSONo__c  = 'test';
            // insert order;
    }

    @isTest
    static void getOptyLITest() {        
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE StageName = 'Identified' LIMIT 1];
    
        Test.startTest();
        DN_OptyLineItemListController.getOptyLI(oppty.Id);
        Test.stopTest();
    }

    @isTest
    static void getProductPriceTest() {        
        InterfaceCommonUtil.setInterface('IF-PARTS-003', 'IF_ERP_Parts_Order');
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE StageName = 'Identified'  LIMIT 1];
        List<QuoteLineItem> opptyList = [SELECT Id, UnitPrice FROM QuoteLineItem];

        List<String> oppty1 = new List<String>{'0010'};
        List<String> oppty2 = new List<String>{'r18181'};
    
        Test.startTest();
        DN_OptyLineItemListController.getProductPrice(oppty.Id, oppty1, oppty2);
        Test.stopTest();
    }
    @isTest
    static void getQuoteProductPriceTest() {        
        InterfaceCommonUtil.setInterface('IF-PARTS-003', 'IF_ERP_Parts_Order');
        Quote qte = [SELECT Id FROM Quote LIMIT 1];
        List<QuoteLineItem> opptyList = [SELECT Id, UnitPrice FROM QuoteLineItem];

        List<String> oppty1 = new List<String>{'0010'};
        List<String> oppty2 = new List<String>{'r18181'};
    
        Test.startTest();
        DN_OptyLineItemListController.getQuoteProductPrice(qte.Id, oppty1, oppty2);
        Test.stopTest();
    }
    @isTest
    static void upsertOptyProductTest() {        
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE StageName = 'Identified' LIMIT 1];
        List<OpportunityLineItem> oliList = [SELECT Id, UnitPrice FROM OpportunityLineItem];
        List<DN_OptyLineItemListController.OptyLineItemWrapper> wrapperList = new List<DN_OptyLineItemListController.OptyLineItemWrapper>();
    
        for (OpportunityLineItem oli : oliList) {
            DN_OptyLineItemListController.OptyLineItemWrapper wrapper = new DN_OptyLineItemListController.OptyLineItemWrapper();
            wrapper.OptyLineItemId = oliList[0].Id;
            wrapper.UnitPrice = 1000;
            wrapperList.add(wrapper);
        }
        Test.startTest();
        String result = DN_OptyLineItemListController.upsertOptyProduct(wrapperList, oppty.Id);
        Test.stopTest();
    }

    @isTest
    static void upsertQuoteProductTest() {        
        Quote qte = [SELECT Id FROM Quote LIMIT 1];
        Product2 prod = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'R18181' LIMIT 1];
        PricebookEntry prib = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id LIMIT 1];
        List<QuoteLineItem> qliList = [SELECT Id, PricebookEntryId, Product2Id, UnitPrice, Quantity FROM QuoteLineItem WHERE QuoteId = :qte.Id];
        List<DN_OptyLineItemListController.QuoteLineItemWrapper> wrapperList = new List<DN_OptyLineItemListController.QuoteLineItemWrapper>();

        for (QuoteLineItem qli : qliList) {
            DN_OptyLineItemListController.QuoteLineItemWrapper wrapper = new DN_OptyLineItemListController.QuoteLineItemWrapper();
            wrapper.QuoteLineItemId = qliList[0].Id;
            wrapper.PricebookEntryId = prib.Id;
            wrapper.ProductId = prod.Id;
            wrapper.UnitPrice = 312700;
            wrapper.Quantity = 1;
            wrapper.ProductName = 'R18181';
            wrapper.ProductCode = 'R18181';
            // wrapper.Amount = Decimal.valueOf(qli.Amount);
            wrapper.isManualAmount = false;
            
            wrapperList.add(wrapper);
        }
        List<Product2> prodList = [SELECT Id FROM Product2];
        Test.startTest();
        String result = DN_OptyLineItemListController.upsertQuoteProduct(wrapperList, qte.Id);
        Test.stopTest();
    }

    @isTest
    static void getQuoteLITest() {        
        Quote qte = [SELECT Id FROM Quote LIMIT 1];
    
        Test.startTest();
        DN_OptyLineItemListController.getQuoteLI(qte.Id);
        Test.stopTest();
    }
    @isTest
    static void getQuoteDiscountTest() {        
        Quote qte = [SELECT Id FROM Quote LIMIT 1];
    
        Test.startTest();
        DN_OptyLineItemListController.getQuoteDiscount(qte.Id);
        Test.stopTest();
    }
    @isTest
    static void getProductTest() {        
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
    
        Test.startTest();
        DN_OptyLineItemListController.getProduct(prod.Id);
        Test.stopTest();
    }

    @isTest
    static void getEquipmentNameTest() {        
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE StageName = 'Identified' LIMIT 1];
    
        Test.startTest();
        DN_OptyLineItemListController.getEquipmentName(oppty.Id);
        Test.stopTest();
    }

    @isTest
    static void deleteOptyLineItemTest() {
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE StageName = 'Identified' LIMIT 1];
        List<QuoteLineItem> opptyList = [SELECT Id, UnitPrice FROM QuoteLineItem];

        List<String> oppty1 = new List<String>{'0010'};
        List<String> oppty2 = new List<String>{'r18181'};        
        
        Test.startTest();
        DN_OptyLineItemListController.ResultWrapper result = DN_OptyLineItemListController.deleteOptyLineItem(oppty1); // 018
        System.debug('result ::: ' + result);

        Test.stopTest();
    }
    @isTest
    static void deleteQuoteLineItemTest() {
        Quote qte = [SELECT Id FROM Quote LIMIT 1];
        System.debug('qte ::: ' + qte);
        List<QuoteLineItem> qteList = [SELECT Id, UnitPrice FROM QuoteLineItem];

        List<String> quote1 = new List<String>{'0010'};
        List<String> quote2 = new List<String>{'r18181'};        
        
        Test.startTest();
        DN_OptyLineItemListController.ResultWrapper result = DN_OptyLineItemListController.deleteQuoteLineItem(quote1); // 018
        System.debug('result ::: ' + result);

        Test.stopTest();
    }

    @isTest
    static void getGPESProductTest() {
        
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry prib = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<QuoteLineItem> qt = [SELECT Id, UnitPrice FROM QuoteLineItem];
        List<Product2> prodList = [SELECT Id FROM Product2];
        // PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod1.Id, UnitPrice = 100, IsActive = true);

        List<Map<String, Object>> targetList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'partNo' => '850409-03196',
                'qty' => '1',
                'lotSize' => 'AY',
                'salesPrice' => '0',
                'Id' => prodList[0].Id
            },
            new Map<String, Object>{
                'partNo' => 'R18181',
                'qty' => '1',
                'lotSize' => 'EA',
                'salesPrice' => '0',
                'Id' => prodList[0].Id
            }
        };
        String targetData = JSON.serialize(targetList);
        List<String> quote1 = new List<String>{'0010'};


        Test.startTest();
        DN_OptyLineItemListController.EventPartsResultWrapper result = DN_OptyLineItemListController.getGPESProduct(targetList);
        Test.stopTest();
    }
}