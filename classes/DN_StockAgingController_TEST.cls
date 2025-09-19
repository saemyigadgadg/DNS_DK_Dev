@IsTest
public with sharing class DN_StockAgingController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerStock__c stock;
    
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
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-011', 'Real-Time');
            insert ifc;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
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
            stock = TestDataFactoryForDealerPortal.createDealerStock(acc.Id,prod.Id);
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
        try {
            Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_011_HttpMock());
            // Datetime dateGRStart = Datetime.now().addDays(-7);
            // Datetime dateGREnd = Datetime.now().addDays(7);
            // DN_CancelGRTableController.SearchOption search = new DN_CancelGRTableController.SearchOption(); 
            // search.gRtype = '1';
            // search.partId = prod.Id;
            // search.productCode = prod.ProductCode;
            // search.dateGRStart = dateGRStart.format('yyyy-MM-dd');
            // search.dateGREnd = dateGREnd.format('yyyy-MM-dd');
            System.runAs(partnerTestUser){
                Test.startTest();
                DN_StockAgingController.PageReturn page = new DN_StockAgingController.PageReturn();
                page.currentPage = 1;
                page.itemsPerPage = 15;
                page.orderBy = 'ASC';
                page.orderByField ='order by Part__r.ProductCode';
                page.pagesPerGroup =10;
                page.strQuery = new Map<String,Object>();
                page.strQuery.put('LastGR',DateTime.now().format('yyyy-MM-dd'));
                page.strQuery.put('productCode',prod.Id);
                page.strQuery.put('LastGI',DateTime.now().format('yyyy-MM-dd'));
                DN_StockAgingController.getDataListQuery(page,1);
                DN_StockAgingController.setExcelData(page,1);
                
                Test.stopTest();    
            }
            
        } catch (Exception e) {
            
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
    
}