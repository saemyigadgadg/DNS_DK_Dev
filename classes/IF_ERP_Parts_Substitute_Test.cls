@isTest
public with sharing class IF_ERP_Parts_Substitute_Test {
    private static String className = 'IF_ERP_Parts_Substitute';

    public IF_ERP_Parts_Substitute_Test() {}

/* Mock Classes
    */
    public class IF_PARTS_004_HttpMock implements HttpCalloutMock {
        public IF_PARTS_004_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"T_ITEM":[{"COMPLAINT":"","MATERIAL_DIA":"","CUST_MAT22":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"","MATERIAL_ENT":"","UOM":"","SPEC":"","GEWEI":"","LOT_CHECK":"","BULLETIN":"","NET_PRICE":"0.00","DIEUMT":"0.000","MITEM":"X","USAGE_HILV":"","ZZEQMASTER":"","ATP_QTY":"0.000","CORE_PARTS":"0.00","MATERIAL_TEXT":"","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"","REF_ORD":"","CCHECK":"","MATERIAL":"101593-00006A","QTY":"1.000","KBETR":"0.00","ZZDEALDT":"0000-00-00","WAERS":"","LANDX":"","KSTOCK":"","IF_CURRENCY":"","ZZWORKHRS":"","KUNNR_SHIP":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"","MATERIAL_N":"","R":"","INPUT_QTY":"0.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"","REF_ITEM":"000000","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000010","SUGRD":"","STORE_LOC":"","CHEKCABLE":"","ACCEPT":"","REQ_QTY":"1.000","PLANT":"","RT_QTY":"0.000","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","DIUKL":"0.000","BO":"","HQ_QTY":"0.000","MEINS":"","MTPOS":"","MVGR5":"","BD":"","MATNR_DESIGN":"00","BULL_MATNR":"","STAWN":""},{"COMPLAINT":"","MATERIAL_DIA":"110508-04211","CUST_MAT22":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"","MATERIAL_ENT":"","UOM":"","SPEC":"","GEWEI":"","LOT_CHECK":"","BULLETIN":"","NET_PRICE":"0.00","DIEUMT":"0.000","MITEM":"","USAGE_HILV":"","ZZEQMASTER":"","ATP_QTY":"0.000","CORE_PARTS":"0.00","MATERIAL_TEXT":"","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"","REF_ORD":"","CCHECK":"","MATERIAL":"110508-04211","QTY":"1.000","KBETR":"0.00","ZZDEALDT":"0000-00-00","WAERS":"","LANDX":"","KSTOCK":"","IF_CURRENCY":"","ZZWORKHRS":"","KUNNR_SHIP":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"","MATERIAL_N":"","R":"","INPUT_QTY":"0.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"","REF_ITEM":"000000","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000020","SUGRD":"","STORE_LOC":"","CHEKCABLE":"","ACCEPT":"","REQ_QTY":"1.000","PLANT":"","RT_QTY":"0.000","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","DIUKL":"0.000","BO":"","HQ_QTY":"0.000","MEINS":"","MTPOS":"","MVGR5":"","BD":"","MATNR_DESIGN":"00","BULL_MATNR":"","STAWN":""},{"COMPLAINT":"","MATERIAL_DIA":"","CUST_MAT22":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"","MATERIAL_ENT":"","UOM":"","SPEC":"","GEWEI":"","LOT_CHECK":"","BULLETIN":"","NET_PRICE":"0.00","DIEUMT":"0.000","MITEM":"X","USAGE_HILV":"","ZZEQMASTER":"","ATP_QTY":"0.000","CORE_PARTS":"0.00","MATERIAL_TEXT":"","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"","REF_ORD":"","CCHECK":"","MATERIAL":"102501-00330S","QTY":"1.000","KBETR":"0.00","ZZDEALDT":"0000-00-00","WAERS":"","LANDX":"","KSTOCK":"","IF_CURRENCY":"","ZZWORKHRS":"","KUNNR_SHIP":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"","MATERIAL_N":"","R":"","INPUT_QTY":"0.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"","REF_ITEM":"000000","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000030","SUGRD":"","STORE_LOC":"","CHEKCABLE":"","ACCEPT":"","REQ_QTY":"1.000","PLANT":"","RT_QTY":"0.000","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","DIUKL":"0.000","BO":"","HQ_QTY":"0.000","MEINS":"","MTPOS":"","MVGR5":"","BD":"","MATNR_DESIGN":"00","BULL_MATNR":"","STAWN":""},{"COMPLAINT":"","MATERIAL_DIA":"110951-01100B","CUST_MAT22":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"","MATERIAL_ENT":"","UOM":"","SPEC":"","GEWEI":"","LOT_CHECK":"","BULLETIN":"","NET_PRICE":"0.00","DIEUMT":"0.000","MITEM":"","USAGE_HILV":"","ZZEQMASTER":"","ATP_QTY":"0.000","CORE_PARTS":"0.00","MATERIAL_TEXT":"","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"","REF_ORD":"","CCHECK":"","MATERIAL":"110951-01100B","QTY":"1.000","KBETR":"0.00","ZZDEALDT":"0000-00-00","WAERS":"","LANDX":"","KSTOCK":"","IF_CURRENCY":"","ZZWORKHRS":"","KUNNR_SHIP":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"","MATERIAL_N":"","R":"","INPUT_QTY":"0.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"","REF_ITEM":"000000","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000040","SUGRD":"","STORE_LOC":"","CHEKCABLE":"","ACCEPT":"","REQ_QTY":"1.000","PLANT":"","RT_QTY":"0.000","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","DIUKL":"0.000","BO":"","HQ_QTY":"0.000","MEINS":"","MTPOS":"","MVGR5":"","BD":"","MATNR_DESIGN":"00","BULL_MATNR":"","STAWN":""},{"COMPLAINT":"","MATERIAL_DIA":"120112-02634","CUST_MAT22":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"","MATERIAL_ENT":"","UOM":"","SPEC":"","GEWEI":"","LOT_CHECK":"","BULLETIN":"","NET_PRICE":"0.00","DIEUMT":"0.000","MITEM":"","USAGE_HILV":"","ZZEQMASTER":"","ATP_QTY":"0.000","CORE_PARTS":"0.00","MATERIAL_TEXT":"","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"","REF_ORD":"","CCHECK":"","MATERIAL":"120112-02634","QTY":"2.000","KBETR":"0.00","ZZDEALDT":"0000-00-00","WAERS":"","LANDX":"","KSTOCK":"","IF_CURRENCY":"","ZZWORKHRS":"","KUNNR_SHIP":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"","MATERIAL_N":"","R":"","INPUT_QTY":"0.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"","REF_ITEM":"000000","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000050","SUGRD":"","STORE_LOC":"","CHEKCABLE":"","ACCEPT":"","REQ_QTY":"1.000","PLANT":"","RT_QTY":"0.000","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","DIUKL":"0.000","BO":"","HQ_QTY":"0.000","MEINS":"","MTPOS":"","MVGR5":"","BD":"","MATNR_DESIGN":"00","BULL_MATNR":"","STAWN":""}]}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_PARTS_004_Test() {
        InterfaceCommonUtil.setInterface('IF-PARTS-004', className);
        
        Test.startTest();
        
        IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req req = new IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req();
        req.I_WERKS = '';
        req.T_ITEM = new List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req_T_ITEM>();
        
        IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req_T_ITEM reqItem = new IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req_T_ITEM();

        reqItem.CCHECK              = 'test';
        reqItem.ITEM                = 'test';
        reqItem.HILV                = 'test';
        reqItem.MATERIAL            = 'test';
        reqItem.MATERIAL_TEXT       = 'test';
        reqItem.QTY                 = 'test';
        reqItem.UOM                 = 'test';
        reqItem.NET_PRICE           = 'test';
        reqItem.NET_VALUE           = 'test';
        reqItem.IF_CURRENCY         = 'test';
        reqItem.AVAILABILITY        = 'test';
        reqItem.REF_ORD             = 'test';
        reqItem.REF_ITEM            = 'test';
        reqItem.COMPLAINT           = 'test';
        reqItem.COMPLAINT_DESC      = 'test';
        reqItem.PLANT               = 'test';
        reqItem.O                   = 'test';
        reqItem.C                   = 'test';
        reqItem.D                   = 'test';
        reqItem.BD                  = 'test';
        reqItem.BO                  = 'test';
        reqItem.DB                  = 'test';
        reqItem.R                   = 'test';
        reqItem.PLANT_TX            = 'test';
        reqItem.USAGE_HILV          = 'test';
        reqItem.CHEKCABLE           = 'test';
        reqItem.MATNR_CHECK         = 'test';
        reqItem.A                   = 'test';
        reqItem.REQ_QTY             = 'test';
        reqItem.LOT_QTY             = 'test';
        reqItem.STAWN               = 'test';
        reqItem.MIN_QTY             = 'test';
        reqItem.MATNR_DESIGN        = 'test';
        reqItem.REQ_QTY_DESIGN      = 'test';
        reqItem.ZZDEALDT            = 'test';
        reqItem.WAERS               = 'test';
        reqItem.REASON              = 'test';
        reqItem.INPUT_QTY           = 'test';
        reqItem.EXCEL               = 'test';
        reqItem.MVGR5               = 'test';
        reqItem.MATERIAL_ENT        = 'test';
        reqItem.MATERIAL_DIA        = 'test';
        reqItem.ERRORCHECK          = 'test';
        reqItem.ERRORMSG            = 'test';
        reqItem.SUGRD               = 'test';
        reqItem.COMPLAINT_REASON    = 'test';
        reqItem.ACCEPT              = 'test';
        reqItem.MATERIAL_N          = 'test';
        reqItem.CUST_MAT22          = 'test';
        reqItem.NETPR               = 'test';
        reqItem.DIEUCE              = 'test';
        reqItem.DIEUFL              = 'test';
        reqItem.DIUK                = 'test';
        reqItem.DIID                = 'test';
        reqItem.DI                  = 'test';
        reqItem.DIUKL               = 'test';
        reqItem.DIEUMT              = 'test';
        reqItem.MEINS               = 'test';
        reqItem.KONDM               = 'test';
        reqItem.NTGEW               = 'test';
        reqItem.GEWEI               = 'test';
        reqItem.KUNNR               = 'test';
        reqItem.KBETR               = 'test';
        reqItem.HERKL               = 'test';
        reqItem.KUNNR_SHIP          = 'test';
        reqItem.ZZAPPMACHINE        = 'test';
        reqItem.ZZEQMASTER          = 'test';
        reqItem.STORE_LOC           = 'test';
        reqItem.ZZWORKHRS           = 'test';
        reqItem.LIST_PRICE          = 'test';
        reqItem.LOT_CHECK           = 'test';
        reqItem.BULLETIN            = 'test';
        reqItem.BULL_MATNR          = 'test';
        reqItem.POUND               = 'test';
        reqItem.KSTOCK              = 'test';
        reqItem.CORE_PARTS          = 'test';
        reqItem.SPEC                = 'test';
        reqItem.TO_PART             = 'test';
        reqItem.MITEM               = 'test';
        reqItem.ATP_QTY             = 'test';
        reqItem.LANDX               = 'test';
        reqItem.MTPOS               = 'test';
        reqItem.RT_QTY              = 'test';
        reqItem.HQ_QTY              = 'test';
        req.T_ITEM.add(reqItem);
        
        IF_ERP_Parts_Substitute instance = new IF_ERP_Parts_Substitute();
        instance.IF_PARTS_004(req);
        
        IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res res = new IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res();
        res.T_ITEM = new List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM>();
        
        IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM resItem = new IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM();
        resItem.CCHECK           = 'test';
        resItem.ITEM             = 'test';
        resItem.HILV             = 'test';
        resItem.MATERIAL         = 'test';
        resItem.MATERIAL_TEXT    = 'test';
        resItem.QTY              = 'test';
        resItem.UOM              = 'test';
        resItem.NET_PRICE        = 'test';
        resItem.NET_VALUE        = 'test';
        resItem.IF_CURRENCY      = 'test';
        resItem.AVAILABILITY     = 'test';
        resItem.REF_ORD          = 'test';
        resItem.REF_ITEM         = 'test';
        resItem.COMPLAINT        = 'test';
        resItem.COMPLAINT_DESC   = 'test';
        resItem.PLANT            = 'test';
        resItem.O                = 'test';
        resItem.C                = 'test';
        resItem.D                = 'test';
        resItem.BD               = 'test';
        resItem.BO               = 'test';
        resItem.DB               = 'test';
        resItem.R                = 'test';
        resItem.PLANT_TX         = 'test';
        resItem.USAGE_HILV       = 'test';
        resItem.CHEKCABLE        = 'test';
        resItem.MATNR_CHECK      = 'test';
        resItem.A                = 'test';
        resItem.REQ_QTY          = 'test';
        resItem.LOT_QTY          = 'test';
        resItem.STAWN            = 'test';
        resItem.MIN_QTY          = 'test';
        resItem.MATNR_DESIGN     = 'test';
        resItem.REQ_QTY_DESIGN   = 'test';
        resItem.ZZDEALDT         = 'test';
        resItem.WAERS            = 'test';
        resItem.REASON           = 'test';
        resItem.INPUT_QTY        = 'test';
        resItem.EXCEL            = 'test';
        resItem.MVGR5            = 'test';
        resItem.MATERIAL_ENT     = 'test';
        resItem.MATERIAL_DIA     = 'test';
        resItem.ERRORCHECK       = 'test';
        resItem.ERRORMSG         = 'test';
        resItem.SUGRD            = 'test';
        resItem.COMPLAINT_REASON = 'test';
        resItem.ACCEPT           = 'test';
        resItem.MATERIAL_N       = 'test';
        resItem.CUST_MAT22       = 'test';
        resItem.NETPR            = 'test';
        resItem.DIEUCE           = 'test';
        resItem.DIEUFL           = 'test';
        resItem.DIUK             = 'test';
        resItem.DIID             = 'test';
        resItem.DI               = 'test';
        resItem.DIUKL            = 'test';
        resItem.DIEUMT           = 'test';
        resItem.MEINS            = 'test';
        resItem.KONDM            = 'test';
        resItem.NTGEW            = 'test';
        resItem.GEWEI            = 'test';
        resItem.KUNNR            = 'test';
        resItem.KBETR            = 'test';
        resItem.HERKL            = 'test';
        resItem.KUNNR_SHIP       = 'test';
        resItem.ZZAPPMACHINE     = 'test';
        resItem.ZZEQMASTER       = 'test';
        resItem.STORE_LOC        = 'test';
        resItem.ZZWORKHRS        = 'test';
        resItem.LIST_PRICE       = 'test';
        resItem.LOT_CHECK        = 'test';
        resItem.BULLETIN         = 'test';
        resItem.BULL_MATNR       = 'test';
        resItem.POUND            = 'test';
        resItem.KSTOCK           = 'test';
        resItem.CORE_PARTS       = 'test';
        resItem.SPEC             = 'test';
        resItem.TO_PART          = 'test';
        resItem.MITEM            = 'test';
        resItem.ATP_QTY          = 'test';
        resItem.LANDX            = 'test';
        resItem.MTPOS            = 'test';
        resItem.RT_QTY           = 'test';
        resItem.HQ_QTY           = 'test';
        res.T_ITEM.add(resItem);
        
        Test.stopTest();
    }
}