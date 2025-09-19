@isTest
public with sharing class DN_WeeklyServiceSolvingStateBatchTest {
    @isTest
    static void testWeeklyServiceSolvingStateBatch() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
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

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

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

        ServiceTerritory wc2 = new ServiceTerritory();
        wc2.Name                 = 'test';
        wc2.ServiceWorkCenter__c = acc.Id;
        wc2.OperatingHoursId     = oh.Id;
        wc2.classify__c          = '지사';
        wc2.WCCode__c            = 'test';
        wc2.IsActive             = true;
        wc2.PlanningPlant__c     = '184S';
        wc2.InstEngineer__c      = u.Id;
        insert wc2;

        List<WorkOrder> woList = new List<WorkOrder>();

        WorkOrder wo1 = new WorkOrder(Status = 'Completed', CreatedDate = System.today().addDays(-1), completionTime__c = System.now(), ServiceTerritoryId = wc.Id, TicketType__c = 'Failure receipt', OrderType__c = '202');
        
        WorkOrder wo2 = new WorkOrder(Status = 'Assigned', CreatedDate = System.today().addDays(-1), ServiceTerritoryId = wc.Id, TicketType__c = 'Failure receipt', OrderType__c = '201');

        WorkOrder wo3 = new WorkOrder(Status = 'Started', CreatedDate = System.today().addDays(-1), ServiceTerritoryId = wc2.Id, TicketType__c = 'Failure receipt', OrderType__c = '202');

        WorkOrder wo4 = new WorkOrder(Status = 'New', CreatedDate = System.today().addDays(-1), ServiceTerritoryId = wc2.Id, TicketType__c = 'Failure receipt', OrderType__c = '201');

        insert woList = new List<WorkOrder>{wo1, wo2, wo3, wo4};

        List<ServiceAppointment> saList = new List<ServiceAppointment>{
            new ServiceAppointment(ParentRecordId = wo1.Id, Pendingprocessing__c = 'Parts'),
            new ServiceAppointment(ParentRecordId = wo2.Id, Pendingprocessing__c = 'Closing'),
            new ServiceAppointment(ParentRecordId = wo3.Id, Pendingprocessing__c = 'Technical Design'),
            new ServiceAppointment(ParentRecordId = wo3.Id, Pendingprocessing__c = 'Installation'),
            new ServiceAppointment(ParentRecordId = wo3.Id, Pendingprocessing__c = 'Customer'),
            new ServiceAppointment(ParentRecordId = wo3.Id, Pendingprocessing__c = 'Result Not entered'),
            new ServiceAppointment(ParentRecordId = wo3.Id, Pendingprocessing__c = 'ETC'),
            new ServiceAppointment(ParentRecordId = wo4.Id, Pendingprocessing__c = 'Person')
        };
        insert saList;

        Test.startTest();
        DN_WeeklyServiceSolvingStateBatch batch = new DN_WeeklyServiceSolvingStateBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
}