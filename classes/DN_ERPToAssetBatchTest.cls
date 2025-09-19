/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class DN_ERPToAssetBatchTest {

    // 가짜 콜아웃 응답을 위한 Mock 클래스 정의
    public class MockERPResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"O_RETURN":{"TYPE":"S","MESSAGE":"Success"},"T_RETURN":[]}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testBatch() {
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

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        insert wo;

        ServiceAppointment appointment = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        insert appointment;

        // 상태 맵 설정
        Map<String, String> statusMap = new Map<String, String>();
        statusMap.put(asset.Id, 'X');

        // 배치 쿼리 정의
        String query = 'SELECT Id, Name, Account.Name, Account.Representative__c, Account.ShippingStreet, Account.ShippingPostalCode, ' +
                       'Account.ShippingCity, Account.CountryLookup__r.CountryCode__c, Account.RegionLookup__r.RegionCode__c, Account.Phone, Account.CustomerCode__c, Maintplant__c, ' +
                       'WorkCenter__r.WCCode__c , PlanningPlant__c, PlannerGrp__c, WarrantyStartDateWages__c, WarrantyEndWages__c, MainWorkCtr__r.WCCode__c, SoldTo__r.CustomerCode__c, ' +
                       'InternNoteLong__c, WarrantyEnd__c, OwnerId, Owner.ERP_Key__c ' +
                       'FROM Asset WHERE Id = \'' + asset.Id + '\'';

        // 콜아웃 Mock 등록
        Test.setMock(HttpCalloutMock.class, new MockERPResponse());

        Test.startTest();
        // 배치 실행
        Database.executeBatch(new DN_ERPToAssetBatch(query, statusMap), 1);
        Test.stopTest();

        // 결과 검증
        Asset updatedAsset = [SELECT IsERPUpdate__c, ERPUpdateError__c, IsECUSCahnge__c FROM Asset WHERE Id = :asset.Id];
    }
}