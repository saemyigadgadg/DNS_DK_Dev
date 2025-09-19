/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-04-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class DN_WorkOrderRejectionControllerTest {
    
    @isTest
    static void testCreateAssignReject_Success() {
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        Country__c us = TestDataFactoryForService.createUSCountry();
        insert us;
        
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        
        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;
        
        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        // Account account1 = TestDataFactoryForService.createAccount('DNSA Customer', 'TEST dnsa Company', us);
        // insert account1;

        // Asset asset1 = TestDataFactoryForService.createAsset(account1.Id);
        // insert asset1;

        // Contact contact1 = TestDataFactoryForService.createContact('CSCustomer', account1.Id);
        // insert contact1;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        // Case technicalTicket1 = TestDataFactoryForService.createCase('Ticket_DNSA', account1.Id, asset1.Id, contact1.Id, 'Technical inquiry', 'Failure receipt');
        // insert technicalTicket1;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        wo.Status = 'Assigned';
        insert wo;

        ServiceAppointment appointment = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        insert appointment;

        // WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_DNSA', technicalTicket.Id, '201', territory.Id, resource.Id);
        // insert wo;

        // ServiceAppointment appointment1 = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        // insert appointment;

        AssignReject__c newAssignReject = new AssignReject__c();
        newAssignReject.Work_Order__c = wo.Id;
        newAssignReject.AssignReject__c = '출동불가';
        newAssignReject.Worker__c = wo.Worker__c;
        insert newAssignReject;

        // AssignReject용 AlertManager 생성
        insert new AlertManager__c(Name = 'CS Assignment Rejection Noti');

        // 테스트 실행
        Test.startTest();
            Map<String, Object> result = DN_WorkOrderRejectionController.createAssignReject(wo.Id, '출동불가');

            // WorkOrder 상태 확인
            WorkOrder updatedWO = [SELECT Status FROM WorkOrder WHERE Id = :wo.Id];
        Test.stopTest();
    }

    @isTest
    static void testCreateAssignReject_InvalidStatus() {
        // 기본 데이터
        String testProfile = UserInfo.getProfileId();

        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        WorkOrder wo = new WorkOrder(Subject = 'Invalid Status', Status = 'Closed', OwnerId = user1.Id);
        insert wo;

        Test.startTest();
            Map<String, Object> result = DN_WorkOrderRejectionController.createAssignReject(wo.Id, 'Invalid');
        Test.stopTest();
    }

    // 유틸리티 - 테스트 유저 생성
    // private class TestUtils {
    //     static User createTestUser(String email, Id profileId) {
    //         return (User)Test.loadData(User.sObjectType, new List<SObject>{
    //             new User(
    //                 Username = email,
    //                 Email = email,
    //                 LastName = 'Tester',
    //                 Alias = 'tst',
    //                 TimeZoneSidKey = 'Asia/Seoul',
    //                 LocaleSidKey = 'ko_KR',
    //                 EmailEncodingKey = 'UTF-8',
    //                 LanguageLocaleKey = 'ko',
    //                 ProfileId = profileId
    //             )
    //         })[0];
    //     }
    // }
}