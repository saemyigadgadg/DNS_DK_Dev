/** 
 * @Class :  DN_AgencyCustomerReturnController_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 23. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-23 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_AgencyCustomerReturnController_TEST {
    static String partnerUserName ='partACRC@test.test.com';
    static String partnerUserName2 ='part2ACRC@test.test.com';
    
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

            Sequence__c seq4 = new Sequence__c(
                Name ='DealerReturnOrder',
                Type__c = 'ReturnOrder', 
                Pattern__c = 'C7{000000000}',
                SObjectAPI__c = 'DealerReturnOrderItem__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq4);
            insert sequenceList;

            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            insert dealerCustomer;
    
            List<Product2> partList = new List<Product2>();
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18181', 'R18181영문', 'R18181국문')
            );
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18182', 'R18182영문', 'R18182국문')
            ); //Last
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18180', 'R18180영문', 'R18180국문')
            ); //Start
            insert partList;
        
            List<ProductByPlant__c> plantByProductList = new List<ProductByPlant__c>();
            ProductByPlant__c plant1 = TestDataFactoryForDealerPortal.getProductByPlant(partList[0].Id,partList[1].Id);
            plant1.StartPart__c = partList[2].id;
            plant1.ReplacingPart__c = partList[1].id;
            plantByProductList.add(plant1);
            ProductByPlant__c plant2 = TestDataFactoryForDealerPortal.getProductByPlant(partList[1].Id,partList[1].Id);
            plant2.StartPart__c = partList[2].id;
            plantByProductList.add(plant2);
            ProductByPlant__c plant3 = TestDataFactoryForDealerPortal.getProductByPlant(partList[2].Id,partList[1].Id);
            plant3.ReplacingPart__c = partList[0].id;
            plant3.StartPart__c = partList[2].id;
            plantByProductList.add(plant3);
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

            DN_UserDetails currentUser = new DN_UserDetails();
            List<Product2> partList = [SELECT Id, ProductCode FROM Product2];
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
        }
    }

    @isTest
    static void init_TEST() {
        Test.startTest();
        DN_AgencyCustomerReturnController.init('Partners');
        DN_AgencyCustomerReturnController.init('12');

        Test.stopTest();
    }

    @isTest
    static void search_Create_TEST() {
        Test.startTest();
        DN_DealerPortalDisplayController.PageReturn page = new DN_DealerPortalDisplayController.PageReturn();
        page.itemsPerPage = 15;
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
            orderItem.Quantity__c = 10;
            orderItemList.add(orderItem);
            DealerOrderItem__c orderItem2 = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[1].id, partList[1].id);
            orderItem2.Quantity__c = 1;
            orderItemList.add(orderItem2);
            insert orderItemList;


            List<DealerInventoryMovements__c> goodIssuesList = new List<DealerInventoryMovements__c>();
            DealerInventoryMovements__c goodIssue = TestDataFactoryForDealerPortal.createGI();
            goodIssue.DealerOrderItem__c = orderItem.Id;
            goodIssue.Part__c = partList[0].id;
            goodIssue.Type__c = 'S';
            goodIssue.Quantity__c = 2;
            goodIssuesList.add(goodIssue);

            DealerInventoryMovements__c goodIssue3 = TestDataFactoryForDealerPortal.createGI();
            goodIssue3.DealerOrderItem__c = orderItem.Id;
            goodIssue3.Part__c = partList[0].id;
            goodIssue3.Type__c = 'S';
            goodIssue3.Quantity__c = 2;
            goodIssuesList.add(goodIssue3);
            insert goodIssuesList;

            Map<String, Object> searchResult = DN_AgencyCustomerReturnController.searchReturnRequestOrder(
                '',
                '',
                Date.today(),
                Date.today(),
                '',
                '',
                page,
                1
            );

            List<DN_AgencyCustomerReturnController.ReturnOrderItem> returnRequestList = (List<DN_AgencyCustomerReturnController.ReturnOrderItem>)searchResult.get('returnRequestList');
            System.debug('returnRequestList : '+ JSON.serializePretty(returnRequestList));
            //
            DN_AgencyCustomerReturnController.createReturnRequestOrder(returnRequestList);

            Map<String,Object> returnSearchResult = DN_AgencyCustomerReturnController.searchReturnOrder(
                '',
                new List<String>(),
                Date.today(),
                Date.today(),
                '',
                '',
                page,
                1
            );

            List<DN_AgencyCustomerReturnController.ReturnOrderItem> returnList = (List<DN_AgencyCustomerReturnController.ReturnOrderItem>) returnSearchResult.get('returnOrderList');
            DN_AgencyCustomerReturnController.deleteReturnOrder(returnList);
        }

        Test.stopTest();
    }

    @isTest
    static void fileRemove_TEST() {
        Test.startTest();
        try {
            DN_AgencyCustomerReturnController.fileRemove(null);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}