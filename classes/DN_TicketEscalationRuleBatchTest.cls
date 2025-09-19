@isTest
public with sharing class DN_TicketEscalationRuleBatchTest {
    private static final Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();

    @TestSetup
    static void makeData(){
        
        Asset asset = new Asset(Name = 'ML0006-006231');
        insert asset;

        Account acc = new Account(
            Name                    = 'Test Account',
            RecordTypeId            = prospectCustomerRT,
            BusinessNumber__c       = '111111',
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

        TicketEscalationRule__c ter = new TicketEscalationRule__c(IsActive__c = true, EscalationType__c = 'Batch', IsChange__c = true, Account__c = acc.Id, TicketType__c = 'Technical inquiry',
        InternalTicketType__c = 'Program Inquiry', EscalationLv__c = 'Esc.Lev 1', Branch__c = 'DNS');
        insert ter;
        TicketEscalationFailureArea__c tefa = new TicketEscalationFailureArea__c(TicketEscalationRule__c = ter.Id, FailureAreaMain__c = 'test');
        insert tefa;
        TicketEscalationEquipment__c tee = new TicketEscalationEquipment__c(Escalation__c = ter.Id, EquipmentNo__c = asset.Id);
        insert tee;
        TicketEscalationRegion__c teregion = new TicketEscalationRegion__c(Escalation__c = ter.Id);
        insert teregion;
        TicketEscalationQueue__c teq = new TicketEscalationQueue__c(TicketEscalationRule__c = ter.Id);
        insert teq;        
        TicketEscalationRole__c terole = new TicketEscalationRole__c(TicketEscalationRule__c = ter.Id);
        insert terole;        
        TicketManager__c tm = new TicketManager__c(TicketEscalationRule__c = ter.Id, Record_Type__c = 'Function', Function__c = 'setModelManager');
        insert tm;

        TicketEscalationRule__c ter3 = new TicketEscalationRule__c(Name = 'test2', IsActive__c = true, IsChange__c = False, Account__c = acc.Id);
        insert ter3;
        TicketEscalationFailureArea__c tefa3 = new TicketEscalationFailureArea__c(TicketEscalationRule__c = ter3.Id, FailureAreaMain__c = 'test', FailureAreaMiddle__c = 'test');
        insert tefa3;
        TicketEscalationEquipment__c tee3 = new TicketEscalationEquipment__c(Escalation__c = ter3.Id, EquipmentNo__c = asset.Id);
        insert tee3;
        TicketEscalationRegion__c teregion3 = new TicketEscalationRegion__c(Escalation__c = ter3.Id);
        insert teregion3;
        TicketEscalationQueue__c teq3 = new TicketEscalationQueue__c(TicketEscalationRule__c = ter3.Id);
        insert teq3;        
        TicketEscalationRole__c terole3 = new TicketEscalationRole__c(TicketEscalationRule__c = ter3.Id);
        insert terole3;        
        TicketManager__c tm3 = new TicketManager__c(TicketEscalationRule__c = ter3.Id, Record_Type__c = 'Function');
        insert tm3;

        TicketEscalationRule__c ter4 = new TicketEscalationRule__c(Name = 'test4', IsActive__c = true, IsChange__c = False, Account__c = acc.Id);
        insert ter4;
        TicketEscalationFailureArea__c tefa4 = new TicketEscalationFailureArea__c(TicketEscalationRule__c = ter4.Id, FailureAreaMain__c = 'test', FailureAreaMiddle__c = 'test', FailurePhenomenon__c = 'test');
        insert tefa4;
        TicketEscalationEquipment__c tee4 = new TicketEscalationEquipment__c(Escalation__c = ter4.Id, EquipmentNo__c = asset.Id);
        insert tee4;
        TicketEscalationRegion__c teregion4 = new TicketEscalationRegion__c(Escalation__c = ter4.Id);
        insert teregion4;
        TicketEscalationQueue__c teq4 = new TicketEscalationQueue__c(TicketEscalationRule__c = ter4.Id);
        insert teq4;        
        TicketEscalationRole__c terole4 = new TicketEscalationRole__c(TicketEscalationRule__c = ter4.Id);
        insert terole4;        
        TicketManager__c tm4 = new TicketManager__c(TicketEscalationRule__c = ter4.Id, Record_Type__c = 'Function');
        insert tm4;

        TicketEscalationRule__c ter2 = new TicketEscalationRule__c(Name = 'test', IsActive__c = true, IsChange__c = true, Account__c = acc.Id);
        insert ter2;
        TicketEscalationFailureArea__c tefa2 = new TicketEscalationFailureArea__c(TicketEscalationRule__c = ter2.Id);
        insert tefa2;
        TicketEscalationEquipment__c tee2 = new TicketEscalationEquipment__c(Escalation__c = ter2.Id, EquipmentNo__c = asset.Id);
        insert tee2;
        TicketEscalationRegion__c teregion2 = new TicketEscalationRegion__c(Escalation__c = ter2.Id);
        insert teregion2;
        TicketEscalationQueue__c teq2 = new TicketEscalationQueue__c(TicketEscalationRule__c = ter2.Id);
        insert teq2;        
        TicketEscalationRole__c terole2 = new TicketEscalationRole__c(TicketEscalationRule__c = ter2.Id);
        insert terole2;    
        TicketManager__c tm2 = new TicketManager__c(TicketEscalationRule__c = ter2.Id);
        insert tm2;

        Case caseObj = new Case(
            // RecordTypeId        = ticketRT,
            Status              = 'New',
            AssetId             = asset.Id,
            ReceptionDetails__c = 'Test',
            TicketType__c       = 'Technical inquiry',
            InternalTicketType__c = 'Program Inquiry',
            FailureArea__c = 'test',
            AccountId = acc.Id
        );
        insert caseObj;

        ModelManager__c mm = new ModelManager__c(Name = 'test');
        insert mm;

    }

    @isTest
    static void testGetRecordInfo(){
        TicketEscalationRule__c ter = [SELECT Id FROM TicketEscalationRule__c WHERE Name = 'test' LIMIT 1];
        TicketEscalationRule__c ter3 = [SELECT Id FROM TicketEscalationRule__c WHERE Name = 'test2' LIMIT 1];
        TicketEscalationRule__c ter4 = [SELECT Id FROM TicketEscalationRule__c WHERE Name = 'test4' LIMIT 1];
        List<Case> caseList = [SELECT Id FROM Case];
        List<User> userList = [SELECT Id FROM User];

        Test.startTest();
        DN_TicketEscalationRuleBatch batch = new DN_TicketEscalationRuleBatch(ter.Id, 'test');
        DN_TicketEscalationRuleBatch batch3 = new DN_TicketEscalationRuleBatch(ter3.Id, 'test');
        DN_TicketEscalationRuleBatch batch2 = new DN_TicketEscalationRuleBatch(null, 'test');
        DN_TicketEscalationRuleBatch batch4 = new DN_TicketEscalationRuleBatch(ter4.Id, 'test');
        Database.executeBatch(batch, 1);
        Database.executeBatch(batch2, 1);
        Database.executeBatch(batch3, 1);
        Database.executeBatch(batch4, 1);
        Test.stopTest();
    }
}