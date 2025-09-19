@isTest
public with sharing class DN_HappyCallBatchTest {
    private static final Id caseRT = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Date today = System.today();
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

        Asset as1 = new Asset();
        as1.Name = 'Test Asset1';
        insert as1;

        Asset as2 = new Asset();
        as2.Name = 'Test Asset2';
        insert as2;

        CampaignMaster__c cm = new CampaignMaster__c();
        cm.AutoExtraction__c = true;
        cm.StartDate__c = today.addDays(-2);
        cm.EndDate__c = today.addDays(2);
        cm.IsActive__c = true;
        cm.IsAlarmTalk__c = true;
        cm.Type__c = 'Survey';
        insert cm;
        
        ExtractCondition__c ec = new ExtractCondition__c();
        ec.CampaignMaster__c = cm.Id;
        ec.ExtractionTarget__c = 'Ticket';
        ec.FromDate__c = Date.newInstance(2025, 6, 11);
        ec.ToDate__c = Date.newInstance(2025, 6, 12);
        insert ec;

        ExtractCondition__c ec2 = new ExtractCondition__c();
        ec2.CampaignMaster__c = cm.Id;
        ec2.ExtractionTarget__c = 'Ticket';
        insert ec2;

        ExtractCondition__c ec3 = new ExtractCondition__c();
        ec3.CampaignMaster__c = cm.Id;
        insert ec3;

        ExceptAccount__c ea = new ExceptAccount__c();
        ea.CampaignMaster__c = cm.Id;
        insert ea;

        ExceptEquipment__c ee = new ExceptEquipment__c();
        ee.CampaignMaster__c = cm.Id;
        insert ee;
        CampaignManager__c cmg = new CampaignManager__c();
        cmg.CampaignMaster__c = cm.Id;
        insert cmg;

        AlertManager__c am = new AlertManager__c();
        am.Name = 'CS HappyCall Noti';
        insert am;

        case cs = new case();
        cs.TicketType__c         = 'Technical inquiry';
        cs.InternalTicketType__c = 'Failure receipt';
        cs.RecordTypeId          = caseRT;
        cs.Status                = 'Closed';
        cs.ReceptionDetails__c   = 'test';
        insert cs;

    }

    @isTest
    static void testBatch() {
        Test.startTest();
        System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_HappyCallBatch());
        Database.ExecuteBatch(new DN_HappyCallBatch());
        Test.stopTest();
    }
}