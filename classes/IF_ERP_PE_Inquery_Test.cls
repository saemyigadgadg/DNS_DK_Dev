@isTest
public with sharing class IF_ERP_PE_Inquery_Test {
    private static String className = 'IF_ERP_PE_Inquery';

    public IF_ERP_PE_Inquery_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_029_HttpMock implements HttpCalloutMock {
        public IF_PARTS_029_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_LIST":[{"RJ_REASON":"","PENUM":"5000000148","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"이메일","PERSON":"김요청","REMARK":"","DOCDT":"2025-03-06","INQUIRY":"987654","SERNR":"장비1","TYPBZ":"호기1"},{"RJ_REASON":"","PENUM":"5000000133","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"메일","PERSON":"두비즈","REMARK":"","DOCDT":"2025-03-05","INQUIRY":"654","SERNR":"호기","TYPBZ":"장비"},{"RJ_REASON":"","PENUM":"5000000122","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"이메일","PERSON":"김요청","REMARK":"","DOCDT":"2025-03-05","INQUIRY":"54321","SERNR":"호기","TYPBZ":"장비"},{"RJ_REASON":"","PENUM":"5000000118","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"","REMARK":"","DOCDT":"2025-03-05","INQUIRY":"","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000112","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"두비즈 링엔진","REMARK":"","DOCDT":"2025-03-04","INQUIRY":"54674","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000111","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"두비즈 링엔진","REMARK":"","DOCDT":"2025-03-04","INQUIRY":"54674","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000110","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"두비즈 링엔진","REMARK":"","DOCDT":"2025-03-04","INQUIRY":"54674","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000106","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"request@request.com","PERSON":"김요청","REMARK":"","DOCDT":"2025-03-04","INQUIRY":"file test","SERNR":"1010호","TYPBZ":"장비 21호"},{"RJ_REASON":"","PENUM":"5000000105","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"request@request.com","PERSON":"김요청","REMARK":"","DOCDT":"2025-03-04","INQUIRY":"file test","SERNR":"1010호","TYPBZ":"장비 21호"},{"RJ_REASON":"","PENUM":"5000000103","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"2","PERSON":"1","REMARK":"","DOCDT":"2025-03-04","INQUIRY":"생성 인터페이스","SERNR":"4","TYPBZ":"3"},{"RJ_REASON":"","PENUM":"5000000102","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"3","PERSON":"2","REMARK":"","DOCDT":"2025-03-04","INQUIRY":"1","SERNR":"5","TYPBZ":"4"},{"RJ_REASON":"","PENUM":"5000000091","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"","REMARK":"","DOCDT":"2025-02-27","INQUIRY":"잘못된 품번","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000090","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"","REMARK":"","DOCDT":"2025-02-27","INQUIRY":"","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000089","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"","REMARK":"","DOCDT":"2025-02-27","INQUIRY":"","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000087","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"","REMARK":"","DOCDT":"2025-02-27","INQUIRY":"","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000086","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"","PERSON":"","REMARK":"","DOCDT":"2025-02-27","INQUIRY":"중복 생성","SERNR":"","TYPBZ":""},{"RJ_REASON":"","PENUM":"5000000085","ATTACH":"","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"qwer@qwer.com","PERSON":"qwer","REMARK":"","DOCDT":"2025-02-27","INQUIRY":"qwerqwer","SERNR":"qwer","TYPBZ":"qwer"},{"RJ_REASON":"","PENUM":"5000000124","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":" JINGI.KIM@DNCOMPANY.COM","PERSON":" 홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":" 장비번호입력2","TYPBZ":" 장비명입력2"},{"RJ_REASON":"","PENUM":"5000000113","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":" JINGI.KIM@DNCOMPANY.COM","PERSON":" 홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":" 장비번호입력2","TYPBZ":" 장비명입력2"},{"RJ_REASON":"","PENUM":"5000000094","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":" JINGI.KIM@DNCOMPANY.COM","PERSON":" 홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":" 장비번호입력2","TYPBZ":" 장비명입력2"},{"RJ_REASON":"","PENUM":"5000000083","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":" JINGI.KIM@DNCOMPANY.COM","PERSON":" 홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":" 장비번호입력2","TYPBZ":" 장비명입력2"},{"RJ_REASON":"","PENUM":"5000000082","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"jingi.kim@dncompany.com","PERSON":"홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":"장비번호입력2","TYPBZ":"장비명입력2"},{"RJ_REASON":"","PENUM":"5000000081","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":" JINGI.KIM@DNCOMPANY.COM","PERSON":" 홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":" 장비번호입력2","TYPBZ":" 장비명입력2"},{"RJ_REASON":"","PENUM":"5000000080","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":" JINGI.KIM@DNCOMPANY.COM","PERSON":" 홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":" 장비번호입력2","TYPBZ":" 장비명입력2"},{"RJ_REASON":"","PENUM":"5000000079","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"jingi.kim@dncompany.com","PERSON":"홍길동","REMARK":"","DOCDT":"2025-02-19","INQUIRY":"","SERNR":"장비번호입력2","TYPBZ":"장비명입력2"},{"RJ_REASON":"","PENUM":"5000000078","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"jingi.kim@dncompany.com","PERSON":"홍길동","REMARK":"","DOCDT":"2025-02-18","INQUIRY":"","SERNR":"장비번호입력","TYPBZ":"장비명입력"},{"RJ_REASON":"","PENUM":"5000000077","ATTACH":"X","STAT":"Q","STAT_TXT":"In Progress","EMAIL":"jingi.kim@dncompany.com","PERSON":"홍길동","REMARK":"","DOCDT":"2025-02-18","INQUIRY":"","SERNR":"장비번호입력","TYPBZ":"장비명입력"}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""},"O_LINES":"27"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    public class IF_PARTS_030_HttpMock implements HttpCalloutMock {
        public IF_PARTS_030_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"ET_SIMUL":[{"SPRICE":"51,500","MAKTX":"ADJUSTER","MATNR":"100101-00065A","PEITEM":"0010","WAERS":"KRW"}],"ET_SAP":[{"SPRICE":"515.00","MAKTX":"ADJUSTER","MATNR":"100101-00065A","PEITEM":"0010","WAERS":"KRW"}],"ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    public class IF_PARTS_031_HttpMock implements HttpCalloutMock {
        public IF_PARTS_031_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_PENUM":"5000000174","ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"PE Inquiry 5000000174 is created."}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }    

    public class IF_PARTS_032_HttpMock implements HttpCalloutMock {
        public IF_PARTS_032_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"ES_HD":{"PENUM":"5000000174","INQUIRY":"333p","KUNNR":"0001057644","NAME1":"링엔지니어링 부품 대리점","PERSON":"","EMAIL":"","DOCDT":"2025-03-11","TYPBZ":"","SERNR":"","REMARK":"","RJ_REASON":"","STAT":"Q"},"ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""},"ET_ATTACH":[{"FILE_NAME":"(반출승인) PDF 테스트 1.html","FILE_NO":"1"}],"ET_ITEM":[{"SPRICE":"51500.00","MAKTX":"ADJUSTER","MATNR":"100101-00065A","COMMNT":"","PEITEM":"10","NPRICE":"0.00","MPRICE":"60000.00","WAERS":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }   
    public class IF_PARTS_033_HttpMock implements HttpCalloutMock {
        public IF_PARTS_033_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"Input":{"I_USERINFO":{"WERKS":"10","VTWEG":"","VKORG":"1846","SPART":"40","RNAME":"","PARNR":"","LIFNR":"","LGORT":"","LAND1":"","KUNNR":"1057644","KUNN2":"","HIER":"","ENAME":"","DF_CHK":"","CO_CHK":"","BNAME":"P_MTDO","ARBPL":""},"I_PENUM":"5000000079","I_FILE_NO":"1"}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }    
/* Test Method
    */
    @IsTest
    static void IF_PARTS_029_TEST(){
        InterfaceCommonUtil.setInterface('IF-PARTS-029', className);
        Test.startTest();
        IF_ERP_PE_Inquery method = new IF_ERP_PE_Inquery();

        IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req_I_USERINFO I_USERINFO = new IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req_I_USERINFO(); 
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

        IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req request  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req();
        request.I_PENUM = '';
        request.I_INQUIRY = '';
        request.I_DOCDT_FR = '';
        request.I_DOCDT_TO = '';
        request.I_MATNR = '';
        request.I_STAT = '';
        request.I_PAGENO = '';
        request.I_ROWNO = '';        
        request.I_USERINFO = I_USERINFO;

        IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_O_RETURN O_RETURN  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_O_RETURN();
        O_RETURN.TYPE = '';
        O_RETURN.CODE = '';
        O_RETURN.MESSAGE = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_T_LIST T_LIST = new IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_T_LIST();
        T_LIST.PENUM = '';
        T_LIST.INQUIRY = '';
        T_LIST.STAT = '';
        T_LIST.STAT_TXT = '';
        T_LIST.DOCDT = '';
        T_LIST.PERSON = '';
        T_LIST.EMAIL = '';
        T_LIST.TYPBZ = '';
        T_LIST.SERNR = '';
        T_LIST.REMARK = '';
        T_LIST.RJ_REASON = '';
        T_LIST.ATTACH = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res response = new IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res();
        response.O_LINES = '';
        response.O_RETURN = O_RETURN;
        response.T_LIST = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_T_LIST>{T_LIST};        
        
        method.IF_PARTS_029(request);
        Test.stopTest(); 
    }

    @IsTest
    static void IF_PARTS_030_TEST(){
        InterfaceCommonUtil.setInterface('IF-PARTS-030', className);
        Test.startTest();
        IF_ERP_PE_Inquery method = new IF_ERP_PE_Inquery();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req request  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_I_USERINFO I_USERINFO = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_I_USERINFO();
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

        IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_IT_MAT IT_MAT = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_IT_MAT();
        IT_MAT.PEITEM = '';
        IT_MAT.MATNR = '';
        IT_MAT.MAKTX = '';
        IT_MAT.WAERS = '';
        IT_MAT.SPRICE = '';
        
        request.I_USERINFO = I_USERINFO;
        request.IT_MAT = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_IT_MAT>{IT_MAT};

        IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res response = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res();

        IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ES_RETURN ES_RETURN = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ES_RETURN();
        ES_RETURN.TYPE = '';
        ES_RETURN.CODE = '';
        ES_RETURN.MESSAGE = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SIMUL  ET_SIMUL  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SIMUL();
        ET_SIMUL.PEITEM = '';
        ET_SIMUL.MATNR = '';
        ET_SIMUL.MAKTX = '';
        ET_SIMUL.WAERS = '';
        ET_SIMUL.SPRICE = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SAP    ET_SAP    = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SAP();
        ET_SAP.PEITEM = '';
        ET_SAP.MATNR = '';
        ET_SAP.MAKTX = '';
        ET_SAP.WAERS = '';
        ET_SAP.SPRICE = '';

        response.ES_RETURN = ES_RETURN;
        response.ET_SIMUL  = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SIMUL>{ET_SIMUL};
        response.ET_SAP    = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SAP>{ET_SAP};

        method.IF_PARTS_030(request);
        Test.stopTest(); 
    }

    @IsTest
    static void IF_PARTS_031_TEST(){
        InterfaceCommonUtil.setInterface('IF-PARTS-031', className);
        Test.startTest();
        IF_ERP_PE_Inquery method = new IF_ERP_PE_Inquery();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req request  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_I_USERINFO IS_USERINFO = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_I_USERINFO();
        IS_USERINFO.BNAME = '';
        IS_USERINFO.RNAME = '';
        IS_USERINFO.HIER = '';
        IS_USERINFO.KUNNR = '';
        IS_USERINFO.LIFNR = '';
        IS_USERINFO.VKORG = '';
        IS_USERINFO.VTWEG = '';
        IS_USERINFO.SPART = '';
        IS_USERINFO.WERKS = '';
        IS_USERINFO.ARBPL = '';
        IS_USERINFO.PARNR = '';
        IS_USERINFO.ENAME = '';
        IS_USERINFO.KUNN2 = '';
        IS_USERINFO.LAND1 = '';
        IS_USERINFO.LGORT = '';
        IS_USERINFO.DF_CHK = '';
        IS_USERINFO.CO_CHK = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IS_HD IS_HD = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IS_HD();
        IS_HD.PENUM = '';
        IS_HD.INQUIRY = '';
        IS_HD.KUNNR = '';
        IS_HD.NAME1 = '';
        IS_HD.PERSON = '';
        IS_HD.EMAIL = '';
        IS_HD.DOCDT = '';
        IS_HD.TYPBZ = '';
        IS_HD.SERNR = '';
        IS_HD.REMARK = '';
        IS_HD.RJ_REASON = '';
        IS_HD.STAT = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ITEM IT_ITEM = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ITEM();
        IT_ITEM.PEITEM = '';
        IT_ITEM.MATNR = '';
        IT_ITEM.MAKTX = '';
        IT_ITEM.COMMNT = '';
        IT_ITEM.WAERS = '';
        IT_ITEM.MPRICE = '';
        IT_ITEM.SPRICE = '';
        IT_ITEM.NPRICE = '';
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH IT_ATTACH = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH();
        IT_ATTACH.FILE_NO = '';
        IT_ATTACH.FILE_SEQ = '';
        IT_ATTACH.FILE_NAME = '';
        IT_ATTACH.CLUSTR = '';
        IT_ATTACH.CLUSTD = '';
        request.IS_USERINFO = IS_USERINFO; 
        request.IS_HD = IS_HD; 
        request.IT_ITEM = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ITEM>{IT_ITEM}; 
        request.IT_ATTACH = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH>{IT_ATTACH}; 

        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res response = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res_ES_RETURN ES_RETURN = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res_ES_RETURN();
        ES_RETURN.TYPE = '';
        ES_RETURN.CODE = '';
        ES_RETURN.MESSAGE = '';        
        response.E_PENUM = '';
        response.ES_RETURN = ES_RETURN;

        method.IF_PARTS_031(request);
        Test.stopTest(); 
    }

    @IsTest
    static void IF_PARTS_032_TEST(){
        InterfaceCommonUtil.setInterface('IF-PARTS-032', className);
        Test.startTest();
        IF_ERP_PE_Inquery method = new IF_ERP_PE_Inquery();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req request  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req_I_USERINFO I_USERINFO  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req_I_USERINFO();
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

        request.I_PENUM = '';
        request.I_USERINFO = I_USERINFO;

        IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res response = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ES_RETURN ES_RETURN = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ES_RETURN();
        ES_RETURN.TYPE = '';
        ES_RETURN.CODE = '';
        ES_RETURN.MESSAGE = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ES_HD     ES_HD = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ES_HD();
        ES_HD.PENUM = '';
        ES_HD.INQUIRY = '';
        ES_HD.KUNNR = '';
        ES_HD.NAME1 = '';
        ES_HD.PERSON = '';
        ES_HD.EMAIL = '';
        ES_HD.DOCDT = '';
        ES_HD.TYPBZ = '';
        ES_HD.SERNR = '';
        ES_HD.REMARK = '';
        ES_HD.RJ_REASON = '';
        ES_HD.STAT = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ITEM   ET_ITEM = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ITEM();
        ET_ITEM.PEITEM = '';
        ET_ITEM.MATNR = '';
        ET_ITEM.MAKTX = '';
        ET_ITEM.COMMNT = '';
        ET_ITEM.WAERS = '';
        ET_ITEM.MPRICE = '';
        ET_ITEM.SPRICE = '';
        ET_ITEM.NPRICE = '';        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ATTACH ET_ATTACH = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ATTACH();
        ET_ATTACH.FILE_NO = '';
        ET_ATTACH.FILE_NAME = '';
        

        response.ES_RETURN = ES_RETURN; 
        response.ES_HD = ES_HD; 
        response.ET_ITEM = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ITEM>{ET_ITEM}; 
        response.ET_ATTACH = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ATTACH>{ET_ATTACH};         
        method.IF_PARTS_032(request);
        Test.stopTest(); 
    }

    @IsTest
    static void IF_PARTS_033_TEST(){
        InterfaceCommonUtil.setInterface('IF-PARTS-033', className);
        Test.startTest();
        IF_ERP_PE_Inquery method = new IF_ERP_PE_Inquery();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Req request  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Req();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Req_I_USERINFO I_USERINFO  = new IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Req_I_USERINFO();
        I_USERINFO.BNAME  = '';
        I_USERINFO.RNAME  = '';
        I_USERINFO.HIER   = '';
        I_USERINFO.KUNNR  = '';
        I_USERINFO.LIFNR  = '';
        I_USERINFO.VKORG  = '';
        I_USERINFO.VTWEG  = '';
        I_USERINFO.SPART  = '';
        I_USERINFO.WERKS  = '';
        I_USERINFO.ARBPL  = '';
        I_USERINFO.PARNR  = '';
        I_USERINFO.ENAME  = '';
        I_USERINFO.KUNN2  = '';
        I_USERINFO.LAND1  = '';
        I_USERINFO.LGORT  = '';
        I_USERINFO.DF_CHK = '';
        I_USERINFO.CO_CHK = '';        
        request.I_PENUM   = '';
        request.I_FILE_NO = '';       
        request.I_USERINFO = I_USERINFO; 
        IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res response = new IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res_ES_RETURN ES_RETURN = new IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res_ES_RETURN();
        ES_RETURN.TYPE = '';
        ES_RETURN.CODE = '';
        ES_RETURN.MESSAGE = '';
        IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res_ET_ATTACH ET_ATTACH = new IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res_ET_ATTACH();
        ET_ATTACH.FILE_NO = '';
        ET_ATTACH.FILE_SEQ = '';
        ET_ATTACH.FILE_NAME = '';
        ET_ATTACH.CLUSTR = '';
        ET_ATTACH.CLUSTD = '';

        response.ES_RETURN = ES_RETURN;
        response.ET_ATTACH = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res_ET_ATTACH>{ET_ATTACH};
        
        method.IF_PARTS_033(request);
        Test.stopTest(); 
    }
}