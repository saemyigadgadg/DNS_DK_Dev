@isTest
public with sharing class IF_ERP_Board_Test {
    private static String className = 'IF_ERP_Board';

    public IF_ERP_Board_Test() {}

/* Mock Classes
    */
    public class IF_CSPLUS_030_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_030_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_O_LIST":[{"TYPE":"S","SEQNO":"SEQ001","PERNR":"PERN001","MSDZ":"08:00:00","MSDD":"2024-02-17","MESSAGE":"Operation completed successfully","LTXA1":"Maintenance Task","ISDZ":"08:30:00","ISDD":"2024-02-17","IEDZ":"12:00:00","IEDD":"2024-02-17","AUFNR":"ORD123456"}],"O_RETURN":{"TYPE":"S","MESSAGE":"Success","CODE":"200"}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Code
    */
    @IsTest
    static void IF_CSPLUS_030_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-030', className);
        Test.startTest();

        // Request 객체 생성 및 필드 값 설정
        IF_ERP_Board_Classes.IF_CSPLUS_030_Req request = new IF_ERP_Board_Classes.IF_CSPLUS_030_Req();
        request.I_FLAG = 'ACTIVE';
        request.I_ZCRMS0016 = new IF_ERP_Board_Classes.IF_CSPLUS_030_Req_I_ZCRMS0016();
        request.I_ZCRMS0016.AUFNR = 'ORD123456';
        request.I_ZCRMS0016.SEQNO = 'SEQ001';
        request.I_ZCRMS0016.PERNR = 'PERN001';

        IF_ERP_Board instance = new IF_ERP_Board();
        instance.IF_CSPLUS_030(request);

        // Response 객체 생성 및 필드 값 설정
        IF_ERP_Board_Classes.IF_CSPLUS_030_Res response = new IF_ERP_Board_Classes.IF_CSPLUS_030_Res();
        response.O_RETURN = new IF_ERP_Board_Classes.IF_CSPLUS_030_Res_O_RETURN();
        response.T_O_LIST = new List<IF_ERP_Board_Classes.IF_CSPLUS_030_Res_T_O_LIST>();

        // O_RETURN 필드 설정
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Success';

        // T_O_LIST 항목 추가 및 필드 설정
        IF_ERP_Board_Classes.IF_CSPLUS_030_Res_T_O_LIST listItem = new IF_ERP_Board_Classes.IF_CSPLUS_030_Res_T_O_LIST();
        listItem.AUFNR = 'ORD123456';
        listItem.SEQNO = 'SEQ001';
        listItem.PERNR = 'PERN001';
        listItem.MSDD = '2024-02-17';
        listItem.MSDZ = '08:00:00';
        listItem.ISDD = '2024-02-17';
        listItem.ISDZ = '08:30:00';
        listItem.IEDD = '2024-02-17';
        listItem.IEDZ = '12:00:00';
        listItem.LTXA1 = 'Maintenance Task';
        listItem.TYPE = 'S';
        listItem.MESSAGE = 'Operation completed successfully';

        response.T_O_LIST.add(listItem);

        Test.stopTest();
    }
}