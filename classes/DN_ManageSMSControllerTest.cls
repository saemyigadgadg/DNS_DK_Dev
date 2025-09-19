@isTest
private class DN_ManageSMSControllerTest {

    static void setupTestData() {
        RecordType con_recordType = TestDataFactoryForSales.getRecordType('CSCustomer', 'Contact');
        RecordType ticket_recordType = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
        Profile siteProfile = [SELECT Id FROM Profile WHERE Name = '서비스센터 프로필' LIMIT 1];

        User u = new User();
        u.Alias               = 'SBTAdmin';
        u.Email               = 'sbtAdmin@test.com';
        u.EmailEncodingKey    = 'UTF-8';
        u.LastName            = 'testAdmin';
        u.LanguageLocaleKey   = 'en_US';
        u.LocaleSidKey        = 'ko';
        u.ProfileId           = testProfile.Id;
        u.TimeZoneSidKey      = 'Asia/Seoul';
        u.UserName            = 'sbtAdmin3@solution.com';
        insert u;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.Name = 'test company';
        acc.CustomerCode__c = '11001620';
        insert acc;

        OperatingHours oh = new OperatingHours();
        oh.Name     = '대한민국 표준 작업 시간';
        oh.TimeZone = 'Asia/Seoul';
        insert oh;

        ServiceTerritory wc = new ServiceTerritory();
        wc.Name                 = 'MCT서비스';
        wc.ServiceWorkCenter__c = acc.Id;
        wc.OperatingHoursId     = oh.Id;
        wc.classify__c          = 'W/C';
        wc.WCCode__c            = '11001620';
        wc.IsActive             = true;
        wc.PlanningPlant__c     = '184S';
        wc.InstEngineer__c      = u.Id;
        insert wc;

        ServiceResource worker = new ServiceResource();
        worker.Name                 = '테스터';
        worker.CurrentStatus__c     = 'Wait';
        worker.RelatedRecordId      = u.Id;
        worker.IsActive             = true;
        worker.Service_Territory__c = wc.Id;
        insert worker;

        Asset asset = new Asset(Name = 'Serial123', AccountId = acc.Id);
        insert asset;

        WorkOrder wo = new WorkOrder(
            Subject = '작업 테스트',
            Status = 'New',
            AccountId = acc.Id,
            AssetId = asset.Id
        );
        insert wo;

        // SMSHistory 생성
        SMSHistory__c sms = new SMSHistory__c(
            OutBoundCall__c = '07011112222',
            InboundCall__c = '01099998888',
            Content__c = '테스트 메시지',
            SendTargetPickVal__c = '서비스요원',
            ServiceResource__c = worker.Id,
            Account__c = acc.Id,
            WorkOrder__c = wo.Id
        );
        insert sms;
    }

    @isTest static void testGetWorkCenterList() {
        setupTestData();
        Test.startTest();
        Map<String, List<DN_ManageSMSController.PicklistWrapper>> result = DN_ManageSMSController.getWorkCenterList();
        Test.stopTest();
    }

    @isTest static void testGetStaffList() {
        setupTestData();
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
        List<DN_ManageSMSController.PicklistWrapper> result = DN_ManageSMSController.getStaffList(st.Id);
        Test.stopTest();
    }

    @isTest static void testGetSearchList() {
        setupTestData();
        ServiceResource sr = [SELECT Id FROM ServiceResource LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
        List<DN_ManageSMSController.StaffWrapper> result = DN_ManageSMSController.getSearchList(st.Id, 'all');
        List<DN_ManageSMSController.StaffWrapper> result2 = DN_ManageSMSController.getSearchList(st.Id, sr.Id);
        Test.stopTest();
    }

    @isTest static void testGetSMSList() {
        setupTestData();
        SMSHistory__c sms = [SELECT CreatedDate, SendTargetPickVal__c, ServiceResource__c, Account__c, WorkOrder__c FROM SMSHistory__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'startDate' => String.valueOf(Date.today().addDays(-1)),
            'endDate' => String.valueOf(Date.today().addDays(1)),
            'searchTarget' => '서비스요원',
            'serviceResourceId' => sms.ServiceResource__c,
            'accountId' => sms.Account__c,
            'workOrderId' => sms.WorkOrder__c
        });

        Test.startTest();
        List<DN_ManageSMSController.SMSWrapper> smsList = DN_ManageSMSController.getSMSList(jsonInput);
        Test.stopTest();
    }

    @isTest static void testSendSMSConfirm() {
        setupTestData();
        ServiceResource sr = [SELECT Id, PhoneNumber__c FROM ServiceResource LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Map<String, Object> payload = new Map<String, Object>{
            'smsContent' => '테스트 SMS 메시지입니다',
            'outboundNum' => '07088887777',
            'inboundNum' => '01012344321',
            'selectedList' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'Id' => sr.Id,
                    'Phone' => sr.PhoneNumber__c,
                    'AccountId' => acc.Id,
                    'WorkOrderId' => wo.Id
                }
            }
        };

        Test.startTest();
        DN_ManageSMSController.ResultWrapper rw = DN_ManageSMSController.sendSMSConfirm(JSON.serialize(payload));
        Test.stopTest();
    }
}