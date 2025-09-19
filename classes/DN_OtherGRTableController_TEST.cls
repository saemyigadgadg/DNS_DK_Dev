@IsTest
public with sharing class DN_OtherGRTableController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerInventoryMovements__c goodsReceipt;
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
            Sequence__c seq =TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GR', 'DealerInventoryMovements__c', 'GoodsReceipt', 'C5{000000000}');
            insert seq;
            
            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-011', 'Real-Time');
            insert ifc;

            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
            insert ifClass;
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = '111111part@test.test.com';
            insert partnerTestUser;
        }
        System.runAs(partnerTestUser) {
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
            goodsReceipt = TestDataFactoryForDealerPortal.getGoodsReceipt(acc.Id,prod.Id);
            insert goodsReceipt;
        }
            
        
    }

    @IsTest
    static void test1(){
        try {
            Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_011_HttpMock());
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_OtherGRTableController.simulation(new List<String>{'R18181'});
                Test.stopTest();    
            }
            
        } catch (Exception e) {
            
        } 
    }

    @IsTest
    static void test2(){
        
        Test.startTest();
        System.runAs(partnerTestUser){
            List<DealerInventoryMovements__c> invenList = [
                SELECT Id,Name,
                Part__c,Quantity__c,CustomerPrice__c,DiscountPrice__c,DiscountAmount__c,
                Reason__c,Comment__c,InventoryItemNumber__c
                FROM DealerInventoryMovements__c WHERE Id =:goodsReceipt.Id
            ];
            DN_OtherGRTableController.insertGRList(invenList);
        }
        Test.stopTest();
        
    }

    public with sharing class IF_DEALERSTOCK_011_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ET_LIST":[{"NETPR":"3407800","LOC":"","WAERS":"KRW","REQTY":"0","STQTY":"0","MEINS":"SET","CUQTY":"0","THREAD":"90BNR10HTYNDBBCA25P4U214","MAKTX":"BEARING,BALL;ANGULAR CONTACT","DISPR":"3407800","MATNR":"R18181"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
}