@isTest
public with sharing class DN_DNSAPreCallConfirmControllerTest {
    @TestSetup
    static void makeData(){
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '123456';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        insert acc;

        Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        con.MobilePhone = '01011112222';
        insert con;

        Campaign campaign = new Campaign(Name = 'Test Campaign');
        insert campaign;

        CampaignAsset__c ca = new CampaignAsset__c(
            Campaign__c = campaign.Id,
            EmailStatus__c = 'Send'
        );
        insert ca;

        CampaignAsset__c ca2 = new CampaignAsset__c(
            Campaign__c = campaign.Id,
            EmailStatus__c = 'Completed'
        );
        insert ca2;
    }

    @isTest
    static void testBatch() {
        CampaignAsset__c ca = [SELECT Id FROM CampaignAsset__c WHERE EmailStatus__c = 'Send' LIMIT 1];
        CampaignAsset__c ca2 = [SELECT Id FROM CampaignAsset__c WHERE EmailStatus__c = 'Completed' LIMIT 1];
        Campaign cp = [SELECT Id FROM Campaign LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.DN_DNSAPrecallConfirmMail;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('recordID', ca.Id);
        DN_DNSAPreCallConfirmController dnsa = new DN_DNSAPreCallConfirmController();
        dnsa.saveReject();
        dnsa.updateRec();

        PageReference pageRef2 = Page.DN_DNSAPrecallConfirmMail;
        Test.setCurrentPage(pageRef2);
        pageRef2.getParameters().put('recordID', ca2.Id);
        DN_DNSAPreCallConfirmController dnsa2 = new DN_DNSAPreCallConfirmController();
        dnsa2.saveReject();
        dnsa2.updateRec();

        DN_DNSAPreCallConfirmController dnsaNull = new DN_DNSAPreCallConfirmController();
        dnsaNull.recordID = null;
        dnsaNull.saveReject();
        dnsaNull.updateRec();

        Test.stopTest();
    }
}