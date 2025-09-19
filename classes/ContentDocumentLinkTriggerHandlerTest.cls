@IsTest
private class ContentDocumentLinkTriggerHandlerTest {

    // Board__c 테스트
    @IsTest
    static void testBoardLinkFull() {
        Board__c board = new Board__c(Name = 'Test Board');
        insert board;

        ContentVersion cv = new ContentVersion(
            Title = 'Board File',
            PathOnClient = 'board.pdf',
            VersionData = Blob.valueOf('Board Content')
        );
        insert cv;

        Id docId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = board.Id,
            ShareType = 'I',
            Visibility = 'InternalUsers'
        );

        Test.startTest();
        insert cdl;                           // insert 트리거
        update new ContentDocumentLink(
            Id = cdl.Id, 
            Visibility = 'AllUsers'
        );                                    // update 트리거
        delete cdl;                            // delete 트리거
        Test.stopTest();
    }

    // Model__c 테스트
    @IsTest
    static void testModelLinkFull() {
        Model__c model = new Model__c(Name = 'Test Model');
        insert model;

        ContentVersion cv = new ContentVersion(
            Title = 'Model File',
            PathOnClient = 'model.pdf',
            VersionData = Blob.valueOf('Model Content')
        );
        insert cv;

        Id docId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = model.Id,
            ShareType = 'I',
            Visibility = 'InternalUsers'
        );

        Test.startTest();
        insert cdl;
        update new ContentDocumentLink(
            Id = cdl.Id, 
            Visibility = 'AllUsers'
        );
        delete cdl;
        Test.stopTest();
    }

    // DeliveryOrder__c 테스트
    @IsTest
    static void testDeliveryOrderLinkFull() {
        // 필수 필드가 없다고 가정
        DeliveryOrder__c delivery = new DeliveryOrder__c();
        insert delivery;

        ContentVersion cv = new ContentVersion(
            Title = 'Delivery File',
            PathOnClient = 'delivery.pdf',
            VersionData = Blob.valueOf('Delivery Content')
        );
        insert cv;

        Id docId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = delivery.Id,
            ShareType = 'I',
            Visibility = 'InternalUsers'
        );

        Test.startTest();
        insert cdl;
        update new ContentDocumentLink(
            Id = cdl.Id, 
            Visibility = 'AllUsers'
        );
        delete cdl;
        Test.stopTest();
    }
     @IsTest
    static void testCaseFileCount() {
        // 표준 Case 레코드 생성
        Case caseRec = new Case(
            Subject = 'Test Case'  // 표준 필드
        );
        insert caseRec;

        // 파일 업로드
        ContentVersion cv = new ContentVersion(
            Title = 'Case File',
            PathOnClient = 'case.pdf',
            VersionData = Blob.valueOf('Case Content')
        );
        insert cv;

        // ContentDocumentId 조회
        Id docId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ].ContentDocumentId;

        // ContentDocumentLink 생성
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = caseRec.Id,
            ShareType = 'I',
            Visibility = 'InternalUsers'
        );

        Test.startTest();
        insert cdl;   // after insert → updateCaseFileCount 호출
        delete cdl;   // after delete → updateCaseFileCount 호출
        Test.stopTest();
    }


}