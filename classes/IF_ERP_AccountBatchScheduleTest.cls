@IsTest
public with sharing class IF_ERP_AccountBatchScheduleTest {
    public IF_ERP_AccountBatchScheduleTest() {}


    public with sharing class IF_ERP_AccountBatchSchedule_HttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String resbody = '{"T_KNVV":[{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001329992","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"}],"T_KNVP":[{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329992","KUNN2":"0001227169","KNREF":"","DEFPA":""}],"T_KNA1":[{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-12","STRAS":"768 East 5th Street","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"New York","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"0117Prospect","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329992","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"0117Repres","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288855"}],"O_REMSG":"Successfully finished.","O_RECODE":"S","O_COUNT":"20","O_BOBAI":""}';
            res.setBody(resBody);
            res.setStatusCode(200);
            return res;
        }      
    }


    @IsTest
    static void accountBatchSchedule(){
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-005', 'IF_ERP_AccountBatchSchedule');
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        String jobName = 'AccountBatchSchedule';
        String jobId = System.schedule(jobName, cronExp, new IF_ERP_AccountBatchSchedule());
        Test.stopTest();
    }
}