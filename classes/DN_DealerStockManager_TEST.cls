@IsTest
public with sharing class DN_DealerStockManager_TEST {
    static Account acc;
    static Contact con;
    static Account acc2;
    static Contact con2;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static DealerLocation__c location;
    static DealerStock__c stock;
    static Product2 prod;
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
        }

        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'taocid1139part@test.test.com';
            insert partnerTestUser;
        }
        System.runAs(adminTestUser) {
            
            acc2 = TestDataFactoryForDealerPortal.dealer2;
            insert acc2;
            con2 = TestDataFactoryForDealerPortal.createContact(acc2.Id);
            insert con2;
            location = TestDataFactoryForDealerPortal.getLocation(acc.Id);
            insert location;
            prod = TestDataFactoryForDealerPortal.getPart('R18181', 'R18181','R18181');
            insert prod;
            stock = TestDataFactoryForDealerPortal.createDealerStock(acc.Id,prod.Id);
            stock.OwnerId = partnerTestUser.Id;
            insert stock;

            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-011', 'Real-Time');
            insert ifc;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
            insert ifClass;

            Interface__c ifc2 = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            insert ifc2;

            InterfaceClasses__c ifClass2 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifc2.Id);
            insert ifClass2;

            Interface__c ifc3 = TestDataFactoryForDealerPortal.createinterface(' IF-DEALERSTOCK-012', 'Real-Time');
            insert ifc3;

            InterfaceClasses__c ifClass3 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc3.Id);
            insert ifClass3;
        }

        
    }

    @IsTest
    static void test1(){
        DealerStock__c currentStock = [select Id, Name, CurrencyIsoCode, SourceSystem__c, LastExportDateTime__c, LastImportDateTime__c, 
                AvailableQuantity__c, CurrentStockQuantity__c, Part__c, Dealer__c,Dealer__r.Name,
                Division__c, DistributionChannel__c, SalesOrganization__c, DealerLocation__c, 
                OrderRequiredQuantity__c, WarrantyRequiredQuantity__c, BlockQuantity__c from DealerStock__c where Id=:stock.Id
            ];

        Test.startTest();
        System.runAs(partnerTestUser){
            set<String> partIds = new set<String>();
            partIds.add(prod.Id);
            set<String> agencyIds = new set<String>();
            agencyIds.add(acc.Id);
            DN_DealerStockManager.getAvailableStockMap(acc.Id,'1846','10','40',partIds);
            DN_DealerStockManager.getAvailableStockMapMutipleForCode(agencyIds,'1846','10','40',partIds);
            DN_DealerStockManager.getAvailableStockMapMutiple(agencyIds,'1846','10','40',partIds);
            DN_DealerStockManager.getAvailableStockMapExcludeCurrent(acc2.Id,'1846','10','40',partIds);
            DN_DealerStockManager.getAvailableStock(currentStock);
             
            DN_DealerStockManager.getAvailable(currentStock);
            DN_DealerStockManager.getDiscountAmount(123456,1);
            DN_DealerStockManager.getPastMonths(datetime.now(),0);
        }
        Test.stopTest();
    }

    @IsTest
    static void test2(){
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock());
        Test.startTest();
        System.runAs(partnerTestUser){
            set<String> partIds = new set<String>();
            partIds.add(prod.Id);
            DN_DealerStockManager.getPartSearch(partIds);
        }
        Test.stopTest();   
    }

    @IsTest
    static void test3(){
        Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_011_HttpMock());
        Test.startTest();
        System.runAs(partnerTestUser){
            set<String> partIds = new set<String>();
            partIds.add(prod.Id);
            DN_DealerStockManager.dealerStock011(partIds);
        }
        Test.stopTest();   
    }

    @IsTest
    static void test4(){
        // set<String> partIds = new set<String>();
        // partIds.add(prod.Id);
        // set<String> agencyIds = new set<String>();
        // agencyIds.add(acc.Id);
        Map<String,Decimal> qtyMap = new Map<String,Decimal>();
        qtyMap.put(prod.Id,1);
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_DealerStockManager.getAvailable(qtyMap,'GR','');
            DN_DealerStockManager.getAvailable(qtyMap,'GI','');
            DN_DealerStockManager.getAvailable(qtyMap,'OtherGI','');
            DN_DealerStockManager.getAvailable(qtyMap,'GICancel','');
            DN_DealerStockManager.getAvailable(qtyMap,'GIWaiting','');
            DN_DealerStockManager.getAvailable(qtyMap,'','');
        }
        Test.stopTest();   
    }

    @IsTest
    static void test5(){
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock());
        Test.startTest();
        System.runAs(partnerTestUser){
            set<String> partIds = new set<String>();
            partIds.add(prod.Id);
            DN_DealerStockManager.dealerStock012(partIds);
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

    public with sharing class IF_DEALERSTOCK_011_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ET_LIST":[{"NETPR":"3407800","LOC":"","WAERS":"KRW","REQTY":"0","STQTY":"0","MEINS":"SET","CUQTY":"0","THREAD":"90BNR10HTYNDBBCA25P4U214","MAKTX":"BEARING,BALL;ANGULAR CONTACT","DISPR":"3407800","MATNR":"R18181"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }

    public with sharing class IF_DEALERSTOCK_012_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ET_LIST":[{"NETPR":"3407800","LOC":"","WAERS":"KRW","REQTY":"0","STQTY":"0","MEINS":"SET","CUQTY":"0","THREAD":"90BNR10HTYNDBBCA25P4U214","MAKTX":"BEARING,BALL;ANGULAR CONTACT","DISPR":"","MATNR":"R18181"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
}