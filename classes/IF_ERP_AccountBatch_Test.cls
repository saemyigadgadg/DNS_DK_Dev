@IsTest
    public with sharing class IF_ERP_AccountBatch_Test {
        public IF_ERP_AccountBatch_Test() {}
    
        
        public class IF_ACCOUNT_005_Schedule_HttpMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setStatusCode(200);
                
                String resBody = '{"T_KNVV":[{"ZTERM":"","WAERS":"KRW","VTWEG":"10","VSBED":"","VKORG":"1800","VKGRP":"","VKBUR":"","SPART":"40","KUNNR":"0001329992","KTGRD":"","KDGRP":"01","INCO1":"","BZIRK":"","AUFSD":"X"}],"T_KNVP":[{"VTWEG":"10","VTEXT":"Related Dealer","VKORG":"1800","SPART":"40","PARVW":"ZI","KUNNR":"0001329992","KUNN2":"0001227169","KNREF":"","DEFPA":""}],"T_KNA1":[{"ZYEAR":"","ZWEBPAGE":"","ZVOL":"","ZTURNOVER":"","ZSEXTEN":"","ZPROD":"","ZPRESI":"","ZMESSAGE":"","ZHEADQ":"","ZEMPL":"","ZBUYER":"","WADAT_IST":"0000-00-00","VTWEG":"10","VTEXT7":"","VTEXT6":"","VTEXT5":"","VTEXT4":"","VTEXT30":"","VTEXT3":"","VTEXT20":"","VTEXT2":"","VTEXT10":"","VTEXT1":"","VSBED":"","VRKME":"","VKORG":"1800","VKBUR":"","VBELN":"","TOTAL_LFIMG":"0.000","TELFX":"","TELF2":"","TELF1":"12-12","STRAS":"768 East 5th Street","STCD4":"","STCD3":"","STCD2":"","STCD1":"","SPART":"40","SORTL":"","SMTP_ADDR":"","SATNR":"","REGIO_T":"","REGIO":"","PSTLZ":"","ORT01":"New York","NAME_GR":"","NAME3":"","NAME2":null,"NAME1":"0117Prospect","MEINS":"","MDLNM":"","MATNR":"","MAKTX":"","LOCATION":"","LFIMG":"0.000","LANDX":"Thailand","LAND1":"TH","KUNNR":"1329992","KTONR":"","KTOKD":"1090","KTEXT":"잠재고객","KONZS":"","KNURL":"","KDGRP":"01","KATR30":"","KATR3":"","KATR20":"","KATR2":"","KATR10":"","KATR1":"","JMZAH":"000000","JMJAH":"0000","J_1KFTIND":"","J_1KFTBUS":"","J_1KFREPRE":"0117Repres","GKAM_M":"","FLAG":"","ERNAM":"EAICOM","ERDAT":"2025-01-17","BZTXT":"","BZIRK":"","BEZEI":"","AUFSD":"X","ANRED":"","ADRNR":"0003288855"}],"O_REMSG":"Successfully finished.","O_RECODE":"S","O_COUNT":"20","O_BOBAI":""}';
                
                res.setBody(resBody);
                return res;
            }
        }


        @IsTest 
        static void accountBatchTest(){
            Interface__c ifObj      = new Interface__c();
            
            ifObj.Name              = 'IF-ACCOUNT-005';
            ifObj.IsActive__c       = true;
            ifObj.HttpMethod__c     = 'POST';
            ifObj.EndpointURL__c    = 'http://temp';
            ifObj.System__c         = 'ERP';
            ifObj.ContentType__c    = 'application/x-www-form-urlencoded';
            ifObj.Timeout__c        = 120000;

            insert ifObj;

            interfaceClasses__c ifCls   = new interfaceClasses__c();

            ifCls.Name              = 'IF_ERP_Account';
            ifCls.Interface__c      = ifObj.Id;

            insert ifCls;

            Test.setMock(HttpCalloutMock.class, new IF_ACCOUNT_005_Schedule_HttpMock());
            Test.startTest();
    
            List<String> accountBatchTableNames = new List<String>{'KNA1'};

            for(String tableNm: accountBatchTableNames) {
                IF_ERP_AccountBatch.RequestDto requestDto = 
                new IF_ERP_AccountBatch.RequestDto('20241227','20241227');          

            IF_ERP_AccountBatch batchTest = new IF_ERP_AccountBatch(requestDto);  
            Database.executeBatch(batchTest, 50);
        }


        Test.stopTest();
    }
    @isTest
    static void testConvertToKNVP_withExistingRecord() {
        String tableNm = 'KNVP';
        String kunnr = '100001';
        String vkorg = '1000';
        String spart = '01';
        String parvw = 'AG';

        IF_Account__c existingAcc = new IF_Account__c(
            TABLE_NAME__c = tableNm,
            KUNNR__c = kunnr,
            VKORG__c = vkorg,
            VTWEG__c = '10',
            SPART__c = spart,
            PARVW__c = parvw,
            VTEXT__c = 'Sold-To Party',
            KUNN2__c = '100002',
            KNREF__c = 'ref001',
            DEFPA__c = 'X',
            IsComplete__c = true
        );
        insert existingAcc;

        IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP obj = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP();
        obj.KUNNR = kunnr;
        obj.VKORG = vkorg;
        obj.VTWEG = '10';
        obj.SPART = spart;
        obj.PARVW = parvw;
        obj.VTEXT = 'Sold-To Party';
        obj.KUNN2 = '100002';
        obj.KNREF = 'ref001';
        obj.DEFPA = 'X';

        List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP> typedList =
            new List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP>{ obj };

        List<Object> scope = ((List<Object>) ((Object) typedList));

        Test.startTest();
        IF_ERP_AccountBatch converter = new IF_ERP_AccountBatch(new IF_ERP_AccountBatch.RequestDto('',''));
        Test.stopTest();
    }

    @isTest
    static void testConvertToKNVP_withNewRecord() {
        String tableNm = 'KNVP';

        IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP obj = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP();
        obj.KUNNR = '999999';
        obj.VKORG = '9999';
        obj.VTWEG = '99';
        obj.SPART = '99';
        obj.PARVW = 'RE';
        obj.VTEXT = 'Payer';
        obj.KUNN2 = '888888';
        obj.KNREF = 'ref999';
        obj.DEFPA = 'Y';

        List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP> typedList =
            new List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP>{ obj };

        List<Object> scope = ((List<Object>) ((Object) typedList));

        Test.startTest();
        IF_ERP_AccountBatch converter = new IF_ERP_AccountBatch(new IF_ERP_AccountBatch.RequestDto('',''));
        Test.stopTest();
    }
    
    @isTest
    static void testConvertToKNVV_withNewRecord() {
        // Given
        String tableNm = 'KNVV';

        IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV obj = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV();
        obj.KUNNR = '400001';
        obj.VKORG = '4000';
        obj.VTWEG = '40';
        obj.SPART = '04';
        obj.BZIRK = '200';
        obj.VKBUR = 'VB02';
        obj.VKGRP = 'VG02';
        obj.KDGRP = 'KG02';
        obj.WAERS = 'USD';
        obj.INCO1 = 'FOB';
        obj.ZTERM = 'ZT02';
        obj.KTGRD = 'KT2';
        obj.VSBED = 'VS2';
        obj.AUFSD = 'N';

        List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV> typedList =
            new List<IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV>{ obj };

        List<Object> scope = ((List<Object>) ((Object) typedList));

        Test.startTest();
        IF_ERP_AccountBatch converter = new IF_ERP_AccountBatch(new IF_ERP_AccountBatch.RequestDto('',''));
        Test.stopTest();
    }


    @isTest
    static void ifAccountAfter(){
        IF_Account__c acc = new IF_Account__c();
        acc.KUNNR__c = 'TEST';
        insert acc; // 실제 DB에 삽입해야 Batch가 제대로 동작해
    
        List<IF_Account__c> accList = [SELECT Id, KUNNR__c FROM IF_Account__c WHERE KUNNR__c = 'TEST'];
    
        Test.startTest();
        IF_ERP_AccountAfterBatch batch = new IF_ERP_AccountAfterBatch(accList);
        Database.executeBatch(batch, 1); // 배치 사이즈 1로 작게 설정
        Test.stopTest();
    }
}