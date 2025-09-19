@isTest
public with sharing class IF_ERP_Opty_DeviceManager_Test {
    private static String className = 'IF_ERP_Opty_DeviceManager';

    public IF_ERP_Opty_DeviceManager_Test() {}

/* Mock Classes
    */
    public class IF_OPTY_001_HttpMock implements HttpCalloutMock {
        public IF_OPTY_001_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Data found."},"T_ZCRMS0001":[],"T_ZCRMS0002":[{"EMPNO_RD5":"I0186212","EMPNO_RD4":"I0105123","EMPNO_RD3":"I0176455","EMPNO_RD2":"I0213811","EMPNO_RD1":"I0213283","EPMAIL_RDC":"","EPMAIL_RDB":"","EPMAIL_RDA":"","EPMAIL_RD8":"ckjeong@doosanmt.com","EPMAIL_RD7":"kjbkjb@doosanmt.com","EPMAIL_RD6":"chyoo@doosanmt.com","EPMAIL_RD5":"donggwon.kim@doosanmt.com","EPMAIL_RD4":"soohyeong.lee@doosanmt.com","EPMAIL_RD3":"sangmoon.ryu@doosanmt.com","EPMAIL_RD2":"hyunmin.choi@doosanmt.com","EPMAIL_RD1":"chang.jegal@doosanmt.com","DEPNM_RDC":"","DEPNM_RDB":"","DEPNM_RDA":"","EMPNM_RDC":"","EMPNM_RDB":"","EMPNM_RDA":"","DEPNM_RD8":"HMC/대형기PART","DEPNM_RD7":"표준PART","DEPNM_RD6":"전자생산기술팀","DEPNM_RD5":"MC개발2팀","DEPNM_RD4":"양산제어부문","DEPNM_RD3":"MC제품개발부문","EMPNM_RD8":"정찬권","DEPNM_RD2":"HMC/대형기PART","DEPNM_RD1":"HMC양산PART","EMPNM_RD7":"김종봉","EMPNM_RD6":"유충환","EMPNM_RD5":"김동권","EMPNM_RD4":"이수형","EMPNM_RD3":"류상문","EMPNM_RD2":"최현민","MAKTX":"HP 4000 II","EMPNM_RD1":"제갈창","WERKS":"1140","DEPHD_RDC":"","DEPHD_RDB":"","DEPHD_RDA":"","DEPHD_RD8":"박용환","DEPHD_RD7":"","DEPHD_RD6":"양해용","EMPNO_RDC":"","DEPHD_RD5":"김동권","EMPNO_RDB":"","DEPHD_RD4":"성환민","EMPNO_RDA":"","DEPHD_RD3":"류상문","DEPHD_RD2":"박용환","DEPHD_RD1":"","SATNR":"MH0004","EMPNO_RD8":"I0207794","EMPNO_RD7":"I0207189","EMPNO_RD6":"I0207574"},{"EMPNO_RD5":"I0186212","EMPNO_RD4":"I0105123","EMPNO_RD3":"I0176455","EMPNO_RD2":"I0213811","EMPNO_RD1":"I0213283","EPMAIL_RDC":"","EPMAIL_RDB":"","EPMAIL_RDA":"","EPMAIL_RD8":"","EPMAIL_RD7":"chang.jegal@doosanmt.com","EPMAIL_RD6":"chyoo@doosanmt.com","EPMAIL_RD5":"donggwon.kim@doosanmt.com","EPMAIL_RD4":"soohyeong.lee@doosanmt.com","EPMAIL_RD3":"sangmoon.ryu@doosanmt.com","EPMAIL_RD2":"hyunmin.choi@doosanmt.com","EPMAIL_RD1":"chang.jegal@doosanmt.com","DEPNM_RDC":"","DEPNM_RDB":"","DEPNM_RDA":"","EMPNM_RDC":"","EMPNM_RDB":"","EMPNM_RDA":"","DEPNM_RD8":"","DEPNM_RD7":"HMC양산PART","DEPNM_RD6":"전자생산기술팀","DEPNM_RD5":"MC개발2팀","DEPNM_RD4":"양산제어부문","DEPNM_RD3":"MC제품개발부문","EMPNM_RD8":"","DEPNM_RD2":"HMC/대형기PART","DEPNM_RD1":"HMC양산PART","EMPNM_RD7":"제갈창","EMPNM_RD6":"유충환","EMPNM_RD5":"김동권","EMPNM_RD4":"이수형","EMPNM_RD3":"류상문","EMPNM_RD2":"최현민","MAKTX":"HP 4000 II","EMPNM_RD1":"제갈창","WERKS":"1141","DEPHD_RDC":"","DEPHD_RDB":"","DEPHD_RDA":"","DEPHD_RD8":"","DEPHD_RD7":"","DEPHD_RD6":"양해용","EMPNO_RDC":"","DEPHD_RD5":"김동권","EMPNO_RDB":"","DEPHD_RD4":"성환민","EMPNO_RDA":"","DEPHD_RD3":"류상문","DEPHD_RD2":"박용환","DEPHD_RD1":"","SATNR":"MH0004","EMPNO_RD8":"","EMPNO_RD7":"I0213283","EMPNO_RD6":"I0207574"},{"EMPNO_RD5":"I0198190","EMPNO_RD4":"I0212618","EMPNO_RD3":"I0183956","EMPNO_RD2":"I0213811","EMPNO_RD1":"I0198190","EPMAIL_RDC":"","EPMAIL_RDB":"","EPMAIL_RDA":"","EPMAIL_RD8":"jonghui.kim@doosanmt.com","EPMAIL_RD7":"","EPMAIL_RD6":"yonghwan.park@doosanmt.com","EPMAIL_RD5":"gilho.son@doosanmt.com","EPMAIL_RD4":"yonghwan.park@doosanmt.com","EPMAIL_RD3":"jaewon.sohn@doosanmt.com","EPMAIL_RD2":"hyunmin.choi@doosanmt.com","EPMAIL_RD1":"gilho.son@doosanmt.com","DEPNM_RDC":"","DEPNM_RDB":"","DEPNM_RDA":"","EMPNM_RDC":"","EMPNM_RDB":"","EMPNM_RDA":"","DEPNM_RD8":"HMC/대형기PART","DEPNM_RD7":"","DEPNM_RD6":"HMC/대형기PART","DEPNM_RD5":"HMC개발PART","DEPNM_RD4":"HMC/대형기PART","DEPNM_RD3":"5축-H PART","EMPNM_RD8":"김종희","DEPNM_RD2":"HMC/대형기PART","DEPNM_RD1":"HMC개발PART","EMPNM_RD7":"","EMPNM_RD6":"박용환","EMPNM_RD5":"손길호","EMPNM_RD4":"박용환","EMPNM_RD3":"손재원","EMPNM_RD2":"최현민","MAKTX":"HP 4000 II","EMPNM_RD1":"손길호","WERKS":"1840","DEPHD_RDC":"","DEPHD_RDB":"","DEPHD_RDA":"","DEPHD_RD8":"박용환","DEPHD_RD7":"","DEPHD_RD6":"박용환","EMPNO_RDC":"","DEPHD_RD5":"김동권","EMPNO_RDB":"","DEPHD_RD4":"박용환","EMPNO_RDA":"","DEPHD_RD3":"","DEPHD_RD2":"박용환","DEPHD_RD1":"김동권","SATNR":"MH0004","EMPNO_RD8":"I0214733","EMPNO_RD7":"","EMPNO_RD6":"I0212618"}],"T_ZCRMS0003":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
     
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_OPTY_001_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-001', className);
        
        Test.startTest();
        
        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req req = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req();

        req.I_CA_PRMD = 'PROD';
        req.I_CA_RNDD = 'RND';
        req.I_CA_MNFE = 'MFG';
        req.I_WERKS = 'Plant001';

        req.I_T_SATNR = new List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR>();
        
        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR satnr = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR();
        satnr.SIGN = 'I';
        satnr.OPTION = 'EQ';
        satnr.LOW = '1000';
        satnr.HIGH = '2000';
 
        req.I_T_SATNR.add(satnr);

        IF_ERP_Opty_DeviceManager instance = new IF_ERP_Opty_DeviceManager();
        instance.IF_OPTY_001(req);

        // 응답 객체 생성
        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res res = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res();
        
        // O_RETURN 데이터 설정
        res.O_RETURN = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '0000';
        res.O_RETURN.MESSAGE = 'Success';

        // T_ZCRMS0001 리스트 초기화 및 데이터 추가
        res.T_ZCRMS0001 = new List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0001>();
        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0001 item1 = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0001();
        item1.WERKS = 'Plant001';
        item1.SATNR = 'MAT001';
        item1.MAKTX = 'Material Description';
        item1.VERID = 'V001';
        item1.TEXT1 = 'Version Text';
        item1.UNAME = 'User1';
        item1.EMP_NAME = 'Employee1';
        item1.BLOCK = 'N';
        res.T_ZCRMS0001.add(item1);

        // T_ZCRMS0002 리스트 초기화 및 모든 필드 포함하여 데이터 추가
        res.T_ZCRMS0002 = new List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0002>();
        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0002 item2 = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0002();
        item2.WERKS = 'Plant002';
        item2.SATNR = 'MAT002';
        item2.MAKTX = 'Another Material';

        item2.EMPNO_RD1 = 'EMP001';
        item2.EMPNM_RD1 = 'John Doe';
        item2.EPMAIL_RD1 = 'john.doe@example.com';
        item2.DEPNM_RD1 = 'Sales';
        item2.DEPHD_RD1 = 'Manager1';

        item2.EMPNO_RD2 = 'EMP002';
        item2.EMPNM_RD2 = 'Jane Doe';
        item2.EPMAIL_RD2 = 'jane.doe@example.com';
        item2.DEPNM_RD2 = 'HR';
        item2.DEPHD_RD2 = 'Manager2';

        item2.EMPNO_RD3 = 'EMP003';
        item2.EMPNM_RD3 = 'Alice';
        item2.EPMAIL_RD3 = 'alice@example.com';
        item2.DEPNM_RD3 = 'Finance';
        item2.DEPHD_RD3 = 'Manager3';

        item2.EMPNO_RD4 = 'EMP004';
        item2.EMPNM_RD4 = 'Bob';
        item2.EPMAIL_RD4 = 'bob@example.com';
        item2.DEPNM_RD4 = 'Marketing';
        item2.DEPHD_RD4 = 'Manager4';

        item2.EMPNO_RD5 = 'EMP005';
        item2.EMPNM_RD5 = 'Charlie';
        item2.EPMAIL_RD5 = 'charlie@example.com';
        item2.DEPNM_RD5 = 'IT';
        item2.DEPHD_RD5 = 'Manager5';

        item2.EMPNO_RD6 = 'EMP006';
        item2.EMPNM_RD6 = 'Daniel';
        item2.EPMAIL_RD6 = 'daniel@example.com';
        item2.DEPNM_RD6 = 'Operations';
        item2.DEPHD_RD6 = 'Manager6';

        item2.EMPNO_RD7 = 'EMP007';
        item2.EMPNM_RD7 = 'Eve';
        item2.EPMAIL_RD7 = 'eve@example.com';
        item2.DEPNM_RD7 = 'R&D';
        item2.DEPHD_RD7 = 'Manager7';

        item2.EMPNO_RD8 = 'EMP008';
        item2.EMPNM_RD8 = 'Frank';
        item2.EPMAIL_RD8 = 'frank@example.com';
        item2.DEPNM_RD8 = 'Logistics';
        item2.DEPHD_RD8 = 'Manager8';

        item2.EMPNO_RDA = 'EMP009';
        item2.EMPNM_RDA = 'Grace';
        item2.EPMAIL_RDA = 'grace@example.com';
        item2.DEPNM_RDA = 'Support';
        item2.DEPHD_RDA = 'Manager9';

        item2.EMPNO_RDB = 'EMP010';
        item2.EMPNM_RDB = 'Henry';
        item2.EPMAIL_RDB = 'henry@example.com';
        item2.DEPNM_RDB = 'Legal';
        item2.DEPHD_RDB = 'Manager10';

        item2.EMPNO_RDC = 'EMP011';
        item2.EMPNM_RDC = 'Isabelle';
        item2.EPMAIL_RDC = 'isabelle@example.com';
        item2.DEPNM_RDC = 'Compliance';
        item2.DEPHD_RDC = 'Manager11';

        res.T_ZCRMS0002.add(item2);

        // T_ZCRMS0003 리스트 초기화 및 데이터 추가
        res.T_ZCRMS0003 = new List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0003>();
        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0003 item3 = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0003();
        item3.WERKS = 'Plant003';
        item3.SATNR = 'MAT003';
        item3.MAKTX = 'Third Material';
        item3.STLAN = 'BOM001';
        item3.MFGNM = 'Manufacturer1';
        item3.EMP_NAME = 'Alice';
        item3.MFGNM2 = 'Manufacturer2';
        item3.EMP_NAME2 = 'Bob';
        item3.MFGNM3 = 'Manufacturer3';
        item3.EMP_NAME3 = 'Charlie';
        res.T_ZCRMS0003.add(item3);
        
        Test.stopTest();
    }
}