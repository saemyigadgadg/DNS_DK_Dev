/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-07-01
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
@isTest
public with sharing class TicketTriggerHandlerTest {
    @TestSetup
    static void makeData(){

        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id, UserName FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            user.LastName = 'Test User Test';
            insert user;
        }


        List<NotiReceptionList__c> insertNotiRecepList = new List<NotiReceptionList__c>();
        NotiReceptionList__c notiRecep1 = new NotiReceptionList__c();
        notiRecep1.Name = 'IndirectReception';
        notiRecep1.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep1);
        NotiReceptionList__c notiRecep2 = new NotiReceptionList__c();
        notiRecep2.Name = 'AlarmTalk';
        notiRecep2.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep2);
        NotiReceptionList__c notiRecep3 = new NotiReceptionList__c();
        notiRecep3.Name = 'PClaimPermission';
        notiRecep3.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep3);
        insert insertNotiRecepList;

        NotiReceptionList__c indirectRecep = NotiReceptionList__c.getInstance('IndirectReception');
        String indirectRecepName = indirectRecep.UserName__c;
        System.debug('indirectRecepName ::: ' + indirectRecepName);

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        Country__c us = TestDataFactoryForService.createUSCountry();
        insert us;
        
        List<Account> insertAccountList = new List<Account>();
        Account account1 = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insertAccountList.add(account1);
        Account account2 = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company2', korea);
        account2.CustomerCode__c = '0000001';
        account2.BusinessNumber__c = '5148171773';
        insertAccountList.add(account2);
        insert insertAccountList;

        List<Asset> insertAssetList = new List<Asset>();
        Asset asset1 = TestDataFactoryForService.createAsset(account1.Id);
        insertAssetList.add(asset1);
        Asset asset2 = TestDataFactoryForService.createAsset(account2.Id);
        asset2.Name = 'MH0013-000391';
        asset2.SerialNumber = 'MH0013-000391';
        insertAssetList.add(asset2);
        insert insertAssetList;

        List<Contact> insertContactList = new List<Contact>();
        Contact contact1 = TestDataFactoryForService.createContact('CSCustomer', account1.Id);
        insertContactList.add(contact1);
        Contact contact2 = TestDataFactoryForService.createContact('CSCustomer', account2.Id);
        insertContactList.add(contact2);
        insert insertContactList;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        List<ModelManager__c> insertModelManagerList = new List<ModelManager__c>();
        ModelManager__c modelManager1 = new ModelManager__c();
        modelManager1.ModelCode__c = 'MH0014';
        modelManager1.Manager__c = UserInfo.getUserId();
        modelManager1.cooperationTeam__c = 'TEST';
        insertModelManagerList.add(modelManager1);
        ModelManager__c modelManager2 = new ModelManager__c();
        modelManager2.ModelCode__c = 'MH0013';
        modelManager2.Manager__c = UserInfo.getUserId();
        modelManager2.cooperationTeam__c = 'TEST2';
        insertModelManagerList.add(modelManager2);
        insert insertModelManagerList;

        List<AssignmentRule__c> arList = new List<AssignmentRule__c>();
        AssignmentRule__c ar1 = new AssignmentRule__c();
        ar1.Name = '일반상담사 순차배정';
        ar1.AssignmentType__c = 'Owner';
        arList.add(ar1);
        AssignmentRule__c ar2 = new AssignmentRule__c();
        ar2.Name = '설치담당자';
        ar2.AssignmentType__c = 'Team Member';
        arList.add(ar2);
        AssignmentRule__c ar3 = new AssignmentRule__c();
        ar3.Name = '기술상담사 순차배정';
        ar3.AssignmentType__c = 'Owner';
        arList.add(ar3);
        AssignmentRule__c ar4 = new AssignmentRule__c();
        ar4.Name = '프로그램상담사 순차배정';
        ar4.AssignmentType__c = 'Owner';
        arList.add(ar4);
        AssignmentRule__c ar5 = new AssignmentRule__c();
        ar5.Name = 'VOC_홈페이지접수';
        ar5.AssignmentType__c = 'Team Member';
        arList.add(ar5);
        insert arList;

        List<AssignmentMember__c> amList = new List<AssignmentMember__c>();
        AssignmentMember__c am1 = new AssignmentMember__c();
        am1.User__c = thisUser.Id;
        am1.AssignmentRule__c = ar1.Id;
        am1.CurrentAssignment__c = false;
        amList.add(am1);
        AssignmentMember__c am2 = new AssignmentMember__c();
        am2.User__c = thisUser.Id;
        am2.AssignmentRule__c = ar2.Id;
        am2.CurrentAssignment__c = false;
        amList.add(am2);
        AssignmentMember__c am3 = new AssignmentMember__c();
        am3.User__c = thisUser.Id;
        am3.AssignmentRule__c = ar3.Id;
        am3.CurrentAssignment__c = false;
        amList.add(am3);
        AssignmentMember__c am4 = new AssignmentMember__c();
        am4.User__c = user.Id;
        am4.AssignmentRule__c = ar4.Id;
        am4.CurrentAssignment__c = false;
        amList.add(am4);
        AssignmentMember__c am5 = new AssignmentMember__c();
        am5.User__c = thisUser.Id;
        am5.AssignmentRule__c = ar4.Id;
        am5.CurrentAssignment__c = false;
        amList.add(am5);
        AssignmentMember__c am6 = new AssignmentMember__c();
        am6.User__c = thisUser.Id;
        am6.AssignmentRule__c = ar5.Id;
        am6.CurrentAssignment__c = false;
        amList.add(am6);
        insert amList;

        List<AlertManager__c> alertManagers = new List<AlertManager__c>{
        new AlertManager__c(Name = 'Ticket Assignment Alert', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Ticket Assignment Receptionist Alert', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'AdminTechAlert', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Program inquiry Alert', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Homepage Ticket Assignment Alert', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Homepage Ticket Assignment Receptionist Alert', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Callback Ticket Assignment Receptionist Alert', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'DNSA Ticket Owner Changed', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Ticket Owner Changed', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Install Request Reject Noti', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Ticket CallService Completed', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Ticket Change Escalation', Part__c = 'Service', IsActive__c = true),
        new AlertManager__c(Name = 'Incomplete Alarm Talk Ticket Assignment Alert', Part__c = 'Service', IsActive__c = true)
};
insert alertManagers;


    }

    @isTest
    static void testInsertTicket() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Asset> assetList = [SELECT Id FROM Asset];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = assetList[0].Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Indirect application';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';
        ticket.FailureArea__c = 'Elec._Ctrl';
        ticket.FailureAreaValue__c = '4T0';
        ticket.FailureAreaDetail__c = 'CNC System';
        ticket.FailureAreaDetailValue__c = '001';
        ticket.FailurePhenomenon__c = '작동 불량';
        ticket.FailurePhenomenonValue__c = '01';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.AssetId = assetList[1].Id;
        ticket.EndOfReason__c = 'Customer Cancellation';
        ticket.ReceptionDetails__c = 'Test';

        update ticket;
        
    }

    @isTest
    static void testInsertTicket2() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Indirect application';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'Internal request';
        ticket.InternalTicketType__c = 'Post-delivery training';
        ticket.TrainingDateTime1__c = Datetime.now().addDays(2);
        ticket.InternalRequester__c = UserInfo.getUserId();
        ticket.Sales_Office__c = '114F';

        ticket.isAlarmToCustomer__c = true;

        insert ticket;

        ticket.Status = 'Closed';
        ticket.EndOfReason__c = 'Call Service';

        update ticket;
    }

    @isTest
    static void testInsertTicket3() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Mobile Indirect application';
        ticket.ReceptionDetails__c  = '';
        ticket.InternalRequester__c  = UserInfo.getUserId();

        ticket.TicketType__c = 'Internal request';
        ticket.InternalTicketType__c = 'Installation request';
        ticket.FailureArea__c = 'Elec._Ctrl';
        ticket.FailureAreaValue__c = '4T0';
        ticket.FailureAreaDetail__c = 'CNC System';
        ticket.FailureAreaDetailValue__c = '001';
        ticket.FailurePhenomenon__c = '작동 불량';
        ticket.FailurePhenomenonValue__c = '01';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.Status = 'Reject';

        update ticket;
    }

    @isTest
    static void testInsertTicket4() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VOC_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ApplicationRoute__c     = 'Service';
        ticket.ReceptionDetails__c  = '';
        ticket.ApplicationRoute2__c  = 'Website';

        ticket.VOCType__c = 'Customer Complaint';
        ticket.VOCTypeDetail__c = 'CustomerComplaint_Service';
        ticket.VOCcategory3__c = 'Attitude/Unkindness Of Service Resource';
        ticket.Sales_Office__c = '114F';
        // ticket.FailureArea__c = 'Elec._Ctrl';
        // ticket.FailureAreaValue__c = '4T0';
        // ticket.FailureAreaDetail__c = 'CNC System';
        // ticket.FailureAreaDetailValue__c = '001';
        // ticket.FailurePhenomenon__c = '작동 불량';
        // ticket.FailurePhenomenonValue__c = '01';

        insert ticket;
    }

    @isTest
    static void testInsertTicket5() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];
        Contact con2 = [SELECT Id FROM Contact WHERE AccountId != :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Alarm Talk';
        ticket.ReceptionDetails__c  = '';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'General inquiry';
        ticket.InternalTicketType__c = 'Other inquiry';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';
        ticket.Requester__c = con2.Id;

        update ticket;

    }
    
    @isTest
    static void testInsertTicket6() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Indirect application';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Program Inquiry';
        ticket.FailureArea__c = 'Elec._Ctrl';
        ticket.FailureAreaValue__c = '4T0';
        ticket.FailureAreaDetail__c = 'CNC System';
        ticket.FailureAreaDetailValue__c = '001';
        ticket.FailurePhenomenon__c = '작동 불량';
        ticket.FailurePhenomenonValue__c = '01';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';

        update ticket;
    }

    @isTest
    static void testInsertTicket7() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Alarm Talk';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'General inquiry';
        ticket.InternalTicketType__c = 'Request callback';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Program Inquiry';

        update ticket;
    }

    
    @isTest
    static void testInsertTicket8() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Alarm Talk';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';
        ticket.RepairRequestDateTime__c = Datetime.now();
        ticket.Sales_Office__c = '114F';
        insert ticket;

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Program Inquiry';
        ticket.RepairRequestDateTime__c = Datetime.now().addDays(1);

        update ticket;

    }
    
    @isTest
    static void testInsertTicket9() {

        User user = [SELECT Id FROM User WHERE LastName = 'Test User Test' LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Alarm Talk';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.OwnerId = user.Id;

        update ticket;

    }
    
    @isTest
    static void testInsertTicket10() {

        User user = [SELECT Id FROM User WHERE LastName = 'Test User Test' LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];
        Contact con2 = [SELECT Id FROM Contact WHERE AccountId != :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Alarm Talk';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.EscLev__c = 'Esc.Lev 3';
        ticket.OwnerId = user.Id;

        update ticket;

    }
    
    @isTest
    static void testInsertTicket11() {

        User user = [SELECT Id FROM User WHERE LastName = 'Test User Test' LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];
        Contact con2 = [SELECT Id FROM Contact WHERE AccountId != :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Alarm Talk';
        ticket.ReceptionDetails__c  = '';
        ticket.Origin  = 'DNS_Homepage';

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.OwnerId = user.Id;

        update ticket;

    }
        
    @isTest
    static void testInsertTicket12() {


        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Mobile Indirect application';
        ticket.ReceptionDetails__c  = '';
        ticket.InternalRequester__c  = UserInfo.getUserId();

        ticket.TicketType__c = 'Internal request';
        ticket.InternalTicketType__c = 'Regular Inspections';
        ticket.Sales_Office__c = '114F';

        insert ticket;

        ticket.Status = 'Reject';

        update ticket;
    }
    
    @isTest
    static void testInsertDNSATicket() {

        User user = [SELECT Id FROM User WHERE LastName = 'Test User Test' LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];
        Contact con2 = [SELECT Id FROM Contact WHERE AccountId != :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_DNSA').getRecordTypeId();

        Case ticket                 = new Case();
        ticket.RecordTypeId         = recordTypeId;
        ticket.AccountId            = account.Id;
        ticket.AssetId              = asset.Id;
        ticket.Requester__c         = con.Id;


        ticket.ReceptionPath__c     = 'Indirect application';
        ticket.ReceptionDetails__c  = '';

        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';

        insert ticket;

        ticket.OwnerId = user.Id;

        update ticket;

    }

    @isTest
    static void testChangedReceptionDetail() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();

        Case ticket = new Case();
        ticket.RecordTypeId = recordTypeId;
        ticket.AccountId = account.Id;
        ticket.AssetId = asset.Id;
        ticket.Requester__c = con.Id;
        ticket.ReceptionPath__c = 'Indirect application';
        ticket.TicketType__c = 'Technical inquiry';
        ticket.InternalTicketType__c = 'Failure receipt';
        ticket.ReceptionDetails__c = '처음내용';
        insert ticket;

        ticket.ReceptionDetails__c = '변경된 내용';
        update ticket;
    }

    @isTest
    static void testInsertTicket_MissingPart() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        String recordTypeId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Ticket_Domestic')
            .getRecordTypeId();

        // Internal request + Missing Part, Wrong Part 시나리오
        Case ticket = new Case();
        ticket.RecordTypeId = recordTypeId;
        ticket.AccountId = account.Id;
        ticket.AssetId = asset.Id;
        ticket.Requester__c = con.Id;
        ticket.ReceptionPath__c = 'Indirect application';
        ticket.TicketType__c = 'Internal request';
        ticket.InternalTicketType__c = 'Missing Part, Wrong Part';
        ticket.Sales_Office__c = '114F';
        insert ticket;

        // update로 한 번 더 타기
        ticket.ReceptionDetails__c = '부품 누락 수정';
        update ticket;
    }



}