@IsTest
public with sharing class IF_ERP_Service_InstAndComm_Test {
    private static String className = 'IF_ERP_Service_InstAndComm';

    public IF_ERP_Service_InstAndComm_Test() {}

/* Mock Classes
    */
    public class IF_SERVICE_045_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_045_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully saved ![ZCS02081]"},"O_DEL_MSG":"","O_TIME":"","O_UPD_MSG":"File upload was successful.","T_MOTION":[{"AUSBS":"2025-02-11","HOL_CHK":"","CHK_FLAG":"","CONF":"","GRUND":"","ISDZ":"00:30:00","ZFLAG":"","RMZHL":"00000000","ISDD":"2025-02-11","TEMPHR":"","AENAM":"","MANDT":"","MAINHR":"","AEDAT":"0000-00-00","AUZTB":"07:00:00","PERNR":"00006520","OPTCHK5":"","OPTCHK4":"","OPTCHK3":"","OPTCHK2":"","OPTCHK1":"","WERKS":"","WORKCD":"","AUFNR":"000403908071","AEZET":"00:00:00","ERNAM":"","SVCMAN_NAME":"이재구","ETC_HR":"0.0","OT_CHK":"","LTXA1":"","ERDAT":"0000-00-00","ISMNW":"6.5","RUECK":"0000000000","EXRSN":"","HDAYWDV":"","ETC_TXT":"","OPTNHR5":"","OPTNHR4":"","OPTNHR3":"","OPTNHR2":"","OPTNHR1":"","SEQNO":"0001","ERZET":"00:00:00","WORKNO":"0000","ISMNW_PDK":"0.0","ISMNE":""}],"T_RETURN":[],"T_TMP":[{"FILENAME":"up.txt","FILE_SIZE":"","DESC":"up.txt","LINE":"[B@7904289a","EVISEQX":"01"}],"T_DEL":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);

            System.debug(res.getBody());
            return res;
        }
    }

    @IsTest
    static void IF_SERVICE_045_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-045', className);
        Test.startTest();
        IF_ERP_Service_InstAndComm method = new IF_ERP_Service_InstAndComm();

        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_SEL        I_SEL   = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_SEL();
        I_SEL.AUFNR = '';
        I_SEL.EQUNR = '';
        I_SEL.TYPBZ = '';
        I_SEL.SERNR = '';
        I_SEL.INSPECTION_TP = '';
        I_SEL.DEALER = '';
        I_SEL.DEALER_NM = '';
        I_SEL.INBDT = '';
        I_SEL.INSPN_DT = '';
        I_SEL.WORK_PLACE = '';
        I_SEL.WORK_CONTENTS = '';
        I_SEL.CONF_TEXT = '';
        I_SEL.RUECK = '';
        I_SEL.RMZHL = '';
        I_SEL.NAME1 = '';
        I_SEL.TELF1 = '';
        I_SEL.WO_NAME1 = '';
        I_SEL.WO_TELF1 = '';        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_INFO       I_INFO  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_INFO();
        I_INFO.AUFNR = '';
        I_INFO.AUART = '';
        I_INFO.ORDER_TYPE_TXT = '';
        I_INFO.QMNUM = '';
        I_INFO.ILART = '';
        I_INFO.DMACTTYPE_TXT = '';
        I_INFO.QMDAT = '';
        I_INFO.GSTRP = '';
        I_INFO.LTRMN = '';
        I_INFO.QMTXT = '';
        I_INFO.TXTQM = '';
        I_INFO.EQUNR = '';
        I_INFO.MATNR = '';
        I_INFO.TYPBZ = '';
        I_INFO.SERNR = '';
        I_INFO.INBDT = '';
        I_INFO.RBNR = '';
        I_INFO.IDATE = '';
        I_INFO.STAND_WE = '';
        I_INFO.MDOCM = '';
        I_INFO.KUNNR = '';
        I_INFO.NAME = '';
        I_INFO.TELEPHONE = '';
        I_INFO.REP_NAME = '';
        I_INFO.TAX_NO_2 = '';
        I_INFO.ABCKZ = '';
        I_INFO.BEBER = '';
        I_INFO.CONTACT_TYPE = '';
        I_INFO.CONTACT_NAME = '';
        I_INFO.CONTACT_MOBILE = '';
        I_INFO.CONTACT_TEL = '';
        I_INFO.PART_PRICE = '';
        I_INFO.LABOR_PRICE = '';
        I_INFO.TOT_AMOUNT = '';
        I_INFO.DISCOUNT_AMT = '';
        I_INFO.WAERS = '';
        I_INFO.VBELN = '';
        I_INFO.ERDAT = '';
        I_INFO.ERNAM = '';
        I_INFO.ERZET = '';
        I_INFO.AEDAT = '';
        I_INFO.AENAM = '';
        I_INFO.AEZET = '';
        I_INFO.ARBPL = '';
        I_INFO.WTY_TYPE = '';
        I_INFO.NOTIFTIME = '';
        I_INFO.MOBILE = '';
        I_INFO.LTRUR = '';
        I_INFO.ISMNW = '';
        I_INFO.ZDIST = '';
        I_INFO.OTHER_COST = '';
        I_INFO.ZENGNO = '';
        I_INFO.USNAM = '';
        I_INFO.UDATE = '';
        I_INFO.UTIME = '';        
        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_COS        I_COS  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_COS();
        I_COS.AUFNR = '';
        I_COS.COMPANY = '';
        I_COS.SRV_NM = '';
        I_COS.TEL_NO = '';
        I_COS.FAX_NO = '';
        I_COS.MOBILE_NO = '';
        I_COS.EMAIL = '';
        I_COS.ADDR = '';
        I_COS.ADDR2 = '';
        I_COS.EQUNR = '';        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_OPTM       I_OPTM  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_OPTM();
        
        I_OPTM.TEMPHR = '';
        I_OPTM.CHK_FLAG = '';
        I_OPTM.MAINHR = '';
        I_OPTM.OPTNHR1 = '';
        I_OPTM.OPTNHR2 = '';
        I_OPTM.OPTNHR3 = '';
        I_OPTM.OPTNHR4 = '';
        I_OPTM.OPTNHR5 = '';
        I_OPTM.HDAYWDV = '';
        I_OPTM.TOTALHR = '';
        I_OPTM.OPTCHK1 = '';
        I_OPTM.OPTCHK2 = '';
        I_OPTM.OPTCHK3 = '';
        I_OPTM.OPTCHK4 = '';
        I_OPTM.OPTCHK5 = '';
        I_OPTM.ETC_HR = '';
        I_OPTM.ETC_TXT = '';        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_CST_PRP    I_CST_PRP  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_CST_PRP();
        I_CST_PRP.WERKS = '';
        I_CST_PRP.AUFNR = '';
        I_CST_PRP.EQUNR = '';
        I_CST_PRP.ZELEC = '';
        I_CST_PRP.ZLUB = '';
        I_CST_PRP.ZHYD = '';
        I_CST_PRP.ZPNEU = '';
        I_CST_PRP.ZLAYOUT = '';
        I_CST_PRP.ZFOUND = '';
        I_CST_PRP.ERDAT = '';
        I_CST_PRP.ERNAM = '';
        I_CST_PRP.ERZET = '';
        I_CST_PRP.AEDAT = '';
        I_CST_PRP.AENAM = '';
        I_CST_PRP.AEZET = '';        
        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_INSPEC     T_INSPEC  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_INSPEC();
        T_INSPEC.CK = '';
        T_INSPEC.SECTN = '';
        T_INSPEC.INSP_CONTENTS = '';
        T_INSPEC.FAULTY = '';
        T_INSPEC.RSLT = '';
        T_INSPEC.ENABLE = '';
        T_INSPEC.REQUIRE = '';
        T_INSPEC.SEQ = '';
        T_INSPEC.SEQ2 = '';        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_DEL        T_DEL  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_DEL();
        T_DEL.DOCNO = '';
        T_DEL.FILENAME = '';        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP        T_TMP  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP();
        T_TMP.FILENAME = '';
        T_TMP.IF_DESC = '';
        T_TMP.EVISEQX = '';
        T_TMP.LINE = '';
        T_TMP.FILE_SIZE = '';        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_MOTION     T_MOTION  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_MOTION();
        T_MOTION.AUFNR = '';
        T_MOTION.RUECK = '';
        T_MOTION.WORKNO = '';
        T_MOTION.SEQNO = '';
        T_MOTION.PERNR = '';
        T_MOTION.SVCMAN_NAME = '';
        T_MOTION.ISDD = '';
        T_MOTION.ISDZ = '';
        T_MOTION.AUSBS = '';
        T_MOTION.AUZTB = '';
        T_MOTION.ISMNW = '';
        T_MOTION.ISMNW_PDK = '';
        T_MOTION.HOL_CHK = '';
        T_MOTION.OT_CHK = '';
        T_MOTION.LTXA1 = '';
        T_MOTION.RMZHL = '';
        T_MOTION.ISMNE = '';
        T_MOTION.ZFLAG = '';
        T_MOTION.TEMPHR = '';
        T_MOTION.CHK_FLAG = '';
        T_MOTION.MAINHR = '';
        T_MOTION.OPTNHR1 = '';
        T_MOTION.OPTNHR2 = '';
        T_MOTION.OPTNHR3 = '';
        T_MOTION.OPTNHR4 = '';
        T_MOTION.OPTNHR5 = '';
        T_MOTION.HDAYWDV = '';
        T_MOTION.OPTCHK1 = '';
        T_MOTION.OPTCHK2 = '';
        T_MOTION.OPTCHK3 = '';
        T_MOTION.OPTCHK4 = '';
        T_MOTION.OPTCHK5 = '';
        T_MOTION.ETC_HR = '';
        T_MOTION.ETC_TXT = '';
        T_MOTION.ERDAT = '';
        T_MOTION.ERNAM = '';
        T_MOTION.ERZET = '';
        T_MOTION.AEDAT = '';
        T_MOTION.AENAM = '';
        T_MOTION.AEZET = '';
        T_MOTION.WERKS = '';
        T_MOTION.CONF = '';
        T_MOTION.GRUND = '';
        T_MOTION.WORKCD = '';
        T_MOTION.EXRSN = '';        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_CODE_INFO  T_CODE_INFO  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_CODE_INFO();
        T_CODE_INFO.WERKS = '';
        T_CODE_INFO.AUFNR = '';
        T_CODE_INFO.EQUNR = '';
        T_CODE_INFO.ZSEQ = '';
        T_CODE_INFO.ZCD1 = '';
        T_CODE_INFO.ZSEQ1 = '';
        T_CODE_INFO.ZCD2 = '';
        T_CODE_INFO.ZSEQ2 = '';
        T_CODE_INFO.ZCD3 = '';
        T_CODE_INFO.ZSEQ3 = '';
        T_CODE_INFO.ZISE = '';
        T_CODE_INFO.ZISR = '';
        T_CODE_INFO.ZECT = '';
        T_CODE_INFO.ERNAM = '';
        T_CODE_INFO.ERDAT = '';
        T_CODE_INFO.ERZET = '';
        T_CODE_INFO.AENAM = '';
        T_CODE_INFO.AEDAT = '';
        T_CODE_INFO.AEZET = '';
        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req request  = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req();
        request.I_UNAME = '';
        request.I_COUNSEL = '';
        request.I_CONF = '';
        request.I_HECARE = '';
        request.I_WERKS = '';
        request.I_ARBPL = '';        
        
        request.I_SEL = I_SEL; 
        request.I_INFO = I_INFO; 
        request.I_COS = I_COS; 
        request.I_OPTM = I_OPTM; 
        request.I_CST_PRP = I_CST_PRP; 

        request.T_INSPEC = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_INSPEC>{T_INSPEC};  
        request.T_DEL = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_DEL>{T_DEL};  
        request.T_TMP = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP>{T_TMP};  
        request.T_MOTION = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_MOTION>{T_MOTION};  
        request.T_CODE_INFO = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_CODE_INFO>{T_CODE_INFO};          


        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_O_RETURN  O_RETURN = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_MOTION  T_MOTION_RES = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_MOTION();
        T_MOTION_RES.AUFNR = '';
        T_MOTION_RES.RUECK = '';
        T_MOTION_RES.WORKNO = '';
        T_MOTION_RES.SEQNO = '';
        T_MOTION_RES.PERNR = '';
        T_MOTION_RES.SVCMAN_NAME = '';
        T_MOTION_RES.ISDD = '';
        T_MOTION_RES.ISDZ = '';
        T_MOTION_RES.AUSBS = '';
        T_MOTION_RES.AUZTB = '';
        T_MOTION_RES.ISMNW = '';
        T_MOTION_RES.ISMNW_PDK = '';
        T_MOTION_RES.HOL_CHK = '';
        T_MOTION_RES.OT_CHK = '';
        T_MOTION_RES.LTXA1 = '';
        T_MOTION_RES.RMZHL = '';
        T_MOTION_RES.ISMNE = '';
        T_MOTION_RES.ZFLAG = '';
        T_MOTION_RES.TEMPHR = '';
        T_MOTION_RES.CHK_FLAG = '';
        T_MOTION_RES.MAINHR = '';
        T_MOTION_RES.OPTNHR1 = '';
        T_MOTION_RES.OPTNHR2 = '';
        T_MOTION_RES.OPTNHR3 = '';
        T_MOTION_RES.OPTNHR4 = '';
        T_MOTION_RES.OPTNHR5 = '';
        T_MOTION_RES.HDAYWDV = '';
        T_MOTION_RES.OPTCHK1 = '';
        T_MOTION_RES.OPTCHK2 = '';
        T_MOTION_RES.OPTCHK3 = '';
        T_MOTION_RES.OPTCHK4 = '';
        T_MOTION_RES.OPTCHK5 = '';
        T_MOTION_RES.ETC_HR = '';
        T_MOTION_RES.ETC_TXT = '';
        T_MOTION_RES.ERDAT = '';
        T_MOTION_RES.ERNAM = '';
        T_MOTION_RES.ERZET = '';
        T_MOTION_RES.AEDAT = '';
        T_MOTION_RES.AENAM = '';
        T_MOTION_RES.AEZET = '';
        T_MOTION_RES.WERKS = '';
        T_MOTION_RES.CONF = '';
        T_MOTION_RES.GRUND = '';
        T_MOTION_RES.WORKCD = '';
        T_MOTION_RES.EXRSN = '';

        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_DEL     T_DEL_RES = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_DEL();
        T_DEL_RES.DOCNO = '';
        T_DEL_RES.FILENAME = '';        
        
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_TMP     T_TMP_RES = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_TMP();
        T_TMP_RES.FILENAME = '';
        T_TMP_RES.IF_DESC = '';
        T_TMP_RES.EVISEQX = '';
        T_TMP_RES.LINE = '';
        T_TMP_RES.FILE_SIZE = '';
                
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_RETURN  T_RETURN = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_RETURN();
        T_RETURN.TYPE = '';
        T_RETURN.CODE = '';
        T_RETURN.MESSAGE = '';        


        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res response = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res();
        response.O_DEL_MSG = ''; 
        response.O_UPD_MSG = ''; 
        response.O_TIME    = ''; 
        response.O_RETURN  = O_RETURN; 
        response.T_MOTION  = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_MOTION>{T_MOTION_RES}; 
        response.T_DEL     = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_DEL>{T_DEL_RES}; 
        response.T_TMP     = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_TMP>{T_TMP_RES}; 
        response.T_RETURN  = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res_T_RETURN>{T_RETURN}; 



        
        method.IF_SERVICE_045(request);
        Test.stopTest(); 
    }    
}