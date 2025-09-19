/** 
 * @Class :  DN_ROPCalculatorBatch_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 29. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-29 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_ROPCalculatorBatch_TEST {
    static String partnerUserName ='partAGLGB@test.test.com';
    static String partnerUserName2 ='part2AGLGB@test.test.com';

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
        Contact con2;
        String dealerId;
        String areaId;
        System.runAs(adminTestUser) {
            Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            insert ifObj;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifObj.Id);
            insert ifClass;

            List<Account> accList = new List<Account>();
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            dealer.DealerGrade__c = 'A';
            dealer.ShippingPostalCode = '01';
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            accList.add(dealer);

            Account dealer2 = TestDataFactoryForDealerPortal.dealer2;
            dealer2.CustomerCode__c = '1233';
            dealer2.DealerGrade__c = 'B';
            accList.add(dealer2);

            Account dealer3 = TestDataFactoryForDealerPortal.createAccountDelear('Test3');
            dealer3.CustomerCode__c = '1234';
            dealer3.DealerGrade__c = 'C';
            accList.add(dealer3);
            insert accList;
            dealerId = dealer.Id;
    
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;

            con2 = TestDataFactoryForDealerPortal.createContact(dealer2.Id);
            insert con2;
    
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerCustomer_Customer', 'DealerCustomer__c', 'Customer', 'C5{000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerOrder_General', 'DealerOrder__c', 'General', 'C8{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerOrder_Emergency', 'DealerOrder__c', 'Emergency', 'C9{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerPurchaseOrder', 'DealerPurchaseOrder__c', 'DealerPO', 'C4{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GI','DealerInventoryMovements__c','GoodsIssue','C6{000000000}'));
            insert sequenceList;

            List<DealerCustomer__c> dealerList = new List<DealerCustomer__c>();
            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            dealerCustomer.IsDealer__c = true;
            dealerList.add(dealerCustomer);
            DealerCustomer__c dealerCustomer2 = TestDataFactoryForDealerPortal.getCustomer(dealer2.Id);
            dealerCustomer2.IsDealer__c = true;
            dealerList.add(dealerCustomer2);
            DealerCustomer__c dealerCustomer3 = TestDataFactoryForDealerPortal.getCustomer(dealer3.Id);
            dealerCustomer3.IsDealer__c = true;
            dealerList.add(dealerCustomer3);
            insert dealerList;
    
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

            AreaByMPPS__c area = TestDataFactoryForDealerPortal.getAreaByMpps();
            insert area;
            areaId = area.Id;

            List<DealerAreaByMPPS__c> dealerMPPSList = new List<DealerAreaByMPPS__c>();
            DealerAreaByMPPS__c dealerMPPS = TestDataFactoryForDealerPortal.getDealerAreaByMPPS(dealer.Id , area.Id);
            dealerMPPSList.add(dealerMPPS);
            insert dealerMPPSList;

            RegionAreaByMPPS__c region = TestDataFactoryForDealerPortal.getRegionAreaByMPPS(area.Id);
            insert region;

            ZipRegionAreaByMPPS__c zipRegionArea = TestDataFactoryForDealerPortal.getZipRegionAreaByMPPS('01', region.Id);
            insert zipRegionArea;

            ABCCriteriaPeriod__c period = TestDataFactoryForDealerPortal.createCalculatePeriod();
            insert period;
        }
    
        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;

        User partnerTestUser2 = TestDataFactoryForDealerPortal.createTestPartPortalUser(con2.Id);
        partnerTestUser2.SalesOrganization__c = '1846';
        partnerTestUser2.DistributionChannel__c = '10';
        partnerTestUser2.Division__c = '40';
        partnerTestUser2.Username = partnerUserName2;
        insert partnerTestUser2;

        System.runAs(adminTestUser) {
        
            List<DealerCustomer__c> dealerCustomerList =  [SELECT Id, OwnerId FROM DealerCustomer__c];
            List<DealerCustomer__Share> dealerCustomerShareList = new List<DealerCustomer__Share>();
            for(DealerCustomer__c dealderCustomer : dealerCustomerList) {
                dealderCustomer.OwnerId = partnerTestUser.Id;
                dealerCustomerShareList.add(new DealerCustomer__Share(
                    ParentId = dealderCustomer.Id,
                    UserOrGroupId = partnerTestUser2.Id,
                    AccessLevel = 'Read'
                ));
            }

            update dealerCustomerList;
            insert dealerCustomerShareList;
        }

        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];
        String accountId;
        WorkOrder serviceOrder;
        ServiceTerritory workCenter;
        Set<String> recordIdSet = new Set<String>();
        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.id);
            insert shipTo;

            TestDataFactoryForDealerPortal.assignFLSPermissionSet(partnerTestUser.Id);
            DN_UserDetails currentUser = new DN_UserDetails();
            accountId = currentUser.getAgencyId();

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

            //ServiceOrder
            Asset equipment = TestDataFactoryForDealerPortal.createEquipment(accountId);
            insert equipment;
            recordIdSet.add(equipment.Id);
            Case ticket = TestDataFactoryForDealerPortal.createCase(equipment.Id);
            insert ticket;
            recordIdSet.add(ticket.Id);
            OperatingHours workTime = TestDataFactoryForDealerPortal.createOperatingHours();
            insert workTime;
            recordIdSet.add(workTime.Id);
            workCenter = TestDataFactoryForDealerPortal.createWorkCenter(accountId, workTime.Id);
            workCenter.Classify__c = 'W/C';
            insert workCenter;
            recordIdSet.add(workCenter.Id);
            ServiceResource worker = TestDataFactoryForDealerPortal.createServiceWorker(partnerTestUser.Id, workCenter.Id);
            insert worker;
            recordIdSet.add(worker.Id);

            serviceOrder = TestDataFactoryForDealerPortal.createServiceOrder(ticket.Id, equipment.Id, accountId, workCenter.Id, worker.Id);
            serviceOrder.ServiceOrderNumber__c = '403906564';
            insert serviceOrder;
            recordIdSet.add(serviceOrder.Id);

            //DealerOrder
            DealerOrder__c order = TestDataFactoryForDealerPortal.getOrder(currentUser.getAgencyId(), customer.id);
            order.Address__PostalCode__s = '01';
            insert order;
            List<DealerOrderItem__c> orderItemList = new List<DealerOrderItem__c>();
            DealerOrderItem__c orderItem = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[0].id, partList[0].id);
            orderItemList.add(orderItem);
            DealerOrderItem__c orderItem2 = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[1].id, partList[1].id);
            orderItemList.add(orderItem2);
            insert orderItemList;

            List<DealerOrderSummary__c> orderSummaryList = new List<DealerOrderSummary__c>();
            DealerOrderSummary__c orderSummary = TestDataFactoryForDealerPortal.createDealerOrderSummary(dealerId, orderItem.Id, partList[0].Id, areaId);
            System.debug('orderSummary.CreatedDateTime__c :' + orderSummary.CreatedDateTime__c);
            orderSummaryList.add(orderSummary);
            DealerOrderSummary__c orderSummary2 = TestDataFactoryForDealerPortal.createDealerOrderSummary(dealerId, orderItem2.Id, partList[1].Id, areaId);
            System.debug('orderSummary2.CreatedDateTime__c :' + orderSummary2.CreatedDateTime__c);
            orderSummaryList.add(orderSummary2);
            insert orderSummaryList;
            
        }

        System.runAs(adminTestUser) {
            
            ProductRequest partClaim = TestDataFactoryForDealerPortal.createPartClaim(serviceOrder.Id, partList[0].Id);
            partClaim.OwnerId = partnerTestUser.Id;
            partClaim.ShipTo__c = workCenter.Id;
            insert partClaim;

            DealerFreeDispatch__c freeClaim = TestDataFactoryForDealerPortal.createFreeClaim(partClaim.Id, accountId);
            freeClaim.Status__c = '2';
            freeClaim.ShippingType__c = '1';
            freeClaim.OwnerId = partnerTestUser.Id;
            freeClaim.IsDemandCapture__c = true;
            insert freeClaim;
            recordIdSet.add(freeClaim.Id);

            DealerOrderSummary__c orderSummary = TestDataFactoryForDealerPortal.createDealerOrderSummary(dealerId, partClaim.Id, partList[0].Id, areaId);
            System.debug('service orderSummary.CreatedDateTime__c :' + orderSummary.CreatedDateTime__c);
            insert orderSummary;
            
            

            List<ABCGradeFrequencyCriteria__c> frequencyList = new List<ABCGradeFrequencyCriteria__c>();
            ABCGradeFrequencyCriteria__c frequencyCriteriaH = TestDataFactoryForDealerPortal.createGradeFrequencyCriteria('H', 6, accountId);
            frequencyList.add(frequencyCriteriaH);
            ABCGradeFrequencyCriteria__c frequencyCriteriaM = TestDataFactoryForDealerPortal.createGradeFrequencyCriteria('M', 3, accountId);
            frequencyList.add(frequencyCriteriaM);
            ABCGradeFrequencyCriteria__c frequencyCriteriaL = TestDataFactoryForDealerPortal.createGradeFrequencyCriteria('L', 0, accountId);
            frequencyList.add(frequencyCriteriaL);
            ABCGradeFrequencyCriteria__c frequencyCriteriaH2 = TestDataFactoryForDealerPortal.createGradeFrequencyCriteria('H', 6, areaId);
            frequencyList.add(frequencyCriteriaH2);
            ABCGradeFrequencyCriteria__c frequencyCriteriaM2 = TestDataFactoryForDealerPortal.createGradeFrequencyCriteria('M', 3, areaId);
            frequencyList.add(frequencyCriteriaM2);
            ABCGradeFrequencyCriteria__c frequencyCriteriaL2 = TestDataFactoryForDealerPortal.createGradeFrequencyCriteria('L', 0, areaId);
            frequencyList.add(frequencyCriteriaL2);
            insert frequencyList;

            List<ABCGradeAmountCriteria__c> amountList = new List<ABCGradeAmountCriteria__c>();
            ABCGradeAmountCriteria__c amountCriteriaH = TestDataFactoryForDealerPortal.createGradeAmountCriteria('H', 100, accountId);
            amountList.add(amountCriteriaH);
            ABCGradeAmountCriteria__c amountCriteriaM = TestDataFactoryForDealerPortal.createGradeAmountCriteria('M', 95, accountId);
            amountList.add(amountCriteriaM);
            ABCGradeAmountCriteria__c amountCriteriaL = TestDataFactoryForDealerPortal.createGradeAmountCriteria('L', 70, accountId);
            amountList.add(amountCriteriaL);
            ABCGradeAmountCriteria__c amountCriteriaH2 = TestDataFactoryForDealerPortal.createGradeAmountCriteria('H', 100, areaId);
            amountList.add(amountCriteriaH2);
            ABCGradeAmountCriteria__c amountCriteriaM2 = TestDataFactoryForDealerPortal.createGradeAmountCriteria('M', 95, areaId);
            amountList.add(amountCriteriaM2);
            ABCGradeAmountCriteria__c amountCriteriaL2 = TestDataFactoryForDealerPortal.createGradeAmountCriteria('L', 70, areaId);
            amountList.add(amountCriteriaL2);
            insert amountList;

            List<ROPAndStockFactorConfig__c> configs = new List<ROPAndStockFactorConfig__c>();
            ROPAndStockFactorConfig__c config = TestDataFactoryForDealerPortal.createRopConfig(accountId);
            config.Dealer__c = accountId;
            config.PriceTo__c = 99999999;
            configs.add(config);

            ROPAndStockFactorConfig__c config2 = TestDataFactoryForDealerPortal.createAreaRopCalculation();
            config2.Dealer__c = accountId;
            configs.add(config2);
            insert configs;
        }
    }

    @isTest 
    static void manual_TEST() {
        //ROP Calculation
        Map<String,Double> mockData = new Map<String,Double>{
            '202311'=>	0, 
            '202312'=>	0, 
            '202401'=>	0, 
            '202402'=>	0, 
            '202403'=>	0, 
            '202404'=>	0, 
            '202405'=>	2, 
            '202406'=>	4, 
            '202407'=>  0, 
            '202408'=>  0, 
            '202409'=>  1, 
            '202410'=>  0, 
            '202411'=>  1, 
            '202412'=>  1, 
            '202501'=>  1, 
            '202502'=>  0, 
            '202503'=>  0,
            '202504'=>  0
        };
        
        DN_ROPCalculatorBatch.ForcastDemandData forcastData = new DN_ROPCalculatorBatch.ForcastDemandData(18);
        for(String key : mockData.keySet()) {
            forcastData.changeDemandForValue(key,mockData.get(key));
        }

        forcastData.calculateMonthDemandUpTo(18);
        System.debug(JSON.serializePretty(forcastData));

        DN_ROPCalculatorBatch ropBatch = new DN_ROPCalculatorBatch(DN_ROPCalculatorBatch.SummaryType.DEALER, null);
        Double pdt = 180.0;
        Double svcFactor = 1.75;
        Double weight = 0;
        forcastData.wamd = ((Decimal)forcastData.wamd).setScale(3, RoundingMode.HALF_UP);
        forcastData.standardDeviation = ((Decimal)forcastData.standardDeviation).setScale(3, RoundingMode.HALF_UP);
        System.debug('amd : '+forcastData.amd);
        System.debug('wamd : '+forcastData.wamd);
        System.debug('avgDemand : '+forcastData.avgDemand);
        System.debug('standardDeviation : '+forcastData.standardDeviation);
        Double safteyStock = ((Decimal)ropBatch.calculateSafetyStock(svcFactor, forcastData.standardDeviation, Double.valueOf(Math.sqrt(pdt/30.0)))).setScale(3, RoundingMode.HALF_UP);
        System.debug('safteyStock : ' + safteyStock);
        Double maxModeAmdRop = Math.ceil(ropBatch.calculateROPMax(forcastData.amd, Double.valueOf(pdt), 0));
        System.debug('Max Level Rounding Mode amdRop : ' + maxModeAmdRop);
        Double maxModeMaxAmdRopLevel = Math.ceil(maxModeAmdRop + safteyStock * weight);
        System.debug('Max Level Rounding Mode maxModeMaxAmdRopLevel : ' + maxModeMaxAmdRopLevel);
        Double maxModeWamdRop = Math.ceil(ropBatch.calculateROPMax(forcastData.wamd, Double.valueOf(pdt), 0));
        System.debug('Max Level Rounding Mode wamdRop : ' + maxModeWamdRop);
        Double maxModeMaxWAmdRopLevel = Math.ceil(maxModeWamdRop + safteyStock * weight);
        System.debug('Max Level Rounding Mode maxModeMaxWAmdRopLevel : ' + maxModeMaxWAmdRopLevel);


        Double maxModeAmdRopSafety = ropBatch.calculateROPMax(forcastData.amd, Double.valueOf(pdt), safteyStock);
        System.debug('Max Level Rounding Mode amdRop + Safety : ' + Math.ceil(maxModeAmdRopSafety));
        Double maxModeAmdRopSafetyLevel = Math.ceil(maxModeAmdRopSafety + safteyStock * weight);
        System.debug('Max Level Rounding Mode maxModeAmdRopSafetyLevel : ' + maxModeAmdRopSafetyLevel);
        Double maxModeWamdRopSafety = ropBatch.calculateROPMax(forcastData.wamd, Double.valueOf(pdt), safteyStock);
        System.debug('Max Level Rounding Mode wamdRop + Safety : ' + Math.ceil(maxModeWamdRopSafety));
        Double maxModeWamdRopSafetyLevel = Math.ceil(maxModeWamdRopSafety + safteyStock * weight);
        System.debug('Max Level Rounding Mode maxModeWamdRopSafetyLevel : ' + maxModeWamdRopSafetyLevel);

        Double fixedPDT= Double.valueOf(pdt/30.0 + weight);
        System.debug('fixedPDT : ' +fixedPDT);
        System.debug('fixedamd : '+forcastData.amd);
        System.debug(' 직접계산 amd :' + (forcastData.amd * fixedPDT));
        Double fixModeAmdRop = ropBatch.calculateROPFixed(forcastData.amd, fixedPDT, 0);
        System.debug('Fixed Mode. amdRop : ' + Math.ceil(fixModeAmdRop));
        System.debug('Fixed Mode. amdRop + safety : ' + Math.ceil((fixModeAmdRop + safteyStock)));

        System.debug('fixedwamd : '+forcastData.wamd);
        Double fixModeWamdRop = ropBatch.calculateROPFixed(forcastData.wamd, fixedPDT, 0);
        System.debug('Fixed Mode. wamdRop : ' + Math.ceil(fixModeWamdRop));
        System.debug('Fixed Mode. wamdRop + safety : ' + Math.ceil(fixModeWamdRop + safteyStock));

    }

    @isTest
    static void execute_Dealer_TEST() {
        DN_ROPCalculatorBatch batch = new DN_ROPCalculatorBatch(DN_ROPCalculatorBatch.SummaryType.DEALER);
        DateTime today = System.now();
        
        List<Account> accountList = [SELECT Id, CustomerCode__c FROM Account];
        Account dealer = accountList[0];
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        List<MonthlyDemandSummaryByDealer__c> summaryDealers = new List<MonthlyDemandSummaryByDealer__c>();
        for(Integer i=1; i<19; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[0].Id);
            summaryDealer.Quantity__c = 1;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        for(Integer i=1; i<19; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[1].Id);
            summaryDealer.Quantity__c = 2;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        insert summaryDealers;

        DealerPartMasterByMPPS__c partMasterMpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(partList[0].Id, dealer.Id);
        partMasterMpps.ABCIndicator__c = 'A';
        partMasterMpps.ExternalKey__c = partList[0].ProductCode + '_' + dealer.CustomerCode__c;
        insert partMasterMpps;

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void execute_Dealer2_TEST() {
        DN_ROPCalculatorBatch batch = new DN_ROPCalculatorBatch(DN_ROPCalculatorBatch.SummaryType.DEALER);
        DateTime today = System.now();
        
        List<Account> accountList = [SELECT Id, CustomerCode__c FROM Account];
        Account dealer = accountList[0];
        batch.setTargetId(dealer.Id).setRemainIds(new Set<String>());
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        List<MonthlyDemandSummaryByDealer__c> summaryDealers = new List<MonthlyDemandSummaryByDealer__c>();
        for(Integer i=1; i<37; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[0].Id);
            summaryDealer.Quantity__c = 1;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        for(Integer i=1; i<37; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[1].Id);
            summaryDealer.Quantity__c = 2;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        insert summaryDealers;

        DealerPartMasterByMPPS__c partMasterMpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(partList[0].Id, dealer.Id);
        partMasterMpps.ABCIndicator__c = 'A';
        partMasterMpps.ExternalKey__c = partList[0].ProductCode + '_' + dealer.CustomerCode__c;
        insert partMasterMpps;

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void execute_Region_TEST() {
        DN_ROPCalculatorBatch batch = new DN_ROPCalculatorBatch(DN_ROPCalculatorBatch.SummaryType.REGION);
        DateTime today = System.now();
        
        List<Account> accountList = [SELECT Id, CustomerCode__c FROM Account];
        List<AreaByMPPS__c> areaList = [SELECT Id, Area__c FROM AreaByMPPS__c];
        Account dealer = accountList[0];
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        List<MonthlyDemandSummaryByRegion__c> summaryDealers = new List<MonthlyDemandSummaryByRegion__c>();
        for(Integer i=1; i<19; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByRegion__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByRegion(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), areaList[0].Id, partList[0].Id);
            summaryDealer.Quantity__c = 1;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        for(Integer i=1; i<19; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByRegion__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByRegion(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), areaList[0].Id, partList[1].Id);
            summaryDealer.Quantity__c = 2;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        insert summaryDealers;

        AreaPartMasterByMPPS__c partMasterMpps = TestDataFactoryForDealerPortal.getAreaPartByMpps(areaList[0].Id,partList[0].Id);
        partMasterMpps.ABCIndicator__c = 'A';
        partMasterMpps.ExternalKey__c = partList[0].ProductCode + '_' + areaList[0].Area__c;
        insert partMasterMpps;

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    
    @isTest
    static void execute_Region2_TEST() {
        DN_ROPCalculatorBatch batch = new DN_ROPCalculatorBatch(DN_ROPCalculatorBatch.SummaryType.REGION);
        DateTime today = System.now();
        
        List<Account> accountList = [SELECT Id, CustomerCode__c FROM Account];
        List<AreaByMPPS__c> areaList = [SELECT Id, Area__c FROM AreaByMPPS__c];
        batch.setTargetId(areaList[0].Id);
        Account dealer = accountList[0];
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        List<MonthlyDemandSummaryByRegion__c> summaryDealers = new List<MonthlyDemandSummaryByRegion__c>();
        for(Integer i=1; i<37; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByRegion__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByRegion(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), areaList[0].Id, partList[0].Id);
            summaryDealer.Quantity__c = 1;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        for(Integer i=1; i<37; i++) {
            DateTime beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByRegion__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByRegion(DN_ROPCalculatorBatch.getYearMonthFrom(beforeDate), areaList[0].Id, partList[1].Id);
            summaryDealer.Quantity__c = 2;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        insert summaryDealers;

        AreaPartMasterByMPPS__c partMasterMpps = TestDataFactoryForDealerPortal.getAreaPartByMpps(areaList[0].Id,partList[0].Id);
        partMasterMpps.ABCIndicator__c = 'A';
        partMasterMpps.ExternalKey__c = partList[0].ProductCode + '_' + areaList[0].Area__c;
        insert partMasterMpps;

        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}