/**
 * @description       : ServiceResourcesTriggerHandlerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class ServiceResourcesTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            insert user;
        }

        Country__c country = TestDataFactoryForService.createKRCountry();
        insert country;

        List<OperatingHours> testHours = TestDataFactoryForService.createOperatingHours();
        insert testHours;
        System.runAs(user) {
            List<ServiceTerritory> stList = TestDataFactoryForService.createTerritory();
            stList[0].WCCode__c = '';
            stList[0].AvailableServiceResource__c = 0;
            stList[1].WCCode__c = '1244842';
            stList[1].AvailableServiceResource__c = 0;
            insert stList;

            List<ServiceResource> insertSRList = new List<ServiceResource>();
            ServiceResource sr = TestDataFactoryForService.createResource(stList[1].Id);
            sr.RelatedRecordId = thisUser.Id;
            sr.StaffNumber__c = '6527';
            sr.LastKnownLatitude = 37.557718278300890;
            sr.LastKnownLongitude = 126.974039677136940;
            insertSRList.add(sr);
    
            ServiceResource sr2 = TestDataFactoryForService.createResource(stList[0].Id);
            sr2.RelatedRecordId = user.Id;
            sr2.StaffNumber__c = '6482';
            sr2.LastKnownLatitude = 37.557718278300890;
            sr2.LastKnownLongitude = 126.974039677136940;
            sr2.CurrentStatus__c = 'Work';
            insertSRList.add(sr2);
            insert insertSRList;
        }
    }

    @isTest
    static void testUpdateResource(){

        ServiceResourcesTriggerHandler.CommonWrapper testObject = new ServiceResourcesTriggerHandler.CommonWrapper();
        List<ServiceTerritory> stList = [SELECT Id FROM ServiceTerritory];
        List<User> userList = [SELECT Id FROM User];

        String stId = stList[0].Id;
        ServiceResource resource = [SELECT Id FROM ServiceResource WHERE Service_Territory__c =:stId LIMIT 1];

        resource.Service_Territory__c = stList[1].Id;
        update resource;

    }

    @isTest
    static void testUpdateResource2(){

        ServiceResourcesTriggerHandler.CommonWrapper testObject = new ServiceResourcesTriggerHandler.CommonWrapper();
        List<ServiceTerritory> stList = [SELECT Id FROM ServiceTerritory];
        List<User> userList = [SELECT Id FROM User];

        String stId = stList[0].Id;
        ServiceResource resource = [SELECT Id FROM ServiceResource WHERE Service_Territory__c =:stId LIMIT 1];

        resource.IsActive = false;
        update resource;

    }
}