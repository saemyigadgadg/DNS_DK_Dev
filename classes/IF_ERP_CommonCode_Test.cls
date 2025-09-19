@isTest
public with sharing class IF_ERP_CommonCode_Test {
    public IF_ERP_CommonCode_Test() {}

/* Mock Classes
    */
    public class MIG_006_HttpMock implements HttpCalloutMock {
        public MIG_006_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            IF_ERP_CommonCode.IF_COMMONCODE_Res mockResponse = new IF_ERP_CommonCode.IF_COMMONCODE_Res();
        
            // T_CURRCODE 리스트 생성
            mockResponse.T_CURRCODE = new List<IF_ERP_CommonCode.T_CURRCODE>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_CURRCODE obj = new IF_ERP_CommonCode.T_CURRCODE();
                obj.MANDT = '100';
                obj.WAERS = 'KRW';
                obj.ISOCD = 'KRW';
                obj.LTEXT = 'Korean Won';
                obj.KTEXT = 'Won';
                mockResponse.T_CURRCODE.add(obj);
            }

            // T_COUNTNAM 리스트 생성
            mockResponse.T_COUNTNAM = new List<IF_ERP_CommonCode.T_COUNTNAM>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_COUNTNAM obj = new IF_ERP_CommonCode.T_COUNTNAM();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.LAND1 = 'KR';
                obj.LANDX = 'South Korea';
                obj.NATIO = 'Korean';
                obj.LANDX50 = 'Republic of Korea';
                obj.NATIO50 = 'Korean';
                obj.PRQ_SPREGT = 'Asia';
                mockResponse.T_COUNTNAM.add(obj);
            }

            // T_MTMAJCAT1 리스트 생성
            mockResponse.T_MTMAJCAT1 = new List<IF_ERP_CommonCode.T_MTMAJCAT1>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_MTMAJCAT1 obj = new IF_ERP_CommonCode.T_MTMAJCAT1();
                obj.ZCRM_INDUS = 'A00' + i;
                obj.ZCRM_INDUS_T = 'Major Category ' + i;
                mockResponse.T_MTMAJCAT1.add(obj);
            }

            // T_MTMAJCAT2 리스트 생성
            mockResponse.T_MTMAJCAT2 = new List<IF_ERP_CommonCode.T_MTMAJCAT2>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_MTMAJCAT2 obj = new IF_ERP_CommonCode.T_MTMAJCAT2();
                obj.ZCRM_INDUS = 'B00' + i;
                obj.ZCRM_INDUS_T = 'Sub Category ' + i;
                mockResponse.T_MTMAJCAT2.add(obj);
            }

            // T_SALESORG 리스트 생성
            mockResponse.T_SALESORG = new List<IF_ERP_CommonCode.T_SALESORG>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_SALESORG obj = new IF_ERP_CommonCode.T_SALESORG();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.VKORG = '1000' + i;
                obj.VTEXT = 'Sales Organization ' + i;
                mockResponse.T_SALESORG.add(obj);
            }

            // T_DISTCHNL 리스트 생성
            mockResponse.T_DISTCHNL = new List<IF_ERP_CommonCode.T_DISTCHNL>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_DISTCHNL obj = new IF_ERP_CommonCode.T_DISTCHNL();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.VTWEG = '10' + i;
                obj.VTEXT = 'Distribution Channel ' + i;
                mockResponse.T_DISTCHNL.add(obj);
            }

            // T_DIVISION 리스트 생성
            mockResponse.T_DIVISION = new List<IF_ERP_CommonCode.T_DIVISION>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_DIVISION obj = new IF_ERP_CommonCode.T_DIVISION();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.SPART = '200' + i;
                obj.VTEXT = 'Division ' + i;
                mockResponse.T_DIVISION.add(obj);
            }

            // T_INCOTERMS 리스트 생성
            mockResponse.T_INCOTERMS = new List<IF_ERP_CommonCode.T_INCOTERMS>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_INCOTERMS obj = new IF_ERP_CommonCode.T_INCOTERMS();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.INCO1 = 'CPT';
                obj.BEZEI = 'Incoterm ' + i;
                mockResponse.T_INCOTERMS.add(obj);
            }

            // T_ACCOUNTGR 리스트 생성
            mockResponse.T_ACCOUNTGR = new List<IF_ERP_CommonCode.T_ACCOUNTGR>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_ACCOUNTGR obj = new IF_ERP_CommonCode.T_ACCOUNTGR();
                obj.MANDT = '100';
                obj.KTOKD = 'AG' + i;
                obj.SPRAS = 'EN';
                obj.TXT30 = 'Account Group ' + i;
                mockResponse.T_ACCOUNTGR.add(obj);
            }

            // T_PAYTERMS 리스트 생성
            mockResponse.T_PAYTERMS = new List<IF_ERP_CommonCode.T_PAYTERMS>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_PAYTERMS obj = new IF_ERP_CommonCode.T_PAYTERMS();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.ZTERM = 'PT' + i;
                obj.ZTAGG = '30';
                obj.TEXT1 = 'Payment Terms ' + i;
                mockResponse.T_PAYTERMS.add(obj);
            }

            // T_REGION 리스트 생성
            mockResponse.T_REGION = new List<IF_ERP_CommonCode.T_REGION>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_REGION obj = new IF_ERP_CommonCode.T_REGION();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.LAND1 = 'KR';
                obj.BLAND = 'Region ' + i;
                obj.BEZEI = 'Region Description ' + i;
                mockResponse.T_REGION.add(obj);
            }

            // T_REJECTRSN 리스트 생성
            mockResponse.T_REJECTRSN = new List<IF_ERP_CommonCode.T_REJECTRSN>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_REJECTRSN obj = new IF_ERP_CommonCode.T_REJECTRSN();
                obj.ABGRU = 'RJ' + i;
                obj.BEZEI = 'Rejection Reason ' + i;
                mockResponse.T_REJECTRSN.add(obj);
            }

            // T_FIAGENCY 리스트 생성
            mockResponse.T_FIAGENCY = new List<IF_ERP_CommonCode.T_FIAGENCY>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_FIAGENCY obj = new IF_ERP_CommonCode.T_FIAGENCY();
                obj.MANDT = '100';
                obj.BUKRS = 'BU' + i;
                obj.FA_CODE = 'FA' + i;
                obj.FA_TEXT = 'Financial Agency ' + i;
                obj.ERDAT = '20240301';
                obj.ERNAM = 'User' + i;
                obj.ERZET = '120000';
                obj.AEDAT = '20240305';
                obj.AENAM = 'Admin' + i;
                obj.AEZET = '180000';
                mockResponse.T_FIAGENCY.add(obj);
            }

            // T_SALESDIS 리스트 생성
            mockResponse.T_SALESDIS = new List<IF_ERP_CommonCode.T_SALESDIS>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_SALESDIS obj = new IF_ERP_CommonCode.T_SALESDIS();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.BZIRK = 'BZ' + i;
                obj.BZTXT = 'Sales District ' + i;
                mockResponse.T_SALESDIS.add(obj);
            }

            // T_CUSTOMGR 리스트 생성
            mockResponse.T_CUSTOMGR = new List<IF_ERP_CommonCode.T_CUSTOMGR>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_CUSTOMGR obj = new IF_ERP_CommonCode.T_CUSTOMGR();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.KDGRP = 'CG' + i;
                obj.KTEXT = 'Customer Group ' + i;
                mockResponse.T_CUSTOMGR.add(obj);
            }

            // T_SALESOFF 리스트 생성
            mockResponse.T_SALESOFF = new List<IF_ERP_CommonCode.T_SALESOFF>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_SALESOFF obj = new IF_ERP_CommonCode.T_SALESOFF();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.VKBUR = 'SO' + i;
                obj.BEZEI = 'Sales Office ' + i;
                mockResponse.T_SALESOFF.add(obj);
            }

            // T_ORDERTYPE 리스트 생성
            mockResponse.T_ORDERTYPE = new List<IF_ERP_CommonCode.T_ORDERTYPE>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_ORDERTYPE obj = new IF_ERP_CommonCode.T_ORDERTYPE();
                obj.MANDT = '100';
                obj.VKORG = '1000' + i;
                obj.VTWEG = '10' + i;
                obj.SPART = '200' + i;
                obj.KDGRP = 'CG' + i;
                obj.AUART = 'OT' + i;
                obj.VBTYP = 'VB' + i;
                obj.STATUS = 'Active';
                mockResponse.T_ORDERTYPE.add(obj);
            }

            // T_ORDERTYPE2 리스트 생성
            mockResponse.T_ORDERTYPE2 = new List<IF_ERP_CommonCode.T_ORDERTYPE2>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_ORDERTYPE2 obj = new IF_ERP_CommonCode.T_ORDERTYPE2();
                obj.AUART = 'OT2' + i;
                obj.BEZEI = 'Order Type 2 ' + i;
                mockResponse.T_ORDERTYPE2.add(obj);
            }

            // T_CUSTPPRC 리스트 생성
            mockResponse.T_CUSTPPRC = new List<IF_ERP_CommonCode.T_CUSTPPRC>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_CUSTPPRC obj = new IF_ERP_CommonCode.T_CUSTPPRC();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.KALKS = 'PP' + i;
                obj.VTEXT = 'Customer Pricing ' + i;
                mockResponse.T_CUSTPPRC.add(obj);
            }

            // T_PRICELIST 리스트 생성
            mockResponse.T_PRICELIST = new List<IF_ERP_CommonCode.T_PRICELIST>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_PRICELIST obj = new IF_ERP_CommonCode.T_PRICELIST();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.PLTYP = 'PL' + i;
                obj.PTEXT = 'Price List ' + i;
                mockResponse.T_PRICELIST.add(obj);
            }

            // T_SHIPCOND 리스트 생성
            mockResponse.T_SHIPCOND = new List<IF_ERP_CommonCode.T_SHIPCOND>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_SHIPCOND obj = new IF_ERP_CommonCode.T_SHIPCOND();
                obj.MANDT = '100';
                obj.SPRAS = 'EN';
                obj.VSBED = 'SC' + i;
                obj.VTEXT = 'Shipping Condition ' + i;
                mockResponse.T_SHIPCOND.add(obj);
            }

            // T_DELPALNT 리스트 생성
            mockResponse.T_DELPALNT = new List<IF_ERP_CommonCode.T_DELPALNT>();
            for (Integer i = 1; i <= 5; i++) {
                IF_ERP_CommonCode.T_DELPALNT obj = new IF_ERP_CommonCode.T_DELPALNT();
                obj.MANDT = '100';
                obj.VKORG = '1000' + i;
                obj.VTWEG = '10' + i;
                obj.WERKS = 'PLANT' + i;
                obj.NAME1 = 'Plant Description ' + i;
                mockResponse.T_DELPALNT.add(obj);
            }
            
            String resBody = JSON.serialize(mockResponse);

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    static void IF_ERP_CommonCode_Test() {
        InterfaceCommonUtil.setInterface('MIG-006', 'IF_ERP_CommonCode');

        Test.startTest();

        IF_ERP_CommonCode.IF_COMMONCODE_Req req = new IF_ERP_CommonCode.IF_COMMONCODE_Req();

        IF_ERP_CommonCode instance = new IF_ERP_CommonCode();
        instance.MIG_006(req);

        IF_ERP_CommonCode.IF_COMMONCODE_Res mockResponse = new IF_ERP_CommonCode.IF_COMMONCODE_Res();
        
        // T_CURRCODE 리스트 생성
        mockResponse.T_CURRCODE = new List<IF_ERP_CommonCode.T_CURRCODE>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_CURRCODE obj = new IF_ERP_CommonCode.T_CURRCODE();
            obj.MANDT = '100';
            obj.WAERS = 'KRW';
            obj.ISOCD = 'KRW';
            obj.LTEXT = 'Korean Won';
            obj.KTEXT = 'Won';
            mockResponse.T_CURRCODE.add(obj);
        }

        // T_COUNTNAM 리스트 생성
        mockResponse.T_COUNTNAM = new List<IF_ERP_CommonCode.T_COUNTNAM>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_COUNTNAM obj = new IF_ERP_CommonCode.T_COUNTNAM();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.LAND1 = 'KR';
            obj.LANDX = 'South Korea';
            obj.NATIO = 'Korean';
            obj.LANDX50 = 'Republic of Korea';
            obj.NATIO50 = 'Korean';
            obj.PRQ_SPREGT = 'Asia';
            mockResponse.T_COUNTNAM.add(obj);
        }

        // T_MTMAJCAT1 리스트 생성
        mockResponse.T_MTMAJCAT1 = new List<IF_ERP_CommonCode.T_MTMAJCAT1>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_MTMAJCAT1 obj = new IF_ERP_CommonCode.T_MTMAJCAT1();
            obj.ZCRM_INDUS = 'A00' + i;
            obj.ZCRM_INDUS_T = 'Major Category ' + i;
            mockResponse.T_MTMAJCAT1.add(obj);
        }

        // T_MTMAJCAT2 리스트 생성
        mockResponse.T_MTMAJCAT2 = new List<IF_ERP_CommonCode.T_MTMAJCAT2>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_MTMAJCAT2 obj = new IF_ERP_CommonCode.T_MTMAJCAT2();
            obj.ZCRM_INDUS = 'B00' + i;
            obj.ZCRM_INDUS_T = 'Sub Category ' + i;
            mockResponse.T_MTMAJCAT2.add(obj);
        }

        // T_SALESORG 리스트 생성
        mockResponse.T_SALESORG = new List<IF_ERP_CommonCode.T_SALESORG>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_SALESORG obj = new IF_ERP_CommonCode.T_SALESORG();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.VKORG = '1000' + i;
            obj.VTEXT = 'Sales Organization ' + i;
            mockResponse.T_SALESORG.add(obj);
        }

        // T_DISTCHNL 리스트 생성
        mockResponse.T_DISTCHNL = new List<IF_ERP_CommonCode.T_DISTCHNL>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_DISTCHNL obj = new IF_ERP_CommonCode.T_DISTCHNL();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.VTWEG = '10' + i;
            obj.VTEXT = 'Distribution Channel ' + i;
            mockResponse.T_DISTCHNL.add(obj);
        }

        // T_DIVISION 리스트 생성
        mockResponse.T_DIVISION = new List<IF_ERP_CommonCode.T_DIVISION>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_DIVISION obj = new IF_ERP_CommonCode.T_DIVISION();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.SPART = '200' + i;
            obj.VTEXT = 'Division ' + i;
            mockResponse.T_DIVISION.add(obj);
        }

        // T_INCOTERMS 리스트 생성
        mockResponse.T_INCOTERMS = new List<IF_ERP_CommonCode.T_INCOTERMS>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_INCOTERMS obj = new IF_ERP_CommonCode.T_INCOTERMS();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.INCO1 = 'CPT';
            obj.BEZEI = 'Incoterm ' + i;
            mockResponse.T_INCOTERMS.add(obj);
        }

        // T_ACCOUNTGR 리스트 생성
        mockResponse.T_ACCOUNTGR = new List<IF_ERP_CommonCode.T_ACCOUNTGR>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_ACCOUNTGR obj = new IF_ERP_CommonCode.T_ACCOUNTGR();
            obj.MANDT = '100';
            obj.KTOKD = 'AG' + i;
            obj.SPRAS = 'EN';
            obj.TXT30 = 'Account Group ' + i;
            mockResponse.T_ACCOUNTGR.add(obj);
        }

        // T_PAYTERMS 리스트 생성
        mockResponse.T_PAYTERMS = new List<IF_ERP_CommonCode.T_PAYTERMS>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_PAYTERMS obj = new IF_ERP_CommonCode.T_PAYTERMS();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.ZTERM = 'PT' + i;
            obj.ZTAGG = '30';
            obj.TEXT1 = 'Payment Terms ' + i;
            mockResponse.T_PAYTERMS.add(obj);
        }

        // T_REGION 리스트 생성
        mockResponse.T_REGION = new List<IF_ERP_CommonCode.T_REGION>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_REGION obj = new IF_ERP_CommonCode.T_REGION();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.LAND1 = 'KR';
            obj.BLAND = 'Region ' + i;
            obj.BEZEI = 'Region Description ' + i;
            mockResponse.T_REGION.add(obj);
        }

        // T_REJECTRSN 리스트 생성
        mockResponse.T_REJECTRSN = new List<IF_ERP_CommonCode.T_REJECTRSN>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_REJECTRSN obj = new IF_ERP_CommonCode.T_REJECTRSN();
            obj.ABGRU = 'RJ' + i;
            obj.BEZEI = 'Rejection Reason ' + i;
            mockResponse.T_REJECTRSN.add(obj);
        }

        // T_FIAGENCY 리스트 생성
        mockResponse.T_FIAGENCY = new List<IF_ERP_CommonCode.T_FIAGENCY>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_FIAGENCY obj = new IF_ERP_CommonCode.T_FIAGENCY();
            obj.MANDT = '100';
            obj.BUKRS = 'BU' + i;
            obj.FA_CODE = 'FA' + i;
            obj.FA_TEXT = 'Financial Agency ' + i;
            obj.ERDAT = '20240301';
            obj.ERNAM = 'User' + i;
            obj.ERZET = '120000';
            obj.AEDAT = '20240305';
            obj.AENAM = 'Admin' + i;
            obj.AEZET = '180000';
            mockResponse.T_FIAGENCY.add(obj);
        }

        // T_SALESDIS 리스트 생성
        mockResponse.T_SALESDIS = new List<IF_ERP_CommonCode.T_SALESDIS>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_SALESDIS obj = new IF_ERP_CommonCode.T_SALESDIS();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.BZIRK = 'BZ' + i;
            obj.BZTXT = 'Sales District ' + i;
            mockResponse.T_SALESDIS.add(obj);
        }

        // T_CUSTOMGR 리스트 생성
        mockResponse.T_CUSTOMGR = new List<IF_ERP_CommonCode.T_CUSTOMGR>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_CUSTOMGR obj = new IF_ERP_CommonCode.T_CUSTOMGR();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.KDGRP = 'CG' + i;
            obj.KTEXT = 'Customer Group ' + i;
            mockResponse.T_CUSTOMGR.add(obj);
        }

        // T_SALESOFF 리스트 생성
        mockResponse.T_SALESOFF = new List<IF_ERP_CommonCode.T_SALESOFF>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_SALESOFF obj = new IF_ERP_CommonCode.T_SALESOFF();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.VKBUR = 'SO' + i;
            obj.BEZEI = 'Sales Office ' + i;
            mockResponse.T_SALESOFF.add(obj);
        }

        // T_ORDERTYPE 리스트 생성
        mockResponse.T_ORDERTYPE = new List<IF_ERP_CommonCode.T_ORDERTYPE>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_ORDERTYPE obj = new IF_ERP_CommonCode.T_ORDERTYPE();
            obj.MANDT = '100';
            obj.VKORG = '1000' + i;
            obj.VTWEG = '10' + i;
            obj.SPART = '200' + i;
            obj.KDGRP = 'CG' + i;
            obj.AUART = 'OT' + i;
            obj.VBTYP = 'VB' + i;
            obj.STATUS = 'Active';
            mockResponse.T_ORDERTYPE.add(obj);
        }

        // T_ORDERTYPE2 리스트 생성
        mockResponse.T_ORDERTYPE2 = new List<IF_ERP_CommonCode.T_ORDERTYPE2>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_ORDERTYPE2 obj = new IF_ERP_CommonCode.T_ORDERTYPE2();
            obj.AUART = 'OT2' + i;
            obj.BEZEI = 'Order Type 2 ' + i;
            mockResponse.T_ORDERTYPE2.add(obj);
        }

        // T_CUSTPPRC 리스트 생성
        mockResponse.T_CUSTPPRC = new List<IF_ERP_CommonCode.T_CUSTPPRC>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_CUSTPPRC obj = new IF_ERP_CommonCode.T_CUSTPPRC();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.KALKS = 'PP' + i;
            obj.VTEXT = 'Customer Pricing ' + i;
            mockResponse.T_CUSTPPRC.add(obj);
        }

        // T_PRICELIST 리스트 생성
        mockResponse.T_PRICELIST = new List<IF_ERP_CommonCode.T_PRICELIST>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_PRICELIST obj = new IF_ERP_CommonCode.T_PRICELIST();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.PLTYP = 'PL' + i;
            obj.PTEXT = 'Price List ' + i;
            mockResponse.T_PRICELIST.add(obj);
        }

        // T_SHIPCOND 리스트 생성
        mockResponse.T_SHIPCOND = new List<IF_ERP_CommonCode.T_SHIPCOND>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_SHIPCOND obj = new IF_ERP_CommonCode.T_SHIPCOND();
            obj.MANDT = '100';
            obj.SPRAS = 'EN';
            obj.VSBED = 'SC' + i;
            obj.VTEXT = 'Shipping Condition ' + i;
            mockResponse.T_SHIPCOND.add(obj);
        }

        // T_DELPALNT 리스트 생성
        mockResponse.T_DELPALNT = new List<IF_ERP_CommonCode.T_DELPALNT>();
        for (Integer i = 1; i <= 5; i++) {
            IF_ERP_CommonCode.T_DELPALNT obj = new IF_ERP_CommonCode.T_DELPALNT();
            obj.MANDT = '100';
            obj.VKORG = '1000' + i;
            obj.VTWEG = '10' + i;
            obj.WERKS = 'PLANT' + i;
            obj.NAME1 = 'Plant Description ' + i;
            mockResponse.T_DELPALNT.add(obj);
        }

        Test.stopTest();
    }
    @isTest
    static void IF_ERP_CommonCodeBatch_Test() {
        InterfaceCommonUtil.setInterface('MIG-006', 'IF_ERP_CommonCode');

        Test.startTest();

        IF_ERP_CommonCode.IF_COMMONCODE_Req req = new IF_ERP_CommonCode.IF_COMMONCODE_Req();

        IF_CommonCodeBatch batch = new IF_CommonCodeBatch(req);
        Database.executeBatch(batch);

        Test.stopTest();
    }
    
}