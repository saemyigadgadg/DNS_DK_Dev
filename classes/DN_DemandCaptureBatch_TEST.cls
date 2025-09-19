/** 
 * @Class :  DN_DemandCaptureBatch_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 26. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-26 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_DemandCaptureBatch_TEST {
    static String partnerUserName ='partDCB@test.test.com';
    static String partnerUserName2 ='part2DCB@test.test.com';

    @TestSetup
    static void makeData(){
        List<User> userList = new List<User>();
        User adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesOffice__c = '1146';
        // adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        User adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesOffice__c = '1146';
        // adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);

        insert userList;

        Contact con;
        Contact con2;
        System.runAs(adminTestUser) {
            List<Interface__c> ifObjList = new List<Interface__c>();
            Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-CSPLUS-007', 'Real-Time');
            ifObjList.add(ifObj);
            Interface__c ifObj2 = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-003', 'Real-Time');
            ifObjList.add(ifObj2);
            Interface__c ifObj3 = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-004', 'Real-Time');
            ifObjList.add(ifObj3);
            Interface__c ifObj4 = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-005', 'Real-Time');
            ifObjList.add(ifObj4);
            insert ifObjList;

            List<InterfaceClasses__c> ifClassList = new List<InterfaceClasses__c>();
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Material', ifObj.Id);
            ifClassList.add(ifClass);
            InterfaceClasses__c ifClass2 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj2.Id);
            ifClassList.add(ifClass2);
            InterfaceClasses__c ifClass3 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj3.Id);
            ifClassList.add(ifClass3);
            InterfaceClasses__c ifClass4 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj4.Id);
            ifClassList.add(ifClass4);
            insert ifClassList;

            

            List<Account> accList = new List<Account>();
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            dealer.DealerGrade__c = 'A';
            dealer.ShippingPostalCode = '01';
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            accList.add(dealer);

            Account dealer2 = TestDataFactoryForDealerPortal.dealer2;
            dealer2.CustomerCode__c = '1233';
            dealer2.DealerGrade__c = 'B';
            accList.add(dealer2);

            Account dealer3 = TestDataFactoryForDealerPortal.createAccountDelear('Test3');
            dealer3.CustomerCode__c = '1234';
            dealer3.DealerGrade__c = 'C';
            accList.add(dealer3);
            insert accList;
    
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;

            con2 = TestDataFactoryForDealerPortal.createContact(dealer2.Id);
            insert con2;
    
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerCustomer_Customer', 'DealerCustomer__c', 'Customer', 'C5{000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerOrder_General', 'DealerOrder__c', 'General', 'C8{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerOrder_Emergency', 'DealerOrder__c', 'Emergency', 'C9{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerPurchaseOrder', 'DealerPurchaseOrder__c', 'DealerPO', 'C4{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GI','DealerInventoryMovements__c','GoodsIssue','C6{000000000}'));
            insert sequenceList;

            List<DealerCustomer__c> dealerList = new List<DealerCustomer__c>();
            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            dealerCustomer.IsDealer__c = true;
            dealerList.add(dealerCustomer);
            DealerCustomer__c dealerCustomer2 = TestDataFactoryForDealerPortal.getCustomer(dealer2.Id);
            dealerCustomer2.IsDealer__c = true;
            dealerList.add(dealerCustomer2);
            DealerCustomer__c dealerCustomer3 = TestDataFactoryForDealerPortal.getCustomer(dealer3.Id);
            dealerCustomer3.IsDealer__c = true;
            dealerList.add(dealerCustomer3);
            insert dealerList;
    
            List<Product2> partList = new List<Product2>();
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18181', 'R18181영문', 'R18181국문')
            );
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18182', 'R18182영문', 'R18182국문')
            );
            insert partList;
        
            List<ProductByPlant__c> plantByProductList = new List<ProductByPlant__c>();
            plantByProductList.add(TestDataFactoryForDealerPortal.getProductByPlant(partList[0].Id,partList[1].Id));
            plantByProductList.add(TestDataFactoryForDealerPortal.getProductByPlant(partList[1].Id,partList[1].Id));
            insert plantByProductList;

            AreaByMPPS__c area = TestDataFactoryForDealerPortal.getAreaByMpps();
            insert area;

            List<DealerAreaByMPPS__c> dealerMPPSList = new List<DealerAreaByMPPS__c>();
            DealerAreaByMPPS__c dealerMPPS = TestDataFactoryForDealerPortal.getDealerAreaByMPPS(dealer.Id , area.Id);
            dealerMPPSList.add(dealerMPPS);
            insert dealerMPPSList;

            RegionAreaByMPPS__c region = TestDataFactoryForDealerPortal.getRegionAreaByMPPS(area.Id);
            insert region;

            ZipRegionAreaByMPPS__c zipRegionArea = TestDataFactoryForDealerPortal.getZipRegionAreaByMPPS('01', region.Id);
            insert zipRegionArea;
            
        }
    
        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;

        User partnerTestUser2 = TestDataFactoryForDealerPortal.createTestPartPortalUser(con2.Id);
        partnerTestUser2.SalesOrganization__c = '1846';
        partnerTestUser2.DistributionChannel__c = '10';
        partnerTestUser2.Division__c = '40';
        partnerTestUser2.Username = partnerUserName2;
        insert partnerTestUser2;

        System.runAs(adminTestUser) {
        
            List<DealerCustomer__c> dealerCustomerList =  [SELECT Id, OwnerId FROM DealerCustomer__c];
            List<DealerCustomer__Share> dealerCustomerShareList = new List<DealerCustomer__Share>();
            for(DealerCustomer__c dealderCustomer : dealerCustomerList) {
                dealderCustomer.OwnerId = partnerTestUser.Id;
                dealerCustomerShareList.add(new DealerCustomer__Share(
                    ParentId = dealderCustomer.Id,
                    UserOrGroupId = partnerTestUser2.Id,
                    AccessLevel = 'Read'
                ));
            }

            update dealerCustomerList;
            insert dealerCustomerShareList;
        }

        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];
        String accountId;
        WorkOrder serviceOrder;
        ServiceTerritory workCenter;
        Set<String> recordIdSet = new Set<String>();
        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.id);
            insert shipTo;

            TestDataFactoryForDealerPortal.assignFLSPermissionSet(partnerTestUser.Id);
            DN_UserDetails currentUser = new DN_UserDetails();
            accountId = currentUser.getAgencyId();

            List<DealerStock__c> stockList = new List<DealerStock__c>();
            DealerStock__c stock = TestDataFactoryForDealerPortal.createDealerStock(currentUser.getAgencyId(), partList[1].id);
            stock.ExternalKey__c = currentUser.getSalesOranization()+'-'+currentUser.getDistributionChannel()+'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+partList[1].ProductCode;
            System.debug('stock ExternalKey : '+stock.ExternalKey__c);
            stockList.add(stock);
            DealerStock__c stock2 = TestDataFactoryForDealerPortal.createDealerStock(currentUser.getAgencyId(), partList[0].id);
            stock2.ExternalKey__c = currentUser.getSalesOranization()+'-'+currentUser.getDistributionChannel()+'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+partList[0].ProductCode;
            System.debug('stock2 ExternalKey : '+stock2.ExternalKey__c);
            stockList.add(stock2);
            upsert stockList ExternalKey__c;

            //ServiceOrder
            Asset equipment = TestDataFactoryForDealerPortal.createEquipment(accountId);
            insert equipment;
            recordIdSet.add(equipment.Id);
            Case ticket = TestDataFactoryForDealerPortal.createCase(equipment.Id);
            insert ticket;
            recordIdSet.add(ticket.Id);
            OperatingHours workTime = TestDataFactoryForDealerPortal.createOperatingHours();
            insert workTime;
            recordIdSet.add(workTime.Id);
            workCenter = TestDataFactoryForDealerPortal.createWorkCenter(accountId, workTime.Id);
            workCenter.Classify__c = 'W/C';
            insert workCenter;
            recordIdSet.add(workCenter.Id);
            ServiceResource worker = TestDataFactoryForDealerPortal.createServiceWorker(partnerTestUser.Id, workCenter.Id);
            insert worker;
            recordIdSet.add(worker.Id);

            serviceOrder = TestDataFactoryForDealerPortal.createServiceOrder(ticket.Id, equipment.Id, accountId, workCenter.Id, worker.Id);
            serviceOrder.ServiceOrderNumber__c = '403906564';
            insert serviceOrder;
            recordIdSet.add(serviceOrder.Id);

            //DealerOrder
            DealerOrder__c order = TestDataFactoryForDealerPortal.getOrder(currentUser.getAgencyId(), customer.id);
            order.Address__PostalCode__s = '01';
            insert order;
            List<DealerOrderItem__c> orderItemList = new List<DealerOrderItem__c>();
            DealerOrderItem__c orderItem = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[0].id, partList[0].id);
            orderItemList.add(orderItem);
            DealerOrderItem__c orderItem2 = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[1].id, partList[1].id);
            orderItemList.add(orderItem2);
            insert orderItemList;
        }

        System.runAs(adminTestUser) {
            ProductRequest partClaim = TestDataFactoryForDealerPortal.createPartClaim(serviceOrder.Id, partList[0].Id);
            partClaim.OwnerId = partnerTestUser.Id;
            partClaim.ShipTo__c = workCenter.Id;
            insert partClaim;

            DealerFreeDispatch__c freeClaim = TestDataFactoryForDealerPortal.createFreeClaim(partClaim.Id, accountId);
            freeClaim.Status__c = '2';
            freeClaim.ShippingType__c = '1';
            freeClaim.OwnerId = partnerTestUser.Id;
            freeClaim.IsDemandCapture__c = true;
            insert freeClaim;
            recordIdSet.add(freeClaim.Id);
        }
    }

    @isTest
    static void orderCapture_TEST () {
        Test.startTest();
        Database.executeBatch(new DN_DemandCaptureBatch());
        Test.stopTest();
    }

    @isTest
    static void orderCapture_Manual_TEST () {
        Test.startTest();
        Database.executeBatch(new DN_DemandCaptureBatch(DN_DemandCaptureBatch.OrderType.DEALERORDER, '1846', Date.today(), Date.today()));
        Test.stopTest();
    }

    @isTest
    static void serviceOrderCapture_TEST () {
        Test.startTest();
        Database.executeBatch(new DN_DemandCaptureBatch(DN_DemandCaptureBatch.OrderType.DEALERFREEDISPATCH));
        Test.stopTest();
    }

    @isTest
    static void serviceOrderCapture_Manual_TEST () {
        Test.startTest();
        Date today = Date.today();
        Date yesterDay = today.addDays(-1);
        Database.executeBatch(new DN_DemandCaptureBatch(DN_DemandCaptureBatch.OrderType.DEALERFREEDISPATCH, '1846', yesterDay, yesterDay));
        Test.stopTest();
    }

    @isTest
    static void schedule_TEST () {
        Test.startTest();

        DN_DemandCaptureBatch captureScheduler = new DN_DemandCaptureBatch();
        String cronExp = '0 0 2 * * ?';
        String jobID = System.schedule('MPPS DemandCapture TEST', cronExp, captureScheduler);

        Test.stopTest();
    }
}