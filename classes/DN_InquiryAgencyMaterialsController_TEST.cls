@isTest
public with sharing class DN_InquiryAgencyMaterialsController_TEST {
    static Account acc;
    static Contact con;
    static Account acc2;
    static Contact con2;
    static Product2 prod;
    static ProductByPlant__c prodByPlant;
    static PurchaseOrder__c purOrder;
    static PurchaseOrderItems__c purOrderItems;
    static DealerPurchaseOrder__c  dealerPurOrder;
    static DealerPurchaseOrderItem__c dealerPurItem;
    static DealerInventoryMovements__c goodsReceipt;
    static DealerInventoryMovements__c goodsIssue;
    static DealerInventoryMovements__c goodsIssue2;
    static DealerCustomer__c custoemr;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static DealerAreaByMPPS__c dealerByMpps;

    static
    {   
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

            //seq
            Sequence__c seq = TestDataFactoryForDealerPortal.getSequence('DealerPurchaseOrder',
                'DealerPurchaseOrder__c','DealerPO','C4{000000000}'
            );
            insert seq;
            Sequence__c seq2 = TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GR',
                'DealerInventoryMovements__c','GoodsReceipt','C5{000000000}'
            );
            insert seq2;
            Sequence__c seq3 = TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GI',
                'DealerInventoryMovements__c','GoodsIssue','C6{000000000}'
            );
            insert seq3;

            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-SERVICE-037', 'Real-Time');
            insert ifc;
    
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Service_PartsDetail', ifc.Id);
            insert ifClass;

            Interface__c ifc2 = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            insert ifc2;
            
            InterfaceClasses__c ifClass2 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifc2.Id);
            insert ifClass2;
    
            

            // Other Dealer
            acc2 = TestDataFactoryForDealerPortal.dealer2;
            insert acc2;
            con2 = TestDataFactoryForDealerPortal.createContact(acc2.Id);
            insert con2;
            
            prod = TestDataFactoryForDealerPortal.getPart('R18181', 'R18181','R18181');
            insert prod;
            ProductByPlant__c prodByPlant = TestDataFactoryForDealerPortal.getProductByPlant(prod.Id, prod.Id);
            insert prodByPlant;
            DealerStock__c stock = TestDataFactoryForDealerPortal.getStock(prod.Id, acc.Id);
            insert stock;
            
            //Other Deaelr
            DealerStock__c otherstock = TestDataFactoryForDealerPortal.getStock(prod.Id, acc2.Id);
            insert otherstock;
            purOrder = TestDataFactoryForDealerPortal.getPurOrder(acc.Id);
            insert purOrder;
            purOrderItems = TestDataFactoryForDealerPortal.getPurOrderItem(purOrder.Id,prod.Id);
            insert purOrderItems;

            goodsReceipt = TestDataFactoryForDealerPortal.getGoodsIssue(acc.Id,prod.Id);
            goodsReceipt.RecordTypeId = TestDataFactoryForDealerPortal.getRecordType('GoodsReceipt', 'DealerInventoryMovements__c').Id;
            insert goodsReceipt;

            custoemr = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert custoemr;
            dealerPurOrder = TestDataFactoryForDealerPortal.getDealerPur(acc.Id,custoemr.Id);
            insert dealerPurOrder;
            dealerPurItem = TestDataFactoryForDealerPortal.getDealerPurItem(dealerPurOrder.Id,prod.Id,prod.Id);
            insert dealerPurItem;
            goodsIssue = TestDataFactoryForDealerPortal.getGoodsIssue(acc.Id,prod.Id);
            goodsIssue.RecordTypeId = TestDataFactoryForDealerPortal.getRecordType('GoodsIssue', 'DealerInventoryMovements__c').Id;
            goodsIssue.InventoryChange__c = 'H';
            goodsIssue.Type__c = 'W';
            goodsIssue.PurchaseOrderItem__c =purOrderItems.Id;
            insert goodsIssue;
            
            goodsIssue2 = TestDataFactoryForDealerPortal.getGoodsIssue(acc.Id,prod.Id);
            goodsIssue2.RecordTypeId = TestDataFactoryForDealerPortal.getRecordType('GoodsIssue', 'DealerInventoryMovements__c').Id;
            goodsIssue2.InventoryChange__c = 'H';
            goodsIssue2.Type__c = 'S';
            goodsIssue2.DealerPurchaseOrderItem__c =dealerPurItem.Id;
            insert goodsIssue2;
            DealerPartMasterByMPPS__c mpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(prod.Id, acc.Id);
            insert mpps;
            AreaByMPPS__c area = TestDataFactoryForDealerPortal.getAreaByMpps();
            insert area;
            dealerByMpps = TestDataFactoryForDealerPortal.getDealerAreaByMPPS(acc.Id,area.Id);
            insert dealerByMpps;
        
        }
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'part@test.test.com';
            insert partnerTestUser;
        }


    }



    @IsTest
    static void test1(){
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock());
        Product2 part = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode='R18181' LIMIT 1];
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        
        DealerStock__c stock = [SELECT Id,BlockQuantity__c,CurrentStockQuantity__c FROM DealerStock__c WHERE Part__r.ProductCode='R18181' AND Dealer__c=:acc.Id LIMIT 1];
        System.runAs(partPortal){
            try {
                Test.startTest();
                    DN_InquiryAgencyMaterialsController.getCurrentAgency();
                    DN_InquiryAgencyMaterialsController.getStock(prod.ProductCode);
                    DN_InquiryAgencyMaterialsController.stockSave(stock);
                    DN_InquiryAgencyMaterialsController.insertMpps(prod.ProductCode);
                Test.stopTest();    
            } catch (Exception e) {
                
            } 
            
        }
    }

    @IsTest
    static void test2(){
        Product2 part = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode='R18181' LIMIT 1];
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        System.debug([SELECT Id, Name,Profile.Name FROM User] + ' test User List');
        System.runAs(adminTestUser) {
            List<DealerPartMasterByMPPS__c> mpps = [SELECT Id FROM DealerPartMasterByMPPS__c];
            delete mpps;            
        }
        DealerStock__c stock = [SELECT Id,BlockQuantity__c,CurrentStockQuantity__c FROM DealerStock__c WHERE Part__r.ProductCode='R18181' AND Dealer__c=:acc.Id LIMIT 1];
        System.runAs(partPortal){
            try {
                Test.startTest();      
                    DN_InquiryAgencyMaterialsController.insertMpps(prod.ProductCode);
                Test.stopTest();    
            } catch (Exception e) {
                
            }    
        }
    }

    @IsTest
    static void test3(){
        Test.setMock(HttpCalloutMock.class, new IF_SERVICE_037_HttpMock());
        Test.startTest();
        Product2 part = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode='R18181' LIMIT 1];
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        
        System.runAs(partPortal){
            try {                
                DN_InquiryAgencyMaterialsController.replacingPart(part.ProductCode);
            } catch (Exception e) {
                
            }    
        }
        Test.stopTest();
        
    }


    public class IF_PARTS_022_HttpMock implements HttpCalloutMock {
        public IF_PARTS_022_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"30","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"22.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"99.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"Y","HERKL":"KR","SUB_MATERIAL":"R18182","KONDM":"P","BRGEW":"4.922","REPLACE":"X","AUMNG":"0.000"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    public class IF_SERVICE_037_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_037_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"O_AVAIL_QTY":"0.000","O_MANUFACT":"","O_MATERIAL":"","O_MESG":"Successfully finished.[ZSS90101]","O_RESULT":{"MAKTX":"카트리지어셈블리","SVC_FLAG":"Y","AVA_FLAG":"N","NOTCD":"","COND_VALUE":"21403100.000000000","NETPR":"21403100.00","CURRENCY":"KRW","NETPR_ETC":"16587400.00","CURRENCY2":"KRW","KWMENG":"0.000","AUMNG":"0.000","LFMNG":"0.000","MEINS":"AY","BRGEW":"0.000","NTGEW":"60.000","GEWEI":"KG","GROES":"","PRODH":"SP3003016030160001","PRODH_T":"OTHERS","BULET":"","ZPRAT":"N","HERKL":"","PLIFZ":"60","M_MATNR":"","C_MTPOS":"N","DATAB":"2023-10-16","KONDM":"M","VTEXT":"","NOTCD_TEXT":"","SVRCD":"S","SVRCD_TEXT":"Service","AVRLT":"0","REMARK2":""},"O_THREAD":"18K_112L_BT/DIN40","ET_AVAIL":[],"ET_CROSS":[{"ITCCD":"","LABST":"0.000","SVRCD_TEXT":"Service","SEQ":"1-1","NOTCD":"","MAKTX":"CARTRIDGE ASSY","DDTEXT":"","MXNET":"","SVRCD":"S","MATNR":"R18181"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
}