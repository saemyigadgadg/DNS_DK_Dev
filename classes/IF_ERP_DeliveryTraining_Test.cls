@isTest
public with sharing class IF_ERP_DeliveryTraining_Test {
    private static String className = 'IF_ERP_DeliveryTraining';

    public IF_ERP_DeliveryTraining_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_025_HttpMock implements HttpCalloutMock {
        public IF_PARTS_025_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully saved ![ZCS02081]"},"O_UPD_MSG":"","O_DEL_MSG":"","T_DOC2":[],"T_INSPEC":[],"T_DEL":[],"T_DEL2":[],"T_TMP":[{"FILENAME":"up.txt","FILE_SIZE":"","DESC":"up.txt","LINE":"[B@559f7330","EVISEQX":"01"}],"T_MOTION":[{"AUSBS":"2025-02-06","HOL_CHK":"","CHK_FLAG":"","CONF":"","GRUND":"","ISDZ":"16:30:00","ZFLAG":"","RMZHL":"00000000","ISDD":"2025-02-06","TEMPHR":"","AENAM":"","MANDT":"","MAINHR":"","AEDAT":"0000-00-00","AUZTB":"23:15:00","PERNR":"00006462","OPTCHK5":"","OPTCHK4":"","OPTCHK3":"","OPTCHK2":"","OPTCHK1":"","WERKS":"184S","WORKCD":"MV","AUFNR":"403908121","AEZET":"00:00:00","ERNAM":"","SVCMAN_NAME":"null 민광식","ETC_HR":"0.0","OT_CHK":"","LTXA1":"test","ERDAT":"0000-00-00","ISMNW":"6.8","RUECK":"0000000000","EXRSN":"","HDAYWDV":"","ETC_TXT":"","OPTNHR5":"","OPTNHR4":"","OPTNHR3":"","OPTNHR2":"","OPTNHR1":"","SEQNO":"0000","ERZET":"00:00:00","WORKNO":"0000","ISMNW_PDK":"0.0","ISMNE":"H"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Code
    */
    @isTest
    public static void IF_PARTS_025_Test(){
        InterfaceCommonUtil.setInterface('IF-PARTS-025', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req request = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req();
        request.I_COUNSEL = 'CounselValue';
        request.I_CONF = 'ConfValue';
        request.I_IPOINT = '100';

        // I_USERINFO 객체 생성 및 값 설정
        request.I_USERINFO = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TestUser';
        request.I_USERINFO.RNAME = 'RoleName';
        request.I_USERINFO.HIER = 'Hierarchy';
        request.I_USERINFO.KUNNR = 'Customer001';
        request.I_USERINFO.LIFNR = 'Supplier001';
        request.I_USERINFO.VKORG = '1000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = '01';
        request.I_USERINFO.WERKS = 'Plant01';
        request.I_USERINFO.ARBPL = 'WorkCenter01';
        request.I_USERINFO.PARNR = 'Partner01';
        request.I_USERINFO.ENAME = 'EmployeeName';
        request.I_USERINFO.KUNN2 = 'KUNN2001';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'Location01';
        request.I_USERINFO.DF_CHK = 'X';
        request.I_USERINFO.CO_CHK = 'X';

        // I_SEL 객체 생성 및 값 설정
        request.I_SEL = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_I_SEL();
        request.I_SEL.AUFNR = 'Order001';
        request.I_SEL.KTEXT = 'OrderText';
        request.I_SEL.SYS_STATUS = 'Open';
        request.I_SEL.EQUNR = 'Equipment001';
        request.I_SEL.TYPBZ = 'TypeBZ001';
        request.I_SEL.SERNR = 'Serial001';
        request.I_SEL.INSPECTION_TP = 'Type001';
        request.I_SEL.INSPN_TP_TXT = 'Inspection Type';
        request.I_SEL.DEALER = 'Dealer001';
        request.I_SEL.DEALER_NM = 'Dealer Name';
        request.I_SEL.INBDT = '2025-01-01';
        request.I_SEL.WORKING_HR = '8';
        request.I_SEL.MDOCM = 'MDOCM001';
        request.I_SEL.MOVING_MAN = 'MovingMan01';
        request.I_SEL.MOVING_MAN_NM = 'Moving Man Name';
        request.I_SEL.RESP_MAN = 'RespMan01';
        request.I_SEL.RESP_MAN_NM = 'Responsible Man';
        request.I_SEL.INSPN_DT = '2025-01-10';
        request.I_SEL.MOVING_S_TM = '08:00';
        request.I_SEL.MOVING_E_TM = '17:00';
        request.I_SEL.MOVING_HR = '9';
        request.I_SEL.DATUM_FR = '2025-01-01';
        request.I_SEL.TIME_FR = '09:00';
        request.I_SEL.DATUM_TO = '2025-01-01';
        request.I_SEL.TIME_TO = '18:00';
        request.I_SEL.CUST_NM = 'Customer Name';
        request.I_SEL.OWNER = 'Owner Name';
        request.I_SEL.TEL_NUMBER = '1234567890';
        request.I_SEL.WORK_PLACE = 'Workplace';
        request.I_SEL.WORK_CONTENTS = 'Work Contents';
        request.I_SEL.RUECK = 'RUECK001';
        request.I_SEL.RMZHL = 'RMZHL001';
        request.I_SEL.CONF_TEXT = 'Confirmation Text';
        request.I_SEL.MOBILE = '9876543210';
        request.I_SEL.PERNR = 'PersonnelNumber';
        request.I_SEL.SVCMAN_NAME = 'Service Man';
        request.I_SEL.GENTYPE = 'GenType001';
        request.I_SEL.MOVING_DIST = '50';
        request.I_SEL.DIST_UNIT = 'KM';
        request.I_SEL.ROUND_CHK = 'X';
        request.I_SEL.HOLIDAY_CHK = 'X';
        request.I_SEL.TOT_HOURS = '8';
        request.I_SEL.LTXA1 = 'LTXA1001';
        request.I_SEL.CONTACTOR_NM = 'Contactor Name';
        request.I_SEL.CONTACTOR_TEL = '1112223333';
        request.I_SEL.ACTWAY = 'ActionWay';
        request.I_SEL.UDATE = '2025-01-02';
        request.I_SEL.UTIME = '12:00';
        request.I_SEL.NAME1 = 'Name1';
        request.I_SEL.TELF1 = '1231231234';
        request.I_SEL.WO_NAME1 = 'Work Order Name';
        request.I_SEL.WO_TELF1 = '4564564567';
        request.I_SEL.IPOINT = '150';

        // 리스트 초기화
        request.T_DOC2 = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DOC2>();
        request.T_INSPEC = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_INSPEC>();
        request.T_DEL = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL>();
        request.T_TMP = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP>();
        request.T_MOTION = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_MOTION>();
        request.T_DEL2 = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL2>();

        // 문서 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DOC2 docItem = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DOC2();
        docItem.FILENAME = 'test.pdf';
        docItem.MIMETYPE = 'application/pdf';
        docItem.FILEDATA = 'Base64EncodedData';
        docItem.DESCRIPTION = 'Test Document';
        docItem.FLAG = 'X';
        docItem.DOCNO = 'DOC001';
        request.T_DOC2.add(docItem);

        // 검사 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_INSPEC inspecItem = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_INSPEC();
        inspecItem.CK = 'X';
        inspecItem.SECTN = 'Section1';
        inspecItem.INSP_CONTENTS = 'Inspection Contents';
        inspecItem.FAULTY = 'No';
        inspecItem.RSLT = 'Pass';
        inspecItem.ENABLE = 'Yes';
        inspecItem.REQUIRE = 'Mandatory';
        inspecItem.SEQ = '1';
        inspecItem.SEQ2 = '2';
        request.T_INSPEC.add(inspecItem);

        // 삭제 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL delItem = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL();
        delItem.DOCNO = 'DOC001';
        delItem.FILENAME = 'delete.pdf';
        request.T_DEL.add(delItem);

        // 임시 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP tmpItem = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP();
        tmpItem.FILENAME = 'temp.txt';
        tmpItem.IF_DESC = 'Temporary File';
        tmpItem.EVISEQX = 'EV001';
        tmpItem.LINE = '1';
        tmpItem.FILE_SIZE = '512';
        request.T_TMP.add(tmpItem);

        // 동작 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_MOTION motionItem = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_MOTION();
        motionItem.AUFNR = 'MOTION001';
        motionItem.RUECK = 'RUECK002';
        motionItem.WORKNO = 'WORK001';
        motionItem.SEQNO = 'SEQ001';
        motionItem.PERNR = 'PER001';
        motionItem.SVCMAN_NAME = 'Service Man';
        request.T_MOTION.add(motionItem);

        // 응답 객체 생성
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res response = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res();
        response.O_DEL_MSG = 'Deletion Successful';
        response.O_UPD_MSG = 'Update Successful';

        // O_RETURN 객체 생성 및 값 설정
        response.O_RETURN = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_O_RETURN();
        response.O_RETURN.TYPE = 'Success';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Operation completed successfully';

        // 리스트 초기화
        response.T_DOC2 = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DOC2>();
        response.T_INSPEC = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_INSPEC>();
        response.T_DEL = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DEL>();
        response.T_TMP = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_TMP>();
        response.T_MOTION = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_MOTION>();
        response.T_DEL2 = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DEL2>();

        // 문서 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DOC2 docItem2 = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DOC2();
        docItem2.FILENAME = 'document.pdf';
        docItem2.MIMETYPE = 'application/pdf';
        docItem2.FILEDATA = 'Base64EncodedData';
        docItem2.DESCRIPTION = 'Document Description';
        docItem2.FLAG = 'X';
        docItem2.DOCNO = 'DOC001';
        response.T_DOC2.add(docItem2);

        // 검사 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_INSPEC inspecItemRes = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_INSPEC();
        inspecItemRes.CK = 'X';
        inspecItemRes.SECTN = 'Inspection Section';
        inspecItemRes.INSP_CONTENTS = 'Inspection Details';
        inspecItemRes.FAULTY = 'No';
        inspecItemRes.RSLT = 'Pass';
        inspecItemRes.ENABLE = 'Yes';
        inspecItemRes.REQUIRE = 'Mandatory';
        inspecItemRes.SEQ = '1';
        inspecItemRes.SEQ2 = '2';
        response.T_INSPEC.add(inspecItemRes);

        // 삭제 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DEL delItemRes = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DEL();
        delItemRes.DOCNO = 'DOC001';
        delItemRes.FILENAME = 'delete.pdf';
        response.T_DEL.add(delItemRes);

        // 임시 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_TMP tmpItemRes = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_TMP();
        tmpItemRes.FILENAME = 'temp.txt';
        tmpItemRes.IF_DESC = 'Temporary File';
        tmpItemRes.EVISEQX = 'EV001';
        tmpItemRes.LINE = '1';
        tmpItemRes.FILE_SIZE = '512';
        response.T_TMP.add(tmpItemRes);

        // 동작 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_MOTION motionItemRes = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_MOTION();
        motionItemRes.AUFNR = 'MOTION001';
        motionItemRes.RUECK = 'RUECK002';
        motionItemRes.WORKNO = 'WORK001';
        motionItemRes.SEQNO = 'SEQ001';
        motionItemRes.PERNR = 'PER001';
        motionItemRes.SVCMAN_NAME = 'Service Man';
        motionItemRes.ISDD = '2025-01-10';
        motionItemRes.ISDZ = '2025-01-11';
        motionItemRes.AUSBS = 'Break Time';
        motionItemRes.AUZTB = 'Lunch Break';
        motionItemRes.ISMNW = '8';
        motionItemRes.ISMNW_PDK = '9';
        motionItemRes.HOL_CHK = 'X';
        motionItemRes.OT_CHK = 'X';
        motionItemRes.LTXA1 = 'Work Description';
        motionItemRes.RMZHL = 'Remark001';
        motionItemRes.ISMNE = 'Yes';
        motionItemRes.ZFLAG = 'X';
        motionItemRes.TEMPHR = '2';
        motionItemRes.CHK_FLAG = 'Checked';
        motionItemRes.MAINHR = '6';
        motionItemRes.OPTNHR1 = '1';
        motionItemRes.OPTNHR2 = '1';
        motionItemRes.OPTNHR3 = '1';
        motionItemRes.OPTNHR4 = '0.5';
        motionItemRes.OPTNHR5 = '0.5';
        motionItemRes.HDAYWDV = 'Yes';
        motionItemRes.OPTCHK1 = 'Checked';
        motionItemRes.OPTCHK2 = 'Checked';
        motionItemRes.OPTCHK3 = 'Unchecked';
        motionItemRes.OPTCHK4 = 'Unchecked';
        motionItemRes.OPTCHK5 = 'Checked';
        motionItemRes.ETC_HR = '3';
        motionItemRes.ETC_TXT = 'Additional Notes';
        motionItemRes.ERDAT = '2025-01-12';
        motionItemRes.ERNAM = 'Admin';
        motionItemRes.ERZET = '12:30';
        motionItemRes.AEDAT = '2025-01-13';
        motionItemRes.AENAM = 'Modifier';
        motionItemRes.AEZET = '15:00';
        motionItemRes.WERKS = 'Factory01';
        motionItemRes.CONF = 'Confirmed';
        motionItemRes.GRUND = 'Maintenance';
        motionItemRes.WORKCD = 'WRK001';
        motionItemRes.EXRSN = 'Extra Reason';
        response.T_MOTION.add(motionItemRes);

        // 삭제 객체 추가
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DEL2 delItem2 = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res_T_DEL2();
        delItem2.DOCNO = 'DOC002';
        delItem2.FILENAME = 'delete2.pdf';
        response.T_DEL2.add(delItem2);

        IF_ERP_DeliveryTraining instance = new IF_ERP_DeliveryTraining();
        instance.IF_PARTS_025(request);

        Test.stopTest();
    }
}