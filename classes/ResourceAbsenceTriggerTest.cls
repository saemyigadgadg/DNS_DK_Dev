/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-04-08
 * @last modified by  : suheon.ha@sobetec.com
**/
@isTest
public with sharing class ResourceAbsenceTriggerTest {
    public ResourceAbsenceTriggerTest() {}

    @TestSetup
    static void makeData(){
        // User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        List<OperatingHours> testHours = TestDataFactoryForService.createOperatingHours();
        insert testHours;

        List<ServiceTerritory> stList = TestDataFactoryForService.createTerritory();
        stList[0].WCCode__c = '';
        stList[0].AvailableServiceResource__c = 0;
        stList[1].WCCode__c = '1244842';
        stList[1].AvailableServiceResource__c = 0;
        insert stList;


        // User testUser = [SELECT Id FROM User WHERE LastName = 'testuser' LIMIT 1];
        // insert testUser;

        List<ServiceResource> insertSRList = new List<ServiceResource>();
        ServiceResource sr = TestDataFactoryForService.createResource(stList[1].Id);
        sr.RelatedRecordId = UserInfo.getUserId();
        sr.StaffNumber__c = '6527';
        sr.LastKnownLatitude = 37.557718278300890;
        sr.LastKnownLongitude = 126.974039677136940;
        insertSRList.add(sr);

        insert insertSRList;
    }

    @isTest
    static void testResourceAbsenceTrigger() {
        // CollaborationGroup group1 = [SELECT Id FROM CollaborationGroup LIMIT 1];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE StaffNumber__c = '6527' LIMIT 1];

        Test.startTest();
        ResourceAbsence ra = new ResourceAbsence(
            ResourceId = sr.Id,
            Type = 'Leave',
            Description = 'Test',
            Start = Datetime.now(),
            End = Datetime.now().addHours(1)
        );
        insert ra;
        Test.stopTest();

    }
}