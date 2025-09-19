/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-03
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-03-06   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class RequestToUseCustomerTriggerHandlerTest {

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
    static void testInsert(){
        Test.startTest();

        User dealer = [SELECT Id FROM User WHERE LastName = 'testDealerUser'];

        Set<Id> accId = new Set<Id>();
        Account acc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '0000000' LIMIT 1];
        accId.add(acc.Id);

        System.runAs(dealer){
                
            Account targetAcc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '112233' LIMIT 1];
            SimpleCustomerInfo__c siInfo = [SELECT Id, Account__c FROM SimpleCustomerInfo__c WHERE Account__c =: accId LIMIT 1];
            
            DNS_RequestToUseCustomer__c req = new DNS_RequestToUseCustomer__c();
            req.TargetAccount__c = targetAcc.Id;
            req.RequestReason__c = 'RequestDealer';
            req.ApprovalStage__c = 'Draft';
            req.SimpleCustomerInfo__c = siInfo.Id;
            insert req;

        }

        Test.stopTest();

    }

    @isTest
    static void testApprovalProcessSubmission() {

        Test.startTest();

        DNS_RequestToUseCustomer__c req = [SELECT Id FROM DNS_RequestToUseCustomer__c LIMIT 1];
        
        // 승인 제출 요청 생성
        Approval.ProcessSubmitRequest reqApproval = new Approval.ProcessSubmitRequest();
        reqApproval.setComments('Test approval submission.');
        reqApproval.setObjectId(req.Id);

        Approval.ProcessResult result = Approval.process(reqApproval);

        Test.stopTest();

    }


    @isTest
    static void testUpdate(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Dealer());

        Set<Id> accId = new Set<Id>();
        Account acc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '0000000' LIMIT 1];
        accId.add(acc.Id);
        
        SimpleCustomerInfo__c siInfo = [SELECT Id, Account__c FROM SimpleCustomerInfo__c WHERE Account__c =: accId LIMIT 1];

        DNS_RequestToUseCustomer__c req = [SELECT Id, ApprovalStage__c, SimpleCustomerInfo__c, CreatedBy.Name FROM DNS_RequestToUseCustomer__c WHERE RequestReason__c='Request' LIMIT 1 ];
        req.ApprovalStage__c = 'Approved';
        req.SimpleCustomerInfo__c = siInfo.Id;

        System.debug( 'Created Name 1 :: ' + req.CreatedBy.Name);

        update req;

        Test.stopTest();
    }


    @isTest
    static void testUpdateforManageSharing(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Dealer());
        
        Set<Id> accId = new Set<Id>();
        Account newAcc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '112233' LIMIT 1];
        accId.add(newAcc.Id);
        
        SimpleCustomerInfo__c newSiInfo = [SELECT Id, Account__c FROM SimpleCustomerInfo__c WHERE Account__c =: accId LIMIT 1];

        DNS_RequestToUseCustomer__c req = [SELECT Id, ApprovalStage__c, SimpleCustomerInfo__c, CreatedBy.Name FROM DNS_RequestToUseCustomer__c WHERE RequestReason__c='RequestDealer' LIMIT 1 ];
        req.ApprovalStage__c = 'Approved';
        req.SimpleCustomerInfo__c = newSiInfo.Id;

        System.debug( 'Created Name 2 :: ' + req.CreatedBy.Name);

        update req;

        Test.stopTest();
    }

    @isTest
    static void testSimpleCustomerInfoChangedBranch() {

        DNS_RequestToUseCustomer__c req = [
            SELECT Id, SimpleCustomerInfo__c, TargetAccount__c, ApprovalStage__c 
            FROM DNS_RequestToUseCustomer__c 
            WHERE RequestReason__c = 'Request' 
            LIMIT 1
        ];

        SimpleCustomerInfo__c newSci = new SimpleCustomerInfo__c();
        newSci.Account__c = req.TargetAccount__c;
        insert newSci;

        req.SimpleCustomerInfo__c = newSci.Id;
        req.ApprovalStage__c = 'Draft';
        
        update req;

    }


    private class MockIF_ERP_Dealer implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RECODE":"S","O_REMSG":"Successfully finished !"}'
            );
            return res;
        }
    }

    
}