public with sharing class IF_ERP_Service_PartStat {
    public IF_ERP_Service_PartStat() {}
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String apexClassName        = 'IF_ERP_Service_PartStat';
    private Boolean isResponseXml       = true;    
    private String interfaceId;

/** IF_SERVICE_035
    */  
    /**
         * ClassName            : IF_ERP_Service_PartStat 
         * Wrapper Name         : IF_SERVICE_035
         * SFDC interface Id    : IF-SERVICE-035
         * AS-IS RFC            : Z_CS_WEB_SVC_PARTS
         * New I/F              : ZCRM_CS_WEB_SVC_PARTS
         * Description          : 청구부품 불출 현황 조회
     */
    public IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Res IF_SERVICE_035(IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Req parmeters){
        interfaceId = 'IF-SERVICE-035';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        // responseString  = responseString.substringAfter('"Output":').substringBeforeLast('}');

        IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Res response = 
                (IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Res.class);
    
        System.debug('response : ' + response);

        return response;
    }
     
}