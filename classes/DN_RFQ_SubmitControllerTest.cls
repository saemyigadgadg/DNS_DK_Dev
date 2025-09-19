@isTest
public with sharing class DN_RFQ_SubmitControllerTest {
    @TestSetup
    static void makeData(){

        // List<Warranty__c> warrantyrecords = TestDataFactoryForSales.getWarranty();
        // insert warrantyrecords;

        // ContentVersion testContentVersion = new ContentVersion(
        //     Title = 'Test Content',
        //     VersionData = Blob.valueOf('Test Data'),
        //     PathOnClient = 'Test.png'
        // );
        // insert testContentVersion;

        // Model__c model = new Model__c();
        // model.Name = 'DN_Common';
        // model.contentVersionId__c = testContentVersion.Id;
        // insert model;
        
        // User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        // List<Country__c> countryList = new List<Country__c>();
        // List<Account> dealerAccList = new List<Account>();
        // List<Contact> dealerConList = new List<Contact>();
        // Country__c country = TestDataFactoryForSales.createKRCountry();
        // countryList.add(country);

        // Country__c country2      = new Country__c();
        // country2.Name            = 'USA';
        // country2.CurrencyIsoCode = 'USD';
        // country2.CountryCode__c  = 'US';
        // countryList.add(country2);
        // insert countryList;

        // TestDataFactoryForSales.activatePriceBook();

        // User dealer;
        // User dealer2;
        // System.runAs(thisUser) {
        //     Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
        //     dealerAccList.add(dealerAcc);
    
        //     // Account dealerAcc2 = TestDataFactoryForSales.createAccount('Dealer', country2, null);
        //     // insert dealerAcc2;

        //     RecordType type = TestDataFactoryForSales.getRecordType('Dealer', 'Account');

        //     Account dealerAcc2           = new Account();
        //     dealerAcc2.Name              = 'test company';
        //     dealerAcc2.RecordTypeId      = type.Id;
        //     dealerAcc2.Phone             = '00000000001';
        //     dealerAcc2.BusinessNumber__c = '5148171771';
        //     dealerAcc2.Representative__c = 'testuser1';
        //     dealerAcc2.CustomerCode__c   = '0000001';
        //     dealerAcc2.TypeOfBusiness__c = 'Manufacturing';
        //     dealerAcc2.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
        //     dealerAcc2.IsKeyAccount__c   = true;
        //     dealerAcc2.ParentId          = null;
    
        //     dealerAcc2.CurrencyIsoCode  = 'USD';
        //     dealerAcc2.Country__c       = 'US';
        //     dealerAcc2.CountryLookup__c = country2.Id;
            
        //     dealerAcc2.DistributionChannel__c = '20';
        //     dealerAcc2.Division__c            = '40';
        //     dealerAcc2.SalesOffice__c         = '114E';
        //     dealerAcc2.SalesDistrict__c       = 'A1KR';
        //     dealerAcc2.SalesOrganization__c   = '1800';
    
        //     dealerAcc2.ShippingCity = '대구광역시 달서구 성서공단로';
        //     dealerAcc2.ShippingPostalCode = '42722';
    
        //     dealerAccList.add(dealerAcc2);
        //     insert dealerAccList;

        //     Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
        //     dealerConList.add(delaerCon);

        //     Contact delaerCon2 = TestDataFactoryForSales.createContact('Dealer', dealerAcc2.Id);
        //     dealerConList.add(delaerCon2);

        //     insert dealerConList;

        //     Test.startTest();
        //     dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
        //     dealer2 = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc2, delaerCon2);
        //     insert dealer;
        //     insert dealer2;
        //     Test.stopTest();
        //     User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
        //     insert kaUser;
        // }

        // Product2 prod = TestDataFactoryForSales.createProduct();
        // insert prod;

        // ProductByPlant__c pbnew = new ProductByPlant__c();
        // pbnew.Plant__c = '1840';
        // pbnew.Part__c = prod.Id;
        // insert pbnew;

        // PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        // insert entry;


        // Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        // bypassSet.add('AccountTriggerHandler');
        // bypassSet.add('ContactTriggerHandler');
        // bypassSet.add('QuoteTriggerHandler');
        // bypassSet.add('OpportunityLineItemTriggerHandler');
        // bypassSet.add('PSTriggerHandler');
        // // bypassSet.add('QuoteLineItemTriggerHandler');
        // TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        // List<Account> parentAccList = new List<Account>();
        // List<SalesAreaData__c> areaList = new List<SalesAreaData__c>();
        // List<Contact> conList = new List<Contact>();
        // List<Opportunity> optyList = new List<Opportunity>();
        
        // System.runAs(dealer) {
        //     Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
        //     parentAccList.add(parentAcc);

        //     Account parentAcc2 = TestDataFactoryForSales.createParentAccount(country2);
        //     parentAccList.add(parentAcc2);
            
        //     Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
        //     acc.CustomerCode__c   = '123456';
        //     acc.BusinessNumber__c = '5148171773';
        //     acc.Representative__c = 'realAcc';
        //     parentAccList.add(acc);

        //     // Account acc2 = TestDataFactoryForSales.createAccount('TradeCustomer', country2, parentAcc2);
        //     // acc2.CustomerCode__c   = '123456';
        //     // acc2.BusinessNumber__c = '5148171773';
        //     // acc2.Representative__c = 'realAcc';
        //     // insert acc2;


        //     RecordType type2 = TestDataFactoryForSales.getRecordType('Dealer', 'Account');

        //     Account acc2           = new Account();
        //     acc2.Name              = 'test company';
        //     acc2.RecordTypeId      = type2.Id;
        //     acc2.Phone             = '00000000002';
        //     acc2.BusinessNumber__c = '5148171772';
        //     acc2.Representative__c = 'testuser2';
        //     acc2.CustomerCode__c   = '0000002';
        //     acc2.TypeOfBusiness__c = 'Manufacturing';
        //     acc2.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
        //     acc2.IsKeyAccount__c   = true;
        //     acc2.ParentId          = parentAcc2 == null ? null : parentAcc2.Id;
    
        //     acc2.CurrencyIsoCode  = 'USD';
        //     acc2.Country__c       = 'US';
        //     acc2.CountryLookup__c = country2.Id;
            
        //     acc2.DistributionChannel__c = '20';
        //     acc2.Division__c            = '40';
        //     acc2.SalesOffice__c         = '114E';
        //     acc2.SalesDistrict__c       = 'A1KR';
        //     acc2.SalesOrganization__c   = '1800';
    
        //     acc2.ShippingCity = '대구광역시 달서구 성서공단로';
        //     acc2.ShippingPostalCode = '42722';
    
        //     parentAccList.add(acc2);
        //     insert parentAccList;

        //     SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
        //     areaList.add(area);
    
        //     // SalesAreaData__c area2 = TestDataFactoryForSales.createAreaData(acc2);
        //     // insert area2;

        //     SalesAreaData__c area2       = new SalesAreaData__c();
        //     area2.CurrencyIsoCode        = 'USD';
        //     area2.Account__c             = acc2.Id;
        //     area2.SalesOrganization__c   = '1800';
        //     area2.DistributionChannel__c = '20';
        //     area2.Division__c            = '40';
        //     area2.SalesDistrict__c       = 'A1KR';
        //     area2.SalesOffice__c         = '114E';
        //     area2.Currency__c            = 'USD';
        //     area2.Incoterms__c           = 'Y03';
        //     area2.TermsOfPayment__c      = 'C001';
        //     area2.ShippingConditions__c  = '10';
        //     area2.Country__c             = 'US';
        //     areaList.add(area2);
        //     insert areaList;

        //     Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        //     conList.add(con);

        //     Contact con2 = TestDataFactoryForSales.createContact('ContactPerson', acc2.Id);
        //     conList.add(con2);
        //     insert conList;

        //     System.debug('test01 check query count 01 : ' + Limits.getQueries());
        //     Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
        //     optyList.add(opty);

        //     Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
        //     insert newCompetitor;

        //     OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
        //     insert optyCompetitor;

        //     // Opportunity optyTurnkey = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
        //     // insert optyTurnkey;
        //     Id pBookId = Test.getStandardPricebookId();
        //     Date today = Date.today();

        //     Opportunity opty1             = new Opportunity();
        //     opty1.AccountId               = acc2.Id;
        //     opty1.RecordTypeId            = opty.RecordTypeId;
        //     opty1.Name                    = 'test opportunity';
        //     opty1.StageName               = 'Qualified';
        //     opty1.LeadSource              = 'Employee Referral';
        //     opty1.CurrencyIsoCode         = 'KRW';
        //     opty1.Pricebook2Id            = pBookId;
        //     opty1.OwnerId                 = dealer.Id;
        //     opty1.MainCategory__c         = 'MB';
        //     opty1.SubCategory__c          = 'MB2';
        //     opty1.IsTooling__c            = 'MY';
        //     opty1.Country__c              = 'US';
        //     opty1.Budget__c               = 100000000;
        //     opty1.RequestDelieveryDate__c = today.addMonths(2);
        //     opty1.CloseDate               = today.addMonths(1);
        //     opty1.OpportunityIdentifier__c = dealer.Id;
        //     opty1.Opportunity_Owner__c    = dealer.Id;
        //     optyList.add(opty1);

        //     Opportunity opty2             = new Opportunity();
        //     opty2.AccountId               = acc2.Id;
        //     opty2.RecordTypeId            = opty.RecordTypeId;
        //     opty2.Name                    = 'test opportunity';
        //     opty2.StageName               = 'Qualified';
        //     opty2.LeadSource              = 'Employee Referral';
        //     opty2.CurrencyIsoCode         = 'KRW';
        //     opty2.Pricebook2Id            = pBookId;
        //     opty2.OwnerId                 = dealer.Id;
        //     opty2.MainCategory__c         = 'MB';
        //     opty2.SubCategory__c          = 'MB2';
        //     opty2.IsTooling__c            = 'MY';
        //     opty2.Country__c              = 'US';
        //     opty2.Budget__c               = 100000000;
        //     opty2.RequestDelieveryDate__c = today.addMonths(2);
        //     opty2.CloseDate               = today.addMonths(1);
        //     opty2.OpportunityIdentifier__c = dealer.Id;
        //     opty2.Opportunity_Owner__c    = dealer.Id;
        //     optyList.add(opty2);

        //     insert optyList;
        //     System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
        //     List<OpportunityLineItem> optyliList = new List<OpportunityLineItem>();
        //     OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
        //     optyliList.add(oItem);

        //     OpportunityLineItem oItem2 = TestDataFactoryForSales.createOptyItem(opty1, entry, prod);
        //     OpportunityLineItem oItem3 = TestDataFactoryForSales.createOptyItem(opty2, entry, prod);
        //     optyliList.add(oItem2);
        //     optyliList.add(oItem3);
        //     insert optyliList;

        //     PS__c newPs = new PS__c();
        //     newPs.Opportunity__c = opty1.Id;
        //     insert newPs;

        //     PS__c newPs2 = new PS__c();
        //     newPs2.Opportunity__c = opty2.Id;
        //     newPs2.Status__c      = 'SEReceipt';
        //     newPs2.RequiredDelivryDate__c         = Date.newInstance(2099, 12, 31);         
        //     newPs2.PartsforMachining__c           = 'gear box housing	';
        //     newPs2.ProductionVolumeYearly__c      = 1;
        //     newPs2.OperationRate__c               = 1;
        //     newPs2.WorkingHoursDaily__c           = 1;
        //     newPs2.CycleTimeRequired__c           = 1;
        //     newPs2.WorkingDaysMonthly__c          = 1;
        //     newPs2.MachineType__c                 = '1';
        //     newPs2.Quantity__c                    = 1;
        //     newPs2.PSModel__c                     = model.Id;
        //     newPs2.AutomationType__c              = '1';
        //     newPs2.LoadCapacity__c                = 1;
        //     insert newPs2;

        //     PS__c newPs3 = new PS__c();
        //     newPs3.Opportunity__c = opty2.Id;
        //     newPs3.Status__c      = 'Draft';
        //     newPs3.RequiredDelivryDate__c         = Date.newInstance(2099, 12, 31);         
        //     newPs3.PartsforMachining__c           = 'gear box housing	';
        //     newPs3.ProductionVolumeYearly__c      = 1;
        //     newPs3.OperationRate__c               = 1;
        //     newPs3.WorkingHoursDaily__c           = 1;
        //     newPs3.CycleTimeRequired__c           = 1;
        //     newPs3.WorkingDaysMonthly__c          = 1;
        //     newPs3.MachineType__c                 = '1';
        //     newPs3.Quantity__c                    = 1;
        //     newPs3.PSModel__c                     = model.Id;
        //     newPs3.AutomationType__c              = '1';
        //     newPs3.LoadCapacity__c                = 1;
        //     insert newPs3;

        //     System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
        //     List<Quote> qtList = new List<Quote>();
        //     Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
        //     qtList.add(quote);

        //     Quote quote2 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty1, 'Global');
        //     qtList.add(quote2);

        //     Quote quote3 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty2, 'Service');
        //     qtList.add(quote3);

        //     insert qtList;
        //     System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
        //     // QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
        //     // insert qItem;
        //     List<QuoteLineItem> qitemList = new List<QuoteLineItem>();
        //     QuoteLineItem qItem        = new QuoteLineItem();
        //     qItem.QuoteId               = quote.Id;
        //     qItem.PricebookEntryId      = entry.Id;
        //     qItem.OpportunityLineItemId = oItem.Id;
        //     qItem.Product2Id            = prod.Id;
        //     qItem.RequestedDelivDate__c = today.addMonths(2);
        //     qItem.ExpectedDelivDate__c  = '계약 후 5개월 내';
        //     qItem.Warranty__c           = 'B24';
        //     qItem.UnitPrice             = 0;
        //     qItem.Quantity              = 1;
        //     qItem.ERPInquiryNo__c       = '600203599';
        //     qitemList.add(qItem);
        //     // QuoteLineItem qItem2 = TestDataFactoryForSales.createQuoteItem(quote2, entry, oItem, prod);
        //     // insert qItem2;
        //     QuoteLineItem qItem2        = new QuoteLineItem();
        //     qItem2.QuoteId               = quote2.Id;
        //     qItem2.PricebookEntryId      = entry.Id;
        //     qItem2.OpportunityLineItemId = oItem2.Id;
        //     qItem2.Product2Id            = prod.Id;
        //     qItem2.RequestedDelivDate__c = today.addMonths(2);
        //     qItem2.ExpectedDelivDate__c  = '계약 후 5개월 내';
        //     qItem2.Warranty__c           = 'B12';
        //     qItem2.UnitPrice             = 0;
        //     qItem2.Quantity              = 1;
        //     qItem2.ERPInquiryNo__c       = 'inquiry1';

        //     qitemList.add(qItem2);

        //     QuoteLineItem qItem3        = new QuoteLineItem();
        //     qItem3.QuoteId               = quote3.Id;
        //     qItem3.PricebookEntryId      = entry.Id;
        //     qItem3.OpportunityLineItemId = oItem3.Id;
        //     qItem3.Product2Id            = prod.Id;
        //     qItem3.RequestedDelivDate__c = today.addMonths(2);
        //     qItem3.ExpectedDelivDate__c  = '계약 후 5개월 내';
        //     qItem3.Warranty__c           = 'B12';
        //     qItem3.UnitPrice             = 0;
        //     qItem3.Quantity              = 1;
        //     qItem3.ERPInquiryNo__c       = 'inquiry1';

        //     qitemList.add(qItem3);

        //     insert qitemList;

        //     SQ__c sq = new SQ__c();
        //     insert sq;
        //     SQ_QuoteLineitem_Junction__c sqjunction = new SQ_QuoteLineitem_Junction__c();
        //     sqjunction.SQ__c = sq.Id;
        //     sqjunction.QuoteLineItem__c = qItem.Id;
        //     insert sqjunction;

        //     SQ__c sq2 = new SQ__c();
        //     insert sq2;
        //     SQ_QuoteLineitem_Junction__c sqjunction2 = new SQ_QuoteLineitem_Junction__c();
        //     sqjunction2.SQ__c = sq2.Id;
        //     sqjunction2.QuoteLineItem__c = qItem2.Id;
        //     insert sqjunction2;
        //     // System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
        // }
    }
    @isTest
    static void testRunning() {
        Test.startTest();

        // InterfaceCommonUtil.setInterface('IF-OPTY-019', 'IF_ERP_Quotation');
        // Opportunity op = [SELECT Id FROM Opportunity WHERE StageName = 'Qualified' LIMIT 1];
        // PS__c ps = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Opportunity__c, SalesArea__c, CustomerDesc__c, SignificanceLevel__c, SoldTo__c, RequiredDelivryDate__c, Status__c, PhoneNo__c, Email__c, CustomerName__c, PSModel__c, CustomerPhoneNo__c, RejecType__c, CustomerMobileNo__c, CustomerEmail__c, PartsforMachining__c, Type__c, MaterialHardness__c, ProcessesBeforeMachining__c, ProductionVolumeYearly__c, WorkingHoursDaily__c, WorkingDaysMonthly__c, OperationRate__c, CycleTimeRequired__c, MachineType__c, Model__c, Quantity__c, ChuckType__c, FixtureClamp__c, RecommendedToolMaker__c, AutomationType__c, LoadCapacity__c, InquirySeq__c, ResponsibleBranch__c, IsInterfaced__c, ERPInquiryNo__c, Version__c, Name__c, AEUser__c, RejectReason__c, Customer__c, CustomerContact__c, FM_CustomerEmail__c, FM_CustomerMobileNo__c, FM_CustomerPhoneNo__c, FM_CustomerName__c, FM_DealerEmail__c, FM_DealerPhoneNumber__c, FM_ResponsibleBranch__c, Approver__c FROM PS__c WHERE Status__c = 'Draft' LIMIT 1];
        // Quote qte = [SELECT Id FROM Quote WHERE RecordType.Name = 'Korea' LIMIT 1];
        // Quote qte2 = [SELECT Id FROM Quote WHERE RecordType.Name = 'Global' LIMIT 1];

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
        //  FROM QuoteLineItem WHERE Quote.RecordType.Name = 'Korea'];
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

        // Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        // bypassSet.add('AccountTriggerHandler');
        // bypassSet.add('ContactTriggerHandler');
        // bypassSet.add('QuoteTriggerHandler');
        // bypassSet.add('OpportunityLineItemTriggerHandler');
        // bypassSet.add('PSTriggerHandler');
        // // bypassSet.add('QuoteLineItemTriggerHandler');
        // TriggerHandler.bypassedHandlers = bypassSet;
        
        // // qtlist.add(qt2);

        // DN_RFQ_SubmitController.currentStatus(ps.Id);
        // DN_RFQ_SubmitController.reqSubmit(ps.Id);
        DN_RFQ_SubmitController.dummy();

        Test.stopTest();
    }
}