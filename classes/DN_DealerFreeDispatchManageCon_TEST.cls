/** 
 * @Class :  DN_DealerFreeDispatchManageCon_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 26. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-26 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_DealerFreeDispatchManageCon_TEST {
    static String partnerUserName ='partDFDM@test.test.com';
    static String partnerUserName2 ='part2DFDM@test.test.com';

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
            Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-CSPLUS-007', 'Real-Time');
            ifObjList.add(ifObj);
            Interface__c ifObj2 = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-003', 'Real-Time');
            ifObjList.add(ifObj2);
            Interface__c ifObj3 = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-004', 'Real-Time');
            ifObjList.add(ifObj3);
            Interface__c ifObj4 = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-005', 'Real-Time');
            ifObjList.add(ifObj4);
            insert ifObjList;

            List<InterfaceClasses__c> ifClassList = new List<InterfaceClasses__c>();
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Material', ifObj.Id);
            ifClassList.add(ifClass);
            InterfaceClasses__c ifClass2 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj2.Id);
            ifClassList.add(ifClass2);
            InterfaceClasses__c ifClass3 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj3.Id);
            ifClassList.add(ifClass3);
            InterfaceClasses__c ifClass4 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj4.Id);
            ifClassList.add(ifClass4);
            insert ifClassList;

            

            List<Account> accList = new List<Account>();
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            dealer.DealerGrade__c = 'A';
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
            ServiceResource worker = TestDataFactoryForDealerPortal.createServiceWorker(partnerTestUser.Id, workCenter.Id);
            insert worker;
            recordIdSet.add(worker.Id);

            serviceOrder = TestDataFactoryForDealerPortal.createServiceOrder(ticket.Id, equipment.Id, accountId, workCenter.Id, worker.Id);
            serviceOrder.ServiceOrderNumber__c = '403906564';
            insert serviceOrder;
            recordIdSet.add(serviceOrder.Id);
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
            freeClaim.IsDemandCapture__c = false;
            insert freeClaim;
            recordIdSet.add(freeClaim.Id);
        }
    }


    @isTest
    static void getDataList() {
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"1 Records Found."},"T_O_LIST":[{"ILART":"201","SOLDTO1":"","QZEIT":"00:00:00","POSNN_VL":"000000","RETURN_YN":"Y","EXTI1":"","STATUS":"REL PRC SETC","TKNUM":"","INVOICE":"","SOLDTO":"0001296931","KWMENG":"2","VNDNM":"일렉트로닉솔루션","NAME4":"엔.씨.에스","BMENG":"2.000","NAME3":"","NAME2":"주식회사신일에스앤피","NAME1":"링엔지니어링","RETURN_TYPE":"","GWLDT":"2023-05-31","VSMNG":"2.000","QMSEQ":"0010","POCONT_YN":"Y","MEINS":"AY","GSMNG":"2.000","TDLNR_NAME":"","SDATE":"0000-00-00","VBELN_VL1":"6000316961","MATNR":"301202-00429","MATNR_TXT":"배송완료","OBJNR":"OR000403906564","MAKTX":"RELAY,MINIATURE;ASSY, 6A,24V,4 PDTS","POSNR":"000000","ZSUPPLY":"02","REQ_DATE":"0000-00-00","PRETD":"0000-00-00","VSBED":"4","AUFNR":"403906564","RECV_DT":"2024-03-26","PRETD3":"0000-00-00","PRETD2":"0000-00-00","LIFNR":"0010112620","KUNUM":"0001236877","TYPBZ":"PUMA DNT2600LM","SERNR":"ML0495-000084","TDLNR":"","DODAT":"0000-00-00","QMNUM":"302380935","VBELN_VL":"","ETD":"0000-00-00","QDATU":"2024-03-26","RETURN_TEXT":"","DEALER_CD":"0001057644","VBELN":""}]}';
        Test.setMock(HttpCalloutMock.class, new IF_TEST_HttpMock(resBody));
        Test.startTest();
        Map<String,Object> whereCondition = new Map<String,Object>();
        DN_DealerFreeDispatchManageController.PageReturn pageInfo = new DN_DealerFreeDispatchManageController.PageReturn();
        DN_DealerFreeDispatchManageController.getDataList(whereCondition, pageInfo);
        Test.stopTest();
    }

    public class IF_TEST_HttpMock implements HttpCalloutMock {
        String resBody;
        public IF_TEST_HttpMock(String resBody){
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
    static void getDetailList_TEST() {
        String resBody = '{"O_RETURN":{"TYPE":"","CODE":"","MESSAGE":""},"T_O_RESB":[{"VORNR":"0010","BDMNG":"1.000","RSART":"","CHK":"","RSNUM":"0173230606","MEINS":"EA","RSPOS":"0003","WERKS":"1846","MAKTX":"BRACKET;FIX","AUFNR":"000403908660","POSTP":"N","POSNR":"9020","LGORT":"","MATNR":"110423-24289"}],"T_O_ZCRMS0093":[],"T_O_ZCST0040":[{"PRT_DATE":"0000-00-00","RETURN_YN":"N","PGMNG":"1.000","BELNR":"","BELNR_IV":"","SO_CHK":"","WAERS":"KRW","MENGE":"1.000","NAME1":"","RETURN_TYPE":"7","CHANGE_DT":"2025-03-25","ZSVP":"","RETURN_QTY":"0","MAT_WARR_YN":"","MEINS":"EA","AENAM":"","MANDT":"880","CNF_QTY":"0","ITEM_NUMBER":"9020","AEDAT":"0000-00-00","MATNR":"110423-24289","EBELP":"00000","RETURN_END_YN":"N","ITEM_CAT":"N","MAKTX":"BRACKET;FIX","EBELN":"","POSNR":"000000","BRTWR":"283.20","GI_MBLNR":"","AUFNR":"000403908660","SUPPLY_TYPE":"대리점","AEZET":"00:00:00","ERNAM":"005JO000000h","CLOSE_DT":"0000-00-00","LIFNR":"","POSNR_VF":"000000","ERDAT":"2025-03-25","CAUSE_PRT":"","RETURN_DT":"0000-00-00","MBLNR":"","BNFPO":"00000","BANFN":"","VBELN_VF":"","RETURN_TEXT":"","VBELN":"","RETURN_WAY":"","SEQNO":"9002","ERZET":"10:32:24","REASON2":"","LPRICE":"0.00","REASON1":"","PRT_TIME":"00:00:00","WORKNO":"0000","FREIGHT":"0.00","NRTN_TEXT":"","NETWR":"70.80"}]}';
        Test.setMock(HttpCalloutMock.class, new IF_TEST_HttpMock(resBody));
        Test.startTest();
        DN_DealerFreeDispatchManageController.DealerFreeDispatch params= new DN_DealerFreeDispatchManageController.DealerFreeDispatch();
        params.order = '403906564';
        params.productCode = '';
        params.reqQty = 1;
        params.uom = '';
        params.dealerCode = '';
        params.item = '0010';
        DN_DealerFreeDispatchManageController.getDetailList(params);
        Test.stopTest();
    }

    @isTest
    static void addReturn_TEST() {
        String resBody = '{"E_DATUM":"2025-03-25","E_USER":"EAICOM","E_UZEIT":"10:36:35","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"successfully deleted."},"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_TEST_HttpMock(resBody));
        

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        String dealerCode;
        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();
            dealerCode = currentUser.getAgencyCustomerCode();

            List<DealerFreeDispatch__c> freeClaim = [SELECT Id, OrderItem__c, OrderItem__r.Product__r.ProductCode FROM DealerFreeDispatch__c];

            DealerInventoryMovements__c giDoc = TestDataFactoryForDealerPortal.createGI();
            giDoc.Dealer__c = currentUser.getAgencyId();
            giDoc.ServiceOrderItem__c = freeClaim[0].OrderItem__c;
            giDoc.Part__c = freeClaim[0].OrderItem__r.Product__c;
            giDoc.Quantity__c = 1;
            insert giDoc;
        }
        
        Test.startTest();
        
        List<DealerFreeDispatch__c> freeClaim = [SELECT Id, OrderItem__c, OrderItem__r.Product__r.ProductCode FROM DealerFreeDispatch__c];

        DN_DealerFreeDispatchManageController.DealerFreeDispatch params= new DN_DealerFreeDispatchManageController.DealerFreeDispatch();
        params.id = freeClaim[0].Id;
        params.orderId = freeClaim[0].OrderItem__c;
        params.productCode = freeClaim[0].OrderItem__r.Product__r.ProductCode;
        params.dealerCode = dealerCode;
        params.reqQty = 1;
        params.order = '403906564';
        params.item = '0010';
        DN_DealerFreeDispatchManageController.addReturn(params, params.item, params.item);
        Test.stopTest();
    }

    @isTest 
    static void partition_TEST() {
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully processed."},"T_DOMESTIC":[{"PRT_DATE":"0000-00-00","RETURN_YN":"N","PGMNG":"2.000","BELNR":"","BELNR_IV":"","SO_CHK":"","WAERS":"KRW","MENGE":"2.000","NAME1":"","RETURN_TYPE":"7","CHANGE_DT":"2025-03-25","ZSVP":"","RETURN_QTY":"0","MAT_WARR_YN":"","MEINS":"EA","AENAM":"","MANDT":"880","CNF_QTY":"0","ITEM_NUMBER":"0010","AEDAT":"0000-00-00","MATNR":"110423-24289","EBELP":"00000","RETURN_END_YN":"N","ITEM_CAT":"N","MAKTX":"BRACKET;FIX","EBELN":"","POSNR":"000000","BRTWR":"283.20","GI_MBLNR":"","AUFNR":"000403908660","SUPPLY_TYPE":"대리점","AEZET":"00:00:00","ERNAM":"005JO000000h","CLOSE_DT":"0000-00-00","LIFNR":"","POSNR_VF":"000000","ERDAT":"2025-03-25","CAUSE_PRT":"","RETURN_DT":"0000-00-00","MBLNR":"","BNFPO":"00000","BANFN":"","VBELN_VF":"","RETURN_TEXT":"","VBELN":"","RETURN_WAY":"","SEQNO":"0001","ERZET":"10:32:24","REASON2":"","LPRICE":"0.00","REASON1":"","PRT_TIME":"00:00:00","WORKNO":"0000","FREIGHT":"0.00","NRTN_TEXT":"","NETWR":"70.80"},{"PRT_DATE":"0000-00-00","RETURN_YN":"N","PGMNG":"1.000","BELNR":"","BELNR_IV":"","SO_CHK":"","WAERS":"KRW","MENGE":"1.000","NAME1":"","RETURN_TYPE":"7","CHANGE_DT":"2025-03-25","ZSVP":"","RETURN_QTY":"0","MAT_WARR_YN":"","MEINS":"EA","AENAM":"","MANDT":"880","CNF_QTY":"0","ITEM_NUMBER":"9020","AEDAT":"0000-00-00","MATNR":"110423-24289","EBELP":"00000","RETURN_END_YN":"N","ITEM_CAT":"N","MAKTX":"BRACKET;FIX","EBELN":"","POSNR":"000000","BRTWR":"283.20","GI_MBLNR":"","AUFNR":"000403908660","SUPPLY_TYPE":"대리점","AEZET":"00:00:00","ERNAM":"005JO000000h","CLOSE_DT":"0000-00-00","LIFNR":"","POSNR_VF":"000000","ERDAT":"2025-03-25","CAUSE_PRT":"","RETURN_DT":"0000-00-00","MBLNR":"","BNFPO":"00000","BANFN":"","VBELN_VF":"","RETURN_TEXT":"","VBELN":"","RETURN_WAY":"","SEQNO":"9002","ERZET":"10:32:24","REASON2":"","LPRICE":"0.00","REASON1":"","PRT_TIME":"00:00:00","WORKNO":"0000","FREIGHT":"0.00","NRTN_TEXT":"","NETWR":"70.80"}],"T_MAIN":[{"AENAM":"","DEZIT":"00:00:00","STAT":"1","DEDAT":"0000-00-00","INVOICE":"","ERZET":"10:30:12","WRAMT":"0.00","AUFNR":"000403908660","AEDAT":"0000-00-00","DEALER_NM":"","MAKTX":"BRACKET;FIX","BMENG":"0.000","QMDAT":"2025-03-25","ERNAM":"EAICOM","MATNR":"110423-24289","ERSDA":"0000-00-00","STATT":"","VSARTT":"","BDMNG":"2.000","VSART":"1","RCOL":"","PDATE":"0000-00-00","WAERS":"","ERDAT":"2025-03-25","POSNR":"0010","DEALER_CD":"0001057644","DENAM":"","AEZET":"00:00:00","MEINS":"EA","CHK":"","PTIME":"00:00:00"},{"AENAM":"","DEZIT":"00:00:00","STAT":"1","DEDAT":"0000-00-00","INVOICE":"","ERZET":"10:30:12","WRAMT":"0.00","AUFNR":"000403908660","AEDAT":"0000-00-00","DEALER_NM":"","MAKTX":"BRACKET;FIX","BMENG":"0.000","QMDAT":"2025-03-25","ERNAM":"EAICOM","MATNR":"110423-24289","ERSDA":"0000-00-00","STATT":"","VSARTT":"","BDMNG":"1.000","VSART":"1","RCOL":"","PDATE":"0000-00-00","WAERS":"","ERDAT":"2025-03-25","POSNR":"9020","DEALER_CD":"0001057644","DENAM":"","AEZET":"00:00:00","MEINS":"EA","CHK":"","PTIME":"00:00:00"}],"T_NOTI":[{"APPRO_ID":"","KUNNR":"0001325706","RSNUM":"0000000000","POWERTRAIN":"","CARRIER":"","RETURN_YN":"N","CARRIER_T":"","DELIV":"","STATUS":"APPROVAL","EQUNR":"ML0006-006232","COUNTRY":"","REQ_USER":"","CLAIM_NO":"","MENGE":"2.000","ARBPL":"","QMSEQ":"0010","MEINS":"EA","VSTEL":"","ORDER_TYPE":"","SPIND":"","MANDT":"880","MATNR":"110423-24289","APPRO_ST":"","ACCT_NO":"","EBELN":"","ZRMA":"","ZSUPPLY":"02","ERROR":"","REQ_DATE":"0000-00-00","TNAME":"","VSBED":"1","WERKS":"","AUFNR":"","CAUSE":"","LIFNR":"0001057644","KUNUM":"","CNF_DATE":"0000-00-00","AUTLF":"","QMNUM":"000302382672","HOLD":"","AUART":"","VBELN":"","ONE_TIME_CHK":""},{"APPRO_ID":"","KUNNR":"0001325706","RSNUM":"0000000000","POWERTRAIN":"","CARRIER":"","RETURN_YN":"N","CARRIER_T":"","DELIV":"","STATUS":"APPROVAL","EQUNR":"ML0006-006232","COUNTRY":"","REQ_USER":"","CLAIM_NO":"","MENGE":"1.000","ARBPL":"","QMSEQ":"9020","MEINS":"EA","VSTEL":"","ORDER_TYPE":"","SPIND":"","MANDT":"880","MATNR":"110423-24289","APPRO_ST":"","ACCT_NO":"","EBELN":"","ZRMA":"","ZSUPPLY":"02","ERROR":"","REQ_DATE":"0000-00-00","TNAME":"","VSBED":"1","WERKS":"","AUFNR":"","CAUSE":"","LIFNR":"0001057644","KUNUM":"","CNF_DATE":"0000-00-00","AUTLF":"","QMNUM":"000302382672","HOLD":"","AUART":"","VBELN":"","ONE_TIME_CHK":""}],"T_RESB":[{"VORNR":"0010","BDMNG":"2.000","RSART":"","CHK":"","RSNUM":"0173230606","MEINS":"EA","RSPOS":"0001","WERKS":"1846","MAKTX":"","AUFNR":"000403908660","POSTP":"N","POSNR":"0010","LGORT":"","MATNR":"110423-24289"},{"VORNR":"0010","BDMNG":"1.000","RSART":"","CHK":"","RSNUM":"0173230606","MEINS":"EA","RSPOS":"0003","WERKS":"1846","MAKTX":"","AUFNR":"000403908660","POSTP":"N","POSNR":"9020","LGORT":"","MATNR":"110423-24289"}],"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_TEST_HttpMock(resBody));

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        String dealerCode;
        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();
            dealerCode = currentUser.getAgencyCustomerCode();

            List<DealerFreeDispatch__c> freeClaim = [SELECT Id, OrderItem__c, OrderItem__r.Product__r.ProductCode FROM DealerFreeDispatch__c];

            DealerInventoryMovements__c giDoc = TestDataFactoryForDealerPortal.createGI();
            giDoc.Dealer__c = currentUser.getAgencyId();
            giDoc.ServiceOrderItem__c = freeClaim[0].OrderItem__c;
            giDoc.Part__c = freeClaim[0].OrderItem__r.Product__c;
            giDoc.Quantity__c = 1;
            giDoc.CustomerPrice__c = 5000;
            insert giDoc;
        }

        Test.startTest();
        List<DealerFreeDispatch__c> freeClaim = [SELECT Id, OrderItem__c, OrderItem__r.Product__r.ProductCode FROM DealerFreeDispatch__c];
        DN_DealerFreeDispatchManageController.DealerFreeDispatch params = new DN_DealerFreeDispatchManageController.DealerFreeDispatch();
        params.Id = freeClaim[0].Id;
        params.orderId = freeClaim[0].OrderItem__c;
        params.productCode = freeClaim[0].OrderItem__r.Product__r.ProductCode;
        params.dealerCode = dealerCode;
        params.order = '403906564';
        params.item = '0010';
        DN_DealerFreeDispatchManageController.partition(params, 1, 1);

        Test.stopTest();
    }

    @isTest 
    static void partitionCheck_TEST() {
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully processed."},"T_DOMESTIC":[{"PRT_DATE":"0000-00-00","RETURN_YN":"N","PGMNG":"2.000","BELNR":"","BELNR_IV":"","SO_CHK":"","WAERS":"KRW","MENGE":"2.000","NAME1":"","RETURN_TYPE":"7","CHANGE_DT":"2025-03-25","ZSVP":"","RETURN_QTY":"0","MAT_WARR_YN":"","MEINS":"EA","AENAM":"","MANDT":"880","CNF_QTY":"0","ITEM_NUMBER":"0010","AEDAT":"0000-00-00","MATNR":"110423-24289","EBELP":"00000","RETURN_END_YN":"N","ITEM_CAT":"N","MAKTX":"BRACKET;FIX","EBELN":"","POSNR":"000000","BRTWR":"283.20","GI_MBLNR":"","AUFNR":"000403908660","SUPPLY_TYPE":"대리점","AEZET":"00:00:00","ERNAM":"005JO000000h","CLOSE_DT":"0000-00-00","LIFNR":"","POSNR_VF":"000000","ERDAT":"2025-03-25","CAUSE_PRT":"","RETURN_DT":"0000-00-00","MBLNR":"","BNFPO":"00000","BANFN":"","VBELN_VF":"","RETURN_TEXT":"","VBELN":"","RETURN_WAY":"","SEQNO":"0001","ERZET":"10:32:24","REASON2":"","LPRICE":"0.00","REASON1":"","PRT_TIME":"00:00:00","WORKNO":"0000","FREIGHT":"0.00","NRTN_TEXT":"","NETWR":"70.80"},{"PRT_DATE":"0000-00-00","RETURN_YN":"N","PGMNG":"1.000","BELNR":"","BELNR_IV":"","SO_CHK":"","WAERS":"KRW","MENGE":"1.000","NAME1":"","RETURN_TYPE":"7","CHANGE_DT":"2025-03-25","ZSVP":"","RETURN_QTY":"0","MAT_WARR_YN":"","MEINS":"EA","AENAM":"","MANDT":"880","CNF_QTY":"0","ITEM_NUMBER":"9020","AEDAT":"0000-00-00","MATNR":"110423-24289","EBELP":"00000","RETURN_END_YN":"N","ITEM_CAT":"N","MAKTX":"BRACKET;FIX","EBELN":"","POSNR":"000000","BRTWR":"283.20","GI_MBLNR":"","AUFNR":"000403908660","SUPPLY_TYPE":"대리점","AEZET":"00:00:00","ERNAM":"005JO000000h","CLOSE_DT":"0000-00-00","LIFNR":"","POSNR_VF":"000000","ERDAT":"2025-03-25","CAUSE_PRT":"","RETURN_DT":"0000-00-00","MBLNR":"","BNFPO":"00000","BANFN":"","VBELN_VF":"","RETURN_TEXT":"","VBELN":"","RETURN_WAY":"","SEQNO":"9002","ERZET":"10:32:24","REASON2":"","LPRICE":"0.00","REASON1":"","PRT_TIME":"00:00:00","WORKNO":"0000","FREIGHT":"0.00","NRTN_TEXT":"","NETWR":"70.80"}],"T_MAIN":[{"AENAM":"","DEZIT":"00:00:00","STAT":"1","DEDAT":"0000-00-00","INVOICE":"","ERZET":"10:30:12","WRAMT":"0.00","AUFNR":"000403908660","AEDAT":"0000-00-00","DEALER_NM":"","MAKTX":"BRACKET;FIX","BMENG":"0.000","QMDAT":"2025-03-25","ERNAM":"EAICOM","MATNR":"110423-24289","ERSDA":"0000-00-00","STATT":"","VSARTT":"","BDMNG":"2.000","VSART":"1","RCOL":"","PDATE":"0000-00-00","WAERS":"","ERDAT":"2025-03-25","POSNR":"0010","DEALER_CD":"0001057644","DENAM":"","AEZET":"00:00:00","MEINS":"EA","CHK":"","PTIME":"00:00:00"},{"AENAM":"","DEZIT":"00:00:00","STAT":"1","DEDAT":"0000-00-00","INVOICE":"","ERZET":"10:30:12","WRAMT":"0.00","AUFNR":"000403908660","AEDAT":"0000-00-00","DEALER_NM":"","MAKTX":"BRACKET;FIX","BMENG":"0.000","QMDAT":"2025-03-25","ERNAM":"EAICOM","MATNR":"110423-24289","ERSDA":"0000-00-00","STATT":"","VSARTT":"","BDMNG":"1.000","VSART":"1","RCOL":"","PDATE":"0000-00-00","WAERS":"","ERDAT":"2025-03-25","POSNR":"9020","DEALER_CD":"0001057644","DENAM":"","AEZET":"00:00:00","MEINS":"EA","CHK":"","PTIME":"00:00:00"}],"T_NOTI":[{"APPRO_ID":"","KUNNR":"0001325706","RSNUM":"0000000000","POWERTRAIN":"","CARRIER":"","RETURN_YN":"N","CARRIER_T":"","DELIV":"","STATUS":"APPROVAL","EQUNR":"ML0006-006232","COUNTRY":"","REQ_USER":"","CLAIM_NO":"","MENGE":"2.000","ARBPL":"","QMSEQ":"0010","MEINS":"EA","VSTEL":"","ORDER_TYPE":"","SPIND":"","MANDT":"880","MATNR":"110423-24289","APPRO_ST":"","ACCT_NO":"","EBELN":"","ZRMA":"","ZSUPPLY":"02","ERROR":"","REQ_DATE":"0000-00-00","TNAME":"","VSBED":"1","WERKS":"","AUFNR":"","CAUSE":"","LIFNR":"0001057644","KUNUM":"","CNF_DATE":"0000-00-00","AUTLF":"","QMNUM":"000302382672","HOLD":"","AUART":"","VBELN":"","ONE_TIME_CHK":""},{"APPRO_ID":"","KUNNR":"0001325706","RSNUM":"0000000000","POWERTRAIN":"","CARRIER":"","RETURN_YN":"N","CARRIER_T":"","DELIV":"","STATUS":"APPROVAL","EQUNR":"ML0006-006232","COUNTRY":"","REQ_USER":"","CLAIM_NO":"","MENGE":"1.000","ARBPL":"","QMSEQ":"9020","MEINS":"EA","VSTEL":"","ORDER_TYPE":"","SPIND":"","MANDT":"880","MATNR":"110423-24289","APPRO_ST":"","ACCT_NO":"","EBELN":"","ZRMA":"","ZSUPPLY":"02","ERROR":"","REQ_DATE":"0000-00-00","TNAME":"","VSBED":"1","WERKS":"","AUFNR":"","CAUSE":"","LIFNR":"0001057644","KUNUM":"","CNF_DATE":"0000-00-00","AUTLF":"","QMNUM":"000302382672","HOLD":"","AUART":"","VBELN":"","ONE_TIME_CHK":""}],"T_RESB":[{"VORNR":"0010","BDMNG":"2.000","RSART":"","CHK":"","RSNUM":"0173230606","MEINS":"EA","RSPOS":"0001","WERKS":"1846","MAKTX":"","AUFNR":"000403908660","POSTP":"N","POSNR":"0010","LGORT":"","MATNR":"110423-24289"},{"VORNR":"0010","BDMNG":"1.000","RSART":"","CHK":"","RSNUM":"0173230606","MEINS":"EA","RSPOS":"0003","WERKS":"1846","MAKTX":"","AUFNR":"000403908660","POSTP":"N","POSNR":"9020","LGORT":"","MATNR":"110423-24289"}],"T_RETURN":[]}';
        Test.setMock(HttpCalloutMock.class, new IF_TEST_HttpMock(resBody));

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        String dealerCode;
        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();
            dealerCode = currentUser.getAgencyCustomerCode();

            List<DealerFreeDispatch__c> freeClaim = [SELECT Id, OrderItem__c, OrderItem__r.Product__r.ProductCode FROM DealerFreeDispatch__c];

            DealerInventoryMovements__c giDoc = TestDataFactoryForDealerPortal.createGI();
            giDoc.Dealer__c = currentUser.getAgencyId();
            giDoc.ServiceOrderItem__c = freeClaim[0].OrderItem__c;
            giDoc.Part__c = freeClaim[0].OrderItem__r.Product__c;
            giDoc.Quantity__c = 1;
            giDoc.CustomerPrice__c = 5000;
            insert giDoc;
        }

        Test.startTest();
        List<DealerFreeDispatch__c> freeClaim = [SELECT Id, OrderItem__c, OrderItem__r.Product__r.ProductCode FROM DealerFreeDispatch__c];
        DN_DealerFreeDispatchManageController.DealerFreeDispatch params = new DN_DealerFreeDispatchManageController.DealerFreeDispatch();
        params.Id = freeClaim[0].Id;
        params.orderId = freeClaim[0].OrderItem__c;
        params.productCode = freeClaim[0].OrderItem__r.Product__r.ProductCode;
        params.dealerCode = dealerCode;
        params.order = '403906564';
        params.item = '0010';
        
        Map<String,Object> result = DN_DealerFreeDispatchManageController.partitionCheck(params, 1, 1);
        System.debug(result + ' ::: result');
        System.assert((Boolean)result.get('isPassCrmDml') == true);
        

        Test.stopTest();
    }
}