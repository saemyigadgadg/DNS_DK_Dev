@isTest
public with sharing class DN_TransferVideoControllerTest {
    @TestSetup
    static void makeData(){
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '123456';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        insert acc;

        Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        con.MobilePhone = '01011112222';
        insert con;

        Contact con2 = new Contact();
        RecordType type = TestDataFactoryForSales.getRecordType('ContactPerson', 'Contact');
        con2.AccountId    = acc.Id;
        con2.LastName     = 'testuser2';
        con2.RecordTypeId = type.Id;
        con2.Email        = 'test2'+acc.Id+'@gmail.com';
        con2.Position__c  = '대리';
        con2.Role__c      = '영업';
        con2.DistributionChannel__c = '10';
        con2.Division__c            = '40';
        con2.SalesOffice__c         = '114E';
        con2.SalesDistrict__c       = 'A1KR';
        con2.SalesOrganization__c   = '1800';
        con2.Phone = '01011112223';
        insert con2;

        Asset as1 = TestDataFactoryForService.createAsset(acc.Id);
        insert as1;           

        Case generalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, as1.Id, con.Id, 'General inquiry', 'Other inquiry');
        insert generalTicket;

        EducationVideo__c ev = new EducationVideo__c(Name = 'Test Video', SourceURL__c = 'https://youtu.be/');
        insert ev;

        AlertManager__c am = new AlertManager__c(Name = 'Video Send Alarm Talk');
        insert am;

    }

    @isTest
    static void testBatch() {
        Contact ct = [SELECT Id FROM Contact WHERE MobilePhone != null];
        Contact ct2 = [SELECT Id FROM Contact WHERE Phone != null];
        Case csObj = [SELECT Id FROM Case WHERE TicketType__c = 'General inquiry'];

        List<Map<String, Object>> selectedVideoList = new List<Map<String, Object>>();
        Map<String, Object> video1 = new Map<String, Object>();
        video1.put('Name', 'Test Video 1');
        video1.put('SourceURL__c', 'https://example.com/video1.mp4');
        Map<String, Object> video2 = new Map<String, Object>();
        video2.put('Name', 'Test Video 2');
        video2.put('SourceURL__c', 'https://example.com/video2.mp4');
        selectedVideoList.add(video1);
        selectedVideoList.add(video2);

        Test.startTest();
        DN_TransferVideoController.getContactPhone(ct.Id);
        DN_TransferVideoController.getContactPhone(ct2.Id);
        DN_TransferVideoController.getViedoURL(csObj.Id, 'test');
        DN_TransferVideoController.getViedoURL(ct.Id, 'test');
        DN_TransferVideoController.sendVideoURL(csObj.Id, '01012345678', selectedVideoList);
        Test.stopTest();
    }
}