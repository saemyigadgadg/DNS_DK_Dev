@isTest
public with sharing class CS_UtilTest {
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
        ca1.AttendanceType__c = 'Holiday(AM)';
        ca1.OffStartTime__c = '0800';
        ca1.OffEndTime__c = '1200';
        
           
        insert ca1;

        ConsultationAttendance__c ca2 = new ConsultationAttendance__c();
        ca2.AttendanceDate__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        ca2.Consultant__c = user2.Id;
        insert ca2;
        
        List<AssignmentRule__c> arList = new List<AssignmentRule__c>();
        AssignmentRule__c ar1 = new AssignmentRule__c();
        ar1.Name = '일반상담사 순차배정';
        ar1.AssignmentType__c = 'Owner';
        arList.add(ar1);
        AssignmentRule__c ar2 = new AssignmentRule__c();
        ar2.Name = '설치담당자';
        ar2.AssignmentType__c = 'Team Member';
        arList.add(ar2);
        AssignmentRule__c ar3 = new AssignmentRule__c();
        ar3.Name = '기술상담사 순차배정';
        ar3.AssignmentType__c = 'Owner';
        arList.add(ar3);
        AssignmentRule__c ar4 = new AssignmentRule__c();
        ar4.Name = '프로그램상담사 순차배정';
        ar4.AssignmentType__c = 'Owner';
        arList.add(ar4);
        AssignmentRule__c ar5 = new AssignmentRule__c();
        ar5.Name = 'VOC_홈페이지접수';
        ar5.AssignmentType__c = 'Team Member';
        arList.add(ar5);
        AssignmentRule__c ar6 = new AssignmentRule__c();
        ar6.Name = 'TEST';
        ar6.AssignmentType__c = 'Team Member';
        arList.add(ar6);
        AssignmentRule__c ar7 = new AssignmentRule__c();
        ar7.Name = 'TEST';
        ar7.AssignmentType__c = 'Owner';
        arList.add(ar7);
        insert arList;

        List<AssignmentMember__c> amList = new List<AssignmentMember__c>();
        AssignmentMember__c am2 = new AssignmentMember__c();
        am2.User__c = User1.Id;
        am2.AssignmentRule__c = ar3.Id;
        am2.CurrentAssignment__c = True;
        amList.add(am2);
        AssignmentMember__c am3 = new AssignmentMember__c();
        am3.User__c = User2.Id;
        am3.AssignmentRule__c = ar3.Id;
        am3.CurrentAssignment__c = True;
        amList.add(am3);
        AssignmentMember__c am4 = new AssignmentMember__c();
        am4.User__c = User1.Id;
        am4.AssignmentRule__c = ar4.Id;
        am4.CurrentAssignment__c = false;
        amList.add(am4);
        AssignmentMember__c am5 = new AssignmentMember__c();
        am5.User__c = User1.Id;
        am5.AssignmentRule__c = ar4.Id;
        am5.CurrentAssignment__c = false;
        amList.add(am5);
        AssignmentMember__c am6 = new AssignmentMember__c();
        am6.User__c = User1.Id;
        am6.AssignmentRule__c = ar5.Id;
        am6.CurrentAssignment__c = false;
        amList.add(am6);
        insert amList;
    }
    
    @isTest
    static void getAssignmentUserTEST(){
        CS_Util.AssignmentRequest req   = new CS_Util.AssignmentRequest();
        req.aID  		  				= [SELECT Id FROM AssignmentRule__c WHERE Name = '기술상담사 순차배정'].Id;
        req.size						= 1;

        CS_Util.AssignmentRequest req2   = new CS_Util.AssignmentRequest();
        req2.aID  		  				= [SELECT Id FROM AssignmentRule__c WHERE Name = 'TEST' AND AssignmentType__c = 'Owner'].Id;
        CS_Util.AssignmentRequest req3   = new CS_Util.AssignmentRequest();
        req3.aID  		  				= [SELECT Id FROM AssignmentRule__c WHERE Name = 'TEST' AND AssignmentType__c = 'Team Member'].Id;
        CS_Util.AssignmentRequest req4   = new CS_Util.AssignmentRequest();
        
        CS_Util.getAssignmentUser(req);
        CS_Util.getAssignmentUser(req2);
        CS_Util.getAssignmentUser(req3);
        CS_Util.getAssignmentUser(req4);
    }
}