/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 2025-05-30
 * @last modified by  : yeongju.yun
**/
@isTest
public with sharing class DN_OrderServiceTest {

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        User qmUser;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            kaUser.LanguageLocaleKey = 'en_US';
            insert kaUser;

            qmUser = TestDataFactoryForSales.createDNSUser('품질 QM', 'QualityTeam');
            insert qmUser;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Asset asset = TestDataFactoryForSales.createAsset();
        insert asset;

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        // testService02
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderKeyAccountCreated'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderStatusConfirmed'));
        alertList.add(TestDataFactoryForSales.createAlertManager('CommodityOrderApprovalRequest'));

        // testService03
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderCanceled'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalApproved'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalRejected'));

        // testService05
        alertList.add(TestDataFactoryForSales.createAlertManager('InspectionCreation'));
        alertList.add(TestDataFactoryForSales.createAlertManager('InspectionConfirmed'));
        alertList.add(TestDataFactoryForSales.createAlertManager('PreparationChecklistEdited'));
        
        // testService06
        
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderConfirmed'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveyOrderERPSent'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderERPFail'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderRequestApproval'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderInternalApproved'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderInternalRejected'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderChangeRequest'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderRequestConfirm'));
        
        insert alertList;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            Triggerhandler.bypass('QuoteLineItemTriggerHandler'); 
            insert qItem;

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.Status = 'Confirmed';
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order.Id);
            insert payment;

            PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
            insert paymentItem;

            Inspection__c inspection = TestDataFactoryForSales.createInspection(order.Id, qmUser.Id);
            insert inspection;

            DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
            insert dOrder;

            // DNSA
            Quote quoteDNSA = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            insert quoteDNSA;

            QuoteLineItem qItemDNSA = TestDataFactoryForSales.createQuoteItem(quoteDNSA, entry, oItem, prod);
            qItemDNSA.ERPQuotationNo__c = '0701069991';
            insert qItemDNSA;

            Order orderDNSA = TestDataFactoryForSales.createDNSAOrder(acc, opty, quoteDNSA, dealer);
            orderDNSA.DNSA_SalesOffice__c = '414A';
            orderDNSA.ServiceReimbursement__c = 'N';
            insert orderDNSA;

            OrderItem oItemProdDNSA = TestDataFactoryForSales.createOrderProduct(orderDNSA.Id, prod.Id, entry.Id, qItemDNSA.Id, '000010');
            insert oItemProdDNSA;
        }
    }

    @IsTest
    static void testService01(){
        Order order = [SELECT Id, CurrencyIsoCode, QuoteId, OwnerId FROM Order LIMIT 1];
        Quote quote = [SELECT Id, CurrencyIsoCode FROM Quote LIMIT 1];

        Test.startTest();
        DN_OrderService ordSvc = new DN_OrderService();
        Id userId = UserInfo.getUserId();
        Set<Id> userIds = new Set<Id>{userId};
        String userType = UserInfo.getUserType();

        List<DN_OrderService.ChannerWrapper> wrapList = new List<DN_OrderService.ChannerWrapper>();
        DN_OrderService.ChannerWrapper wrap = new DN_OrderService.ChannerWrapper(order.OwnerId, false);
        wrapList.add(wrap);

        ordSvc.setSalesChannel(wrapList);
        ordSvc.setSalesChannel(wrap);

        ordSvc.getUserFlag(userIds);
        ordSvc.getUserFlag(userType);

        ordSvc.isManager(userId);
        ordSvc.isManager(userIds);

        ordSvc.getBaseUrl();
        ordSvc.getBaseUrl(true);
        ordSvc.getBaseUrl(false);

        ordSvc.getAdminFlag();
        ordSvc.getAlertManagerId('OrderStatusConfirmed');

        Test.stopTest();
    }

    @IsTest
    static void testService02(){

        Order order = [SELECT Id, OrderNumber, Status, ERPOrderNo__c, CurrencyIsoCode, QuoteId, OwnerId, AccountId, Account.Name, CancelReason__c FROM Order LIMIT 1];
        Quote quote = [SELECT Id, CurrencyIsoCode FROM Quote LIMIT 1];
        User kaUser = [SELECT Id FROM User WHERE Profile.Name = '영업 KA' LIMIT 1];
        
        Test.startTest();
        
        DN_OrderService ordSvc = new DN_OrderService();

        List<Order> target = new List<Order>{order};
        Set<Id> targetUser  = new Set<Id>{order.OwnerId, kaUser.Id};

        Map<Id, String> accNameMap = new Map<Id, String>{order.AccountId => order.Account.Name};
        Map<Id, String> userNameMap = ordSvc.getUserNameMap(targetUser);
        Map<String, String> statusMap = ordSvc.getPicklistMap('Order', 'Status');
        Map<String, String> reasonMap = ordSvc.getPicklistMap('Order', 'CancelReason__c');
        Map<Id, String> commentsMap = new Map<Id, String>{order.Id => 'test'};

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        targetUserMap.put(order.Id, new Set<Id>{order.OwnerId, kaUser.Id});
        // OrderKeyAccountCreated
        ordSvc.sendAlert('OrderKeyAccountCreated', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'accNameMap' => accNameMap
            }
        );

        ordSvc.sendAlert('OrderKeyAccountCreated', 'email', target, targetUserMap
            , new Map<String, Object>{
                'accNameMap' => accNameMap
            }
        );

        // OrderStatusConfirmed
        ordSvc.sendAlert('OrderStatusConfirmed', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'statusMap' => statusMap
            }
        );

        ordSvc.sendAlert('OrderStatusConfirmed', 'email', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'statusMap' => statusMap
            }
        );
        
        Test.stopTest();
        
    }

    @IsTest
    static void testService03(){

        Order order = [SELECT Id, OrderNumber, Status, ERPOrderNo__c, CurrencyIsoCode, QuoteId, OwnerId, AccountId, Account.Name, CancelReason__c FROM Order LIMIT 1];
        Quote quote = [SELECT Id, CurrencyIsoCode FROM Quote LIMIT 1];
        User kaUser = [SELECT Id FROM User WHERE Profile.Name = '영업 KA' LIMIT 1];
        
        Test.startTest();
        
        DN_OrderService ordSvc = new DN_OrderService();

        List<Order> target = new List<Order>{order};
        Set<Id> targetUser  = new Set<Id>{order.OwnerId, kaUser.Id};

        Map<Id, String> accNameMap = new Map<Id, String>{order.AccountId => order.Account.Name};
        Map<Id, String> userNameMap = ordSvc.getUserNameMap(targetUser);
        Map<String, String> statusMap = ordSvc.getPicklistMap('Order', 'Status');
        Map<String, String> reasonMap = ordSvc.getPicklistMap('Order', 'CancelReason__c');
        Map<Id, String> commentsMap = new Map<Id, String>{order.Id => 'test'};

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        targetUserMap.put(order.Id, targetUser);

        // OrderCanceled
        ordSvc.sendAlert('OrderCanceled', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'reasonMap' => reasonMap
            }
        );

        ordSvc.sendAlert('OrderCanceled', 'email', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'reasonMap' => reasonMap
            }
        );

        // OrderInternalApproved
        ordSvc.sendAlert('OrderInternalApproved', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'nameMap' => commentsMap
            }
        );

        ordSvc.sendAlert('OrderInternalApproved', 'email', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'nameMap' => commentsMap
            }
        );

        // OrderInternalRejected
        ordSvc.sendAlert('OrderInternalRejected', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'nameMap' => commentsMap
            }
        );

        ordSvc.sendAlert('OrderInternalRejected', 'email', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'nameMap' => commentsMap
            }
        );
        
        Test.stopTest();
        
    }

    @IsTest
    static void testService04(){
        Test.startTest();
        
        DN_OrderService ordSvc = new DN_OrderService();

        Id userId = UserInfo.getUserId();
        Set<Id> userIds = new Set<Id>{userId};

        ordSvc.getPicklist('Order', 'Status');
        ordSvc.getPicklistMap('Order', 'Status');
        ordSvc.getPicklistWrap('Order', 'Status');
        ordSvc.getPicklistLabel('Order', 'Status', 'Created');

        ordSvc.getFieldInfo(
            'DeliveryOrder__c'
            , new List<String>{
                'DestinationZone__c'
                , 'Shipping__c'
                , 'PlannedGI__c'
                , 'CapitalNo__c'
                , 'ActualGIDate__c'
                , 'Note__c'
            }
            , new List<String>()
        );

        ordSvc.getRelatedAccounts(userIds);
        ordSvc.getUserNameMap(userIds);
        ordSvc.formatCodeForSAP(10, '1124140');
        ordSvc.formatCodeForSAP('0001124140');
        ordSvc.formatDateForSAP(Date.today(), true);
        ordSvc.formatDateForSAP(Date.today(), false);
        ordSvc.formatDateTimeForSAP(DateTime.now(), true);
        ordSvc.formatDateTimeForSAP(DateTime.now(), false);
        
        Test.stopTest();
    }

    @IsTest
    static void testService05(){

        Inspection__c inspection = [
            SELECT  Id, OwnerId, Order__c, Order__r.OrderNumber, Order__r.Owner.Name 
                    , FM_CompanyName__c, Name, Start_Date_of_Visit__c, End_Date_of_Visit__c
            FROM    Inspection__c 
            LIMIT 1
        ];
        
        Test.startTest();
        
        DN_OrderService ordSvc = new DN_OrderService();

        List<Inspection__c> target = new List<Inspection__c>{inspection};
        Set<Id> targetUser  = new Set<Id>{inspection.OwnerId};

        Map<Id, String> ordNameMap = new Map<Id, String>{inspection.Order__c => inspection.Order__r.OrderNumber};
        Map<Id, String> userNameMap = new Map<Id, String>{inspection.Order__c => inspection.Order__r.Owner.Name};

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        targetUserMap.put(inspection.Id, new Set<Id>{inspection.OwnerId});

        // InspectionCreation
        ordSvc.sendAlert('InspectionCreation', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'ordNameMap' => ordNameMap
            }
        );

        ordSvc.sendAlert('InspectionCreation', 'email', target, targetUserMap
            , new Map<String, Object>{
                'ordNameMap' => ordNameMap
            }
        );

        // InspectionConfirmed
        ordSvc.sendAlert('InspectionConfirmed', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => ordNameMap
                , 'ordNameMap' => userNameMap
            }
        );

        ordSvc.sendAlert('InspectionConfirmed', 'email', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => ordNameMap
                , 'ordNameMap' => userNameMap
            }
        );

        Test.stopTest();
        
    }

    @IsTest
    static void testService06(){
        Test.startTest();

        DN_OrderService ordSvc = new DN_OrderService();

        // PreparationChecklistEdited
        TriggerHandler.bypassedHandlers =  new Set<String>{'TicketTriggerHandler', 'PreparationCheckListTriggerHandler'};
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Order order = [SELECT Id, OwnerId FROM Order LIMIT 1];

        PreparationCheckList__c preparation = TestDataFactoryForSales.createPreparation(order.Id, acc.Id, con.Id, UserInfo.getUserId());
        insert preparation;

        Case c = new Case();
        c.AccountId = acc.Id;
        c.ContactId = con.Id;
        c.InternalRequester__c = order.OwnerId;
        c.Requester__c = con.Id;
        c.AssetId = asset.Id;
        c.Status = ordSvc.TICKET_NEW; // 신규일 때 'New', 반려일 때 수정 시 'New'
        c.ReceptionPath__c = ordSvc.TICKET_PORTAL;
        c.RepairRequestDateTime__c = Date.today();
        c.isAlarmToCustomer__c = false;
        c.ReceptionDetails__c = System.Label.DNS_M_RequestTicket;
        c.PreparationCheckList__c = preparation.Id;
        insert c;

        Map<Id, String> userNameMap = new Map<Id, String>{UserInfo.getUserId() => UserInfo.getName()};
        Map<Id, String> preNameMap  = new Map<Id, String>{preparation.Id => preparation.Name};

        List<Case> target = new List<Case>{c};
        Set<Id> targetUser  = new Set<Id>{c.OwnerId};

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        targetUserMap.put(c.Id, targetUser);

        ordSvc.sendAlert('PreparationChecklistEdited', 'bell', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'preNameMap' => preNameMap
            }
        );

        ordSvc.sendAlert('PreparationChecklistEdited', 'email', target, targetUserMap
            , new Map<String, Object>{
                'userNameMap' => userNameMap
                , 'preNameMap' => preNameMap
            }
        );

        Test.stopTest();
    }

    @IsTest
    static void testService07(){
        Order order = [
            SELECT  Id, OrderNumber, Status, ERPOrderNo__c, EffectiveDate, CurrencyIsoCode
                    , QuoteId, OwnerId, Owner__c, AccountId, Account.Name, CancelReason__c 
            FROM Order 
            WHERE DNSA_SalesOffice__c = '414A'
            LIMIT 1
        ];
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();

        Approval.ProcessResult requestedResult;
        System.runAs(dealer) {
            requestedResult = TestDataFactoryForSales.runApproval(order.Id, dealer.Id);
        }

        DN_OrderService.sendApprovalNotificationAsync(new Set<Id>{order.Id});
        // Approval.ProcessResult rejectedResult = TestDataFactoryForSales.actionApproval(requestedResult, 'Reject');

        // Approval.ProcessResult requestedResult2;
        // System.runAs(dealer) {
        //     requestedResult2 = TestDataFactoryForSales.runApproval(order.Id, dealer.Id);
        // }
        // Approval.ProcessResult approvedResult = TestDataFactoryForSales.actionApproval(requestedResult2, 'Approve');

        Test.stopTest();
    }
}