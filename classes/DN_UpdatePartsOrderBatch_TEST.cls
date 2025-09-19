@isTest
public with sharing class DN_UpdatePartsOrderBatch_TEST {
    
    @TestSetup
    static void makeData(){
        Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('IF-PARTS-013', 'Real-Time');
        insert ifObj;

        List<InterfaceClasses__c> ifClassList = new List<InterfaceClasses__c>();
        InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_ERP_Parts_Order', ifObj.Id);
        ifClassList.add(ifClass);

        insert ifClassList;

        List<Product2> partList = new List<Product2>();
        Product2 orderPart = TestDataFactoryForDealerPortal.getPart('Test_Parts', '영문', '국문');
        partList.add(orderPart);

        Product2 orderPart2 = TestDataFactoryForDealerPortal.getPart('Test_Parts2', '영문', '국문');
        partList.add(orderPart2);

        insert partList;

        List<PurchaseOrder__c> poList = new List<PurchaseOrder__c>();
        DateTime now = System.now();
        PurchaseOrder__c po = new PurchaseOrder__c(
            PartOrderNo__c = 'PO12345',
            CreatedDate = now.addMonths(-2)
        );
        poList.add(po);

        PurchaseOrder__c po2 = new PurchaseOrder__c(
            PartOrderNo__c = 'PO12456'
        );
        poList.add(po2);
        insert poList;

        List<PurchaseOrderItems__c> itemList = new List<PurchaseOrderItems__c>();
        PurchaseOrderItems__c item = new PurchaseOrderItems__c(
            ItemNo__c = '10',
            PurchaseOrder__c = po.Id,
            Quantity__c = 100,
            SupplyPartNo__c = orderPart.ProductCode,
            OrderPartNo__c = orderPart.ProductCode
        );
        itemList.add(item);

        PurchaseOrderItems__c item2 = new PurchaseOrderItems__c(
            ItemNo__c = '20',
            PurchaseOrder__c = po.Id,
            Quantity__c = 10,
            SupplyPartNo__c = orderPart2.ProductCode,
            OrderPartNo__c = orderPart2.ProductCode
        );
        itemList.add(item2);

        PurchaseOrderItems__c item3 = new PurchaseOrderItems__c(
            ItemNo__c = '10',
            PurchaseOrder__c = po2.Id,
            Quantity__c = 10,
            SupplyPartNo__c = orderPart2.ProductCode,
            OrderPartNo__c = orderPart2.ProductCode
        );
        itemList.add(item3);
        insert itemList;
    }

    @isTest
    static void execute_Partition_TEST() {
        String resBody = '{"O_MESG":"Successfully finished.[ZSS90101]","O_COUNT":"3","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}],"T_DETAIL":[{"MATNR_SH":"Test_Parts","ETENR":"0001","SH_QTY":"30.000","RE_QTY":"0.000","STB_QTY":"40.000","VBELN":"PO12345","FST_ETD":"2025-03-26","PI_QTY":"30.000","MAKTX":"CENTER,LIVE","SO_QTY":"100.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"0000-00-00","EMERC":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"30.000","POSNR":"10","AUART":"YDOR","POSNR_H":"10","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"Test_Parts","AUART_T":"Dom Ordinary Order","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"Test_Parts","ETENR":"0001","SH_QTY":"30.000","RE_QTY":"0.000","STB_QTY":"40.000","VBELN":"PO12345","FST_ETD":"2025-03-26","PI_QTY":"30.000","MAKTX":"CENTER,LIVE","SO_QTY":"100.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"2025-05-14","EMERC":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"30.000","POSNR":"10","AUART":"YDOR","POSNR_H":"10","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"Test_Parts","AUART_T":"Dom Ordinary Order","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"Test_Parts2","ETENR":"0001","SH_QTY":"10.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"PO12345","FST_ETD":"2025-03-26","PI_QTY":"10.000","MAKTX":"CENTER,LIVE","SO_QTY":"10.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"2025-05-14","EMERC":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"10.000","POSNR":"20","AUART":"YDOR","POSNR_H":"20","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"Test_Parts2","AUART_T":"Dom Ordinary Order","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"}]}';
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_013_HttpMock(resBody));
        Test.startTest();

        Database.executeBatch(new DN_UpdatePartsOrderBatch());

        Test.stopTest();
    }

    @isTest
    static void execute_Complete_TEST() {
        String resBody = '{"O_MESG":"Successfully finished.[ZSS90101]","O_COUNT":"4","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}],"T_DETAIL":[{"MATNR_SH":"Test_Parts","ETENR":"0001","SH_QTY":"30.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"PO12345","FST_ETD":"2025-03-26","PI_QTY":"30.000","MAKTX":"CENTER,LIVE","SO_QTY":"100.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"0000-00-00","EMERC":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"30.000","POSNR":"10","AUART":"YDOR","POSNR_H":"10","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"Test_Parts","AUART_T":"Dom Ordinary Order","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"Test_Parts","ETENR":"0001","SH_QTY":"30.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"PO12345","FST_ETD":"2025-03-26","PI_QTY":"30.000","MAKTX":"CENTER,LIVE","SO_QTY":"100.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"2025-05-12","EMERC":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"30.000","POSNR":"10","AUART":"YDOR","POSNR_H":"10","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"Test_Parts","AUART_T":"Dom Ordinary Order","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"Test_Parts","ETENR":"0001","SH_QTY":"40.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"PO12345","FST_ETD":"2025-03-26","PI_QTY":"40.000","MAKTX":"CENTER,LIVE","SO_QTY":"100.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"2025-05-14","EMERC":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"40.000","POSNR":"10","AUART":"YDOR","POSNR_H":"10","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"Test_Parts","AUART_T":"Dom Ordinary Order","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"},{"MATNR_SH":"Test_Parts2","ETENR":"0001","SH_QTY":"10.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"PO12456","FST_ETD":"2025-03-26","PI_QTY":"10.000","MAKTX":"CENTER,LIVE","SO_QTY":"10.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"포탈250324_고객사","DODAT":"2025-05-14","EMERC":"","AUDAT":"2025-03-24","ERDAT":"2025-03-24","VSTEL":"1846","CFM_QTY":"10.000","POSNR":"10","AUART":"YDOR","POSNR_H":"10","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"Test_Parts2","AUART_T":"Dom Ordinary Order","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"28"}]}';
        Test.setMock(HttpCalloutMock.class, new IF_PARTS_013_HttpMock(resBody));
        Test.startTest();

        Database.executeBatch(new DN_UpdatePartsOrderBatch());

        Test.stopTest();
    }


    public class IF_PARTS_013_HttpMock implements HttpCalloutMock {
        String resBody;
        public IF_PARTS_013_HttpMock(String resBody){
            this.resBody = resBody;
        }

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = resBody;

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
}