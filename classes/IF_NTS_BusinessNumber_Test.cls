@isTest
public with sharing class IF_NTS_BusinessNumber_Test {
    private static String className = 'IF_NTS_BusinessNumber';

    public IF_NTS_BusinessNumber_Test() {}

/* Mock Classes
    */
    public class NTS_BusinessNumber_HttpMock implements HttpCalloutMock {
        public NTS_BusinessNumber_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"request_cnt":1,"match_cnt":1,"status_code":"OK","data":[{"b_no":"1370438219","b_stt":"계속사업자","b_stt_cd":"01","tax_type":"부가가치세 일반과세자","tax_type_cd":"01","end_dt":"","utcc_yn":"N","tax_type_change_dt":"","invoice_apply_dt":"","rbf_tax_type":"해당없음","rbf_tax_type_cd":"99"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @isTest
    public static void classTestCoverage(){
        IF_NTS_BusinessNumber_Class.GetBusinessNumberRes res = new IF_NTS_BusinessNumber_Class.GetBusinessNumberRes();
        res.status_code = '';
        res.request_cnt = '';
        res.match_cnt = '';

        IF_NTS_BusinessNumber_Class.Data b = new IF_NTS_BusinessNumber_Class.Data();
        
        b.b_no = '';
        b.b_stt = '';
        b.b_stt_cd = '';
        b.tax_type = '';
        b.tax_type_cd = '';
        b.end_dt = '';
        b.utcc_yn = '';
        b.tax_type_change_dt = '';
        b.invoice_apply_dt = '';
        b.rbf_tax_type = '';

        res.data = new List<IF_NTS_BusinessNumber_Class.Data>{b};
        InterfaceCommonUtil.setInterface('NTS_BusinessNumber', 'IF_NTS_BusinessNumber');
        
        Test.startTest();
        IF_NTS_BusinessNumber.getBusinessNumber('');
        Test.stopTest();
    }
}