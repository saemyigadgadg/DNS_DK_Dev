/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-12-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class DN_CampaignExtractConditionControlerTest {
    private static final Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id caseRT = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

    @isTest(SeeAllData=true)
    static void testGetRecordInfo(){
        Survey survey = [SELECT Id FROM Survey LIMIT 1];
        
        CampaignMaster__c cm = new CampaignMaster__c(IsAlarmTalk__c = true, Type__c = 'Survey', Survey__c = survey.Id);
        insert cm;
        Campaign cp = new Campaign(Name = 'campaign');
        insert cp;

        ExtractCondition__c ec = new ExtractCondition__c(Name = 'CM', CampaignMaster__c = cm.Id, Campaign__c = cp.Id, ExtractionTarget__c = 'Ticket', ExtractionCondition__c = 'Ticket Type', 
        TicketType__c = 'Technical inquiry', TicketTypeMiddle__c = 'Failure receipt');
        insert ec;
        ExtractCondition__c ec3 = new ExtractCondition__c(Name = 'CM3', CampaignMaster__c = cm.Id, Campaign__c = cp.Id, ExtractionTarget__c = 'Ticket', ExtractionCondition__c = 'Ticket Type', 
        TicketType__c = 'Internal request', TicketTypeMiddle__c = 'Installation request');
        insert ec3;
        ExtractCondition__c ec2 = new ExtractCondition__c(Name = 'CP', Campaign__c = cp.Id, CampaignMaster__c = cm.Id, ExtractionTarget__c = 'Ticket', ExtractionCondition__c = 'Ticket Closed Date',
        TicketType__c = 'Yesterday', FromDate__c = Date.newInstance(2023, 06, 12), ToDate__c = Date.newInstance(2025, 06, 20));
        insert ec2;

        Account acc = new Account(
            Name                    = 'Test Account',
            RecordTypeId            = prospectCustomerRT,
            BusinessNumber__c       = '545454',
            Representative__c       = 'test',
            Competitor__c           = 'None',
            MainCategory__c         = 'MB',
            SubCategory__c          = 'MB1',
            IsTooling__c            = 'MY',
            Production__c           = 'TEST',
            TypeOfBusiness__c       = 'Manufacturing',
            TypeOfIndustry__c       = '가구,기타 제품 제조',
            Country__c              = 'KR',
            Phone                   = '010-1111-2222',
            Website                 = 'www.test.com',
            Fax                     = '010-1111-2222',
            SearchTerm__c           = 'test',
            SalesOrganization__c    = '1800',
            SalesDistrict__c        = 'A1KR',
            SalesOffice__c          = '114C',
            DistributionChannel__c  = '10',
            Division__c             = '40',
            ShippingPostalCode      = '01402'
        );
        insert acc;

        Asset asset = new Asset(Name = 'ML0006-006231');
        insert asset;

        ExceptAccount__c ea = new ExceptAccount__c(Name = 'ea', CampaignMaster__c = cm.Id, Account__c = acc.Id);
        insert ea;

        ExceptEquipment__c ee = new ExceptEquipment__c(CampaignMaster__c = cm.Id, Equipment__c = asset.Id);
        insert ee;

        CampaignManager__c cmanager = new CampaignManager__c(CampaignMaster__c = cm.Id);

        Case caseObj = new Case(
            RecordTypeId        = caseRT,
            Status              = 'Closed',
            ReceptionDetails__c = 'Test',
            TicketType__c       = 'Internal request',
            InternalTicketType__c = 'Installation request',
            FailureArea__c = 'test'
        );
        insert caseObj;
        
        Date fromDate = Date.newInstance(2025, 01, 01);
        Date toDate = Date.newInstance(2025, 01, 05);
        Map<String, Object> extractionData = new Map<String, Object>{
            'ticketType' => 'ticketType',
            'closedDateType' => 'closedDateType',
            'fromDate' => fromDate,
            'toDate' => toDate,
            'extractCondition' => 'Ticket Type'
        };
        String extractionDataString = JSON.serialize(extractionData);

        Test.startTest();
        DN_CampaignExtractConditionController.getObjectType(cm.Id);
        DN_CampaignExtractConditionController.getExtractInfo('a1C');
        DN_CampaignExtractConditionController.getExtractInfo('701');
        DN_CampaignExtractConditionController.getExtractInfo('a0x');
        DN_CampaignExtractConditionController.getConditionList(ec.Id);
        DN_CampaignExtractConditionController.deleteCondition(ec.Id);
        DN_CampaignExtractConditionController.saveExtractionInfo(ec2.Id, extractionDataString);
        DN_CampaignExtractConditionController.extractCampaign(cm.Id);

        Test.stopTest();
    }
}