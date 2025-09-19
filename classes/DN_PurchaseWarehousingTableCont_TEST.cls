@IsTest
public with sharing class DN_PurchaseWarehousingTableCont_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerStock__c stock;
    static DealerCustomer__c customer;
    static PurchaseOrder__c  purOrder;
    static PurchaseOrder__c  purOrderReturn;
    static PurchaseOrderItems__c purOrderItems;
    static PurchaseOrderItems__c purOrderReturnItems;
    static DealerPurchaseOrder__c dealerPurOrder;
    static DealerPurchaseOrderItem__c dealerPurOrderItem;
    static DealerInventoryMovements__c goodsReceipt;
    static DealerInventoryMovements__c purOrderGoodsReceipt;
    static DealerInventoryMovements__c goddsRecCancle;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    
    static {
        List<User> userList = new List<User>();
        adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesOffice__c = '414A';
        adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesOffice__c = '414A';
        adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);
        insert userList;
        System.runAs(adminTestUser) {
            acc = TestDataFactoryForDealerPortal.dealer;
            insert acc;
            con = TestDataFactoryForDealerPortal.createContact(acc.Id);
            insert con;
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
            Sequence__c seq =TestDataFactoryForDealerPortal.getSequence('DealerCustomer', 'DealerCustomer__c', 'Customer', 'C5{000000}');
            insert seq;
            Sequence__c seq2 =TestDataFactoryForDealerPortal.getSequence('DealerPurchaseOrder', 'DealerPurchaseOrder__c', 'DealerPO', 'C4{000000000}');
            insert seq2;
            Sequence__c seq3 =TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GR', 'DealerInventoryMovements__c', 'GoodsReceipt', 'C5{000000000}');
            insert seq3;
            Sequence__c seq4 =TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GI', 'DealerInventoryMovements__c', 'GoodsIssue', 'C6{000000000}');
            insert seq4;

            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-006', 'Real-Time');
            insert ifc;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
            insert ifClass;

            
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = '2222222part@test.test.com';
            insert partnerTestUser;
        }
        System.runAs(partnerTestUser) {
            stock = TestDataFactoryForDealerPortal.createDealerStock(acc.Id,prod.Id);
            insert stock;
            goodsReceipt = TestDataFactoryForDealerPortal.getGoodsReceipt(acc.Id,prod.Id);
            goodsReceipt.InventoryChange__c = 'S';
            goodsReceipt.Type__c = '1';
            insert goodsReceipt;
            goddsRecCancle = TestDataFactoryForDealerPortal.getGoodsReceipt(acc.Id,prod.Id);
            goddsRecCancle.InventoryChange__c = 'H';
            goddsRecCancle.GoodsReceiptNumber__c = goodsReceipt.Id;
            insert goddsRecCancle;
            purOrder = TestDataFactoryForDealerPortal.getPurOrder(acc.Id);
            insert purOrder;
            purOrderItems = TestDataFactoryForDealerPortal.getPurOrderItem(purOrder.Id,prod.Id);
            purOrderItems.SupplyPartId__c = prod.Id;
            insert purOrderItems;
            purOrderReturn = TestDataFactoryForDealerPortal.getPurOrderReturn(acc.Id);
            insert purOrderReturn;
            purOrderReturnItems = TestDataFactoryForDealerPortal.getPurOrderItem(purOrderReturn.Id,prod.Id);
            purOrderReturnItems.SupplyPartId__c = prod.Id;
            insert purOrderReturnItems;
            purOrderGoodsReceipt = TestDataFactoryForDealerPortal.getGoodsReceipt(acc.Id,prod.Id);
            purOrderGoodsReceipt.InventoryChange__c ='S';
            purOrderGoodsReceipt.PurchaseOrderItem__c = purOrderReturnItems.Id;
            insert purOrderGoodsReceipt;
            customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert customer;
            dealerPurOrder = TestDataFactoryForDealerPortal.getDealerPur(acc.Id,customer.Id);
            
            dealerPurOrder.OrderNumber__c = '3001955256';
            insert dealerPurOrder;
            dealerPurOrderItem = TestDataFactoryForDealerPortal.getDealerPurItem(dealerPurOrder.Id,prod.Id,prod.Id);
            dealerPurOrderItem.ReplacingPart__c = prod.Id;
            dealerPurOrderItem.GICompletedDateTime__c = DateTime.now();
            dealerPurOrderItem.GICompletedQuantity__c =1;
            insert dealerPurOrderItem;
        }
            
        
    }

    @IsTest
    static void test1(){
        try {
            Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_006_HttpMock());
            Datetime OrderDateStart = Datetime.now().addDays(-7);
            Datetime OrderDateEnd = Datetime.now().addDays(7);
            Map<String,Object> searchMap = new Map<String,Object>();
            
            searchMap.put('OrderDateStart',OrderDateStart.format('yyyy-MM-dd'));
            searchMap.put('OrderDateEnd',OrderDateEnd.format('yyyy-MM-dd'));
            searchMap.put('orderNumber','3001955256');
            searchMap.put('orderType','All');
            searchMap.put('productCode',prod.Id);
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_PurchaseWarehousingTableController.getDNSLIst(searchMap);
                    DN_PurchaseWarehousingTableController.getDealerPurOrder(searchMap);
                Test.stopTest();    
            }
            
        } catch (Exception e) {
            
        } 
    }

    @IsTest
    static void test2(){
        try {
            Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_006_HttpMock());
            Datetime OrderDateStart = Datetime.now().addDays(-7);
            Datetime OrderDateEnd = Datetime.now().addDays(7);
            Map<String,Object> searchMap = new Map<String,Object>();
            
            searchMap.put('OrderDateStart',OrderDateStart.format('yyyy-MM-dd'));
            searchMap.put('OrderDateEnd',OrderDateEnd.format('yyyy-MM-dd'));
            searchMap.put('orderNumber','3001955256');
            searchMap.put('orderType','DNS'); 
            searchMap.put('productCode',prod.Id);
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_PurchaseWarehousingTableController.getDNSLIst(searchMap);
                Test.stopTest();    
            }
            
        } catch (Exception e) {
            
        }
        
    }

    @IsTest
    static void test3(){
        try {
            Datetime OrderDateStart = Datetime.now().addDays(-7);
            Datetime OrderDateEnd = Datetime.now().addDays(7);
            Map<String,Object> searchMap = new Map<String,Object>();
            searchMap.put('OrderDateStart',OrderDateStart.format('yyyy-MM-dd'));
            searchMap.put('OrderDateEnd',OrderDateEnd.format('yyyy-MM-dd'));
            searchMap.put('orderNumber','3001955256');
            searchMap.put('orderType','Agency'); 
            searchMap.put('productCode',prod.Id);
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_PurchaseWarehousingTableController.getDealerPurOrder(searchMap);
                Test.stopTest();    
            }
        } catch (Exception e) {
            
        }
    }

    @IsTest
    static void test4(){
        DN_PurchaseWarehousingTableController.GoodsReceipt rep = new DN_PurchaseWarehousingTableController.GoodsReceipt();
        rep.inventoryChange = 'S';
        rep.part = prod.Id;
        rep.location = '';
        rep.quantity = 1;
        rep.type = '2';
        rep.purchaseOrderItem =  purOrderItems.Id;
        DN_PurchaseWarehousingTableController.GoodsReceipt rep2 = new DN_PurchaseWarehousingTableController.GoodsReceipt();
        rep2.inventoryChange = 'S';
        rep2.part = prod.Id;
        rep2.location = '';
        rep2.quantity = 1;
        rep2.type = '1';
        rep2.dealerPurchaseOrderItem =  dealerPurOrderItem.Id;
        System.runAs(partnerTestUser){
            Test.startTest();
                DN_PurchaseWarehousingTableController.insertGRList(new List<DN_PurchaseWarehousingTableController.GoodsReceipt>{rep,rep2},new List<String>{purOrderItems.Id}, new List<String>{dealerPurOrderItem.Id});
            Test.stopTest();    
        }
        
    }

    public with sharing class IF_DEALERSTOCK_006_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"조회 완료"},"ET_LIST":[{"DISPR":"3180","TEXT1":"","NETPR":"4100","KWMENG":"10","MAKTX":"BEARING,BALL;THRUST","MATNR":"R18181","TYPE":"1","CUQTY":"14","LOC":"B-57-02","GRQTY":"8","RMQTY":"2","RTQTY":"0","BSTKD":"20241206","GIDAT":"2024-12-09","DOCNO":"3001955256","CUST_NO":"","WAERS":"KRW","AUDAT":"2024-12-06","DMBTR":"31800","DOCIT":"10","NAME1":"DN Solutions","MEINS":"EA"}]}';
            
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }

}