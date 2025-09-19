/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-12-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class DN_CampaignTargetCmpControllerTest {
    // @TestSetup
    // static void makeData(){
    //     Campaign testCampaign = new Campaign(Name = 'Survey Campaign', Type__c = 'Survey');
    //     insert testCampaign;
    // }


    @isTest
    static void testGetObjectType(){        
        Campaign cp = new Campaign(Name = 'Test', Type__c = 'Survey');
        insert cp;
        Test.startTest();
        DN_CampaignTargetCmpController.getObjectType(cp.Id);
        Test.stopTest();
    }

    @isTest(seeAllData = true)
    static void testGetHappyCallResult() {
        Campaign cp = [SELECT Id, CampaignMaster__c FROM Campaign WHERE Type__c = 'Survey' LIMIT 1];
        CampaignMaster__c cm = [SELECT Id, Survey__c FROM CampaignMaster__c WHERE Id = :cp.CampaignMaster__c LIMIT 1];
        Survey sv = [SELECT Id FROM Survey WHERE Id = :cm.Survey__c LIMIT 1];
        Test.startTest();
        DN_CampaignTargetCmpController.getHappyCallResult(cp.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpdateMemo(){        
        CampaignTarget__c ct = new CampaignTarget__c();
        insert ct;
        Test.startTest();
        DN_CampaignTargetCmpController.updateMemo('test', ct.Id);
        Test.stopTest();
    }

    @isTest
    static void testSaveSurveyScore(){        
        CampaignTarget__c ct = new CampaignTarget__c();
        insert ct;
        Test.startTest();
        DN_CampaignTargetCmpController.saveSurveyScore(ct.Id, 10);
        Test.stopTest();
    }
    
    @isTest
    static void testSendAlarmTalk() {
        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;

        CampaignMaster__c cm = new CampaignMaster__c(Name = 'cm', AlertManager__c = alertManager.Id);
        insert cm;
        Campaign cp = new Campaign(Name = 'Test', Type__c = 'Survey', CampaignMaster__c = cm.Id);
        insert cp;
        CampaignTarget__c ct = new CampaignTarget__c(Campaign__c = cp.Id, AlamTalkSend__c = true);
        insert ct;

        DN_CampaignTargetCmpController.CampaignTargetWrapper wrapper = new DN_CampaignTargetCmpController.CampaignTargetWrapper();
        wrapper.TicketId = ct.Id;
        wrapper.PhoneNumber = '01012345678';
        wrapper.AlamTalkSendCount = 0;
    
        List<DN_CampaignTargetCmpController.CampaignTargetWrapper> wrapperList = new List<DN_CampaignTargetCmpController.CampaignTargetWrapper>{ wrapper };

        Test.startTest();
        DN_CampaignTargetCmpController.sendAlarmTalk(wrapperList, cp.Id);
        Test.stopTest();
    }

    @isTest
    static void testReSendAlarmTalk() {
        
        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;
        
        // Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];
        // Test.setMock(HttpCalloutMock.class, Type.forName('DN_CampaignTargetCmpControllerTest.IF_SWEET_TRACKER_HttpMock').newInstance());

        // AlertAlarmTalkTemplate__c alertAlarm = new AlertAlarmTalkTemplate__c();
        // alertAlarm.Name = 'TestAlarm';
        // alertAlarm.AlertManagerID__c = alertManager.Id;
        // alertAlarm.AlarmTalkTemplateCode__c = alarmTem.TemplateCode__c;
        // alertAlarm.Language__c = 'ko';
        // alertAlarm.Name = 'TestAlarm';
        // insert alertAlarm;

        // Interface__c testInterface = new Interface__c();
        // testInterface.Name = 'Sweet_Tracker_SendMessage_Op';
        // testInterface.EndpointURL__c = 'https://alimtalk-api.sweettracker.net/v2';
        // testInterface.HttpMethod__c = 'POST';
        // testInterface.ContentType__c = 'application/json; charset=UTF-8';
        // testInterface.Timeout__c = 120000;
        // testInterface.System__c = 'SWEET TRAKER';
        // testInterface.IsActive__c = true;
        // insert testInterface;

        CampaignMaster__c cm = new CampaignMaster__c(Name = 'cm', AlertManager__c = alertManager.Id);
        insert cm;
        Campaign cp = new Campaign(Name = 'Test', Type__c = 'Survey', CampaignMaster__c = cm.Id);
        insert cp;
        CampaignTarget__c ct = new CampaignTarget__c(Campaign__c = cp.Id);
        insert ct;

        Test.startTest();
        DN_CampaignTargetCmpController.reSendAlarmTalk('test', '01011112222', cp.Id, ct.Id, 'test', 'test', false);
        Test.stopTest();
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

    // @isTest
    // static void testUpdateSurveyResult() {
        
    //     CampaignMaster__c cm = new CampaignMaster__c(Name = 'cm');
    //     insert cm;
    //     Campaign cp = new Campaign(Name = 'Test', Type__c = 'Survey', CampaignMaster__c = cm.Id);
    //     insert cp;
    //     List<CampaignTarget__c> ctList = new List<CampaignTarget__c>();
    //     CampaignTarget__c ct = new CampaignTarget__c(Campaign__c = cp.Id);
    //     ctList.add(ct);
    //     CampaignTarget__c ct2 = new CampaignTarget__c(Campaign__c = cp.Id);
    //     ctList.add(ct2);

    //     Test.startTest();
    //     DN_CampaignTargetCmpController.updateSurveyResult(ctList);
    //     Test.stopTest();
    // }

    @isTest
    static void testGetTargetList() {
        CampaignMaster__c cm = new CampaignMaster__c(Name = 'cm');
        insert cm;
        Campaign cp = new Campaign(Name = 'Test', Type__c = 'Survey', CampaignMaster__c = cm.Id);
        insert cp;
        List<CampaignTarget__c> ctList = new List<CampaignTarget__c>();
        CampaignTarget__c ct = new CampaignTarget__c(Campaign__c = cp.Id, RegisterDate__c = Date.newInstance(2025, 02, 01), ListSequence__c = '10');
        ctList.add(ct);
        CampaignTarget__c ct2 = new CampaignTarget__c(Campaign__c = cp.Id, RegisterDate__c = Date.newInstance(2025, 01, 03), ListSequence__c = '20');
        ctList.add(ct2);
        insert ctList;

        Date startDate = Date.newInstance(2025, 1, 1);
        Date endDate = Date.newInstance(2025, 5, 1);        

        CampaignMaster__c cm2 = new CampaignMaster__c(Name = 'cm2');
        insert cm2;
        Campaign cp2 = new Campaign(Name = 'Test2', Type__c = 'Survey', CampaignMaster__c = cm2.Id, IsMigration__c = true);
        insert cp2;
        List<CampaignTarget__c> ctList2 = new List<CampaignTarget__c>();
        CampaignTarget__c ct3 = new CampaignTarget__c(Campaign__c = cp2.Id, RegisterDate__c = Date.newInstance(2025, 02, 01), ListSequence__c = '10');
        ctList2.add(ct3);
        CampaignTarget__c ct4 = new CampaignTarget__c(Campaign__c = cp2.Id, RegisterDate__c = Date.newInstance(2025, 01, 03), ListSequence__c = '20');
        ctList2.add(ct4);
        insert ctList2;

        List<HappyCallResponse__c> hcrList = new List<HappyCallResponse__c>();
        HappyCallResponse__c hcr = new HappyCallResponse__c(ListSequence__c = '10');
        hcrList.add(hcr);
        HappyCallResponse__c hcr2 = new HappyCallResponse__c(ListSequence__c = '20');
        hcrList.add(hcr2);
        HappyCallResponse__c hcr3 = new HappyCallResponse__c(ListSequence__c = '10');
        hcrList.add(hcr3);
        HappyCallResponse__c hcr4 = new HappyCallResponse__c(ListSequence__c = '20');
        hcrList.add(hcr4);
        insert hcrList;

        CampaignMaster__c cm3 = new CampaignMaster__c(Name = 'cm3');
        insert cm3;
        Campaign cp3 = new Campaign(Name = 'Test3', Type__c = 'General', CampaignMaster__c = cm3.Id);
        insert cp3;
        List<CampaignTarget__c> ctList3 = new List<CampaignTarget__c>();
        CampaignTarget__c ct5 = new CampaignTarget__c(Campaign__c = cp3.Id, RegisterDate__c = Date.newInstance(2025, 02, 01), ListSequence__c = '10');
        ctList3.add(ct5);
        CampaignTarget__c ct6 = new CampaignTarget__c(Campaign__c = cp3.Id, RegisterDate__c = Date.newInstance(2025, 01, 03), ListSequence__c = '20');
        ctList3.add(ct6);
        insert ctList3;

        Test.startTest();
        DN_CampaignTargetCmpController.getTargetList(cp.Id, startDate, endDate);
        DN_CampaignTargetCmpController.getTargetList(cp2.Id, startDate, endDate);
        DN_CampaignTargetCmpController.getTargetList(cp3.Id, startDate, endDate);
        Test.stopTest();
    }

}