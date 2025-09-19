@IsTest
public with sharing class DN_AgencyInventoryLookupController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerStock__c stock;
    static DealerLocation__c location;
    static DealerCustomer__c dealerCustomer;
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

            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            insert ifc;
    
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifc.Id);
            insert ifClass;
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'partSeotest1111@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';

            insert partnerTestUser;
        }
        System.runAs(partnerTestUser) {
            dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert dealerCustomer;
            location = TestDataFactoryForDealerPortal.getLocation(acc.Id);
            insert location;
            
            stock = TestDataFactoryForDealerPortal.createDealerStock(acc.Id,prod.Id);
            stock.DealerLocation__c = location.Id;
            stock.SalesOrganization__c = '1846';
            stock.DistributionChannel__c = '10';
            stock.Division__c = '40';
            stock.CurrentStockQuantity__c =1;
            stock.LastImportDateTime__c = DateTime.now().addDays(-3);
            stock.LastExportDateTime__c = DateTime.now().addDays(-3);
            insert stock;   
        }
    }

    @IsTest
    static void test1(){
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock());
        DN_AgencyInventoryLookupController.PageReturn page = new DN_AgencyInventoryLookupController.PageReturn();
        page.currentPage =1;
        page.itemsPerPage =20;
        page.orderBy ='DESC';
        page.orderByField ='order by LastModifiedDate';
        page.pagesPerGroup =10;
        page.strQuery = new Map<String,Object>();
        page.strQuery.put('binOption', 'All');
        page.strQuery.put('stockOption', '1');
        page.strQuery.put('productCode', prod.Id);
        page.strQuery.put('CustomerName',dealerCustomer.Id);
        page.strQuery.put('location',location.Id);
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_AgencyInventoryLookupController.getDataListQuery(page, 1);
            stock.DealerLocation__c =null;
            DN_AgencyInventoryLookupController.StorageChange storege = new DN_AgencyInventoryLookupController.StorageChange(stock);
            DN_AgencyInventoryLookupController.StorageChange storege2 = new DN_AgencyInventoryLookupController.StorageChange();
        }
        Test.stopTest();
    }

    @IsTest
    static void tset2(){
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock());
        DN_AgencyInventoryLookupController.PageReturn page = new DN_AgencyInventoryLookupController.PageReturn();
        page.currentPage =1;
        page.itemsPerPage =20;
        page.orderBy ='DESC';
        page.orderByField ='order by LastModifiedDate';
        page.pagesPerGroup =10;
        page.strQuery = new Map<String,Object>();
        page.strQuery.put('binOption', 'All');
        page.strQuery.put('stockOption', 'All');
        page.strQuery.put('productCode', prod.Id);
        page.strQuery.put('CustomerName',dealerCustomer.Id);
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_AgencyInventoryLookupController.setExcelData(page, 1);
            DN_AgencyInventoryLookupController.storageBinDetailInfo('TESTABC11-11',acc.Id);
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
}