/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
**/
@isTest
public with sharing class InsertCdaQueueable_TEST {
    @TestSetup
    static void makeData(){

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'UserTriggerHandler', 'RequestToUseCustomerTriggerHandler', 'SimpleCustomerInforTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '0000000';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'TradeAcc';
        insert acc;

        Account anotherAcc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        anotherAcc.CustomerCode__c   = '0000011';
        insert anotherAcc;

        Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        insert con;

        Account dealerAcc;
        Contact dealerCon;
        User dealer;

        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert dealerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            dealer.LastName = 'testDealerUser';
            insert dealer;

            SimpleCustomerInfo__c siInfo = new SimpleCustomerInfo__c();
            siInfo.Account__c = acc.Id;
            insert siInfo;

            DNS_RequestToUseCustomer__c req = new DNS_RequestToUseCustomer__c();
            req.TargetAccount__c = acc.Id;
            req.RequestReason__c = 'Request';
            req.ApprovalStage__c = 'Draft';
            req.SimpleCustomerInfo__c = siInfo.Id;
            insert req;
        }

        System.runAs(dealer){
            Account newAcc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            newAcc.CustomerCode__c = '112233';
            insert newAcc;

            SimpleCustomerInfo__c newSiInfo = new SimpleCustomerInfo__c();
            newSiInfo.Account__c = newAcc.Id;
            insert newSiInfo;

            DNS_RequestToUseCustomer__c req = new DNS_RequestToUseCustomer__c();
            req.TargetAccount__c = newAcc.Id;
            req.RequestReason__c = 'RequestDealer';
            req.ApprovalStage__c = 'Draft';
            req.SimpleCustomerInfo__c = newSiInfo.Id;
            insert req;
        }

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-DEALER-008', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Dealer', ifc.Id);
        insert ifClass;
    }

    @isTest
    static void testSuccessRunning() {
        InterfaceCommonUtil.setInterface('IF-DEALER-008', 'IF_ERP_Dealer');
        Account acc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '0000000' LIMIT 1];
        User u = [SELECT Id, AccountId, SalesOrganization__c, DistributionChannel__c, Division__c FROM User WHERE LastName = 'testDealerUser' LIMIT 1];

        List<DNS_CustomerDealerAssociation__c> insertCdaList = new List<DNS_CustomerDealerAssociation__c>();
        DNS_CustomerDealerAssociation__c cda = new DNS_CustomerDealerAssociation__c();
        cda.Dealer__c   = u.AccountId;
        cda.Customer__c = acc.Id;
        insertCdaList.add(cda);

        Test.startTest();
        System.enqueueJob(new InsertCdaQueueable(insertCdaList, u));
        Test.stopTest();
    }

    @isTest
    static void testFailRunning() {
        Account acc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '0000000' LIMIT 1];
        User u = [SELECT Id, AccountId, SalesOrganization__c, DistributionChannel__c, Division__c FROM User WHERE LastName = 'testDealerUser' LIMIT 1];

        List<DNS_CustomerDealerAssociation__c> insertCdaList = new List<DNS_CustomerDealerAssociation__c>();
        DNS_CustomerDealerAssociation__c cda = new DNS_CustomerDealerAssociation__c();
        cda.Dealer__c   = u.AccountId;
        cda.Customer__c = acc.Id;
        insertCdaList.add(cda);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Dealer());
        System.enqueueJob(new InsertCdaQueueable(insertCdaList, u));
        Test.stopTest();
    }

    private class MockIF_ERP_Dealer implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RECODE":"E","O_REMSG":"Successfully finished !"}'
            );
            return res;
        }
    }
}