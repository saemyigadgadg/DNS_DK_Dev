@isTest
private class DN_StandardMHApprovalControllerTest {

    @testSetup
    static void setupData() {
        RecordType con_recordType = TestDataFactoryForSales.getRecordType('CSCustomer', 'Contact');
        RecordType ticket_recordType = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

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
        
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        // 테스트 알림 관리자
        AlertManager__c approveAlert = new AlertManager__c(Name = 'CS StandardMH Approve Noti');
        insert approveAlert;

        AlertManager__c rejectAlert = new AlertManager__c(Name = 'CS StandardMH Reject Noti');
        insert rejectAlert;

        ModelManager__c mm = new ModelManager__c(Name = 'testGijong');
        insert mm;

        // 표준공수
        Standard_HR__c std = new Standard_HR__c(
            StandardWorkTime__c = 10,
            StandardWorkForce__c = 2,
            FailureArea__c = 'AreaA',
            StandardHourItem__c = 'Item1',
            ModelManager__c = mm.Id,
            IsActive__c = true
        );
        insert std;

        // 변경 요청
        RequestStandardHR__c req1 = new RequestStandardHR__c(
            StandardHour__c = std.Id,
            OrderNo__c = 'ORDER123',
            FaultArea__c = 'AreaA',
            StandardHourItem__c = 'Item1',
            Requester__c = u.Id,
            StandardWorkTime__c = 20,
            StandardWorkForce__c = 3,
            RequestType__c = '변경',
            ApprovalStatus__c = '승인대기',
            Approver__c = u.Id,
            RequestReason__c = '변경 이유',
            BeforeWorkTime__c = 10,
            BeforeWorkForce__c = 2
        );
        insert req1;

        // 신규 요청
        RequestStandardHR__c req2 = new RequestStandardHR__c(
            OrderNo__c = 'DNM4500',
            FaultArea__c = 'AreaB',
            StandardHourItem__c = 'Item2',
            Requester__c = u.Id,
            StandardWorkTime__c = 15,
            StandardWorkForce__c = 4,
            RequestType__c = '신규',
            ApprovalStatus__c = '승인대기',
            Approver__c = u.Id,
            RequestReason__c = '신규 이유'
        );
        insert req2;

        // 변경 요청
        RequestStandardHR__c req3 = new RequestStandardHR__c(
            StandardHour__c = std.Id,
            OrderNo__c = 'DNM4500',
            FaultArea__c = 'AreaA',
            StandardHourItem__c = 'Item1',
            Requester__c = u.Id,
            StandardWorkTime__c = 20,
            StandardWorkForce__c = 3,
            RequestType__c = '변경',
            ApprovalStatus__c = '승인',
            Approver__c = u.Id,
            RequestReason__c = '변경 이유',
            BeforeWorkTime__c = 10,
            BeforeWorkForce__c = 2
        );
        insert req3;

        // 변경 요청
        RequestStandardHR__c req4 = new RequestStandardHR__c(
            StandardHour__c = std.Id,
            OrderNo__c = 'DNM4500',
            FaultArea__c = 'AreaA',
            StandardHourItem__c = 'Item1',
            Requester__c = u.Id,
            StandardWorkTime__c = 20,
            StandardWorkForce__c = 3,
            RequestType__c = '변경',
            ApprovalStatus__c = '반려',
            Approver__c = u.Id,
            RequestReason__c = '변경 이유',
            BeforeWorkTime__c = 10,
            BeforeWorkForce__c = 2
        );
        insert req4;
        


    }

    @isTest
    static void testGetRequestList() {
        User u = [SELECT Id FROM User WHERE LastName = 'testAdmin' LIMIT 1];
        Date today = Date.today();
        test.startTest();
        DN_StandardMHApprovalController.getRequestList('DNM4500', today.addDays(-1), today.addDays(1), u.Id, '승인');
        DN_StandardMHApprovalController.getRequestList('DNM4500', today.addDays(-1), today.addDays(1), u.Id, '반려');
        DN_StandardMHApprovalController.getRequestList('DNM4500', today.addDays(-1), today.addDays(1), u.Id, '승인대기');
        test.stopTest();

    }
    
    @isTest
    static void testConfirmApproval_Change() {
        RequestStandardHR__c req = [SELECT Id, StandardHour__c FROM RequestStandardHR__c WHERE RequestType__c = '변경' LIMIT 1];
        Map<String, Object> data = new Map<String, Object>{
            'Id' => req.Id,
            'standardHour' => req.StandardHour__c
        };
        String json = JSON.serialize(data);

        Test.startTest();
        DN_StandardMHApprovalController.ResultWrapper result = DN_StandardMHApprovalController.confirmApproval(json);
        Test.stopTest();
    }

    @isTest
    static void testConfirmApproval_New() {
        RequestStandardHR__c req = [SELECT Id FROM RequestStandardHR__c WHERE RequestType__c = '신규' LIMIT 1];
        Map<String, Object> data = new Map<String, Object>{
            'Id' => req.Id
        };
        String json = JSON.serialize(data);

        Test.startTest();
        DN_StandardMHApprovalController.ResultWrapper result = DN_StandardMHApprovalController.confirmApproval(json);
        Test.stopTest();
    }

    @isTest
    static void testConfirmReject() {
        RequestStandardHR__c req = [SELECT Id FROM RequestStandardHR__c LIMIT 1];
        Map<String, Object> data = new Map<String, Object>{
            'Id' => req.Id
        };
        String json = JSON.serialize(data);

        Test.startTest();
        DN_StandardMHApprovalController.ResultWrapper result = DN_StandardMHApprovalController.confirmReject(json, '테스트 반려 사유');
        Test.stopTest();
    }
}