@isTest
private class DN_InterfaceExecutionController_Test {

    @testSetup
    static void setupTestData() {
        // 테스트용 Interface__c 레코드 생성
        Interface__c intf1 = new Interface__c(
            Name = 'TEST_INTERFACE',
            Requirement__c = 'Required',
            WebServiceType__c = 'REST',
            Description__c = 'Test Desc',
            Cycle__c = 'Daily',
            EndpointURL__c = 'https://example.com/api',
            System__c = 'ERP',
            IsActive__c = true,
            HttpMethod__c = 'POST',
            TtrafficDirection__c = 'Outbound',
            ContentType__c = 'JSON',
            Timeout__c = 30,
            RequestBodySample__c = '{"request": "sample"}',
            ResponseBodySample__c = '{"response": "sample"}',
            SubCategory__c = 'Account'
        );
        insert intf1;

        // 테스트용 InterfaceLog__c 레코드 생성
        InterfaceLog__c log = new InterfaceLog__c(
            Name = 'TestLog',
            RequestBody__c = 'SampleRequest',
            ResponseBody__c = 'SampleResponse',
            RequestTime__c = System.now().addSeconds(-5),
            ResponseTime__c = System.now(),
            Interface__c = intf1.Id
        );
        insert log;
    }

    @isTest
    static void testGetInterfaceList() {
        Test.startTest();
        Map<String, Object> result = DN_InterfaceExecutionController.getInterfaceList('TEST_INTERFACE');
        Test.stopTest();
    }

    @isTest
    static void testGetInterfaceLogList() {
        Test.startTest();
        Map<String, Object> result = DN_InterfaceExecutionController.getInterfaceLogList('TEST_INTERFACE');
        Test.stopTest();
    }

    @isTest
    static void testExecuteInterface() {
        Interface__c intf = [SELECT Id, Name FROM Interface__c WHERE Name = 'TEST_INTERFACE' LIMIT 1];

        Test.startTest();
        try {
            String result = DN_InterfaceExecutionController.executeInterface(intf.Name, '{"param":"value"}');
            System.debug('executeInterface result: ' + result);
        } catch (AuraHandledException e) {
            System.debug('Expected Exception caught: ' + e.getMessage());
        }
        Test.stopTest();
    }
}