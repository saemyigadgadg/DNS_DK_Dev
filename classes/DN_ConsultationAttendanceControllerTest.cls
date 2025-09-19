@isTest
public with sharing class DN_ConsultationAttendanceControllerTest {
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'DNS CS Receptionist'];
        UserRole role = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName ='CSGeneralM'];
        //국내 접수 상담사 프로필로 유저2개
        User user1 = new User();
        User user2 = new User();

        System.runAs(thisUser) {
            user1.Username          = 'test001@gmail.com' + System.currentTimeMillis();
            user1.LastName          = '상담사1';
            user1.CompanyName       = 'DN Solutions';
            user1.Email             = 'test001@gmail.com';
            user1.Alias             = '상담사1';
            user1.IsActive          = true;
            user1.TimeZoneSidKey    = 'Asia/Seoul';
            user1.LocaleSidKey      = 'ko';
            user1.LanguageLocaleKey = 'ko';
            user1.EmailEncodingKey  = 'UTF-8';
            user1.ProfileId         = profile.Id;
            user1.UserRoleId        = role.Id;
            insert user1;

            user2.Username          = 'test002@gmail.com' + System.currentTimeMillis();
            user2.LastName          = '상담사2';
            user2.CompanyName       = 'DN Solutions';
            user2.Email             = 'test002@gmail.com';
            user2.Alias             = '상담사2';
            user2.IsActive          = true;
            user2.TimeZoneSidKey    = 'Asia/Seoul';
            user2.LocaleSidKey      = 'ko';
            user2.LanguageLocaleKey = 'ko';
            user2.EmailEncodingKey  = 'UTF-8';
            user2.ProfileId         = profile.Id;
            user2.UserRoleId        = role.Id;
            insert user2;
        }

        ConsultationAttendance__c ca1 = new ConsultationAttendance__c();
        ca1.AttendanceDate__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        ca1.Consultant__c = user1.Id;
        insert ca1;

        ConsultationAttendance__c ca2 = new ConsultationAttendance__c();
        ca2.AttendanceDate__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        ca2.Consultant__c = user2.Id;
        insert ca2;
    }

    @isTest
    static void testSetData() {
        List<ConsultationAttendance__c> dataList = [SELECT Id FROM ConsultationAttendance__c LIMIT 1];
        Test.startTest();
        DN_ConsultationAttendanceController.setData('RESET', dataList, '', '', '');
        DN_ConsultationAttendanceController.setData('SAVE', dataList,'휴가종일', '0800', '1700');
        Test.stopTest();
    }
        
    @isTest
    static void testGetData() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'DNS CS Receptionist'];
        DN_ConsultationAttendanceController.ConsultationAttendanceWrapper wrapper = new DN_ConsultationAttendanceController.ConsultationAttendanceWrapper();
        Test.startTest();
        Date dateTo = System.today();
        Date dateFrom = System.today().addMonths(-1);
        DN_ConsultationAttendanceController.setInquiryType();
        DN_ConsultationAttendanceController.getData(dateTo, dateFrom, profile.Id, '', '상담사');
        Test.stopTest();
    }
}