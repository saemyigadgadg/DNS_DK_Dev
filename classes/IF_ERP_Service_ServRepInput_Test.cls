@IsTest
public with sharing class IF_ERP_Service_ServRepInput_Test {
    private static String className = 'IF_ERP_Service_ServRepInput';

    public IF_ERP_Service_ServRepInput_Test() {}

/* Mock Classes
    */
    public class IF_SERVICE_046_HttpMock implements HttpCalloutMock {
        public IF_SERVICE_046_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Confm No(CBO) insert ok[ZCS02034]"},"O_DEL_MSG":"","O_TIME":"X","O_UPD_MSG":"","T_CONSIGN":[],"T_DEL":[],"T_DEL_SR":[],"T_DOC":[],"T_MATERIAL":[],"T_MOTION":[{"AENAM":"","ISDZ":"09:30:00","ISMNE":"","FLAG_0060":"","LTXA1":"고객사이동15분2","SEQNO":"0000","ISMNW_PDK":"0.0","SVCMAN_NAME":"","ERZET":"00:00:00","AUFNR":"403908144","AEDAT":"0000-00-00","WORKCD":"MV","AUSBS":"2025-02-05","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-02-05","EXRSN":"","RUECK":"0000000000","MANDT":"","ISMNW":"0.3","ERDAT":"0000-00-00","RMZHL":"00000000","AUZTB":"09:45:00","PERNR":"00006527","AEZET":"00:00:00","WORKNO":"0000"},{"AENAM":"","ISDZ":"09:45:00","ISMNE":"","FLAG_0060":"","LTXA1":"진단1시간2","SEQNO":"0000","ISMNW_PDK":"0.0","SVCMAN_NAME":"","ERZET":"00:00:00","AUFNR":"403908144","AEDAT":"0000-00-00","WORKCD":"DN","AUSBS":"2025-02-05","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-02-05","EXRSN":"","RUECK":"0000000000","MANDT":"","ISMNW":"1.0","ERDAT":"0000-00-00","RMZHL":"00000000","AUZTB":"10:45:00","PERNR":"00006527","AEZET":"00:00:00","WORKNO":"0000"},{"AENAM":"","ISDZ":"10:45:00","ISMNE":"","FLAG_0060":"","LTXA1":"작업1시간2","SEQNO":"0000","ISMNW_PDK":"0.0","SVCMAN_NAME":"","ERZET":"00:00:00","AUFNR":"403908144","AEDAT":"0000-00-00","WORKCD":"WK","AUSBS":"2025-02-05","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-02-05","EXRSN":"","RUECK":"0000000000","MANDT":"","ISMNW":"1.0","ERDAT":"0000-00-00","RMZHL":"00000000","AUZTB":"11:45:00","PERNR":"00006527","AEZET":"00:00:00","WORKNO":"0000"}],"T_RETURN":[{"CODE":"","MESSAGE":"Contact info update ok ![ZCS02025]","TYPE":"S"},{"CODE":"","MESSAGE":"Notification Same data[ZCS02064]","TYPE":"S"},{"CODE":"","MESSAGE":"Settlement Rule Entry OK ![ZCS02158]","TYPE":"S"},{"CODE":"","MESSAGE":"Confm No(CBO) insert ok[ZCS02034]","TYPE":"S"},{"CODE":"","MESSAGE":"Service Report File upload was successful.","TYPE":"S"}],"T_TMP":[],"T_TMP_SR":[{"FILENAME":"403908144_test.txt","FILE_SIZE":"76","DESC":"403908144_test.txt","LINE":"[B@173590b2","EVISEQX":"01"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }


    @IsTest
    static void IF_SERVICE_046_TEST(){
        InterfaceCommonUtil.setInterface('IF-SERVICE-046', className);
        Test.startTest();
        IF_ERP_Service_ServRepInput method = new IF_ERP_Service_ServRepInput();
        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_USERINFO I_USERINFO =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_USERINFO();
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
        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_INFO I_INFO =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_INFO();
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

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_SUB I_SUB =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_SUB();
        I_SUB.KEY = '';
        I_SUB.VALUE = '';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_CODE I_CODE =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_CODE();
        I_CODE.CODE_01 = '';
        I_CODE.CODE_02 = '';
        I_CODE.CODE_03 = '';
        I_CODE.TEXT = '';
        I_CODE.TEXT2 = '';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_HISTORY I_HISTORY =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_HISTORY();
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
        I_HISTORY.INCLUDE = '';
        I_HISTORY.ERDAT = '';
        I_HISTORY.ERNAM = '';
        I_HISTORY.ERZET = '';
        I_HISTORY.AEDAT = '';
        I_HISTORY.AENAM = '';
        I_HISTORY.AEZET = '';
        I_HISTORY.TXTQM = '';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MOTION T_MOTION =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MOTION();
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

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MATERIAL T_MATERIAL =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MATERIAL();
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

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DOC T_DOC =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DOC();
        T_DOC.FILENAME = '';
        T_DOC.MIMETYPE = '';
        T_DOC.FILEDATA = '';
        T_DOC.DESCRIPTION = '';
        T_DOC.FLAG = '';
        T_DOC.DOCNO = '';


        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL T_DEL =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL();
        T_DEL.DOCNO = '';
        T_DEL.FILENAME = '';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP T_TMP =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP();
        T_TMP.FILENAME = '';
        T_TMP.IF_DESC = '';
        T_TMP.EVISEQX = '';
        T_TMP.LINE = '';
        T_TMP.FILE_SIZE = '';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL_SR T_DEL_SR =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL_SR();
        T_DEL_SR.DOCNO = '';
        T_DEL_SR.FILENAME = '';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR T_TMP_SR =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR();
        T_TMP_SR.FILENAME = '';
        T_TMP_SR.IF_DESC = '';
        T_TMP_SR.EVISEQX = '';
        T_TMP_SR.LINE = '';
        T_TMP_SR.FILE_SIZE = '';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_CONSIGN T_CONSIGN =
        new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_CONSIGN();
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

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req request  = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req();
        request.I_TIME = '';
        request.I_NOT_DELIVERY = '';
        request.I_TEXT = '';
        request.I_DESCRIPT = '';
        request.I_CAUSE = '';
        request.I_ACTIVITY = '';
        request.I_CR = '';
        request.I_MANHOUR_REASON = '';
        request.I_EXRSN = '';

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_O_RETURN O_RETURN = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_MOTION T_MOTION_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_MOTION();
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
        T_MOTION_RES.ERDAT = '';
        T_MOTION_RES.ERNAM = '';
        T_MOTION_RES.ERZET = '';
        T_MOTION_RES.AEDAT = '';
        T_MOTION_RES.AENAM = '';
        T_MOTION_RES.AEZET = '';
        T_MOTION_RES.FLAG_0060 = '';
        T_MOTION_RES.WORKCD = '';
        T_MOTION_RES.EXRSN = '';        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_MATERIAL T_MATERIAL_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_MATERIAL(); 
        T_MATERIAL_RES.AUFNR = '';
        T_MATERIAL_RES.WORKNO = '';
        T_MATERIAL_RES.SEQNO = '';
        T_MATERIAL_RES.MATNR = '';
        T_MATERIAL_RES.MEINS = '';
        T_MATERIAL_RES.SUPPLY_TYPE = '';
        T_MATERIAL_RES.CHANGE_DT = '';
        T_MATERIAL_RES.EBELN = '';
        T_MATERIAL_RES.EBELP = '';
        T_MATERIAL_RES.MBLNR = '';
        T_MATERIAL_RES.GI_MBLNR = '';
        T_MATERIAL_RES.LIFNR = '';
        T_MATERIAL_RES.NAME1 = '';
        T_MATERIAL_RES.NETWR = '';
        T_MATERIAL_RES.BRTWR = '';
        T_MATERIAL_RES.FREIGHT = '';
        T_MATERIAL_RES.WAERS = '';
        T_MATERIAL_RES.BELNR = '';
        T_MATERIAL_RES.RETURN_YN = '';
        T_MATERIAL_RES.ERDAT = '';
        T_MATERIAL_RES.ERNAM = '';
        T_MATERIAL_RES.ERZET = '';
        T_MATERIAL_RES.AEDAT = '';
        T_MATERIAL_RES.AENAM = '';
        T_MATERIAL_RES.AEZET = '';
        T_MATERIAL_RES.ITEM_CAT = '';
        T_MATERIAL_RES.RETURN_TYPE = '';
        T_MATERIAL_RES.RETURN_TEXT = '';
        T_MATERIAL_RES.PGMNG = '';
        T_MATERIAL_RES.READ_ONLY = '';
        T_MATERIAL_RES.MENGE = '';
        T_MATERIAL_RES.MENGE_GI = '';
        T_MATERIAL_RES.READ_ONLY_02 = '';
        T_MATERIAL_RES.READ_ONLY_03 = '';
        T_MATERIAL_RES.MAKTX = '';
        T_MATERIAL_RES.CAUSE_PRT = '';
        T_MATERIAL_RES.READ_ONLY_04 = '';
        T_MATERIAL_RES.ITEM_NUMBER = '';
        T_MATERIAL_RES.NETWR_VISIBLE = '';
        T_MATERIAL_RES.QDATU = '';
        T_MATERIAL_RES.QZEIT = '';
        T_MATERIAL_RES.RTYPE_ENABLE = '';
        T_MATERIAL_RES.GR = '';
        T_MATERIAL_RES.REASON1 = '';
        T_MATERIAL_RES.REASON2 = '';        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DOC T_DOC_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DOC(); 
        T_DOC_RES.FILENAME = '';
        T_DOC_RES.MIMETYPE = '';
        T_DOC_RES.FILEDATA = '';
        T_DOC_RES.DESCRIPTION = '';
        T_DOC_RES.FLAG = '';
        T_DOC_RES.DOCNO = '';        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DEL T_DEL_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DEL(); 
        T_DEL_RES.DOCNO = '';
        T_DEL_RES.FILENAME = '';        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_TMP T_TMP_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_TMP(); 
        T_TMP_RES.FILENAME = '';
        T_TMP_RES.IF_DESC = '';
        T_TMP_RES.EVISEQX = '';
        T_TMP_RES.LINE = '';
        T_TMP_RES.FILE_SIZE = '';        
        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DEL_SR T_DEL_SR_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DEL_SR(); 
        T_DEL_SR_RES.DOCNO ='';
        T_DEL_SR_RES.FILENAME ='';        

        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_TMP_SR T_TMP_SR_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_TMP_SR(); 
        T_TMP_SR_RES.FILENAME = '';
        T_TMP_SR_RES.IF_DESC = '';
        T_TMP_SR_RES.EVISEQX = '';
        T_TMP_SR_RES.LINE = '';
        T_TMP_SR_RES.FILE_SIZE = '';        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_CONSIGN T_CONSIGN_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_CONSIGN(); 
        T_CONSIGN_RES.AUFNR = '';
        T_CONSIGN_RES.QMNUM = '';
        T_CONSIGN_RES.ZSEQN = '';
        T_CONSIGN_RES.WERKS = '';
        T_CONSIGN_RES.LIFNR = '';
        T_CONSIGN_RES.NAME1 = '';
        T_CONSIGN_RES.ZCOSTC = '';
        T_CONSIGN_RES.ZCOSTC_T = '';
        T_CONSIGN_RES.ZPORD = '';
        T_CONSIGN_RES.ZPORD_T = '';
        T_CONSIGN_RES.ZACTIVI = '';
        T_CONSIGN_RES.ZACTIVI_T = '';
        T_CONSIGN_RES.ZTRANF = '';
        T_CONSIGN_RES.ZTRANF_T = '';
        T_CONSIGN_RES.ZTRANT = '';
        T_CONSIGN_RES.ZDISTA = '';
        T_CONSIGN_RES.ZEXPEN = '';
        T_CONSIGN_RES.WAERS = '';
        T_CONSIGN_RES.REMARK = '';
        T_CONSIGN_RES.CONFID = '';
        T_CONSIGN_RES.CONFDT = '';
        T_CONSIGN_RES.CONFTM = '';        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_RETURN T_RETURN_RES = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_RETURN();         
        T_RETURN_RES.TYPE = '';
        T_RETURN_RES.CODE = '';
        T_RETURN_RES.MESSAGE = '';
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res response = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res();
        response.O_TIME = '';
        response.O_DEL_MSG = '';
        response.O_UPD_MSG = '';        
        response.O_RETURN = O_RETURN;
        response.T_MOTION = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_MOTION>{T_MOTION_RES};
        response.T_MATERIAL = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_MATERIAL>{T_MATERIAL_RES};
        response.T_DOC = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DOC>{T_DOC_RES};
        response.T_DEL = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DEL>{T_DEL_RES};
        response.T_TMP = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_TMP>{T_TMP_RES};
        response.T_DEL_SR = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_DEL_SR>{T_DEL_SR_RES};
        response.T_TMP_SR = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_TMP_SR>{T_TMP_SR_RES};
        response.T_CONSIGN = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_CONSIGN>{T_CONSIGN_RES};
        response.T_RETURN = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res_T_RETURN>{T_RETURN_RES};        
        method.IF_SERVICE_046(request);
        Test.stopTest(); 
    }    
}