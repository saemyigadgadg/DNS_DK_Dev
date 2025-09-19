/** 
 * @Class :  DN_MonthlyDemandSummaryBatch_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 27. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-27 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_MonthlyDemandSummaryBatch_TEST {
    static String partnerUserName ='partMDSB@test.test.com';
    static String partnerUserName2 ='part2MDSB@test.test.com';

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
        }
    }

    public class IF_PARTS_022_HttpMock implements HttpCalloutMock {
        String resBody;
        
        public IF_PARTS_022_HttpMock(String resBody){
            this.resBody = resBody;
        }

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @isTest
    static void dealerOrderSummary() {
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"R18182","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"},{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18182","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"}],"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock(resBody));
        Test.startTest();

        Database.executeBatch(new DN_MonthlyDemandSummaryBatch(DN_MonthlyDemandSummaryBatch.SummaryType.DEALER));

        Test.stopTest();
    }

    @isTest
    static void regionOrderSummary() {
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"R18182","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"},{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18182","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"}],"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock(resBody));
        Test.startTest();

        Database.executeBatch(new DN_MonthlyDemandSummaryBatch(DN_MonthlyDemandSummaryBatch.SummaryType.REGION));

        Test.stopTest();
    }
}