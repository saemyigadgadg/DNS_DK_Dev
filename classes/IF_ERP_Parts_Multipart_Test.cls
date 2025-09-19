@isTest
public with sharing class IF_ERP_Parts_Multipart_Test {
    private static String className = 'IF_ERP_Parts_Multipart';

    public IF_ERP_Parts_Multipart_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_022_HttpMock implements HttpCalloutMock {
        public IF_PARTS_022_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"30","SVCLT":"19","SVC_FLAG":"Y","NETPR":"205300.00","KWMENG":"22.000","VTEXT":"","THREAD":"#GLC 5BN","DATAB":"2024-03-02","D_MATERIAL":"M. DES-S7051","MEINS":"EA","NTGEW":"4.422","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"R18181","NOTCD_TEXT":"","MAKTX":"라이브센터","NETPR_ETC":"159110.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"99.000","COND_VALUE":"205300.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"Y","HERKL":"KR","SUB_MATERIAL":"R18182","KONDM":"P","BRGEW":"4.922","REPLACE":"X","AUMNG":"0.000"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
/* Test Method
    */
    @isTest
    private static void IF_PARTS_022_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-022', className);
        
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req request = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();

        // 기본 필드 값 설정
        request.I_LANGU = 'EN';
        request.I_KVGR5 = 'Group5';

        // 리스트 초기화
        request.D_DETAIL = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();

        // D_DETAIL 객체 생성 및 값 설정
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL detailItem = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
        detailItem.MATNR = 'MAT12345';
        detailItem.MAKTX = 'Test Material';
        detailItem.SVC_FLAG = 'X';
        detailItem.AVA_FLAG = 'A';

        detailItem.NOTCD = 'NC001';
        detailItem.COND_VALUE = '100';
        detailItem.NETPR = '200.50';
        detailItem.IF_CURRENCY = 'USD';

        detailItem.NETPR_ETC = '50';
        detailItem.CURRENCY2 = 'EUR';
        detailItem.KWMENG = '10';
        detailItem.AUMNG = '5';

        detailItem.LFMNG = '15';
        detailItem.MEINS = 'EA';
        detailItem.BRGEW = '2.5';
        detailItem.NTGEW = '2.3';

        detailItem.GEWEI = 'KG';
        detailItem.GROES = 'L';
        detailItem.PRODH = 'P001';
        detailItem.PRODH_T = 'Product Type';

        detailItem.BULET = 'Bullet Info';
        detailItem.ZPRAT = 'Rate1';
        detailItem.HERKL = 'Origin';
        detailItem.PLIFZ = '7';

        detailItem.M_MATNR = 'MAT56789';
        detailItem.C_MTPOS = 'MT001';
        detailItem.DATAB = '20250101';
        detailItem.KONDM = 'K001';

        detailItem.VTEXT = 'Some Text';
        detailItem.NOTCD_TEXT = 'Note Text';
        detailItem.SVRCD = 'SV001';
        detailItem.AVAIL_QTY = '100';

        detailItem.THREAD = 'Thread Info';
        detailItem.D_MATERIAL = 'D12345';
        detailItem.MANUFACT = 'MFG001';
        detailItem.REPLACE = 'Replacement';

        detailItem.SUB_MATERIAL = 'SM001';
        detailItem.SVCLT = 'Service Category';

        // 리스트에 추가
        request.D_DETAIL.add(detailItem);

        // 사용자 정보 객체 생성
        request.I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TestUser';
        request.I_USERINFO.RNAME = 'Tester';
        request.I_USERINFO.HIER = 'Admin';
        request.I_USERINFO.KUNNR = 'K12345';
        request.I_USERINFO.LIFNR = 'L67890';

        request.I_USERINFO.VKORG = '1000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = '20';
        request.I_USERINFO.WERKS = 'W001';
        request.I_USERINFO.ARBPL = 'A001';

        request.I_USERINFO.PARNR = 'P001';
        request.I_USERINFO.ENAME = 'John Doe';
        request.I_USERINFO.KUNN2 = 'K98765';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'L001';

        request.I_USERINFO.DF_CHK = 'X';
        request.I_USERINFO.CO_CHK = 'Y';

        // 응답 객체 생성
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res response = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res();

        // 리스트 초기화
        response.D_DETAIL = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL>();
        response.T_RETURN = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_T_RETURN>();

        // D_DETAIL 객체 생성 및 값 설정
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL detailItemRes = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL();
        detailItemRes.MATNR = 'MAT12345';
        detailItemRes.MAKTX = 'Test Material';
        detailItemRes.SVC_FLAG = 'X';
        detailItemRes.AVA_FLAG = 'A';

        detailItemRes.NOTCD = 'NC001';
        detailItemRes.COND_VALUE = '100';
        detailItemRes.NETPR = '200.50';
        detailItemRes.IF_CURRENCY = 'USD';

        detailItemRes.NETPR_ETC = '50';
        detailItemRes.CURRENCY2 = 'EUR';
        detailItemRes.KWMENG = '10';
        detailItemRes.AUMNG = '5';

        detailItemRes.LFMNG = '15';
        detailItemRes.MEINS = 'EA';
        detailItemRes.BRGEW = '2.5';
        detailItemRes.NTGEW = '2.3';

        detailItemRes.GEWEI = 'KG';
        detailItemRes.GROES = 'L';
        detailItemRes.PRODH = 'P001';
        detailItemRes.PRODH_T = 'Product Type';

        detailItemRes.BULET = 'Bullet Info';
        detailItemRes.ZPRAT = 'Rate1';
        detailItemRes.HERKL = 'Origin';
        detailItemRes.PLIFZ = '7';

        detailItemRes.M_MATNR = 'MAT56789';
        detailItemRes.C_MTPOS = 'MT001';
        detailItemRes.DATAB = '20250101';
        detailItemRes.KONDM = 'K001';

        detailItemRes.VTEXT = 'Some Text';
        detailItemRes.NOTCD_TEXT = 'Note Text';
        detailItemRes.SVRCD = 'SV001';
        detailItemRes.AVAIL_QTY = '100';

        detailItemRes.THREAD = 'Thread Info';
        detailItemRes.D_MATERIAL = 'D12345';
        detailItemRes.MANUFACT = 'MFG001';
        detailItemRes.REPLACE = 'Replacement';

        detailItemRes.SUB_MATERIAL = 'SM001';
        detailItemRes.SVCLT = 'Service Category';
        detailItemRes.MIN_QTY = '5';

        // 리스트에 추가
        response.D_DETAIL.add(detailItemRes);

        // O_RETURN 객체 생성 및 값 설정
        response.O_RETURN = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_O_RETURN();
        response.O_RETURN.TYPE = 'Success';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Operation Completed Successfully';

        // T_RETURN 객체 생성 및 값 설정
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_T_RETURN returnItem = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_T_RETURN();
        returnItem.TYPE = 'Error';
        returnItem.CODE = '500';
        returnItem.MESSAGE = 'Internal Server Error';

        // 리스트에 추가
        response.T_RETURN.add(returnItem);

        IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
        instance.IF_PARTS_022(request);
        Test.stopTest();
    }
}