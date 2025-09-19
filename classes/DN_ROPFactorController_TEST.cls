@IsTest
public with sharing class DN_ROPFactorController_TEST {
    static Account acc;
    static Contact con;
    static ROPAndStockFactorConfig__c areaFactor;
    static ROPAndStockFactorConfig__c areaROPCalculation;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static {
        List<User> userList = new List<User>();
        adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesOffice__c = '414A';
        adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesOffice__c = '414A';
        adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);
        insert userList;
        System.runAs(adminTestUser) {
            acc = TestDataFactoryForDealerPortal.dealer;
            insert acc;
            con = TestDataFactoryForDealerPortal.createContact(acc.Id);
            insert con;
            areaFactor = TestDataFactoryForDealerPortal.createRopConfig(acc.Id);
            insert areaFactor;
            areaROPCalculation = TestDataFactoryForDealerPortal.createAreaRopCalculation();
            insert areaROPCalculation;
            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-007', 'Real-Time');
            insert ifc;
    
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
            insert ifClass;
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'partSeotest1111@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';

            insert partnerTestUser;
        }
        System.runAs(partnerTestUser) {
            
        }
    }

    @IsTest
    static void test1(){
        
       
        Test.startTest();
        System.runAs(partnerTestUser){
            Map<String,Object> whereCondition = new Map<String,Object>();
            whereCondition.put('ABCIndicator__c','A');
            DN_ROPFactorController.getDataList(whereCondition);
            Map<String,List<ROPAndStockFactorConfig__c>> saveMap = new Map<String,List<ROPAndStockFactorConfig__c>>();
             
            saveMap.put('AreaMaxStockWeightingFactor',new List<ROPAndStockFactorConfig__c>{areaFactor});
            saveMap.put('AreaROPCalculationFactorConfiguration',new List<ROPAndStockFactorConfig__c>{areaROPCalculation});
            DN_ROPFactorController.ropFactorSave(saveMap);
        }
        Test.stopTest();
    }

    @IsTest
    static void test2(){
        Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_007_HttpMock());
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_ROPFactorController.getTslList(); 
        }
        Test.stopTest();
    }
    

    public with sharing class IF_DEALERSTOCK_007_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"조회완료"},"ET_SFT":[{"TSL":"50.00","SFT":"0.00"},{"TSL":"51.00","SFT":"0.03"},{"TSL":"52.00","SFT":"0.05"},{"TSL":"53.00","SFT":"0.08"},{"TSL":"54.00","SFT":"0.10"},{"TSL":"55.00","SFT":"0.13"},{"TSL":"56.00","SFT":"0.15"},{"TSL":"57.00","SFT":"0.18"},{"TSL":"58.00","SFT":"0.20"},{"TSL":"59.00","SFT":"0.23"},{"TSL":"60.00","SFT":"0.25"},{"TSL":"61.00","SFT":"0.28"},{"TSL":"62.00","SFT":"0.31"},{"TSL":"63.00","SFT":"0.33"},{"TSL":"64.00","SFT":"0.36"},{"TSL":"65.00","SFT":"0.39"},{"TSL":"66.00","SFT":"0.41"},{"TSL":"67.00","SFT":"0.44"},{"TSL":"68.00","SFT":"0.47"},{"TSL":"69.00","SFT":"0.50"},{"TSL":"70.00","SFT":"0.52"},{"TSL":"71.00","SFT":"0.55"},{"TSL":"72.00","SFT":"0.58"},{"TSL":"73.00","SFT":"0.61"},{"TSL":"74.00","SFT":"0.64"},{"TSL":"75.00","SFT":"0.67"},{"TSL":"76.00","SFT":"0.71"},{"TSL":"77.00","SFT":"0.74"},{"TSL":"78.00","SFT":"0.77"},{"TSL":"79.00","SFT":"0.81"},{"TSL":"80.00","SFT":"0.84"},{"TSL":"81.00","SFT":"0.88"},{"TSL":"82.00","SFT":"0.92"},{"TSL":"83.00","SFT":"0.95"},{"TSL":"84.00","SFT":"0.99"},{"TSL":"85.00","SFT":"1.04"},{"TSL":"86.00","SFT":"1.08"},{"TSL":"87.00","SFT":"1.13"},{"TSL":"88.00","SFT":"1.17"},{"TSL":"89.00","SFT":"1.23"},{"TSL":"90.00","SFT":"1.28"},{"TSL":"91.00","SFT":"1.34"},{"TSL":"92.00","SFT":"1.41"},{"TSL":"93.00","SFT":"1.48"},{"TSL":"94.00","SFT":"1.55"},{"TSL":"95.00","SFT":"1.64"},{"TSL":"96.00","SFT":"1.75"},{"TSL":"97.00","SFT":"1.88"},{"TSL":"98.00","SFT":"2.05"},{"TSL":"99.00","SFT":"2.33"},{"TSL":"99.99","SFT":"3.72"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
}