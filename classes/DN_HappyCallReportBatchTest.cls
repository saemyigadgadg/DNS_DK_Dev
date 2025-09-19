@IsTest(SeeAllData=true)
private class DN_HappyCallReportBatchTest {
    private static final Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();

    @IsTest static void testAllMonthBranches() {
        RecordType ticket_recordType = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');

        OperatingHours oh = new OperatingHours();
            oh.Name     = '대한민국 표준 작업 시간';
            oh.TimeZone = 'Asia/Seoul';
        insert oh;

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = new Account(
            Name                    = 'Test Account',
            RecordTypeId            = prospectCustomerRT,
            BusinessNumber__c       = '545454',
            Representative__c       = 'test',
            Competitor__c           = 'None',
            MainCategory__c         = 'MB',
            SubCategory__c          = 'MB1',
            IsTooling__c            = 'MY',
            Production__c           = 'TEST',
            TypeOfBusiness__c       = 'Manufacturing',
            TypeOfIndustry__c       = '가구,기타 제품 제조',
            Country__c              = 'KR',
            Phone                   = '010-1111-2222',
            Website                 = 'www.test.com',
            Fax                     = '010-1111-2222',
            SearchTerm__c           = 'test',
            SalesOrganization__c    = '1800',
            SalesDistrict__c        = 'A1KR',
            SalesOffice__c          = '114C',
            DistributionChannel__c  = '10',
            Division__c             = '40',
            ShippingPostalCode      = '01402'
        );
        insert acc;

        Survey survey = [SELECT Id, Name FROM Survey WHERE Name = '설치알림톡' LIMIT 1];

        CampaignMaster__c cm = new CampaignMaster__c(
            Name        = 'TM_AllMonth',
            Type__c     = 'Survey',
            IsActive__c = true,
            Survey__c = survey.Id
        );
        insert cm;

        Campaign camp = new Campaign(
            Name              = 'TC_AllMonth',
            CampaignMaster__c = cm.Id,
            IsMigration__c    = false,
            Type__c = 'Survey'
        );
        insert camp;

        ServiceTerritory wc = new ServiceTerritory();
            wc.Name                 = 'TEST123';
            wc.ServiceWorkCenter__c = acc.Id;
            wc.OperatingHoursId     = oh.Id;
            wc.classify__c          = 'W/C';
            wc.WCCode__c            = '11001620';
            wc.IsActive             = true;
            wc.PlanningPlant__c     = '184S';
        insert wc;

        Asset ass = new Asset();
        ass.Name            = 'ML0006-006233';
        ass.MachineName__c  = 'LYNX 220A-t';
        ass.Material__c     = 'L22ANT-F0TP-0-Kt';
        ass.SerialNumber    = 'ML0006-00623';
        ass.Status          = 'AVLB';
        ass.AccountId       = acc.Id;
        ass.SoldTo__c       = acc.Id;
        insert ass;

        case cs = new case();
        cs.TicketType__c         = 'General inquiry';
        cs.InternalTicketType__c = 'Other inquiry';
        cs.EndOfReason__c        = 'Call Service';
        cs.RecordTypeId          = ticket_recordType.Id;
        cs.Status                = 'Closed';
        cs.ReceptionDetails__c   = 'test';
        cs.AssetId               = ass.Id;
        insert cs;

        WorkOrder wo  = new WorkOrder();
        wo.CaseId                   = cs.Id;
        wo.AssetId                  = cs.AssetId;
        wo.AccountId                = acc.Id;
        wo.SoldTo__c                = acc.Id;
        wo.ServiceTerritoryId       = wc.Id;
        wo.TicketType__c            = 'Failure receipt';
        wo.OrderType__c             = '202';
        wo.Status                   = 'Uncompleted';
        wo.completionTime__c        = System.Now();
        wo.ActualDispatchTime__c    = System.Now();
        wo.ScheduledDispatchTime__c = System.Now();
        wo.ServiceOrderNumber__c    = '403908129';
        insert wo;

        HappyCallReport__c hcp = new HappyCallReport__c();
        hcp.Year__c = '2025';
        hcp.WorkCenter__c = wc.Id;
        hcp.Type__c = 'W/C';
        insert hcp;

        HappyCallReport__c hcp2 = new HappyCallReport__c();
        hcp2.Survey__c = survey.Id;
        hcp2.Year__c = '2025';
        hcp2.WorkCenter__c = wc.Id;
        hcp2.Type__c = 'W/C';
        insert hcp2;

        // ────────────────────────────────────────────────

        // ── 1월~12월 CampaignTarget__c 레코드 생성 ─────────────
        List<CampaignTarget__c> cts = new List<CampaignTarget__c>();
        for (Integer m = 1; m <= 12; m++) {
            cts.add(new CampaignTarget__c(
                Campaign__c            = camp.Id,
                Ticket__c              = cs.Id,
                Score__c               = 80,
                SurveyCompletedDate__c = Date.newInstance(2025, m, 15)
            ));
        }
        insert cts;

        DN_HappyCallReportBatch.testScope     = cts;
        Test.startTest();
            DN_HappyCallReportBatch batch = new DN_HappyCallReportBatch();
            Iterable<SObject> scope = batch.start(null);
            new DN_HappyCallReportBatch().execute(null, null);
        Test.stopTest();
    }

    @IsTest
    static void testInsertOnlyBranch() {
        RecordType ticket_recordType = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');

        OperatingHours oh = new OperatingHours();
            oh.Name     = '대한민국 표준 작업 시간';
            oh.TimeZone = 'Asia/Seoul';
        insert oh;

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = new Account(
            Name                    = 'Test Account',
            RecordTypeId            = prospectCustomerRT,
            BusinessNumber__c       = '545454',
            Representative__c       = 'test',
            Competitor__c           = 'None',
            MainCategory__c         = 'MB',
            SubCategory__c          = 'MB1',
            IsTooling__c            = 'MY',
            Production__c           = 'TEST',
            TypeOfBusiness__c       = 'Manufacturing',
            TypeOfIndustry__c       = '가구,기타 제품 제조',
            Country__c              = 'KR',
            Phone                   = '010-1111-2222',
            Website                 = 'www.test.com',
            Fax                     = '010-1111-2222',
            SearchTerm__c           = 'test',
            SalesOrganization__c    = '1800',
            SalesDistrict__c        = 'A1KR',
            SalesOffice__c          = '114C',
            DistributionChannel__c  = '10',
            Division__c             = '40',
            ShippingPostalCode      = '01402'
        );
        insert acc;

        Survey survey = [SELECT Id, Name FROM Survey WHERE Name = '설치알림톡' LIMIT 1];

        CampaignMaster__c cm = new CampaignMaster__c(
            Name        = 'TM_AllMonth',
            Type__c     = 'Survey',
            IsActive__c = true,
            Survey__c = survey.Id
        );
        insert cm;

        Campaign camp = new Campaign(
            Name              = 'TC_AllMonth',
            CampaignMaster__c = cm.Id,
            IsMigration__c    = false,
            Type__c = 'Survey'
        );
        insert camp;

        ServiceTerritory wc = new ServiceTerritory();
            wc.Name                 = 'TEST123';
            wc.ServiceWorkCenter__c = acc.Id;
            wc.OperatingHoursId     = oh.Id;
            wc.classify__c          = 'W/C';
            wc.WCCode__c            = '11001620';
            wc.IsActive             = true;
            wc.PlanningPlant__c     = '184S';
        insert wc;

        Asset ass = new Asset();
        ass.Name            = 'ML0006-006233';
        ass.MachineName__c  = 'LYNX 220A-t';
        ass.Material__c     = 'L22ANT-F0TP-0-Kt';
        ass.SerialNumber    = 'ML0006-00623';
        ass.Status          = 'AVLB';
        ass.AccountId       = acc.Id;
        ass.SoldTo__c       = acc.Id;
        insert ass;

        case cs = new case();
        cs.TicketType__c         = 'General inquiry';
        cs.InternalTicketType__c = 'Other inquiry';
        cs.EndOfReason__c        = 'Call Service';
        cs.RecordTypeId          = ticket_recordType.Id;
        cs.Status                = 'Closed';
        cs.ReceptionDetails__c   = 'test';
        cs.AssetId               = ass.Id;
        insert cs;

        WorkOrder wo  = new WorkOrder();
        wo.CaseId                   = cs.Id;
        wo.AssetId                  = cs.AssetId;
        wo.AccountId                = acc.Id;
        wo.SoldTo__c                = acc.Id;
        wo.ServiceTerritoryId       = wc.Id;
        wo.TicketType__c            = 'Failure receipt';
        wo.OrderType__c             = '202';
        wo.Status                   = 'Uncompleted';
        wo.completionTime__c        = System.Now();
        wo.ActualDispatchTime__c    = System.Now();
        wo.ScheduledDispatchTime__c = System.Now();
        wo.ServiceOrderNumber__c    = '403908129';
        insert wo;

        List<CampaignTarget__c> cts = new List<CampaignTarget__c>();
        for (Integer m = 1; m <= 12; m++) {
            cts.add(new CampaignTarget__c(
                Campaign__c            = camp.Id,
                Ticket__c              = cs.Id,
                Score__c               = 75,
                SurveyCompletedDate__c = Date.newInstance(2025, m, 15)
            ));
        }
        insert cts;

        DN_HappyCallReportBatch.testScope     = cts;

        Test.startTest();
            new DN_HappyCallReportBatch().execute(null, null);
        Test.stopTest();
    }
}