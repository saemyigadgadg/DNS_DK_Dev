/**
 * @author            : Hayeong Min
 * @last modified on  : 2025-04-29
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-03-21   Hayeong Min   Initial Version
**/
@isTest
public with sharing class TestDataFactoryForService {
    /*  *ticket info  */
    public static Case createCase(String recType, Id accId, Id assetId, Id conId, String major, String middle){
        RecordType type = getRecordType(recType, 'Case');

        Case ticket                 = new Case();
        ticket.RecordTypeId         = type.Id;
        ticket.AccountId            = accId;
        ticket.AssetId              = assetId;
        ticket.Requester__c         = conId;


        ticket.ReceptionPath__c     = 'Indirect application';
        ticket.ReceptionDetails__c  = 'TEST';

        ticket.TicketType__c = major;
        if(major == 'Technical inquiry'){
            ticket.InternalTicketType__c = middle;
            ticket.FailureArea__c = 'Elec._Ctrl';
            ticket.FailureAreaValue__c = '4T0';
            ticket.FailureAreaDetail__c = 'CNC System';
            ticket.FailureAreaDetailValue__c = '001';
            ticket.FailurePhenomenon__c = '작동 불량';
            ticket.FailurePhenomenonValue__c = '01';
            ticket.RepairRequestDateTime__c = System.today().addDays(3);
            ticket.BreakdownDateTime__c = Date.newInstance(2025, 5, 20);
            ticket.ApplicationDateTime__c = System.now();
        }else if(major == 'General inquiry'){
            ticket.InternalTicketType__c = middle;
        }else if(major == 'Internal request'){
            ticket.InternalTicketType__c = middle;
        }else if(major == 'Service Campaign'){
            ticket.InternalTicketType__c = middle;
        }

        return ticket;
    }

    /*  *WorkOrder info  */
    public static WorkOrder createDNSWorkOrder(String recType, Id caseId, String orderType, Id territoryId, Id resourceId){
        RecordType type = getRecordType(recType, 'WorkOrder');

        Case ticket = [SELECT AccountId, AssetId, Requester__c, InternalTicketType__c FROM Case WHERE Id = :caseId];
        WorkOrder workorder                 = new WorkOrder();
        workorder.RecordTypeId              = type.Id;
        workorder.CaseId                    = caseId;
        workOrder.AccountId                 = ticket.AccountId;
        workOrder.AssetId                   = ticket.AssetId;
        workOrder.ContactId                 = ticket.Requester__c;
        workOrder.SoldTo__c                 = ticket.AccountId;

        workOrder.ServiceTerritoryId        = territoryId;
        workOrder.Worker__c                 = resourceId;

        workOrder.Status                    = 'Assigned';
        workOrder.ReceptionDetail__c        = 'TEST';
        workOrder.isAlarmToStaff__c         = TRUE;
        workOrder.ScheduledDispatchTime__c  = Date.newInstance(2025, 5, 20);

        workOrder.TicketType__c             = ticket.InternalTicketType__c;        
        workOrder.OrderType__c              = orderType;
        workOrder.PMActivityType__c         = 'CS0'+orderType.left(1);
        
        workOrder.ServiceOrderNumber__c     = '403908716';

        return workorder;
    }

    public static WorkOrder createDNSWorkOrder(String recType, Id caseId, String orderType){
        RecordType type = getRecordType(recType, 'WorkOrder');

        Case ticket = [SELECT AccountId, AssetId, Requester__c, InternalTicketType__c FROM Case WHERE Id = :caseId];
        WorkOrder workorder                 = new WorkOrder();
        workorder.RecordTypeId              = type.Id;
        workorder.CaseId                    = caseId;
        workOrder.AccountId                 = ticket.AccountId;
        workOrder.AssetId                   = ticket.AssetId;
        workOrder.ContactId                 = ticket.Requester__c;
        workOrder.SoldTo__c                 = ticket.AccountId;

        // workOrder.ServiceTerritoryId        = territoryId;
        // workOrder.Worker__c                 = resourceId;

        workOrder.Status                    = 'New';
        workOrder.ReceptionDetail__c        = 'TEST';
        workOrder.isAlarmToStaff__c         = TRUE;
        workOrder.ScheduledDispatchTime__c  = Date.newInstance(2025, 5, 20);

        workOrder.TicketType__c             = ticket.InternalTicketType__c;        
        workOrder.OrderType__c              = orderType;
        workOrder.PMActivityType__c         = 'CS0'+orderType.left(1);
        
        workOrder.ServiceOrderNumber__c     = '403908716';

        return workorder;
    }

    /*  *Service Appointment  */
    public static ServiceAppointment createDNSAppointment(WorkOrder wo, Id territoryId, Id resourceId, String workerType){
        RecordType type = getRecordType('ServiceAppointment', 'ServiceAppointment');
        ServiceResource sr = [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id = :resourceId];
        Account acc = [SELECT Id, ShippingCity, ShippingCountry, ShippingState, ShippingStreet, ShippingPostalCode FROM Account WHERE Id = :wo.AccountId];

        ServiceAppointment appointment = new ServiceAppointment();
        appointment.RecordTypeId = type.Id;
        appointment.ParentRecordId = wo.Id;

        DateTime dt = wo.ScheduledDispatchTime__c;
        appointment.RepairRequestDateTime__c = dt;
        appointment.EarliestStartTime = dt;
        appointment.DueDate = DateTime.newInstance(dt.year(), dt.month(), dt.day(), 23, 59, 59);
        appointment.ScheduledDispatchTime__c = dt;
        appointment.SchedStartTime = dt;
        appointment.SchedEndTime = dt.addHours(4);
        
        appointment.ServiceTerritoryId = territoryId;
        appointment.ServiceResource__c = resourceId;
        if(workerType == 'Main'){
            appointment.WorkerType__c = 'Service Resource (Main)';
        }else{
            appointment.WorkerType__c = 'Service Resource (Sub)';
        }
        
        appointment.Status = 'Assigned';
        appointment.OwnerId = sr.RelatedRecordId;

        appointment.city = acc.ShippingCity;
        appointment.country = acc.ShippingCountry;
        appointment.state = acc.ShippingState;
        appointment.street = acc.ShippingStreet;
        appointment.postalCode = acc.ShippingPostalCode;

        return appointment;
    }

    /*  *Service Appointment without AssignedResource */
    public static ServiceAppointment createAppointmentWithoutAssignedResource(WorkOrder wo, String workerType){
        RecordType type = getRecordType('ServiceAppointment', 'ServiceAppointment');
        Account acc = [SELECT Id, ShippingCity, ShippingCountry, ShippingState, ShippingStreet, ShippingPostalCode FROM Account WHERE Id = :wo.AccountId];

        ServiceAppointment appointment = new ServiceAppointment();
        appointment.RecordTypeId = type.Id;
        appointment.ParentRecordId = wo.Id;
        appointment.Status = 'None';

        DateTime dt = wo.ScheduledDispatchTime__c;
        appointment.RepairRequestDateTime__c = dt;
        appointment.EarliestStartTime = dt;
        appointment.DueDate = DateTime.newInstance(dt.year(), dt.month(), dt.day(), 23, 59, 59);
        appointment.ScheduledDispatchTime__c = dt;

        if(workerType == 'Main'){
            appointment.WorkerType__c = 'Service Resource (Main)';
        }else{
            appointment.WorkerType__c = 'Service Resource (Sub)';
        }
        
        appointment.city = acc.ShippingCity;
        appointment.country = acc.ShippingCountry;
        appointment.state = acc.ShippingState;
        appointment.street = acc.ShippingStreet;
        appointment.postalCode = acc.ShippingPostalCode;

        return appointment;
    }

    /*  *Assigned Resource  */
    public static AssignedResource createAssignedResource(Id appointmentId, Id resourceId){
        AssignedResource ar = new AssignedResource ();
        ar.ServiceAppointmentId = appointmentId;
        ar.ServiceResourceId = resourceId;
        ar.EstimatedTravelTime = 200;
        return ar;
    }

    /*  *Task  */
    public static Task createCallCenterTask(Id whatId, Id whoId, String callCenter){
        RecordType type = getRecordType('Service', 'Task');

        Task task = new Task();
        task.TaskSubtype = 'Call';
        task.Status = 'Completed';
        task.WhatId = whatId;
        task.WhoId = whoId;
        task.CallType__c = 'Inbound Call';
        task.ConsultationTypeMajor__c = 'Failure Receipt';
        task.ConsultationTypeMiddle__c = 'Claim Submission';

        task.Matrix_Agent_ID__c	= '45205';
        task.Matrix_Answered_At__c = Date.newInstance(2024, 12, 25);
        task.Matrix_Call_State__c = 'Connect';
        task.Matrix_Call_Type__c = 'Inbound';
        task.Matrix_CallerID__c = '00000000000';
        task.Matrix_DNIS__c	 = '16004522';
        task.Matrix_DNIS_Memo__c = callCenter;
        task.Matrix_Extension__c = '45205';
        task.Matrix_Is_Ans__c = true;
        task.Matrix_IVR_Tag__c = 'dns';
        task.Matrix_IVR_Tag_Memo__c = '대표번호';
        task.Matrix_Queue_Name__c = '대표번호';
        task.Matrix_Phone_Number__c = '00000000000';
        task.Matrix_Call_ID__c = '102-1744159433.3921';
        task.RecordTypeId = type.Id;
        
        return task;
    }
    
    /*  *Service Territory Member */
    public static ServiceTerritoryMember createTerritoryMember(Id territoryId, Id resourceId){
        ServiceTerritoryMember stmember = new ServiceTerritoryMember();
        stmember.ServiceTerritoryId = territoryId;
        stmember.ServiceResourceId = resourceId;
        stmember.EffectiveStartDate = Date.newInstance(2020, 1, 1); 
        stmember.TerritoryType = 'P';
        return stmember;
    }

    /*  *Service Territory  */
    public static List<ServiceTerritory> createTerritory(){
        OperatingHours koHours = [SELECT Id FROM OperatingHours WHERE Name = '대한민국 표준 작업 시간'];

        List<ServiceTerritory> territory = new List<ServiceTerritory>{
            new ServiceTerritory (Branch__c = 'DNS', Name = '창원지사', classify__c = '지사', IsActive = TRUE, isDirect__c = TRUE, PlanningPlant__c = '184S', WCCode__c = '114G', OperatingHoursId = koHours.Id),
            new ServiceTerritory (Branch__c = 'DNS', Name = '광명산업', classify__c = 'W/C', IsActive = TRUE, isDirect__c = FALSE, PlanningPlant__c = '184S', WCCode__c = '1244842', OperatingHoursId = koHours.Id)
        };
        
        return territory;
    }

    /*  *Service Resource  */
    public static ServiceResource createResource(Id territoryId){
        ServiceResource resource        = new ServiceResource();
        resource.IsActive               = TRUE;
        resource.Name                   = 'TEST';
        resource.StaffNumber__c         = '6482';
        resource.Service_Territory__c   = territoryId;
        resource.RelatedRecordId        = UserInfo.getUserId();        
        return resource;
    }

    /*  *Service Resource  */
    public static ServiceResource createResource(Id territoryId, Id userId){
        ServiceResource resource        = new ServiceResource();
        resource.IsActive               = TRUE;
        resource.Name                   = 'TEST';
        resource.StaffNumber__c         = '6482';
        resource.Service_Territory__c   = territoryId;
        resource.RelatedRecordId        = userId;        
        return resource;
    }

    /*  *OperatingHours  */
    public static List<OperatingHours> createOperatingHours(){
        List<OperatingHours> operatingList = new List<OperatingHours>{
            new OperatingHours (Name = '대한민국 표준 작업 시간', Description = '대한민국 표준 작업 시간', TimeZone = 'Asia/Seoul'),
            new OperatingHours (Name = 'DNSA Operating Hours_Chicago', Description = 'DNSA Operating Hours_Chicago', TimeZone = 'America/Chicago')
        };

        return operatingList;
    }

    /*  *FailureArea Major info  */
    public static List<FailureArea_Major__c > createFailureAreaMajor() {
        List<FailureArea_Major__c > failureMajor = new List<FailureArea_Major__c >{
            new FailureArea_Major__c (ERPCodeGroup__c = '4T000000', FailureAreaMajor_Label__c = 'Elec._Ctrl', FailureAreaMajor_Label_EN__c = 'Elec._Ctrl', FailureAreaMajor_Value__c = '4T0', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T100000', FailureAreaMajor_Label__c = 'Spindle Head', FailureAreaMajor_Label_EN__c = 'Spindle Head', FailureAreaMajor_Value__c = '4T1', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T200000', FailureAreaMajor_Label__c = 'Column_Bed_Feed', FailureAreaMajor_Label_EN__c = 'Column_Bed_Feed', FailureAreaMajor_Value__c = '4T2', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T300000', FailureAreaMajor_Label__c = 'ATC_Magazine', FailureAreaMajor_Label_EN__c = 'ATC_Magazine', FailureAreaMajor_Value__c = '4T3', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T400000', FailureAreaMajor_Label__c = 'APC', FailureAreaMajor_Label_EN__c = 'APC', FailureAreaMajor_Value__c = '4T4', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T500000', FailureAreaMajor_Label__c = 'Cover', FailureAreaMajor_Label_EN__c = 'Cover', FailureAreaMajor_Value__c = '4T5', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T600000', FailureAreaMajor_Label__c = 'Chip Conveyor', FailureAreaMajor_Label_EN__c = 'Conveyor', FailureAreaMajor_Value__c = '4T6', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T700000', FailureAreaMajor_Label__c = 'Lub_Hyd_Pneu.', FailureAreaMajor_Label_EN__c = 'Lub_Hyd_Pneu.', FailureAreaMajor_Value__c = '4T7', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T800000', FailureAreaMajor_Label__c = 'Coolant', FailureAreaMajor_Label_EN__c = 'Coolant', FailureAreaMajor_Value__c = '4T8', ModelCategory__c = 'CS_MT_PDC'),
            new FailureArea_Major__c (ERPCodeGroup__c = '4T900000', FailureAreaMajor_Label__c = 'Option', FailureAreaMajor_Label_EN__c = 'Option', FailureAreaMajor_Value__c = '4T9', ModelCategory__c ='CS_MT_PDC')
        };
        return failureMajor;
    }

    /*  *FailureArea Middle info  */
    public static List<FailureAreaMiddle__c> createFailureAreaMiddle() {
        List<FailureAreaMiddle__c> failureMiddle = new List<FailureAreaMiddle__c >{
            new FailureAreaMiddle__c (CodeGroup__c = '4T0', ERPCodeGroup__c = '4T000100', FailureAreaMiddle_Label__c = 'CNC System', FailureAreaMiddle_Label_EN__c = 'CNC System', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T1', ERPCodeGroup__c = '4T100100', FailureAreaMiddle_Label__c = 'Spindle Body', FailureAreaMiddle_Label_EN__c = 'Spindle Body', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T2', ERPCodeGroup__c = '4T200100', FailureAreaMiddle_Label__c = 'Clm_Top Beam', FailureAreaMiddle_Label_EN__c = 'Clm_Top Beam', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T3', ERPCodeGroup__c = '4T300100', FailureAreaMiddle_Label__c = 'Tool Magazine', FailureAreaMiddle_Label_EN__c = 'Tool Magazine', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T4', ERPCodeGroup__c = '4T400100', FailureAreaMiddle_Label__c = 'Pallet', FailureAreaMiddle_Label_EN__c = 'Pallet', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T5', ERPCodeGroup__c = '4T500100', FailureAreaMiddle_Label__c = 'Splash Guard', FailureAreaMiddle_Label_EN__c = 'Splash Guard', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T6', ERPCodeGroup__c = '4T600100', FailureAreaMiddle_Label__c = 'Hinged Conv.', FailureAreaMiddle_Label_EN__c = 'Hinged Conv.', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T7', ERPCodeGroup__c = '4T700100', FailureAreaMiddle_Label__c = 'Lub.', FailureAreaMiddle_Label_EN__c = 'Lub.', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T8', ERPCodeGroup__c = '4T800100', FailureAreaMiddle_Label__c = 'Coolant Chiller', FailureAreaMiddle_Label_EN__c = 'Coolant Chiller', FailureAreaMiddle_Value__c = '001'),
            new FailureAreaMiddle__c (CodeGroup__c = '4T9', ERPCodeGroup__c = '4T900100', FailureAreaMiddle_Label__c = 'Head Attach_Univ.', FailureAreaMiddle_Label_EN__c = 'Head Attach_Univ.', FailureAreaMiddle_Value__c = '001')
        };
        return failureMiddle;
    }

    /*  *Failure Phenomenon info  */
    public static List<FailurePhenomenon__c> createFailurePhenomenon() {
        List<FailurePhenomenon__c> failurePhenomenon = new List<FailurePhenomenon__c>{
            new FailurePhenomenon__c (CodeGroup__c = '4T0001', ERPCodeGroup__c = '4T000101', FailurePhenomenon_Label__c = '작동 불량', FailurePhenomenon_Label_EN__c = 'Inoperable', FailurePhenomenon_Value__c = '01'),
            new FailurePhenomenon__c (CodeGroup__c = '4T0001', ERPCodeGroup__c = '4T000102', FailurePhenomenon_Label__c = '성능 이상', FailurePhenomenon_Label_EN__c = 'Malfunction', FailurePhenomenon_Value__c = '02'),
            new FailurePhenomenon__c (CodeGroup__c = '4T1001', ERPCodeGroup__c = '4T100101', FailurePhenomenon_Label__c = '작동 불량', FailurePhenomenon_Label_EN__c = 'Inoperable', FailurePhenomenon_Value__c = '01'),
            new FailurePhenomenon__c (CodeGroup__c = '4T1001', ERPCodeGroup__c = '4T100102', FailurePhenomenon_Label__c = '성능 이상', FailurePhenomenon_Label_EN__c = 'Malfunction', FailurePhenomenon_Value__c = '02'),
            new FailurePhenomenon__c (CodeGroup__c = '4T2001', ERPCodeGroup__c = '4T200101', FailurePhenomenon_Label__c = '작동 불량', FailurePhenomenon_Label_EN__c = 'Inoperable', FailurePhenomenon_Value__c = '01'),
            new FailurePhenomenon__c (CodeGroup__c = '4T2001', ERPCodeGroup__c = '4T200102', FailurePhenomenon_Label__c = '성능 이상', FailurePhenomenon_Label_EN__c = 'Malfunction', FailurePhenomenon_Value__c = '02'),
            new FailurePhenomenon__c (CodeGroup__c = '4T3001', ERPCodeGroup__c = '4T300101', FailurePhenomenon_Label__c = '작동 불량', FailurePhenomenon_Label_EN__c = 'Inoperable', FailurePhenomenon_Value__c = '01'),
            new FailurePhenomenon__c (CodeGroup__c = '4T3001', ERPCodeGroup__c = '4T300102', FailurePhenomenon_Label__c = '성능 이상', FailurePhenomenon_Label_EN__c = 'Malfunction',FailurePhenomenon_Value__c = '02'),
            new FailurePhenomenon__c (CodeGroup__c = '4T4001', ERPCodeGroup__c = '4T400101', FailurePhenomenon_Label__c = '작동 불량', FailurePhenomenon_Label_EN__c = 'Inoperable', FailurePhenomenon_Value__c = '01'),
            new FailurePhenomenon__c (CodeGroup__c = '4T4001', ERPCodeGroup__c = '4T400102', FailurePhenomenon_Label__c = '성능 이상', FailurePhenomenon_Label_EN__c = 'Malfunction', FailurePhenomenon_Value__c = '02')
        };
        return failurePhenomenon;
    }

    /*  *alert manager info  */
    public static AlertManager__c createAlertManager(String managerName){
        AlertManager__c manager = new AlertManager__c();
        manager.Name        = managerName;
        manager.IsActive__c = true;
        manager.Part__c     = 'Service';
        return manager;
    }

    

    /*  *account info  */
    public static Account createAccount(String accType, String accName, Country__c country) {
        RecordType type = getRecordType(accType, 'Account');

        Account acc           = new Account();
        acc.Name              = accName;
        acc.RecordTypeId      = type.Id;
        acc.Phone             = '00000000000';
        acc.BusinessNumber__c = '5148171774';
        acc.Representative__c = 'testuser';
        acc.CustomerCode__c   = '0000000';
        acc.TypeOfBusiness__c = 'Manufacturing';
        acc.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
        acc.IsKeyAccount__c   = true;

        acc.CurrencyIsoCode  = 'KRW';
        acc.Country__c       = 'KR';
        acc.CountryLookup__c = country.Id;
        
        acc.DistributionChannel__c = '10';
        acc.Division__c            = '40';
        acc.SalesOffice__c         = '114E';
        acc.SalesDistrict__c       = 'A1KR';
        acc.SalesOrganization__c   = '1800';

        acc.ShippingCity = '대구광역시 달서구 성서공단로';
        acc.ShippingPostalCode = '42722';

        return acc;
    }

    /*  *Country__c info  */
    public static Country__c createKRCountry() {
        Country__c country      = new Country__c();
        country.Name            = 'South Korea';
        country.CurrencyIsoCode = 'KRW';
        country.CountryCode__c  = 'KR';
        return country;
    }

    public static Country__c createUSCountry() {
        Country__c country      = new Country__c();
        country.Name            = 'USA';
        country.CurrencyIsoCode = 'USD';
        country.CountryCode__c  = 'US';
        country.Country_Picklist__c  = 'US';
        country.DNSCOLtd__c  = 'DNSA';
        return country;
    }

    /*  *asset info  */
    public static Asset createAsset(Id accId){
        Asset asset          = new Asset();
        asset.Name           = 'MH0014-000391';
        asset.SerialNumber   = 'MH0014-000391';
        asset.MachineName__c = 'HM1250';
        asset.NCType__c      = 'FANUC 31I-B PLUS';
        asset.AccountId      = accId;
        asset.ObjectType__c      = 'CS_MT_PDC';
        asset.InstallationFinish__c = Date.newInstance(2025, 1, 22);
        asset.StartUpDate__c = Date.newInstance(2025, 1, 22);
        
        return asset;
    }

    /*  *contact info  */
    public static Contact createContact(String conType, Id accId) {
        RecordType type = getRecordType(conType, 'Contact');

        Contact con      = new Contact();
        con.AccountId    = accId;
        con.LastName     = 'testuser';
        con.RecordTypeId = type.Id;
        con.Email        = 'test'+accId+'@gmail.com';
        con.MobilePhone  = '00000000000';

        con.DistributionChannel__c = '10';
        con.Division__c            = '40';
        con.SalesOffice__c         = '114E';
        con.SalesDistrict__c       = 'A1KR';
        con.SalesOrganization__c   = '1800';
        return con;
    }

    /*  *order info  */
    public static Order createDNSDomesticOrder(Account acc, Opportunity opty, Quote quote, User owner, String orderType){
        RecordType type  = getRecordType(orderType, 'Order');
        Id pBookId = Test.getStandardPricebookId();

        Date today = Date.today();

        Order order                  = new Order();
        order.AccountId              = acc.Id;
        order.Pricebook2Id           = pBookId;
        order.OpportunityId          = opty.Id;
        order.QuoteId                = quote.Id;
        order.RecordTypeId           = type.Id;
        order.EffectiveDate          = today;
        order.Status                 = 'Created';
        order.CurrencyIsoCode        = quote.CurrencyIsoCode;
        order.OrderType__c           = 'ZPO';
        order.ReqDeliveryDate__c     = today.addMonths(2);
        order.PurchaseType__c        = 'Z1';
        // order.OrderSegmentation__c   = 'Wholesale';
        order.Country__c             = 'KR';
        order.SalesChannelType__c    = 'Domestic';

        order.PaymentTerms__c        = 'C001';
        order.Incoterms__c           = 'Y03';
        order.ShippingConditions__c  = '10';
        // order.Warranty__c            = 'B1D (12Month)';

        order.EndUser__c             = 'test';
        order.Contractor__c          = 'test';
        order.MainCategory__c        = 'MB';
        order.SubCategory__c         = 'MB2';
        order.IsTooling__c           = 'MY';

        order.OwnerId                = owner.Id;
        order.SalesRep__c            = owner.AccountId;
        order.ServiceDealer__c       = owner.AccountId;
        order.CreditDealer__c        = owner.AccountId;

        order.BillTo__c              = acc.Id;
        order.ShipTo__c              = acc.Id;
        order.Payer__c               = acc.Id;
        order.SoldTo__c              = acc.Id;

        order.DistributionChannel__c = '10';
        order.Division__c            = '40';
        order.SalesDistrict__c       = 'A1KR';
        order.SalesOrganization__c   = '1800';
        return order;
    }

    /*  *record type info  */
    public static RecordType getRecordType(String devName, String sObjName) {
        RecordType type = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =: sObjName AND DeveloperName =:devName];
        return type;
    }

    public static Map<String, RecordType> getRecordType(String sObjName) {
        List<RecordType> types = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =: sObjName];
        
        Map<String, RecordType> typeMap = new Map<String, RecordType>();
        for(RecordType type : types) {
            typeMap.put(type.DeveloperName, type);
        }
        return typeMap;
    }

    /*  user info  */
    public static Profile getProfile(String profileName){

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = : profileName];
        return profile;
    }
    public static UserRole getUserRole(String roleName) {

        UserRole role = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName =: roleName];
        return role;
    }
    public static User createDNSAUser(String orgCode, String profileName, String roleName){
        Profile profile = getProfile(profileName);
        UserRole role = getUserRole(roleName);

        User u = new User();
        u.SalesOrganization__c = orgCode;
        u.ProfileId = profile.Id;
        u.UserRoleId = role.Id;

        u.Username               = 'test001@gmail.com' + System.currentTimeMillis();
        u.LastName               = 'testuser';
        u.CompanyName            = 'DN Solutions';
        u.Email                  = 'suheon.ha@dncompany.com';
        u.Alias                  = 'testuser';
        u.IsActive               = true;
        u.TimeZoneSidKey         = 'America/Chicago';
        u.LocaleSidKey           = 'en_US';
        u.LanguageLocaleKey      = 'en_US';
        u.EmailEncodingKey       = 'UTF-8';

        u.SalesDistrict__c       = 'A1KR';
        u.DistributionChannel__c = '10';
        u.Division__c            = '40';
        u.IsActive               = TRUE;
    

        return u;
    }

    public static User createDNSUser(String orgCode, String profileName, String roleName){
        Profile profile = getProfile(profileName);
        UserRole role = getUserRole(roleName);

        User u = new User();
        u.SalesOrganization__c = orgCode;
        u.ProfileId = profile.Id;
        u.UserRoleId = role.Id;

        u.Username               = 'test001@gmail.com' + System.currentTimeMillis();
        u.LastName               = 'testuser';
        u.Phone                  = '01012345678';
        u.CompanyName            = 'DN Solutions';
        u.Email                  = 'yeongdeok.s@dncompany.com';
        u.Alias                  = 'testuser';
        u.IsActive               = true;
        u.TimeZoneSidKey         = 'Asia/Seoul';
        u.LocaleSidKey           = 'ko_KR';
        u.LanguageLocaleKey      = 'ko';
        u.EmailEncodingKey       = 'UTF-8';

        u.SalesDistrict__c       = 'A1KR';
        u.DistributionChannel__c = '10';
        u.Division__c            = '40';
    
        return u;
    }

    /*  *Pricebook2 info  */
    public static void activatePriceBook(){
        Pricebook2 pBook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update pBook;
    }

    public static PricebookEntry createPriceBookEntry(Product2 prod, String curr) {
        Id pBookId = Test.getStandardPricebookId();

        PricebookEntry entry  = new PricebookEntry();
        entry.Pricebook2Id    = pBookId;
        entry.Product2Id      = prod.Id;
        entry.CurrencyIsoCode = curr;
        entry.UnitPrice       = 0;
        entry.IsActive        = true;

        return entry;
    }

    

    /*  *product2 info  */
    public static Model__c createModel() {
        Model__c model             = new Model__c();
        model.Name                 = 'DNM 4500';
        model.Name__c              = 'DNM 4500';
        model.NameEN__c            = 'DNM 4500';
        model.Code__c              = 'MV0176';
        model.MaterialCode__c      = 'MV0176';
        model.MaterialGroupCode__c = '610225';
        model.MaterialGroupName__c = 'VERTICAL MACHINING C';
        model.Unit__c              = 'EA';
        model.Weight__c            = 5000;
        model.WeightUnit__c        = 'KG';
        return model;
    }

    public static ModelManager__c createModelManager() {
        ModelManager__c modelManager    = new ModelManager__c();
        modelManager.Name                      = 'DNM 4500';
        modelManager.ModelCode__c              = 'DNM 4500';
        return modelManager;
    }
    
    public static product2 createProduct() {
        RecordType type = getRecordType('Part', 'Product2');

        Model__c model = createModel();
        insert model;

        product2 prod               = new product2();
        prod.Name                   = 'R18181';
        prod.ProductCode            = 'R18181';
        prod.IsActive               = true;
        prod.CurrencyIsoCode        = 'KRW';
        prod.RecordTypeId           = type.Id;
        prod.Unit__c                = 'EA';
        prod.Name__c                = 'R18181;KOREA';
        prod.Model__c               = model.Id;
        prod.MaterialGroupCode__c   = '610225';
        prod.MaterialGroupName__c   = 'VERTICAL MACHINING C';
        prod.Region__c              = 'K';
        prod.MaxSpindleSpeed__c     = '12000 R/MIN';
        prod.ToolStorageCapacity__c = '30 EA';
        prod.MonitorSize__c         = '15 inch';
        prod.NCSystem__c            = 'DN SOLUTIONS-FANUC I SERIES_MC';
        prod.Plant__c               = '184S;1846;';
        return prod;
    }

    /*  *productRequest info  */
    public static ProductRequest createProductRequest(Product2 prod, WorkOrder workOrder, ServiceTerritory workcenter) {
        
        // 필요시 필드 값 추가하시길
        ProductRequest prodReq = new ProductRequest();
        prodReq.Product__c = prod.Id;
        prodReq.WorkOrderId = workOrder.Id;
        prodReq.TransportsDivision__c = '20';
        prodReq.DeliveryDate__c = Date.today();
        prodReq.ProgressStatus__c = '배송완료';
        prodReq.OrderQuantity__c = 1;
        prodReq.Inventory__c = '1';
        prodReq.PackagingCompleted__c = 1;
        prodReq.VNDNM__c = 'Test';
        prodReq.ReturnStatus__c = 'N';
        prodReq.SALES__c = '';
        prodReq.TrackingNumber__c = '';
        prodReq.WarehouseReleaseNumber__c = '';
        prodReq.ShipToName__c = 'Test';
        prodReq.CompanyName__c = 'Test';
        prodReq.WorkCenter__c = workcenter.Id;
        prodReq.RECV_DT__c = Date.today();
        prodReq.PartsRequestDate__c = Date.today();
        prodReq.Seq__c = '0010';

        return prodReq;
    }

    public static QuoteLineItem createQuoteItem(Quote quote, PricebookEntry entry, OpportunityLineItem oItem, Product2 prod) {
        Date today = Date.today();

        QuoteLineItem qItem         = new QuoteLineItem();
        qItem.QuoteId               = quote.Id;
        qItem.PricebookEntryId      = entry.Id;
        qItem.OpportunityLineItemId = oItem.Id;
        qItem.Product2Id            = prod.Id;
        qItem.RequestedDelivDate__c = today.addMonths(2);
        qItem.ExpectedDelivDate__c  = '계약 후 5개월 내';
        qItem.Warranty__c           = 'B1D';
        qItem.UnitPrice             = 0;
        qItem.Quantity              = 1;
        qItem.Max_POSNR__c          = 20;
        return qItem;
    }

}