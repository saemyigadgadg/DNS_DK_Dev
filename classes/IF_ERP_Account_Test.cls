/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-13-2025   Hanyeong Choi   Initial Version
**/
@IsTest
public with sharing class IF_ERP_Account_Test {
    private static String className = 'IF_ERP_Account';

/** Mock Classes
   */
        /** ACCOUNT 001
        */
            // ** SUCCESS CASE
            public with sharing class IF_ACCOUNT_001_HttpMock implements HttpCalloutMock {
                public HttpResponse respond(HttpRequest req){
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');

                    String resBody = '{"O_REMSG":"Successfully finished.","O_RECODE":"S","O_KUNNR":"1330094","O_DUP":"","ET_DATA":[]}';
                    res.setBody(resBody);
                    res.setStatusCode(200);

                    return res;
                }
            }

            // ** Fail CASE
            public with sharing class IF_ACCOUNT_001_Fail_HttpMock implements HttpCalloutMock {
                public HttpResponse respond(HttpRequest req){
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');

                    String resBody = '{"O_DUP":"X","O_KUNNR":"","O_RECODE":"E","O_REMSG":"Duplicate entry exists.","ET_DATA":[{"TELFX":"","ERDAT":"2025-03-18","ANRED_ZI":"Company","NAME1_ZI":"에이앤티머신 주식회사","VTWEG":"10","ERZET":"00:00:00","VKORG":"1800","KUNNR":"0001330255","LAND1":"KR","KUNNR_ZI":"0001306120","KTOKD":"1090","TELF2":"","TELF1":"","KNURL":"","SPART":"40","NAME1":"세무사","ANRED":"Company"}]}';
                    res.setBody(resBody);
                    res.setStatusCode(200);

                    return res;
                }
            }

        /** IF_ACCOUNT_002
        */
            // 
            public with sharing class IF_ACCOUNT_002_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_REMSG":"Successfully finished.","O_RECODE":"S"}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }
 
        /** IF_ACCOUNT_003
        */
            // 
            public with sharing class IF_ACCOUNT_003_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_REMSG":"Formatting error in the field KNVV-WAERS; see next message","O_RECODE":"E","O_BLOCKED_MSG":"","O_BLOCKED":""}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }
 
        /** IF_ACCOUNT_004
        */
            // 
            public with sharing class IF_ACCOUNT_004_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_REMSG":"Successfully finished.","O_RECODE":"S","O_KUNNR":"1330096","O_DUP":"","ET_DATA":[]}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        /** IF_ACCOUNT_005
        */
            // 
            public with sharing class IF_ACCOUNT_005_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"T_KNVV":[{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001329992","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"114B","SPART":"40","KUNNR":"0001329993","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"A1AE","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"114B","SPART":"40","KUNNR":"0001329994","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"A1AE","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"114B","SPART":"40","KUNNR":"0001329995","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"A1AE","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"114B","SPART":"40","KUNNR":"0001329996","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"A1AE","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001329997","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001329998","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001329999","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001330000","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"C0","WAERS":"KRW","VTWEG":"10","VSBED":"10","VKORG":"1846","VKGRP":"","VKBUR":"114F","SPART":"40","KUNNR":"0001330001","KTGRD":"01","KDGRP":"01","INCO1":"Y01","BZIRK":"A1KR","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001330002","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"C0","WAERS":"KRW","VTWEG":"10","VSBED":"10","VKORG":"1846","VKGRP":"","VKBUR":"114F","SPART":"40","KUNNR":"0001330003","KTGRD":"01","KDGRP":"01","INCO1":"Y01","BZIRK":"A1KR","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001330004","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"C0","WAERS":"KRW","VTWEG":"10","VSBED":"10","VKORG":"1846","VKGRP":"","VKBUR":"114F","SPART":"40","KUNNR":"0001330005","KTGRD":"01","KDGRP":"01","INCO1":"Y01","BZIRK":"A1KR","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001330006","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"114B","SPART":"40","KUNNR":"0001330007","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"A1AE","AUFSD":""},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001330008","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"1140","SPART":"40","KUNNR":"0001330009","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"A1IN","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001330010","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"},{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"1140","SPART":"40","KUNNR":"0001330011","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"A1IN","AUFSD":"X"}],"T_KNVP":[{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329992","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329993","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329994","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329995","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329996","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329997","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329998","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329999","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001330000","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Sold-to party","VKORG":"1846","SPART":"40","PARVW":"AG","KUNNR":"0001330001","KUNN2":"0001330001","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Bill-to party","VKORG":"1846","SPART":"40","PARVW":"RE","KUNNR":"0001330001","KUNN2":"0001330001","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Payer","VKORG":"1846","SPART":"40","PARVW":"RG","KUNNR":"0001330001","KUNN2":"0001330001","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Ship-to party","VKORG":"1846","SPART":"40","PARVW":"WE","KUNNR":"0001330001","KUNN2":"0001330001","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001330002","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Sold-to party","VKORG":"1846","SPART":"40","PARVW":"AG","KUNNR":"0001330003","KUNN2":"0001330003","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Bill-to party","VKORG":"1846","SPART":"40","PARVW":"RE","KUNNR":"0001330003","KUNN2":"0001330003","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Payer","VKORG":"1846","SPART":"40","PARVW":"RG","KUNNR":"0001330003","KUNN2":"0001330003","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Ship-to party","VKORG":"1846","SPART":"40","PARVW":"WE","KUNNR":"0001330003","KUNN2":"0001330003","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001330004","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Sold-to party","VKORG":"1846","SPART":"40","PARVW":"AG","KUNNR":"0001330005","KUNN2":"0001330005","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Bill-to party","VKORG":"1846","SPART":"40","PARVW":"RE","KUNNR":"0001330005","KUNN2":"0001330005","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Payer","VKORG":"1846","SPART":"40","PARVW":"RG","KUNNR":"0001330005","KUNN2":"0001330005","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Ship-to party","VKORG":"1846","SPART":"40","PARVW":"WE","KUNNR":"0001330005","KUNN2":"0001330005","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001330006","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001330007","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001330008","KUNN2":"0001227169","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Sales Resps.","VKORG":"1800","SPART":"40","PARVW":"ZM","KUNNR":"0001330009","KUNN2":"0001040787","KNREF":"","DEFPA":""},{"VTWEG":"10","VTEXT":"Sales Resps.","VKORG":"1800","SPART":"40","PARVW":"ZM","KUNNR":"0001330011","KUNN2":"0001040787","KNREF":"","DEFPA":""}],"T_KNA1":[{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-12","STRAS":"768 East 5th Street","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"New York","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"0117Prospect","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329992","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"0117Repres","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288855"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"Mold","VTEXT20":"","VTEXT2":"Other Vehicles","VTEXT10":"","VTEXT1":"Automotive & Parts","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"114B","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-13","STRAS":"768 East 5th Street","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"New York","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"1017Pros","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329993","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"MY","KATR20":"","KATR2":"MA4","KATR10":"","KATR1":"MA","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"1017Pros","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288856"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"Mold","VTEXT20":"","VTEXT2":"Other Vehicles","VTEXT10":"","VTEXT1":"Automotive & Parts","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"114B","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"010-1010","STRAS":"Si Pha Ya - Icon Siam","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Bang kok","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"1017Prospect2","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329994","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"MY","KATR20":"","KATR2":"MA4","KATR10":"","KATR1":"MA","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"1017Prospe","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288857"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"Mold","VTEXT20":"","VTEXT2":"Other Vehicles","VTEXT10":"","VTEXT1":"Automotive & Parts","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"114B","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"010-1234","STRAS":"Pedro de Alba","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"San Nicolás de los Garza","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"parkpark","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329995","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"MY","KATR20":"","KATR2":"MA4","KATR10":"","KATR1":"MA","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"TEST","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288858"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"Mold","VTEXT20":"","VTEXT2":"Other Vehicles","VTEXT10":"","VTEXT1":"Automotive & Parts","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"114B","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"112123132","STRAS":"test","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Iconium","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"Sample0117","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329996","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"MY","KATR20":"","KATR2":"MA4","KATR10":"","KATR1":"MA","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"Sample0117","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288860"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"123-333-344","STRAS":"","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"New York","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"SampleProspect0117","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329997","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"SamplePros","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288861"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-123","STRAS":"Fforest-fach","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Swansea","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"SampleProspect01171","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329998","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"SampleP","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288862"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-356","STRAS":"Apple Park Way","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Cupertino","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"SamplePros1","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329999","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"SamplePros","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288863"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"123-44","STRAS":"Apple Park Way","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Cupertino","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"Acc1143","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1330000","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"ACc","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288864"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"영업","VTEXT10":"","VTEXT1":"신용도 A","VSBED":"","VRKME":"","VKORG":"1846","VKBUR":"114F","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"0299998888","STRAS":"I_STREET","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"I_CITY","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"콜드브루_TEST0","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"USA","LAND1":"US","KUNNR":"1330001","KTONR":"","KTOKD":"1010","KTEXT":"Captive customer","KONZS":"","KNURL":"1234@DNCOMPANY.COM","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"200","KATR10":"","KATR1":"100","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"대표자","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288865"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"1234","STRAS":"Apple Park Way","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Cupertino","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"AccTest1","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1330002","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"AccTest1","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288866"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"영업","VTEXT10":"","VTEXT1":"신용도 A","VSBED":"","VRKME":"","VKORG":"1846","VKBUR":"114F","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"0299998888","STRAS":"I_STREET","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"I_CITY","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"콜드브루_TEST0","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"USA","LAND1":"US","KUNNR":"1330003","KTONR":"","KTOKD":"1010","KTEXT":"Captive customer","KONZS":"","KNURL":"1234@DNCOMPANY.COM","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"200","KATR10":"","KATR1":"100","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"해외 예시","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288867"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"1223","STRAS":"Apple Park Way","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Cupertino","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"AccTest2","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1330004","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"AccTest2","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288868"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"영업","VTEXT10":"","VTEXT1":"신용도 A","VSBED":"","VRKME":"","VKORG":"1846","VKBUR":"114F","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"0299998888","STRAS":"I_STREET","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"I_CITY","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"콜드브루_TEST8","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"USA","LAND1":"US","KUNNR":"1330005","KTONR":"","KTOKD":"1010","KTEXT":"Captive customer","KONZS":"","KNURL":"1234@DNCOMPANY.COM","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"200","KATR10":"","KATR1":"100","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"해외 예시","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288869"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12323","STRAS":"Apple Park Way","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Cupertino","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"sampleAcc1","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1330006","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"sampleAcc1","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288870"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"Non Mold","VTEXT20":"","VTEXT2":"Electric car","VTEXT10":"","VTEXT1":"Automotive & Parts","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"114B","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-23-4","STRAS":"Apple Park Way","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Cupertino","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"ValidCustomer1","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1330007","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"MN","KATR20":"","KATR2":"MA6","KATR10":"","KATR1":"MA","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"ValidCusto","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"","ANRED":"","ADRNR":"0003288871"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-123-4-1","STRAS":"","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"Metairie","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"잠재고객1","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1330008","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"잠재대표1","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288872"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"Mold","VTEXT20":"","VTEXT2":"Mobile Phone","VTEXT10":"","VTEXT1":"IT","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"1140","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"","STRAS":"","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"TEST20241226_23","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"LOCATION","LFIMG":"0.000","LANDX":"USA","LAND1":"US","KUNNR":"1330009","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"MY","KATR20":"","KATR2":"MB5","KATR10":"","KATR1":"MB","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"TEST_1_US","GKAM_M":"","FLAG":"","ERNAM":"IV0109946","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288873"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"","STRAS":"LOCATION","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"TEST20241226_24","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"LOCATION","LFIMG":"0.000","LANDX":"USA","LAND1":"US","KUNNR":"1330010","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"USA","GKAM_M":"","FLAG":"","ERNAM":"IV0101650","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288875"},{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"Mold","VTEXT20":"","VTEXT2":"Mobile Phone","VTEXT10":"","VTEXT1":"IT","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"1140","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"","STRAS":"","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"TEST20241226_22","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"LOCATION","LFIMG":"0.000","LANDX":"India","LAND1":"IN","KUNNR":"1330011","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"MY","KATR20":"","KATR2":"MB5","KATR10":"","KATR1":"MB","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"TEST_1","GKAM_M":"","FLAG":"","ERNAM":"IV0109946","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288876"}],"O_REMSG":"Successfully finished.","O_RECODE":"S","O_COUNT":"     20","O_BOBAI":""}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        /** IF_ACCOUNT_006
        */
            // 
            public with sharing class IF_ACCOUNT_006_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_RECODE":"S","O_REMSG":"Successfully finished."}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }
 
        /** IF_ACCOUNT_012
        */
            // 
            public with sharing class IF_ACCOUNT_012_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_REMSG":"Please Check Sales Organization.","O_RECODE":"E","O_KUNNR":"","O_DUP":"","ET_DATA":[]}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }
 
        /** IF_ACCOUNT_013
        */
            // 
            public with sharing class IF_ACCOUNT_013_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_REMSG":"Successfully finished.","O_RECODE":"S"}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        /** IF_ACCOUNT_014
        */
            // 
            public with sharing class IF_ACCOUNT_014_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"T_KNA1":[],"O_RETURN":"N","O_REMSG":"카파정공;No data found.","O_RECODE":"S"}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        /** IF_ACCOUNT_015
        */
            // 
            public with sharing class IF_ACCOUNT_015_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_RETURN":{"TYPE":"S","MESSAGE":"Sales Employee0000013350was created .","CODE":""},"O_PERSON":"13350"}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        /** IF_ACCOUNT_016
        */
            // 
            public with sharing class IF_ACCOUNT_016_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Data found"},"T_LIST":[{"KUNNR2":"","LAND1_TEXT":"USA","STATUS":"Active","NAME_CO":"TOM DEER","STR_SUPPL1":"","COUNC":"","COUNTRY":"US","NAME2X":"","FAX_NUMBER":"","TRANSPZONE":"","TERRITORY_TX":"","BRAN1":"","SMTP_ADDR":"sales@ablemm.com","REGIO_TEXT":"Texas","POST_CODE1":"77086","REGION":"TX","NAME4":"","NAME3":"","NAME2":"","NAME1":"ABLE MACHINERY MOVERS","STCD1":"","KUNNR":"0000012824","MOB_NUMBER":"","CITY1":"Houston","TEL_NUMBER":"713-460-2253","STREET":"10835 BAMMEL NORTH HOUSTON RD"},{"KUNNR2":"","LAND1_TEXT":"USA","STATUS":"Active","NAME_CO":"JAIE CLEARY","STR_SUPPL1":"","COUNC":"","COUNTRY":"US","NAME2X":"","FAX_NUMBER":"","TRANSPZONE":"","TERRITORY_TX":"","BRAN1":"","SMTP_ADDR":"LCOLBY@ELLISONTECHNOLOGIES.COM","REGIO_TEXT":"Maryland","POST_CODE1":"21154","REGION":"MD","NAME4":"","NAME3":"","NAME2":"","NAME1":"ACE RIGGING","STCD1":"","KUNNR":"0000012811","MOB_NUMBER":"","CITY1":"STREET","TEL_NUMBER":"443-277-2840","STREET":"3224 CONOWINGO ROAD"}]}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        /** IF_ACCOUNT_017
        */
        
            // 
            public with sharing class IF_ACCOUNT_017_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"T_LIST":[{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"C","KUNNR":"0001063199","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)케이엠티이","MANDT":"880","KVGR4":"C","KUNNR":"0001066596","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"B","KUNNR":"0001076112","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에프엠공작기계㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"엠티창원판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"오마이머신 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001107902","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 경기머신툴","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티충청","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디엠티 부산판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001133521","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디엠공작기계㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"엠티솔루션경서판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001158372","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디머신부경판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001169833","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"B","KUNNR":"0001293590","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001302389","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306120","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"C","KUNNR":"0001307672","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001311191","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티웍스","MANDT":"880","KVGR4":"B","KUNNR":"0001313992","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"C","KUNNR":"0001057663","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"B","KUNNR":"0001063199","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)케이엠티이","MANDT":"880","KVGR4":"B","KUNNR":"0001066596","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"B","KUNNR":"0001076112","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에프엠공작기계㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"엠티창원판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"오마이머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107902","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 경기머신툴","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티충청","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디엠티 부산판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001133521","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디엠공작기계㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"엠티솔루션경서판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001158372","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디머신부경판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001169833","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"B","KUNNR":"0001293590","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001302389","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스에스엘엠티 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306079","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306120","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"C","KUNNR":"0001307672","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001311191","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티웍스","MANDT":"880","KVGR4":"B","KUNNR":"0001313992","DATBI":"2023-12-31","DATAB":"2023-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 엠티웍스","MANDT":"880","KVGR4":"B","KUNNR":"0001313992","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"C","KUNNR":"0001057663","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"B","KUNNR":"0001063199","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)케이엠티이","MANDT":"880","KVGR4":"B","KUNNR":"0001066596","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"B","KUNNR":"0001076112","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에프엠공작기계㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"엠티창원판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"오마이머신 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001107902","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 경기머신툴","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티충청","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디엠티 부산판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001133521","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디엠공작기계㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"엠티솔루션경서판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001158372","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디머신부경판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001169833","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"B","KUNNR":"0001293590","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001302389","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스에스엘엠티 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306079","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001306120","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"C","KUNNR":"0001307672","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001311191","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티웍스","MANDT":"880","KVGR4":"B","KUNNR":"0001313992","DATBI":"2023-06-30","DATAB":"2023-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"C","KUNNR":"0001057663","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"C","KUNNR":"0001063199","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산엠티이","MANDT":"880","KVGR4":"B","KUNNR":"0001066596","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"B","KUNNR":"0001076112","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에프엠공작기계㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"엠티창원판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계중부판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001107902","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산인프라코어경기판매","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산공작기계 충청판매","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부산판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001133521","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대전판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계경서판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001158372","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부경판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001169833","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디에스","MANDT":"880","KVGR4":"B","KUNNR":"0001286985","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"B","KUNNR":"0001293590","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001302389","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계부창판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306079","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306120","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"C","KUNNR":"0001307672","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001311191","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티웍스","MANDT":"880","KVGR4":"B","KUNNR":"0001313992","DATBI":"2022-12-31","DATAB":"2022-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"부경엠티 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001328434","DATBI":"2023-12-31","DATAB":"2023-06-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"부경엠티 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001328434","DATBI":"2024-06-30","DATAB":"2024-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대전판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계경서판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001158372","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부경판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001169833","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디에스","MANDT":"880","KVGR4":"B","KUNNR":"0001286985","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"B","KUNNR":"0001293590","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001302389","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계부창판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306079","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306120","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"C","KUNNR":"0001307672","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001311191","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계중부판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107902","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산인프라코어경기판매","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산공작기계 충청판매","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부산판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001133521","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대전판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계경서판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001158372","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산공작기계 안산판매","MANDT":"880","KVGR4":"C","KUNNR":"0001166276","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"창원판매","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"C","KUNNR":"0001063199","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001076112","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001306120","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"C","KUNNR":"0001057663","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"C","KUNNR":"0001063199","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산엠티이","MANDT":"880","KVGR4":"B","KUNNR":"0001066596","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"C","KUNNR":"0001076112","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대구경북판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 창원판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계중부판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001107902","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산인프라코어경기판매","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산공작기계 충청판매","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부산판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001133521","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대전판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계경서판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001158372","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부경판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001169833","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계엠티에스 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001271409","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디에스","MANDT":"880","KVGR4":"C","KUNNR":"0001286985","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"B","KUNNR":"0001293590","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001302389","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"경북판매주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001304374","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계부창판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306079","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306120","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"C","KUNNR":"0001307672","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부경판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001169833","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 서부판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001173895","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계엠티에스 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001271409","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디에스","MANDT":"880","KVGR4":"B","KUNNR":"0001286985","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"C","KUNNR":"0001293590","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001302389","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"경북판매주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001304374","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계부창판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001306079","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"C","KUNNR":"0001307672","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"C","KUNNR":"0001057663","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001311191","DATBI":"2021-06-30","DATAB":"2021-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 엠티웍스","MANDT":"880","KVGR4":"C","KUNNR":"0001313992","DATBI":"2021-06-30","DATAB":"2021-06-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"B","KUNNR":"0001057663","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"B","KUNNR":"0001063199","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산엠티이","MANDT":"880","KVGR4":"B","KUNNR":"0001066596","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"B","KUNNR":"0001076112","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대구경북판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 창원판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계중부판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001107902","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산인프라코어경기판매","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산공작기계 충청판매","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부산판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001133521","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대전판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001158263","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계경서판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001158372","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부경판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001169833","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부산판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001133521","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디에스","MANDT":"880","KVGR4":"B","KUNNR":"0001286985","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"B","KUNNR":"0001293590","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001302389","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"경북판매주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001304374","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계부창판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001306079","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001306120","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 하이엠","MANDT":"880","KVGR4":"B","KUNNR":"0001307672","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 디에스엠티","MANDT":"880","KVGR4":"B","KUNNR":"0001311191","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 엠티웍스","MANDT":"880","KVGR4":"B","KUNNR":"0001313992","DATBI":"2021-12-31","DATAB":"2021-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"B","KUNNR":"0001057663","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"B","KUNNR":"0001063199","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산엠티이","MANDT":"880","KVGR4":"B","KUNNR":"0001066596","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"B","KUNNR":"0001076112","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대구경북판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 창원판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001084141","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계중부판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107902","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산인프라코어경기판매","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산공작기계 충청판매","MANDT":"880","KVGR4":"B","KUNNR":"0001127223","DATBI":"2022-06-30","DATAB":"2022-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)세훈엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001056926","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜혜성테크","MANDT":"880","KVGR4":"C","KUNNR":"0001057478","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜세원기계","MANDT":"880","KVGR4":"B","KUNNR":"0001057663","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057671","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001057769","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두진기계","MANDT":"880","KVGR4":"C","KUNNR":"0001063199","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산엠티이","MANDT":"880","KVGR4":"C","KUNNR":"0001066596","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"중앙머신 BANK","MANDT":"880","KVGR4":"C","KUNNR":"0001066755","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"영남머신(주)","MANDT":"880","KVGR4":"C","KUNNR":"0001076112","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대구경북판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 창원판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001084141","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001107596","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계부창판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001306079","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계중부판매 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107902","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산토탈머신 주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001124140","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산인프라코어경기판매","MANDT":"880","KVGR4":"B","KUNNR":"0001126120","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"(주)두산공작기계 충청판매","MANDT":"880","KVGR4":"C","KUNNR":"0001127223","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부산판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001133521","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"탑공작기계판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001157856","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대전판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001158263","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계경서판매 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001158372","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계경인판매(주)","MANDT":"880","KVGR4":"C","KUNNR":"0001160148","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산공작기계 안산판매","MANDT":"880","KVGR4":"C","KUNNR":"0001166276","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 부경판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001169833","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 서부판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001173895","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디와이판매주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001057477","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜혜성테크","MANDT":"880","KVGR4":"C","KUNNR":"0001057478","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디아이테크㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057671","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 아이티티","MANDT":"880","KVGR4":"C","KUNNR":"0001226090","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계엠티에스 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001271409","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"디에스","MANDT":"880","KVGR4":"B","KUNNR":"0001286985","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 더머신","MANDT":"880","KVGR4":"C","KUNNR":"0001293590","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"주식회사 티엠티","MANDT":"880","KVGR4":"C","KUNNR":"0001302389","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"경북판매주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001304374","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에이앤티머신 주식회사","MANDT":"880","KVGR4":"C","KUNNR":"0001306120","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"에스케이엠티㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001306140","DATBI":"2020-06-30","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜진성엠텍","MANDT":"880","KVGR4":"C","KUNNR":"0001057664","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜덕성티에스","MANDT":"880","KVGR4":"C","KUNNR":"0001057668","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001066666","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 진주판매(주)","MANDT":"880","KVGR4":"C","KUNNR":"0001073041","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 경남판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001083444","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대성판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001175453","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 남부판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001176039","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 안산중앙판매㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001185360","DATBI":"2020-02-28","DATAB":"2020-01-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"한국엠티에스㈜","MANDT":"880","KVGR4":"C","KUNNR":"0001057769","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"㈜두산엠티이","MANDT":"880","KVGR4":"C","KUNNR":"0001066596","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"중앙머신 BANK","MANDT":"880","KVGR4":"C","KUNNR":"0001066755","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"두산공작기계 대구경북판매㈜","MANDT":"880","KVGR4":"B","KUNNR":"0001082347","DATBI":"2020-12-31","DATAB":"2020-07-01"},{"VTWEG":"10","VKORG":"1800","SPART":"40","NAME1":"하이머신주식회사","MANDT":"880","KVGR4":"B","KUNNR":"0001107596","DATBI":"2020-12-31","DATAB":"2020-07-01"}],"O_RETURN":{"TYPE":"S","MESSAGE":"Successfully finished.","CODE":""}}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        public class IF_ACCOUNT_017_Testcode_HttpMock implements HttpCalloutMock {
            public IF_ACCOUNT_017_Testcode_HttpMock(){}
    
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
    
                String resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished."},"T_LIST":[{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001057477","KVGR4":"B","NAME1":"디와이판매주식회사","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001057671","KVGR4":"B","NAME1":"디아이테크㈜","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001057769","KVGR4":"C","NAME1":"한국엠티에스㈜","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001063199","KVGR4":"C","NAME1":"㈜두진기계","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001066596","KVGR4":"C","NAME1":"(주)케이엠티이","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001076112","KVGR4":"B","NAME1":"영남머신(주)","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001082347","KVGR4":"B","NAME1":"에프엠공작기계㈜","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001084141","KVGR4":"B","NAME1":"엠티창원판매 주식회사","SPART":"40","DATAB":"2024-01-01","MANDT":"880"},{"DATBI":"2024-06-30","VTWEG":"10","VKORG":"1800","KUNNR":"0001107596","KVGR4":"B","NAME1":"하이머신주식회사","SPART":"40","DATAB":"2024-01-01","MANDT":"880"}]}';
    
                res.setBody(resBody);
                res.setStatusCode(200);
        
                System.debug(res.getBody());
                return res;
            }
        }

        /** IF_ACCOUNT_018
        */
            // 
            public with sharing class IF_ACCOUNT_018_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_KUNNR":"0001330128","OT_RETURN":[{"CODE":"","MESSAGE":"이미 회계뷰가 확장된 고객 입니다","TYPE":"E"},{"CODE":"","MESSAGE":"0001330128 1800 10 40 고객 Sales View 확장 완료","TYPE":"S"}]}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }

        /** IF_ACCOUNT_019
        */
            // 
        public with sharing class IF_ACCOUNT_019_HttpMock implements HttpCalloutMock {
            public HttpResponse respond(HttpRequest req){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                String resBody = '{"O_KUNNR":"0001330354","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished."}}';
                res.setBody(resBody);
                res.setStatusCode(200);

                return res;
            }
        }
 
/** TEST CODE
  */ 
        @IsTest
        static void IF_ACCOUNT_001_Test() {
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-001', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
 
            IF_ERP_Account_Classes.IF_ACCOUNT_001_Req request = new IF_ERP_Account_Classes.IF_ACCOUNT_001_Req();
            request.I_ANRED                         = 'MR';
            request.I_NAME1                         = 'TEST_INTERFACE_250206'; // 고객사 명
            request.I_NAME                          = '대표자2';
            request.I_LOCATION                      = 'LOCATION';
            request.I_COUNTRY                       = 'IN';
            request.I_PSTLZ                         = '134941';
            request.I_JMZAH                         = '000000';
            request.I_JMJAH                         = '0000';
            request.I_KATR1                         = 'MB';
            request.I_KATR2                         = 'MB5';
            request.I_KATR3                         = 'MY';
            request.I_VKBUR                         = '1140';
            request.I_BZIRK                         = 'A1IN';
            request.I_TAXNUMBER1                    = '0123456789ABCDEF';
            request.I_KTONR2                        = '1040787';
            request.I_VKORG                         = '1800';
            request.I_VTWEG                         = '10';
            request.I_SPART                         = '40';
            request.I_DEALER                        = '1040787';
            request.I_SPRAS                         = 'EN';
            request.I_WAERS                         = 'USD';

            method.IF_ACCOUNT_001(request);


            List<IF_ERP_Account_Classes.IF_Account_001_Res_ET_DATA> ET_DATA_LIST = new List<IF_ERP_Account_Classes.IF_Account_001_Res_ET_DATA> ();

            IF_ERP_Account_Classes.IF_Account_001_Res_ET_DATA ET_DATA =
            new IF_ERP_Account_Classes.IF_Account_001_Res_ET_DATA(); 
            ET_DATA.KUNNR_ZI = 'temp';
            ET_DATA.NAME1_ZI = 'temp';
            ET_DATA.KUNNR = 'temp';
            ET_DATA.NAME1_GP = 'temp';
            ET_DATA.TELF1 = 'temp';
            ET_DATA.TELF2 = 'temp';
            ET_DATA.TELFX = 'temp';
            ET_DATA.URL = 'temp';
            ET_DATA.VKORG = 'temp';
            ET_DATA.VTWEG = 'temp';
            ET_DATA.SPART = 'temp';
            ET_DATA.LAND1 = 'temp';
            ET_DATA.KTOKD = 'temp';
            ET_DATA.ERDAT = 'temp';
            ET_DATA.ERZET = 'temp';
            ET_DATA.ANRED_ZI = 'temp';
            ET_DATA.ANRED = 'temp';

            ET_DATA_LIST.add(ET_DATA);

            IF_ERP_Account_Classes.IF_Account_001_Res response = new IF_ERP_Account_Classes.IF_Account_001_Res(); 
            response.O_RECODE = 'temp';
            response.O_REMSG  = 'temp';
            response.O_KUNNR  = 'temp';
            response.O_DUP    = 'temp';
            response.ET_DATA  =  ET_DATA_LIST;

            Test.stopTest();
        }

        @IsTest 
        static void IF_ACCOUNT_002_SuccessTest(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-002', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();

            // request 
            IF_ERP_Account_Classes.IF_ACCOUNT_002_Req request = 
                new IF_ERP_Account_Classes.IF_ACCOUNT_002_Req();
                request.I_KUNNR = 'temp';
                request.I_ANRED = 'temp';
                request.I_NAME1 = 'temp';
                request.I_NAME3 = 'temp';
                request.I_SORT1 = 'temp';
                request.I_NAME = 'temp';
                request.I_LOCATION = 'temp';
                request.I_COUNTRY = 'temp';
                request.I_REGION = 'temp';
                request.I_PSTLZ = 'temp';
                request.I_STREET = 'temp';
                request.I_CITY1 = 'temp';
                request.I_STR_SUPPL1 = 'temp';
                request.I_TEL_NUMBER = 'temp';
                request.I_MOB_NUMBER = 'temp';
                request.I_FAX_NUMBER = 'temp';
                request.I_SMTP_ADDR = 'temp';
                request.I_JMZAH = 'temp';
                request.I_JMJAH = 'temp';
                request.I_KATR1 = 'temp';
                request.I_KATR2 = 'temp';
                request.I_KATR3 = 'temp';
                request.I_J_1KFTBUS = 'temp';
                request.I_J_1KFTIND = 'temp';
                request.I_VKBUR = 'temp';
                request.I_BZIRK = 'temp';
                request.I_TAXNUMBER1 = 'temp';
                request.I_KTONR = 'temp';
                request.I_VKORG = 'temp';
                request.I_VTWEG = 'temp';
                request.I_SPART = 'temp';
                request.I_DEALER = 'temp';
                request.I_SPRAS = 'temp';
                request.I_TAXNUMBER4 = 'temp';
                request.I_EMAIL = 'temp';
                request.I_AUFSD = 'temp';
                request.I_WAERS = 'temp';
                request.O_BLOCKED = 'temp';
                request.O_BLOCKED_MSG = 'temp'; 
            method.IF_ACCOUNT_002(request);

            // response 
            IF_ERP_Account_Classes.IF_ACCOUNT_002_Res  response = 
                new IF_ERP_Account_Classes.IF_ACCOUNT_002_Res();
                response.O_RECODE = 'temp';
                response.O_REMSG = 'temp';

            Test.stopTest();
        }

        @IsTest 
        static void IF_ACCOUNT_003_FormattingError_Test(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-003', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();

            // request
            IF_ERP_Account_Classes.IF_ACCOUNT_003_Req request =
             new IF_ERP_Account_Classes.IF_ACCOUNT_003_Req() ;
             request.I_KUNNR ='temp';
             request.I_ANRED ='temp';
             request.I_NAME1 ='temp';
             request.I_NAME3 ='temp';
             request.I_SORT1 ='temp';
             request.I_LOCATION ='temp';
             request.I_COUNTRY ='temp';
             request.I_REGION ='temp';
             request.I_PSTLZ ='temp';
             request.I_STREET ='temp';
             request.I_CITY1 ='temp';
             request.I_STR_SUPPL1 ='temp';
             request.I_TEL_NUMBER ='temp';
             request.I_MOB_NUMBER ='temp';
             request.I_FAX_NUMBER ='temp';
             request.I_SMTP_ADDR ='temp';
             request.I_JMZAH ='temp';
             request.I_JMJAH ='temp';
             request.I_KATR1 ='temp';
             request.I_KATR2 ='temp';
             request.I_KATR3 ='temp';
             request.I_J_1KFTBUS ='temp';
             request.I_J_1KFTIND ='temp';
             request.I_VKBUR ='temp';
             request.I_BZIRK ='temp';
             request.I_TAXNUMBER1 ='temp';
             request.I_KTONR ='temp';
             request.I_VKORG ='temp';
             request.I_VTWEG ='temp';
             request.I_SPART ='temp';
             request.I_DEALER ='temp';
             request.I_SPRAS ='temp';
             request.I_TAXNUMBER4 ='temp';
             request.I_EMAIL ='temp';
             request.I_NAME ='temp';
             request.I_AUFSD ='temp';
             request.I_WAERS ='temp';
             method.IF_ACCOUNT_003(request);

            // response  
            IF_ERP_Account_Classes.IF_ACCOUNT_003_Res response =
             new IF_ERP_Account_Classes.IF_ACCOUNT_003_Res(); 
             response.O_RECODE = 'temp';
             response.O_REMSG = 'temp';
             response.O_BLOCKED = 'temp';
             response.O_BLOCKED_MSG = 'temp';             

             Test.stopTest();
        }

        @IsTest 
        static void IF_ACCOUNT_004_Test(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-004', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_004_Req request = new IF_ERP_Account_Classes.IF_ACCOUNT_004_Req(); 
            request.I_ANRED = '';
            request.I_NAME1 = '';
            request.I_NAME3 = '';
            request.I_SORT1 = '';
            request.I_LOCATION = '';
            request.I_COUNTRY = '';
            request.I_REGION = '';
            request.I_PSTLZ = '';
            request.I_STREET = '';
            request.I_CITY1 = '';
            request.I_STR_SUPPL1 = '';
            request.I_TEL_NUMBER = '';
            request.I_MOB_NUMBER = '';
            request.I_FAX_NUMBER = '';
            request.I_SMTP_ADDR = '';
            request.I_JMZAH = '';
            request.I_JMJAH = '';
            request.I_KATR1 = '';
            request.I_KATR2 = '';
            request.I_KATR3 = '';
            request.I_J_1KFTBUS = '';
            request.I_J_1KFTIND = '';
            request.I_VKBUR = '';
            request.I_BZIRK = '';
            request.I_TAXNUMBER1 = '';
            request.I_KTONR = '';
            request.I_VKORG = '';
            request.I_VTWEG = '';
            request.I_SPART = '';
            request.I_DEALER = '';
            request.I_SPRAS = '';
            request.I_TAXNUMBER4 = '';
            request.I_EMAIL = '';
            request.I_NAME = '';
            request.I_WAERS = '';
            method.IF_ACCOUNT_004(request);

    

            List<IF_ERP_Account_Classes.IF_ACCOUNT_004_Res_ET_DATA> et_data_list = new List<IF_ERP_Account_Classes.IF_ACCOUNT_004_Res_ET_DATA>(); 
            IF_ERP_Account_Classes.IF_ACCOUNT_004_Res_ET_DATA et_data = new IF_ERP_Account_Classes.IF_ACCOUNT_004_Res_ET_DATA();
            et_data.KUNNR_ZI = '';
            et_data.NAME1_ZI = '';
            et_data.KUNNR = '';
            et_data.NAME1 = '';
            et_data.TELF1 = '';
            et_data.TELF2 = '';
            et_data.TELFX = '';
            et_data.KNURL = '';
            et_data.VKORG = '';
            et_data.VTWEG = '';
            et_data.SPART = '';
            et_data.LAND1 = '';
            et_data.KTOKD = '';
            et_data.ERDAT = '';
            et_data.ERZET = '';
            et_data.ANRED_ZI = '';
            et_data.ANRED = '';
            et_data_list.add(et_data);

            IF_ERP_Account_Classes.IF_ACCOUNT_004_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_004_Res(); 
            response.O_RECODE = '';
            response.O_REMSG = '';
            response.O_KUNNR = '';
            response.O_DUP = '';        
            response.ET_DATA = et_data_list;
            Test.stopTest(); 
        }

        @IsTest    
        static void IF_ACCOUNT_005_Test(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-005', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_005_Req request = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Req();
            request.I_SDATE = '';
            request.I_EDATE = '';

            IF_ERP_Account_Classes.IF_ACCOUNT_005_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Res();
            response.O_RECODE = '';
            response.O_REMSG = '';
            response.O_COUNT = '';
            response.O_BOBAI = '';

            List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNA1> t_kna1_list = new List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNA1>();
            IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNA1 kana1 = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNA1(); 
            kana1.KUNNR = '';
            kana1.NAME1 = '';
            kana1.ORT01 = '';
            kana1.STRAS = '';
            kana1.LAND1 = '';
            kana1.LANDX = '';
            kana1.ERNAM = '';
            kana1.ERDAT = '';
            kana1.KTOKD = '';
            kana1.KDGRP = '';
            kana1.KTEXT = '';
            kana1.ANRED = '';
            kana1.LOCATION = '';
            kana1.REGIO = '';
            kana1.SORTL = '';
            kana1.NAME3 = '';
            kana1.PSTLZ = '';
            kana1.TELF1 = '';
            kana1.TELF2 = '';
            kana1.TELFX = '';
            kana1.KNURL = '';
            kana1.KATR1 = '';
            kana1.VTEXT1 = '';
            kana1.KATR2 = '';
            kana1.VTEXT2 = '';
            kana1.KATR3 = '';
            kana1.VTEXT3 = '';
            kana1.STCD1 = '';
            kana1.STCD2 = '';
            kana1.J_1KFTBUS = '';
            kana1.J_1KFTIND = '';
            kana1.JMZAH = '';
            kana1.JMJAH = '';
            kana1.BZIRK = '';
            kana1.BZTXT = '';
            kana1.VKBUR = '';
            kana1.BEZEI = '';
            kana1.KTONR = '';
            kana1.NAME2 = '';
            kana1.VSBED = '';
            kana1.VTEXT4 = '';
            kana1.VKORG = '';
            kana1.VTEXT5 = '';
            kana1.VTWEG = '';
            kana1.VTEXT6 = '';
            kana1.SPART = '';
            kana1.VTEXT7 = '';
            kana1.MDLNM = '';
            kana1.MATNR = '';
            kana1.MAKTX = '';
            kana1.MEINS = '';
            kana1.ADRNR = '';
            kana1.FLAG = '';
            kana1.STCD4 = '';
            kana1.SATNR = '';
            kana1.AUFSD = '';
            kana1.J_1KFREPRE = '';
            kana1.VBELN = '';
            kana1.WADAT_IST = '';
            kana1.VRKME = '';
            kana1.LFIMG = '';
            kana1.TOTAL_LFIMG = '';
            kana1.ZSEXTEN = '';
            kana1.ZMESSAGE = '';
            kana1.STCD3 = '';
            kana1.KONZS = '';
            kana1.NAME_GR = '';
            kana1.KATR10 = '';
            kana1.VTEXT10 = '';
            kana1.KATR20 = '';
            kana1.VTEXT20 = '';
            kana1.KATR30 = '';
            kana1.VTEXT30 = '';
            kana1.GKAM_M = '';
            kana1.ZTURNOVER = '';
            kana1.ZEMPL = '';
            kana1.ZPRESI = '';
            kana1.ZYEAR = '';
            kana1.ZHEADQ = '';
            kana1.ZVOL = '';
            kana1.ZPROD = '';
            kana1.ZBUYER = '';
            kana1.ZWEBPAGE = '';
            kana1.REGIO_T = '';
            kana1.SMTP_ADDR = '';
            t_kna1_list.add(kana1);

            List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV> t_knvv_list = new List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV>();
            IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV knvv  = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV();
            knvv.KUNNR = '';
            knvv.VKORG = '';
            knvv.VTWEG = '';
            knvv.SPART = '';
            knvv.BZIRK = '';
            knvv.VKBUR = '';
            knvv.VKGRP = '';
            knvv.KDGRP = '';
            knvv.WAERS = '';
            knvv.INCO1 = '';
            knvv.ZTERM = '';
            knvv.KTGRD = '';
            knvv.VSBED = '';
            knvv.AUFSD = '';
            t_knvv_list.add(knvv);

            List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP> t_knvp_list = new List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP>();
            IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP knvp  = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP();
            knvp.KUNNR = '';
            knvp.VKORG = '';
            knvp.VTWEG = '';
            knvp.SPART = '';
            knvp.PARVW = '';
            knvp.VTEXT = '';
            knvp.KUNN2 = '';
            knvp.KNREF = '';
            knvp.DEFPA = '';
            t_knvp_list.add(knvp);

            method.IF_ACCOUNT_005(request);


            Test.stopTest();
        }

        @IsTest
        static void IF_ACCOUNT_006_TEST(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-006', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_006_Req request  = new IF_ERP_Account_Classes.IF_ACCOUNT_006_Req();   
            IF_ERP_Account_Classes.IF_ACCOUNT_006_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_006_Res();
            
            response.O_RECODE = '';
            response.O_REMSG = '';

            request.I_KUNNR = '';
            request.I_ANRED = '';
            request.I_STCD1 = '';
            request.I_STCD2 = '';
            request.I_STCD3 = '';
            request.I_LZONE = '';
            request.I_J_1KFTBUS = '';
            request.I_J_1KFTIND = '';
            request.I_KTONR = '';
            request.I_VKBUR = '';
            request.I_BZIRK = '';
            request.I_WAERS = '';
            request.I_INCO1 = '';
            request.I_INCO2 = '';
            request.I_VSBED = '';
            request.I_TAXKD = '';
            request.I_KDGRP = '';
            request.I_ZTERM = '';
            request.I_KTGRD = '';
            request.I_KTONR1 = '';
            request.I_KTONR2 = '';
            request.I_KTONR3 = '';
            request.I_KTONR4 = '';
            request.I_KTONR5 = '';
            request.I_KTONR6 = '';
            request.I_VKORG = '';
            request.I_VTWEG = '';
            request.I_SPART = '';
            request.I_DEALER = '';
            request.I_SPRAS = '';
            request.I_TAXNUMBER4 = '';
            request.I_REGION = '';
            request.I_BUTYP = '';
            request.I_BUCOD = '';
            request.I_APPROVE_CHK = '';
            request.I_KALKS = '';
            request.I_J_1KFREPRE = '';            
            
                     
            method.IF_ACCOUNT_006(request);
            Test.stopTest();
        }


        @IsTest    
        static void IF_ACCOUNT_012_Test(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-012', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_012_Req request = new IF_ERP_Account_Classes.IF_ACCOUNT_012_Req();
            request.I_ANRED = '';
            request.I_NAME1 = '';
            request.I_NAME3 = '';
            request.I_SORT1 = '';
            request.I_LOCATION = '';
            request.I_COUNTRY = '';
            request.I_REGION = '';
            request.I_PSTLZ = '';
            request.I_STREET = '';
            request.I_CITY1 = '';
            request.I_TEL_NUMBER = '';
            request.I_MOB_NUMBER = '';
            request.I_FAX_NUMBER = '';
            request.I_SMTP_ADDR = '';
            request.I_JMZAH = '';
            request.I_JMJAH = '';
            request.I_KATR1 = '';
            request.I_KATR2 = '';
            request.I_KATR3 = '';
            request.I_J_1KFTBUS = '';
            request.I_J_1KFTIND = '';
            request.I_VKBUR = '';
            request.I_BZIRK = '';
            request.I_TAXNUMBER1 = '';
            request.I_KTONR = '';
            request.I_VKORG = '';
            request.I_VTWEG = '';
            request.I_SPART = '';
            request.I_DEALER = '';
            request.I_SPRAS = '';
            request.I_TAXNUMBER4 = '';
            request.I_EMAIL = '';
            request.I_VSBED = '';
            request.I_INCO1 = '';
            request.I_INCO2 = '';
            request.I_ZTERM = '';
            request.I_KTGRD = '';
            request.I_TAXKD_CN = '';
            request.I_TAXKD_KR = '';
            request.I_NAME = '';
            request.I_PLTYP = '';
            request.I_KATR5 = '';
            request.I_WAERS = '';
            request.I_NAME_CO = '';
            request.I_STR_SUPPL1 = '';

            List<IF_ERP_Account_Classes.IF_ACCOUNT_012_Res_ET_DATA> et_data  = new List<IF_ERP_Account_Classes.IF_ACCOUNT_012_Res_ET_DATA>(); 
            IF_ERP_Account_Classes.IF_ACCOUNT_012_Res_ET_DATA       data     = new IF_ERP_Account_Classes.IF_ACCOUNT_012_Res_ET_DATA();
            data.KUNNR_ZI = ''; 
            data.NAME1_ZI = ''; 
            data.KUNNR = ''; 
            data.NAME1 = ''; 
            data.TELF1 = ''; 
            data.TELF2 = ''; 
            data.TELFX = ''; 
            data.KNURL = ''; 
            data.VKORG = ''; 
            data.VTWEG = ''; 
            data.SPART = ''; 
            data.LAND1 = ''; 
            data.KTOKD = ''; 
            data.ERDAT = ''; 
            data.ERZET = ''; 
            et_data.add(data);


            IF_ERP_Account_Classes.IF_ACCOUNT_012_Res               response = new IF_ERP_Account_Classes.IF_ACCOUNT_012_Res();
            response.O_RECODE = '';
            response.O_REMSG = '';
            response.O_KUNNR = '';
            response.O_DUP = '';
            method.IF_ACCOUNT_012(request);
            
            Test.stopTest();
        }

        @IsTest
        static void IF_ACCOUNT_013_TEST(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-013', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_013_Req request  = new IF_ERP_Account_Classes.IF_ACCOUNT_013_Req();
            IF_ERP_Account_Classes.IF_ACCOUNT_013_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_013_Res();
            request.I_KUNNR = '';
            request.I_ANRED = '';
            request.I_NAME1 = '';
            request.I_NAME3 = '';
            request.I_SORT1 = '';
            request.I_LOCATION = '';
            request.I_COUNTRY = '';
            request.I_REGION = '';
            request.I_PSTLZ = '';
            request.I_STREET = '';
            request.I_CITY1 = '';
            request.I_STR_SUPPL1 = '';
            request.I_TEL_NUMBER = '';
            request.I_MOB_NUMBER = '';
            request.I_FAX_NUMBER = '';
            request.I_SMTP_ADDR = '';
            request.I_JMZAH = '';
            request.I_JMJAH = '';
            request.I_KATR1 = '';
            request.I_KATR2 = '';
            request.I_KATR3 = '';
            request.I_J_1KFTBUS = '';
            request.I_J_1KFTIND = '';
            request.I_VKBUR = '';
            request.I_BZIRK = '';
            request.I_TAXNUMBER1 = '';
            request.I_KTONR = '';
            request.I_VKORG = '';
            request.I_VTWEG = '';
            request.I_SPART = '';
            request.I_DEALER = '';
            request.I_SPRAS = '';
            request.I_TAXNUMBER4 = '';
            request.I_EMAIL = '';
            request.I_NAME = '';
            request.I_WAERS = '';            

            response.O_RECODE = '';
            response.O_REMSG = '';            
            method.IF_ACCOUNT_013(request);

            Test.stopTest(); 

        }


        @IsTest
        static void IF_ACCOUNT_014_TEST(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-014', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_014_Req request  = new IF_ERP_Account_Classes.IF_ACCOUNT_014_Req();
            IF_ERP_Account_Classes.IF_ACCOUNT_014_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_014_Res();
            
            request.I_NAME1 = '';
            request.I_J_1KFREPRE = '';         
            
            response.O_RECODE = '';
            response.O_REMSG = '';
            response.O_RETURN = '';     

            IF_ERP_Account_Classes.IF_ACCOUNT_014_Res_T_KNA1 t_kna1 = new IF_ERP_Account_Classes.IF_ACCOUNT_014_Res_T_KNA1();           
            t_kna1.KUNNR = '';
            t_kna1.NAME1 = '';
            t_kna1.ORT01 = '';
            t_kna1.STRAS = '';
            t_kna1.LAND1 = '';
            t_kna1.LANDX = '';
            t_kna1.ERNAM = '';
            t_kna1.ERDAT = '';
            t_kna1.KTOKD = '';
            t_kna1.KDGRP = '';
            t_kna1.KTEXT = '';
            t_kna1.ANRED = '';
            t_kna1.LOCATION = '';
            t_kna1.REGIO = '';
            t_kna1.SORTL = '';
            t_kna1.NAME3 = '';
            t_kna1.PSTLZ = '';
            t_kna1.TELF1 = '';
            t_kna1.TELF2 = '';
            t_kna1.TELFX = '';
            t_kna1.KNURL = '';
            t_kna1.KATR1 = '';
            t_kna1.VTEXT1 = '';
            t_kna1.KATR2 = '';
            t_kna1.VTEXT2 = '';
            t_kna1.KATR3 = '';
            t_kna1.VTEXT3 = '';
            t_kna1.STCD1 = '';
            t_kna1.STCD2 = '';
            t_kna1.J_1KFTBUS = '';
            t_kna1.J_1KFTIND = '';
            t_kna1.JMZAH = '';
            t_kna1.JMJAH = '';
            t_kna1.BZIRK = '';
            t_kna1.BZTXT = '';
            t_kna1.VKBUR = '';
            t_kna1.BEZEI = '';
            t_kna1.KTONR = '';
            t_kna1.NAME22 = '';
            t_kna1.VSBED = '';
            t_kna1.VTEXT4 = '';
            t_kna1.VKORG = '';
            t_kna1.VTEXT5 = '';
            t_kna1.VTWEG = '';
            t_kna1.VTEXT6 = '';
            t_kna1.SPART = '';
            t_kna1.VTEXT7 = '';
            t_kna1.MDLNM = '';
            t_kna1.MATNR = '';
            t_kna1.MAKTX = '';
            t_kna1.MEINS = '';
            t_kna1.ADRNR = '';
            t_kna1.FLAG = '';
            t_kna1.STCD4 = '';
            t_kna1.SATNR = '';
            t_kna1.AUFSD = '';
            t_kna1.J_1KFREPRE = '';
            t_kna1.VBELN = '';
            t_kna1.WADAT_IST = '';
            t_kna1.VRKME = '';
            t_kna1.LFIMG = '';
            t_kna1.TOTAL_LFIMG = '';
            t_kna1.ZSEXTEN = '';
            t_kna1.ZMESSAGE = '';
            t_kna1.STCD3 = '';
            t_kna1.KONZS = '';
            t_kna1.NAME_GR = '';
            t_kna1.KATR10 = '';
            t_kna1.VTEXT10 = '';
            t_kna1.KATR20 = '';
            t_kna1.VTEXT20 = '';
            t_kna1.KATR30 = '';
            t_kna1.VTEXT30 = '';
            t_kna1.GKAM_M = '';
            t_kna1.ZTURNOVER = '';
            t_kna1.ZEMPL = '';
            t_kna1.ZPRESI = '';
            t_kna1.ZYEAR = '';
            t_kna1.ZHEADQ = '';
            t_kna1.ZVOL = '';
            t_kna1.ZPROD = '';
            t_kna1.ZBUYER = '';
            t_kna1.ZWEBPAGE = '';
            t_kna1.REGIO_T = '';
            t_kna1.SMTP_ADDR = '';
            method.IF_ACCOUNT_014(request);
            Test.stopTest(); 
        }

        @IsTest
        static void IF_ACCOUNT_015_TEST(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-015', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_015_Req_I_BASIC ibasic   = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Req_I_BASIC(); 
            ibasic.STCD1 = '';
            ibasic.NAME1 = '';
            ibasic.NAME3 = '';
            ibasic.NAME2 = '';
            ibasic.NAME4 = '';
            ibasic.SMTP_ADDR = '';
            ibasic.COUNTRY = '';
            ibasic.POST_CODE1 = '';
            ibasic.CITY1 = '';
            ibasic.REGION = '';
            ibasic.COUNC = '';
            ibasic.STREET = '';
            ibasic.STR_SUPPL1 = '';
            ibasic.NAME_CO = '';
            ibasic.TRANSPZONE = '';
            ibasic.TEL_NUMBER = '';
            ibasic.MOB_NUMBER = '';
            ibasic.FAX_NUMBER = '';
            ibasic.KUNNR = '';
            ibasic.BRAN1 = '';

            IF_ERP_Account_Classes.IF_ACCOUNT_015_I_USERINFO iuserinfo = new IF_ERP_Account_Classes.IF_ACCOUNT_015_I_USERINFO();  
            iuserinfo.BNAME = '';
            iuserinfo.RNAME = '';
            iuserinfo.HIER = '';
            iuserinfo.KUNNR = '';
            iuserinfo.LIFNR = '';
            iuserinfo.VKORG = '';
            iuserinfo.VTWEG = '';
            iuserinfo.SPART = '';
            iuserinfo.WERKS = '';
            iuserinfo.ARBPL = '';
            iuserinfo.PARNR = '';
            iuserinfo.ENAME = '';
            iuserinfo.KUNN2 = '';
            iuserinfo.LAND1 = '';
            iuserinfo.LGORT = '';
            iuserinfo.DF_CHK = '';
            iuserinfo.CO_CHK = '';                       
            IF_ERP_Account_Classes.IF_ACCOUNT_015_Req request = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Req();
            request.I_CHECK = '';
            request.I_CUSTOMER_TYPE = '';
            request.I_WAERS = '';
            request.I_USERINFO = iuserinfo;
            request.I_BASIC = ibasic;


            IF_ERP_Account_Classes.IF_ACCOUNT_015_Res_O_RETURN oReturn = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Res_O_RETURN();
            oReturn.TYPE = '';
            oReturn.CODE = '';
            oReturn.MESSAGE = '';            
            IF_ERP_Account_Classes.IF_ACCOUNT_015_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Res();
            response.O_PERSON = '';
            response.O_RETURN = oReturn;
            method.IF_ACCOUNT_015(request);
            Test.stopTest(); 
        }


        @IsTest
        static void IF_ACCOUNT_016_test(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-016', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_016_Req request = new IF_ERP_Account_Classes.IF_ACCOUNT_016_Req();
            IF_ERP_Account_Classes.IF_ACCOUNT_016_Req_I_USERINFO req_I_USERINFO = new IF_ERP_Account_Classes.IF_ACCOUNT_016_Req_I_USERINFO();            
            req_I_USERINFO.BNAME = '';
            req_I_USERINFO.RNAME = '';
            req_I_USERINFO.HIER = '';
            req_I_USERINFO.KUNNR = '';
            req_I_USERINFO.LIFNR = '';
            req_I_USERINFO.VKORG = '';
            req_I_USERINFO.VTWEG = '';
            req_I_USERINFO.SPART = '';
            req_I_USERINFO.WERKS = '';
            req_I_USERINFO.ARBPL = '';
            req_I_USERINFO.PARNR = '';
            req_I_USERINFO.ENAME = '';
            req_I_USERINFO.KUNN2 = '';
            req_I_USERINFO.LAND1 = '';
            req_I_USERINFO.LGORT = '';
            req_I_USERINFO.DF_CHK = '';
            req_I_USERINFO.CO_CHK = '';

            request.I_KUNNR = '';
            request.I_NAME1 = '';
            request.I_CUSTOMER_TYPE = '';
            request.I_LANGU    = '';
            request.I_USERINFO = req_I_USERINFO;

            method.IF_ACCOUNT_016(request);


            IF_ERP_Account_Classes.IF_ACCOUNT_016_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_016_Res();
            IF_ERP_Account_Classes.IF_ACCOUNT_016_Res_O_RETURN res_reeturn = new IF_ERP_Account_Classes.IF_ACCOUNT_016_Res_O_RETURN();
            res_reeturn.TYPE = '';
            res_reeturn.CODE = '';
            res_reeturn.MESSAGE = '';


            List<IF_ERP_Account_Classes.IF_ACCOUNT_016_Res_T_LIST> t_list = new List<IF_ERP_Account_Classes.IF_ACCOUNT_016_Res_T_LIST>(); 
            IF_ERP_Account_Classes.IF_ACCOUNT_016_Res_T_LIST item = new IF_ERP_Account_Classes.IF_ACCOUNT_016_Res_T_LIST();  
            item.KUNNR = '';
            item.NAME1 = '';
            item.NAME3 = '';
            item.NAME2X = '';
            item.NAME4 = '';
            item.STCD1 = '';
            item.CITY1 = '';
            item.REGION = '';
            item.COUNTRY = '';
            item.POST_CODE1 = '';
            item.STREET = '';
            item.STR_SUPPL1 = '';
            item.COUNC = '';
            item.TRANSPZONE = '';
            item.TEL_NUMBER = '';
            item.FAX_NUMBER = '';
            item.MOB_NUMBER = '';
            item.SMTP_ADDR = '';
            item.NAME_CO = '';
            item.REGIO_TEXT = '';
            item.LAND1_TEXT = '';
            item.KUNNR2 = '';
            item.NAME2 = '';
            item.STATUS = '';
            item.BRAN1 = '';
            item.TERRITORY_TX = '';


            Test.stopTest(); 
        }


        @IsTest
        static void IF_ACCOUNT_017_TEST(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-017', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_017_Req request  = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Req();
            request.I_FROMDATE = '';
            request.I_TODATE = '';


            IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_O_RETURN O_RETURN = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_O_RETURN();
            O_RETURN.TYPE = '';
            O_RETURN.CODE = '';
            O_RETURN.MESSAGE = '';            

            IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST T_LIST     = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST();
            T_LIST.MANDT = '';
            T_LIST.VKORG = '';
            T_LIST.VTWEG = '';
            T_LIST.SPART = '';
            T_LIST.KUNNR = '';
            T_LIST.NAME1 = '';
            T_LIST.KVGR4 = '';
            T_LIST.DATBI = '';
            T_LIST.DATAB = '';

            IF_ERP_Account_Classes.IF_ACCOUNT_017_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Res();
            response.O_RETURN = O_RETURN;
            response.T_LIST   = new List<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST>{T_LIST};
       
            method.IF_ACCOUNT_017(request);
            Test.stopTest(); 
        }

       @IsTest
        static void IF_ACCOUNT_018_TEST(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-018', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_018_Req request  = new IF_ERP_Account_Classes.IF_ACCOUNT_018_Req();
            request.I_KUNNR = '';
            request.I_PLTYP = '';
            request.I_KALKS = '';
            request.I_VKORG = '';
            request.I_VTWEG = '';
            request.I_SPART = '';
            request.I_BZIRK = '';
            request.I_VKBUR = '';
            request.I_KDGRP = '';
            request.I_WAERS = '';
            request.I_INCO1 = '';
            request.I_ZTERM = '';
            request.I_KTGRD = '';
            request.I_VSBED = '';
            request.I_TAXKD_01 = '';
            request.I_TAXKD_02 = '';
            request.I_KVGR1 = '';
            request.I_KVGR2 = '';
            request.I_KVGR3 = '';
            request.I_KVGR5 = '';
            request.I_VWERK = '';
            
            IF_ERP_Account_Classes.IF_ACCOUNT_018_Res_OT_RETURN OT_RETURN = new IF_ERP_Account_Classes.IF_ACCOUNT_018_Res_OT_RETURN();
            OT_RETURN.TYPE = '';
            OT_RETURN.CODE = '';
            OT_RETURN.MESSAGE = '';

            IF_ERP_Account_Classes.IF_ACCOUNT_018_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_018_Res();
            response.O_KUNNR = '';
            response.OT_RETURN = new List<IF_ERP_Account_Classes.IF_ACCOUNT_018_Res_OT_RETURN>{OT_RETURN};   

            method.IF_ACCOUNT_018(request);
            Test.stopTest(); 
        }

        @IsTest
        static void IF_ACCOUNT_019_TEST(){
            InterfaceCommonUtil.setInterface('IF-ACCOUNT-019', className);
            Test.startTest();
            IF_ERP_Account method = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_019_Req request  = new IF_ERP_Account_Classes.IF_ACCOUNT_019_Req();
            request.I_KUNNR = '';
            request.I_VSBED = '';

            IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_AREA I_SALES_AREA = 
                new IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_AREA(); 
                I_SALES_AREA.VKORG = '';
                I_SALES_AREA.VTWEG = '';
                I_SALES_AREA.SPART = '';                
            IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_DETAIL I_SALES_DETAIL = 
                new IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_DETAIL();
                I_SALES_DETAIL.KALKS = '';
                I_SALES_DETAIL.BZIRK = '';
                I_SALES_DETAIL.VKBUR = '';
                I_SALES_DETAIL.KDGRP = '';
                I_SALES_DETAIL.WAERS = '';

            IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_BILLING I_BILLING =
                new IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_BILLING(); 
                I_BILLING.INCO1 = '';
                I_BILLING.INCO2 = '';
                I_BILLING.ZTERM = '';
                I_BILLING.KTGRD = '';
                I_BILLING.TAXKD_01 = '';
                I_BILLING.TAXKD_02 = '';                
            
            IF_ERP_Account_Classes.IF_ACCOUNT_019_Res_O_RETURN OT_RETURN = 
                new IF_ERP_Account_Classes.IF_ACCOUNT_019_Res_O_RETURN();
            OT_RETURN.TYPE = '';
            OT_RETURN.CODE = '';
            OT_RETURN.MESSAGE = '';

            IF_ERP_Account_Classes.IF_ACCOUNT_019_Res response = new IF_ERP_Account_Classes.IF_ACCOUNT_019_Res();
            response.O_KUNNR = '';

            method.IF_ACCOUNT_019(request);
            Test.stopTest(); 
        }
}