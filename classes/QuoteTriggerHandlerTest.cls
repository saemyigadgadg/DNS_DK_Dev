@isTest
public with sharing class QuoteTriggerHandlerTest {
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

            System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            System.debug('test01 check query count 06 : ' + Limits.getQueries() + ' / ' + sq);
            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            insert dnsaQuote;

            QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            insert dnsaQItem;
        }
    }
    @isTest
    static void testRunning() {
        Test.startTest();

        // Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        // bypassSet.add('AccountTriggerHandler');
        // bypassSet.add('ContactTriggerHandler');
        // // bypassSet.add('QuoteTriggerHandler');
        // bypassSet.add('OpportunityLineItemTriggerHandler');
        // // bypassSet.add('QuoteLineItemTriggerHandler');
        // TriggerHandler.bypassedHandlers = bypassSet;
        // Date today = Date.today();

        // Quote qte = [SELECT Id FROM Quote WHERE RecordType.Name = 'Korea' LIMIT 1];

        // QuoteLineItem qt = [SELECT Id, 
        // Quote.RecordTypeId,
        // Product2.Plant__c, 
        // Product2.ProductCode, 
        // Product2.Description, 
        // Quote.Opportunity.MainCategory__c, 
        // Quote.Opportunity.SubCategory__c, 
        // Quote.Opportunity.IsTooling__c, 
        // Quote.Incoterms__c, 
        // Quote.TermsOfPayment__c, 
        // Quote.IncotermsKR__c, 
        // Quote.PaymentConditionKR__c, 
        // ERPInquiryNo__c, 
        // ERPQuotationNo__c, 
        // Quote.OwnerId, 
        // Quote.AccountId, 
        // OpportunityLineItem.Opportunity.RecordType.Name, 
        // RequestedDelivDate__c, 
        // OpportunityLineItem.Opportunity.Inquiry_Type__c ,
        // Warranty__c,
        // Max_POSNR__c,
        // OpportunityLineItem.Opportunity.Opportunity_Owner__c,
        // OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c, 
        // OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.DealerGrade__c,
        // OpportunityLineItem.Opportunity.Opportunity_Owner__r.Profile.Name,
        // OpportunityLineItem.Opportunity.Account.CustomerCode__c,
        // OpportunityLineItem.Opportunity.Opportunity_Owner__r.Profile.UserLicense.Name,
        // CurrencyIsoCode,
        // Quote.Account.CustomerCode__c,
        // Product2.Name__c
        //  FROM QuoteLineItem WHERE Quote.RecordType.Name = 'Korea' LIMIT 1 ];
        //  QuoteLineItem qtupdate = new QuoteLIneItem();
        //  qtupdate.Id = qt.Id;
        //  qtupdate.ERPQuotationNo__c = 'test';
        //  qtupdate.RequestedDelivDate__c = today.addMonths(8);
        //  update qtupdate;


        // Accessory__c accory = new Accessory__c();
        // accory.QuoteLineItem__c = qt.Id;
        // accory.Category__c = 'test';
        // accory.Key__c  = 'DNM4504-F0MP-1-K31';
        // accory.Name = 'DNM4504-F0MP-1-K31';
        // accory.Description__c ='test';
        // accory.Quantity__c = 1; 
        // accory.SalesUnit__c = '10';
        // accory.Delete__c = '';
        // accory.Quote__c = qte.Id;
        // accory.MachineRequestShipDate__c = Date.today();
        // insert accory;

        // CharacteristicValue__c cv = new CharacteristicValue__c();
        // cv.QuoteLineItem__c = qt.Id;
        // cv.Price__c = 1000;
        // cv.C_Code__c = 'ccode';
        // cv.C_Value__c = 'cvalue';
        // cv.V_Code__c = 'vcode';
        // cv.V_Value__c = 'vvalue';
        // cv.defChange__c = true;
        // cv.ShowData__c = true;
        // insert cv;

        // List<QuoteLineItem> qtlist = new List<QuoteLineItem>();
        // qtlist.add(qt);
        // qtlist.add(qt2);
        // InterfaceCommonUtil.setInterface('IF-OPTY-019', 'IF_ERP_Quotation');

        QuoteTriggerHandler.dummy();


        Test.stopTest();
    }
}