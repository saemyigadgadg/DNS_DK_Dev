/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-21-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-21-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Parts_Multipart {
    public IF_ERP_Parts_Multipart() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Parts_Multipart';
    private Boolean isResponseXml = true; 
    private String  interfaceId;

    /** SFDC interface Id    : IF-PARTS-022
     * RFC Name              : ZCRM_EP_PARTS_STANDARD_ME_SR
     * Description           : Parts > 부품정보 > 멀티부품정보조회
        */
        public IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res IF_PARTS_022(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req parameters){
            parameters.I_LANGU = interfaceUtil.getLanguageKey(parameters.I_LANGU);

            parameters.I_LANGU = parameters.I_LANGU == null ? '' : parameters.I_LANGU;
            parameters.I_KVGR5 = parameters.I_KVGR5 == null ? '' : parameters.I_KVGR5;

            for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL : parameters.D_DETAIL){
                D_DETAIL.MATNR        = D_DETAIL.MATNR        == null ? '' : D_DETAIL.MATNR;
                D_DETAIL.MAKTX        = D_DETAIL.MAKTX        == null ? '' : D_DETAIL.MAKTX;
                D_DETAIL.SVC_FLAG     = D_DETAIL.SVC_FLAG     == null ? '' : D_DETAIL.SVC_FLAG;
                D_DETAIL.AVA_FLAG     = D_DETAIL.AVA_FLAG     == null ? '' : D_DETAIL.AVA_FLAG;
                D_DETAIL.NOTCD        = D_DETAIL.NOTCD        == null ? '' : D_DETAIL.NOTCD;
                D_DETAIL.COND_VALUE   = D_DETAIL.COND_VALUE   == null ? '' : D_DETAIL.COND_VALUE;
                D_DETAIL.NETPR        = D_DETAIL.NETPR        == null ? '' : D_DETAIL.NETPR;
                D_DETAIL.IF_CURRENCY  = D_DETAIL.IF_CURRENCY  == null ? '' : D_DETAIL.IF_CURRENCY;
                D_DETAIL.NETPR_ETC    = D_DETAIL.NETPR_ETC    == null ? '' : D_DETAIL.NETPR_ETC;
                D_DETAIL.CURRENCY2    = D_DETAIL.CURRENCY2    == null ? '' : D_DETAIL.CURRENCY2;
                D_DETAIL.KWMENG       = D_DETAIL.KWMENG       == null ? '' : D_DETAIL.KWMENG;
                D_DETAIL.AUMNG        = D_DETAIL.AUMNG        == null ? '' : D_DETAIL.AUMNG;
                D_DETAIL.LFMNG        = D_DETAIL.LFMNG        == null ? '' : D_DETAIL.LFMNG;
                D_DETAIL.MEINS        = D_DETAIL.MEINS        == null ? '' : D_DETAIL.MEINS;
                D_DETAIL.BRGEW        = D_DETAIL.BRGEW        == null ? '' : D_DETAIL.BRGEW;
                D_DETAIL.NTGEW        = D_DETAIL.NTGEW        == null ? '' : D_DETAIL.NTGEW;
                D_DETAIL.GEWEI        = D_DETAIL.GEWEI        == null ? '' : D_DETAIL.GEWEI;
                D_DETAIL.GROES        = D_DETAIL.GROES        == null ? '' : D_DETAIL.GROES;
                D_DETAIL.PRODH        = D_DETAIL.PRODH        == null ? '' : D_DETAIL.PRODH;
                D_DETAIL.PRODH_T      = D_DETAIL.PRODH_T      == null ? '' : D_DETAIL.PRODH_T;
                D_DETAIL.BULET        = D_DETAIL.BULET        == null ? '' : D_DETAIL.BULET;
                D_DETAIL.ZPRAT        = D_DETAIL.ZPRAT        == null ? '' : D_DETAIL.ZPRAT;
                D_DETAIL.HERKL        = D_DETAIL.HERKL        == null ? '' : D_DETAIL.HERKL;
                D_DETAIL.PLIFZ        = D_DETAIL.PLIFZ        == null ? '' : D_DETAIL.PLIFZ;
                D_DETAIL.M_MATNR      = D_DETAIL.M_MATNR      == null ? '' : D_DETAIL.M_MATNR;
                D_DETAIL.C_MTPOS      = D_DETAIL.C_MTPOS      == null ? '' : D_DETAIL.C_MTPOS;
                D_DETAIL.DATAB        = D_DETAIL.DATAB        == null ? '' : D_DETAIL.DATAB;
                D_DETAIL.KONDM        = D_DETAIL.KONDM        == null ? '' : D_DETAIL.KONDM;
                D_DETAIL.VTEXT        = D_DETAIL.VTEXT        == null ? '' : D_DETAIL.VTEXT;
                D_DETAIL.NOTCD_TEXT   = D_DETAIL.NOTCD_TEXT   == null ? '' : D_DETAIL.NOTCD_TEXT;
                D_DETAIL.SVRCD        = D_DETAIL.SVRCD        == null ? '' : D_DETAIL.SVRCD;
                D_DETAIL.AVAIL_QTY    = D_DETAIL.AVAIL_QTY    == null ? '' : D_DETAIL.AVAIL_QTY;
                D_DETAIL.AVAIL_QTY2   = D_DETAIL.AVAIL_QTY2   == null ? '' : D_DETAIL.AVAIL_QTY2;
                D_DETAIL.THREAD       = D_DETAIL.THREAD       == null ? '' : D_DETAIL.THREAD;
                D_DETAIL.D_MATERIAL   = D_DETAIL.D_MATERIAL   == null ? '' : D_DETAIL.D_MATERIAL;
                D_DETAIL.MANUFACT     = D_DETAIL.MANUFACT     == null ? '' : D_DETAIL.MANUFACT;
                D_DETAIL.REPLACE      = D_DETAIL.REPLACE      == null ? '' : D_DETAIL.REPLACE;
                D_DETAIL.SUB_MATERIAL = D_DETAIL.SUB_MATERIAL == null ? '' : D_DETAIL.SUB_MATERIAL;
                D_DETAIL.SVCLT        = D_DETAIL.SVCLT        == null ? '' : D_DETAIL.SVCLT;
            }

            parameters.I_USERINFO.BNAME  = parameters.I_USERINFO.BNAME   == null ? '' : parameters.I_USERINFO.BNAME;
            parameters.I_USERINFO.RNAME  = parameters.I_USERINFO.RNAME   == null ? '' : parameters.I_USERINFO.RNAME;
            parameters.I_USERINFO.HIER   = parameters.I_USERINFO.HIER    == null ? '' : parameters.I_USERINFO.HIER;
            parameters.I_USERINFO.KUNNR  = parameters.I_USERINFO.KUNNR   == null ? '' : parameters.I_USERINFO.KUNNR;
            parameters.I_USERINFO.LIFNR  = parameters.I_USERINFO.LIFNR   == null ? '' : parameters.I_USERINFO.LIFNR;
            parameters.I_USERINFO.VKORG  = parameters.I_USERINFO.VKORG   == null ? '' : parameters.I_USERINFO.VKORG;
            parameters.I_USERINFO.VTWEG  = parameters.I_USERINFO.VTWEG   == null ? '' : parameters.I_USERINFO.VTWEG;
            parameters.I_USERINFO.SPART  = parameters.I_USERINFO.SPART   == null ? '' : parameters.I_USERINFO.SPART;
            parameters.I_USERINFO.WERKS  = parameters.I_USERINFO.WERKS   == null ? '' : parameters.I_USERINFO.WERKS;
            parameters.I_USERINFO.ARBPL  = parameters.I_USERINFO.ARBPL   == null ? '' : parameters.I_USERINFO.ARBPL;
            parameters.I_USERINFO.PARNR  = parameters.I_USERINFO.PARNR   == null ? '' : parameters.I_USERINFO.PARNR;
            parameters.I_USERINFO.ENAME  = parameters.I_USERINFO.ENAME   == null ? '' : parameters.I_USERINFO.ENAME;
            parameters.I_USERINFO.KUNN2  = parameters.I_USERINFO.KUNN2   == null ? '' : parameters.I_USERINFO.KUNN2;
            parameters.I_USERINFO.LAND1  = parameters.I_USERINFO.LAND1   == null ? '' : parameters.I_USERINFO.LAND1;
            parameters.I_USERINFO.LGORT  = parameters.I_USERINFO.LGORT   == null ? '' : parameters.I_USERINFO.LGORT;
            parameters.I_USERINFO.DF_CHK = parameters.I_USERINFO.DF_CHK  == null ? '' : parameters.I_USERINFO.DF_CHK;
            parameters.I_USERINFO.CO_CHK = parameters.I_USERINFO.CO_CHK  == null ? '' : parameters.I_USERINFO.CO_CHK;

            interfaceId = 'IF-PARTS-022';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            interfaceUtil.isFieldNotNull = true;
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res response = 
                (IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res) JSON.deserialize(responseString, IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res.class);
            
            return response;
        }
}