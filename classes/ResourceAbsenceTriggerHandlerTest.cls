/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-29-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class ResourceAbsenceTriggerHandlerTest {

    @isTest
    static void testInsert_NoOverlap_ShouldSucceed() {
        // 테스트용 사용자 생성
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        ServiceResource sr = new ServiceResource(
            Name = '홍길동',
            RelatedRecordId = thisUser.Id,
            StaffNumber__c = '6527',
            LastKnownLatitude = 37.557718278300890,
            LastKnownLongitude = 126.974039677136940,
            IsActive = true
        );
        insert sr;

        // ResourceAbsence에 필요한 리소스 생성 (여기선 User를 Resource로 가정)
        Id resourceId = sr.Id;

        // 중복되지 않는 시간대의 부재 레코드 생성
        ResourceAbsence absence1 = new ResourceAbsence(
            ResourceId = resourceId,
            Start = System.now(),
            End = System.now().addHours(1),
            Type = 'Training/Meeting'
        );

        insert absence1;

        System.assertNotEquals(null, absence1.Id, '첫 번째 부재 레코드가 정상적으로 삽입되어야 합니다.');
    }

    @isTest
    static void testInsert_Overlap_ShouldThrowError() {
        // 사용자 가져오기
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        ServiceResource sr = new ServiceResource(
            Name = '홍길동',
            RelatedRecordId = thisUser.Id,
            StaffNumber__c = '6527',
            LastKnownLatitude = 37.557718278300890,
            LastKnownLongitude = 126.974039677136940,
            IsActive = true
        );
        insert sr;

        Id resourceId = sr.Id;

        // 기존 일정 삽입
        ResourceAbsence existing = new ResourceAbsence(
            ResourceId = resourceId,
            Start = System.now().addHours(1),
            End = System.now().addHours(2),
            Type = 'Training/Meeting'
        );
        insert existing;

        // 겹치는 시간대의 새로운 일정 생성
        ResourceAbsence overlapping = new ResourceAbsence(
            ResourceId = resourceId,
            Start = System.now().addMinutes(90),
            End = System.now().addHours(3),
            Type = 'Training/Meeting'
        );

        Test.startTest();
        try {
            insert overlapping;
            System.assert(false, '중복된 일정은 삽입되면 안 됩니다.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('해당 일자 및 시간에 이미 생성된 일정이 있습니다'), '에러 메시지가 기대와 일치해야 합니다.');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdate_Overlap_ShouldThrowError() {
        // 사용자
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        ServiceResource sr = new ServiceResource(
            Name = '홍길동',
            RelatedRecordId = thisUser.Id,
            StaffNumber__c = '6527',
            LastKnownLatitude = 37.557718278300890,
            LastKnownLongitude = 126.974039677136940,
            IsActive = true
        );
        insert sr;
        Id resourceId = sr.Id;

        // 기존 일정
        ResourceAbsence absence1 = new ResourceAbsence(
            ResourceId = resourceId,
            Start = System.now().addHours(1),
            End = System.now().addHours(2),
            Type = 'Training/Meeting'
        );
        insert absence1;

        // 다른 일정
        ResourceAbsence absence2 = new ResourceAbsence(
            ResourceId = resourceId,
            Start = System.now().addHours(3),
            End = System.now().addHours(4),
            Type = 'Training/Meeting'
        );
        insert absence2;

        // absence2를 업데이트해서 겹치게 만들기
        absence2.Start = System.now().addHours(1).addMinutes(30); // 겹침
        absence2.End = System.now().addHours(3);

        Test.startTest();
        try {
            update absence2;
            System.assert(false, '중복 업데이트는 허용되지 않아야 합니다.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('해당 일자 및 시간에 이미 생성된 일정이 있습니다'), '중복 시간에 대한 에러가 발생해야 합니다.');
        }
        Test.stopTest();
    }
}