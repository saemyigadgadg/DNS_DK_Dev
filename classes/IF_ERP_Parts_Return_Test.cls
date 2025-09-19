@isTest
public with sharing class IF_ERP_Parts_Return_Test {
    private static String className = 'IF_ERP_Parts_Return';

    public IF_ERP_Parts_Return_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_017_HttpMock implements HttpCalloutMock {
        public IF_PARTS_017_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"LV_MSG":"","LT_SEARCH2":[{"CL_QTY":"88.000","MWSBP":"2.76","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"230.00","KWMENG":"-76.000","MAKTX":"WASHER;RIBBED LOCK","FKIMG":"12.000","MATNR":"P51600012","KZWI2_N":"2.30","VRKME":"EA","VBTYP_VF":"M","KZWI2":"27.60","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"2760.00","ERDAT":"2024-03-28","POSNR":"000011","WAERK":"","MATWA":"P51600012","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"97.000","MWSBP":"4.68","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"390.00","KWMENG":"-85.000","MAKTX":"BOLT,HEX SOCKET HEAD","FKIMG":"12.000","MATNR":"S2216162","KZWI2_N":"3.90","VRKME":"EA","VBTYP_VF":"M","KZWI2":"46.80","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"4680.00","ERDAT":"2024-03-28","POSNR":"000020","WAERK":"","MATWA":"S2216162","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"16.000","MWSBP":"259.95","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"86650.00","KWMENG":"-13.000","MAKTX":"POT,TOOL","FKIMG":"3.000","MATNR":"R78938","KZWI2_N":"866.50","VRKME":"EA","VBTYP_VF":"M","KZWI2":"2599.50","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"259950.00","ERDAT":"2024-03-28","POSNR":"000030","WAERK":"","MATWA":"R78938","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"6.000","MWSBP":"509.48","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"254740.00","KWMENG":"-4.000","MAKTX":"STOPPER ASSY","FKIMG":"2.000","MATNR":"C42106243B","KZWI2_N":"2547.40","VRKME":"SET","VBTYP_VF":"M","KZWI2":"5094.80","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"509480.00","ERDAT":"2024-03-28","POSNR":"000040","WAERK":"","MATWA":"C42106243B","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"8.000","MWSBP":"420.36","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"210180.00","KWMENG":"-6.000","MAKTX":"BEARING,ROLLER;CYL. D/ROW","FKIMG":"2.000","MATNR":"R11293","KZWI2_N":"2101.80","VRKME":"SET","VBTYP_VF":"M","KZWI2":"4203.60","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"420360.00","ERDAT":"2024-03-28","POSNR":"000050","WAERK":"","MATWA":"R11293","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"3.000","MWSBP":"51.46","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"51460.00","KWMENG":"-2.000","MAKTX":"VALVE,REDUCING;PRESSURE","FKIMG":"1.000","MATNR":"R30483B","KZWI2_N":"514.60","VRKME":"EA","VBTYP_VF":"M","KZWI2":"514.60","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"51460.00","ERDAT":"2024-03-28","POSNR":"000061","WAERK":"","MATWA":"R30483B","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"3.000","MWSBP":"175.77","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"58590.00","KWMENG":"0.000","MAKTX":"VALVE,SOLENOID;DOUBLE","FKIMG":"3.000","MATNR":"R30765A","KZWI2_N":"585.90","VRKME":"EA","VBTYP_VF":"M","KZWI2":"1757.70","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"175770.00","ERDAT":"2024-03-28","POSNR":"000070","WAERK":"","MATWA":"R30765A","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"0.000","MWSBP":"70.06","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"70060.00","KWMENG":"1.000","MAKTX":"CHAIN,CABLE","FKIMG":"1.000","MATNR":"130301-00945","KZWI2_N":"700.60","VRKME":"EA","VBTYP_VF":"M","KZWI2":"700.60","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"70060.00","ERDAT":"2024-03-28","POSNR":"000081","WAERK":"","MATWA":"130301-00945","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"2.000","MWSBP":"66.34","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"33170.00","KWMENG":"0.000","MAKTX":"LOCKER;ARM(BT)","FKIMG":"2.000","MATNR":"C75512223","KZWI2_N":"331.70","VRKME":"EA","VBTYP_VF":"M","KZWI2":"663.40","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"66340.00","ERDAT":"2024-03-28","POSNR":"000090","WAERK":"","MATWA":"C75512223","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"2.000","MWSBP":"10.70","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"5350.00","KWMENG":"0.000","MAKTX":"WIPER;XRL","FKIMG":"2.000","MATNR":"L31412143A","KZWI2_N":"53.50","VRKME":"EA","VBTYP_VF":"M","KZWI2":"107.00","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"10700.00","ERDAT":"2024-03-28","POSNR":"000100","WAERK":"","MATWA":"L31412143A","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"0.000","MWSBP":"55.80","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"27900.00","KWMENG":"2.000","MAKTX":"WIPER;XF","FKIMG":"2.000","MATNR":"L31412123A","KZWI2_N":"279.00","VRKME":"EA","VBTYP_VF":"M","KZWI2":"558.00","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"55800.00","ERDAT":"2024-03-28","POSNR":"000110","WAERK":"","MATWA":"L31412123A","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"0.000","MWSBP":"246.68","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"246680.00","KWMENG":"1.000","MAKTX":"SPRING,DISC","FKIMG":"1.000","MATNR":"111601-00895","KZWI2_N":"2466.80","VRKME":"SET","VBTYP_VF":"M","KZWI2":"2466.80","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"246680.00","ERDAT":"2024-03-28","POSNR":"000121","WAERK":"","MATWA":"111601-00895","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"0.000","MWSBP":"402.23","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"402230.00","KWMENG":"1.000","MAKTX":"CYLINDER,TOOL UNCLAMP","FKIMG":"1.000","MATNR":"C49044173B","KZWI2_N":"4022.30","VRKME":"EA","VBTYP_VF":"M","KZWI2":"4022.30","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"402230.00","ERDAT":"2024-03-28","POSNR":"000130","WAERK":"","MATWA":"C49044173B","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"},{"CL_QTY":"0.000","MWSBP":"67.05","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006379240","BUDAT":"2024-03-28","VKORG":"1846","NETPR":"13410.00","KWMENG":"5.000","MAKTX":"GAUGE,PRESSURE","FKIMG":"5.000","MATNR":"800112-00328","KZWI2_N":"134.10","VRKME":"EA","VBTYP_VF":"M","KZWI2":"670.50","BSTKD":"_20240328","WAERS":"KRW","VTWEG":"10","NETWR":"67050.00","ERDAT":"2024-03-28","POSNR":"000141","WAERK":"","MATWA":"800112-00328","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006379240","VSBED":"20"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_018_HttpMock implements HttpCalloutMock {
        public IF_PARTS_018_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Document 7100253530 created."},"O_VBELN":"7100253530"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_019_HttpMock implements HttpCalloutMock {
        public IF_PARTS_019_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"LV_MSG":"","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"LT_SEARCH":[{"VGBEL":"","SUBMI":"","ZZAUKON":"EMERGENCY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"16:50:34","VBELN":"2001404642","VKORG":"1846","NETPR":"51460.00","T_NETWR":"113212.00","CARR_DEC":"","BSTKD":"test_qwer_004","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDEO","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"20","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"EMERGENCY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"16:59:43","VBELN":"2001404643","VKORG":"1846","NETPR":"1107090.00","T_NETWR":"3653397.00","CARR_DEC":"","BSTKD":"test_qwer_004","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDEO","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"20","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"15:46:12","VBELN":"3001955021","VKORG":"1846","NETPR":"51460.00","T_NETWR":"56606.00","CARR_DEC":"","BSTKD":"test_qwer_001","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"15:48:05","VBELN":"3001955022","VKORG":"1846","NETPR":"51460.00","T_NETWR":"56606.00","CARR_DEC":"","BSTKD":"test_qwer_002","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"16:19:15","VBELN":"3001955024","VKORG":"1846","NETPR":"94240.00","T_NETWR":"1451296.00","CARR_DEC":"","BSTKD":"test_qwer_003","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"16:38:44","VBELN":"3001955025","VKORG":"1846","NETPR":"51460.00","T_NETWR":"452848.00","CARR_DEC":"","BSTKD":"test_qwer_004","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"16:41:17","VBELN":"3001955026","VKORG":"1846","NETPR":"51460.00","T_NETWR":"566060.00","CARR_DEC":"","BSTKD":"test_qwer_005","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"16:42:18","VBELN":"3001955027","VKORG":"1846","NETPR":"51460.00","T_NETWR":"226424.00","CARR_DEC":"","BSTKD":"test_qwer_004","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"15:58:48","VBELN":"3001955023","VKORG":"1846","NETPR":"12811680.00","T_NETWR":"14092848.00","CARR_DEC":"","BSTKD":"test_qwer_002","VTWEG":"10","VTEXT2":"Quick Service","ERDAT":"2024-10-30","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"90","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"16:26:41","VBELN":"3001955013","VKORG":"1846","NETPR":"1402360.00","T_NETWR":"1542596.00","CARR_DEC":"","BSTKD":"Purchase other dealer","VTWEG":"10","VTEXT2":"Truck","ERDAT":"2024-10-21","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"20","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"10:15:57","VBELN":"3001955009","VKORG":"1846","NETPR":"8450.00","T_NETWR":"18590.00","CARR_DEC":"","BSTKD":"Test Order2","VTWEG":"10","VTEXT2":"Domestic Express","ERDAT":"2024-10-16","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"10","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"","FKSTK":"","ERZET":"10:51:40","VBELN":"3001955008","VKORG":"1846","NETPR":"8450.00","T_NETWR":"46475.00","CARR_DEC":"","BSTKD":"Test Order","VTWEG":"10","VTEXT2":"Domestic Express","ERDAT":"2024-10-11","ZZAPPNO":"","NAME2":"","NAME1":"","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001244220","COUNT":"1","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"10","TOTALQTY":"0.000"}],"LT_SEARCH2":[{"ZZANSWER":"","BSTKD":"test_qwer_004","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"113212.00","NETPR":"51460.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"66400.00","KWMENG":"2.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R30483B","VRKME":"EA","MAKTX":"VALVE,REDUCING;PRESSURE","VKORG":"1846","POSNR":"000011","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R30483B","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDEO","VBTYP":"C","VBELN":"2001404642","ERZET":"16:50:34","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_004","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"3653397.00","NETPR":"1107090.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"1428500.00","KWMENG":"3.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"C46026043A","VRKME":"PAA","MAKTX":"GUIDE,LM;NM51HS.X.ROLLER","VKORG":"1846","POSNR":"000010","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"C46026043A","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDEO","VBTYP":"C","VBELN":"2001404643","ERZET":"16:59:43","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_001","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"56606.00","NETPR":"51460.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"66400.00","KWMENG":"1.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R30483B","VRKME":"EA","MAKTX":"VALVE,REDUCING;PRESSURE","VKORG":"1846","POSNR":"000011","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R30483B","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955021","ERZET":"15:46:12","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_002","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"56606.00","NETPR":"51460.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"66400.00","KWMENG":"1.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R30483B","VRKME":"EA","MAKTX":"VALVE,REDUCING;PRESSURE","VKORG":"1846","POSNR":"000011","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R30483B","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955022","ERZET":"15:48:05","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_003","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"1451296.00","NETPR":"94240.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"121600.00","KWMENG":"14.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"101101-00325","VRKME":"EA","MAKTX":"LEVER;WRECKING BAR(빠루)","VKORG":"1846","POSNR":"000010","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"101101-00325","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955024","ERZET":"16:19:15","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_004","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"452848.00","NETPR":"51460.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"66400.00","KWMENG":"8.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R30483B","VRKME":"EA","MAKTX":"VALVE,REDUCING;PRESSURE","VKORG":"1846","POSNR":"000011","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R30483B","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955025","ERZET":"16:38:44","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_005","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"566060.00","NETPR":"51460.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"66400.00","KWMENG":"10.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R30483B","VRKME":"EA","MAKTX":"VALVE,REDUCING;PRESSURE","VKORG":"1846","POSNR":"000011","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R30483B","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955026","ERZET":"16:41:17","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_004","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"226424.00","NETPR":"51460.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"66400.00","KWMENG":"4.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R30483B","VRKME":"EA","MAKTX":"VALVE,REDUCING;PRESSURE","VKORG":"1846","POSNR":"000011","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R30483B","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955027","ERZET":"16:42:18","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"test_qwer_002","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"14092848.00","NETPR":"12811680.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"16531200.00","KWMENG":"1.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"101507-00099E-RM","VRKME":"AY","MAKTX":"CARTRIDGE ASSY;REBUILD_NHP6300","VKORG":"1846","POSNR":"000011","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"101507-00099E-RM","ERDAT":"2024-10-30","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955023","ERZET":"15:58:48","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"Purchase other dealer","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"1542596.00","NETPR":"1402360.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"1809500.00","KWMENG":"1.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"110510-01414A","VRKME":"EA","MAKTX":"COVER,SLIDE;(YR)","VKORG":"1846","POSNR":"000010","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"110510-01414A","ERDAT":"2024-10-21","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955013","ERZET":"16:26:41","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"Test Order2","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"18590.00","NETPR":"8450.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"10900.00","KWMENG":"2.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R10014","VRKME":"EA","MAKTX":"BEARING,BALL;RADIAL","VKORG":"1846","POSNR":"000010","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R10014","ERDAT":"2024-10-16","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955009","ERZET":"10:15:57","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"Test Order","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"46475.00","NETPR":"8450.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"10900.00","KWMENG":"5.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"Not Returned","EMP_NAME":"","NFKIMG":"0.00","MATNR":"R10014","VRKME":"EA","MAKTX":"BEARING,BALL;RADIAL","VKORG":"1846","POSNR":"000010","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"Not Processed","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"R10014","ERDAT":"2024-10-11","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001955008","ERZET":"10:51:40","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_028_HttpMock implements HttpCalloutMock {
        public IF_PARTS_028_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_LIST":[{"MSGTYP":"S","VBELN":"7100253486","MSG":"SP Dom. Return Req. 7100253486 deleted"},{"MSGTYP":"S","VBELN":"7100253487","MSG":"SP Dom. Return Req. 7100253487 deleted"},{"MSGTYP":"S","VBELN":"7100253488","MSG":"SP Dom. Return Req. 7100253488 deleted"},{"MSGTYP":"S","VBELN":"7100253489","MSG":"SP Dom. Return Req. 7100253489 deleted"},{"MSGTYP":"S","VBELN":"7100253490","MSG":"SP Dom. Return Req. 7100253490 deleted"},{"MSGTYP":"S","VBELN":"7100253491","MSG":"SP Dom. Return Req. 7100253491 deleted"},{"MSGTYP":"S","VBELN":"7100253492","MSG":"SP Dom. Return Req. 7100253492 deleted"},{"MSGTYP":"S","VBELN":"7100253493","MSG":"SP Dom. Return Req. 7100253493 deleted"},{"MSGTYP":"S","VBELN":"7100253494","MSG":"SP Dom. Return Req. 7100253494 deleted"},{"MSGTYP":"S","VBELN":"7100253495","MSG":"SP Dom. Return Req. 7100253495 deleted"},{"MSGTYP":"S","VBELN":"7100253496","MSG":"SP Dom. Return Req. 7100253496 deleted"},{"MSGTYP":"S","VBELN":"7100253497","MSG":"SP Dom. Return Req. 7100253497 deleted"},{"MSGTYP":"S","VBELN":"7100253498","MSG":"SP Dom. Return Req. 7100253498 deleted"},{"MSGTYP":"S","VBELN":"7100253504","MSG":"SP Dom. Return Req. 7100253504 deleted"},{"MSGTYP":"S","VBELN":"7100253506","MSG":"SP Dom. Return Req. 7100253506 deleted"},{"MSGTYP":"S","VBELN":"7100253507","MSG":"SP Dom. Return Req. 7100253507 deleted"},{"MSGTYP":"S","VBELN":"7100253508","MSG":"SP Dom. Return Req. 7100253508 deleted"},{"MSGTYP":"S","VBELN":"7100253509","MSG":"SP Dom. Return Req. 7100253509 deleted"},{"MSGTYP":"S","VBELN":"7100253510","MSG":"SP Dom. Return Req. 7100253510 deleted"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_PARTS_017_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-017', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req request = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req();
        
        // 기본 필드 값 설정
        request.I_VKORG = '1000';
        request.I_FKART = 'ZINV';
        
        // LS_SEARCH 객체 설정
        request.LS_SEARCH = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req_LS_SEARCH();
        request.LS_SEARCH.AUART = 'OR';
        request.LS_SEARCH.BSTKD = 'PO123456';
        request.LS_SEARCH.VGBEL = '50001234';
        request.LS_SEARCH.VBELN = '60004567';
        request.LS_SEARCH.MATNR = 'MAT001';
        request.LS_SEARCH.FRDATE = '20240301';
        request.LS_SEARCH.TODATE = '20240331';
        request.LS_SEARCH.USERID = 'TESTUSER';
        request.LS_SEARCH.KUNNR = '1000001';
        request.LS_SEARCH.VKORG = '2000';
        request.LS_SEARCH.VBTYP = 'C';
        request.LS_SEARCH.WAERK = 'USD';
        request.LS_SEARCH.T_NETWR = '15000.00';
        request.LS_SEARCH.SPART = 'SP01';
        request.LS_SEARCH.COUNT = '10';
        request.LS_SEARCH.RFGSK = 'X';
        request.LS_SEARCH.FKSTK = 'Y';
        request.LS_SEARCH.KVGR5 = 'Z5';
        request.LS_SEARCH.IHREZ = 'Note123';
        request.LS_SEARCH.SUBMI = 'Submit1';
        request.LS_SEARCH.KONDA = 'P1';
        request.LS_SEARCH.XBLNR = 'ExternalDoc001';
        request.LS_SEARCH.ZZACCPTCD = 'ACCPT01';
        request.LS_SEARCH.ZZCFSTA = 'Confirmed';
        request.LS_SEARCH.ITEMLEVEL = '1';
        request.LS_SEARCH.ZLINE_STAT = 'Completed';
        request.LS_SEARCH.DVBELN = '70005678';
        request.LS_SEARCH.EFCIVNO = 'INV12345';

        // I_USERINFO 객체 설정
        request.I_USERINFO = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TESTUSER01';
        request.I_USERINFO.RNAME = 'Test User';
        request.I_USERINFO.HIER = '1';
        request.I_USERINFO.KUNNR = '2000002';
        request.I_USERINFO.LIFNR = 'LIF001';
        request.I_USERINFO.VKORG = '3000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = 'SP02';
        request.I_USERINFO.WERKS = 'W001';
        request.I_USERINFO.ARBPL = 'PlantA';
        request.I_USERINFO.PARNR = 'P001';
        request.I_USERINFO.ENAME = 'Test Partner';
        request.I_USERINFO.KUNN2 = '3000003';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'L001';
        request.I_USERINFO.DF_CHK = 'Yes';
        request.I_USERINFO.CO_CHK = 'No';

        // 응답 객체 생성
        IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res response = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res();
        
        // 기본 필드 값 설정
        response.LV_MSG = 'Success';

        // LT_SEARCH2 리스트 초기화
        response.LT_SEARCH2 = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res_LT_SEARCH2>();

        // LT_SEARCH2 객체 생성 및 값 설정
        IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res_LT_SEARCH2 search2Item = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res_LT_SEARCH2();
        search2Item.VBELN = '60004567';
        search2Item.POSNR = '000010';
        search2Item.BSTKD = 'PO123456';
        search2Item.VBELN2 = '50001234';
        search2Item.VKORG = '1000';
        search2Item.VTWEG = '10';
        search2Item.SPART = 'SP01';
        search2Item.AUBEL = '70008999';
        search2Item.AUPOS = '000020';
        search2Item.ERDAT = '20240301';
        search2Item.COUNT = '5';
        search2Item.NETWR = '12000.00';
        search2Item.WAERK = 'USD';
        search2Item.VBTYP_VF = 'N';
        search2Item.VBTYP = 'C';
        search2Item.RFGSK = 'X';
        search2Item.NETPR = '2500.00';
        search2Item.MATNR = 'MAT001';
        search2Item.KWMENG = '3';
        search2Item.MAKTX = 'Test Material';
        search2Item.VRKME = 'EA';
        search2Item.MATWA = 'Warehouse1';
        search2Item.BUDAT = '20240305';
        search2Item.FKIMG = '2';
        search2Item.WAERS = 'USD';
        search2Item.VSBED = '02';
        search2Item.MWSBP = 'TaxCode1';
        search2Item.KZWI2 = 'D1';
        search2Item.KZWI2_N = 'Discount10';
        search2Item.CL_QTY = '50';
        search2Item.KONDA = 'P1';
        search2Item.XBLNR = 'ExternalDoc123';

        // 리스트에 추가
        response.LT_SEARCH2.add(search2Item);

        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        instance.IF_PARTS_017(Request);
        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_018_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-018', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req request = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req();

        // 개별 오브젝트 초기화
        request.I_HEAD = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_I_HEAD();
        request.I_COLLECTION = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_I_COLLECTION();
        request.I_USERINFO = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_I_USERINFO();
        request.T_FILE = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE>();

        // 기본 필드 값 설정
        request.I_REF_ORDER = 'Ref12345';
        request.I_COMPLAIN = 'No';
        request.I_GUBUN = 'TypeA';
        request.I_TESTRUN = 'X';
        request.I_INQUIRY = 'Inquiry123';
        request.I_MDOWN = 'DownloadAllowed';
        request.I_EMAIL = 'test@example.com';

        // I_HEAD 값 설정
        request.I_HEAD.AUART          = 'test';
        request.I_HEAD.VKORG          = 'test';
        request.I_HEAD.VTWEG          = 'test';
        request.I_HEAD.SPART          = 'test';
        request.I_HEAD.VKBUR          = 'test';
        request.I_HEAD.VDATU          = 'test';
        request.I_HEAD.BSTKD          = 'test';
        request.I_HEAD.BZIRK          = 'test';
        request.I_HEAD.INCO1          = 'test';
        request.I_HEAD.INCO2          = 'test';
        request.I_HEAD.ZTERM          = 'test';
        request.I_HEAD.LIFSK          = 'test';
        request.I_HEAD.FAKSK          = 'test';
        request.I_HEAD.AUGRU          = 'test';
        request.I_HEAD.KVGR1          = 'test';
        request.I_HEAD.KVGR2          = 'test';
        request.I_HEAD.KVGR3          = 'test';
        request.I_HEAD.KVGR4          = 'test';
        request.I_HEAD.KVGR5          = 'test';
        request.I_HEAD.WAERK          = 'test';
        request.I_HEAD.WERKS          = 'test';
        request.I_HEAD.SUBMI          = 'test';
        request.I_HEAD.AUTLF          = 'test';
        request.I_HEAD.KNUMV          = 'test';
        request.I_HEAD.ERNAM          = 'test';
        request.I_HEAD.ZZINCOM_VER    = 'test';
        request.I_HEAD.BASE_DATE      = 'test';
        request.I_HEAD.GI_DATE        = 'test';
        request.I_HEAD.T_NETWR        = 'test';
        request.I_HEAD.T_EST_AMT      = 'test';
        request.I_HEAD.ERDAT          = 'test';
        request.I_HEAD.ERZET          = 'test';
        request.I_HEAD.BUKRS_VF       = 'test';
        request.I_HEAD.NETWR          = 'test';
        request.I_HEAD.ABRVW          = 'test';
        request.I_HEAD.REFDOCTYPE     = 'test';
        request.I_HEAD.REF_DOC        = 'test';
        request.I_HEAD.REFDOC_CAT     = 'test';
        request.I_HEAD.REF_PROC       = 'test';
        request.I_HEAD.KZAZU          = 'test';
        request.I_HEAD.BSTDK          = 'test';
        request.I_HEAD.FKDAT          = 'test';
        request.I_HEAD.VBTYP          = 'test';
        request.I_HEAD.PLTYP          = 'test';
        request.I_HEAD.VSBED          = 'test';
        request.I_HEAD.KONDA          = 'test';
        request.I_HEAD.SDABW          = 'test';
        request.I_HEAD.EQUNR          = 'test';
        request.I_HEAD.VSNMR_V        = 'test';
        request.I_HEAD.BNAME          = 'test';
        request.I_HEAD.TELF1          = 'test';
        request.I_HEAD.IHREZ          = 'test';
        request.I_HEAD.VSART          = 'test';
        request.I_HEAD.BSTKD_E        = 'test';
        request.I_HEAD.IHREZ_E        = 'test';
        request.I_HEAD.AUART_T        = 'test';
        request.I_HEAD.ZTERM_T        = 'test';
        request.I_HEAD.VSBED_T        = 'test';
        request.I_HEAD.ABRVW_T        = 'test';
        request.I_HEAD.ANGDT          = 'test';
        request.I_HEAD.BNDDT          = 'test';
        request.I_HEAD.SERGE          = 'test';
        request.I_HEAD.ZSDFUNC        = 'test';
        request.I_HEAD.ZZSTATUS       = 'test';
        request.I_HEAD.ZZUSEDCAR_NO   = 'test';
        request.I_HEAD.ZZINCOM_NO     = 'test';
        request.I_HEAD.ZZPERM_NO      = 'test';
        request.I_HEAD.ZZCAPITAL_NO   = 'test';
        request.I_HEAD.ZZPERIOD       = 'test';
        request.I_HEAD.ZZRAT_REDUCE   = 'test';
        request.I_HEAD.ZZWARRPER      = 'test';
        request.I_HEAD.ZZPERUNIT      = 'test';
        request.I_HEAD.ZZWARHRS       = 'test';
        request.I_HEAD.ZZWARRPER_B    = 'test';
        request.I_HEAD.ZZPERUNIT_B    = 'test';
        request.I_HEAD.ZZWARHRS_B     = 'test';
        request.I_HEAD.ZZWARRDAT      = 'test';
        request.I_HEAD.ZZPR_WAR       = 'test';
        request.I_HEAD.ZZPR_WAR_B     = 'test';
        request.I_HEAD.ZZCOVERAGE     = 'test';
        request.I_HEAD.ZZCOVERAGE_B   = 'test';
        request.I_HEAD.ZZSQNO         = 'test';
        request.I_HEAD.ZZTECHARG      = 'test';
        request.I_HEAD.ZZDRAFTNO      = 'test';
        request.I_HEAD.ZZAPPNO        = 'test';
        request.I_HEAD.ZZAPPNO_T      = 'test';
        request.I_HEAD.ZZCAPITAL_NO_T = 'test';
        request.I_HEAD.ZZMACNO        = 'test';
        request.I_HEAD.ZZQUINO        = 'test';
        request.I_HEAD.ZZISDAT        = 'test';
        request.I_HEAD.ZZCFSTA        = 'test';
        request.I_HEAD.ZZCFUSR        = 'test';
        request.I_HEAD.CUSTOMS_BRO    = 'test';
        request.I_HEAD.ZZURGEN        = 'test';

        // I_COLLECTION 값 설정
        request.I_COLLECTION.ZZUSEDCAR_NO = 'test';
        request.I_COLLECTION.ZZPERM_NO    = 'test';
        request.I_COLLECTION.ZZCAPITAL_NO = 'test';
        request.I_COLLECTION.MORT_CODE1   = 'test';
        request.I_COLLECTION.MORT_DATE1   = 'test';
        request.I_COLLECTION.MORT_CODE2   = 'test';
        request.I_COLLECTION.MORT_DATE2   = 'test';
        request.I_COLLECTION.MORT_CODE3   = 'test';
        request.I_COLLECTION.MORT_DATE3   = 'test';
        request.I_COLLECTION.MORT_CODE4   = 'test';
        request.I_COLLECTION.MORT_DATE4   = 'test';
        request.I_COLLECTION.MORT_CODE5   = 'test';
        request.I_COLLECTION.MORT_DATE5   = 'test';
        request.I_COLLECTION.MORT_CODE6   = 'test';
        request.I_COLLECTION.MORT_DATE6   = 'test';
        request.I_COLLECTION.ZZWARRPER    = 'test';
        request.I_COLLECTION.ZZPERUNIT    = 'test';
        request.I_COLLECTION.ZZWARHRS     = 'test';
        request.I_COLLECTION.ZZWARRDAT    = 'test';
        request.I_COLLECTION.BASE_DATE    = 'test';
        request.I_COLLECTION.WADAT_IST    = 'test';
        request.I_COLLECTION.ZZINCOM_NO   = 'test';
        request.I_COLLECTION.NETWR        = 'test';
        request.I_COLLECTION.NETWR1       = 'test';
        request.I_COLLECTION.WAERK        = 'test';
        request.I_COLLECTION.INCOM_CODE   = 'test';
        request.I_COLLECTION.ZTERM        = 'test';
        request.I_COLLECTION.EST_DAT      = 'test';
        request.I_COLLECTION.EST_AMT      = 'test';
        request.I_COLLECTION.FA_CODE      = 'test';
        request.I_COLLECTION.DOWN_REQ_NO  = 'test';
        request.I_COLLECTION.MODIFY_NETWR = 'test';
        request.I_COLLECTION.ZZPERIOD     = 'test';
        request.I_COLLECTION.ZZRAT_REDUCE = 'test';
        request.I_COLLECTION.RESIDUAL     = 'test';
        request.I_COLLECTION.ZZDRAFTNO    = 'test';

        // I_USERINFO 값 설정
        request.I_USERINFO.BNAME  = 'test';
        request.I_USERINFO.RNAME  = 'test';
        request.I_USERINFO.HIER   = 'test';
        request.I_USERINFO.KUNNR  = 'test';
        request.I_USERINFO.LIFNR  = 'test';
        request.I_USERINFO.VKORG  = 'test';
        request.I_USERINFO.VTWEG  = 'test';
        request.I_USERINFO.SPART  = 'test';
        request.I_USERINFO.WERKS  = 'test';
        request.I_USERINFO.ARBPL  = 'test';
        request.I_USERINFO.PARNR  = 'test';
        request.I_USERINFO.ENAME  = 'test';
        request.I_USERINFO.KUNN2  = 'test';
        request.I_USERINFO.LAND1  = 'test';
        request.I_USERINFO.LGORT  = 'test';
        request.I_USERINFO.DF_CHK = 'test';
        request.I_USERINFO.CO_CHK = 'test';

        // 리스트 초기화
        request.T_ITEM = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_ITEM>();
        request.T_PARTNER = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PARTNER>();
        request.T_CONFIG = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_CONFIG>();
        request.T_SEL_CONFIG = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_SEL_CONFIG>();
        request.T_PRICING = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PRICING>();
        request.T_PRICING_ADD = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PRICING_ADD>();
        request.T_PRICING_RATE = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PRICING_RATE>();
        request.T_NOTES = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_NOTES>();
        request.T_FILE = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE>();
        request.T_RETURN = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_RETURN>();
        request.T_CONDTEXT = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_CONDTEXT>();

        // T_ITEM 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_ITEM item = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_ITEM();
        item.POSNR        = 'test';
        item.UEPOS        = 'test';
        item.MATNR        = 'test';
        item.ARKTX        = 'test';
        item.ABGRU        = 'test';
        item.VKAUS        = 'test';
        item.NETWR        = 'test';
        item.NETPR        = 'test';
        item.MWST         = 'test';
        item.WAERK        = 'test';
        item.MWSBP        = 'test';
        item.KWMENG       = 'test';
        item.KBMENG       = 'test';
        item.KLMENG       = 'test';
        item.VRKME        = 'test';
        item.MEINS        = 'test';
        item.WERKS        = 'test';
        item.ROUTE        = 'test';
        item.ANZSN        = 'test';
        item.UPDATEFLAG   = 'test';
        item.KZWI1        = 'test';
        item.LIST_PRICE   = 'test';
        item.SUB_TOTAL    = 'test';
        item.PSTYV        = 'test';
        item.REF_DOC      = 'test';
        item.REF_DOC_IT   = 'test';
        item.REF_DOC_CA   = 'test';
        item.POSEX        = 'test';
        item.MAKTX        = 'test';
        item.PRSDT        = 'test';
        item.KONDA        = 'test';
        item.LGORT        = 'test';
        item.LGOBE        = 'test';
        item.VSART        = 'test';
        item.PARENT       = 'test';
        item.EDATU        = 'test';
        item.POSNRX       = 'test';
        item.TNDR_TRKID   = 'test';
        item.IHREZ_E      = 'test';
        item.ST_7020      = 'test';
        item.ZZACCPTCD    = 'test';
        item.ZZDEALDT     = 'test';
        item.ZZAPPMACHINE = 'test';
        item.ZZEQMASTER   = 'test';
        item.ZZWORKHRS    = 'test';
        item.ZZCMPCD      = 'test';
        item.ZZREASON     = 'test';
        item.ZZKMAT       = 'test';
        item.EQUIP_CHECK  = 'test';
        item.AVAIL_DATE   = 'test';
        item.VENDOR       = 'test';
        item.CARRIER      = 'test';
        item.TRACKING_NO  = 'test';
        item.VDATU        = 'test';
        item.REMARK       = 'test';
        request.T_ITEM.add(item);

        // T_PARTNER 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PARTNER partner = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PARTNER();
        partner.VBELN        = 'test';
        partner.POSNR        = 'test';
        partner.PARVW        = 'test';
        partner.KUNNR        = 'test';
        partner.NAME1        = 'test';
        partner.NAME2        = 'test';
        partner.NAME3        = 'test';
        partner.NAME4        = 'test';
        partner.STREET1      = 'test';
        partner.STREET2      = 'test';
        partner.CITY1        = 'test';
        partner.CITY2        = 'test';
        partner.STATE        = 'test';
        partner.ZIP          = 'test';
        partner.HOUSE_NUM1   = 'test';
        partner.TEL_NUMBER   = 'test';
        partner.FAX_NUMBER   = 'test';
        partner.EMAIL        = 'test';
        partner.SIC_CODE     = 'test';
        partner.MAIL_OK      = 'test';
        partner.COUNTRY      = 'test';
        partner.TZONE        = 'test';
        partner.CONTACT      = 'test';
        partner.SORT2        = 'test';
        partner.PO_BOX_LOC   = 'test';
        request.T_PARTNER.add(partner);

        // T_CONFIG 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_CONFIG config = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_CONFIG();
        config.POSNR        = 'test';
        config.ATNAM        = 'test';
        config.ATBEZ        = 'test';
        config.ZSEQNO       = 'test';
        config.SHOW         = 'test';
        config.READONLY     = 'test';
        request.T_CONFIG.add(config);

        // T_PRICING 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PRICING pricing = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_PRICING();
        pricing.POSNR = '000010';
        pricing.KSCHL = 'PR00';
        pricing.KWERT = '250.00';
        pricing.WAERK = 'USD';
        request.T_PRICING.add(pricing);

        // T_NOTES 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_NOTES note = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_NOTES();
        note.POSNR = '000010';
        note.SEQNO = '1';
        note.LINE = 'This is a test note.';
        request.T_NOTES.add(note);

        // T_FILE 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE file = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE();
        file.INT_NO = 'F1234';
        file.FILE_NAME = 'document.pdf';
        file.FILESIZE = '1024';
        request.T_FILE.add(file);

        // T_RETURN 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_RETURN ret = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_RETURN();
        ret.TYPE = 'S';
        ret.MESSAGE = 'Success';
        request.T_RETURN.add(ret);

        // T_CONDTEXT 추가
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_CONDTEXT condText = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_CONDTEXT();
        condText.MANDT = '100';
        condText.KSCHL = 'TextType1';
        condText.ZZTEXT = 'Condition text sample';
        request.T_CONDTEXT.add(condText);

        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        instance.IF_PARTS_018(Request);
        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_019_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-019', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req request = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req();

        // 개별 오브젝트 초기화
        request.LS_SEARCH = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req_LS_SEARCH();
        request.I_USERINFO = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req_I_USERINFO();

        // 기본 필드 값 설정
        request.COMPLAINT = 'No Issue';
        request.I_LANGU = 'EN';
        request.I_BGTYP = 'TypeA';
        request.I_DIBK_FLAG = 'X';

        // LS_SEARCH 값 설정
        request.LS_SEARCH.AUART = 'OR01';
        request.LS_SEARCH.BSTKD = 'PO12345';
        request.LS_SEARCH.VGBEL = 'VB123';
        request.LS_SEARCH.VBELN = 'SO98765';
        request.LS_SEARCH.MATNR = 'MAT001';
        request.LS_SEARCH.FRDATE = '20240101';
        request.LS_SEARCH.TODATE = '20240312';
        request.LS_SEARCH.USERID = 'U001';
        request.LS_SEARCH.KUNNR = 'CUST001';
        request.LS_SEARCH.VKORG = '1000';
        request.LS_SEARCH.VBTYP = 'C';
        request.LS_SEARCH.WAERK = 'USD';
        request.LS_SEARCH.T_NETWR = '1500.75';
        request.LS_SEARCH.SPART = '10';
        request.LS_SEARCH.COUNT = '5';
        request.LS_SEARCH.RFGSK = 'R01';
        request.LS_SEARCH.FKSTK = 'Y';
        request.LS_SEARCH.KVGR5 = 'K01';
        request.LS_SEARCH.IHREZ = 'Special Req';
        request.LS_SEARCH.SUBMI = 'S001';
        request.LS_SEARCH.KONDA = 'Discount';
        request.LS_SEARCH.XBLNR = 'ExternalDoc123';
        request.LS_SEARCH.ZZACCPTCD = 'Approved';
        request.LS_SEARCH.ZZCFSTA = 'Confirmed';
        request.LS_SEARCH.ITEMLEVEL = '1';
        request.LS_SEARCH.ZLINE_STAT = 'Active';
        request.LS_SEARCH.DVBELN = 'Deliver001';
        request.LS_SEARCH.EFCIVNO = 'EF789';

        // I_USERINFO 값 설정
        request.I_USERINFO.BNAME = 'UserTest';
        request.I_USERINFO.RNAME = 'Sales Rep';
        request.I_USERINFO.HIER = 'Level1';
        request.I_USERINFO.KUNNR = 'CUST001';
        request.I_USERINFO.LIFNR = 'SUPP001';
        request.I_USERINFO.VKORG = '1000';
        request.I_USERINFO.VTWEG = '20';
        request.I_USERINFO.SPART = '30';
        request.I_USERINFO.WERKS = 'Plant1';
        request.I_USERINFO.ARBPL = 'WorkCenter1';
        request.I_USERINFO.PARNR = 'Partner001';
        request.I_USERINFO.ENAME = 'John Doe';
        request.I_USERINFO.KUNN2 = 'SubCustomer';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'Storage1';
        request.I_USERINFO.DF_CHK = 'Yes';
        request.I_USERINFO.CO_CHK = 'Checked';

        // 응답 객체 생성
        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res response = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res();

        // 리스트 객체 초기화
        response.LT_SEARCH = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH>();
        response.LT_SEARCH2 = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2>();
        response.O_RETURN = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_O_RETURN();
        
        // 기본 필드 값 설정
        response.LV_MSG = 'Success';

        // LT_SEARCH 값 설정
        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH searchItem = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH();
        searchItem.AUART = 'OR01';
        searchItem.VBELN = 'SO12345';
        searchItem.BSTKD = 'PO7890';
        searchItem.VBELN2 = 'DO56789';
        searchItem.VKORG = '1000';
        searchItem.VTWEG = '20';
        searchItem.SPART = '30';
        searchItem.ERDAT = '20240312';
        searchItem.ERZET = '103000';
        searchItem.COUNT = '5';
        searchItem.T_NETWR = '2000.50';
        searchItem.WAERK = 'USD';
        searchItem.VBTYP = 'C';
        searchItem.RFGSK = 'R01';
        searchItem.FKSTK = 'Yes';
        searchItem.NETPR = '150.25';
        searchItem.VGBEL = 'DEL001';
        searchItem.ZZACCPTCD = 'Approved';
        searchItem.VTEXT = 'Order Confirmed';
        searchItem.VBELN3 = 'SO98765';
        searchItem.VSBED = 'Standard';
        searchItem.ZZAUKON = 'A001';
        searchItem.VTEXT2 = 'Delivery Scheduled';
        searchItem.KONDA = 'Discount';
        searchItem.KVGR5 = 'K01';
        searchItem.KUNNR = 'CUST001';
        searchItem.NAME_KUNNR = 'John Doe';
        searchItem.KUNWE = 'Warehouse001';
        searchItem.NAME1 = 'Warehouse A';
        searchItem.TOTALQTY = '50';
        searchItem.SUBMI = 'S001';
        searchItem.CARR_DEC = 'FedEx';
        searchItem.ZZAPPNO = 'APP123';
        searchItem.NAME2 = 'Jane Doe';
        searchItem.AUGRU = 'Reason1';

        response.LT_SEARCH.add(searchItem);

        // LT_SEARCH2 값 설정
        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2 searchItem2 = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2();
        searchItem2.AUART = 'OR02';
        searchItem2.VBELN = 'SO23456';
        searchItem2.POSNR = '10';
        searchItem2.BSTKD = 'PO54321';
        searchItem2.VBELN2 = 'DO67890';
        searchItem2.POSNR2 = '20';
        searchItem2.VKORG = '2000';
        searchItem2.VTWEG = '10';
        searchItem2.SPART = '40';
        searchItem2.ERDAT = '20240313';
        searchItem2.ERZET = '113000';
        searchItem2.COUNT = '3';
        searchItem2.T_NETWR = '5000.75';
        searchItem2.WAERK = 'EUR';
        searchItem2.VBTYP = 'B';
        searchItem2.RFGSK = 'R02';
        searchItem2.NETPR = '300.75';
        searchItem2.MATNR = 'MAT123';
        searchItem2.KWMENG = '20';
        searchItem2.MAKTX = 'Product X';
        searchItem2.VRKME = 'EA';
        searchItem2.MATWA = 'WeightX';
        searchItem2.RFGSK_TX = 'Refund Requested';
        searchItem2.RFGSK_TX_T = 'Pending';
        searchItem2.ZZACCPTCD = 'Pending Approval';
        searchItem2.VTEXT = 'Invoice Generated';
        searchItem2.VGBEL = 'INVOICE001';
        searchItem2.ZZCMPCD = 'CMP002';
        searchItem2.VBELN3 = 'SO76543';
        searchItem2.VBELN4 = 'SO87654';
        searchItem2.KBETR = '100.25';
        searchItem2.STATUS = 'In Progress';
        searchItem2.TEXT002 = 'Note 1';
        searchItem2.TEXT004 = 'Note 2';
        searchItem2.EMP_NAME = 'Agent Smith';
        searchItem2.RDATE = '20240314';
        searchItem2.IN_FREIGHT = '500.00';
        searchItem2.OUT_FREIGHT = '250.00';
        searchItem2.ZZAPPNO = 'APP456';
        searchItem2.NAME2 = 'Alice Johnson';
        searchItem2.RFGSK_TX_T1 = 'Completed';
        searchItem2.XBLNR = 'External Doc 789';
        searchItem2.FKIMG = '30';
        searchItem2.IFKIMG = '20';
        searchItem2.NFKIMG = '10';
        searchItem2.FKDAT = '20240315';
        searchItem2.ZFCIVNO = 'CIV789';
        searchItem2.ZFSEQ = 'SEQ001';
        searchItem2.ZFMBLNO = 'MBL123';
        searchItem2.ZFHBLNO = 'HBL456';
        searchItem2.ZZANSWER = 'Confirmed';

        response.LT_SEARCH2.add(searchItem2);

        // O_RETURN 값 설정
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '0000';
        response.O_RETURN.MESSAGE = 'Operation successful';
        response.O_RETURN.LOG_NO = 'LOG001';
        response.O_RETURN.LOG_MSG_NO = 'MSG123';
        response.O_RETURN.MESSAGE_V1 = 'Detail 1';
        response.O_RETURN.MESSAGE_V2 = 'Detail 2';
        response.O_RETURN.MESSAGE_V3 = 'Detail 3';
        response.O_RETURN.MESSAGE_V4 = 'Detail 4';

        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        instance.IF_PARTS_019(Request);
        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_028_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-028', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req request = new IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req();
        
        // 리스트 객체 초기화
        request.T_LIST = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req_T_LIST>();

        // 기본 필드 값 설정
        request.I_VKORG = '1000';

        // T_LIST 값 설정
        IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req_T_LIST reqItem = new IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req_T_LIST();
        reqItem.VBELN = 'SO12345';
        reqItem.MSGTYP = 'INFO';
        reqItem.MSG = 'Order Created Successfully';

        request.T_LIST.add(reqItem);

        // 응답 객체 생성
        IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res response = new IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res();
        
        // 리스트 객체 초기화
        response.T_LIST = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res_T_LIST>();

        // T_LIST 값 설정
        IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res_T_LIST resItem = new IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res_T_LIST();
        resItem.VBELN = 'SO12345';
        resItem.MSGTYP = 'SUCCESS';
        resItem.MSG = 'Order Processed Successfully';

        response.T_LIST.add(resItem);

        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        instance.IF_PARTS_028(Request);
        Test.stopTest();
    }
}