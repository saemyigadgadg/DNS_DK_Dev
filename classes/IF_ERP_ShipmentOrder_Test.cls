@isTest
public with sharing class IF_ERP_ShipmentOrder_Test {
    private static String className = 'IF_ERP_ShipmentOrder';

    public IF_ERP_ShipmentOrder_Test() {}

/* Mock Classes
    */
    public class IF_CSPLUS_029_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_029_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_O_SHIPPING_PART_LIST":[{"ZWARE":"ZW001","ZSPEC":"ZSPEC01","STICO":"SC002","SOBSL":"S001","SCHGT":"G001","REMAK":"Remark01","PSTYV":"PS001","PPNOF":"PP002","POSNR_VA":"VA001","POSNR":"P002","MSGTY":"Error","MSGTX":"Shipping Part Issue","MENGE":"50","MEINS":"EA","MATNR":"M002","MARKT":"Market01","MANDT":"100","MAKTX":"Item Description","LGPRO_F":"LF001","LGPRO":"LP001","ISSUE":"I001","ETTYP":"Type1","ETENR":"ET001","ERTIM":"12:00:00","ERNAM":"Admin","ERDAT":"2024-02-18","BESKZ":"Stock","BEAKZ":"B001","AETIM":"13:00:00","AENAM":"User1","AEDAT":"2024-02-19"}],"T_O_RSP_LIST":[{"ZWARE":null,"ZSPEC":"ZSPEC02","STICO":null,"SOBSL":null,"SCHGT":"G002","REMAK":null,"PSTYV":null,"PPNOF":"PP003","POSNR_VA":null,"POSNR":"P003","MSGTY":"Warning","MSGTX":"RSP Issue","MENGE":"30","MEINS":"EA","MATNR":"M003","MARKT":null,"MANDT":"100","MAKTX":null,"LGPRO_F":null,"LGPRO":null,"ISSUE":"I002","ETTYP":null,"ETENR":null,"ERTIM":null,"ERNAM":null,"ERDAT":null,"BESKZ":"Reserve","BEAKZ":null,"AETIM":null,"AENAM":null,"AEDAT":null}],"T_O_REMARK":[{"ZTEXT":"This is a remark","TDFORMAT":"PDF"}],"T_O_MATERIAL":[{"ZZFOR":"Z001","VRKME":"EA","STICO":"SC001","POSNR":"P001","MTART":"Material","MSGTY":"Info","MSGTX":"Material message","MATNR":"M001","KWMENG":"100","CUOBJ":"CO001","BESKZ":"Stock","ATWRT":"Spec1","ARKTX":"Item A"}],"T_O_MANNUAL":[{"SPRAS":"EN","SLANG":"English","SERIAL":"SR001","PPNOF":"PP001","MANULDV":"LV001","MANUL":"M001","MANDT":"100","COPIS":"CP001","BOOKN":"BK001"}],"T_O_Classification":[{"WKVALUE":"VALUE01","WKADDR":"ADDR01"}],"O_RETURN":{"TYPE":"S","MESSAGE":"Success","CODE":"200"},"O_HEADER":{"WADAT":"2024-02-17","TYPE":"ORDER","TYPBZ":"TYPE01","SERNR":"SERIAL123","ISSUE_NO":"IN001","INBDT":"2024-02-18","CONT_NO":"CN001"}}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Code
    */
    @IsTest
    static void IF_CSPLUS_029_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-029', className);
        Test.startTest();

        IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Req req = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Req();
        req.I_TYPBZ = '';
        req.I_DEL_FLAG = '';
        req.I_SERNR = '';

        IF_ERP_ShipmentOrder instance = new IF_ERP_ShipmentOrder();
        instance.IF_CSPLUS_029(req);

        // Response 객체 생성
        IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res response = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res();
        response.O_RETURN = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_RETURN();
        response.O_HEADER = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_HEADER();
        response.T_O_Classification = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_Classification>();
        response.T_O_MANNUAL = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MANNUAL>();
        response.T_O_REMARK = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_REMARK>();
        response.T_O_MATERIAL = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MATERIAL>();
        response.T_O_SHIPPING_PART_LIST = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST>();
        response.T_O_RSP_LIST = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_RSP_LIST>();

        // O_RETURN 필드 설정
        response.O_RETURN.TYPE = 'S';
        response.O_RETURN.CODE = '200';
        response.O_RETURN.MESSAGE = 'Success';

        // O_HEADER 필드 설정
        response.O_HEADER.CONT_NO = 'CN001';
        response.O_HEADER.ISSUE_NO = 'IN001';
        response.O_HEADER.TYPBZ = 'TYPE01';
        response.O_HEADER.SERNR = 'SERIAL123';
        response.O_HEADER.TYPE = 'ORDER';
        response.O_HEADER.WADAT = '2024-02-17';
        response.O_HEADER.INBDT = '2024-02-18';

        // T_O_Classification 항목 추가
        response.T_O_Classification.add(new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_Classification());
        response.T_O_Classification[0].WKADDR = 'ADDR01';
        response.T_O_Classification[0].WKVALUE = 'VALUE01';

        // T_O_MANNUAL 항목 추가
        response.T_O_MANNUAL.add(new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MANNUAL());
        response.T_O_MANNUAL[0].MANDT = '100';
        response.T_O_MANNUAL[0].MANULDV = 'LV001';
        response.T_O_MANNUAL[0].MANUL = 'M001';
        response.T_O_MANNUAL[0].BOOKN = 'BK001';
        response.T_O_MANNUAL[0].COPIS = 'CP001';
        response.T_O_MANNUAL[0].PPNOF = 'PP001';
        response.T_O_MANNUAL[0].SPRAS = 'EN';
        response.T_O_MANNUAL[0].SLANG = 'English';
        response.T_O_MANNUAL[0].SERIAL = 'SR001';

        // T_O_REMARK 항목 추가
        response.T_O_REMARK.add(new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_REMARK());
        response.T_O_REMARK[0].TDFORMAT = 'PDF';
        response.T_O_REMARK[0].ZTEXT = 'This is a remark';

        // T_O_MATERIAL 항목 추가
        response.T_O_MATERIAL.add(new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MATERIAL());
        response.T_O_MATERIAL[0].POSNR = 'P001';
        response.T_O_MATERIAL[0].MATNR = 'M001';
        response.T_O_MATERIAL[0].ARKTX = 'Item A';
        response.T_O_MATERIAL[0].ATWRT = 'Spec1';
        response.T_O_MATERIAL[0].KWMENG = '100';
        response.T_O_MATERIAL[0].VRKME = 'EA';
        response.T_O_MATERIAL[0].BESKZ = 'Stock';
        response.T_O_MATERIAL[0].CUOBJ = 'CO001';
        response.T_O_MATERIAL[0].MTART = 'Material';
        response.T_O_MATERIAL[0].ZZFOR = 'Z001';
        response.T_O_MATERIAL[0].STICO = 'SC001';
        response.T_O_MATERIAL[0].MSGTY = 'Info';
        response.T_O_MATERIAL[0].MSGTX = 'Material message';

        // T_O_SHIPPING_PART_LIST 항목 추가
        response.T_O_SHIPPING_PART_LIST.add(new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST());
        response.T_O_SHIPPING_PART_LIST[0].MANDT = '100';
        response.T_O_SHIPPING_PART_LIST[0].PPNOF = 'PP002';
        response.T_O_SHIPPING_PART_LIST[0].POSNR = 'P002';
        response.T_O_SHIPPING_PART_LIST[0].MATNR = 'M002';
        response.T_O_SHIPPING_PART_LIST[0].ZSPEC = 'ZSPEC01';
        response.T_O_SHIPPING_PART_LIST[0].MENGE = '50';
        response.T_O_SHIPPING_PART_LIST[0].MEINS = 'EA';
        response.T_O_SHIPPING_PART_LIST[0].ISSUE = 'I001';
        response.T_O_SHIPPING_PART_LIST[0].BESKZ = 'Stock';
        response.T_O_SHIPPING_PART_LIST[0].SCHGT = 'G001';
        response.T_O_SHIPPING_PART_LIST[0].POSNR_VA = 'VA001';
        response.T_O_SHIPPING_PART_LIST[0].PSTYV = 'PS001';
        response.T_O_SHIPPING_PART_LIST[0].BEAKZ = 'B001';
        response.T_O_SHIPPING_PART_LIST[0].MARKT = 'Market01';
        response.T_O_SHIPPING_PART_LIST[0].REMAK = 'Remark01';
        response.T_O_SHIPPING_PART_LIST[0].ZWARE = 'ZW001';
        response.T_O_SHIPPING_PART_LIST[0].ERNAM = 'Admin';
        response.T_O_SHIPPING_PART_LIST[0].ERDAT = '2024-02-18';
        response.T_O_SHIPPING_PART_LIST[0].ERTIM = '12:00:00';
        response.T_O_SHIPPING_PART_LIST[0].AENAM = 'User1';
        response.T_O_SHIPPING_PART_LIST[0].AEDAT = '2024-02-19';
        response.T_O_SHIPPING_PART_LIST[0].AETIM = '13:00:00';
        response.T_O_SHIPPING_PART_LIST[0].MAKTX = 'Item Description';
        response.T_O_SHIPPING_PART_LIST[0].ETENR = 'ET001';
        response.T_O_SHIPPING_PART_LIST[0].ETTYP = 'Type1';
        response.T_O_SHIPPING_PART_LIST[0].SOBSL = 'S001';
        response.T_O_SHIPPING_PART_LIST[0].LGPRO = 'LP001';
        response.T_O_SHIPPING_PART_LIST[0].LGPRO_F = 'LF001';
        response.T_O_SHIPPING_PART_LIST[0].STICO = 'SC002';
        response.T_O_SHIPPING_PART_LIST[0].MSGTY = 'Error';
        response.T_O_SHIPPING_PART_LIST[0].MSGTX = 'Shipping Part Issue';

        // T_O_RSP_LIST 항목 추가
        response.T_O_RSP_LIST.add(new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_RSP_LIST());
        response.T_O_RSP_LIST[0].MANDT = '100';
        response.T_O_RSP_LIST[0].PPNOF = 'PP003';
        response.T_O_RSP_LIST[0].POSNR = 'P003';
        response.T_O_RSP_LIST[0].MATNR = 'M003';
        response.T_O_RSP_LIST[0].ZSPEC = 'ZSPEC02';
        response.T_O_RSP_LIST[0].MENGE = '30';
        response.T_O_RSP_LIST[0].MEINS = 'EA';
        response.T_O_RSP_LIST[0].ISSUE = 'I002';
        response.T_O_RSP_LIST[0].BESKZ = 'Reserve';
        response.T_O_RSP_LIST[0].SCHGT = 'G002';
        response.T_O_RSP_LIST[0].MSGTY = 'Warning';
        response.T_O_RSP_LIST[0].MSGTX = 'RSP Issue';

        Test.stopTest();
    }
}