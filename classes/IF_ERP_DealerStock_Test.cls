@isTest
public with sharing class IF_ERP_DealerStock_Test {
    private static String className = 'IF_ERP_DealerStock';

/** Mock Classes
    */
    public with sharing class IF_DEALERSTOCK_001_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"조회 완료","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"ET_HIST":[{"MMSTA":"","MABST":"1","DMD09":"0","MAABC":"I","VERPR":"0","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"CARTRIDGE ASSY;SPINDLE","MATNR":"101507-00469H","MINBE":"1","DMD18":"0","LSTNR":"101507-00469H","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240220","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"1","DMD09":"0","MAABC":"H","VERPR":"439400","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,DUCT;STEEL APRON","MATNR":"110505-00072","MINBE":"1","DMD18":"0","LSTNR":"110505-00072","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"1","CHGDT":"20240219","FRQ18":"1","DMD10":"0","SVRCD":"S","FRQ12":"1","MEINS":"EA"},{"MMSTA":"N1","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"167600","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"GEAR,SPUR","MATNR":"130424-00319","MINBE":"0","DMD18":"0","LSTNR":"130424-00319","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240103","FRQ18":"0","DMD10":"0","SVRCD":"N","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"5452600","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"BALL SCREW;SMX3100L A-AXIS(R/S)","MATNR":"130510-01215A","MINBE":"0","DMD18":"0","LSTNR":"130510-01215A","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240322","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"N","VERPR":"0","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"HOUSING,BEARING;FRONT","MATNR":"140203-00901","MINBE":"0","DMD18":"0","LSTNR":"140203-00901","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240129","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"2432000","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"HOUSING,BEARING;FRONT","MATNR":"140203-00901-E","MINBE":"0","DMD18":"0","LSTNR":"140203-00901-E","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240129","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"40800","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"SWITCH,PRESSURE","MATNR":"301413-00493","MINBE":"0","DMD18":"0","LSTNR":"301413-00493","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240306","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"0","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"CABLE ASSY,CONTROL;TURRET PULSE CODER","MATNR":"310209-10597B","MINBE":"0","DMD18":"0","LSTNR":"310209-10597B","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240320","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"AY"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"84500","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"RADIATOR","MATNR":"400821-00355C-06","MINBE":"0","DMD18":"0","LSTNR":"400821-00355C-06","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240124","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"696100","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"GEAR,MOTOR","MATNR":"900115-00088C-P1","MINBE":"0","DMD18":"0","LSTNR":"900115-00088C-P1","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240322","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"SET"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"351500","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,TELESCOPIC;X-AXIS","MATNR":"L55611011E","MINBE":"0","DMD18":"0","LSTNR":"L55611011E","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240326","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"374400","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,SIDE;LEFT","MATNR":"L55621281G","MINBE":"0","DMD18":"0","LSTNR":"L55621281G","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240111","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"},{"MMSTA":"","MABST":"0","DMD09":"0","MAABC":"Z","VERPR":"516100","DMD08":"0","DMD07":"0","DMD06":"0","DMD05":"0","DMD04":"0","DMD03":"0","DMD02":"0","DMD01":"0","FRQ06":"0","MAKTX":"COVER,TELESCOPIC","MATNR":"L55651011E","MINBE":"0","DMD18":"0","LSTNR":"L55651011E","DMD17":"0","DMD16":"0","DMD15":"0","DMD14":"0","DMD13":"0","DMD12":"0","WAERS":"KRW","DMD11":"0","CHGDT":"20240117","FRQ18":"0","DMD10":"0","SVRCD":"S","FRQ12":"0","MEINS":"EA"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_002_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"MPPS 품번 확장완료","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""}}';
            
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_003_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"O_RETURN":{"TYPE":"","CODE":"","MESSAGE":""},"T_O_RESB":[{"VORNR":"0010","BDMNG":"1.000","RSART":"","CHK":"","RSNUM":"0173227197","MEINS":"EA","RSPOS":"0005","WERKS":"1846","MAKTX":"VALVE,SOLENOID","AUFNR":"000403908573","POSTP":"N","POSNR":"0030","LGORT":"","MATNR":"R41706"}],"T_O_ZCRMS0093":[{"APPRO_ID":"","KUNNR":"0001308913","RSNUM":"0000000000","POWERTRAIN":"","CARRIER":"","RETURN_YN":"N","CARRIER_T":"","DELIV":"","STATUS":"APPROVAL","EQUNR":"MH0014-000385","COUNTRY":"","REQ_USER":"","CLAIM_NO":"","MENGE":"1.000","ARBPL":"","NAME1":"영진기계","QMSEQ":"0030","MEINS":"EA","VSTEL":"","ORDER_TYPE":"","SPIND":"","MANDT":"880","MATNR":"R41706","APPRO_ST":"","MAKTX":"VALVE,SOLENOID","ACCT_NO":"","EBELN":"","ZRMA":"","ZSUPPLY":"02","ERROR":"","REQ_DATE":"0000-00-00","TNAME":"","VSBED":"4","WERKS":"","AUFNR":"","CAUSE":"","LIFNR":"0001057455","KUNUM":"","CNF_DATE":"0000-00-00","AUTLF":"","QMNUM":"000302382568","HOLD":"","AUART":"","VBELN":"","CHK":"","ONE_TIME_CHK":""}],"T_O_ZCST0040":[]}';
            
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_004_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully processed."},"T_DOMESTIC":[{"PRT_DATE":"0000-00-00","RETURN_YN":"Y","PGMNG":"3.000","BELNR":"","BELNR_IV":"","SO_CHK":"","WAERS":"KRW","MENGE":"3.000","NAME1":"","RETURN_TYPE":"1","CHANGE_DT":"0000-00-00","ZSVP":"","RETURN_QTY":"0","MAT_WARR_YN":"","MEINS":"AY","AENAM":"","MANDT":"880","CNF_QTY":"0","ITEM_NUMBER":"0010","AEDAT":"0000-00-00","MATNR":"101507-00070G-RM","EBELP":"00000","RETURN_END_YN":"N","ITEM_CAT":"N","MAKTX":"CARTRIDGE ASSY;REPLACEMENT","EBELN":"","POSNR":"000000","BRTWR":"0.00","GI_MBLNR":"","AUFNR":"000403908476","SUPPLY_TYPE":"대리점","AEZET":"00:00:00","ERNAM":"CS_DMTDO","CLOSE_DT":"0000-00-00","LIFNR":"","POSNR_VF":"000000","ERDAT":"2025-02-28","CAUSE_PRT":"","RETURN_DT":"0000-00-00","MBLNR":"","BNFPO":"00000","BANFN":"","VBELN_VF":"","RETURN_TEXT":"","VBELN":"","RETURN_WAY":"","SEQNO":"0001","ERZET":"10:05:57","REASON2":"B04","LPRICE":"0.00","REASON1":"B","PRT_TIME":"00:00:00","WORKNO":"0000","FREIGHT":"0.00","NRTN_TEXT":"","NETWR":"0.00"},{"PRT_DATE":"0000-00-00","RETURN_YN":"Y","PGMNG":"2.000","BELNR":"","BELNR_IV":"","SO_CHK":"","WAERS":"KRW","MENGE":"2.000","NAME1":"","RETURN_TYPE":"1","CHANGE_DT":"0000-00-00","ZSVP":"","RETURN_QTY":"0","MAT_WARR_YN":"","MEINS":"AY","AENAM":"","MANDT":"880","CNF_QTY":"0","ITEM_NUMBER":"9010","AEDAT":"0000-00-00","MATNR":"101507-00070G-RM","EBELP":"00000","RETURN_END_YN":"N","ITEM_CAT":"N","MAKTX":"CARTRIDGE ASSY;REPLACEMENT","EBELN":"","POSNR":"000000","BRTWR":"0.00","GI_MBLNR":"","AUFNR":"000403908476","SUPPLY_TYPE":"대리점","AEZET":"00:00:00","ERNAM":"CS_DMTDO","CLOSE_DT":"0000-00-00","LIFNR":"","POSNR_VF":"000000","ERDAT":"2025-02-28","CAUSE_PRT":"","RETURN_DT":"0000-00-00","MBLNR":"","BNFPO":"00000","BANFN":"","VBELN_VF":"","RETURN_TEXT":"","VBELN":"","RETURN_WAY":"","SEQNO":"9001","ERZET":"10:05:57","REASON2":"B04","LPRICE":"0.00","REASON1":"B","PRT_TIME":"00:00:00","WORKNO":"0000","FREIGHT":"0.00","NRTN_TEXT":"","NETWR":"0.00"}],"T_MAIN":[{"AENAM":"","DEZIT":"00:00:00","STAT":"1","DEDAT":"0000-00-00","INVOICE":"","ERZET":"08:58:13","WRAMT":"0.00","AUFNR":"000403908476","AEDAT":"0000-00-00","DEALER_NM":"","MAKTX":"CARTRIDGE ASSY;REPLACEMENT","BMENG":"0.000","QMDAT":"2025-02-28","ERNAM":"EAICOM","MATNR":"101507-00070G-RM","ERSDA":"0000-00-00","STATT":"","VSARTT":"","BDMNG":"3.000","VSART":"2","RCOL":"","PDATE":"0000-00-00","WAERS":"","ERDAT":"2025-02-28","POSNR":"0010","DEALER_CD":"0001057644","DENAM":"","AEZET":"00:00:00","MEINS":"AY","CHK":"","PTIME":"00:00:00"},{"AENAM":"","DEZIT":"00:00:00","STAT":"1","DEDAT":"0000-00-00","INVOICE":"","ERZET":"08:58:13","WRAMT":"0.00","AUFNR":"000403908476","AEDAT":"0000-00-00","DEALER_NM":"","MAKTX":"CARTRIDGE ASSY;REPLACEMENT","BMENG":"0.000","QMDAT":"2025-02-28","ERNAM":"EAICOM","MATNR":"101507-00070G-RM","ERSDA":"0000-00-00","STATT":"","VSARTT":"","BDMNG":"2.000","VSART":"2","RCOL":"","PDATE":"0000-00-00","WAERS":"","ERDAT":"2025-02-28","POSNR":"9010","DEALER_CD":"0001057644","DENAM":"","AEZET":"00:00:00","MEINS":"AY","CHK":"","PTIME":"00:00:00"}],"T_NOTI":[{"APPRO_ID":"","KUNNR":"0001057644","RSNUM":"0000000000","POWERTRAIN":"","CARRIER":"","RETURN_YN":"Y","CARRIER_T":"","DELIV":"","STATUS":"APPROVAL","EQUNR":"MH0014-000385","COUNTRY":"","REQ_USER":"","CLAIM_NO":"","MENGE":"3.000","ARBPL":"","QMSEQ":"0010","MEINS":"AY","VSTEL":"","ORDER_TYPE":"","SPIND":"","MANDT":"880","MATNR":"101507-00070G-RM","APPRO_ST":"","ACCT_NO":"","EBELN":"","ZRMA":"","ZSUPPLY":"02","ERROR":"","REQ_DATE":"0000-00-00","TNAME":"","VSBED":"2","WERKS":"","AUFNR":"","CAUSE":"","LIFNR":"0001057644","KUNUM":"","CNF_DATE":"0000-00-00","AUTLF":"","QMNUM":"000302382438","HOLD":"","AUART":"","VBELN":"","ONE_TIME_CHK":""},{"APPRO_ID":"","KUNNR":"0001057644","RSNUM":"0000000000","POWERTRAIN":"","CARRIER":"","RETURN_YN":"Y","CARRIER_T":"","DELIV":"","STATUS":"APPROVAL","EQUNR":"MH0014-000385","COUNTRY":"","REQ_USER":"","CLAIM_NO":"","MENGE":"2.000","ARBPL":"","QMSEQ":"9010","MEINS":"AY","VSTEL":"","ORDER_TYPE":"","SPIND":"","MANDT":"880","MATNR":"101507-00070G-RM","APPRO_ST":"","ACCT_NO":"","EBELN":"","ZRMA":"","ZSUPPLY":"02","ERROR":"","REQ_DATE":"0000-00-00","TNAME":"","VSBED":"2","WERKS":"","AUFNR":"","CAUSE":"","LIFNR":"0001057644","KUNUM":"","CNF_DATE":"0000-00-00","AUTLF":"","QMNUM":"000302382438","HOLD":"","AUART":"","VBELN":"","ONE_TIME_CHK":""}],"T_RESB":[{"VORNR":"0010","BDMNG":"3.000","RSART":"","CHK":"","RSNUM":"0173222648","MEINS":"AY","RSPOS":"0001","WERKS":"1846","MAKTX":"","AUFNR":"000403908476","POSTP":"N","POSNR":"0010","LGORT":"","MATNR":"101507-00070G-RM"},{"VORNR":"0010","BDMNG":"2.000","RSART":"","CHK":"","RSNUM":"0173222648","MEINS":"AY","RSPOS":"0002","WERKS":"1846","MAKTX":"","AUFNR":"000403908476","POSTP":"N","POSNR":"9010","LGORT":"","MATNR":"101507-00070G-RM"}],"T_RETURN":[]}';
            
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_005_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"E_DATUM":"2025-03-11","E_USER":"EAICOM","E_UZEIT":"14:05:30","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"successfully deleted."},"T_RETURN":[]}';
            
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_006_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"조회 완료"},"ET_LIST":[{"DISPR":"3180","TEXT1":"","NETPR":"4100","KWMENG":"10","MAKTX":"BEARING,BALL;THRUST","MATNR":"S6080040","TYPE":"1","CUQTY":"14","LOC":"B-57-02","GRQTY":"8","RMQTY":"2","RTQTY":"0","BSTKD":"20241206","GIDAT":"2024-12-09","DOCNO":"3001955097","CUST_NO":"","WAERS":"KRW","AUDAT":"2024-12-06","DMBTR":"31800","DOCIT":"10","NAME1":"DN Solutions","MEINS":"EA"}]}';
            
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_007_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"조회완료"},"ET_SFT":[{"TSL":"50.00","SFT":"0.00"},{"TSL":"51.00","SFT":"0.03"},{"TSL":"52.00","SFT":"0.05"},{"TSL":"53.00","SFT":"0.08"},{"TSL":"54.00","SFT":"0.10"},{"TSL":"55.00","SFT":"0.13"},{"TSL":"56.00","SFT":"0.15"},{"TSL":"57.00","SFT":"0.18"},{"TSL":"58.00","SFT":"0.20"},{"TSL":"59.00","SFT":"0.23"},{"TSL":"60.00","SFT":"0.25"},{"TSL":"61.00","SFT":"0.28"},{"TSL":"62.00","SFT":"0.31"},{"TSL":"63.00","SFT":"0.33"},{"TSL":"64.00","SFT":"0.36"},{"TSL":"65.00","SFT":"0.39"},{"TSL":"66.00","SFT":"0.41"},{"TSL":"67.00","SFT":"0.44"},{"TSL":"68.00","SFT":"0.47"},{"TSL":"69.00","SFT":"0.50"},{"TSL":"70.00","SFT":"0.52"},{"TSL":"71.00","SFT":"0.55"},{"TSL":"72.00","SFT":"0.58"},{"TSL":"73.00","SFT":"0.61"},{"TSL":"74.00","SFT":"0.64"},{"TSL":"75.00","SFT":"0.67"},{"TSL":"76.00","SFT":"0.71"},{"TSL":"77.00","SFT":"0.74"},{"TSL":"78.00","SFT":"0.77"},{"TSL":"79.00","SFT":"0.81"},{"TSL":"80.00","SFT":"0.84"},{"TSL":"81.00","SFT":"0.88"},{"TSL":"82.00","SFT":"0.92"},{"TSL":"83.00","SFT":"0.95"},{"TSL":"84.00","SFT":"0.99"},{"TSL":"85.00","SFT":"1.04"},{"TSL":"86.00","SFT":"1.08"},{"TSL":"87.00","SFT":"1.13"},{"TSL":"88.00","SFT":"1.17"},{"TSL":"89.00","SFT":"1.23"},{"TSL":"90.00","SFT":"1.28"},{"TSL":"91.00","SFT":"1.34"},{"TSL":"92.00","SFT":"1.41"},{"TSL":"93.00","SFT":"1.48"},{"TSL":"94.00","SFT":"1.55"},{"TSL":"95.00","SFT":"1.64"},{"TSL":"96.00","SFT":"1.75"},{"TSL":"97.00","SFT":"1.88"},{"TSL":"98.00","SFT":"2.05"},{"TSL":"99.00","SFT":"2.33"},{"TSL":"99.99","SFT":"3.72"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_009_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"T_RETURN":[{"ZZKVGR4":"A","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-22.50","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"B","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-15.00","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"C","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-12.00","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2022-07-06","KZBZG":""},{"ZZKVGR4":"D","DATBI":"9999-12-31","ZTERM":"","KZNEP":"","KBETR":"-13.35","KFRST":"","KRECH":"A","KBSTAT":"","KONWA":"%","VALTG":"00","VALDT":"0000-00-00","DATAB":"2016-05-02","KZBZG":""}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Success"}}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_010_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"ET_MAT":[{"KMEIN":"","SGST":"","KBETR":"0.00","RATE":"","NETPR":"","MAKTX":"DOOR;MAG.(80T)","KONWA":"","AVQTY":"0.000","NONMV":"","MATNR":"220205-01090","CUQTY":"0.000","KPEIN":"             0","IGST":"","NOTCD":"","CGST":"","HSCODE":"","OTHER":"","KUNNR":"1244220","REPNR":"220205-01090"},{"KMEIN":"","SGST":"","KBETR":"0.00","RATE":"","NETPR":"","MAKTX":"STDY REST,SAMCHULLY;HYD - TL SERIES","KONWA":"","AVQTY":"8.000","NONMV":"","MATNR":"STA-2LT-DNS","CUQTY":"9.000","KPEIN":"             0","IGST":"","NOTCD":"","CGST":"","HSCODE":"","OTHER":"","KUNNR":"1057455","REPNR":"STA-2LT-DNS"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_011_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ET_LIST":[{"NETPR":"3407800","LOC":"","WAERS":"KRW","REQTY":"0","STQTY":"0","MEINS":"SET","CUQTY":"0","THREAD":"90BNR10HTYNDBBCA25P4U214","MAKTX":"BEARING,BALL;ANGULAR CONTACT","DISPR":"3407800","MATNR":"R10905"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_012_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ET_LIST":[{"NETPR":"3407800","LOC":"","WAERS":"KRW","REQTY":"0","STQTY":"0","MEINS":"SET","CUQTY":"0","THREAD":"90BNR10HTYNDBBCA25P4U214","MAKTX":"BEARING,BALL;ANGULAR CONTACT","DISPR":"","MATNR":"R10905"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }
    public with sharing class IF_DEALERSTOCK_014_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"조회 완료"},"ET_LIST":[{"NETPR":"284300","ERDAT":"20240311","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115370","CUQTY":"1","RETNO":"7100252410","DMBTR":"440660","MENGE":"2","THREAD":"DNU-80-500-PPV-A","MAKTX":"CYLINDER,AIR","DISPR":"220330","CAQTY":"1","MATNR":"R42220","DOCIT":"10"},{"NETPR":"20500","ERDAT":"20240314","LOC":"B-09-04","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115377","CUQTY":"3","RETNO":"7100252630","DMBTR":"15890","MENGE":"1","THREAD":"SKY-32","MAKTX":"PACKING;SKY","DISPR":"15890","CAQTY":"0","MATNR":"R56162","DOCIT":"10"},{"NETPR":"1234600","ERDAT":"20240314","LOC":"A-83-01","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115379","CUQTY":"4","RETNO":"7100252629","DMBTR":"805400","MENGE":"1","THREAD":"DVSD-TTS-14C_14AMPERE_17B","MAKTX":"DRIVE,SERVO;TURRET_ATC FOR AS","DISPR":"805400","CAQTY":"0","MATNR":"300419-00031","DOCIT":"10"},{"NETPR":"235300","ERDAT":"20240315","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115380","CUQTY":"1","RETNO":"7100252674","DMBTR":"182360","MENGE":"1","THREAD":"PCB BOARD(STD)","MAKTX":"PCB ASSY;OP","DISPR":"182360","CAQTY":"0","MATNR":"EITOP057AS","DOCIT":"10"},{"NETPR":"1195600","ERDAT":"20240321","LOC":"A-82-01","RMQTY":"2","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115398","CUQTY":"0","RETNO":"7100252823","DMBTR":"1446820","MENGE":"2","THREAD":"DVSC-TM-14E-01","MAKTX":"DRIVE,SERVO;TURRET_ATC","DISPR":"723410","CAQTY":"0","MATNR":"300419-00035B","DOCIT":"10"},{"NETPR":"422800","ERDAT":"20240402","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115442","CUQTY":"0","RETNO":"7100253121","DMBTR":"327670","MENGE":"1","THREAD":"","MAKTX":"COVER,SLIDE;(XR)","DISPR":"327670","CAQTY":"0","MATNR":"AS-133","DOCIT":"10"},{"NETPR":"284300","ERDAT":"20240807","LOC":"","RMQTY":"1","WAERS":"KRW","MEINS":"EA","DOCNO":"5000115444","CUQTY":"1","RETNO":"7100253175","DMBTR":"220330","MENGE":"1","THREAD":"DNU-80-500-PPV-A","MAKTX":"CYLINDER,AIR","DISPR":"220330","CAQTY":"0","MATNR":"R42220","DOCIT":"11"}]}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }

    public with sharing class IF_DEALERSTOCK_015_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = ' {"ES_RETURN":{"TYPE":"E","ROW":"0","PARAMETER":"","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"","MESSAGE":"정산대상 상태만 정산완료로 변경할 수 있습니다.","LOG_NO":"","LOG_MSG_NO":"000000","IF_SYSTEM":"","IF_NUMBER":"000","ID":"","FIELD":""}}';

            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }        
    }

/** TEST CODE
    */
    @IsTest
    static void IF_DEALERSTOCK_001_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-001', className);
        Test.startTest();

        // 요청(Request) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req();
        request.I_DATE_FROM = '20240101';
        request.I_DATE_TO = '20240215';

        // I_USERINFO 객체 생성 및 데이터 설정
        request.I_USERINFO = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TestUser';
        request.I_USERINFO.RNAME = 'TestRole';
        request.I_USERINFO.HIER = 'Level1';
        request.I_USERINFO.KUNNR = 'C12345';
        request.I_USERINFO.LIFNR = 'L98765';
        request.I_USERINFO.VKORG = 'V001';
        request.I_USERINFO.VTWEG = 'T001';
        request.I_USERINFO.SPART = 'S001';
        request.I_USERINFO.WERKS = 'W001';
        request.I_USERINFO.ARBPL = 'A001';
        request.I_USERINFO.PARNR = 'P001';
        request.I_USERINFO.ENAME = 'Test Employee';
        request.I_USERINFO.KUNN2 = 'K002';
        request.I_USERINFO.LAND1 = 'KR';
        request.I_USERINFO.LGORT = 'L001';
        request.I_USERINFO.DF_CHK = 'X';
        request.I_USERINFO.CO_CHK = 'X';

        // IT_MATNR 리스트에 데이터 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_IT_MATNR matnrItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_IT_MATNR();
        matnrItem.MATNR = 'M001';
        request.IT_MATNR.add(matnrItem);

        // 응답(Response) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res();

        // ES_RETURN 객체 생성 및 데이터 설정
        response.ES_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res_ES_RETURN();
        response.ES_RETURN.TYPE = 'S';
        response.ES_RETURN.ID = 'MSG001';
        response.ES_RETURN.IF_NUMBER = '1001';
        response.ES_RETURN.MESSAGE = 'Success';
        response.ES_RETURN.LOG_NO = 'LOG001';
        response.ES_RETURN.LOG_MSG_NO = 'LOGMSG01';
        response.ES_RETURN.MESSAGE_V1 = 'Message 1';
        response.ES_RETURN.MESSAGE_V2 = 'Message 2';
        response.ES_RETURN.MESSAGE_V3 = 'Message 3';
        response.ES_RETURN.MESSAGE_V4 = 'Message 4';
        response.ES_RETURN.PARAMETER = 'Parameter1';
        response.ES_RETURN.ROW = 'Row1';
        response.ES_RETURN.FIELD = 'Field1';
        response.ES_RETURN.IF_SYSTEM = 'System1';

        // ET_HIST 리스트에 데이터 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res_ET_HIST histItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res_ET_HIST();
        histItem.MATNR = 'M001';
        histItem.MAKTX = 'Material Description';
        histItem.LSTNR = 'LST001';
        histItem.DMD18 = '10';
        histItem.DMD17 = '15';
        histItem.DMD16 = '20';
        histItem.DMD15 = '25';
        histItem.DMD14 = '30';
        histItem.DMD13 = '35';
        histItem.DMD12 = '40';
        histItem.DMD11 = '45';
        histItem.DMD10 = '50';
        histItem.DMD09 = '55';
        histItem.DMD08 = '60';
        histItem.DMD07 = '65';
        histItem.DMD06 = '70';
        histItem.DMD05 = '75';
        histItem.DMD04 = '80';
        histItem.DMD03 = '85';
        histItem.DMD02 = '90';
        histItem.DMD01 = '95';
        histItem.MEINS = 'EA';
        histItem.FRQ06 = '6';
        histItem.FRQ12 = '12';
        histItem.FRQ18 = '18';
        histItem.VERPR = '100.00';
        histItem.WAERS = 'USD';
        histItem.MAABC = 'A';
        histItem.MINBE = '5';
        histItem.MABST = '10';
        histItem.CHGDT = '20240201';
        histItem.SVRCD = '001';
        histItem.MMSTA = 'Active';

        response.ET_HIST.add(histItem);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_001(request);

        Test.stopTest();
    }   
    @IsTest
    static void IF_DEALERSTOCK_002_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-002', className);
        Test.startTest();

        // 요청(Request) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Req();
        request.I_MATNR = 'MAT001';

        // I_USERINFO 객체 생성 및 데이터 설정
        request.I_USERINFO = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Req_I_USERINFO();
        request.I_USERINFO.BNAME = 'TestUser';
        request.I_USERINFO.VKORG = 'V001';
        request.I_USERINFO.VTWEG = 'T001';
        request.I_USERINFO.SPART = 'S001';
        request.I_USERINFO.WERKS = 'W001';

        // 응답(Response) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Res();

        // ES_RETURN 객체 생성 및 데이터 설정
        response.ES_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Res_ES_RETURN();
        response.ES_RETURN.TYPE = 'S';
        response.ES_RETURN.ID = 'MSG002';
        response.ES_RETURN.IF_NUMBER = '2001';
        response.ES_RETURN.MESSAGE = 'Success';
        response.ES_RETURN.LOG_NO = 'LOG002';
        response.ES_RETURN.LOG_MSG_NO = 'LOGMSG02';
        response.ES_RETURN.MESSAGE_V1 = 'Message V1';
        response.ES_RETURN.MESSAGE_V2 = 'Message V2';
        response.ES_RETURN.MESSAGE_V3 = 'Message V3';
        response.ES_RETURN.MESSAGE_V4 = 'Message V4';
        response.ES_RETURN.PARAMETER = 'Parameter2';
        response.ES_RETURN.ROW = 'Row2';
        response.ES_RETURN.FIELD = 'Field2';
        response.ES_RETURN.IF_SYSTEM = 'System2';

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_002(request);

        Test.stopTest();
    }   
    @IsTest
    static void IF_DEALERSTOCK_003_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-003', className);
        Test.startTest();

        // 요청(Request) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req();
        request.I_HISTORY = 'Y';

        // I_DETAIL_INFO 객체 생성 및 데이터 설정
        request.I_DETAIL_INFO = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req_I_DETAIL_INFO();
        request.I_DETAIL_INFO.AUFNR = '123456';
        request.I_DETAIL_INFO.MATNR = 'MAT001';
        request.I_DETAIL_INFO.BDMNG = '100';
        request.I_DETAIL_INFO.POSNR = '10';
        request.I_DETAIL_INFO.MEINS = 'PCS';
        request.I_DETAIL_INFO.DEALER_CD = 'D001';
        request.I_DETAIL_INFO.DEDAT = '20240216';
        request.I_DETAIL_INFO.DEZIT = '1200';
        request.I_DETAIL_INFO.DENAM = 'Test Dealer';

        // 응답(Response) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res();

        // O_RETURN 객체 생성 및 데이터 설정
        response.O_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '0000';
        response.O_RETURN.MESSAGE = 'Success';

        // T_O_RESB 리스트 생성 및 데이터 설정
        response.T_O_RESB = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_RESB>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_RESB resbRecord = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_RESB();
        resbRecord.AUFNR = '123456';
        resbRecord.POSNR = '10';
        resbRecord.RSNUM = 'RES001';
        resbRecord.RSPOS = '1';
        resbRecord.MATNR = 'MAT001';
        resbRecord.MAKTX = 'Test Material';
        resbRecord.WERKS = 'Plant01';
        resbRecord.LGORT = 'Storage01';
        resbRecord.POSTP = 'Post001';
        resbRecord.BDMNG = '100';
        resbRecord.MEINS = 'PCS';
        resbRecord.VORNR = 'V001';
        resbRecord.RSART = 'A';
        resbRecord.CHK = 'X';

        response.T_O_RESB.add(resbRecord);

        // 응답(Response) 객체 생성
        response.T_O_ZCRMS0093 = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093 zcrmsRecord = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093();
        zcrmsRecord.MANDT = '100';
        zcrmsRecord.QMNUM = 'QM123456';
        zcrmsRecord.QMSEQ = '001';
        zcrmsRecord.EQUNR = 'EQ98765';
        zcrmsRecord.MATNR = 'MAT001';
        zcrmsRecord.CAUSE = 'Defective Part';
        zcrmsRecord.LIFNR = 'LIF001';
        zcrmsRecord.ZSUPPLY = 'SupplierABC';
        zcrmsRecord.MENGE = '50';
        zcrmsRecord.MEINS = 'PCS';
        zcrmsRecord.VBELN = 'VB12345';
        zcrmsRecord.VSBED = 'Standard';
        zcrmsRecord.KUNNR = 'KUN456';
        zcrmsRecord.ERROR = 'None';
        zcrmsRecord.EBELN = 'EB98765';
        zcrmsRecord.DELIV = 'DEL123';
        zcrmsRecord.CLAIM_NO = 'CLM789';
        zcrmsRecord.POWERTRAIN = 'Hybrid';
        zcrmsRecord.STATUS = 'Approved';
        zcrmsRecord.RETURN_YN = 'Y';
        zcrmsRecord.ARBPL = 'PlantA';
        zcrmsRecord.AUFNR = 'ORD001';
        zcrmsRecord.AUART = 'TypeA';
        zcrmsRecord.KUNUM = 'KNUM123';
        zcrmsRecord.TNAME = 'TechName';
        zcrmsRecord.WERKS = 'WERK001';
        zcrmsRecord.APPRO_ID = 'APPROVAL001';
        zcrmsRecord.APPRO_ST = 'Approved';
        zcrmsRecord.REQ_USER = 'UserABC';
        zcrmsRecord.REQ_DATE = '20240217';
        zcrmsRecord.CNF_DATE = '20240218';
        zcrmsRecord.AUTLF = 'Y';
        zcrmsRecord.COUNTRY = 'USA';
        zcrmsRecord.CARRIER = 'DHL';
        zcrmsRecord.CARRIER_T = 'Express';
        zcrmsRecord.ACCT_NO = 'ACC789';
        zcrmsRecord.ONE_TIME_CHK = 'N';
        zcrmsRecord.ORDER_TYPE = 'Urgent';
        zcrmsRecord.RSNUM = 'RS456';
        zcrmsRecord.HOLD = 'N';
        zcrmsRecord.VSTEL = 'VS001';
        zcrmsRecord.ZRMA = 'ZRMA456';
        zcrmsRecord.SPIND = 'SP123';
        zcrmsRecord.MAKTX = 'Material Description';
        zcrmsRecord.NAME1 = 'Customer Name';
        zcrmsRecord.CHK = 'CheckOK';
        response.T_O_ZCRMS0093.add(zcrmsRecord);

        response.T_O_ZCST0040 = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCST0040>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCST0040 zcstRecord = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCST0040();
        zcstRecord.MANDT = '100';
        zcstRecord.AUFNR = 'ORD12345';
        zcstRecord.WORKNO = 'WORK789';
        zcstRecord.SEQNO = '001';
        zcstRecord.MATNR = 'MAT001';
        zcstRecord.ITEM_NUMBER = 'ITEM123';
        zcstRecord.MAKTX = 'Material Desc';
        zcstRecord.MEINS = 'PCS';
        zcstRecord.PGMNG = '50';
        zcstRecord.MENGE = '100';
        zcstRecord.SUPPLY_TYPE = 'Standard';
        zcstRecord.ITEM_CAT = 'CategoryA';
        zcstRecord.CHANGE_DT = '20240217';
        zcstRecord.EBELN = 'EB12345';
        zcstRecord.EBELP = '10';
        zcstRecord.MBLNR = 'MBL123';
        zcstRecord.GI_MBLNR = 'GI456';
        zcstRecord.LIFNR = 'LIF789';
        zcstRecord.NAME1 = 'Supplier Name';
        zcstRecord.LPRICE = '500';
        zcstRecord.NETWR = '1000';
        zcstRecord.BRTWR = '1200';
        zcstRecord.FREIGHT = '50';
        zcstRecord.WAERS = 'USD';
        zcstRecord.BELNR = 'BLN456';
        zcstRecord.CAUSE_PRT = 'Defect';
        zcstRecord.RETURN_YN = 'Y';
        zcstRecord.RETURN_TYPE = 'Full';
        zcstRecord.RETURN_TEXT = 'Return Approved';
        zcstRecord.RETURN_WAY = 'Courier';
        zcstRecord.RETURN_END_YN = 'Y';
        zcstRecord.RETURN_QTY = '10';
        zcstRecord.RETURN_DT = '20240220';
        zcstRecord.BANFN = 'BAN001';
        zcstRecord.BNFPO = 'BNF123';
        zcstRecord.BELNR_IV = 'BEL987';
        zcstRecord.VBELN = 'VB123';
        zcstRecord.POSNR = '0010';
        zcstRecord.SO_CHK = 'Checked';
        zcstRecord.CNF_QTY = '90';
        zcstRecord.CLOSE_DT = '20240301';
        zcstRecord.PRT_DATE = '20240218';
        zcstRecord.PRT_TIME = '1200';
        zcstRecord.REASON1 = 'Damaged Item';
        zcstRecord.REASON2 = 'Supplier Fault';
        zcstRecord.MAT_WARR_YN = 'N';
        zcstRecord.ZSVP = 'SVP001';
        zcstRecord.VBELN_VF = 'VF001';
        zcstRecord.POSNR_VF = 'VF002';
        zcstRecord.NRTN_TEXT = 'No Return Required';
        zcstRecord.INCLUDE = 'Yes';
        zcstRecord.ERDAT = '20240217';
        zcstRecord.ERNAM = 'SystemUser';
        zcstRecord.ERZET = '1330';
        zcstRecord.AEDAT = '20240218';
        zcstRecord.AENAM = 'AdminUser';
        zcstRecord.AEZET = '1400';
        response.T_O_ZCST0040.add(zcstRecord);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_003(request);

        Test.stopTest();
    }   
    @IsTest
    static void IF_DEALERSTOCK_004_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-004', className);
        Test.startTest();

        // 요청(Request) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Req();

        // 필드 값 설정
        request.I_AUFNR = 'ORD12345';
        request.I_POSNR = '0010';
        request.I_QTY1 = '50';
        request.I_QTY2 = '100';

        // 응답(Response) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res();
        
        // O_RETURN 객체 생성 및 값 설정
        response.O_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Success';

        // T_RETURN 리스트 생성 및 값 설정
        response.T_RETURN = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_RETURN>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_RETURN returnData = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_RETURN();
        returnData.TYPE = 'S';
        returnData.CODE = '100';
        returnData.MESSAGE = 'Processed Successfully';
        response.T_RETURN.add(returnData);

        // T_MAIN 리스트 생성 및 값 설정
        response.T_MAIN = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_MAIN>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_MAIN mainData = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_MAIN();
        mainData.AUFNR = 'ORD12345';
        mainData.POSNR = '0010';
        mainData.QMDAT = '20240216';
        mainData.MATNR = 'MAT56789';
        mainData.BDMNG = '50';
        mainData.BMENG = '45';
        mainData.MEINS = 'EA';
        mainData.WRAMT = '500.00';
        mainData.WAERS = 'USD';
        mainData.VSART = 'Standard';
        mainData.PDATE = '20240216';
        mainData.PTIME = '120000';
        mainData.ERSDA = '20240215';
        mainData.DEALER_CD = 'D001';
        mainData.STAT = 'Active';
        mainData.INVOICE = 'INV12345';
        mainData.ERDAT = '20240216';
        mainData.ERZET = '130000';
        mainData.ERNAM = 'User01';
        mainData.AEDAT = '20240217';
        mainData.AEZET = '140000';
        mainData.AENAM = 'User02';
        mainData.MAKTX = 'Product Description';
        mainData.VSARTT = 'Type A';
        mainData.STATT = 'Completed';
        mainData.DEALER_NM = 'Dealer Name';
        mainData.DEDAT = '20240217';
        mainData.DEZIT = '150000';
        mainData.DENAM = 'Manager01';
        mainData.RCOL = 'Collection Info';
        mainData.CHK = 'Y';
        response.T_MAIN.add(mainData);

        // T_RESB 리스트 생성 및 값 설정
        response.T_RESB = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_RESB>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_RESB resbData = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_RESB();
        resbData.AUFNR = 'ORD12345';
        resbData.POSNR = '0010';
        resbData.RSNUM = 'RS001';
        resbData.RSPOS = '01';
        resbData.MATNR = 'MAT56789';
        resbData.MAKTX = 'Product A';
        resbData.WERKS = 'Plant1';
        resbData.LGORT = 'Storage1';
        resbData.POSTP = 'P';
        resbData.BDMNG = '50';
        resbData.MEINS = 'EA';
        resbData.VORNR = 'V001';
        resbData.RSART = '01';
        resbData.CHK = 'Y';
        response.T_RESB.add(resbData);

        // T_NOTI 리스트 생성 및 값 설정
        response.T_NOTI = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_NOTI>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_NOTI notiData = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_NOTI();
        notiData.MANDT = '100';
        notiData.QMNUM = 'QM001';
        notiData.QMSEQ = '1';
        notiData.EQUNR = 'EQ001';
        notiData.MATNR = 'MAT12345';
        notiData.CAUSE = 'Defective Part';
        notiData.LIFNR = 'LIF001';
        notiData.ZSUPPLY = 'Supplier A';
        notiData.MENGE = '10';
        notiData.MEINS = 'EA';
        notiData.VBELN = 'VB12345';
        notiData.VSBED = 'Express';
        notiData.KUNNR = 'Customer1';
        notiData.ERROR = 'None';
        notiData.EBELN = 'PO12345';
        notiData.DELIV = '20240218';
        notiData.CLAIM_NO = 'CLM001';
        notiData.POWERTRAIN = 'PT100';
        notiData.STATUS = 'Open';
        notiData.RETURN_YN = 'N';
        notiData.ARBPL = 'Work Center A';
        notiData.AUFNR = 'ORD001';
        notiData.AUART = 'Repair';
        notiData.KUNUM = 'KUN001';
        notiData.TNAME = 'Tech Name';
        notiData.WERKS = 'Plant A';
        notiData.APPRO_ID = 'APP001';
        notiData.APPRO_ST = 'Approved';
        notiData.REQ_USER = 'User001';
        notiData.REQ_DATE = '20240217';
        notiData.CNF_DATE = '20240218';
        notiData.AUTLF = 'Auto';
        notiData.COUNTRY = 'USA';
        notiData.CARRIER = 'FedEx';
        notiData.CARRIER_T = 'Standard';
        notiData.ACCT_NO = 'ACC12345';
        notiData.ONE_TIME_CHK = 'N';
        notiData.ORDER_TYPE = 'Special';
        notiData.RSNUM = 'RS002';
        notiData.HOLD = 'N';
        notiData.VSTEL = 'VS001';
        notiData.ZRMA = 'ZR001';
        notiData.SPIND = 'SP001';
        response.T_NOTI.add(notiData);

        // T_DOMESTIC 리스트 생성 및 값 설정
        response.T_DOMESTIC = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_DOMESTIC>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_DOMESTIC domesticData = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_DOMESTIC();
        domesticData.MANDT = '100';
        domesticData.AUFNR = 'ORD12345';
        domesticData.WORKNO = 'W001';
        domesticData.SEQNO = 'S001';
        domesticData.MATNR = 'MAT56789';
        domesticData.ITEM_NUMBER = 'Item001';
        domesticData.MAKTX = 'Product A';
        domesticData.MEINS = 'EA';
        domesticData.PGMNG = '100';
        domesticData.MENGE = '50';
        domesticData.SUPPLY_TYPE = 'Normal';
        domesticData.ITEM_CAT = 'Category A';
        domesticData.CHANGE_DT = '20240218';
        domesticData.EBELN = 'PO12345';
        domesticData.EBELP = '10';
        domesticData.MBLNR = 'MB001';
        domesticData.GI_MBLNR = 'GM001';
        domesticData.LIFNR = 'LIF001';
        domesticData.NAME1 = 'Supplier A';
        domesticData.LPRICE = '200.00';
        domesticData.NETWR = '5000.00';
        domesticData.BRTWR = '5500.00';
        domesticData.FREIGHT = '50.00';
        domesticData.WAERS = 'USD';
        domesticData.BELNR = 'BL12345';
        domesticData.CAUSE_PRT = 'Damage';
        domesticData.RETURN_YN = 'Y';
        domesticData.RETURN_TYPE = 'Full';
        domesticData.RETURN_TEXT = 'Defective';
        domesticData.RETURN_WAY = 'Standard';
        domesticData.RETURN_END_YN = 'Y';
        domesticData.RETURN_QTY = '10';
        domesticData.RETURN_DT = '20240219';
        domesticData.BANFN = 'BN001';
        domesticData.BNFPO = 'BP001';
        domesticData.BELNR_IV = 'IV12345';
        domesticData.VBELN = 'VB12345';
        domesticData.POSNR = '0010';
        domesticData.SO_CHK = 'N';
        domesticData.CNF_QTY = '90';
        domesticData.CLOSE_DT = '20240220';
        domesticData.PRT_DATE = '20240217';
        domesticData.PRT_TIME = '12:00:00';
        domesticData.REASON1 = 'Damaged during transit';
        domesticData.REASON2 = 'Supplier Issue';
        domesticData.MAT_WARR_YN = 'Y';
        domesticData.ZSVP = 'Z100';
        domesticData.VBELN_VF = 'VF12345';
        domesticData.POSNR_VF = '0020';
        domesticData.NRTN_TEXT = 'Replacement Needed';
        domesticData.ERDAT = '20240216';
        domesticData.ERNAM = 'Admin';
        domesticData.ERZET = '11:30:00';
        domesticData.AEDAT = '20240217';
        domesticData.AENAM = 'AdminUpdated';
        domesticData.AEZET = '14:00:00';
        response.T_DOMESTIC.add(domesticData);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_004(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_005_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-005', className);
        Test.startTest();

        // 요청(Request) 객체 생성 및 값 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Req();
        request.I_AUFNR = 'ORD56789';
        request.I_POSNR = 'POS12345';
        request.I_DOMESTIC = 'Y';

        // 응답(Response) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res();

        // 응답의 일반 필드 설정
        response.E_USER = 'TestUser';
        response.E_DATUM = '20240220';
        response.E_UZEIT = '14:30:00';

        // O_RETURN 객체 생성 및 값 설정
        response.O_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Success';

        // T_RETURN 리스트 생성 및 값 설정
        response.T_RETURN = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res_T_RETURN>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res_T_RETURN returnData = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res_T_RETURN();
        returnData.TYPE = 'S';
        returnData.CODE = '100';
        returnData.MESSAGE = 'Processed Successfully';
        response.T_RETURN.add(returnData);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_005(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_006_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-006', className);
        Test.startTest();

        // 요청(Request) 객체 생성 및 값 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req();
        
        // IS_USERINFO 객체 생성 및 값 설정
        request.IS_USERINFO = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IS_USERINFO();
        request.IS_USERINFO.BNAME = 'TestUser';
        request.IS_USERINFO.RNAME = 'Test Role';
        request.IS_USERINFO.HIER = 'Hierarchy1';
        request.IS_USERINFO.KUNNR = '1234567890';
        request.IS_USERINFO.LIFNR = 'LIF12345';
        request.IS_USERINFO.VKORG = '1000';
        request.IS_USERINFO.VTWEG = '10';
        request.IS_USERINFO.SPART = '00';
        request.IS_USERINFO.WERKS = 'Plant1';
        request.IS_USERINFO.ARBPL = 'WorkCenter1';
        request.IS_USERINFO.PARNR = 'PARNR123';
        request.IS_USERINFO.ENAME = 'Employee1';
        request.IS_USERINFO.KUNN2 = '9876543210';
        request.IS_USERINFO.LAND1 = 'US';
        request.IS_USERINFO.LGORT = 'Storage1';
        request.IS_USERINFO.DF_CHK = 'X';
        request.IS_USERINFO.CO_CHK = 'Y';

        // IS_INPUT 객체 생성 및 값 설정
        request.IS_INPUT = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IS_INPUT();
        request.IS_INPUT.DOCNO = 'DOC001';
        request.IS_INPUT.MATNR = 'MAT12345';
        request.IS_INPUT.ERDAT_F = '20240101';
        request.IS_INPUT.ERDAT_T = '20240201';
        request.IS_INPUT.TYPE = 'TypeA';

        // IT_MATNR 리스트 생성 및 값 설정
        request.IT_MATNR = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_MATNR>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_MATNR matnrItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_MATNR();
        matnrItem.MATNR = 'MAT001';
        request.IT_MATNR.add(matnrItem);

        // IT_IVNO 리스트 생성 및 값 설정
        request.IT_IVNO = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_IVNO>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_IVNO ivnoItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_IVNO();
        ivnoItem.TEXT1 = 'Invoice001';
        request.IT_IVNO.add(ivnoItem);

        // 응답(Response) 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res();

        // O_RETURN 객체 생성 및 값 설정
        response.O_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Success';

        // ET_LIST 리스트 생성 및 값 설정
        response.ET_LIST = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res_ET_LIST>();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res_ET_LIST listItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res_ET_LIST();
        listItem.DOCNO = 'DOC001';
        listItem.DOCIT = 'IT001';
        listItem.CUST_NO = 'CUST123';
        listItem.NAME1 = 'Customer1';
        listItem.MATNR = 'MAT001';
        listItem.MAKTX = 'Material Name 1';
        listItem.CUQTY = '10';
        listItem.KWMENG = '20';
        listItem.RMQTY = '5';
        listItem.GRQTY = '15';
        listItem.RTQTY = '5';
        listItem.MEINS = 'EA';
        listItem.LOC = 'Loc1';
        listItem.NETPR = '100.00';
        listItem.DISPR = '5.00';
        listItem.DMBTR = '950.00';
        listItem.WAERS = 'USD';
        listItem.AUDAT = '20240215';
        listItem.GIDAT = '20240220';
        listItem.TYPE = 'Standard';
        listItem.BSTKD = 'Order123';
        listItem.TEXT1 = 'Order processed';
        response.ET_LIST.add(listItem);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_006(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_007_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-007', className);
        Test.startTest();

        // 응답 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res();

        // O_RETURN 객체 생성 및 값 설정
        response.O_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Success';

        // ET_SFT 리스트 생성 및 값 설정
        response.ET_SFT = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT>();
        
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT sftItem1 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT();
        sftItem1.TSL = 'TSL001';
        sftItem1.SFT = 'Shift A';
        response.ET_SFT.add(sftItem1);

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT sftItem2 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT();
        sftItem2.TSL = 'TSL002';
        sftItem2.SFT = 'Shift B';
        response.ET_SFT.add(sftItem2);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_007();

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_009_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-009', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Req();

        // 필드 값 설정
        request.I_CON_TYPE = '01';
        request.I_VKORG = '1000';
        request.I_PLTYP = 'A1';
        request.I_GRADE = 'Premium';
        request.I_DATE = '2024-02-17';

        // 응답 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res();

        // O_RETURN 객체 생성 및 값 설정
        response.O_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res_O_RETURN();
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Success';

        // T_RETURN 리스트 생성 및 값 설정
        response.T_RETURN = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res_T_RETURN>();

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res_T_RETURN returnItem1 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res_T_RETURN();
        returnItem1.ZZKVGR4 = 'Group1';
        returnItem1.KFRST = 'Active';
        returnItem1.KBSTAT = 'Valid';
        returnItem1.KBETR = '100.50';
        returnItem1.KONWA = 'USD';
        returnItem1.KRECH = 'Rebate';
        returnItem1.KZBZG = 'ZB01';
        returnItem1.DATAB = '2024-01-01';
        returnItem1.DATBI = '2024-12-31';
        returnItem1.KZNEP = 'N';
        returnItem1.ZTERM = 'Net30';
        returnItem1.VALDT = '2024-01-01';
        returnItem1.VALTG = '365';

        response.T_RETURN.add(returnItem1);

        // 두 번째 항목 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res_T_RETURN returnItem2 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res_T_RETURN();
        returnItem2.ZZKVGR4 = 'Group2';
        returnItem2.KFRST = 'Inactive';
        returnItem2.KBSTAT = 'Expired';
        returnItem2.KBETR = '200.75';
        returnItem2.KONWA = 'EUR';
        returnItem2.KRECH = 'Discount';
        returnItem2.KZBZG = 'ZB02';
        returnItem2.DATAB = '2023-01-01';
        returnItem2.DATBI = '2023-12-31';
        returnItem2.KZNEP = 'Y';
        returnItem2.ZTERM = 'Net60';
        returnItem2.VALDT = '2023-01-01';
        returnItem2.VALTG = '730';

        response.T_RETURN.add(returnItem2);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_009(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_010_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-010', className);
        Test.startTest();

        // 요청 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req();

        // 사용자 정보 설정
        request.I_USERINFO.BNAME = 'testUser';
        request.I_USERINFO.RNAME = 'Test Role';
        request.I_USERINFO.HIER = 'Admin';
        request.I_USERINFO.KUNNR = '100000';
        request.I_USERINFO.LIFNR = '200000';
        request.I_USERINFO.VKORG = '3000';
        request.I_USERINFO.VTWEG = '10';
        request.I_USERINFO.SPART = '01';
        request.I_USERINFO.WERKS = 'W001';
        request.I_USERINFO.ARBPL = 'Plant1';
        request.I_USERINFO.PARNR = '5000';
        request.I_USERINFO.ENAME = 'John Doe';
        request.I_USERINFO.KUNN2 = '600000';
        request.I_USERINFO.LAND1 = 'US';
        request.I_USERINFO.LGORT = 'L001';
        request.I_USERINFO.DF_CHK = 'X';
        request.I_USERINFO.CO_CHK = 'Y';

        // 기타 필드 설정
        request.I_CUST_NO = 'CUST12345';
        request.I_OTHERS = 'Additional Data';

        // IT_ITEM 리스트 생성 및 추가
        request.IT_ITEM.add(new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req_IT_ITEM());
        request.IT_ITEM[0].MATNR = 'MATERIAL123';
        request.IT_ITEM[0].KUNNR = '100000';

        // 응답 객체 생성
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res();

        // ES_RETURN 객체 초기화 및 필드 설정
        response.ES_RETURN.TYPE = 'S';
        response.ES_RETURN.ID = 'MSG001';
        response.ES_RETURN.IF_NUMBER = '123456789';
        response.ES_RETURN.MESSAGE = 'Success';
        response.ES_RETURN.LOG_NO = 'LOG001';
        response.ES_RETURN.LOG_MSG_NO = 'LOGMSG001';
        response.ES_RETURN.MESSAGE_V1 = 'Value1';
        response.ES_RETURN.MESSAGE_V2 = 'Value2';
        response.ES_RETURN.MESSAGE_V3 = 'Value3';
        response.ES_RETURN.MESSAGE_V4 = 'Value4';
        response.ES_RETURN.PARAMETER = 'Parameter1';
        response.ES_RETURN.ROW = '10';
        response.ES_RETURN.FIELD = 'Field1';
        response.ES_RETURN.IF_SYSTEM = 'SAP';

        // ET_MAT 리스트 생성 및 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res_ET_MAT matData = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res_ET_MAT();
        matData.MATNR = 'MAT12345';
        matData.REPNR = 'REP6789';
        matData.MAKTX = 'Material Description';
        matData.KPEIN = '100';
        matData.KMEIN = 'KG';
        matData.KBETR = '5000';
        matData.KONWA = 'USD';
        matData.CUQTY = '10';
        matData.AVQTY = '20';
        matData.NOTCD = 'N123';
        matData.NONMV = '500';
        matData.KUNNR = 'KUN98765';
        matData.RATE = '10%';
        matData.HSCODE = 'HS1234';
        matData.IGST = '5%';
        matData.CGST = '2.5%';
        matData.SGST = '2.5%';
        matData.OTHER = 'Additional Info';
        matData.NETPR = '4500';

        response.ET_MAT.add(matData);

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_010(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_011_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-011', className);
        Test.startTest();

        // 요청 객체 생성 및 필드 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req();
        
        // I_USERINFO 객체 초기화 및 필드 설정
        request.I_USERINFO.BNAME = 'testuser';
        request.I_USERINFO.RNAME = 'Test Role';
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

        // IT_MAT 리스트 생성 및 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req_IT_MAT matItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req_IT_MAT();
        matItem.MATNR = 'MAT001';
        matItem.STQTY = '50';
        request.IT_MAT.add(matItem);

        // 응답 객체 생성 및 필드 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res();

        // ET_LIST 리스트 생성 및 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST resItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST();
        resItem.MATNR = 'MAT001';
        resItem.MAKTX = 'Material Name';
        resItem.STQTY = '50';
        resItem.CUQTY = '10';
        resItem.REQTY = '5';
        resItem.MEINS = 'EA';
        resItem.THREAD = 'Thread Type';
        resItem.NETPR = '1000';
        resItem.DISPR = '900';
        resItem.WAERS = 'USD';
        resItem.LOC = 'Location1';

        response.ET_LIST = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST>{resItem};

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_011(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_012_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-012', className);
        Test.startTest();

        // 요청 객체 생성 및 필드 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req();
        
        // I_USERINFO 객체 초기화 및 필드 설정
        request.I_USERINFO.BNAME = 'testuser';
        request.I_USERINFO.RNAME = 'Test Role';
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

        // IT_MAT 리스트 생성 및 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req_IT_MAT matItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req_IT_MAT();
        matItem.MATNR = 'MAT001';
        matItem.STQTY = '50';
        request.IT_MAT.add(matItem);

        // 응답 객체 생성 및 필드 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res();

        // ET_LIST 리스트 생성 및 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res_ET_LIST resItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res_ET_LIST();
        resItem.MATNR = 'MAT001';
        resItem.MAKTX = 'Material Name';
        resItem.STQTY = '50';
        resItem.CUQTY = '10';
        resItem.REQTY = '5';
        resItem.MEINS = 'EA';
        resItem.THREAD = 'Thread Type';
        resItem.NETPR = '1000';
        resItem.DISPR = '900';
        resItem.WAERS = 'USD';
        resItem.LOC = 'Location1';

        response.ET_LIST = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res_ET_LIST>{resItem};

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_012(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_014_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-014', className);
        Test.startTest();

        // 요청 객체 생성 및 필드 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req();
        
        // IS_INPUT 객체 초기화 및 필드 설정
        request.IS_INPUT.TYPE = 'TestType';
        request.IS_INPUT.DOCNO = 'DOC12345';
        request.IS_INPUT.MATNR = 'MAT001';
        request.IS_INPUT.DATE_F = '2024-01-01';
        request.IS_INPUT.DATE_T = '2024-12-31';

        // I_USERINFO 객체 초기화 및 필드 설정
        request.I_USERINFO.BNAME = 'testuser';
        request.I_USERINFO.RNAME = 'Test Role';
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

        // 응답 객체 생성 및 필드 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res();
        
        // ES_RETURN 객체 초기화 및 필드 설정
        response.ES_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ES_RETURN();
        response.ES_RETURN.TYPE = 'Success';
        response.ES_RETURN.CODE = '200';
        response.ES_RETURN.MESSAGE = 'Request processed successfully';

        // ET_LIST 리스트 생성 및 추가
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ET_LIST resItem = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ET_LIST();
        resItem.DOCNO = 'DOC12345';
        resItem.DOCIT = '001';
        resItem.MATNR = 'MAT001';
        resItem.MAKTX = 'Material Description';
        resItem.THREAD = 'Thread Type';
        resItem.LOC = 'Location1';
        resItem.CUQTY = '100';
        resItem.MENGE = '200';
        resItem.CAQTY = '50';
        resItem.RMQTY = '10';
        resItem.MEINS = 'EA';
        resItem.ERDAT = '2024-02-01';
        resItem.NETPR = '1000';
        resItem.DISPR = '900';
        resItem.DMBTR = '850';
        resItem.WAERS = 'USD';
        resItem.RETNO = 'RET001';

        response.ET_LIST = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ET_LIST>{resItem};

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_014(request);

        Test.stopTest();
    }
    @IsTest
    static void IF_DEALERSTOCK_015_Test() {
        InterfaceCommonUtil.setInterface('IF-DealerStock-015', className);
        Test.startTest();

        // 요청 객체 생성 및 필드 설정
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req();

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_I_ORG I_ORG   = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_I_ORG(); 
        I_ORG.VKORG = '1846';
        I_ORG.VTWEG = '10';
        I_ORG.SPART = '40';

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST IT_LIST = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST();
        IT_LIST.AUFNR = '403908107';
        IT_LIST.POSNR = '0020';
        IT_LIST.BMENG = '1';
        IT_LIST.PDATE = '2025-02-06';
        IT_LIST.PTIME = '10:00:00';
        IT_LIST.WRAMT = '205530';
        IT_LIST.WAERS = 'KRW';
        IT_LIST.ERSDA = '2025-02-06';

        request.I_ORG = I_ORG;
        request.I_STAT = '5';
        request.IT_LIST = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST>{IT_LIST};

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res response = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res();

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res_ES_RETURN ES_RETURN = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res_ES_RETURN();
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
        response.ES_RETURN = ES_RETURN;

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        instance.IF_DEALERSTOCK_015(request);

        Test.stopTest();
    }
}