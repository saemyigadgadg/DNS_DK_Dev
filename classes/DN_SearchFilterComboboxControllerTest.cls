/**
 * @description       : DN_SearchFilterComboboxControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-31
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_SearchFilterComboboxControllerTest {
    @TestSetup
    static void makeData(){
        List<OperatingHours> hoursList = TestDataFactoryForService.createOperatingHours();
        insert hoursList;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);
        insert resource;
        
    }

    @isTest
    static void testDummny(){        
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource worker = [SELECT Id, Name FROM ServiceResource WHERE Service_Territory__c = :territory.Id];

        Test.startTest();
        DN_SearchFilterComboboxController.getServiceResourceList(territory.Id, worker.Id);
        DN_SearchFilterComboboxController.getServiceResourceList(territory.Id, '');
        DN_SearchFilterComboboxController.getServiceResourceList('', worker.Id);
        DN_SearchFilterComboboxController.getServiceResourceList('', '');
        DN_SearchFilterComboboxController.getServiceResourceList('TEST', 'TEST');
        DN_SearchFilterComboboxController.getWorkcenterId(worker.Id);
        DN_SearchFilterComboboxController.getSearchWorker('TEST', territory.Id);
        DN_SearchFilterComboboxController.getSearchWorker('TEST','TEST');
        Test.stopTest();
    }
}