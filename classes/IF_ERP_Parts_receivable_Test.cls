@isTest
public with sharing class IF_ERP_Parts_receivable_Test {
    private static String className = 'IF_ERP_Parts_receivable';

    public IF_ERP_Parts_receivable_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_020_HttpMock implements HttpCalloutMock {
        public IF_PARTS_020_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_COUNT":"1","O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_INVOICE":[{"WRSHB":"234520.00","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"9006382937","WRBTR":"234520.00","ZFCIVNO":"","VERZN":"-55","FAEDT":"2025-03-30","WAERK":"KRW","SEQNO":"000000","SHKZG":"S","WRBTR2":"0.00","BLDAT":"2024-12-17"}],"T_INVOICE1":[{"WRSHB":"2345.20","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"","WRBTR":"2345.20","ZFCIVNO":"","VERZN":"-55","FAEDT":"2025-03-30","WAERK":"KRW","SEQNO":"000000","SHKZG":"S","WRBTR2":"0.00","BLDAT":"2024-12-17"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_023_HttpMock implements HttpCalloutMock {
        public IF_PARTS_023_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_TOTAL":"234,520","ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"select completed.","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"ET_LIST":[{"VGBEL":"8006466200","AUBEL":"3001955162","MWSBP":"21,320","FKIMG":"1","TOTAL":"234,520","MAKTX":"CENTER,LIVE","VRKME":"EA","NETWR":"213,200","WAERK":"KRW","POSNR":"000010","MATNR":"R18182"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_PARTS_020_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-020', className);

        Test.startTest();

        IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Req req = new IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Req();
        req.I_KUNNR         = 'TEMP';
        req.I_VKORG         = 'TEMP';
        req.I_VTWEG         = 'TEMP';
        req.I_SPART         = 'TEMP';
        req.I_F_VBELN       = 'TEMP';
        req.I_T_VBELN       = 'TEMP';
        req.I_F_ZFCIVNO     = 'TEMP';
        req.I_T_ZFCIVNO     = 'TEMP';
        req.I_F_BLDAT       = 'TEMP';
        req.I_T_BLDAT       = 'TEMP';
        req.I_SPRAS         = 'TEMP';
        req.I_AUART         = 'TEMP';

        IF_ERP_Parts_receivable instance = new IF_ERP_Parts_receivable();
        instance.IF_PARTS_020(req);

        IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res res = new IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res();
        res.O_MESG          = 'TEMP';
        res.O_COUNT         = 'TEMP';

        IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_O_RETURN O_RETURN = new IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_O_RETURN();
        O_RETURN.TYPE           = 'TEMP';
        O_RETURN.CODE           = 'TEMP';
        O_RETURN.MESSAGE        = 'TEMP';
        O_RETURN.LOG_NO         = 'TEMP';
        O_RETURN.LOG_MSG_NO     = 'TEMP';
        O_RETURN.MESSAGE_V1     = 'TEMP';
        O_RETURN.MESSAGE_V2     = 'TEMP';
        O_RETURN.MESSAGE_V3     = 'TEMP';
        O_RETURN.MESSAGE_V4     = 'TEMP';

        res.O_RETURN        = O_RETURN;

        IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_T_INVOICE T_INVOICE = new IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_T_INVOICE();
        T_INVOICE.VBELN         = 'TEMP';
        T_INVOICE.ZFCIVNO       = 'TEMP';
        T_INVOICE.ZTERM         = 'TEMP';
        T_INVOICE.VTEXT         = 'TEMP';
        T_INVOICE.BUZEI         = 'TEMP';
        T_INVOICE.BLDAT         = 'TEMP';
        T_INVOICE.FAEDT         = 'TEMP';
        T_INVOICE.WRBTR         = 'TEMP';
        T_INVOICE.WAERK         = 'TEMP';
        T_INVOICE.WRSHB         = 'TEMP';
        T_INVOICE.VERZN         = 'TEMP';
        T_INVOICE.SHKZG         = 'TEMP';
        T_INVOICE.WRBTR2        = 'TEMP';
        T_INVOICE.SEQNO         = 'TEMP';

        res.T_INVOICE       = new List<IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_T_INVOICE>{T_INVOICE};

        IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_T_INVOICE1 T_INVOICE1 = new IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_T_INVOICE1();
        T_INVOICE1.VBELN        = 'TEMP';
        T_INVOICE1.ZFCIVNO      = 'TEMP';
        T_INVOICE1.ZTERM        = 'TEMP';
        T_INVOICE1.VTEXT        = 'TEMP';
        T_INVOICE1.BUZEI        = 'TEMP';
        T_INVOICE1.BLDAT        = 'TEMP';
        T_INVOICE1.FAEDT        = 'TEMP';
        T_INVOICE1.WRBTR        = 'TEMP';
        T_INVOICE1.WAERK        = 'TEMP';
        T_INVOICE1.WRSHB        = 'TEMP';
        T_INVOICE1.VERZN        = 'TEMP';
        T_INVOICE1.SHKZG        = 'TEMP';
        T_INVOICE1.WRBTR2       = 'TEMP';
        T_INVOICE1.SEQNO        = 'TEMP';

        res.T_INVOICE1      = new List<IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res_T_INVOICE1>{T_INVOICE1};

        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_023_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-023', className);

        Test.startTest();

        IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Req req = new IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Req();
        req.I_VBELN     = 'TEMP';
        
        IF_ERP_Parts_receivable instance = new IF_ERP_Parts_receivable();
        instance.IF_PARTS_023(req);

        IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res res = new IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res();
        res.E_TOTAL         = 'TEMP';

        IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res_ES_RETURN ES_RETURN = new IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res_ES_RETURN();
        ES_RETURN.TYPE          = 'TEMP';
        ES_RETURN.ID            = 'TEMP';
        ES_RETURN.IF_NUMBER     = 'TEMP';
        ES_RETURN.MESSAGE       = 'TEMP';
        ES_RETURN.LOG_NO        = 'TEMP';
        ES_RETURN.LOG_MSG_NO    = 'TEMP';
        ES_RETURN.MESSAGE_V1    = 'TEMP';
        ES_RETURN.MESSAGE_V2    = 'TEMP';
        ES_RETURN.MESSAGE_V3    = 'TEMP';
        ES_RETURN.MESSAGE_V4    = 'TEMP';
        ES_RETURN.PARAMETER     = 'TEMP';
        ES_RETURN.ROW           = 'TEMP';
        ES_RETURN.FIELD         = 'TEMP';
        ES_RETURN.IF_SYSTEM     = 'TEMP';

        res.ES_RETURN       = ES_RETURN;

        IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res_ET_LIST ET_LIST = new IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res_ET_LIST();
        ET_LIST.AUBEL       = 'TEMP';
        ET_LIST.POSNR       = 'TEMP';
        ET_LIST.MATNR       = 'TEMP';
        ET_LIST.MAKTX       = 'TEMP';
        ET_LIST.FKIMG       = 'TEMP';
        ET_LIST.VRKME       = 'TEMP';
        ET_LIST.NETWR       = 'TEMP';
        ET_LIST.MWSBP       = 'TEMP';
        ET_LIST.TOTAL       = 'TEMP';
        ET_LIST.WAERK       = 'TEMP';
        ET_LIST.VGBEL       = 'TEMP';

        res.ET_LIST         = new List<IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res_ET_LIST>{ET_LIST};

        Test.stopTest();
    }
}