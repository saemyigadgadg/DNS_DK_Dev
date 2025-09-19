@IsTest
public with sharing class DN_QueryReplacementController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerPartMasterByMPPS__c partByMpps;
    static MonthlyDemandSummaryByDealer__c monSummByDealer;
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
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
        }
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'partSeotest1111@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';
            insert partnerTestUser;
        }
        System.runAs(adminTestUser) {
            partByMpps = TestDataFactoryForDealerPortal.getPartMasterByMpps(prod.Id,acc.Id);
            partByMpps.ReorderPoint__c = 0;
            partByMpps.MaximumStock__c = 0;
            partByMpps.OwnerId=partnerTestUser.Id;
            insert partByMpps;
            monSummByDealer = TestDataFactoryForDealerPortal.createMonDemSumByDealer(prod.Id,acc.Id);
            monSummByDealer.OwnerId=partnerTestUser.Id;
            insert monSummByDealer;
            //IF
            Interface__c ifc = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-001', 'Real-Time');
            insert ifc;
    
            InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifc.Id);
            insert ifClass;
        }   
    }

    @IsTest
    static void test1(){
        
        Test.startTest();
        System.runAs(partnerTestUser) {
            Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_001_HttpMock());
            Map<String,Object> search = new Map<String,Object>();
            DateTime historyDateStart = DateTime.now().addDays(-7);
            DateTime historyDateEnd = DateTime.now().addDays(+7);
            search.put('historyDateStart',historyDateStart.format('yyyy-MM-dd'));
            search.put('historyDateEnd',historyDateEnd.format('yyyy-MM-dd'));
            search.put('productCode', 'R18181');
            DN_QueryReplacementController.getReplacementList(search);
        }
        Test.stopTest();
        
    }



    public with sharing class IF_DEALERSTOCK_001_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"조회 완료","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"ET_HIST":[{"MMSTA":"","MABST":"1","DMD09":"0","MAABC":"I","VERPR":"0","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"CARTRIDGE ASSY;SPINDLE","MATNR":"R18181","MINBE":"1","DMD18":"0","LSTNR":"101507-00469H","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240220","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"1","DMD09":"0","MAABC":"H","VERPR":"439400","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,DUCT;STEEL APRON","MATNR":"110505-00072","MINBE":"1","DMD18":"0","LSTNR":"110505-00072","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"1","CHGDT":"20240219","FRQ18":"1","DMD10":"0","SVRCD":"S","FRQ12":"1","MEINS":"EA"},{"MMSTA":"N1","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"167600","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"GEAR,SPUR","MATNR":"130424-00319","MINBE":"0","DMD18":"0","LSTNR":"130424-00319","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240103","FRQ18":"0","DMD10":"0","SVRCD":"N","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"5452600","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"BALL SCREW;SMX3100L A-AXIS(R/S)","MATNR":"130510-01215A","MINBE":"0","DMD18":"0","LSTNR":"130510-01215A","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240322","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"N","VERPR":"0","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"HOUSING,BEARING;FRONT","MATNR":"140203-00901","MINBE":"0","DMD18":"0","LSTNR":"140203-00901","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240129","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"2432000","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"HOUSING,BEARING;FRONT","MATNR":"140203-00901-E","MINBE":"0","DMD18":"0","LSTNR":"140203-00901-E","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240129","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"40800","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"SWITCH,PRESSURE","MATNR":"301413-00493","MINBE":"0","DMD18":"0","LSTNR":"301413-00493","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240306","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"0","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"CABLE ASSY,CONTROL;TURRET PULSE CODER","MATNR":"310209-10597B","MINBE":"0","DMD18":"0","LSTNR":"310209-10597B","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240320","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"AY"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"84500","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"RADIATOR","MATNR":"400821-00355C-06","MINBE":"0","DMD18":"0","LSTNR":"400821-00355C-06","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240124","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"696100","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"GEAR,MOTOR","MATNR":"900115-00088C-P1","MINBE":"0","DMD18":"0","LSTNR":"900115-00088C-P1","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240322","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"SET"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"351500","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,TELESCOPIC;X-AXIS","MATNR":"L55611011E","MINBE":"0","DMD18":"0","LSTNR":"L55611011E","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240326","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"374400","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,SIDE;LEFT","MATNR":"L55621281G","MINBE":"0","DMD18":"0","LSTNR":"L55621281G","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240111","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"516100","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,TELESCOPIC","MATNR":"L55651011E","MINBE":"0","DMD18":"0","LSTNR":"L55651011E","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240117","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"}]}';
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
}