@isTest
public class DN_OrderERPToCRMBatch_Test {
    @testSetup
    static void setupTestData() {
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
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = 'CUST001';
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
            oItem.ERPInquiryNo__c = '0600203414';
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            qItem.ERPQuotationNo__c = '0701069991';
            insert qItem;
        }

        IF_Order__c order = new IF_Order__c();
        order.VBELN__c      = 'ORD001';
        order.VBELN_I__c    = '0600203414';
        order.VBELN_Q__c    = '0701069991';
        order.AUART__c      = 'ZPO';
        order.WAERK__c      = 'USD';
        order.ZTERM__c      = 'PT01';
        order.VDATU__c      = '2025-03-07';
        order.KUNNR_AG__c   = 'CUST001';
        order.KUNNR_RE__c   = 'CUST001';
        order.MATNR__c      = 'DNM4504-F0MP-1-K30';
        order.NETWR_AMT__c  = '500.00';
        order.TAX_AMT__c    = '50.00';
        order.BMENG__c      = '10';
        order.VRKME__c      = 'PCS';
        order.POSNR__c      = '000010';
        order.MTART__c      = 'FPRO';
        order.FKDAT__c      = '2025-03-10';
        order.WADAT_IST__c  = '2025-03-12';
        order.BSTKD__c      = 'PO12345';
        order.ZZSTATUS__c   = 'C';
        order.IsConverted__c = false;
        order.IsDNSA__c      = false;
        insert order;

        IF_Order__c returnOrder = new IF_Order__c();
        returnOrder.VBELN__c      = 'ORD001';
        returnOrder.VBELN_I__c    = '0600203414';
        returnOrder.VBELN_Q__c    = '0701069991';
        returnOrder.AUART__c      = 'ZRE';
        returnOrder.WAERK__c      = 'USD';
        returnOrder.ZTERM__c      = 'PT01';
        returnOrder.VDATU__c      = '2025-03-07';
        returnOrder.KUNNR_AG__c   = 'CUST001';
        returnOrder.KUNNR_RE__c   = 'CUST001';
        returnOrder.MATNR__c      = 'DNM4504-F0MP-1-K30';
        returnOrder.NETWR_AMT__c  = '500.00';
        returnOrder.TAX_AMT__c    = '50.00';
        returnOrder.BMENG__c      = '10';
        returnOrder.VRKME__c      = 'PCS';
        returnOrder.POSNR__c      = '000010';
        returnOrder.MTART__c      = 'FPRO';
        returnOrder.FKDAT__c      = '2025-03-10';
        returnOrder.WADAT_IST__c  = '2025-03-12';
        returnOrder.BSTKD__c      = 'PO12345';
        returnOrder.ZZSTATUS__c   = 'C';
        returnOrder.IsConverted__c = false;
        returnOrder.IsDNSA__c      = false;
        insert returnOrder;

        IF_Order__c turnKeyOrder = new IF_Order__c();
        turnKeyOrder.VBELN__c      = 'ORD001';
        turnKeyOrder.VBELN_I__c    = '0600203414';
        turnKeyOrder.VBELN_Q__c    = '0701069991';
        turnKeyOrder.AUART__c      = 'ZPSA';
        turnKeyOrder.WAERK__c      = 'USD';
        turnKeyOrder.ZTERM__c      = 'PT01';
        turnKeyOrder.VDATU__c      = '2025-03-07';
        turnKeyOrder.KUNNR_AG__c   = 'CUST001';
        turnKeyOrder.KUNNR_RE__c   = 'CUST001';
        turnKeyOrder.MATNR__c      = 'P123456';
        turnKeyOrder.NETWR_AMT__c  = '500.00';
        turnKeyOrder.TAX_AMT__c    = '50.00';
        turnKeyOrder.BMENG__c      = '10';
        turnKeyOrder.VRKME__c      = 'PCS';
        turnKeyOrder.POSNR__c      = '000010';
        turnKeyOrder.MTART__c      = 'FPRO';
        turnKeyOrder.FKDAT__c      = '2025-03-10';
        turnKeyOrder.WADAT_IST__c  = '2025-03-12';
        turnKeyOrder.BSTKD__c      = 'PO12345';
        turnKeyOrder.ZZSTATUS__c   = 'C';
        turnKeyOrder.IsConverted__c = false;
        turnKeyOrder.IsDNSA__c      = false;
        insert turnKeyOrder;

    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        
        // 배치 실행
        DN_OrderERPToCRMBatch batchJob = new DN_OrderERPToCRMBatch();
        Database.executeBatch(batchJob, 50);

        Test.stopTest();

    }


}