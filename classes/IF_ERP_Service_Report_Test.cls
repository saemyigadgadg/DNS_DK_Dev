@IsTest
public with sharing class IF_ERP_Service_Report_Test {
    private static String className = 'IF_ERP_Service_Report';

    public IF_ERP_Service_Report_Test() {}

/* Mock Classes
    */
    public class IF_SERVICE_011_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_011_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished."},"T_LIST":[{"CODE":"0001","KEY1":"PERSON","TEXT01":"Person"},{"CODE":"0002","KEY1":"R & D","TEXT01":"R & D"},{"CODE":"0004","KEY1":"MACHINE","TEXT01":"Machine"},{"CODE":"0006","KEY1":"DOM VENDOR","TEXT01":"Domestic Vendor"},{"CODE":"0007","KEY1":"OVS VENDOR","TEXT01":"Overseas Vendor"},{"CODE":"0010","KEY1":"SALSE","TEXT01":"Salse"},{"CODE":"0011","KEY1":"PD MANGNT","TEXT01":"Production management"},{"CODE":"0012","KEY1":"SERVICE","TEXT01":"Service"},{"CODE":"0013","KEY1":"CUSTOMER","TEXT01":"Customer"},{"CODE":"0014","KEY1":"OEM","TEXT01":"OEM"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_SERVICE_049_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_049_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_AUFNR_F":"000403908070","O_DEL_MSG":"","O_INFO":{"NAME":"","INBDT":"0000-00-00","WTY_TYPE":"","RBNR":"","GWLDT_O":"0000-00-00","GWLEN_O":"0000-00-00","CODING":"","CODE_TEXT":"","NOTIF_NO":"","ATTACHMENT_CODE":"","ATTACHMENT":"","WORK_AREA_CODE":"","WORK_AREA":"","WORK_TYPE_CODE":"","WORK_TYPE":"","MAINTROOM_CODE":"","MAINTROOM":"","NOTIF_DATE":"0000-00-00","NOTIFTIME":"00:00:00","REQUIRE_DAT":"0000-00-00","STRMLFNDATE":"0000-00-00","STRMLFNTIME":"00:00:00","DESENDDATE":"0000-00-00","DESENDTM":"00:00:00","STAND_WE":"","PHENOMENA":"","DL_CODEGRP":"","DL_CODE":"","STXT_GRPCD":"","D_CODEGRP":"","D_CODE":"","TXT_PROBCD":"","DESCRIPT":"","REPORTEDBY":"","EQUNR":"","ILART":"","ZZ_EX_TERM_TYP":"","ZZ_EX_TERM_TYP_TXT":"","ZZ_EX_TERM_TYP_B":"","ZZ_EX_TERM_TYP_B_TXT":"","ZZ_EX_END_DT":"0000-00-00","MGANR_OUT":"","MGANR_OUT_TXT40":"","ZZ_CS_PWRNT_HR":"0","ZZ_CS_PWRNT_MM":"0","ZZ_EX_TERM_VL":"0","ZZ_EX_OPH":"0"},"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Confirmation OK!"},"O_UPD_MSG":""}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_SERVICE_050_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_050_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_RETURN":[{"CODE":"","MESSAGE":"Contact info update ok ![ZCS02025]","TYPE":"S"},{"CODE":"IW085","MESSAGE":"Noti update ok[ZCS02030]","TYPE":"S"},{"CODE":"","MESSAGE":"Noti insert(CBO) ok[ZCS02032]","TYPE":"S"},{"CODE":"","MESSAGE":"Settlement Rule Entry OK ![ZCS02158]","TYPE":"S"},{"CODE":"RU100","MESSAGE":"0137297437(Confirm No)","TYPE":"S"},{"CODE":"","MESSAGE":"Confm No(CBO) insert ok[ZCS02034]","TYPE":"S"}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Contact info update ok ![ZCS02025]"},"O_ACTIVE":"","O_DEL_MSG":"","O_UPD_MSG":""}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_SERVICE_052_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_052_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Order confirmation canceled successfully"}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    public class IF_SERVICE_054_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_054_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_AMOUNT":{"TOTAL":"0.00","VAT":"0.00","WAERS":""},"O_AUFNR":"403907829","O_BILL_CATEGORY":"","O_BYRJD":"","O_BYRJM":"","O_BYRJT":"","O_CITY1":"","O_CODE":{"CODE_01":"","CODE_02":"","CODE_03":"","TEXT":"","TEXT2":""},"O_EQART":"","O_HISTORY":{"MANDT":"","QMNUM":"","SEQNO":"","OTGRP":"","OTEIL":"","KURZTEXT":"","FEGRP":"","FECOD":"","TXTCDFE":"","FETXT":"","SYMPTOM_ADD_TXT":"","URGRP":"","URCOD":"","TXTCDUR":"","URTXT":"","CAUSE_ADD_TXT":"","MNGRP":"","MNCOD":"","TXTCDMA":"","MATXT":"","ACT_ADD_TXT":"","FAULT_CAUSE":"","PHENO_ADD_TXT":"","BLCOD":"","BLCOD_T":"","ERDAT":"0000-00-00","ERNAM":"","ERZET":"00:00:00","AEDAT":"0000-00-00","AENAM":"","AEZET":"00:00:00","TXTQM":""},"O_HUMAN_VAL":"","O_ILART":"104","O_INFO":{"MANDT":"","AUFNR":"","AUART":"CS01","ORDER_TYPE_TXT":"Inspection Order","QMNUM":"","ILART":"104","DMACTTYPE_TXT":"Installation & Test-run","QMDAT":"0000-00-00","GSTRP":"2025-01-21","LTRMN":"0000-00-00","QMTXT":"","TXTQM":"","EQUNR":"","MATNR":"GT3100-F0TP-0-K30","TYPBZ":"PUMA GT3100","SERNR":"ML0311-000789","INBDT":"0000-00-00","RBNR":"","IDATE":"0000-00-00","STAND_WE":"","MDOCM":"","KUNNR":"","NAME":"","TELEPHONE":"","REP_NAME":"","TAX_NO_2":"","ABCKZ":"","BEBER":"","CONTACT_TYPE":"","CONTACT_NAME":"","CONTACT_MOBILE":"","CONTACT_TEL":"","PART_PRICE":"0.00","LABOR_PRICE":"0.00","TOT_AMOUNT":"0.00","DISCOUNT_AMT":"0.00","WAERS":"KRW","VBELN":"","ERDAT":"0000-00-00","ERNAM":"","ERZET":"00:00:00","AEDAT":"0000-00-00","AENAM":"","AEZET":"00:00:00","ARBPL":"","WTY_TYPE":"In","NOTIFTIME":"00:00:00","MOBILE":"","LTRUR":"00:00:00","ISMNW":"0.000","ZDIST":"0.000","OTHER_COST":"0.00","ZENGNO":"","USNAM":"","UDATE":"0000-00-00","UTIME":"00:00:00"},"O_LOEKZ":"","O_MANHOUR_REASON":"","O_MANHOUR_USE_YN":"","O_MANHOUR_VAL":"","O_NOT_DELIVERY":"","O_REF_NO":"","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""},"O_RJXO":"","O_SERIES_NAME":"","O_STATUS":"REL","O_STREET":"","O_TEXT":"","O_TEXT_RJ":"","O_UNIT_NAME":"","O_UNIT_SUB_DESC":"","O_UNIT_SUB_NAME":"","O_USR11":"","O_WORK_ITEM_NAME":"","T_CONSIGN":[],"T_DATA":[],"T_DOC":[],"T_DOC_INFO":[],"T_DOC_SR":[],"T_MATERIAL":[],"T_MOTION":[{"AENAM":"","ISDZ":"00:00:00","ISMNE":"","FLAG_0060":"X","LTXA1":"","SEQNO":"0001","ISMNW_PDK":"0.0","SVCMAN_NAME":"MKRC0067 정경연","ERZET":"13:24:17","AUFNR":"403907829","AEDAT":"0000-00-00","WORKCD":"","AUSBS":"2025-03-12","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-03-12","EXRSN":"","RUECK":"0137294904","MANDT":"","ISMNW":"0.0","ERDAT":"2025-03-12","RMZHL":"00000000","AUZTB":"00:00:00","PERNR":"00006068","AEZET":"00:00:00","WORKNO":"0000"}],"T_SUB":[],"T_TEXT_A":[{"TDLINE":"딜러포탈테스트20250131001-조치:수정","TDFORMAT":"*"}],"T_TEXT_C":[{"TDLINE":"테스트-고장원인내용입력 12","TDFORMAT":"*"}],"T_TEXT_CR":[],"T_TEXT_D":[{"TDLINE":"테스트-고장현상내용입력 12","TDFORMAT":"*"}],"T_ZCST0061":[],"T_ZCST0062":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @IsTest
    static void IF_SERVICE_011_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-011', className);
        Test.startTest();
        IF_ERP_Service_Report method = new IF_ERP_Service_Report();
        IF_ERP_Service_Report_Classes.IF_SERVICE_011_Req request  = new IF_ERP_Service_Report_Classes.IF_SERVICE_011_Req();
        request.I_UNAME   = '';
        request.I_KATALOG = '';
        request.I_LANGU   = '';        
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res_O_RETURN O_RETURN = new IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        

        IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res_T_LIST   T_LIST = new IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res_T_LIST();
        T_LIST.CODE = '';
        T_LIST.KEY1 = '';
        T_LIST.TEXT01 = '';
        

        IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res response = new IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res();
        response.O_RETURN = O_RETURN; 
        response.T_LIST = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res_T_LIST>{T_LIST};         

        method.IF_SERVICE_011(request);
        Test.stopTest(); 
    }
    
    @IsTest
    static void IF_SERVICE_049_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-049', className);
        Test.startTest();
        IF_ERP_Service_Report method = new IF_ERP_Service_Report();


        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INFO       I_INFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INFO();
        I_INFO.NAME = '';
        I_INFO.INBDT = '';
        I_INFO.WTY_TYPE = '';
        I_INFO.RBNR = '';
        I_INFO.GWLDT_O = '';
        I_INFO.GWLEN_O = '';
        I_INFO.CODING = '';
        I_INFO.CODE_TEXT = '';
        I_INFO.NOTIF_NO = '';
        I_INFO.ATTACHMENT_CODE = '';
        I_INFO.ATTACHMENT = '';
        I_INFO.WORK_AREA_CODE = '';
        I_INFO.WORK_AREA = '';
        I_INFO.WORK_TYPE_CODE = '';
        I_INFO.WORK_TYPE = '';
        I_INFO.MAINTROOM = '';
        I_INFO.NOTIF_DATE = '';
        I_INFO.NOTIFTIME = '';
        I_INFO.REQUIRE_DAT = '';
        I_INFO.STRMLFNDATE = '';
        I_INFO.STRMLFNTIME = '';
        I_INFO.DESENDDATE = '';
        I_INFO.DESENDTM = '';
        I_INFO.STAND_WE = '';
        I_INFO.PHENOMENA = '';
        I_INFO.DL_CODEGRP = '';
        I_INFO.DL_CODE = '';
        I_INFO.STXT_GRPCD = '';
        I_INFO.D_CODEGRP = '';
        I_INFO.D_CODE = '';
        I_INFO.TXT_PROBCD = '';
        I_INFO.DESCRIPT = '';
        I_INFO.REPORTEDBY = '';
        I_INFO.EQUNR = '';
        I_INFO.ILART = '';
        I_INFO.ZZ_EX_TERM_TYP = '';
        I_INFO.ZZ_EX_TERM_TYP_TXT = '';
        I_INFO.ZZ_EX_TERM_TYP_B = '';
        I_INFO.ZZ_EX_TERM_TYP_B_TXT = '';
        I_INFO.ZZ_EX_END_DT = '';        

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INPUT      I_INPUT = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INPUT();
        I_INPUT.EQUNR = '';
        I_INPUT.WTY_TYPE = '';
        I_INPUT.CODING = '';
        I_INPUT.ATTACHMENT = '';
        I_INPUT.WORK_AREA = '';
        I_INPUT.WORK_TYPE = '';
        I_INPUT.MAINTROOM = '';
        I_INPUT.NOTIF_DATE = '';
        I_INPUT.NOTIFTIME = '';
        I_INPUT.REQUIRE_DAT = '';
        I_INPUT.STRMLFNDATE = '';
        I_INPUT.STRMLFNTIME = '';
        I_INPUT.DESENDDATE = '';
        I_INPUT.DESSTTIME = '';
        I_INPUT.STAND_WE = '';
        I_INPUT.PHENOMENA = '';
        I_INPUT.PHENOMENA_ADD_TXT = '';
        I_INPUT.DL_CODEGRP = '';
        I_INPUT.DL_CODE = '';
        I_INPUT.D_CODEGRP = '';
        I_INPUT.D_CODE = '';
        I_INPUT.DESCRIPT = '';
        I_INPUT.SYMPTOM_ADD_TXT = '';
        I_INPUT.REPORTEDBY = '';
        I_INPUT.QMNUM = '';
        I_INPUT.ILART = '';
        I_INPUT.CLAIM_NO = '';
        I_INPUT.POWERTRAIN = '';
        I_INPUT.SHIP_TO = '';
        I_INPUT.TXTQM = '';
        I_INPUT.REF_NO = '';        
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INFOR      I_INFOR = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INFOR();
        I_INFOR.MANDT = '';
        I_INFOR.AUFNR = '';
        I_INFOR.AUART = '';
        I_INFOR.ORDER_TYPE_TXT = '';
        I_INFOR.QMNUM = '';
        I_INFOR.ILART = '';
        I_INFOR.DMACTTYPE_TXT = '';
        I_INFOR.QMDAT = '';
        I_INFOR.GSTRP = '';
        I_INFOR.LTRMN = '';
        I_INFOR.QMTXT = '';
        I_INFOR.TXTQM = '';
        I_INFOR.EQUNR = '';
        I_INFOR.MATNR = '';
        I_INFOR.TYPBZ = '';
        I_INFOR.SERNR = '';
        I_INFOR.INBDT = '';
        I_INFOR.RBNR = '';
        I_INFOR.IDATE = '';
        I_INFOR.STAND_WE = '';
        I_INFOR.MDOCM = '';
        I_INFOR.KUNNR = '';
        I_INFOR.NAME = '';
        I_INFOR.TELEPHONE = '';
        I_INFOR.REP_NAME = '';
        I_INFOR.TAX_NO_2 = '';
        I_INFOR.ABCKZ = '';
        I_INFOR.BEBER = '';
        I_INFOR.CONTACT_TYPE = '';
        I_INFOR.CONTACT_NAME = '';
        I_INFOR.CONTACT_MOBILE = '';
        I_INFOR.CONTACT_TEL = '';
        I_INFOR.PART_PRICE = '';
        I_INFOR.LABOR_PRICE = '';
        I_INFOR.TOT_AMOUNT = '';
        I_INFOR.DISCOUNT_AMT = '';
        I_INFOR.WAERS = '';
        I_INFOR.VBELN = '';
        I_INFOR.ERDAT = '';
        I_INFOR.ERNAM = '';
        I_INFOR.ERZET = '';
        I_INFOR.AEDAT = '';
        I_INFOR.AENAM = '';
        I_INFOR.AEZET = '';
        I_INFOR.ARBPL = '';
        I_INFOR.WTY_TYPE = '';
        I_INFOR.NOTIFTIME = '';
        I_INFOR.MOBILE = '';
        I_INFOR.LTRUR = '';
        I_INFOR.ISMNW = '';
        I_INFOR.ZDIST = '';
        I_INFOR.OTHER_COST = '';
        I_INFOR.ZENGNO = '';
        I_INFOR.USNAM = '';
        I_INFOR.UDATE = '';
        I_INFOR.UTIME = '';        
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_HISTORY    I_HISTORY = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_HISTORY();
        I_HISTORY.MANDT = '';
        I_HISTORY.QMNUM = '';
        I_HISTORY.SEQNO = '';
        I_HISTORY.OTGRP = '';
        I_HISTORY.OTEIL = '';
        I_HISTORY.KURZTEXT = '';
        I_HISTORY.FEGRP = '';
        I_HISTORY.FECOD = '';
        I_HISTORY.TXTCDFE = '';
        I_HISTORY.FETXT = '';
        I_HISTORY.SYMPTOM_ADD_TXT = '';
        I_HISTORY.URGRP = '';
        I_HISTORY.URCOD = '';
        I_HISTORY.TXTCDUR = '';
        I_HISTORY.URTXT = '';
        I_HISTORY.CAUSE_ADD_TXT = '';
        I_HISTORY.MNGRP = '';
        I_HISTORY.MNCOD = '';
        I_HISTORY.TXTCDMA = '';
        I_HISTORY.MATXT = '';
        I_HISTORY.ACT_ADD_TXT = '';
        I_HISTORY.FAULT_CAUSE = '';
        I_HISTORY.PHENO_ADD_TXT = '';
        I_HISTORY.BLCOD = '';
        I_HISTORY.BLCOD_T = '';
        I_HISTORY.ERDAT = '';
        I_HISTORY.ERNAM = '';
        I_HISTORY.ERZET = '';
        I_HISTORY.AEDAT = '';
        I_HISTORY.AENAM = '';
        I_HISTORY.AEZET = '';
        I_HISTORY.TXTQM = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_CODE I_CODE = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_CODE();        
        I_CODE.CODE_01 = '';
        I_CODE.CODE_02 = '';
        I_CODE.CODE_03 = '';
        I_CODE.TEXT = '';
        I_CODE.TEXT2 = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_USERINFO I_USERINFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_USERINFO();        
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


        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_MOTION   T_MOTION = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_MOTION(); 
        T_MOTION.MANDT = '';
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
        T_MOTION.ERDAT = '';
        T_MOTION.ERNAM = '';
        T_MOTION.ERZET = '';
        T_MOTION.AEDAT = '';
        T_MOTION.AENAM = '';
        T_MOTION.AEZET = '';
        T_MOTION.FLAG_0060 = '';
        T_MOTION.WORKCD = '';
        T_MOTION.EXRSN = '';        


        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_ITEM     T_ITEM = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_ITEM(); 
        T_ITEM.MATNR = '';
        T_ITEM.CAUSE = '';
        T_ITEM.MENGE = '';
        T_ITEM.MEINS = '';
        T_ITEM.LIFNR = '';
        T_ITEM.ZSUPPLY = '';
        T_ITEM.VSBED = '';
        T_ITEM.KUNNR = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_DEL      T_DEL = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_DEL(); 
        T_DEL.DOCNO = '';
        T_DEL.FILENAME = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP      T_TMP = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP();         
        T_TMP.FILENAME = '';
        T_TMP.IF_DESC = '';
        T_TMP.EVISEQX = '';
        T_TMP.LINE = '';
        T_TMP.FILE_SIZE = '';        

        
        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req request  = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req();
        request.I_PHENOMENA  = '';
        request.I_DESCRIPT  = '';
        request.I_CAUSE  = '';
        request.I_ACTIVITY  = '';
        request.I_FLAG  = '';
        request.I_TYPBZ  = '';
        request.I_SERNR  = '';
        request.I_EQUNR  = '';      
        request.I_INFO = I_INFO ;
        request.I_INPUT = I_INPUT; 
        request.I_INFOR = I_INFOR ;
        request.I_HISTORY = I_HISTORY; 
        request.I_CODE = I_CODE ;
        request.I_USERINFO = I_USERINFO; 
        request.T_MOTION = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_MOTION>{T_MOTION}; 
        request.T_ITEM = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_ITEM>{T_ITEM}; 
        request.T_DEL = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_DEL>{T_DEL}; 
        request.T_TMP = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP>{T_TMP};         


        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res_O_RETURN O_RETURN = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res_O_INFO O_INFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res_O_INFO();
        O_INFO.NAME = '';
        O_INFO.INBDT = '';
        O_INFO.WTY_TYPE = '';
        O_INFO.RBNR = '';
        O_INFO.GWLDT_O = '';
        O_INFO.GWLEN_O = '';
        O_INFO.CODING = '';
        O_INFO.CODE_TEXT = '';
        O_INFO.NOTIF_NO = '';
        O_INFO.ATTACHMENT_CODE = '';
        O_INFO.ATTACHMENT = '';
        O_INFO.WORK_AREA_CODE = '';
        O_INFO.WORK_AREA = '';
        O_INFO.WORK_TYPE_CODE = '';
        O_INFO.WORK_TYPE = '';
        O_INFO.MAINTROOM_CODE = '';
        O_INFO.MAINTROOM = '';
        O_INFO.NOTIF_DATE = '';
        O_INFO.NOTIFTIME = '';
        O_INFO.REQUIRE_DAT = '';
        O_INFO.STRMLFNDATE = '';
        O_INFO.STRMLFNTIME = '';
        O_INFO.DESENDDATE = '';
        O_INFO.DESENDTM = '';
        O_INFO.STAND_WE = '';
        O_INFO.PHENOMENA = '';
        O_INFO.DL_CODEGRP = '';
        O_INFO.DL_CODE = '';
        O_INFO.STXT_GRPCD = '';
        O_INFO.D_CODEGRP = '';
        O_INFO.D_CODE = '';
        O_INFO.TXT_PROBCD = '';
        O_INFO.DESCRIPT = '';
        O_INFO.REPORTEDBY = '';
        O_INFO.EQUNR = '';
        O_INFO.ILART = '';
        O_INFO.ZZ_EX_TERM_TYP = '';
        O_INFO.ZZ_EX_TERM_TYP_TXT = '';
        O_INFO.ZZ_EX_TERM_TYP_B = '';
        O_INFO.ZZ_EX_TERM_TYP_B_TXT = '';
        O_INFO.ZZ_EX_END_DT = '';
        O_INFO.MGANR_OUT = '';
        O_INFO.MGANR_OUT_TXT40 = '';
        O_INFO.ZZ_CS_PWRNT_HR = '';
        O_INFO.ZZ_CS_PWRNT_MM = '';
        O_INFO.ZZ_EX_TERM_VL = '';
        O_INFO.ZZ_EX_OPH = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res response = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res();
        response.O_DEL_MSG = '';
        response.O_UPD_MSG = '';
        response.O_AUFNR_F = '';
        response.O_QMNUM_F = '';
        response.O_RETURN  = O_RETURN;
        response.O_INFO    = O_INFO;
        
        
        
        
        method.IF_SERVICE_049(request);
        Test.stopTest(); 
    }

    @IsTest
    static void IF_SERVICE_050_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-050', className);
        Test.startTest();
        IF_ERP_Service_Report method = new IF_ERP_Service_Report();

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_INFO I_INFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_INFO();
        // I_INFO.MANDT = '';
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

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_HISTORY I_HISTORY = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_HISTORY();
        // I_HISTORY.MANDT = '';
        I_HISTORY.QMNUM = '';
        I_HISTORY.SEQNO = '';
        I_HISTORY.OTGRP = '';
        I_HISTORY.OTEIL = '';
        I_HISTORY.KURZTEXT = '';
        I_HISTORY.FEGRP = '';
        I_HISTORY.FECOD = '';
        I_HISTORY.TXTCDFE = '';
        I_HISTORY.FETXT = '';
        I_HISTORY.SYMPTOM_ADD_TXT = '';
        I_HISTORY.URGRP = '';
        I_HISTORY.URCOD = '';
        I_HISTORY.TXTCDUR = '';
        I_HISTORY.URTXT = '';
        I_HISTORY.CAUSE_ADD_TXT = '';
        I_HISTORY.MNGRP = '';
        I_HISTORY.MNCOD = '';
        I_HISTORY.TXTCDMA = '';
        I_HISTORY.MATXT = '';
        I_HISTORY.ACT_ADD_TXT = '';
        I_HISTORY.FAULT_CAUSE = '';
        I_HISTORY.PHENO_ADD_TXT = '';
        I_HISTORY.BLCOD = '';
        I_HISTORY.BLCOD_T = '';
        I_HISTORY.ERDAT = '';
        I_HISTORY.ERNAM = '';
        I_HISTORY.ERZET = '';
        I_HISTORY.AEDAT = '';
        I_HISTORY.AENAM = '';
        I_HISTORY.AEZET = '';
        I_HISTORY.TXTQM = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_CODE I_CODE = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_CODE();
        I_CODE.CODE_01 = '';
        I_CODE.CODE_02 = '';
        I_CODE.CODE_03 = '';
        I_CODE.TEXT = '';
        I_CODE.TEXT2 = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_SUB I_SUB = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_SUB();
        I_SUB.KEY = '';
        I_SUB.VALUE = '';


        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MOTION T_MOTION = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MOTION();
        T_MOTION.MANDT = '';
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
        T_MOTION.ERDAT = '';
        T_MOTION.ERNAM = '';
        T_MOTION.ERZET = '';
        T_MOTION.AEDAT = '';
        T_MOTION.AENAM = '';
        T_MOTION.AEZET = '';
        T_MOTION.FLAG_0060 = '';
        T_MOTION.WORKCD = '';
        T_MOTION.EXRSN = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MATERIAL T_MATERIAL  = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MATERIAL();
        T_MATERIAL.MANDT = '';
        T_MATERIAL.AUFNR = '';
        T_MATERIAL.WORKNO = '';
        T_MATERIAL.SEQNO = '';
        T_MATERIAL.MATNR = '';
        T_MATERIAL.MEINS = '';
        T_MATERIAL.SUPPLY_TYPE = '';
        T_MATERIAL.CHANGE_DT = '';
        T_MATERIAL.EBELN = '';
        T_MATERIAL.EBELP = '';
        T_MATERIAL.MBLNR = '';
        T_MATERIAL.GI_MBLNR = '';
        T_MATERIAL.LIFNR = '';
        T_MATERIAL.NAME1 = '';
        T_MATERIAL.NETWR = '';
        T_MATERIAL.BRTWR = '';
        T_MATERIAL.FREIGHT = '';
        T_MATERIAL.WAERS = '';
        T_MATERIAL.BELNR = '';
        T_MATERIAL.RETURN_YN = '';
        T_MATERIAL.ERDAT = '';
        T_MATERIAL.ERNAM = '';
        T_MATERIAL.ERZET = '';
        T_MATERIAL.AEDAT = '';
        T_MATERIAL.AENAM = '';
        T_MATERIAL.AEZET = '';
        T_MATERIAL.ITEM_CAT = '';
        T_MATERIAL.RETURN_TYPE = '';
        T_MATERIAL.RETURN_TEXT = '';
        T_MATERIAL.PGMNG = '';
        T_MATERIAL.READ_ONLY = '';
        T_MATERIAL.MENGE = '';
        T_MATERIAL.MENGE_GI = '';
        T_MATERIAL.READ_ONLY_02 = '';
        T_MATERIAL.READ_ONLY_03 = '';
        T_MATERIAL.MAKTX = '';
        T_MATERIAL.CAUSE_PRT = '';
        T_MATERIAL.READ_ONLY_04 = '';
        T_MATERIAL.ITEM_NUMBER = '';
        T_MATERIAL.NETWR_VISIBLE = '';
        T_MATERIAL.QDATU = '';
        T_MATERIAL.QZEIT = '';
        T_MATERIAL.RTYPE_ENABLE = '';
        T_MATERIAL.GR = '';
        T_MATERIAL.REASON1 = '';
        T_MATERIAL.REASON2 = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req request  = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req();
        request.I_UNAME = '';
        request.I_DESCRIPT = '';
        request.I_CAUSE = '';
        request.I_ACTIVITY = '';
        request.I_CR = '';
        request.I_MANHOUR_REASON = '';
        request.I_EXRSN = '';
        request.I_INFO = I_INFO;
        request.I_HISTORY = I_HISTORY;
        request.I_CODE = I_CODE;
        request.I_SUB = I_SUB;        
        request.T_MOTION = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MOTION>{T_MOTION} ;
        request.T_MATERIAL = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MATERIAL>{T_MATERIAL} ;        

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res_T_RETURN T_RETURN = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res_T_RETURN();
        T_RETURN.TYPE = '';
        T_RETURN.CODE = '';
        T_RETURN.MESSAGE = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res_O_RETURN O_RETURN = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res response = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res();
        // response.O_ACTIVE = '';
        response.O_DEL_MSG = '';
        response.O_UPD_MSG = ''; 
        response.O_RETURN = O_RETURN;
        response.T_RETURN = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res_T_RETURN>{T_RETURN};
        method.IF_SERVICE_050(request);
        Test.stopTest(); 
    }

    @IsTest
    static void IF_SERVICE_052_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-052', className);
        Test.startTest();
        IF_ERP_Service_Report method = new IF_ERP_Service_Report();
        IF_ERP_Service_Report_Classes.IF_SERVICE_052_Req request  = new IF_ERP_Service_Report_Classes.IF_SERVICE_052_Req();
        request.I_AUFNR = '';

        IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res_O_RETURN O_RETURN = new IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res response = new IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res();
        response.O_RETURN = O_RETURN;
        method.IF_SERVICE_052(request);
        Test.stopTest(); 
    }

    @IsTest
    static void IF_SERVICE_054_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-054', className);
        Test.startTest();
        IF_ERP_Service_Report method = new IF_ERP_Service_Report();

        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_ORDER I_ORDER = 
        new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_ORDER();
        I_ORDER.AUFNR = '';
        I_ORDER.KTEXT = '';


        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_USERINFO I_USERINFO = 
        new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_USERINFO();
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

        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req request  = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req();
        request.I_CHECK = '';
        request.I_REF_NO = '';
        request.I_READ = '';
        request.I_ORDER = I_ORDER;
        request.I_USERINFO = I_USERINFO;
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_AMOUNT O_AMOUNT = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_AMOUNT(); 
        O_AMOUNT.TOTAL = '';
        O_AMOUNT.VAT = '';
        O_AMOUNT.WAERS = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_INFO O_INFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_INFO(); 
        O_INFO.MANDT = '';
        O_INFO.AUFNR = '';
        O_INFO.AUART = '';
        O_INFO.ORDER_TYPE_TXT = '';
        O_INFO.QMNUM = '';
        O_INFO.ILART = '';
        O_INFO.DMACTTYPE_TXT = '';
        O_INFO.QMDAT = '';
        O_INFO.GSTRP = '';
        O_INFO.LTRMN = '';
        O_INFO.QMTXT = '';
        O_INFO.TXTQM = '';
        O_INFO.EQUNR = '';
        O_INFO.MATNR = '';
        O_INFO.TYPBZ = '';
        O_INFO.SERNR = '';
        O_INFO.INBDT = '';
        O_INFO.RBNR = '';
        O_INFO.IDATE = '';
        O_INFO.STAND_WE = '';
        O_INFO.MDOCM = '';
        O_INFO.KUNNR = '';
        O_INFO.NAME = '';
        O_INFO.TELEPHONE = '';
        O_INFO.REP_NAME = '';
        O_INFO.TAX_NO_2 = '';
        O_INFO.ABCKZ = '';
        O_INFO.BEBER = '';
        O_INFO.CONTACT_TYPE = '';
        O_INFO.CONTACT_NAME = '';
        O_INFO.CONTACT_MOBILE = '';
        O_INFO.CONTACT_TEL = '';
        O_INFO.PART_PRICE = '';
        O_INFO.LABOR_PRICE = '';
        O_INFO.TOT_AMOUNT = '';
        O_INFO.DISCOUNT_AMT = '';
        O_INFO.WAERS = '';
        O_INFO.VBELN = '';
        O_INFO.ERDAT = '';
        O_INFO.ERNAM = '';
        O_INFO.ERZET = '';
        O_INFO.AEDAT = '';
        O_INFO.AENAM = '';
        O_INFO.AEZET = '';
        O_INFO.ARBPL = '';
        O_INFO.WTY_TYPE = '';
        O_INFO.NOTIFTIME = '';
        O_INFO.MOBILE = '';
        O_INFO.LTRUR = '';
        O_INFO.ISMNW = '';
        O_INFO.ZDIST = '';
        O_INFO.OTHER_COST = '';
        O_INFO.ZENGNO = '';
        O_INFO.USNAM = '';
        O_INFO.UDATE = '';
        O_INFO.UTIME = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_CODE O_CODE = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_CODE(); 
        O_CODE.CODE_01 = '';
        O_CODE.CODE_02 = '';
        O_CODE.CODE_03 = '';
        O_CODE.TEXT = '';
        O_CODE.TEXT2 = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_HISTORY O_HISTORY = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_HISTORY(); 
        O_HISTORY.MANDT = '';
        O_HISTORY.QMNUM = '';
        O_HISTORY.SEQNO = '';
        O_HISTORY.OTGRP = '';
        O_HISTORY.OTEIL = '';
        O_HISTORY.KURZTEXT = '';
        O_HISTORY.FEGRP = '';
        O_HISTORY.FECOD = '';
        O_HISTORY.TXTCDFE = '';
        O_HISTORY.FETXT = '';
        O_HISTORY.SYMPTOM_ADD_TXT = '';
        O_HISTORY.URGRP = '';
        O_HISTORY.URCOD = '';
        O_HISTORY.TXTCDUR = '';
        O_HISTORY.URTXT = '';
        O_HISTORY.CAUSE_ADD_TXT = '';
        O_HISTORY.MNGRP = '';
        O_HISTORY.MNCOD = '';
        O_HISTORY.TXTCDMA = '';
        O_HISTORY.MATXT = '';
        O_HISTORY.ACT_ADD_TXT = '';
        O_HISTORY.FAULT_CAUSE = '';
        O_HISTORY.PHENO_ADD_TXT = '';
        O_HISTORY.BLCOD = '';
        O_HISTORY.BLCOD_T = '';
        O_HISTORY.INCLUDE = '';
        O_HISTORY.ERDAT = '';
        O_HISTORY.ERNAM = '';
        O_HISTORY.ERZET = '';
        O_HISTORY.AEDAT = '';
        O_HISTORY.AENAM = '';
        O_HISTORY.AEZET = '';
        O_HISTORY.TXTQM = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_RETURN O_RETURN = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_O_RETURN();         
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_MATERIAL T_MATERIAL = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_MATERIAL(); 
        T_MATERIAL.MANDT = '';
        T_MATERIAL.AUFNR = '';
        T_MATERIAL.WORKNO = '';
        T_MATERIAL.SEQNO = '';
        T_MATERIAL.MATNR = '';
        T_MATERIAL.MEINS = '';
        T_MATERIAL.SUPPLY_TYPE = '';
        T_MATERIAL.CHANGE_DT = '';
        T_MATERIAL.EBELN = '';
        T_MATERIAL.EBELP = '';
        T_MATERIAL.MBLNR = '';
        T_MATERIAL.GI_MBLNR = '';
        T_MATERIAL.LIFNR = '';
        T_MATERIAL.NAME1 = '';
        T_MATERIAL.NETWR = '';
        T_MATERIAL.BRTWR = '';
        T_MATERIAL.FREIGHT = '';
        T_MATERIAL.WAERS = '';
        T_MATERIAL.BELNR = '';
        T_MATERIAL.RETURN_YN = '';
        T_MATERIAL.ERDAT = '';
        T_MATERIAL.ERNAM = '';
        T_MATERIAL.ERZET = '';
        T_MATERIAL.AEDAT = '';
        T_MATERIAL.AENAM = '';
        T_MATERIAL.AEZET = '';
        T_MATERIAL.ITEM_CAT = '';
        T_MATERIAL.RETURN_TYPE = '';
        T_MATERIAL.RETURN_TEXT = '';
        T_MATERIAL.PGMNG = '';
        T_MATERIAL.READ_ONLY = '';
        T_MATERIAL.MENGE = '';
        T_MATERIAL.MENGE_GI = '';
        T_MATERIAL.READ_ONLY_02 = '';
        T_MATERIAL.READ_ONLY_03 = '';
        T_MATERIAL.MAKTX = '';
        T_MATERIAL.CAUSE_PRT = '';
        T_MATERIAL.READ_ONLY_04 = '';
        T_MATERIAL.ITEM_NUMBER = '';
        T_MATERIAL.NETWR_VISIBLE = '';
        T_MATERIAL.QDATU = '';
        T_MATERIAL.QZEIT = '';
        T_MATERIAL.RTYPE_ENABLE = '';
        T_MATERIAL.GR = '';
        T_MATERIAL.REASON1 = '';
        T_MATERIAL.REASON2 = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_MOTION T_MOTION = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_MOTION() ;
        T_MOTION.MANDT = '';
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
        T_MOTION.ERDAT = '';
        T_MOTION.ERNAM = '';
        T_MOTION.ERZET = '';
        T_MOTION.AEDAT = '';
        T_MOTION.AENAM = '';
        T_MOTION.AEZET = '';
        T_MOTION.FLAG_0060 = '';
        T_MOTION.WORKCD = '';
        T_MOTION.EXRSN = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC T_DOC = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC() ;
        T_DOC.FILENAME = '';
        T_DOC.MIMETYPE = '';
        T_DOC.FILEDATA = '';
        T_DOC.DESCRIPTION = '';
        T_DOC.FLAG = '';
        T_DOC.DOCNO = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_SUB T_SUB = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_SUB() ;
        T_SUB.KEY = '';
        T_SUB.VALUE = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DATA T_DATA = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DATA(); 
        T_DATA.FILENAME = '';
        T_DATA.EVISEQX = '';
        T_DATA.LINE = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_INFO T_DOC_INFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_INFO(); 
        T_DOC_INFO.AUFNR = '';
        T_DOC_INFO.SEQNO = '';
        T_DOC_INFO.DOCNO = '';
        T_DOC_INFO.FILENAME = '';
        T_DOC_INFO.FILESIZE = '';
        T_DOC_INFO.DESCRIPTION = '';
        T_DOC_INFO.DOC_ID = '';
        T_DOC_INFO.STOR_CAT = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_SR T_DOC_SR = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_SR() ;
        T_DOC_SR.AUFNR = '';
        T_DOC_SR.SEQNO = '';
        T_DOC_SR.DOCNO = '';
        T_DOC_SR.FILENAME = '';
        T_DOC_SR.FILESIZE = '';
        T_DOC_SR.DESCRIPTION = '';
        T_DOC_SR.DOC_ID = '';
        T_DOC_SR.STOR_CAT = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_D T_TEXT_D = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_D() ;
        T_TEXT_D.TDFORMAT = '';
        T_TEXT_D.TDLINE = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_C T_TEXT_C = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_C() ;
        T_TEXT_C.TDFORMAT = '';
        T_TEXT_C.TDLINE = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_A T_TEXT_A = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_A() ;
        T_TEXT_A.TDFORMAT = '';
        T_TEXT_A.TDLINE = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_CONSIGN T_CONSIGN = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_CONSIGN(); 
        T_CONSIGN.AUFNR = '';
        T_CONSIGN.QMNUM = '';
        T_CONSIGN.ZSEQN = '';
        T_CONSIGN.WERKS = '';
        T_CONSIGN.LIFNR = '';
        T_CONSIGN.NAME1 = '';
        T_CONSIGN.ZCOSTC = '';
        T_CONSIGN.ZCOSTC_T = '';
        T_CONSIGN.ZPORD = '';
        T_CONSIGN.ZPORD_T = '';
        T_CONSIGN.ZACTIVI = '';
        T_CONSIGN.ZACTIVI_T = '';
        T_CONSIGN.ZTRANF = '';
        T_CONSIGN.ZTRANF_T = '';
        T_CONSIGN.ZTRANT = '';
        T_CONSIGN.ZDISTA = '';
        T_CONSIGN.ZEXPEN = '';
        T_CONSIGN.WAERS = '';
        T_CONSIGN.REMARK = '';
        T_CONSIGN.CONFID = '';
        T_CONSIGN.CONFDT = '';
        T_CONSIGN.CONFTM = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_CR T_TEXT_CR = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_CR() ;
        T_TEXT_CR.TDFORMAT = '';
        T_TEXT_CR.TDLINE = ''; 
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_ZCST0061 T_ZCST0061 = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_ZCST0061(); 
        T_ZCST0061.AUFNR = '';
        T_ZCST0061.STDCD = '';
        T_ZCST0061.SERIES_NAME = '';
        T_ZCST0061.MODEL = '';
        T_ZCST0061.OBJPT = '';
        T_ZCST0061.STDWK = '';
        T_ZCST0061.MANHOUR_VAL = '';
        T_ZCST0061.HUMAN_VAL = '';
        T_ZCST0061.REGYN = '';        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_ZCST0062 T_ZCST0062 = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_ZCST0062() ;
        T_ZCST0062.AUFNR = '';
        T_ZCST0062.EXRSN = '';
        T_ZCST0062.STDYN = '';
        T_ZCST0062.SMTP_ADDR = '';
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res response = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res();
        response.O_EQART = '';
        response.O_ILART = '';
        response.O_NOT_DELIVERY = '';
        response.O_AUFNR = '';
        response.O_REF_NO = '';
        response.O_TEXT = '';
        response.O_TEXT_RJ = '';
        response.O_BYRJD = '';
        response.O_BYRJT = '';
        response.O_BYRJM = '';
        response.O_RJXO = '';
        response.O_USR11 = '';
        response.O_CITY1 = '';
        response.O_STREET = '';
        response.O_SERIES_NAME = '';
        response.O_UNIT_NAME = '';
        response.O_UNIT_SUB_NAME = '';
        response.O_UNIT_SUB_DESC = '';
        response.O_MANHOUR_VAL = '';
        response.O_HUMAN_VAL = '';
        response.O_BILL_CATEGORY = '';
        response.O_MANHOUR_USE_YN = '';
        response.O_MANHOUR_REASON = '';
        response.O_WORK_ITEM_NAME = '';
        response.O_LOEKZ = '';
        response.O_STATUS = '';
        response.O_AMOUNT = O_AMOUNT;
        response.O_INFO = O_INFO;
        response.O_CODE = O_CODE;
        response.O_HISTORY = O_HISTORY;
        response.O_RETURN = O_RETURN;                
        response.T_MATERIAL = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_MATERIAL>{T_MATERIAL};
        response.T_MOTION = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_MOTION>{T_MOTION};
        response.T_DOC = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC>{T_DOC};
        response.T_SUB = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_SUB>{T_SUB};
        response.T_DATA = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DATA>{T_DATA};
        response.T_DOC_INFO = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_INFO>{T_DOC_INFO};
        response.T_DOC_SR = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_SR>{T_DOC_SR};
        response.T_TEXT_D = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_D>{T_TEXT_D};
        response.T_TEXT_C = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_C>{T_TEXT_C};
        response.T_TEXT_A = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_A>{T_TEXT_A};
        response.T_CONSIGN = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_CONSIGN>{T_CONSIGN};
        response.T_TEXT_CR = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_TEXT_CR>{T_TEXT_CR};
        response.T_ZCST0061 = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_ZCST0061>{T_ZCST0061};
        response.T_ZCST0062 = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_ZCST0062>{T_ZCST0062};        
        
        method.IF_SERVICE_054(request);
        Test.stopTest(); 
    }

}