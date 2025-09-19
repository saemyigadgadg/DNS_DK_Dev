@isTest
public with sharing class DN_WarrantyPartsManagement_TEST {
    static String partnerUserName ='partWPM@test.test.com';
    static String partnerUserName2 ='part2WPM@test.test.com';

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
        System.runAs(adminTestUser) {
            List<Interface__c> ifObjList = new List<Interface__c>();
            Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-009', 'Real-Time');
            ifObjList.add(ifObj);
            Interface__c ifObj2 = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            ifObjList.add(ifObj2);
            Interface__c ifObj3 = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-015', 'Real-Time');
            ifObjList.add(ifObj3);
            insert ifObjList;

            List<InterfaceClasses__c> ifClassList = new List<InterfaceClasses__c>();
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj.Id);
            ifClassList.add(ifClass);

            InterfaceClasses__c ifClass2 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifObj2.Id);
            ifClassList.add(ifClass2);
            insert ifClassList;

            

            List<Account> accList = new List<Account>();
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            dealer.DealerGrade__c = 'A';
            dealer.DealerGrade_Parts__c = 'A'; 
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            accList.add(dealer);

            Account dealer2 = TestDataFactoryForDealerPortal.dealer2;
            dealer2.CustomerCode__c = '1233';
            dealer2.DealerGrade__c = 'B';
            dealer2.DealerGrade_Parts__c = 'B'; 
            accList.add(dealer2);

            Account dealer3 = TestDataFactoryForDealerPortal.createAccountDelear('Test3');
            dealer3.CustomerCode__c = '1234';
            dealer3.DealerGrade__c = 'C';
            dealer3.DealerGrade_Parts__c = 'C'; 
            accList.add(dealer3);
            insert accList;
    
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

        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.id);
            insert shipTo;
        }
    }

    @isTest
    static void init_TEST() {
        String resBody = '{"T_RETURN":[{"ZZKVGR4":"A","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-22.50","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"B","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-15.00","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"C","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-12.00","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"D","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-13.35","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2016-05-02","KZBZG":""}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Success"}}';
        Test.setMock(HttpCalloutMock.class, new DN_UserDetails_TEST.IF_DEALERSTOCK_009_HttpMock(resBody));
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        DN_DealerPortalDisplayController.PageReturn page = new DN_DealerPortalDisplayController.PageReturn();
        page.itemsPerPage = 1;

        System.runAs(partPortalUser) {
            DN_WarrantyPartsManagement.init();
        }
        Test.stopTest();
    }

    @isTest
    static void searchWarrnatyItems_completeGoodsIssue_Test() {
        DN_DealerPortalDisplayController.PageReturn page = new DN_DealerPortalDisplayController.PageReturn();
        page.itemsPerPage = 1;
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"R18182","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"},{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18182","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"}],"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock(resBody));
        
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        String accountId;
        WorkOrder serviceOrder;
        ServiceTerritory workCenter;
        Set<String> recordIdSet = new Set<String>();
        System.runAs(partPortalUser) {
            TestDataFactoryForDealerPortal.assignFLSPermissionSet(partPortalUser.Id);
            DN_UserDetails currentUser = new DN_UserDetails();
            accountId = currentUser.getAgencyId();
            DealerStock__c stock = TestDataFactoryForDealerPortal.createDealerStock(accountId, partList[0].Id);
            stock.CurrentStockQuantity__c = stock.AvailableQuantity__c = 10;
            stock.ExternalKey__c = currentUser.getSalesOranization()+'-'+currentUser.getDistributionChannel()+'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+partList[0].ProductCode;
            insert stock;

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
            ServiceResource worker = TestDataFactoryForDealerPortal.createServiceWorker(partPortalUser.Id, workCenter.Id);
            insert worker;
            recordIdSet.add(worker.Id);

            serviceOrder = TestDataFactoryForDealerPortal.createServiceOrder(ticket.Id, equipment.Id, accountId, workCenter.Id, worker.Id);
            insert serviceOrder;
            recordIdSet.add(serviceOrder.Id);
        }

        
        ProductRequest partClaim = TestDataFactoryForDealerPortal.createPartClaim(serviceOrder.Id, partList[0].Id);
        partClaim.OwnerId = partPortalUser.Id;
        partClaim.ShipTo__c = workCenter.Id;
        insert partClaim;

        DealerFreeDispatch__c freeClaim = TestDataFactoryForDealerPortal.createFreeClaim(partClaim.Id, accountId);
        freeClaim.Status__c = '1';
        freeClaim.ShippingType__c = '1';
        freeClaim.OwnerId = partPortalUser.Id;
        freeClaim.Dealer__c = accountId;
        insert freeClaim;
        recordIdSet.add(freeClaim.Id);
        
        Test.startTest();
        System.runAs(partPortalUser) {
            SchemaInfo schema = new SchemaInfo();
            //권한 체크용        
            Map<String, UserRecordAccess> recordAccess = schema.getUserAccesses(partPortalUser.Id, recordIdSet);
            // System.debug(JSON.serializePretty(recordAccess));

            Map<String,Object> result = DN_WarrantyPartsManagement.searchWarrnatyItems(
                '',
                null,
                null,
                page,
                1
            );

            List<DN_WarrantyPartsManagement.DealerFreeDispatch> warrantyList = (List<DN_WarrantyPartsManagement.DealerFreeDispatch>) result.get('warrantyList');
            //출고완료
            DN_WarrantyPartsManagement.completeGoodsIssue(warrantyList, null);
            //업데이트
            DN_WarrantyPartsManagement.updateWarranty(warrantyList);
            //Claim Order 정보 조회
            DN_WarrantyPartsManagement.warrantyDetailInit(warrantyList[0].serviceOrderSeq);
            //정산 상태값 업데이트
            try {
                //확정완료 - 성공
                warrantyList[0].status = '4';
                DN_WarrantyPartsManagement.statusUpdate(warrantyList, '2');
                //확정완료 - 실패
                warrantyList[0].status = '2';
                DN_WarrantyPartsManagement.statusUpdate(warrantyList, '2');
            }catch (Exception e) {
                System.debug(e.getMessage());
            }

            try {
                //정산대상 - 성공
                warrantyList[0].status = '2';
                DN_WarrantyPartsManagement.statusUpdate(warrantyList, '4');

                //정산대상 - 실패
                warrantyList[0].status = '2';
                DN_WarrantyPartsManagement.statusUpdate(warrantyList, '5');
            }catch (Exception e) {
                System.debug(e.getMessage());
            }

            try {
                //정산완료 - 성공
                warrantyList[0].status = '4';
                DN_WarrantyPartsManagement.statusUpdate(warrantyList, '5');

                //정산완료 - 실패
                warrantyList[0].status = '4';
                DN_WarrantyPartsManagement.statusUpdate(warrantyList, '1');
            }catch (Exception e) {
                System.debug(e.getMessage());
            }

            try {
                //확정대기
                warrantyList[0].status = '1';
                DN_WarrantyPartsManagement.statusUpdate(warrantyList, '2');
            }catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        System.runAs(new User(Id=UserInfo.getUserId())) {
            DN_WarrantyPartsManagement.searchCostWarrnatyItems(
                '',
                null,
                null,
                '',
                null
            );
        }

        Test.stopTest();
    }

    @isTest
    static void statusUpdate_TEST() {

        DN_DealerPortalDisplayController.PageReturn page = new DN_DealerPortalDisplayController.PageReturn();
        page.itemsPerPage = 1;
        Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_015_HttpMock());
        
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        String accountId;
        WorkOrder serviceOrder;
        ServiceTerritory workCenter;
        Set<String> recordIdSet = new Set<String>();
        System.runAs(partPortalUser) {
            TestDataFactoryForDealerPortal.assignFLSPermissionSet(partPortalUser.Id);
            DN_UserDetails currentUser = new DN_UserDetails();
            accountId = currentUser.getAgencyId();
            DealerStock__c stock = TestDataFactoryForDealerPortal.createDealerStock(accountId, partList[0].Id);
            stock.CurrentStockQuantity__c = stock.AvailableQuantity__c = 10;
            stock.ExternalKey__c = currentUser.getSalesOranization()+'-'+currentUser.getDistributionChannel()+'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+partList[0].ProductCode;
            insert stock;

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
            ServiceResource worker = TestDataFactoryForDealerPortal.createServiceWorker(partPortalUser.Id, workCenter.Id);
            insert worker;
            recordIdSet.add(worker.Id);

            serviceOrder = TestDataFactoryForDealerPortal.createServiceOrder(ticket.Id, equipment.Id, accountId, workCenter.Id, worker.Id);
            serviceOrder.ConfirmedDate__c = DateTime.now();
            insert serviceOrder;
            recordIdSet.add(serviceOrder.Id);
        }

        
        ProductRequest partClaim = TestDataFactoryForDealerPortal.createPartClaim(serviceOrder.Id, partList[0].Id);
        partClaim.OwnerId = partPortalUser.Id;
        partClaim.ShipTo__c = workCenter.Id;
        insert partClaim;

        DealerFreeDispatch__c freeClaim = TestDataFactoryForDealerPortal.createFreeClaim(partClaim.Id, accountId);
        freeClaim.Status__c = '2';
        freeClaim.ShippingType__c = '1';
        freeClaim.OwnerId = partPortalUser.Id;
        insert freeClaim;


        DN_WarrantyPartsManagement.DealerFreeDispatch dispatch = new DN_WarrantyPartsManagement.DealerFreeDispatch();
        dispatch.warrantyId = freeClaim.Id;
        dispatch.plannedDeliveryDateTime = DateTime.now();
        dispatch.confirmDate = DateTime.now();

        List<DN_WarrantyPartsManagement.DealerFreeDispatch> statusList = new List<DN_WarrantyPartsManagement.DealerFreeDispatch>{
            dispatch
        };

        Test.startTest();

        DN_WarrantyPartsManagement.statusUpdate(statusList, '4');

        Test.stopTest();
    }

    public with sharing class IF_DEALERSTOCK_015_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","ID":"","IF_NUMBER":"000","MESSAGE":"상태 변경을 완료하였습니다","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","IF_SYSTEM":""}}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }

    @isTest
    static void getCustomerPriceByIf_Test() {
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"R18182","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"},{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18182","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"}],"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock(resBody));
        try {
            DN_WarrantyPartsManagement.getCustomerPriceByIf('', '1846', '10', '40', 'KR', new Set<String>{'R18181'});
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @isTest
    static void searchCostWarrnatyItems_Test() {
        DN_DealerPortalDisplayController.PageReturn page = new DN_DealerPortalDisplayController.PageReturn();
        page.itemsPerPage = 1;
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"R18182","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"},{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"25.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18182","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"}],"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock(resBody));
        
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName2 LIMIT 1];
        List<Product2> partList = [SELECT Id, ProductCode FROM Product2];

        String accountId;
        WorkOrder serviceOrder;
        ServiceTerritory workCenter;
        Set<String> recordIdSet = new Set<String>();
        System.runAs(partPortalUser) {
            TestDataFactoryForDealerPortal.assignFLSPermissionSet(partPortalUser.Id);
            DN_UserDetails currentUser = new DN_UserDetails();
            accountId = currentUser.getAgencyId();
            DealerStock__c stock = TestDataFactoryForDealerPortal.createDealerStock(accountId, partList[0].Id);
            stock.CurrentStockQuantity__c = stock.AvailableQuantity__c = 10;
            stock.ExternalKey__c = currentUser.getSalesOranization()+'-'+currentUser.getDistributionChannel()+'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+partList[0].ProductCode;
            insert stock;

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
            ServiceResource worker = TestDataFactoryForDealerPortal.createServiceWorker(partPortalUser.Id, workCenter.Id);
            insert worker;
            recordIdSet.add(worker.Id);

            serviceOrder = TestDataFactoryForDealerPortal.createServiceOrder(ticket.Id, equipment.Id, accountId, workCenter.Id, worker.Id);
            insert serviceOrder;
            recordIdSet.add(serviceOrder.Id);
        }

        
        ProductRequest partClaim = TestDataFactoryForDealerPortal.createPartClaim(serviceOrder.Id, partList[0].Id);
        partClaim.OwnerId = partPortalUser.Id;
        partClaim.ShipTo__c = workCenter.Id;
        insert partClaim;

        DealerFreeDispatch__c freeClaim = TestDataFactoryForDealerPortal.createFreeClaim(partClaim.Id, accountId);
        freeClaim.Status__c = '1';
        freeClaim.ShippingType__c = '1';
        freeClaim.OwnerId = partPortalUser.Id;
        insert freeClaim;
        recordIdSet.add(freeClaim.Id);
        
        Test.startTest();
        System.runAs(partPortalUser) {
            SchemaInfo schema = new SchemaInfo();
            //권한 체크용        
            Map<String, UserRecordAccess> recordAccess = schema.getUserAccesses(partPortalUser.Id, recordIdSet);
            // System.debug(JSON.serializePretty(recordAccess));

            DN_WarrantyPartsManagement.searchCostWarrnatyItems(
                '',
                null,
                null,
                '',
                null
            );
        }


        Test.stopTest();
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
            System.debug('IF Mock');
            System.debug(res.getBody());
            return res;
        }
    }

    @isTest
    static void getStockByChangeDealer_TEST() {
        Test.startTest();
        List<DealerStock__c> stockList = new List<DealerStock__c>();
        List<Account> accList = [SELECT Id, CustomerCode__c FROM Account];
        Set<String> partIdSet = new Set<String>();
        for(Account acc : accList) {
            for(Product2 product : [SELECT Id, ProductCode FROM Product2]) {
                DealerStock__c stock = TestDataFactoryForDealerPortal.createDealerStock(acc.Id, product.Id);
                stock.CurrentStockQuantity__c = stock.AvailableQuantity__c = 10;
                stock.ExternalKey__c = '1846-10-40-'+acc.CustomerCode__c+'-'+product.ProductCode;
                stockList.add(stock);
                partIdSet.add(product.ProductCode);
            }
        }
        insert stockList;

        DN_WarrantyPartsManagement.getStockByChangeDealer(accList[0].Id, new List<String>(partIdSet));
        
        Test.stopTest();
    }

    @isTest
    static void roundAndFloorToTen_TEST() {
        Test.startTest();
        Decimal price1 = DN_WarrantyPartsManagement.roundAndFloorToTen(null);
        System.debug('price1 : ' +price1);
        System.assert( price1 == 0);

        Decimal price2 = DN_WarrantyPartsManagement.roundAndFloorToTen(221262.50);
        System.debug('price2 : ' +price2);
        System.assert(221260 == price2);

        Decimal price3 = DN_WarrantyPartsManagement.roundAndFloorToTen(65334.500);
        System.debug('price3 : ' +price3);
        System.assert(65330== price3);

        Test.stopTest();
    }

    @isTest
    static void coverageTest() {
        DN_WarrantyPartsManagement disPatchcontroller = new DN_WarrantyPartsManagement();
        DN_WarrantyPartsManagement.DealerFreeDispatch dispath = new DN_WarrantyPartsManagement.DealerFreeDispatch();
        System.debug(dispath.avaiableQuantity);
        System.debug(dispath.reservedQuantity);
        System.debug(dispath.currentStockQuantity);
        System.debug(dispath.currencyCode);
        System.debug(dispath.dealerGrade);
        System.debug(dispath.deliveryDate);
        System.debug(dispath.confirmDateStr);
        System.debug(dispath.customerPrice);
        System.debug(dispath.compensationAmount);
        System.debug(dispath.finalCompensationAmount);
        System.debug(dispath.dealerGradeRate);
        
        
        DN_WarrantyPartsManagement.StatusInfo status = new DN_WarrantyPartsManagement.StatusInfo();
        status.setCode(200);
        status.setMessage('200');
        status.setError('400',400);
    }
}