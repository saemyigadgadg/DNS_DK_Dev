/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class IF_ERP_Parts_Order_Test {
    private static String className = 'IF_ERP_Parts_Order';

    public IF_ERP_Parts_Order_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_001_HttpMock implements HttpCalloutMock {
        public IF_PARTS_001_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_KDGRP":"","T_ZSSV0002":[{"ZZAUKON":"ORDINARY ORDER","DEFFLG":"X","AUART":"YDOR","VBTYP":"C","KDGRP":"02","VTEXT":"긴급주문","STATUS":"X","KONDA":"28","VTWEG":"10","VKORG":"1846","RDDAT":"2025-01-15","SPART":"40"},{"ZZAUKON":"EMERGENCY ORDER","DEFFLG":"X","AUART":"YDEO","VBTYP":"C","KDGRP":"02","VTEXT":"긴급주문","STATUS":"X","KONDA":"20","VTWEG":"10","VKORG":"1846","RDDAT":"2025-01-15","SPART":"40"},{"ZZAUKON":"STOCK ORDER","DEFFLG":"X","AUART":"YDSO","VBTYP":"C","KDGRP":"02","VTEXT":"Commission Order","STATUS":"X","KONDA":"40","VTWEG":"10","VKORG":"1846","RDDAT":"2025-02-09","SPART":"40"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_003_HttpMock implements HttpCalloutMock {
        public IF_PARTS_003_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_MEG":"","LS_MAIN_HEAD_RESULT":{"KONDA":"28","KUNNR":"0001057644","KUNNR_NAME":"","KUNNR_STREET":"","KUNAG":"0001057644","KUNAG_NAME":"","KUNAG_STREET":"","KUNNR_CR":"","NETWR":"175021.00","WAERK":"KRW","CREDIT":"419014415.00","CREDIT_WAERK":"KRW","TOTAL_WEIGHT":"90.000","GEWEI":"KG","VOLUM":"0.000","VOLEH":"CBM","KONDA_TEXT":"","KVGR5":"40","NAME":"","CITY":"","STREET":"","COUNTRY":"","POSTL_CODE":"","TRANSPZONE":"","ORDER_DATE":"0000-00-00","PRICE_LIST":"","COLLECT_NO":"","ZTERM":"","ORD_REASON":"","BZIRK":"","DOCUFEE":""},"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"LS_GENERAL":{"BSTNK":"","VDATU":"2025-06-02","INCO1":"","INCO2":"","VSBED":"","COMPLETE_DELIVERY":"","ROUTE":"","VSBED_TX":"","ROUTE_TX":"","SPECPROCID":"","POSSIBLE_DATE":"2025-06-02","IF_FROM":"0000-00-00","TO":"0000-00-00","AUDAT":"0000-00-00","ERZET":"00:00:00","BSTKD_E":"","ZZCFDAT":"0000-00-00"},"ERRORMSG":[],"LT_BAPIRET2":[{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_HEADER_IN","MESSAGE":"SALES_HEADER_IN has been processed successfully","FIELD":"","ROW":"0","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"VBAKKOM"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_ITEM_IN","MESSAGE":"SALES_ITEM_IN has been processed successfully","FIELD":"","ROW":"1","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"555","PARAMETER":"VBUVKOM","MESSAGE":"The sales document is not yet complete: Edit data","FIELD":"","ROW":"0","TYPE":"W","ID":"V1","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"}],"LT_ITEM":[{"COMPLAINT":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"N","HERKL":"KR","MATERIAL_ENT":"R18181","UOM":"EA","GEWEI":"KG","BULLETIN":"X","NET_PRICE":"159110.00","NET_ITEM_PRICE":"159110.00","MITEM":"","MEMO_MATNR":"","EMERC":"","USAGE_HILV":"","ZZEQMASTER":"","MATERIAL_TEXT":"라이브센터","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"DNS Parts","REF_ORD":"","CCHECK":"","MATERIAL":"R18181","QTY":"1.000","ZZDEALDT":"0000-00-00","BSTKD_E":"","WAERS":"","TDLNR":"","IF_CURRENCY":"KRW","ZZWORKHRS":"","NET_VALUE":"159110.00","KUNNR":"","MATNR_CHECK":"X","MATERIAL_N":"","R":"","INPUT_QTY":"1.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"X","REF_ITEM":"000000","TNDR_TRKID":"","NTGEW":"4.422","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000010","SUGRD":"","CHEKCABLE":"","ACCEPT":"","AVAIL_QTY2":"73.000","AVAIL_QTY1":"0.000","REQ_QTY":"1.000","PLANT":"1846","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","TDLNR_NAME":"","DIUKL":"0.000","BO":"","MEINS":"","STATUS":"","MVGR5":"","BD":"","MEMO":"","MATNR_DESIGN":"00","BULL_MATNR":"R18181","BSTDK_E":"0000-00-00"}],"LT_NON_EXIST":[],"LT_NON_PRICE":[],"LT_NON_PURCHASE":[],"LT_NON_QTY":[],"LT_PRICING_01":[{"NETWR":"0.00","WAERK":"KRW","NAME":"Item Total (A)","NEWR":"159110.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Freight(B)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Insurance(C)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Handling Charge(D)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Output Tax(E)","NEWR":"15911.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Total Amt(A+B+C+D+E)","NEWR":"175021.00"}],"LT_PRICING_02":[{"NETWR":"1591.10","WAERK":"KRW","NAME":"Item Total(Doosan) (A-F)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Commission value(F)","NEWR":"0.00"}],"LT_STATUS":[],"LT_WRONG_DIVISION":[],"LT_WRONG_ITEM":[],"IF_RETURN":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_005_HttpMock implements HttpCalloutMock {
        public IF_PARTS_005_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_MEG":"Dom Ordinary Order 3001955308 has been saved","LS_MAIN_HEAD_RESULT":{"KONDA":"","KUNNR":"","KUNNR_NAME":"","KUNNR_STREET":"","KUNAG":"","KUNAG_NAME":"","KUNAG_STREET":"","KUNNR_CR":"","NETWR":"0.00","WAERK":"","CREDIT":"0.00","CREDIT_WAERK":"","TOTAL_WEIGHT":"0.000","GEWEI":"","VOLUM":"0.000","VOLEH":"","KONDA_TEXT":"","KVGR5":"","NAME":"","CITY":"","STREET":"","COUNTRY":"","POSTL_CODE":"","TRANSPZONE":"","ORDER_DATE":"0000-00-00","PRICE_LIST":"","COLLECT_NO":"","ZTERM":"","ORD_REASON":"","BZIRK":"","DOCUFEE":""},"LV_VENLR":"3001955308","LT_BAPIRET2":[{"SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","NUMBER":"311","PARAMETER":"SALES_HEADER_IN","MESSAGE":"Dom Ordinary Order 3001955308 has been saved","FIELD":"","ROW":"0","TYPE":"S","ID":"V1","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"3001955308","MESSAGE_V1":"Dom Ordinary Order"},{"SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","NUMBER":"233","PARAMETER":"SALES_HEADER_IN","MESSAGE":"SALES_HEADER_IN has been processed successfully","FIELD":"","ROW":"0","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"VBAKKOM"},{"SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","NUMBER":"233","PARAMETER":"SALES_ITEM_IN","MESSAGE":"SALES_ITEM_IN has been processed successfully","FIELD":"","ROW":"1","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_007_HttpMock implements HttpCalloutMock {
        public IF_PARTS_007_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"LV_MSG":"Successfully finished.[ZSS90101]","LT_SEARCH":[{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"0001057644","FKSTK":"","ERZET":"09:09:21","VBELN":"3001950782","VKORG":"1846","NETPR":"85720.00","T_NETWR":"161007.00","CARR_DEC":"","BSTKD":"_20240302","VTWEG":"10","VTEXT2":"Truck","ERDAT":"2024-03-02","ZZAPPNO":"","NAME2":"","NAME1":"링엔지니어링","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001057644","COUNT":"5","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"20","TOTALQTY":"0.000"},{"VGBEL":"","SUBMI":"","ZZAUKON":"ORDINARY ORDER","ZZACCPTCD":"","AUGRU":"","NAME_KUNNR":"","KVGR5":"40","SPART":"40","KUNWE":"0001057644","FKSTK":"","ERZET":"10:52:44","VBELN":"3001950783","VKORG":"1846","NETPR":"2176140.00","T_NETWR":"3391883.00","CARR_DEC":"","BSTKD":"_20240302","VTWEG":"10","VTEXT2":"Truck","ERDAT":"2024-03-02","ZZAPPNO":"","NAME2":"","NAME1":"링엔지니어링","WAERK":"KRW","AUART":"YDOR","KUNNR":"0001057644","COUNT":"5","VTEXT":"","VBELN3":"","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","VSBED":"20","TOTALQTY":"0.000"}],"LT_SEARCH2":[{"ZZANSWER":"","BSTKD":"_20240302","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"21912.00","NETPR":"19920.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"25700.00","KWMENG":"1.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"","EMP_NAME":"","NFKIMG":"0.00","MATNR":"L29561134","VRKME":"EA","MAKTX":"","VKORG":"1846","POSNR":"000010","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"L29561134","ERDAT":"2024-03-02","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001950782","ERZET":"09:09:21","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"},{"ZZANSWER":"","BSTKD":"_20240302","ZZCMPCD":"","ZFSEQ":"000000","ZZAPPNO":"","RFGSK":"","STATUS":"","T_NETWR":"1705.00","NETPR":"310.00","ZFMBLNO":"","FKIMG":"0.00","KBETR":"400.00","KWMENG":"5.000","WAERK":"KRW","ZZACCPTCD":"","OUT_FREIGHT":"0.00","VTEXT":"","NAME2":"","POSNR2":"000000","TEXT004":"","TEXT002":"","RFGSK_TX_T1":"","EMP_NAME":"","NFKIMG":"0.00","MATNR":"P80300145","VRKME":"EA","MAKTX":"","VKORG":"1846","POSNR":"000020","VTWEG":"10","VGBEL":"","ZFHBLNO":"","FKDAT":"0000-00-00","RFGSK_TX_T":"","ZFCIVNO":"","IN_FREIGHT":"0.00","RDATE":"0000-00-00","MATWA":"P80300145","ERDAT":"2024-03-02","VBELN4":"","VBELN3":"","VBELN2":"","XBLNR":"","COUNT":"1","AUART":"YDOR","VBTYP":"C","VBELN":"3001950782","ERZET":"09:09:21","SPART":"40","RFGSK_TX":"","IFKIMG":"0.00"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_008_HttpMock implements HttpCalloutMock {
        public IF_PARTS_008_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_MDOWN":"","E_MEG":"","E_VSART_TX":"","I_INQUIRY":"","LS_FIRST":{},"LS_GENERAL":{"BSTNK":"3001949606","VDATU":"2024-03-11","INCO1":"EXW","INCO2":"Changwon","VSBED":"99","COMPLETE_DELIVERY":"","ROUTE":"160740","VSBED_TX":"","ROUTE_TX":"","SPECPROCID":"","POSSIBLE_DATE":"2024-03-11","FROM":"0000-00-00","TO":"0000-00-00","AUDAT":"2024-03-11","ERZET":"23:50:54","BSTKD_E":"","ZZCFDAT":"0000-00-00"},"LS_MAIN_HEAD_RESULT":{"KONDA":"28","KUNNR":"0001057644","KUNNR_NAME":"링엔지니어링","KUNNR_STREET":"대저2동 부산티플렉스131동 117,217,118,218호","KUNAG":"0001057644","KUNAG_NAME":"링엔지니어링","KUNAG_STREET":"대저2동 부산티플렉스131동 117,217,118,218호","NETWR":"440660.00","NETWR1":"4406.60","WAERK":"KRW","CREDIT":"0.00","CREDIT_WAERK":"KRW","TOTAL_WEIGHT":"0.000","POUND":"0.000","GEWEI":"KG","VOLUM":"0.000","VOLEH":"CBM","KONDA_TEXT":"","KVGR5":"40","NAME":"링엔지니어링","CITY":"부산광역시 강서구 유통단지1로 41","STREET":"대저2동 부산티플렉스131동 117,217,118,218호","COUNTRY":"KR","POSTL_CODE":"46721","TRANSPZONE":"051-002","TELEPHONE":"051-831-1204","ZZAPPNO":"","NAME2":"","SUBMI":"","CARR_DEC":"","VSNMR_V":"","BNAME":"","TELF1":"051-831-1204","IHREZ":"","BSTDK_E":"0000-00-00","BSTDK":"0000-00-00","AUGRU":"","AUGRU_T":"","ABRVW":"","PLTYP":"10","FREIGHT":"0.00","BNDDT":"0000-00-00","AUART_T":"CLAIM RETURN(ORDINARY ORDER)","XBLNR":"","ZZMACNO":"","ZZQUINO":"","ZZISDAT":"0000-00-00","ZZCFSTA":"","ZZCFSTA_T":"","ZZCFUSR":"","ZZCFUSR_T":"","STATUS":"","ZZURGEN":"","ZZURGEN_TEXT":""},"LV_ADDRESS":"","LV_ONETIME":"","LV_REMARK":"","LV_SCAT":"","O_FORWARDER":"","O_NAME1":"","O_TOTAL":"440660.00","ERRORMSG":[],"LT_CONDITION":[{"KMEIN":"EA","VARCOND":"","KBETR":"2843.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"5686.00","KPEIN":"1","STUNR":"010","KSCHL":"YB00","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"Y","POSNR":"000010","WAERK":"KRW","KRECH":"C"},{"KMEIN":"","VARCOND":"","KBETR":"-225.00","KAWRT":"5686.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"-1279.35","KPEIN":"0","STUNR":"110","KSCHL":"YAI0","ZWAERS":"%","WAERS":"","KAPPL":"V","KINAK":"Y","POSNR":"000010","WAERK":"KRW","KRECH":"A"},{"KMEIN":"EA","VARCOND":"","KBETR":"2203.33","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"-0.05","KPEIN":"1","STUNR":"390","KSCHL":"YRNP","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"Y","POSNR":"000010","WAERK":"KRW","KRECH":"C"},{"KMEIN":"EA","VARCOND":"","KBETR":"0.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"0.00","KPEIN":"1","STUNR":"435","KSCHL":"YRNF","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"Y","POSNR":"000010","WAERK":"KRW","KRECH":"C"},{"KMEIN":"EA","VARCOND":"","KBETR":"0.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"0.00","KPEIN":"1","STUNR":"480","KSCHL":"YRNH","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"Y","POSNR":"000010","WAERK":"KRW","KRECH":"C"},{"KMEIN":"EA","VARCOND":"","KBETR":"2203.30","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"4406.60","KPEIN":"1","STUNR":"498","KSCHL":"YBSR","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"Y","POSNR":"000010","WAERK":"KRW","KRECH":"C"},{"KMEIN":"EA","VARCOND":"","KBETR":"2203.30","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"4406.60","KPEIN":"1","STUNR":"500","KSCHL":"YSN1","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"G"},{"KMEIN":"","VARCOND":"","KBETR":"100.00","KAWRT":"4406.60","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"440.66","KPEIN":"0","STUNR":"910","KSCHL":"MWST","ZWAERS":"%","WAERS":"","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"A"},{"KMEIN":"EA","VARCOND":"","KBETR":"1643.30","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"3286.60","KPEIN":"1","STUNR":"940","KSCHL":"YVPR","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"C"},{"KMEIN":"EA","VARCOND":"","KBETR":"0.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"5686.00","KPEIN":"1","STUNR":"981","KSCHL":"YSCG","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"G"},{"KMEIN":"EA","VARCOND":"","KBETR":"0.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"-1279.40","KPEIN":"1","STUNR":"983","KSCHL":"YSCD","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"G"},{"KMEIN":"EA","VARCOND":"","KBETR":"0.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"5686.00","KPEIN":"1","STUNR":"991","KSCHL":"YSL0","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"G"},{"KMEIN":"EA","VARCOND":"","KBETR":"0.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"5686.00","KPEIN":"1","STUNR":"993","KSCHL":"YSG0","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"G"},{"KMEIN":"EA","VARCOND":"","KBETR":"0.00","KAWRT":"20.00","ZAEHK":"01","UPDATEFLAG":"","KPOSN":"000010","KWERT":"4406.60","KPEIN":"1","STUNR":"997","KSCHL":"YSN0","ZWAERS":"KRW","WAERS":"KRW","KAPPL":"V","KINAK":"","POSNR":"000010","WAERK":"KRW","KRECH":"G"}],"LT_FILE":[],"LT_FILE2":[{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@53886e88","VISIBLE":"","FILE_NO":"1","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@2210cd90","VISIBLE":"","FILE_NO":"2","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@7d27ba68","VISIBLE":"","FILE_NO":"3","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@3b3f4209","VISIBLE":"","FILE_NO":"4","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@36087b42","VISIBLE":"","FILE_NO":"5","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@66d445c4","VISIBLE":"","FILE_NO":"6","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@7a307b99","VISIBLE":"","FILE_NO":"7","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@502b87b","VISIBLE":"","FILE_NO":"8","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@759d95ce","VISIBLE":"","FILE_NO":"9","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@3cd643b5","VISIBLE":"","FILE_NO":"10","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@16f73f47","VISIBLE":"","FILE_NO":"11","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@425b5a18","VISIBLE":"","FILE_NO":"12","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@7b77ffb0","VISIBLE":"","FILE_NO":"13","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@333bb24","VISIBLE":"","FILE_NO":"14","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@39433a20","VISIBLE":"","FILE_NO":"15","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@6c9d283e","VISIBLE":"","FILE_NO":"16","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@41bd3627","VISIBLE":"","FILE_NO":"17","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@6d2e5c28","VISIBLE":"","FILE_NO":"18","CHECK":"","INT_NO":"0"},{"DOCU_ITEM":"000000","FILE_NAME":"","FILESIZE":"000000000000","DESCRIPTION":"","FILE_DATA":"[B@7ea47e17","VISIBLE":"","FILE_NO":"19","CHECK":"","INT_NO":"0"}],"LT_GERNERAL_ZTERM":[],"LT_ITEM":[{"SHIP_QTY":"0.000","COMPLAINT":"D","RMADT":"0000-00-00","KONDM":"","NETPR":"0.00","AVAILABILITY":"N","HERKL":"","MATERIAL_ENT":"R42220","SHIP_LOC":"KOREA","UOM":"EA","SPEC":"","GEWEI":"KG","BULLETIN":"","NET_PRICE":"220330.00","NET_ITEM_PRICE":"220330.00","MITEM":"","MEMO_MATNR":"","EMERC":"","USAGE_HILV":"","BILL_QTY":"0.000","ZZEQMASTER":"","PARTIAL_QTY":"0.000","KDMAT":"","CORE_PARTS":"0.00","MATERIAL_TEXT":"에어실린더","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"DNS Parts","REF_ORD":"7100252410","CCHECK":"","MATERIAL":"R42220","QTY":"2.000","ZZDEALDT":"2024-02-23","TEXT4_SH":"","BSTKD_E":"3001949606","WAERS":"","RMANO":"","TDLNR":"","TKNUM":"","CURRENCY":"KRW","ZZWORKHRS":"","DIS_PRICE":"0.00","TPBEZ":"","NET_VALUE":"440660.00","KUNNR":"","MATNR_CHECK":"","MATERIAL_N":"","R":"","INPUT_QTY":"0.000","COMPLAINT_DESC":"청구착오","LIST_PRICE":"284300.00","DI":"0.000","O":"","EXCEL":"","RMAST":"","REF_ITEM":"000010","TNDR_TRKID":"","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"D01","COMPLAINT_REASON":"","VBELN_V":"","D":"","C":"","A":"","ITEM":"000010","SUGRD":"","POSEX":"","CHEKCABLE":"","ACCEPT":"","AVAIL_QTY1":"0.000","REQ_QTY":"2.000","SHIP_VIA":"","PLANT":"1846","TO_PART":"","ERRORCHECK":"","PLIFZ":"25","LOT_QTY":"0.000","STOCK":"0.000","HILV":"000000","FREIGHT":"0.00","DIEUCE":"0.000","MIN_QTY":"0.000","TDLNR_NAME":"","DIUKL":"0.000","RMAST_T":"","BO":"","PRDHA":"SP2002006020060016","MEINS":"","DIS_VALUE":"0.00","STATUS":"","MVGR5":"","BD":"","MEMO":"","DELV_QTY":"0.000","MATNR_DESIGN":"00","POSNR_V":"000000","BULL_MATNR":"","STOCK_DI":"0.000","BSTDK_E":"0000-00-00"}],"LT_PARTNER":[{"TZONE":"051-002","EMAIL":"","HOUSE_NUM1":"","VBELN":"","COUNTRY":"KR","FAX_NUMBER":"","CONTACT":"","STREET2":"","PO_BOX_LOC":"","STREET1":"대저2동 부산티플렉스131동 117,217,118,218호","MAIL_OK":"","SIC_CODE":"","NAME4":"","NAME3":"","STATE":"12","NAME2":"","PARVW":"AG","NAME1":"링엔지니어링","POSNR":"000000","SORT2":"","KUNNR":"0001057644","CITY2":"","ZIP":"46721","CITY1":"부산광역시 강서구 유통단지1로 41","TEL_NUMBER":"051-831-1204"},{"TZONE":"051-002","EMAIL":"","HOUSE_NUM1":"","VBELN":"","COUNTRY":"KR","FAX_NUMBER":"","CONTACT":"","STREET2":"","PO_BOX_LOC":"","STREET1":"대저2동 부산티플렉스131동 117,217,118,218호","MAIL_OK":"","SIC_CODE":"","NAME4":"","NAME3":"","STATE":"12","NAME2":"","PARVW":"WE","NAME1":"링엔지니어링","POSNR":"000000","SORT2":"051-831-1204","KUNNR":"0001057644","CITY2":"","ZIP":"46721","CITY1":"부산광역시 강서구 유통단지1로 41","TEL_NUMBER":"051-831-1204"},{"TZONE":"051-002","EMAIL":"","HOUSE_NUM1":"","VBELN":"","COUNTRY":"KR","FAX_NUMBER":"","CONTACT":"","STREET2":"","PO_BOX_LOC":"","STREET1":"대저2동 부산티플렉스131동 117,217,118,218호","MAIL_OK":"","SIC_CODE":"","NAME4":"","NAME3":"","STATE":"12","NAME2":"","PARVW":"Z2","NAME1":"링엔지니어링","POSNR":"000000","SORT2":"051-831-1204","KUNNR":"0001057644","CITY2":"","ZIP":"46721","CITY1":"부산광역시 강서구 유통단지1로 41","TEL_NUMBER":"051-831-1204"}],"LT_PRICING_01":[{"NETWR":"0.00","WAERK":"KRW","NAME":"Item Total (A)","NEWR":"440660.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Freight(B)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Insurance(C)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Handling Charge(D)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Output Tax(E)","NEWR":"44066.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Total Amt(A+B+C+D+E)","NEWR":"484726.00"}],"LT_PRICING_02":[{"NETWR":"4406.60","WAERK":"KRW","NAME":"Item Total(Doosan) (A-F)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Commission value(F)","NEWR":"0.00"}],"LT_STATUS":[{"CODE":"C","TEXT":"","NAME":"Overall status"},{"CODE":"","TEXT":"","NAME":"Allocation status"},{"CODE":"C","TEXT":"","NAME":"Delivery status"},{"CODE":"","TEXT":"","NAME":"Billing status_D"},{"CODE":"","TEXT":"","NAME":"Billing status_O"},{"CODE":"","TEXT":"","NAME":"Delivery Block"},{"CODE":"A","TEXT":"","NAME":"Rejection status"},{"CODE":"","TEXT":"","NAME":"Credit status"}],"LT_TEXT":[{"TDID":"Y002","LINE":"청구착오","POSNR":"000010","SEQNO":"0001"},{"TDID":"Y003","LINE":"_20240223","POSNR":"000010","SEQNO":"0001"}],"LT_VALUESET":[{"TEXT":"1 000010 R42220 에어실린더","VALUE":"1 000010 R42220 에어실린더"}],"RETURN":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_009_HttpMock implements HttpCalloutMock {
        public IF_PARTS_009_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_MEG":"","E_STAT":"S","LS_MAIN_HEAD_RESULT":{"KONDA":"28","KUNNR":"0001057644","KUNNR_NAME":"","KUNNR_STREET":"","KUNAG":"0001057644","KUNAG_NAME":"","KUNAG_STREET":"","KUNNR_CR":"","NETWR":"175021.00","WAERK":"KRW","CREDIT":"86947213.00","CREDIT_WAERK":"KRW","TOTAL_WEIGHT":"4.922","GEWEI":"KG","VOLUM":"0.000","VOLEH":"CBM","KONDA_TEXT":"","KVGR5":"40","NAME":"","CITY":"","STREET":"","COUNTRY":"","POSTL_CODE":"","TRANSPZONE":"","ORDER_DATE":"0000-00-00","PRICE_LIST":"","COLLECT_NO":"","ZTERM":"","ORD_REASON":"","BZIRK":"","DOCUFEE":""},"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"LS_GENERAL":{"BSTNK":"","VDATU":"2025-06-25","INCO1":"","INCO2":"","VSBED":"","COMPLETE_DELIVERY":"","ROUTE":"","VSBED_TX":"","ROUTE_TX":"","SPECPROCID":"","POSSIBLE_DATE":"2025-06-25","IF_FROM":"0000-00-00","TO":"0000-00-00","AUDAT":"0000-00-00","ERZET":"00:00:00","BSTKD_E":"","ZZCFDAT":"0000-00-00"},"ERRORMSG":[],"LT_BAPIRET2":[],"LT_ITEM":[{"COMPLAINT":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"N","HERKL":"KR","MATERIAL_ENT":"R18181","UOM":"EA","GEWEI":"KG","BULLETIN":"X","NET_PRICE":"159110.00","NET_ITEM_PRICE":"159110.00","MITEM":"","MEMO_MATNR":"","EMERC":"","USAGE_HILV":"","ZZEQMASTER":"","MATERIAL_TEXT":"라이브센터","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"DNS Parts","REF_ORD":"","CCHECK":"","MATERIAL":"R18181","QTY":"1.000","ZZDEALDT":"0000-00-00","BSTKD_E":"","WAERS":"","TDLNR":"","IF_CURRENCY":"KRW","ZZWORKHRS":"","NET_VALUE":"159110.00","KUNNR":"","MATNR_CHECK":"X","MATERIAL_N":"","R":"","INPUT_QTY":"1.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"X","REF_ITEM":"000000","TNDR_TRKID":"","NTGEW":"4.422","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000010","SUGRD":"","CHEKCABLE":"","ACCEPT":"","AVAIL_QTY2":"2.000","AVAIL_QTY1":"0.000","REQ_QTY":"1.000","PLANT":"1846","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","TDLNR_NAME":"","DIUKL":"0.000","BO":"","MEINS":"","STATUS":"","MVGR5":"","BD":"","MEMO":"","MATNR_DESIGN":"00","BULL_MATNR":"R18181","BSTDK_E":"0000-00-00"}],"LT_NON_EXIST":[],"LT_NON_PRICE":[],"LT_NON_PURCHASE":[],"LT_NON_QTY":[],"LT_PRICING_01":[],"LT_PRICING_02":[],"LT_STATUS":[],"LT_WRONG_DIVISION":[],"LT_WRONG_ITEM":[],"LT_PARTNER":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_012_HttpMock implements HttpCalloutMock {
        public IF_PARTS_012_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_COUNT":"12","O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_HEADER":[{"BSTKD":"test_qwer_004","KONDA_T":"Emergency Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"SP Domestic EO","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"2.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"113212.00","RE_QTY":"2.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"113212.00","SO_ITEM":"1","RE_AMT":"113212.00","AUART":"YDEO","VBELN":"2001404642","EQFNR":"","KONDA":"20"},{"BSTKD":"test_qwer_004","KONDA_T":"Emergency Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"SP Domestic EO","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"3.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"3653397.00","RE_QTY":"3.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"3653397.00","SO_ITEM":"1","RE_AMT":"3653397.00","AUART":"YDEO","VBELN":"2001404643","EQFNR":"","KONDA":"20"},{"BSTKD":"Test Order","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"Yes","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"5.000","CFM_QTY":"5.000","SO_QTY":"5.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"5.000","SH_AMT":"46475.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"46475.00","RE_QTY":"0.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-11","BO_AMT":"0.00","SO_ITEM":"1","RE_AMT":"0.00","AUART":"YDOR","VBELN":"3001955008","EQFNR":"","KONDA":"28"},{"BSTKD":"Test Order2","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"2.000","SO_QTY":"2.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"18590.00","RE_QTY":"2.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-16","BO_AMT":"18590.00","SO_ITEM":"1","RE_AMT":"18590.00","AUART":"YDOR","VBELN":"3001955009","EQFNR":"","KONDA":"28"},{"BSTKD":"Purchase other dealer","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Truck","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"20","SO_AMT":"1542596.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-21","BO_AMT":"1542596.00","SO_ITEM":"1","RE_AMT":"1542596.00","AUART":"YDOR","VBELN":"3001955013","EQFNR":"","KONDA":"28"},{"BSTKD":"test_qwer_001","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"56606.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"56606.00","SO_ITEM":"1","RE_AMT":"56606.00","AUART":"YDOR","VBELN":"3001955021","EQFNR":"","KONDA":"28"},{"BSTKD":"test_qwer_002","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"0.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"56606.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"56606.00","SO_ITEM":"1","RE_AMT":"56606.00","AUART":"YDOR","VBELN":"3001955022","EQFNR":"","KONDA":"28"},{"BSTKD":"test_qwer_002","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"14092848.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"14092848.00","SO_ITEM":"1","RE_AMT":"14092848.00","AUART":"YDOR","VBELN":"3001955023","EQFNR":"","KONDA":"28"},{"BSTKD":"test_qwer_003","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"14.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"1451296.00","RE_QTY":"14.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"1451296.00","SO_ITEM":"1","RE_AMT":"1451296.00","AUART":"YDOR","VBELN":"3001955024","EQFNR":"","KONDA":"28"},{"BSTKD":"test_qwer_004","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"7.000","SO_QTY":"8.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"452848.00","RE_QTY":"8.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"452848.00","SO_ITEM":"1","RE_AMT":"452848.00","AUART":"YDOR","VBELN":"3001955025","EQFNR":"","KONDA":"28"},{"BSTKD":"test_qwer_005","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"10.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"566060.00","RE_QTY":"10.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"566060.00","SO_ITEM":"1","RE_AMT":"566060.00","AUART":"YDOR","VBELN":"3001955026","EQFNR":"","KONDA":"28"},{"BSTKD":"test_qwer_004","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001244220","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"명성기계","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"4.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"226424.00","RE_QTY":"4.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2024-10-30","BO_AMT":"226424.00","SO_ITEM":"1","RE_AMT":"226424.00","AUART":"YDOR","VBELN":"3001955027","EQFNR":"","KONDA":"28"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_013_HttpMock implements HttpCalloutMock {
        public IF_PARTS_013_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_MESG":"Successfully finished.[ZSS90101]","O_COUNT":"1","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}],"T_DETAIL":[{"MATNR_SH":"R18182","ETENR":"0001","SH_QTY":"0.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"2001404719","FST_ETD":"2025-01-27","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"5.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"대체품 ID 부여","DODAT":"0000-00-00","EMERC":"T","AUDAT":"2025-01-23","ERDAT":"2025-01-23","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000011","AUART":"YDEO","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18181","AUART_T":"SP Domestic EO","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"20"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_026_HttpMock implements HttpCalloutMock {
        public IF_PARTS_026_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"Saved successfully.","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_034_HttpMock implements HttpCalloutMock {
        public IF_PARTS_034_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]"},"T_DETAIL":[{"MATNR_SH":"300632-00221","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"1.000","INVOICE":"","VBELN":"2001404738","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"MPG;PORTABLE,EMG,P.C.","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"90000011TEST","DODAT":"0000-00-00","EMERC":"T","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000011","AUART":"YDEO","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"300632-00221","AUART_T":"SP Domestic EO","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"20"},{"MATNR_SH":"140105-01262","ETENR":"0001","SH_QTY":"1.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955496","FST_ETD":"2025-03-26","PI_QTY":"1.000","MAKTX":"BEARING","SO_QTY":"1.000","VRKME":"SET","IN_QTY":"0.000","BSTKD":"cwkim_20250324_1","DODAT":"2025-03-24","EMERC":"","RFGSK_TX_T":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000011","AUART":"YDOR","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"140105-01262","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"140105-01319","ETENR":"0001","SH_QTY":"1.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"9006383072","VBELN":"3001955496","FST_ETD":"2025-03-26","PI_QTY":"1.000","MAKTX":"BEARING","SO_QTY":"1.000","VRKME":"SET","IN_QTY":"0.000","BSTKD":"cwkim_20250324_1","DODAT":"2025-03-24","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000021","AUART":"YDOR","POSNR_H":"000021","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"140105-01319","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"300640-00585B","ETENR":"0001","SH_QTY":"1.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"9006383074","VBELN":"3001955497","FST_ETD":"2025-03-26","PI_QTY":"1.000","MAKTX":"PCB ASSY;BM SERIES IO PCB STD","SO_QTY":"1.000","VRKME":"AY","IN_QTY":"0.000","BSTKD":"cwkim_3024_dn","DODAT":"2025-03-24","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000010","AUART":"YDOR","POSNR_H":"000010","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"300640-00585B","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"R18182","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955498","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"2.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"두비즈테스트0324001","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000010","AUART":"YDOR","POSNR_H":"000010","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18182","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"R18182","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955499","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"딜러포탈테스트250324001","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000010","AUART":"YDOR","POSNR_H":"000010","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18182","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"300632-00221","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955500","FST_ETD":"2025-04-22","PI_QTY":"0.000","MAKTX":"MPG;PORTABLE,EMG,P.C.","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"cwkim_3024_dn2","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000011","AUART":"YDSO","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"300632-00221","AUART_T":"SP Domestic SO","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"40"},{"MATNR_SH":"300640-00585B","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"1.000","INVOICE":"","VBELN":"3001955500","FST_ETD":"2025-04-22","PI_QTY":"0.000","MAKTX":"PCB ASSY;BM SERIES IO PCB STD","SO_QTY":"1.000","VRKME":"AY","IN_QTY":"0.000","BSTKD":"cwkim_3024_dn2","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000020","AUART":"YDSO","POSNR_H":"000020","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"300640-00585B","AUART_T":"SP Domestic SO","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"40"},{"MATNR_SH":"301202-00429","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"1.000","INVOICE":"","VBELN":"3001955500","FST_ETD":"2025-04-22","PI_QTY":"0.000","MAKTX":"RELAY,MINIATURE;ASSY, 6A,24V,4 PDTS","SO_QTY":"1.000","VRKME":"AY","IN_QTY":"0.000","BSTKD":"cwkim_3024_dn2","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000030","AUART":"YDSO","POSNR_H":"000030","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"301202-00429","AUART_T":"SP Domestic SO","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"40"},{"MATNR_SH":"301306-00028","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"1.000","INVOICE":"","VBELN":"3001955500","FST_ETD":"2025-04-22","PI_QTY":"0.000","MAKTX":"SENSOR,ANGLE;AMO","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"cwkim_3024_dn2","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000040","AUART":"YDSO","POSNR_H":"000040","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"301306-00028","AUART_T":"SP Domestic SO","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"40"},{"MATNR_SH":"300632-00221","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"1.000","INVOICE":"","VBELN":"3001955501","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"MPG;PORTABLE,EMG,P.C.","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"HWJin-0324-D","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000011","AUART":"YDOR","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"300632-00221","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"R18181","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955502","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"구로 테스트 1 차","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000010","AUART":"YDOR","POSNR_H":"000010","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18181","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"401004-00209","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955503","FST_ETD":"2025-04-22","PI_QTY":"0.000","MAKTX":"RING,PISTON;D","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"cwkim_3024_dn3","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000011","AUART":"YDSO","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"401004-00209","AUART_T":"SP Domestic SO","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"40"},{"MATNR_SH":"400206-00913A","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955504","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"COOLER,OIL;WITH TANK","SO_QTY":"12.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"구로 2차 태스트","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000011","AUART":"YDOR","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R90033","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"R18182","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955505","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"2.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000010","AUART":"YDOR","POSNR_H":"000010","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18182","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"R18182","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955506","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"2.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_수기입력","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000010","AUART":"YDOR","POSNR_H":"000010","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18182","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"301411-00511","ETENR":"0001","SH_QTY":"1.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"9006383075","VBELN":"3001955507","FST_ETD":"2025-03-26","PI_QTY":"1.000","MAKTX":"SWITCH,LIMIT;ROLLER,IP69K,5M","SO_QTY":"1.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"cwkim_3024_dn4","DODAT":"2025-03-24","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"1.000","POSNR":"000010","AUART":"YDOR","POSNR_H":"000010","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"301411-00511","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"400206-00913A","ETENR":"0001","SH_QTY":"0.000","LIFSK":"","RE_QTY":"0.000","STB_QTY":"0.000","INVOICE":"","VBELN":"3001955508","FST_ETD":"2025-03-26","PI_QTY":"0.000","MAKTX":"COOLER,OIL;WITH TANK","SO_QTY":"123.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"배송처 테스트 구로 1차","DODAT":"0000-00-00","EMERC":"","RFGSK_TX_T":"미진행","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000011","AUART":"YDOR","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R90033","AUART_T":"Dom Ordinary Order","VBELN2":"","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"}],"T_HEADER":[{"BSTKD":"90000011TEST","KONDA_T":"Emergency Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0011999999","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"SP Domestic EO","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"DI One-time Customer","SH_QTY":"0.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Truck","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"20","SO_AMT":"331023.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"331023.00","SO_ITEM":"1","RE_AMT":"331023.00","AUART":"YDEO","VBELN":"2001404738","EQFNR":"","KONDA":"20"},{"BSTKD":"cwkim_20250324_1","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"Yes","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"2.000","CFM_QTY":"2.000","SO_QTY":"2.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"2.000","SH_AMT":"1643873.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"1643873.00","RE_QTY":"0.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"0.00","SO_ITEM":"2","RE_AMT":"0.00","AUART":"YDOR","VBELN":"3001955496","EQFNR":"","KONDA":"28"},{"BSTKD":"cwkim_3024_dn","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"Yes","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"1.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"1.000","SH_AMT":"626593.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"626593.00","RE_QTY":"0.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"0.00","SO_ITEM":"1","RE_AMT":"0.00","AUART":"YDOR","VBELN":"3001955497","EQFNR":"","KONDA":"28"},{"BSTKD":"두비즈테스트0324001","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0011999999","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"DI One-time Customer","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"2.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"170500.00","RE_QTY":"2.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"170500.00","SO_ITEM":"1","RE_AMT":"170500.00","AUART":"YDOR","VBELN":"3001955498","EQFNR":"","KONDA":"28"},{"BSTKD":"딜러포탈테스트250324001","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"1.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"85250.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"85250.00","SO_ITEM":"1","RE_AMT":"85250.00","AUART":"YDOR","VBELN":"3001955499","EQFNR":"","KONDA":"28"},{"BSTKD":"cwkim_3024_dn2","KONDA_T":"Commission Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"SP Domestic SO","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"0.000","CFM_QTY":"3.000","SO_QTY":"4.000","VSBED_T":"Bus","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"21","SO_AMT":"3316665.00","RE_QTY":"4.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"3316665.00","SO_ITEM":"4","RE_AMT":"3316665.00","AUART":"YDSO","VBELN":"3001955500","EQFNR":"","KONDA":"40"},{"BSTKD":"HWJin-0324-D","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"0.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"331023.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"331023.00","SO_ITEM":"1","RE_AMT":"331023.00","AUART":"YDOR","VBELN":"3001955501","EQFNR":"","KONDA":"28"},{"BSTKD":"구로 테스트 1 차","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0011999999","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"DI One-time Customer","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"1.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"175021.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"175021.00","SO_ITEM":"1","RE_AMT":"175021.00","AUART":"YDOR","VBELN":"3001955502","EQFNR":"","KONDA":"28"},{"BSTKD":"cwkim_3024_dn3","KONDA_T":"Commission Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"SP Domestic SO","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"1.000","VSBED_T":"Bus","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"21","SO_AMT":"59334.00","RE_QTY":"1.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"59334.00","SO_ITEM":"1","RE_AMT":"59334.00","AUART":"YDSO","VBELN":"3001955503","EQFNR":"","KONDA":"40"},{"BSTKD":"구로 2차 태스트","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0011999999","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"DI One-time Customer","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"12.000","VSBED_T":"Quick Service","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"90","SO_AMT":"22343376.00","RE_QTY":"12.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"22343376.00","SO_ITEM":"1","RE_AMT":"22343376.00","AUART":"YDOR","VBELN":"3001955504","EQFNR":"","KONDA":"28"},{"BSTKD":"포탈250324_고객사","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0011999999","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"DI One-time Customer","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"2.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"170500.00","RE_QTY":"2.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"170500.00","SO_ITEM":"1","RE_AMT":"170500.00","AUART":"YDOR","VBELN":"3001955505","EQFNR":"","KONDA":"28"},{"BSTKD":"포탈250324_수기입력","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0011999999","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"DI One-time Customer","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"2.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"170500.00","RE_QTY":"2.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"170500.00","SO_ITEM":"1","RE_AMT":"170500.00","AUART":"YDOR","VBELN":"3001955506","EQFNR":"","KONDA":"28"},{"BSTKD":"cwkim_3024_dn4","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"Yes","KUNWE":"0001057644","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"링엔지니어링","SH_QTY":"1.000","CFM_QTY":"1.000","SO_QTY":"1.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"1.000","SH_AMT":"108438.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"108438.00","RE_QTY":"0.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"0.00","SO_ITEM":"1","RE_AMT":"0.00","AUART":"YDOR","VBELN":"3001955507","EQFNR":"","KONDA":"28"},{"BSTKD":"배송처 테스트 구로 1차","KONDA_T":"Ordinary Order","ZZAPPNO":"","LIFSK":"N","STATUS":"No","KUNWE":"0011999999","CA_AMT":"0.00","ZTERM":"CPBC","AUART_T":"Dom Ordinary Order","KWMENG":"0.000","WAERK":"KRW","RJ_QTY":"0.000","NAME2":"","NAME1":"DI One-time Customer","SH_QTY":"0.000","CFM_QTY":"0.000","SO_QTY":"123.000","VSBED_T":"Domestic Express","ZTERM_T":"Sales:1~31, Due on 3 m end","BNAME":"","VRKME":"","PI_QTY":"0.000","SH_AMT":"0.00","IN_QTY":"0.000","VSBED":"10","SO_AMT":"229019604.00","RE_QTY":"123.000","PI_AMT":"0.00","IN_AMT":"0.00","ERDAT":"2025-03-24","BO_AMT":"229019604.00","SO_ITEM":"1","RE_AMT":"229019604.00","AUART":"YDOR","VBELN":"3001955508","EQFNR":"","KONDA":"28"}],"T_SALESAREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_PARTS_001_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-001', className);

        Test.startTest();

        IF_ERP_Parts_Order_Classes.IF_PARTS_001_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_001_Req();
        req.I_VKORG         = '';
        req.I_VTWEG         = '';
        req.I_KUNNR         = '';
        req.I_SPART         = '';
        req.I_AUART         = '';
        req.I_LANG          = 'KO';
        req.I_VBTYP         = '';
        req.I_STATUS        = '';
        req.I_VBELN         = '';

        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        instance.IF_PARTS_001(req);

        IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res res = new IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res();
        res.E_KDGRP         = '';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res_T_ZSSV0002 T_ZSSV0002 = new IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res_T_ZSSV0002();
        T_ZSSV0002.KONDA        = '';
        T_ZSSV0002.ZZAUKON      = '';
        T_ZSSV0002.VKORG        = '';
        T_ZSSV0002.VTWEG        = '';
        T_ZSSV0002.SPART        = '';
        T_ZSSV0002.KDGRP        = '';
        T_ZSSV0002.AUART        = '';
        T_ZSSV0002.VBTYP        = '';
        T_ZSSV0002.STATUS       = '';
        T_ZSSV0002.RDDAT        = '';
        T_ZSSV0002.VTEXT        = '';
        T_ZSSV0002.DEFFLG       = '';

        res.T_ZSSV0002      = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res_T_ZSSV0002>{T_ZSSV0002};

        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_003_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-003', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req request = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req();
        
        // 기본 필드 값 설정
        request.LS_APPLY = 'Y';
        request.LV_AUART = 'ZORD';
        request.I_USERID = 'TestUser';
        request.I_LANGU = 'EN';
        request.I_SHIPTO = 'SH123456';
        request.I_DATE = '20250315';
        request.I_CS = 'CS01';

        // I_USERINFO 객체 설정
        request.I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TestBNAME';
        request.I_USERINFO.RNAME = 'TestRNAME';
        request.I_USERINFO.HIER = 'TestHIER';
        request.I_USERINFO.KUNNR = '1000001';
        request.I_USERINFO.LIFNR = '2000001';
        request.I_USERINFO.VKORG = '1000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = '20';
        request.I_USERINFO.WERKS = '3000';
        request.I_USERINFO.ARBPL = '4000';
        request.I_USERINFO.PARNR = '5000001';
        request.I_USERINFO.ENAME = 'TestName';
        request.I_USERINFO.KUNN2 = '6000001';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = '7000';
        request.I_USERINFO.DF_CHK = 'X';
        request.I_USERINFO.CO_CHK = 'X';

        // LS_MAIN_HEAD 객체 설정
        request.LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_MAIN_HEAD();
        request.LS_MAIN_HEAD.KONDA = 'Z1';
        request.LS_MAIN_HEAD.KUNNR = '1000001';
        request.LS_MAIN_HEAD.KUNNR_NAME = 'Test Customer';
        request.LS_MAIN_HEAD.KUNNR_STREET = '123 Test St';
        request.LS_MAIN_HEAD.KUNAG = 'Test AG';
        request.LS_MAIN_HEAD.KUNAG_NAME = 'Test AG Name';
        request.LS_MAIN_HEAD.KUNAG_STREET = '456 Test St';
        request.LS_MAIN_HEAD.KUNNR_CR = 'A';
        request.LS_MAIN_HEAD.NETWR = '1000.00';
        request.LS_MAIN_HEAD.WAERK = 'USD';
        request.LS_MAIN_HEAD.CREDIT = '2000.00';
        request.LS_MAIN_HEAD.CREDIT_WAERK = 'USD';
        request.LS_MAIN_HEAD.TOTAL_WEIGHT = '50';
        request.LS_MAIN_HEAD.GEWEI = 'KG';
        request.LS_MAIN_HEAD.VOLUM = '10';
        request.LS_MAIN_HEAD.VOLEH = 'L';
        request.LS_MAIN_HEAD.KONDA_TEXT = 'Test Price Group';
        request.LS_MAIN_HEAD.KVGR5 = 'K5';
        request.LS_MAIN_HEAD.NAME = 'Main Head Name';
        request.LS_MAIN_HEAD.CITY = 'New York';
        request.LS_MAIN_HEAD.STREET = '789 Test St';
        request.LS_MAIN_HEAD.COUNTRY = 'US';
        request.LS_MAIN_HEAD.POSTL_CODE = '10001';
        request.LS_MAIN_HEAD.TRANSPZONE = 'Z1';
        request.LS_MAIN_HEAD.ORDER_DATE = '20250315';
        request.LS_MAIN_HEAD.PRICE_LIST = 'PL01';
        request.LS_MAIN_HEAD.COLLECT_NO = 'CN123';
        request.LS_MAIN_HEAD.ZTERM = 'ZT01';
        request.LS_MAIN_HEAD.ORD_REASON = 'OR01';
        request.LS_MAIN_HEAD.BZIRK = 'B01';
        request.LS_MAIN_HEAD.DOCUFEE = '10.00';

        // LS_ERROR_IGNORE 객체 설정
        request.LS_ERROR_IGNORE = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_ERROR_IGNORE();
        request.LS_ERROR_IGNORE.IGNORE = 'X';
        request.LS_ERROR_IGNORE.IGNORE_QTY = 'X';
        request.LS_ERROR_IGNORE.IGNORE_PRICE = 'X';
        request.LS_ERROR_IGNORE.IGNORE_DIVISION = 'X';
        request.LS_ERROR_IGNORE.IGNORE_PURCHASE = 'X';
        request.LS_ERROR_IGNORE.IGNORE_HAZARD = 'X';

        // LS_IMPORT_PORTAL 객체 설정
        request.LS_IMPORT_PORTAL = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_IMPORT_PORTAL();
        request.LS_IMPORT_PORTAL.DOC_CATEGORY = 'DC01';
        request.LS_IMPORT_PORTAL.DOC_MODE = 'M1';
        request.LS_IMPORT_PORTAL.COMPLAINT = 'C1';

        // I_ORG 객체 설정
        request.I_ORG = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_ORG();
        request.I_ORG.VKORG = '1000';
        request.I_ORG.VTWEG = '10';
        request.I_ORG.SPART = '20';
        request.I_ORG.WERKS = '3000';
        request.I_ORG.ARBPL = '4000';
        request.I_ORG.AMSCCTL = 'AC01';

        // LT_GERNERAL_ZTERM 리스트 설정
        request.LT_GERNERAL_ZTERM.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_GERNERAL_ZTERM());
        request.LT_GERNERAL_ZTERM[0].ZTERM = 'ZT01';
        request.LT_GERNERAL_ZTERM[0].TEXT = 'Payment Term';

        // LT_PARTNER 리스트 설정
        request.LT_PARTNER.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_PARTNER());
        request.LT_PARTNER[0].PARTN_ROLE = 'PR01';
        request.LT_PARTNER[0].PARTN_NUMB = 'P1001';
        request.LT_PARTNER[0].ITM_NUMBER = 'ITM01';
        request.LT_PARTNER[0].TITLE = 'Mr.';
        request.LT_PARTNER[0].NAME = 'John Doe';

        // LT_ITEM 리스트 설정
        request.LT_ITEM.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM());
        request.LT_ITEM[0].CCHECK = 'X';
        request.LT_ITEM[0].ITEM = 'ITM001';
        request.LT_ITEM[0].HILV = 'H01';
        request.LT_ITEM[0].MATERIAL = 'MAT001';
        request.LT_ITEM[0].MATERIAL_TEXT = 'Test Material';
        request.LT_ITEM[0].QTY = '10';
        request.LT_ITEM[0].UOM = 'EA';
        request.LT_ITEM[0].NET_PRICE = '100.00';
        request.LT_ITEM[0].NET_ITEM_PRICE = '1000.00';
        request.LT_ITEM[0].NET_VALUE = '10000.00';
        request.LT_ITEM[0].LIST_PRICE = '120.00';
        request.LT_ITEM[0].IF_CURRENCY = 'USD';

        // LT_STATUS 리스트 설정
        request.LT_STATUS.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_STATUS());
        request.LT_STATUS[0].CODE = 'S01';
        request.LT_STATUS[0].TEXT = 'Success';
        request.LT_STATUS[0].NAME = 'Status Name';

        // 응답 객체 생성
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res response = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res();

        // 기본 필드 값 설정
        response.E_MEG = 'Test Message';

        // LS_MAIN_HEAD_RESULT 객체 설정
        response.LS_MAIN_HEAD_RESULT = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LS_MAIN_HEAD_RESULT();
        response.LS_MAIN_HEAD_RESULT.KONDA = 'Z1';
        response.LS_MAIN_HEAD_RESULT.KUNNR = '1000001';
        response.LS_MAIN_HEAD_RESULT.KUNNR_NAME = 'Test Customer';
        response.LS_MAIN_HEAD_RESULT.KUNNR_STREET = '123 Test St';
        response.LS_MAIN_HEAD_RESULT.KUNAG = 'Test AG';
        response.LS_MAIN_HEAD_RESULT.KUNAG_NAME = 'Test AG Name';
        response.LS_MAIN_HEAD_RESULT.KUNAG_STREET = '456 Test St';
        response.LS_MAIN_HEAD_RESULT.KUNNR_CR = 'A';
        response.LS_MAIN_HEAD_RESULT.NETWR = '1000.00';
        response.LS_MAIN_HEAD_RESULT.WAERK = 'USD';
        response.LS_MAIN_HEAD_RESULT.CREDIT = '2000.00';
        response.LS_MAIN_HEAD_RESULT.CREDIT_WAERK = 'USD';

        // O_RETURN 객체 설정
        response.O_RETURN = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '000';
        response.O_RETURN.MESSAGE = 'Success';

        // LT_ITEM 리스트 설정
        response.LT_ITEM = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_ITEM>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_ITEM item = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_ITEM();
        item.ITEM = 'ITM001';
        item.MATERIAL = 'MAT001';
        item.MATERIAL_TEXT = 'Test Material';
        item.QTY = '10';
        item.UOM = 'EA';
        item.NET_PRICE = '100.00';
        item.NET_ITEM_PRICE = '1000.00';
        item.NET_VALUE = '10000.00';
        item.LIST_PRICE = '120.00';
        item.IF_CURRENCY = 'USD';
        item.AVAILABILITY       = 'test';
        item.REF_ORD            = 'test';
        item.REF_ITEM           = 'test';
        item.COMPLAINT          = 'test';
        item.COMPLAINT_DESC     = 'test';
        item.PLANT              = 'test';
        item.O                  = 'test';
        item.C                  = 'test';
        item.D                  = 'test';
        item.BD                 = 'test';
        item.BO                 = 'test';
        item.DB                 = 'test';
        item.R                  = 'test';
        item.PLANT_TX           = 'test';
        item.USAGE_HILV         = 'test';
        item.CHEKCABLE          = 'test';
        item.MATNR_CHECK        = 'test';
        item.A                  = 'test';
        item.REQ_QTY            = 'test';
        item.LOT_QTY            = 'test';
        item.MIN_QTY            = 'test';
        item.MATNR_DESIGN       = 'test';
        item.REQ_QTY_DESIGN     = 'test';
        item.ZZDEALDT           = 'test';
        item.WAERS              = 'test';
        item.REASON             = 'test';
        item.INPUT_QTY          = 'test';
        item.EXCEL              = 'test';
        item.MVGR5              = 'test';
        item.MATERIAL_ENT       = 'test';
        item.ERRORCHECK         = 'test';
        item.ERRORMSG           = 'test';
        item.SUGRD              = 'test';
        item.COMPLAINT_REASON   = 'test';
        item.ACCEPT             = 'test';
        item.MATERIAL_N         = 'test';
        item.NETPR              = 'test';
        item.DIEUCE             = 'test';
        item.DIEUFL             = 'test';
        item.DIUK               = 'test';
        item.DIID               = 'test';
        item.DI                 = 'test';
        item.DIUKL              = 'test';
        item.MEINS              = 'test';
        item.HERKL              = 'test';
        item.KONDM              = 'test';
        item.NTGEW              = 'test';
        item.GEWEI              = 'test';
        item.POUND              = 'test';
        item.KUNNR              = 'test';
        item.TDLNR              = 'test';
        item.TDLNR_NAME         = 'test';
        item.BSTKD_E            = 'test';
        item.BSTDK_E            = 'test';
        item.AVAIL_QTY1         = 'test';
        item.ZZAPPMACHINE       = 'test';
        item.ZZEQMASTER         = 'test';
        item.ZZWORKHRS          = 'test';
        item.TNDR_TRKID         = 'test';
        item.STATUS             = 'test';
        item.MITEM              = 'test';
        item.TO_PART            = 'test';
        item.BULLETIN           = 'test';
        item.BULL_MATNR         = 'test';
        item.MEMO               = 'test';
        item.MEMO_MATNR         = 'test';
        item.EMERC              = 'test';
        response.LT_ITEM.add(item);

        // LT_PRICING_01 리스트 설정
        response.LT_PRICING_01 = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_PRICING_01>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_PRICING_01 pricing1 = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_PRICING_01();
        pricing1.NAME = 'Test Pricing';
        pricing1.NEWR = '1000';
        pricing1.WAERK = 'USD';
        pricing1.NETWR = '900.00';
        response.LT_PRICING_01.add(pricing1);

        // LT_PRICING_02 리스트 설정
        response.LT_PRICING_02 = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_PRICING_02>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_PRICING_02 pricing2 = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_PRICING_02();
        pricing2.NAME = 'Test Pricing 2';
        pricing2.NEWR = '1500';
        pricing2.WAERK = 'USD';
        pricing2.NETWR = '1350.00';
        response.LT_PRICING_02.add(pricing2);

        // LT_STATUS 리스트 설정
        response.LT_STATUS = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_STATUS>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_STATUS status = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_STATUS();
        status.CODE = 'S01';
        status.TEXT = 'Success';
        status.NAME = 'Status Name';
        response.LT_STATUS.add(status);

        // IF_RETURN 리스트 설정
        response.IF_RETURN = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_IF_RETURN>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_IF_RETURN returnData = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_IF_RETURN();
        returnData.TYPE = 'S';
        returnData.ID = '12345';
        returnData.IF_NUMBER = 'IF001';
        returnData.MESSAGE = 'Processed Successfully';
        returnData.LOG_NO = 'LOG001';
        response.IF_RETURN.add(returnData);

        // ERRORMSG 리스트 설정
        response.ERRORMSG = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_ERRORMSG>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_ERRORMSG errorMsg = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_ERRORMSG();
        errorMsg.NAME = 'Error';
        errorMsg.TEXT = 'Invalid data';
        response.ERRORMSG.add(errorMsg);

        // LT_NON_EXIST 리스트 설정
        response.LT_NON_EXIST = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_NON_EXIST>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_NON_EXIST nonExist = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_NON_EXIST();
        nonExist.ERROR_MATNR = 'MAT002';
        nonExist.APPLY = 'N';
        nonExist.ITEM = 'ITM002';
        nonExist.MESSAGE = 'Material does not exist';
        response.LT_NON_EXIST.add(nonExist);

        // LS_GENERAL 객체 설정
        response.LS_GENERAL = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LS_GENERAL();
        response.LS_GENERAL.BSTNK = 'PO12345';
        response.LS_GENERAL.VDATU = '20250320';
        response.LS_GENERAL.INCO1 = 'EXW';
        response.LS_GENERAL.INCO2 = 'FOB';
        response.LS_GENERAL.VSBED = 'A1';
        response.LS_GENERAL.COMPLETE_DELIVERY = 'Yes';

        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_005_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-005', className);

        Test.startTest();

        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req();
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM   LT_GERNERAL_ZTERM = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM();
        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM             LT_ITEM           = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM();
        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_FILE             LT_FILE           = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_FILE();
        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_PARTNER          LT_PARTNER        = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_PARTNER();
        
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        instance.IF_PARTS_005(req);
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res res = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res();

        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res_LS_MAIN_HEAD_RESULT LS_MAIN_HEAD_RESULT = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res_LS_MAIN_HEAD_RESULT();
        LS_MAIN_HEAD_RESULT.KONDA               = '';
        LS_MAIN_HEAD_RESULT.KUNNR               = '';
        LS_MAIN_HEAD_RESULT.KUNNR_NAME          = '';
        LS_MAIN_HEAD_RESULT.KUNNR_STREET        = '';
        LS_MAIN_HEAD_RESULT.KUNAG               = '';
        LS_MAIN_HEAD_RESULT.KUNAG_NAME          = '';
        LS_MAIN_HEAD_RESULT.KUNAG_STREET        = '';
        LS_MAIN_HEAD_RESULT.KUNNR_CR            = '';
        LS_MAIN_HEAD_RESULT.NETWR               = '';
        LS_MAIN_HEAD_RESULT.WAERK               = '';
        LS_MAIN_HEAD_RESULT.CREDIT              = '';
        LS_MAIN_HEAD_RESULT.CREDIT_WAERK        = '';
        LS_MAIN_HEAD_RESULT.TOTAL_WEIGHT        = '';
        LS_MAIN_HEAD_RESULT.GEWEI               = '';
        LS_MAIN_HEAD_RESULT.VOLUM               = '';
        LS_MAIN_HEAD_RESULT.VOLEH               = '';
        LS_MAIN_HEAD_RESULT.KONDA_TEXT          = '';
        LS_MAIN_HEAD_RESULT.KVGR5               = '';
        LS_MAIN_HEAD_RESULT.NAME                = '';
        LS_MAIN_HEAD_RESULT.CITY                = '';
        LS_MAIN_HEAD_RESULT.STREET              = '';
        LS_MAIN_HEAD_RESULT.COUNTRY             = '';
        LS_MAIN_HEAD_RESULT.POSTL_CODE          = '';
        LS_MAIN_HEAD_RESULT.TRANSPZONE          = '';
        LS_MAIN_HEAD_RESULT.ORDER_DATE          = '';
        LS_MAIN_HEAD_RESULT.PRICE_LIST          = '';
        LS_MAIN_HEAD_RESULT.COLLECT_NO          = '';
        LS_MAIN_HEAD_RESULT.ZTERM               = '';
        LS_MAIN_HEAD_RESULT.ORD_REASON          = '';
        LS_MAIN_HEAD_RESULT.BZIRK               = '';
        LS_MAIN_HEAD_RESULT.DOCUFEE             = '';

        res.LS_MAIN_HEAD_RESULT     = LS_MAIN_HEAD_RESULT;

        res.E_MEG                   = '';
        res.LV_VENLR                = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res_LT_BAPIRET2 LT_BAPIRET2 = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res_LT_BAPIRET2(); 
        LT_BAPIRET2.TYPE            = '';
        LT_BAPIRET2.ID              = '';
        LT_BAPIRET2.IF_NUMBER       = '';
        LT_BAPIRET2.MESSAGE         = '';
        LT_BAPIRET2.LOG_NO          = '';
        LT_BAPIRET2.LOG_MSG_NO      = '';
        LT_BAPIRET2.MESSAGE_V1      = '';
        LT_BAPIRET2.MESSAGE_V2      = '';
        LT_BAPIRET2.MESSAGE_V3      = '';
        LT_BAPIRET2.MESSAGE_V4      = '';
        LT_BAPIRET2.PARAMETER       = '';
        LT_BAPIRET2.ROW             = '';
        LT_BAPIRET2.FIELD           = '';
        LT_BAPIRET2.IF_SYSTEM       = '';

        res.LT_BAPIRET2             = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res_LT_BAPIRET2>{LT_BAPIRET2};


        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_007_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-007', className);

        Test.startTest();

        IF_ERP_Parts_Order_Classes.IF_PARTS_007_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_007_Req();
        
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        instance.IF_PARTS_007(req);

        IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res res = new IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res();
        res.LV_MSG      = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res_LT_SEARCH LT_SEARCH = new IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res_LT_SEARCH();
        LT_SEARCH.AUART             = '';
        LT_SEARCH.VBELN             = '';
        LT_SEARCH.BSTKD             = '';
        LT_SEARCH.VBELN2            = '';
        LT_SEARCH.VKORG             = '';
        LT_SEARCH.VTWEG             = '';
        LT_SEARCH.SPART             = '';
        LT_SEARCH.ERDAT             = '';
        LT_SEARCH.ERZET             = '';
        LT_SEARCH.COUNT             = '';
        LT_SEARCH.T_NETWR           = '';
        LT_SEARCH.WAERK             = '';
        LT_SEARCH.VBTYP             = '';
        LT_SEARCH.RFGSK             = '';
        LT_SEARCH.FKSTK             = '';
        LT_SEARCH.NETPR             = '';
        LT_SEARCH.VGBEL             = '';
        LT_SEARCH.ZZACCPTCD         = '';
        LT_SEARCH.VTEXT             = '';
        LT_SEARCH.VBELN3            = '';
        LT_SEARCH.VSBED             = '';
        LT_SEARCH.ZZAUKON           = '';
        LT_SEARCH.VTEXT2            = '';
        LT_SEARCH.KONDA             = '';
        LT_SEARCH.KVGR5             = '';
        LT_SEARCH.KUNNR             = '';
        LT_SEARCH.NAME_KUNNR        = '';
        LT_SEARCH.KUNWE             = '';
        LT_SEARCH.NAME1             = '';
        LT_SEARCH.TOTALQTY          = '';
        LT_SEARCH.SUBMI             = '';
        LT_SEARCH.CARR_DEC          = '';
        LT_SEARCH.ZZAPPNO           = '';
        LT_SEARCH.NAME2             = '';
        LT_SEARCH.AUGRU             = '';

        res.LT_SEARCH           = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res_LT_SEARCH>{LT_SEARCH};

        IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res_LT_SEARCH2 LT_SEARCH2 = new IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res_LT_SEARCH2();
        LT_SEARCH2.AUART            = '';
        LT_SEARCH2.VBELN            = '';
        LT_SEARCH2.POSNR            = '';
        LT_SEARCH2.BSTKD            = '';
        LT_SEARCH2.VBELN2           = '';
        LT_SEARCH2.POSNR2           = '';
        LT_SEARCH2.VKORG            = '';
        LT_SEARCH2.VTWEG            = '';
        LT_SEARCH2.SPART            = '';
        LT_SEARCH2.ERDAT            = '';
        LT_SEARCH2.ERZET            = '';
        LT_SEARCH2.COUNT            = '';
        LT_SEARCH2.T_NETWR          = '';
        LT_SEARCH2.WAERK            = '';
        LT_SEARCH2.VBTYP            = '';
        LT_SEARCH2.RFGSK            = '';
        LT_SEARCH2.NETPR            = '';
        LT_SEARCH2.MATNR            = '';
        LT_SEARCH2.KWMENG           = '';
        LT_SEARCH2.MAKTX            = '';
        LT_SEARCH2.VRKME            = '';
        LT_SEARCH2.MATWA            = '';
        LT_SEARCH2.RFGSK_TX         = '';
        LT_SEARCH2.RFGSK_TX_T       = '';
        LT_SEARCH2.ZZACCPTCD        = '';
        LT_SEARCH2.VTEXT            = '';
        LT_SEARCH2.VGBEL            = '';
        LT_SEARCH2.ZZCMPCD          = '';
        LT_SEARCH2.VBELN3           = '';
        LT_SEARCH2.VBELN4           = '';
        LT_SEARCH2.KBETR            = '';
        LT_SEARCH2.STATUS           = '';
        LT_SEARCH2.TEXT002          = '';
        LT_SEARCH2.TEXT004          = '';
        LT_SEARCH2.EMP_NAME         = '';
        LT_SEARCH2.RDATE            = '';
        LT_SEARCH2.IN_FREIGHT       = '';
        LT_SEARCH2.OUT_FREIGHT      = '';
        LT_SEARCH2.ZZAPPNO          = '';
        LT_SEARCH2.NAME2            = '';
        LT_SEARCH2.RFGSK_TX_T1      = '';
        LT_SEARCH2.XBLNR            = '';
        LT_SEARCH2.FKIMG            = '';
        LT_SEARCH2.IFKIMG           = '';
        LT_SEARCH2.NFKIMG           = '';
        LT_SEARCH2.FKDAT            = '';
        LT_SEARCH2.ZFCIVNO          = '';
        LT_SEARCH2.ZFSEQ            = '';
        LT_SEARCH2.ZFMBLNO          = '';
        LT_SEARCH2.ZFHBLNO          = '';
        LT_SEARCH2.ZZANSWER         = '';

        res.LT_SEARCH2          = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res_LT_SEARCH2>{LT_SEARCH2};

        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_008_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-008', className);

        Test.startTest();

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Req();
        
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        instance.IF_PARTS_008(req);

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res res = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res();
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LS_MAIN_HEAD_RESULT LS_MAIN_HEAD_RESULT = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LS_MAIN_HEAD_RESULT();
        LS_MAIN_HEAD_RESULT.KONDA               = '';
        LS_MAIN_HEAD_RESULT.KUNNR               = '';
        LS_MAIN_HEAD_RESULT.KUNNR_NAME          = '';
        LS_MAIN_HEAD_RESULT.KUNNR_STREET        = '';
        LS_MAIN_HEAD_RESULT.KUNAG               = '';
        LS_MAIN_HEAD_RESULT.KUNAG_NAME          = '';
        LS_MAIN_HEAD_RESULT.KUNAG_STREET        = '';
        LS_MAIN_HEAD_RESULT.KUNNR_CR            = '';
        LS_MAIN_HEAD_RESULT.NETWR               = '';
        LS_MAIN_HEAD_RESULT.WAERK               = '';
        LS_MAIN_HEAD_RESULT.CREDIT              = '';
        LS_MAIN_HEAD_RESULT.CREDIT_WAERK        = '';
        LS_MAIN_HEAD_RESULT.TOTAL_WEIGHT        = '';
        LS_MAIN_HEAD_RESULT.GEWEI               = '';
        LS_MAIN_HEAD_RESULT.VOLUM               = '';
        LS_MAIN_HEAD_RESULT.VOLEH               = '';
        LS_MAIN_HEAD_RESULT.KONDA_TEXT          = '';
        LS_MAIN_HEAD_RESULT.KVGR5               = '';
        LS_MAIN_HEAD_RESULT.NAME                = '';
        LS_MAIN_HEAD_RESULT.CITY                = '';
        LS_MAIN_HEAD_RESULT.STREET              = '';
        LS_MAIN_HEAD_RESULT.COUNTRY             = '';
        LS_MAIN_HEAD_RESULT.POSTL_CODE          = '';
        LS_MAIN_HEAD_RESULT.TRANSPZONE          = '';
        LS_MAIN_HEAD_RESULT.ORDER_DATE          = '';
        LS_MAIN_HEAD_RESULT.PRICE_LIST          = '';
        LS_MAIN_HEAD_RESULT.COLLECT_NO          = '';
        LS_MAIN_HEAD_RESULT.ZTERM               = '';
        LS_MAIN_HEAD_RESULT.ORD_REASON          = '';
        LS_MAIN_HEAD_RESULT.BZIRK               = '';
        LS_MAIN_HEAD_RESULT.DOCUFEE             = '';

        res.LS_MAIN_HEAD_RESULT        = LS_MAIN_HEAD_RESULT;

        res.E_MEG                      = '';
        res.LV_VENLR                   = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LS_FIRST LS_FIRST = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LS_FIRST();
        LS_FIRST.AUART          = '';
        LS_FIRST.VKORG          = '';
        LS_FIRST.VTWEG          = '';
        LS_FIRST.SPART          = '';
        LS_FIRST.BEZEI          = '';
        LS_FIRST.VKORG_T        = '';
        LS_FIRST.VTWEG_T        = '';
        LS_FIRST.SPART_T        = '';

        res.LS_FIRST        = LS_FIRST;
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LS_GENERAL LS_GENERAL = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LS_GENERAL();
        LS_GENERAL.BSTNK                    = '';
        LS_GENERAL.VDATU                    = '';
        LS_GENERAL.INCO1                    = '';
        LS_GENERAL.INCO2                    = '';
        LS_GENERAL.VSBED                    = '';
        LS_GENERAL.COMPLETE_DELIVERY        = '';
        LS_GENERAL.ROUTE                    = '';
        LS_GENERAL.VSBED_TX                 = '';
        LS_GENERAL.ROUTE_TX                 = '';
        LS_GENERAL.SPECPROCID               = '';
        LS_GENERAL.POSSIBLE_DATE            = '';
        LS_GENERAL.IF_FROM                  = '';
        LS_GENERAL.TO                       = '';
        LS_GENERAL.AUDAT                    = '';
        LS_GENERAL.ERZET                    = '';
        LS_GENERAL.BSTKD_E                  = '';
        LS_GENERAL.ZZCFDAT                  = '';

        res.LS_GENERAL      = LS_GENERAL;

        res.LV_ADDRESS      = '';
        res.LV_REMARK       = '';
        res.LV_ONETIME      = '';
        res.O_TOTAL         = '';
        res.O_FORWARDER     = '';
        res.O_NAME1         = '';
        res.LV_SCAT         = '';
        res.I_INQUIRY       = '';
        res.E_MDOWN         = '';
        res.E_VSART_TX      = '';

        res.LT_GERNERAL_ZTERM       = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_GERNERAL_ZTERM>();      
        res.LT_ITEM                 = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_ITEM>();
        res.LT_FILE                 = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_FILE>();     
        res.LT_PRICING_01           = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PRICING_01>();
        res.LT_PRICING_02           = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PRICING_02>();
        res.LT_STATUS               = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_STATUS>();    
        res.IF_RETURN               = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_RETURN>(); 
        res.ERRORMSG                = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_ERRORMSG>();         
        res.LT_VALUESET             = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_VALUESET>();  
        res.LT_FILE2                = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_FILE2>();    
        res.LT_TEXT                 = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_TEXT>();  
        res.LT_PARTNER              = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PARTNER>();     
        res.LT_CONDITION            = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_CONDITION>();  

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_GERNERAL_ZTERM LT_GERNERAL_ZTERM = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_GERNERAL_ZTERM();
        LT_GERNERAL_ZTERM.ZTERM     = '';
        LT_GERNERAL_ZTERM.TEXT      = '';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_ITEM LT_ITEM = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_ITEM();
        LT_ITEM.CCHECK                  = '';
        LT_ITEM.ITEM                    = '';
        LT_ITEM.HILV                    = '';
        LT_ITEM.MATERIAL                = '';
        LT_ITEM.MATERIAL_TEXT           = '';
        LT_ITEM.QTY                     = '';
        LT_ITEM.UOM                     = '';
        LT_ITEM.NET_PRICE               = '';
        LT_ITEM.NET_ITEM_PRICE          = '';
        LT_ITEM.NET_VALUE               = '';
        LT_ITEM.LIST_PRICE              = '';
        LT_ITEM.IF_CURRENCY             = '';
        LT_ITEM.AVAILABILITY            = '';
        LT_ITEM.REF_ORD                 = '';
        LT_ITEM.REF_ITEM                = '';
        LT_ITEM.COMPLAINT               = '';
        LT_ITEM.COMPLAINT_DESC          = '';
        LT_ITEM.PLANT                   = '';
        LT_ITEM.O                       = '';
        LT_ITEM.C                       = '';
        LT_ITEM.D                       = '';
        LT_ITEM.BD                      = '';
        LT_ITEM.BO                      = '';
        LT_ITEM.DB                      = '';
        LT_ITEM.R                       = '';
        LT_ITEM.PLANT_TX                = '';
        LT_ITEM.USAGE_HILV              = '';
        LT_ITEM.CHEKCABLE               = '';
        LT_ITEM.MATNR_CHECK             = '';
        LT_ITEM.A                       = '';
        LT_ITEM.REQ_QTY                 = '';
        LT_ITEM.LOT_QTY                 = '';
        LT_ITEM.MIN_QTY                 = '';
        LT_ITEM.MATNR_DESIGN            = '';
        LT_ITEM.REQ_QTY_DESIGN          = '';
        LT_ITEM.ZZDEALDT                = '';
        LT_ITEM.WAERS                   = '';
        LT_ITEM.REASON                  = '';
        LT_ITEM.INPUT_QTY               = '';
        LT_ITEM.EXCEL                   = '';
        LT_ITEM.MVGR5                   = '';
        LT_ITEM.MATERIAL_ENT            = '';
        LT_ITEM.ERRORCHECK              = '';
        LT_ITEM.ERRORMSG                = '';
        LT_ITEM.SUGRD                   = '';
        LT_ITEM.COMPLAINT_REASON        = '';
        LT_ITEM.ACCEPT                  = '';
        LT_ITEM.MATERIAL_N              = '';
        LT_ITEM.NETPR                   = '';
        LT_ITEM.DIEUCE                  = '';
        LT_ITEM.DIEUFL                  = '';
        LT_ITEM.DIUK                    = '';
        LT_ITEM.DIID                    = '';
        LT_ITEM.DI                      = '';
        LT_ITEM.DIUKL                   = '';
        LT_ITEM.ZZAPPMACHINE            = '';
        LT_ITEM.ZZEQMASTER              = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_FILE LT_FILE = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_FILE();
        LT_FILE.INT_NO              = '';
        LT_FILE.CHECK               = '';
        LT_FILE.DOCU_ITEM           = '';
        LT_FILE.VISIBLE             = '';
        LT_FILE.FILE_NAME           = '';
        LT_FILE.DESCRIPTION         = '';
        LT_FILE.FILE_DATA           = '';
        LT_FILE.FILE_NO             = '';
        LT_FILE.FILESIZE            = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PRICING_01 LT_PRICING_01 = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PRICING_01();
        LT_PRICING_01.NAME          = '';
        LT_PRICING_01.NEWR          = '';
        LT_PRICING_01.WAERK         = '';
        LT_PRICING_01.NETWR         = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PRICING_02 LT_PRICING_02 = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PRICING_02();
        LT_PRICING_02.NAME          = '';
        LT_PRICING_02.NEWR          = '';
        LT_PRICING_02.WAERK         = '';
        LT_PRICING_02.NETWR         = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_STATUS LT_STATUS = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_STATUS();
        LT_STATUS.CODE      = '';
        LT_STATUS.TEXT      = '';
        LT_STATUS.NAME      = '';

        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_RETURN Res_RETURN = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_RETURN();
        Res_RETURN.TYPE             = '';
        Res_RETURN.ID               = '';
        Res_RETURN.IF_NUMBER        = '';
        Res_RETURN.MESSAGE          = '';
        Res_RETURN.LOG_NO           = '';
        Res_RETURN.LOG_MSG_NO       = '';
        Res_RETURN.MESSAGE_V1       = '';
        Res_RETURN.MESSAGE_V2       = '';
        Res_RETURN.MESSAGE_V3       = '';
        Res_RETURN.MESSAGE_V4       = '';
        Res_RETURN.PARAMETER        = '';
        Res_RETURN.ROW              = '';
        Res_RETURN.FIELD            = '';
        Res_RETURN.IF_SYSTEM        = '';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_ERRORMSG ERRORMSG = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_ERRORMSG();
        ERRORMSG.NAME       = '';
        ERRORMSG.TEXT       = '';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_VALUESET LT_VALUESET = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_VALUESET();
        LT_VALUESET.VALUE       = '';
        LT_VALUESET.TEXT        = '';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_FILE2 LT_FILE2 = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_FILE2();
        LT_FILE2.INT_NO             = '';
        LT_FILE2.CHECK              = '';
        LT_FILE2.DOCU_ITEM          = '';
        LT_FILE2.VISIBLE            = '';
        LT_FILE2.FILE_NAME          = '';
        LT_FILE2.DESCRIPTION        = '';
        LT_FILE2.FILE_DATA          = '';
        LT_FILE2.FILE_NO            = '';
        LT_FILE2.FILESIZE           = '';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PARTNER LT_PARTNER = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_PARTNER();
        LT_PARTNER.VBELN            = '';
        LT_PARTNER.POSNR            = '';
        LT_PARTNER.PARVW            = '';
        LT_PARTNER.KUNNR            = '';
        LT_PARTNER.NAME1            = '';
        LT_PARTNER.NAME2            = '';
        LT_PARTNER.NAME3            = '';
        LT_PARTNER.NAME4            = '';
        LT_PARTNER.STREET1          = '';
        LT_PARTNER.STREET2          = '';
        LT_PARTNER.CITY1            = '';
        LT_PARTNER.CITY2            = '';
        LT_PARTNER.STATE            = '';
        LT_PARTNER.ZIP              = '';
        LT_PARTNER.HOUSE_NUM1       = '';
        LT_PARTNER.TEL_NUMBER       = '';
        LT_PARTNER.FAX_NUMBER       = '';
        LT_PARTNER.EMAIL            = '';
        LT_PARTNER.SIC_CODE         = '';
        LT_PARTNER.MAIL_OK          = '';
        LT_PARTNER.COUNTRY          = '';
        LT_PARTNER.TZONE            = '';
        LT_PARTNER.CONTACT          = '';
        LT_PARTNER.SORT2            = '';
        LT_PARTNER.PO_BOX_LOC       = '';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_CONDITION LT_CONDITION = new IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res_LT_CONDITION();
        LT_CONDITION.POSNR          = '';
        LT_CONDITION.KPOSN          = '';
        LT_CONDITION.STUNR          = '';
        LT_CONDITION.ZAEHK          = '';
        LT_CONDITION.KSCHL          = '';
        LT_CONDITION.KRECH          = '';
        LT_CONDITION.KBETR          = '';
        LT_CONDITION.WAERS          = '';
        LT_CONDITION.ZWAERS         = '';
        LT_CONDITION.KPEIN          = '';
        LT_CONDITION.KMEIN          = '';
        LT_CONDITION.KWERT          = '';
        LT_CONDITION.WAERK          = '';
        LT_CONDITION.VARCOND        = '';
        LT_CONDITION.KAWRT          = '';
        LT_CONDITION.KINAK          = '';
        LT_CONDITION.KAPPL          = '';
        LT_CONDITION.UPDATEFLAG     = '';

        Test.stopTest();
    }

    @isTest
    private static void IF_PARTS_009_Test () {
        InterfaceCommonUtil.setInterface('IF-PARTS-009', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req request = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req();
        
        // 기본 필드 값 설정
        request.ODKEY = 'test20250625';
        request.LS_APPLY = 'Y';
        request.LV_AUART = 'ZORD';
        request.I_USERID = 'TestUser';
        request.I_LANGU = 'EN';
        request.I_SHIPTO = 'SH123456';
        request.I_DATE = '20250315';
        request.I_CS = 'CS01';

        // I_USERINFO 객체 설정
        request.I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TestBNAME';
        request.I_USERINFO.RNAME = 'TestRNAME';
        request.I_USERINFO.HIER = 'TestHIER';
        request.I_USERINFO.KUNNR = '1000001';
        request.I_USERINFO.LIFNR = '2000001';
        request.I_USERINFO.VKORG = '1000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = '20';
        request.I_USERINFO.WERKS = '3000';
        request.I_USERINFO.ARBPL = '4000';
        request.I_USERINFO.PARNR = '5000001';
        request.I_USERINFO.ENAME = 'TestName';
        request.I_USERINFO.KUNN2 = '6000001';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = '7000';
        request.I_USERINFO.DF_CHK = 'X';
        request.I_USERINFO.CO_CHK = 'X';

        // LS_MAIN_HEAD 객체 설정
        request.LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LS_MAIN_HEAD();
        request.LS_MAIN_HEAD.KONDA = 'Z1';
        request.LS_MAIN_HEAD.KUNNR = '1000001';
        request.LS_MAIN_HEAD.KUNNR_NAME = 'Test Customer';
        request.LS_MAIN_HEAD.KUNNR_STREET = '123 Test St';
        request.LS_MAIN_HEAD.KUNAG = 'Test AG';
        request.LS_MAIN_HEAD.KUNAG_NAME = 'Test AG Name';
        request.LS_MAIN_HEAD.KUNAG_STREET = '456 Test St';
        request.LS_MAIN_HEAD.KUNNR_CR = 'A';
        request.LS_MAIN_HEAD.NETWR = '1000.00';
        request.LS_MAIN_HEAD.WAERK = 'USD';
        request.LS_MAIN_HEAD.CREDIT = '2000.00';
        request.LS_MAIN_HEAD.CREDIT_WAERK = 'USD';
        request.LS_MAIN_HEAD.TOTAL_WEIGHT = '50';
        request.LS_MAIN_HEAD.GEWEI = 'KG';
        request.LS_MAIN_HEAD.VOLUM = '10';
        request.LS_MAIN_HEAD.VOLEH = 'L';
        request.LS_MAIN_HEAD.KONDA_TEXT = 'Test Price Group';
        request.LS_MAIN_HEAD.KVGR5 = 'K5';
        request.LS_MAIN_HEAD.NAME = 'Main Head Name';
        request.LS_MAIN_HEAD.CITY = 'New York';
        request.LS_MAIN_HEAD.STREET = '789 Test St';
        request.LS_MAIN_HEAD.COUNTRY = 'US';
        request.LS_MAIN_HEAD.POSTL_CODE = '10001';
        request.LS_MAIN_HEAD.TRANSPZONE = 'Z1';
        request.LS_MAIN_HEAD.ORDER_DATE = '20250315';
        request.LS_MAIN_HEAD.PRICE_LIST = 'PL01';
        request.LS_MAIN_HEAD.COLLECT_NO = 'CN123';
        request.LS_MAIN_HEAD.ZTERM = 'ZT01';
        request.LS_MAIN_HEAD.ORD_REASON = 'OR01';
        request.LS_MAIN_HEAD.BZIRK = 'B01';
        request.LS_MAIN_HEAD.DOCUFEE = '10.00';

        // LS_ERROR_IGNORE 객체 설정
        request.LS_ERROR_IGNORE = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LS_ERROR_IGNORE();
        request.LS_ERROR_IGNORE.IGNORE = 'X';
        request.LS_ERROR_IGNORE.IGNORE_QTY = 'X';
        request.LS_ERROR_IGNORE.IGNORE_PRICE = 'X';
        request.LS_ERROR_IGNORE.IGNORE_DIVISION = 'X';
        request.LS_ERROR_IGNORE.IGNORE_PURCHASE = 'X';
        request.LS_ERROR_IGNORE.IGNORE_HAZARD = 'X';

        // LS_IMPORT_PORTAL 객체 설정
        request.LS_IMPORT_PORTAL = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LS_IMPORT_PORTAL();
        request.LS_IMPORT_PORTAL.DOC_CATEGORY = 'DC01';
        request.LS_IMPORT_PORTAL.DOC_MODE = 'M1';
        request.LS_IMPORT_PORTAL.COMPLAINT = 'C1';

        // I_ORG 객체 설정
        request.I_ORG = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_I_ORG();
        request.I_ORG.VKORG = '1000';
        request.I_ORG.VTWEG = '10';
        request.I_ORG.SPART = '20';
        request.I_ORG.WERKS = '3000';
        request.I_ORG.ARBPL = '4000';
        request.I_ORG.AMSCCTL = 'AC01';

        // LT_GERNERAL_ZTERM 리스트 설정
        request.LT_GERNERAL_ZTERM.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_GERNERAL_ZTERM());
        request.LT_GERNERAL_ZTERM[0].ZTERM = 'ZT01';
        request.LT_GERNERAL_ZTERM[0].TEXT = 'Payment Term';

        // LT_PARTNER 리스트 설정
        request.LT_PARTNER.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_PARTNER());
        request.LT_PARTNER[0].PARTN_ROLE = 'PR01';
        request.LT_PARTNER[0].PARTN_NUMB = 'P1001';
        request.LT_PARTNER[0].ITM_NUMBER = 'ITM01';
        request.LT_PARTNER[0].TITLE = 'Mr.';
        request.LT_PARTNER[0].NAME = 'John Doe';

        request.LT_PARTNER[0].NAME_2       = 'TEST';
        request.LT_PARTNER[0].NAME_3       = 'TEST';
        request.LT_PARTNER[0].NAME_4       = 'TEST';
        request.LT_PARTNER[0].STREET       = 'Street Address';
        request.LT_PARTNER[0].COUNTRY      = 'KR';

        request.LT_PARTNER[0].COUNTR_ISO   = 'KR';
        request.LT_PARTNER[0].POSTL_CODE   = '12345';
        request.LT_PARTNER[0].POBX_PCD     = '54321';
        request.LT_PARTNER[0].POBX_CTY     = 'Seoul';
        request.LT_PARTNER[0].CITY         = 'Seoul';

        request.LT_PARTNER[0].DISTRICT     = 'Gangnam';
        request.LT_PARTNER[0].REGION       = 'KR-11';
        request.LT_PARTNER[0].PO_BOX       = 'PO123';
        request.LT_PARTNER[0].TELEPHONE    = '010-1234-5678';
        request.LT_PARTNER[0].TELEPHONE2   = '010-8765-4321';

        request.LT_PARTNER[0].TELEBOX      = 'Telebox';
        request.LT_PARTNER[0].FAX_NUMBER   = '02-1234-5678';
        request.LT_PARTNER[0].TELETEX_NO   = 'Teletex';
        request.LT_PARTNER[0].TELEX_NO     = 'Telex';
        request.LT_PARTNER[0].LANGU        = 'KO';

        request.LT_PARTNER[0].LANGU_ISO    = 'KO';
        request.LT_PARTNER[0].UNLOAD_PT    = 'Unload Point';
        request.LT_PARTNER[0].TRANSPZONE   = 'Trans Zone';
        request.LT_PARTNER[0].TAXJURCODE   = 'Tax Code';
        request.LT_PARTNER[0].ADDRESS      = 'Full Address';

        request.LT_PARTNER[0].PRIV_ADDR    = 'Private Address';
        request.LT_PARTNER[0].ADDR_TYPE    = 'Type';
        request.LT_PARTNER[0].ADDR_ORIG    = 'Origin';
        request.LT_PARTNER[0].ADDR_LINK    = 'Link';
        request.LT_PARTNER[0].REFOBJTYPE   = 'RefObjType';

        request.LT_PARTNER[0].REFOBJKEY    = 'RefObjKey';
        request.LT_PARTNER[0].REFLOGSYS    = 'RefLogSys';

        // LT_ITEM 리스트 설정
        request.LT_ITEM.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_ITEM());
        request.LT_ITEM[0].CCHECK = 'X';
        request.LT_ITEM[0].ITEM = 'ITM001';
        request.LT_ITEM[0].HILV = 'H01';
        request.LT_ITEM[0].MATERIAL = 'MAT001';
        request.LT_ITEM[0].MATERIAL_TEXT = 'Test Material';
        request.LT_ITEM[0].QTY = '10';
        request.LT_ITEM[0].UOM = 'EA';
        request.LT_ITEM[0].NET_PRICE = '100.00';
        request.LT_ITEM[0].NET_ITEM_PRICE = '1000.00';
        request.LT_ITEM[0].NET_VALUE = '10000.00';
        request.LT_ITEM[0].LIST_PRICE = '120.00';
        request.LT_ITEM[0].IF_CURRENCY = 'USD';

        request.LT_ITEM[0].AVAILABILITY     = 'TEST';
        request.LT_ITEM[0].REF_ORD          = 'TEST';
        request.LT_ITEM[0].REF_ITEM         = 'TEST';

        request.LT_ITEM[0].COMPLAINT        = 'TEST';
        request.LT_ITEM[0].COMPLAINT_DESC   = 'TEST';
        request.LT_ITEM[0].PLANT            = 'TEST';
        request.LT_ITEM[0].O                = 'TEST';
        request.LT_ITEM[0].C                = 'TEST';

        request.LT_ITEM[0].D                = 'TEST';
        request.LT_ITEM[0].BD               = 'TEST';
        request.LT_ITEM[0].BO               = 'TEST';
        request.LT_ITEM[0].DB               = 'TEST';
        request.LT_ITEM[0].R                = 'TEST';

        request.LT_ITEM[0].PLANT_TX         = 'TEST';
        request.LT_ITEM[0].USAGE_HILV       = 'TEST';
        request.LT_ITEM[0].CHEKCABLE        = 'TEST';
        request.LT_ITEM[0].MATNR_CHECK      = 'TEST';
        request.LT_ITEM[0].A                = 'TEST';

        request.LT_ITEM[0].REQ_QTY          = 'TEST';
        request.LT_ITEM[0].LOT_QTY          = 'TEST';
        request.LT_ITEM[0].MIN_QTY          = 'TEST';
        request.LT_ITEM[0].MATNR_DESIGN     = 'TEST';
        request.LT_ITEM[0].REQ_QTY_DESIGN   = 'TEST';

        request.LT_ITEM[0].ZZDEALDT         = 'TEST';
        request.LT_ITEM[0].WAERS            = 'TEST';
        request.LT_ITEM[0].REASON           = 'TEST';
        request.LT_ITEM[0].INPUT_QTY        = 'TEST';
        request.LT_ITEM[0].EXCEL            = 'TEST';

        request.LT_ITEM[0].MVGR5            = 'TEST';
        request.LT_ITEM[0].MATERIAL_ENT     = 'TEST';
        request.LT_ITEM[0].ERRORCHECK       = 'TEST';
        request.LT_ITEM[0].ERRORMSG         = 'TEST';
        request.LT_ITEM[0].SUGRD            = 'TEST';

        request.LT_ITEM[0].COMPLAINT_REASON = 'TEST';
        request.LT_ITEM[0].ACCEPT           = 'TEST';
        request.LT_ITEM[0].MATERIAL_N       = 'TEST';
        request.LT_ITEM[0].NETPR            = 'TEST';
        request.LT_ITEM[0].DIEUCE           = 'TEST';

        request.LT_ITEM[0].DIEUFL           = 'TEST';
        request.LT_ITEM[0].DIUK             = 'TEST';
        request.LT_ITEM[0].DIID             = 'TEST';
        request.LT_ITEM[0].DI               = 'TEST';
        request.LT_ITEM[0].DIUKL            = 'TEST';

        request.LT_ITEM[0].MEINS            = 'TEST';
        request.LT_ITEM[0].HERKL            = 'TEST';
        request.LT_ITEM[0].KONDM            = 'TEST';
        request.LT_ITEM[0].NTGEW            = 'TEST';
        request.LT_ITEM[0].GEWEI            = 'TEST';

        request.LT_ITEM[0].POUND            = 'TEST';
        request.LT_ITEM[0].KUNNR            = 'TEST';
        request.LT_ITEM[0].TDLNR            = 'TEST';
        request.LT_ITEM[0].TDLNR_NAME       = 'TEST';
        request.LT_ITEM[0].BSTKD_E          = 'TEST';

        request.LT_ITEM[0].BSTDK_E          = 'TEST';
        request.LT_ITEM[0].AVAIL_QTY1       = 'TEST';
        request.LT_ITEM[0].AVAIL_QTY2       = 'TEST';
        request.LT_ITEM[0].ZZAPPMACHINE     = 'TEST';
        request.LT_ITEM[0].ZZEQMASTER       = 'TEST';
        request.LT_ITEM[0].ZZWORKHRS        = 'TEST';

        request.LT_ITEM[0].TNDR_TRKID       = 'TEST';
        request.LT_ITEM[0].STATUS           = 'TEST';
        request.LT_ITEM[0].MITEM            = 'TEST';
        request.LT_ITEM[0].TO_PART          = 'TEST';
        request.LT_ITEM[0].BULLETIN         = 'TEST';

        request.LT_ITEM[0].BULL_MATNR       = 'TEST';
        request.LT_ITEM[0].MEMO             = 'TEST';
        request.LT_ITEM[0].MEMO_MATNR       = 'TEST';
        request.LT_ITEM[0].EMERC            = 'TEST';

        // LT_STATUS 리스트 설정
        request.LT_STATUS.add(new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_STATUS());
        request.LT_STATUS[0].CODE = 'S01';
        request.LT_STATUS[0].TEXT = 'Success';
        request.LT_STATUS[0].NAME = 'Status Name';

        // 응답 객체 생성
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res response = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res();

        // 기본 필드 값 설정
        response.E_MEG = 'Test Message';

        // LS_MAIN_HEAD_RESULT 객체 설정
        response.LS_MAIN_HEAD_RESULT = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LS_MAIN_HEAD_RESULT();
        response.LS_MAIN_HEAD_RESULT.KONDA = 'Z1';
        response.LS_MAIN_HEAD_RESULT.KUNNR = '1000001';
        response.LS_MAIN_HEAD_RESULT.KUNNR_NAME = 'Test Customer';
        response.LS_MAIN_HEAD_RESULT.KUNNR_STREET = '123 Test St';
        response.LS_MAIN_HEAD_RESULT.KUNAG = 'Test AG';
        response.LS_MAIN_HEAD_RESULT.KUNAG_NAME = 'Test AG Name';
        response.LS_MAIN_HEAD_RESULT.KUNAG_STREET = '456 Test St';
        response.LS_MAIN_HEAD_RESULT.KUNNR_CR = 'A';
        response.LS_MAIN_HEAD_RESULT.NETWR = '1000.00';
        response.LS_MAIN_HEAD_RESULT.WAERK = 'USD';
        response.LS_MAIN_HEAD_RESULT.CREDIT = '2000.00';
        response.LS_MAIN_HEAD_RESULT.CREDIT_WAERK = 'USD';

        // O_RETURN 객체 설정
        response.O_RETURN = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '000';
        response.O_RETURN.MESSAGE = 'Success';

        // LT_ITEM 리스트 설정
        response.LT_ITEM = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_ITEM>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_ITEM item = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_ITEM();
        item.ITEM = 'ITM001';
        item.MATERIAL = 'MAT001';
        item.MATERIAL_TEXT = 'Test Material';
        item.QTY = '10';
        item.UOM = 'EA';
        item.NET_PRICE = '100.00';
        item.NET_ITEM_PRICE = '1000.00';
        item.NET_VALUE = '10000.00';
        item.LIST_PRICE = '120.00';
        item.IF_CURRENCY = 'USD';
        item.AVAILABILITY       = 'test';
        item.REF_ORD            = 'test';
        item.REF_ITEM           = 'test';
        item.COMPLAINT          = 'test';
        item.COMPLAINT_DESC     = 'test';
        item.PLANT              = 'test';
        item.O                  = 'test';
        item.C                  = 'test';
        item.D                  = 'test';
        item.BD                 = 'test';
        item.BO                 = 'test';
        item.DB                 = 'test';
        item.R                  = 'test';
        item.PLANT_TX           = 'test';
        item.USAGE_HILV         = 'test';
        item.CHEKCABLE          = 'test';
        item.MATNR_CHECK        = 'test';
        item.A                  = 'test';
        item.REQ_QTY            = 'test';
        item.LOT_QTY            = 'test';
        item.MIN_QTY            = 'test';
        item.MATNR_DESIGN       = 'test';
        item.REQ_QTY_DESIGN     = 'test';
        item.ZZDEALDT           = 'test';
        item.WAERS              = 'test';
        item.REASON             = 'test';
        item.INPUT_QTY          = 'test';
        item.EXCEL              = 'test';
        item.MVGR5              = 'test';
        item.MATERIAL_ENT       = 'test';
        item.ERRORCHECK         = 'test';
        item.ERRORMSG           = 'test';
        item.SUGRD              = 'test';
        item.COMPLAINT_REASON   = 'test';
        item.ACCEPT             = 'test';
        item.MATERIAL_N         = 'test';
        item.NETPR              = 'test';
        item.DIEUCE             = 'test';
        item.DIEUFL             = 'test';
        item.DIUK               = 'test';
        item.DIID               = 'test';
        item.DI                 = 'test';
        item.DIUKL              = 'test';
        item.MEINS              = 'test';
        item.HERKL              = 'test';
        item.KONDM              = 'test';
        item.NTGEW              = 'test';
        item.GEWEI              = 'test';
        item.POUND              = 'test';
        item.KUNNR              = 'test';
        item.TDLNR              = 'test';
        item.TDLNR_NAME         = 'test';
        item.BSTKD_E            = 'test';
        item.BSTDK_E            = 'test';
        item.AVAIL_QTY1         = 'test';
        item.ZZAPPMACHINE       = 'test';
        item.ZZEQMASTER         = 'test';
        item.ZZWORKHRS          = 'test';
        item.TNDR_TRKID         = 'test';
        item.STATUS             = 'test';
        item.MITEM              = 'test';
        item.TO_PART            = 'test';
        item.BULLETIN           = 'test';
        item.BULL_MATNR         = 'test';
        item.MEMO               = 'test';
        item.MEMO_MATNR         = 'test';
        item.EMERC              = 'test';
        response.LT_ITEM.add(item);

        // LT_PRICING_01 리스트 설정
        response.LT_PRICING_01 = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_PRICING_01>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_PRICING_01 pricing1 = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_PRICING_01();
        pricing1.NAME = 'Test Pricing';
        pricing1.NEWR = '1000';
        pricing1.WAERK = 'USD';
        pricing1.NETWR = '900.00';
        response.LT_PRICING_01.add(pricing1);

        // LT_PRICING_02 리스트 설정
        response.LT_PRICING_02 = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_PRICING_02>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_PRICING_02 pricing2 = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_PRICING_02();
        pricing2.NAME = 'Test Pricing 2';
        pricing2.NEWR = '1500';
        pricing2.WAERK = 'USD';
        pricing2.NETWR = '1350.00';
        response.LT_PRICING_02.add(pricing2);

        // LT_STATUS 리스트 설정
        response.LT_STATUS = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_STATUS>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_STATUS status = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_STATUS();
        status.CODE = 'S01';
        status.TEXT = 'Success';
        status.NAME = 'Status Name';
        response.LT_STATUS.add(status);

        // ERRORMSG 리스트 설정
        response.ERRORMSG = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_ERRORMSG>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_ERRORMSG errorMsg = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_ERRORMSG();
        errorMsg.NAME = 'Error';
        errorMsg.TEXT = 'Invalid data';
        response.ERRORMSG.add(errorMsg);

        // LT_NON_EXIST 리스트 설정
        response.LT_NON_EXIST = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_NON_EXIST>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_NON_EXIST nonExist = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LT_NON_EXIST();
        nonExist.ERROR_MATNR = 'MAT002';
        nonExist.APPLY = 'N';
        nonExist.ITEM = 'ITM002';
        nonExist.MESSAGE = 'Material does not exist';
        response.LT_NON_EXIST.add(nonExist);

        // LS_GENERAL 객체 설정
        response.LS_GENERAL = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res_LS_GENERAL();
        response.LS_GENERAL.BSTNK = 'PO12345';
        response.LS_GENERAL.VDATU = '20250320';
        response.LS_GENERAL.INCO1 = 'EXW';
        response.LS_GENERAL.INCO2 = 'FOB';
        response.LS_GENERAL.VSBED = 'A1';
        response.LS_GENERAL.COMPLETE_DELIVERY = 'Yes';

        Test.stopTest();
    }

    @isTest
    private static void IF_PARTS_012_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-012', className);
        
        Test.startTest();
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_012_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_012_Req();
        req.I_FDATE = '';
        req.I_TDATE = '';
        req.I_VBELN = '';
        req.I_BSTKD = '';
        req.I_AUART = '';
        req.I_KONDA = '';
        req.I_PENDING = '';
        req.I_MATNR = '';
        req.I_DIG = '';
        req.I_EQFNR = '';
        req.I_STATUS = '';
        req.I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_012_Req_I_USERINFO();
        
        req.I_USERINFO.BNAME = '';
        req.I_USERINFO.RNAME = '';
        req.I_USERINFO.HIER = '';
        req.I_USERINFO.KUNNR = '';
        req.I_USERINFO.LIFNR = '';
        req.I_USERINFO.VKORG = '';
        req.I_USERINFO.VTWEG = '';
        req.I_USERINFO.SPART = '';
        req.I_USERINFO.WERKS = '';
        req.I_USERINFO.ARBPL = '';
        req.I_USERINFO.PARNR = '';
        req.I_USERINFO.ENAME = '';
        req.I_USERINFO.KUNN2 = '';
        req.I_USERINFO.LAND1 = '';
        req.I_USERINFO.LGORT = '';
        req.I_USERINFO.DF_CHK = '';
        req.I_USERINFO.CO_CHK = '';
        
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        instance.IF_PARTS_012(req);
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res res = new IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res();
        res.O_MESG = '';
        res.O_COUNT = '';
        res.O_RETURN = new IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res_O_RETURN();
        res.O_RETURN.TYPE = '';
        res.O_RETURN.CODE = '';
        res.O_RETURN.MESSAGE = '';
        res.O_RETURN.LOG_NO = '';
        res.O_RETURN.LOG_MSG_NO = '';
        res.O_RETURN.MESSAGE_V1 = '';
        res.O_RETURN.MESSAGE_V2 = '';
        res.O_RETURN.MESSAGE_V3 = '';
        res.O_RETURN.MESSAGE_V4 = '';
        res.T_HEADER = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res_T_HEADER>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res_T_HEADER header = new IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res_T_HEADER();
        header.VBELN = '';
        header.BSTKD = '';
        header.AUART = '';
        header.AUART_T = '';
        header.KONDA = '';
        header.KONDA_T = '';
        header.ZTERM = '';
        header.ZTERM_T = '';
        header.VSBED = '';
        header.VSBED_T = '';
        header.WAERK = '';
        header.SO_ITEM = '';
        header.SO_AMT = '';
        header.RE_AMT = '';
        header.PI_AMT = '';
        header.IN_AMT = '';
        header.SH_AMT = '';
        header.BO_AMT = '';
        header.CA_AMT = '';
        header.KWMENG = '';
        header.SO_QTY = '';
        header.PI_QTY = '';
        header.SH_QTY = '';
        header.RE_QTY = '';
        header.IN_QTY = '';
        header.CFM_QTY = '';
        header.RJ_QTY = '';
        header.VRKME = '';
        header.ERDAT = '';
        header.EQFNR = '';
        header.KUNWE = '';
        header.NAME1 = '';
        header.ZZAPPNO = '';
        header.NAME2 = '';
        header.BNAME = '';
        header.STATUS = '';
        header.LIFSK = '';
        res.T_HEADER.add(header);
        
        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_013_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-013', className);
        
        Test.startTest();
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req();
        req.I_FDATE = '';
        req.I_TDATE = '';
        req.I_VBELN = '';
        req.I_BSTKD = '';
        req.I_MATNR = '';
        req.I_STATUS = '';
        req.I_DROP = '';
        req.I_SCOMB = '';
        req.LT_VBELN = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN>();
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN ltVbeln = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN();
        ltVbeln.VBELN = '';
        req.LT_VBELN.add(ltVbeln);
        
        req.I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_I_USERINFO();
        req.I_USERINFO.BNAME = '';
        req.I_USERINFO.RNAME = '';
        req.I_USERINFO.HIER = '';
        req.I_USERINFO.KUNNR = '';
        req.I_USERINFO.LIFNR = '';
        req.I_USERINFO.VKORG = '';
        req.I_USERINFO.VTWEG = '';
        req.I_USERINFO.SPART = '';
        req.I_USERINFO.WERKS = '';
        req.I_USERINFO.ARBPL = '';
        req.I_USERINFO.PARNR = '';
        req.I_USERINFO.ENAME = '';
        req.I_USERINFO.KUNN2 = '';
        req.I_USERINFO.LAND1 = '';
        req.I_USERINFO.LGORT = '';
        req.I_USERINFO.DF_CHK = '';
        req.I_USERINFO.CO_CHK = '';
        
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        instance.IF_PARTS_013(req);
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res res = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res();
        res.O_MESG = '';
        res.O_COUNT = '';
        res.O_RETURN = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_O_RETURN();
        res.O_RETURN.TYPE = '';
        res.O_RETURN.CODE = '';
        res.O_RETURN.MESSAGE = '';
        res.O_RETURN.LOG_NO = '';
        res.O_RETURN.LOG_MSG_NO = '';
        res.O_RETURN.MESSAGE_V1 = '';
        res.O_RETURN.MESSAGE_V2 = '';
        res.O_RETURN.MESSAGE_V3 = '';
        res.O_RETURN.MESSAGE_V4 = '';
        
        res.T_SALES_AREA = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_SALES_AREA>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_SALES_AREA salesArea = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_SALES_AREA();
        salesArea.VKORG = '';
        salesArea.VTWEG = '';
        salesArea.SPART = '';
        res.T_SALES_AREA.add(salesArea);
        
        res.T_DETAIL = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL>();
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL detail = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL();
        detail.VBELN = '';
        detail.BSTKD = '';
        detail.POSNR = '';
        detail.POSNR_H = '';
        detail.ETENR = '';
        detail.ERDAT = '';
        detail.AUDAT = '';
        detail.KONDA = '';
        detail.KONDA_T = '';
        detail.AUART = '';
        detail.AUART_T = '';
        detail.MATNR_SO = '';
        detail.MATNR_SH = '';
        detail.MAKTX = '';
        detail.SO_QTY = '';
        detail.PI_QTY = '';
        detail.SH_QTY = '';
        detail.RE_QTY = '';
        detail.IN_QTY = '';
        detail.CFM_QTY = '';
        detail.STB_QTY = '';
        detail.VRKME = '';
        detail.FST_ETD = '';
        detail.LST_ETD = '';
        detail.DODAT = '';
        detail.VSTEL = '';
        detail.VTEXT = '';
        detail.EMERC = '';
        res.T_DETAIL.add(detail);
        
        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_026_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-026', className);
        
        Test.startTest();
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req();
        req.I_VKORG = '';
        req.I_VTWEG = '';
        req.I_SPART = '';
        req.I_KUNNR = '';
        req.I_VBELN = '';
        req.I_USERID = '';
        req.IT_ITEM = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req_IT_ITEM>();
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req_IT_ITEM item = new IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req_IT_ITEM();
        item.POSNR = '';
        item.ETENR = '';
        item.EMERC = '';
        req.IT_ITEM.add(item);
        
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        instance.IF_PARTS_026(req);
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res res = new IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res();
        IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res_ES_RETURN ES_RETURN = new IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res_ES_RETURN();
        ES_RETURN.TYPE = '';
        ES_RETURN.ID = '';
        ES_RETURN.IF_NUMBER = '';
        ES_RETURN.MESSAGE = '';
        ES_RETURN.LOG_NO = '';
        ES_RETURN.LOG_MSG_NO = '';
        ES_RETURN.MESSAGE_V1 = '';
        ES_RETURN.MESSAGE_V2 = '';
        ES_RETURN.MESSAGE_V3 = '';
        ES_RETURN.MESSAGE_V4 = '';
        ES_RETURN.PARAMETER = '';
        ES_RETURN.ROW = '';
        ES_RETURN.FIELD = '';
        ES_RETURN.IF_SYSTEM = '';
        
        Test.stopTest();
    }

}