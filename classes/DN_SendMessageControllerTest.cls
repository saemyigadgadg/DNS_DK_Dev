@isTest
public with sharing class DN_SendMessageControllerTest {
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

        AlertManager__c noti = new AlertManager__c();
        noti.Name = 'Message Received Notification';
        noti.Part__c = 'Service';
        insert noti;

        System.runAs(user1){
            Message__c msg = new Message__c();
            msg.Recipient__c = user2.Id;
            msg.Type__c = '일반';
            msg.Content__c = '쪽지내용';
            insert msg;
        }        
    }

    @isTest
    static void testMessageInfo() {        
        User user1 = [SELECT Id FROM User WHERE Name = '상담사1'];
        User user2 = [SELECT Id FROM User WHERE Name = '상담사2'];
        Test.startTest();
        Date dateTo = System.today();
        Date dateFrom = System.today().addMonths(-1);
        List<DN_SendMessageController.targetList> targetList1 = new List<DN_SendMessageController.targetList>();
        DN_SendMessageController.targetList target1 = new DN_SendMessageController.targetList();
        target1.Id = user2.Id;
        target1.name = '';
        target1.grade = '';
        targetList1.add(target1);
        List<DN_SendMessageController.targetList> targetList2 = new List<DN_SendMessageController.targetList>();
        DN_SendMessageController.targetList target2 = new DN_SendMessageController.targetList();
        target2.Id = user1.Id;
        target2.name = '';
        target2.grade = '';
        targetList2.add(target2);
        System.runAs(user1) {
            DN_SendMessageController.setSendMessage('긴급', '쪽지 test',targetList1);
        }
        System.runAs(user2) {
            DN_SendMessageController.setSendMessage('일반', '쪽지 test', targetList2);
        }

        Message__c msg1 = [SELECT Id FROM Message__c WHERE Recipient__c =: user1.Id LIMIT 1];
        Message__c msg2 = [SELECT Id FROM Message__c WHERE CreatedById =: user1.Id LIMIT 1];
        List<DN_SendMessageController.messageList> msgList1 = new List<DN_SendMessageController.messageList>();
        DN_SendMessageController.messageList message1 = new DN_SendMessageController.messageList();
        message1.Id = msg1.Id;
        msgList1.add(message1);
        List<DN_SendMessageController.messageList> msgList2 = new List<DN_SendMessageController.messageList>();
        DN_SendMessageController.messageList message2 = new DN_SendMessageController.messageList();
        message2.Id = msg2.Id;
        msgList2.add(message2);
        
        System.runAs(user1) {
            DN_SendMessageController.getData('수신', dateTo, dateFrom, '', '');
            DN_SendMessageController.getData('발신', dateTo, dateFrom, '', '');
            
            DN_SendMessageController.deleteMessage('발신', msgList1);
            DN_SendMessageController.deleteMessage('수신', msgList2);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetInfo() {
        Profile pro = [SELECT Id FROM Profile WHERE Profile.Name = 'DNS CS Receptionist' LIMIT 1];
        Test.startTest();
        DN_SendMessageController.setGrade();
        DN_SendMessageController.getGradeUser('', '');
        DN_SendMessageController.getGradeUser(pro.Id, '');
        Test.stopTest();
    }

    @isTest
    static void testGetMessage() {     
        Message__c msg = [SELECT Id FROM Message__c WHERE Content__c = '쪽지내용'];
        Test.startTest();
        DN_SendMessageController.readMessage(msg.Id);
        Test.stopTest();
    }
}