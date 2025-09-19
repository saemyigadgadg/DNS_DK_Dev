@IsTest
public with sharing class DN_HECareBatchTest {
    // @TestSetup
    // static void makeData(){
    //     Country__c country = TestDataFactoryForSales.createKRCountry();
    //     insert country;
    //     Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
    //     acc.CustomerCode__c   = '123456';
    //     acc.BusinessNumber__c = '5148171773';
    //     acc.Representative__c = 'realAcc';
    //     insert acc;

    //     Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
    //     con.MobilePhone = '01011112222';
    //     insert con;

    //     Date today = System.today();
    //     Campaign cp = new Campaign();
    //     cp.Name = 'Test Campaign';
    //     cp.RegularServiceType__c = 'HE Care';
    //     cp.IsActive = true;
    //     cp.StartDate = today.addDays(-2);
    //     cp.EndDate = today.addDays(2);
    //     cp.InstallationDateStart__c = Date.newInstance(2024, 2, 20);
    //     cp.InstallationDateEnd__c = Date.newInstance(2025, 2, 28);
    //     insert cp;

    //     ModelManager__c mm = new ModelManager__c();
    //     mm.Name = 'Test Model';
    //     mm.HECare__c = true;
    //     mm.isPortalHECare__c = false;
    //     insert mm;

    //     Asset as1 = new Asset();
    //     as1.Name = 'Test Asset1';
    //     as1.MachineName__c = mm.Name;
    //     as1.InstallationFinish__c = Date.newInstance(2025, 2, 26);
    //     insert as1;

    //     Asset as2 = new Asset();
    //     as2.Name = 'Test Asset2';
    //     as2.MachineName__c = mm.Name;
    //     as2.InstallationFinish__c = Date.newInstance(2024, 9, 26);
    //     insert as2;

    //     Asset as3 = new Asset();
    //     as3.Name = 'Test Asset3';
    //     as3.MachineName__c = mm.Name;
    //     as3.InstallationFinish__c = Date.newInstance(2024, 3, 26);
    //     insert as3;

    //     Case generalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, as2.Id, con.Id, 'General inquiry', 'Other inquiry');
    //     insert generalTicket;
    //     Case generalTicket2 = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, as3.Id, con.Id, 'General inquiry', 'Other inquiry');
    //     insert generalTicket2;
    //     Case generalTicket3 = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, as3.Id, con.Id, 'General inquiry', 'Other inquiry');
    //     insert generalTicket3;

    //     CampaignTarget__c ct1 = new CampaignTarget__c();
    //     ct1.Campaign__c = cp.Id;
    //     ct1.Equipment__c = as1.Id;
    //     insert ct1;

    //     CampaignTarget__c ct2 = new CampaignTarget__c();
    //     ct2.Campaign__c = cp.Id;
    //     ct2.X_1month__c = generalTicket.Id;
    //     ct2.Equipment__c = as2.Id;
    //     insert ct2;

    //     CampaignTarget__c ct3 = new CampaignTarget__c();
    //     ct3.Campaign__c = cp.Id;
    //     ct3.X_1month__c = generalTicket2.Id;
    //     ct3.X_6month__c = generalTicket3.Id;
    //     ct3.Equipment__c = as3.Id;
    //     insert ct3;
        
    //     AlertManager__c am = new AlertManager__c(Name = 'HE Care 1612 Alert', IsActive__c = true);
    //     insert am;
    // }

    // @isTest
    // static void testBatch() {
    //     Test.startTest();
    //     System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_HECareBatch());
    //     Database.ExecuteBatch(new DN_HECareBatch());
    //     Test.stopTest();
    // }    
    @testSetup
    static void setupData() {
        // 캠페인 생성
        Campaign cp = new Campaign(
            Name = 'HE Care Campaign',
            RegularServiceType__c = 'HE Care',
            IsActive = true,
            StartDate = Date.today().addDays(-1),
            EndDate = Date.today().addDays(1),
            InstallationDateStart__c = Date.today().addDays(-10),
            InstallationDateEnd__c = Date.today().addDays(10)
        );
        insert cp;

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '123456';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        insert acc;

        // 자산 생성 (설치 완료일 설정: 1, 6, 12개월 전에)
        List<Asset> assets = new List<Asset>{
            new Asset(Name = '장비1', InstallationFinish__c = Date.today().addMonths(-1), AccountId = acc.Id),
            new Asset(Name = '장비6', InstallationFinish__c = Date.today().addMonths(-5), AccountId = acc.Id),
            new Asset(Name = '장비12', InstallationFinish__c = Date.today().addMonths(-11), AccountId = acc.Id)
        };
        insert assets;

        // CampaignTarget 생성
        List<CampaignTarget__c> ctList = new List<CampaignTarget__c>();
        for (Asset a : assets) {
            ctList.add(new CampaignTarget__c(
                Campaign__c = cp.Id,
                Equipment__c = a.Id,
                Account__c = acc.Id
            ));
        }
        insert ctList;

        // 알림 메니저 설정
        insert new AlertManager__c(Name = 'HE Care 1612 Alert');

        // 커스텀 Metadata Type mock (HE_Equipment__mdt)
        // 메타데이터는 테스트 클래스에서 직접 생성 불가 → 대신 Mocking을 위한 Stub 또는 Stubbed List 사용
        // 이 테스트에서는 UTIL_Alert 호출부 주석 처리하셨기 때문에, 생략해도 됨
    }

    @isTest
    static void testBatchForAllMonths() {
        Test.startTest();
        DN_HECareBatch batch = new DN_HECareBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        // 생성된 케이스 확인
        List<Case> createdCases = [SELECT Id, Campaign__c, AssetId, AccountId, ReceptionDetails__c FROM Case];
        System.assertEquals(3, createdCases.size(), '총 3개의 케이스가 생성되어야 합니다 (1,6,12개월차)');

        // 각 CampaignTarget 의 필드 업데이트 확인
        List<CampaignTarget__c> updatedTargets = [
            SELECT Id, X_1month__c, X_6month__c, X_12month__c FROM CampaignTarget__c
        ];

        Boolean oneMonthFound = false, sixMonthFound = false, twelveMonthFound = false;

        for (CampaignTarget__c ct : updatedTargets) {
            if (ct.X_1month__c != null) oneMonthFound = true;
            if (ct.X_6month__c != null) sixMonthFound = true;
            if (ct.X_12month__c != null) twelveMonthFound = true;
        }

        System.assert(oneMonthFound, '1개월차 티켓이 연결된 CampaignTarget 이 있어야 합니다');
        System.assert(sixMonthFound, '6개월차 티켓이 연결된 CampaignTarget 이 있어야 합니다');
        System.assert(twelveMonthFound, '12개월차 티켓이 연결된 CampaignTarget 이 있어야 합니다');
    }
}