@isTest
public with sharing class IF_ERP_Parts_Pending_Test{
    private static String className = 'IF_ERP_Parts_Pending';

    public IF_ERP_Parts_Pending_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_021_HttpMock implements HttpCalloutMock {
        public IF_PARTS_021_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody =
            '{'+
                '"O_MESG":"Successfully finished.[ZSS90101]",'+
                '"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},'+
                '"T_RECEIPT":['+
                    '{"FAEDT":"2024-06-29","WRBTR_OVERDUE":"0.00","SHKZG":"H","WAERK":"KRW","WRBTR3":"0.00","WRBTR2":"0.00","WRBTR":"-3210054.00","WRSHB":"-3210054.00"},'+
                    '{"FAEDT":"2024-06-29","WRBTR_OVERDUE":"0.00","SHKZG":"S","WAERK":"KRW","WRBTR3":"0.00","WRBTR2":"0.00","WRBTR":"49527951.00","WRSHB":"49527951.00"},'+
                    '{"FAEDT":"2024-07-30","WRBTR_OVERDUE":"0.00","SHKZG":"S","WAERK":"KRW","WRBTR3":"0.00","WRBTR2":"0.00","WRBTR":"11087945.00","WRSHB":"11087945.00"}'+
                ']'+
            '}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_PARTS_021_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-021', className);
        
        Test.startTest();

        IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req req = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req();
        req.I_USERID            = 'TEMP';
        req.I_FAEDT             = 'TEMP';

        IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req_I_USERINFO();
        I_USERINFO.BNAME        = 'MKRP0024';
        I_USERINFO.RNAME        = 'MKRP0024';
        I_USERINFO.KUNNR        = '1244220';
        I_USERINFO.VKORG        = '1846';
        I_USERINFO.VTWEG        = '10';
        I_USERINFO.SPART        = '40';
        I_USERINFO.LAND1        = 'KR';
        I_USERINFO.DF_CHK       = 'X';

        I_USERINFO.HIER         = 'TEMP';
        I_USERINFO.LIFNR        = 'TEMP';
        I_USERINFO.WERKS        = 'TEMP';
        I_USERINFO.ARBPL        = 'TEMP';
        I_USERINFO.PARNR        = 'TEMP';
        I_USERINFO.ENAME        = 'TEMP';
        I_USERINFO.KUNN2        = 'TEMP';
        I_USERINFO.LGORT        = 'TEMP';
        I_USERINFO.CO_CHK       = 'TEMP';

        req.I_USERINFO          = I_USERINFO;

        IF_ERP_Parts_Pending instance = new IF_ERP_Parts_Pending();
        instance.IF_PARTS_021(req);

        IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res res = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res();
        res.O_MESG      = 'TEMP';
        res.O_COUNT     = 'TEMP';

        IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_O_RETURN O_RETURN = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_O_RETURN();
        O_RETURN.TYPE        = 'TEMP';
        O_RETURN.CODE        = 'TEMP';
        O_RETURN.MESSAGE     = 'TEMP';
        O_RETURN.LOG_NO      = 'TEMP';
        O_RETURN.LOG_MSG_NO  = 'TEMP';
        O_RETURN.MESSAGE_V1  = 'TEMP';
        O_RETURN.MESSAGE_V2  = 'TEMP';
        O_RETURN.MESSAGE_V3  = 'TEMP';
        O_RETURN.MESSAGE_V4  = 'TEMP';

        res.O_RETURN    = O_RETURN;

        IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_T_RECEIPT T_RECEIPT = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_T_RECEIPT();
        T_RECEIPT.FAEDT         = 'TEMP';
        T_RECEIPT.WRBTR         = 'TEMP';
        T_RECEIPT.WRBTR2        = 'TEMP';
        T_RECEIPT.WRBTR3        = 'TEMP';
        T_RECEIPT.WAERK         = 'TEMP';
        T_RECEIPT.WRSHB         = 'TEMP';
        T_RECEIPT.WRBTR_OVERDUE = 'TEMP';
        T_RECEIPT.SHKZG         = 'TEMP';
        
        res.T_RECEIPT   = new List<IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_T_RECEIPT>{T_RECEIPT};
        
        IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_T_LIST T_LIST = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_T_LIST();
        T_LIST.VBELN    = 'TEMP';
        T_LIST.XBLNR    = 'TEMP';
        T_LIST.FAEDT    = 'TEMP';
        T_LIST.WRBTR    = 'TEMP';
        T_LIST.WRBTR2   = 'TEMP';
        T_LIST.WRBTR3   = 'TEMP';
        T_LIST.WAERK    = 'TEMP';
        T_LIST.WRSHB    = 'TEMP';
        T_LIST.FKDAT    = 'TEMP';

        res.T_LIST      = new List<IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res_T_LIST>{T_LIST};

        Test.stopTest();
    }
    
}