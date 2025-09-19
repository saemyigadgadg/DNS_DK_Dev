@isTest
public class DN_WorkOrderChargingPartControllerTest {
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        TriggerHandler.bypassedHandlers = new Set<String>{
            'AccountTriggerHandler'
            , 'ContactTriggerHandler'
            , 'OpportunityTriggerHandler'
        };
        
        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;
        }

        Product2 prod = TestDataFactoryForService.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForService.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Account acc;
        Contact con;
        System.runAs(dealer) {
            acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '1308913';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

        }

        Asset asset = TestDataFactoryForSales.createAsset();
        asset.AccountId = acc.Id;
        asset.SoldTo__c = acc.Id;
        insert asset;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, asset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        Interface__c ifc_010 = TestDataFactoryForSales.createinterface('IF-CSPLUS-010', 'Real-Time');
        insert ifc_010;
        Interface__c ifc_033 = TestDataFactoryForSales.createinterface('IF-CSPLUS-033', 'Real-Time');
        insert ifc_033;

        InterfaceClasses__c ifClass_010 = TestDataFactoryForSales.createIFClass('IF_ERP_WorkOrder', ifc_010.Id);
        insert ifClass_010;
        InterfaceClasses__c ifClass_033 = TestDataFactoryForSales.createIFClass('IF_ERP_Receipt', ifc_033.Id);
        insert ifClass_033;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();    
        for(ServiceTerritory st : territoryList) {
            st.ServiceWorkCenter__c = acc.Id;
            st.WCCode__c = acc.CustomerCode__c;
        }
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        insert wo;

        ProductRequest pr = TestDataFactoryForService.createProductRequest(prod, wo, territory);
        pr.Status = 'Approved';
        insert pr;

        DealerStock__c ds = new DealerStock__c();
        ds.WarrantyRequiredQuantity__c = 1;
        ds.CurrentStockQuantity__c = 10;
        ds.OrderRequiredQuantity__c = 1;
        ds.BlockQuantity__c = 1;
        ds.AvailableQuantity__c = 7;
        ds.Part__c = prod.Id;
        ds.Dealer__c = acc.Id;        
        insert ds;
    }

    @IsTest
    static void testGetDeleteLastIndex(){
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        
        Test.startTest();
        DN_WorkOrderChargingPartController.getDeleteLastIndex(wo.Id, '0010');
        Test.stopTest();
    }

    @IsTest
    static void testGetChargingPartList(){
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        
        Test.startTest();
        DN_WorkOrderChargingPartController.getChargingPartList(wo.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetProduct(){
        Product2 prod = [SELECT Id, Name FROM Product2 LIMIT 1];
        
        Test.startTest();
        DN_WorkOrderChargingPartController.getProductName(prod.Id);
        DN_WorkOrderChargingPartController.getProductId(prod.Name);
        DN_WorkOrderChargingPartController.getProductDetails(prod.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetOptyLI() {
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        DN_WorkOrderChargingPartController.getOptyLI(opty.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpsertOptyProduct() {
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 prod = [SELECT Id, ProductCode FROM Product2 LIMIT 1];

        List<DN_WorkOrderChargingPartController.ChargingPartWrapper> wrapList = new List<DN_WorkOrderChargingPartController.ChargingPartWrapper>();
        DN_WorkOrderChargingPartController.ChargingPartWrapper wrap = new DN_WorkOrderChargingPartController.ChargingPartWrapper();
        wrap.ProductId = prod.Id;
        wrap.PartAmountUnit = 1;
        wrap.PartAmount = 1;
        wrap.UnitCode = 'EA';
        wrapList.add(wrap);

        Test.startTest();
        try {
            DN_WorkOrderChargingPartController.upsertOptyProduct(wrapList, opty.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteRequestProduct() {
        ProductRequest pr = [SELECT Id FROM ProductRequest LIMIT 1];
        Test.startTest();
        DN_WorkOrderChargingPartController.deleteRequestProduct(pr.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetServiceTerritories() {
        Test.startTest();
        DN_WorkOrderChargingPartController.getServiceTerritories();
        Test.stopTest();
    }

    @isTest
    static void testGetGPESProducts() {
        Product2 prod = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        List<Object> gpesPartsList = new List<Object>();
        Map<String, Object> gpesPart = new Map<String, Object>{
            'partNo' => prod.ProductCode,
            'qty' => 1
        };
        Map<String, Object> gpesPart2 = new Map<String, Object>{
            'partNo' => 'invalidId',
            'qty' => 1
        };
        gpesPartsList.add(gpesPart);
        gpesPartsList.add(gpesPart2);

        Test.startTest();
        DN_WorkOrderChargingPartController.getGPESProducts(gpesPartsList);
        Test.stopTest();
    }

    @isTest
    static void testGetAssetName() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();
        DN_WorkOrderChargingPartController.getAssetName(wo.Id);
        DN_WorkOrderChargingPartController.getWorkOrder(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void testSearchSpindle() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-031', 'IF_ERP_Material');
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();
        try {
            DN_WorkOrderChargingPartController.searchSpindle(wo.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCheckProduct() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        DN_WorkOrderChargingPartController.checkProduct(prod.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetProductByCode() {
        Product2 prod = [SELECT Id, Name FROM Product2 LIMIT 1];

        Test.startTest();
        DN_WorkOrderChargingPartController.getProductByCode(prod.Name);
        Test.stopTest();
    }

    @isTest
    static void testGetDealerStock() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-021', 'IF_ERP_Material');
        Product2 prod = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        Test.startTest();
        DN_WorkOrderChargingPartController.searchDealerStock(prod.Id,'1');
        Test.stopTest();
    }

    @isTest
    static void testSearchMultipleProductStock() {
        Product2 prod = [SELECT Id, ProductCode FROM Product2 LIMIT 1];

        List<Map<String, Object>> productIds = new List<Map<String, Object>>();
        productIds.add(new Map<String, Object>{ 'ProductId' => prod.Id, 'PartAmount' => 1 });

        Test.startTest();
        try {
            DN_WorkOrderChargingPartController.searchMultipleProductStock(productIds);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }    
        Test.stopTest();
    }

    @isTest
    static void testGetLastSequence() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        DN_WorkOrderChargingPartController.getLastSequence(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpsertPRData() {
        // InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Product2 prod = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        Account acc = [SELECT Id, Name FROM Account WHERE CustomerCode__c = '1308913' LIMIT 1];

        List<DN_WorkOrderChargingPartController.ChargingPartWrapper> wrapList = new List<DN_WorkOrderChargingPartController.ChargingPartWrapper>();
        DN_WorkOrderChargingPartController.ChargingPartWrapper wrap = new DN_WorkOrderChargingPartController.ChargingPartWrapper();
        wrap.ProductId = prod.Id;
        wrap.PartAmountUnit = 1;
        wrap.PartAmount = 1;
        wrap.UnitCode = 'EA';
        wrap.ShipTo = '고객직송';
        wrapList.add(wrap);
        DN_WorkOrderChargingPartController.ChargingPartWrapper wrap02 = new DN_WorkOrderChargingPartController.ChargingPartWrapper();
        wrap02.ProductId = prod.Id;
        wrap02.PartAmountUnit = 1;
        wrap02.PartAmount = 1;
        wrap02.UnitCode = 'EA';
        wrap02.ShipTo = '고객직송';
        wrap02.WorkCenterId = acc.Id;
        wrap02.WorkCenterName = acc.Name;
        wrapList.add(wrap02);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_WorkOrder());

        DN_WorkOrderChargingPartController.upsertPRData(wrapList, wo.Id);
        Test.stopTest();
    }

    private class MockIF_ERP_WorkOrder implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_AUFNR":"403908048","O_QMNUM":"302382064", ' 
                + '"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"403908048/302382064///요청자 정보를 등록하였습니다./0173213624/173213624"},' 
                + '"O_RSNUM":"173213624",' 
                + '"T_O_LIST":[' 
                + '{"QMSEQ":"0010","RETURN_YN":"N","VBELN":"1000531295","RSPOS":"0000","VENDOR":"1308913",' 
                + '"MAKTX":"SWITCH,SELECTOR","RSNUM":"0000000000","MATNR":"ESWSL0132","SUPPLY_TP":"N",' 
                + '"SLTD":"11","MFLAG":"X","SPIND":"","SOLDTO":"0001308913","MENGE":"1","NETWR":"6,250",' 
                + '"NAME1":"","QMNUM":"000302382064","MATNR_TXT":"확정","MEINS":"EA","PLIFZ":"20","VSBED":"1"},' 
                + '{"QMSEQ":"0020","RETURN_YN":"N","VBELN":"1000531295","RSPOS":"0000","VENDOR":"1308913",' 
                + '"MAKTX":"SWITCH,SELECTOR","RSNUM":"0000000000","MATNR":"ESWSL0132","SUPPLY_TP":"N","SLTD":"11",' 
                + '"MFLAG":"X","SPIND":"","SOLDTO":"0001308913","MENGE":"1","NETWR":"6,250","NAME1":"",' 
                + '"QMNUM":"000302382064","MATNR_TXT":"확정","MEINS":"EA","PLIFZ":"20","VSBED":"1"}]}'
            );
            return res;
        }
    }
    
}