/** 
 * @Class :  DN_DealerPOReviewBatch_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 04. 01. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-29 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_DealerPOReviewBatch_TEST {
    static String partnerUserName ='partPORB@test.test.com';
    static String partnerUserName2 ='part2PORB@test.test.com';

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
        String dealerId;
        String areaId;
        System.runAs(adminTestUser) {
            Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            insert ifObj;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifObj.Id);
            insert ifClass;

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
            dealerId = dealer.Id;
    
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
            areaId = area.Id;

            List<DealerAreaByMPPS__c> dealerMPPSList = new List<DealerAreaByMPPS__c>();
            DealerAreaByMPPS__c dealerMPPS = TestDataFactoryForDealerPortal.getDealerAreaByMPPS(dealer.Id , area.Id);
            dealerMPPSList.add(dealerMPPS);
            insert dealerMPPSList;

            RegionAreaByMPPS__c region = TestDataFactoryForDealerPortal.getRegionAreaByMPPS(area.Id);
            insert region;

            ZipRegionAreaByMPPS__c zipRegionArea = TestDataFactoryForDealerPortal.getZipRegionAreaByMPPS('01', region.Id);
            insert zipRegionArea;

            ABCCriteriaPeriod__c period = TestDataFactoryForDealerPortal.createCalculatePeriod();
            insert period;
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
            String customerCode = currentUser.getAgencyCustomerCode();
            List<DealerCustomer__c> dealers = [SELECT Id, CustomerCode__c FROM DealerCustomer__c WHERE IsDealer__c = true AND SourceAccount__c != :accountId ];

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

            List<DealerPurchaseOrder__c> poList = new List<DealerPurchaseOrder__c>();
            DealerPurchaseOrder__c po = TestDataFactoryForDealerPortal.getDealerPur(accountId, dealers[0].Id);
            poList.add(po);
            insert poList;

            List<DealerPurchaseOrderItem__c> poItemList = new List<DealerPurchaseOrderItem__c>();
            DealerPurchaseOrderItem__c poItem = TestDataFactoryForDealerPortal.getDealerPurItem(po.Id, partList[0].Id, partList[0].Id);
            poItemList.add(poItem);

            insert poItem;

            List<PurchaseOrder__c> dnsPoList = new List<PurchaseOrder__c>();
            PurchaseOrder__c dnsPo = TestDataFactoryForDealerPortal.getPurOrder(accountId);
            dnsPoList.add(dnsPo);
            insert dnsPoList;

            List<PurchaseOrderItems__c> dnsPoItemList = new List<PurchaseOrderItems__c>();
            PurchaseOrderItems__c dnsPoItem = TestDataFactoryForDealerPortal.getPurOrderItem(dnsPo.Id,  partList[0].Id);
            dnsPoItemList.add(dnsPoItem);
            insert dnsPoItemList;

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
            
            DealerPartMasterByMPPS__c partMasterMpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(partList[0].Id, currentUser.getAgencyId());
            partMasterMpps.ABCIndicator__c = 'A';
            partMasterMpps.ExternalKey__c = partList[0].ProductCode + '_' + customerCode;
            insert partMasterMpps;

            DealerPartMasterByMPPS__c partMasterMpps2 = TestDataFactoryForDealerPortal.getPartMasterByMpps(partList[1].Id, currentUser.getAgencyId());
            partMasterMpps2.ABCIndicator__c = 'A';
            partMasterMpps2.MRPType__c = 'ND';
            partMasterMpps2.ExternalKey__c = partList[1].ProductCode + '_' + customerCode;
            insert partMasterMpps2;

            List<DealerInventoryMovements__c> grList = new List<DealerInventoryMovements__c>();
            DealerInventoryMovements__c gr = TestDataFactoryForDealerPortal.getGoodsReceipt(currentUser.getAgencyId(), partList[0].Id);
            gr.DealerPurchaseOrderItem__c = poItem.Id;
            grList.add(gr);

            DealerInventoryMovements__c gr2 = TestDataFactoryForDealerPortal.getGoodsReceipt(currentUser.getAgencyId(), partList[0].Id);
            gr2.PurchaseOrderItem__c = dnsPoItem.Id;
            grList.add(gr2);

            //취소
            DealerInventoryMovements__c gr3 = TestDataFactoryForDealerPortal.getGoodsReceipt(currentUser.getAgencyId(), partList[0].Id);
            gr3.PurchaseOrderItem__c = dnsPoItem.Id;
            gr3.InventoryChange__c = 'H';
            grList.add(gr3);
            insert grList;
        }

    }

    @isTest
    static void execute_TEST() {
        Test.startTest();
        Database.executeBatch(new DN_DealerPOReviewBatch('1846'));
        Test.stopTest();
    }

    @isTest
    static void schedule_TEST() {
        Test.startTest();
        DN_DealerPOReviewBatch poScheduler = new DN_DealerPOReviewBatch('1846');
        String cronExp = '0 0 10,15 * * ?';
        String jobID = System.schedule('3-Hour Interval TEST Batch', cronExp, poScheduler);

        Test.stopTest();
    }

    @isTest
    static void chaining_TEST() {
        Test.startTest();

        DN_DealerPOReviewBatch poBatch = new DN_DealerPOReviewBatch('1846', new List<String>{'1', '2', '3', '4'});
        Database.executeBatch(poBatch);

        Test.stopTest();
    }
}