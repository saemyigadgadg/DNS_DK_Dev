/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-04-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class DN_ResourceAbsenceControllerTest {

    static User user1;
    static ServiceResource sr;
    static WorkOrder wo;
    static ServiceAppointment sa;

    // 초기 테스트 데이터 설정
    static void setupTestData() {
        // Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        // testUser = new User(
        //     Alias = 'tuser',
        //     Email = 'testuser@example.com',
        //     EmailEncodingKey = 'UTF-8',
        //     LanguageLocaleKey = 'en_US',
        //     LocaleSidKey = 'en_US',
        //     ProfileId = p.Id,
        //     TimeZoneSidKey = 'Asia/Seoul',
        //     UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
        // );
        // insert testUser;
        String testProfile = UserInfo.getProfileId();

        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        sr = new ServiceResource(
            Name = 'Test SR',
            RelatedRecordId = user1.Id,
            CurrentStatus__c = 'Work'
        );
        insert sr;

        wo = new WorkOrder(
            // Subject = 'Test Work Order',
            Status = 'Assigned'
            // OrderType__c = '201'
        );
        insert wo;

        sa = new ServiceAppointment(
            ParentRecordId = wo.Id,
            Status = 'Assigned'
            // AppointmentNumber = 'SA-' + String.valueOf(DateTime.now().getTime())
        );
        insert sa;
    }

    @isTest
    static void testUpdateSRStatus() {
        setupTestData();

            Test.startTest();
            DN_ResourceAbsenceController.updateSRStatus(wo.Id, 'Wait');
            Test.stopTest();
        

        ServiceResource updatedSR = [SELECT CurrentStatus__c FROM ServiceResource WHERE Id = :sr.Id];
    }

    @isTest
    static void testUpdateSRStatus_noServiceResource() {
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

            Test.startTest();
            try {
                DN_ResourceAbsenceController.updateSRStatus(null, 'Wait');
            } catch (AuraHandledException e) {
            }
            Test.stopTest();
    }

    @isTest
    static void testChangeStatus() {
        setupTestData();

        Test.startTest();
        String result = DN_ResourceAbsenceController.changeStatus(wo.Id);
        Test.stopTest();

        WorkOrder updatedWO = [SELECT Status FROM WorkOrder WHERE Id = :wo.Id];

        ServiceAppointment updatedSA = [SELECT Status FROM ServiceAppointment WHERE Id = :sa.Id];
    }

    @isTest
    static void testGetSRStatus() {
        setupTestData();

            Test.startTest();
            String status = DN_ResourceAbsenceController.getSRStatus(wo.Id);
            Test.stopTest();
        }
    
}