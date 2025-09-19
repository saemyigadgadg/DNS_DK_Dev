/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
**/
@isTest
private class DN_WithoutSharingClass_TEST {
    @TestSetup
    static void setup() {
        Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();

        TriggerHandler.bypassedHandlers = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'SalesAreaDataTriggerhandler', 'OpportunityTriggerHandler'
        , 'OpportunityLineItemTriggerHandler', 'QuoteTriggerHandler', 'WorkOrderTriggerHandler', 'TicketTriggerHandler', 'QuoteLineItemTriggerHandler'
        , 'SQRegistrationTriggerHandler', 'RequestedSQTriggerHandler', 'SQReviewTriggerhandler', 'SQTriggerHandler', 'OrderTriggerHandler'
        , 'SQQuoteItemsTriggerHandler', 'ServiceAppointmentTriggerHandler' };

        User user = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        User dealer;
        System.runAs(user) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;
        }

        System.runAs(dealer) {

            List<Account> accounts = new List<Account>();
            accounts.add(new Account(
                Name = 'Test Account 1',
                Representative__c = 'Test Rep 1',
                RecordTypeId = prospectCustomerRT,
                SalesOrganization__c = '1800',
                BusinessNumberDuplCheck__c = '1234567890',
                IsBVC__c = 'Y'
            ));
            accounts.add(new Account(
                Name = 'Test Account 2',
                Representative__c = 'Test Rep 2',
                RecordTypeId = tradeCustomerRT,
                SalesOrganization__c = '1800',
                BusinessNumberDuplCheck__c = '0987654321'
            ));
            insert accounts;
    
            Contact contact = new Contact(
                LastName = 'Test Contact',
                Email = 'test.contact@example.com',
                MobilePhone = '1234567890',
                Position__c = 'Manager',
                Role__c = 'Manager',
                AccountId = accounts[0].Id
            );
            insert contact;
    
            Asset asset = new Asset(
                Name = 'Test Asset',
                AccountId = accounts[1].Id
            );
            insert asset;
    
            WorkOrder workOrder = new WorkOrder(
                AccountId = accounts[0].Id,
                Subject = 'Test Work Order'
            );
            insert workOrder;
    
            Case caseRecord = new Case(
                AccountId = accounts[0].Id,
                Subject = 'Test Case'
            );
            insert caseRecord;
    
            WorkOrderResult__c workOrderResult = new WorkOrderResult__c();
            insert workOrderResult;
    
            ServiceAppointment sa = new ServiceAppointment(
                ParentRecordId = workOrder.Id,
                Status = 'Scheduled'
            );
            insert sa;
    
            TestDataFactoryForSales.activatePriceBook();
            Pricebook2 pbk = [SELECT Id FROM PriceBook2 LIMIT 1];
            insert TestDataFactoryForSales.createModel();
            Product2 prd = TestDataFactoryForSales.createProduct();
            insert prd;
            PricebookEntry pre = TestDataFactoryForSales.createPriceBookEntry(prd, 'KRW');
            insert pre;
    
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(accounts[0], dealer, 'General');
                insert opty;
    
                OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, pre, prd);
                insert oItem;
    
                Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
                insert quote;
    
                QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, pre, oItem, prd);
                insert qItem;
    
            Order order = TestDataFactoryForSales.createDNSDomesticOrder(accounts[1], opty, quote, dealer, 'DNS');
            insert order;
    
            // AccountTeamMember atm = new AccountTeamMember(
            //     AccountId = accounts[0].Id,
            //     UserId = user.Id
            // );
            // insert atm;
    
            DNS_RequestToUseCustomer__c req = new DNS_RequestToUseCustomer__c();
            req.RequestReason__c = 'test';
            insert req;
    
            // RequestedSQ__c rsq = new RequestedSQ__c();
            // req.Category__c = '기타';
            // insert rsq;
    
            SQ__c sq = new SQ__c();
            insert sq;
    
            SQ_QuoteLineitem_Junction__c sqlj = new SQ_QuoteLineitem_Junction__c();
            insert sqlj;
    
            PS__c ps = new PS__c(
                Inquiry_Seq2__c = 1
            );
            insert ps;
    
            T_COND_ELMT__c tce = new T_COND_ELMT__c();
            insert tce;
        }
    }

    @isTest
    static void testIsDuplicatedAccount() {
        Account acc = [SELECT Id, Name, Representative__c FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass instance = DN_WithoutSharingClass.getInstance();
        instance.isDuplicatedAccount(acc.Name, acc.Representative__c);
        instance.isDuplicatedAccount('NonExistent', 'NonExistent');
        Test.stopTest();
    }

    @isTest
    static void testIsAccountbyPortal() {
        Test.startTest();
        DN_WithoutSharingClass.isAccountbyPortal('Test Account 1', 'Test Rep 1', '1234567890');
        Test.stopTest();
    }

    @isTest
    static void testGetAccMap() {
        Set<String> accNames = new Set<String>{'Test Account 1'};
        Set<String> repNames = new Set<String>{'Test Rep 1'};
        
        Test.startTest();
        DN_WithoutSharingClass.getAccMap(accNames, repNames);
        Test.stopTest();
    }

    @isTest
    static void testCheckBusinessNumberDuplicate() {
        Test.startTest();
        DN_WithoutSharingClass.checkBusinessNumberDuplicate('1234567890');
        DN_WithoutSharingClass.checkBusinessNumberDuplicate('NonExistent');
        Test.stopTest();
    }

    @isTest
    static void testCheckBusinessNumberDuplicateList() {
        List<String> businessNumbers = new List<String>{'1234567890', '0987654321'};
        
        Test.startTest();
        DN_WithoutSharingClass.checkBusinessNumberDuplicateList(businessNumbers);
        Test.stopTest();
    }

    @isTest
    static void testGetDealerInfo() {
        Set<Id> accIds = new Set<Id>{[SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1].Id};
        
        Test.startTest();
        DN_WithoutSharingClass.getDealerInfo(accIds);
        Test.stopTest();
    }

    @isTest
    static void testSearchDupl() {
        Test.startTest();
        DN_WithoutSharingClass.searchDupl('1234567890');
        DN_WithoutSharingClass.searchDupl('NonExistent');
        Test.stopTest();
    }

    @isTest
    static void testSearchAccount() {
        Test.startTest();
        DN_WithoutSharingClass.searchAccount('%Test Account%');
        Test.stopTest();
    }

    @isTest
    static void testSearchAccShare() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        User user = [SELECT Id FROM User LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.searchAccShare(acc.Id, user);
        Test.stopTest();
    }

    @isTest
    static void testSearchAccOwner() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.searchAccOwner(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void testWithoutUpdateAsset() {
        Asset asset = [SELECT Id, Name FROM Asset WHERE Name = 'Test Asset' LIMIT 1];
        asset.Name = 'Updated Asset';
        
        Test.startTest();
        DN_WithoutSharingClass.withoutUpdateAsset(asset);
        Test.stopTest();
    }

    @isTest
    static void testWithoutSearchWorkOrder() {
        String query = 'SELECT Id, Subject FROM WorkOrder WHERE Subject = \'Test Work Order\'';
        
        Test.startTest();
        DN_WithoutSharingClass.withoutSearchWorkOrder(query);
        Test.stopTest();
    }

    @isTest
    static void testWithoutUpdateCase() {
        Case caseRecord = [SELECT Id, Subject FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        caseRecord.Subject = 'Updated Case';
        
        Test.startTest();
        DN_WithoutSharingClass.withoutUpdateCase(caseRecord);
        Test.stopTest();
    }

    @isTest
    static void testWithoutDeleteWorkOrderResult() {
        WorkOrderResult__c wor = [SELECT Id FROM WorkOrderResult__c LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.withoutDeleteWorkOrderResult(new List<WorkOrderResult__c>{wor});
        Test.stopTest();
    }

    @isTest
    static void testWithoutSearchSeller() {
        String query = 'SELECT Id, CustomerCode__c FROM Account WHERE Name = \'Test Account 1\'';
        
        Test.startTest();
        DN_WithoutSharingClass.withoutSearchSeller(query);
        Test.stopTest();
    }

    @isTest
    static void testDeleteQuoteLineItems() {
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.deleteQuoteLineItems(new List<QuoteLineItem>{qli});
        Test.stopTest();
    }

    @isTest
    static void testDeleteAccessories() {
        Accessory__c acc = new Accessory__c();
        insert acc;
        
        Test.startTest();
        DN_WithoutSharingClass.deleteAccessories(new List<Accessory__c>{acc});
        Test.stopTest();
    }

    @isTest
    static void testDeleteOrders() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.deleteOrders(new List<Order>{order});
        Test.stopTest();
    }

    @isTest
    static void testDeleteSQReview() {
        SQReview__c review = new SQReview__c();
        insert review;
        
        Test.startTest();
        DN_WithoutSharingClass.deleteSQReview(new List<SQReview__c>{review});
        Test.stopTest();
    }

    @isTest
    static void testDeleteSQ() {
        SQ__c sq = [SELECT Id FROM SQ__c LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.deleteSQ(new List<SQ__c>{sq});
        Test.stopTest();
    }

    @isTest
    static void testUpdateQli() {
        QuoteLineItem qli = [SELECT Id, UnitPrice FROM QuoteLineItem LIMIT 1];
        qli.UnitPrice = 200;
        
        Test.startTest();
        DN_WithoutSharingClass.updateQli(new List<QuoteLineItem>{qli});
        Test.stopTest();
    }

    @isTest
    static void testInsertSqlj() {
        SQ_QuoteLineitem_Junction__c sqlj = new SQ_QuoteLineitem_Junction__c();
        
        Test.startTest();
        DN_WithoutSharingClass.insertSqlj(new List<SQ_QuoteLineitem_Junction__c>{sqlj});
        Test.stopTest();
    }

    @isTest
    static void testUpdateSqlj() {
        SQ_QuoteLineitem_Junction__c sqlj = [SELECT Id FROM SQ_QuoteLineitem_Junction__c LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.updateSqlj(new List<SQ_QuoteLineitem_Junction__c>{sqlj});
        Test.stopTest();
    }

    @isTest
    static void testDeleteSqlj() {
        SQ_QuoteLineitem_Junction__c sqlj = [SELECT Id FROM SQ_QuoteLineitem_Junction__c LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.deleteSqlj(new List<SQ_QuoteLineitem_Junction__c>{sqlj});
        Test.stopTest();
    }

    @isTest
    static void testUpdateSQ() {
        SQ__c sq = [SELECT Id FROM SQ__c LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.updateSQ(new List<SQ__c>{sq});
        Test.stopTest();
    }

    @isTest
    static void testGetUserEmail() {
        Test.startTest();
        DN_WithoutSharingClass.getUserEmail(UserInfo.getUserId());
        Test.stopTest();
    }

    @isTest
    static void testGetUserEmails() {
        Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
        
        Test.startTest();
        DN_WithoutSharingClass.getUserEmails(userIds);
        Test.stopTest();
    }

    @isTest
    static void testGetEmployeeEmails() {
        Set<String> empls = new Set<String>{'1231231'};
        
        Test.startTest();
        DN_WithoutSharingClass.getEmployeeEmails(empls);
        Test.stopTest();
    }

    @isTest
    static void testGetProfileUser() {
        Test.startTest();
        DN_WithoutSharingClass.getProfileUser('Standard User');
        Test.stopTest();
    }

    @isTest
    static void testInsertRQU() {
        DNS_RequestToUseCustomer__c req = new DNS_RequestToUseCustomer__c();
        
        Test.startTest();
        DN_WithoutSharingClass.insertRQU(req);
        Test.stopTest();
    }

    @isTest
    static void testInsertRQUException() {
        DNS_RequestToUseCustomer__c req = new DNS_RequestToUseCustomer__c();
        
        Test.startTest();
        DN_WithoutSharingClass.insertRQU(req);
        Test.stopTest();
    }

    @isTest
    static void testGetAccountCustomerCode() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.getAccountCustomerCode(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void testQueryQuoteLineItems() {
        Test.startTest();
        DN_WithoutSharingClass.queryQuoteLineItems('STOCK123');
        Test.stopTest();
    }

    @isTest
    static void testQueryQuoteLineItemsSet() {
        Set<String> stockNumbers = new Set<String>{'STOCK123'};
        
        Test.startTest();
        DN_WithoutSharingClass.queryQuoteLineItemsSet(stockNumbers);
        Test.stopTest();
    }

    @isTest
    static void testQueryQuoteLineItemsQuoteIds() {
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Set<Id> quoteIds = new Set<Id>{quote.Id};
        
        Test.startTest();
        DN_WithoutSharingClass.queryQuoteLineItemsQuoteIds(quoteIds);
        Test.stopTest();
    }

    @isTest
    static void testQueryQuotes() {
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Set<Id> quoteIds = new Set<Id>{quote.Id};
        
        Test.startTest();
        DN_WithoutSharingClass.queryQuotes(quoteIds);
        Test.stopTest();
    }

    @isTest
    static void testUpdateQuotes() {
        Quote quote = [SELECT Id, Waiting_Seq__c FROM Quote LIMIT 1];
        quote.Waiting_Seq__c = '1';
        
        Test.startTest();
        DN_WithoutSharingClass.updateQuotes(new List<Quote>{quote});
        Test.stopTest();
    }

    @isTest
    static void testUpdateQuote() {
        Quote quote = [SELECT Id, Waiting_Seq__c FROM Quote LIMIT 1];
        quote.Waiting_Seq__c = '2';
        
        Test.startTest();
        DN_WithoutSharingClass.updateQuote(quote);
        Test.stopTest();
    }

    @isTest
    static void testUpdateOrderItems() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        OrderItem oi = new OrderItem(
            OrderId = order.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = [SELECT Id FROM PricebookEntry LIMIT 1].Id
        );
        insert oi;
        oi.Quantity = 2;
        
        Test.startTest();
        DN_WithoutSharingClass.updateOrderItems(new List<OrderItem>{oi});
        Test.stopTest();
    }

    @isTest
    static void testUpdateOppty() {
        Opportunity oppty = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        oppty.StageName = 'Closed Won';
        
        Test.startTest();
        DN_WithoutSharingClass.updateOppty(oppty);
        Test.stopTest();
    }

    @isTest
    static void testUpdateAccountHasOrder() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Set<Id> accIds = new Set<Id>{acc.Id};
        
        Test.startTest();
        DN_WithoutSharingClass.updateAccountHasOrder(accIds, 'insert');
        Test.stopTest();
    }

    @isTest
    static void testGetTeamMemberList() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        DN_WithoutSharingClass.getTeamMemberList(acc.Id);
        Test.stopTest();
    }
}