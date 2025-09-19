@isTest
public class DN_DailyLoginHistoryBatchTest {

    @testSetup
    static void setupData() {
        OperatingHours oh = new OperatingHours();
        oh.Name     = '대한민국 표준 작업 시간';
        oh.TimeZone = 'Asia/Seoul';
        insert oh;

        // Create a Service Territory with classify__c = 'W/C'
        ServiceTerritory territory = new ServiceTerritory(Name = 'Test Territory', classify__c = 'W/C', OperatingHoursId = oh.Id, IsActive = true);
        insert territory;

        // Create a User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
        User u = new User(
            Alias = 'testusr',
            Email='testuser@example.com',
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='testuser'+Math.random()+'@example.com'
        );
        insert u;

        // Create ServiceResource
        ServiceResource sr = new ServiceResource(
            Name = 'Test Resource',
            IsActive = true,
            RelatedRecordId = u.Id,
            Service_Territory__c = territory.Id
        );
        insert sr;

        // Create WorkOrders for each test scenario
        List<WorkOrder> woList = new List<WorkOrder>();

        // 접수건수
        woList.add(new WorkOrder(ServiceTerritoryId = territory.Id, Status = 'New'));

        // 출동건수
        woList.add(new WorkOrder(ServiceTerritoryId = territory.Id, Status = 'Dispatched'));

        // 도착건수
        woList.add(new WorkOrder(ServiceTerritoryId = territory.Id, Status = 'En Route'));

        // 완료건수
        woList.add(new WorkOrder(ServiceTerritoryId = territory.Id, Status = 'Completed'));

        // 2HR 출동 및 24HR 수리 (모의 필드 값 설정)
        WorkOrder woWithDispatchAndRepair = new WorkOrder(
            ServiceTerritoryId = territory.Id,
            Status = 'Completed'
        );
        insert woWithDispatchAndRepair;

        // 날짜 설정 (테스트에서는 setCreatedDate 사용)
        Test.setCreatedDate(woWithDispatchAndRepair.Id, DateTime.now().addDays(-1));

        // ⚠ 커스텀 필드들은 테스트에서 직접 설정 불가할 수 있으므로 배치 클래스에서 접근 전 Null 체크 필수

        insert woList;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();

        DN_DailyLoginHistoryBatch batch = new DN_DailyLoginHistoryBatch();
        Database.executeBatch(batch, 200);

        Test.stopTest();

        List<LoginHistory__c> records = [SELECT Id FROM LoginHistory__c];
        System.assert(records.size() > 0, 'LoginHistory__c records should have been inserted.');
    }

    @isTest
    static void testScheduledExecution() {
        Test.startTest();

        DN_DailyLoginHistoryBatch scheduler = new DN_DailyLoginHistoryBatch();
        String cron = '0 0 0 1 1 ? 2050'; // future schedule
        System.schedule('Test Schedule', cron, scheduler);

        Test.stopTest();
    }
}