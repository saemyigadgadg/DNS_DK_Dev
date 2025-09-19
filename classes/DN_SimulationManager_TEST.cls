/** 
 * @Class :  DN_SimulationManager_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 23. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-23 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_SimulationManager_TEST {
    static String partnerUserName ='partSM@test.test.com';
    static String partnerUserName2 ='part2SM@test.test.com';
    
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
        System.runAs(adminTestUser) {
            Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-010', 'Real-Time');
            insert ifObj;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj.Id);
            insert ifClass;

            Account dealer = TestDataFactoryForDealerPortal.dealer;
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            insert dealer;
    
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;
    
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
            insert sequenceList;

            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            insert dealerCustomer;
    
            List<Product2> partList = new List<Product2>();
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18181', 'R18181영문', 'R18181국문')
            );
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18182', 'R18182영문', 'R18182국문')
            ); //Last
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18180', 'R18180영문', 'R18180국문')
            ); //Start
            insert partList;
        
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

        }
    
        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;
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
    }

    public class IF_DEALERSTOCK_010_HttpMock implements HttpCalloutMock {
        String resBody;
        public IF_DEALERSTOCK_010_HttpMock(String resBody){
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
    static void singleSimulation_TEST() {
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();
            List<String> partCodeList = new List<String>{
                'R18182'
            };
            DN_SimulationManager simulationHandler = new DN_SimulationManager(DN_SimulationManager.Type.CUSTOMERORDER, partCodeList, currentUser.getAgencyId());
            simulationHandler.singleSimulation();
        }

        Test.stopTest();
    }

    @isTest
    static void simulationIF_TEST() {
        String resBody = '{"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"ET_MAT":[{"KMEIN":"EA","SGST":"","KBETR":"100000","RATE":"","NETPR":"","MAKTX":"CENTER,LIVE","KONWA":"KRW","AVQTY":"9.000","NONMV":"","MATNR":"R18182","CUQTY":"11.000","KPEIN":" 1","IGST":"","NOTCD":"","CGST":"","HSCODE":"","OTHER":"","KUNNR":"","REPNR":"R18182"}]}';
        
        Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_010_HttpMock(resBody));
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

       

        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();
            List<String> partCodeList = new List<String>{
                'R18182', 'Test'
            };
            DN_SimulationManager simulationHandler = new DN_SimulationManager(DN_SimulationManager.Type.CUSTOMERORDER, partCodeList, currentUser.getAgencyId());
            Map<String, List<DN_SimulationManager.PartDetails>> partsMap = simulationHandler.simulation(currentUser, null);
        }

        Test.stopTest();
    }

}