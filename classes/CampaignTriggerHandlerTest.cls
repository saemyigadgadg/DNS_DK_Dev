@isTest
public with sharing class CampaignTriggerHandlerTest {
    private static final Id CampaignRT = SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campaign').getRecordTypeId();
    private static final Id dnsaCampaignRT = SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('DNSAPreCall').getRecordTypeId();

    @isTest
    static void testBeforeInsertHandler() {
        Test.startTest();

        // Mock Campaign with fake RecordTypeId
        Campaign newCP = new Campaign(
            Name = 'BeforeInsertCampaign',
            RecordTypeId = CampaignRT, // Dummy ID
            Pre__c = 'Pre-call',
            Status = 'Planned',
            StartDate = System.today()
        );

        insert newCP;
        Test.stopTest();
    }

    @isTest
    static void testAfterInsertHandler() {
        Campaign cp = new Campaign(
            Name = 'AfterInsertCampaign',
            RecordTypeId = CampaignRT, // Dummy ID
            Pre__c = 'Missing Part',
            Status = 'Planned',
            StartDate = System.today()
        );

        insert cp;
    }

    @isTest
    static void testBeforeUpdateHandler() {
        Campaign cp = new Campaign(
            Name = 'BeforeUpdateCampaign',
            Pre__c = 'Pre-call',
            Status = 'Planned',
            StartDate = System.today(),
            RecordTypeId = dnsaCampaignRT
        );
        insert cp;

        cp.Pre__c = 'Missing Part';

        Test.startTest();
        update cp;
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdateHandler() {
        Campaign cp = new Campaign(
            Name = 'AfterUpdateCampaign',
            CampaignType__c = 'ServiceCampaign',
            Status = 'Planned',
            StartDate = System.today()
        );
        insert cp;

        cp.CampaignType__c = 'RegularInspections';

        Test.startTest();
        update cp;
        Test.stopTest();
    }
}