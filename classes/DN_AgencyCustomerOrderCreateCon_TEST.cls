/** 
 * @Class :  DN_AgencyCustomerOrderCreateCon_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 21. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-21 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_AgencyCustomerOrderCreateCon_TEST {
    static String partnerUserName ='partACOCC@test.test.com';
    static String partnerUserName2 ='part2ACOCC@test.test.com';

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
        System.runAs(adminTestUser) {
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            insert dealer;
    
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;
    
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            Sequence__c seq0 = new Sequence__c(
                Name ='DealerCustomer_Dealer',
                Type__c = 'Dealer', 
                Pattern__c = 'C1{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq0);

            Sequence__c seq1 = new Sequence__c(
                Name ='DealerCustomer_Customer',
                Type__c = 'Customer', 
                Pattern__c = 'C5{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq1);

            Sequence__c seq2 = new Sequence__c(
                Name ='DealerOrder_General',
                Type__c = 'General', 
                Pattern__c = 'C8{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq2);

            Sequence__c seq3 = new Sequence__c(
                Name ='DealerOrder_Emergency',
                Type__c = 'Emergency', 
                Pattern__c = 'C9{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq3);
            insert sequenceList;

            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            insert dealerCustomer;
    
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
            
            List<DealerCustomer__c> customers = [ SELECT Id, Name FROM DealerCustomer__c WHERE IsDealer__c = false ];

            List<Product2> partList = [ SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2 WHERE ProductCode = 'R18181'];

            DN_DealerPortalQuoteCreateController.Quote quote = new DN_DealerPortalQuoteCreateController.Quote();
            quote.salesOrganization = currentUser.getSalesOranization();
            quote.distributionChannel = currentUser.getDistributionChannel();
            quote.division    = currentUser.getDivision();
            quote.dealer      = currentUser.getAgencyId();
            quote.dealerName  = currentUser.getAgencyName();
            quote.customer    = customers[0].id;
            quote.customerName = customers[0].Name;
            quote.machineName = '기종';
            quote.equipment   = '장비번호';
            quote.description = '견적서 설명';
            quote.address     = ''; 
            quote.phone       = '';
            quote.fax         = '';
            quote.postalCode  = '';

            DN_DealerPortalQuoteCreateController.QuoteItem quoteItem = new DN_DealerPortalQuoteCreateController.QuoteItem();
            quoteItem.part          = partList[0].id;      
            quoteItem.partName      = partList[0].ProductCode;            
            quoteItem.partDetails   = partList[0].FM_MaterialDetails__c;      
            quoteItem.replacingPart = partList[0].id;      
            quoteItem.replacingPartName  = partList[0].ProductCode;
            quoteItem.replacingPartDetails = partList[0].FM_MaterialDetails__c;
            quoteItem.unit = '';
            quoteItem.quantity = 1;    
            quoteItem.customerPrice = 1000; 
            quoteItem.discountRate = 10.0;  
            quoteItem.discountPrice = quoteItem.customerPrice * (1 - quoteItem.discountRate/ 100);
            quoteItem.discountAmount = quoteItem.quantity * quoteItem.discountPrice;
            quote.itemList.add(quoteItem);
            
            Map<String,Object> saveResult = DN_DealerPortalQuoteCreateController.doSave(quote);
            //견적서 기반
            DN_AgencyCustomerOrderCreateController.init((String)saveResult.get('quoteId'));

            DealerOrder__c order = TestDataFactoryForDealerPortal.getOrder(currentUser.getAgencyId(), customers[0].id);
            insert order;

            DealerOrderItem__c orderItem = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[0].id, partList[0].id);
            insert orderItem;

            DN_AgencyCustomerOrderCreateController.init(order.id);

            //Flow 삭제.
            DN_AgencyCustomerOrderCreateController.deleteOrder(new List<String>{order.id});

            try {
                DN_AgencyCustomerOrderCreateController.init(partList[0].id);
            } catch (Exception e) {
                System.debug('e : '+e.getMessage());
            }
        }

        Test.stopTest();
    }

    @isTest 
    static void doSimulation_TEST() {
        test.startTest();
        List<String> partCodeList = new List<String> {
            'R18181'
        };
        DN_AgencyCustomerOrderCreateController.doSimulation(partCodeList);
        test.stopTest();
    }

    @isTest
    static void createOrder_Detail_Update_Delete_TEST() {
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            List<DealerCustomer__c> customers = [ SELECT Id, Name FROM DealerCustomer__c WHERE IsDealer__c = false ];
            List<DealerCustomerShipTo__c> shipTos = [ SELECT Id FROM DealerCustomerShipTo__c ];
            List<Product2> partList = [ SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2 WHERE ProductCode = 'R18181'];

            DN_AgencyCustomerOrderCreateController.Order order = new DN_AgencyCustomerOrderCreateController.Order();   
            order.customerOrerNumber = '직접입력주문번호';
            order.orderType = 'E';
            order.customer = customers[0].id;
            order.customerShipTo = shipTos[0].id;
            order.postalCode = '11120';
            order.city = '도로명주소';
            order.street = '상세주소';
            order.phone = '01012332543';
            order.representative = '박대표';
            order.shippingCompany = '대한통운';
            order.invoice = 'invoice';
            order.memo = '특이사항memo';

            DN_AgencyCustomerOrderCreateController.OrderItem orderItem = new DN_AgencyCustomerOrderCreateController.OrderItem();
            orderItem.itemSeq = '00010';
            orderItem.part = partList[0].id;
            orderItem.partName = partList[0].ProductCode;
            orderItem.partDetails = partList[0].FM_MaterialDetails__c;
            orderItem.replacingPart = partList[0].id;
            orderItem.replacingPartName = partList[0].ProductCode;
            orderItem.replacingPartDetails = partList[0].FM_MaterialDetails__c;
            orderItem.quantity = 1;
            orderItem.unit = 'EA';
            orderItem.salesUnit = 1;
            orderItem.avaiableQuantity = 2;
            orderItem.reservedQuantity = 0;
            orderItem.giQuantity = 0;
            orderItem.currentStockQuantity = 2;
            orderItem.currencyCode = 'KRW';
            orderItem.customerPrice = 1000;
            orderItem.discountRate = 0.1;
            orderItem.discountPrice = orderItem.customerPrice * (1 - orderItem.discountRate);
            orderItem.discountAmount = orderItem.discountPrice * orderItem.quantity;
            orderItem.machineName = 'DNM4555';
            orderItem.equipment = 'DNM4555장비번호';
            order.itemList.add(orderItem);

            Map<String,Object> createResult = DN_AgencyCustomerOrderCreateController.createOrder(order);
            String orderId =(String) createResult.get('orderId');
            Map<String,Object> detailResult = DN_AgencyCustomerOrderCreateController.detailInit(orderId);
            System.debug(detailResult + ' :: detailResult');
            System.debug(createResult + ' :: createResult');
            order = (DN_AgencyCustomerOrderCreateController.Order)detailResult.get('order');
            System.debug(order +' ::: order');
            DN_AgencyCustomerOrderCreateController.updateOrder(order, false);
            System.debug(order.itemList + ' ::: order.itemList');
            DN_AgencyCustomerOrderCreateController.deleteOrderItems(order.itemList);
            DN_AgencyCustomerOrderCreateController.deleteOrder(orderId);
            
        }
        Test.stopTest();
    }

    @isTest
    static void getOrderSummaryList_TEST() {
        Test.startTest();
        DN_DealerPortalDisplayController.PageReturn page = new DN_DealerPortalDisplayController.PageReturn();
        page.itemsPerPage = 15;
        DN_AgencyCustomerOrderCreateController.getOrderSummaryList(
            '',
            '',
            new List<String>(),
            '',
            Date.today(),
            Date.today(),
            '',
            '',
            '',
            '',
            page,
            1,
            null    
        );

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();
            List<DealerCustomer__c> customers = [ SELECT Id, Name FROM DealerCustomer__c WHERE IsDealer__c = false ];
            List<Product2> partList = [ SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2];
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

            //고객 주문 관리 조회
            DN_AgencyCustomerOrderCreateController.getOrderSummaryList(
                '',
                '',
                new List<String>(),
                '',
                Date.today(),
                Date.today(),
                '',
                '',
                '',
                '',
                page,
                1,
                null    
            );

            //배송상태 조회
            DN_AgencyCustomerOrderCreateController.getInventoryStatusList(orderItem.id);
        }

        Test.stopTest();
    }


    @isTest
    static void getReturnListFromOrderSummary_TEST() {
        test.startTest();

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();
            List<DealerCustomer__c> customers = [ SELECT Id, Name FROM DealerCustomer__c WHERE IsDealer__c = false ];
            List<Product2> partList = [ SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2];
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

            List<DealerReturnOrderItem__c> returnOrderList = new List<DealerReturnOrderItem__c>();
            returnOrderList.add(
                TestDataFactoryForDealerPortal.createReturnOrderItem(orderItem.Id)
            );

            DN_AgencyCustomerOrderCreateController.getReturnListFromOrderSummary(order.id);

        }

        test.stopTest();
    }
}