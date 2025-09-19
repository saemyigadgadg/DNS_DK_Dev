/** 
 * @Class :  DN_CreateAnotherAgencyPurchase_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 24. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-24 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_CreateAnotherAgencyPurchase_TEST {
    static String partnerUserName ='partCAAP@test.test.com';
    static String partnerUserName2 ='part2CAAP@test.test.com';

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

        User adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('ITDept');
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
            List<Account> accList = new List<Account>();
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            dealer.DealerGrade__c = 'A';
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

            // DealerPurchaseOrder__Share share = new DealerPurchaseOrder__Share();
            // share.ParentId = recordId;  // 공유할 레코드 ID
            // share.UserOrGroupId = userId;  // 공유 대상 사용자 ID
            // share.AccessLevel = 'Read';  // 권한 수준: Read, Edit, All
            // share.RowCause = Schema.DealerPurchaseOrder__Share.RowCause.Manual;
            
            // insert share;

            update dealerCustomerList;
            insert dealerCustomerShareList;
        }

        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.id);
            insert shipTo;
        }
    }

    @isTest
    static void init_TEST() {
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();

            List<Account> accList = [SELECT Id FROM Account];
            System.debug('accList.size : '+accList.size());
        
            String currAccountId = currentUser.getAgencyId();
            List<DealerCustomer__c> dealers = [SELECT Id FROM DealerCustomer__c WHERE IsDealer__c = true AND SourceAccount__c != :currAccountId ];
            List<Product2> partList = [SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2];

            DealerPurchaseOrder__c po = TestDataFactoryForDealerPortal.getDealerPur(currAccountId, dealers[0].Id);
            insert po;
            
            new DN_CreateAnotherAgencyPurchase();
            new DN_CreateAnotherAgencyPurchase.OrderSummary();
            DN_CreateAnotherAgencyPurchase.OrderSummary orderWrapper = new DN_CreateAnotherAgencyPurchase.OrderSummary(po);
            System.debug(orderWrapper.orderId);
            System.debug(orderWrapper.customerOrderSeq);
            System.debug(orderWrapper.currencyCode);
            System.debug(orderWrapper.status);
            System.debug(orderWrapper.statusLabel);
            System.debug(orderWrapper.orderItemIdList);

            DealerPurchaseOrderItem__c poItem = TestDataFactoryForDealerPortal.getDealerPurItem(po.Id, partList[0].Id, partList[0].Id);
            poItem.Status__c = '0';
            insert poItem;

            DN_CreateAnotherAgencyPurchase.init(new List<String>{po.Id});

            List<DealerCustomer__c> customers = [ SELECT Id, Name FROM DealerCustomer__c WHERE IsDealer__c = false ];

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

            DealerOrder__c order = TestDataFactoryForDealerPortal.getOrder(currentUser.getAgencyId(), customers[0].id);
            insert order;
            List<DealerOrderItem__c> orderItemList = new List<DealerOrderItem__c>();
            DealerOrderItem__c orderItem = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[0].id, partList[0].id);
            orderItemList.add(orderItem);
            DealerOrderItem__c orderItem2 = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[1].id, partList[1].id);
            orderItemList.add(orderItem2);
            insert orderItemList;

            DN_CreateAnotherAgencyPurchase.init(new List<String>{orderItem.Id, orderItem2.Id});

            try {
                DN_CreateAnotherAgencyPurchase.init(new List<String>{partList[0].id});
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        

        Test.stopTest();
    }

    @isTest
    static void doSimulation_TEST() {
        Test.startTest();

        List<Account> accList = [SELECT Id, CustomerCode__c FROM Account ];
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        Map<String, String> partDealerMap = new Map<String, String>();
        for(Product2 part : partList) {
            partDealerMap.put(part.ProductCode, accList[1].CustomerCode__c);
        }

        DN_CreateAnotherAgencyPurchase.doSimulation(new List<String>(partDealerMap.keySet()), partDealerMap);
        Test.stopTest();
    }

    @isTest
    static void create_detail_request_TEST() {
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        
        String recordId;
        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();

            List<Account> accList = [SELECT Id FROM Account];
            System.debug('accList.size : '+accList.size());
        
            String currAccountId = currentUser.getAgencyId();
            List<DealerCustomer__c> dealers = [SELECT Id FROM DealerCustomer__c WHERE IsDealer__c = true AND SourceAccount__c != :currAccountId ];
            List<Product2> partList = [SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2];

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

            List<DN_CreateAnotherAgencyPurchase.Order> orderList = new List<DN_CreateAnotherAgencyPurchase.Order>();

            String jsonData = '[{"id":null,"orderType":"P","bulkShipping":"N","shippingType":"1","customerShipTo":null,"customerOrerNumber":"ETSET","itemList":[{"itemSeq":"000010","part":"","partName":"","replacingPart":"","replacingPartName":"","unit":"EA","salesUnit":1,"quantity":1,"customerPrice":205300,"discountRate":10,"discountPrice":184770,"discountAmount":184770,"currentStockQuantity":10,"dealer":"","dealerName":""}],"customer":""}]';

            orderList = (List<DN_CreateAnotherAgencyPurchase.Order>)JSON.deserialize(jsonData, List<DN_CreateAnotherAgencyPurchase.Order>.class);
            orderList[0].customer = dealers[0].Id;
            orderList[0].itemList[0].part = partList[0].Id;
            orderList[0].itemList[0].replacingPart = partList[0].Id;

            List<DealerPurchaseOrder__c> orderSObjectList = (List<DealerPurchaseOrder__c>)DN_CreateAnotherAgencyPurchase.createOrder(orderList).get('orderList');
            recordId = orderSObjectList[0].Id;

            DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'detail');

            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'APPROVAL').get('order');
            
            // // DN_CreateAnotherAgencyPurchase.getDealerPurchaseOrderList('');
            // DN_CreateAnotherAgencyPurchase.doApproval(orderWrapper);
            // DN_CreateAnotherAgencyPurchase.doDeleteRequest(orderWrapper.itemList);
            // DN_CreateAnotherAgencyPurchase.doApproval(orderWrapper);
            // DN_CreateAnotherAgencyPurchase.doUpdateRequest(orderWrapper.itemList);
            // DN_CreateAnotherAgencyPurchase.doApproval(orderWrapper);
        }

        User partPortalUser2 = [SELECT Id FROM User WHERE UserName = :partnerUserName2 LIMIT 1];
        System.runAs(partPortalUser2) {
            DN_CreateAnotherAgencyPurchase.getDealerPurchaseOrderList('');
            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'APPROVAL').get('order');
            DN_CreateAnotherAgencyPurchase.doApproval(orderWrapper);
        }

        //변경요청 - 승인
        System.runAs(partPortalUser) {
            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'detail').get('order');
            DN_CreateAnotherAgencyPurchase.doUpdateRequest(orderWrapper.itemList);
        }
        //승인
        System.runAs(partPortalUser2) {
            DN_CreateAnotherAgencyPurchase.getDealerPurchaseOrderList('');
            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'APPROVAL').get('order');
            DN_CreateAnotherAgencyPurchase.doApproval(orderWrapper);
        }
        //변경요청 - 거절
        System.runAs(partPortalUser) {
            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'detail').get('order');
            DN_CreateAnotherAgencyPurchase.doUpdateRequest(orderWrapper.itemList);
        }
        //거절
        System.runAs(partPortalUser2) {
            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'APPROVAL').get('order');
            DN_CreateAnotherAgencyPurchase.doReject(orderWrapper);
        }

        //삭제 - 승인
        System.runAs(partPortalUser) {
            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'detail').get('order');
            DN_CreateAnotherAgencyPurchase.doDeleteRequest(orderWrapper.itemList);
        }

        System.runAs(partPortalUser2) {
            DN_CreateAnotherAgencyPurchase.Order orderWrapper =(DN_CreateAnotherAgencyPurchase.Order)DN_CreateAnotherAgencyPurchase.detailInit(recordId, 'APPROVAL').get('order');
            DN_CreateAnotherAgencyPurchase.doApproval(orderWrapper);
        }

        Test.stopTest();
    }
}