/**
 * @description       : DN_NewWorkOrderController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-24
 * @last modified by  : Hayeong Min
 * @Percentage        :
**/
@isTest
public with sharing class DN_NewWorkOrderController_TEST {
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{
              'AccountTriggerHandler'
            , 'OpportunityTriggerHandler'
            , 'QuoteTriggerHandler'
            , 'OrderTriggerHandler'
            , 'QuoteLineItemTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', korea, null);
            insert dealerAcc;
   
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
   
            dealer = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer;
        }

        RecordType product_recordType = TestDataFactoryForSales.getRecordType('ServicePackage', 'Product2');
        Product2 prod = TestDataFactoryForSales.createProduct();
        prod.RecordTypeId = product_recordType.Id;
        prod.Field2__c = '1개월;2개월;3개월;4개월;';
        prod.StandardDay__c = '설치일';
        prod.IsActive = true;
        insert prod;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TradeCustomer Company', korea);
        account.AccountGroup__c= '1010';
        insert account;

        Account dealerAcc = TestDataFactoryForService.createAccount('Dealer', 'Dealer Company', korea);
        dealerAcc.BusinessNumber__c= 'dealer BusinessNumber';
        dealerAcc.AccountGroup__c= '1010';
        insert dealerAcc;
        
        Account shipto = TestDataFactoryForService.createAccount('TradeCustomer', 'ShipTo Company', korea);
        shipto.BusinessNumber__c= 'shipto BusinessNumber';
        shipto.AccountGroup__c= '1030';
        insert shipto;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        asset.WarrantyStartDateWages__c = Date.newInstance(2024, 5, 20);
        asset.WarrantyEndWages__c = Date.newInstance(2026, 5, 20);
        asset.WarrantyEndWages__c = Date.newInstance(2026, 5, 20);
        asset.WarrantyEnd__c = Date.newInstance(2024, 5, 20);
        asset.WarrantyStartDate__c = Date.newInstance(2024, 6, 20);
        insert asset;

        Asset asset2 = TestDataFactoryForService.createAsset(shipto.Id);
        asset2.WarrantyStartDateWages__c = Date.newInstance(2024, 5, 20);
        asset2.WarrantyEndWages__c = Date.newInstance(2026, 5, 20);
        asset.WarrantyEnd__c = Date.newInstance(2024, 5, 20);
        asset.WarrantyStartDate__c = Date.newInstance(2024, 6, 20);
        insert asset2;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;


        List<Case> validation_Ticket = new List<Case>{
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, null, null, '', ''),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, null, 'Technical inquiry', 'Failure receipt'),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, null, 'Technical inquiry', 'Failure receipt'),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, null, 'Technical inquiry', 'Failure receipt'),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Technical consultation'),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Pre-Call'),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Service Package Claim'),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, null, 'Technical inquiry', 'Failure receipt'),
            TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset2.Id, null, 'Technical inquiry', 'Failure receipt')
        };

        insert validation_Ticket;

        validation_Ticket[1].RepairRequestDateTime__c    = null;
        validation_Ticket[2].BreakdownDateTime__c        = null;
        validation_Ticket[3].ApplicationDateTime__c      = null;
        validation_Ticket[5].FailureAreaValue__c         = '';
        validation_Ticket[7].Status                      = 'Closed';
        update validation_Ticket;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        List<Case> ticketList = new List<Case>();
        
        Case dnsaTicket = TestDataFactoryForService.createCase('Ticket_DNSA', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        ticketList.add(dnsaTicket);
        
        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        ticketList.add(technicalTicket);
       
        Case trainingTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Post-delivery training');
        ticketList.add(trainingTicket);

        Case installTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        installTicket.TicketType__c = 'Internal request';
        installTicket.InternalTicketType__c = 'Installation request';
        ticketList.add(installTicket);

        insert ticketList;


        List<OperatingHours> hoursList = TestDataFactoryForService.createOperatingHours();
        insert hoursList;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);
        insert resource;        

        ModelManager__c mm = new ModelManager__c(ModelCode__c = 'MH0014', ModelGroup__c = 'TC');
        insert mm;

        // Skill skill = new Skill(DeveloperName = 'TC', Language = 'ko', MasterLabel = '설치_TC');
        // insert skill;
        Skill skill = [SELECT Id FROM Skill WHERE DeveloperName = 'TC' LIMIT 1];
        ServiceResourceSkill srSkill = new ServiceResourceSkill(SkillId = skill.Id, ServiceResourceId = resource.Id, EffectiveStartDate = Date.newInstance(2024, 10,15));
        insert srSkill;


        List<Order> orderList = new List<Order>();
        List<Asset> assetList = new List<Asset>();
        List<Case> caseList = new List<Case>();

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', korea, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
            insert entry;    

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem1 = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem1;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;
            System.debug('quote RecordType :: '+quote.RecordTypeId);


            QuoteLineItem qItem1 = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem1, prod);
            qItem1.Quote_RecordType__c = 'Korea';
            insert qItem1;

            Order order1 = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order1.CreatedDate = Date.newInstance(2025, 1, 22);
            order1.ERPPSONo__c = '1000000';
            orderList.add(order1);

            Order order2 = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order2.CreatedDate = Date.newInstance(2025, 1, 22);
            order2.IsBilled__c = 'Y';
            orderList.add(order2);

            insert orderList;

        }

        Case orderTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, null, 'Internal request', 'Installation request');
        orderTicket.SalesOrder__c = orderList[0].Id;
        installTicket.TicketType__c = 'Internal request';
        installTicket.InternalTicketType__c = 'Installation request';
        insert orderTicket;

        AssignmentRule__c ar = new AssignmentRule__c(Name = 'P-Claim 사용자', AssignmentType__c = 'Team Member');
        insert ar;

        AssignmentMember__c am = new AssignmentMember__c(User__c = dealer.Id, AssignmentRule__c = ar.Id, CurrentAssignment__c = false);
        insert am;

        JurisdictionalInfo__c jd = new JurisdictionalInfo__c(WorkCenter__c = territory.Id, CityCounty__c = '대구광역시 달서구');
        insert jd;
    }

    @isTest
    static void testGetRecordInfo(){   
        String urlStr = '1.eyJ0eXBlIjoic3RhbmRhcmRfX3JlY29yZFBhZ2UiLCJhdHRyaWJ1dGVzIjp7Im9iamVjdEFwaU5hbWUiOiJDYXNlIiwicmVjb3JkSWQiOiI1MDBKTzAwMDAwOVFtbjRZQUMiLCJhY3Rpb25OYW1lIjoidmlldyJ9LCJzdGF0ZSI6e319';

        Test.startTest();
        DN_NewWorkOrderController.decodeTicketId(urlStr);
        DN_NewWorkOrderController.decodeTicketId('Exception');
        Test.stopTest();
    }


    @isTest
    static void testGetSoldToRecordType(){   
        Account dealer = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Dealer' LIMIT 1];

        Test.startTest();
        DN_NewWorkOrderController.getSoldToRecordType(dealer.Id);
        DN_NewWorkOrderController.getSoldToRecordType('Exception');
        Test.stopTest();
    }

    @isTest
    static void testGetSoldToInfo(){   
        Case ticket = [SELECT Id FROM Case WHERE SalesOrder__c != null];

        Test.startTest();
        DN_NewWorkOrderController.getSoldToInfo(ticket.Id, '104');
        DN_NewWorkOrderController.getSoldToInfo(ticket.Id, '103');
        DN_NewWorkOrderController.getSoldToInfo('Exception', '104');
        DN_NewWorkOrderController.getTicketInfo(ticket.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetTicketInfoValidation(){   

        Case case1 = [SELECT Id FROM Case WHERE AssetId = null LIMIT 1];
        Case case2 = [SELECT Id FROM Case WHERE RepairRequestDateTime__c = null LIMIT 1];
        Case case3 = [SELECT Id FROM Case WHERE InternalTicketType__c = 'Failure receipt' AND BreakdownDateTime__c = null LIMIT 1];
        Case case4 = [SELECT Id FROM Case WHERE ApplicationDateTime__c = null LIMIT 1];
        Case case5 = [SELECT Id FROM Case WHERE InternalTicketType__c = 'Technical consultation' LIMIT 1];
        Case case6 = [SELECT Id FROM Case WHERE InternalTicketType__c = 'Pre-Call' LIMIT 1];
        Case case7 = [SELECT Id FROM Case WHERE InternalTicketType__c = 'Service Package Claim' LIMIT 1];
        Case case8 = [SELECT Id FROM Case WHERE Status = 'Closed' LIMIT 1];

        Test.startTest();
        DN_NewWorkOrderController.getTicketInfo(case1.Id);        
        DN_NewWorkOrderController.getTicketInfo(case2.Id);
        DN_NewWorkOrderController.getTicketInfo(case3.Id);
        DN_NewWorkOrderController.getTicketInfo(case4.Id);
        DN_NewWorkOrderController.getTicketInfo(case5.Id);           
        DN_NewWorkOrderController.getTicketInfo(case6.Id);           
        DN_NewWorkOrderController.getTicketInfo(case7.Id);           
        DN_NewWorkOrderController.getTicketInfo(case8.Id);           
        DN_NewWorkOrderController.getTicketInfo('Exception');
        Test.stopTest();
    }

    @isTest
    static void testDNSAOrder(){
        InterfaceCommonUtil.setInterface('IF-CSPLUS-044', 'IF_ERP_SalesOrder');

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE Service_Territory__c  = :territory.Id LIMIT 1];
                
        Case techTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Failure receipt'
                                        AND FM_Country__c = 'DNSA' LIMIT 1];

         

        RecordType dnsa = TestDataFactoryForSales.getRecordType('WorkOrder_DNSA', 'WorkOrder');

        String woData1 = '{"CaseId":"'+techTicket.Id+'","AssetId":"'+techTicket.AssetId+'","TicketType__c":"Failure receipt","OrderType__c":"601","AccountId":"'+techTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"2025-06-05T02:41:46.000Z","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false,"Duration":"4","DateOfReceipt__c":"2025-06-01","RecordTypeId":"'+dnsa.Id+'" };';

        
        DN_NewWorkOrderController.saveWorkOrder('true', woData1); 

    }

    @isTest
    static void testSaveWorkOrder(){   
        InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');


        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE Service_Territory__c  = :territory.Id LIMIT 1];
        
        Case techTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Failure receipt'
                                        AND FM_Country__c = 'DNS' LIMIT 1];
        Case traingngTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Post-delivery training' LIMIT 1];
        Case installTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Installation request' LIMIT 1];


        String woData1 = '{"CaseId":"'+techTicket.Id+'","AssetId":"'+techTicket.AssetId+'","TicketType__c":"Failure receipt","OrderType__c":"201","AccountId":"'+techTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"2025-06-05T02:41:46.000Z","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false,"Duration":"4","DateOfReceipt__c":"2025-06-01"};';
        String woData2 = '{"CaseId":"'+techTicket.Id+'","AssetId":"'+techTicket.AssetId+'","TicketType__c":"Failure receipt","OrderType__c":"217","AccountId":"'+techTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / ","IsDirectPaidService__c":false,"Duration":"4","DateOfReceipt__c":"2025-06-01"};';
        String woData3 = '{"CaseId":"'+techTicket.Id+'","AssetId":"'+techTicket.AssetId+'","TicketType__c":"Failure receipt","OrderType__c":"215","AccountId":"'+techTicket.AccountId+'","SPTask__c":"VM-G","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":true, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';
        String woData4 = '{"CaseId":"'+techTicket.Id+'","AssetId":"'+techTicket.AssetId+'","TicketType__c":"Failure receipt","OrderType__c":"204","AccountId":"'+techTicket.AccountId+'","SPTask__c":"VM-G","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":true, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';
        // String woData4 = '{"CaseId":"'+traingngTicket.Id+'","AssetId":"'+traingngTicket.AssetId+'","TicketType__c":"Post-delivery training","OrderType__c":"801","AccountId":"'+traingngTicket.AccountId+'","SPTask__c":"VM-G","isAlarmToStaff__c":true,"SoldTo__c":"'+traingngTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":true, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'"};';
        // String woData5 = '{"CaseId":"'+installTicket.Id+'","AssetId":"'+installTicket.AssetId+'","TicketType__c":"Post-delivery training","OrderType__c":"801","AccountId":"'+installTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';

        Test.startTest();        
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData1);  
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData2); 
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData3); 
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData4); 
        Test.stopTest();
    }

    @isTest
    static void testGetTicketInfo(){   
        InterfaceCommonUtil.setInterface('IF-CSPLUS-005', 'IF_ERP_WorkOrder');
        // InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');


        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE Service_Territory__c  = :territory.Id LIMIT 1];
        

        Case dnsaTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Failure receipt'
                                        AND FM_Country__c = 'DNSA' LIMIT 1];
        
        Case techTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Failure receipt'
                                        AND FM_Country__c = 'DNS' LIMIT 1];
        Case traingngTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Post-delivery training' LIMIT 1];
        Case installTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Installation request' LIMIT 1];


        // String woData1 = '{"CaseId":"'+techTicket.Id+'","AssetId":"'+techTicket.AssetId+'","TicketType__c":"Failure receipt","OrderType__c":"201","AccountId":"'+techTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"2025-06-05T02:41:46.000Z","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false,"Duration":"4","DateOfReceipt__c":"2025-06-01"};';
        // String woData2 = '{"CaseId":"'+installTicket.Id+'","AssetId":"'+installTicket.AssetId+'","TicketType__c":"Installation request","OrderType__c":"104","AccountId":"'+installTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';
        // String woData3 = '{"CaseId":"'+techTicket.Id+'","AssetId":"'+techTicket.AssetId+'","TicketType__c":"Failure receipt","OrderType__c":"215","AccountId":"'+techTicket.AccountId+'","SPTask__c":"VM-G","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":true, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';
        String woData4 = '{"CaseId":"'+traingngTicket.Id+'","AssetId":"'+traingngTicket.AssetId+'","TicketType__c":"Post-delivery training","OrderType__c":"801","AccountId":"'+traingngTicket.AccountId+'","SPTask__c":"VM-G","isAlarmToStaff__c":true,"SoldTo__c":"'+traingngTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":true, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'"};';
        // String woData5 = '{"CaseId":"'+installTicket.Id+'","AssetId":"'+installTicket.AssetId+'","TicketType__c":"Post-delivery training","OrderType__c":"801","AccountId":"'+installTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';

        Test.startTest();
        DN_NewWorkOrderController.getTicketInfo(dnsaTicket.Id);        
        DN_NewWorkOrderController.getTicketInfo(techTicket.Id);        
        DN_NewWorkOrderController.getTicketInfo(traingngTicket.Id);        
        DN_NewWorkOrderController.getTicketInfo(installTicket.Id);  
        
        
        // DN_NewWorkOrderController.saveWorkOrder('fasle', woData1);  
        // DN_NewWorkOrderController.saveWorkOrder('fasle', woData2); 
        // DN_NewWorkOrderController.saveWorkOrder('fasle', woData3); 
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData4); 
        // DN_NewWorkOrderController.saveWorkOrder('fasle', woData5); 
        Test.stopTest();
    }
    
    @isTest
    static void testInstallationWorkorder(){   
        InterfaceCommonUtil.setInterface('IF-CSPLUS-036', 'IF_ERP_InstAndComm');

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE Service_Territory__c  = :territory.Id LIMIT 1];
        

        Case orderTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE SalesOrder__c != null LIMIT 1];
        
        Case installTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Installation request' LIMIT 1];


        String woData1 = '{"CaseId":"'+orderTicket.Id+'","AssetId":"'+orderTicket.AssetId+'","TicketType__c":"Installation request","OrderType__c":"104","AccountId":"'+orderTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+orderTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';
        String woData2 = '{"CaseId":"'+installTicket.Id+'","AssetId":"'+installTicket.AssetId+'","TicketType__c":"Installation request","OrderType__c":"104","AccountId":"'+installTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+installTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';

        Test.startTest();        
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData1); 
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData2); 
        Test.stopTest();
    }
    
     @isTest
    static void testServiceCampaignWorkorder(){   
        InterfaceCommonUtil.setInterface('IF-CSPLUS-042', 'IF_ERP_WorkOrder');


        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE Service_Territory__c  = :territory.Id LIMIT 1];
        

        Case dnsaTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Failure receipt'
                                        AND FM_Country__c = 'DNSA' LIMIT 1];
        
        Case techTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Failure receipt'
                                        AND FM_Country__c = 'DNS' LIMIT 1];
        Case traingngTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Post-delivery training' LIMIT 1];
        Case installTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Installation request' LIMIT 1];


        String woData2 = '{"CaseId":"'+installTicket.Id+'","AssetId":"'+installTicket.AssetId+'","TicketType__c":"Service Campaign","OrderType__c":"106","AccountId":"'+installTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';

        Test.startTest();        
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData2); 
        Test.stopTest();
    }

    
    @isTest
    static void testSaveWorkOrderValidation(){   
        Account shipto = [SELECT Id FROM Account WHERE Name = 'ShipTo Company'];
        Asset equip = [SELECT Id FROM Asset WHERE AccountId = :shipto.Id];
        Case validation1 = [SELECT Id FROM Case WHERE AssetId = :equip.Id LIMIT 1];
        Case techTicket = [SELECT Id, AccountId, AssetId, Requester__c FROM Case WHERE 
                                        AccountId != null AND AssetId != null AND Requester__c != null AND 
                                        InternalTicketType__c = 'Failure receipt' LIMIT 1];


        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE Service_Territory__c  = :territory.Id LIMIT 1];
        String woData1 = '{"CaseId":"'+validation1.Id+'","AssetId":"'+equip.Id+'","TicketType__c":"Failure receipt","OrderType__c":"201","AccountId":"'+techTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"2025-06-05T02:41:46.000Z","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';
        String woData2 = '{"CaseId":"'+validation1.Id+'","AssetId":"'+equip.Id+'","TicketType__c":"Installation request","OrderType__c":"104","AccountId":"'+techTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"2025-06-05T02:41:46.000Z","EquipmentWarranty__c":"Y / Y","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';
        String woData3 = '{"CaseId":"'+validation1.Id+'","AssetId":"'+equip.Id+'","TicketType__c":"Failure receipt","OrderType__c":"217","AccountId":"'+techTicket.AccountId+'","SPTask__c":"","isAlarmToStaff__c":true,"SoldTo__c":"'+techTicket.AccountId+'","ScheduledDispatchTime__c":"'+System.now().addDays(2)+'","EquipmentWarranty__c":"N / ","IsDirectPaidService__c":false, "ServiceTerritoryId":"'+territory.Id+'","Worker__c":"'+sr.Id+'" };';


        Test.startTest();
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData1); 
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData2); 
        DN_NewWorkOrderController.saveWorkOrder('fasle', woData3); 
        Test.stopTest();
    }

}