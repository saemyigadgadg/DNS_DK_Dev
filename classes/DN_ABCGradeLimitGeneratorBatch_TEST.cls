/** 
 * @Class :  DN_ABCGradeLimitGeneratorBatch_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 28. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-28 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_ABCGradeLimitGeneratorBatch_TEST {
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

            
            
        }
    }

    @isTest
    static void exceucte_Dealer() {
        DN_ABCGradeLimitGeneratorBatch batch = new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.DEALER);
        Date today = Date.today();
        
        List<Account> accountList = [SELECT Id, CustomerCode__c FROM Account];
        Account dealer = accountList[0];
        List<Product2> partList = [SELECT Id FROM Product2];

        List<ABCIndicatorMatrix__c> abcIndicatorList = new List<ABCIndicatorMatrix__c>();
        ABCIndicatorMatrix__c abcIndicator1 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'H', 'A');
        abcIndicator1.ExternalKey__c = abcIndicator1.AmountGrade__c +'_'+abcIndicator1.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator1);
        ABCIndicatorMatrix__c abcIndicator2 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'M', 'D');
        abcIndicator2.ExternalKey__c = abcIndicator2.AmountGrade__c +'_'+abcIndicator2.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator2);
        ABCIndicatorMatrix__c abcIndicator3 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'L', 'G');
        abcIndicator3.ExternalKey__c = abcIndicator3.AmountGrade__c +'_'+abcIndicator3.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator3);
        ABCIndicatorMatrix__c abcIndicator4 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'H', 'B');
        abcIndicator4.ExternalKey__c = abcIndicator4.AmountGrade__c +'_'+abcIndicator4.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator4);
        ABCIndicatorMatrix__c abcIndicator5 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'M', 'E');
        abcIndicator5.ExternalKey__c = abcIndicator5.AmountGrade__c +'_'+abcIndicator5.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator5);
        ABCIndicatorMatrix__c abcIndicator6 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'L', 'H');
        abcIndicator6.ExternalKey__c = abcIndicator6.AmountGrade__c +'_'+abcIndicator6.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator6);
        ABCIndicatorMatrix__c abcIndicator7 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'H', 'C');
        abcIndicator7.ExternalKey__c = abcIndicator7.AmountGrade__c +'_'+abcIndicator7.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator7);
        ABCIndicatorMatrix__c abcIndicator8 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'M', 'F');
        abcIndicator8.ExternalKey__c = abcIndicator8.AmountGrade__c +'_'+abcIndicator8.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator8);
        ABCIndicatorMatrix__c abcIndicator9 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'L', 'I');
        abcIndicator9.ExternalKey__c = abcIndicator9.AmountGrade__c +'_'+abcIndicator9.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator9);
        insert abcIndicatorList;
        
        List<MonthlyDemandSummaryByDealer__c> summaryDealers = new List<MonthlyDemandSummaryByDealer__c>();
        for(Integer i=1; i<19; i++) {
            Date beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(batch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[0].Id);
            summaryDealer.Quantity__c = 1;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        for(Integer i=1; i<19; i++) {
            Date beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(batch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[1].Id);
            summaryDealer.Quantity__c = 2;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        insert summaryDealers;

        Test.startTest();

        // Database.executeBatch(batch);
        Set<String> dealerIds = new Set<String>();
        for(User user : [ SELECT AccountId, Account.CustomerCode__c FROM User WHERE UserType = 'PowerPartner' and Profile.Name ='DNS CS Parts_Partner' ]) {
            dealerIds.add(user.AccountId);
        }
        Database.executeBatch(new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.DEALER, dealerIds), 200);

        Test.stopTest();
    }

    @isTest
    static void exceucte_Dealer2() {
        DN_ABCGradeLimitGeneratorBatch batch = new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.DEALER);
        Date today = Date.today();
        
        List<Account> accountList = [SELECT Id, CustomerCode__c FROM Account];
        Account dealer = accountList[0];
        List<Product2> partList = [SELECT Id FROM Product2];

        List<ABCIndicatorMatrix__c> abcIndicatorList = new List<ABCIndicatorMatrix__c>();
        ABCIndicatorMatrix__c abcIndicator1 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'H', 'A');
        abcIndicator1.ExternalKey__c = abcIndicator1.AmountGrade__c +'_'+abcIndicator1.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator1);
        ABCIndicatorMatrix__c abcIndicator2 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'M', 'D');
        abcIndicator2.ExternalKey__c = abcIndicator2.AmountGrade__c +'_'+abcIndicator2.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator2);
        ABCIndicatorMatrix__c abcIndicator3 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'L', 'G');
        abcIndicator3.ExternalKey__c = abcIndicator3.AmountGrade__c +'_'+abcIndicator3.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator3);
        ABCIndicatorMatrix__c abcIndicator4 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'H', 'B');
        abcIndicator4.ExternalKey__c = abcIndicator4.AmountGrade__c +'_'+abcIndicator4.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator4);
        ABCIndicatorMatrix__c abcIndicator5 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'M', 'E');
        abcIndicator5.ExternalKey__c = abcIndicator5.AmountGrade__c +'_'+abcIndicator5.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator5);
        ABCIndicatorMatrix__c abcIndicator6 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'L', 'H');
        abcIndicator6.ExternalKey__c = abcIndicator6.AmountGrade__c +'_'+abcIndicator6.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator6);
        ABCIndicatorMatrix__c abcIndicator7 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'H', 'C');
        abcIndicator7.ExternalKey__c = abcIndicator7.AmountGrade__c +'_'+abcIndicator7.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator7);
        ABCIndicatorMatrix__c abcIndicator8 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'M', 'F');
        abcIndicator8.ExternalKey__c = abcIndicator8.AmountGrade__c +'_'+abcIndicator8.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator8);
        ABCIndicatorMatrix__c abcIndicator9 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'L', 'I');
        abcIndicator9.ExternalKey__c = abcIndicator9.AmountGrade__c +'_'+abcIndicator9.FrequencyGrade__c+'_'+dealer.CustomerCode__c;
        abcIndicatorList.add(abcIndicator9);
        insert abcIndicatorList;
        
        List<MonthlyDemandSummaryByDealer__c> summaryDealers = new List<MonthlyDemandSummaryByDealer__c>();
        for(Integer i=1; i<19; i++) {
            Date beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(batch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[0].Id);
            summaryDealer.Quantity__c = 1;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        for(Integer i=1; i<19; i++) {
            Date beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByDealer__c summaryDealer = TestDataFactoryForDealerPortal.createMonthlySummaryByDealer(batch.getYearMonthFrom(beforeDate), accountList[0].Id, partList[1].Id);
            summaryDealer.Quantity__c = 2;
            summaryDealer.Frequency__c = 1;
            System.debug(summaryDealer.AnalysisPeriodMonth__c);
            summaryDealers.add(summaryDealer);
        }

        insert summaryDealers;

        Test.startTest();

        Database.executeBatch(batch);
        

        Test.stopTest();
    }

    @isTest
    static void exceucte_Region() {
        DN_ABCGradeLimitGeneratorBatch batch = new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.REGION);
        Date today = Date.today();
        
        List<AreaByMPPS__c> areaList = [SELECT Id, Area__c FROM AreaByMPPS__c];
        AreaByMPPS__c area = areaList[0];
        List<Product2> partList = [SELECT Id FROM Product2];

        List<ABCIndicatorMatrix__c> abcIndicatorList = new List<ABCIndicatorMatrix__c>();
        ABCIndicatorMatrix__c abcIndicator1 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'H', 'A');
        abcIndicator1.ExternalKey__c = abcIndicator1.AmountGrade__c +'_'+abcIndicator1.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator1);
        ABCIndicatorMatrix__c abcIndicator2 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'M', 'D');
        abcIndicator2.ExternalKey__c = abcIndicator2.AmountGrade__c +'_'+abcIndicator2.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator2);
        ABCIndicatorMatrix__c abcIndicator3 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'L', 'G');
        abcIndicator3.ExternalKey__c = abcIndicator3.AmountGrade__c +'_'+abcIndicator3.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator3);
        ABCIndicatorMatrix__c abcIndicator4 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'H', 'B');
        abcIndicator4.ExternalKey__c = abcIndicator4.AmountGrade__c +'_'+abcIndicator4.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator4);
        ABCIndicatorMatrix__c abcIndicator5 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'M', 'E');
        abcIndicator5.ExternalKey__c = abcIndicator5.AmountGrade__c +'_'+abcIndicator5.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator5);
        ABCIndicatorMatrix__c abcIndicator6 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'L', 'H');
        abcIndicator6.ExternalKey__c = abcIndicator6.AmountGrade__c +'_'+abcIndicator6.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator6);
        ABCIndicatorMatrix__c abcIndicator7 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'H', 'C');
        abcIndicator7.ExternalKey__c = abcIndicator7.AmountGrade__c +'_'+abcIndicator7.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator7);
        ABCIndicatorMatrix__c abcIndicator8 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'M', 'F');
        abcIndicator8.ExternalKey__c = abcIndicator8.AmountGrade__c +'_'+abcIndicator8.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator8);
        ABCIndicatorMatrix__c abcIndicator9 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'L', 'I');
        abcIndicator9.ExternalKey__c = abcIndicator9.AmountGrade__c +'_'+abcIndicator9.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator9);
        insert abcIndicatorList;
        
        List<MonthlyDemandSummaryByRegion__c> summaryRegions = new List<MonthlyDemandSummaryByRegion__c>();
        for(Integer i=1; i<19; i++) {
            Date beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByRegion__c summaryRegion = TestDataFactoryForDealerPortal.createMonthlySummaryByRegion(batch.getYearMonthFrom(beforeDate), areaList[0].Id, partList[0].Id);
            summaryRegions.add(summaryRegion);
        }
        insert summaryRegions;


        Test.startTest();

        // Database.executeBatch(batch);
        Set<String> regionIds = new Set<String>();
        for(AreaByMPPS__c region : [ SELECT Id FROM AreaByMPPS__c ]) {
            regionIds.add(region.Id);
        }
        Database.executeBatch(new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.REGION, regionIds), 200);

        Test.stopTest();
    }

    @isTest
    static void exceucte_Region2() {
        DN_ABCGradeLimitGeneratorBatch batch = new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.REGION);
        Date today = Date.today();
        
        List<AreaByMPPS__c> areaList = [SELECT Id, Area__c FROM AreaByMPPS__c];
        AreaByMPPS__c area = areaList[0];
        List<Product2> partList = [SELECT Id FROM Product2];

        List<ABCIndicatorMatrix__c> abcIndicatorList = new List<ABCIndicatorMatrix__c>();
        ABCIndicatorMatrix__c abcIndicator1 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'H', 'A');
        abcIndicator1.ExternalKey__c = abcIndicator1.AmountGrade__c +'_'+abcIndicator1.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator1);
        ABCIndicatorMatrix__c abcIndicator2 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'M', 'D');
        abcIndicator2.ExternalKey__c = abcIndicator2.AmountGrade__c +'_'+abcIndicator2.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator2);
        ABCIndicatorMatrix__c abcIndicator3 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('H', 'L', 'G');
        abcIndicator3.ExternalKey__c = abcIndicator3.AmountGrade__c +'_'+abcIndicator3.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator3);
        ABCIndicatorMatrix__c abcIndicator4 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'H', 'B');
        abcIndicator4.ExternalKey__c = abcIndicator4.AmountGrade__c +'_'+abcIndicator4.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator4);
        ABCIndicatorMatrix__c abcIndicator5 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'M', 'E');
        abcIndicator5.ExternalKey__c = abcIndicator5.AmountGrade__c +'_'+abcIndicator5.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator5);
        ABCIndicatorMatrix__c abcIndicator6 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('M', 'L', 'H');
        abcIndicator6.ExternalKey__c = abcIndicator6.AmountGrade__c +'_'+abcIndicator6.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator6);
        ABCIndicatorMatrix__c abcIndicator7 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'H', 'C');
        abcIndicator7.ExternalKey__c = abcIndicator7.AmountGrade__c +'_'+abcIndicator7.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator7);
        ABCIndicatorMatrix__c abcIndicator8 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'M', 'F');
        abcIndicator8.ExternalKey__c = abcIndicator8.AmountGrade__c +'_'+abcIndicator8.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator8);
        ABCIndicatorMatrix__c abcIndicator9 = TestDataFactoryForDealerPortal.createABCIndicatorMatrix('L', 'L', 'I');
        abcIndicator9.ExternalKey__c = abcIndicator9.AmountGrade__c +'_'+abcIndicator9.FrequencyGrade__c+'_'+area.Area__c;
        abcIndicatorList.add(abcIndicator9);
        insert abcIndicatorList;
        
        List<MonthlyDemandSummaryByRegion__c> summaryRegions = new List<MonthlyDemandSummaryByRegion__c>();
        for(Integer i=1; i<19; i++) {
            Date beforeDate = today.addMonths(i*(-1));
            MonthlyDemandSummaryByRegion__c summaryRegion = TestDataFactoryForDealerPortal.createMonthlySummaryByRegion(batch.getYearMonthFrom(beforeDate), areaList[0].Id, partList[0].Id);
            summaryRegions.add(summaryRegion);
        }
        insert summaryRegions;


        Test.startTest();

        Database.executeBatch(batch);

        Test.stopTest();
    }
}