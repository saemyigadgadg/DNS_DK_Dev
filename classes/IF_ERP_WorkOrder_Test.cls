@isTest
public with sharing class IF_ERP_WorkOrder_Test {
    private static String className = 'IF_ERP_WorkOrder';

    public IF_ERP_WorkOrder_Test() {}

/* Mock Classes
    */
    public class IF_CSPLUS_004_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_004_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_005_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_005_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"403908171"},"O_AUFNR":"403908171"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_010_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_010_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_AUFNR":"403908204","O_QMNUM":"302382197","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"403908204 302382197/S/주작업자를 등록하였습니다./요청자 정보를 등록하였습니다./0000000000/0"},"O_RSNUM":"0","T_O_LIST":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_015_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_015_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"보조작업자를 등록하였습니다."}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_019_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_019_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_AUFNR":"403907770","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"403907770 Work Order 생성 완료"},"ET_PARTNER":[{"PARTNER":"","PARTNER_OLD":"0001158372","PARTN_ROLE_OLD":"RE","PARTN_ROLE":""},{"PARTNER":"","PARTNER_OLD":"0001094482","PARTN_ROLE_OLD":"WE","PARTN_ROLE":""},{"PARTNER":"","PARTNER_OLD":"0001094482","PARTN_ROLE_OLD":"AG","PARTN_ROLE":""}],"ES_HEADER":{"ORDERID":"000403907770","ORDER_TYPE":"CS01","PLANPLANT":"184S","BUS_AREA":"B140","MN_WK_CTR":"114B","PLANT":"184S","MN_WKCTR_ID":"10010706","PMACTTYPE":"106","PLANGROUP":"180","SYSTCOND":"","FUNCT_LOC":"","EQUIPMENT":"MV0081-001437","SERIALNO":"MV0081-001437","MATERIAL":"T4000L-F0MP-2-K10","ASSEMBLY":"","DEVICEDATA":"","MAINTPLANT":"184S","LOCATION":"","MAINTROOM":"","PLSECTN":"E07","LOC_WK_CTR":"114B","LOC_WKCTR_ID":"10010706","ABCINDIC":"","SORTFIELD":"","COMP_CODE":"1800","PROFIT_CTR":"","CO_AREA":"1800","RESPCCTR":"0000053004","FUNC_AREA":"","SUPERIOR_NETWORK":"","SUPERIOR_ACTIVITY":"","SUPERIOR_ROUTING_NO":"0000000000","SUPERIOR_COUNTER":"00000000","WBS_ELEM":"00000000","PROJ_DEF":"00000000","PROCESSING_GROUP":"00","OBJECTCLASS":"OC","TAXJURCODE":"","LOC_COMP_CODE":"1800","LOC_CO_AREA":"1800","ASSET_NO":"","SUB_NUMBER":"","LOC_BUS_AREA":"B140","COSTCENTER":"","LOC_WBS_ELEM":"00000000","STANDORDER":"","SETTLORDER":"","SALESORG":"1800","DISTR_CHAN":"10","DIVISION":"40","ORDPLANID":"","START_DATE":"2025-01-08","FINISH_DATE":"2025-01-08","BASICSTART":"00:00:00","BASIC_FIN":"24:00:00","PRIORITY":"","REVISION":"","VERSION":"00","SCHED_TYPE":"2","AUTOSCHED":"X","CAP_REQMTS":"X","SCHEDULING_EXACT_BREAK_TIMES":"","MRP_RELEVANT":"1","PRODUCTION_START_DATE":"2025-01-08","PRODUCTION_FINISH_DATE":"2025-01-08","PRODUCTION_START_TIME":"18:00:00","PRODUCTION_FINISH_TIME":"18:00:00","ACTUAL_START_DATE":"0000-00-00","ACTUAL_FINISH_DATE":"0000-00-00","ACTUAL_START_TIME":"00:00:00","ACTUAL_FINISH_TIME":"00:00:00","REFDATE":"2025-01-08","SALES_ORD":"","S_ORD_ITEM":"000000","CALC_MOTIVE":"","INVEST_PROFILE":"","SCALE":"","INV_REASON":"","ENVIR_INVEST":"","ESTIMATED_COSTS":"0.00","CURRENCY":"KRW","CURRENCY_ISO":"KRW","CSTG_SHEET":"","OVERHEAD_KEY":"","RES_ANAL_KEY":"","NETWORK_PROFILE":"CS00001","CSTGVAPPLN":"PM01","CSTGVARACT":"PM01","TASK_LIST_GROUP":"","GROUP_COUNTER":"","TASK_LIST_TYPE":"E","RESP_PLANNER_GROUP":"","MNTPLAN":"","MAINTITEM":"","CALL_NO":"0","LAST_ORD":"","ENTERED_BY":"EAICOM","ENTER_DATE":"2025-01-08","CHANGED_BY":"","CHANGE_DATE":"0000-00-00","SCENARIO":"O100","SYS_STATUS":"CRTD MANC NMAT PRC","USER_ST":"","USERSTATUS":"","STAT_PROF":"","OBJECT_NO":"OR000403907770","ROUTING_NO":"1038028131","RESERV_NO":"0173209163","SHORT_TEXT":"","LONG_TEXT":"","NOTIF_NO":"","ASSEMBLY_EXTERNAL":"","ASSEMBLY_GUID":"","ASSEMBLY_VERSION":"","MATERIAL_EXTERNAL":"","MATERIAL_GUID":"","MATERIAL_VERSION":"","CALID":"","KALSN":"00"},"ES_SRVDATA":{"OBJECT_NO":"OR000403907770","SALESORG":"1800","DISTR_CHAN":"10","DIVISION":"40","SALES_GRP":"","SALES_OFF":"","PURCH_NO_C":"","PURCH_DATE":"0000-00-00","MATERIAL":"","QUANTITY":"0.000","BASE_UOM":"","BASE_UOM_ISO":"","CONFIGURATION":"000000000000000000","DLI_PROFILE":"","BILLING_FORM":"","MATERIAL_EXTERNAL":"","MATERIAL_GUID":"","MATERIAL_VERSION":""},"ET_OPERATIONS":[{"ACT_START_TIME":"00:00:00","CONSTRAINT_TYPE_FINISH":"","COST_ELEMENT":"","WORK_CNTR":"114B","UNLOAD_PT":"","PERS_NO":"00000000","FIELD_KEY":"","ACTTYPE":"","EARL_SCHED_FIN_TIME":"18:00:00","WAGETYPE":"","USE05_ISO":"","UN_WORK":"H","SORT_FLD":"","CONSTRAINT_TYPE_START":"","LATE_SCHED_FIN_TIME":"18:00:00","STANDARD_TEXT_KEY":"","SYSTCOND":"","ORDER_ITEM":"00000","PRICE_UNIT":"0","SYSTEM_STATUS_TEXT":"CRTD","LATE_SCHED_START_TIME":"18:00:00","ASSEMBLY_GUID":"","WAGEGROUP":"","USE04_ISO":"","FCST_FIN_DATE":"0000-00-00","START_CONS":"0000-00-00","CALC_KEY":"1","LANGU_ISO":"","USR11":"","USR10":"","PREQ_NAME":"","FW_ORDER":"","DURATION_NORMAL_UNIT_ISO":"","SUB_ACTIVITY":"","VENDOR_NO":"","PUR_GROUP":"","DURATION_NORMAL":"0.0","CURRENCY":"","CONF_NO":"0137294769","USR09":"0000-00-00","USR08":"0000-00-00","USR07":"0.000","USR06":"0.000","EXECFACTOR":"1","USR05":"0.000","USR04":"0.000","USR03":"","AGREEMENT":"","USR02":"","USR01":"","USR00":"","PRICE":"0.00","STRTTIMCON":"00:00:00","PREQ_NO":"","INFO_REC":"","WORK_FORECAST":"0.0","ASSEMBLY":"","MRP_RELEVANT":"1","EARL_SCHED_START_DATE":"2025-01-08","ACTIVITY":"0010","FCST_FIN_TIME":"00:00:00","FIN_CONSTR":"0000-00-00","SUITABILITY":"","CURRENCY_ISO":"","ACT_END_DATE":"0000-00-00","MATL_GROUP":"","FINTIMCONS":"00:00:00","ACT_START_DATE":"0000-00-00","PURCH_ORG":"","BASE_UOM":"","PLANT":"184S","WORK_ACTUAL":"0.000","USE07_ISO":"","UN_WORK_ISO":"","AGMT_ITEM":"00000","ASSEMBLY_EXTERNAL":"","CONTROL_KEY":"SM01","ASSEMBLY_VERSION":"","EARL_SCHED_FIN_DATE":"2025-01-08","FREE_BUFFER":"0","DURATION_NORMAL_UNIT":"H","PLND_DELRY":"0","GR_RCPT":"","DESCRIPTION":"","NUMBER_OF_CAPACITIES":"1","PERCENT_OF_WORK":"0","NO_OF_TIME_TICKETS":"0","LATE_SCHED_FIN_DATE":"2025-01-08","COMPLETE":"","PREQ_ITEM":"00000","USE07":"","EARL_SCHED_START_TIME":"18:00:00","USE06":"","USE05":"","INT_DISTR":"","USE04":"","QUANTITY":"1.000","BASE_UOM_ISO":"","LANGU":"","TRACKINGNO":"","USE06_ISO":"","TOTAL_BUFFER":"0","LATE_SCHED_START_DATE":"2025-01-08","ACT_END_TIME":"00:00:00","WORK_ACTIVITY":"0.0"}],"T_O_LIST":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_028_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_028_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully saved ! [ZCS05002]"},"T_O_LIST":[{"PERNR":"00006559","MSDD":"2025-02-12","IEDD":"2025-02-12","MESSAGE":"작업 시간 등록에 성공하였습니다.","MSDZ":"19:21:46","IEDZ":"19:22:41","ISDD":"2025-02-12","ISDZ":"19:21:57","TYPE":"S","AUFNR":"403908189","LTXA1":"0.0"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_034_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_034_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_037_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_037_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_NOTI_NUMB":"000302382185","E_SERVICE_ORDER":"000501573315","T_RETURN":[{"SYSTEM":"","LOG_NO":"","LOG_MSG_NO":"000000","NUMBER":"000","PARAMETER":"","MESSAGE":"Success to Create and Release Notification, Service Order","FIELD":"","ROW":"0","TYPE":"S","ID":"","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_042_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_042_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_AUFNR":"403908133","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"403908133"}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* TEST CODE
    */
    @IsTest
    static void IF_CSPLUS_004_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-004', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Req();

        // 요청 데이터 설정
        req.I_PARNR = 'PARNR001';
        req.I_FLAG = 'X';

        // 요청 헤더 초기화 및 값 설정
        req.I_HEADER = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Req_I_HEADER();
        req.I_HEADER.AUFNR = 'AUFNR001';
        req.I_HEADER.OTGRP = 'OTGRP001';
        req.I_HEADER.OTEIL = 'OTEIL001';
        req.I_HEADER.FEGRP = 'FEGRP001';
        req.I_HEADER.FECOD = 'FECOD001';
        req.I_HEADER.FETXT = 'Failure Description';
        req.I_HEADER.URGRP = 'URGRP001';
        req.I_HEADER.URCOD = 'URCOD001';
        req.I_HEADER.URTXT = 'Urgent Repair';
        req.I_HEADER.MNGRP = 'MNGRP001';
        req.I_HEADER.MNCOD = 'MNCOD001';
        req.I_HEADER.MATXT = 'Material Text';
        req.I_HEADER.ISMNW_2 = '2';
        req.I_HEADER.IEDD = '20240101';
        req.I_HEADER.IEDZ = '120000';
        req.I_HEADER.LTXA1 = 'Long Text';
        req.I_HEADER.GRUND = 'Repair Reason';

        // IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        // instance.IF_CSPLUS_004(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res();

        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Successful';

        // T_O_LIST 객체 초기화 및 값 설정
        res.T_O_LIST = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res_T_O_LIST();
        res.T_O_LIST.TYPE = 'S';
        res.T_O_LIST.CODE = '200';
        res.T_O_LIST.MESSAGE = 'Data Processed Successfully';

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_005_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-005', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req();

        // 요청 데이터 설정
        req.I_EQUNR = 'EQ001';
        req.I_KTEXT = 'Equipment Description';
        req.I_PERNR = '12345';
        req.I_ILART = 'IL001';
        req.I_VAPLZ = 'VP001';
        req.I_AUFNR = 'AUF001';
        req.I_MANAGER = 'John Doe';
        req.I_TELF1 = '123-456-7890';
        req.I_PSTLZ = '98765';
        req.I_ADDR1 = '123 Main St';
        req.I_ADDR2 = 'Suite 200';
        req.I_GSTRP = '20240101';
        req.I_GLTRP = '20241231';
        req.I_SOLDTO = 'Customer001';
        req.I_SWERKS = 'Plant001';

        // T_I_LIST 초기화 및 값 설정
        req.T_I_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req_T_I_LIST>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req_T_I_LIST item1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req_T_I_LIST();
        item1.LINE = 'Line 1';
        req.T_I_LIST.add(item1);

        // T_I_LIST2 초기화 및 값 설정
        req.T_I_LIST2 = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req_T_I_LIST2>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req_T_I_LIST2 item2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req_T_I_LIST2();
        item2.LINE = 'Line 2';
        req.T_I_LIST2.add(item2);

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.IF_CSPLUS_005(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res();

        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Processed Successfully';

        // O_AUFNR 값 설정
        res.O_AUFNR = 'AUF001';

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_010_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-010', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req();

        // 요청 데이터 설정
        req.I_QMNUM = 'QM001';
        req.I_AUFNR = 'AUF001';
        req.I_EQUNR = 'EQ001';
        req.I_WARR_YN = 'Y';
        req.I_STATUS = 'Active';
        req.I_NEW_CLICK = 'I';
        req.I_MAT_CLICK = 'Y';
        req.I_MAT_CONFIRM = 'Y';
        req.I_SOLDTO = 'CUST001';
        req.I_SKIP_SBOM = 'X';
        req.I_SAFETY = 'Safe';
        req.I_OUT_WARR = 'X';
        req.I_DIRECT = 'X';
        req.I_TASKLIST = 'TL001';
        req.I_DOC_TYPE = 'DT001';
        req.I_SERIES_CODE = 'SC001';
        req.I_SERIES_NAME = 'Series A';
        req.I_UNIT_CODE = 'UC001';
        req.I_UNIT_NAME = 'Unit A';
        req.I_UNIT_SUB_CODE = 'USC001';
        req.I_UNIT_SUB_NAME = 'Service Item A';
        req.I_UNIT_SUB_DESC = 'Detailed Work Description';
        req.I_MANHOUR_VAL = '10H';
        req.I_HUMAN_VAL = '5';
        req.I_WORK_ITEM_CODE = 'WIC001';
        req.I_WORK_ITEM_NAME = 'Standard Work Item';
        req.I_BILL_CATEGORY = 'Y';
        req.I_MANHOUR_USE_YN = 'Y';
        req.I_LOEKZ = 'X';

        // I_HEADER 객체 초기화 및 값 설정
        req.I_HEADER = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER();
        req.I_HEADER.QMCOD = 'QMC001';
        req.I_HEADER.OTGRP = 'OT001';
        req.I_HEADER.OTEIL = 'OTPart1';
        req.I_HEADER.FEGRP = 'FE001';
        req.I_HEADER.FECOD = 'FECode1';
        req.I_HEADER.FETXT = 'Short Text';
        req.I_HEADER.TRBL_DT = '20240101';
        req.I_HEADER.TRBL_TM = '1000';
        req.I_HEADER.RECV_DT = '20240102';
        req.I_HEADER.RECV_TM = '1100';
        req.I_HEADER.LTRMN = '20240103';
        req.I_HEADER.LTRUR = '1200';
        req.I_HEADER.QMNAM = 'John Doe';
        req.I_HEADER.ARBPL = 'WorkCenter1';
        req.I_HEADER.DAUNO = '5';
        req.I_HEADER.S_DATE = '20240101';
        req.I_HEADER.W_DETAIL = 'Work Details';
        req.I_HEADER.INPUT_NO = '3';
        req.I_HEADER.PERNR = 'P12345';
        req.I_HEADER.TYPBZ = 'Model A';
        req.I_HEADER.SERNR = 'SN001';
        req.I_HEADER.REP_DEPT = 'Repair';
        req.I_HEADER.SAFETY = 'Y';

        // I_HEADER2 객체 초기화 및 값 설정
        req.I_HEADER2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2();
        req.I_HEADER2.KUNNR = 'CUST001';
        req.I_HEADER2.SEQNO = '1';
        req.I_HEADER2.NAME = 'Customer Name';
        req.I_HEADER2.NAME1 = 'Customer Name 1';
        req.I_HEADER2.POST_CODE1 = '12345';
        req.I_HEADER2.CITY1 = 'Seoul';
        req.I_HEADER2.STREET = '123 Main St';
        req.I_HEADER2.TEL_NUMBER = '010-1234-5678';
        req.I_HEADER2.TEL_NUMBER2 = '010-9876-5432';
        req.I_HEADER2.TEL_NUMBER3 = '010-5678-1234';
        req.I_HEADER2.DELT = 'X';
        req.I_HEADER2.ERDAT = '20240101';
        req.I_HEADER2.ERNAM = 'Admin';
        req.I_HEADER2.AEDAT = '20240102';
        req.I_HEADER2.AENAM = 'Updater';

        // T_I_LIST 초기화 및 값 설정
        req.T_I_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST item1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST();
        item1.MATNR = 'MAT001';
        item1.MENGE = '5';
        item1.SUPPLY_TP = 'Supply A';
        item1.VENDOR = 'Vendor1';
        item1.VSBED = 'Shipping A';
        item1.RSNUM = 'RS001';
        item1.RSPOS = 'RSP001';
        item1.MFLAG = 'M';
        item1.RETURN_YN = 'Y';
        item1.POSNR = 'P001';
        item1.SPIND = 'R';
        req.T_I_LIST.add(item1);

        // T_I_LIST2 초기화 및 값 설정
        req.T_I_LIST2 = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2 item2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2();
        item2.TEXT = 'Sample Text';
        req.T_I_LIST2.add(item2);

        // T_I_PERNR 초기화 및 값 설정
        req.T_I_PERNR = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_PERNR>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_PERNR pernr1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_PERNR();
        pernr1.PERSNO = 'P12345';
        req.T_I_PERNR.add(pernr1);

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.IF_CSPLUS_010(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res();

        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Processed Successfully';

        // O_AUFNR, O_QMNUM, O_RSNUM 값 설정
        res.O_AUFNR = 'AUF001';
        res.O_QMNUM = 'QM001';
        res.O_RSNUM = 'RS001';

        // T_O_LIST 초기화 및 값 설정
        res.T_O_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res_T_O_LIST>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res_T_O_LIST message1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res_T_O_LIST();
        message1.TYPE = 'S';
        message1.CODE = '100';
        message1.MESSAGE = 'Success message';
        res.T_O_LIST.add(message1);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_015_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-015', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req();

        // 요청 데이터 설정
        req.I_AUFNR = 'AUF015';

        // T_I_LIST 초기화 및 값 설정
        req.T_I_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req_T_I_LIST>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req_T_I_LIST item1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req_T_I_LIST();
        item1.PERNR = 'P001';
        req.T_I_LIST.add(item1);

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.IF_CSPLUS_015(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res();

        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Processed Successfully';

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_019_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-019', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Req();

        // 요청 데이터 설정
        req.I_AUFNR = 'AUF001';
        req.I_EQUNR = 'EQ001';
        req.I_PERNR = 'P001';
        req.I_ILART = 'MT001';
        req.I_KTEXT = 'Short description';
        req.I_DOC_TYPE = 'DOC01';
        req.I_LTXA1 = 'Operation description';
        req.I_ARBEI = '5H';
        req.I_ANZZL = '3';
        req.I_F_PERNR = 'P12345';
        req.I_SOLD_TO = 'CUST001';

        // T_I_LIST 초기화 및 값 설정
        req.T_I_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Req_T_I_LIST>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Req_T_I_LIST item1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Req_T_I_LIST();
        item1.AUFNR = 'AUF001';
        item1.PERNR = 'P001';
        item1.MSDD = '20240201';
        item1.MSDZ = '1000';
        item1.ISDD = '20240202';
        item1.ISDZ = '1100';
        item1.IEDD = '20240203';
        item1.IEDZ = '1200';
        item1.LTXA1 = 'Active Task';
        req.T_I_LIST.add(item1);

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.IF_CSPLUS_019(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res();

        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Processed Successfully';

        // O_AUFNR 값 설정
        res.O_AUFNR = 'AUF001';

        // ES_HEADER 객체 초기화 및 값 설정
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ES_HEADER header = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ES_HEADER();
        header.ORDERID = 'ORD12345';
        header.ORDER_TYPE = 'PM';
        header.PLANPLANT = 'PLNT001';
        header.BUS_AREA = 'BUS123';
        header.MN_WK_CTR = 'WKC001';

        header.PLANT = 'PLANT123';
        header.MN_WKCTR_ID = 'WKC123';
        header.PMACTTYPE = 'Repair';
        header.PLANGROUP = 'PLNGRP1';
        header.SYSTCOND = 'Normal';

        header.FUNCT_LOC = 'LOC123';
        header.EQUIPMENT = 'EQP456';
        header.SERIALNO = 'SN789';
        header.MATERIAL = 'MAT001';
        header.ASSEMBLY = 'ASM001';

        header.DEVICEDATA = 'DeviceXYZ';
        header.MAINTPLANT = 'MP001';
        header.LOCATION = 'LocationA';
        header.MAINTROOM = 'RoomA';
        header.PLSECTN = 'SecB';

        header.LOC_WK_CTR = 'LWC001';
        header.LOC_WKCTR_ID = 'LWC123';
        header.ABCINDIC = 'A';
        header.SORTFIELD = 'SF123';
        header.COMP_CODE = 'CC123';

        header.PROFIT_CTR = 'PC456';
        header.CO_AREA = 'CA789';
        header.RESPCCTR = 'RC999';
        header.FUNC_AREA = 'FA001';
        header.SUPERIOR_NETWORK = 'SN999';

        header.SUPERIOR_ACTIVITY = 'SA001';
        header.SUPERIOR_ROUTING_NO = 'SRN002';
        header.SUPERIOR_COUNTER = 'SC003';
        header.WBS_ELEM = 'WBSE001';
        header.PROJ_DEF = 'PD999';

        header.PROCESSING_GROUP = 'PG001';
        header.OBJECTCLASS = 'OC002';
        header.TAXJURCODE = 'TJ003';
        header.LOC_COMP_CODE = 'LCC001';
        header.LOC_CO_AREA = 'LCA002';

        header.ASSET_NO = 'AN123';
        header.SUB_NUMBER = 'SN456';
        header.LOC_BUS_AREA = 'LBA789';
        header.COSTCENTER = 'CCO999';
        header.LOC_WBS_ELEM = 'LWBE001';

        header.STANDORDER = 'SO123';
        header.SETTLORDER = 'SET001';
        header.SALESORG = 'SAL001';
        header.DISTR_CHAN = 'DC002';
        header.DIVISION = 'DIV003';

        header.ORDPLANID = 'OP123';
        header.START_DATE = '2024-02-17';
        header.FINISH_DATE = '2024-02-20';
        header.BASICSTART = '08:00:00';
        header.BASIC_FIN = '18:00:00';

        header.PRIORITY = 'High';
        header.REVISION = 'Rev001';
        header.VERSION = 'V1.0';
        header.SCHED_TYPE = 'Auto';
        header.AUTOSCHED = 'X';

        header.CAP_REQMTS = 'Yes';
        header.SCHEDULING_EXACT_BREAK_TIMES = 'No';
        header.MRP_RELEVANT = 'Yes';
        header.PRODUCTION_START_DATE = '2024-02-18';
        header.PRODUCTION_FINISH_DATE = '2024-02-19';

        header.PRODUCTION_START_TIME = '09:00:00';
        header.PRODUCTION_FINISH_TIME = '17:00:00';
        header.ACTUAL_START_DATE = '2024-02-18';
        header.ACTUAL_FINISH_DATE = '2024-02-19';
        header.ACTUAL_START_TIME = '09:30:00';

        header.ACTUAL_FINISH_TIME = '16:30:00';
        header.REFDATE = '2024-02-15';
        header.SALES_ORD = 'SO001';
        header.S_ORD_ITEM = 'SORD002';
        header.CALC_MOTIVE = 'CM123';

        header.INVEST_PROFILE = 'IP001';
        header.SCALE = 'SCALE1';
        header.INV_REASON = 'IR002';
        header.ENVIR_INVEST = 'EI003';
        header.ESTIMATED_COSTS = '5000.00';

        header.IF_CURRENCY = 'USD';
        header.CURRENCY_ISO = 'USD';
        header.CSTG_SHEET = 'CS001';
        header.OVERHEAD_KEY = 'OH002';
        header.RES_ANAL_KEY = 'RA003';

        header.NETWORK_PROFILE = 'NP001';
        header.CSTGVAPPLN = 'CA002';
        header.CSTGVARACT = 'CV003';
        header.TASK_LIST_GROUP = 'TLG001';
        header.GROUP_COUNTER = 'GC002';

        header.TASK_LIST_TYPE = 'TLT003';
        header.RESP_PLANNER_GROUP = 'RPG001';
        header.MNTPLAN = 'MP002';
        header.MAINTITEM = 'MI003';
        header.CALL_NO = 'CN004';

        header.LAST_ORD = 'LO123';
        header.ENTERED_BY = 'UserA';
        header.ENTER_DATE = '2024-02-14';
        header.CHANGED_BY = 'UserB';
        header.CHANGE_DATE = '2024-02-16';

        header.SCENARIO = 'SCN001';
        header.SYS_STATUS = 'Active';
        header.USER_ST = 'In Progress';
        header.USERSTATUS = 'Completed';
        header.STAT_PROF = 'SP001';

        header.OBJECT_NO = 'OBJ123';
        header.ROUTING_NO = 'RN002';
        header.RESERV_NO = 'RS003';
        header.SHORT_TEXT = 'Short Description';
        header.LONG_TEXT = 'This is a long text description for testing.';

        header.NOTIF_NO = 'NOTI777';
        header.ASSEMBLY_EXTERNAL = 'AE001';
        header.ASSEMBLY_GUID = 'AG002';
        header.ASSEMBLY_VERSION = 'AV003';
        header.MATERIAL_EXTERNAL = 'ME004';

        header.MATERIAL_GUID = 'MG005';
        header.MATERIAL_VERSION = 'MV006';
        header.CALID = 'CAL001';
        header.KALSN = 'KAL002';
        res.ES_HEADER = header;

        // ES_SRVDATA 객체 초기화 및 값 설정
        res.ES_SRVDATA = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ES_SRVDATA();
        res.ES_SRVDATA.OBJECT_NO = 'OBJ001';
        res.ES_SRVDATA.SALESORG = 'SO001';
        res.ES_SRVDATA.DISTR_CHAN = 'DC001';
        res.ES_SRVDATA.DIVISION = 'D001';
        res.ES_SRVDATA.SALES_GRP = 'SG001';
        res.ES_SRVDATA.SALES_OFF            = 'test';
        res.ES_SRVDATA.PURCH_NO_C           = 'test';
        res.ES_SRVDATA.PURCH_DATE           = 'test';
        res.ES_SRVDATA.MATERIAL             = 'test';
        res.ES_SRVDATA.QUANTITY             = 'test';
        res.ES_SRVDATA.BASE_UOM             = 'test';
        res.ES_SRVDATA.BASE_UOM_ISO         = 'test';
        res.ES_SRVDATA.CONFIGURATION        = 'test';
        res.ES_SRVDATA.DLI_PROFILE          = 'test';
        res.ES_SRVDATA.BILLING_FORM         = 'test';
        res.ES_SRVDATA.MATERIAL_EXTERNAL    = 'test';
        res.ES_SRVDATA.MATERIAL_GUID        = 'test';
        res.ES_SRVDATA.MATERIAL_VERSION     = 'test';

        // ET_PARTNER 리스트 초기화 및 값 설정
        res.ET_PARTNER = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ET_PARTNER>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ET_PARTNER partner1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ET_PARTNER();
        partner1.PARTN_ROLE = 'PR001';
        partner1.PARTNER = 'PART001';
        res.ET_PARTNER.add(partner1);

        // ET_OPERATIONS 리스트 초기화 및 값 설정
        res.ET_OPERATIONS = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ET_OPERATIONS>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ET_OPERATIONS operation = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_ET_OPERATIONS();

        // 필드 값 설정 (모든 필드 포함)
        operation.ACTIVITY = 'OP001';
        operation.SUB_ACTIVITY = 'SUB001';
        operation.CONTROL_KEY = 'CTRL123';
        operation.WORK_CNTR = 'WKC001';
        operation.PLANT = 'PLANT123';

        operation.STANDARD_TEXT_KEY = 'TXT001';
        operation.DESCRIPTION = 'Operation Description';
        operation.LANGU = 'EN';
        operation.LANGU_ISO = 'ENG';
        operation.NO_OF_TIME_TICKETS = '5';

        operation.WAGETYPE = 'WT001';
        operation.SUITABILITY = 'S01';
        operation.WAGEGROUP = 'WG002';
        operation.SORT_FLD = 'SORT01';
        operation.VENDOR_NO = 'VND123';

        operation.QUANTITY = '100';
        operation.BASE_UOM = 'EA';
        operation.BASE_UOM_ISO = 'PCS';
        operation.PRICE = '500.00';
        operation.PRICE_UNIT = '10';

        operation.COST_ELEMENT = 'CE001';
        operation.IF_CURRENCY = 'USD';
        operation.CURRENCY_ISO = 'USD';
        operation.INFO_REC = 'IR123';
        operation.PURCH_ORG = 'PO001';

        operation.PUR_GROUP = 'PG001';
        operation.MATL_GROUP = 'MG002';
        operation.AGREEMENT = 'AG123';
        operation.AGMT_ITEM = 'AITEM1';
        operation.PREQ_NAME = 'Requester1';

        operation.TRACKINGNO = 'TRK123';
        operation.NUMBER_OF_CAPACITIES = '3';
        operation.PERCENT_OF_WORK = '75';
        operation.CALC_KEY = 'CK001';
        operation.ACTTYPE = 'AT001';

        operation.SYSTCOND = 'Normal';
        operation.ASSEMBLY = 'ASM001';
        operation.INT_DISTR = 'ID001';
        operation.GR_RCPT = 'GR123';
        operation.UNLOAD_PT = 'UP001';

        operation.PERS_NO = 'P001';
        operation.FW_ORDER = 'FWO123';
        operation.ORDER_ITEM = 'OITEM1';
        operation.PLND_DELRY = '5';
        operation.DURATION_NORMAL = '8';

        operation.DURATION_NORMAL_UNIT = 'H';
        operation.DURATION_NORMAL_UNIT_ISO = 'HR';
        operation.CONSTRAINT_TYPE_START = 'CTS001';
        operation.CONSTRAINT_TYPE_FINISH = 'CTF002';
        operation.WORK_ACTIVITY = 'WA001';

        operation.UN_WORK = 'H';
        operation.UN_WORK_ISO = 'HR';
        operation.START_CONS = 'SC001';
        operation.STRTTIMCON = '09:00:00';
        operation.FIN_CONSTR = 'FC001';

        operation.FINTIMCONS = '18:00:00';
        operation.EXECFACTOR = '1.2';
        operation.MRP_RELEVANT = 'Yes';
        operation.FIELD_KEY = 'FK001';
        operation.USR00 = 'UserField0';

        operation.USR01 = 'UserField1';
        operation.USR02 = 'UserField2';
        operation.USR03 = 'UserField3';
        operation.USR04 = 'UserField4';
        operation.USE04 = 'Unit4';

        operation.USE04_ISO = 'ISO4';
        operation.USR05 = 'UserField5';
        operation.USE05 = 'Unit5';
        operation.USE05_ISO = 'ISO5';
        operation.USR06 = 'UserField6';

        operation.USE06 = 'Unit6';
        operation.USE06_ISO = 'ISO6';
        operation.USR07 = 'UserField7';
        operation.USE07 = 'Unit7';
        operation.USE07_ISO = 'ISO7';

        operation.USR08 = '2024-02-17';
        operation.USR09 = '2024-02-18';
        operation.USR10 = 'Indicator1';
        operation.USR11 = 'Indicator2';
        operation.CONF_NO = 'CONF123';

        operation.PREQ_NO = 'PRQ001';
        operation.PREQ_ITEM = 'PRQ002';
        operation.COMPLETE = 'X';
        operation.WORK_ACTUAL = '90';
        operation.EARL_SCHED_START_DATE = '2024-02-19';

        operation.EARL_SCHED_START_TIME = '07:00:00';
        operation.EARL_SCHED_FIN_DATE = '2024-02-20';
        operation.EARL_SCHED_FIN_TIME = '18:00:00';
        operation.LATE_SCHED_START_DATE = '2024-02-21';
        operation.LATE_SCHED_START_TIME = '08:00:00';

        operation.LATE_SCHED_FIN_DATE = '2024-02-22';
        operation.LATE_SCHED_FIN_TIME = '17:00:00';
        operation.ACT_START_DATE = '2024-02-23';
        operation.ACT_START_TIME = '09:30:00';
        operation.ACT_END_DATE = '2024-02-24';

        operation.ACT_END_TIME = '16:30:00';
        operation.FCST_FIN_DATE = '2024-02-25';
        operation.FCST_FIN_TIME = '18:00:00';
        operation.FREE_BUFFER = '30';
        operation.TOTAL_BUFFER = '60';

        operation.WORK_FORECAST = '100';
        operation.SYSTEM_STATUS_TEXT = 'Active';
        operation.ASSEMBLY_EXTERNAL = 'AE001';
        operation.ASSEMBLY_GUID = 'AG002';
        operation.ASSEMBLY_VERSION = 'AV003';
        res.ET_OPERATIONS.add(operation);

        // T_O_LIST 리스트 초기화 및 값 설정
        res.T_O_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_T_O_LIST>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_T_O_LIST message1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res_T_O_LIST();
        message1.AUFNR = 'AUF001';
        message1.PERNR = 'P001';
        message1.MSDD = '20240201';
        message1.MSDZ = '1000';
        message1.ISDD = '20240202';
        message1.ISDZ = '1100';
        message1.IEDD = '20240203';
        message1.IEDZ = '1200';
        message1.LTXA1 = 'Active Task';
        message1.TYPE = 'S';
        message1.MESSAGE = 'Success message';
        res.T_O_LIST.add(message1);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_028_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req();
        
        // 요청 데이터 설정
        req.T_I_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST>();
        
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST item1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST();
        item1.AUFNR = 'ORD12345';
        item1.PERNR = 'P001';
        item1.MSDD  = '2024-02-17';
        item1.MSDZ  = '10:00:00';
        item1.ISDD  = '2024-02-18';
        item1.ISDZ  = '12:00:00';
        item1.IEDD  = '2024-02-19';
        item1.IEDZ  = '14:00:00';
        item1.LTXA1 = 'Test Execution';
        
        req.T_I_LIST.add(item1);

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.IF_CSPLUS_028(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res();
        
        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Processed Successfully';

        // 응답 리스트 초기화 및 데이터 설정
        res.T_O_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res_T_O_LIST>();
        
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res_T_O_LIST resItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res_T_O_LIST();
        resItem.AUFNR = 'ORD12345';
        resItem.PERNR = 'P001';
        resItem.MSDD  = '2024-02-17';
        resItem.MSDZ  = '10:00:00';
        resItem.ISDD  = '2024-02-18';
        resItem.ISDZ  = '12:00:00';
        resItem.IEDD  = '2024-02-19';
        resItem.IEDZ  = '14:00:00';
        resItem.LTXA1 = 'Test Execution';
        resItem.TYPE = 'S';
        resItem.MESSAGE = 'Execution Successful';
        
        res.T_O_LIST.add(resItem);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_034_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-034', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Req();
        
        // 조직 정보 설정
        req.I_USERID = 'USER123';
        req.I_CUST_NO = 'CUST001';
        req.I_OTHERS = 'Additional Info';
        
        req.I_ORG = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Req_I_ORG();
        req.I_ORG.VKORG = '1000';
        req.I_ORG.VTWEG = '10';
        req.I_ORG.SPART = '20';
        req.I_ORG.WERKS = '3000';
        req.I_ORG.ARBPL = '4000';
        req.I_ORG.AMSCCTL = '5000';

        // 요청 아이템 리스트 설정
        req.IT_ITEM = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Req_IT_ITEM>();
        
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Req_IT_ITEM item1 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Req_IT_ITEM();
        item1.MATNR = 'MAT123';
        item1.KUNNR = 'CUST001';
        
        req.IT_ITEM.add(item1);

        // IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        // instance.IF_CSPLUS_034(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res();
        
        // 응답 메시지 설정
        res.ES_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res_ES_RETURN();
        res.ES_RETURN.TYPE = 'S';
        res.ES_RETURN.ID = '001';
        res.ES_RETURN.IF_NUMBER = 'IF_034';
        res.ES_RETURN.MESSAGE = 'Request processed successfully';
        res.ES_RETURN.LOG_NO = 'LOG123';
        res.ES_RETURN.LOG_MSG_NO = 'MSG001';
        res.ES_RETURN.MESSAGE_V1 = 'Data Valid';
        res.ES_RETURN.MESSAGE_V2 = 'All checks passed';
        res.ES_RETURN.MESSAGE_V3 = '';
        res.ES_RETURN.MESSAGE_V4 = '';
        res.ES_RETURN.PARAMETER = 'Param1';
        res.ES_RETURN.ROW = '1';
        res.ES_RETURN.FIELD = 'FieldX';
        res.ES_RETURN.IF_SYSTEM = 'System_01';

        // 응답 데이터 리스트 설정
        res.ET_MAT = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res_ET_MAT>();

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res_ET_MAT matItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res_ET_MAT();
        matItem.MATNR = 'MAT123';
        matItem.REPNR = 'REP001';
        matItem.MAKTX = 'Test Material';
        matItem.KPEIN = '10';
        matItem.KMEIN = 'KG';
        matItem.KBETR = '100.50';
        matItem.KONWA = 'USD';
        matItem.CUQTY = '5';
        matItem.NOTCD = 'NC001';
        matItem.AVQTY = '100';
        matItem.NONMV = 'N';
        matItem.KUNNR = 'CUST001';
        matItem.RATE = '5.0';
        matItem.HSCODE = 'HS001';
        matItem.IGST = '18%';
        matItem.CGST = '9%';
        matItem.OTHER = 'Other Charges';
        matItem.SGST = '9%';
        matItem.NETPR = '95.00';

        res.ET_MAT.add(matItem);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_037_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-037', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Req();
        
        // 기본 정보 설정
        req.I_EQUNR = 'EQ12345';
        req.I_RES_PERSON = 'EMP001';
        
        // I_HEADER 객체 생성 및 설정
        req.I_HEADER = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Req_I_HEADER();
        req.I_HEADER.PLANPLANT = 'PLNT001';
        req.I_HEADER.PLANGROUP = 'GRP01';
        req.I_HEADER.MN_WK_CTR = 'WKCTR001';
        req.I_HEADER.PLANT = 'PLNT002';
        req.I_HEADER.PMACTTYPE = 'MT001';
        req.I_HEADER.START_DATE = '2024-02-17';
        req.I_HEADER.SHORT_TEXT = 'Test Maintenance Order';

        // I_OPERATION 객체 생성 및 설정
        req.I_OPERATION = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Req_I_OPERATION();
        req.I_OPERATION.CONTROL_KEY = 'CTRL01';
        req.I_OPERATION.SHORT_TEXT = 'Test Operation';

        // I_NOTI 객체 생성 및 설정
        req.I_NOTI = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Req_I_NOTI();
        req.I_NOTI.DESSTDATE = '2024-02-18';
        req.I_NOTI.DESENDDATE = '2024-02-19';
        req.I_NOTI.PLANPLANT = 'PLNT001';
        req.I_NOTI.PLANGROUP = 'GRP01';
        req.I_NOTI.STRMLFNDATE = '2024-02-18';
        req.I_NOTI.ENDMLFNDATE = '2024-02-19';
        req.I_NOTI.REPORTEDBY = 'EMP002';
        req.I_NOTI.NOTIF_DATE = '2024-02-17';
        req.I_NOTI.CODE_GROUP = 'CG001';
        req.I_NOTI.CODING = 'CD001';
        req.I_NOTI.MAINTPLANT = 'PLNT002';

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.IF_CSPLUS_037(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res();
        
        // 응답 데이터 설정
        res.E_NOTI_NUMB = 'NOTI123';
        res.E_SERVICE_ORDER = 'ORD12345';

        // 응답 메시지 리스트 설정
        res.T_RETURN = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res_T_RETURN>();

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res_T_RETURN returnItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res_T_RETURN();
        returnItem.TYPE = 'S';
        returnItem.ID = 'MSG001';
        returnItem.IF_NUMBER = 'IF_037';
        returnItem.MESSAGE = 'Notification created successfully';
        returnItem.LOG_NO = 'LOG123';
        returnItem.LOG_MSG_NO = 'MSG002';
        returnItem.MESSAGE_V1 = 'Valid Data';
        returnItem.MESSAGE_V2 = 'Process Completed';
        returnItem.MESSAGE_V3 = '';
        returnItem.MESSAGE_V4 = '';
        returnItem.PARAMETER = 'Param1';
        returnItem.ROW = '1';
        returnItem.FIELD = 'FieldX';
        returnItem.IF_SYSTEM = 'System_01';

        res.T_RETURN.add(returnItem);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_042_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-042', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req();
                
        // 기본 정보 설정
        req.I_EQUNR = 'EQ12345';
        req.I_KTEXT = 'Test Equipment';
        req.I_PERNR = 'EMP001';
        req.I_ILART = 'IL001';
        req.I_VAPLZ = 'VP001';

        req.I_AUFNR = 'AUF123';
        req.I_GSTRP = '2024-02-17';
        req.I_KUNUM = 'KUN123';
        req.I_COWORKER1 = 'CW001';
        req.I_COWORKER2 = 'CW002';
        req.I_COWORKER3 = 'CW003';
        req.I_COWORKER4 = 'CW004';
        req.I_SWERKS = 'PLANT01';

        // 리스트 생성 및 추가
        req.T_I_LIST = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req_T_I_LIST>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req_T_I_LIST listItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req_T_I_LIST();
        listItem.LINE = 'Test Line 1';
        req.T_I_LIST.add(listItem);

        req.T_I_LIST2 = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req_T_I_LIST2>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req_T_I_LIST2 listItem2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req_T_I_LIST2();
        listItem2.LINE = 'Test Line 2';
        req.T_I_LIST2.add(listItem2);

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.IF_CSPLUS_042(req);

        // 응답 객체 생성
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res res = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res();

        // 응답 데이터 설정
        res.O_AUFNR = 'AUF98765';

        // O_RETURN 설정
        res.O_RETURN = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = 'SUCCESS';
        res.O_RETURN.MESSAGE = 'Order successfully created';

        Test.stopTest();
    }
}