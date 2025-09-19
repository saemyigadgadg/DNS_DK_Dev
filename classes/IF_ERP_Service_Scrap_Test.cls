@IsTest
public with sharing class IF_ERP_Service_Scrap_Test {
    private static String className = 'IF_ERP_Service_Scrap';

    public IF_ERP_Service_Scrap_Test() {}

/* Mock Classes
    */
    public class IF_SERVICE_047_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_047_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"228","MESSAGE":"Successfully finished."},"T_LIST":[{"PRT_TIME":"00:00:00","KTEXT":"부산지사","SVCMAN":"214788 김준태","SEQNO":"0010","RETURN_END_YN":"N","RETURN_TYPE_T":"","RETURN_YN":"Y","AUFNR":"000403908164","RETURN_TYPE":"2","MAKTX":"","SUPPLY_TYPE":"부품센타","ARBPL":"114F","MATNR":"400907-00303","REP_NAME":"","MENGE":"1.000","SERNR":"MB0013-000055","PRT_DATE":"0000-00-00","ISSUE_QTY":"0.000","NO_QTY":"1.000","NAME2":"","NAME1":"영광산업사","TEXT":"","QMNUM":"000302382164","TYPBZ":"DBC 130S","MEINS":"EA"},{"PRT_TIME":"00:00:00","KTEXT":"부산지사","SVCMAN":"214788 김준태","SEQNO":"0010","RETURN_END_YN":"N","RETURN_TYPE_T":"","RETURN_YN":"Y","AUFNR":"000403908186","RETURN_TYPE":"2","MAKTX":"","SUPPLY_TYPE":"부품센타","ARBPL":"114F","MATNR":"300419-00035B","REP_NAME":"","MENGE":"1.000","SERNR":"ML0494-000207","PRT_DATE":"0000-00-00","ISSUE_QTY":"0.000","NO_QTY":"1.000","NAME2":"","NAME1":"진현상사","TEXT":"","QMNUM":"000302382181","TYPBZ":"PUMA DNT2600L","MEINS":"EA"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_SERVICE_048_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_048_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_OUTPUT":[{"WADAT_IST":"2023-02-27","PRT_TIME":"18:17:17","KTEXT":"광명산업","MZEIT":"09:00:00","SEQNO":"0001","AUFNR":"000403908123","RETURN_TYPE":"신품반납","QMDAT":"2025-02-05","MAKTX":"TABLE ASSY;ROTARY","SUPPLY_TYPE":"부품센타","MATNR":"102501-00099K","MENGE":"2.000","RETURN_TEXT":"청구착오되었습니다.","SERNR":"MV0061-001292","PRT_DATE":"2025-02-10","NAME2":"","MATXT":"딜러포탈조친사항입력134567","NAME1":"유진금속공업(주)","TYPBZ":"VC 510","ENAME":"MKRC0393 김동현","QMNUM":"000302382116","RETURN_DT":"2025-02-10","MEINS":""}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]"}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @IsTest
    static void IF_SERVICE_047_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-047', className);
        Test.startTest();
        IF_ERP_Service_Scrap method = new IF_ERP_Service_Scrap();
        IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Req_I_USERINFO I_USERINFO  = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Req_I_USERINFO();
        I_USERINFO.BNAME = '';
        I_USERINFO.RNAME = '';
        I_USERINFO.HIER = '';
        I_USERINFO.KUNNR = '';
        I_USERINFO.LIFNR = '';
        I_USERINFO.VKORG = '';
        I_USERINFO.VTWEG = '';
        I_USERINFO.SPART = '';
        I_USERINFO.WERKS = '';
        I_USERINFO.ARBPL = '';
        I_USERINFO.PARNR = '';
        I_USERINFO.ENAME = '';
        I_USERINFO.KUNN2 = '';
        I_USERINFO.LAND1 = '';
        I_USERINFO.LGORT = '';
        I_USERINFO.DF_CHK = '';
        I_USERINFO.CO_CHK = '';        

        IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Req request  = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Req();
        request.I_DATUM_TO = '';
        request.I_DATUM_FROM = '';
        request.I_ARBPL = '';
        request.I_KTEXT = '';
        request.I_RETURN_TYPE = '';
        request.I_RETURN_YN = '';
        request.I_PARNR = '';
        request.I_ENAME = '';
        request.I_LANGU = '';
        request.I_AUFNR = '';
        request.I_MATNR = '';
        request.I_USERINFO = I_USERINFO;        
        
        IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res_O_RETURN O_RETURN = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        
        IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res_T_LIST T_LIST = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res_T_LIST();
        T_LIST.AUFNR = '';
        T_LIST.SERNR = '';
        T_LIST.TYPBZ = '';
        T_LIST.REP_NAME = '';
        T_LIST.MATNR = '';
        T_LIST.MAKTX = '';
        T_LIST.MENGE = '';
        T_LIST.MEINS = '';
        T_LIST.RETURN_TYPE = '';
        T_LIST.RETURN_TYPE_T = '';
        T_LIST.SUPPLY_TYPE = '';
        T_LIST.RETURN_END_YN = '';
        T_LIST.ARBPL = '';
        T_LIST.KTEXT = '';
        T_LIST.TEXT = '';
        T_LIST.ISSUE_QTY = '';
        T_LIST.RETURN_YN = '';
        T_LIST.NO_QTY = '';
        T_LIST.SVCMAN = '';
        T_LIST.PRT_DATE = '';
        T_LIST.PRT_TIME = '';
        T_LIST.NAME1 = '';
        T_LIST.NAME2 = '';
        T_LIST.SEQNO = '';
        T_LIST.QMNUM = '';        

        IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res response = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res();
        response.O_RETURN = O_RETURN ;
        response.T_LIST   = new List<IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res_T_LIST>{T_LIST};         

        method.IF_SERVICE_047(request);
        
        Test.stopTest(); 
    }
    
    @IsTest
    static void IF_SERVICE_048_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-048', className);
        Test.startTest();
        IF_ERP_Service_Scrap method = new IF_ERP_Service_Scrap();
        
        IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req_T_INPUT T_INPUT  = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req_T_INPUT();
        T_INPUT.MATNR = '';
        T_INPUT.AUFNR = '';

        IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req request  = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req();
        request.T_INPUT = new List<IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req_T_INPUT>{T_INPUT};
        

        IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res_O_RETURN O_RETURN = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res_T_OUTPUT T_OUTPUT = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res_T_OUTPUT();
        T_OUTPUT.AUFNR = '';
        T_OUTPUT.TYPBZ = '';
        T_OUTPUT.SERNR = '';
        T_OUTPUT.KTEXT = '';
        T_OUTPUT.ENAME = '';
        T_OUTPUT.NAME1 = '';
        T_OUTPUT.WADAT_IST = '';
        T_OUTPUT.MATNR = '';
        T_OUTPUT.MAKTX = '';
        T_OUTPUT.MATXT = '';
        T_OUTPUT.MENGE = '';
        T_OUTPUT.RETURN_TYPE = '';
        T_OUTPUT.RETURN_DT = '';
        T_OUTPUT.MEINS = '';
        T_OUTPUT.SUPPLY_TYPE = '';
        T_OUTPUT.NAME2 = '';
        T_OUTPUT.QMNUM = '';
        T_OUTPUT.SEQNO = '';
        T_OUTPUT.RETURN_TEXT = '';
        T_OUTPUT.PRT_DATE = '';
        T_OUTPUT.PRT_TIME = '';
        T_OUTPUT.QMDAT = '';
        T_OUTPUT.MZEIT = '';

        
        IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res response = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res();
        response.T_OUTPUT = new List<IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res_T_OUTPUT>{T_OUTPUT};
        response.O_RETURN = O_RETURN;
        
        method.IF_SERVICE_048(request);

        
        Test.stopTest(); 
    }    
}