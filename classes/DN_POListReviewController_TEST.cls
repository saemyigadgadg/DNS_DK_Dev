@isTest
public with sharing class DN_POListReviewController_TEST {
    
    
    static Account acc;
    static DealerCustomer__c agency;
    static DealerCustomer__c customer;
    static Product2 prod;
    static DealerOrder__c order;
    static DealerOrderItem__c orderItem;
    static DealerPartMasterByMPPS__c partMasterByMpps;
    static Contact con;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;

    @TestSetup
    static void makeData(){
        List<User> userList = new List<User>();
        adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);

        insert userList;
        System.runAs(adminTestUser) {
            acc = TestDataFactoryForDealerPortal.dealer;            
            insert acc; 

            Account acc2 = TestDataFactoryForDealerPortal.dealer2;            
            insert acc2;   


            con = TestDataFactoryForDealerPortal.createContact(acc.Id);
            insert con;  

            List<Sequence__c> sequenceList = new List<Sequence__c>();
            Sequence__c seq1 = new Sequence__c(
                Name ='DealerCustomer_Dealer',
                Type__c = 'Dealer', 
                Pattern__c = '1{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq1);

            Sequence__c seq2 = new Sequence__c(
                Name ='DealerCustomer_Customer',
                Type__c = 'Customer', 
                Pattern__c = '5{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq2);

            Sequence__c seq3 = new Sequence__c(
                Name ='DealerOrder_General',
                Type__c = 'General', 
                Pattern__c = '8{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq3);

            Sequence__c seq4 = new Sequence__c(
                Name ='DealerOrder_Emergency',
                Type__c = 'Emergency', 
                Pattern__c = '9{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq4);
            
            insert sequenceList;

            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'part@test.test.com';
            insert partnerTestUser;

            agency = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert agency;
            
            customer = TestDataFactoryForDealerPortal.getCustomer(null);
            insert customer;

            con = TestDataFactoryForDealerPortal.createContact(acc.Id);
            insert con;
            
            prod = TestDataFactoryForDealerPortal.getPart('R18181', 'R18181','R18181');
            insert prod;

            order =TestDataFactoryForDealerPortal.getOrder(acc.Id,customer.Id);
            insert order;

            orderItem = TestDataFactoryForDealerPortal.getOrderItem(order.Id,prod.Id,prod.Id);
            insert orderItem;

            partMasterByMpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(prod.Id,acc.Id);
            insert partMasterByMpps;

            ProductByPlant__c prodByPlant = TestDataFactoryForDealerPortal.getProductByPlant(prod.Id, prod.Id);
            insert prodByPlant;

            DealerStock__c stock = TestDataFactoryForDealerPortal.getStock(prod.Id, acc.Id);
            stock.CurrentStockQuantity__c = 1;
            insert stock;

            DealerPartMasterByMPPS__c dealerPartMaster = TestDataFactoryForDealerPortal.getPartMasterByMpps(prod.Id, acc.Id);
            dealerPartMaster.DealerStock__c = stock.Id;
            dealerPartMaster.POQuantity__c = 3;
            insert dealerPartMaster;

            AreaByMPPS__c area = TestDataFactoryForDealerPortal.getAreaByMpps();
            insert area;

            DealerAreaByMPPS__c dealerArea = TestDataFactoryForDealerPortal.getDealerAreaByMPPS(acc.Id, area.Id);
            insert dealerArea;

            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-SERVICE-037', 'Real-Time');
            insert ifc;
            //IF_ERP_Service_PartsDetail
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Service_PartsDetail', ifc.Id);
            insert ifClass;

            Interface__c ifc2 = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            insert ifc2;
    
            InterfaceClasses__c ifClass2 = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifc2.Id);
            insert ifClass2;
        }
    }

    @IsTest
    static void test1(){
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock());
        Test.startTest();
        Product2 part = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode='R18181' LIMIT 1];
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        System.runAs(partPortal){
            DN_POListReviewController.Monthly mon       = new DN_POListReviewController.Monthly();
            DN_POListReviewController.Details  detalis  = new DN_POListReviewController.Details();
            DN_POListReviewController.LastPart lastpart = new DN_POListReviewController.LastPart();
            DN_POListReviewController.PageReturn page = new DN_POListReviewController.PageReturn();
            page.currentPage = 1;
            page.itemsPerPage = 15;
            page.orderBy ='DESC';
            page.orderByField = 'order by LastModifiedDate';
            page.pagesPerGroup = 5;
            Map<String, Object> strMap = new Map<String, Object>();
            strMap.put('ABCIndicator', 'Z');
            strMap.put('MRPType', 'VB');
            strMap.put('POReview', 'MRPBatch');
            strMap.put('docDateEnd', '2025-03-20');
            strMap.put('docDateStart', '2024-03-20');
            strMap.put('isPOCheck', 'true');
            strMap.put('productCode', part.Id);
            Integer nextPage = 1;
            Boolean isExcelLoad = false;
            page.strQuery = strMap;
            DN_POListReviewController.getDataListQuery(page, nextPage,isExcelLoad);
            DN_POListReviewController.setpageSetting(page, 2);
        }
        Test.stopTest();
    }

    @IsTest
    static void test2(){
        //InterfaceCommonUtil.setInterface('IF-SERVICE-037', 'IF_ERP_Service_PartsDetail');
        Test.setMock(HttpCalloutMock.class, new IF_SERVICE_037_HttpMock());
        Test.startTest();
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        System.runAs(partPortal){
            DN_POListReviewController.getAMD('R18181');
        }
        Test.stopTest();
    }

    @IsTest
    static void getStock(){
        //InterfaceCommonUtil.setInterface('IF-SERVICE-037', 'IF_ERP_Service_PartsDetail');
        Test.setMock(HttpCalloutMock.class, new IF_SERVICE_037_HttpMock());
        Test.startTest();
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        System.runAs(partPortal){
            DN_POListReviewController.getStock('R18181');
        }
        Test.stopTest();
    }

    @IsTest
    static void dueOutDetails(){
        //InterfaceCommonUtil.setInterface('IF-SERVICE-037', 'IF_ERP_Service_PartsDetail');
        Test.setMock(HttpCalloutMock.class, new IF_SERVICE_037_HttpMock());
        Test.startTest();
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        System.runAs(partPortal){
            DN_POListReviewController.dueOutDetails('R18181');
        }
        Test.stopTest();
    }

    @IsTest
    static void dueInDetails(){
        //InterfaceCommonUtil.setInterface('IF-SERVICE-037', 'IF_ERP_Service_PartsDetail');
        Test.setMock(HttpCalloutMock.class, new IF_SERVICE_037_HttpMock());
        Test.startTest();
        User partPortal = [SELECT Id FROM User WHERE UserName = 'part@test.test.com' LIMIT 1];
        System.runAs(partPortal){
            DN_POListReviewController.dueInDetails('R18181');
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

    public class IF_SERVICE_037_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_037_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"O_AVAIL_QTY":"0.000","O_MANUFACT":"","O_MATERIAL":"","O_MESG":"Successfully finished.[ZSS90101]","O_RESULT":{"MAKTX":"카트리지어셈블리","SVC_FLAG":"Y","AVA_FLAG":"N","NOTCD":"","COND_VALUE":"21403100.000000000","NETPR":"21403100.00","CURRENCY":"KRW","NETPR_ETC":"16587400.00","CURRENCY2":"KRW","KWMENG":"0.000","AUMNG":"0.000","LFMNG":"0.000","MEINS":"AY","BRGEW":"0.000","NTGEW":"60.000","GEWEI":"KG","GROES":"","PRODH":"SP3003016030160001","PRODH_T":"OTHERS","BULET":"","ZPRAT":"N","HERKL":"","PLIFZ":"60","M_MATNR":"","C_MTPOS":"N","DATAB":"2023-10-16","KONDM":"M","VTEXT":"","NOTCD_TEXT":"","SVRCD":"S","SVRCD_TEXT":"Service","AVRLT":"0","REMARK2":""},"O_THREAD":"18K_112L_BT/DIN40","ET_AVAIL":[],"ET_CROSS":[{"ITCCD":"","LABST":"0.000","SVRCD_TEXT":"Service","SEQ":"1-1","NOTCD":"","MAKTX":"CARTRIDGE ASSY","DDTEXT":"","MXNET":"","SVRCD":"S","MATNR":"R18181"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    
}