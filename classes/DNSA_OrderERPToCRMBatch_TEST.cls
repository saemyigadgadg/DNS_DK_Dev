/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-05-27
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DNSA_OrderERPToCRMBatch_TEST {
    
    @testSetup
    static void setupTestData() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        TriggerHandler.bypassedHandlers = new Set<String>{
            'AccountTriggerHandler'
            , 'SalesAreaDataTrigger'
            , 'OpportunityTriggerHandler'
            , 'QuoteTriggerHandler'
        };

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

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'USD');
        insert entry;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('DNSACustomer', country, null);
            acc.CurrencyIsoCode = 'USD';
            acc.Country__c = 'US';
            acc.SalesDistrict__c = 'M3US';
            acc.SalesOffice__c = '414A';
            acc.SalesOrganization__c = '4140';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            area.SalesDistrict__c = acc.SalesDistrict__c;
            area.SalesOrganization__c = acc.SalesOrganization__c;
            area.Currency__c = acc.CurrencyIsoCode;
            area.CurrencyIsoCode = acc.CurrencyIsoCode;
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            // Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            // insert opty;

            // OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            // oItem.ERPInquiryNo__c = '0600203414';
            // insert oItem;

            // Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            // insert quote;

            // QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            // qItem.ERPQuotationNo__c = '0701069991';
            // insert qItem;
        }

        List<IF_Order__c> orderList = new List<IF_Order__c>();
        IF_Order__c order01 = new IF_Order__c(
            TABLE_NAME__c = 'T_ORDER'
            , VBELN__c = '0201986112'
            , PSO_NUM__c = '0201884286'
            , AUART__c = 'ZDOB'
            , BSTKD__c = '920321'
            , WAERK__c = 'USD'
            , ZTERM__c = 'C001'
            , VDATU__c = '2025-06-06'
            , KUNNR_AG__c = '0000000'
            , KUNNR_RE__c = '0000000'
            , KUNNR_RG__c = '0000000'
            , KUNNR_WE__c = '0000000'
            , KUNNR_ZM__c = '0000000'
            , ZZSTATUS__c = 'A'
            , EQUNR__c = 'MH0029-000884'
            , AUGRU__c = '001'
            , INCO1__c = 'FOB'
            , VKBUR__c = '414A'
            , IHREZ__c = '0100455240'
            , VSBED__c = '10'
            , MATNR__c = 'DNM4504/F0IMP_AT8_12K;KOREA'
            , VKORG__c = '4140'
            , VTWEG__c = '10'
            , SPART__c = '40'
            , POSNR__c = '000010'
            , MAKTX__c = 'DNM4504-F0MP-1-K30'
            , BMENG__c = '1.000'
            , VRKME__c = 'EA'
            , NETWR_AMT__c = '191265.00'
            , TAX_AMT__c = '0.00'
            , WADAT_IST__c = '0000-00-00'
            , FKDAT__c = '0000-00-00'
            , IsDNSA__c = true
        );
        orderList.add(order01);

        IF_Order__c order02 = new IF_Order__c(
            TABLE_NAME__c = 'T_ORDER'
            , VBELN__c = '0201986112'
            , PSO_NUM__c = '0201884286'
            , AUART__c = 'ZDOB'
            , BSTKD__c = '920321'
            , WAERK__c = 'USD'
            , ZTERM__c = 'C001'
            , VDATU__c = '2025-06-06'
            , KUNNR_AG__c = '0000000'
            , KUNNR_RE__c = '0000000'
            , KUNNR_RG__c = '0000000'
            , KUNNR_WE__c = '0000000'
            , KUNNR_ZM__c = '0000000'
            , ZZSTATUS__c = 'A'
            , EQUNR__c = 'MH0029-000884'
            , AUGRU__c = '001'
            , INCO1__c = 'FOB'
            , VKBUR__c = '414A'
            , IHREZ__c = '0100455240'
            , VSBED__c = '10'
            , MATNR__c = '5701-9041'
            , VKORG__c = '4140'
            , VTWEG__c = '10'
            , SPART__c = '40'
            , POSNR__c = '000020'
            , MAKTX__c = 'CONVEYOR,CHIP;REAR MH250 4BOX NHP4'
            , BMENG__c = '1.000'
            , VRKME__c = 'EA'
            , NETWR_AMT__c = '11280.00'
            , TAX_AMT__c = '0.00'
            , WADAT_IST__c = '0000-00-00'
            , FKDAT__c = '0000-00-00'
            , IsDNSA__c = true
        );
        orderList.add(order02);

        IF_Order__c order03 = new IF_Order__c(
            TABLE_NAME__c = 'T_ZCRMS0094'
            , VBELN_SO__c = '0201986112'
            , PSO_NUM__c = '0201884286'
            , VBELN__c = '0081301326'
            , ZFETD__c = '2023-06-24'
            , ZFETA__c = '2023-07-28'
            , NAME1__c = '선진로지스틱스 주식회사'
            , WADAT_IST__c = '2023-06-24'
            , IsDNSA__c = true
        );
        orderList.add(order03);

        insert orderList;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        
        Database.executeBatch(new DNSA_OrderERPToCRMBatch(), 50);

        Test.stopTest();

    }
}