@IsTest
public with sharing class DN_DemandAdjPerAgencyController_TEST {
    static Account acc;
    static Contact con;
    static DealerCustomer__c customer;
    static DealerOrder__c dealerOrder;
    static DealerOrderItem__c dealerOrderItem;
    static AreaByMPPS__c area;
    static DealerPartMasterByMPPS__c dealerByMpps;
    static DealerAreaByMPPS__c dealerAreaByMpps;
    static AreaPartMasterByMPPS__c areaPartByMpps;
    static DealerOrderSummary__c orderSum;
    static MonthlyDemandSummaryByDealer__c monSummByDealer;
    static MonthlyDemandSummaryByRegion__c monSumRegion;
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
            customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert customer;
        }

        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'taocidaaaaa1139part@test.test.com';
            insert partnerTestUser;
        }
        System.runAs(adminTestUser) {
            prod = TestDataFactoryForDealerPortal.getPart('R18181', 'R18181','R18181');
            insert prod;
            dealerOrder = TestDataFactoryForDealerPortal.getOrder(acc.Id, customer.Id);
            insert dealerOrder;
            dealerOrderItem = TestDataFactoryForDealerPortal.getOrderItem(dealerOrder.Id,prod.Id,prod.Id);
            insert dealerOrderItem;
            area = TestDataFactoryForDealerPortal.getAreaByMpps();
            insert area;
            areaPartByMpps = TestDataFactoryForDealerPortal.getAreaPartByMpps(area.Id,prod.Id);
            insert areaPartByMpps;
            dealerAreaByMpps = TestDataFactoryForDealerPortal.getDealerAreaByMPPS(acc.Id,area.Id);
            dealerAreaByMpps.OwnerId = partnerTestUser.Id; 
            insert dealerAreaByMpps;
            orderSum = TestDataFactoryForDealerPortal.getDealerOrderSummary(acc.Id,prod.Id);
            orderSum.OwnerId = partnerTestUser.Id;
            orderSum.CreatedDateTime__c = Datetime.now().addMonths(-6);
            orderSum.DemandType__c = 'DS';
            orderSum.DealerOrderItem__c =dealerOrderItem.Id;
            insert orderSum;
            dealerByMpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(prod.Id, acc.Id);
            dealerByMpps.OwnerId = partnerTestUser.Id;
            dealerByMpps.ReorderPoint__c =0;
            dealerByMpps.MinimumLotSize__c = 0;
            dealerByMpps.MaximumStock__c = 0;
            insert dealerByMpps;
            monSummByDealer = TestDataFactoryForDealerPortal.createMonDemSumByDealer(prod.Id,acc.Id);
            monSummByDealer.AnalysisPeriodMonth__c = Datetime.now().addMonths(-6).format('yyyyMM');
            monSummByDealer.OwnerId = partnerTestUser.Id;
            monSummByDealer.LastPart__c = prod.Id;
            insert monSummByDealer;
            monSumRegion = TestDataFactoryForDealerPortal.getMonSumByRegion(area.Id,prod.Id);
            monSumRegion.OwnerId = partnerTestUser.Id;
            monSumRegion.LastPart__c = prod.Id;
            insert monSumRegion;

        }
    }


    @IsTest // Stock Monitoring 
    static void test1(){
        DN_DemandAdjPerAgencyController.PageReturns pages = new DN_DemandAdjPerAgencyController.PageReturns();
        pages.currentPage = 1;
        pages.itemsPerPage = 15;
        pages.orderBy = 'DESC';
        pages.orderByField = 'order by LastModifiedDate';
        pages.pagesPerGroup = 5;
        pages.strQuery = new Map<String,Object>();
        pages.strQuery.put('ABCIndicator','ALL');
        pages.strQuery.put('IsSaveStock','1');
        pages.strQuery.put('MRPType','ALL');
        pages.strQuery.put('productCode',prod.Id);
        DN_DemandAdjPerAgencyController.StockMonitoring stockM = new DN_DemandAdjPerAgencyController.StockMonitoring();
        stockM.id = dealerByMpps.Id;
        stockM.isExcludeStockMonitoring = false;
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_DemandAdjPerAgencyController.getStockMonitoringList(pages,1);
            DN_DemandAdjPerAgencyController.getStockMonitoringExcel(pages,1);
            DN_DemandAdjPerAgencyController.stockMonitoringSave(new List<DN_DemandAdjPerAgencyController.StockMonitoring>{stockM});
        }
        Test.stopTest();
    }


    @IsTest // 지역별 수요조회
    static void test2(){
        DN_DemandAdjPerAgencyController.PageReturn page = new DN_DemandAdjPerAgencyController.PageReturn();
        page.currentPage = 1;
        page.itemsPerPage = 20;
        page.orderBy = 'DESC';
        page.orderByField = 'order by Part__r.ProductCode';
        page.pagesPerGroup = 10;
        page.strQuery = new Map<String,Object>();
        page.strQuery.put('MRPType','All');
        page.strQuery.put('abcIndicatior','ALL');
        page.strQuery.put('area',area.Id);
        page.strQuery.put('productCode',prod.Id);
        System.debug([
            SELECT Area__r.Name Area__c,Part__r.ProductCode,
            AnalysisPeriodMonth__c, SUM(Quantity__c) OrderQuantity__c, 
            SUM(FM_TotalQuantity__c) FM_TotalQuantity__c, 
            SUM(FM_TotalFrequency__c) FM_TotalFrequency__c 
            FROM MonthlyDemandSummaryByRegion__c  
            group by Part__r.ProductCode,Area__r.Name ,AnalysisPeriodMonth__c 
        ] + ' 지역별 수요조회');
        
        
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_DemandAdjPerAgencyController.getAreaListQuery(page,1,'Seach');
            DN_DemandAdjPerAgencyController.getAreaExcelData(page,1);
        }
        Test.stopTest();   
    }


    @IsTest // 대리점별 수요조정
    static void tset3(){
        DN_DemandAdjPerAgencyController.PageReturn page = new DN_DemandAdjPerAgencyController.PageReturn();
        page.currentPage = 1;
        page.itemsPerPage = 1;
        page.orderBy = 'DESC';
        page.orderByField = 'order by Part__r.ProductCode';
        page.pagesPerGroup = 5;
        page.strQuery = new Map<String,Object>();
        page.strQuery.put('MRPType','ALL');
        page.strQuery.put('abcIndicatior','ALL');
        page.strQuery.put('productCode',prod.Id);
        
        
        
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_DemandAdjPerAgencyController.getMonth();
            DN_DemandAdjPerAgencyController.getYYYYMM();
            DN_DemandAdjPerAgencyController.getDataListQuery(page, 1);
            DN_DemandAdjPerAgencyController.setExcelData(page, 1);
            //202409
            Map<String,Object> seleted = new Map<String,Object>();
            seleted.put('part', prod.ProductCode);
            seleted.put('yyyymm', '202409');
            seleted.put('lastParts', 'R18181');
            DN_DemandAdjPerAgencyController.getDetails(seleted,'Dealer');
            DN_DemandAdjPerAgencyController.Details det = new DN_DemandAdjPerAgencyController.Details();
            det.id = orderSum.Id;
            det.currentQuantity = 3;
            DN_DemandAdjPerAgencyController.dealerOrderSummarySave(new List<DN_DemandAdjPerAgencyController.Details>{det},seleted);
        }
        Test.stopTest();
    }

    @IsTest
    static void test4(){
        

        DN_DemandAdjPerAgencyController.Details det = new DN_DemandAdjPerAgencyController.Details();
        Test.startTest();
        System.runAs(partnerTestUser){
            
        }
        Test.stopTest();
        
    }
}