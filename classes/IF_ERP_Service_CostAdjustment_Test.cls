@IsTest
public with sharing class IF_ERP_Service_CostAdjustment_Test {
    private static String className = 'IF_ERP_Service_CostAdjustment';

    public IF_ERP_Service_CostAdjustment_Test() {}

/* Mock Classes
    */
    public class IF_SERVICE_043_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_043_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully selected."},"ET_HD":[{"COCST":"0.00","EDCST":"0.00","TLCST":"0.00","INCST":"0.00","SPMON":"202501","TTCST":"0.00"}],"ET_ITEM":[{"ILART":"104","AUSBS":"2025-01-17","PAY_MH":"13.0","ISDZ":"08:00:00","WAERS":"KRW","ERSDA":"2025-01-17","ARBPL":"114C","ILATX":"설치시운전","KTEXT":"수원지사","NAME1":"세종정밀","RMZHL":"00000000","ISDD":"2025-01-17","WORKCD_NM":"","TEMPHR":"0.0","TLCST":"0.00","MAINHR":"13.0","AEDAT":"2025-01-17","AUZTB":"10:00:00","EXFLG":"","WORK_SUM":"0.0","TXT":"Inspection Order","WORKCD":"","AUFNR":"000403907875","RESP_MAN_NM":"533390 장성현","WEB_CHK":"","SVCMAN_NAME":"533390 장성현","ETC_HR":"0.0","LTXA1":"","KUNUM":"0001092694","TYPBZ":"MYNX 6500 II","SERNR":"MV0048-003931","ERDAT":"2025-01-17","ISMNW":"13.0","STD_MH":"0.0","AUART":"CS01","SEQNO":"0000","OPTNHR":"0.0","ISMNE":"H"},{"ILART":"104","AUSBS":"2025-01-15","PAY_MH":"7.0","ISDZ":"13:00:00","WAERS":"KRW","ERSDA":"2025-01-17","ARBPL":"114C","ILATX":"설치시운전","KTEXT":"수원지사","NAME1":"유일미크론","RMZHL":"00000000","ISDD":"2025-01-15","WORKCD_NM":"","TEMPHR":"0.0","TLCST":"0.00","MAINHR":"7.0","AEDAT":"2025-01-17","AUZTB":"14:00:00","EXFLG":"","WORK_SUM":"0.0","TXT":"Inspection Order","WORKCD":"","AUFNR":"000403907884","RESP_MAN_NM":"213067 한마음","WEB_CHK":"","SVCMAN_NAME":"213067 한마음","ETC_HR":"0.0","LTXA1":"","KUNUM":"0001087921","TYPBZ":"LYNX 2100MA-NT","SERNR":"ML0328-000165","ERDAT":"2025-01-17","ISMNW":"7.0","STD_MH":"0.0","AUART":"CS01","SEQNO":"0000","OPTNHR":"0.0","ISMNE":"H"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_SERVICE_044_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_044_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @IsTest
    static void IF_SERVICE_044_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-044', className);
        Test.startTest();
        IF_ERP_Service_CostAdjustment method = new IF_ERP_Service_CostAdjustment();
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req_IT_ITEM IT_ITEM = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req_IT_ITEM();
        IT_ITEM.AUFNR = '';
        IT_ITEM.SEQNO = '';
        IT_ITEM.WEB_CHK = '';

        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req request  = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req();
        request.IT_ITEM = new List<IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req_IT_ITEM>{IT_ITEM};

        
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res_O_RETURN O_RETURN = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res response = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res();
        response.O_RETURN = O_RETURN;
        method.IF_SERVICE_044(request);
        Test.stopTest(); 
    }    

    @IsTest
    static void IF_SERVICE_043_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-043', className);
        Test.startTest();
        IF_ERP_Service_CostAdjustment method = new IF_ERP_Service_CostAdjustment();
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req_I_USERINFO I_USERINFO  = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req_I_USERINFO();
        I_USERINFO.BNAME = '';
        I_USERINFO.WERKS = '';
        I_USERINFO.ARBPL = '';


        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req request  = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req();
        request.I_AUFNR = '';
        request.I_DATE_FR = '';
        request.I_DATE_TO = '';
        request.I_TYPE = '';


        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_O_RETURN O_RETURN  = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        


        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_ET_ITEM  ET_ITEM   = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_ET_ITEM();
        ET_ITEM.AUART = '';
        ET_ITEM.TXT = '';
        ET_ITEM.AUFNR = '';
        ET_ITEM.SEQNO = '';
        ET_ITEM.RMZHL = '';
        ET_ITEM.ILART = '';
        ET_ITEM.ILATX = '';
        ET_ITEM.KUNUM = '';
        ET_ITEM.NAME1 = '';
        ET_ITEM.TYPBZ = '';
        ET_ITEM.SERNR = '';
        ET_ITEM.ERDAT = '';
        ET_ITEM.ERSDA = '';
        ET_ITEM.ARBPL = '';
        ET_ITEM.KTEXT = '';
        ET_ITEM.RESP_MAN_NM = '';
        ET_ITEM.SVCMAN_NAME = '';
        ET_ITEM.LTXA1 = '';
        ET_ITEM.ISDD = '';
        ET_ITEM.ISDZ = '';
        ET_ITEM.AUSBS = '';
        ET_ITEM.AUZTB = '';
        ET_ITEM.MAINHR = '';
        ET_ITEM.TEMPHR = '';
        ET_ITEM.OPTNHR = '';
        ET_ITEM.ETC_HR = '';
        ET_ITEM.ISMNW = '';
        ET_ITEM.ISMNE = '';
        ET_ITEM.EXFLG = '';
        ET_ITEM.TLCST = '';
        ET_ITEM.WAERS = '';
        ET_ITEM.AEDAT = '';
        ET_ITEM.WEB_CHK = '';
        ET_ITEM.WORKCD = '';
        ET_ITEM.WORKCD_NM = '';
        ET_ITEM.WORK_SUM = '';
        ET_ITEM.STD_MH = '';
        ET_ITEM.PAY_MH = '';

        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_ET_HD    ET_HD     = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_ET_HD();
        ET_HD.SPMON = '';
        ET_HD.TLCST = '';
        ET_HD.INCST = '';
        ET_HD.EDCST = '';
        ET_HD.COCST = '';
        ET_HD.TTCST = '';

        
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res response = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res();
        response.O_RETURN = O_RETURN; 
        response.ET_ITEM  = new List<IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_ET_ITEM>{ET_ITEM}; 
        response.ET_HD    = new List<IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res_ET_HD>{ET_HD};         

        method.IF_SERVICE_043(request);
        Test.stopTest(); 
    }    
}