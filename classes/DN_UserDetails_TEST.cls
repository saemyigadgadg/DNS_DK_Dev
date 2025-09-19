@isTest
public with sharing class DN_UserDetails_TEST {
    @TestSetup
    static void makeData(){
        Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-DEALERSTOCK-009', 'Real-Time');
        insert ifObj;

        InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_DealerStock', ifObj.Id);
        insert ifClass;
    }

    public class IF_DEALERSTOCK_009_HttpMock implements HttpCalloutMock {
        String resBody;
        public IF_DEALERSTOCK_009_HttpMock(String resBody){
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
    static void getUserInfo_Test() {
        String resBody = '{"T_RETURN":[{"ZZKVGR4":"A","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-22.50","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"B","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-15.00","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"C","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-12.00","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"D","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-13.35","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2016-05-02","KZBZG":""}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Success"}}';
        Test.setMock(HttpCalloutMock.class, new IF_DEALERSTOCK_009_HttpMock(resBody));
        test.startTest();

        DN_UserDetails currentUserInfo = new DN_UserDetails();

        System.debug('Current User SalesOranization : ' +currentUserInfo.getSalesOranizationByUser());
        System.debug('Current User SalesOranization2 : ' +currentUserInfo.getSalesOranization());
        System.debug('Current User DistributionChannel : ' +currentUserInfo.getDistributionChannelByUser());
        System.debug('Current User DistributionChannel2 : ' +currentUserInfo.getDistributionChannel());
        System.debug('Current User Division : ' +currentUserInfo.getDivisionByUser());
        System.debug('Current User Division2 : ' +currentUserInfo.getDivision());
        System.debug('Current User AccountId : ' +currentUserInfo.getAgencyId());
        System.debug('Current User AccountId2 : ' +currentUserInfo.getAgencyIdByUser());
        System.debug('Current User AccountName : ' +currentUserInfo.getAgencyName());
        System.debug('Current User AccountCode : ' +currentUserInfo.getAgencyCustomerCodeByUser());
        
        System.debug('Current User Country : ' +currentUserInfo.getCountry());
        System.debug('Current User LanguageLoacleKey : ' +currentUserInfo.getLanguageLocaleKey());
        System.debug('Current User DealerGrade : ' +currentUserInfo.getDealerGrade());
        System.debug('Current User Admin : ' +currentUserInfo.getIsAdmin());
        System.debug('Current User DealerGradeRate : ' +currentUserInfo.getDealerGradeRate());
        

        test.stopTest();
    }
}