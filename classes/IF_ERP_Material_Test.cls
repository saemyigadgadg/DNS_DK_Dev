/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-29
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-24   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class IF_ERP_Material_Test {
    private static String className = 'IF_ERP_Material';

    public IF_ERP_Material_Test() {}

/* Mock Classes
    */
    public class IF_CSPLUS_007_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_007_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"2 Records Found."},"T_O_LIST":[{"ILART":"204","SOLDTO1":"","QZEIT":"00:00:00","POSNN_VL":"000000","RETURN_YN":"N","EXTI1":"","STATUS":"","TKNUM":"","INVOICE":"","SOLDTO":"0001307755","KWMENG":"1","VNDNM":"대영코어텍(주)","NAME4":"경호기계","BMENG":"0.000","NAME3":"","NAME2":"(주)원창테크","NAME1":"영진기계","RETURN_TYPE":"7","GWLDT":"2023-12-31","VSMNG":"0.000","QMSEQ":"0020","POCONT_YN":"Y","MEINS":"KIT","GSMNG":"0.000","TDLNR_NAME":"","SDATE":"0000-00-00","VBELN_VL1":"","MATNR":"R18181","MATNR_TXT":"재고보유","OBJNR":"OR000403908683","MAKTX":"DNM 4500","POSNR":"000000","ZSUPPLY":"02","REQ_DATE":"0000-00-00","PRETD":"0000-00-00","VSBED":"20","AUFNR":"403908682","RECV_DT":"2025-04-29","PRETD3":"0000-00-00","PRETD2":"0000-00-00","LIFNR":"0010034021","KUNUM":"0001325706","TYPBZ":"DNM 4500","SERNR":"ML0006-006232","TDLNR":"","DODAT":"0000-00-00","QMNUM":"302382687","VBELN_VL":"","ETD":"0000-00-00","QDATU":"0000-00-00","RETURN_TEXT":"","DEALER_CD":"0001057455","VBELN":""},{"ILART":"204","SOLDTO1":"","QZEIT":"00:00:00","POSNN_VL":"000000","RETURN_YN":"N","EXTI1":"","STATUS":"","TKNUM":"","INVOICE":"","SOLDTO":"0001307755","KWMENG":"1","VNDNM":"대영코어텍(주)","NAME4":"경호기계","BMENG":"0.000","NAME3":"","NAME2":"(주)원창테크","NAME1":"영진기계","RETURN_TYPE":"7","GWLDT":"2023-12-31","VSMNG":"0.000","QMSEQ":"0010","POCONT_YN":"Y","MEINS":"KIT","GSMNG":"0.000","TDLNR_NAME":"","SDATE":"0000-00-00","VBELN_VL1":"","MATNR":"R18181","MATNR_TXT":"재고보유","OBJNR":"OR000403908682","MAKTX":"DNM 4500","POSNR":"000000","ZSUPPLY":"02","REQ_DATE":"0000-00-00","PRETD":"0000-00-00","VSBED":"20","AUFNR":"403908682","RECV_DT":"2025-04-29","PRETD3":"0000-00-00","PRETD2":"0000-00-00","LIFNR":"0010034021","KUNUM":"0001325706","TYPBZ":"DNM 4500","SERNR":"ML0006-006232","TDLNR":"","DODAT":"0000-00-00","QMNUM":"302382687","VBELN_VL":"","ETD":"0000-00-00","QDATU":"0000-00-00","RETURN_TEXT":"","DEALER_CD":"0001057455","VBELN":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_017_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_017_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"Success to Save Data","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"T_RETURN":[{"SYSTEM":"","LOG_NO":"$000003","LOG_MSG_NO":"000001","NUMBER":"506","PARAMETER":"","MESSAGE":"Saving changes to assignments","FIELD":"","ROW":"0","TYPE":"S","ID":"CL","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":""},{"SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","NUMBER":"737","PARAMETER":"","MESSAGE":"Assignment changed","FIELD":"","ROW":"0","TYPE":"S","ID":"CL","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_017_Error_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_017_Error_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"E","ID":"","NUMBER":"000","MESSAGE":"Success to Save Data","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"T_RETURN":[{"SYSTEM":"","LOG_NO":"$000003","LOG_MSG_NO":"000001","NUMBER":"506","PARAMETER":"","MESSAGE":"Saving changes to assignments","FIELD":"","ROW":"0","TYPE":"S","ID":"CL","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":""},{"SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","NUMBER":"737","PARAMETER":"","MESSAGE":"Assignment changed","FIELD":"","ROW":"0","TYPE":"S","ID":"CL","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_018_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_018_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished."},"T_DOCUMENT":[],"T_ITEM":[{"RES_PLANT":"","ZZ_INST_FINISH":"0000-00-00","M_ATWRT2":"6000 R/MIN","LOC_ARBPL":"1244842","RES_MN_WK_CTR":"1244842","STREET":"","GWLEN":"0000-00-00","HERST":"1840/0AM1","PERSON_RES":"00006527","POST_CODE1":"","IWERK":"","EQART":"CS_MT_PHM","TXT04":"ECUS","M_ATWRT":"FANUC 31I-B PLUS","EQUNR":"MH0015-000307","INGRP":"","BEBER":"","LOC_ARBPL_TXT":"","COUNTRY":"","ZI_KUNNR":"0001127223","INBDT":"0000-00-00","CITY1":"","EQKTX":"MH0015-000307 (APO)","INTERNAL_NOTE":"","V_GWLEN":"0000-00-00","NAME2":"","IF_CLASS":"CS_MT_PART_SERIAL","ZI_ORT01":"대전광역시 대덕구 회덕로21번길","KDAUF":"","NAME1":"","GWLDT":"0000-00-00","ZI_STRAS":"63(신대동)","WADAT_IST":"0000-00-00","SWERK":"","GTEXT":"Machine Tools","DO_VBELN":"0201941762","BUTXT":"","BEBER_TXT":"","BUKRS":"","IWERK_TXT":"","REGION":"","ANSDT":"0000-00-00","MATNR":"NHM500-F31P-0-K30","ORG_ARBPL":"1244842","TEL_NUMBER":"","HERLD":"KR","GSBER":"B140","ZI_NAME1":"주식회사 디에스엠티충청","V_GWLDT":"0000-00-00","WERKS":"","PERSON_RES_NAME":"","RBNR":"CS_MT_PHM","ORG_ARBPL_TXT":"","ZZ_INST_START":"0000-00-00","SERNR":"MH0015-000307","STRATEGIC_EQUIP_FLAG":"","TYPBZ":"NHM 5000","SWERK_TXT":"","BAUMM":"","BAUJJ":"","RBNRX":"Horizontal Maching Center","ZI_PSTLZ":"34349","EARTX":"Horizontal M/C","ATWRT":"","INNAM":""}],"T_PARTNERS_INFO":[{"VTEXT":"Sold-to party","EQUNR":"MV0089-003848","ORT01":"경기도 화성시 송산면 공룡로","PARNR":"0001326780","NAME1":"(주)아프로테크플러스"},{"VTEXT":"Bill-to party","EQUNR":"MV0089-003848","ORT01":"경기도 안산시 단원구 풍전로 37-9","PARNR":"0001311191","NAME1":"주식회사 디에스엠티"},{"VTEXT":"Ship-to party","EQUNR":"MV0089-003848","ORT01":"충청남도 천안시 서북구 직산읍 4산단3로","PARNR":"0001237758","NAME1":"(주)제이아이테크"}],"T_DOCUMENT_FILE":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_018_Error_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_018_Error_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"E","CODE":"","MESSAGE":"Successfully finished."},"T_DOCUMENT":[],"T_ITEM":[{"RES_PLANT":"","ZZ_INST_FINISH":"0000-00-00","M_ATWRT2":"6000 R/MIN","LOC_ARBPL":"1244842","RES_MN_WK_CTR":"1244842","STREET":"","GWLEN":"0000-00-00","HERST":"1840/0AM1","PERSON_RES":"00006527","POST_CODE1":"","IWERK":"","EQART":"CS_MT_PHM","TXT04":"ECUS","M_ATWRT":"FANUC 31I-B PLUS","EQUNR":"MH0015-000307","INGRP":"","BEBER":"","LOC_ARBPL_TXT":"","COUNTRY":"","ZI_KUNNR":"0001127223","INBDT":"0000-00-00","CITY1":"","EQKTX":"MH0015-000307 (APO)","INTERNAL_NOTE":"","V_GWLEN":"0000-00-00","NAME2":"","IF_CLASS":"CS_MT_PART_SERIAL","ZI_ORT01":"대전광역시 대덕구 회덕로21번길","KDAUF":"","NAME1":"","GWLDT":"0000-00-00","ZI_STRAS":"63(신대동)","WADAT_IST":"0000-00-00","SWERK":"","GTEXT":"Machine Tools","DO_VBELN":"0201941762","BUTXT":"","BEBER_TXT":"","BUKRS":"","IWERK_TXT":"","REGION":"","ANSDT":"0000-00-00","MATNR":"NHM500-F31P-0-K30","ORG_ARBPL":"1244842","TEL_NUMBER":"","HERLD":"KR","GSBER":"B140","ZI_NAME1":"주식회사 디에스엠티충청","V_GWLDT":"0000-00-00","WERKS":"","PERSON_RES_NAME":"","RBNR":"CS_MT_PHM","ORG_ARBPL_TXT":"","ZZ_INST_START":"0000-00-00","SERNR":"MH0015-000307","STRATEGIC_EQUIP_FLAG":"","TYPBZ":"NHM 5000","SWERK_TXT":"","BAUMM":"","BAUJJ":"","RBNRX":"Horizontal Maching Center","ZI_PSTLZ":"34349","EARTX":"Horizontal M/C","ATWRT":"","INNAM":""}],"T_PARTNERS_INFO":[{"VTEXT":"Sold-to party","EQUNR":"MV0089-003848","ORT01":"경기도 화성시 송산면 공룡로","PARNR":"0001326780","NAME1":"(주)아프로테크플러스"},{"VTEXT":"Bill-to party","EQUNR":"MV0089-003848","ORT01":"경기도 안산시 단원구 풍전로 37-9","PARNR":"0001311191","NAME1":"주식회사 디에스엠티"},{"VTEXT":"Ship-to party","EQUNR":"MV0089-003848","ORT01":"충청남도 천안시 서북구 직산읍 4산단3로","PARNR":"0001237758","NAME1":"(주)제이아이테크"}],"T_DOCUMENT_FILE":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_021_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_021_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"ES_INFO":{"MAKTX":"DRIVE,SERVO;TURRET_ATC","REPNR":"300419-00035B","THREAD":"DVSC-TM-14E-01","MEINS":"EA","LABST":"57","NETPR":"1195600","WAERS":"KRW","CUQTY":"0","AVQTY":"0","SOQTY":"0","PRQTY":"0","DMTOP":"0","OTHOP":"0","LOC":"","DIQTY":"","STQTY":"0","GIQTY":"0","YGQTY":"0","LAST_EX_DT":"00000000","LAST_IM_DT":"00000000","BLQTY":"0","ZNOTE":"","MPPS_YN":"N","NONMV":"N","AVRLT":"24","PLIFZ":"30","DISMM":"","MAABC":"","WAMD":"","MINBE":"","MABST":"","BSTRF":"","BSTMI":"","HSCODE":"","IGST":"","SVRCD":"S","SVRCD_T":"Service","NTGEW":"3.620","GEWEI":"KG","HERKL":"","DENET":"","DASTK":"","LTEXT":""},"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"조회완료","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"ET_AVAIL":[],"ET_CROSS":[]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_024_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_024_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"11 Records Found."},"T_O_LIST":[{"EQKTX":"MV0092-000064 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0092-000064","GWLDT":"2016-06-17","INBDT":"2016-06-17","EQUNR":"MV0092-000064","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0092-000064","TYPBZ":"DNM 6700"},{"EQKTX":"MV0062-000214 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0062-000214","GWLDT":"2014-06-20","INBDT":"2014-06-19","EQUNR":"MV0062-000214","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0062-000214","TYPBZ":"DNM 750L"},{"EQKTX":"MV0062-000326 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0062-000326","GWLDT":"2015-09-24","INBDT":"2015-09-23","EQUNR":"MV0062-000326","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0062-000326","TYPBZ":"DNM 750L II"},{"EQKTX":"MV0048-003499 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0048-003499","GWLDT":"2022-05-16","INBDT":"2022-04-30","EQUNR":"MV0048-003499","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0048-003499","TYPBZ":"MYNX 6500 II"},{"EQKTX":"MV0048-002130 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0048-002130","GWLDT":"2016-10-28","INBDT":"2016-10-25","EQUNR":"MV0048-002130","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0048-002130","TYPBZ":"MYNX 6500/40"},{"EQKTX":"MV0054-000823 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0054-000823","GWLDT":"2017-04-15","INBDT":"2017-04-15","EQUNR":"MV0054-000823","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0054-000823","TYPBZ":"VM 6500"},{"EQKTX":"MV0054-000824 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0054-000824","GWLDT":"2017-04-15","INBDT":"2017-04-15","EQUNR":"MV0054-000824","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0054-000824","TYPBZ":"VM 6500"},{"EQKTX":"MV0054-000825 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0054-000825","GWLDT":"2017-04-15","INBDT":"2017-04-15","EQUNR":"MV0054-000825","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0054-000825","TYPBZ":"VM 6500"},{"EQKTX":"MV0054-000884 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0054-000884","GWLDT":"2017-08-24","INBDT":"2017-07-19","EQUNR":"MV0054-000884","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0054-000884","TYPBZ":"VM 6500"},{"EQKTX":"MV0054-000885 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0054-000885","GWLDT":"2017-08-24","INBDT":"2017-07-19","EQUNR":"MV0054-000885","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0054-000885","TYPBZ":"VM 6500"},{"EQKTX":"MV0054-001258 (APO)","PARNR":"0001237758","RBNR":"CS_MT_PVM","OBJNR":"IEMV0054-001258","GWLDT":"2020-11-25","INBDT":"2020-11-25","EQUNR":"MV0054-001258","MAINWC":"","WC":"","NAME1":"(주)제이아이테크","SERNR":"MV0054-001258","TYPBZ":"VM 6500"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);

            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_031_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_031_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"Success.","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"T_O_LIST":[{"ZTYPE":"N","MEINS":"AY","MAKTX":"CARTRIDGE ASSY;BBT 12K W/O TSC","MENGE":"11","MATNR":"101507-00353E","NETWR":"4500000","PLIFZ":"60","WAERS":"KRW"},{"ZTYPE":"R","MEINS":"AY","MAKTX":"CARTRIDGE ASSY;REPLACEMENT","MENGE":"1","MATNR":"101507-00353E-RM","NETWR":"3600000","PLIFZ":"60","WAERS":"KRW"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);

            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_045_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_045_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_DOCUMENT_FILE":[{"WSAPPLICATION":"PNG","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","BUFFER":"cwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==","DOKNR":"12-MV0089-003848-CS"}],"T_DOCUMENT":[{"DKTXT":"000403907733 제목없는이미지","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"00-MV0089-003848-CS"},{"DKTXT":"000403907733 제목없는이미지","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"01-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"02-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"03-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"06-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"04-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"05-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"08-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"07-MV0089-003848-CS"},{"DKTXT":"000403908301 test","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"09-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"10-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"11-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"12-MV0089-003848-CS"}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully Finished"}}';

            res.setBody(resBody);
            res.setStatusCode(200);

            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_CSPLUS_047_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_047_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_DOCUMENT_FILE":[{"WSAPPLICATION":"PNG","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","BUFFER":"cwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==","DOKNR":"12-MV0089-003848-CS"}],"T_DOCUMENT":[{"DKTXT":"000403907733 제목없는이미지","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"00-MV0089-003848-CS"},{"DKTXT":"000403907733 제목없는이미지","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"01-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"02-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"03-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"06-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"04-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"05-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"08-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"07-MV0089-003848-CS"},{"DKTXT":"000403908301 test","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"09-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"10-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"11-MV0089-003848-CS"},{"DKTXT":"up.txt","DOKVR":"00","DOKTL":"000","DOKAR":"CS2","OBJKY":"MV0089-003848","DOKNR":"12-MV0089-003848-CS"}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully Finished"}}';

            res.setBody(resBody);
            res.setStatusCode(200);

            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_CSPLUS_007_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-007', className);
        
        Test.startTest();
        
        IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();
        req.FR_RECV_DAT = '';
        req.TO_RECV_DAT = '';
        req.I_MAKTX = '';
        req.I_STATUS = '';
        req.I_NAME2 = '';
        req.I_TYPBZ = '';
        req.I_EQUNR = '';
        req.I_MATNR = '';
        req.I_CHK = '';
        
        req.T_I_LIST = new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST>();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST tList = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST();
        tList.SIGN = '';
        tList.OPTION = '';
        tList.LOW = '';
        tList.HIGH = '';
        req.T_I_LIST.add(tList);
        
        req.T_I_LIST2 = new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2>();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2 tList2 = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2();
        tList2.SIGN = '';
        tList2.OPTION = '';
        tList2.LOW = '';
        tList2.HIGH = '';
        req.T_I_LIST2.add(tList2);
        
        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_007(req);
        
        IF_ERP_Material_Classes.IF_CSPLUS_007_Res res = new IF_ERP_Material_Classes.IF_CSPLUS_007_Res();
        res.O_RETURN = new IF_ERP_Material_Classes.IF_CSPLUS_007_Res_O_RETURN();
        res.O_RETURN.TYPE = '';
        res.O_RETURN.CODE = '';
        res.O_RETURN.MESSAGE = '';
        
        res.T_O_LIST = new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST tOList = new IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST();
        tOList.AUFNR = '';
        tOList.QMNUM = '';
        tOList.RECV_DT = '';
        tOList.TYPBZ = '';
        tOList.SERNR = '';
        tOList.MATNR = '';
        tOList.MAKTX = '';
        tOList.KWMENG = '';
        tOList.MEINS = '';
        tOList.MATNR_TXT = '';
        tOList.TDLNR = '';
        tOList.TDLNR_NAME = '';
        tOList.EXTI1 = '';
        tOList.VBELN = '';
        tOList.POSNR = '';
        tOList.QDATU = '';
        tOList.QZEIT = '';
        tOList.RETURN_YN = '';
        tOList.RETURN_TYPE = '';
        tOList.RETURN_TEXT = '';
        tOList.SOLDTO = '';
        tOList.NAME2 = '';
        tOList.GWLDT = '';
        tOList.PRETD = '';
        tOList.PRETD2 = '';
        tOList.PRETD3 = '';
        tOList.BMENG = '';
        tOList.VSMNG = '';
        tOList.GSMNG = '';
        tOList.SDATE = '';
        tOList.VBELN_VL = '';
        tOList.POSNN_VL = '';
        tOList.SOLDTO1 = '';
        tOList.NAME3 = '';
        tOList.ZSUPPLY = '';
        tOList.QMSEQ = '';
        tOList.DEALER_CD = '';
        tOList.NAME1 = '';
        tOList.ILART = '';
        tOList.NAME4 = '';
        tOList.KUNUM = '';
        tOList.OBJNR = '';
        tOList.STATUS = '';
        tOList.POCONT_YN = '';
        tOList.INVOICE = '';
        tOList.TKNUM = '';
        tOList.VBELN_VL1 = '';
        tOList.ETD = '';
        tOList.DODAT = '';
        tOList.LIFNR = '';
        tOList.VNDNM = '';
        tOList.VSBED = '';
        tOList.REQ_DATE = '';
        res.T_O_LIST.add(tOList);
        
        Test.stopTest();
    }
    @isTest
    private static void IF_CSPLUS_017_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-017', className);
        
        IF_ERP_Material_Classes.IF_CSPLUS_017_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req();
        req.I_EQUNR = '';
        req.I_AG_PARNR = '';
        req.I_WE_PARNR = '';
        req.I_NOTE = '';
        req.I_CLASS_VALUE = '';
        req.I_DESC = '';
        req.I_STATUS_FLG = '';
        
        req.I_ADDRESS = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ADDRESS();
        req.I_ADDRESS.NAME1 = '';
        req.I_ADDRESS.NAME2 = '';
        req.I_ADDRESS.STREET = '';
        req.I_ADDRESS.POST_CODE1 = '';
        req.I_ADDRESS.CITY1 = '';
        req.I_ADDRESS.COUNTRY = '';
        req.I_ADDRESS.REGION = '';
        req.I_ADDRESS.TEL_NUMBER = '';
        
        req.I_GENERAL = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_GENERAL();
        req.I_GENERAL.OBJECTTYPE = '';
        req.I_GENERAL.START_FROM = '';
        req.I_GENERAL.ACQDATE = '';
        req.I_GENERAL.MANFACTURE = '';
        req.I_GENERAL.MANMODEL = '';
        req.I_GENERAL.MANCOUNTRY = '';
        req.I_GENERAL.CONSTYEAR = '';
        req.I_GENERAL.CONSTMONTH = '';
        req.I_GENERAL.ZZ_INST_START = '';
        req.I_GENERAL.ZZ_INST_FINISH = '';
        
        req.I_LOCATION = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_LOCATION();
        req.I_LOCATION.MAINTPLANT = '';
        req.I_LOCATION.PLSECTN = '';
        req.I_LOCATION.WERKS = '';
        req.I_LOCATION.ARBPL = '';
        
        req.I_ORG = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ORG();
        req.I_ORG.BUS_AREA = '';
        req.I_ORG.PLANPLANT = '';
        req.I_ORG.PLANGROUP = '';
        req.I_ORG.WERKS = '';
        req.I_ORG.ARBPL = '';
        req.I_ORG.CATPROFILE = '';
        
        req.I_WARRANTY = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_WARRANTY();
        req.I_WARRANTY.GWLDT = '';
        req.I_WARRANTY.GWLEN = '';
        req.I_WARRANTY.V_GWLEN = '';
        
        req.I_USERINFO = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_USERINFO();
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
        
        req.T_DOCUMENT = new List<IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT>();
        IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT doc = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT();
        doc.DOKAR = '';
        doc.DOKNR = '';
        doc.DOKTL = '';
        doc.DOKVR = '';
        req.T_DOCUMENT.add(doc);
        
        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_017(req);
    }
    @isTest
    private static void IF_CSPLUS_018_Test(){
        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', className);
        
        Test.startTest();

        IF_ERP_Material_Classes.IF_CSPLUS_018_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req();
        req.I_FROM = '';
        req.I_TO = '';

        req.T_ITEM = new List<IF_ERP_Material_Classes.IF_CSPLUS_018_Req_T_ITEM>();
        IF_ERP_Material_Classes.IF_CSPLUS_018_Req_T_ITEM item = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req_T_ITEM();
        item.EQUNR = '';
        item.EQKTX = '';
        item.TXT04 = '';
        item.ATWRT = '';
        item.INTERNAL_NOTE = '';
        item.IF_CLASS = '';
        item.EQART = '';
        item.EARTX = '';
        item.INBDT = '';
        item.ANSDT = '';
        item.HERST = '';
        item.HERLD = '';
        item.TYPBZ = '';
        item.BAUJJ = '';
        item.BAUMM = '';
        item.ZZ_INST_START = '';
        item.ZZ_INST_FINISH = '';
        item.SWERK = '';
        item.SWERK_TXT = '';
        item.BEBER = '';
        item.BEBER_TXT = '';
        item.LOC_ARBPL = '';
        item.LOC_ARBPL_TXT = '';
        item.NAME1 = '';
        item.NAME2 = '';
        item.STREET = '';
        item.POST_CODE1 = '';
        item.CITY1 = '';
        item.COUNTRY = '';
        item.REGION = '';
        item.TEL_NUMBER = '';
        item.BUKRS = '';
        item.BUTXT = '';
        item.GSBER = '';
        item.GTEXT = '';
        item.IWERK = '';
        item.IWERK_TXT = '';
        item.INGRP = '';
        item.INNAM = '';
        item.ORG_ARBPL = '';
        item.ORG_ARBPL_TXT = '';
        item.WERKS = '';
        item.RBNR = '';
        item.RBNRX = '';
        item.GWLDT = '';
        item.GWLEN = '';
        item.MGANR = '';
        item.GAKTX = '';
        item.STRATEGIC_EQUIP_FLAG = '';
        item.MATNR = '';
        item.SERNR = '';
        item.V_GWLDT = '';
        item.V_GWLEN = '';
        item.M_ATWRT = '';
        item.KDAUF = '';
        item.RES_MN_WK_CTR = '';
        item.RES_PLANT = '';
        item.PERSON_RES = '';
        item.PERSON_RES_NAME = '';
        item.DO_VBELN = '';
        item.ZI_KUNNR = '';
        item.ZI_NAME1 = '';
        item.ZI_STRAS = '';
        item.ZI_PSTLZ = '';
        item.ZI_ORT01 = '';
        req.T_ITEM.add(item);

        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_018(req);

        IF_ERP_Material_Classes.IF_CSPLUS_018_Res res = new IF_ERP_Material_Classes.IF_CSPLUS_018_Res();
        
        res.O_RETURN = new IF_ERP_Material_Classes.IF_CSPLUS_018_Res_O_RETURN();
        res.O_RETURN.TYPE = '';
        res.O_RETURN.CODE = '';
        res.O_RETURN.MESSAGE = '';

        res.T_ITEM = new List<IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM>();
        IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM itemRes = new IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM();
        itemRes.EQUNR = '';
        itemRes.EQKTX = '';
        itemRes.TXT04 = '';
        itemRes.ATWRT = '';
        itemRes.INTERNAL_NOTE = '';
        itemRes.IF_CLASS = '';
        itemRes.EQART = '';
        itemRes.EARTX = '';
        itemRes.INBDT = '';
        itemRes.ANSDT = '';
        itemRes.HERST = '';
        itemRes.HERLD = '';
        itemRes.TYPBZ = '';
        itemRes.BAUJJ = '';
        itemRes.BAUMM = '';
        itemRes.ZZ_INST_START = '';
        itemRes.ZZ_INST_FINISH = '';
        itemRes.SWERK = '';
        itemRes.SWERK_TXT = '';
        itemRes.BEBER = '';
        itemRes.BEBER_TXT = '';
        itemRes.LOC_ARBPL = '';
        itemRes.LOC_ARBPL_TXT = '';
        itemRes.NAME1 = '';
        itemRes.NAME2 = '';
        itemRes.STREET = '';
        itemRes.POST_CODE1 = '';
        itemRes.CITY1 = '';
        itemRes.COUNTRY = '';
        itemRes.REGION = '';
        itemRes.TEL_NUMBER = '';
        itemRes.BUKRS = '';
        itemRes.BUTXT = '';
        itemRes.GSBER = '';
        itemRes.GTEXT = '';
        itemRes.IWERK = '';
        itemRes.IWERK_TXT = '';
        itemRes.INGRP = '';
        itemRes.INNAM = '';
        itemRes.ORG_ARBPL = '';
        itemRes.ORG_ARBPL_TXT = '';
        itemRes.WERKS = '';
        itemRes.RBNR = '';
        itemRes.RBNRX = '';
        itemRes.GWLDT = '';
        itemRes.GWLEN = '';
        itemRes.MGANR = '';
        itemRes.GAKTX = '';
        itemRes.STRATEGIC_EQUIP_FLAG = '';
        itemRes.MATNR = '';
        itemRes.SERNR = '';
        itemRes.V_GWLDT = '';
        itemRes.V_GWLEN = '';
        itemRes.M_ATWRT = '';
        res.T_ITEM.add(itemRes);
        
        res.T_PARTNERS_INFO = new List<IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO>();
        IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO partner = new IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO();
        partner.EQUNR = '';
        partner.VTEXT = '';
        partner.PARNR = '';
        partner.NAME1 = '';
        partner.ORT01 = '';
        res.T_PARTNERS_INFO.add(partner);

        res.T_DOCUMENT = new List<IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT>();
        IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT doc = new IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT();
        doc.OBJKY = '';
        doc.DOKAR = '';
        doc.DOKNR = '';
        doc.DOKTL = '';
        doc.DOKVR = '';
        doc.DKTXT = '';
        res.T_DOCUMENT.add(doc);

        res.T_DOCUMENT_FILE = new List<IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT_FILE>();
        IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT_FILE docFile = new IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT_FILE();
        docFile.OBJKY = '';
        docFile.DOKAR = '';
        docFile.DOKNR = '';
        docFile.DOKTL = '';
        docFile.DOKVR = '';
        docFile.BUFFER = '';
        res.T_DOCUMENT_FILE.add(docFile);

        Test.stopTest();
    }
    @isTest
    private static void IF_CSPLUS_021_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-021', className);
        
        Test.startTest();
        
        IF_ERP_Material_Classes.IF_CSPLUS_021_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_021_Req();
        req.I_USERID = '';
        req.I_MATNR = '';
        
        req.I_ORG = new IF_ERP_Material_Classes.IF_CSPLUS_021_I_ORG();
        req.I_ORG.VKORG = '';
        req.I_ORG.VTWEG = '';
        req.I_ORG.SPART = '';
        req.I_ORG.WERKS = '';
        req.I_ORG.ARBPL = '';
        req.I_ORG.AMSCCTL = '';

        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_021(req);

        IF_ERP_Material_Classes.IF_CSPLUS_021_Res res = new IF_ERP_Material_Classes.IF_CSPLUS_021_Res();
        
        res.ES_RETURN = new IF_ERP_Material_Classes.IF_CSPLUS_021_ES_RETURN();
        res.ES_RETURN.TYPE = '';
        res.ES_RETURN.ID = '';
        res.ES_RETURN.IF_NUMBER = '';
        res.ES_RETURN.MESSAGE = '';
        res.ES_RETURN.LOG_NO = '';
        res.ES_RETURN.LOG_MSG_NO = '';
        res.ES_RETURN.MESSAGE_V1 = '';
        res.ES_RETURN.MESSAGE_V2 = '';
        res.ES_RETURN.MESSAGE_V3 = '';
        res.ES_RETURN.MESSAGE_V4 = '';
        res.ES_RETURN.PARAMETER = '';
        res.ES_RETURN.ROW = '';
        res.ES_RETURN.FIELD = '';
        res.ES_RETURN.IF_SYSTEM = '';

        res.ES_INFO = new IF_ERP_Material_Classes.IF_CSPLUS_021_ES_INFO();
        res.ES_INFO.MAKTX = '';
        res.ES_INFO.REPNR = '';
        res.ES_INFO.THREAD = '';
        res.ES_INFO.MEINS = '';
        res.ES_INFO.LABST = '';
        res.ES_INFO.NETPR = '';
        res.ES_INFO.WAERS = '';
        res.ES_INFO.CUQTY = '';
        res.ES_INFO.AVQTY = '';
        res.ES_INFO.SOQTY = '';
        res.ES_INFO.PRQTY = '';
        res.ES_INFO.DMTOP = '';
        res.ES_INFO.OTHOP = '';
        res.ES_INFO.LOC = '';
        res.ES_INFO.DIQTY = '';
        res.ES_INFO.STQTY = '';
        res.ES_INFO.GIQTY = '';
        res.ES_INFO.YGQTY = '';
        res.ES_INFO.LAST_EX_DT = '';
        res.ES_INFO.LAST_IM_DT = '';
        res.ES_INFO.BLQTY = '';
        res.ES_INFO.ZNOTE = '';
        res.ES_INFO.MPPS_YN = '';
        res.ES_INFO.NONMV = '';
        res.ES_INFO.AVRLT = '';
        res.ES_INFO.PLIFZ = '';
        res.ES_INFO.DISMM = '';
        res.ES_INFO.MAABC = '';
        res.ES_INFO.WAMD = '';
        res.ES_INFO.MINBE = '';
        res.ES_INFO.MABST = '';
        res.ES_INFO.BSTRF = '';
        res.ES_INFO.BSTMI = '';
        res.ES_INFO.HSCODE = '';
        res.ES_INFO.IGST = '';
        res.ES_INFO.SVRCD = '';
        res.ES_INFO.SVRCD_T = '';
        res.ES_INFO.NTGEW = '';
        res.ES_INFO.GEWEI = '';
        res.ES_INFO.HERKL = '';
        res.ES_INFO.DENET = '';
        res.ES_INFO.DASTK = '';
        res.ES_INFO.LTEXT = '';

        res.ET_AVAIL = new List<IF_ERP_Material_Classes.IF_CSPLUS_021_ET_AVAIL>();
        IF_ERP_Material_Classes.IF_CSPLUS_021_ET_AVAIL avail = new IF_ERP_Material_Classes.IF_CSPLUS_021_ET_AVAIL();
        avail.DEALER_CD = '';
        avail.NAME1 = '';
        avail.AVQTY = '';
        avail.NONMV = '';
        res.ET_AVAIL.add(avail);

        res.ET_CROSS = new List<IF_ERP_Material_Classes.IF_CSPLUS_021_ET_CROSS>();
        IF_ERP_Material_Classes.IF_CSPLUS_021_ET_CROSS cross = new IF_ERP_Material_Classes.IF_CSPLUS_021_ET_CROSS();
        cross.SEQ = '';
        cross.MATNR = '';
        cross.MAKTX = '';
        cross.ITCCD = '';
        cross.LABST = '';
        cross.NOTCD = '';
        cross.DDTEXT = '';
        cross.SVRCD = '';
        cross.MXNET = '';
        res.ET_CROSS.add(cross);

        Test.stopTest();
    }
    @isTest
    private static void IF_CSPLUS_024_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-024', className);

        Test.startTest();
        
        IF_ERP_Material_Classes.IF_CSPLUS_024_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_024_Req();
        req.I_KUNNR = '';

        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_024(req);

        IF_ERP_Material_Classes.IF_CSPLUS_024_Res res = new IF_ERP_Material_Classes.IF_CSPLUS_024_Res();
        
        res.O_RETURN = new IF_ERP_Material_Classes.IF_CSPLUS_024_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Success';

        res.T_O_LIST = new List<IF_ERP_Material_Classes.IF_CSPLUS_024_T_O_LIST>();
        
        IF_ERP_Material_Classes.IF_CSPLUS_024_T_O_LIST item = new IF_ERP_Material_Classes.IF_CSPLUS_024_T_O_LIST();
        item.EQUNR = 'EQ001';
        item.EQKTX = 'Test Equipment';
        item.TYPBZ = 'A';
        item.SERNR = 'SER001';
        item.INBDT = '20240101';
        
        item.PARNR = 'P12345';
        item.NAME1 = 'Test Name';
        item.RBNR = 'RB001';
        item.GWLDT = '20241231';
        item.OBJNR = 'OBJ001';
        
        item.WC = 'WC01';
        item.MAINWC = 'MAINWC01';
        
        res.T_O_LIST.add(item);

        Test.stopTest();
    }
    @isTest
    private static void IF_CSPLUS_031_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-031', className);

        Test.startTest();
        
        IF_ERP_Material_Classes.IF_CSPLUS_031_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_031_Req();
        req.I_VKORG = '1000';
        req.I_EQUNR = 'EQ001';
        req.I_KUNNR = 'K12345';

        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_031(req);

        IF_ERP_Material_Classes.IF_CSPLUS_031_Res res = new IF_ERP_Material_Classes.IF_CSPLUS_031_Res();

        res.O_RETURN = new IF_ERP_Material_Classes.IF_CSPLUS_031_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.ID = 'MSG001';
        res.O_RETURN.MSG_NUMBER = '100';
        res.O_RETURN.MESSAGE = 'Success';
        res.O_RETURN.LOG_NO = 'LOG123';
        res.O_RETURN.LOG_MSG_NO = '10';
        res.O_RETURN.MESSAGE_V1 = 'Info1';
        res.O_RETURN.MESSAGE_V2 = 'Info2';
        res.O_RETURN.MESSAGE_V3 = 'Info3';
        res.O_RETURN.MESSAGE_V4 = 'Info4';
        res.O_RETURN.PARAMETER = 'Parameter1';
        res.O_RETURN.ROW = '1';
        res.O_RETURN.FIELD = 'Field1';
        res.O_RETURN.MSG_SYSTEM = 'System1';

        res.T_O_LIST = new List<IF_ERP_Material_Classes.IF_CSPLUS_031_T_O_LIST>();
        IF_ERP_Material_Classes.IF_CSPLUS_031_T_O_LIST item = new IF_ERP_Material_Classes.IF_CSPLUS_031_T_O_LIST();
        item.ZTYPE = 'Z1';
        item.MATNR = 'Material001';
        item.MAKTX = 'Test Material';
        item.NETWR = '1000.00';
        item.WAERS = 'USD';
        item.MENGE = '50';
        item.MEINS = 'EA';
        item.PLIFZ = '30';

        res.T_O_LIST.add(item);

        Test.stopTest();
    }
    @isTest
    private static void IF_CSPLUS_045_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-045', className);

        Test.startTest();
        
        IF_ERP_Material_Classes.IF_CSPLUS_045_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_045_Req();
        req.I_EQUNR = 'EQ001234';

        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_045(req);

        IF_ERP_Material_Classes.IF_CSPLUS_045_Res_T_DOCUMENT doc = new IF_ERP_Material_Classes.IF_CSPLUS_045_Res_T_DOCUMENT();
        doc.OBJKY = 'OBJ001';
        doc.DOKAR = 'DRW';
        doc.DOKNR = '0001';
        doc.DOKTL = '01';
        doc.DOKVR = 'A1';
        doc.DKTXT = 'Test Document';

        IF_ERP_Material_Classes.IF_CSPLUS_045_Res_T_DOCUMENT_FILE docFile = new IF_ERP_Material_Classes.IF_CSPLUS_045_Res_T_DOCUMENT_FILE();
        docFile.OBJKY = 'OBJ001';
        docFile.DOKAR = 'DRW';
        docFile.DOKNR = '0001';
        docFile.DOKTL = '01';
        docFile.DOKVR = 'A1';
        docFile.BUFFER = 'Base64EncodedData==';
        docFile.WSAPPLICATION = 'PDF';

        IF_ERP_Material_Classes.IF_CSPLUS_045_Res_O_RETURN returnObj = new IF_ERP_Material_Classes.IF_CSPLUS_045_Res_O_RETURN();
        returnObj.TYPE = 'S';
        returnObj.CODE = '000';
        returnObj.MESSAGE = 'Success';

        IF_ERP_Material_Classes.IF_CSPLUS_045_Res res = new IF_ERP_Material_Classes.IF_CSPLUS_045_Res();
        res.T_DOCUMENT = new List<IF_ERP_Material_Classes.IF_CSPLUS_045_Res_T_DOCUMENT>{ doc };
        res.T_DOCUMENT_FILE = new List<IF_ERP_Material_Classes.IF_CSPLUS_045_Res_T_DOCUMENT_FILE>{ docFile };
        res.O_RETURN = returnObj;

        Test.stopTest();
    }
    @isTest
    private static void IF_CSPLUS_047_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-047', className);

        Test.startTest();
        
        IF_ERP_Material_Classes.IF_CSPLUS_047_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_047_Req();
        req.I_VBELN = 'EQ001234';

        IF_ERP_Material instance = new IF_ERP_Material();
        instance.IF_CSPLUS_047(req);

        IF_ERP_Material_Classes.IF_CSPLUS_047_Res_T_DOCUMENT doc = new IF_ERP_Material_Classes.IF_CSPLUS_047_Res_T_DOCUMENT();
        doc.OBJKY = 'OBJ001';
        doc.DOKAR = 'DRW';
        doc.DOKNR = '0001';
        doc.DOKTL = '01';
        doc.DOKVR = 'A1';
        doc.DKTXT = 'Test Document';

        IF_ERP_Material_Classes.IF_CSPLUS_047_Res_T_DOCUMENT_FILE docFile = new IF_ERP_Material_Classes.IF_CSPLUS_047_Res_T_DOCUMENT_FILE();
        docFile.OBJKY = 'OBJ001';
        docFile.DOKAR = 'DRW';
        docFile.DOKNR = '0001';
        docFile.DOKTL = '01';
        docFile.DOKVR = 'A1';
        docFile.BUFFER = 'Base64EncodedData==';
        docFile.WSAPPLICATION = 'PDF';

        IF_ERP_Material_Classes.IF_CSPLUS_047_Res_O_RETURN returnObj = new IF_ERP_Material_Classes.IF_CSPLUS_047_Res_O_RETURN();
        returnObj.TYPE = 'S';
        returnObj.CODE = '000';
        returnObj.MESSAGE = 'Success';

        IF_ERP_Material_Classes.IF_CSPLUS_047_Res res = new IF_ERP_Material_Classes.IF_CSPLUS_047_Res();
        res.T_DOCUMENT = new List<IF_ERP_Material_Classes.IF_CSPLUS_047_Res_T_DOCUMENT>{ doc };
        res.T_DOCUMENT_FILE = new List<IF_ERP_Material_Classes.IF_CSPLUS_047_Res_T_DOCUMENT_FILE>{ docFile };
        res.O_RETURN = returnObj;

        Test.stopTest();
    }

}