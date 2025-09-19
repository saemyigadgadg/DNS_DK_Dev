@isTest
public with sharing class IF_ERP_InstAndComm_Test {
    private static String className = 'IF_ERP_InstAndComm';

    public IF_ERP_InstAndComm_Test() {}

/* Mock Classes
    */
    public class IF_CSPLUS_036_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_036_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"OT_RETURN":[{"CODE":"","MESSAGE":"Work Order 403908089 Created And Released","TYPE":"S"},{"CODE":"","MESSAGE":"Equip Master ML0316-000089 Updated","TYPE":"S"}],"O_AUFNR":"403908089"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_043_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_043_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"OT_RETURN":[{"TYPE":"S","MESSAGE":"Order successfully processed","CODE":"200"}],"O_AUFNR":"ORD987654"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* TEST CODE
    */
    @IsTest
    static void IF_CSPLUS_036_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-036', className);
        Test.startTest();

        // Request 객체 생성 및 필드 값 설정
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Req request = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Req();
        request.I_EQUNR = 'EQ123456';
        request.I_SWERKS = 'Plant001';
        request.I_ARBPL = 'WorkCenter001';
        request.I_GSTRP = '2024-02-17';
        request.I_PARNR = 'Partner001';
        request.I_VBELN = 'VB123456';
        request.I_WADAT = '2024-02-18';
        request.I_LFDAT = '2024-02-19';
        request.I_VKBUR = 'SalesOffice001';
        request.I_AUGRU = 'Reason001';
        request.I_SOLDTO = 'Customer001';

        IF_ERP_InstAndComm instance = new IF_ERP_InstAndComm();
        instance.IF_CSPLUS_036(request);

        // Response 객체 생성 및 필드 값 설정
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res response = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res();
        response.OT_RETURN = new List<IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res_OT_RETURN>();
        response.O_AUFNR = 'ORD987654';

        // OT_RETURN 리스트에 항목 추가
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res_OT_RETURN returnItem = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res_OT_RETURN();
        returnItem.TYPE = 'S';
        returnItem.CODE = '200';
        returnItem.MESSAGE = 'Order successfully processed';

        response.OT_RETURN.add(returnItem);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_043_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-043', className);
        Test.startTest();

        // Request 객체 생성 및 필드 값 설정
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Req request = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Req();
        request.I_EQUNR = 'EQ123456';
        request.I_SWERKS = 'Plant001';
        request.I_ARBPL = 'WorkCenter001';
        request.I_GSTRP = '2024-02-17';
        request.I_PARNR = 'Partner001';
        request.I_VBELN = 'VB123456';
        request.I_WADAT = '2024-02-18';
        request.I_LFDAT = '2024-02-19';
        request.I_VKBUR = 'SalesOffice001';
        request.I_AUGRU = 'Reason001';
        request.I_SOLDTO = 'Customer001';
        request.I_AUFNR = 'ORD987654';

        // Response 객체 생성 및 필드 값 설정
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res response = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res();
        response.OT_RETURN = new List<IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res_OT_RETURN>();
        response.O_AUFNR = 'ORD987654';

        // OT_RETURN 리스트에 항목 추가
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res_OT_RETURN returnItem = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res_OT_RETURN();
        returnItem.TYPE = 'S';
        returnItem.CODE = '200';
        returnItem.MESSAGE = 'Order successfully processed';

        response.OT_RETURN.add(returnItem);
        
        IF_ERP_InstAndComm instance = new IF_ERP_InstAndComm();
        instance.IF_CSPLUS_043(request);
        Test.stopTest();
    }
}