@isTest
public with sharing class DN_SalesPerformanceTableTest {

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ORDER-003', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc.Id);
        insert ifClass;

        OrderPromotion__c oProm = TestDataFactoryForSales.createOrderPromotion();
        insert oProm;

        OrderIncentive__c incentive = TestDataFactoryForSales.createOrderIncentive();
        insert incentive;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            List<T_COND_ELMT__c> condList = new List<T_COND_ELMT__c>();
            T_COND_ELMT__c cond01 = new T_COND_ELMT__c(Quote_Line_Item__c = qItem.Id, KSCHL__c = 'ZPR8', VKORG__c = '1800', VTWEG__c = '10', ZZKVGR4__c = 'B', ZTERM__c = 'C007', KBETR__c = '127600000.00');
            T_COND_ELMT__c cond02 = new T_COND_ELMT__c(Quote_Line_Item__c = qItem.Id, KSCHL__c = 'ZPR8', VKORG__c = '1800', VTWEG__c = '10', ZZKVGR4__c = 'C', ZTERM__c = 'C007', KBETR__c = '128400000.00');
            T_COND_ELMT__c cond03 = new T_COND_ELMT__c(Quote_Line_Item__c = qItem.Id, KSCHL__c = 'ZPR8', VKORG__c = '1800', VTWEG__c = '10', ZZKVGR4__c = 'B', ZTERM__c = 'C006', KBETR__c = '127100000.00');
            T_COND_ELMT__c cond04 = new T_COND_ELMT__c(Quote_Line_Item__c = qItem.Id, KSCHL__c = 'ZPR8', VKORG__c = '1800', VTWEG__c = '10', ZZKVGR4__c = 'C', ZTERM__c = 'C006', KBETR__c = '127900000.00');
            T_COND_ELMT__c cond05 = new T_COND_ELMT__c(Quote_Line_Item__c = qItem.Id, KSCHL__c = 'ZPR9', VKORG__c = '1800', VTWEG__c = '10', ZZKVGR4__c = 'B', KBETR__c = '127600000.00');
            T_COND_ELMT__c cond06 = new T_COND_ELMT__c(Quote_Line_Item__c = qItem.Id, KSCHL__c = 'ZPR9', VKORG__c = '1800', VTWEG__c = '10', ZZKVGR4__c = 'C', KBETR__c = '127600000.00');
            T_COND_ELMT__c cond07 = new T_COND_ELMT__c(Quote_Line_Item__c = qItem.Id, KSCHL__c = 'ZPR7', VKORG__c = '1800', VTWEG__c = '10', ZZKVGR4__c = 'B', KBETR__c = '137900000.00');
            condList.add(cond01);
            condList.add(cond02);
            condList.add(cond03);
            condList.add(cond04);
            condList.add(cond05);
            condList.add(cond06);
            condList.add(cond07);
            insert condList;

            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.PaymentTerms__c = 'C006';
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            OrderItem oItemSQ = TestDataFactoryForSales.createOrderSQ(order.Id, prod.Id, entry.Id, qItem.Id, sq.Id, '000020');
            insert oItemSQ;

            OrderItem oItemAccessory = TestDataFactoryForSales.createOrderAccessory(order.Id, prod.Id, entry.Id, qItem.Id, accessory.Id, '000030');
            insert oItemAccessory;

            CharacteristicValue__c cv = TestDataFactoryForSales.createCV(qItem.Id, null, null);
            insert cv;

            CVOrderItem__c cvOItem = TestDataFactoryForSales.createCVJunction(cv.Id, oItemProd.Id);
            insert cvOItem;

            OrderPricingSelected__c selectedProm = TestDataFactoryForSales.createSelectedProm(order.Id);
            insert selectedProm;
        }
        // 테스트용 Sales_Goal__c 데이터 삽입
        List<Sales_Goal__c> goals = new List<Sales_Goal__c>();
        for (Integer i = 1; i <= 12; i++) {
            goals.add(new Sales_Goal__c(
                Sales_Goal_Name__c = '2025-' + i + '월',
                Corporation__c = '한국',
                YYYY__c = '2025',
                MM__c = String.valueOf(i),
                TargetAmount__c = 1000000
            ));
        }

        // 글로벌용
        for (Integer i = 1; i <= 12; i++) {
            goals.add(new Sales_Goal__c(
                Sales_Goal_Name__c = '2025-' + i + '월',
                Corporation__c = '유럽직수출',
                YYYY__c = '2025',
                MM__c = String.valueOf(i),
                TargetAmount__c = 2000000
            ));
        }

        insert goals;
    }

    @isTest
    static void testGetPerformanceData() {
        Test.startTest();
        List<DN_SalesPerformanceTable.PerformanceRow> result = DN_SalesPerformanceTable.getPerformanceData();
        DN_SalesPerformanceTable.dummy();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.size() > 0, '결과가 있어야 합니다.');
    }
    @isTest
    static void testGetPerformanceDataGlobal() {
        Test.startTest();
        List<DN_SalesPerformanceTable.PerformanceRow> result = DN_SalesPerformanceTable.getPerformanceDataGlobal();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.size() > 0, '글로벌 결과가 있어야 합니다.');
    }
}