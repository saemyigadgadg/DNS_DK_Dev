@isTest
public with sharing class IF_ERP_Receipt_Test {
    private static String className = 'IF_ERP_Receipt';

    public IF_ERP_Receipt_Test() {}

/* Mock Classes
    */
    public class IF_CSPLUS_008_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_008_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"3 Records Found."},"T_O_LIST":[{"DAYYN":"N","QMSEQ":"0010","QMNUM":"000302381987","MENGE":"1","MATNR":"102501-00099K","DAREG":"0000-00-00","UAREG":"00:00:00"},{"DAYYN":"Y","QMSEQ":"0020","QMNUM":"000302381987","MENGE":"1","MATNR":"102304-00054A","DAREG":"2025-01-23","UAREG":"14:29:00"},{"DAYYN":"N","QMSEQ":"0030","QMNUM":"000302381987","MENGE":"1","MATNR":"102501-00099K","DAREG":"0000-00-00","UAREG":"00:00:00"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_008_List_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_008_List_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '<BODYbgcolor=#dddddd><TABLEbgcolor=#ddddddborder=1><TR><TDvalign="top"><B>Output_JSON</B></TD><TD>{&quot;O_RETURN&quot;:{&quot;TYPE&quot;:&quot;S&quot;,&quot;CODE&quot;:&quot;&quot;,&quot;MESSAGE&quot;:&quot;1RecordsFound.&quot;},&quot;T_O_LIST&quot;:[{&quot;DAYYN&quot;:&quot;N&quot;,&quot;QMSEQ&quot;:&quot;0010&quot;,&quot;QMNUM&quot;:&quot;000302382698&quot;,&quot;MENGE&quot;:&quot;1&quot;,&quot;MATNR&quot;:&quot;R18181&quot;,&quot;DAREG&quot;:&quot;0000-00-00&quot;,&quot;UAREG&quot;:&quot;00:00:00&quot;}]}</TD></TR></TABLE></BODY>';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_025_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_025_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"E","CODE":"","MESSAGE":"No data found ! [ZCS05001]"},"T_O_LIST":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_032_CaseOneIF_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_032_CaseOneIF_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"저장 완료."}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_032_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_032_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '<BODYbgcolor=#dddddd><TABLEbgcolor=#ddddddborder=1><TR><TDvalign="top"><B>Output_JSON</B></TD><TD>{&quot;O_RETURN&quot;:{&quot;TYPE&quot;:&quot;S&quot;,&quot;CODE&quot;:&quot;&quot;,&quot;MESSAGE&quot;:&quot;저장완료.&quot;}}</TD></TR></TABLE></BODY>';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_033_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_033_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"2 Records Found."},"T_O_LIST":[{"QMSEQ":"0010","RETURN_YN":"N","VBELN":"1000531316","RSPOS":"0000","VENDOR":"","MAKTX":"GLASS,SAFETY;(DOOR FRONT)","RSNUM":"0000000000","MATNR":"C42176083B","SUPPLY_TP":"L","SLTD":"13","MFLAG":"X","SPIND":"","SOLDTO":"0001244842","MENGE":"1","NETWR":"    65,428","NAME1":"","QMNUM":"000302382160","MATNR_TXT":"확정","MEINS":"EA","PLIFZ":"25","VSBED":"99"},{"QMSEQ":"0020","RETURN_YN":"Y","VBELN":"1000531326","RSPOS":"0000","VENDOR":"","MAKTX":"DRIVE,SERVO;TURRET_ATC","RSNUM":"0000000000","MATNR":"300419-00035B","SUPPLY_TP":"L","SLTD":"24","MFLAG":"X","SPIND":"","SOLDTO":"0001244842","MENGE":"1","NETWR":"   498,068","NAME1":"","QMNUM":"000302382160","MATNR_TXT":"확정","MEINS":"EA","PLIFZ":"30","VSBED":"99"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* TEST CODE
    */
    @IsTest
    static void IF_CSPLUS_008_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-008', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req();
        
        // 기본 정보 설정
        req.I_ORDER_NO = 'ORD12345';

        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        instance.IF_CSPLUS_008(req);

        // 응답 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res res = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res();

        // O_RETURN 설정
        res.O_RETURN = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = 'SUCCESS';
        res.O_RETURN.MESSAGE = 'Order retrieved successfully';

        // 리스트 생성 및 추가
        res.T_O_LIST = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_T_O_LIST>();
        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_T_O_LIST listItem = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_T_O_LIST();
        listItem.MATNR = 'MAT001';
        listItem.MENGE = '10';
        listItem.DAREG = '2024-02-17';
        listItem.UAREG = 'USER001';
        listItem.DAYYN = 'Y';
        listItem.QMNUM = 'QM12345';
        listItem.QMSEQ = '1';
        res.T_O_LIST.add(listItem);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_008_CaseList_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-008', className, 'List');
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req();
        
        // 기본 정보 설정
        req.I_ORDER_NO = 'ORD12345';

        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        instance.IF_CSPLUS_008(new List<IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req>{req});

        // 응답 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res res = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res();

        // O_RETURN 설정
        res.O_RETURN = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = 'SUCCESS';
        res.O_RETURN.MESSAGE = 'Order retrieved successfully';

        // 리스트 생성 및 추가
        res.T_O_LIST = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_T_O_LIST>();
        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_T_O_LIST listItem = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_T_O_LIST();
        listItem.MATNR = 'MAT001';
        listItem.MENGE = '10';
        listItem.DAREG = '2024-02-17';
        listItem.UAREG = 'USER001';
        listItem.DAYYN = 'Y';
        listItem.QMNUM = 'QM12345';
        listItem.QMSEQ = '1';
        res.T_O_LIST.add(listItem);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_025_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-025', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_025_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_025_Req();
        
        // 기본 정보 설정
        req.FR_RECV_DT = '2024-02-01';
        req.TO_RECV_DT = '2024-02-17';
        req.I_STATUS = 'Open';
        req.I_AUFNR = 'ORD56789';
        req.I_OF_CC_DP = 'CC001';
        req.I_ARBPL2 = 'ARB002';

        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        instance.IF_CSPLUS_025(req);

        // 응답 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res res = new IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res();

        // O_RETURN 설정
        res.O_RETURN = new IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = 'SUCCESS';
        res.O_RETURN.MESSAGE = 'Orders retrieved successfully';

        // 리스트 생성 및 추가
        res.T_O_LIST = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res_T_O_LIST>();
        IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res_T_O_LIST listItem = new IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res_T_O_LIST();
        listItem.AUFNR = 'ORD56789';
        listItem.QMNAM = 'John Doe';
        listItem.NAME2 = 'Jane Doe';
        listItem.TYPBZ = 'Repair';
        listItem.SERNR = 'SN123456';
        listItem.RECV_DT = '2024-02-15';
        listItem.ARBPL = 'Workshop A';
        listItem.ENAME = 'Technician A';
        listItem.NC_UNIT = 'Unit-123';
        listItem.INBDT = '2024-02-14';
        listItem.MNCOD_TXT = 'Machine Error';
        listItem.MATXT = 'Engine Component';
        listItem.PARNR = 'Customer001';
        listItem.WARRANT_BG = '2023-02-01';
        listItem.KTEXT = 'Repair Request';
        listItem.AGENT = 'AGT001';
        listItem.AGENT_NAME = 'Service Agent A';
        listItem.ENAME2 = 'Technician B';
        listItem.PERNR = 'EMP9876';
        listItem.E_WC = 'Workshop C';
        listItem.E_MAINWC = 'Main Workshop';
        listItem.PRETD2 = 'Pending';
        listItem.MATNR_TXT = 'Spare Part X';
        listItem.ARBPL2 = 'Assembly Line 2';
        listItem.QDATU = '2024-02-16';
        
        res.T_O_LIST.add(listItem);

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_032_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-032', className, 'CaseOneIF');
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req();
        
        // 기본 정보 설정
        req.I_AUFNR = 'ORD12345';
        req.I_IPLBM = 'IPLBM56789';

        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        instance.IF_CSPLUS_032(req);

        // 응답 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res res = new IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res();

        // O_RETURN 설정
        res.O_RETURN = new IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = 'SUCCESS';
        res.O_RETURN.MESSAGE = 'Order processed successfully';

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_032_CaseList_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-032', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req();
        
        // 기본 정보 설정
        req.I_AUFNR = 'ORD12345';
        req.I_IPLBM = 'IPLBM56789';

        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        instance.IF_CSPLUS_032(new List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req>{req});

        // 응답 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res res = new IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res();

        // O_RETURN 설정
        res.O_RETURN = new IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = 'SUCCESS';
        res.O_RETURN.MESSAGE = 'Order processed successfully';

        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_033_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-033', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req();
        req.T_I_AUFNR = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR>();

        // 요청 리스트 추가
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR reqItem = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR();
        reqItem.SIGN = 'I';
        reqItem.OPTION = 'EQ';
        reqItem.LOW = 'ORD12345';
        reqItem.HIGH = 'ORD67890';
        req.T_I_AUFNR.add(reqItem);

        // 응답 객체 생성
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res res = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res();
        res.O_RETURN = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = 'SUCCESS';
        res.O_RETURN.MESSAGE = 'Order processed successfully';

        // 응답 리스트 생성
        res.T_O_LIST = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res_T_O_LIST>();

        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res_T_O_LIST resItem = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res_T_O_LIST();
        resItem.MATNR = 'MAT12345';
        resItem.MAKTX = 'Test Material';
        resItem.MENGE = '100';
        resItem.MEINS = 'EA';
        resItem.SUPPLY_TP = 'Internal';
        resItem.VENDOR = 'VND123';
        resItem.NAME1 = 'Vendor Name';
        resItem.VSBED = 'Standard';
        resItem.MATNR_TXT = 'Test Material';
        resItem.MFLAG = 'Test Material';
        resItem.RSNUM = 'Test Material';
        resItem.RSPOS = 'Test Material';
        resItem.QMNUM = 'Test Material';
        resItem.VBELN = 'Test Material';
        resItem.NETWR = 'Test Material';
        resItem.SLTD = 'Test Material';
        resItem.PLIFZ = 'Test Material';
        resItem.SPIND = 'Test Material';
        res.T_O_LIST.add(resItem);

        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        instance.IF_CSPLUS_033(req);

        Test.stopTest();
    }
        // IF_ERP_Receipt instance = new IF_ERP_Receipt();
        // instance.IF_CSPLUS_008(req);
}