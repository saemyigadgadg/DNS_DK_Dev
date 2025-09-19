@isTest
public with sharing class DN_DOFileManagerControllerTest {
    
    @TestSetup
    static void makeData(){

        DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(null);
        insert dOrder;

        ContentVersion testVersion = new ContentVersion(
            Title = 'Test File'
            , VersionData = Blob.valueOf('Test File Content')
            , PathOnClient = 'TestFile.pdf'
        );
        insert testVersion;

        ContentVersion queryVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        ContentDocumentLink testLink = new ContentDocumentLink(
            LinkedEntityId = dOrder.Id
            , ContentDocumentId = queryVersion.ContentDocumentId
            , ShareType = 'V'
        );
        insert testLink;
    }

    @IsTest
    static void getFlagSentERPTest(){

        DeliveryOrder__c dOrder = [SELECT Id FROM DeliveryOrder__c LIMIT 1];
        
        Test.startTest();

        DN_DOFileManagerController.getFlagSentERP(dOrder.Id);

        try {
            DN_DOFileManagerController.getFlagSentERP(null);
        } catch (Exception e) {
            System.debug('getFlagSentERPTest error : ' + e.getMessage());
        }
        
        Test.stopTest();
    }

    @IsTest
    static void getUploadedFilesTest(){

        DeliveryOrder__c dOrder = [SELECT Id FROM DeliveryOrder__c LIMIT 1];
        
        Test.startTest();

        DN_DOFileManagerController.getUploadedFiles(dOrder.Id);

        try {
            DN_DOFileManagerController.getUploadedFiles(null);
        } catch (Exception e) {
            System.debug('getUploadedFilesTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void deleteFileTest(){

        ContentDocument testDocu = [SELECT Id FROM ContentDocument LIMIT 1];
        
        Test.startTest();

        DN_DOFileManagerController.deleteFile(testDocu.Id);

        Test.stopTest();
    }

    @IsTest
    static void uploadFileTest(){

        DeliveryOrder__c dOrder = [SELECT Id FROM DeliveryOrder__c LIMIT 1];
        String fileName = 'TestFile.pdf';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String contentType = 'application/pdf';
        String fileType = 'bizReg';
        
        Test.startTest();

        DN_DOFileManagerController.uploadFile(fileName, base64Data, contentType, fileType, dOrder.Id);

        Test.stopTest();
    }
}