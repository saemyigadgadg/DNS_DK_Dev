/** 
 * @Class :  DN_OtherDealerStockQtyModal_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 24. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-24 | Hyunwook Jin   | 최초작성 
 */ 
@iSTest
public with sharing class DN_OtherDealerStockQtyModal_TEST {
    static String partnerUserName ='partODoSM@test.test.com';
    static String partnerUserName2 ='part2ODoSM@test.test.com';

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
        Contact con3;
        System.runAs(adminTestUser) {
            Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-022', 'Real-Time');
            insert ifObj;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Multipart', ifObj.Id);
            insert ifClass;

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

            List<Contact> conList = new List<Contact>();
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            conList.add(con);
            con2 = TestDataFactoryForDealerPortal.createContact(dealer2.Id);
            conList.add(con2);
            con3 = TestDataFactoryForDealerPortal.createContact(dealer3.Id);
            conList.add(con3);
            insert conList;
    
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            Sequence__c seq0 = new Sequence__c(
                Name ='DealerCustomer_Dealer',
                Type__c = 'Dealer', 
                Pattern__c = 'C1{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq0);

            Sequence__c seq1 = new Sequence__c(
                Name ='DealerCustomer_Customer',
                Type__c = 'Customer', 
                Pattern__c = 'C5{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq1);

            Sequence__c seq2 = new Sequence__c(
                Name ='DealerOrder_General',
                Type__c = 'General', 
                Pattern__c = 'C8{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq2);

            Sequence__c seq3 = new Sequence__c(
                Name ='DealerOrder_Emergency',
                Type__c = 'Emergency', 
                Pattern__c = 'C9{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq3);

            Sequence__c seq4 = new Sequence__c(
                Name ='DealerReturnOrder',
                Type__c = 'ReturnOrder', 
                Pattern__c = 'C7{000000000}',
                SObjectAPI__c = 'DealerReturnOrderItem__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq4);
            insert sequenceList;

            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            insert dealerCustomer;
    
            List<Product2> partList = new List<Product2>();
            partList.add(
                TestDataFactoryForDealerPortal.getPart('110423-06969A', 'R18181영문', 'R18181국문')
            );
            partList.add(
                TestDataFactoryForDealerPortal.getPart('220210-03151', 'R18182영문', 'R18182국문')
            ); //Last
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18181', 'R18180영문', 'R18180국문')
            ); //Start
            insert partList;

            List<DealerStock__c> stockList = new List<DealerStock__c>();
            DealerStock__c stock = TestDataFactoryForDealerPortal.createDealerStock(dealer2.id, partList[0].id);
            stock.ExternalKey__c = '1846-10-40-'+dealer2.CustomerCode__c+'-'+partList[0].ProductCode;
            stock.AvailableQuantity__c = 20;
            stockList.add(stock);
            DealerStock__c stock2 = TestDataFactoryForDealerPortal.createDealerStock(dealer3.id, partList[0].id);
            stock2.ExternalKey__c = '1846-10-40-'+dealer3.CustomerCode__c+'-'+partList[0].ProductCode;
            stock2.AvailableQuantity__c = 20;
            stockList.add(stock2);
            DealerStock__c stock3 = TestDataFactoryForDealerPortal.createDealerStock(dealer2.id, partList[1].id);
            stock3.ExternalKey__c = '1846-10-40-'+dealer2.CustomerCode__c+'-'+partList[1].ProductCode;
            stock3.AvailableQuantity__c = 20;
            stockList.add(stock3);
            DealerStock__c stock4 = TestDataFactoryForDealerPortal.createDealerStock(dealer3.id, partList[1].id);
            stock4.ExternalKey__c = '1846-10-40-'+dealer3.CustomerCode__c+'-'+partList[1].ProductCode;
            stock4.AvailableQuantity__c = 20;
            stockList.add(stock4);
            insert stockList;
            
            List<ProductByPlant__c> plantByProductList = new List<ProductByPlant__c>();
            ProductByPlant__c plant1 = TestDataFactoryForDealerPortal.getProductByPlant(partList[0].Id,partList[1].Id);
            plant1.StartPart__c = partList[2].id;
            plant1.ReplacingPart__c = partList[1].id;
            plantByProductList.add(plant1);
            ProductByPlant__c plant2 = TestDataFactoryForDealerPortal.getProductByPlant(partList[1].Id,partList[1].Id);
            plant2.StartPart__c = partList[2].id;
            plantByProductList.add(plant2);
            ProductByPlant__c plant3 = TestDataFactoryForDealerPortal.getProductByPlant(partList[2].Id,partList[1].Id);
            plant3.ReplacingPart__c = partList[0].id;
            plant3.StartPart__c = partList[2].id;
            plantByProductList.add(plant3);
            insert plantByProductList;

            List<DealerDiscountRate__c> rateList = new List<DealerDiscountRate__c>();
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='A', PurchasingDealerGrade__c='A',Rate__c=10)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='B', PurchasingDealerGrade__c='A', Rate__c=5)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='C', PurchasingDealerGrade__c='A', Rate__c=5)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='A', PurchasingDealerGrade__c='B',Rate__c=10)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='B', PurchasingDealerGrade__c='B', Rate__c=6)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='C', PurchasingDealerGrade__c='B', Rate__c=5)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='A', PurchasingDealerGrade__c='C',Rate__c=10)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='B', PurchasingDealerGrade__c='C', Rate__c=6)
            );
            rateList.add(
                new DealerDiscountRate__c(SalesDealerGrade__c='C', PurchasingDealerGrade__c='B', Rate__c=5)
            );
            insert rateList;

        }

        List<User> partnerTestUsers = new List<User>();
        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        partnerTestUsers.add(partnerTestUser);

        User partnerTestUser2 = TestDataFactoryForDealerPortal.createTestPartPortalUser(con2.Id);
        partnerTestUser2.SalesOrganization__c = '1846';
        partnerTestUser2.DistributionChannel__c = '10';
        partnerTestUser2.Division__c = '40';
        partnerTestUser2.Username = partnerUserName+'2';
        partnerTestUsers.add(partnerTestUser2);

        User partnerTestUser3 = TestDataFactoryForDealerPortal.createTestPartPortalUser(con3.Id);
        partnerTestUser3.SalesOrganization__c = '1846';
        partnerTestUser3.DistributionChannel__c = '10';
        partnerTestUser3.Division__c = '40';
        partnerTestUser3.Username = partnerUserName+'3';
        partnerTestUsers.add(partnerTestUser3);

        insert partnerTestUsers;
        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.id);
            insert shipTo;

            DN_UserDetails currentUser = new DN_UserDetails();
            List<Product2> partList = [SELECT Id, ProductCode FROM Product2];
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
        }  

        new DN_OtherDealerStockQtyModal();
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
    static void getPartInfos_TEST() {
        String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"30","SVCLT":"0","SVC_FLAG":"N","NETPR":"76800.00","KWMENG":"0.000","VTEXT":"O Pricing Type","THREAD":"","DATAB":"2024-03-02","D_MATERIAL":"","MEINS":"EA","NTGEW":"7.500","SVRCD":"N","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"110423-06969A","AVAIL_QTY2":"0.000","NOTCD_TEXT":"","MAKTX":"BRACKET;SLIDE(YR)","NETPR_ETC":"59520.00","PRODH_T":"BRACKET,OTHER","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160002","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"76800.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"N","HERKL":"KR","SUB_MATERIAL":"220210-03151","KONDM":"O","BRGEW":"0.000","REPLACE":"X","AUMNG":"0.000"},{"PLIFZ":"60","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"44.000","VTEXT":"P Pricing Type","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","AVAIL_QTY2":"73.000","NOTCD_TEXT":"","MAKTX":"CENTER,LIVE","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"0.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"Y","HERKL":"KR","SUB_MATERIAL":"","KONDM":"P","BRGEW":"90.000","REPLACE":"","AUMNG":"0.000"}],"T_RETURN":[]}';
        
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_022_HttpMock(resBody));

        Test.startTest();

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            
            Map<String, DN_OtherDealerStockQtyModal.DealerStock> requestStockMap = new Map<String, DN_OtherDealerStockQtyModal.DealerStock>{};
            for(Product2 product :[SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2]) {
                DN_OtherDealerStockQtyModal.DealerStock stock = new DN_OtherDealerStockQtyModal.DealerStock();
                stock.partName = product.ProductCode;
                stock.part = product.Id;
                stock.partDetails = product.FM_MaterialDetails__c;
                stock.requestQuantity = 1;
                requestStockMap.put(stock.partName, stock);
            }

            DN_OtherDealerStockQtyModal.getPartInfos(requestStockMap);
        }

        Test.stopTest();
    }
}