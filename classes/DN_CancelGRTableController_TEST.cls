@IsTest
public with sharing class DN_CancelGRTableController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerStock__c stock;
    static PurchaseOrder__c  purOrder;
    static PurchaseOrder__c  purOrderReturn;
    static PurchaseOrderItems__c purOrderItems;
    static PurchaseOrderItems__c purOrderReturnItems;
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
            Sequence__c seq =TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GR', 'DealerInventoryMovements__c', 'GoodsReceipt', 'C5{000000000}');
            insert seq;

            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-014', 'Real-Time');
            insert ifc;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
            insert ifClass;
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = '111aaa111part@test.test.com';
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
            insert purOrderItems;
            purOrderReturn = TestDataFactoryForDealerPortal.getPurOrderReturn(acc.Id);
            insert purOrderReturn;
            purOrderReturnItems = TestDataFactoryForDealerPortal.getPurOrderItem(purOrderReturn.Id,prod.Id);
            insert purOrderReturnItems;
            purOrderGoodsReceipt = TestDataFactoryForDealerPortal.getGoodsReceipt(acc.Id,prod.Id);
            purOrderGoodsReceipt.InventoryChange__c ='S';
            purOrderGoodsReceipt.PurchaseOrderItem__c = purOrderReturnItems.Id;
            insert purOrderGoodsReceipt;
        }
            
        
    }

    @IsTest
    static void test1(){
        try {
            Datetime dateGRStart = Datetime.now().addDays(-7);
            Datetime dateGREnd = Datetime.now().addDays(7);
            DN_CancelGRTableController.SearchOption search = new DN_CancelGRTableController.SearchOption(); 
            search.gRtype = '1';
            search.partId = prod.Id;
            search.productCode = prod.ProductCode;
            search.dateGRStart = dateGRStart.format('yyyy-MM-dd');
            search.dateGREnd = dateGREnd.format('yyyy-MM-dd');
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_CancelGRTableController.getDataList(search);
                    DealerStock__c currentStock = [SELECT DealerLocation__c,DealerLocation__r.FM_Loc__c,CurrentStockQuantity__c FROM DealerStock__c WHERE Id=:stock.Id];
                    DN_CancelGRTableController.CancelGR gr = new DN_CancelGRTableController.CancelGR(currentStock);
                Test.stopTest();    
            }
            
        } catch (Exception e) {
            
        } 
    }

    @IsTest
    static void tset2(){
        try {
            Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_014_HttpMock());
            Datetime dateGRStart = Datetime.now().addDays(-7);
            Datetime dateGREnd = Datetime.now().addDays(7);
            DN_CancelGRTableController.SearchOption search = new DN_CancelGRTableController.SearchOption(); 
            search.gRtype = '2';
            search.partId = prod.Id;
            search.productCode = prod.ProductCode;
            search.dateGRStart = dateGRStart.format('yyyy-MM-dd');
            search.dateGREnd = dateGREnd.format('yyyy-MM-dd');
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_CancelGRTableController.getDataList(search);
                Test.stopTest();    
            }
        } catch (Exception e) {
            
        } 
    }

    @IsTest // DNS 입고취소
    static void test3(){
        try {
            DN_CancelGRTableController.CancelGR cancelGR = new DN_CancelGRTableController.CancelGR();
            cancelGR.cancelAvailableGRQty =1;
            cancelGR.cancelGRQty = 1;
            cancelGR.canceledlGRQty = 0;
            cancelGR.dNSDocument = '5000115444';
            cancelGR.dNSId = purOrderReturnItems.Id;
            cancelGR.firstGRQty = 1;
            cancelGR.gRDocument = '7100253175';
            cancelGR.itemNumber='11';
            cancelGR.lastImportDateTime = '2024-08-07';
            cancelGR.partId=prod.Id;
            cancelGR.partName='R18181';
            cancelGR.pratNumber='R18181';
            cancelGR.stockQty=0;
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_CancelGRTableController.gRCancel(new List<DN_CancelGRTableController.CancelGR>{cancelGR} ,'2');
                Test.stopTest();    
            }
        } catch (Exception e) {
            
        } 
    }

    
    public with sharing class IF_DEALERSTOCK_014_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String responseBody = '{"ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"조회 완료"},"ET_LIST":[{"NETPR":"284300","ERDAT":"20240311","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115370","CUQTY":"1","RETNO":"7100252410","DMBTR":"440660","MENGE":"2","THREAD":"DNU-80-500-PPV-A","MAKTX":"CYLINDER,AIR","DISPR":"220330","CAQTY":"1","MATNR":"R42220","DOCIT":"10"},{"NETPR":"20500","ERDAT":"20240314","LOC":"B-09-04","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115377","CUQTY":"3","RETNO":"7100252630","DMBTR":"15890","MENGE":"1","THREAD":"SKY-32","MAKTX":"PACKING;SKY","DISPR":"15890","CAQTY":"0","MATNR":"R56162","DOCIT":"10"},{"NETPR":"1234600","ERDAT":"20240314","LOC":"A-83-01","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115379","CUQTY":"4","RETNO":"7100252629","DMBTR":"805400","MENGE":"1","THREAD":"DVSD-TTS-14C_14AMPERE_17B","MAKTX":"DRIVE,SERVO;TURRET_ATC FOR AS","DISPR":"805400","CAQTY":"0","MATNR":"300419-00031","DOCIT":"10"},{"NETPR":"235300","ERDAT":"20240315","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115380","CUQTY":"1","RETNO":"7100252674","DMBTR":"182360","MENGE":"1","THREAD":"PCB BOARD(STD)","MAKTX":"PCB ASSY;OP","DISPR":"182360","CAQTY":"0","MATNR":"EITOP057AS","DOCIT":"10"},{"NETPR":"1195600","ERDAT":"20240321","LOC":"A-82-01","RMQTY":"2","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115398","CUQTY":"0","RETNO":"7100252823","DMBTR":"1446820","MENGE":"2","THREAD":"DVSC-TM-14E-01","MAKTX":"DRIVE,SERVO;TURRET_ATC","DISPR":"723410","CAQTY":"0","MATNR":"300419-00035B","DOCIT":"10"},{"NETPR":"422800","ERDAT":"20240402","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115442","CUQTY":"0","RETNO":"7100253121","DMBTR":"327670","MENGE":"1","THREAD":"","MAKTX":"COVER,SLIDE;(XR)","DISPR":"327670","CAQTY":"0","MATNR":"AS-133","DOCIT":"10"},{"NETPR":"284300","ERDAT":"20240807","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115444","CUQTY":"1","RETNO":"7100253175","DMBTR":"220330","MENGE":"1","THREAD":"DNU-80-500-PPV-A","MAKTX":"CYLINDER,AIR","DISPR":"220330","CAQTY":"0","MATNR":"R18181","DOCIT":"11"}]}';
            response.setBody(responseBody);
            response.setStatusCode(200);
            return response;        
        }        
    }

   
}