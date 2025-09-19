/**
 * @description       : DN_SearchAccountControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_SearchAccountControllerTest {
    @TestSetup
    static void makeData(){
        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        Country__c us = TestDataFactoryForService.createUSCountry();
        insert us;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        Account account2 = TestDataFactoryForService.createAccount('TradeCustomer', 'Company Without Asset', korea);
        account2.BusinessNumber__c = 'TEST Business Number';
        List<Account> accList = new List<Account>();
        accList.add(account);
        accList.add(account2);
        insert accList;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        Contact contact2 = TestDataFactoryForService.createContact('CSCustomer', account2.Id);
        Contact contact3 = TestDataFactoryForService.createContact('CSCustomer', null);
        List<Contact> conList = new List<Contact>();
        conList.add(contact);
        conList.add(contact2);
        conList.add(contact3);
        insert conList;

        Task task1 = TestDataFactoryForService.createCallCenterTask(null, contact.Id, '서비스콜센터');
        Task task2 = TestDataFactoryForService.createCallCenterTask(null, contact.Id, '고객의소리');
        List<Task> taskList = new List<Task>();
        taskList.add(task1);
        taskList.add(task2);
        insert taskList;

        Case generalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'General inquiry', 'Other inquiry');
        insert generalTicket;

    }

    @isTest
    static void testGetAssetInfo(){        
        Account acc = [SELECT Id FROM Account WHERE Name = 'TEST Company'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'Company Without Asset'];

        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        Contact con2 = [SELECT Id FROM Contact WHERE AccountId = :acc2.Id LIMIT 1];
        Contact con3 = [SELECT Id FROM Contact WHERE AccountId = null LIMIT 1];
        Task callCenter = [SELECT Id FROM Task WHERE Matrix_DNIS_Memo__c = '서비스콜센터' LIMIT 1];
        Task voc = [SELECT Id FROM Task WHERE Matrix_DNIS_Memo__c = '고객의소리' LIMIT 1];

        Test.startTest();
        DN_SearchAccountController.getAssetInfo(con.Id, callCenter.Id);
        DN_SearchAccountController.getAssetInfo(con.Id, voc.Id);
        DN_SearchAccountController.getAssetInfo(con2.Id, voc.Id);
        DN_SearchAccountController.getAssetInfo(con3.Id, voc.Id);
        DN_SearchAccountController.getAssetInfo('TEST', 'TEST');
        Test.stopTest();
    }

    @isTest
    static void testGetSearchResult(){        
        Account acc = [SELECT Id FROM Account WHERE Name = 'TEST Company'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'Company Without Asset'];
        Asset equip = [SELECT Id, Name FROM Asset WHERE AccountId = : acc.Id];

        Map<String, Object> jsonMap = new Map<String, Object>{
            'accountKey' => acc.Id,
            'assetTerm' => equip.Name
        };

        Map<String, Object> jsonMap2 = new Map<String, Object>{
            'accountKey' => acc2.Id,
            'assetTerm' => 'TEST'
        };
        
        String keyData = JSON.serialize(jsonMap);
        String keyData2 = JSON.serialize(jsonMap2);

        Test.startTest();
        DN_SearchAccountController.getSearchResult(keyData);
        DN_SearchAccountController.getSearchResult(keyData2);
        DN_SearchAccountController.getSearchResult('{"accountKey" : "", "assetTerm" : ""}');
        Test.stopTest();
    }

    @isTest
    static void testGetTicketList(){        
        Account acc = [SELECT Id FROM Account WHERE Name = 'TEST Company'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'Company Without Asset'];
        Asset equip = [SELECT Id, Name FROM Asset WHERE AccountId = : acc.Id];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        Task callCenter = [SELECT Id FROM Task WHERE Matrix_DNIS_Memo__c = '서비스콜센터' LIMIT 1];
        Case ticket = [SELECT Id FROM Case WHERE TicketType__c = 'General inquiry'];

        Map<String, Object> jsonMap = new Map<String, Object>{
            'assetId' => equip.Id,
            'taskId' => callCenter.Id,
            'caller' => con.Id,
            'recType' => 'Ticket',
            'uId' => '102-1744159433.3921'
        };

        Map<String, Object> jsonMap2 = new Map<String, Object>{
            'assetId' => equip.Id,
            'taskId' => callCenter.Id,
            'caller' => con.Id,
            'recType' => 'VOC',
            'uId' => '102-1744159433.3921'
        };

        String keyData = JSON.serialize(jsonMap);
        String keyData2 = JSON.serialize(jsonMap2);

        Test.startTest();
        DN_SearchAccountController.getTicketList(keyData);
        DN_SearchAccountController.getTicketList(keyData2);
        DN_SearchAccountController.getTicketList('{"assetId" : "", "taskId" : "", "taskId" : "", "recType" : "", "uId" : ""}');

        DN_SearchAccountController.viewSelectedTicket(ticket.Id, callCenter.Id, '102-1744159433.3921', con.Id);
        DN_SearchAccountController.viewSelectedTicket('TEST', 'TEST', 'TEST', 'TEST');
        Test.stopTest();
    }

    @isTest
    static void testGetNewTicket(){   
        Account acc = [SELECT Id FROM Account WHERE Name = 'TEST Company'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'Company Without Asset'];
        Asset equip = [SELECT Id, Name FROM Asset WHERE AccountId = : acc.Id];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        Task callCenter = [SELECT Id FROM Task WHERE Matrix_DNIS_Memo__c = '서비스콜센터' LIMIT 1];
        Case ticket = [SELECT Id FROM Case WHERE TicketType__c = 'General inquiry'];

        Map<String, Object> jsonMap = new Map<String, Object>{
            'accountKey' => acc.Id,
            'assetKey' => equip.Id,
            'contactKey' => con.Id,
            'taskId' => callCenter.Id,
            'caller' => con.Id,
            'recType' => 'Ticket',
            'uId' => '102-1744159433.3921'
        };
        String keyData = JSON.serialize(jsonMap);

        Test.startTest();
        DN_SearchAccountController.getNewTicket(keyData);
        DN_SearchAccountController.getNewTicket('{"accountKey" : "", "assetKey" : "", "contactKey" : "",  "taskId" : "",  "caller" : "", "recType" : "", "uId" : ""}');
        DN_SearchAccountController.getContactInfo(con.Id);
        DN_SearchAccountController.getContactInfo('TEST');
        Test.stopTest();
    }
}