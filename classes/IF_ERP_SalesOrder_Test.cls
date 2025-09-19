@isTest
public with sharing class IF_ERP_SalesOrder_Test {
    private static String className = 'IF_ERP_SalesOrder';

    public IF_ERP_SalesOrder_Test() {}

/* Mock Classes
    */
    public class IF_OPTY_033_HttpMock implements HttpCalloutMock {
        public IF_OPTY_033_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_LIST":[{"AEDAT":"0000-00-00","ZZSQ":"001","SATNR":"ML0389","BASE_CODE":"26LSYB2-F0TF-0-U11","MDLNM":"PUMA 2600LSYB II"},{"AEDAT":"0000-00-00","ZZSQ":"001","SATNR":"MV0105","BASE_CODE":"BM1530M-F31B-0-U10","MDLNM":"PUMA 2600LSYB II  123456788899"},{"AEDAT":"0000-00-00","ZZSQ":"001","SATNR":"MV0105","BASE_CODE":"BM1530M-F31P-0-U30","MDLNM":"PUMA 2600LSYB II  123456788899111110"},{"AEDAT":"0000-00-00","ZZSQ":"002","SATNR":"MV0105","BASE_CODE":"BM1530M-F31P-0-U30","MDLNM":"PUMA 2600LSYB II  123456788899111110"},{"AEDAT":"0000-00-00","ZZSQ":"001","SATNR":"MY0080","BASE_CODE":"DNM205A-F0MD-0-P09","MDLNM":"DNM 750L-II / 12K / 30 ATC"},{"AEDAT":"0000-00-00","ZZSQ":"002","SATNR":"MY0080","BASE_CODE":"DNM205A-F0MD-0-P09","MDLNM":"DNM 750L-II / 12K / 60 ATC"}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Success"}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_038_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_038_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_AUFNR":"000403907918","T_RETURN":[{"IF_SYSTEM":"","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"000","PARAMETER":"","MESSAGE":"403907918 - Success to Complete(business) and set Deletion Flag","FIELD":"","ROW":"0","TYPE":"S","ID":"","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_040_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_040_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_DATE":[{"TYPE":"E","MESSAGE":"Error occurred"}],"O_UPD_MSG":"Updated successfully","O_RETURN":{"TYPE":"S","MESSAGE":"Operation completed successfully"},"O_DEL_MSG":"Deleted successfully"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_044_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_044_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_TMP":[],"T_TEXT_S":null,"T_TEXT_P":null,"T_TEXT_C":null,"T_TEXT_A":[{"TDLINE":"This is additional text A","TDFORMAT":"TXT","CLAIM_SEQ":"1"}],"T_SIGN2":[{"TDLINE":"Signed by Jane Doe","TDFORMAT":"Signature2","CLAIM_SEQ":"2"}],"T_SIGN1":[{"TDLINE":"Signed by John Doe","TDFORMAT":"Signature1","CLAIM_SEQ":"1"}],"T_RETURN":[{"TYPE":"W","MESSAGE":"Warning Message"}],"T_PART":[{"ZZWAGRPNM":null,"ZZWAGRP":null,"ZSUPPLY":null,"WORKNO":null,"WAERS":"USD","VTWEG":null,"VTEXT":null,"VSBED":null,"VKORG":null,"VERPR":null,"UNIT_PRICE":null,"STAN_PRICE":null,"SPART":null,"SEQNO":"1","SALESPRICE":null,"RETURN_YN":null,"RETURN_TYPE_T":null,"RETURN_TYPE":null,"RETURN_TEXT":null,"RETURN_QTY":null,"RETURN_END_YN":null,"RETURN_DT":null,"RESP_FACTOR":null,"PART_RATE":null,"NFNUM2":null,"NFNUM":null,"MGANR_UE":null,"MENGE":"10","MEINS":"EA","MATNR":"Material001","MAKTX":"Material Description","LOT_NO":null,"LIFNR":null,"INVOICE_NO":null,"GWLDT":null,"FOC_FLAG":null,"FATURA":null,"ERZET":null,"ERNAM":null,"ERDAT":null,"ENTRAD":null,"DOCNUM":null,"DNET_PRICE":null,"DEPART_RATE":null,"CON_MENGE":null,"CNF_QTY":null,"CNF_NETPR":null,"CAUSE_PRT":null,"AUFNR":null,"APPNO":null,"AMOUNT":null,"AEZET":null,"AENAM":null,"AEDAT":null}],"T_OTHER":[{"WAERS":null,"VALUE":"500","UNIT":null,"TYPE":"Cost","TOT_AMT":null,"SEQNO":"1","DESCRIPTION":"Repair Cost","CATEGORY":"Warranty","AMOUNT":null}],"T_FILE":[{"LINE":"20","IF_DESC":"Report File","FILENAME":"report.csv","FILE_SIZE":"4096","EVISEQX":"E124"}],"T_DOC":[{"MIMETYPE":"application/pdf","FLAG":null,"FILENAME":"document.pdf","FILEDATA":"Base64EncodedData","DOCNO":null,"DESCRIPTION":"Technical Document"}],"T_DEL":null,"T_DATE":[{"SEQNO":"1","REP_TO_TM":null,"REP_TO_DT":null,"REP_FR_TM":"120000","REP_FR_DT":"20240220","QMNUM":"QM001","ISMNW_PDK":null,"ISMNW":null,"ISMNE":null,"AUFNR":"123456","AIR_TRIP":null}],"T_CLAIM":[{"URTXT":null,"URGRP":null,"URCOD":null,"TXTCDUR":null,"TXTCDMA":null,"TXTCDFE":null,"SYMPTOM_ADD_TXT":null,"PHENO_ADD_TXT":null,"OTGRP":"Group A","OTEIL":"Component A","MNGRP":null,"MNCOD":null,"MATXT":null,"KURZTEXT_L":"Long Description","KURZTEXT":"Short Text","FETXT":null,"FEGRP":null,"FECOD":null,"FAULT_CAUSE":null,"CODE_03":"C03","CODE_02":"B02","CODE_01":"A01","CLAIM_SEQ":"1","CAUSE_ADD_TXT":null,"BLCOD_T":null,"BLCOD":null,"ACT_ADD_TXT":null}],"O_UPD_MSG":"Update successful","O_RETURN":{"TYPE":"S","MESSAGE":"Success"},"O_ORDER":"000001","O_NOTIFICATION":"000001","O_DEL_MSG":"Deletion successful"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* TEST CODE
    */
    @IsTest
    static void IF_OPTY_033_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-033', className);
        Test.startTest();

        IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req request = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req();
        request.I_FROM  = '2025-02-01';
        request.I_TO    = '2025-03-01';

        // 응답 객체 생성 및 필드 값 설정
        IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res response = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res();
        response.O_RETURN = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_O_RETURN();
        response.T_LIST = new List<IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_T_LIST>();

        // O_RETURN 값 설정
        response.O_RETURN.TYPE = 'S';  // 성공 (Success)
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Response processed successfully';

        // T_LIST 항목 추가
        IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_T_LIST listItem = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_T_LIST();
        listItem.BASE_CODE = 'BC123';
        listItem.ZZSQ = 'SQ456';
        listItem.MDLNM = 'Model-X';
        listItem.SATNR = 'SAT789';
        listItem.AEDAT = '2024-03-12';

        // 리스트에 추가
        response.T_LIST.add(listItem);

        IF_ERP_SalesOrder instance = new IF_ERP_SalesOrder();
        instance.IF_OPTY_033(request);
        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_038_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-038', className);
        Test.startTest();

        // Request 객체 생성 및 필드 값 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Req request = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Req();
        request.I_AUFNR = 'ORD123456';

        // Response 객체 생성 및 필드 값 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res response = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res();
        response.E_AUFNR = 'ORD123456';
        response.T_RETURN = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res_T_RETURN>();

        // T_RETURN 리스트에 항목 추가
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res_T_RETURN returnItem = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res_T_RETURN();
        returnItem.TYPE = 'S';
        returnItem.ID = 'MSG001';
        returnItem.IF_NUMBER = '1001';
        returnItem.MESSAGE = 'Order successfully processed';
        returnItem.LOG_NO = 'LOG987654';
        returnItem.LOG_MSG_NO = '123';
        returnItem.MESSAGE_V1 = 'Variable1';
        returnItem.MESSAGE_V2 = 'Variable2';
        returnItem.MESSAGE_V3 = 'Variable3';
        returnItem.MESSAGE_V4 = 'Variable4';
        returnItem.PARAMETER = 'PARAM001';
        returnItem.ROW = '1';
        returnItem.FIELD = 'FIELD001';
        returnItem.IF_SYSTEM = 'SYS001';

        response.T_RETURN.add(returnItem);

        IF_ERP_SalesOrder instance = new IF_ERP_SalesOrder();
        instance.IF_CSPLUS_038(request);
        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_040_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-040', className);
        Test.startTest();

        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req request = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req();
        request.I_LANGU = 'EN';

        // I_HEADER 객체 설정
        request.I_HEADER = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_I_HEADER();
        request.I_HEADER.QMNUM = 'QM12345';
        request.I_HEADER.TYPBZ = 'Type1';
        request.I_HEADER.SERNR = 'S12345678';
        request.I_HEADER.WORKING_HR = '8';
        request.I_HEADER.ARRVAL_DT = '2024-02-17';
        request.I_HEADER.FAIL_END_DT = '2024-02-18';
        request.I_HEADER.BREAKDOWN = 'Y';
        request.I_HEADER.REF_NO = 'REF98765';
        request.I_HEADER.SHIP_TO = 'ST12345';
        request.I_HEADER.VSBED = 'VB001';
        request.I_HEADER.AUTLF = 'AUTO';
        request.I_HEADER.CARRIER = 'FedEx';
        request.I_HEADER.ACCT_NO = 'ACC001';
        request.I_HEADER.PARTS_INST_DT = '2024-02-19';

        // I_USERINFO 객체 설정
        request.I_USERINFO = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'john_doe';
        request.I_USERINFO.RNAME = 'John Doe';
        request.I_USERINFO.HIER = 'Manager';
        request.I_USERINFO.KUNNR = 'K12345';
        request.I_USERINFO.LIFNR = 'L56789';
        request.I_USERINFO.VKORG = 'V123';
        request.I_USERINFO.VTWEG = 'VT1';
        request.I_USERINFO.SPART = 'SP1';
        request.I_USERINFO.WERKS = 'Plant1';
        request.I_USERINFO.ARBPL = 'Workshop1';
        request.I_USERINFO.PARNR = 'Partner1';
        request.I_USERINFO.ENAME = 'John';
        request.I_USERINFO.KUNN2 = 'KUNN2';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'LG001';
        request.I_USERINFO.DF_CHK = 'N';
        request.I_USERINFO.CO_CHK = 'Y';

        // T_CLAIM 리스트 설정
        request.T_CLAIM = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_CLAIM>();
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_CLAIM claim = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_CLAIM();
        claim.CLAIM_SEQ = '001';
        claim.CODE_01 = 'C01';
        claim.CODE_02 = 'C02';
        claim.CODE_03 = 'C03';
        claim.OTGRP = 'Group1';
        claim.OTEIL = 'OT1';
        claim.KURZTEXT = 'Short Text';
        claim.KURZTEXT_L = 'Long Text';
        claim.FEGRP = 'FG1';
        claim.FECOD = 'FC1';
        claim.TXTCDFE = 'TX1';
        claim.FETXT = 'Feature Text';
        claim.SYMPTOM_ADD_TXT = 'Symptom Detail';
        claim.URGRP = 'UR1';
        claim.URCOD = 'URC1';
        claim.TXTCDUR = 'TXC1';
        claim.URTXT = 'Urgency Text';
        claim.CAUSE_ADD_TXT = 'Cause Details';
        claim.MNGRP = 'MG1';
        claim.MNCOD = 'MC1';
        claim.TXTCDMA = 'TXT1';
        claim.MATXT = 'Material Text';
        claim.ACT_ADD_TXT = 'Activity Detail';
        claim.FAULT_CAUSE = 'Cause1';
        claim.PHENO_ADD_TXT = 'Phenomenon';
        claim.BLCOD = 'BL1';
        claim.BLCOD_T = 'BL Text';
        request.T_CLAIM.add(claim);

        // T_OTHER 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_OTHER other = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_OTHER();
        other.SEQNO = '001';
        other.TYPE = 'Expense';
        other.CATEGORY = 'Travel';
        other.DESCRIPTION = 'Flight cost for site visit';
        other.VALUE = '500';
        other.UNIT = 'USD';
        other.AMOUNT = '500';
        other.TOT_AMT = '500';
        other.WAERS = 'USD';

        // T_DATE 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DATE dateEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DATE();
        dateEntry.MANDT = '100';
        dateEntry.AUFNR = 'AU123456';
        dateEntry.QMNUM = 'QM123';
        dateEntry.SEQNO = '002';
        dateEntry.REP_FR_DT = '2024-02-17';
        dateEntry.REP_FR_TM = '08:00:00';
        dateEntry.REP_TO_DT = '2024-02-18';
        dateEntry.REP_TO_TM = '18:00:00';
        dateEntry.ISMNW = 'Yes';
        dateEntry.ISMNW_PDK = 'N/A';
        dateEntry.ISMNE = 'No';
        dateEntry.AIR_TRIP = 'Yes';

        // T_PART 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_PART partEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_PART();
        partEntry.SEQNO = '003';
        partEntry.MATNR = 'MAT12345';
        partEntry.MAKTX = 'Brake Pad';
        partEntry.MEINS = 'PC';
        partEntry.MENGE = '10';
        partEntry.FOC_FLAG = 'Y';
        partEntry.CAUSE_PRT = 'Damaged';
        partEntry.RESP_FACTOR = 'Wear & Tear';
        partEntry.LOT_NO = 'LOT98765';
        partEntry.RETURN_YN = 'N';
        partEntry.RETURN_TYPE = 'Exchange';
        partEntry.RETURN_TYPE_T = 'Full';
        partEntry.RETURN_TEXT = 'Defective part replacement';
        partEntry.VSBED = 'Standard';
        partEntry.VTEXT = 'Standard Delivery';
        partEntry.APPNO = 'APP123';
        partEntry.WORKNO = 'W001';
        partEntry.WAERS = 'USD';
        partEntry.UNIT_PRICE = '20.00';
        partEntry.AMOUNT = '200.00';
        partEntry.SALESPRICE = '22.00';
        partEntry.CON_MENGE = '2';
        partEntry.STAN_PRICE = '18.50';
        partEntry.PART_RATE = '95';
        partEntry.DEPART_RATE = '5';
        partEntry.RETURN_END_YN = 'N';
        partEntry.RETURN_QTY = '0';
        partEntry.RETURN_DT = 'N/A';
        partEntry.CNF_QTY = '10';
        partEntry.CNF_NETPR = '20.00';
        partEntry.VERPR = '19.00';
        partEntry.LIFNR = 'Supplier123';
        partEntry.ZSUPPLY = 'Local Warehouse';
        partEntry.DOCNUM = 'DOC7890';
        partEntry.NFNUM = 'NF456';
        partEntry.ENTRAD = '2024-02-19';
        partEntry.FATURA = 'INV12345';
        partEntry.NFNUM2 = 'NF789';
        partEntry.ERDAT = '2024-02-16';
        partEntry.ERNAM = 'John Doe';
        partEntry.ERZET = '10:30:00';
        partEntry.AEDAT = '2024-02-17';
        partEntry.AENAM = 'Jane Smith';
        partEntry.AEZET = '14:45:00';
        partEntry.AUFNR = 'AU654321';
        partEntry.DNET_PRICE = '19.50';
        partEntry.ZZWAGRP = 'Group A';
        partEntry.ZZWAGRPNM = 'Auto Parts';
        partEntry.VKORG = 'VKO123';
        partEntry.VTWEG = 'VTW01';
        partEntry.SPART = 'SPT02';
        partEntry.GWLDT = '2024-02-18';
        partEntry.MGANR_UE = 'UE001';
        partEntry.INVOICE_NO = 'INV56789';

        // 리스트 생성 및 추가
        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_OTHER> otherList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_OTHER>();
        otherList.add(other);

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DATE> dateList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DATE>();
        dateList.add(dateEntry);

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_PART> partList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_PART>();
        partList.add(partEntry);

        // T_DEL 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DEL delEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DEL();
        delEntry.DOCNO = 'DOC12345';
        delEntry.FILENAME = 'invoice.pdf';

        // T_TMP 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TMP tmpEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TMP();
        tmpEntry.FILENAME = 'temp_file.jpg';
        tmpEntry.IF_DESC = 'Temporary file for claim processing';
        tmpEntry.EVISEQX = 'EVID123';
        tmpEntry.LINE = '10';
        tmpEntry.FILE_SIZE = '2MB';

        // T_TEXT_S 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_S textSEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_S();
        textSEntry.CLAIM_SEQ = '001';
        textSEntry.TDFORMAT = 'Bold';
        textSEntry.TDLINE = 'Service request approved.';

        // T_TEXT_C 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_C textCEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_C();
        textCEntry.CLAIM_SEQ = '002';
        textCEntry.TDFORMAT = 'Italic';
        textCEntry.TDLINE = 'Customer complaint received.';

        // T_TEXT_A 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_A textAEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_A();
        textAEntry.CLAIM_SEQ = '003';
        textAEntry.TDFORMAT = 'Underline';
        textAEntry.TDLINE = 'Additional warranty information provided.';

        // 리스트 생성 및 추가
        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DEL> delList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_DEL>();
        delList.add(delEntry);

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TMP> tmpList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TMP>();
        tmpList.add(tmpEntry);

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_S> textSList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_S>();
        textSList.add(textSEntry);

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_C> textCList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_C>();
        textCList.add(textCEntry);

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_A> textAList = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req_T_TEXT_A>();
        textAList.add(textAEntry);

        // Response 객체 생성 및 필드 값 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res response = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res();
        response.O_DEL_MSG = 'Deleted successfully';
        response.O_UPD_MSG = 'Updated successfully';

        // O_RETURN 설정
        response.O_RETURN = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.MESSAGE = 'Operation completed successfully';

        // T_DATE 리스트 설정
        response.T_DATE = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res_T_RETURN>();
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res_T_RETURN returnItem = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res_T_RETURN();
        returnItem.TYPE = 'E';
        returnItem.MESSAGE = 'Error occurred';
        response.T_DATE.add(returnItem);

        IF_ERP_SalesOrder instance = new IF_ERP_SalesOrder();
        instance.IF_CSPLUS_040(request);
        Test.stopTest();
    }
    @IsTest
    static void IF_CSPLUS_044_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-044', className);
        Test.startTest();
        //IF_ERP_SalesOrder_Classes
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req request = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req();
        request.I_UNAME = '';
        request.I_LANGU = '';

        request.T_TMP   = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP>();
        request.T_FILE  = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE>();

        // I_HEADER 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER header = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER();
        header.CLAIM_NO = 'CLM12345';
        header.QMNUM = 'QM56789';
        header.AUFNR = 'ORD98765';
        header.NAME = 'John Doe';
        header.INBDT = '2024-02-17';
        header.GWLDT_O = '2024-02-25';
        header.WTY_TYPE = 'Standard';
        header.GWLEN_O = '12M';
        header.ZZ_EX_TERM_VL = 'Extended';
        header.ZZ_EX_OPH = '5000';
        header.ZZ_CS_CAPA = '100';
        header.ZZ_CS_EWRNT_MM = '24';
        header.ZZ_CS_EWRNT_HR = '10000';
        header.ZZ_EX_TERM_TYP = 'Warranty';
        header.ZZ_EX_TERM_TYP_TXT = 'Extended Warranty';
        header.ZZ_EX_TERM_TYP_B = 'Basic';
        header.ZZ_EX_TERM_TYP_B_TXT = 'Basic Warranty';
        header.ZZ_EX_END_DTZZ_EX_END_DT = '2026-02-17';
        header.ZZ_WARR_S_DT = '2024-01-01';
        header.ZZ_WARR_E_DT = '2025-12-31';
        header.ILART = 'Repair';
        header.ILATX = 'Standard Repair';
        header.WORKING_HR = '8';
        header.PARTS_INST_DT = '2024-01-15';
        header.FAIL_DT = '2024-02-10';
        header.FAIL_TM = '14:30';
        header.QMDAT = '2024-02-11';
        header.REG_TIME = '09:00';
        header.REQUIRE_DAT = '2024-02-12';
        header.REQUIRE_TIM = '10:00';
        header.ARRVAL_DT = '2024-02-13';
        header.ARRVAL_TM = '11:00';
        header.FAIL_END_DT = '2024-02-14';
        header.FAIL_END_TM = '15:00';
        header.REPAIR_DT = '2024-02-15';
        header.WARR_END_DT = '2025-12-31';
        header.BEBER = 'Technician A';
        header.BEBER_T = 'Certified Technician';
        header.STORT = 'NYC Service Center';
        header.STORT_T = 'New York Service Center';
        header.ABCKZ = 'A1';
        header.ABCKZ_T = 'High Priority';
        header.MSGRP = 'Maintenance Group A';
        header.REPORTEDBY = 'Jane Doe';
        header.BREAKDOWN = 'Yes';
        header.EQUNR = 'EQ123456';
        header.RBNR = 'RB56789';
        header.TYPBZ = 'Type B';
        header.SERNR = 'SN987654';
        header.WERKS = 'Plant A';
        header.WARR_COUNTER = '3';
        header.CODING = 'Repair Code A';
        header.CODE_TEXT = 'Repair Description';
        header.ATTACHMENT_CODE = 'ATT001';
        header.ATTACHMENT = 'Service Report.pdf';
        header.WORK_AREA_CODE = 'WA01';
        header.WORK_AREA = 'Electronics Repair';
        header.WORK_TYPE_CODE = 'WT02';
        header.WORK_TYPE = 'Component Replacement';
        header.MAINTROOM = 'Room 101';
        header.MAINTROOM_CODE = 'R101';
        header.NOTIF_DATE = '2024-02-17';
        header.NOTIFTIME = '12:00';
        header.STRMLFNDATE = '2024-02-18';
        header.STRMLFNTIME = '13:00';
        header.DESENDDATE = '2024-02-19';
        header.DESENDTM = '14:00';
        header.STAND_WE = 'Standard Warranty';
        header.PHENOMENA = 'System Failure';
        header.CODE_01 = 'C001';
        header.CODE_02 = 'C002';
        header.CODE_03 = 'C003';
        header.DL_CODEGRP = 'DG01';
        header.DL_CODE = 'D01';
        header.STXT_GRPCD = 'SG01';
        header.D_CODEGRP = 'DC01';
        header.D_CODE = 'D02';
        header.TXT_PROBCD = 'TP01';
        header.POWERTRAIN = 'Engine';
        header.SHIP_TO = 'Customer Warehouse';
        header.DESCRIPT = 'Engine Overhaul';
        header.TXTQM = 'Quality Maintenance';
        header.REF_NO = 'REF001';
        header.INACT_STAT = 'Active';
        header.NOCO_STAT = 'Not Completed';
        header.SMTP_ADDR = 'customer@example.com';
        header.CHECK_SAVED = 'Yes';
        header.STREET = '123 Main Street';
        header.CITY1 = 'New York';
        header.POST_CODE1 = '10001';
        header.TEL_NUMBER = '555-1234';
        header.CONTROL_TYP = 'Control A';
        header.CONTROL_SN = 'SN1001';
        header.VSBED = 'Standard';
        header.AUTLF = 'Yes';
        header.CARRIER = 'FedEx';
        header.ACCT_NO = 'ACC12345';
        header.SIGNED_DATE = '2024-02-16';
        header.CUSTOMER_NAME = 'John Smith';
        header.CUSTOMER_TITLE = 'Operations Manager';

        // I_USERINFO 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO userInfo = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO();
        userInfo.BNAME = 'user123';
        userInfo.RNAME = 'John Doe';
        userInfo.HIER = 'Manager';
        userInfo.KUNNR = 'CUST001';
        userInfo.NAME1 = 'Customer One';
        userInfo.LIFNR = 'VEND001';
        userInfo.VKORG = 'SalesOrg1';
        userInfo.VTWEG = 'DistChannel1';
        userInfo.SPART = 'Division1';
        userInfo.WERKS = 'PlantA';
        userInfo.WAERS = 'USD';
        userInfo.ARBPL = 'WorkCenter1';
        userInfo.PARNR = 'Partner1';
        userInfo.ENAME = 'Jane Doe';
        userInfo.KUNN2 = 'CUST002';
        userInfo.LAND1 = 'US';
        userInfo.REGIO = 'NY';
        userInfo.LGORT = 'Storage1';
        userInfo.VERAN = 'Version1';
        userInfo.DF_CHK = 'X';
        userInfo.CO_CHK = 'Y';
        userInfo.DEL_CHK = 'N';
        userInfo.FOREIGN = 'International';
        userInfo.BZIRK = 'Zone1';
        userInfo.ERDAT = '2024-02-17';
        userInfo.ERNAM = 'SystemUser';
        userInfo.AEDAT = '2024-02-18';
        userInfo.AENAM = 'AdminUser';

        // T_RETURN 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_RETURN returnData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_RETURN();
        returnData.TYPE = 'Success';
        returnData.MESSAGE = 'Process completed successfully';

        // T_CLAIM 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM claimData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM();
        claimData.CLAIM_SEQ = '1';
        claimData.CODE_01 = 'C001';
        claimData.CODE_02 = 'C002';
        claimData.CODE_03 = 'C003';
        claimData.OTGRP = 'GroupA';
        claimData.OTEIL = 'ComponentX';
        claimData.KURZTEXT = 'Short Text';
        claimData.KURZTEXT_L = 'Detailed Description';
        claimData.FEGRP = 'Failure Group A';
        claimData.FECOD = 'Failure Code X';
        claimData.TXTCDFE = 'Failure Text';
        claimData.FETXT = 'Extended Failure Text';
        claimData.SYMPTOM_ADD_TXT = 'Additional Symptom';
        claimData.URGRP = 'Urgency Group 1';
        claimData.URCOD = 'Urgency Code A';
        claimData.TXTCDUR = 'Urgency Text';
        claimData.URTXT = 'Urgency Explanation';
        claimData.CAUSE_ADD_TXT = 'Cause Description';
        claimData.MNGRP = 'Maintenance Group A';
        claimData.MNCOD = 'Maintenance Code X';
        claimData.TXTCDMA = 'Maintenance Text';
        claimData.MATXT = 'Material Explanation';
        claimData.ACT_ADD_TXT = 'Additional Action';
        claimData.FAULT_CAUSE = 'Root Cause';
        claimData.PHENO_ADD_TXT = 'Phenomena Details';
        claimData.BLCOD = 'Block Code 1';
        claimData.BLCOD_T = 'Block Code Text';

        // T_DATE 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE dateData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE();
        dateData.AUFNR = 'ORD98765';
        dateData.QMNUM = 'QM56789';
        dateData.SEQNO = '1';
        dateData.REP_FR_DT = '2024-02-10';
        dateData.REP_FR_TM = '10:00';
        dateData.REP_TO_DT = '2024-02-12';
        dateData.REP_TO_TM = '14:00';
        dateData.ISMNW = 'Yes';
        dateData.ISMNW_PDK = 'PDK Value';
        dateData.ISMNE = 'NE Value';
        dateData.AIR_TRIP = 'Flight123';

        // T_PART 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART partData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART();
        partData.SEQNO = '1';
        partData.MATNR = 'MAT001';
        partData.MAKTX = 'Material A';
        partData.MEINS = 'EA';
        partData.MENGE = '10';
        partData.FOC_FLAG = 'Yes';
        partData.CAUSE_PRT = 'Cause P1';
        partData.RESP_FACTOR = 'Factor A';
        partData.LOT_NO = 'LOT123';
        partData.RETURN_YN = 'No';
        partData.RETURN_TYPE = 'Type1';
        partData.RETURN_TYPE_T = 'Type Explanation';
        partData.RETURN_TEXT = 'Return Text';
        partData.VSBED = 'Standard';
        partData.VTEXT = 'Standard Text';
        partData.APPNO = 'App001';
        partData.WORKNO = 'Work123';
        partData.WAERS = 'USD';
        partData.UNIT_PRICE = '100';
        partData.AMOUNT = '1000';
        partData.SALESPRICE = '120';
        partData.CON_MENGE = '5';
        partData.STAN_PRICE = '110';
        partData.PART_RATE = '5%';
        partData.DEPART_RATE = '3%';
        partData.RETURN_END_YN = 'No';
        partData.RETURN_QTY = '0';
        partData.RETURN_DT = '2024-02-20';
        partData.CNF_QTY = '10';
        partData.CNF_NETPR = '900';
        partData.VERPR = '850';
        partData.LIFNR = 'VEND002';
        partData.ZSUPPLY = 'Supply A';
        partData.DOCNUM = 'DOC001';
        partData.NFNUM = 'NF123';
        partData.ENTRAD = 'Entry A';
        partData.FATURA = 'Invoice123';
        partData.NFNUM2 = 'NF456';
        partData.ERDAT = '2024-02-17';
        partData.ERNAM = 'CreatorUser';
        partData.ERZET = '11:00';
        partData.AEDAT = '2024-02-18';
        partData.AENAM = 'EditorUser';
        partData.AEZET = '13:00';
        partData.AUFNR = 'ORD567';
        partData.DNET_PRICE = '950';
        partData.ZZWAGRP = 'Group Z';
        partData.ZZWAGRPNM = 'Group Name Z';
        partData.VKORG = 'SalesOrg2';
        partData.VTWEG = 'DistChannel2';
        partData.SPART = 'Division2';
        partData.GWLDT = '2024-03-01';
        partData.MGANR_UE = 'MG123';
        partData.INVOICE_NO = 'INV456';

        // T_OTHER 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_OTHER otherData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_OTHER();
        otherData.SEQNO = '1';
        otherData.TYPE = 'Expense';
        otherData.CATEGORY = 'Maintenance';
        otherData.DESCRIPTION = 'Repair cost';
        otherData.VALUE = '500';
        otherData.UNIT = 'USD';
        otherData.AMOUNT = '500';
        otherData.TOT_AMT = '500';
        otherData.WAERS = 'USD';

        // T_TMP 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP tmpData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP();
        tmpData.FILENAME = 'tempFile.txt';
        tmpData.IF_DESC = 'Temporary description';
        tmpData.EVISEQX = 'E123';
        tmpData.LINE = '10';
        tmpData.FILE_SIZE = '2048';

        // T_DOC 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DOC docData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DOC();
        docData.FILENAME = 'document.pdf';
        docData.MIMETYPE = 'application/pdf';
        docData.FILEDATA = 'Base64EncodedData';
        docData.DESCRIPTION = 'Service document';
        docData.FLAG = 'Y';
        docData.DOCNO = 'D123456';

        // T_DEL 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DEL delData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DEL();
        delData.FILENAME = 'old_document.pdf';
        delData.DOCNO = 'D654321';

        // T_TEXT_A 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_A textAData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_A();
        textAData.CLAIM_SEQ = '1';
        textAData.TDFORMAT = 'TXT';
        textAData.TDLINE = 'This is an additional text A';

        // T_TEXT_C 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_C textCData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_C();
        textCData.CLAIM_SEQ = '2';
        textCData.TDFORMAT = 'TXT';
        textCData.TDLINE = 'This is an additional text C';

        // T_TEXT_S 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_S textSData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_S();
        textSData.CLAIM_SEQ = '3';
        textSData.TDFORMAT = 'TXT';
        textSData.TDLINE = 'This is an additional text S';

        // T_TEXT_P 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_P textPData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_P();
        textPData.CLAIM_SEQ = '4';
        textPData.TDFORMAT = 'TXT';
        textPData.TDLINE = 'This is an additional text P';

        // T_FILE 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE fileData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE();
        fileData.FILENAME = 'report.csv';
        fileData.IF_DESC = 'File description';
        fileData.EVISEQX = 'E124';
        fileData.LINE = '20';
        fileData.FILE_SIZE = '4096';

        // T_SIGN1 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_SIGN1 sign1Data = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_SIGN1();
        sign1Data.CLAIM_SEQ = '5';
        sign1Data.TDFORMAT = 'Signature1';
        sign1Data.TDLINE = 'Digital Signature Data 1';

        // T_SIGN2 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_SIGN2 sign2Data = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_SIGN2();
        sign2Data.CLAIM_SEQ = '6';
        sign2Data.TDFORMAT = 'Signature2';
        sign2Data.TDLINE = 'Digital Signature Data 2';

        // O_RETURN 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_O_RETURN resReturnData = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_O_RETURN();
        resReturnData.TYPE = 'S';
        resReturnData.MESSAGE = 'Success';

        // T_RETURN 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_RETURN returnEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_RETURN();
        returnEntry.TYPE = 'W';
        returnEntry.MESSAGE = 'Warning Message';

        // T_CLAIM 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_CLAIM claimEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_CLAIM();
        claimEntry.CLAIM_SEQ = '1';
        claimEntry.CODE_01 = 'A01';
        claimEntry.CODE_02 = 'B02';
        claimEntry.CODE_03 = 'C03';
        claimEntry.OTGRP = 'Group A';
        claimEntry.OTEIL = 'Component A';
        claimEntry.KURZTEXT = 'Short Text';
        claimEntry.KURZTEXT_L = 'Long Description';

        // T_DATE 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_DATE dateEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_DATE();
        dateEntry.AUFNR = '123456';
        dateEntry.QMNUM = 'QM001';
        dateEntry.SEQNO = '1';
        dateEntry.REP_FR_DT = '20240220';
        dateEntry.REP_FR_TM = '120000';

        // T_PART 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_PART partEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_PART();
        partEntry.SEQNO = '1';
        partEntry.MATNR = 'Material001';
        partEntry.MAKTX = 'Material Description';
        partEntry.MEINS = 'EA';
        partEntry.MENGE = '10';
        partEntry.FOC_FLAG = 'Y';
        partEntry.CAUSE_PRT = 'CP01';
        partEntry.RESP_FACTOR = 'RF01';
        partEntry.LOT_NO = 'LOT12345';
        partEntry.RETURN_YN = 'N';
        partEntry.RETURN_TYPE = 'RT01';
        partEntry.RETURN_TYPE_T = 'Return Type Text';
        partEntry.RETURN_TEXT = 'Defective Item';
        partEntry.VSBED = 'Shipping Condition';
        partEntry.VTEXT = 'Shipping Text';
        partEntry.APPNO = 'APP123';
        partEntry.WORKNO = 'WK456';
        partEntry.WAERS = 'USD';
        partEntry.UNIT_PRICE = '100.50';
        partEntry.AMOUNT = '1050.00';
        partEntry.SALESPRICE = '1100.00';
        partEntry.CON_MENGE = '5';
        partEntry.STAN_PRICE = '95.00';
        partEntry.PART_RATE = '0.9';
        partEntry.DEPART_RATE = '0.1';
        partEntry.RETURN_END_YN = 'N';
        partEntry.RETURN_QTY = '2';
        partEntry.RETURN_DT = '20240220';
        partEntry.CNF_QTY = '8';
        partEntry.CNF_NETPR = '800.00';
        partEntry.VERPR = '90.00';
        partEntry.LIFNR = 'Supplier001';
        partEntry.ZSUPPLY = 'ZSupplyCode';
        partEntry.DOCNUM = 'DOC98765';
        partEntry.NFNUM = 'NF1001';
        partEntry.ENTRAD = 'Entry Data';
        partEntry.FATURA = 'Invoice Data';
        partEntry.NFNUM2 = 'NF2002';
        partEntry.ERDAT = '20240219';
        partEntry.ERNAM = 'John Doe';
        partEntry.ERZET = '120000';
        partEntry.AEDAT = '20240220';
        partEntry.AENAM = 'Jane Doe';
        partEntry.AEZET = '130000';
        partEntry.AUFNR = 'Order001';
        partEntry.DNET_PRICE = '95.50';
        partEntry.ZZWAGRP = 'ZZGroup';
        partEntry.ZZWAGRPNM = 'ZZ Group Name';
        partEntry.VKORG = 'SalesOrg001';
        partEntry.VTWEG = 'DistChannel001';
        partEntry.SPART = 'Division001';
        partEntry.GWLDT = 'Warranty Date';
        partEntry.MGANR_UE = 'MGANR001';
        partEntry.INVOICE_NO = 'INV12345';

        // T_OTHER 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_OTHER otherEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_OTHER();
        otherEntry.SEQNO = '1';
        otherEntry.TYPE = 'Cost';
        otherEntry.CATEGORY = 'Warranty';
        otherEntry.DESCRIPTION = 'Repair Cost';
        otherEntry.VALUE = '500';

        // T_DOC 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_DOC docEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_DOC();
        docEntry.FILENAME = 'document.pdf';
        docEntry.MIMETYPE = 'application/pdf';
        docEntry.FILEDATA = 'Base64EncodedData';
        docEntry.DESCRIPTION = 'Technical Document';

        // T_TEXT_A 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_TEXT_A textAEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_TEXT_A();
        textAEntry.CLAIM_SEQ = '1';
        textAEntry.TDFORMAT = 'TXT';
        textAEntry.TDLINE = 'This is additional text A';

        // T_FILE 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_FILE fileEntry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_FILE();
        fileEntry.FILENAME = 'report.csv';
        fileEntry.IF_DESC = 'Report File';
        fileEntry.EVISEQX = 'E124';
        fileEntry.LINE = '20';
        fileEntry.FILE_SIZE = '4096';

        // T_SIGN1 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_SIGN1 sign1Entry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_SIGN1();
        sign1Entry.CLAIM_SEQ = '1';
        sign1Entry.TDFORMAT = 'Signature1';
        sign1Entry.TDLINE = 'Signed by John Doe';

        // T_SIGN2 객체 생성 및 필드 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_SIGN2 sign2Entry = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_SIGN2();
        sign2Entry.CLAIM_SEQ = '2';
        sign2Entry.TDFORMAT = 'Signature2';
        sign2Entry.TDLINE = 'Signed by Jane Doe';

        // 응답 객체 생성 및 설정
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res response = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res();
        response.O_ORDER = '000001';
        response.O_NOTIFICATION = '000001';
        response.O_DEL_MSG = 'Deletion successful';
        response.O_UPD_MSG = 'Update successful';
        response.O_RETURN = resReturnData;
        response.T_RETURN = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_RETURN>{ returnEntry };
        response.T_CLAIM = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_CLAIM>{ claimEntry };
        response.T_DATE = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_DATE>{ dateEntry };
        response.T_PART = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_PART>{ partEntry };
        response.T_OTHER = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_OTHER>{ otherEntry };
        response.T_DOC = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_DOC>{ docEntry };
        response.T_TEXT_A = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_TEXT_A>{ textAEntry };
        response.T_FILE = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_FILE>{ fileEntry };
        response.T_SIGN1 = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_SIGN1>{ sign1Entry };
        response.T_SIGN2 = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_T_SIGN2>{ sign2Entry };

        IF_ERP_SalesOrder instance = new IF_ERP_SalesOrder();
        instance.IF_CSPLUS_044(request);
        Test.stopTest();
    }
}