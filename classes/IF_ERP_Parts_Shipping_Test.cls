@isTest
public with sharing class IF_ERP_Parts_Shipping_Test {
    private static String className = 'IF_ERP_Parts_Shipping';

    public IF_ERP_Parts_Shipping_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_002_HttpMock implements HttpCalloutMock {
        public IF_PARTS_002_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"T_LIST":[{"INCO2":"Ex Works","INCO1":"EXW","VSBED":"10","ZTERM":"CPBC","VTWEG":"10","ROUTE_TX":"","ROUTE":"","VKORG":"1846","KUNNR":"0001244220","VSBED_TX":"Domestic Express","ZTERM_TX":"Sales:1~31, Due on 3 months\' end","SPART":"40","MANDT":"880"},{"INCO2":"Ex Works","INCO1":"EXW","VSBED":"20","ZTERM":"CPBC","VTWEG":"10","ROUTE_TX":"","ROUTE":"","VKORG":"1846","KUNNR":"0001244220","VSBED_TX":"Truck","ZTERM_TX":"Sales:1~31, Due on 3 months\' end","SPART":"40","MANDT":"880"},{"INCO2":"Ex Works","INCO1":"EXW","VSBED":"90","ZTERM":"CPBC","VTWEG":"10","ROUTE_TX":"","ROUTE":"","VKORG":"1846","KUNNR":"0001244220","VSBED_TX":"Quick Service","ZTERM_TX":"Sales:1~31, Due on 3 months\' end","SPART":"40","MANDT":"880"},{"INCO2":"Ex Works","INCO1":"EXW","VSBED":"99","ZTERM":"CPBC","VTWEG":"10","ROUTE_TX":"","ROUTE":"","VKORG":"1846","KUNNR":"0001244220","VSBED_TX":"Loco(Spot)","ZTERM_TX":"Sales:1~31, Due on 3 months\' end","SPART":"40","MANDT":"880"}],"T_VALUE_SET":[{"TEXT":"","VALUE":"99"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_014_HttpMock implements HttpCalloutMock {
        public IF_PARTS_014_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"027","MESSAGE":"Successfully finished."},"T_LIST":[{"DTABF":"2024-03-30","DATEN":"0000-00-00","ROUTE":"161200","DATBG":"0000-00-00","TDLNR":"","TKNUM":"0003524865","EXTI2":"","EXTI1":""},{"DTABF":"2024-03-30","DATEN":"0000-00-00","ROUTE":"161200","DATBG":"0000-00-00","TDLNR":"","TKNUM":"0003524878","EXTI2":"","EXTI1":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_015_HttpMock implements HttpCalloutMock {
        public IF_PARTS_015_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_COUNT":"16","O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_LIST":[{"VGBEL":"3001954636","BEZEI_T":"","TPLST":"1846","VBELN":"8006465460","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524895","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.081","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954640","BEZEI_T":"","TPLST":"1846","VBELN":"8006465522","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524895","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.081","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954642","BEZEI_T":"","TPLST":"1846","VBELN":"8006465523","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524895","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.081","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"2001403988","BEZEI_T":"","TPLST":"1846","VBELN":"8006465543","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524895","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.081","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954657","BEZEI_T":"","TPLST":"1846","VBELN":"8006465544","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524895","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.081","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954669","BEZEI_T":"","TPLST":"1846","VBELN":"8006465594","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524895","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.081","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954676","BEZEI_T":"","TPLST":"1846","VBELN":"8006465603","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524895","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.081","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001950024","BEZEI_T":"","TPLST":"1846","VBELN":"8006465438","GEWEI_MAX":"KG","ZFETA":"2024-04-02","ZFMBLNO":"","TKNUM":"0003524917","BSTNK":"1","VSART":"Y2","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"Bus","KUNNZ":"0001244220","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"명성기계","WAERK":"","BRGEW":"44.960","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001950036","BEZEI_T":"","TPLST":"1846","VBELN":"8006465439","GEWEI_MAX":"KG","ZFETA":"2024-04-02","ZFMBLNO":"","TKNUM":"0003524917","BSTNK":"1","VSART":"Y2","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"Bus","KUNNZ":"0001244220","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"명성기계","WAERK":"","BRGEW":"44.960","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001950488","BEZEI_T":"","TPLST":"1846","VBELN":"8006465440","GEWEI_MAX":"KG","ZFETA":"2024-04-02","ZFMBLNO":"","TKNUM":"0003524917","BSTNK":"1","VSART":"Y2","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"Bus","KUNNZ":"0001244220","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"명성기계","WAERK":"","BRGEW":"44.960","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001950491","BEZEI_T":"","TPLST":"1846","VBELN":"8006465441","GEWEI_MAX":"KG","ZFETA":"2024-04-02","ZFMBLNO":"","TKNUM":"0003524917","BSTNK":"1","VSART":"Y2","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"Bus","KUNNZ":"0001244220","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"명성기계","WAERK":"","BRGEW":"44.960","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001950040","BEZEI_T":"","TPLST":"1846","VBELN":"8006465551","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524969","BSTNK":"1","VSART":"Y2","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"Bus","KUNNZ":"0001244220","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"명성기계","WAERK":"","BRGEW":"0.000","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001950491","BEZEI_T":"","TPLST":"1846","VBELN":"8006465552","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524969","BSTNK":"1","VSART":"Y2","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"Bus","KUNNZ":"0001244220","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-01","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"명성기계","WAERK":"","BRGEW":"0.000","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954685","BEZEI_T":"","TPLST":"1846","VBELN":"8006465617","GEWEI_MAX":"KG","ZFETA":"2024-04-03","ZFMBLNO":"","TKNUM":"0003524988","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"2","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-02","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.000","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954804","BEZEI_T":"","TPLST":"1846","VBELN":"8006465914","GEWEI_MAX":"KG","ZFETA":"2024-04-04","ZFMBLNO":"","TKNUM":"0003525224","BSTNK":"1","VSART":"","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2024-04-02","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"0.000","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001954833","BEZEI_T":"","TPLST":"1846","VBELN":"8006465957","GEWEI_MAX":"KG","ZFETA":"2024-04-04","ZFMBLNO":"","TKNUM":"0003525251","BSTNK":"1","VSART":"","STTRG":"2","COUNT2":"2","COUNT1":"1","STTRG_T":"Check-in","BEZEI20":"명성기계/오용래/055-296-7290/경상남도 창원시 성산구 웅남로/316 1동 101호(웅남동,산업지식센터)","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"0000-00-00","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"2.284","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"}],"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_PARTS_027_HttpMock implements HttpCalloutMock {
        public IF_PARTS_027_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}],"T_DETAIL":[{"ZFOBDT":"2024-12-17","MATNR_SH":"R18182","STAWN":"","ZFCUSAMT":"0.00","ZFTOTAL":"0.00","ZFINSAMT":"0.00","ZFETCAMT_D":"0.00","BSTKD":"반품 TEST","STTRG_T":"","ZFSTRAMT":"0.00","TKNUM":"0003525428","KVGR5":"40","NETPR":"2132.00","ZFMBLNO":"","NETPR2":"0.00","INTCA3":"KR","KWMENG":"0","WAERK":"KRW","BRGEW_T":"0.000","MEINS":"EA","NTGEW_T":"0.000","NTGEW":"0.000","NETWR2":"0.00","PO_ITM_NO":"","STTRG":"5","GEWEI":"","KWERT":"0.00","POSNR_DO":"000000","MAKTX":"CENTER,LIVE","LFIMG":"1.000","ZFDOCAMT":"0.00","VSBED":"99","ZFHBLNO":"","ZFTRSAMT":"0.00","EXIDV":"00000000001006898010","VBELN_DO":"","ZFCIVNO":"","ZFDONO":"","ZFETCAMT":"0.00","HERKL":"KR","COUNT2":"0","VBELN2":"3001955162","COUNT1":"0","ZFETCAMT_S":"0.00","MATNR_SO":"R18182","BRGEW":"0.000","ZFCIVDT":"0000-00-00","STABF":"","NETWR":"2132.00"}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_PARTS_002_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-002', className);
        
        Test.startTest();
        
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Req req = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Req();
        req.I_VKORG = '';
        req.I_VTWEG = '';
        req.I_SPART = '';
        req.I_KUNNR = '';
        req.I_VSBED = '';
        req.I_ROUTE = '';
        req.I_ZTERM = '';
        req.I_LANG = 'KO';
        
        IF_ERP_Parts_Shipping instance = new IF_ERP_Parts_Shipping();
        instance.IF_PARTS_002(req);
        
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res res = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res();
        res.O_RETURN = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_O_RETURN();
        res.O_RETURN.TYPE = '';
        res.O_RETURN.CODE = '';
        res.O_RETURN.MESSAGE = '';
        
        res.T_LIST = new List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_LIST>();
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_LIST tList = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_LIST();
        tList.VKORG = '';
        tList.VTWEG = '';
        tList.SPART = '';
        tList.KUNNR = '';
        tList.VSBED = '';
        tList.ROUTE = '';
        tList.ZTERM = '';
        tList.INCO1 = '';
        tList.INCO2 = '';
        tList.VSBED_TX = '';
        tList.ROUTE_TX = '';
        tList.ZTERM_TX = '';
        res.T_LIST.add(tList);
        
        res.T_VALUE_SET = new List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_VALUE_SET>();
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_VALUE_SET tValueSet = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_VALUE_SET();
        tValueSet.VALUE = '';
        tValueSet.TEXT = '';
        res.T_VALUE_SET.add(tValueSet);
        
        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_014_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-014', className);
        
        Test.startTest();
        
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Req req = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Req();
        
        // I_INPUT 객체 초기화 및 필드 값 설정
        req.I_INPUT = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Req_I_INPUT();
        req.I_INPUT.TKNUM = '123456789';
        req.I_INPUT.TDLNR = 'TDL001';
        req.I_INPUT.EXTI1 = 'EXT001';
        req.I_INPUT.EXTI2 = 'EXT002';
        req.I_INPUT.ROUTE = 'ROUTE001';
        req.I_INPUT.DTABF = '20250210';
        req.I_INPUT.DATBG = '20250211';
        req.I_INPUT.DATEN = '20250212';

        IF_ERP_Parts_Shipping instance = new IF_ERP_Parts_Shipping();
        instance.IF_PARTS_014(req);

        // 응답 객체 생성
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res res = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res();
        res.O_RETURN = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Success';

        // T_LIST 리스트 초기화 및 데이터 추가
        res.T_LIST = new List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res_T_LIST>();
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res_T_LIST item = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res_T_LIST();
        item.TKNUM = '123456789';
        item.TDLNR = 'TDL001';
        item.EXTI1 = 'EXT001';
        item.EXTI2 = 'EXT002';
        item.ROUTE = 'ROUTE001';
        item.DTABF = '20250210';
        item.DATBG = '20250211';
        item.DATEN = '20250212';

        res.T_LIST.add(item);
        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_015_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-015', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req req = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req();

        // 요청 데이터 설정
        req.I_FDATE = '20250101';
        req.I_TDATE = '20250201';
        req.I_TKNUM = '123456789';
        req.I_VBELN = 'VBELN12345';
        req.I_MATNR = 'MATNR001';
        req.I_BSTNK = 'BSTNK123';
        req.I_STTRG = 'STTRG001';
        req.I_LANGU = 'EN';
        req.I_GUBUN = 'GUBUN001';

        // 사용자 정보 설정
        req.I_USERINFO = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req_I_USERINFO();
        req.I_USERINFO.BNAME = 'JohnDoe';
        req.I_USERINFO.RNAME = 'John Doe';
        req.I_USERINFO.HIER = 'Manager';
        req.I_USERINFO.KUNNR = 'KUNNR001';
        req.I_USERINFO.LIFNR = 'LIFNR001';
        req.I_USERINFO.VKORG = '1000';
        req.I_USERINFO.VTWEG = '10';
        req.I_USERINFO.SPART = '01';
        req.I_USERINFO.WERKS = 'WERK001';
        req.I_USERINFO.ARBPL = 'ARBPL001';
        req.I_USERINFO.PARNR = 'PARNR001';
        req.I_USERINFO.ENAME = 'John Doe';
        req.I_USERINFO.KUNN2 = 'KUNN2001';
        req.I_USERINFO.LAND1 = 'US';
        req.I_USERINFO.LGORT = 'LGORT001';
        req.I_USERINFO.DF_CHK = 'X';
        req.I_USERINFO.CO_CHK = 'X';

        IF_ERP_Parts_Shipping instance = new IF_ERP_Parts_Shipping();
        instance.IF_PARTS_015(req);

        // 응답 객체 생성
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res res = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res();
        res.O_MESG = 'Success';
        res.O_COUNT = '5';

        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Successful';
        res.O_RETURN.LOG_NO = 'LOG12345';
        res.O_RETURN.LOG_MSG_NO = 'MSG001';
        res.O_RETURN.MESSAGE_V1 = 'Info1';
        res.O_RETURN.MESSAGE_V2 = 'Info2';
        res.O_RETURN.MESSAGE_V3 = 'Info3';
        res.O_RETURN.MESSAGE_V4 = 'Info4';

        // 판매 지역 리스트 초기화 및 데이터 추가
        res.T_SALES_AREA = new List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_SALES_AREA>();
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_SALES_AREA salesArea = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_SALES_AREA();
        salesArea.VKORG = '1000';
        salesArea.VTWEG = '10';
        salesArea.SPART = '01';
        res.T_SALES_AREA.add(salesArea);

        // 리스트 초기화 및 데이터 추가
        res.T_LIST = new List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_LIST>();
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_LIST item = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_LIST();
        item.TKNUM = '123456789';
        item.COUNT1 = '5';
        item.COUNT2 = '10';
        item.NETWR = '500.00';
        item.WAERK = 'USD';
        item.BRGEW = '100.00';
        item.GEWEI_MAX = 'KG';
        item.BEZEI20 = 'Item Desc';
        item.KUNNZ = 'KUNNZ001';
        item.NAME1 = 'Company A';
        item.VSART = 'Type A';
        item.BEZEI = 'Description';
        item.VSBED = 'Standard';
        item.VTEXT = 'Text';
        item.TDLNR = 'TDL001';
        item.NAME2 = 'Warehouse A';
        item.STTRG = 'Status1';
        item.STTRG_T = 'Status Text';
        item.ZFCIVNO = 'ZFCIV001';
        item.ZFMBLNO = 'ZFMBL001';
        item.ZFOBDT = '20250101';
        item.ZFETA = '20250105';
        item.DATEN = '20250110';
        item.VBELN = 'VBELN001';
        item.VGBEL = 'VGBEL001';
        item.BSTNK = 'BSTNK001';
        item.TPLST = 'TPLST001';
        item.BEZEI_T = 'Transport Desc';
        item.EXTI1 = 'EXTI001';
        item.KDINVOICE = 'INV001';

        res.T_LIST.add(item);

        Test.stopTest();
    }
    @isTest
    private static void IF_PARTS_027_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-027', className);

        Test.startTest();

        // 요청 객체 생성
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Req req = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Req();

        // 요청 데이터 설정
        req.I_VKORG = '1000';
        req.I_VTWEG = '10';
        req.I_SPART = '01';
        req.I_KUNNR = 'KUNNR001';
        req.I_TKNUM = '123456789';
        req.I_EXIDV = 'EXIDV001';
        req.I_VBELN = 'VBELN001';
        req.I_MATNR = 'MATNR001';
        req.I_BSTNK = 'BSTNK001';
        req.I_STTRG = 'STTRG001';
        req.I_FDATE = '20250101';
        req.I_TDATE = '20250201';
        req.I_LANGU = 'EN';
        req.I_DELVE = 'Y';
        req.I_FGDAT = '20250105';
        req.I_TGDAT = '20250205';

        IF_ERP_Parts_Shipping instance = new IF_ERP_Parts_Shipping();
        instance.IF_PARTS_027(req);

        // 응답 객체 생성
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res res = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res();
        res.O_MESG = 'Success';
        res.O_COUNT = '5';

        // O_RETURN 객체 초기화 및 값 설정
        res.O_RETURN = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_O_RETURN();
        res.O_RETURN.TYPE = 'S';
        res.O_RETURN.CODE = '200';
        res.O_RETURN.MESSAGE = 'Request Successful';
        res.O_RETURN.LOG_NO = 'LOG12345';
        res.O_RETURN.LOG_MSG_NO = 'MSG001';
        res.O_RETURN.MESSAGE_V1 = 'Info1';
        res.O_RETURN.MESSAGE_V2 = 'Info2';
        res.O_RETURN.MESSAGE_V3 = 'Info3';
        res.O_RETURN.MESSAGE_V4 = 'Info4';

        // 판매 지역 리스트 초기화 및 데이터 추가
        res.T_SALES_AREA = new List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_SALES_AREA>();
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_SALES_AREA salesArea = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_SALES_AREA();
        salesArea.VKORG = '1000';
        salesArea.VTWEG = '10';
        salesArea.SPART = '01';
        res.T_SALES_AREA.add(salesArea);

        // 상세 리스트 초기화 및 데이터 추가
        res.T_DETAIL = new List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_DETAIL>();
        IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_DETAIL detail = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_DETAIL();
        detail.TKNUM = '123456789';
        detail.EXIDV = 'EXIDV001';
        detail.MATNR_SO = 'MATNR_SO001';
        detail.MATNR_SH = 'MATNR_SH001';
        detail.MAKTX = 'Item Desc';
        detail.LFIMG = '10';
        detail.MEINS = 'EA';
        detail.NETPR = '100.00';
        detail.NETWR = '1000.00';
        detail.WAERK = 'USD';
        detail.HERKL = 'DE';
        detail.INTCA3 = 'INTC001';
        detail.BSTKD = 'BSTKD001';
        detail.STTRG = 'STTRG001';
        detail.STTRG_T = 'Status Text';
        detail.ZFOBDT = '20250101';
        detail.ZFDONO = 'DO123';
        detail.VBELN2 = 'VBELN002';
        detail.KVGR5 = 'Group5';
        detail.ZFCIVNO = 'CIV001';
        detail.ZFMBLNO = 'MBL001';
        detail.COUNT1 = '5';
        detail.COUNT2 = '10';
        detail.ZFHBLNO = 'HBL001';
        detail.ZFCIVDT = '20250102';
        detail.STABF = 'ABF001';
        detail.VSBED = 'Standard';
        detail.KWERT = '500.00';
        detail.NTGEW = '20.00';
        detail.BRGEW = '25.00';
        detail.GEWEI = 'KG';
        detail.NTGEW_T = 'Net Weight';
        detail.BRGEW_T = 'Gross Weight';
        detail.NETPR2 = '110.00';
        detail.NETWR2 = '1100.00';
        detail.ZFTRSAMT = '200.00';
        detail.ZFINSAMT = '300.00';
        detail.ZFETCAMT = '400.00';
        detail.ZFTOTAL = '500.00';
        detail.ZFSTRAMT = '600.00';
        detail.ZFCUSAMT = '700.00';
        detail.ZFDOCAMT = '800.00';
        detail.ZFETCAMT_S = '900.00';
        detail.ZFETCAMT_D = '1000.00';
        detail.STAWN = 'STAWN001';
        detail.VBELN_DO = 'DO123';
        detail.POSNR_DO = 'POS001';
        detail.PO_ITM_NO = 'POITEM001';
        detail.KWMENG = '50';

        res.T_DETAIL.add(detail);

        Test.stopTest();
    }
    
}