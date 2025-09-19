@isTest
public with sharing class DN_ASRegisterControllerTest {
    @TestSetup
    static void makeData(){
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

        User sitUser = new User();
        sitUser.Alias               = '게스트';
        sitUser.Email               = 'site@test.com';
        sitUser.EmailEncodingKey    = 'UTF-8';
        sitUser.LastName            = '사이트 게스트 사용자';
        sitUser.FirstName           = '서비스센터';
        sitUser.LanguageLocaleKey   = 'en_US';
        sitUser.LocaleSidKey        = 'ko';
        sitUser.ProfileId           = testProfile.Id;
        sitUser.TimeZoneSidKey      = 'Asia/Seoul';
        sitUser.UserName            = 'site@solution.com';
        insert sitUser;
        
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        List<Account> accList = new List<Account>();
        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.Name = 'test company';
        acc.CustomerCode__c = '11001620';
        accList.add(acc);

        Account acc2 = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc2.Name = 'AA고객사';
        acc2.BusinessNumber__c = '5148171771';
        acc2.CustomerCode__c = '11001621';
        accList.add(acc2);

        Account acc3 = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc3.Name = '미확인 고객사';
        acc3.BusinessNumber__c = '000000';
        acc3.CustomerCode__c = '000000';
        accList.add(acc3);
        insert accList;

        List<Contact> ctList = new List<Contact>();
        Contact con = TestDataFactoryForSales.createContact('CSCustomer', acc.Id);
        con.MobilePhone = '01000000000';
        con.Phone = '01000000000';
        ctList.add(con);

        Contact con2 = TestDataFactoryForSales.createContact('CSCustomer', acc2.Id);
        con2.LastName = '고객킴';
        con2.MobilePhone = '01011112222';
        con2.Phone = '01011112222';
        ctList.add(con2);
        insert ctList;

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

        Asset ass = new Asset();
        ass.Name            = 'ML0006-006231';
        ass.MachineName__c  = 'LYNX 220A-NT';
        ass.Material__c     = 'L22ANT-F0TP-0-K30';
        ass.SerialNumber    = 'ML0006-006231';
        ass.Status          = 'AVLB';
        ass.AccountId       = acc.Id;
        ass.SoldTo__c       = acc.Id;
        ass.InstEngineer__c = worker.Id;
        insert ass;

        case cs = new case();
        cs.TicketType__c         = 'General inquiry';
        cs.InternalTicketType__c = 'Other inquiry';
        cs.EndOfReason__c        = 'Call Service';
        cs.RecordTypeId          = ticket_recordType.Id;
        cs.Status                = 'Closed';
        cs.ReceptionDetails__c   = 'test';
        cs.AssetId               = ass.Id;
        cs.Requester__c          = con.Id;
        insert cs;

        WorkOrder wo  = new WorkOrder();
        wo.CaseId                   = cs.Id;
        wo.AssetId                  = cs.AssetId;
        wo.AccountId                = acc.Id;
        wo.SoldTo__c                = acc.Id;
        wo.ServiceTerritoryId       = wc.Id;
        wo.Worker__c                = worker.Id;
        wo.TicketType__c            = 'Failure receipt';
        wo.OrderType__c             = '202';
        wo.Status                   = 'Uncompleted';
        wo.completionTime__c        = System.Now();
        wo.ActualDispatchTime__c    = System.Now();
        wo.ScheduledDispatchTime__c = System.Now();
        wo.ServiceOrderNumber__c    = '403908129';
        insert wo;

        List<AlertManager__c> amList = new List<AlertManager__c>();
        AlertManager__c noti = new AlertManager__c();
        noti.Name = 'AS Reception Completion Alarm Talk';
        noti.IsActive__c = true;
        noti.Part__c = 'Service';
        amList.add(noti);

        AlertManager__c noti2 = new AlertManager__c();
        noti2.Name = 'AS Reception Completion Outside Hours Alarm Talk';
        noti2.IsActive__c = true;
        noti2.Part__c = 'Service';
        amList.add(noti2);

        AlertManager__c noti3 = new AlertManager__c();
        noti3.Name = 'Send Noti To Inst Engineer At Night';
        noti3.IsActive__c = true;
        noti3.Part__c = 'Service';
        amList.add(noti3);

        AlertManager__c noti4 = new AlertManager__c();
        noti4.Name = 'A/S Reception Cancel Alarm Talk';
        noti4.IsActive__c = true;
        noti4.Part__c = 'Service';
        amList.add(noti4);

        AlertManager__c noti5 = new AlertManager__c();
        noti5.Name = 'CS AS Reception Cancel Noti';
        noti5.IsActive__c = true;
        noti5.Part__c = 'Service';
        amList.add(noti5);   

        insert amList;
        
        AlarmTalk__c at = new AlarmTalk__c();
        at.Name = '테스트';
        insert at;

        ContentVersion cv = new ContentVersion();
        cv.Title = '파일1';
        cv.VersionData = Blob.valueOf('Test Content Data');
        cv.PathOnClient = '파일1.png';
        insert cv;

        String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = cs.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        System.runAs(sitUser){
            ContentVersion cv2 = new ContentVersion();
            cv2.Title = '파일2';
            cv2.VersionData = Blob.valueOf('Test Content Data');
            cv2.PathOnClient = '파일1.png';
            insert cv2;

            String contentDocumentId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id LIMIT 1].ContentDocumentId;
            ContentDocumentLink cdl2 = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId2,
                LinkedEntityId = cs.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert cdl2;
        }

        Interface__c cti_g002= TestDataFactoryForSales.createinterface('IF-CTI-DNIS-G002', 'Real-Time');
        insert cti_g002;
    }

    private class MockIF_ERP_CTI implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"status": 200,"code": "SUCCESS","message": "Request is successfully done","data": {"code": "WORK","name": "업무시간","isWork": false,"scheduleType": "routine","scheduleName": "업무시간","cidState": null},"remark": null}'
            );
            return res;
        }
    }

    @isTest
    static void testGetPartsProgress(){
        InterfaceCommonUtil.setInterface('IF-CSPLUS-007', 'IF_ERP_Material');
        WorkOrder wo = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder LIMIT 1];
        Test.startTest();
        try{
            DN_ASRegisterController.getPartsProgress(String.valueOf(System.today()), wo.ServiceOrderNumber__c);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void checkWorkingHours(){
        Test.setMock(HttpCalloutMock.class, new ValidMockResponse());

        Test.startTest();
        Map<String, Object> result = DN_ASRegisterController.checkWorkingHours();
        Test.stopTest();

        System.assertEquals(true, result.get('success'));
        System.assertEquals(true, result.get('isWork'));
        System.assertEquals('001', result.get('code'));
        System.assertEquals('Test Name', result.get('name'));
    }

    @isTest
    static void getServiceCenterList(){
        Test.startTest();
        try{
            DN_ASRegisterController.getServiceCenterList();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testFile2(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        ContentDocumentLink cdl = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId LIMIT 1];
        Test.startTest();
        try{
            DN_ASRegisterController.attachFiles(new List<String>{cv.Id}, cv.Id, cv.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        try{
            DN_ASRegisterController.linkFileToAlarmTalk(cv.Id, cs.Id);
            DN_ASRegisterController.deleteFile(cdl.Id, cs.Id);
            DN_ASRegisterController.deleteFiles(cv.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSetCustomerRequest(){
        TriggerHandler.bypass('TicketTriggerHandler');
        Account acc = [SELECT Id, Name, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ShippingAddress FROM Account LIMIT 1];
        // Contact con = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = 'testuser' LIMIT 1];
        Contact con2 = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = '고객킴' LIMIT 1];
        Asset ass = [SELECT Id, SerialNumber FROM Asset LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];

        Test.startTest();
        try{
            String accAddress = acc.ShippingState == null?'':acc.ShippingState;
            if(accAddress != '') accAddress+=' ';
            accAddress+=acc.ShippingCity;

            //장비선택-연락처 있음
            DN_ASRegisterController.setCustomerRequest(acc.Id, acc.Name, acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>{cv.Id}, con2.MobilePhone, '', '', '', ass.SerialNumber
                                                        , '', con2.Name, ass.Id, con2.Id, st.Id, false, false, 'KAKAO', 1);

            DN_ASRegisterController.setCustomerRequest(acc.Id, acc.Name, acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), con2.MobilePhone, '', '', '', ass.SerialNumber
                                                        , '', '김고객', ass.Id, con2.Id, st.Id, false, false, 'KAKAO', 1);

            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, acc.ShippingStreet
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), con2.MobilePhone, '2025-01-01', '', '12:00', ass.SerialNumber
                                                        , '', '김고객', ass.Id, con2.Id, st.Id, true, true, 'KAKAO', 1);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Case cs = [SELECT Id FROM Case LIMIT 1];
        try{
            DN_ASRegisterController.getAttachedFiles(cs.Id);
            DN_ASRegisterController.getAttachedFiles('invalidId');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSetCustomerRequest2(){
        TriggerHandler.bypass('TicketTriggerHandler');
        Account acc = [SELECT Id, Name, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ShippingAddress FROM Account LIMIT 1];
        Contact con2 = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = '고객킴' LIMIT 1];
        Asset ass = [SELECT Id, SerialNumber FROM Asset LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
        try{
            String accAddress = acc.ShippingState == null?'':acc.ShippingState;
            if(accAddress != '') accAddress+=' ';
            accAddress+=acc.ShippingCity;

            //장비선택-연락처 없음
            DN_ASRegisterController.setCustomerRequest(acc.Id, acc.Name, acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), con2.MobilePhone, '', '', '', ass.SerialNumber
                                                        , '', con2.Name, ass.Id, '', st.Id, false, false, 'KAKAO', 2);

            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01055555555', '', '', '', ass.SerialNumber
                                                        , '', '김고객', ass.Id, '', st.Id, false, false, 'KAKAO', 2);

            DN_ASRegisterController.setCustomerRequest(acc.Id, acc.Name, acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01044444444', '', '', '', ass.SerialNumber
                                                        , '', '김고객', ass.Id, '', st.Id, false, false, 'KAKAO', 2);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        // AlarmTalk__c alarm = [SELECT Id, Phone__c FROM AlarmTalk__c WHERE Name != '테스트' LIMIT 1];
        Case ca = [SELECT Id, FM_PhoneNumber__c FROM Case LIMIT 1];
        try{
            DN_ASRegisterController.checkRepairRequestDateTime(ca.Id);
            DN_ASRegisterController.checkAlarmTalk(ca.FM_PhoneNumber__c);//알림톡전화번호
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSetCustomerRequest3(){
        TriggerHandler.bypass('TicketTriggerHandler');
        TriggerHandler.bypass('TicketTriggerHandler');
        Account acc = [SELECT Id, Name, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ShippingAddress FROM Account LIMIT 1];
        Contact con = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = 'testuser' LIMIT 1];
        Asset ass = [SELECT Id, SerialNumber FROM Asset LIMIT 1];
        // Asset ass = [SELECT Id, SerialNumber FROM Asset LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
        try{
            String accAddress = acc.ShippingState == null?'':acc.ShippingState;
            if(accAddress != '') accAddress+=' ';
            accAddress+=acc.ShippingCity;

            // 제조번호-연락처 있음
            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01066666666', '', '', '', ass.SerialNumber
                                                        , '', '김고객', '', con.Id, st.Id, false, false, 'KAKAO', 3);

            //제조번호-연락처 없음
            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01099999999', '', '', '', ass.SerialNumber
                                                        , '', '김고객', '', '', st.Id, false, false, 'KAKAO', 3);

            //명판사진-연락처 있음
            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01088888888', '', '', '', ''
                                                        , '', '김고객', '', con.Id, st.Id, false, false, 'KAKAO', 3);

            //명판사진-연락처 없음
            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01077777777', '', '', '', ''
                                                        , '', '김고객', '', '', st.Id, false, false, 'KAKAO', 3);

            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01099999999', '', '', '', 'test'
                                                        , '', '김고객', '', '', st.Id, false, false, 'KAKAO', 3);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Case c = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        try{
            List<AlertManager__c> notiList = new List<AlertManager__c>();
            AlertManager__c noti4 = new AlertManager__c();
            noti4.Name = 'A/S Reception Cancel Alarm Talk';
            noti4.IsActive__c = true;
            noti4.Part__c = 'Service';
            notiList.add(noti4);
    
            AlertManager__c noti5 = new AlertManager__c();
            noti5.Name = 'CS AS Reception Cancel Noti';
            noti5.IsActive__c = true;
            noti5.Part__c = 'Service';
            notiList.add(noti5);

            insert notiList;
            DN_ASRegisterController.getTicketInfo(c.CaseNumber);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

        @isTest
    static void testSetCustomerRequest4(){
        Account acc = [SELECT Id, Name, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ShippingAddress FROM Account LIMIT 1];
        // Contact con = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = 'testuser' LIMIT 1];
        Contact con2 = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = '고객킴' LIMIT 1];
        Asset ass = [SELECT Id, SerialNumber FROM Asset LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];

        Test.startTest();
        try{
            String accAddress = acc.ShippingState == null?'':acc.ShippingState;
            if(accAddress != '') accAddress+=' ';
            accAddress+=acc.ShippingCity;

            DN_ASRegisterController.setCustomerRequest(acc.Id, '고객사명', acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), '01055555555', '', '', '', ass.SerialNumber
                                                        , '', '김고객', ass.Id, '', st.Id, false, false, 'KAKAO', 2);
            //수기입력력-연락처 있음
            DN_ASRegisterController.setCustomerRequest(acc.Id, acc.Name, acc.ShippingPostalCode, accAddress, ''
                                                        , '증상', '', '', 'technicalCouncel', ''
                                                        , new List<String>(), con2.MobilePhone, '', '', '', ass.SerialNumber
                                                        , '', '김고객', ass.Id, con2.Id, st.Id, false, false, 'KAKAO', 2);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Case cs = [SELECT Id FROM Case LIMIT 1];
        try{
            DN_ASRegisterController.getAttachedFiles(cs.Id);
            DN_ASRegisterController.getAttachedFiles('invalidId');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    // @isTest
    // static void testCancel(){
    //     Case c = [SELECT Id, CaseNumber FROM Case LIMIT 1];
    //     Test.startTest();
    //     try{
    //         DN_ASRegisterController.cancelAlarmTalk(c.Id, '취소사유');
    //     } catch (Exception e) {
    //         System.debug(e.getMessage());
    //     }
    //     Test.stopTest();
    // }

    @isTest
    static void testCancelAlarmTalk_success() {
        RecordType ticket_recordType = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');
        Account acc = [SELECT Id, Name, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ShippingAddress FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = '고객킴' LIMIT 1];
        case testCase = new case();
        testCase.TicketType__c         = 'General inquiry';
        testCase.InternalTicketType__c = 'Other inquiry';
        testCase.EndOfReason__c        = 'Call Service';
        testCase.RecordTypeId          = ticket_recordType.Id;
        testCase.ReceptionDetails__c   = 'test';
        insert testCase;

        // AlarmTalk__c 생성 (Case와 연결)
        AlarmTalk__c alarm = new AlarmTalk__c(
            Name = '테스트알림',
            Ticket__c = testCase.Id,
            Phone__c = '01012345678',
            AccountName__c = acc.Name,
            Contact__c = contact.Id
        );
        insert alarm;

        // AlertManager 설정
        insert new AlertManager__c(Name = 'CS AS Reception Cancel Noti');
        insert new AlertManager__c(Name = 'A/S Reception Cancel Alarm Talk');

        // WorkOrder가 없으면 정상 실행됨
        Test.startTest();
        String result = DN_ASRegisterController.cancelAlarmTalk(testCase.Id, '고객 요청');
        Test.stopTest();

        System.assertEquals('SUCCESS', result);
        
        // 결과 검증
        Case updatedCase = [SELECT Status, EndOfReason__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Closed', updatedCase.Status);
        System.assertEquals('Customer Cancellation', updatedCase.EndOfReason__c);

        AlarmTalk__c updatedAlarm = [SELECT Name FROM AlarmTalk__c WHERE Id = :alarm.Id];

    }

    @isTest
    static void testCancelAlarmTalk_throwWhenServiceStarted() {
        RecordType ticket_recordType = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');
        Account acc = [SELECT Id, Name, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, ShippingAddress FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name, MobilePhone FROM Contact WHERE LastName = '고객킴' LIMIT 1];
        case testCase = new case();
        testCase.TicketType__c         = 'General inquiry';
        testCase.InternalTicketType__c = 'Other inquiry';
        testCase.EndOfReason__c        = 'Call Service';
        testCase.RecordTypeId          = ticket_recordType.Id;
        testCase.ReceptionDetails__c   = 'test';
        insert testCase;

        insert new WorkOrder(
            Status = 'Started',
            CaseId = testCase.Id
        );

        Boolean isExceptionThrown = false;

        Test.startTest();
        try {
            DN_ASRegisterController.cancelAlarmTalk(testCase.Id, '서비스 시작됨');
        } catch (Exception e) {
            isExceptionThrown = true;
            System.debug('예외 메시지: ' + e.getMessage());
            System.assert(e instanceof AuraHandledException, '예외 타입이 AuraHandledException이 아닙니다.');
        }
        Test.stopTest();

        System.assert(isExceptionThrown, '예외가 발생하지 않았습니다.');
    }

    @isTest
    static void testGetAssets() {
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Test.startTest();
       try {
           DN_ASRegisterController.searchAssets(acc.Id, '0');
           DN_ASRegisterController.searchAssets('invalidId','');
       } catch (Exception e) {
           System.debug(e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void testGetExistEngineer() {
       Asset ass = [SELECT Id FROM Asset LIMIT 1];
       Test.startTest();
       try {
           DN_ASRegisterController.getExistEngineer(ass.Id);
       } catch (Exception e) {
           System.debug(e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void testGetCustomerAssetList() {
       Contact con = [SELECT Id, MobilePhone FROM Contact LIMIT 1];
       Test.startTest();
       try {
           DN_ASRegisterController.getCustomerAssetList(con.MobilePhone, '');
           DN_ASRegisterController.getCustomerAssetList('','');
       } catch (Exception e) {
           System.debug(e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void testSetNewCustomer() {
       Contact con = [SELECT Id, MobilePhone FROM Contact LIMIT 1];
       Test.startTest();
       try {
           DN_ASRegisterController.createNewCustomer('testuser',con.MobilePhone);
           DN_ASRegisterController.createNewCustomer('','01010101010');
           DN_ASRegisterController.createNewCustomer('','');
       } catch (Exception e) {
           System.debug(e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void testSetEquipInfo() {
       Asset ass = [SELECT Id FROM Asset LIMIT 1];
       Test.startTest();
       try {
           DN_ASRegisterController.setEquipInfo(ass.Id,'','');
           DN_ASRegisterController.setEquipInfo('','ML0006-006231','');
           DN_ASRegisterController.setEquipInfo('','invalidName','');
           DN_ASRegisterController.setEquipInfo('','','');
       } catch (Exception e) {
           System.debug(e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void testGetEquipmentBySerialNo() {
       Asset ass = [SELECT Id FROM Asset LIMIT 1];
       Test.startTest();
       try {
           DN_ASRegisterController.getEquipmentBySerialNo('ML0006-006231', '01066666666');
       } catch (Exception e) {
           System.debug(e.getMessage());
       }
       Test.stopTest();
    }

    // 정상 응답을 반환하는 Mock
    private class ValidMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data": {"isWork": true, "code": "001", "name": "Test Name", "scheduleType": "WEEKLY", "scheduleName": "Weekday Schedule"}}');
            return res;
        }
    }

    @isTest
    static void testValidationNow() {
        Test.startTest();
        try {
            Date selectedDateAdd = Date.today().addDays(1);
            Date selectedDate = Date.today().addDays(-1);
            String selectedTime ='23:59';
            DN_ASRegisterController.validationNow(selectedDateAdd, selectedTime);
            DN_ASRegisterController.validationNow(selectedDate, selectedTime);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        Test.stopTest();
    }


    @isTest
    static void testSaveNameSymptomFile() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
        Case cs = [SELECT Id FROM Case LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        ServiceTerritory wc = [SELECT Id FROM ServiceTerritory LIMIT 1];

        DN_ASRegisterController instance = new DN_ASRegisterController();
        instance.setContactId(cont.Id);
        instance.setEquipmentNo(ass.Id);
        instance.setRepairRequestDate('2025-02-25');
        instance.setRequestTime('10:00');
        instance.setReservationTime('test');
        instance.setCaseId(cs.Id);
        instance.setSelectedFileIds(new List<String>{cv.Id});
        instance.setRequestTimeType('test');
        instance.setSerialNo('test');
        instance.setHogi('test');
        instance.setSelectedServiceCenter(wc.Id);
        instance.setNamePlateImagefiles(new List<String>{'test'});
        instance.setReferenceImagefiles(new List<String>{'test'});

        String timeValue = instance.getReservationTime();
        Id caseIdValue = instance.getCaseId();
        List<String> fileIds = instance.getSelectedFileIds();
        String dateValue = instance.getRepairRequestDate();
        String typeValue = instance.getRequestTimeType();
        String requestTime = instance.getRequestTime();
        String serialValue = instance.getSerialNo();
        String hogi = instance.getHogi();
        String equipmentNo = instance.getEquipmentNo();
        String contactId = instance.getContactId();
        String selectedServiceCenter = instance.getSelectedServiceCenter();
        List<String> namePlateImagefiles = instance.getNamePlateImagefiles();
        List<String> referenceImagefiles = instance.getReferenceImagefiles();

        Test.startTest();
        try {
            instance.saveNameSymptomFile();
            DN_ASRegisterController.saveNameSymptomFile('Test Body', 'fileName', 'contentType', 0, cs.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}