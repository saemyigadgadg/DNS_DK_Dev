@IsTest
public with sharing class IF_FilePackingServiceTest {
    public IF_FilePackingServiceTest() {}


    @TestSetup
    static void makeData(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // 두 개의 ContentVersion 생성
        ContentVersion cv1 = new ContentVersion(
            Title = 'TestFile1',
            PathOnClient = 'TestFile1.txt',
            VersionData = Blob.valueOf('This is test file 1'),
            IsMajorVersion = true
        );

        ContentVersion cv2 = new ContentVersion(
            Title = 'TestFile2',
            PathOnClient = 'TestFile2.txt',
            VersionData = Blob.valueOf('This is test file 2'),
            IsMajorVersion = true
        );

        // ContentVersion 삽입 후, 삽입된 내용 반환
        insert new List<ContentVersion>{cv1, cv2};
    }

    @istest 
    static void fileConvertedTest(){
         List<ContentVersion> cvList = [SELECT Id, Title FROM ContentVersion WHERE Title IN ('TestFile1', 'TestFile2')];
         Test.startTest();
         List<String> ids = new List<String>(); 

         for(ContentVersion version : cvList){
            ids.add(version.Id);
         }

         IF_FilePackingService packingService = new IF_FilePackingService();
         packingService.packingToMapByHTML(ids);
         packingService.packingToListByHTML(ids);
         packingService.packingToMapByHTML(ids.get(0));
         packingService.packingToListByHTML(ids.get(0));

         Test.stopTest();
    }
}