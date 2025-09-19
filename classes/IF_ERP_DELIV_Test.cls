@isTest
public with sharing class IF_ERP_DELIV_Test {
    private static String className = 'IF_ERP_DELIV';

    public IF_ERP_DELIV_Test() {}

/* Mock Classes
    */
    public class IF_DELIV_001_HttpMock implements HttpCalloutMock {
        public IF_DELIV_001_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Delivery Document No0081328553 created."},"O_VBELN":"0081328553","O_UPD_MSG":"File upload was successful.","O_DEL_MSG":"","T_RETURN":[{"CODE":"311","MESSAGE":"Outbound Delivery 81328553 has been saved","TYPE":"S"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_DELIV_002_HttpMock implements HttpCalloutMock {
        public IF_DELIV_002_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_MATERIAL":[{"WERKS":"","ANZSN":"0","VBELN":"0081328477","ABGRU":"","KDMAT":"","UPDATEFLAG":"","VKAUS":"","NETPR":"0.00","KWMENG":"1.000","MAKTX":"L210LYA/D300_STD;KOREA","ZZSQCOD":"","KBMENG":"0.000","MATNR":"L210LYA-D300-0-K10","VRKME":"","ROUTE":"","REF_DOC_IT":"000000","KLMENG":"0.000","KZWI1":"0.00","POSEX":"","PSTYV":"","NETWR":"0.00","ZZSQTITLE":"","VSTEL":"","POSNR":"000010","WAERK":"","REF_DOC_CA":"","REF_DOC":"","MEINS":"EA"},{"WERKS":"","ANZSN":"0","VBELN":"0081328479","ABGRU":"","KDMAT":"","UPDATEFLAG":"","VKAUS":"","NETPR":"0.00","KWMENG":"1.000","MAKTX":"DNM6704/F0IMP_AT8_12K;STD","ZZSQCOD":"","KBMENG":"0.000","MATNR":"DNM6704-F0MP-1-P09","VRKME":"","ROUTE":"","REF_DOC_IT":"000000","KLMENG":"0.000","KZWI1":"0.00","POSEX":"","PSTYV":"","NETWR":"0.00","ZZSQTITLE":"","VSTEL":"","POSNR":"000010","WAERK":"","REF_DOC_CA":"","REF_DOC":"","MEINS":"EA"},{"WERKS":"","ANZSN":"0","VBELN":"0081328479","ABGRU":"","KDMAT":"","UPDATEFLAG":"","VKAUS":"","NETPR":"0.00","KWMENG":"1.000","MAKTX":"AIR BLOWER","ZZSQCOD":"","KBMENG":"0.000","MATNR":"SQ100","VRKME":"","ROUTE":"","REF_DOC_IT":"000000","KLMENG":"0.000","KZWI1":"0.00","POSEX":"","PSTYV":"","NETWR":"0.00","ZZSQTITLE":"","VSTEL":"","POSNR":"000020","WAERK":"","REF_DOC_CA":"","REF_DOC":"","MEINS":"SET"},{"WERKS":"","ANZSN":"0","VBELN":"0081328479","ABGRU":"","KDMAT":"","UPDATEFLAG":"","VKAUS":"","NETPR":"0.00","KWMENG":"1.000","MAKTX":"DATA SERVER 1G","ZZSQCOD":"","KBMENG":"0.000","MATNR":"SQ100","VRKME":"","ROUTE":"","REF_DOC_IT":"000000","KLMENG":"0.000","KZWI1":"0.00","POSEX":"","PSTYV":"","NETWR":"0.00","ZZSQTITLE":"","VSTEL":"","POSNR":"000030","WAERK":"","REF_DOC_CA":"","REF_DOC":"","MEINS":"SET"},{"WERKS":"","ANZSN":"0","VBELN":"0081328484","ABGRU":"","KDMAT":"","UPDATEFLAG":"","VKAUS":"","NETPR":"0.00","KWMENG":"1.000","MAKTX":"DBC1102/F31IBP_STD;KOREA","ZZSQCOD":"","KBMENG":"0.000","MATNR":"DBC1102-F31P-0-K30","VRKME":"","ROUTE":"","REF_DOC_IT":"000000","KLMENG":"0.000","KZWI1":"0.00","POSEX":"","PSTYV":"","NETWR":"0.00","ZZSQTITLE":"","VSTEL":"","POSNR":"000010","WAERK":"","REF_DOC_CA":"","REF_DOC":"","MEINS":"EA"}],"T_PARTNER":[{"READ":"X","POST_CODE1":"15081","STREET":"(조남동, 케이엠지식산업센터)","PARVW":"AG","CITY1":"경기도 시흥시 수풀안길 9-36, 738호","VTEXT":"Sold-to party","VBELN":"0081328477","KUNNR":"0001313992","ADRNR":"0003176086","NAME1":"주식회사 디에스엠티웍스"},{"READ":"","POST_CODE1":"15081","STREET":"(조남동, 케이엠지식산업센터)","PARVW":"RE","CITY1":"경기도 시흥시 수풀안길 9-36, 738호","VTEXT":"Bill-to party","VBELN":"0081328477","KUNNR":"0001313992","ADRNR":"0003176086","NAME1":"주식회사 디에스엠티웍스"},{"READ":"","POST_CODE1":"16384","STREET":"(고색동, 수원델타원지식산업센터)","PARVW":"WE","CITY1":"경기도 수원시 권선구 산업로 198, 제지증 제비114호","VTEXT":"Ship-to party","VBELN":"0081328477","KUNNR":"0001329049","ADRNR":"0003258093","NAME1":"비트(BIT)"},{"READ":"X","POST_CODE1":"42723","STREET":"31(월성동)","PARVW":"AG","CITY1":"대구광역시 달서구 월곡로99길","VTEXT":"Sold-to party","VBELN":"0081328479","KUNNR":"0001107596","ADRNR":"0000761679","NAME1":"하이머신주식회사"},{"READ":"","POST_CODE1":"42723","STREET":"31(월성동)","PARVW":"RE","CITY1":"대구광역시 달서구 월곡로99길","VTEXT":"Bill-to party","VBELN":"0081328479","KUNNR":"0001107596","ADRNR":"0000761679","NAME1":"하이머신주식회사"},{"READ":"","POST_CODE1":"41557","STREET":"27길 138","PARVW":"WE","CITY1":"대구광역시 북구 팔달로","VTEXT":"Ship-to party","VBELN":"0081328479","KUNNR":"0001075497","ADRNR":"0000316327","NAME1":"일광연마"},{"READ":"X","POST_CODE1":"18428","STREET":"","PARVW":"AG","CITY1":"경기도 화성시 남여울2길 24(능동)","VTEXT":"Sold-to party","VBELN":"0081328484","KUNNR":"0001124140","ADRNR":"0000913785","NAME1":"토탈머신 주식회사"},{"READ":"","POST_CODE1":"18428","STREET":"","PARVW":"RE","CITY1":"경기도 화성시 남여울2길 24(능동)","VTEXT":"Bill-to party","VBELN":"0081328484","KUNNR":"0001124140","ADRNR":"0000913785","NAME1":"토탈머신 주식회사"},{"READ":"","POST_CODE1":"04501","STREET":"서울특별시 중구 만리재로33길 21 (만리동1가, LIG 서울역","PARVW":"WE","CITY1":"서울특별시","VTEXT":"Ship-to party","VBELN":"0081328484","KUNNR":"0001092533","ADRNR":"0000479401","NAME1":"ERP에 코드가 있는 고객3"}],"T_DOC":[],"T_ZCRMS0062":[{"WAUHR":"16:49:00","ZFPLDVLD":"","VBELN":"0081328477","ZFPLDVCD":"","LFDAT":"2025-04-18","ZFCSHCP":"","ZFETD":"0000-00-00","ZFPLDV":"","ZFETA":"0000-00-00","ZFCARNM":"","ZZSTATUS":"A","WADAT_IST":"0000-00-00","WADAT":"2025-03-08","LFUHR":"16:49:00"},{"WAUHR":"16:49:00","ZFPLDVLD":"","VBELN":"0081328479","ZFPLDVCD":"","LFDAT":"2025-04-18","ZFCSHCP":"","ZFETD":"0000-00-00","ZFPLDV":"","ZFETA":"0000-00-00","ZFCARNM":"","ZZSTATUS":"A","WADAT_IST":"0000-00-00","WADAT":"2025-03-08","LFUHR":"16:49:00"},{"WAUHR":"00:00:00","ZFPLDVLD":"","VBELN":"0081328484","ZFPLDVCD":"","LFDAT":"2025-01-10","ZFCSHCP":"","ZFETD":"0000-00-00","ZFPLDV":"","ZFETA":"0000-00-00","ZFCARNM":"","ZZSTATUS":"C","WADAT_IST":"2025-01-10","WADAT":"2025-01-10","LFUHR":"00:00:00"}],"T_HEADER":[{"ERDAT":"2019-11-08","ZTERM":"C007","TEXT1":"Wholesale selling (30 Days)","VBELN":"0081328477","BEZEI":"인천지사","WAERK":"KRW","NAME1":"","T_EST_AMT":"0.00","VDATU":"2024-04-06"},{"ERDAT":"2022-12-06","ZTERM":"C007","TEXT1":"Wholesale selling (30 Days)","VBELN":"0081328479","BEZEI":"대구지사","WAERK":"KRW","NAME1":"","T_EST_AMT":"0.00","VDATU":"2024-04-29"},{"ERDAT":"2025-01-03","ZTERM":"C007","TEXT1":"Wholesale selling (30 Days)","VBELN":"0081328484","BEZEI":"수원지사","WAERK":"KRW","NAME1":"","T_EST_AMT":"0.00","VDATU":"2025-01-03"}],"T_CREDIT":[{"SALES_AMT":"0.00","VBELN":"0081328477","CREDIT_LIMIT":"0.00","WAERK":"KRW","CREDIT":"0.00","OPEN_SALES":"0.00"},{"SALES_AMT":"0.00","VBELN":"0081328479","CREDIT_LIMIT":"0.00","WAERK":"KRW","CREDIT":"0.00","OPEN_SALES":"0.00"},{"SALES_AMT":"0.00","VBELN":"0081328484","CREDIT_LIMIT":"0.00","WAERK":"KRW","CREDIT":"0.00","OPEN_SALES":"0.00"}],"T_COND":[{"TO":"CCC001","VBELN_VA":"0100473266","FROM_TXT":"","FROM":"","TO_TXT":"합덕","VBELN":"0201752032","CAPITAL_NO":"123","AUBEL":"0081328477"},{"TO":"CCC001","VBELN_VA":"0100473310","FROM_TXT":"창원","FROM":"CGS010","TO_TXT":"합덕","VBELN":"0201888311","CAPITAL_NO":"123","AUBEL":"0081328479"},{"TO":"CCC043","VBELN_VA":"0100474792","FROM_TXT":"창원","FROM":"CGS010","TO_TXT":"연기","VBELN":"0201941626","CAPITAL_NO":"","AUBEL":"0081328484"}],"T_NOTE":[{"TDLINE":"123","TDFORMAT":"","VBELN":"0081328477"},{"TDLINE":"123","TDFORMAT":"","VBELN":"0081328479"},{"TDLINE":"123","TDFORMAT":"","VBELN":"0081328484"}],"T_CHANGE":[{"VBELN":"0081328477","CHANGE":""},{"VBELN":"0081328479","CHANGE":""},{"VBELN":"0081328484","CHANGE":""}],"T_DELINFO":[],"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_DELIV_003_HttpMock implements HttpCalloutMock {
        public IF_DELIV_003_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"T_LIST":[{"AENAM":"","ZZINCOM_VER":"01","CLRAMT":"0.00","ZCLASS":"","ZPARTIAL_BILLNO":"","ZZINCOM_NO":"0000433168","DPCL_AMT":"0.00","FA_CODE":"","ERZET":"15:07:36","FKDAT":"0000-00-00","AEDAT":"0000-00-00","EST_DAT_OLD":"0000-00-00","DOWN_REQ_NO":"","ERNAM":"EAICOM","ZZTERM":"","ZTERM":"C007","INCOM_CODE":"P02","EST_DAT":"2025-02-23","ZRESCHE":"","SERIAL_NO":"01","ERDAT":"2025-01-19","NOTAX_INT_AMT":"0.00","PRI_AMT":"225115000.00","WAERK":"KRW","AEZET":"00:00:00","ZBD1T":"0030","BASE_DATE":"2025-01-24","EST_AMT":"225115000.00"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_DELIV_004_HttpMock implements HttpCalloutMock {
        public IF_DELIV_004_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""},"T_OUTPUT":[{"ERDAT":"2025-01-23","ZFBOXSEQ":"000000","EXDRVR":"","ZZISSUEDT":"0000-00-00","INCO2":"Y01 (Delivered at Customer S","INCO1":"Y01","NAME1_S":"토탈머신 주식회사","ZZCOUNTRY":"","ZSEQ":"0000","NAME1_H":"ERP에 코드가 있는 고객3","B_CDATE":"0000-00-00","COUNTRY_2":"KR","WADAT":"2025-02-08","COUNTRY_1":"KR","AUART":"","MATNR_V":"DBC1102-F31P-0-K30","ZSDFUNC":"","WERKS":"1842","MATNR_R":"DBC1102-F31P-0-K30","TRANS_EXP":"","ZZAPPNO":"","EMP_NAME":"","ZFBGNO":"","GLTRI":"0000-00-00","ZFSETTLE":"","POSNR":"000010","PARRDT":"0000-00-00","HPNO":"","LGORT":"","GI_FLAG":"","COUNTRY_ST":"South Korea","ZZAPPROVAL":"","LFDAT":"2025-02-07","ZFCDNM":"","LTRMI":"0000-00-00","ZSSRED":"2024-06-10","VKBUR":"","LGORT_1":"","B_CTIME":"00:00:00","SERNR":"","LZONE":"031-069","ZINVNO":"","ZZISSUER":"","VKORG":"1800","WADAT_IST":"0000-00-00","VBELN":"0081328504","GIREQ_DT":"0000-00-00","VBELN_V":"0100474780","LZONE_T":"시흥신현285","LAND1":"","VBELN_R":"0201934766","ZZPRINT":"000","SPART":"40","AUFNR":"","VTWEG":"10","TRANAG_T":"","WBSTK":"","LFART":"ZLF","LFUHR":"18:33:00","PARRTM":"00:00:00","KUNNR_S":"0001124140","CL_DATE":"0000-00-00","CARGO_DETAIL":"","CARLC":"","ZSMS":"","VERID":"","KUNNR_H":"0001092533","ZZAPPDT":"0000-00-00","APP_NAME":"","ETD":"0000-00-00","ZFTRANSTP":"","VGPOS":"000010","ZZSTATUS":"A","B_ETD":"0000-00-00","ZSPADDR":"","B_ETA":"0000-00-00","BZIRK":"A1KR","ZZMACHIN":"","LGORT_REAL":"","CITY1":"서울특별시","TRANAG":"","ZZAPPUSER":"","VGBEL":"0201934766","COUNTRY_S":"KR"},{"ERDAT":"2025-01-23","ZFBOXSEQ":"000000","EXDRVR":"","ZZISSUEDT":"0000-00-00","INCO2":"Y01 (Delivered at Customer S","INCO1":"Y01","NAME1_S":"토탈머신 주식회사","ZZCOUNTRY":"","ZSEQ":"0000","NAME1_H":"ERP에 코드가 있는 고객3","B_CDATE":"0000-00-00","COUNTRY_2":"KR","WADAT":"2025-02-08","COUNTRY_1":"KR","AUART":"","MATNR_V":"160401-00891A","ZSDFUNC":"","WERKS":"1842","MATNR_R":"160401-00891A","TRANS_EXP":"","ZZAPPNO":"","EMP_NAME":"","ZFBGNO":"","GLTRI":"0000-00-00","ZFSETTLE":"","POSNR":"000020","PARRDT":"0000-00-00","HPNO":"","LGORT":"","GI_FLAG":"","COUNTRY_ST":"South Korea","ZZAPPROVAL":"","LFDAT":"2025-02-07","ZFCDNM":"","LTRMI":"0000-00-00","ZSSRED":"2024-07-31","VKBUR":"","LGORT_1":"","B_CTIME":"00:00:00","SERNR":"","LZONE":"031-069","ZINVNO":"","ZZISSUER":"","VKORG":"1800","WADAT_IST":"0000-00-00","VBELN":"0081328504","GIREQ_DT":"0000-00-00","VBELN_V":"0100474780","LZONE_T":"시흥신현285","LAND1":"","VBELN_R":"0201934766","ZZPRINT":"000","SPART":"40","AUFNR":"","VTWEG":"10","TRANAG_T":"","WBSTK":"","LFART":"ZLF","LFUHR":"18:33:00","PARRTM":"00:00:00","KUNNR_S":"0001124140","CL_DATE":"0000-00-00","CARGO_DETAIL":"","CARLC":"","ZSMS":"","VERID":"","KUNNR_H":"0001092533","ZZAPPDT":"0000-00-00","APP_NAME":"","ETD":"0000-00-00","ZFTRANSTP":"","VGPOS":"000020","ZZSTATUS":"A","B_ETD":"0000-00-00","ZSPADDR":"","B_ETA":"0000-00-00","BZIRK":"A1KR","ZZMACHIN":"","LGORT_REAL":"","CITY1":"서울특별시","TRANAG":"","ZZAPPUSER":"","VGBEL":"0201934766","COUNTRY_S":"KR"},{"ERDAT":"2025-01-23","ZFBOXSEQ":"000000","EXDRVR":"","ZZISSUEDT":"0000-00-00","INCO2":"Y01 (Delivered at Customer S","INCO1":"Y01","NAME1_S":"토탈머신 주식회사","ZZCOUNTRY":"","ZSEQ":"0000","NAME1_H":"ERP에 코드가 있는 고객3","B_CDATE":"0000-00-00","COUNTRY_2":"KR","WADAT":"2025-02-08","COUNTRY_1":"KR","AUART":"","MATNR_V":"SQ100","ZSDFUNC":"","WERKS":"1842","MATNR_R":"SQ100","TRANS_EXP":"","ZZAPPNO":"","EMP_NAME":"","ZFBGNO":"","GLTRI":"0000-00-00","ZFSETTLE":"","POSNR":"000030","PARRDT":"0000-00-00","HPNO":"","LGORT":"","GI_FLAG":"","COUNTRY_ST":"South Korea","ZZAPPROVAL":"","LFDAT":"2025-02-07","ZFCDNM":"","LTRMI":"0000-00-00","ZSSRED":"2024-07-31","VKBUR":"","LGORT_1":"","B_CTIME":"00:00:00","SERNR":"","LZONE":"031-069","ZINVNO":"","ZZISSUER":"","VKORG":"1800","WADAT_IST":"0000-00-00","VBELN":"0081328504","GIREQ_DT":"0000-00-00","VBELN_V":"0100474780","LZONE_T":"시흥신현285","LAND1":"","VBELN_R":"0201934766","ZZPRINT":"000","SPART":"40","AUFNR":"","VTWEG":"10","TRANAG_T":"","WBSTK":"","LFART":"ZLF","LFUHR":"18:33:00","PARRTM":"00:00:00","KUNNR_S":"0001124140","CL_DATE":"0000-00-00","CARGO_DETAIL":"","CARLC":"","ZSMS":"","VERID":"","KUNNR_H":"0001092533","ZZAPPDT":"0000-00-00","APP_NAME":"","ETD":"0000-00-00","ZFTRANSTP":"","VGPOS":"000030","ZZSTATUS":"A","B_ETD":"0000-00-00","ZSPADDR":"","B_ETA":"0000-00-00","BZIRK":"A1KR","ZZMACHIN":"","LGORT_REAL":"","CITY1":"서울특별시","TRANAG":"","ZZAPPUSER":"","VGBEL":"0201934766","COUNTRY_S":"KR"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/** TEST CODE
    */
    @IsTest
    static void IF_DELIV_001_Test() {
        InterfaceCommonUtil.setInterface('IF-DELIV-001', className);
        Test.startTest();

        // 요청 객체 생성 및 필드 설정
        IF_ERP_DELIV_Classes.IF_DELIV_001_Req request = new IF_ERP_DELIV_Classes.IF_DELIV_001_Req();

        // 기본 필드 설정
        request.I_CHK = 'Y';
        request.I_VBELN = '1234567890';
        request.I_CAPITAL_NO = 'CAP001';
        request.I_DEST = 'Destination1';
        request.I_WADAT = '2024-06-01';
        request.I_WAUHR = '10:00';
        request.I_LFDAT = '2024-06-02';
        request.I_LFUHR = '12:00';
        request.I_NOTE = 'Delivery Note';
        request.I_UNAME = 'TestUser';

        // I_USERINFO 객체 초기화 및 필드 설정
        request.I_USERINFO = new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'testuser';
        request.I_USERINFO.RNAME = 'Role1';
        request.I_USERINFO.HIER = 'Level1';
        request.I_USERINFO.KUNNR = '123456';
        request.I_USERINFO.LIFNR = '654321';
        request.I_USERINFO.VKORG = '1000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = '00';
        request.I_USERINFO.WERKS = 'PLANT1';
        request.I_USERINFO.ARBPL = 'WorkCenter1';
        request.I_USERINFO.PARNR = '001122';
        request.I_USERINFO.ENAME = 'Test Name';
        request.I_USERINFO.KUNN2 = '987654';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'Storage1';
        request.I_USERINFO.DF_CHK = 'Y';
        request.I_USERINFO.CO_CHK = 'N';

        // I_ORG 객체 초기화 및 필드 설정
        request.I_ORG = new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_I_ORG('1000', '10', '00', 'PLANT1', 'WorkCenter1', 'Control1');

        // T_PARTNER 리스트 생성 및 추가
        request.T_PARTNER = new List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_PARTNER>();
        request.T_PARTNER.add(new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_PARTNER(
            'Partner1', 'Name1', 'City1', 'Street1', '12345', 'VTEXT1', 'Read1', 'KUNNR1', 'M_Name1', 'M_City1', 'M_Street1', 'M_PostCode1'
        ));

        // T_ITEM 리스트 생성 및 추가
        request.T_ITEM = new List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_ITEM>();
        request.T_ITEM.add(new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_ITEM('0001', 'MAT001', '10', 'EA'));

        // T_DEL 리스트 생성 및 추가
        request.T_DEL = new List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_DEL>();
        request.T_DEL.add(new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_DEL('DOC001', 'File001.pdf'));

        // T_TMP 리스트 생성 및 추가
        request.T_TMP = new List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP>();
        request.T_TMP.add(new IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP('File001.pdf', 'Test Description', '123', '10', '1024'));


        // 응답 객체 생성 및 필드 설정
        IF_ERP_DELIV_Classes.IF_DELIV_001_Res response = new IF_ERP_DELIV_Classes.IF_DELIV_001_Res();
        
        // 기본 필드 설정
        response.O_VBELN = '1234567890';
        response.O_DEL_MSG = 'Delivery Successful';
        response.O_UPD_MSG = 'Update Successful';

        // O_RETURN 객체 초기화 및 필드 설정
        response.O_RETURN = new IF_ERP_DELIV_Classes.IF_DELIV_001_Res_O_RETURN('S', '200', 'Operation Completed Successfully');

        // T_RETURN 리스트 생성 및 추가
        response.T_RETURN = new List<IF_ERP_DELIV_Classes.IF_DELIV_001_Res_T_RETURN>();
        response.T_RETURN.add(new IF_ERP_DELIV_Classes.IF_DELIV_001_Res_T_RETURN('S', '200', 'Transaction Successful'));
        response.T_RETURN.add(new IF_ERP_DELIV_Classes.IF_DELIV_001_Res_T_RETURN('W', '300', 'Warning: Minor Issue'));

        IF_ERP_DELIV instance = new IF_ERP_DELIV();
        instance.IF_DELIV_001(request);

        Test.stopTest();
    }   
    @IsTest
    static void IF_DELIV_002_Test() {
        InterfaceCommonUtil.setInterface('IF-DELIV-002', className);
        Test.startTest();

        // 요청 객체 생성 및 필드 설정
        IF_ERP_DELIV_Classes.IF_DELIV_002_Req request = new IF_ERP_DELIV_Classes.IF_DELIV_002_Req();
        
        // 기본 필드 설정
        request.I_AEDAT_FR = '20240101';
        request.I_AEDAT_TO = '20240131';

        // I_USERINFO 객체 초기화 및 필드 설정
        request.I_USERINFO = new IF_ERP_DELIV_Classes.IF_DELIV_002_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TestUser';
        request.I_USERINFO.RNAME = 'TestRole';
        request.I_USERINFO.HIER = 'Manager';
        request.I_USERINFO.KUNNR = '123456';
        request.I_USERINFO.LIFNR = '789012';
        request.I_USERINFO.VKORG = '1000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = '20';
        request.I_USERINFO.WERKS = 'Factory1';
        request.I_USERINFO.ARBPL = 'WorkCenter1';
        request.I_USERINFO.PARNR = 'Partner1';
        request.I_USERINFO.ENAME = 'John Doe';
        request.I_USERINFO.KUNN2 = '654321';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'Storage1';
        request.I_USERINFO.DF_CHK = 'X';
        request.I_USERINFO.CO_CHK = 'X';

        // I_ORG 객체 초기화 및 필드 설정
        request.I_ORG = new IF_ERP_DELIV_Classes.IF_DELIV_002_Req_I_ORG();
        request.I_ORG.VKORG = '1000';
        request.I_ORG.VTWEG = '10';
        request.I_ORG.SPART = '20';
        request.I_ORG.WERKS = 'Factory1';
        request.I_ORG.ARBPL = 'WorkCenter1';
        request.I_ORG.AMSCCTL = 'Control1';

        // T_I_DELIVERY 리스트 생성 및 추가
        request.T_I_DELIVERY = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Req_T_I_DELIVERY>();
        request.T_I_DELIVERY.add(new IF_ERP_DELIV_Classes.IF_DELIV_002_Req_T_I_DELIVERY());
        request.T_I_DELIVERY[0].SIGN = 'I';
        request.T_I_DELIVERY[0].OPTION = 'EQ';
        request.T_I_DELIVERY[0].LOW = 'DEL12345';
        request.T_I_DELIVERY[0].HIGH = 'DEL67890';

        // 응답 객체 생성 및 필드 설정
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res response = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res();
        
        // O_RETURN 객체 설정
        response.O_RETURN = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '000';
        response.O_RETURN.MESSAGE = 'Success';

        // T_MATERIAL 리스트 설정
        response.T_MATERIAL = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_MATERIAL>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_MATERIAL material = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_MATERIAL();
        material.VBELN = '1234567890';
        material.POSNR = '10';
        material.MATNR = 'MAT001';
        material.ABGRU = 'A1';
        material.VKAUS = 'B2';
        material.NETWR = '1000';
        material.NETPR = '500';
        material.WAERK = 'USD';
        material.KWMENG = '50';
        material.KBMENG = '45';
        material.KLMENG = '40';
        material.VRKME = 'PC';
        material.MEINS = 'EA';
        material.WERKS = 'W001';
        material.ROUTE = 'R1';
        material.ANZSN = 'SN001';
        material.UPDATEFLAG = 'U';
        material.KZWI1 = '1';
        material.PSTYV = 'ZP';
        material.REF_DOC = 'REF123';
        material.REF_DOC_IT = 'IT123';
        material.REF_DOC_CA = 'CA123';
        material.POSEX = '0010';
        material.MAKTX = 'Material Description';
        material.KDMAT = 'KD001';
        material.VSTEL = 'V001';
        material.ZZSQCOD = 'SQ001';
        material.ZZSQTITLE = 'Special Title';
        response.T_MATERIAL.add(material);

        // T_PARTNER 리스트 설정
        response.T_PARTNER = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_PARTNER>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_PARTNER partner = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_PARTNER();
        partner.VBELN = '1234567890';
        partner.PARVW = 'SH';
        partner.NAME1 = 'Customer Name';
        partner.CITY1 = 'New York';
        partner.STREET = '5th Avenue';
        partner.POST_CODE1 = '10001';
        partner.KUNNR = 'CUST001';
        partner.ADRNR = 'ADR123';
        partner.VTEXT = 'Delivery Partner';
        partner.READ = 'Yes';
        response.T_PARTNER.add(partner);

        // T_DOC 리스트 설정
        response.T_DOC = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_DOC>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_DOC doc = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_DOC();
        doc.VBELV = '1234567890';
        doc.VBELN = '9876543210';
        doc.DOKNR = 'DOC001';
        doc.FILENAME = 'invoice.pdf';
        doc.MIMETYPE = 'application/pdf';
        doc.FILEDATA = 'BASE64ENCODEDDATA';
        doc.DESCRIPTION = 'Invoice Document';
        doc.FLAG = 'Active';
        doc.DOCNO = 'DOCNO123';
        response.T_DOC.add(doc);

        // T_ZCRMS0062 리스트 설정
        response.T_ZCRMS0062 = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_ZCRMS0062>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_ZCRMS0062 zcrms0062 = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_ZCRMS0062();
        zcrms0062.VBELN = '1234567890';
        zcrms0062.WADAT = '20240210';
        zcrms0062.WAUHR = '120000';
        zcrms0062.LFDAT = '20240215';
        zcrms0062.LFUHR = '150000';
        zcrms0062.WADAT_IST = '20240210';
        zcrms0062.ZZSTATUS = 'DELIVERED';
        zcrms0062.ZFETD = '20240212';
        zcrms0062.ZFETA = '20240214';
        zcrms0062.ZFCSHCP = 'SomeCode';
        zcrms0062.ZFCARNM = 'CarrierName';
        zcrms0062.ZFPLDVLD = 'PL123';
        zcrms0062.ZFPLDVCD = 'PL567';
        zcrms0062.ZFPLDV = 'PL890';
        response.T_ZCRMS0062.add(zcrms0062);

        // T_HEADER 리스트 설정
        response.T_HEADER = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_HEADER>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_HEADER header = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_HEADER();
        header.VBELN = '1234567890';
        header.ZTERM = 'Z001';
        header.TEXT1 = 'Payment Terms';
        header.T_EST_AMT = '5000';
        header.WAERK = 'USD';
        header.ERDAT = '20240201';
        header.BEZEI = 'Description';
        header.NAME1 = 'Company XYZ';
        header.VDATU = '20240220';
        response.T_HEADER.add(header);

        // T_CREDIT 리스트 설정
        response.T_CREDIT = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_CREDIT>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_CREDIT credit = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_CREDIT();
        credit.VBELN = '1234567890';
        credit.CREDIT_LIMIT = '10000';
        credit.OPEN_SALES = '3000';
        credit.SALES_AMT = '7000';
        credit.CREDIT = '5000';
        credit.WAERK = 'USD';
        response.T_CREDIT.add(credit);

        // T_COND 리스트 설정
        response.T_COND = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_COND>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_COND cond = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_COND();
        cond.VBELN = '1234567890';
        cond.CAPITAL_NO = 'CAP123';
        cond.IF_FROM = 'Warehouse A';
        cond.TO = 'Customer B';
        cond.FROM_TXT = 'Location A';
        cond.TO_TXT = 'Location B';
        cond.AUBEL = 'AU123';
        cond.VBELN_VA = 'VA567';
        response.T_COND.add(cond);

        // T_NOTE 리스트 설정
        response.T_NOTE = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_NOTE>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_NOTE note = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_NOTE();
        note.VBELN = '1234567890';
        note.TDFORMAT = 'PDF';
        note.TDLINE = 'This is a note.';
        response.T_NOTE.add(note);

        // T_CHANGE 리스트 설정
        response.T_CHANGE = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_CHANGE>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_CHANGE change = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_CHANGE();
        change.VBELN = '1234567890';
        change.CHANGE = 'Updated quantity';
        response.T_CHANGE.add(change);

        // T_DELINFO 리스트 설정
        response.T_DELINFO = new List<IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_DELINFO>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_DELINFO delinfo = new IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_DELINFO();
        delinfo.VBELN_VL = '1234567890';
        delinfo.SRDATE = '20240210';
        delinfo.ARDATE = '20240212';
        delinfo.STTEXT = 'Delivered successfully';
        response.T_DELINFO.add(delinfo);

        IF_ERP_DELIV instance = new IF_ERP_DELIV();
        instance.IF_DELIV_002(request);

        Test.stopTest();
    }   
    @IsTest
    static void IF_DELIV_003_Test() {
        InterfaceCommonUtil.setInterface('IF-DELIV-003', className);
        Test.startTest();

        IF_ERP_DELIV_Classes.IF_DELIV_003_Req request = new IF_ERP_DELIV_Classes.IF_DELIV_003_Req();
        request.I_INCOMING = 'test';
        request.I_VBELN = 'test';

        // 응답 객체 생성 및 필드 설정
        IF_ERP_DELIV_Classes.IF_DELIV_003_Res response = new IF_ERP_DELIV_Classes.IF_DELIV_003_Res();
        
        // O_RETURN 객체 설정
        response.O_RETURN = new IF_ERP_DELIV_Classes.IF_DELIV_003_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '000';
        response.O_RETURN.MESSAGE = 'Success';

        // T_LIST 리스트 설정
        response.T_LIST = new List<IF_ERP_DELIV_Classes.IF_DELIV_003_Res_T_LIST>();
        IF_ERP_DELIV_Classes.IF_DELIV_003_Res_T_LIST listItem = new IF_ERP_DELIV_Classes.IF_DELIV_003_Res_T_LIST();
        listItem.ZZINCOM_NO = 'INC12345';
        listItem.ZZINCOM_VER = 'V1.0';
        listItem.INCOM_CODE = 'IC56789';
        listItem.SERIAL_NO = 'SN00001';
        listItem.ZTERM = 'ZT123';
        listItem.ZZTERM = 'ZT456';
        listItem.FA_CODE = 'FA789';
        listItem.EST_DAT = '20240210';
        listItem.EST_AMT = '5000';
        listItem.PRI_AMT = '4500';
        listItem.NOTAX_INT_AMT = '4300';
        listItem.DOWN_REQ_NO = 'DRN123';
        listItem.ZRESCHE = 'RSC001';
        listItem.WAERK = 'USD';
        listItem.BASE_DATE = '20240205';
        listItem.ZBD1T = '15';
        listItem.FKDAT = '20240220';
        listItem.ZPARTIAL_BILLNO = 'PB12345';
        listItem.DPCL_AMT = '200';
        listItem.EST_DAT_OLD = '20240125';
        listItem.ZCLASS = 'ClassA';
        listItem.CLRAMT = '4900';
        listItem.ERDAT = '20240201';
        listItem.ERNAM = 'Admin';
        listItem.ERZET = '120000';
        listItem.AEDAT = '20240215';
        listItem.AENAM = 'Modifier';
        listItem.AEZET = '150000';

        // 리스트에 항목 추가
        response.T_LIST.add(listItem);

        IF_ERP_DELIV instance = new IF_ERP_DELIV();
        instance.IF_DELIV_003(request);

        Test.stopTest();
    }   
    @IsTest
    static void IF_DELIV_004_Test() {
        InterfaceCommonUtil.setInterface('IF-DELIV-004', className);
        Test.startTest();

        IF_ERP_DELIV_Classes.IF_DELIV_004_Req request = new IF_ERP_DELIV_Classes.IF_DELIV_004_Req();
        request.I_VBELN = 'test';

        // 응답 객체 생성 및 필드 설정
        IF_ERP_DELIV_Classes.IF_DELIV_004_Res response = new IF_ERP_DELIV_Classes.IF_DELIV_004_Res();

        // O_RETURN 객체 설정
        response.O_RETURN = new IF_ERP_DELIV_Classes.IF_DELIV_004_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '000';
        response.O_RETURN.MESSAGE = 'Success';

        // T_OUTPUT 리스트 설정
        response.T_OUTPUT = new List<IF_ERP_DELIV_Classes.IF_DELIV_004_Res_T_OUTPUT>();
        IF_ERP_DELIV_Classes.IF_DELIV_004_Res_T_OUTPUT outputItem = new IF_ERP_DELIV_Classes.IF_DELIV_004_Res_T_OUTPUT();
        
        outputItem.VBELN_R = 'VB12345';
        outputItem.MATNR_R = 'MAT56789';
        outputItem.SERNR = 'SN00001';
        outputItem.POSNR = '0010';
        outputItem.ZSSRED = 'ZSS01';
        outputItem.KUNNR_S = 'KUN001';
        outputItem.NAME1_S = 'Customer A';
        outputItem.KUNNR_H = 'KUN002';
        outputItem.NAME1_H = 'Customer B';
        outputItem.COUNTRY_1 = 'USA';
        outputItem.CITY1 = 'New York';
        outputItem.LZONE = 'ZL1';
        outputItem.LZONE_T = 'Zone A';
        outputItem.B_CDATE = '20240215';
        outputItem.B_CTIME = '100000';
        outputItem.B_ETD = '20240220';
        outputItem.B_ETA = '20240225';
        outputItem.VBELN_V = 'VB99887';
        outputItem.MATNR_V = 'MAT67890';
        outputItem.VBELN = 'VB11223';
        outputItem.ZFBOXSEQ = 'BX001';
        outputItem.WADAT_IST = '20240301';
        outputItem.VTWEG = 'VT1';
        outputItem.BZIRK = 'BZ100';
        outputItem.COUNTRY_2 = 'CAN';
        outputItem.COUNTRY_S = 'MEX';
        outputItem.COUNTRY_ST = 'BRZ';
        outputItem.INCO1 = 'CPT';
        outputItem.INCO2 = 'DDP';
        outputItem.CARLC = 'CR100';
        outputItem.EXDRVR = 'John Doe';
        outputItem.HPNO = 'HP5678';
        outputItem.GIREQ_DT = '20240305';
        outputItem.WERKS = 'W001';
        outputItem.VERID = 'VR123';
        outputItem.LGORT = 'L100';
        outputItem.LGORT_REAL = 'L200';
        outputItem.VGBEL = 'VG789';
        outputItem.VKBUR = 'VBUR10';
        outputItem.LAND1 = 'DEU';
        outputItem.LTRMI = 'LT01';
        outputItem.LGORT_1 = 'LG10';
        outputItem.WADAT = '20240310';
        outputItem.LFDAT = '20240315';
        outputItem.LFUHR = '150000';
        outputItem.AUFNR = 'AUF123';
        outputItem.ZINVNO = 'INV5678';
        outputItem.TRANS_EXP = 'TE001';
        outputItem.ZFTRANSTP = 'T001';
        outputItem.ZFSETTLE = 'SET01';
        outputItem.CARGO_DETAIL = 'Cargo details here';
        outputItem.ZZAPPROVAL = 'Yes';
        outputItem.ZZAPPDT = '20240312';
        outputItem.ZZAPPUSER = 'ApproverX';
        outputItem.APP_NAME = 'Approval Team';
        outputItem.EMP_NAME = 'John Smith';
        outputItem.ZZISSUEDT = '20240318';
        outputItem.ZFBGNO = 'ZFB001';
        outputItem.ZFCDNM = 'ZF Code';
        outputItem.ZZPRINT = 'Printed';
        outputItem.CL_DATE = '20240320';
        outputItem.ETD = '20240322';
        outputItem.ZSPADDR = 'Some Address';
        outputItem.TRANAG = 'Transport A';
        outputItem.TRANAG_T = 'Transport Type A';
        outputItem.ZSEQ = 'Z1001';
        outputItem.WBSTK = 'WB01';
        outputItem.VGPOS = 'VP123';
        outputItem.VKORG = 'VK001';
        outputItem.SPART = 'SP001';
        outputItem.AUART = 'AU01';
        outputItem.ZZISSUER = 'IssuerX';
        outputItem.LFART = 'LF001';
        outputItem.ZZSTATUS = 'Completed';
        outputItem.ZSDFUNC = 'FunctionA';
        outputItem.ZZAPPNO = 'APP12345';
        outputItem.ZZCOUNTRY = 'USA';
        outputItem.ZZMACHIN = 'MACH001';
        outputItem.GLTRI = 'GL123';
        outputItem.ERDAT = '20240325';
        outputItem.GI_FLAG = 'YES';
        outputItem.ZSMS = 'SMS123';

        // 리스트에 항목 추가
        response.T_OUTPUT.add(outputItem);

        IF_ERP_DELIV instance = new IF_ERP_DELIV();
        instance.IF_DELIV_004(request);

        Test.stopTest();
    }   
}