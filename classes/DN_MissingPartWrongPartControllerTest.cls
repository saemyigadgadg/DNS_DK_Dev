/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-09-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_MissingPartWrongPartControllerTest {

    @testSetup
    static void setupTestData() {
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        
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


            ContentVersion cv = new ContentVersion(
                Title = 'Test File',
                PathOnClient = 'TestFile.jpg',
                VersionData = Blob.valueOf('Dummy Data')
            );
            insert cv;

            // ContentDocumentId 가져오기
            Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

            // uploadedFileIds 준비
            List<String> uploadedFileIds = new List<String>{cdId};

            // 테스트 실행
            Test.startTest();
            DN_MissingPartWrongPartController.createTicket(
                account.Id,
                contact.Id,
                asset.Id,
                '테스트 접수 내용입니다.',
                uploadedFileIds
            );
            Test.stopTest();

            // 검증: Case 생성 확인
            List<Case> caseList = [SELECT Id, AssetId, AccountId, Requester__c, ReceptionDetails__c, Is_MissingPart_WrongPart__c FROM Case];

            // 검증: 파일 연결 확인
            List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :caseList[0].Id];    
    }

    @isTest
    static void testUploadFileContentVersion() {
        String fileName = 'SampleFile.txt';
        String content = 'This is a test file content.';
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf(content));
        String contentType = 'text/plain';

        Test.startTest();
        Id contentDocId = DN_MissingPartWrongPartController.uploadFileContentVersion(fileName, base64Content, contentType);
        Test.stopTest();


        // 검증
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id = :contentDocId LIMIT 1];
    }
}