/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-05-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Parts_Return {
    public IF_ERP_Parts_Return() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Parts_Return';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    /** SFDC interface Id   : IF-PARTS-017
     * AS-IS RFC            : Z_EP_INVOICELIST
     * New I/F              : ZCRM_EP_INVOICELIST
     * Description          : 반품대상 조회
        */
        public IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res IF_PARTS_017(IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req parameters){
            interfaceId = 'IF-PARTS-017';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res response = 
                (IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res) JSON.deserialize(responseString, IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res.class);
            
            return response;
        }

    /** SFDC interface Id   : IF-PARTS-018
     *  AS-IS RFC            : Z_SD_CREATE_SALES_ORDER_DIA
     *  New I/F              : ZCRM_SD_CREATE_SALES_ORDER_USA
     *  Description          : 반품생성 저장
        */
        public IF_ERP_Parts_Return_Classes.IF_PARTS_018_Res IF_PARTS_018(IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req parameters){
            List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE>    T_FILE     = parameters.T_FILE;     
            
            for (IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE T_FILE_E : T_FILE) {
                if(T_FILE_E.FILE_NAME   != null) T_FILE_E.FILE_NAME      = EncodingUtil.urlEncode(T_FILE_E.FILE_NAME, 'UTF-8');
                if(T_FILE_E.DESCRIPTION != null) T_FILE_E.DESCRIPTION    = EncodingUtil.urlEncode(T_FILE_E.DESCRIPTION, 'UTF-8');
            }

            parameters.T_FILE = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE>();
            
            interfaceId = 'IF-PARTS-018';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            parametersString = encodeForSAP(parametersString);           
            
            parametersString = parametersString.replace('"T_FILE":[]', '"T_FILE":' + Json.serialize(T_FILE));

            interfaceUtil.isCustomURLEncode = true;
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Return_Classes.IF_PARTS_018_Res response = 
                (IF_ERP_Parts_Return_Classes.IF_PARTS_018_Res) JSON.deserialize(responseString, IF_ERP_Parts_Return_Classes.IF_PARTS_018_Res.class);
            
            return response;
        }

    /** SFDC interface Id   : IF-PARTS-019
     * AS-IS RFC            : Z_EP_ORDERLIST
     * New I/F              : ZCRM_EP_ORDERLIST
     * Description          : 반품 목록 조회
        */ 
        public IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res IF_PARTS_019(IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req parameters){
            interfaceId = 'IF-PARTS-019';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res response = 
                (IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res) JSON.deserialize(responseString, IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res.class);
            
            return response;
        }

    /** IF-PARTS-028 (전달필요)
     *  RFC Name             : ZCRM_EP_ORDER_DELETE_ME
     *  Description          : 반품 대상 삭제
        */
        public IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res IF_PARTS_028(IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req parameters){
            interfaceId = 'IF-PARTS-028';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res response = 
                (IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res) JSON.deserialize(responseString, IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res.class);
            
            return response;
        }

        private String encodeForSAP(String jsonString){
            jsonString = EncodingUtil.urlEncode(jsonString, 'UTF-8');
            jsonString = jsonString.replaceAll('%3D', '=');
            jsonString = jsonString.replaceAll('%7B', '{');
            jsonString = jsonString.replaceAll('%22', '"');
            jsonString = jsonString.replaceAll('%3A', ':');
            jsonString = jsonString.replaceAll('%7D', '}');  
            jsonString = jsonString.replaceAll('%5B', '[');  
            jsonString = jsonString.replaceAll('%5D', ']');  
    
            return jsonString;
        }
}