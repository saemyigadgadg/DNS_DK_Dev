@IsTest
public with sharing class IF_ERP_Service_PartsDetail_Test {
    private static String className = 'IF_ERP_Service_PartsDetail';

    public IF_ERP_Service_PartsDetail_Test() {}

/* Mock Classes
    */
    public class IF_SERVICE_037_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_037_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"O_AVAIL_QTY":"0.000","O_MANUFACT":"","O_MATERIAL":"","O_MESG":"Successfully finished.[ZSS90101]","O_RESULT":{"MAKTX":"카트리지어셈블리","SVC_FLAG":"Y","AVA_FLAG":"N","NOTCD":"","COND_VALUE":"21403100.000000000","NETPR":"21403100.00","CURRENCY":"KRW","NETPR_ETC":"16587400.00","CURRENCY2":"KRW","KWMENG":"0.000","AUMNG":"0.000","LFMNG":"0.000","MEINS":"AY","BRGEW":"0.000","NTGEW":"60.000","GEWEI":"KG","GROES":"","PRODH":"SP3003016030160001","PRODH_T":"OTHERS","BULET":"","ZPRAT":"N","HERKL":"","PLIFZ":"60","M_MATNR":"","C_MTPOS":"N","DATAB":"2023-10-16","KONDM":"M","VTEXT":"","NOTCD_TEXT":"","SVRCD":"S","SVRCD_TEXT":"Service","AVRLT":"0","REMARK2":""},"O_THREAD":"18K_112L_BT/DIN40","ET_AVAIL":[],"ET_CROSS":[{"ITCCD":"","LABST":"0.000","SVRCD_TEXT":"Service","SEQ":"1-1","NOTCD":"","MAKTX":"CARTRIDGE ASSY","DDTEXT":"","MXNET":"","SVRCD":"S","MATNR":"101507-00422C"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_SERVICE_038_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_038_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_LIST":[{"MAKTX":"라이브센터","MATNR":"R18181","AVA_FLAG":"N"},{"MAKTX":"라이브센터","MATNR":"R18182","AVA_FLAG":"N"}],"O_COUNT":"2"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    @IsTest
    static void IF_SERVICE_037_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-037', className);
        Test.startTest();
        IF_ERP_Service_PartsDetail method = new IF_ERP_Service_PartsDetail();
        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO I_USERINFO  = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO();
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

        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req request  = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req();
        request.I_MATNR = 'I_MATNR';
        request.I_LANGU = 'KO';
        request.I_KVGR5 = '';
        request.I_REPLACE = '';        
        request.I_USERINFO = I_USERINFO;


        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_O_RESULT O_RESULT = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_O_RESULT();
        O_RESULT.MAKTX = '';
        O_RESULT.SVC_FLAG = '';
        O_RESULT.AVA_FLAG = '';
        O_RESULT.NOTCD = '';
        O_RESULT.COND_VALUE = '';
        O_RESULT.NETPR = '';
        O_RESULT.IF_CURRENCY = '';
        O_RESULT.NETPR_ETC = '';
        O_RESULT.CURRENCY2 = '';
        O_RESULT.KWMENG = '';
        O_RESULT.AUMNG = '';
        O_RESULT.LFMNG = '';
        O_RESULT.MEINS = '';
        O_RESULT.BRGEW = '';
        O_RESULT.NTGEW = '';
        O_RESULT.GEWEI = '';
        O_RESULT.GROES = '';
        O_RESULT.PRODH = '';
        O_RESULT.PRODH_T = '';
        O_RESULT.BULET = '';
        O_RESULT.ZPRAT = '';
        O_RESULT.HERKL = '';
        O_RESULT.PLIFZ = '';
        O_RESULT.M_MATNR = '';
        O_RESULT.C_MTPOS = '';
        O_RESULT.DATAB = '';
        O_RESULT.KONDM = '';
        O_RESULT.VTEXT = '';
        O_RESULT.NOTCD_TEXT = '';
        O_RESULT.SVRCD = '';
        O_RESULT.SVRCD_TEXT = '';
        O_RESULT.AVRLT = '';
        O_RESULT.REMARK2 = '';

        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_O_RETURN O_RETURN = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';
        O_RETURN.LOG_NO = '';
        O_RETURN.LOG_MSG_NO = '';
        O_RETURN.MESSAGE_V1 = '';
        O_RETURN.MESSAGE_V2 = '';
        O_RETURN.MESSAGE_V3 = '';
        O_RETURN.MESSAGE_V4 = '';

        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_AVAIL ET_AVAIL = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_AVAIL();
        ET_AVAIL.DEALER_CD = '';
        ET_AVAIL.NAME1 = '';
        ET_AVAIL.AVQTY = '';
        ET_AVAIL.NONMV = '';        

        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS ET_CROSS = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS();
        ET_CROSS.SEQ = '';
        ET_CROSS.MATNR = '';
        ET_CROSS.MAKTX = '';
        ET_CROSS.ITCCD = '';
        ET_CROSS.LABST = '';
        ET_CROSS.NOTCD = '';
        ET_CROSS.DDTEXT = '';
        ET_CROSS.SVRCD = '';
        ET_CROSS.MXNE = '';
        ET_CROSS.SVRCD_TEXT = '';


        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res response = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res();
        method.IF_SERVICE_037(request);
        response.O_MESG = '';
        response.O_AVAIL_QTY = '';
        response.O_THREAD = '';
        response.O_MATERIAL = '';
        response.O_MANUFACT = '';
        response.O_RESULT = O_RESULT;
        response.O_RETURN = O_RETURN;
        response.ET_AVAIL = new List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_AVAIL>{ET_AVAIL};
        response.ET_CROSS = new List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS>{ET_CROSS}; 

        Test.stopTest(); 
    }    

    @IsTest
    static void IF_SERVICE_038_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-038', className);
        Test.startTest();
        IF_ERP_Service_PartsDetail method = new IF_ERP_Service_PartsDetail();

        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req_I_USERINFO I_USERINFO  = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req_I_USERINFO();
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


        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req request  = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req();
        request.I_MATNR = 'I_MATNR';
        request.I_LANGU = 'KO';        
        request.I_USERINFO = I_USERINFO;

        

        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_O_RETURN O_RETURN = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';
        O_RETURN.LOG_NO = '';
        O_RETURN.LOG_MSG_NO = '';
        O_RETURN.MESSAGE_V1 = '';
        O_RETURN.MESSAGE_V2 = '';
        O_RETURN.MESSAGE_V3 = '';
        O_RETURN.MESSAGE_V4 = '';

        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST T_LIST = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST();
        T_LIST.MATNR = '';
        T_LIST.MAKTX = '';
        T_LIST.AVA_FLAG = '';



        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res response = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res();
        response.O_RETURN  = O_RETURN;
        response.T_LIST  = new List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST>{T_LIST};        
        response.O_MESG = '';
        response.O_COUNT = '';
        
        
        
        method.IF_SERVICE_038(request);
        Test.stopTest(); 
    }    
}