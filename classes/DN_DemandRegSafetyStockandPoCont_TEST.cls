@IsTest     
public with sharing class DN_DemandRegSafetyStockandPoCont_TEST {
    static Account acc;
    static Contact con;
    static DealerPartMasterByMPPS__c dealerByMpps;
    static MonthlyDemandSummaryByDealer__c monSummByDealer;
    static DealerStock__c stock;
    static Product2 prod;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;

    static {
        List<User> userList = new List<User>();
        adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        userList.add(adminTestUser);

        adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
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
            prod = TestDataFactoryForDealerPortal.getPart('R18181', 'R18181','R18181');
            insert prod;
            dealerByMpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(prod.Id, acc.Id);
            dealerByMpps.ServiceFactor__c = 0;
            dealerByMpps.OwnerId = partnerTestUser.Id;
            insert dealerByMpps;
            monSummByDealer = TestDataFactoryForDealerPortal.createMonDemSumByDealer(prod.Id,acc.Id);
            monSummByDealer.AnalysisPeriodMonth__c = Datetime.now().addMonths(-6).format('yyyyMM');
            monSummByDealer.OwnerId = partnerTestUser.Id;
            insert monSummByDealer;
             //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-011', 'Real-Time');
            insert ifc;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
            insert ifClass;
        }
       
    }


    @IsTest
    static void test1(){
        Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_011_HttpMock());
        DN_DemandRegSafetyStockandPoController.PageReturns page = new DN_DemandRegSafetyStockandPoController.PageReturns();
        page.currentPage = 1;
        page.itemsPerPage = 15;
        page.orderBy = 'DESC';
        page.orderByField = 'order by LastModifiedDate';
        page.pagesPerGroup = 5;
        page.strQuery = new Map<String,Object>();
        page.strQuery.put('ABCIndicator','ALL');
        page.strQuery.put('MRPType','ALL');
        page.strQuery.put('productCode',prod.Id);

        Test.startTest();
        System.runAs(partnerTestUser){
            DN_DemandRegSafetyStockandPoController.getSafetyStockList(page, 1, false);
        }
        Test.stopTest();
        
    }

    @IsTest
    static void test2(){
        DN_DemandRegSafetyStockandPoController.SafetyStock stock = new DN_DemandRegSafetyStockandPoController.SafetyStock();
        stock.id = dealerByMpps.Id;
        stock.nMaxLv = 1;
        stock.nROP = 1;
        stock.mrpType = 'VB';
        stock.fix = false;
        stock.nRVal = 1;
        stock.nMinLot = 1;
        stock.materialId = prod.Id;
        stock.partsNote = 'test';
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_DemandRegSafetyStockandPoController.ropSave(new List<DN_DemandRegSafetyStockandPoController.SafetyStock>{stock});
            DN_DemandRegSafetyStockandPoController.getMonth();
        }
        Test.stopTest();
        
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