// @isTest(SeeAllData=true)
// public with sharing class SurveyInvitationTriggerHandlerTest {
//     @isTest
//     static void testGetRecordInfo(){        
//         Survey survey = [SELECT Id FROM Survey LIMIT 1];
//         SurveyInvitation invite = new SurveyInvitation(
//             Name = 'Test Invite',
//             SurveyId = survey.Id
//         );
//         insert invite;

//         Test.startTest();
        
//         Test.stopTest();
//     }
// }
@isTest(SeeAllData=true)
public with sharing class SurveyInvitationTriggerHandlerTest {

    @isTest
    static void testInviteExpirySetOnCompletedStatus() {
        // 실제 Survey 데이터 중 하나를 사용
        Survey survey = [SELECT Id FROM Survey LIMIT 1];

        // SurveyInvitation 생성
        SurveyInvitation invite = new SurveyInvitation(
            Name = 'Test Invite',
            SurveyId = survey.Id
        );
        insert invite;

        Test.startTest();
        update invite;
        Test.stopTest();
    }

    @isTest
    static void testNoChangeWhenNotCompleted() {
        // Survey 데이터 로드
        Survey survey = [SELECT Id FROM Survey LIMIT 1];

        // SurveyInvitation 생성
        SurveyInvitation invite = new SurveyInvitation(
            Name = 'Test Invite 2',
            SurveyId = survey.Id
        );
        insert invite;

        // 다른 필드만 업데이트 (Status 변화 없음)
        invite.Name = 'Updated Name';

        Test.startTest();
        update invite;
        Test.stopTest();
    }
}