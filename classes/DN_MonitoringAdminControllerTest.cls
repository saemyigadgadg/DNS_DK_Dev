/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-03-30
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
@isTest
public with sharing class DN_MonitoringAdminControllerTest {
    @TestSetup
    static void makeData(){
        RecordType voc_recordType = TestDataFactoryForSales.getRecordType('VOC_Domestic', 'Case');
        RecordType ticket_recordType = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');
        RecordType sa_recordType = TestDataFactoryForSales.getRecordType('ServiceAppointment', 'ServiceAppointment');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);

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

        Asset ass = new Asset();
        ass.Name            = 'ML0006-006231';
        ass.MachineName__c  = 'LYNX 220A-NT';
        ass.Material__c     = 'L22ANT-F0TP-0-K30';
        ass.SerialNumber    = 'ML0006-006231';
        ass.Status          = 'AVLB';
        ass.AccountId       = acc.Id;
        ass.SoldTo__c       = acc.Id;
        insert ass;

        case cs_voc = new case();
        cs_voc.VOCType__c   = 'Customer Complaint';
        cs_voc.VOCTypeDetail__c   = 'CustomerComplaint_Quality';
        cs_voc.VOCcategory3__c   = 'Product Performance';
        cs_voc.RecordTypeId = voc_recordType.Id;
        cs_voc.Status       = 'New';
        cs_voc.AssetId      = ass.Id;
        insert cs_voc;

        case cs_ticket = new case();
        cs_ticket.TicketType__c         = 'General inquiry';
        cs_ticket.InternalTicketType__c = 'Other inquiry';
        cs_ticket.EndOfReason__c        = 'Call Service';
        cs_ticket.RecordTypeId          = ticket_recordType.Id;
        cs_ticket.Status                = 'Closed';
        cs_ticket.ReceptionDetails__c   = 'test';
        cs_ticket.AssetId               = ass.Id;
        insert cs_ticket;

        case cs_ticket2 = new case();
        cs_ticket2.TicketType__c             = 'Technical inquiry';
        cs_ticket2.InternalTicketType__c     = 'Failure receipt';
        cs_ticket2.EndOfReason__c            = 'Call Service';
        cs_ticket2.RecordTypeId              = ticket_recordType.Id;
        cs_ticket2.Status                    = 'Uncompleted';
        cs_ticket2.ReceptionDetails__c       = 'test';
        cs_ticket2.BreakdownDateTime__c      = System.Now();
        cs_ticket2.FailureArea__c            ='Elec._Ctrl';
        cs_ticket2.FailureAreaDetail__c      = 'CNC System';
        cs_ticket2.FailurePhenomenonValue__c = '01';
        cs_ticket2.AssetId                   = ass.Id;
        cs_ticket2.RepairRequestDateTime__c  = System.Now();
        insert cs_ticket2;

        case cs_ticket3 = new case();
        cs_ticket3.TicketType__c             = 'Technical inquiry';
        cs_ticket3.InternalTicketType__c     = 'Failure receipt';
        cs_ticket3.EndOfReason__c            = 'Call Service';
        cs_ticket3.RecordTypeId              = ticket_recordType.Id;
        cs_ticket3.Status                    = 'Completed';
        cs_ticket3.ReceptionDetails__c       = 'test';
        cs_ticket3.BreakdownDateTime__c      = System.Now();
        cs_ticket3.FailureArea__c            ='Elec._Ctrl';
        cs_ticket3.FailureAreaDetail__c      = 'CNC System';
        cs_ticket3.FailurePhenomenonValue__c = '01';
        cs_ticket3.AssetId                   = ass.Id;
        cs_ticket3.RepairRequestDateTime__c  = System.Now();
        insert cs_ticket3;

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
        insert wc;

        ServiceResource worker = new ServiceResource();
        worker.Name                 = '테스터';
        worker.CurrentStatus__c     = 'Wait';
        worker.RelatedRecordId      = u.Id;
        worker.IsActive             = true;
        worker.Service_Territory__c = wc.Id;
        insert worker;

        WorkOrder wo  = new WorkOrder();
        wo.CaseId                   = cs_ticket2.Id;
        wo.AssetId                  = cs_ticket2.AssetId;
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
        insert wo;

        WorkOrder wo2  = new WorkOrder();
        wo2.CaseId                   = cs_ticket3.Id;
        wo2.AssetId                  = cs_ticket3.AssetId;
        wo2.AccountId                = acc.Id;
        wo2.SoldTo__c                = acc.Id;
        wo2.ServiceTerritoryId       = wc.Id;
        wo2.Worker__c                = worker.Id;
        wo2.TicketType__c            = 'Failure receipt';
        wo2.OrderType__c             = '202';
        wo2.Status                   = 'Assigned';
        wo2.completionTime__c        = System.Now();
        wo2.ActualDispatchTime__c    = System.Now();
        wo2.ScheduledDispatchTime__c = System.Now();
        insert wo2;

        ServiceAppointment sa = new ServiceAppointment();
        sa.Department__c = System.Now();
        sa.Status = 'Completed';
        sa.ParentRecordId = wo.Id;
        sa.RecordTypeId = sa_recordType.Id;
        insert sa;
    }

    @isTest
    static void test01() {
        Test.startTest();
        DN_MonitoringAdminController.getData();
        Test.stopTest();
    }
}