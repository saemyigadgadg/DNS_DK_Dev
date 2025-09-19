/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-24   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class UTIL_Alert_TEST {
    public UTIL_Alert_TEST() {}

    @TestSetup
    static void makeData(){

        EmailTemplate eTem = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];
        CustomNotificationType noti = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];
        
        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;

        AlertEmailTemplate__c alertEmail = new AlertEmailTemplate__c();
        alertEmail.Name = 'TestEmail';
        alertEmail.AlertManagerID__c = alertManager.Id;
        alertEmail.EmailTemplateName__c = eTem.DeveloperName;
        alertEmail.Language__c = 'ko';
        insert alertEmail;

        AlertNotificationTemplate__c alertNoti = new AlertNotificationTemplate__c();
        alertNoti.Name = 'TestNoti';
        alertNoti.AlertManagerID__c = alertManager.Id;
        alertNoti.Body__c = 'Test Notification {0}';
        alertNoti.IsDynamic__c = true;
        alertNoti.Language__c = 'ko';
        alertNoti.Title__c = 'Test Notification';
        alertNoti.CustomNotificationName__c = noti.DeveloperName;
        insert alertNoti;

        AlertAlarmTalkTemplate__c alertAlarm = new AlertAlarmTalkTemplate__c();
        alertAlarm.Name = 'TestAlarm';
        alertAlarm.AlertManagerID__c = alertManager.Id;
        alertAlarm.AlarmTalkTemplateCode__c = alarmTem.TemplateCode__c;
        alertAlarm.Language__c = 'ko';
        alertAlarm.Name = 'TestAlarm';
        insert alertAlarm;

        String contentTitle = 'test';
        String myString = 'StringToBlob';
        Blob pdfContent = Blob.valueof(myString);

        ContentVersion testFile = new ContentVersion();
        testFile.Title = contentTitle;
        testFile.PathOnClient = contentTitle + '.pdf';
        testFile.VersionData = pdfContent;
        testFile.origin = 'H';
        
        insert testFile;

        Interface__c testInterface = new Interface__c();
        testInterface.Name = 'Sweet_Tracker_SendMessage_Op';
        testInterface.EndpointURL__c = 'https://alimtalk-api.sweettracker.net/v2';
        testInterface.HttpMethod__c = 'POST';
        testInterface.ContentType__c = 'application/json; charset=UTF-8';
        testInterface.Timeout__c = 120000;
        testInterface.System__c = 'SWEET TRAKER';
        testInterface.IsActive__c = true;
        insert testInterface;

        InterfaceClasses__c testInterface2 = new InterfaceClasses__c();
        testInterface2.Name = 'IF_SWEET_TRACKER';
        insert testInterface2;

        Attachment attach = new Attachment();
        attach.ParentId = alertManager.Id;
        attach.Name = 'SampleFile.txt';
        attach.Body = Blob.valueOf('This is the file content');
        attach.ContentType = 'text/plain';
        insert attach;


    }

    public class IF_SWEET_TRACKER_HttpMock implements HttpCalloutMock {
        public IF_SWEET_TRACKER_HttpMock() {}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse(); 
            
            String resBody = '[{"result":"Y","code":"K000","kind":"K","msgid":"20250404_134650_44","originCode":null,"error":"","sendtime":"2025-04-04 13:46:50","originError":null}]';
            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @isTest
    static void runAlertEventTest() {
        Test.setMock(HttpCalloutMock.class, Type.forName('UTIL_Alert_TEST.IF_SWEET_TRACKER_HttpMock').newInstance());
        // InterfaceCommonUtil.setInterface('SWEET_TRACKER', 'IF_SWEET_TRACKER');

        AlertManager__c manager = [SELECT Id FROM AlertManager__c LIMIT 1];

        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();
        Id userId = UserInfo.getUserId();

        ContentVersion testFile = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Attachment testFile2 = [SELECT Id FROM Attachment LIMIT 1];

        // Email
        UTIL_Alert.HistoryWrapper wrapper1 = new UTIL_Alert.HistoryWrapper();
        wrapper1.alertID = manager.Id;
        wrapper1.targetID = manager.Id;
        wrapper1.alertType = 'Email';
        wrapper1.alertLanguage = 'ko';
        wrapper1.title = 'Test Title';
        wrapper1.elementList = new List<String> {'Test'};
        wrapper1.receiverforEmail = new List<String>{'dnrjsk123@naver.com'};
        wrapper1.receiverforEmailCC = new List<String>{'yeongdeok.s@dncompany.com'};
        wrapper1.attachmentIDS = new Set<Id>{testFile.ContentDocumentId, testFile2.Id};
        wrapperList.add(wrapper1);

        // Notification
        UTIL_Alert.HistoryWrapper wrapper2 = new UTIL_Alert.HistoryWrapper();
        wrapper2.alertID = manager.Id;
        wrapper2.targetID = manager.Id;
        wrapper2.alertType = 'Notification';
        wrapper2.alertLanguage = 'ko';
        wrapper2.title = 'Test Title';
        wrapper2.elementList = new List<String> {'Test'};
        wrapper2.receiverforID = new Set<Id>{userId};
        wrapperList.add(wrapper2);

        // Alarmtalk
        Map<String, String> elementMap = new Map<String, String>();
        elementMap.put('url', 'naver.com');
        UTIL_Alert.HistoryWrapper wrapper3 = new UTIL_Alert.HistoryWrapper();
        wrapper3.alertID = manager.Id;
        wrapper3.targetID = manager.Id;
        wrapper3.alertType = 'AlarmTalk';
        wrapper3.alertLanguage = 'ko';
        wrapper3.elementMap = elementMap;
        wrapper3.receiverforPhone = new Set<String>{'01071913896'};
        wrapperList.add(wrapper3);

        UTIL_Alert.runAlertEvent(wrapperList);
        Test.startTest();
        Test.getEventBus().deliver();
        Test.stopTest();
    }

    @isTest
    static void runAlertEventFailTest() {

        AlertManager__c manager = [SELECT Id FROM AlertManager__c LIMIT 1];

        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();
        Id userId = UserInfo.getUserId();

        // Email
        UTIL_Alert.HistoryWrapper wrapper1 = new UTIL_Alert.HistoryWrapper();
        // wrapper1.alertID = manager.Id;
        wrapper1.targetID = manager.Id;
        wrapper1.alertType = 'Email';
        wrapper1.alertLanguage = 'ko';
        wrapper1.title = 'Test Title';
        wrapper1.elementList = new List<String> {'Test'};
        wrapper1.receiverforEmail = new List<String>{'dnrjsk123@naver.com'};
        wrapper1.receiverforEmailCC = new List<String>{'yeongdeok.s@dncompany.com'};
        wrapperList.add(wrapper1);

        // Notification
        UTIL_Alert.HistoryWrapper wrapper2 = new UTIL_Alert.HistoryWrapper();
        // wrapper2.alertID = manager.Id;
        wrapper2.targetID = manager.Id;
        wrapper2.alertType = 'Notification';
        wrapper2.alertLanguage = 'ko';
        wrapper2.title = 'Test Title';
        wrapper2.elementList = new List<String> {'Test'};
        wrapper2.receiverforID = new Set<Id>{userId};
        wrapperList.add(wrapper2);

        // Alarmtalk
        Map<String, String> elementMap = new Map<String, String>();
        elementMap.put('url', 'naver.com');
        UTIL_Alert.HistoryWrapper wrapper3 = new UTIL_Alert.HistoryWrapper();
        // wrapper3.alertID = manager.Id;
        wrapper3.targetID = manager.Id;
        wrapper3.alertType = 'AlarmTalk';
        wrapper3.alertLanguage = 'ko';
        wrapper3.elementMap = elementMap;
        wrapper3.receiverforPhone = new Set<String>{'01071913896'};
        wrapperList.add(wrapper3);

        UTIL_Alert.runAlertEvent(wrapperList);
    }

    @isTest
    static void runAlertEventEmailTemplateFailTest() {

        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager2';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;


        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();

        // Email
        UTIL_Alert.HistoryWrapper wrapper1 = new UTIL_Alert.HistoryWrapper();
        wrapper1.alertID = alertManager.Id;
        wrapper1.targetID = alertManager.Id;
        wrapper1.alertType = 'Email';
        wrapper1.alertLanguage = 'ko';
        wrapper1.title = 'Test Title';
        wrapper1.elementList = new List<String> {'Test'};
        wrapper1.receiverforEmail = new List<String>{'dnrjsk123@naver.com'};
        wrapper1.receiverforEmailCC = new List<String>{'yeongdeok.s@dncompany.com'};
        wrapperList.add(wrapper1);

        UTIL_Alert.runAlertEvent(wrapperList);
    }

    @isTest
    static void runAlertEventNotiTemplateFailTest() {
        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager2';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;

        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();
        Id userId = UserInfo.getUserId();

        // Notification
        UTIL_Alert.HistoryWrapper wrapper2 = new UTIL_Alert.HistoryWrapper();
        wrapper2.alertID = alertManager.Id;
        wrapper2.targetID = alertManager.Id;
        wrapper2.alertType = 'Notification';
        wrapper2.alertLanguage = 'ko';
        wrapper2.title = 'Test Title';
        wrapper2.elementList = new List<String> {'Test'};
        wrapper2.receiverforID = new Set<Id>{userId};
        wrapperList.add(wrapper2);

        UTIL_Alert.runAlertEvent(wrapperList);

    }

    @isTest
    static void runAlertEventAlarmtalkTemplateFailTest() {
        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager2';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;

        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();

        // Alarmtalk
        Map<String, String> elementMap = new Map<String, String>();
        elementMap.put('url', 'naver.com');
        UTIL_Alert.HistoryWrapper wrapper3 = new UTIL_Alert.HistoryWrapper();
        wrapper3.alertID = alertManager.Id;
        wrapper3.targetID = alertManager.Id;
        wrapper3.alertType = 'AlarmTalk';
        wrapper3.alertLanguage = 'ko';
        wrapper3.elementMap = elementMap;
        wrapper3.receiverforPhone = new Set<String>{'01071913896'};
        wrapperList.add(wrapper3);

        UTIL_Alert.runAlertEvent(wrapperList);

    }

    // @isTest
    // static void testCoverage() {
    //     UTIL_Alert.testCoverage();
    // }    
}